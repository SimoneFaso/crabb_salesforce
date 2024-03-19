/* -----------------------------------------------------------------------------------------------------------------------------------
Name:            MappingUtils.cls
Description:     Batch invoked by Crabb Administration page to process all existing records to be mapped through Data Mapper
                 utility, mapping all Source Objects records to Target Objects records
Test class:

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  --------------------------------------------------------------------------------
30-Mar-2021  0.1      M.Siotto                        First Version (Not Committed)
-------------------------------------------------------------------------------------------------------------------------------------*/

global without sharing class HandleMappingMigrationBatch implements Database.Batchable<sObject>, Database.Stateful{

    String source;
    String target;
    String query;
    List<CRABB_DEV__Log__c> logList;
    List<String> source_target;
    Set<Id> extIdSet = new Set<Id>();
    Map<String,String> mappingRT = MappingUtils.getRecordTypesMapping();
    Integer mappingMigrationScopeSize = MappingUtils.getMappingMigrationScopeSize();
    global static Boolean secureAccess = CRABB_DEV__SecuritySettings__c.getInstance().CRABB_DEV__isSecure__c;

    public HandleMappingMigrationBatch(){
        List<CRABB_DEV__Mapping__c> source_targetList = [SELECT CRABB_DEV__SourceObj__c,CRABB_DEV__TargetObj__c FROM CRABB_DEV__Mapping__c WITH SECURITY_ENFORCED ORDER BY CRABB_DEV__SourceObj__c];
        source_target = new List<String>();
        Set<String> source_target_Set = new Set<String>();
        for(CRABB_DEV__Mapping__c st : source_targetList) {
            source_target_Set.add(st.CRABB_DEV__SourceObj__c+'~'+st.CRABB_DEV__TargetObj__c);
        }
        this.source_target.addAll(source_target_Set);
        this.source = source_target.get(0).split('~').get(0);
        this.target = source_target.get(0).split('~').get(1);

        List<String> MappingSourceFields = MappingUtils.getMappingFieldsST(source,target);
        query = 'SELECT ' + String.join(MappingSourceFields,',') + ' FROM ' + source;
    }

    public HandleMappingMigrationBatch(List<String> source_target){
        this.source_target = source_target;
        this.source = source_target.get(0).split('~').get(0);
        this.target = source_target.get(0).split('~').get(1);

        List<String> MappingSourceFields = MappingUtils.getMappingFieldsST(source,target);
        query = 'SELECT ' + String.join(MappingSourceFields,',') + ' FROM ' + source;
    }



    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext bc, List<sObject> records){
        // process each batch of records
        logList = new List<CRABB_DEV__Log__c>();
        Id recordTypeId = Schema.SObjectType.Log__c.getRecordTypeInfosByDeveloperName().get('DataMapper').getRecordTypeId();

        for(sObject sobj : records) {
            String jsonToSave = JSON.serialize(sobj);
            logList.add(MappingUtils.buildLog(jsonToSave,source,String.valueOf(sobj.id),'insert',mappingRT.get(source+'~'+target),String.valueOf(recordTypeId)));
        }
    }


    global void finish(Database.BatchableContext bc){
        Database.SaveResult[] saveResults;
        if(MappingUtils.secureAccess || (Utils.checkObjPermission('Log__c').get('INSERT') && logList.size() > 0)) {
            saveResults = Database.insert(logList);
        }

        for(Database.SaveResult sRes : saveResults) {
            System.debug('source start --> ' + source + ' target start --> ' + target + ' sRes --> ' + sRes);
        }

        source_target.remove(0);

        if(source_target.size() != 0) {
            Database.executeBatch(new HandleMappingMigrationBatch(source_target), mappingMigrationScopeSize);
        }
    }
    
}