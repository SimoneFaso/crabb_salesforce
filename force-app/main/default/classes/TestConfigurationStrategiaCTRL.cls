/* ---------------------------------------------------------------------------------------------------------------------
Name:            ConfigurationStrategiaCTRL.cls
Description:     Test Class for code coverage of ConfigurationStrategiaCTRL.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                          First Version
15-Jun-2022  0.2      C. Sanna & V.Doda   Modified for code coverage
----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class TestConfigurationStrategiaCTRL {
	
	@isTest static void test_method_one() {
		Test.startTest();

		ConfigurationStrategiaCTRL ctrl = new ConfigurationStrategiaCTRL();

		Test.stopTest();
	}

	@isTest static void test_method_two() {
		Test.startTest();

		Rule_control__c rc = new Rule_control__c();
		rc.Rule_Name__c = 'Test';
		rc.Name = 'Test';
		rc.Api_object_name__c = 'Pratica__c';
		rc.Api_field_name__c = 'Name';
		rc.Condition__c = '!=';
		rc.Strategia_api_field_name__c = 'Name';
		insert rc;

		Strategia__c testata= new Strategia__c();
        Strategia__c step= new Strategia__c();
        testata=TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        step=TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id,testata.id);
        insert step;
		
        PageReference page = new PageReference('/apex/ConfigurationStrategia');
        page.getParameters().put('testid',testata.Id);
        Test.setCurrentPage(page);
		ConfigurationStrategiaCTRL ctrl = new ConfigurationStrategiaCTRL();
		ctrl.getChartString();

		ctrl.newTestataName = 'Test';
		ctrl.newTestataDescr = 'Test';
		ctrl.newTestataVers = 1;
		ctrl.newTestataPrior = 1;
		ctrl.createTestata();

		ctrl.newCDIName = 'Test';
		ctrl.newCDIPrior = 1;
		ctrl.newCDIVers = 1;
		ctrl.createCDI();

		ctrl.newCDUName = 'Test';
		ctrl.newCDUPrior = 1;
		//ctrl.newCDUVers = 1;
		ctrl.newCDUEsito = 'Test Esito';
		ctrl.createCDU();

		ctrl.newSname = 'Test';
		ctrl.selectedTipologia = 'Test';
		ctrl.selectedFase = 'Legale';
		ctrl.selectedTipoAtt = 'Test';
		ctrl.selectedSottotipo = 'Test';
		ctrl.selectedRuleStep = 'Test';
		ctrl.selectedAttivitaPadre = testata.Id;
		ctrl.newSprior = 1;
		ctrl.createStep();

		ctrl.newJname = 'testJump';
		ctrl.selectedJumpFrom = step.Id;
		ctrl.selectedJumpTo = step.Id;
		ctrl.createJump();

		Test.stopTest();
	}

	@isTest static void test_method_three() {
		Test.startTest();

		Rule_control__c rc = new Rule_control__c();
		rc.Rule_Name__c = 'Test';
		rc.Name = 'Test';
		rc.Api_object_name__c = 'Pratica__c';
		rc.Api_field_name__c = 'Name';
		rc.Condition__c = '!=';
		rc.Strategia_api_field_name__c = 'Name';
		insert rc;

		Strategia__c testata= new Strategia__c();
        Strategia__c step= new Strategia__c();
        testata=TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        step=TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id,testata.id);
        insert step;
		
        PageReference page = new PageReference('/apex/ConfigurationStrategia');
        Test.setCurrentPage(page);
		ConfigurationStrategiaCTRL ctrl = new ConfigurationStrategiaCTRL();
		ctrl.getChartString();

		ctrl.newTestataName = 'Test';
		ctrl.newTestataDescr = 'Test';
		ctrl.newTestataVers = 1;
		ctrl.newTestataPrior = 1;
		ctrl.selectedTipoStratTestata = 'Standard';
		ctrl.createTestata();

		ctrl.newCDIName = 'Test';
		ctrl.newCDIPrior = 1;
		ctrl.newCDIVers = 1;
		ctrl.createCDI();

		ctrl.newCDUName = 'Test';
		ctrl.newCDUPrior = 1;
		//ctrl.newCDUVers = 1;
		ctrl.createCDU();

		ctrl.newSname = 'Test';
		ctrl.selectedTipologia = 'Test';
		ctrl.selectedFase = 'Legale';
		ctrl.selectedTipoAtt = 'Test';
		ctrl.selectedSottotipo = 'Test';
		ctrl.selectedRuleStep = 'Test';
		ctrl.selectedAttivitaPadre = testata.Id;
		ctrl.createStep();

		Test.stopTest();
	}

}