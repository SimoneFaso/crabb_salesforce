@IsTest 
public class TestCebUtils {

    @TestSetup
    public static void generateTestData() {
        generateRecordsForStrategy();
    }

    @IsTest
    public static void newOrkVersionEnabledTest() {
        CEBUtils.newOrkVersionEnabled();
    }

    @IsTest
    public static void addCebEventsTest() {
        Test.startTest();
            List<CRABB_DEV__Pratica__c> praList = generatePraticaList();
            CEBUtils.addCebEvents(false,praList, 'DSU');
        Test.stopTest();
    }

    @IsTest
    public static void addCebEvents2Test() {
        Test.startTest();
            List<String> praIdList = generatePraticaIdList();
            CEBUtils.updateCebEvents(praIdList, 'Blocked');
        Test.stopTest();
    }

    @IsTest
    public static void updateCebEventsTest() {
        Test.startTest();
            List<CRABB_DEV__Pratica__c> praList = generatePraticaList();
            CEBUtils.addCebEvents(false,praList, 'DSU');
        Test.stopTest();
    }

    private static void generateRecordsForStrategy() {
        Account acc = new Account(name = 'accTest');
        insert acc;

        CRABB_DEV__Pratica__c pra = new CRABB_DEV__Pratica__c();
        pra.CRABB_DEV__Account__c = acc.id;
        insert pra;

        CRABB_DEV__Movimento__c mov = new CRABB_DEV__Movimento__c();
        mov.CRABB_DEV__Pratica__c = pra.id;
        mov.CRABB_DEV__Residuo__c = 1000;
        mov.CRABB_DEV__Importo__c= 1000;
        mov.CRABB_DEV__Data_Emissione__c = system.today().addDays(-30);
        mov.CRABB_DEV__Data_Scadenza__c = system.today().addDays(-20);
        mov.CRABB_DEV__Account__c = acc.id;
        mov.CRABB_DEV__Sollecitabile__c = true;
        mov.CRABB_DEV__Tipo_Scadenza__c = 'Scaduto';
        insert mov;

        Task t = [SELECT id, CRABB_DEV__ActivityExtended__c from Task where WhatId=:pra.id];

        CRABB_DEV__ActivityExtended__c ae = [SELECT id, CRABB_DEV__Expiration_date__c from CRABB_DEV__ActivityExtended__c where id = :t.CRABB_DEV__ActivityExtended__c];
        ae.CRABB_DEV__Expiration_date__c = System.today().addDays(-7);

        update ae;
    }

    private static List<String> generatePraticaIdList() {
        List<CRABB_DEV__Pratica__c> praList = [SELECT id FROM CRABB_DEV__Pratica__c limit 10];
        List<String> praIdList = new List<String>();
        for(CRABB_DEV__Pratica__c pr : praList) {
            praIdList.add(String.valueOf(pr));
        }

        CEBUtils.addCebEvents(false,praIdList, 'DSU');

        return praIdList;
    }

    private static List<CRABB_DEV__Pratica__c> generatePraticaList() {
        List<CRABB_DEV__Pratica__c> praList = [SELECT id, CRABB_DEV__Stato__c FROM CRABB_DEV__Pratica__c limit 10];

        return praList;
    }

}