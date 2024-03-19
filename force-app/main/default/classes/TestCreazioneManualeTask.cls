/*
 * Created by: Endrit Sino, 10/02/2015
 * Desc: TestClass => CreazioneManualeTask. 
 */
@isTest
public class TestCreazioneManualeTask{
    
    static testmethod void UnitTest(){
        // Creazione STR
        Strategia__c Testata = TestClassFroDataGenAffidamenti.getStrategia('Testata');
            Testata.Tipo_Strategia__c = 'Manuale';
            Testata.Stato__c = 'Attiva';
            Testata.Nome__c = 'STRATEGIA MANUALE';
        insert testata;
        Strategia__c Strat = TestClassFroDataGenAffidamenti.getStrategia('Step');
            Strat.Tipologia__c = 'UI';
            Strat.Testata__c = testata.Id;
            Strat.Nome__c = 'Attesa verifica condizioni';
        insert strat;
        
        testata.Stato__c = 'Attiva';
        update testata;
        
        system.debug('\n Testata: ' + testata + '\n Step: ' + strat);
        /*Strategia__c s = [Select Nome__c From Strategia__c WHERE Stato__c = 'Attiva' And Tipo_Strategia__c = 'Manuale'];
        System.assertNotEquals(null, s);
        */
        // crea acc e contratto per pratica
        Contratto__c con = TestclassfrodataGenAffidamenti.getContratto();
        insert con;
        Account acc = TestclassfrodataGenAffidamenti.getAccount(con.Id);
        acc.Name = 'Endrit';
        insert acc;
        
        Pratica__c p = TestclassfrodataGenAffidamenti.getPratica(acc.Id);
        insert p;
        
        test.startTest();
            Test.setCurrentPage(new pageReference('/apex/CreazioneManualeTask'));
            ApexPages.currentPage().getParameters().put('id', p.id);
            
            CreazioneManualeTaskCTRL atm = new CreazioneManualeTaskCTRL();
            
            atm.TaskA = 'Attesa verifica condizioni';    
            atm.StrategieSelectable = 'STRATEGIA MANUALE';
            atm.RecuperaTask();        
            System.debug('\n idStrat: ' + atm.idStrat + '\n TaskA: ' + atm.TaskA);
        	atm.TaskA = 'Attesa verifica condizioni';    
        	atm.creaTaskManuale();
            atm.Indietro();
            atm.UpdateTaskA();         
            
        test.stopTest();            
    }
}