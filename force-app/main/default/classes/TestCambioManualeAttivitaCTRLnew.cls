@isTest
private class TestCambioManualeAttivitaCTRLnew {
	
	@isTest static void test_method_one() {
		// Implement test code
        Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
        Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
		//Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByName().get('Step').getRecordTypeId();
        //Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByName().get('Testata').getRecordTypeId();
        Strategia__c Testata = new Strategia__c();
            Testata.RecordTypeId = rtStrat_Testata;
            Testata.Tipologia__c = 'UI';
            Testata.Stato__c = 'Attiva';
            Testata.Nome__c = 'STRATEGIA CONCESSIONE';
        insert testata;
        Strategia__c Strat = new Strategia__c();
            Strat.RecordTypeId=rtStrat_Step;
            Strat.Tipologia__c = 'UI';
            Strat.Testata__c = testata.Id;
            Strat.Stato__c = 'Attiva';
            Strat.Nome__c = 'Attesa verifica condizioni';
        insert strat;
        Strategia__c Strat1 = new Strategia__c();
            Strat1.RecordTypeId=rtStrat_Step;
            Strat1.Tipologia__c = 'UI';
            Strat1.Testata__c = testata.Id;
            Strat1.Stato__c = 'Attiva';
            Strat1.Nome__c = 'Doppio invio completato';
        insert strat1;
        
        //2-        
        // crea acc e contratto per pratica
        Contratto__c con = TestclassfrodataGenAffidamenti.getContratto();
        insert con;
        Account acc = TestclassfrodataGenAffidamenti.getAccount(con.Id);
        acc.Name = 'Endrit';
        insert acc;
        
        Pratica__c p = TestclassfrodataGenAffidamenti.getPratica(acc.Id);
        p.Strategia__c = testata.id;
        insert p;
        
        //3- 
        Task t1 = new Task();
        t1.subject = 'Gestione Manuale post diffida';
        t1.status = 'Non Iniziata';
        ActivityExtended__c ae = new ActivityExtended__c();
        ae.id_attivita__c = strat1.id;
        ae.RecordTypeId = Schema.SObjectType.ActivityExtended__c.getRecordTypeInfosByName().get('UI').getRecordTypeId();
        insert ae;
        t1.ActivityExtended__c = ae.Id;
        t1.whatId = p.id;  
        insert t1;
        
        //4-
                
        
        test.startTest();
        Test.setCurrentPage(new pageReference('/apex/CambioAttivitaNEW'));
        //ApexPages.currentPage().getParameters().put('id', p.id);
        //System.debug('\n TEst, Pratica: ' + p);
        CambioManualeAttivitaCTRLnew cap = new CambioManualeAttivitaCTRLnew();
        cap.SelectAll();
        cap.Beginning();
        cap.Next();
        cap.Previous();
        cap.Continua();
        cap.StrategieSelectable = 'STRATEGIA CONCESSIONE';
        cap.RecuperaTask();
        ApexPages.currentPage().getParameters().put('pTaskDa', 'Doppio invio completato');
        cap.UpdateTaskDa();
        cap.Continua();
        cap.getlistPraticheSelectable();
        ApexPages.currentPage().getParameters().put('pTaskA', 'Attesa verifica condizioni');
        cap.RecuperaTask();
        cap.UpdateTaskA();
        cap.ConfermaSelezione();
        cap.bonificaTask();
        cap.End();
        cap.getDisableNext();
        cap.getDisablePrevious();

	}
	
}