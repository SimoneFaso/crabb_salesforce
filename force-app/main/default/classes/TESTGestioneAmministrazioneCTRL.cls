@isTest
private class TESTGestioneAmministrazioneCTRL {
    
    @isTest static void test_one(){

        Test.startTest();

        AmministrazioneSettings__c temp = new AmministrazioneSettings__c();
        temp.SetupOwnerId = UserInfo.getProfileId();
        temp.AffidoCollector__c = true;
        temp.AttivitaProfili__c = true;
        temp.ConfigurazioneAmministrazione__c = true;
        temp.ConfigurazioneCollector__c = true;
        temp.ConfigurazioneMapping__c = true;
        temp.ConfigurazioneStrategie__c = true;
        temp.CruscottoPratica__c = true;
        temp.EstrattoConto__c = true;
        temp.FlussiCollector__c = true;
        temp.GestioneOrkBatch__c = true;
        temp.EliminazioneLog__c = true;
        temp.ProfilazioneUtenti__c = true;
        temp.CostiAttivita__c = true;
        temp.FasceCollector__c = true;
        insert temp;

        GestioneAmministrazioneCTRL ctrl = new GestioneAmministrazioneCTRL();
        ctrl.updateRecords();

        GestioneAmministrazioneCTRL.removeRecord(temp.Id);

        GestioneAmministrazioneCTRL.addNewRecord('TEST_'+UserInfo.getProfileId(), true, true, true, true, true, true, true, true, true, true, true, true, true, true,true);

        Test.stopTest();

    }

}