/*
 * Creata da: Endrit Sino
 * Desc: Classe di test il controller GestioneRevocaCTRL
 * Date: 22/9/2014
 */
@isTest
public class TestGestioneRevocaCTRL {
    
    // Test metodi ausiliari
    public static testmethod void testTinyMethods(){
        // istanza
        GestioneRevocaCTRL istanza = new GestioneRevocaCTRL();
        
        test.startTest();
        List<String> list1 = new List<String>{'opt1','opt2','opt3'};
            istanza.getunSelectedValues(list1);
        istanza.recordsSelected = new Set<String>{'value1', 'value2'};
            integer size = istanza.getNumberOfSelectedRecords();
        System.assertEquals(2, size);
        istanza.GestioneProrogaIndietro_3_2();
        
        // set var
        istanza.QueryAffidPag = 'Select id From Affidamento__c';
        istanza.RecXPage = 6;
        istanza.Indice = 5;        
        istanza.initialTotal = 21;
        
        istanza.Beginning();
        istanza.End();
        
        istanza.getIsBeginningVisibility();
        istanza.Previous();
        
        istanza.initialTotal = 24;
        istanza.End();
        istanza.getIsEndVisibility();
        
        istanza.Indice = 1;
        istanza.initialTotal = 24;
        istanza.RecXPage = 6;
        istanza.getIsEndVisibility();
        
        istanza.initialTotal = 10;
        istanza.RecXPage = 1;
        istanza.Indice = 2;
        istanza.Next();        
        
        istanza.sizeTable();
        
        List<SelectOption> selList = istanza.recordsForPageValues;
        
        test.stopTest();
    }
    
    // test Reduce Filters & Indietro & GestioneProrogaStep1
    // - crea dei affidi test, per popolare i filtri
    // *Prima chiama anche il metodo GestioneProrogaStep1() => Indietro() => reduceFIlters()
    public static testmethod void testReduceFilters(){
        // istanza
        GestioneRevocaCTRL istanza = new GestioneRevocaCTRL();
        
        test.StartTest();
        // crea dei affidi test
        TestClassFroDataGenAffidamenti.CreateAffidGeneric();
        istanza.GestioneProrogaStep1();
        test.StopTest();
    }
    
    // test queryAffidamenti & GestioneProrogaStep2()
    // *Prima chiama GestioneProrogaStep2()
    public static testmethod void testQueryAffidamenti(){
        
        test.StartTest();
        
        // istanza
        // prima di chiamare il costruttore 
        // strurtturare il metodo setTasksCandidatiAEssereProcesssati()
        // 
        
        
        GestioneRevocaCTRL istanza = new GestioneRevocaCTRL();
        
        //  - Imposta filtri e intervali per entrare nei if() del controllo
        // 1) Scenario Positivo(valori positivo)
        istanza.dataScadenzaLottoDa = Date.parse('11/9/2014');
        istanza.dataScadenzaLottoA = Date.parse('20/9/2014');
        istanza.dataScadenzaAffidamentoDa = date.parse('11/09/2014');
        istanza.dataScadenzaAffidamentoA = date.parse('20/09/2014');
        istanza.rightValues_Lotto = new List<String>{'Lotto_1', 'Lotto_2'};
        istanza.rightValues_Collector = new List<String>{'Coll_1', 'Coll_2'};
        istanza.rightValues_TipoCollector = new List<String>{'Tipo_Coll_1', 'Tipo_Coll_2'};
        
        istanza.GestioneProrogaStep2();
        
        // 2) Scenario negativo: Intervali errati
        istanza.dataScadenzaLottoDa = Date.parse('26/9/2014');
        istanza.dataScadenzaLottoA = Date.parse('20/9/2014');
        istanza.dataScadenzaAffidamentoDa = date.parse('5/09/2014');
        istanza.dataScadenzaAffidamentoA = date.parse('1/09/2014');
        
        istanza.GestioneProrogaStep2();
        
        // 3) Scenario 3: Crea dei affidi per avere qualcosa da prendere dal DB
        TestClassFroDataGenAffidamenti.CreateAffidGeneric();
        // sbianca filtri
        istanza.dataScadenzaLottoDa = null;
        istanza.dataScadenzaLottoA = null;
        istanza.dataScadenzaAffidamentoDa = null;
        istanza.dataScadenzaAffidamentoA = null;
        istanza.rightValues_Lotto = new List<String>();
        istanza.rightValues_Collector = new List<String>();
        istanza.rightValues_TipoCollector = new List<String>();
        istanza.GestioneProrogaStep2();
        test.StopTest();
    }
    
    // testmethod per i vari collections che appartengono a i filtri
    public static testmethod void testGetVariousCollections(){
        // istanza
        GestioneRevocaCTRL istanza = new GestioneRevocaCTRL();
        
        test.StartTest();        
        istanza.getoriginalValues_CollectorSize();
        istanza.getoriginalValues_LottoSize();
        istanza.getoriginalValues_TipoCollectorSize();
        istanza.getrightValues_CollectorSize();
        istanza.getrightValues_LottoSize();
        istanza.getrightValues_TipoCollectorSize();
        
        // leggi i contenieri dei filtri
        List<String> temp = new List<String>();
        istanza.originalValues_TipoCollector = null;
        istanza.originalValues_Lotto = null;
        istanza.originalValues_Collector = null;
        
        temp = istanza.originalValues_TipoCollector;
        temp = istanza.originalValues_Lotto;
        temp = istanza.originalValues_Collector;
        test.StopTest();
    }
    
    // testmetod per UpdateListe(filtri dei collector, tipo col e lotto)
    public static testmethod void testUpdateListe(){
        // istanza
        GestioneRevocaCTRL istanza = new GestioneRevocaCTRL();
        
        test.StartTest();        
        // set page parameters        
        Test.setCurrentPageReference(new PageReference('Page.GestioneRevoca'));
        
        // per filtro Lotto:
        System.currentPageReference().getParameters().put('ValSelected', 'LOT-0000009');
        System.currentPageReference().getParameters().put('IndexSelected', '1');
        istanza.UpdateListe();
        
        // per filtro Collector:
        System.currentPageReference().getParameters().put('ValSelected', 'COLL-0000000');
        System.currentPageReference().getParameters().put('IndexSelected', '2');
        istanza.UpdateListe();
        
        // per filtro Collector:
        System.currentPageReference().getParameters().put('ValSelected', 'ADR');
        System.currentPageReference().getParameters().put('IndexSelected', '3');
        istanza.UpdateListe();
        
        // caso nullo
        System.currentPageReference().getParameters().put('ValSelected', null);
        System.currentPageReference().getParameters().put('IndexSelected', null);
        istanza.UpdateListe();
                
        test.stopTest();
    }
        
    // test per aggiorna elemento lista
    public static testmethod void testAggiornaElemento(){
        // istanza
        GestioneRevocaCTRL istanza = new GestioneRevocaCTRL();
            
        test.StartTest();
        
        List<Affidamento__c> affidi = new List<Affidamento__c>();
        affidi = TestClassFroDataGenAffidamenti.CreateAffidGeneric();
        Test.setCurrentPageReference(new PageReference('Page.GestioneRevoca_1'));
        System.currentPageReference().getParameters().put('isSel', 'true');
        System.currentPageReference().getParameters().put('Codice_Affid', affidi[0].id);
        istanza.recordsSelected = new Set<String>{affidi[0].id};
        istanza.initialTotal = 2;
        istanza.AggiornaElementoLista();
        
        System.currentPageReference().getParameters().put('isSel', 'false');
        istanza.recordsSelected.clear();
        istanza.recordsSelected = new Set<String>{'kot'};
        istanza.AggiornaElementoLista();
        
        test.StopTest();
    
    }
    
    // test metodi di ConfermaSelezione & GestioneProrogaStep3()
    // *Prima chiama GestioneProrogaStep3()
    public static testmethod void testConfermaSelezione(){
        // istanza
        GestioneRevocaCTRL istanza = new GestioneRevocaCTRL();
        
        test.StartTest();
        istanza.GestioneProrogaStep3();
        test.StopTest();
    }
    
    // test metodi di selectAll()
    public static testmethod void testSelectAll(){
        // istanza
        GestioneRevocaCTRL istanza = new GestioneRevocaCTRL();
        
        test.StartTest();        
        
        // 1) scenario bSelAll = true
        // aggiungere dei affidi da selezionare
        istanza = TestClassFroDataGenAffidamenti.setEnviromentWithAffidi(istanza);
        istanza.SelectAll();
        
        // 2) scenario bSelAll = false
        istanza.bAllSel = false;
        istanza.ListTabellaAffidamentoSelectable();
        istanza.recordsUnSelected = new Set<String>();
        istanza.recordsSelected = new Set<String>{'Che figata', 'In che senso'};
        istanza.SelectAll();
        
        test.StopTest();
    }
    
    // test metodi di saveState() & GestioneProrogaStep3()
    // * Prima chiama GestioneProrogaStep3()
    public static testmethod void testSaveState(){
        // istanza
        GestioneRevocaCTRL istanza = new GestioneRevocaCTRL();
        
        test.StartTest();
        // 1) popola listAffidamentiSelectable con due affidi true & false
        // e inizia recordsSelected e recordsUnselected
        // 2)con due affidi true & false
        
        // 1-
        istanza = TestClassFroDataGenAffidamenti.setEnviromentWithAffidi(istanza);
        
        // 2-
        istanza.listAffidamentiSelectable[0].isSelected = false;
        istanza.listAffidamentiSelectable[1].isSelected = true;
                
        istanza.GestioneProrogaStep3();
        test.StopTest();
    }
    
    // test metodi di revocaAffidi()
    public static testmethod void testRevocaAffidi(){
        // istanza
        GestioneRevocaCTRL istanza = new GestioneRevocaCTRL();
        
        test.StartTest();
            istanza.AffidamentiDaElaborare = TestClassFroDataGenAffidamenti.CreateAffidGeneric();
            istanza.revocaAffidi();
        test.StopTest();
    }    
}