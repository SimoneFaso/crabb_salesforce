@IsTest
private class TestCRABB_ListOfFieldsCS
{
	public static testmethod void testCSV(){

		ListOfFields__c testLof = new ListOfFields__c(Name='CSVNEW0000001',Field__c='Id',Field_Label__c='Id',Show__c=false,Object__c='CSV||Pratica__c');
		insert testLof;

		Test.startTest();

		Response response = CRABB_ListOfFieldsCS.onComponentLoad('CSVNEW');

		Response response1 = CRABB_ListOfFieldsCS.updateRecords(JSON.serialize(response.Data));

		Response response2 = CRABB_ListOfFieldsCS.retrieveListFields('Account' );

		Response response3 = CRABB_ListOfFieldsCS.addRecord('Account' ,
				'Id',
				false,
				'CSVNEW','ID');
		Response response4 = CRABB_ListOfFieldsCS.removeRecord(testLof.Id, 'CSVNEW');

		Test.stopTest();
	}

	@isTest static void testPDF(){
		Test.startTest();

		ListOfFields__c testLof = new ListOfFields__c(Name='Pdf_01',Field__c='Id',Field_Label__c='Id',Show__c=false,Object__c='Pratica__c');
		insert testLof;

		Response response = CRABB_ListOfFieldsCS.onComponentLoad('PDF');

		Response response1 = CRABB_ListOfFieldsCS.updateRecords(JSON.serialize(response.Data));

		Response response2 = CRABB_ListOfFieldsCS.retrieveListFields('Account' );

		Response response3 = CRABB_ListOfFieldsCS.addRecord('Account' ,
				'Id',
				false,
				'PDF','ID');

		Response response4 = CRABB_ListOfFieldsCS.removeRecord(testLof.Id, 'PDF');

		Test.stopTest();
	}

	@isTest static void testTAB(){
		Test.startTest();

		Response response = CRABB_ListOfFieldsCS.onComponentLoad('TAB');

		Response response1 = CRABB_ListOfFieldsCS.updateRecords(JSON.serialize(response.Data));

		Response response2 = CRABB_ListOfFieldsCS.retrieveTabObj('Statement of Account' );

		//CRABB_ListOfFieldsCS.addTabField('Id' ,'Statement Of Account',false,'TAB');

		Test.stopTest();
	}

	@isTest static void testWrongObj(){
		Test.startTest();

		Response response = CRABB_ListOfFieldsCS.onComponentLoad('wrong');

		Test.stopTest();
	}
}