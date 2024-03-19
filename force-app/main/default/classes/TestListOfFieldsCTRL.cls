@isTest
public class TestListOfFieldsCTRL {
    
    @isTest static void testOne(){
        Test.startTest();

        PageReference page = new pageReference('/apex/ListOfFieldsCS');
        page.getParameters().put('object','CSVNEW');
        Test.setCurrentPage(page);
        ListOfFieldsCSCTRL ctrl = new ListOfFieldsCSCTRL();

        ctrl.updateRecords();
        ctrl.getMapShowTF();
        ctrl.getMapTabRecName();
        ctrl.createTabObj();
        ctrl.selectedTO = 'Statement of Account';
        ctrl.retrieveTabObj();
        ctrl.selectedOF = 'Id';
        ctrl.selectedTOFvisible = false;
        ctrl.addTabField();
        ctrl.retrieveTabFields();

        Test.stopTest();
    }

    @isTest static void testOnePDF(){
        Test.startTest();

        ListOfFields__c testLof = new ListOfFields__c(Name='Pdf_01',Field__c='Id',Field_Label__c='Id',Show__c=false,Object__c='Pratica__c');
        insert testLof;

        PageReference page = new pageReference('/apex/ListOfFieldsCS');
        page.getParameters().put('object','PDF');
        Test.setCurrentPage(page);
        ListOfFieldsCSCTRL ctrl = new ListOfFieldsCSCTRL();

        ctrl.updateRecords();

        ctrl.selectedObj = 'Account';
        ctrl.selectedField = 'Id';
        ctrl.selectedVisible = false;
        ctrl.addRecord();

        Test.stopTest();
    }

    @isTest static void testOneCSV(){
        Test.startTest();

        PageReference page = new pageReference('/apex/ListOfFieldsCS');
        page.getParameters().put('object','CSVNEW');
        Test.setCurrentPage(page);
        ListOfFieldsCSCTRL ctrl = new ListOfFieldsCSCTRL();

        ctrl.updateRecords();

        ListOfFields__c testLof = new ListOfFields__c(Name='CSVNEW0000001',Field__c='Id',Field_Label__c='Id',Show__c=false,Object__c='CSV||Pratica__c');
        insert testLof;

        ctrl.selectedObj = 'Account';
        ctrl.selectedField = 'Id';
        ctrl.selectedVisible = false;
        ctrl.addRecord();

        ListOfFieldsCSCTRL.removeRecords(testLof.Id, 'CSVNEW');

        Test.stopTest();
    }

    @isTest static void testObjNull(){
        Test.startTest();

        ListOfFieldsCSCTRL ctrl = new ListOfFieldsCSCTRL();
        ctrl.retrieveListFields();
        ctrl.selectedObj = 'Account';
        ctrl.retrieveListFields();

        Test.stopTest();
    }

    @isTest static void testObjNotAdmitted(){
        Test.startTest();

        PageReference page = new pageReference('/apex/ListOfFieldsCS');
        page.getParameters().put('object','TEST');
        Test.setCurrentPage(page);
        ListOfFieldsCSCTRL ctrl = new ListOfFieldsCSCTRL();

        Test.stopTest();
    }
}