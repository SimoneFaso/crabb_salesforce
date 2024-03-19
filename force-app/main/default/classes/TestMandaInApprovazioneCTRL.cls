/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestMandaInApprovazioneCTRL.cls
Description:      Test Class for code coverage of MandaInApprovazioneCTRL.cls


Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
09-Feb-2015  0.1      Endrit Sino                     First Version
30-Sep-2021  0.2      C. Sanna M. Pizzichini          Replaced getRecordTypeInfosByName with
                                                      getRecordTypeInfosByDeveloperName

----------------------------------------------------------------------------------------------------------------------*/

@isTest
public class TestMandaInApprovazioneCTRL {
	
    static testmethod void UnitTest(){
        // Creazione STR
        //Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByName().get('Step').getRecordTypeId();
        Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
        //Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByName().get('Testata').getRecordTypeId();
        Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
        Strategia__c Testata = new Strategia__c();
            Testata.RecordTypeId = rtStrat_Testata;
        Testata.Tipologia__c = 'UI';
            Testata.Stato__c = 'Attiva';
            Testata.Nome__c = 'STRATEGIA CONCESSIONE';
        insert testata;
        Strategia__c Strat = new Strategia__c();
            Strat.RecordTypeId=rtStrat_Step;
            Strat.Tipologia__c = 'UI';
            Strat.Testata__c = testata.Id;
            Strat.Nome__c = 'Attesa verifica condizioni';
        insert strat;
        // crea acc e contratto per pratica
        Contratto__c con = TestclassfrodataGenAffidamenti.getContratto();
        insert con;
        Account acc = TestclassfrodataGenAffidamenti.getAccount(con.Id);
        acc.Name = 'Endrit';
        insert acc;
        
        Pratica__c p = TestclassfrodataGenAffidamenti.getPratica(acc.Id);
        p.Strategia__c = testata.id;
        insert p;
        
        //3- 
        Task t1 = new Task();
        t1.subject = 'Gestione Manuale post diffida';
        t1.status = 'In corso';
        ActivityExtended__c ae = new ActivityExtended__c();
        ae.id_attivita__c = strat.id;
        ae.RecordTypeId = Schema.SObjectType.ActivityExtended__c.getRecordTypeInfosByName().get('UI').getRecordTypeId();
        insert ae;
        t1.whatId = p.id;
        t1.ActivityExtended__c = ae.Id;
        insert t1;
        User u3 = TestClassFroDataGenAffidamenti.getUser('CRABB Operatore Credito');
        // 4- Crea tag:
        Tag__c t = new Tag__c(Name = 'Ruolo Operatore Credito Id', ValueText__c =u3.UserRoleId);
        insert t;
        
        // Test as User Operator
        // User u3 = [SELECT Id FROM User WHERE UserRoleId = '00Ew0000000kx7nEAA' limit 1];
        System.runAs(u3){
        	test.startTest();
            Test.setCurrentPage(new pageReference('/apex/MandaInApprovazione'));
            ApexPages.currentPage().getParameters().put('id', p.id);
            
			MandaInApprovazioneCTRL mia = new MandaInApprovazioneCTRL();
            
            // set task scelta
            ApexPages.currentPage().getParameters().put('pTaskA', 'Gestione Manuale post diffida');
            mia.TaskA = 'Gestione Manuale post diffida';            
            mia.Conferma();
            
            mia.Indietro();
            mia.UpdateTaskA();
            
			test.stopTest();            
	  	}
    }
}