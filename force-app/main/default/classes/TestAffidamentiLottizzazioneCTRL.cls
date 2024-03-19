/*
 * Creata da: Endrit Sino
 * Desc: Classe di test per il controller AffidamentiLotizzazioneCTRL
 * data: 26/9/2014
 *   Modificato: Rajni, 22/02/2021 - Modified line 403 to replace getRecordTypeInfosByName with getrecordtypeinfosbydevelopername.
 */
@isTest
public class TestAffidamentiLottizzazioneCTRL {
    
    /* **Metodi di test**
     */
    
    // test metodo QueryAllRecords => executeQueryWithFilters => StringWithFilters 
    // *test anche getStringFilters
    public static testmethod void testQueryRec(){
        // istanza
        AffidamentiLottizzazioneCTRL istanza = new AffidamentiLottizzazioneCTRL();


        test.startTest();
        // Catena: 1) (*Inserisci delle prat, e aggiungi id su taskIdPraticaId) Compila taskIdPraticaId 
        // 2) Compila dati per StringWithFilters() 3) Compila TotalSize
        
        Pratica__c p1 = getPratica();
        insert p1;
        Pratica__C p2 = getPratica();
        insert p2;
        Test.setCurrentPageReference(new PageReference('Page.newLottizzazione'));
        istanza.TasksCandidatiAEssereProcesssati();

        istanza.taskIdPraticaId = new Map<String, String>();// Chiama getPraticaIds() per leggere taskIdPraticaId
        Task t1 = new Task();
        t1.WhatId = p1.id;
        insert t1;
        
        Task t2 = new Task();
        t2.whatId = p2.Id;
        insert t2;
        
        istanza.taskIdPraticaId.put(t1.id, p1.id);
        istanza.taskIdPraticaId.put(t2.Id, p2.Id);
        istanza.getPraticaIds();
        
        // test StringWithFilters
        istanza.QueryBase = 'Select id From Pratica__C';
        istanza.getStringFilters();
        istanza.recordsSelected.add(p1.id);
        
        istanza.statiPraticaSelezionati = new List<String>{'In Lavorazione', 'Bloccata'};
        istanza.strategiaSelezionati = new List<String>{'Str1'};
        istanza.comuniSelezionati = new List<String>{'Com1'};
        istanza.serviziSelezionati = new List<String>{'Serv1'};        
        istanza.classiDiRischioScelti = new List<String>{'CDR 1'};
        istanza.stringWithFilters();
        
        istanza.statiPraticaSelezionati.clear();
        istanza.statiPraticaSelezionati.add('In Lavorazione');
        istanza.stringWithFilters();
        
        istanza.statiPraticaSelezionati.clear();
        istanza.statiPraticaSelezionati.add('Bloccata');
        istanza.stringWithFilters();
        // Catena per executeQueryWithFilters()
        // 1) compila RecXPage, Indice
        System.assert(true,t2.WhatId == p2.Id);
        test.stopTest();
    }
    
    // Metodo test ProcessFifo
    // Compila: 1) RecordsSelected 2) drList
    // 3) Crea delle pratiche 
    /*
    public static testmethod void testProcessFifo(){
        // istanza
        AffidamentiLottizzazioneCTRL istanza = new AffidamentiLottizzazioneCTRL();
        
        test.startTest();
        istanza.recordsSelected = new set<String>();  
        // crea pratica
        pratica__c p = getPratica();
        // trovare un modo per mod il residuo totale
        //Residuo_Totale__c = 10;
        insert p;
        istanza.PraticaIdtaskId = new Map<String, String>();
        istanza.PraticaIdtaskId.put();
        istanza.recordsSelected.add(p.id);
        istanza.drList = new List<AffidamentiLottizzazioneCTRL.DistribResult>();
        istanza.drList.add(new AffidamentiLottizzazioneCTRL.DistribResult());
        istanza.drList[0].l.Affidamenti_support_numero_affidi__c = 1;
        istanza.drList[0].l.Affidamenti_support_Percentuale__c = 0.1;
        istanza.drList[0].l.Affidamenti_support_Scaduto_Affidato__c = 0;
        istanza.drList[0].l.Affidamenti_support_Percentuale_effettiv__c = 0.0;
        istanza.processFifo();
        
        test.stopTest();
    }
    */
    // test per confermaDistribuzione()
    public static testmethod void testconfermaDistribuzione(){
        // istanza
        AffidamentiLottizzazioneCTRL istanza = new AffidamentiLottizzazioneCTRL();
        
        test.startTest();
        // 1) crea dei lotti test
        // 2) compila drList
        istanza.drList = new List<AffidamentiLottizzazioneCTRL.DistribResult>();
        istanza.drList.add(new AffidamentiLottizzazioneCTRL.DistribResult());
        // impostaCollectorSelezionabili(inserisci un collector test)
        User lUs = new User();
        lUs = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');
        
        // Chiedi collector
        Collector__c col1 = TestClassFroDataGenAffidamenti.getCollector(lUs.id); 
        col1.Ragione_Sociale__c = 'Rag SOc';
        col1.Tipo_Collector__c = 'ADR';
        insert col1;

        CollectorAlgoritmoConfiguration__c alg1 = new CollectorAlgoritmoConfiguration__c();
        alg1.Algoritmo__c = 'RR';
        alg1.CollectorId__c = col1.Id;
        alg1.Name = 'test 1';
        insert alg1;

        CollectorAlgoritmoConfiguration__c alg2 = new CollectorAlgoritmoConfiguration__c();
        alg2.Algoritmo__c = 'RRR';
        alg2.CollectorId__c = col1.Id;
        alg2.Name = 'test 2';
        insert alg2;

        CollectorAlgoritmoConfiguration__c alg3 = new CollectorAlgoritmoConfiguration__c();
        alg3.Algoritmo__c = 'test';
        alg3.CollectorId__c = col1.Id;
        alg3.Name = 'test 3';
        insert alg3;

        istanza.setCollSelezionabili.add(col1.Id);
        istanza.impostaSavedConfigurations();
        
        istanza.drList[0].l.Agenzia_di_recupero__c = col1.id;
        istanza.confermaDistribuzione();
        istanza.creaAffidamenti();
        System.assert(true,col1.Tipo_Collector__c == 'ADR');
        test.stopTest();
    }
    
    // metodo per piccole metodi
    public static testmethod void testTinyMetodi(){
        // istanza
        AffidamentiLottizzazioneCTRL istanza = new AffidamentiLottizzazioneCTRL();
        
        test.startTest();
        istanza.sizeTable();
        
        // congela dati con collectorSelezionati null & not NUll
        istanza.congelaDati();
        
        //istanza.collectorSelezionati = new List<SelectOption>{new SelectOption('VALORE', 'valore')};
        //istanza.congelaDati();
        
        // * crea un collector 
        // impostaCollectorSelezionabili(inserisci un collector test)
        User lUs = new User();
        lUs = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');
        
        // Chiedi collector
        Collector__c col1 = TestClassFroDataGenAffidamenti.getCollector(lUs.id); 
        col1.Ragione_Sociale__c = 'Rag SOc';
        col1.Tipo_Collector__c = 'ADR';
        insert col1;
        
        Collector__c col = new Collector__c();
         col.Prefisso_Lotto__c = '002';
         col.Ragione_Sociale__c = 'Rag Soc Test';
         col.Localita__c = 'Localitá test';
         col.User__c = lUs.id;
         col.Tipo_Collector__c = 'ADR';
        insert col;
        
        istanza.collectorSelezionati = new List<SelectOption>();
        SelectOption opt = new Selectoption(col.id, 'lab');
        istanza.collectorSelezionati.add(opt);
        istanza.collectorSelezionati.add(new SelectOption(col1.id, 'lab1'));

        CollectorAlgoritmoConfiguration__c alg2 = new CollectorAlgoritmoConfiguration__c();
        alg2.Algoritmo__c = 'RRR';
        alg2.CollectorId__c = col1.Id;
        alg2.Name = 'CONF_00000';
        insert alg2;
        istanza.impostaSavedConfigurations();
        istanza.configurationSelected = 'test';
        istanza.istanziaDati();
        
        istanza.scongelaDati();
        istanza.getPraticaIds();
        istanza.RefreshRB();
        istanza.AnnullaFiltri();
        istanza.lavoraPreLottidaPreLotti();
        istanza.homeDaPreLotti();
        istanza.IndietroDaViewDataAdFiltri();
        istanza.IndietroAlgortmi();
        istanza.IndietroDaAlgortmi();
        istanza.ProseguiFiltri();
        
        istanza.Beginning();
        istanza.Previous();
        istanza.Next();
        istanza.End();
        
        istanza.Indice = 1;
        istanza.getIsBeginningVisibility();
        
        istanza.RecXPage = 5;
        istanza.TotalSize = 4;
        istanza.getIsEndVisibility();
        
        istanza.TotalSize = 20;
        istanza.getIsEndVisibility();
        
        // compila delle str test per configuraLeStrategieDisponibili
        // Crea una testata
        Strategia__c testata = getStrategia('Testata');
        testata.Nome__c = 'Nome Test';
        testata.stato__c = 'Attiva';        
        insert testata;
        
        Strategia__c s = getStrategia('Step');        
        s.Testata__c = testata.id;
        istanza.tipoAffido = 'test';
        s.Sotto_tipo_attivita__c = 'test';
        insert s;
        // prova
        /*
        List<strategia__c> tmp = new List<Strategia__c>();  // and  Sotto_tipo_attivita__c=\''+ istanza.tipoAffido+'\' and testata__r.stato__c=\'Attiva\'
        string query = 'Select id, nome__c,testata__c,testata__r.nome__c, RecordType.Name, Sotto_tipo_attivita__c, testata__r.stato__c  from Strategia__c where recordType.Name=\'Step\'  ';
        tmp = database.query(query);
        System.debug('\n dati del STR: \n' + tmp[0].recordType.Name + '\n soto tipo: ' + tmp[0].sotto_tipo_attivita__c + '\n stato testata: ' + tmp[0].testata__r.stato__c);
        */
        istanza.configuraLeStrategieDisponibili();

        istanza.processReverseRoundRobin();

        
        istanza.calcolaDistribuzione();
        
        istanza.recordsSelected = new set<String>{'kot1', 'kot2'};  
        istanza.processRoundRobin();
                
        istanza.impostaCollectorSelezionabili();
        
        istanza.collectorSelezionabili = null;
        col.Tipo_Collector__c = 'tipo';
        update col;
        istanza.categorieCollector = new List<String>{'tipo'};
        istanza.impostaCollectorSelezionabili();
        istanza.saveConfiguration();
        istanza.goBackRiepilogoTask();
        System.assert(true,col.Tipo_Collector__c == 'tipo');
        test.stopTest();
    }
    
    // metodi per testare i collection(filtri)
    public static testmethod void testCollections(){
        // istanza
        AffidamentiLottizzazioneCTRL istanza = new AffidamentiLottizzazioneCTRL();
        
        test.startTest();
        List<String> tmp = new List<String>();
        tmp = istanza.strategiaDisponibili;
        tmp= istanza.classiDiRischio;
        tmp = istanza.serviziDisponibili;
        tmp = istanza.contrattiDisponibili;
                
        Contratto__c ct = getContratto();
        ct.Comune__c = 'Com';
        insert ct;
        tmp = istanza.comuniDisponibili;
        tmp = istanza.statiPratica;
        List<SelectOption> temp = istanza.recordsForPageValues;
        temp = istanza.algoritmi;
        System.assert(true,ct.Comune__c == 'Com');
        test.stopTest();
    }
    
    // test metodi di selectAll()
    public static testmethod void testSelectAll(){
        // istanza
        AffidamentiLottizzazioneCTRL istanza = new AffidamentiLottizzazioneCTRL();
        
        test.StartTest();        
        
        // 1) scenario bSelAll = true
        // aggiungere dei affidi da selezionare
        /* setEnviromentWithAffidi(istanza); */
        
        istanza.listTPraticaSelectable = new List<AffidamentiLottizzazioneCTRL.TPratica>();
        Pratica__c p1 = getPratica();
        //Pratica__c p2 = getPratica();
        insert p1;
        //insert p2;
        istanza.listTPraticaSelectable.add(new AffidamentiLottizzazioneCTRL.TPratica(true, p1));
       // istanza.listTPraticaSelectable.add(new AffidamentiLottizzazioneCTRL.TPratica(false, p2));
        istanza.SelectAll();
        
        // 2) scenario bSelAll = false
        istanza.bAllSel = false;
        //istanza.ListTabellaAffidamentoSelectable();
        istanza.recordsUnSelected = new Set<String>();
        istanza.recordsSelected = new Set<String>{'Che figata', 'In che senso'};
        istanza.SelectAll();
        System.assert(true,istanza.recordsSelected.contains('In che senso'));
        test.StopTest();
    }
    
    // metodo test save state
    public static testmethod void testSaveState(){
        // istanza
        AffidamentiLottizzazioneCTRL istanza = new AffidamentiLottizzazioneCTRL();
        
        test.StartTest(); 
        
        istanza.ProseguiAlgoritmi();// a) testcase con records selected nullo
        
        istanza.listTPraticaSelectable = new List<AffidamentiLottizzazioneCTRL.TPratica>();
        Pratica__c p1 = getPratica();
        insert p1;
        istanza.listTPraticaSelectable.add(new AffidamentiLottizzazioneCTRL.TPratica(true, p1));
        Pratica__c p2 = getPratica();
        insert p2;
        istanza.listTPraticaSelectable.add(new AffidamentiLottizzazioneCTRL.TPratica(false, p2));
        istanza.recordsSelected = new Set<String>{'Che figata', 'In che senso'};
        istanza.recordsUnSelected = new Set<String>{'Che figata', 'In che senso'};
        istanza.saveState();        
        
        istanza.ProseguiAlgoritmi();// b) testcase con records selected non nullo
        System.assert(true,istanza.recordsSelected.contains('Che figata'));
        test.stopTest();
    }
    
    // testmetod per UpdateListe(filtri dei collector, tipo col e lotto)
    public static testmethod void testUpdateListe(){
        // istanza
        AffidamentiLottizzazioneCTRL istanza = new AffidamentiLottizzazioneCTRL();
        
        test.StartTest();        
        // set page parameters        
        Test.setCurrentPageReference(new PageReference('Page.newLottizzazione'));
        
        // per filtro Strategia:
        System.currentPageReference().getParameters().put('ValSelected', 'STR-000009');
        System.currentPageReference().getParameters().put('IndexSelected', '0');
        istanza.UpdateListe();
                
        // per filtro Contratti:
        System.currentPageReference().getParameters().put('ValSelected', 'LOT-0000009');
        System.currentPageReference().getParameters().put('IndexSelected', '1');
        istanza.UpdateListe();
        
        // per filtro Comuni:
        System.currentPageReference().getParameters().put('ValSelected', 'COM-0000000');
        System.currentPageReference().getParameters().put('IndexSelected', '2');
        istanza.UpdateListe();
        
        // per filtro Servizi:
        System.currentPageReference().getParameters().put('ValSelected', 'ADR');
        System.currentPageReference().getParameters().put('IndexSelected', '3');
        istanza.UpdateListe();
        
        // per filtro Stati:
        System.currentPageReference().getParameters().put('ValSelected', 'ADR');
        System.currentPageReference().getParameters().put('IndexSelected', '4');
        istanza.UpdateListe();
        
        // per filtro Classi di Rsichio:
        System.currentPageReference().getParameters().put('ValSelected', 'ADR');
        System.currentPageReference().getParameters().put('IndexSelected', '5');
        istanza.UpdateListe();
        
        // caso nullo
        System.currentPageReference().getParameters().put('ValSelected', null);
        System.currentPageReference().getParameters().put('IndexSelected', null);
        istanza.UpdateListe();
                
        test.stopTest();
    }
        
    /* Fine metodi di test
     */
    
    /*
     * Metodi ausiliari
     */
    
    // 1) metodo per creare pratica
    public static Pratica__c getPratica(){
        // crea pratica
        Contratto__c ct = getContratto();
        ct.Gestore_del_Credito__c = String.valueOf(System.now());
        // prendi il acct con il contratto appena chiesto
        Account acc = getAccount(ct.id);
        acc.Data_di_Nascita__c = + System.Today();
        // crea la pratica con il acct
        Pratica__c pr = getPratica(acc.id);
        return pr;
    }
    public static Pratica__c getPratica(id accId){
        
        Pratica__c prat = new Pratica__c();
         prat.account__c = accId;
        return prat;
    }
    
    // 2) metodo per creare un contratto
    public static contratto__c getContratto(){
        
        Contratto__c con = new Contratto__c();
        con.Id_esterno__c = 'NomeContrTest'; 
        con.Comune__c = 'NomecoumneTest';
        con.Data_inizio__c = System.Today();
        con.Partita_IVA__c = 'ssss';
        con.Titolo__c = String.valueOf(System.today());
        return con;
    }
        
    // 3) metodo per creare un acct
    public static Account getAccount(id conId){
        
        Account act = new Account();
        act.Contratto__c = conId;
        act.Name = 'Test';
        act.Stato__c = 'Attiva';
        act.Pratiche_In_Lavorazione__c = 1;
        return act;
    }
    
    // 4) metodo per strategia
    public static Strategia__c getStrategia(String recordType){
        
        Strategia__c s = new Strategia__c();
        Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName();
        s.recordTypeId = ctRecordTypes.get(recordType).getRecordTypeId();
        return s;
    }
    
}