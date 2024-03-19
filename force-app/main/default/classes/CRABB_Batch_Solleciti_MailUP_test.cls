/**
 * Created by MatteoSala on 18/06/2020.
 */

@IsTest
private class CRABB_Batch_Solleciti_MailUP_test { //

    @IsTest
    static void CalloutOK() {
        MockCRABBSender mcs = new MockCRABBSender(200, 'OK', '{ "Email":"prova@prova.it"  }', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mcs);

        Test.startTest();
        String batchId = Database.executeBatch(new CRABB_Batch_Solleciti_MailUP(),20);
        Test.stopTest();
    }

    @IsTest
    static void Callout_Unauthorized(){
        MockCRABBSender mcs = new MockCRABBSender(401, 'Unauthorized', '{"IdList" : "pass" , "idMessage" : "12343"}', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mcs);

        Test.startTest();
        String batchId = Database.executeBatch(new CRABB_Batch_Solleciti_MailUP(),20);
        Test.stopTest();
    }

    @IsTest
    static void Callout_FAIL(){
        MockCRABBSender mcs = new MockCRABBSender(500, 'INTERNAL SERVER ERROR', 'Error:generico', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mcs);

        Test.startTest();
        String batchId = Database.executeBatch(new CRABB_Batch_Solleciti_MailUP(),20);
        Test.stopTest();
    }

    @isTest
    static void crabbSenderMailupGetToken(){
        CRABBSENDER_MailUP csm =  new CRABBSENDER_MailUP();
        MockCRABBSender mcs = new MockCRABBSender(200, 'Unauthorized', '{"IdList" : "pass" , "idMessage" : "12343"}', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mcs);
        Test.startTest();
        csm.getToken('' , '' , '' , '' , '' , '');
        Test.stopTest();
    }

    @testSetup
    private static void populateObjects()
    {
        List<CRABB_DEV__CRABB_Sollecito__mdt> solleciti = [SELECT MasterLabel, CRABB_DEV__Template__c, CRABB_DEV__Tipo_Sottotipo__c, CRABB_DEV__Type__c, CRABB_DEV__Sender__c FROM CRABB_DEV__CRABB_Sollecito__mdt WHERE CRABB_DEV__Active__c = true];
        //System.assert(solleciti.size() > 0);
        Id personRecordType = sObjectType.Account.getRecordTypeInfosByName().get('CONSUMER').getRecordTypeId();

        Account testAccount = new Account();
        //testAccount.LastName = 'TestAccount';
        testAccount.Name = 'TestAccount';
        testAccount.RecordTypeId = personRecordType;
        testAccount.CRABB_DEV__CRABB_Email__c = 'prova@prova.it';
        testAccount.CRABB_DEV__Preferred_Language_for_Communications__c = 'ITA';
        testAccount.CRABB_DEV__CRABB_Mobile_Phone__c = '+393401234567';
        insert testAccount;

        //EMAL
        CRABB_DEV__ActivityExtended__c testActivityExtended_1 = new CRABB_DEV__ActivityExtended__c();
        testActivityExtended_1.CRABB_DEV__IdAccount__c = testAccount.Id;
        testActivityExtended_1.CRABB_DEV__Carrier__c = 'AWS_EMAIL';
        testActivityExtended_1.CRABB_DEV__Carrier_status_activation_code__c = 'EMAIL';
        testActivityExtended_1.CRABB_DEV__code_status__c = 'Non iniziata';
        testActivityExtended_1.CRABB_DEV__Message_Status__c = 'Created';
        testActivityExtended_1.CRABB_DEV__Tipo__c = 'Invio e-mail';
        testActivityExtended_1.CRABB_DEV__Message_Email__c = 'prova@prova.it';
        testActivityExtended_1.CRABB_DEV__Sotto_Tipo__c ='Primo Sollecito MAILUP';
        insert testActivityExtended_1;

        insert new CRABB_DEV__Pratica__c();
        CRABB_DEV__Pratica__c testPratica_1 = [SELECT Id, Name FROM CRABB_DEV__Pratica__c LIMIT 1];

        Task testTask_1 = new Task();
        testTask_1.CRABB_DEV__ActivityExtended__c = testActivityExtended_1.Id;
        testTask_1.WhatId = testPratica_1.Id;
        insert testTask_1;

        //SMS
        CRABB_DEV__ActivityExtended__c testActivityExtended_2 = new CRABB_DEV__ActivityExtended__c();
        testActivityExtended_2.CRABB_DEV__IdAccount__c = testAccount.Id;
        testActivityExtended_2.CRABB_DEV__Carrier__c = 'AWS_SMS';
        testActivityExtended_2.CRABB_DEV__Carrier_status_activation_code__c = 'EMAIL';
        testActivityExtended_2.CRABB_DEV__code_status__c = 'Non iniziata';
        testActivityExtended_2.CRABB_DEV__Message_Status__c = 'Created';
        testActivityExtended_2.CRABB_DEV__Message_Email__c = 'prova@prova.it';
        testActivityExtended_2.CRABB_DEV__Tipo__c = 'Invio e-mail';
        testActivityExtended_2.CRABB_DEV__Sotto_Tipo__c ='Primo Sollecito';
        insert testActivityExtended_2;

        insert new CRABB_DEV__Pratica__c();
        CRABB_DEV__Pratica__c testPratica_2 = [SELECT Id, Name FROM CRABB_DEV__Pratica__c WHERE Id != '' LIMIT 1];

        Task testTask_2 = new Task();
        testTask_2.CRABB_DEV__ActivityExtended__c = testActivityExtended_2.Id;
        testTask_2.WhatId = testPratica_2.Id;
        insert testTask_2;
    }

}