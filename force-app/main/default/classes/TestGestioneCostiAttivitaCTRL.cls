@isTest
private class TestGestioneCostiAttivitaCTRL {
	
	@isTest static void test_method_one() {

		Test.startTest();

		User Utente = TestClassFroDataGenAffidamenti.getUser('CRABB Operatore Credito');
        Collector__c Coll = new Collector__c();
        Coll.Prefisso_Lotto__c = 'AAA';
        Coll.Ragione_Sociale__c = 'Avv. Test Test';
        Coll.Tipo_Collector__c = 'LEGALE';
        Coll.User__c = Utente.Id;
        insert Coll;

		CostoAttivita__c ca = new CostoAttivita__c();
		ca.Costo__C = 0;
		ca.Tipo_Sottotipo__c = 'Test';
		ca.Collector__c = 'All';
		ca.Name = 'Costo00000';
		insert ca;

		GestioneCostiAttivitaCTRL ctrl = new GestioneCostiAttivitaCTRL();
		ctrl.persCollector = 'All';
		ctrl.persCosto = 1;
		ctrl.persTipoSottotipo = 'TEST';
		ctrl.confermaPersonalizza();

		ctrl.idRecord = ca.Id;
		ctrl.costoModificato = 3;
		ctrl.confermaModifica();

		ctrl.newCollectorSelected = 'COLL1';
		ctrl.addingTipo = 'TEST';
		ctrl.addNewRecord();

		ctrl.removeRecord();

		Test.stopTest();

	}
	
}