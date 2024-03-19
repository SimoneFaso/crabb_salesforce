/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestGestioneProroga.cls
Description:     Test class for code coverage of GestioneProrogaCTRL1

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
25-Sep-2014  0.1      E. Sino              First Version
28-Sep-2021  0.2      M. Pizzichini        Modified for code coverage
----------------------------------------------------------------------------------------------------------------------*/

@isTest
public class TestGestioneProroga {
    
    /****
     * Metodi di test
     * ***/
    // Test metodi ausiliari
    public static testmethod void testTinyMethods(){
        // istanza
        TestClassFroDataGenAffidamenti.CreateAffidGeneric();

        GestioneProrogaCTRL1 istanza = new GestioneProrogaCTRL1();
        
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
        istanza.GestioneProrogaStep3();
        istanza.confermaselezione();
        istanza.isApprova = true;
        System.currentPageReference().getParameters().put('{!tmpAff.Giorni_di_proroga__c}', '5');
        istanza.GestioneProrogaConfirmOperation();
        istanza.ConfermaApprProroga();
        istanza.GestioneProrogaStep4();
        istanza.GestioneProrogaIndietro_4_3();
        istanza.GestioneProrogaStep3();
        istanza.validnrGiorniProga=true;
        
        istanza.isApprova = true;
        istanza.GestioneProrogaConfirmOperation();
        istanza.ConfermaApprProroga();
        istanza.isApprova = false;
        istanza.GestioneProrogaConfirmOperation();
        istanza.ConfermaApprProroga();
        
        test.stopTest();
    }
    
    // test Reduce Filters & Indietro & GestioneProrogaStep1
    // - crea dei affidi test, per popolare i filtri
    // *Prima chiama anche il metodo GestioneProrogaStep1() => Indietro() => reduceFIlters()
    public static testmethod void testReduceFilters(){
        // istanza
        GestioneProrogaCTRL1 istanza = new GestioneProrogaCTRL1();
                
        test.StartTest();
        // crea dei affidi test
        TestClassFroDataGenAffidamenti.CreateAffidGeneric();
        istanza.GestioneProrogaStep1();
        test.StopTest();
    }
    
    // test queryAffidamenti & GestioneProrogaStep2()
    // *Prima chiama GestioneProrogaStep2()
    public static testmethod void testQueryAffidamenti(){
        // istanza
        GestioneProrogaCTRL1 istanza = new GestioneProrogaCTRL1();
        
        test.StartTest();
        //  - Imposta filtri e intervali per entrare nei if() del controllo
        // 1) Scenario Positivo(valori positivo)
        istanza.dataScadenzaLottoDa = Date.parse('11/9/2014');
        istanza.dataScadenzaLottoA = Date.parse('20/9/2014');
        istanza.dataScadenzaAffidamentoDa = date.parse('11/09/2014');
        istanza.dataScadenzaAffidamentoA = date.parse('20/09/2014');
        istanza.scadutoInizialeA = '5';
        istanza.scadutoInizialeDa = '1';
        istanza.rightValues_Lotto = new List<String>{'Lotto_1', 'Lotto_2'};
        istanza.rightValues_Collector = new List<String>{'Coll_1', 'Coll_2'};
        istanza.rightValues_TipoCollector = new List<String>{'Tipo_Coll_1', 'Tipo_Coll_2'};
        
        istanza.GestioneProrogaStep2();
        
        // 2) Scenario negativo: Intervali errati
        istanza.dataScadenzaLottoDa = Date.parse('26/9/2014');
        istanza.dataScadenzaLottoA = Date.parse('20/9/2014');
        istanza.scadutoInizialeA = '5';
        istanza.scadutoInizialeDa = '14';
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
        istanza.scadutoInizialeA = null;
        istanza.scadutoInizialeDa = null;
        istanza.rightValues_Lotto = new List<String>();
        istanza.rightValues_Collector = new List<String>();
        istanza.rightValues_TipoCollector = new List<String>();
        istanza.GestioneProrogaStep2();
        test.StopTest();
    }
    
    // testmethod per i vari collections che appartengono a i filtri
    public static testmethod void testGetVariousCollections(){
        // istanza
        GestioneProrogaCTRL1 istanza = new GestioneProrogaCTRL1();
        
        test.StartTest();        
        istanza.getoriginalValues_CollectorSize();
        istanza.getoriginalValues_LottoSize();
        istanza.getoriginalValues_TipoCollectorSize();
        istanza.getoriginalValues_ServizioSize();
        istanza.getrightValues_CollectorSize();
        istanza.getrightValues_LottoSize();
        istanza.getrightValues_TipoCollectorSize();
        istanza.getrightValues_ServizioSize();
        
        // leggi i contenieri dei filtri
        List<String> temp = new List<String>();
        istanza.originalValues_TipoCollector = null;
        istanza.originalValues_Lotto = null;
        istanza.originalValues_Collector = null;
        istanza.originalValues_Servizio = null;
        temp = istanza.originalValues_TipoCollector;
        temp = istanza.originalValues_Lotto;
        temp = istanza.originalValues_Collector;
        temp = istanza.originalValues_Servizio;
        test.StopTest();
    }
    
    
    // testmetod per UpdateListe(filtri dei collector, tipo col e lotto)
    public static testmethod void testUpdateListe(){
        // istanza
        GestioneProrogaCTRL1 istanza = new GestioneProrogaCTRL1();
        
        test.StartTest();        
        // set page parameters        
        Test.setCurrentPageReference(new PageReference('Page.GestioneRevoca'));
        
        // per filtro Lotto:
        System.currentPageReference().getParameters().put('ValSelected', 'LOT-0000001');
        System.currentPageReference().getParameters().put('IndexSelected', '1');
        istanza.UpdateListe();
        
        // per filtro Collector:
        System.currentPageReference().getParameters().put('ValSelected', 'COLL-0000003');
        System.currentPageReference().getParameters().put('IndexSelected', '2');
        istanza.UpdateListe();
        
        // per filtro TipoCollector:
        System.currentPageReference().getParameters().put('ValSelected', 'ADR');
        System.currentPageReference().getParameters().put('IndexSelected', '3');
        istanza.UpdateListe();
        
        // per filtro Servizio:
        System.currentPageReference().getParameters().put('ValSelected', 'PREREF');
        System.currentPageReference().getParameters().put('IndexSelected', '4');
        istanza.UpdateListe();
        
        // caso nullo
        System.currentPageReference().getParameters().put('ValSelected', null);
        System.currentPageReference().getParameters().put('IndexSelected', null);
        istanza.UpdateListe();
                
        test.stopTest();
    }
    
    // test metodi di selectAll()
    public static testmethod void testSelectAll(){
        // istanza
        GestioneProrogaCTRL1 istanza = new GestioneProrogaCTRL1();
        
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
    
}