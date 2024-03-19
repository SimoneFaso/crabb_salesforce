/*
 * Created by: Endrit Sino, 04/02/2015
 * Desc: Test di cambio Puntuale di attivita. 
 */
@isTest
public class TestCambioAttivitaPuntualeCTRL {
    
    /* Scenario: 
     * 1- Una strategia con dei step
     * 2- Una pratica con (dei)task associati aperti, UI.
     * 3- Crea la pagina, con l'id della prat, come param
     * 4- Scelta da qualche step 
     * 5- Cambio task... 
     */
    Static testmethod void unitTest(){
        //1-
        //Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByName().get('Step').getRecordTypeId();
        //Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByName().get('Testata').getRecordTypeId();
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
        Strategia__c Strat1 = new Strategia__c();
            Strat1.RecordTypeId=rtStrat_Step;
            Strat1.Tipologia__c = 'UI';
            Strat1.Testata__c = testata.Id;
            Strat1.Nome__c = 'Doppio invio completato';
        insert strat1;
        
        //2-        
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
        t1.status = 'Rimandata';
        ActivityExtended__c ae = new ActivityExtended__c();
        ae.id_attivita__c = strat.id;
        t1.whatId = p.id;
        ae.RecordTypeId = Schema.SObjectType.ActivityExtended__c.getRecordTypeInfosByName().get('UI').getRecordTypeId();  
        insert ae;
        t1.ActivityExtended__c = ae.Id;
        insert t1;
        
        //4-
                
        
        test.startTest();
        Test.setCurrentPage(new pageReference('/apex/CambioAttivitaPuntuale'));
        ApexPages.currentPage().getParameters().put('id', p.id);
        System.debug('\n TEst, Pratica: ' + p);
        CambioattivitaPuntualeCTRL cap = new CambioattivitaPuntualeCTRL();
        
        testata.Nome__c = 'STRATEGIA APPALTI';
        update testata;
        cap = new CambioattivitaPuntualeCTRL();
        
        testata.Nome__c = 'STRATEGIA CONCESSIONE COMUNE DI RHO';
        update testata;
        cap = new CambioattivitaPuntualeCTRL();
        
        testata.Nome__c = 'STRATEGIA AUTOMATICA MENSILE';
        update testata;
        cap = new CambioattivitaPuntualeCTRL();
        
        cap.TaskA = 'Doppio invio completato';
        cap.TaskDa = 'Gestione Manuale post diffida'; 
        
        cap.Conferma();
        
        // Insert another task
        Task t2 = new Task();
        t2.subject = 'Gestione Manuale post diffida 1';
        t2.status = 'Rimandata';
        ActivityExtended__c ab = new ActivityExtended__c();
        ab.id_attivita__c = strat.id;
        t2.whatId = p.id;
        ab.RecordTypeId = Schema.SObjectType.ActivityExtended__c.getRecordTypeInfosByName().get('UI').getRecordTypeId();  
        insert ab;
        t2.ActivityExtended__c = ab.Id;
        insert t2;
        
        cap = new CambioattivitaPuntualeCTRL();
        cap.TaskA = 'Doppio invio completato';
        cap.TaskDa = 'Gestione Manuale post diffida'; 
        cap.Conferma();
        
        pagereference pr = cap.UpdateTaskDa();
        pr = cap.UpdateTaska();
        test.stopTest();
    }
}