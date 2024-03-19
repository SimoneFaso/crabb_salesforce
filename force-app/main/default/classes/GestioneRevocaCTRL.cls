/* ---------------------------------------------------------------------------------------------------------------------
Name:            GestioneRevocaCTRL.cls
Description:     Controller del gestione della revoca dei affidamenti.
Test class:      TestGestioneRevoceCTRL.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
18-Sep-2014  0.1      K.Meta               First Version

16-Sep-2022  0.2      R.Kurti & C.Sanna     Added cebCheckObjPermissions and WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class GestioneRevocaCTRL {
    public class GestioneProrogaCTRL1Exception extends Exception {
    }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    public lotto__c lforFiltro { get; set; }//Oggetto utilizzato per addattare i campi dei filtri
    public boolean ciSonoAffidamentiDaLavorare { get; set; }
    public integer hawmanyaffidamentiarePresent { get; set; }
    public boolean thereAreLessThanLimit { get; set; }
    // properties
    public boolean confirmationOP { get; set; }
    // oggetto temp per gestione del proroga
    public Affidamento__c tmpAff { get; set; }
    public set<id> idAff { get; set; }

    public GestioneRevocaCTRL() {
        lforFiltro = new lotto__C();
        tmpAff = new Affidamento__C();
        totalSize = 0;
        bAllSel = true;

        conditionPraticaBloccoManuale = TagHelper.getValueText('StatoPraticaBloccoManuale');
        LimitQuery = TagHelper.getValueInteger('MaxProrogaSizeList');
        QueryAffid = null;
        Indice = 0;
        errorCode = 0;

        MapSelezione = new Map<String, Boolean>();
        recordsSelected = new set<string>();
        recordsUnSelected = new set<string>();

        confirmationOP = false;
        ErrorValidateDecimal = false;
        errorValidateNrProroga = false;
        nrGiorniProrogaVuoto = false;
        calledFromSizeTable = false;

        rightValues_Lotto = new list<String>();
        rightValues_Collector = new list<String>();
        rightValues_TipoCollector = new list<String>();

        // E.S.
        originalValues_SelTipo.add('Approva Proroga');
        originalValues_SelTipo.add('Rifiuta Proroga');
        leftselected_SelTipo = 'Approva Proroga';
        unSelectedValues_SelTipo = getunSelectedValues(originalValues_SelTipo);

        //Make a Filter on filters if possible
        reducefilters();
    }

    // Fornisci i filtri con valori selezionabili
    // -Controllo quanto affidi sono revocabili
    // - Secondo le casistiche fornire al utente dei info
    public void reduceFilters() {
        if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Tipo_servizio__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Tipo_collector__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Nome_Collector__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'codice_lotto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('ACCESS')) {
            List<Affidamento__c> affList = [
                    Select id, Data_fine_affidamento_prevista__c, Tipo_servizio__c, Tipo_collector__c,
                            Nome_Collector__c, codice_lotto__c
                    from Affidamento__C
                    Where Stato__c = 'In Corso'
                    and Pratica__r.stato__c != :conditionPraticaBloccoManuale
                    //WITH  SECURITY_ENFORCED
                    limit :LimitQuery
            ];
            idAff = new set<id>();
            hawmanyaffidamentiarePresent = affList.size();
            if (hawmanyaffidamentiarePresent > 0) ciSonoAffidamentiDaLavorare = true;
            else ciSonoAffidamentiDaLavorare = false;

            thereAreLessThanLimit = (hawmanyaffidamentiarePresent < LimitQuery);
            if (thereAreLessThanLimit) {
                set<String> setLotti = new set<String>();
                set<String> setCollector = new set<String>();
                set<String> setTipoCollector = new set<String>();
                for (affidamento__C a : affList) {
                    setLotti.add(a.codice_lotto__c);
                    setCollector.add(a.Nome_Collector__c);
                    setTipoCollector.add(a.Tipo_collector__c);
                    idAff.add(a.id);
                }
                originalValues_Lotto = new List<String>();
                originalValues_Lotto.addAll(setLotti);

                originalValues_Collector = new List<String>();
                originalValues_Collector.addAll(setCollector);

                originalValues_TipoCollector = new List<String>();
                originalValues_TipoCollector.addAll(setTipoCollector);
            }
        }
    }


    public string recordsForPage { get {if (recordsForPage == null) return '25'; return recordsForPage;} set; }
    public integer RecXPage {
        get {
            if (recordsForPage == null) RecXPage = 0;
            else RecXPage = integer.valueOf(recordsForPage);
            return RecXPage;
        }
        set;
    }
    public void sizeTable() {
        System.debug('\n >SizeTable() \n');
        //saveState();
        indice = 0;
        RecXPage = integer.valueOf(recordsForPage);
        ListTabellaAffidamentoSelectable();
    }
    public List<SelectOption> recordsForPageValues {
        get {
            List<SelectOption> records = new list<SelectOption>();
            records.add(new SelectOption('25', '25'));
            records.add(new SelectOption('50', '50'));
            records.add(new SelectOption('100', '100'));
            records.add(new SelectOption('200', '200'));
            return records;
        }
        set;
    }
    //Gestione Filtri da a 
    public date dataScadenzaLottoDa { get; set; }
    public date dataScadenzaLottoA { get; set; }
    public date dataScadenzaAffidamentoDa { get; set; }
    public date dataScadenzaAffidamentoA { get; set; }
    public boolean errorValidateNrProroga { get; set; }
    public boolean nrGiorniProrogaVuoto { get; set; }
    public boolean nrGiorProOutOfRange { get; set; }


    public boolean affidEsiste { get; set; }
    public boolean AffidamentoSelEsisti { get; set; }

    // ricorda se save state é chiamato da sizeTable()
    public static boolean calledFromSizeTable;

    // ricorda il nr totale iniziale
    public integer initialTotal { get; set; }

    // codice e messagio di errore, dalla lavorazione dei affidi
    public integer errorCode { get; set; }
    public string errorMessage { get; set; }

    /*  ***Non deve essere usata per Revoca dei Affidamenti*** */
    // selezione del tipo d'operazione: Approva/Rifiuta
    Public String leftselected_SelTipo { get; set; }
    Public List<SelectOption> unSelectedValues_SelTipo { get; set; }
    List<String> originalValues_SelTipo = new List<String>();

    // Lista dei affidamenti da visualizzare
    public list<TAffidamento> listAffidamentiSelectable { get; set; }
    public transient list<Affidamento__c> listAffidamentiToView { get; set; }
    public List<Affidamento__c> AffidamentiDaElaborare { get; set; }

    public boolean ErrorValidateDecimal { get; set; }
    public boolean BAllSel { get; set; }

    public Map<String, Boolean> MapSelezione;
    public set<string> recordsSelected;
    public set<string> recordsUnSelected;

    //variabili per gestione paginazione
    public Integer Indice { get; set; }
    public Integer TotalSize { get; set; }
    // query diretta & query del paginazione
    public String QueryAffid { get; set; }
    public String QueryAffidPag { get; set; }

    // condizione per i affidi delle pratiche bloccate manualmente
    // limite del query
    public string conditionPraticaBloccoManuale;
    public integer LimitQuery;

    // Nome Lotto
    Public List<String> rightValues_Lotto { get; set; }
    public integer getrightValues_LottoSize() {
        if (rightValues_Lotto == null) return 0;
        return rightValues_Lotto.size();
    }
    public integer getoriginalValues_LottoSize() {
        if (originalValues_Lotto == null) return 0;
        return originalValues_Lotto.size();
    }
    public List<String> originalValues_Lotto {
        get {
            //if(originalValues_Lotto == null){
            if (originalValues_Lotto == null
                    && Utils.cebCheckObjPermission('Lotto__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'Name', gd).get('ACCESS')) {
                set<String> myValues = new Set<String>();
                originalValues_Lotto = new List<String>();

                List<Lotto__c> lottoList = new List<Lotto__C>();
                //lottoList = [Select name from Lotto__c WITH SECURITY_ENFORCED LIMIT 50000];
                lottoList = [Select name from Lotto__c LIMIT 50000];
                for (lotto__c l : lottoList)
                    myValues.add(l.Name);
                originalValues_Lotto.addAll(myValues);
                return originalValues_Lotto;
            } else
                    return originalValues_Lotto;
        }
        set;
    }

    // Collector
    Public List<String> rightValues_Collector { get; set; }
    public integer getrightValues_CollectorSize() {
        if (rightValues_Collector == null) return 0;
        return rightValues_Collector.size();
    }
    public integer getoriginalValues_CollectorSize() {
        if (originalValues_Collector == null) return 0;
        return originalValues_Collector.size();
    }
    public List<String> originalValues_Collector {
        get {
            //if(originalValues_Collector== null) {
            if (originalValues_Collector == null
                    && Utils.cebCheckObjPermission('Collector__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Collector__c', 'Name', gd).get('ACCESS')) {
                set<String> myValues = new Set<String>();
                originalValues_Collector = new List<String>();

                List<Collector__c> collectList = new List<Collector__C>();
                //collectList = [Select name from Collector__c WITH SECURITY_ENFORCED LIMIT 50000];
                collectList = [Select name from Collector__c LIMIT 50000];
                for (Collector__c c : collectList)
                    myValues.add(c.Name);
                originalValues_Collector.addAll(myValues);
                return originalValues_Collector;
            } else
                    return originalValues_Collector;
        }
        set;
    }

    // Tipologia Collector
    Public List<String> rightValues_TipoCollector { get; set; }
    public integer getrightValues_TipoCollectorSize() {
        if (rightValues_TipoCollector == null) return 0;
        return rightValues_TipoCollector.size();
    }
    public integer getoriginalValues_TipoCollectorSize() {
        if (originalValues_TipoCollector == null) return 0;
        return originalValues_TipoCollector.size();
    }
    public List<String> originalValues_TipoCollector {
        get {
            if (originalValues_TipoCollector == null) {
                set<String> myValues = new Set<String>();
                originalValues_TipoCollector = new List<String>();

                List<collector__C> collectList = new List<collector__C>();
                //if(Utils.checkFLSPermission('collector__c', 'tipo_collector__c').get('ACCESS'))
                if (Utils.cebCheckObjPermission('Collector__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Collector__c', 'tipo_collector__c', gd).get('ACCESS')) {
                    collectList = [Select tipo_collector__c from collector__c LIMIT 50000];
                    //collectList = [Select tipo_collector__c from collector__c WITH SECURITY_ENFORCED LIMIT 50000];
                    for (Collector__c l : collectList)
                        myValues.add(l.tipo_collector__c);
                    originalValues_TipoCollector.addAll(myValues);
                }
                return originalValues_TipoCollector;
            } else
                    return originalValues_TipoCollector;
        }
        set;
    }

    // Fine: Filtri Affidamenti

    public integer getNumberOfSelectedRecords() {
        return recordsSelected.size();
    }


    // Metodo per confermare le liste scelte del utente nei filtri rispettivi
    public void UpdateListe() {
        try {

            String sElenco = Apexpages.currentPage().getParameters().get('ValSelected');

            Integer iIndex = Integer.valueOf(Apexpages.currentPage().getParameters().get('IndexSelected'));
            List<String> elenco = sElenco.split(',');

            if (iIndex == 1) {
                //Id Lotto
                rightvalues_Lotto.clear();
                if (sElenco != '') {
                    for (string s : elenco)
                        rightvalues_Lotto.add(s);
                    System.debug('*DOPO LA UPDATE DELLE LISTE(Lotto):' + rightvalues_Lotto);
                }
            } else if (iIndex == 2) {
                // NomeCollector
                rightValues_Collector.clear();
                if (sElenco != '') {
                    for (string s : elenco)
                        rightValues_Collector.add(s);
                }
            } else if (iIndex == 3) {
                // Tipologia Collector
                rightValues_TipoCollector.clear();
                if (sElenco != '') {
                    for (string s : elenco)
                        rightValues_TipoCollector.add(s);
                }
            }
        } catch (Exception e) {
            System.Debug('Eccezione nel metodo UpdateListe: ' + e.getMessage());
        }
    }

    // Il funzione per prendere dal DB le Account desiderati
    public void QueryAffidamenti() {
        String patDecimal = '(^(\\+|\\-)(0|([1-9][0-9]*))(\\.[0-9]{1,2})?$)|(^(0{0,1}|([1-9][0-9]*))(\\.[0-9]{1,2})?$)';

        // ****Revoca
        /*if(Utils.checkFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Pratica__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Lotto__c').get('ACCESS')
            && Utils.checkFLSPermission('Pratica__c', 'Residuo_Totale__c').get('ACCESS')
            && Utils.checkFLSPermission('Pratica__c', 'Data_Apertura__c').get('ACCESS')
            && Utils.checkFLSPermission('Lotto__c', 'Data_Scadenza__c').get('ACCESS'))*/
        if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckObjPermission('Lotto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Lotto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Residuo_Totale__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Apertura__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Data_Scadenza__c', gd).get('ACCESS')) {
            QueryAffid = 'Select id,Giorni_di_proroga_richiesti_da_Collector__c, Name, Pratica__r.Name,Lotto__r.Agenzia_di_Recupero__r.Name, Data_fine_affidamento_prevista__c , Pratica__r.Account__r.Name, Pratica__r.Residuo_Totale__c, Pratica__r.Data_Apertura__c,pratica__r.Servizio_Fornitura__r.RecordType.Name, Lotto__r.Data_Scadenza__c, Lotto__r.Agenzia_di_Recupero__r.Tipo_Collector__c, Lotto__r.id, pratica__r.Servizio_Fornitura__r.LookupContratto__r.Comune__c, Data_Fine_Affidamento__c ';
            QueryAffid += ' From Affidamento__c Where id in:idAff and stato__c = \'In Corso\' and Pratica__r.stato__c !=: conditionPraticaBloccoManuale';

            // ***Revoca        
            // secondo i filtri compilati, modifica anche il query
            if (rightValues_Lotto.size() > 0) {
                QueryAffid += ' And Lotto__r.Name in ' + Utils.inStrings(rightValues_Lotto);
            }
            if (rightValues_Collector.size() > 0) {
                QueryAffid += ' And Lotto__r.Agenzia_di_Recupero__r.Name in ' + Utils.inStrings(rightValues_Collector);
            }
            if (rightValues_TipoCollector.size() > 0) {
                QueryAffid += ' And Lotto__r.Agenzia_di_Recupero__r.Tipo_collector__c in:rightValues_TipoCollector ';
            }

            // considerare i altri intervali
            if (lforFiltro.FF_Data_scadenza_lotto_da__c != null) {
                date md = lforFiltro.FF_Data_scadenza_lotto_da__c;
                string df = md.year() + '-';
                if (md.month() < 10)
                    df += '0' + md.month() + '-';
                else
                        df += md.month() + '-';
                if (md.day() < 10)
                    df += '0' + md.day();
                else
                        df += md.day();

                QueryAffid += ' And Lotto__r.Data_Scadenza__c >=' + String.escapeSingleQuotes(df);
            }
            if (lforFiltro.FF_Data_scadenza_lotto_a__c != null) {
                date md = lforFiltro.FF_Data_scadenza_lotto_a__c;
                //string df= md.year()+'-'+md.month()+'-'+md.day();
                string df = md.year() + '-';
                if (md.month() < 10)
                    df += '0' + md.month() + '-';
                else
                        df += md.month() + '-';
                if (md.day() < 10)
                    df += '0' + md.day();
                else
                        df += md.day();

                QueryAffid += ' And Lotto__r.Data_Scadenza__c <=' + String.escapeSingleQuotes(df);
            }
            if (lforFiltro.FF_Data_scadenza_affidamento_a__c != null) {
                date md = lforFiltro.FF_Data_scadenza_affidamento_a__c;
                //string df= md.year()+'-'+md.month()+'-'+md.day();
                string df = md.year() + '-';
                if (md.month() < 10)
                    df += '0' + md.month() + '-';
                else
                        df += md.month() + '-';
                if (md.day() < 10)
                    df += '0' + md.day();
                else
                        df += md.day();

                QueryAffid += ' And Data_Fine_Affidamento__c <=' + String.escapeSingleQuotes(df);
            }
            if (lforFiltro.FF_Data_scadenza_affidamento_da__c != null) {
                date md = lforFiltro.FF_Data_scadenza_affidamento_da__c;
                //string df= md.year()+'-'+md.month()+'-'+md.day();
                string df = md.year() + '-';
                if (md.month() < 10)
                    df += '0' + md.month() + '-';
                else
                        df += md.month() + '-';
                if (md.day() < 10)
                    df += '0' + md.day();
                else
                        df += md.day();

                QueryAffid += ' And Data_Fine_Affidamento__c >=' + df;
            }
            QueryAffidPag = QueryAffid;// Here I save the query generated by filters. So is possible to use Offeset and limits with it
            QueryAffid += ' Order By Name Desc Limit : LimitQuery';

            // ***Proroga
            // inizio nuovo codice 13/04/17 inserimento check permission
            /*if(Utils.checkFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Pratica__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Lotto__c').get('ACCESS')
            && Utils.checkFLSPermission('Pratica__c', 'Residuo_Totale__c').get('ACCESS')
            && Utils.checkFLSPermission('Pratica__c', 'Data_Apertura__c').get('ACCESS')
            && Utils.checkFLSPermission('Lotto__c', 'Data_Scadenza__c').get('ACCESS'))*/
            if (Utils.cebCheckObjPermission('Affidamento__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Pratica__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Lotto__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Residuo_Totale__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Apertura__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'Data_Scadenza__c', gd).get('ACCESS')) {
                listAffidamentiToView = database.Query(QueryAffid);
                initialTotal = listAffidamentiToView.size();
                totalSize = initialTotal;
            }
            // fine nuovo codice 13/04/17 inserimento check permission
        }
        // controlla se ci sono affidamenti da processare
        if (initialTotal > 0) {
            affidEsiste = true;

            //Meti check by default i affidamenti chiesti dal DB
            for (Affidamento__c aff : listAffidamentiToView) {
                recordsSelected.add(aff.id);
            }
            listAffidamentiToView.clear();
            ListTabellaAffidamentoSelectable();
        } else
                affidEsiste = false;
    }

    // ***Revoca: GESTISCI I AFFIDAMENTI SELEZIONABILI
    public void ListTabellaAffidamentoSelectable() {
        // inizio nuovo codice 13/04/17 inserimento check permission
        /*   if(Utils.checkFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c').get('ACCESS')
               && Utils.checkFLSPermission('Affidamento__c', 'Pratica__c').get('ACCESS')
               && Utils.checkFLSPermission('Affidamento__c', 'Lotto__c').get('ACCESS')
               && Utils.checkFLSPermission('Pratica__c', 'Residuo_Totale__c').get('ACCESS')
               && Utils.checkFLSPermission('Pratica__c', 'Data_Apertura__c').get('ACCESS')
               && Utils.checkFLSPermission('Lotto__c', 'Data_Scadenza__c').get('ACCESS'))*/
        if (Utils.cebCheckObjPermission('Affidamento__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Lotto__c', gd).get('ACCESS')
                && Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Residuo_Totale__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Apertura__c', gd).get('ACCESS')
                && Utils.cebCheckObjPermission('Lotto__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Data_Scadenza__c', gd).get('ACCESS')) {
            List<Affidamento__c> listAffidamentiToView = Database.Query(String.escapeSingleQuotes(QueryAffidPag + ' Order by Name Desc Limit ' + recXPage + ' OFFSET ' + (indice * recXPage)));
            List<TAffidamento> tempAff = new List<TAffidamento>();
            for (Affidamento__c aff : listAffidamentiToView) {
                // secondo il bAllSel, se si desidera di visualizzare piu record, si compila il campo boolean           
                if (bAllSel) {
                    if (!recordsSelected.contains(aff.id) && !recordsUnSelected.contains(aff.id)) {
                        recordsSelected.add(aff.id);
                    }
                    TAffidamento AffidSelect;
                    if (recordsSelected.contains(aff.id)) AffidSelect = new TAffidamento(true, aff);
                    else AffidSelect = new TAffidamento(false, aff);
                    tempAff.add(AffidSelect);
                } else {
                    if (!recordsSelected.contains(aff.id) && !recordsUnSelected.contains(aff.id)) {
                        recordsUnSelected.add(aff.id);
                    }
                    TAffidamento AffidSelect;
                    if (recordsUnSelected.contains(aff.id)) AffidSelect = new TAffidamento(false, aff);
                    else AffidSelect = new TAffidamento(true, aff);
                    tempAff.add(AffidSelect);
                }
            }

            if (tempAff.size() > 0) {
                AffidEsiste = true;
            } else AffidEsiste = false;
            listAffidamentiSelectable = tempAff;
        }
        // fine nuovo codice 13/04/17 inserimento check permission
    }

    //metodi per gestione paginazione
    public void Beginning() {
        saveState(); Indice = 0; ListTabellaAffidamentoSelectable();
    }
    public void Previous() {
        saveState(); if (indice > 0) {
            Indice--; ListTabellaAffidamentoSelectable();
        }
    }
    public void Next() {
        saveState(); if (recXPage < initialTotal && indice * recXPage < initialTotal) {
            Indice++; ListTabellaAffidamentoSelectable();
        }
    }
    public void End() {
        saveState(); indice = integer.valueof(initialTotal / recXPage); ListTabellaAffidamentoSelectable();
    }
    public boolean getIsBeginningVisibility() {
        return indice > 0;
    }
    public boolean getIsEndVisibility() {
        if (recXPage >= initialTotal) return false;
        return indice < integer.valueof(initialTotal / recXPage);
    }

    // *** Revoca: Parti tutti i filtri da zero(Usata per chiamare la pagina step 1: GestioneRevoca)
    public void Indietro() {
        System.debug('\n met. Indietro()=> \n a) Sbianca Filtri \n b) Chiama reduceFilters()');
        dataScadenzaLottoDa = null;
        dataScadenzaLottoA = null;
        dataScadenzaAffidamentoDa = null;
        dataScadenzaAffidamentoA = null;

        rightValues_Lotto = null;
        rightValues_Collector = null;
        rightValues_TipoCollector = null;
        //rightValues_Servizio=null;
        reducefilters();
    }

    // METODO per aggiornaler i affidi scelti
    public Pagereference AggiornaElementoLista() {
        // riempi recordSelected con i affidamenti selezionati
        System.debug('\n met. AggiornaElementoLista() \n');

        /*String Sel = ApexPages.currentPage().getParameters().get('isSel');
        String Affid = ApexPages.currentPage().getParameters().get('Codice_Affid');*/
        String Sel = ApexPages.currentPage().getParameters().get('isSel').escapeHtml4();
        String Affid = ApexPages.currentPage().getParameters().get('Codice_Affid').escapeHtml4();
        system.debug('Prima: Affido:  ' + Affid + '\n isSelected: ' + Sel + '\n Is AllSelected:' + bAllSel);

        if (recordsSelected.contains(Affid) && Sel == 'true')
            recordsSelected.remove(Affid);
        else if (!recordsSelected.contains(Affid) && Sel == 'false')
            recordsSelected.add(Affid);

        // aggiorna selectall
        TotalSize = recordsSelected.size();

        // aggiorna Select All
        if (TotalSize == initialTotal) {
            System.debug('\n ***IF COND: bAllSel deve essere true.');
            bAllSel = true;
        } else {
            System.debug('\n ***Else: bAllSel deve essere false.');
            bAllSel = false;
        }

        system.debug('Dopo: TotalSize: ' + TotalSize + '\n Is AllSelected:' + bAllSel);

        return null;
    }

    // ***Revoca
    public void confermaselezione() {
        AffidamentiDaElaborare = new List<Affidamento__c>();
        system.debug('\n ConfermaSelezione(): \n RecordsSelected = ' + recordsSelected + '\n Totale = ' + recordsSelected.size());
        Set<String> NameSet = recordsSelected;
        // inizio nuovo codice 13/04/17 inserimento check permission
/*        if(Utils.checkFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Pratica__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Lotto__c').get('ACCESS')
            && Utils.checkFLSPermission('Pratica__c', 'Residuo_Totale__c').get('ACCESS')
            && Utils.checkFLSPermission('Pratica__c', 'Data_Apertura__c').get('ACCESS')
            && Utils.checkFLSPermission('Lotto__c', 'Data_Scadenza__c').get('ACCESS'))*/
        if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Lotto__c', gd).get('ACCESS')
                && Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Residuo_Totale__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Apertura__c', gd).get('ACCESS')
                && Utils.cebCheckObjPermission('Lotto__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Data_Scadenza__c', gd).get('ACCESS')) {
            String queryConferma = 'Select id, Name, Stato__c, Note_Elior__c,Data_fine_affidamento_prevista__c , id_Task_associato__c, E_richiesta_una_proroga__c, Data_Termine_Proroga__c, Data_Fine_Affidamento__c, Giorni_di_proroga__c from Affidamento__c where id in :NameSet and Stato__c = \'In Corso\'';
            AffidamentiDaElaborare = Database.query(queryConferma);

            if (AffidamentiDaElaborare.size() > 0) {
                AffidamentoSelEsisti = false; System.debug('\n Metodo Conferma selezione == \n **Affidamenti selezionati: ' + AffidamentiDaElaborare + '\n Nameset: ' + recordsSelected + '\n Flag NumberOfSelectedRecords: ' + getNumberOfSelectedRecords());
            } else {
                AffidamentoSelEsisti = true;
            }

            integer i = 1;
            // modifica affidi
            for (Affidamento__c aff : AffidamentiDaElaborare) {
                System.debug('\n Stato del finale ' + i + ' record: ' + aff.Stato__c);
            }
        }
        // fine nuovo codice 13/04/17 inserimento check permission

    }

    // Revoca: Selectall ListTabellaAffidamentoSelectable
    public void SelectAll() {
        if (bAllSel) {
            recordsSelected.addAll(recordsUnSelected);
            recordsUnSelected = new set<string>();
            TotalSize = initialTotal;
        } else {
            recordsUnSelected.addAll(recordsSelected);
            recordsSelected = new set<string>();
        }
        for (TAffidamento tb : listAffidamentiSelectable) {
            tb.isSelected = bAllSel;
        }

    }

    // salva i affidamenti selezionati, durante le varie percorsi del utente
    // su il wizard
    public void saveState() {
        System.debug('\n Met. SaveState()');
        if (listAffidamentiSelectable != null && listAffidamentiSelectable.size() > 0) {
            for (TAffidamento tb : listAffidamentiSelectable) {
                if (tb.isSelected) {
                    recordsSelected.add(tb.Aff.id);
                    recordsUnSelected.remove(tb.Aff.id);
                } else {
                    recordsSelected.remove(tb.Aff.id);
                    recordsUnSelected.add(tb.Aff.id);
                }
            }
        }

    }

    // E.S. Non cambiata
    public List<SelectOption> getunSelectedValues(List<String> original) {
        try {
            List<SelectOption> options = new List<SelectOption>();
            List<string> tempList = new List<String>();
            tempList.addAll(original);
            for (string b : tempList)
                options.add(new SelectOption(b, b));
            return options;
        } catch (Exception e) {
            System.debug('Eccezione nel caricamento dei valori di sinistra: ' + e.getMessage());
            return null;
        }

    }

    // Conferma della revoca dei Affidamenti

    // Esegui impostazione dello stato dei affidi selezionati in
    // Revocato.
    public pageReference revocaAffidi() {

        // Prossimo step, sara un feedback semplice
        confirmationOP = true;
        List<id> ids = new list<id>();
        integer i = 1;
        // modifica affidi
        if (AffidamentiDaElaborare == null) {
            errorCode = 1;
            errorMessage = 'Errore, Le liste sono null. Contattare l\'amministratore';
            return null;
        }
        for (Affidamento__c aff : AffidamentiDaElaborare) {
            ids.add(aff.id);
        }
        try {
            System.debug('\n *Revocando Affidi==>' + tmpAff.Note_elior__c);
            //AffidamentiManager.revocaListAffidamenti(ids,tmpAff.Note_elior__c);
            errorCode = AffidamentiManager.revocaListAffidamentiInt(ids, tmpAff.Note_elior__c);
            System.debug('\n ** Affidi revocati! \n Affidi: ' + AffidamentiDaElaborare + '\n Codice di errore: ' + errorCode);
            if (errorCode == 0)
                return null;
            else if (errorCode == 1) errorMessage = 'Errore, Le liste sono null. Contattare l\'amministratore';
            else if (errorCode == 2) errorMessage = 'Errore, Una o più liste non presentano elementi. Contattare l\'amministratore. Le liste sono, affidmanento, pratiche, task';
            else if (errorCode == 3) errorMessage = 'Errore, Le liste non presentano un eguale numero di elementi. Contattare l\'amministratore. Il numero di Task e affidamenti non sono uguali, oppure ages.Severity.ERROR,il numero di pratiche e affidamenti non sono uguali.';
            else if (errorCode == 4) errorMessage = 'Errore durante la lavorazione dei affidamenti!';
            return null;
        } catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
    }

    // metodi per navigare il wizard
    // 
    // Legenda: ..._(Pg Attutale)_(Pg Futtura)
    public pageReference GestioneProrogaIndietro_3_2() {
        return Page.GestioneRevoca_1;
    }

    // vai sul ultimo step(3 conferma del op)
    public pageReference GestioneProrogaStep3() {
        saveState();
        System.debug('\n Metodo GestioneProrogaStep3 => Next meth: Conferma selezione');
        ConfermaSelezione();
        if (getNumberOfSelectedRecords() == 0 || getNumberOfSelectedRecords() == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, 'Devi selezionare almeno un Affido per poter procedere con questo operazione.'));
            return null;
        }
        return Page.GestioneRevoca_2;
    }

    // Vai su step 2: Query i affidi con i filtri da step 3
    public pageReference GestioneProrogaStep2() {
        QueryAffidamenti();
        bAllSel = true;
        return Page.GestioneRevoca_1;
    }

    // Torna su step 1: Imposta FIltri
    public pageReference GestioneProrogaStep1() {
        System.debug('\n met. GestioneProrogaStep1()=> Calling: Indietro()');
        indietro();
        PageReference pageRef = new PageReference('/apex/GestioneRevoca');
        pageRef.setRedirect(true);
        return pageRef;
    }

    public with sharing class TAffidamento implements Attributeable {
        public boolean isSelected { get; set; }
        public Affidamento__C Aff { get; set; }
        public Id idAff { get; set; }

        public TAffidamento(Boolean isSelected, Affidamento__c Aff) {
            this.Aff = Aff;
            this.isSelected = isSelected;
        }
    }
}