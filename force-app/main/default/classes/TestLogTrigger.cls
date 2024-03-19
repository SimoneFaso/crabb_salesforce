/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestLogTrigger.cls
Description:     Test class for code coverage of LogTrigger.cls, HandleMappingSyncBatchScheduler.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
15-Mar-2021  0.2      M.Siotto, C.Sanna & G.Mameli    Added DataMapper Log record to cover mapping methods
----------------------------------------------------------------------------------------------------------------------*/

@IsTest
public class TestLogTrigger {

    static testMethod void testLogTrigger() {

        Test.startTest();

        List<Log__c> logList = new List<Log__c>();
        Schema.SObjectField externalIDField = MappingUtils.getSobjectExternalId();

        DataMapper dm = new DataMapper();
        List<SelectOption> selSourceObj = dm.getSourceObjectsName();
        dm.selObject = 'Account';
        dm.SourceObj = 'Account';
        dm.getObjectFields();
        dm.SourceField = 'CRABB_DEV__Id_Esterno__c';
        List<SelectOption> selTargetObj = dm.getTargetObjectsName();
        dm.selObject = 'Contact';
        dm.TargetObj = 'Contact';
        dm.getObjectFields();
        dm.TargetField = 'CRABB_DEV__Id_Esterno__c';
        dm.buildSingleRelation();

        //Source Object record
        Account acc = new Account();
        acc.BillingCity = 'Milano';
        acc.Id_Esterno__c = '1234';
        acc.Name = 'Test1';
        acc.CRABB_DEV__Data_di_Nascita__c = System.today();
        insert acc;

        CRABB_DEV__Log__c dmLog = new CRABB_DEV__Log__c();
        String jsonToSave = '{"CRABB_DEV__Id_Esterno__c":"1234"}';
        Id dataMapperRecordTypeId = Schema.SObjectType.CRABB_DEV__Log__c.getRecordTypeInfosByDeveloperName().get('DataMapper').getRecordTypeId();

        dmLog.CRABB_DEV__Object__c = acc.Id;
        dmLog.CRABB_DEV__External_Id__c = acc.Id_Esterno__c;
        dmLog.CRABB_DEV__type__c = 'Account';
        dmLog.CRABB_DEV__CS_Nome_Servizio__c = 'update';
        dmLog.CRABB_DEV__info__c = 'Default';
        dmLog.RecordTypeId = dataMapperRecordTypeId;
        System.debug('dmLog.RecordTypeId --> ' +dmLog.RecordType.DeveloperName);
        dmLog.CRABB_DEV__Integration_Json_file_data__c = jsonToSave;
        logList.add(dmLog);

        //Integration Log
        tag__c tag = new tag__c();
        tag.name = 'isBatchInbActive';
        tag.ValueBoolean__c = true;
        insert tag;
        Log__c myLog = new Log__c();
        myLog.Message_In__c = 'Vlere1; vlere2; vlere3;';
        Id debugRecordTypeId = Schema.SObjectType.CRABB_DEV__Log__c.getRecordTypeInfosByDeveloperName().get('Integration').getRecordTypeId();
        myLog.RecordTypeId = debugRecordTypeId;
        myLog.CRABB_DEV__External_Id__c = '5678';
        logList.add(myLog);

        Database.UpsertResult[] upsertResult = Database.upsert(logList, externalIDField ,true);

        Test.stopTest();
    }
}