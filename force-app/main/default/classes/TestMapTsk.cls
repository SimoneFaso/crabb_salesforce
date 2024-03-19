@isTest
private class TestMapTsk {
	
	@isTest static void test_method_one() {
		// Implement test code
		
		List<Task> ltask = new List<Task>();
		// Creazione STR
        /*Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByName().get('Step').getRecordTypeId();
        Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByName().get('Testata').getRecordTypeId();*/
            Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
            Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();

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
            Strat.Nome__c = 'Attesa verifica condizioni';
        insert strat;
        // crea acc e contratto per pratica
        Contratto__c con = TestclassfrodataGenAffidamenti.getContratto();
        insert con;
        Account acc = TestclassfrodataGenAffidamenti.getAccount(con.Id);
        acc.Name = 'Endritnnnn';
        insert acc;
        
        Pratica__c p = TestclassfrodataGenAffidamenti.getPratica(acc.Id);
        p.Strategia__c = testata.id;
        insert p;
        
        //3- 
        Task t1 = new Task();
        t1.subject = 'Gestione Manuale post diffida';
        t1.status = 'In approvazione';
        ActivityExtended__c ae = new ActivityExtended__c();
        ae.id_attivita__c = strat.id;
        ae.tipo__c = 'Raccomandata';
        ae.RecordTypeId = Schema.SObjectType.ActivityExtended__c.getRecordTypeInfosByName().get('UI').getRecordTypeId();
        insert ae;
        t1.ActivityExtended__c = ae.Id;
        t1.whatId = p.id; 
        insert t1;
        Test.setCreatedDate(t1.id, DateTime.now());
        Task q = [Select Id,CreatedDate,ActivityExtended__r.Tipo__c,subject,status,ActivityExtended__r.id_attivita__c,whatId from Task where id=:t1.id limit 1];
        ltask.add(q);
        Task t2 = new Task();
        t2.subject = 'Diffida proposta';
        t2.status = 'In approvazione';
        ActivityExtended__c ae2 = new ActivityExtended__c();
        ae2.id_attivita__c = strat.id;
        ae2.tipo__c = 'Raccomandata';
        ae2.RecordTypeId = Schema.SObjectType.ActivityExtended__c.getRecordTypeInfosByName().get('UI').getRecordTypeId();
        insert ae2;
        t2.ActivityExtended__c = ae2.Id;
        t2.whatId = p.id;
        //Test.setCreatedDate(t2.id, System.now());
        insert t2;
        //ltask.add(t2);
        User u3 = TestClassFroDataGenAffidamenti.getUser('CRABB Credit Manager');
        // 4- Crea tag:
        Tag__c t = new Tag__c(Name = 'Ruolo Credit Manager Id', ValueText__c = u3.UserRoleId);
        insert t;
        Test.startTest();
        MapTsk mt = new MapTsk();
		mt.CreateMapTsk(ltask);
		Test.stopTest();
	}
	
}