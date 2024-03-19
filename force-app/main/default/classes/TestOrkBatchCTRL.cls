@isTest
private class TestOrkBatchCTRL {
	
	@isTest static void test_method_one() {
		Test.startTest();

		OrkBatchCTRL ctrl = new OrkBatchCTRL();
		ctrl.runOrkBatch();
		ctrl.refresh();
		ctrl.rescheduleEveryHour();

		Test.stopTest();
	}

	@isTest static void test_method_two() {
		Test.startTest();

		OrkBatchCTRL ctrl = new OrkBatchCTRL();
		ctrl.runOrkBatch();
		ctrl.refresh();
		ctrl.selectedDay = system.label.Monday;
		ctrl.selectedMonth = system.label.January;
		ctrl.selectedHour = '0';
		ctrl.reschedule();

		Test.stopTest();
	}
	
}