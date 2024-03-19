/* ---------------------------------------------------------------------------------------------------------------------
Name:            HandleMappingDeletionBatch.cls
Description:     Batch to delete DataMapper processed Logs
Test class:      TestDataMapper.cls & TestLogTrigger.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
16-Mar-2017  0.1      M.Siotto & A.Smiriglia          First Version
25-Mar-2021  0.2      G.Mameli & M.Siotto             Set dataMapperScopeSize from BatchProcess__c custom setting
31-Mar-2021  0.3      M.Siotto                        Set the Class without sharing, introduced secureAccess
                                                      (from SecuritySettings__c custom setting) to skip FLS controls
                                                      when set to true and introduced WITH SECURITY_ENFORCED on queries.
21-Apr-2021  0.4      G.Mameli                        Added in finish the deletion of the Scheduled Apex Job related to
                                                      the current Apex Job execution, when all Log records are processed.
----------------------------------------------------------------------------------------------------------------------*/

global without sharing class HandleMappingDeletionBatch implements Database.Batchable<SObject>, Database.Stateful {
    String query;
    Boolean restart;
    Integer dataMapperScopeSize = MappingUtils.getDataMapperScopeSize();
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    global HandleMappingDeletionBatch(Boolean restart) {
        System.debug('HandleMappingDeletionBatch restart Start -->' + restart);
        this.restart = restart;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String DataMapper = 'DataMapper';
        //Collect all CRABB_DEV__Log__c records (with field CRABB_DEV__Integration_processed__c = true) to be passed to execute
        query = 'SELECT Id from CRABB_DEV__Log__c where RecordType.Name = :DataMapper and CRABB_DEV__Integration_processed__c = true';
        if (!MappingUtils.secureAccess) query += ' WITH SECURITY_ENFORCED';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<CRABB_DEV__Log__c> records) {
        if (MappingUtils.secureAccess || (Utils.cebCheckObjPermission('Log__c', gd).get('DELETE') && records.size() > 0)) delete records;
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('HandleMappingDeletionBatch restart Finish -->' + restart);
        if (restart) {
            Database.executeBatch(new HandleMappingSyncBatch(), dataMapperScopeSize);
        }

        List<CronTrigger> cronJobsList = new List<CronTrigger>();
        cronJobsList = [SELECT Id, CronJobDetailId, CronJobDetail.Name
                        FROM CronTrigger
                        WHERE CronJobDetail.Name LIKE '%DataMapper Log%'
        ];

        //Delete Scheduled Apex Jobs related to already processed HandleMappingSyncBatch and HandleMappingDeletionBatch batches
        for (CronTrigger job : cronJobsList) {
            System.abortJob(job.Id);

        }
    }
}