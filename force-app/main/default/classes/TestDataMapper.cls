/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestDataMapper.cls
Description:     Test class for code coverage of DataMapper.cls and DataMapperApi.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
01-Feb-2017  0.1                                      First Version
19-Mar-2021  0.2      M.Siotto, C.Sanna & G.Mameli    Covered DataMapperApi methods
----------------------------------------------------------------------------------------------------------------------*/

@IsTest
private class TestDataMapper {

    @TestSetup
    public static void setupData() {
        DataMapper dm = new DataMapper();
        List<SelectOption> selSourceObj = dm.getSourceObjectsName();
        dm.selObject = 'Account';
        dm.SourceObj = 'Account';
        dm.getObjectFields();
        dm.SourceField = 'BillingCity';
        List<SelectOption> selTargetObj = dm.getTargetObjectsName();
        dm.selObject = 'Contact';
        dm.TargetObj = 'Contact';
        dm.getObjectFields();
        dm.TargetField = 'OtherCity';
        dm.buildSingleRelation();
        dm.selObject = 'Account';
        dm.SourceObj = 'Account';
        dm.getObjectFields();
        dm.SourceField = 'CRABB_DEV__Id_Esterno__c';
        dm.selObject = 'Contact';
        dm.TargetObj = 'Contact';
        dm.getObjectFields();
        dm.TargetField = 'CRABB_DEV__Id_Esterno__c';
        dm.buildSingleRelation();
        dm.selObject = 'Account';
        dm.SourceObj = 'Account';
        dm.getObjectFields();
        dm.SourceField = 'Name';
        dm.selObject = 'Contact';
        dm.TargetObj = 'Contact';
        dm.getObjectFields();
        dm.TargetField = 'LastName';
        dm.buildSingleRelation();
        dm.selObject = 'Account';
        dm.SourceObj = 'Account';
        dm.getObjectFields();
        dm.SourceField = 'CRABB_DEV__Data_di_Nascita__c';
        dm.selObject = 'Contact';
        dm.TargetObj = 'Contact';
        dm.getObjectFields();
        dm.TargetField = 'Birthdate';
        dm.buildSingleRelation();
        dm.getObjectFields();
        dm.SourceField = 'CRABB_DEV__Data_di_Nascita__c';
        dm.selObject = 'Contact';
        dm.TargetObj = 'Contact';
        dm.getObjectFields();
        dm.TargetField = 'Birthdate';
        dm.buildSingleRelation();

        Account acc1 = new Account();
        acc1.BillingCity = 'Milano';
        acc1.Id_Esterno__c = '1234';
        acc1.Name = 'Test1';
        acc1.CRABB_DEV__Data_di_Nascita__c = System.today();

        Account acc2 = new Account();
        acc2.BillingCity = 'Milano';
        acc2.Id_Esterno__c = '5678';
        acc2.Name = 'Test2';
        acc1.CRABB_DEV__Data_di_Nascita__c = System.today();

        List<Account> acclist = new List<Account>();
        acclist.add(acc1);
        acclist.add(acc2);
        insert acclist;

        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Id_Esterno__c = '1234';
        insert con;

    }


    @IsTest static void DataMapper_deleteRelationsTest() {
        DataMapper dm = new DataMapper();
        List<SelectOption> selobj = dm.getSourceObjectsName();
        dm.selObject = 'Account';
        dm.SourceObj = 'Account';
        dm.getObjectFields();
        dm.SourceField = 'BillingCity';
        List<SelectOption> selobj2 = dm.getTargetObjectsName();
        dm.selObject = 'Contact';
        dm.TargetObj = 'Contact';
        dm.getObjectFields();
        dm.TargetField = 'OtherCity';
        dm.buildSingleRelation();
        Mapping__c m = [SELECT Id,SourceObj__c,TargetObj__c,SourceField__c,TargetField__c,SourceFieldType__c,TargetFieldType__c,isUpsertKey__c,md5HashKey__c FROM Mapping__c ORDER BY CreatedDate Desc LIMIT 1];
        dm.mappingId = m.Id;
        dm.deleteSingleRelation();
        Mapping__c n = new Mapping__c();
        n.SourceObj__c = 'Account';
        n.TargetObj__c = 'Contact';
        n.SourceField__c = 'BillingCity';
        n.TargetField__c = 'OtherCity';
        insert n;
        dm.deleteRelations();

    }

    @IsTest static void DataMapperApi_Test() {

        List<Account> accountsList = [SELECT Id, BillingCity, CRABB_DEV__Id_Esterno__c, Name, CRABB_DEV__Data_di_Nascita__c FROM Account];
        List<Contact> contactsList = [SELECT Id, CRABB_DEV__Id_Esterno__c, Birthdate FROM Contact];
        List<CRABB_DEV__Mapping__c> allMapping = [SELECT CRABB_DEV__SourceField__c FROM CRABB_DEV__Mapping__c where CRABB_DEV__SourceObj__c = 'Account' WITH SECURITY_ENFORCED];
        System.debug('allMapping--> ' + allMapping);
        Id recordTypeId = Schema.SObjectType.CRABB_DEV__Log__c.getRecordTypeInfosByDeveloperName().get('DataMapper').getRecordTypeId();
        List<CRABB_DEV__Log__c> logToSync = new List<CRABB_DEV__Log__c>();
        List<String> sourceFieldsList = MappingUtils.getMappingFields('Account');
        System.debug('sourceFieldsList--> ' + sourceFieldsList);

        Schema.SObjectField externalIDField = MappingUtils.getSobjectExternalId();

        CRABB_DEV__Log__c log;
        if (sourceFieldsList.size() != 0) {
            for (Account acc : accountsList) {
                System.debug('Test Acc Id_Esterno__c --> '+acc.Id_Esterno__c);
                log = new CRABB_DEV__Log__c();
                Map<String, Object> mapAcc = new Map<String, Object>();
                for (String field : sourceFieldsList) {
                    mapAcc.put(field, acc.get(field));
                }

                String jsonToSave = JSON.serialize(mapAcc);

                logToSync.add(MappingUtils.buildLog(jsonToSave, 'Account', String.valueOf(acc.id), 'update', 'Default', String.valueOf(recordTypeId)));
                System.debug('Account afterUpdate logToSync--> ' + logToSync);
            }
        }

        DataMapperApi.enableLogs = true;

        Map<String, Object> sourceRecordsMap = new Map<String, Object>();
        for(Account acc : accountsList){
            for(String sourceField : sourceFieldsList){
                sourceRecordsMap.put(sourceField, acc.get(sourceField));
            }
        }

        Test.startTest();

        DataMapperApi.getAllMapsContainer('Account', 'Contact');
        DataMapperApi.DataMapperApiSetValues('Account', 'update', 'Default');
        DataMapperApi.syncMapObjects(sourceRecordsMap);
        DataMapperApi.buildLists('Contact');
        DataMapperApi.syncMapObjects(sourceRecordsMap);
        Boolean singleRunResult = DataMapperApi.doOperation();//test the update

        //contactsList[0].Id_Esterno__c =
        update(accountsList);

        Test.stopTest();
    }
}