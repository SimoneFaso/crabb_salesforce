@isTest
private class TestPreviewDocuments {

    static testMethod void UnitTest1() {
    	
    	PreViewDocuments pvd = new PreViewDocuments();
    	
    	test.startTest();
    	
    	pvd.PrendiValori();
    	pvd.CheckString();
    	
    	test.stopTest();
    }
}