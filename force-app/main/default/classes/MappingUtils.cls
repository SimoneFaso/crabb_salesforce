/* ---------------------------------------------------------------------------------------------------------------------
Name:            MappingUtils.cls
Description:     Utils class for Mapping. To be used in Target Objects Triggers
Test class:      TestDataMapper.cls & TestLogTrigger.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
16-Mar-2021  0.1      M.Siotto & A.Smiriglia          First Version
25-Mar-2021  0.2      M.Siotto & G.Mameli             Added getDataMapperScopeSize and getDeleteLogsScopeSize Methods
30-Mar-2021  0.3      M.Siotto                        Added getRecordTypesMapping method
31-Mar-2021  0.4      M.Siotto                        Added getMappingMigrationScopeSize and introduced secureAccess
                                                      (from SecuritySettings__c custom setting) to skip FLS controls when
                                                      set to true.
06-Apr-2021  0.5      M.Siotto                        Added getMappingFieldsST method
21-Apr-2021  0.6      G.Mameli                        Added getSchedulerDataMapperWaitingTime method
----------------------------------------------------------------------------------------------------------------------*/

global without sharing class MappingUtils {
    global static Boolean alreadyRun = false;
    global static Integer dataMapperScopeSize;
    global static Integer deleteLogsScopeSize;
    global static Boolean secureAccess = CRABB_DEV__SecuritySettings__c.getInstance().CRABB_DEV__isSecure__c;
    public static final String DATAMAPPER_RTID = Schema.SObjectType.CRABB_DEV__Log__c.getRecordTypeInfosByDeveloperName().get('DataMapper').getRecordTypeId();

    //To create a Log record from Source Object record
    global static CRABB_DEV__Log__c buildLog(String jsonToSave, String type, String objId, String operation, String recordType, String recordTypeId) {
        CRABB_DEV__Log__c log = new CRABB_DEV__Log__c();

        //log.CRABB_DEV__Object__c = ObjId;
        log.CRABB_DEV__External_Id__c = objId;
        log.CRABB_DEV__type__c = type;
        log.CRABB_DEV__CS_Nome_Servizio__c = operation;
        log.CRABB_DEV__info__c = recordType;
        log.RecordTypeId = recordTypeId;
        log.CRABB_DEV__Integration_Json_file_data__c = jsonToSave;
        return log;
    }

    //getUniqueList due to possible different destination for the same source field
    global static List<String> getMappingFields(String objType) {
        String allMappingQuery = 'SELECT CRABB_DEV__SourceField__c  FROM CRABB_DEV__Mapping__c where CRABB_DEV__SourceObj__c= :objType';
        if(secureAccess == false) allMappingQuery += ' WITH SECURITY_ENFORCED';
        List<CRABB_DEV__Mapping__c> allMapping = Database.query(allMappingQuery);
        Set<String> uniqueFields = new Set<String>();

        for(CRABB_DEV__Mapping__c mp : allMapping) {
            uniqueFields.add(mp.CRABB_DEV__SourceField__c);
        }

        return new List<String>(uniqueFields);
    }

    global static List<String> getMappingFieldsST(String sourceObjType, String targetObjType) {
        String allMappingQuery = 'SELECT CRABB_DEV__SourceField__c  FROM CRABB_DEV__Mapping__c where CRABB_DEV__SourceObj__c= :sourceObjType and CRABB_DEV__TargetObj__c = :targetObjType';
        if(secureAccess == false) allMappingQuery += ' WITH SECURITY_ENFORCED';
        List<CRABB_DEV__Mapping__c> allMapping = Database.query(allMappingQuery);
        Set<String> uniqueFields = new Set<String>();

        for(CRABB_DEV__Mapping__c mp : allMapping) {
            uniqueFields.add(mp.CRABB_DEV__SourceField__c);
        }

        return new List<String>(uniqueFields);
    }

    //To get the External_Id__c field as Sobject Field
    global static SObjectField getSobjectExternalId(){
        Schema.SObjectField externalIDField = ((SObject) (Type.forName('Schema.' + 'Log__c').newInstance())).getSObjectType().getDescribe().fields.getMap().get('CRABB_DEV__External_Id__c');
        return externalIDField;
    }

    //To get the proper batch scopeSize for HandleMappingSyncBatch from the related BatchProcess__c custom setting
    global static Integer getDataMapperScopeSize(){
        CRABB_DEV__BatchProcess__c batchProcess = CRABB_DEV__BatchProcess__c.getValues('HandleMappingSyncBatch');
        Integer dataMapperScopeSize = batchProcess != null ? Integer.valueOf(batchProcess.CRABB_DEV__ScopeSize__c) : 25;

        return dataMapperScopeSize;

    }

    //To get the proper batch scopeSize for HandleMappingDeletionBatch from the related BatchProcess__c custom setting 
    global static Integer getDeleteLogsScopeSize(){
        CRABB_DEV__BatchProcess__c batchProcess = CRABB_DEV__BatchProcess__c.getValues('HandleMappingDeletionBatch');
        Integer deleteLogsScopeSize = batchProcess != null ? Integer.valueOf(batchProcess.CRABB_DEV__ScopeSize__c) : 25;

        return deleteLogsScopeSize;

    }

    //To get the proper batch scopeSize for HandleMappingMigrationBatch from the related BatchProcess__c custom metadata
    global static Integer getMappingMigrationScopeSize(){
        CRABB_DEV__BatchProcess__c batchProcess = CRABB_DEV__BatchProcess__c.getValues('HandleMappingMigrationBatch');
        Integer mappingMigrationScopeSize = batchProcess != null ? Integer.valueOf(batchProcess.CRABB_DEV__ScopeSize__c) : 25;

        return mappingMigrationScopeSize;

    }

    //To get the proper record type HandleMappingMigrationBatch from the related mapping_migration custom setting
    global static Map<String,String> getRecordTypesMapping() {
        String queryMappingRTList = 'SELECT Id, CRABB_DEV__Source_Object__c, CRABB_DEV__Target_Object__c, CRABB_DEV__Target_Record_Type__c FROM CRABB_DEV__CRABB_Mapping_Migration__mdt';
        if(!secureAccess) queryMappingRTList += ' WITH SECURITY_ENFORCED';
        List<CRABB_DEV__CRABB_Mapping_Migration__mdt> mappingRTList = (List<CRABB_DEV__CRABB_Mapping_Migration__mdt>) Database.query(queryMappingRTList);

        Map<String, String> mapRecordTypes = new Map<String, String>();

        for (CRABB_DEV__CRABB_Mapping_Migration__mdt mappingRT : mappingRTList) {
            mapRecordTypes.put(mappingRT.CRABB_DEV__Source_Object__c+'~'+mappingRT.CRABB_DEV__Target_Object__c, mappingRT.CRABB_DEV__Target_Record_Type__c);
        }

        return mapRecordTypes;
    }

    //Used in LogTrigger to get the proper number of minutes to wait to schedule HandleMappingDeletionBatchScheduler when
    //source records are updated by a batch (HandleMappingSyncBatch cannot be called from a batch)
    global static Integer getSchedulerDataMapperWaitingTime(){
        CRABB_DEV__BatchProcess__c batchProcess = CRABB_DEV__BatchProcess__c.getValues('HandleMappingSyncBatchScheduler');
        Integer waitingMins = batchProcess != null ? Integer.valueOf(batchProcess.Run_every_minutes__c) : 10;

        return waitingMins;

    }

    /*
    To be invoked by Source Object trigger, for building a Source record fields Map and set the DataMapper Log fields
    */
    global static CRABB_DEV__Log__c createDataMapperLog(SObject sourceRecord, List<String> sourceFieldsList, String type, String operation, String destRecordType) {
        CRABB_DEV__Log__c log = new CRABB_DEV__Log__c();
        Map<String, Object> sourceRecordMap = new Map<String, Object>();

        try {
            for (String field : sourceFieldsList) {
                sourceRecordMap.put(field, sourceRecord.get(field));
            }
            String jsonToSave = JSON.serialize(sourceRecordMap);
            log = MappingUtils.buildLog(
                    jsonToSave,
                    type,
                    String.valueOf(sourceRecord.Id),
                    operation,
                    destRecordType,
                    String.valueOf(DATAMAPPER_RTID)
            );

        } catch (Exception ex) {

            ErrorClass.logError('MappingUtils - createDataMapperLog', 'Exception: ' + ex.getMessage() + ' for sourceRecord: ' + sourceRecord.Id);

        }

        return log;
    }
}