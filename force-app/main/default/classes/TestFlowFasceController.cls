@isTest
private class TestFlowFasceController {
	
	@isTest static void test_method_one() {
		FasceCompensiCollector__c fcl = new FasceCompensiCollector__c();
		fcl.name = 'Test';
		fcl.Valore__c = 10;
		insert fcl;
		User lUs = new User();
        lUs = TestClassFroDataGenAffidamenti.getUser('CRABB Credit Manager');
        // Chiedi collector
        Collector__c col = TestClassFroDataGenAffidamenti.getCollector(lUs.id); 
        col.Tipo_Collector__c = 'ADR';
        insert col;
        List<Decimal> ListSoglie = new List<Decimal>();
        List<Decimal> ListFascie = new List<Decimal>();
        ListSoglie.add(1.0);
        ListSoglie.add(3.4);
        ListSoglie.add(4.2);
        ListSoglie.add(4.3);
        ListSoglie.add(4.4);
        ListSoglie.add(4.5);
        ListFascie = ListSoglie;
		Test.setCurrentPage(new pageReference('/apex/AssegnaFasce'));
	    ApexPages.currentPage().getParameters().put('Id', col.id);
	    ApexPages.currentPage().getParameters().put('RagioneSociale', 'Test');
		FlowFasceController fl = new FlowFasceController();
		fl.ListSoglie = ListSoglie;
		fl.ListFasce = ListFascie;
		fl.SelFasce = '1';
		fl.AggiornaCollector();
		fl.SelFasce = '2';
		fl.AggiornaCollector();
		fl.SelFasce = '3';
		fl.AggiornaCollector();
		fl.SelFasce = '4';
		fl.AggiornaCollector();
		fl.SelFasce = '5';
		fl.AggiornaCollector();
		fl.Riepilogo();

	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}