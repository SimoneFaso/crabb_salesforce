@isTest
private class TestCoverage_TaskSemiAutomatici {
    static testMethod void myUnitTest() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<18; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<18; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<18; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Decreto';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Decreto');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Decreto');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', 'Content');
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        MyClass.DaScaduto = 'Errore';
        MyClass.AScaduto = '12.42';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.42';
       	MyClass.DaSaldoSpese = '12.42';
        MyClass.ASaldoSpese = '12.42';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.42';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.42';
        MyClass.DaScaduto_Spese = '12.42';
        MyClass.AScaduto_Spese = '12.42';
        MyClass.ASaldo_Totale = '12.42';
        MyClass.DaSaldo_Totale = '12.42';
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();
    	MyClass.pagination();
        MyClass.getPratica();
        MyClass.setNumber(20);
        MyClass.test();
        MyClass.getItems();
        MyClass.refresh();
    	//MyClass.aggiorna_Elenco(ListPratica);
    	//MyClass.End();
    	//MyClass.Next();
    	//MyClass.Beginning();
    	//MyClass.Previous();
    }
    
       static testMethod void myUnitTest2() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);           
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Decreto');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', 'Content');
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '1');
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = 'Errore';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.42';
       	MyClass.DaSaldoSpese = '12.42';
        MyClass.ASaldoSpese = '12.42';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.42';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.42';
        MyClass.DaScaduto_Spese = '12.42';
        MyClass.AScaduto_Spese = '12.42';
        MyClass.ASaldo_Totale = '12.42';
        MyClass.DaSaldo_Totale = '12.42';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();
    	MyClass.pagination();
    	//MyClass.aggiorna_Elenco(ListPratica);
    	//MyClass.End();
    	//MyClass.Next();
    	MyClass.Indietro();
    	MyClass.HomePage();
    	MyClass.getleftselected_Tipo_Lettera();
    	MyClass.SelectAll();
    	//MyClass.Next();
    	MyClass.HAVEOptionPickVisibilityResult();
    	//MyClass.UpdateListe();

    }
    
    static testMethod void myUnitTest3() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Decreto');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', 'Content');
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '2');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = 'errore';
        MyClass.AScadutoConsolidato = '12.42';
       	MyClass.DaSaldoSpese = '12.42';
        MyClass.ASaldoSpese = '12.42';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.42';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.42';
        MyClass.DaScaduto_Spese = '12.42';
        MyClass.AScaduto_Spese = '12.42';
        MyClass.ASaldo_Totale = '12.42';
        MyClass.DaSaldo_Totale = '12.42';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();
    	MyClass.pagination();
    	//MyClass.aggiorna_Elenco(ListPratica);
    	//MyClass.End();
    	MyClass.Next();
    	MyClass.Indietro();
    	MyClass.HomePage();
    	MyClass.getleftselected_Tipo_Lettera();
    	MyClass.SelectAll();
    	//MyClass.Next();
    	MyClass.HAVEOptionPickVisibilityResult();
    	//MyClass.UpdateListe();
    	MyClass.AggiornaElementoLista();
    	MyClass.ConfermaLista();
    	MyClass.getEnablePrevious();
    	MyClass.getEnableNext();
    	MyClass.Previous();
    	MyClass.Beginning();

    }
    
        static testMethod void myUnitTest4() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Decreto');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '3');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = 'errore';
       	MyClass.DaSaldoSpese = '12.42';
        MyClass.ASaldoSpese = '12.42';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.42';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.42';
        MyClass.DaScaduto_Spese = '12.42';
        MyClass.AScaduto_Spese = '12.42';
        MyClass.ASaldo_Totale = '12.42';
        MyClass.DaSaldo_Totale = '12.42';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();
    	MyClass.pagination();
    	//MyClass.aggiorna_Elenco(ListPratica);
    	//MyClass.End();
    	MyClass.Next();
    	MyClass.Indietro();
    	MyClass.HomePage();
    	MyClass.getleftselected_Tipo_Lettera();
    	MyClass.SelectAll();
    	//MyClass.Next();
    	MyClass.HAVEOptionPickVisibilityResult();
    	//MyClass.UpdateListe();
    	MyClass.AggiornaElementoLista();
    	MyClass.ConfermaLista();
    	MyClass.getEnablePrevious();
    	MyClass.getEnableNext();
    	MyClass.Previous();
    	MyClass.Beginning();

    }
    
      static testMethod void myUnitTest5() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '4');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.42';
        MyClass.ASaldoSpese = 'errore';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.42';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.42';
        MyClass.DaScaduto_Spese = '12.42';
        MyClass.AScaduto_Spese = '12.42';
        MyClass.ASaldo_Totale = '12.42';
        MyClass.DaSaldo_Totale = '12.42';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();
    	MyClass.pagination();
    	//MyClass.aggiorna_Elenco(ListPratica);
    	//MyClass.End();
    	MyClass.Next();
    	MyClass.Indietro();
    	MyClass.HomePage();
    	MyClass.getleftselected_Tipo_Lettera();
    	MyClass.SelectAll();
    	//MyClass.Next();
    	MyClass.HAVEOptionPickVisibilityResult();
    	//MyClass.UpdateListe();
    	MyClass.AggiornaElementoLista();
    	MyClass.ConfermaLista();
    	MyClass.getEnablePrevious();
    	MyClass.getEnableNext();
    	MyClass.Previous();
    	MyClass.Beginning();

    }
    
    
   static testMethod void myUnitTest6() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
            T.ActivityExtended__c = ae.Id;
        	ae.Owner_contratto__c = 'Gelsomino';
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = 'errore';
        MyClass.ASaldoSpese = '12.42';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.42';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.42';
        MyClass.DaScaduto_Spese = '12.42';
        MyClass.AScaduto_Spese = '12.42';
        MyClass.ASaldo_Totale = '12.42';
        MyClass.DaSaldo_Totale = '12.42';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();
    	MyClass.pagination();
    	//MyClass.aggiorna_Elenco(ListPratica);
    	//MyClass.End();
    	MyClass.Next();
    	MyClass.Indietro();
    	MyClass.HomePage();
    	MyClass.getleftselected_Tipo_Lettera();
    	MyClass.SelectAll();
    	//MyClass.Next();
    	MyClass.HAVEOptionPickVisibilityResult();
    	//MyClass.UpdateListe();
    	MyClass.AggiornaElementoLista();
    	MyClass.ConfermaLista();
    	MyClass.getEnablePrevious();
    	MyClass.getEnableNext();
    	MyClass.Previous();
    	MyClass.Beginning();

    }
    
    
    static testMethod void myUnitTest7() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.43';
        MyClass.ASaldoSpese = 'errore';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.42';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.42';
        MyClass.DaScaduto_Spese = '12.42';
        MyClass.AScaduto_Spese = '12.42';
        MyClass.ASaldo_Totale = '12.42';
        MyClass.DaSaldo_Totale = '12.42';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();
    	MyClass.pagination();
    	//MyClass.aggiorna_Elenco(ListPratica);
    	//MyClass.End();
    	MyClass.Next();
    	MyClass.Indietro();
    	MyClass.HomePage();
    	MyClass.getleftselected_Tipo_Lettera();
    	MyClass.SelectAll();
    	//MyClass.Next();
    	MyClass.HAVEOptionPickVisibilityResult();
    	//MyClass.UpdateListe();
    	MyClass.AggiornaElementoLista();
    	MyClass.ConfermaLista();
    	MyClass.getEnablePrevious();
    	MyClass.getEnableNext();
    	MyClass.Previous();
    	MyClass.Beginning();
    }
    
    
    static testMethod void myUnitTest8() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.43';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = 'error';
        MyClass.ASaldoConsolidato = '12.42';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.42';
        MyClass.DaScaduto_Spese = '12.42';
        MyClass.AScaduto_Spese = '12.42';
        MyClass.ASaldo_Totale = '12.42';
        MyClass.DaSaldo_Totale = '12.42';*/
        
		MyClass.VaiATabella();
    	MyClass.FiltroQuery();
    	MyClass.pagination();
    	//MyClass.aggiorna_Elenco(ListPratica);
    	//MyClass.End();
    	MyClass.Next();
    	MyClass.Indietro();
    	MyClass.HomePage();
    	MyClass.getleftselected_Tipo_Lettera();
    	MyClass.SelectAll();
    	//MyClass.Next();
    	MyClass.HAVEOptionPickVisibilityResult();
    	//MyClass.UpdateListe();
    	MyClass.AggiornaElementoLista();
    	MyClass.ConfermaLista();
    	MyClass.getEnablePrevious();
    	MyClass.getEnableNext();
    	MyClass.Previous();
    	MyClass.Beginning();
    }
    
    
    static testMethod void myUnitTest9() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.43';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = 'error';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.42';
        MyClass.DaScaduto_Spese = '12.42';
        MyClass.AScaduto_Spese = '12.42';
        MyClass.ASaldo_Totale = '12.42';
        MyClass.DaSaldo_Totale = '12.42';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();
    	MyClass.pagination();
    	//MyClass.aggiorna_Elenco(ListPratica);
    	//MyClass.End();
    	MyClass.Next();
    	MyClass.Indietro();
    	MyClass.HomePage();
    	MyClass.getleftselected_Tipo_Lettera();
    	MyClass.SelectAll();
    	//MyClass.Next();
    	MyClass.HAVEOptionPickVisibilityResult();
    	//MyClass.UpdateListe();
    	MyClass.AggiornaElementoLista();
    	MyClass.ConfermaLista();
    	MyClass.getEnablePrevious();
    	MyClass.getEnableNext();
    	MyClass.Previous();
    	MyClass.Beginning();
    }
    
    
        static testMethod void myUnitTest10() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.43';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = 'error';
        MyClass.AAnzianita_scaduto = '12.42';
        MyClass.DaScaduto_Spese = '12.42';
        MyClass.AScaduto_Spese = '12.42';
        MyClass.ASaldo_Totale = '12.42';
        MyClass.DaSaldo_Totale = '12.42';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();
    	MyClass.pagination();
    	//MyClass.aggiorna_Elenco(ListPratica);
    	//MyClass.End();
    	MyClass.Next();
    	MyClass.Indietro();
    	MyClass.HomePage();
    	MyClass.getleftselected_Tipo_Lettera();
    	MyClass.SelectAll();
    	//MyClass.Next();
    	MyClass.HAVEOptionPickVisibilityResult();
    	//MyClass.UpdateListe();
    	MyClass.AggiornaElementoLista();
    	MyClass.ConfermaLista();
    	MyClass.getEnablePrevious();
    	MyClass.getEnableNext();
    	MyClass.Previous();
    	MyClass.Beginning();
    }
    
    
    static testMethod void myUnitTest11() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.43';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = 'error';
        MyClass.DaScaduto_Spese = '12.42';
        MyClass.AScaduto_Spese = '12.42';
        MyClass.ASaldo_Totale = '12.42';
        MyClass.DaSaldo_Totale = '12.42';*/
    
    	MyClass.VaiATabella();
    	MyClass.FiltroQuery();
    	MyClass.pagination();
    	//MyClass.aggiorna_Elenco(ListPratica);
    	//MyClass.End();
    	MyClass.Next();
    	MyClass.Indietro();
    	MyClass.HomePage();
    	MyClass.getleftselected_Tipo_Lettera();
    	MyClass.SelectAll();
    	//MyClass.Next();
    	MyClass.HAVEOptionPickVisibilityResult();
    	//MyClass.UpdateListe();
    	MyClass.AggiornaElementoLista();
    	MyClass.ConfermaLista();
    	MyClass.getEnablePrevious();
    	MyClass.getEnableNext();
    	MyClass.Previous();
    	MyClass.Beginning();
    }
    
     static testMethod void myUnitTest12() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.43';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.43';
        MyClass.DaScaduto_Spese = 'error';
        MyClass.AScaduto_Spese = '12.42';
        MyClass.ASaldo_Totale = '12.42';
        MyClass.DaSaldo_Totale = '12.42';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();
    	MyClass.pagination();
    	//MyClass.aggiorna_Elenco(ListPratica);
    	//MyClass.End();
    	MyClass.Next();
    	MyClass.Indietro();
    	MyClass.HomePage();
    	MyClass.getleftselected_Tipo_Lettera();
    	MyClass.SelectAll();
    	//MyClass.Next();
    	MyClass.HAVEOptionPickVisibilityResult();
    	//MyClass.UpdateListe();
    	MyClass.AggiornaElementoLista();
    	MyClass.ConfermaLista();
    	MyClass.getEnablePrevious();
    	MyClass.getEnableNext();
    	MyClass.Previous();
    	MyClass.Beginning();
    }
    
     static testMethod void myUnitTest13() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
            T.ActivityExtended__c = ae.Id;
        	ae.Owner_contratto__c = 'Gelsomino';
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.43';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.43';
        MyClass.DaScaduto_Spese = '12.43';
        MyClass.AScaduto_Spese = 'error';
        MyClass.ASaldo_Totale = '12.42';
        MyClass.DaSaldo_Totale = '12.42';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();
    	MyClass.pagination();
    	//MyClass.aggiorna_Elenco(ListPratica);
    	//MyClass.End();
    	MyClass.Next();
    	MyClass.Indietro();
    	MyClass.HomePage();
    	MyClass.getleftselected_Tipo_Lettera();
    	MyClass.SelectAll();
    	//MyClass.Next();
    	MyClass.HAVEOptionPickVisibilityResult();
    	//MyClass.UpdateListe();
    	MyClass.AggiornaElementoLista();
    	MyClass.ConfermaLista();
    	MyClass.getEnablePrevious();
    	MyClass.getEnableNext();
    	MyClass.Previous();
    	MyClass.Beginning();
    }
    
    
     static testMethod void myUnitTest14() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.43';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.43';
        MyClass.DaScaduto_Spese = '12.43';
        MyClass.AScaduto_Spese = '12.44';
        MyClass.ASaldo_Totale = 'error';
        MyClass.DaSaldo_Totale = '12.42';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();
    	MyClass.pagination();
    	//MyClass.aggiorna_Elenco(ListPratica);
    	//MyClass.End();
    	MyClass.Next();
    	MyClass.Indietro();
    	MyClass.HomePage();
    	MyClass.getleftselected_Tipo_Lettera();
    	MyClass.SelectAll();
    	//MyClass.Next();
    	MyClass.HAVEOptionPickVisibilityResult();
    	//MyClass.UpdateListe();
    	MyClass.AggiornaElementoLista();
    	MyClass.ConfermaLista();
    	MyClass.getEnablePrevious();
    	MyClass.getEnableNext();
    	MyClass.Previous();
    	MyClass.Beginning();
    }
    
    
    static testMethod void myUnitTest15() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.43';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.43';
        MyClass.DaScaduto_Spese = '12.43';
        MyClass.AScaduto_Spese = '12.44';
        MyClass.ASaldo_Totale = '12.44';
        MyClass.DaSaldo_Totale = 'error';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();

    }
    
        static testMethod void myUnitTest16() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.43';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.43';
        MyClass.DaScaduto_Spese = '12.43';
        MyClass.AScaduto_Spese = '12.44';
        MyClass.ASaldo_Totale = '12.44';
        MyClass.DaSaldo_Totale = '12.45';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();

    }
    
    static testMethod void myUnitTest17() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.43';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.43';
        MyClass.DaScaduto_Spese = '12.43';
        MyClass.AScaduto_Spese = '12.44';
        MyClass.ASaldo_Totale = '12.44';
        MyClass.DaSaldo_Totale = '12.45';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();

    }
    
    static testMethod void myUnitTest18() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.43';
        MyClass.DaScaduto_Spese = '12.43';
        MyClass.AScaduto_Spese = '12.44';
        MyClass.ASaldo_Totale = '12.44';
        MyClass.DaSaldo_Totale = '12.45';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();

    }
    
    static testMethod void myUnitTest19() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.42';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.43';
        MyClass.DaScaduto_Spese = '12.43';
        MyClass.AScaduto_Spese = '12.44';
        MyClass.ASaldo_Totale = '12.44';
        MyClass.DaSaldo_Totale = '12.45';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();

    }
    
    static testMethod void myUnitTest20() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.42';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = '';
        MyClass.AAnzianita_scaduto = '12.43';
        MyClass.DaScaduto_Spese = '12.43';
        MyClass.AScaduto_Spese = '12.44';
        MyClass.ASaldo_Totale = '12.44';
        MyClass.DaSaldo_Totale = '12.45';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();

    }
    
     static testMethod void myUnitTest21() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.42';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.43';
        MyClass.DaScaduto_Spese = '';
        MyClass.AScaduto_Spese = '12.44';
        MyClass.ASaldo_Totale = '12.44';
        MyClass.DaSaldo_Totale = '12.45';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();

    }
    
    static testMethod void myUnitTest22() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.42';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.43';
        MyClass.DaScaduto_Spese = '12.43';
        MyClass.AScaduto_Spese = '12.44';
        MyClass.ASaldo_Totale = '';
        MyClass.DaSaldo_Totale = '12.45';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();

    }
    
        static testMethod void myUnitTest23() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '13.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.42';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.43';
        MyClass.DaScaduto_Spese = '12.43';
        MyClass.AScaduto_Spese = '12.44';
        MyClass.ASaldo_Totale = '12.44';
        MyClass.DaSaldo_Totale = '12.45';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();

    }
    
    static testMethod void myUnitTest24() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '13.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.42';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.43';
        MyClass.DaScaduto_Spese = '12.43';
        MyClass.AScaduto_Spese = '12.44';
        MyClass.ASaldo_Totale = '12.44';
        MyClass.DaSaldo_Totale = '12.45';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();

    }
    
    static testMethod void myUnitTest25() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '13.42';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.43';
        MyClass.DaScaduto_Spese = '12.43';
        MyClass.AScaduto_Spese = '12.44';
        MyClass.ASaldo_Totale = '12.44';
        MyClass.DaSaldo_Totale = '12.45';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();

    }
    
    static testMethod void myUnitTest26() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.42';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '13.42';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.43';
        MyClass.DaScaduto_Spese = '12.43';
        MyClass.AScaduto_Spese = '12.44';
        MyClass.ASaldo_Totale = '12.45';
        MyClass.DaSaldo_Totale = '12.46';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();

    }
    
      static testMethod void myUnitTest28() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.42';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = '13.42';
        MyClass.AAnzianita_scaduto = '12.43';
        MyClass.DaScaduto_Spese = '12.43';
        MyClass.AScaduto_Spese = '12.44';
        MyClass.ASaldo_Totale = '12.45';
        MyClass.DaSaldo_Totale = '12.46';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();

    }
    
    static testMethod void myUnitTest29() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.42';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.43';
        MyClass.DaScaduto_Spese = '13.43';
        MyClass.AScaduto_Spese = '12.44';
        MyClass.ASaldo_Totale = '12.45';
        MyClass.DaSaldo_Totale = '12.46';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();

    }
    
    static testMethod void myUnitTest30() {
    	
    	List<Strategia__c> ListStrategie = new List<Strategia__c>();
    	List<Strategia__c> ListTestata = new List<Strategia__c>();
    	List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    	
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;
    	for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;
        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
        	System.debug('**TEST Str.Id = ' + Str.Id);
        	System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
        	System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
        	System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }
        
        
        List<Pratica__c> ListPratica = new List<Pratica__c>();
        for(Integer i=0; i<16; i++){
        	Pratica__c Prat = new Pratica__c();
        	ListPratica.add(Prat);
        }
        insert ListPratica;
        List<Id> ListIdPratica = new List<Id>();
        for(Pratica__c Prat : ListPratica)
        	ListIdPratica.add(Prat.Id);
        
        Profile pro = [select id from Profile where name like '%admin%' limit 1]; 
        
       User Utente1 = new User ( isactive = true,
	                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
	                Email = 'Unassigned@god.it', Alias = 'Unassi',ProfileID = pro.id, 
	                CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente1;
        
        User Utente2 = new User ( isactive = true,
	                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
	                Email = 'GEGGIO@god.it', Alias = 'UnassiSa',ProfileID = pro.id,
	                CommunityNickname ='guest2' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
	                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
               );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++){
        	Task T = new Task();
        	T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
        	T.Priority = 'Alta';
        	ae.Tipo__c = 'Invio Lettera di Posta Prioritaria Standard';
        	ae.Sotto_Tipo__c = 'Piano di rientro';
        	T.Status = 'Non Iniziata';
        	T.WhatId = ListIdPratica[i];
        	ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
        	ListTask.add(T);
        }
        insert aes;
        insert ListTask;
        TaskSemiAutomatici.PraticheSelectable PratSelec = new TaskSemiAutomatici.PraticheSelectable();
        List<TaskSemiAutomatici.PraticheSelectable> ListPratSelec = new List<TaskSemiAutomatici.PraticheSelectable>();

        for(Integer i=0; i<ListStrategie.size(); i++){
        	TaskSemiAutomatici.PraticheSelectable PratSelecClass = new TaskSemiAutomatici.PraticheSelectable ();
        	PratSelecClass.Position = i;
        	PratSelecClass.isSelected = true;
			PratSelecClass.Prat = ListPratica[i];
			PratSelecClass.Strat = ListStrategie[i];
		}
		
        String TipoH = ApexPages.currentPage().getParameters().put('TipoH', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoH = ApexPages.currentPage().getParameters().put('SottoTipoHeader', 'Piano di rientro');	
        String MHeader = ApexPages.currentPage().getParameters().put('Header', 'Header');
        String TipoContent = ApexPages.currentPage().getParameters().put('TipoContent', 'Invio Lettera di Posta Prioritaria Standard');
        String SottoTipoContent = ApexPages.currentPage().getParameters().put('SottoTipoContent', 'Piano di rientro');
        String OwnerContent = ApexPages.currentPage().getParameters().put('OwnerContent', 'Gelsomino');
        String Header_Content = ApexPages.currentPage().getParameters().put('Header_Content', null);
        
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected' , '5');
        
        String Sel = ApexPages.currentPage().getParameters().put('isSel', 'false');
        String Pratica = ApexPages.currentPage().getParameters().put('Codice_Pratica', ListPratica[0].Name);
        
        TaskSemiAutomatici MyClass = new TaskSemiAutomatici();
        /*List<String> originalValues_Comune = MyClass.originalValues_Comune;
        List<String> originalValues_CodiceServizio = MyClass.originalValues_CodiceServizio;
        List<String> originalValues_IdContratto = MyClass.originalValues_IdContratto;
        List<String> originalValues_Stato = MyClass.originalValues_Stato;
        List<String> originalValues_ClasseDiRischio = MyClass.originalValues_ClasseDiRischio;
        MyClass.DaScaduto = '12.42';
        MyClass.AScaduto = '12.43';
        MyClass.DaScadutoConsolidato = '12.42';
        MyClass.AScadutoConsolidato = '12.43';
       	MyClass.DaSaldoSpese = '12.42';
        MyClass.ASaldoSpese = '12.44';
        MyClass.DaSaldoConsolidato = '12.42';
        MyClass.ASaldoConsolidato = '12.43';

        MyClass.DaAnzianita_scaduto = '12.42';
        MyClass.AAnzianita_scaduto = '12.43';
        MyClass.DaScaduto_Spese = '12.43';
        MyClass.AScaduto_Spese = '12.44';
        MyClass.ASaldo_Totale = '13.45';
        MyClass.DaSaldo_Totale = '12.46';*/
        
        MyClass.VaiATabella();
    	MyClass.FiltroQuery();

    }
}