@isTest
private class BatchStatoPraticaTEST {
	
	@isTest static void test_one_param() {
        Test.startTest();

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
        m.Stato_Pratiica_Picklist__c = null;
        insert m;

        Movimento__c mm = testClassForDataGenerationCreateData.getTestMovimento();
        Date tmmp = system.today();
        tmmp.addDays(5);
        mm.pratica__c = p.id;
        mm.account__c = a.id;
        mm.Data_Scadenza__c= tmmp;
        mm.Stato_Pratiica_Picklist__c = 'Chiusa';
        insert mm;

        p.Stato__c = 'In Lavorazione';
        update p;
        
        Database.executeBatch(new BatchStatoPratica(p.Id,p.Stato__c));

        test.StopTest();
	}

	@isTest static void test_two_param() {
        Test.startTest();

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
        m.Stato_Pratiica_Picklist__c = null;
        insert m;

        Movimento__c mm = testClassForDataGenerationCreateData.getTestMovimento();
        Date tmmp = system.today();
        tmmp.addDays(5);
        mm.pratica__c = p.id;
        mm.account__c = a.id;
        mm.Data_Scadenza__c= tmmp;
        mm.Stato_Pratiica_Picklist__c = 'Chiusa';
        insert mm;

        p.Stato__c = 'In Lavorazione';
        update p;
        
        Database.executeBatch(new BatchStatoPratica(p.Id,p.Stato__c,true));

        test.StopTest();
	}
	
}