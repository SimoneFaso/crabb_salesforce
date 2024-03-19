/* ---------------------------------------------------------------------------------------------------------------------
Name:            HandleMappingSyncBatch.cls
Description:     Batch to process DataMapper Logs, mapping Source to Target Objects
Test class:      TestDataMapper.cls & TestLogTrigger.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
10-Mar-2017  0.1      M.Siotto & A.Smiriglia          First Version
31-Mar-2021  0.4      M.Siotto                        Set the Class without sharing, introduced secureAccess
                                                      (from SecuritySettings__c custom setting) to skip FLS controls
                                                      when set to true and introduced WITH SECURITY_ENFORCED on queries
----------------------------------------------------------------------------------------------------------------------*/
 
global without sharing class HandleMappingSyncBatch implements Database.Batchable<SObject>, Database.Stateful {
    String query;
    String DataMapper = 'DataMapper';
    List<String> source_target;
    String source;
    String target;
    Boolean reworkL;
    Integer deleteLogsScopeSize = MappingUtils.getDeleteLogsScopeSize();
    Integer dataMapperScopeSize = MappingUtils.getDataMapperScopeSize();

    global HandleMappingSyncBatch() {
        String querySourceTargetList = 'SELECT Id,CRABB_DEV__SourceObj__c,CRABB_DEV__TargetObj__c FROM CRABB_DEV__Mapping__c ';
        if(!MappingUtils.secureAccess) {
            querySourceTargetList+= ' WITH SECURITY_ENFORCED ORDER BY CRABB_DEV__SourceObj__c';
        } else {
            querySourceTargetList+= ' ORDER BY CRABB_DEV__SourceObj__c';
        }
        List<CRABB_DEV__Mapping__c> source_targetList = Database.query(querySourceTargetList);
        source_target = new List<String>();
        Set<String> source_target_Set = new Set<String>();
        for(CRABB_DEV__Mapping__c st : source_targetList) {
            source_target_Set.add(st.CRABB_DEV__SourceObj__c+'~'+st.CRABB_DEV__TargetObj__c);
        }

        this.source_target.addAll(source_target_Set);
        this.source = source_target.get(0).split('~').get(0);
        this.target = source_target.get(0).split('~').get(1);

        query = 'SELECT CRABB_DEV__Integration_Json_file_data__c, CRABB_DEV__Object__c , CRABB_DEV__type__c , CRABB_DEV__CS_Nome_Servizio__c , ' +
                'CRABB_DEV__info__c, CRABB_DEV__Integration_processed__c, RecordType.name FROM CRABB_DEV__Log__c WHERE RecordType.name = :DataMapper AND ' +
                'CRABB_DEV__type__c = :source AND CRABB_DEV__Integration_processed__c = false AND CRABB_DEV__Error_code__c = null';
        if(!MappingUtils.secureAccess) {
            query+= ' WITH SECURITY_ENFORCED ORDER BY CRABB_DEV__type__c';
        }
        else {
            query+= ' ORDER BY CRABB_DEV__type__c';
        }
        System.debug('HandleMappingSyncBatch rework query --> ' + query);
    }

    global HandleMappingSyncBatch(List<String> source_target, Boolean reworkLogs) {
        this.reworkL = reworkLogs;
        System.debug('#### rework log --> ' + reworkL);
        this.source_target = source_target;
        this.source = source_target.get(0).split('~').get(0);
        this.target = source_target.get(0).split('~').get(1);
        query = 'SELECT CRABB_DEV__Integration_Json_file_data__c, CRABB_DEV__Object__c , CRABB_DEV__type__c , CRABB_DEV__CS_Nome_Servizio__c , ' +
                'CRABB_DEV__info__c, CRABB_DEV__Integration_processed__c, RecordType.name FROM CRABB_DEV__Log__c WHERE RecordType.name = :DataMapper AND ' +
                'CRABB_DEV__type__c = :source AND CRABB_DEV__Integration_processed__c = :reworkL AND CRABB_DEV__Error_code__c = null';
        if(!MappingUtils.secureAccess) {
            query+= ' WITH SECURITY_ENFORCED ORDER BY CRABB_DEV__type__c';
        }
        else {
            query+= ' ORDER BY CRABB_DEV__type__c';
        }
        System.debug('HandleMappingSyncBatch rework query --> ' + query);
    }

    global Database.QueryLocator start (Database.BatchableContext bc) {
        //Collect the CRABB_DEV__Log__c records or objects to be passed to execute
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<CRABB_DEV__Log__c> records) {
        // Process each batch of CRABB_DEV__Log__c records
        DataMapperApi.getAllMapsContainer(source, target);
        for (CRABB_DEV__Log__c log : records) {
            DataMapperApi.DataMapperApiSetValues(log.CRABB_DEV__type__c, log.CRABB_DEV__CS_Nome_Servizio__c, log.CRABB_DEV__info__c);
            Map<String, Object> jsonMap =   (Map<String, Object>) JSON.deserializeUntyped(log.CRABB_DEV__Integration_Json_file_data__c);

            Boolean result = DataMapperApi.syncMapObjects(jsonMap);
            if(!result) {
                log.CRABB_DEV__Error_code__c = 'fieldConversion: '+String.valueOf(result);
                //log.CRABB_DEV__Integration_processed__c = true;
            }// else {
                log.CRABB_DEV__Integration_processed__c = true;
            //}
        }

        DataMapperApi.buildLists(target);
        Boolean singleRunResult = DataMapperApi.doOperation();
        DataMapperApi.insertErrorsOnMapping();
        update records;
    }

    global void finish(Database.BatchableContext bc) {
        Boolean reworkLogs = false;
        Boolean restart = false;
        String prevSource = source_target.get(0).split('~').get(0);
        String nextSource;
        if (source_target.size() > 1) {
            nextSource = source_target.get(1).split('~').get(0);
            if(prevSource == nextSource) reworkLogs = true;
        }

        query = 'SELECT count() from CRABB_DEV__Log__c where RecordType.name = :DataMapper and CRABB_DEV__Integration_processed__c = false';
        if(!MappingUtils.secureAccess) query+= ' WITH SECURITY_ENFORCED';
        source_target.remove(0);
        if(source_target.size() != 0) {
            Database.executeBatch(new HandleMappingSyncBatch(source_target, reworkLogs),dataMapperScopeSize);
        } else {
            Integer count = Database.countQuery(query);
            String queryJobsList = 'SELECT ApexClass.Name,Status, CreatedById, ApexClassId, ParentJobId, LastProcessed, LastProcessedOffset, CreatedDate  FROM AsyncApexJob WHERE ApexClass.Name = \'HandleMappingSyncBatch\' AND Status NOT IN (\'Completed\',\'Aborted\')';
            if(!MappingUtils.secureAccess) queryJobsList+= ' WITH SECURITY_ENFORCED';
            List<AsyncApexJob> jobsList = Database.query(queryJobsList);

            //If there aren't others HandleMappingSyncBatch in progress/failed/queued end all and delete DataMapper Logs
            System.debug('HandleMappingSyncBatch jobsList.size() --> '+jobsList.size());
            if(jobsList.size() == 0 && count > 0) {
                restart = true;
                //Database.executeBatch(new HandleMappingSyncBatch());
            }
            System.debug('HandleMappingSyncBatch restart --> '+restart);
            Database.executeBatch(new HandleMappingDeletionBatch(restart), deleteLogsScopeSize);
        }
    }

}