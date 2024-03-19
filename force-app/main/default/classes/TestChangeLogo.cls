@isTest
private class TestChangeLogo {
	
	@isTest static void test_method_one() {
		Test.startTest();

		ChangeLogoCTRL ctrl = new ChangeLogoCTRL();
		ctrl.newLogo = Blob.valueOf('TEST');
		ctrl.updateLogo();

		Test.stopTest();
	}
	
}