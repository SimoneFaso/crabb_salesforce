/**
 * Created by ssalaris on 24/05/2021.
 */

@IsTest
public with sharing class TestBatchDeleteRiconStaging {

    static testmethod void testBatch(){

        List<CRABB_DEV__Riconciliazione_Staging__c> ricStagList = new List<CRABB_DEV__Riconciliazione_Staging__c>();

        CRABB_DEV__Riconciliazione_Staging__c ricStag = new CRABB_DEV__Riconciliazione_Staging__c(CRABB_DEV__RiconciliazioneId__c = 'a0r0oood00000uHb9AAE', CRABB_DEV__Nome_Autore__c = 'Test Autore', CRABB_DEV__Autore__c = UserInfo.getUserId(),CRABB_DEV__PraticaId__c = 'Idpraticanum1', CRABB_DEV__Stato__c = 'Nuovo', CRABB_DEV__Value__c = '320');
        ricStagList.add(ricStag);
        CRABB_DEV__Riconciliazione_Staging__c ricStag2 = new CRABB_DEV__Riconciliazione_Staging__c(CRABB_DEV__RiconciliazioneId__c = 'a0r0oprov0000uHbAAE', CRABB_DEV__Nome_Autore__c = 'Test Autore', CRABB_DEV__Autore__c = UserInfo.getUserId(), CRABB_DEV__PraticaId__c = 'Idpraticanum21', CRABB_DEV__Stato__c = 'Nuovo', CRABB_DEV__Value__c = '320');
        ricStagList.add(ricStag2);
        CRABB_DEV__Riconciliazione_Staging__c ricStag3 = new CRABB_DEV__Riconciliazione_Staging__c(CRABB_DEV__RiconciliazioneId__c = 'Idriconciliaznenum1', CRABB_DEV__Nome_Autore__c = 'Test Autore', CRABB_DEV__Autore__c = UserInfo.getUserId(), CRABB_DEV__PraticaId__c = 'Idpraticanum41', CRABB_DEV__Stato__c = 'Nuovo', CRABB_DEV__Value__c = '20');
        ricStagList.add(ricStag3);



        insert ricStagList;

        test.startTest();
        BatchDeleteRiconStaging istanza = new BatchDeleteRiconStaging(UserInfo.getUserId());
        Id process = Database.executeBatch(istanza);
        test.stopTest();
    }

    static testmethod void testBatch2(){

        List<CRABB_DEV__Riconciliazione_Staging__c> ricStagList = new List<CRABB_DEV__Riconciliazione_Staging__c>();
        CRABB_DEV__Riconciliazione_Staging__c ricStag = new CRABB_DEV__Riconciliazione_Staging__c(CRABB_DEV__RiconciliazioneId__c = 'a0r0oood00000uHb9AAE', CRABB_DEV__Nome_Autore__c = 'Test Autore', CRABB_DEV__Autore__c = UserInfo.getUserId(),CRABB_DEV__PraticaId__c = 'Idpraticanum1', CRABB_DEV__Stato__c = 'Nuovo', CRABB_DEV__Value__c = '320');
        ricStagList.add(ricStag);
        CRABB_DEV__Riconciliazione_Staging__c ricStag2 = new CRABB_DEV__Riconciliazione_Staging__c(CRABB_DEV__RiconciliazioneId__c = 'a0r0oprov0000uHbAAE', CRABB_DEV__Nome_Autore__c = 'Test Autore', CRABB_DEV__Autore__c = UserInfo.getUserId(), CRABB_DEV__PraticaId__c = 'Idpraticanum21', CRABB_DEV__Stato__c = 'Nuovo', CRABB_DEV__Value__c = '320');
        ricStagList.add(ricStag2);
        CRABB_DEV__Riconciliazione_Staging__c ricStag3 = new CRABB_DEV__Riconciliazione_Staging__c(CRABB_DEV__RiconciliazioneId__c = 'Idriconciliaznenum1', CRABB_DEV__Nome_Autore__c = 'Test Autore', CRABB_DEV__Autore__c = UserInfo.getUserId(), CRABB_DEV__PraticaId__c = 'Idpraticanum41', CRABB_DEV__Stato__c = 'Nuovo', CRABB_DEV__Value__c = '20');
        ricStagList.add(ricStag3);

        insert ricStagList;

        Datetime data = Datetime.now().addDays(-31);
        for(CRABB_DEV__Riconciliazione_Staging__c ric : ricStagList) {
            Test.setCreatedDate(ric.Id, data);
        }

        test.startTest();
        BatchDeleteRiconStaging istanza = new BatchDeleteRiconStaging();
        Id process = Database.executeBatch(istanza);
        test.stopTest();
    }
}