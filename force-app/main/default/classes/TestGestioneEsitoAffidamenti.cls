/*
 * Created by: Endrit Sino
 * Desc: Classe di test per il controller della pagina GestioneEsitoAffidamenti
 * data: 30/9/2014
 */
@isTest
public class TestGestioneEsitoAffidamenti {
    
    static testmethod void testController(){
        test.startTest();
        
        // 1) id non valido
        // istanza
        GestioneEsitoAffidamentiCTRL istanza = new GestioneEsitoAffidamentiCTRL();
        
        // 2) id valido(crea affidi tramite il metodo ausiliario createAffidiGenerici())
        List<Affidamento__c> lAff = TestClassFroDataGenAffidamenti.CreateAffidGeneric();
        // chiama pagina con id 18 caratteri
        test.setCurrentPage(new PageReference('/apex/GestioneEsitiAffidamenti'));
        System.currentPageReference().getParameters().put('id', lAff[0].id);
        istanza = new GestioneEsitoAffidamentiCTRL();
        // chiama pagina con id 15 caratteri
        String myId =lAff[0].id;
        myId = myId.substring(0, myId.length()-3);// guadagni un id di 15 caratteri
        System.currentPageReference().getParameters().put('id', myId);
        istanza = new GestioneEsitoAffidamentiCTRL();
        // test anche salva nel modo adatto
        istanza.salva();
        
        // entra catch
        delete lAff[0];
        System.currentPageReference().getParameters().put('id', myId);
        istanza = new GestioneEsitoAffidamentiCTRL();
        // test anche il catch del metodo salva()
        istanza.salva();
        
        // 3) test tiny method
        GestioneEsitoAffidamentiCTRL.getRecordTypeid('EsitiCollector');
        istanza.cancella();
        
        
        test.stopTest();
    }
}