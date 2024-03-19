@isTest
private class TESTRiepilogoTaskCTRL {
	
	@isTest static void test_method_one() {

        Test.startTest();

		AffidiSettings__c afs =new AffidiSettings__c();
		afs.SetupOwnerId = UserInfo.getProfileId();
		afs.Sottotipo__c = 'Prima raccomandata;Seconda Raccomandata;Phone Collection';
		afs.Tipo__c = 'Proposta di Attività';

        insert afs;

		Account a = testClassForDataGenerationCreateData.getTestAccount();
        insert a;
        
        Pratica__c p = testClassForDataGenerationCreateData.getTestPratica();
        p.account__c = a.id;
        insert p;
        
        Movimento__c m = testClassForDataGenerationCreateData.getTestMovimento();
        Date tmp = system.today();
        tmp.addDays(5);
        m.pratica__c = p.id;
        m.account__c = a.id;
        m.Data_Scadenza__c= tmp;
        insert m;

        ApexPages.StandardController std = new ApexPages.StandardController(p);
        RiepilogoTaskCTRL ctrl = new RiepilogoTaskCTRL(std);
        List<SelectOption> lso = ctrl.pickVisibilityResult;
        ctrl.createStepOne();
        ctrl.selAll = true;
        ctrl.selectAll();
        ctrl.selAll = false;
        ctrl.selectAll();
        ctrl.selPage = true;
        ctrl.selectPage();
        ctrl.selPage = false;
        ctrl.selectPage();
        ctrl.selectedPickValue = Utils.NAMESPACE+'CAP__c';
        ctrl.sInput = '73028';
        ctrl.picklistMethod();
        ctrl.getPicklistInput();
        ctrl.setFilter();
        ctrl.deleteFilter();
        ctrl.selectedNumOfRec = '10';
        ctrl.setNumOfRec();
        ctrl.AffidaLista();
        ctrl.ConfermaLista();
        ctrl.empty();
        ctrl.backTo();
        ctrl.homePage();
        RiepilogoTaskCTRL.ARWrapper arw = new RiepilogoTaskCTRL.ARWrapper('sotto', 'owner', 1, 1);

		Test.stopTest();

	}
	
}