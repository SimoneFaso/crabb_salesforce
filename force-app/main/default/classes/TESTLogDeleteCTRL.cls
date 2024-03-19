@isTest
private class TESTLogDeleteCTRL {


	@isTest static void test_method_one() {
		
		Test.startTest();

		Log__c l = new Log__c();

		insert l;

		LogDeleteCTRL ctrl = new LogDeleteCTRL();
		ctrl.refresh();
		ctrl.message = 'TEST';
		ctrl.showConfirm();
		ctrl.showError();
		ctrl.deleteAll();

		Test.stopTest();
	}

	@isTest static void test_method_two() {

		Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Log__c.getRecordTypeInfosByName();

		Test.startTest();

		Log__c l = new Log__c();

		l.recordTypeId = ctRecordTypes.get('Debug').getRecordTypeID();

		insert l;

		String f = '02/09/2017 16.51';
		String t = '02/09/2017 16.57';
		LogDeleteCTRL.deletePartial(f, t);

		Test.stopTest();
	}
	
}