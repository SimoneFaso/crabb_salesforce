@isTest
private class TestTaskSemiAutomaticiCTRL {
	
	@isTest static void test_method_one(){
		Test.startTest();

		Affidamento__c aff = TestClassFroDataGenAffidamenti.getQuickAffido();
        insert aff;
        
        //2-
        Task t = new Task();
        t.Type = 'Credito';
        ActivityExtended__c ae = new ActivityExtended__c();
        ae.id_affidamento__c = aff.id;
        insert ae;
        t.ActivityExtended__c = ae.Id;
        t.Status = 'Non Iniziata';
        insert t;

		TaskSemiAutomaticiCTRL ctrl = new TaskSemiAutomaticiCTRL();
		List<SelectOption> temp1 = ctrl.pickVisibilityResult;
		List<String> temp2 = ctrl.originalValues_Comune;
		List<String> temp3 = ctrl.originalValues_ClasseDiRischio;
		List<String> temp4 = ctrl.originalValues_Stato;
		List<String> temp5 = ctrl.originalValues_IdContratto;
		List<String> temp6 = ctrl.originalValues_CodiceServizio;

		ctrl.HAVEOptionPickVisibilityResult();

		ctrl.VaiAFiltri();

		ctrl.setTipiAffido();

		ctrl.ProseguiFiltri();

		

		Test.stopTest();
	}

}