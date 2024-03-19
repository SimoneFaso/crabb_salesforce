/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestBatchGeneraAffidamento.cls
Description:     Test Class for code coverage of BatchGeneraAffidamento.cls


Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
11-Jun-2021  0.2      M.Siotto                        Reviewed for using ceb methods
30-Aug-2021  0.3      C.Sanna                         Modified for using ceb methods (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

@isTest
private class TestBatchGeneraAffidamento {


	@isTest static void test_one() {
		Test.startTest();

		User u = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');
        Collector__c col = TestClassFroDataGenAffidamenti.getCollector(u.Id);
        insert col;
        
        List<Lotto__c> tmp = new List<Lotto__c>();
        
        for(integer i = 0;i<10; i++)
            tmp.add(new Lotto__c(Stato__c = 'Stato', Agenzia_di_recupero__c = col.id));

		insert tmp;

		Database.executeBatch(new BatchGeneraAffidamento(tmp[0].Id));

		Affidamento__c aff = new Affidamento__c();
		Pratica__c Dossier = new Pratica__c();
		insert Dossier;

		aff.Lotto__c = tmp[1].Id;
		aff.Pratica__c = Dossier.Id;
		aff.Stato__c = 'Chiuso';
		insert aff;

		Database.executeBatch(new BatchGeneraAffidamento(tmp[1].Id));
		Database.executeBatch(new BatchGeneraAffidamento(tmp[0].Id, 5));

		Test.stopTest();
	}

}