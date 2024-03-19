/*
*    Created by: Endrit Sino
*    Date: 8/Agosto/2014
*    Description: Classe di test per il controller del gestione dei account su
*    su White List.
*/
@isTest
public class TestGestioneWhiteListCTRL{
    
    // Test a i metodi ausiliari
    public static testmethod void testGeneralMethods(){
        
        GestioneWhiteListCTRL wlInstance = new GestioneWhiteListCTRL();
        wlInstance.Indice = 1;
        wlInstance.LPrimoName = new List<String>{'First','Second'};
        
        // testBeginning
        wlInstance.QueryAccountPag = 'SELECT id, Name, Stato__c, Classe_di_Rischio__c, Contratto__r.id_Esterno__c, Comune_Contratto__c FROM Account';
        wlInstance.recXpage = 20;
        wlInstance.Continua();
        wlInstance.beginning();
        wlInstance.Next();
        wlInstance.Previous();
        wlInstance.initialTotal = 10;
        wlInstance.recXPage = 40;
        wlInstance.End();
        
        wlInstance.getIsBeginningVisibility();
        wlInstance.getIsEndVisibility();
        wlInstance.Indice = 0;
        //wlInstance.getDisablePrevious();
        wlInstance.pagesize = 1;
        wlInstance.RecXPage = 2;
        wlInstance.limitQuery = 10;
        wlInstance.isPutInWhiteList = true;
        // inserisci un account di test 
        Contratto__c cont = TestClassFroDataGenAffidamenti.getContratto();
        insert cont;
        Account a = TestClassFroDataGenAffidamenti.getAccount(cont.Id);
        a.Stato__c = 'Attivo0';
        //a.Comune_Contratto__c = 'com';
        //a.Classe_di_Rischio__c = 'A0';
        insert a;
        
        wlInstance.indietro();
        
        // test navigation meths
        wlInstance.GestioneWHLStepTipoOp();
        wlInstance.GestioneWHLStepFiltri();
        wlInstance.GestioneWHLStepSelAcct();
        wlInstance.gestioneWhiteListStep4();
        
        wlInstance.SaldoMovScadutoDa = '1';
        wlInstance.SaldoMovScadutoA = '3';
        wlInstance.SaldoTotaleDa = '3';
        wlInstance.SaldoTotaleA = '5';
        
        wlInstance.Filtra();

        System.assertNotEquals(0,wlInstance.recordsForPageValues.size());
        wlInstance.updateAccountList();
        wlInstance.aggiornaElemento();
        wlInstance.sizeTable();
        
    }
    
    // Test QueryAccount()
    public static testmethod void testQueryAccount(){
        GestioneWhiteListCTRL wlInstance = new GestioneWhiteListCTRL();
        
        // istanze neccessarie:
        // Scenerio 1: Valori corretti
        wlInstance.RecXPage = 20;
        wlInstance.SaldoMovScadutoDa = '5';
        wlInstance.SaldoMovScadutoA = '7';
        wlInstance.SaldoTotaleDa = '5';
        wlInstance.SaldoTotaleA = '7';
        
        wlInstance.rightvalues_idEsternoContratto.add('NomeContrTest');
        wlInstance.rightValues_Comuni.add('NomecoumneTest');
        wlInstance.rightValues_Stato.add('Attiva');
        wlInstance.rightValues_CdR.add('A1');
        
        // UN account test
        Contratto__c ct = new Contratto__c(Id_esterno__c = 'NomeContrTest', 
                                            Comune__c = 'NomecoumneTest',
                                            Data_inizio__c = System.Today(),
                                            Partita_IVA__c = 'ssss',
                                            Titolo__c = 'dddd');
        insert ct; 
        Account acc = new Account(Contratto__c = ct.id,
                                    Name = 'Test', 
                                    Stato__c = 'Attiva', 
                                    //Fruitore_Uscente__c = 10,
                                    Pratiche_In_Lavorazione__c = 1);
        insert acc; 
        
        // crea un Movimento, per impostare i campi SaldoTotale & SaldoMovScaduto
        Pratica__c pr = new Pratica__c(account__c = acc.id);
        insert pr; 
        Movimento__c mov = new Movimento__c(account__c = acc.id,
                                            pratica__c = pr.id, 
                                            Tipo_Scadenza__c = 'Scaduto', 
                                            Sollecitabile__c = true, 
                                            Data_Emissione__c = System.Today(),
                                            Data_Scadenza__c = System.Today(),
                                            Write_Off__c = false, 
                                            importo__c = 6, 
                                            Residuo__c = 6);
        insert mov;
        update acc;        
        
        wlInstance.leftselected_SelTipo='Assegna White List';
        wlInstance.RecXPage= 2;
        wlInstance.queryAccount();
        wlInstance.leftselected_SelTipo='Rimuovi White List';
        wlInstance.queryAccount();
        
        // Scenario 2: Valori scorretti nei filtri
        wlInstance.SaldoMovScadutoDa = '*';
        wlInstance.queryAccount();
        wlInstance.SaldoMovScadutoA = '*';
        wlInstance.queryAccount();
        wlInstance.SaldoTotaleDa = '*';
        wlInstance.queryAccount();
        wlInstance.SaldoTotaleA = '*';
        wlInstance.queryAccount();
        
        // Scenario 3: valori out of range
        wlInstance.SaldoMovScadutoDa = '7';
        wlInstance.SaldoMovScadutoA = '3';
        wlInstance.queryAccount();
        wlInstance.SaldoTotaleDa = '7';
        wlInstance.SaldoTotaleA = '3';
        wlInstance.queryAccount();
    }
    
    /*
    *    Metodi di test per Continua() & AggiornaelementoLista()
    */
    public static testmethod void testContAggio(){
        GestioneWhiteListCTRL wlInstance = new GestioneWhiteListCTRL();
        
        // 1. Test per Continua()
        wlInstance.leftselected_SelTipo = 'Assegna White List';
        wlInstance.continua();
        wlInstance.leftselected_SelTipo = '';
        wlInstance.continua();
        
        // 2. Test per Aggiornamentolista()
        //Crea un account
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        // aggiorna mapSeleziona
        wlInstance.MapSelezione.put(acc.Name, true);
        
        Test.setCurrentPageReference(new PageReference('Page.GestioneWhiteListPage'));
        System.currentPageReference().getParameters().put('isSel', 'true');
        System.currentPageReference().getParameters().put('Codice_Account', acc.Name);
        wlInstance.AggiornaelementoLista(); 
        
        System.currentPageReference().getParameters().put('isSel', 'false'); 
        wlInstance.MapSelezione.remove(acc.Name);    
        wlInstance.MapSelezione.put('kot', true);
        wlInstance.AggiornaelementoLista();   
    }
    
    // Metodo per testare UpdateListe
    public static testmethod void testUpdateListe(){
        GestioneWhiteListCTRL wlInstance = new GestioneWhiteListCTRL();
        
        // set page parameters        
        Test.setCurrentPageReference(new PageReference('Page.GestioneWhiteListPage'));
        
        // per filtro id Esterno:
        System.currentPageReference().getParameters().put('ValSelected', '9334');
        System.currentPageReference().getParameters().put('IndexSelected', '1');
        wlInstance.updateListe();
        
        // filtro commune
        System.currentPageReference().getParameters().put('ValSelected', 'Rho');
        System.currentPageReference().getParameters().put('IndexSelected', '2');
        wlInstance.updateListe();
        
        // filtro stato
        System.currentPageReference().getParameters().put('ValSelected', 'Attiva');
        System.currentPageReference().getParameters().put('IndexSelected', '4');
        wlInstance.updateListe();
        
        // filtro classe di rischio
        System.currentPageReference().getParameters().put('ValSelected', 'A0,D0');
        System.currentPageReference().getParameters().put('IndexSelected', '5');
        wlInstance.updateListe();
        
        // caso nullo
        System.currentPageReference().getParameters().put('ValSelected', null);
        System.currentPageReference().getParameters().put('IndexSelected', null);
        wlInstance.updateListe();
    }
    
    /*
    * Metodi test, per le metodi responsabile ad eseguire
    * il assegno/rimuovo delle account dal WhiteList.
    */
    public static testmethod void testMettiInWL(){
        GestioneWhiteListCTRL wlInstance = new GestioneWhiteListCTRL();
        
        // crea dei account processabili dal metodo
        Account acc1 = new Account(Name = 'Test1');
        Account acc2 = new Account(Name = 'Test2');
        insert acc1;
        insert acc2;
        wlInstance.accountDaElaborare = new List<Account>();
        wlInstance.accountDaElaborare.add(acc1);
        wlInstance.accountDaElaborare.add(acc2);
        wlInstance.myWhiteListLimit = System.Today();
         
        wlInstance.mettiInWhL();
    }
    
    public static testmethod void testMettiRimuoviWLFailure(){
        GestioneWhiteListCTRL wlInstance = new GestioneWhiteListCTRL();
        
        wlInstance.AccountDaelaborare = null;
        wlInstance.mettiInWhL();
        wlInstance.rimuoviDaWhL();
    }
    public static testmethod void testRimuovidaWL(){
        GestioneWhiteListCTRL wlInstance = new GestioneWhiteListCTRL();
        
        // crea dei account processabili dal metodo
        Account acc1 = new Account(Name = 'Test1');
        Account acc2 = new Account(Name = 'Test2');
        insert acc1;
        insert acc2;
        wlInstance.accountDaElaborare = new List<Account>();
        wlInstance.accountDaElaborare.add(acc1);
        wlInstance.accountDaElaborare.add(acc2);
        wlInstance.myWhiteListLimit = System.Today();
        
        wlInstance.rimuoviDaWhL();
    }
    
    // test per selectAll()& getListAccountSelectable()
    public static testmethod void testSelectAll(){
        GestioneWhiteListCTRL wlInstance = new GestioneWhiteListCTRL();
        
        //1. Primo caso: LPrimoName é vuoto
        wlInstance.LPrimoName = new List<String>();
        
        //2.Secondo caso: LPrimoName non é vuoto
        // Crea 2 account test:
        Account acc1 = new Account(Name = 'Test1');
        Account acc2 = new Account(Name = 'Test2');
        insert acc1;
        insert acc2;
        // popolato il map della selezione
        wlInstance.mapSelezione = new Map<String,Boolean>();
        wlInstance.mapSelezione.put(acc1.Name, true);
        wlInstance.mapSelezione.put(acc2.Name, true);
        
        // inizia LPrimoName
        wlInstance.LPrimoName = new List<String>{acc1.Name, acc2.Name};
        
        // inizia Indice
        wlInstance.Indice = 0;
        
        // inizia QueryAccountPag
        wlInstance.QueryAccountPag = 'SELECT id, Name, Stato__c, Classe_di_Rischio__c, Contratto__r.id_Esterno__c, Comune_Contratto__c FROM Account ';
        
        wlInstance.ListTabellaAccountSelectable();
        wlInstance.selectAll();
        
        wlInstance.BAllSel = false;
        wlInstance.SelectAll();
        //3. Listaccounttoview ha un account differente da quello nel mapSelezione
        wlInstance.mapSelezione.clear();
        wlInstance.mapSelezione.put('Test3', true);
               
    }
    
    // Test per confermaSelezione()
    public static testmethod void testConfermaSelezione(){
        GestioneWhiteListCTRL wlInstance = new GestioneWhiteListCTRL();
        
        // Crea 2 account test:
        Account acc1 = new Account(Name = 'Test1');
        Account acc2 = new Account(Name = 'Test2');
        insert acc1;
        insert acc2;
        
        wlInstance.mapSelezione = new Map<String,Boolean>();
        wlInstance.mapSelezione.put(acc1.Name, true);
        wlInstance.mapSelezione.put(acc2.Name, true);
        wlInstance.confermaSelezione();
        wlInstance.mapSelezione.clear();
        wlInstance.confermaSelezione();
    }
    
    /*
    *  4 metodi per testare la mancanza dei filtri
    */
    public static testmethod void missingFilter1(){
        GestioneWhiteListCTRL wlInstance = new GestioneWhiteListCTRL();
        wlInstance.SaldoMovScadutoDa = '7';
        wlInstance.SaldoMovScadutoA = '';
        wlInstance.SaldoTotaleDa = '';
        wlInstance.SaldoTotaleA = '';
        wlInstance.queryAccount();
    }
    public static testmethod void missingFilter2(){
        GestioneWhiteListCTRL wlInstance = new GestioneWhiteListCTRL();
        wlInstance.SaldoMovScadutoDa = '';
        wlInstance.SaldoMovScadutoA = '7';
        wlInstance.SaldoTotaleDa = '';
        wlInstance.SaldoTotaleA = '';
        wlInstance.queryAccount();
    }
    
    public static testmethod void missingFilter3(){
        GestioneWhiteListCTRL wlInstance = new GestioneWhiteListCTRL();
        wlInstance.SaldoMovScadutoDa = '';
        wlInstance.SaldoMovScadutoA = '';
        wlInstance.SaldoTotaleDa = '7';
        wlInstance.SaldoTotaleA = '';
        wlInstance.queryAccount();
    }
    
    public static testmethod void missingFilter4(){
        GestioneWhiteListCTRL wlInstance = new GestioneWhiteListCTRL();
        wlInstance.SaldoMovScadutoDa = '';
        wlInstance.SaldoMovScadutoA = '';
        wlInstance.SaldoTotaleDa = '';
        wlInstance.SaldoTotaleA = '7';
        wlInstance.queryAccount();
    }
    
    // Valore invalido per SaldoMovScadutoA
    public static testmethod void missingFilter5(){
        GestioneWhiteListCTRL wlInstance = new GestioneWhiteListCTRL();
        wlInstance.SaldoMovScadutoDa = '7';
        wlInstance.SaldoMovScadutoA = '{}{}{}';
        wlInstance.SaldoTotaleDa = '5';
        wlInstance.SaldoTotaleA = '6';
        wlInstance.queryAccount();
    }
    
    // valore invalido per SaldoTotaleA
    public static testmethod void missingFilter6(){
        GestioneWhiteListCTRL wlInstance = new GestioneWhiteListCTRL();
        wlInstance.SaldoMovScadutoDa = '3';
        wlInstance.SaldoMovScadutoA = '4';
        wlInstance.SaldoTotaleDa = '5';
        wlInstance.SaldoTotaleA = '{}{}{}{';
        wlInstance.queryAccount();
    }
    
    // metodo per i vari scenari di errore dei filtri
    public static testmethod void testScen2QueryAccount(){
        GestioneWhiteListCTRL wlInstance = new GestioneWhiteListCTRL();
        wlInstance.SaldoMovScadutoDa = '5';
        wlInstance.SaldoMovScadutoA = '7';
        wlInstance.SaldoTotaleDa = '7';
        wlInstance.SaldoTotaleA = '3';
        wlInstance.queryAccount();
    }
    
    // metodo per testare le propietá {get;set;}
    public static testmethod void testFilterProperties(){
        
        GestioneWhiteListCTRL wlInstance = new GestioneWhiteListCTRL();
        
        List<String> temp = new List<String>();
        temp = wlInstance.originalvalues_idEsternoContratto;
        temp = wlInstance.originalValues_CdR;
        temp = wlInstance.originalValues_Stato;
        temp = wlInstance.originalValues_Comuni;
    }
}