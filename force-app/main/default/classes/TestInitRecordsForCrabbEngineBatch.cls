@IsTest
public class TestInitRecordsForCrabbEngineBatch {

    @TestSetup
    public static void generateTestData() {
        List<Pratica__c> praList = generateData();
        for (Pratica__c pra : praList) {
            CEBUtils.addCebEvents(false,praList, 'DSU');
            CEBUtils.addCebEvents(false,praList, 'WAI');
            CEBUtils.addCebEvents(false,praList, 'SCH');
            CEBUtils.addCebEvents(true,praList, 'UEC');
            CEBUtils.addCebEvents(true,praList, 'NCA');
            CEBUtils.addCebEvents(true,praList, 'PDF');
        }
    }

    @IsTest

    private static void initCebRecordsSchedule() {
        Test.StartTest();
            System.schedule('Set cebs In Progress', '0 0 1 * * ?', new InitRecordsForCrabbEngineBatch());
        Test.StopTest();
    }

    @IsTest
    public static void initCebRecords() {
        Test.startTest();
            Database.executeBatch(new InitRecordsForCrabbEngineBatch(), 25);
        Test.stopTest();
    }


    public static List<CRABB_DEV__Pratica__c> generateData() {
        Account acc = new Account(name = 'accTest');
        insert acc;

        List<CRABB_DEV__Pratica__c> praList = new List<CRABB_DEV__Pratica__c>();
        CRABB_DEV__Pratica__c pra = new CRABB_DEV__Pratica__c();
        pra.CRABB_DEV__Account__c = acc.id;
        praList.add(pra);
        insert praList;

        CRABB_DEV__Movimento__c mov = new CRABB_DEV__Movimento__c();
        mov.CRABB_DEV__Pratica__c = pra.id;
        mov.CRABB_DEV__Residuo__c = 1000;
        mov.CRABB_DEV__Importo__c = 1000;
        mov.CRABB_DEV__Data_Emissione__c = system.today().addDays(-30);
        mov.CRABB_DEV__Data_Scadenza__c = system.today().addDays(-20);
        mov.CRABB_DEV__Account__c = acc.id;
        mov.CRABB_DEV__Sollecitabile__c = true;
        mov.CRABB_DEV__Tipo_Scadenza__c = 'Scaduto';
        insert mov;

        Task t = [SELECT id, CRABB_DEV__ActivityExtended__c from Task where WhatId = :pra.id];

        CRABB_DEV__ActivityExtended__c ae = [SELECT id, CRABB_DEV__Tipo_Sottotipo__c, CRABB_DEV__Expiration_date__c from CRABB_DEV__ActivityExtended__c where id = :t.CRABB_DEV__ActivityExtended__c];
        ae.CRABB_DEV__Expiration_date__c = System.today().addDays(-7);

        update ae;

        return praList;
    }

}