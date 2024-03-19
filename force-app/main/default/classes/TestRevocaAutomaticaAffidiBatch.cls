@isTest
private class TestRevocaAutomaticaAffidiBatch {
	
	@isTest static void test_method_one() {
		test.startTest();
		User u = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');
        Collector__c col = TestClassFroDataGenAffidamenti.getCollector(u.Id);
        insert col;
        
        List<Lotto__c> tmp = new List<Lotto__c>();
        
        for(integer i = 0;i<10; i++)
            tmp.add(new Lotto__c(Stato__c = 'Stato', Agenzia_di_recupero__c = col.id));
        insert tmp;
        Affidamento__c aff = TestClassFroDataGenAffidamenti.getQuickAffido();
        aff.Scaduto_iniziale__c = 12;
        aff.Scaduto_finale__c = 4;
        
        // 3-
        Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        Database.insert(con, false);
        Account ac = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert ac;
        
        Pratica__c p = new Pratica__c(Account__c = ac.id, Data_ultimo_Saldo__c = System.today());
        p.Stato__c = 'Affidato';
        insert p;
        
        aff.Lotto__c = tmp[0].id;
        aff.Pratica__c = p.id;
        aff.Stato__c = 'In corso';
        aff.Data_fine_affidamento_prevista__c = System.today()-1;
        insert aff;
        
        Task t = new Task();
        t.Type = 'Credito';
        ActivityExtended__c ae = new ActivityExtended__c();
        ae.id_affidamento__c = aff.id;
        insert ae;
        t.ActivityExtended__c = ae.Id;
        t.Status = 'Non Iniziata';
        insert t;
        RevocaAutomaticaAffidiBatch istanza = new RevocaAutomaticaAffidiBatch();
        Id process = Database.executeBatch(istanza);
        test.stopTest();
	}

	@isTest static void test_method_two() {
		
		User u = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');
        Collector__c col = TestClassFroDataGenAffidamenti.getCollector(u.Id);
        insert col;
        
        List<Lotto__c> tmp = new List<Lotto__c>();
        
        for(integer i = 0;i<10; i++)
            tmp.add(new Lotto__c(Stato__c = 'Stato', Agenzia_di_recupero__c = col.id));
        insert tmp;
        delete [Select id from Affidamento__c];
        Affidamento__c aff = TestClassFroDataGenAffidamenti.getQuickAffido();
        aff.Scaduto_iniziale__c = 12;
        aff.Scaduto_finale__c = 4;
        
        // 3-
        Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        Database.insert(con, false);
        Account ac = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert ac;
        
        Pratica__c p = new Pratica__c(Account__c = ac.id, Data_ultimo_Saldo__c = System.today());
        p.Stato__c = 'Affidato';
        insert p;
        
        aff.Lotto__c = tmp[0].id;
        aff.Pratica__c = p.id;
        aff.Stato__c = 'Da confermare';
        aff.Data_fine_affidamento_prevista__c = System.today()+1;
        insert aff;
        
        Task t = new Task();
        t.Type = 'Credito';
        ActivityExtended__c ae = new ActivityExtended__c();
        ae.id_affidamento__c = aff.id;
        insert ae;
        t.ActivityExtended__c = ae.Id;
        t.Status = 'Non Iniziata';
        insert t;
         Task t2 = new Task();
        t2.Type = 'Credito';
        ActivityExtended__c ae2 = new ActivityExtended__c();
        ae2.id_affidamento__c = aff.id;
        insert ae2;
        t2.ActivityExtended__c = ae2.Id;
        t2.Status = 'Non Iniziata';
        insert t2;
        test.startTest();
        RevocaAutomaticaAffidiBatch istanza = new RevocaAutomaticaAffidiBatch();
        Id process = Database.executeBatch(istanza);
        test.stopTest();
	}


	
}