@IsTest
private class TestCoverage_CambioManualeAttivitaCTRL {

    static testMethod void myUnitTest() {
        
        List<String> nomeStrategia = new List<String>();
        nomeStrategia.add('Gestione Manuale post diffida');
        nomeStrategia.add('Attesa verifica condizioni');
        nomeStrategia.add('STRATEGIA APPALTI');
        nomeStrategia.add('Doppio invio completato');
        
        List<Strategia__c> ListStrategie = new List<Strategia__c>();  
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	Strategia__c Testata1 = new Strategia__c();
    	Testata1.RecordTypeId = rtStrat_Testata;
		Testata1.Tipologia__c = 'UI';
		Testata1.Stato__c = 'Attiva';
		Testata1.Nome__c = 'STRATEGIA CONCESSIONE';
		ListTestata.add(Testata1);
		
    	for(Integer i=0; i<3; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
			Testata.Nome__c = nomeStrategia[i];
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<3; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
			Strat.Nome__c = nomeStrategia[i];
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        
        // crea acc e contratto per pratica
        Contratto__c con = TestclassfrodataGenAffidamenti.getContratto();
        insert con;
        Account acc = TestclassfrodataGenAffidamenti.getAccount(con.Id);
        insert acc;
        
        List<Pratica__c> ListPrat = new List<Pratica__c>();
        for(Integer i=0; i<3; i++){
        	Pratica__c Prat = TestclassfrodataGenAffidamenti.getPratica(acc.Id);
        	ListPrat.add(Prat);
        }
        insert ListPrat;
        
        // ES: compila lprimoName
        CambioManualeAttivitaCTRL controller = new CambioManualeAttivitaCTRL();
        controller.LPrimoName = new List<String>();
        for(Pratica__c p: ListPrat)
        	controller.LPrimoName.add(p.name);
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<3; i++){
        	Task Att = new Task();
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListStrategie[i].Id;
        	Att.Status= 'Non Iniziata';
        	Att.WhatId = ListPrat[i].id;
            Att.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(Att);
        }
        insert aes;
        insert ListTask;

        controller.StrategieSelectable = 'STRATEGIA CONCESSIONE';
        controller.RecuperaTask();
        controller.Continua();
        controller.Indietro();
        controller.getListPraticheSelectable();
        controller.TaskA = 'Gestione Manuale post diffida';
        controller.ConfermaSelezione();
        
        // E.S.
        controller.bonificaTask();

        controller.StrategieSelectable = '';
        controller.Continua();
        
        controller.AggiornaElementoLista();
        
        // test getListPraticheSelectable
        List<TabellaPratica> tP = new List<TabellaPratica>();
        System.assertEquals(0, controller.LPrimoName.size());
        tP = controller.getListPraticheSelectable();
        
        // test tiny methods
        controller.Beginning();
        controller.Previous();
        controller.Next();
        controller.End();
        controller.SelectAll();
        controller.Indice = 0;
        controller.getDisablePrevious();
        controller.Indice = 1;
        controller.getDisablePrevious();
        controller.PageSize = 1;
        controller.RecXPage = 2;
        controller.getDisableNext();
        controller.PageSize = 3;
        controller.getDisableNext();
    }

    // E.S.
    static testmethod void unitTest2(){

    }
}