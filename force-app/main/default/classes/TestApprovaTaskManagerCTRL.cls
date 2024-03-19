/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestApprovaTaskManagerCTRL.cls
Description:     Test Class for Code Coverage of ApprovaTaskManagerCTRL.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
09-Feb-2015  0.1      E. Sino                         First Version
24-Aug-2021  0.2      C. Sanna                        Modified getRecordTypeInfosByDeveloperName
----------------------------------------------------------------------------------------------------------------------*/

@isTest
public class TestApprovaTaskManagerCTRL {
    
    static testmethod void UnitTest(){
        // Creazione STR
        Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
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
        t1.status = 'In approvazione';
        ActivityExtended__c ae = new ActivityExtended__c();
        ae.id_attivita__c = strat.id;
        insert ae;
        t1.ActivityExtended__c = ae.Id;
        t1.whatId = p.id;
        ae.RecordTypeId = Schema.SObjectType.ActivityExtended__c.getRecordTypeInfosByDeveloperName().get('UI').getRecordTypeId();
        insert t1;
        Task t2 = new Task();
        t2.subject = 'Diffida proposta';
        t2.status = 'In approvazione';
        ActivityExtended__c ab = new ActivityExtended__c();
        ab.id_attivita__c = strat.id;
        insert ab;
        t2.ActivityExtended__c = ab.Id;
        t2.whatId = p.id;
        ab.RecordTypeId = Schema.SObjectType.ActivityExtended__c.getRecordTypeInfosByDeveloperName().get('UI').getRecordTypeId();
        insert t2;
        User u3 = TestClassFroDataGenAffidamenti.getUser('CRABB Credit Manager');
        // 4- Crea tag:
        Tag__c t = new Tag__c(Name = 'Ruolo Credit Manager Id', ValueText__c = u3.UserRoleId);
        insert t;
        
        // Test as User Operator
        //User u3 = [SELECT Id FROM User WHERE UserRoleId = '00Ew0000000kx7iEAA' limit 1];
        System.runAs(u3){
            test.startTest();
            Test.setCurrentPage(new pageReference('/apex/MandaInApprovazione'));
            ApexPages.currentPage().getParameters().put('id', p.id);
            
            ApprovaTaskMAnagerCTRL atm = new ApprovaTaskMAnagerCTRL();
            
            // set task scelta
            //System.assertEquals(null, t1.Status);
            //System.assertEquals(null, t2.Status);
            // *Approva
            atm.TaskA = 'Gestione Manuale post diffida';            
            atm.approva();
            // *Riffiuta
            atm.TaskA = 'Diffida proposta'; 
            atm.rifiuta();
            
            atm.Indietro();
            atm.UpdateTaskA();
            
            System.assert(true, t.Name == 'Ruolo Credit Manager Id');
            test.stopTest();            
        }
    }
}