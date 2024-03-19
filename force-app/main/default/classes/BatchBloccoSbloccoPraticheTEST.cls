@isTest
private class BatchBloccoSbloccoPraticheTEST {
	
	@isTest static void insertBlockingAndNonBlockingCases() {
		Account a = new Account(name = 'Alessio Massidda');
		insert a;

		List<Case> cases = new List<Case>();
		cases.add(new Case(status = 'Open', origin = 'Web', accountId = a.Id));
		cases.add(new Case(status = 'Open', origin = 'Phone', accountId = a.Id, Blocking_SR__c = true));
		insert cases;

		Test.startTest();
			Database.executeBatch(new BatchBloccoSbloccoPratiche());
		Test.stopTest();
	}

	@isTest static void insertBlockingAndNonBlockingCasesAndCloseJustOne(){
		Account a = new Account(name = 'Alessio Massidda');
		insert a;

		List<Case> cases = new List<Case>();
		cases.add(new Case(status = 'Open', origin = 'Web', accountId = a.Id));
		cases.add(new Case(status = 'Open', origin = 'Phone', accountId = a.Id, Blocking_SR__c = true));
		cases.add(new Case(status = 'On Hold', origin = 'Phone', accountId = a.Id, Blocking_SR__c = true));
		insert cases;
		
		Database.executeBatch(new BatchBloccoSbloccoPratiche());
		
		cases.get(2).status = 'Closed';
		update cases.get(2);

		Test.startTest();
			Database.executeBatch(new BatchBloccoSbloccoPratiche());
		Test.stopTest();
	}

	@isTest static void lockAndUnlockPraticas(){
		Account a = new Account(name = 'Alessio Massidda');
		insert a;

		List<Case> cases = new List<Case>();
		cases.add(new Case(status = 'Open', origin = 'Phone', accountId = a.Id, Blocking_SR__c = true));
		insert cases;
		
		Database.executeBatch(new BatchBloccoSbloccoPratiche());
		
		cases.get(0).status = 'Closed';
		update cases;

		Test.startTest();
			Database.executeBatch(new BatchBloccoSbloccoPratiche());
		Test.stopTest();
	}

	@isTest static void forceExceptions(){
		Id profileID = [SELECT ID FROM Profile WHERE Name = 'Chatter External User' LIMIT 1].Id;
		User u = new User(lastName = 'Pallino', profileId = profileId, Username = 'pinco@pinco.it', Email = 'pinco@pinco.it', Alias = 'pinco', 
			CommunityNickname = 'pinco', TimeZoneSidKey = 'Europe/Rome', LocaleSidKey = 'pt_BR', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'pt_BR');
		insert u ;

		try{
			System.runAs(u){
				Database.executeBatch(new BatchBloccoSbloccoPratiche());
			}
		}
		catch(Exception e){}
	}

	@isTest static void testDeprecatedConstructor(){
		Database.executeBatch(new BatchBloccoSbloccoPratiche(new Set<Id>(), true));
	}
}