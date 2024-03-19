/**
 * Created by ssalaris on 16/06/2021.
 */

@isTest
public class TestBatchDeleteRiconStagingScheduler {

    @isTest
    static void testmethod_ok() {
        List<CRABB_DEV__Riconciliazione_Staging__c> ricStagList  = new List<CRABB_DEV__Riconciliazione_Staging__c>();

        CRABB_DEV__Riconciliazione_Staging__c ric = new CRABB_DEV__Riconciliazione_Staging__c();
        ric.CRABB_DEV__RiconciliazioneId__c = 'idriconciliazione';
        ric.CRABB_DEV__PraticaId__c = 'idpratica';
        ric.CRABB_DEV__Value__c= '55.36';
        ricStagList.add(ric);

        ric = new CRABB_DEV__Riconciliazione_Staging__c();
        ric.CRABB_DEV__RiconciliazioneId__c = 'idriconciliazione2';
        ric.CRABB_DEV__PraticaId__c = 'idpratica2';
        ric.CRABB_DEV__Value__c= '55.38';
        ricStagList.add(ric);

        ric = new CRABB_DEV__Riconciliazione_Staging__c();
        ric.CRABB_DEV__RiconciliazioneId__c = 'idriconciliazione3';
        ric.CRABB_DEV__PraticaId__c = 'idpratica3';
        ric.CRABB_DEV__Value__c= '55.40';
        ricStagList.add(ric);

        insert ricStagList;

        Datetime data = Datetime.now().addDays(-31);
        for(CRABB_DEV__Riconciliazione_Staging__c ricst : ricStagList) {
            Test.setCreatedDate(ricst.Id, data);
        }


        test.startTest();
        BatchDeleteRiconStagingScheduler sche = new BatchDeleteRiconStagingScheduler();
        system.schedule('BatchDeleteRiconStaging', '0 0 22 * * ? *', sche);
        test.stopTest();
    }

}