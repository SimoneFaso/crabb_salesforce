/**
 * Created by MatteoSala on 16/07/2020.
 */

@IsTest
private class CRABB_Schedule_BatchPDF_Test {
    @IsTest
    static void testBehavior()
    {
        Test.StartTest();

        CRABB_Schedule_BatchPDF sh1 = new CRABB_Schedule_BatchPDF(25);
        String sch = '0 0 23 * * ?';
        system.schedule('Test Schedule BS', sch, sh1);

        Test.stopTest();
    }

    @testSetup
    private static void populateObjects()
    {
        List<CRABB_DEV__CRABB_PDF_from_Template__mdt> lPDF = [SELECT MasterLabel, CRABB_DEV__Template__c, CRABB_DEV__Tipo_Sottotipo__c FROM CRABB_DEV__CRABB_PDF_from_Template__mdt WHERE CRABB_DEV__Active__c = true];
        System.assert(lPDF.size() > 0);
        //Id personRecordType = sObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account testAccount = new Account();
        //testAccount.LastName = 'TestAccount';
        testAccount.Name = 'TestAccount';
        //testAccount.RecordTypeId = personRecordType;
        testAccount.CRABB_DEV__Preferred_Language_for_Communications__c = 'ITA';
        testAccount.CRABB_DEV__CRABB_Mobile_Phone__c = '+393401234567';
        insert testAccount;

        //PDF
        CRABB_DEV__ActivityExtended__c testActivityExtended_1 = new CRABB_DEV__ActivityExtended__c();
        testActivityExtended_1.CRABB_DEV__IdAccount__c = testAccount.Id;
        testActivityExtended_1.CRABB_DEV__code_status__c = 'Non iniziata';
        testActivityExtended_1.CRABB_DEV__Tipo__c = 'TEST PDF';
        testActivityExtended_1.CRABB_DEV__Sotto_Tipo__c ='ATTACHMENT';
        insert testActivityExtended_1;

        insert new CRABB_DEV__Pratica__c();
        CRABB_DEV__Pratica__c testPratica_1 = [SELECT Id, Name FROM CRABB_DEV__Pratica__c LIMIT 1];

        Task testTask_1 = new Task();
        testTask_1.CRABB_DEV__ActivityExtended__c = testActivityExtended_1.Id;
        testTask_1.WhatId = testPratica_1.Id;
        insert testTask_1;
    }
}