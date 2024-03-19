/* ---------------------------------------------------------------------------------------------------------------------
Name:            LogTrigger.cls
Description:     Trigger on Log__c Object
Test class:      TestLogTrigger.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
15-Mar-2021  0.2      M.Siotto & A.Smiriglia          Run HandleMappingSyncBatch() batch on After Insert for DataMapper Logs
25-Mar-2021  0.3      G.Mameli & M.Siotto             Set dataMapperScopeSize from BatchProcess__c custom setting
08-Apr-2021  0.4      G.Mameli & C.Sanna              Introduced secureAccess (from SecuritySettings__c custom setting) to skip FLS
                                                      controls when set to true.
21-Apr-2021  0.6      G.Mameli                        Introduced isBatch() check on processing DataMapper Logs. When DataMapper
                                                      Logs are created by a batch, then HandleMappingSyncBatch() is scheduled
                                                      waitingMins minutes after now.
----------------------------------------------------------------------------------------------------------------------*/

//Trigger che scatta al momento in cui Talend crea un Log con il campo Sender='TALEND' e che i CSV caricati
//(sotto i contratti indicati nel campo "Msg Input") siano > 0

trigger LogTrigger on Log__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    Boolean isBatchInbActive = TagHelper.getValueBoolean('isBatchInbActive');
    public static Map<String, Schema.RecordTypeInfo> nameID;
    public static Set<Id> processedRecords;

    if (processedRecords == null) processedRecords = new Set<Id>();
    public static List<Log__c> dataMapperLogs = new List<Log__c>();
    public static Integer dataMapperScopeSize = MappingUtils.getDataMapperScopeSize();
    public static Integer waitingMins = MappingUtils.getSchedulerDataMapperWaitingTime();

    //New process for integration
    if (Trigger.isAfter && Trigger.isInsert) {

        //List<String> idContracts = new List<String>();
        //Map<String, String> cl = new Map<String, String>();
        try {
            for (Log__c log : Trigger.new) {
                if (log.RecordTypeId == getRecordTypeId('DataMapper')) {
                    dataMapperLogs.add(log);
                }
                if (isBatchInbActive) {
                    if (processedRecords.contains(log.Id)) continue;

                    if (log.RecordTypeId != getRecordTypeId('Integration')) continue;
                    processedRecords.add(log.Id);

                    if (log.Message_In__c != null && log.Message_In__c != '') {
                        BatchQueue.reqBatch('IPAB', 'IntegrationProcessAttachmentBatch', 0, 1, log.Id, null);
                        BatchQueue.runBatches();
                        for (String s : log.Message_In__c.split(';')) {
                            //cl.put(s,log.id);

                        }
                    }
                }
                /*if(cl!=null && !cl.isempty()  && cl.keyset()!=null && cl.keyset().size()>0){
                    try{
                        IntegrationProcessAttachmentBatch  attBatch = new IntegrationProcessAttachmentBatch(cl);
                        Id batchInstanceId = Database.executeBatch(attBatch, 1);
                    }
                    catch(Exception e){
                        system.debug('LOGLOGLOGLOF:'+ e.getMessage() +'\n'+e.getLineNumber()+'\n' +e.getStackTraceString());
                    }
                }*/
            }

            /* -------------------------------------------------------------------------------------------------------------
            Author: A.Smiriglia, M.Siotto
            Company: Balance
            Description: This piece of code is for Data Mapping. It checks if it doesn't exists a processing
                         HandleMappingSyncBatch Apex Job to execute the HandleMappingSyncBatch batch for DataMapper Logs.
            ------------------------------------------------------------------------------------------------------------- */

            if (dataMapperLogs.size() > 0) {
                String queryJobsList = 'SELECT ApexClass.Name, Status, CreatedById, ApexClassId, ParentJobId, LastProcessed, LastProcessedOffset, CreatedDate FROM AsyncApexJob WHERE ApexClass.Name = \'HandleMappingSyncBatch\' AND Status NOT IN (\'Completed\',\'Aborted\')';
                if (!MappingUtils.secureAccess) queryJobsList += ' WITH SECURITY_ENFORCED';
                List<AsyncApexJob> jobsList = Database.query(queryJobsList);

                if (jobsList.size() == 0) {
                    if (System.isBatch() || Test.isRunningTest()) {

                        String nextFireTime = setNextFireTime();

                        String schName = 'DataMapper Log ' + String.valueOf(System.today());

                        String queryCronJobsList = 'SELECT Id, CronJobDetailId, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name =: schName';
                        if (!MappingUtils.secureAccess) queryCronJobsList += ' WITH SECURITY_ENFORCED';
                        List<CronTrigger> cronJobsList = Database.query(queryCronJobsList);
                        if (cronJobsList.size() == 0) {
                            System.schedule(schName, nextFireTime, new HandleMappingSyncBatchScheduler(dataMapperScopeSize));
                        }
                    } else {
                        Database.executeBatch(new HandleMappingSyncBatch(), dataMapperScopeSize);
                    }
                }

            }

        } catch (Exception ex) {
            Log__c log = new Log__c();
            log.Message__c = 'LogTrigger Exception: ' + ex.getMessage();
            log.Class_Name__c = 'LogTrigger';
            log.Object__c = 'Log__c';
            insert log;
        }
    }

    public static Id getRecordTypeId(String RecordTypeDeveloperName) {

        if (nameID == null) {
            nameID = Schema.SObjectType.Log__c.getRecordTypeInfosByDeveloperName();
        }

        return nameID.get(RecordTypeDeveloperName).getRecordTypeId();
    }

    /*
    Method used for DataMapper Logs to set the next scheduled time, adding the waiting minutes stored in
    HandleMappingSyncBatchScheduler Batch Process custom setting, when the mapping is trigger by a batch
    */
    public static String setNextFireTime() {
        String nextFireTime;
        Integer hourInt = Datetime.now().hour();
        Integer minInt = Datetime.now().minute() + waitingMins;

        if (minInt > 59) {
            hourInt = hourInt + 1;
            minInt = waitingMins;
        }

        String hour = String.valueOf(hourInt);
        String min = String.valueOf(minInt);
        String ss = String.valueOf(Datetime.now().second());

        nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';

        return(nextFireTime);

    }

}