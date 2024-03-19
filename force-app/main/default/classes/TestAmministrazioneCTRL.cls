@IsTest
private class TestAmministrazioneCTRL {
	
	@IsTest static void test_method_one() {
		Test.startTest();

		AmministrazioneSettings__c ase = new AmministrazioneSettings__c();
		ase.SetupOwnerId = UserInfo.getProfileId();
		insert ase;

		AmministrazioneCTRL ctrl = new AmministrazioneCTRL();
		AmministrazioneCTRL.getCurrentAS();
		AmministrazioneCTRL.getUrl();
        AmministrazioneCTRL.importCustomSetting();

		Test.stopTest();
	}
	
}