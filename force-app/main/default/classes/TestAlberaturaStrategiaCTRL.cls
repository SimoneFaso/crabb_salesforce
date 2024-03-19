@isTest
private class TestAlberaturaStrategiaCTRL {
	
	@isTest static void test_method_one() {
		Strategia__c testata = TestClassFroDataGenAffidamenti.getStrategia('Testata');
        testata.Stato__c = 'Attiva';
        insert testata;
        Strategia__c nonTestata = TestClassFroDataGenAffidamenti.getStrategia('Step');
        nontestata.Nome__c = 'Nome NNonTest';
        nontestata.Testata__c = testata.id;
        nontestata.E_da_affidare__c = true;
        nontestata.SLA__c = 5;
        nontestata.Sotto_tipo_attivita__c  = 'TEST';
        insert nontestata;
		test.startTest();
        PageReference pageRef = Page.AlberaturaStrategia;
    	Test.setCurrentPage(pageRef);
    	ApexPages.CurrentPage().getparameters().put('STRId', testata.Id);
    	AlberaturaStrategiaCTRL cp = new AlberaturaStrategiaCTRL();
    	cp.getDRows();
        System.assert(true,nontestata.Sotto_tipo_attivita__c  == 'TEST');
        test.stopTest();
	}
}