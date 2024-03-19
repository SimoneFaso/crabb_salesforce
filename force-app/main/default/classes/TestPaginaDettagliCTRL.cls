/*
 * Created by: Endrit Sino  
 * Desc: Classe di test per il controller della pagina dettagli delle strategie.
 * date: 30/9/2014
 * Modified to fix English version - replace recordtype name line no 31, 34
 */
@isTest
public class TestPaginaDettagliCTRL {
    
    static testmethod void testOverallFunc(){
        test.startTest();
        // istanza
        // 1) id invalida
        Test.setCurrentPage(new pageReference('/apex/paginaDettagli'));
        ApexPages.currentPage().getParameters().put('myId', null);
        // 2) id valida
        Strategia__c str = TestClassFroDataGenAffidamenti.getStrategia('Testata');
        insert str;
        ApexPages.currentPage().getParameters().put('myId', str.Id);
        Strategia__c str0 = new Strategia__c();
        ApexPages.StandardController controller = new ApexPages.StandardController(str0);
        paginaDettagliCTRL istanza = new paginaDettagliCTRL(controller);
        
        // 3) crea step, salti ect.
        Strategia__c step = TestClassFroDataGenAffidamenti.getStrategia('Step');
        step.testata__C = str.Id;
        insert step;
        Strategia__c salto = TestClassFroDataGenAffidamenti.getStrategia('Salto');
        salto.Testata__c = str.id;
        insert salto;
        strategia__c cdi = TestClassFroDataGenAffidamenti.getStrategia('Condizioni_di_Ingresso');
        cdi.Testata__c = str.id;
        insert cdi;
        Strategia__c cdu = TestClassFroDataGenAffidamenti.getStrategia('Condizioni_di_Uscita');
        cdu.Testata__c = str.id;
        insert cdu;
        //Strategia__c str2 = new Strategia__c();
        //ApexPages.StandardController controller2 = new ApexPages.StandardController(str2);
        //istanza = new paginaDettagliCTRL(controller2);
        
        // 4) test retrieve testata
        istanza.retrieveTestata(str.Id);
        
        // 5) cambi stato
        istanza.myTestata = str;
        istanza.cambiStato();
        
        // 6) test remove
        istanza.SelectedId = step.id;
        istanza.remove();
        istanza.SelectedId = salto.id;
        istanza.remove();
        istanza.SelectedId = cdi.id;
        istanza.remove();
        istanza.SelectedId = cdu.id;
        istanza.remove();
        
        test.stopTest();
    }


}