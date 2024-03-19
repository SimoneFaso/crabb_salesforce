/* ---------------------------------------------------------------------------------------------------------------------
Name:            DataMapperApi.cls
Description:     Code used to synchronize Source Objects records and Target Objects records, using a defined Mapping.
                 To be used in Source Objects triggers for continuously update Target Objects records.
Test class:      TestDataMapper.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
29-Jan-2017  0.1                                      First Version
18-Apr-2017  0.2                                      Modified singleMapper method adding CheckFLSPermission.
04-Mar-2021  0.3      M.Siotto, C.Sanna, G.Mameli     Modified singleMapper method and created checkSourceAndTargetFieldTypes
                                                      and getSourceAndTargetFieldTypes methods.
16-Mar-2021  0.3      M.Siotto,  A. Smiriglia         Created getAllMapsContainer, buildLists, doOperation methods and
                      C.Sanna, G.Mameli               modified DataMapperApiSetValues, syncObjects, singleMapper methods
26-Mar-2021  0.3      M.Siotto                        Changed error log management.
31-Mar-2021  0.4      M.Siotto                        Set the Class without sharing, modified buildLists method, introduced
                                                      secureAccess (from SecuritySettings__c custom setting) to skip FLS
                                                      controls when set to true. Created logErrorOnMapping and
                                                      insertErrorsOnMapping methods.
09-Apr-2021  0.5      G.Mameli                        Modified checkSourceAndTargetFieldTypes method.
06-Oct-2021  0.6      M. Pizzichini                   Reviewed for Security Review
----------------------------------------------------------------------------------------------------------------------*/

global without sharing class DataMapperApi {
    private static Boolean isSynced = false;
    private static Boolean isError = false;
    private static List<CRABB_DEV__Mapping__c> mapping2Use;
    private static Map<String, Map<String, String>> fieldMapping;
    private static String sourceObjectName;
    private static Map<String, String> upsertKeyMap;
    private static String operation = 'upsert';
    private static Id targetRecordTypeId;
    private static List<String> targetFieldsFinalList = new List<String>();
    private static Map<String, FieldInfoObj> targetObjectFieldsInfoMap;
    private static Map<String, FieldInfoObj> sourceObjectFieldsInfoMap;
    private static Map<String, List<CRABB_DEV__Mapping__c>> allMapsContainer = new Map<String, List<CRABB_DEV__Mapping__c>>();
    global static List<SObject> listDeleteObj = new List<SObject>();
    global static List<SObject> listUpdateObj = new List<SObject>();
    global static List<SObject> listInsertObj = new List<SObject>();
    global static List<SObject> targetObjsList;
    global static List<SObject> targetObjectsInstance = new List<SObject>();
    global static Set<String> targetExternalids = new Set<String>();
    global static Boolean fieldConversion = false;
    global static List<String> targetFieldsList = new List<String>();
    global static Boolean enableLogs = false;
    global static List<CRABB_DEV__Log__c> errorsOnMappingProcess = new List<CRABB_DEV__Log__c>();
    public static final Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    //SCOPE SIZE LIMIT IS 5000 records

    global static void getAllMapsContainer(String source, String target) {
        System.debug('##### Source --> ' + source);
        System.debug('##### Target --> ' + target);
        String allMappingQuery = 'SELECT Id,CRABB_DEV__SourceObj__c,CRABB_DEV__TargetObj__c,CRABB_DEV__SourceField__c,CRABB_DEV__TargetField__c,CRABB_DEV__isUpsertKey__c,CRABB_DEV__md5HashKey__c FROM CRABB_DEV__Mapping__c where CRABB_DEV__SourceObj__c = :source and CRABB_DEV__TargetObj__c = :target';
        if (!MappingUtils.secureAccess) allMappingQuery += ' WITH SECURITY_ENFORCED';
        System.debug('Query on Mapping --> ' + allMappingQuery);
        List<CRABB_DEV__Mapping__c> allMapping = Database.query(allMappingQuery);
        List<CRABB_DEV__Mapping__c> mappingRecords;
        for (CRABB_DEV__Mapping__c mp : allMapping) {
            mappingRecords = new List<CRABB_DEV__Mapping__c>();
            if (allMapsContainer.containsKey(mp.CRABB_DEV__SourceObj__c)) {
                mappingRecords = allMapsContainer.get(mp.CRABB_DEV__SourceObj__c);
            }
            mappingRecords.add(mp);
            allMapsContainer.put(mp.CRABB_DEV__SourceObj__c, mappingRecords);
        }
    }

    //Method deprecated; here just for deployment purpose.
    global DataMapperApi(List<SObject> sourceObjects, String operation, String recordTypeName) {
    }

    global static void DataMapperApiSetValues(String sourceObjectName, String operation, String recordTypeName) {
        try {

            DataMapperApi.sourceObjectName = sourceObjectName;
            DataMapperApi.operation = operation;
            //sourceObjectName = sourceObject.getSObjectType().getDescribe().getName();
            fieldMapping = new Map<String, Map<String, String>>();
            targetObjectFieldsInfoMap = new Map<String, FieldInfoObj> ();
            sourceObjectFieldsInfoMap = new Map<String, FieldInfoObj> ();
            Map<String, FieldInfoObj> currFieldInfoMap = new Map<String, FieldInfoObj>();

            if (MappingUtils.secureAccess || (Utils.cebCheckFLSPermission('Mapping__c', 'SourceObj__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Mapping__c', 'CRABB_DEV__TargetObj__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Mapping__c', 'SourceField__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Mapping__c', 'TargetField__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Mapping__c', 'SourceFieldType__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Mapping__c', 'TargetFieldType__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Mapping__c', 'isUpsertKey__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Mapping__c', 'md5HashKey__c', gd).get('ACCESS'))) {

                mapping2Use = allMapsContainer.get(sourceObjectName);

                upsertKeyMap = new Map<String, String>();
                System.debug('mapping2Use: ' + mapping2Use);
                //if (enableLogs) ErrorClass.logError('DataMapperApi constructor', 'mapping2Use: ' + mapping2Use);
                for (CRABB_DEV__Mapping__c mapRow : mapping2Use) {
                    //currFieldMapping.put(mapRow.SourceField__c,mapRow.TargetField__c);
                    if (fieldMapping.containsKey(mapRow.CRABB_DEV__TargetObj__c)) {
                        fieldMapping.get(mapRow.CRABB_DEV__TargetObj__c).put(mapRow.SourceField__c + '~' + mapRow.TargetField__c, mapRow.TargetField__c);
                    } else {
                        Map<String, String> currFieldMapping = new Map<String, String>();
                        currFieldMapping.put(mapRow.SourceField__c + '~' + mapRow.TargetField__c, mapRow.TargetField__c);
                        fieldMapping.put(mapRow.CRABB_DEV__TargetObj__c, currFieldMapping);
                    }

                    if (sourceObjectFieldsInfoMap.containsKey(String.valueOf(mapRow.SourceObj__c))) {
                        currFieldInfoMap = getSourceAndTargetFieldTypes(String.valueOf(mapRow.SourceObj__c), String.valueOf(mapRow.SourceField__c));
                        sourceObjectFieldsInfoMap.putAll(currFieldInfoMap);
                    } else {
                        currFieldInfoMap = getSourceAndTargetFieldTypes(String.valueOf(mapRow.SourceObj__c), String.valueOf(mapRow.SourceField__c));
                        sourceObjectFieldsInfoMap.putAll(currFieldInfoMap);
                    }

                    if (targetObjectFieldsInfoMap.containsKey(String.valueOf(mapRow.CRABB_DEV__TargetObj__c))) {
                        currFieldInfoMap = getSourceAndTargetFieldTypes(String.valueOf(mapRow.CRABB_DEV__TargetObj__c), String.valueOf(mapRow.TargetField__c));
                        targetObjectFieldsInfoMap.putAll(currFieldInfoMap);
                    } else {
                        currFieldInfoMap = getSourceAndTargetFieldTypes(String.valueOf(mapRow.CRABB_DEV__TargetObj__c), String.valueOf(mapRow.TargetField__c));
                        targetObjectFieldsInfoMap.putAll(currFieldInfoMap);
                    }

                    String ObjNameToken = Schema.describeSObjects(new String[]{mapRow.CRABB_DEV__TargetObj__c})[0].getName();
                    DescribeSObjectResult targetFieldTypes = ((SObject) (Type.forName('Schema.' + ObjNameToken).newInstance())).getSObjectType().getDescribe();
                    Map<String, Schema.sObjectField> targetFieldTokens = targetFieldTypes.fields.getMap();

                    if (String.isNotBlank(recordTypeName) && !recordTypeName.equalsIgnoreCase('Default')) DataMapperApi.targetRecordTypeId = targetFieldTypes.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeID();
                    Boolean isTargetExternalID = targetFieldTokens.get(mapRow.TargetField__c).getDescribe().isExternalID() || targetFieldTokens.get(mapRow.TargetField__c).getDescribe().isUnique();
                    System.debug('isTargetExternalID: ' + isTargetExternalID);
                    //if (isSourceExternalID) object2ExternalKey.put(tmp.SourceObj__c,isSourceExternalID);
                    if (isTargetExternalID) upsertKeyMap.put(mapRow.CRABB_DEV__TargetObj__c, mapRow.TargetField__c);
                    System.debug('upsertKeyMap:' + upsertKeyMap);
                    //if (enableLogs) ErrorClass.logError('DataMapperApi constructor', 'upsertKeyMap:' + upsertKeyMap);
                }
            }

        } catch (Exception e) {
            isError = true;
            System.debug('DataMapper DataMapperApiSetValues error:' + e.getMessage()+' - '+e.getStackTraceString());
            //if (enableLogs) ErrorClass.logError('DataMapperApi constructor', 'DataMapper constructor error:' + e.getMessage()); 
            errorsOnMappingProcess.add(logErrorOnMapping('DataMapperApi - DataMapperApiSetValues', ' error:' + ' ' + e.getMessage(), 'Error'));
        }
    }

    global static Boolean syncMapObjects(Map<String, Object> sourceObjects) {
        Boolean singleRunResult = false;
        Set<String> targetObjectNames = fieldMapping.keySet();
        //List<sObject> targetObjectsInstance = new List<sObject>();
        System.debug('targetObjectNames: ' + targetObjectNames);
        //if (enableLogs) ErrorClass.logError('DataMapperApi syncObjects', 'targetObjectNames: ' + targetObjectNames);
        for (String targetObjectName : targetObjectNames) {
            Map<String, String> currFieldMapping = fieldMapping.get(targetObjectName);
            //sObject targetObj = gd.get(tmp).newsObject();
            //System.debug('targetObj:'+targetObj);
            //singleRunResult = true;

            singleRunResult = singleMapper(sourceObjects, currFieldMapping, targetObjectName);


            //System.debug('singleRunResult: ' + singleRunResult);
            //if (enableLogs) ErrorClass.logError('DataMapperApi syncObjects', 'singleRunResult: ' + singleRunResult);
            //if (!singleRunResult) break;
        }
        return singleRunResult;
    }

    //Method deprecated; here just for deployment purpose.
    global Boolean syncObjects(List<SObject> sourceObjects) {
        return false;
    }

    global static Boolean singleMapper(Map<String, Object> sourceObjectFields, Map<String, String> currFieldMapping, String targetObjectName) {
        //Type sourceObjectType = Type.forName(sourceObjectName);
        //Set<String> targetObjects = fieldMapping.keySet();
        String targetFieldkey = upsertKeyMap.get(targetObjectName);//
        //DataMapperApi.targetFieldsFinalList = new List<String>();
        //List<String> targetFieldsList = new List<String>();

        //if (enableLogs) ErrorClass.logError('DataMapperApi singleMapper', 'targetFieldkey:' + targetFieldkey);

        //Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        //for (SObject sourceObject : sourceObjects) {

        //System.debug('sourceObjName: '+sourceObjName);
        Set<String> sourceFields = currFieldMapping.keySet();

        //if (enableLogs) ErrorClass.logError('DataMapperApi singleMapper', 'sourcefields: ' + sourceFields);

        SObject targetObj = gd.get(targetObjectName).newSObject();

        for (String sourceTargetField : sourceFields) {

            targetFieldsList.add(currFieldMapping.get(sourceTargetField));

            //System.debug('sourceField: '+( (String) Schema.getGlobalDescribe().get((String) sourceField.get('Name')).getDescribe().fields.getMap().get(field).getDescribe().getType().name()));

            //if (enableLogs) ErrorClass.logError('DataMapperApi singleMapper', 'sourceField: ' + sourceTargetField);

            String sourceField = sourceTargetField.split('~').get(0);
            String targetFieldName = sourceTargetField.split('~').get(1);

            //String targetFieldName = currFieldMapping.get(sourceField);

            //Get source field type
            //String sourceFieldType = sourceObjectFieldsInfoMap.get(sourceField).fieldType;

            //Get target field type
            String targetFieldType = targetObjectFieldsInfoMap.get(targetFieldName).fieldType;

            System.debug('targetFieldName:' + targetFieldName + ' targetFieldkey:' + targetFieldkey);

            //if (enableLogs) ErrorClass.logError('DataMapperApi singleMapper', 'targetFieldName:' + targetFieldName + ' targetFieldkey:' + targetFieldkey);

            if (targetFieldkey == targetFieldName) targetExternalids.add((String) sourceObjectFields.get(sourceField));

            //Check if source and target field types match and if not cast source value before to put in target field
            targetObj = checkSourceAndTargetFieldTypes(sourceObjectFields, sourceField, targetObj, targetFieldName, targetFieldType);

            if (DataMapperApi.targetRecordTypeId != null) targetObj.put('RecordTypeId', DataMapperApi.targetRecordTypeId);
        }

        System.debug('singleMapper targetExternalids: ' + targetExternalids);
        //if (enableLogs) ErrorClass.logError('DataMapperApi singleMapper', 'targetExternalids: ' + targetExternalids);
        System.debug('singleMapper targetObj: ' + targetObj);
        //if (enableLogs) ErrorClass.logError('DataMapperApi singleMapper', 'singleMapper targetObj: ' + targetObj);
        targetObjectsInstance.add(targetObj);
        return fieldConversion;
    }
    //sObjectField targetUpsertField = Schema.getGlobalDescribe().get(targetObjectName).getDescribe().fields.getMap().get(targetFieldkey);

    /* -----------------------------------------------------------------------------------------------------------------
    Author: G.Mameli, M.Siotto, C.Sanna
    Company: Balance
    Description: This method builds targetObj2update List adding target object records discriminated querying the Target
    Object by targetFieldkey (excluding not updateable fields from each record) and targetObj2insert putting target records
    not retrieved by the query
    Inputs:  String targetObjectName
    Returns: NA

    17-Mar-2021  0.1    G.Mameli, M.Siotto, C.Sanna    First Version
    31-Mar-2021  0.2    M.Siotto                       Added try/catch and secureAccess check
    27-Sep-2021  0.3    Matteo Pizzichini              Fixing FLS adding braces to if statement
    ----------------------------------------------------------------------------------------------------------------- */

    global static void buildLists(String targetObjectName) {
        try {
            Set<String> targetFieldsSetList = new Set<String>();
            targetFieldsSetList.addAll(targetFieldsList);
            String targetFieldkey = String.escapeSingleQuotes(upsertKeyMap.get(targetObjectName));
            System.debug('targetFieldkey: ' + targetFieldkey);
            System.debug('targetExternalids: ' + targetExternalids);
            //targetFieldkey = String.escapeSingleQuotes(targetFieldkey);
            targetObjectName = String.escapeSingleQuotes(targetObjectName);
            //targetObjsList = null;
            String query4ExternalKey = 'SELECT Id,' + targetFieldkey + ' FROM ' + targetObjectName + ' WHERE ' + targetFieldkey + ' IN :targetExternalids';
            System.debug('query external key: ' + query4ExternalKey);
            //if (enableLogs) ErrorClass.logError('DataMapperApi singleMapper', 'query external key: ' + query4ExternalKey);

            // inizio nuovo codice 18/04/17 inserimento CheckFLSPermission
            //List<sObject> targetObjsList = new List<sObject>();
            if (MappingUtils.secureAccess || Utils.cebCheckFLSPermission(targetObjectName, targetFieldkey, gd).get('ACCESS')) {
                if (targetObjsList == null) {
                    System.debug('IF Query');
                    targetObjsList = Database.query(query4ExternalKey);
                }
            }
            // inizio nuovo codice 18/04/17 inserimento CheckFLSPermission
            Map<String, SObject> obj2update = new Map<String, SObject>();
            for (SObject targetObj2 : targetObjsList) {
                obj2update.put((String) targetObj2.get(targetFieldkey), targetObj2);
            }
            //if (enableLogs) ErrorClass.logError('DataMapperApi singleMapper', 'single mapper obj2update: ' + obj2update);
            List<SObject> targetObj2insert = new List<SObject>();
            List<SObject> targetObj2update = new List<SObject>();

            //Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

            for (SObject targetObjectRecord : targetObjectsInstance) {
                if (obj2update.containsKey((String) targetObjectRecord.get(targetFieldkey))) {
                    SObject targetObjectUpdate = gd.get(targetObjectName).newSObject();
                    //Set the Id required for the updating targetObj2update list
                    targetObjectUpdate.Id = obj2update.get((String) targetObjectRecord.get(targetFieldkey)).Id;

                    //Fill targetFieldsFinalList excluding not updateable fields
                    for (String targetField : targetFieldsSetList) {
                        Boolean fieldUpdateable = targetObjectFieldsInfoMap.get(targetField).fieldUpdateable;
                        if (fieldUpdateable) {
                            if (!DataMapperApi.targetFieldsFinalList.contains(targetField)) {
                                DataMapperApi.targetFieldsFinalList.add(targetField);
                            }
                        }
                    }

                    //Loop through targetFieldsFinalList filling targetObjectUpdate with allowed fields
                    for (String targetField : DataMapperApi.targetFieldsFinalList) {
                        if (targetObjectFieldsInfoMap.get(targetField).fieldNotRequired || targetObjectRecord.get(targetField) != null) {
                            targetObjectUpdate.put(targetField, targetObjectRecord.get(targetField));
                        }
                    }

                    targetObj2update.add(targetObjectUpdate);

                } //else targetObj2insert.add(targetObjectRecord);
                    else {
                        targetObj2insert.add(targetObjectRecord);
                    }
            }

            //upsert targetObjectsInstance; //targetUpsertField  //not available Salesforce bug (http://salesforce.stackexchange.com/questions/64988/apex-cast-sobject-list-dynamically-to-a-specific-sobject-type)
            System.debug('targetObj2insert: ' + targetObj2insert);
            //if (enableLogs) ErrorClass.logError('DataMapperApi singleMapper', 'targetObj2insert: ' + targetObj2insert);
            System.debug('targetObj2update: ' + targetObj2update);
            //if (enableLogs) ErrorClass.logError('DataMapperApi singleMapper', 'targetObj2update: ' + targetObj2update);


            if (operation.equalsIgnoreCase('delete')) {
                System.debug('Delete operation');
                //if (MappingUtils.secureAccess || (checkFLSPermissions('DELETE') && Utils.checkObjPermission(targetObjectName).get('DELETE')))listDeleteObj.addAll(targetObj2update); //the delete operation is triggered by an update on the source object
                if (MappingUtils.secureAccess || (checkFLSPermissions('DELETE') && Utils.checkObjPermission(targetObjectName).get('DELETE'))) {
                    listDeleteObj.addAll(targetObj2update);
                } //the delete operation is triggered by an update on the source object
            } else {
                System.debug('MappingUtils.secureAccess -->' + MappingUtils.secureAccess);
                System.debug('(checkFLSPermissions(\'INSERT\')) -->' + (checkFLSPermissions('INSERT')));
                //if (MappingUtils.secureAccess || (checkFLSPermissions('UPDATE'))) listUpdateObj.addAll(targetObj2update);
                if (MappingUtils.secureAccess || (checkFLSPermissions('UPDATE'))) {
                    listUpdateObj.addAll(targetObj2update);
                }
                //if (MappingUtils.secureAccess || (checkFLSPermissions('INSERT'))) listInsertObj.addAll(targetObj2insert);
                if (MappingUtils.secureAccess || (checkFLSPermissions('INSERT'))) {
                    listInsertObj.addAll(targetObj2insert);
                }
            }
        } catch (Exception e) {
            isError = true;
            System.debug('DataMapper buildLists error:' + e.getMessage());
            //if (enableLogs) ErrorClass.logError('DataMapperApi constructor', 'DataMapper constructor error:' + e.getMessage());
            errorsOnMappingProcess.add(logErrorOnMapping('DataMapperApi - buildLists', ' error:' + e.getMessage(), 'Error'));
        }
    }

    /* -----------------------------------------------------------------------------------------------------------------
    Author: M.Siotto, A.Smiriglia
    Company: Balance
    Description: This method performs the expected DML operation for listDeleteObj, listUpdateObj and listInsertObj
    Inputs:  NA
    Returns: Boolean isSynced (true if all records in the batch are correctly updated)

    17-Mar-2021  0.1    M.Siotto, A.Smiriglia     First Version
    31-Mar-2021  0.2    M.Siotto                  Added secureAccess check
    27-Sep-2021  0.3    Matteo Pizzichini         Fixing FLS adding braces to if statement
    ----------------------------------------------------------------------------------------------------------------- */

    global static Boolean doOperation() {
        try {
            //if (checkFLSPermissions('DELETE') && Utils.checkObjPermission(targetObjectName).get('DELETE'))
            //if (MappingUtils.secureAccess || (checkFLSPermissions('DELETE') && listDeleteObj.size() > 0)) delete listDeleteObj; //the delete operation is triggered by an update on the source object
            if (MappingUtils.secureAccess || (checkFLSPermissions('DELETE') && listDeleteObj.size() > 0)) {
                delete listDeleteObj;
            } //the delete operation is triggered by an update on the source object

            //if (checkFLSPermissions('UPDATE'))


            //if (listUpdateObj.size() > 0) {
            if (MappingUtils.secureAccess || (checkFLSPermissions('UPDATE') && listUpdateObj.size() > 0)) {
                System.debug('listUpdateObj.size() --> ' + listUpdateObj.size());
                Database.SaveResult[] updateResult = Database.update(listUpdateObj, false);
                System.debug('updateResult --> ' + updateResult);
                for (Database.SaveResult sr : updateResult) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted record: ' + sr.getId());
                    } else {
                        // Operation failed, so get all errors
                        for (Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('fields that affected this error: ' + err.getFields());
                            errorsOnMappingProcess.add(logErrorOnMapping('DataMapperApi - doOperation', 'singleRunResult: ' + isSynced + ' - Message: ' + err.getMessage(), 'Error'));
                        }
                    }
                }
            }

            //if (checkFLSPermissions('INSERT'))
            if (listInsertObj.size() > 0) {
                System.debug('listInsertObj.size() --> ' + listUpdateObj.size());
                Database.SaveResult[] insertResult = Database.insert(listInsertObj, false);
                System.debug('insertResult --> ' + insertResult);
                for (Database.SaveResult sr : insertResult) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted record. Record ID: ' + sr.getId());
                    } else {
                        // Operation failed, so get all errors
                        for (Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('fields that affected this error: ' + err.getFields());
                            errorsOnMappingProcess.add(logErrorOnMapping('DataMapperApi - doOperation', 'singleRunResult: ' + isSynced + ' - Message: ' + err.getMessage(),'Error'));
                        }
                    }
                }
            }

            System.debug('################ listDeleteObj' + listDeleteObj);
            System.debug('################ listUpdateObj ' + listUpdateObj);
            System.debug('################ listInsertObj ' + listInsertObj);

            isSynced = true;

        } catch (Exception e) {
            isSynced = false;
            errorsOnMappingProcess.add(logErrorOnMapping('DataMapperApi - doOperation', 'singleRunResult: ' + isSynced + ' message: ' + e.getMessage() + ' stackTrace: ' + e.getStackTraceString(), 'Error'));
            System.debug('Error on update insert target Object: ' + e.getMessage());
        }
        return isSynced;
    }

    private static Map<String, Boolean> checkFLSPermission(String targetField) {
        //field name without any namespace example: account__c instead of BALANCE_CRABB__Account__c
        //SObjectType type = ((SObject) (Type.forName('Schema.' + targetObjectName).newInstance())).getSObjectType();
        //Map<String, Schema.SObjectField> fieldMap = type.getDescribe().fields.getMap();
        //Schema.DescribeFieldResult fieldDesc = fieldMap.get(field.toLowerCase()).getDescribe();
        Map<String, Boolean> permMap = new Map<String, Boolean>();
        permMap.put('CREATE', targetObjectFieldsInfoMap.get(targetField).fieldCreatable);
        permMap.put('INSERT', targetObjectFieldsInfoMap.get(targetField).fieldCreatable);
        permMap.put('ACCESS', targetObjectFieldsInfoMap.get(targetField).fieldAccessible);
        permMap.put('UPDATE', targetObjectFieldsInfoMap.get(targetField).fieldUpdateable);
        permMap.put('UPSERT', targetObjectFieldsInfoMap.get(targetField).fieldUpdateable && targetObjectFieldsInfoMap.get(targetField).fieldCreatable);
        return permMap;
    }

    /* -----------------------------------------------------------------------------------------------------------------
    Author:
    Company: Balance
    Description: This method takes in input the dmlOperation string and for the target Object and related fields (included
    in targetFieldsFinalList if UPDATE or in fieldMapping for other DML Operations) checks if they can be updated or not.
    Inputs:  String dmlOperation
    Returns: Boolean isOk (true if record can be updated)

                 0.1                     First Version
    08-Mar-2021  0.2    G.Mameli         If dmlOperation is 'UPDATE' then check FLS permissions on targetFieldsFinalList
                                         (that excludes not updateable fields)
    ----------------------------------------------------------------------------------------------------------------- */

    private static Boolean checkFLSPermissions(String dmlOperation) {
        Set<String> targetObjects = DataMapperApi.fieldMapping.keySet();
        Boolean isOk = true;
        List<String> targetFieldNames = new List<String>();

        for (String targetObject : targetObjects) {

            if (dmlOperation == 'UPDATE') {
                targetFieldNames = DataMapperApi.targetFieldsFinalList;
            } else {
                targetFieldNames = DataMapperApi.fieldMapping.get(targetObject).values();
            }

            for (String targetFieldName : targetFieldNames) {
                isOK = (checkFLSPermission(targetFieldName).get(dmlOperation) == null) ? true : checkFLSPermission(targetFieldName).get(dmlOperation);
                if (!isOK) break;
            }
        }
        return isOK;
    }


    /* -----------------------------------------------------------------------------------------------------------------
    Author: M.Siotto, C.Sanna, G.Mameli
    Company: Balance
    Description: This method checks Target Field Type to cast the Source Field Value to the same type prior to put it in
                 the Target Object Map.
    Inputs:  Map<String, Object> sourceObjectFields, String sourceFieldName, SObject targetObj, String targetFieldType
    Returns: SObject targetObj (added the current source field value)

    04-Mar-2021  0.1    M.Siotto, C.Sanna, G.Mameli     First Version
    09-Apr-2021  0.2    G.Mameli                        Managed null values when targetFieldType is STRING, TEXTAREA, PICKLIST,
                                                        DOUBLE, DECIMAL, CURRENCY
    ----------------------------------------------------------------------------------------------------------------- */

    private static SObject checkSourceAndTargetFieldTypes(Map<String, Object> sourceObjectFields, String sourceFieldName, SObject targetObj, String targetFieldName, String targetFieldType) {

        try {
            if (sourceObjectFields.get(sourceFieldName) != null && (targetFieldType.toUpperCase() == 'ID' || targetFieldType.toUpperCase() == 'REFERENCE')) {
                targetObj.put(targetFieldName, Id.valueOf((String) sourceObjectFields.get(sourceFieldName)));
            } else if (sourceObjectFields.get(sourceFieldName) != null && (targetFieldType.toUpperCase() == 'STRING') || (targetFieldType.toUpperCase() == 'TEXTAREA')) {
                Integer sourceFieldLength = sourceObjectFieldsInfoMap.get(sourceFieldName).fieldLength;
                Integer targetFieldLength = targetObjectFieldsInfoMap.get(targetFieldName).fieldLength;
                String sourceStringValue = String.valueOf(sourceObjectFields.get(sourceFieldName));
                Integer realSourceLength = sourceStringValue.length();
                if (sourceFieldLength > targetFieldLength && realSourceLength > targetFieldLength) {
                    targetObj.put(targetFieldName, sourceStringValue.substring(0, targetFieldLength));
                } else {
                    targetObj.put(targetFieldName, sourceStringValue);
                }
            } else if (targetFieldType.toUpperCase() == 'DATE') {
                //Datetime sourceDt = (DateTime) JSON.deserialize('"' + sourceObjectFields.get(sourceFieldName) + '"', DateTime.class);
                //Datetime dt = sourceObjectFields.get(sourceFieldName) != null ? (Datetime) sourceDt : null;
                Datetime dt = sourceObjectFields.get(sourceFieldName) != null ? (Datetime) JSON.deserialize('"' + sourceObjectFields.get(sourceFieldName) + '"', Datetime.class) : null;
                if (dt != null) targetObj.put(targetFieldName, dt.date());
            } else if (targetFieldType.toUpperCase() == 'DATETIME') {
                Datetime dt = sourceObjectFields.get(sourceFieldName) != null ? (Datetime) JSON.deserialize('"' + sourceObjectFields.get(sourceFieldName) + '"', Datetime.class) : null;
                //DateTime dt = sourceObjectFields.get(sourceFieldName) != null ? Datetime.newInstance((Date) sourceObjectFields.get(sourceFieldName), Time.newInstance(00, 00, 00, 00)) : null;
                if (dt != null) targetObj.put(targetFieldName, dt.date()); targetObj.put(targetFieldName, dt);
            } else if (targetFieldType.toUpperCase() == 'BOOLEAN') {
                Boolean booleanValue = sourceObjectFields.get(sourceFieldName) != null ? Boolean.valueOf(sourceObjectFields.get(sourceFieldName)) : false;
                targetObj.put(targetFieldName, booleanValue);
            } else if (targetFieldType.toUpperCase() == 'PICKLIST') {
                String pickValue = sourceObjectFields.get(sourceFieldName) != null ? String.valueOf(sourceObjectFields.get(sourceFieldName)) : '';
                targetObj.put(targetFieldName, pickValue);
            } else if (sourceObjectFields.get(sourceFieldName) != null && targetFieldType.toUpperCase() == 'DOUBLE') {
                targetObj.put(targetFieldName, Double.valueOf(sourceObjectFields.get(sourceFieldName)));
            } else if (targetFieldType.toUpperCase() == 'DECIMAL' || targetFieldType.toUpperCase() == 'CURRENCY') {
                Decimal decimalValue = sourceObjectFields.get(sourceFieldName) != null ? Decimal.valueOf((Double) sourceObjectFields.get(sourceFieldName)) : 0;
                targetObj.put(targetFieldName, decimalValue);
                /*} else if(targetFieldType.toUpperCase() == 'INTEGER'){
                        targetObj.put(targetFieldName,Integer.valueOf(sourceObjectFields.get(sourceFieldName)));*/

            } else {
                //exclude from the Target Object Map required fields if they are null (blanked out in Source record)
                if (targetObjectFieldsInfoMap.get(targetFieldName).fieldNotRequired) {
                    targetObj.put(targetFieldName, sourceObjectFields.get(sourceFieldName));
                }
            }
            fieldConversion = true;
        } catch (Exception err) {
            System.debug('checkSourceAndTargetFieldTypes Exception: ' + err.getMessage() + ' on field: ' + targetFieldName);
            fieldConversion = false;
            errorsOnMappingProcess.add(logErrorOnMapping('DataMapperApi - checkSourceAndTargetFieldTypes', ' fieldConversion: ' + fieldConversion + ' Exception: ' + err.getMessage() + ' on field: ' + targetFieldName,'Error'));
        }

        return targetObj;
    }

    /* -----------------------------------------------------------------------------------------------------------------
    Author: M.Siotto, C.Sanna, G.Mameli
    Company: Balance
    Description: This method takes in input the objectName string and the fieldName string to return a Map containing
    the field Name as key and a FieldInfoObj object holding the field data type, if it's updateable, if it's createable,
    if it's accessible, if it's not required and the field's length if it's a string.
    Inputs:  String objectName, String fieldName
    Returns: Map<String, TargetFieldTypeDMLInfo>

    04-Mar-2021  0.1    M.Siotto, C.Sanna, G.Mameli     First Version
    ----------------------------------------------------------------------------------------------------------------- */

    private static Map<String, FieldInfoObj> getSourceAndTargetFieldTypes(String objectName, String fieldName) {

        Map<String, FieldInfoObj> fieldInfoObjMap = new Map<String, FieldInfoObj>();
        FieldInfoObj fieldInfoObjRecord = new FieldInfoObj();

        DescribeSObjectResult describeSObjectResult = ((SObject) (Type.forName('Schema.' + objectName).newInstance())).getSObjectType().getDescribe();
        fieldInfoObjRecord.fieldType = describeSObjectResult.fields.getMap().get(fieldName).getDescribe().getType().name();
        fieldInfoObjRecord.fieldUpdateable = describeSObjectResult.fields.getMap().get(fieldName).getDescribe().isUpdateable();
        fieldInfoObjRecord.fieldCreatable = describeSObjectResult.fields.getMap().get(fieldName).getDescribe().isCreateable();
        fieldInfoObjRecord.fieldAccessible = describeSObjectResult.fields.getMap().get(fieldName).getDescribe().isAccessible();
        fieldInfoObjRecord.fieldNotRequired = describeSObjectResult.fields.getMap().get(fieldName).getDescribe().nillable;
        if (fieldInfoObjRecord.fieldType.toUpperCase() == 'STRING' || fieldInfoObjRecord.fieldType.toUpperCase() == 'TEXTAREA') {
            fieldInfoObjRecord.fieldLength = describeSObjectResult.fields.getMap().get(fieldName).getDescribe().length;
        }
        fieldInfoObjMap.put(fieldName, fieldInfoObjRecord);
        return fieldInfoObjMap;
    }

    private class FieldInfoObj {
        String fieldType          { get; set; }
        Boolean fieldUpdateable   { get; set; }
        Boolean fieldCreatable    { get; set; }
        Boolean fieldAccessible   { get; set; }
        Integer fieldLength       { get; set; }
        Boolean fieldNotRequired  { get; set; }
    }

    /* -----------------------------------------------------------------------------------------------------------------
    Author: M.Siotto
    Description: This method creates an Error Log when code exceptions occur.
    Inputs:  String classMethodNames, String errorMessage, String error
    Returns: Log__c record

    31-Mar-2021  0.1    M.Siotto            First Version
    ----------------------------------------------------------------------------------------------------------------- */

    private static Log__c logErrorOnMapping(String classMethodNames, String errorMessage, String error) {
        Log__c log = new Log__c();
        log.Class_Name__c = classMethodNames;
        log.Error__c = errorMessage;
        log.RecordTypeId = Schema.SObjectType.Log__c.getRecordTypeInfosByDeveloperName().get(error).getRecordTypeId();

        return log;
    }

    public static void insertErrorsOnMapping() {
        if (errorsOnMappingProcess.size() > 0) {
            insert errorsOnMappingProcess;
        }
    }
}