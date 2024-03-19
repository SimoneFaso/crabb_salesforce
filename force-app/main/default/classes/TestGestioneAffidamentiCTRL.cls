@isTest
private class TestGestioneAffidamentiCTRL {
	
	@isTest static void test_method_one() {
		User lUs = new User();
        lUs = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');
            
        // Chiedi collector
        Collector__c col = TestClassFroDataGenAffidamenti.getCollector(lUs.id); 
        col.Tipo_Collector__c = 'ADR';
        insert col;
        Lotto__c lot3= TestClassFroDataGenAffidamenti.getLotto(col.id);
        lot3.Tipo__c='Pre-Lotto';
        lot3.Stato__c = 'In creazione';
        insert lot3;
        Lotto__c lot= TestClassFroDataGenAffidamenti.getLotto(col.id);
        lot.Tipo__c='Lotto';
        lot.Stato__c = 'Confermato';
        lot.Pre_lotto__c = lot3.id;
        insert lot;
        Lotto__c lot2= TestClassFroDataGenAffidamenti.getLotto(col.id);
        lot2.Tipo__c='Pre-Lotto';
        lot2.Stato__c = 'Da confermare';
        insert lot2;
        // crea pratica
        Contratto__c ct = TestClassFroDataGenAffidamenti.getContratto();
        insert ct;
        // prendi il acct con il contratto appena chiesto
        Account acc = TestClassFroDataGenAffidamenti.getAccount(ct.id);
        insert acc;
        // crea la pratica con il acct
        Pratica__c pr = TestClassFroDataGenAffidamenti.getPratica(acc.id);
        insert pr;
        // adesso crea gli affidi
        Affidamento__c aff1 = TestClassFroDataGenAffidamenti.getAffido('In Corso', System.today(), lot2.id, pr.id);
        Affidamento__c aff2 = TestClassFroDataGenAffidamenti.getAffido('In Corso', System.today(), lot.id, pr.id);
        Affidamento__c aff3 = TestClassFroDataGenAffidamenti.getAffido('In Corso', System.today(), lot2.id, pr.id);
        Affidamento__c aff4 = TestClassFroDataGenAffidamenti.getAffido('In Corso', System.today(), lot2.id, pr.id);
        List<Affidamento__c> affList = new List<Affidamento__c>();
        affList.add(aff1);
        affList.add(aff2);
        affList.add(aff3);
        affList.add(aff4);
        //insert aff1;
        //insert affList; insert rende inutile il ruolo dello scenario di test.
        test.startTest();
        Test.setCurrentPage(new pageReference('/apex/GestioneAffidamenti'));
        ApexPages.currentPage().getParameters().put('TabToView', 'LICTab');
        GestioneAffidamentiCTRL gaff= new GestioneAffidamentiCTRL();
        gaff.impostaTabToView('LICTab');
        gaff.refreshTabToView();
        gaff.refreshLotti();
        gaff.refreshpreLotti();
        gaff.GeneraPreLottoIDLIC();
        gaff.EliminaIDLIC();
        ApexPages.currentPage().getParameters().put('IDLIC', lot2.id);
        gaff.GeneraPreLottoIDLIC();
        gaff.EliminaIDLIC();
        gaff.IdLotto = lot.id;
        gaff.startNewLotto();
        gaff.ModificaLotti();
        gaff.EliminaLotti();
        gaff.EliminaPreLotti();
        Test.stopTest();
	}
	
}