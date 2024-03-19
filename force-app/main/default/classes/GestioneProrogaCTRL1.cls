/* ---------------------------------------------------------------------------------------------------------------------
Name:            GestioneProrogaCTRL1.cls
Description:     Controller for GestioneAffidamenti.page
Test class:      TestGestioneProroga.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                          First Version
             0.2      ESino               Metodo Conferma Proroga: Il controllo del nr dei giorni é fatto dal codice.
                                          É stato rimosso dal visualforce page.
28-Sep-2021  0.3      Matteo Pizzichini   Modified for adding check permission: cebCheckFLSPermission (Security Review)
15-Jun-2022  0.4      C. Sanna & V.Doda   Modified for adding check permission: cebCheckObjPermission and
                                          cebCheckFLSPermission (Security Review)
16-Sep-2022  0.5      R.Kurti & C.Sanna   Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class GestioneProrogaCTRL1 {

    public class GestioneProrogaCTRL1Exception extends Exception {
    }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    public string recordsForPage { get {if (recordsForPage == null) return '25'; return recordsForPage;} set; }
    public integer RecXPage {
        get {
            if (recordsForPage == null) RecXPage = 0;
            else RecXPage = integer.valueOf(recordsForPage);
            //RecXpage=1;
            return RecXPage;
        }
        set;
    }
    public void sizeTable() {
        saveState();
        indice = 0;
        RecXPage = integer.valueOf(recordsForPage);
        ListTabellaAffidamentoSelectable();
    }
    public List<SelectOption> recordsForPageValues {
        get {
            List<SelectOption> records = new list<SelectOption>();
            records.add(new SelectOption('25', '25'));
            records.add(new SelectOption('50', '50'));
            records.add(new SelectOption('200', '100'));
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
    public string scadutoInizialeDa { get; set; }
    public string scadutoInizialeA { get; set; }
    public static string nrGiorniProroga { get; set; }  //scrivi esplicitamente i metodi get()&Set()
    public decimal decScadutoInizialeDa { get; set; }
    public decimal decScadutoInizialeA { get; set; }
    public boolean validScadutoInizialeDa { get; set; }
    public boolean validScadutoInizialeA { get; set; }
    public boolean validnrGiorniProga { get; set; }
    public boolean errorValidateNrProroga { get; set; }
    public boolean nrGiorniProrogaVuoto { get; set; }
    public boolean nrGiorProOutOfRange { get; set; }

    public boolean confirmationOP { get; set; }

    //count and visibility
    public boolean ciSonoAffidamentiDaLavorare { get; set; }
    public integer hawmanyaffidamentiarePresent { get; set; }
    public boolean thereAreLessThanLimit { get; set; }

    // oggetto temp per gestione del proroga
    public Affidamento__c tmpAff { get; set; }

    public boolean affidEsiste { get; set; }
    public boolean AffidamentoSelEsisti { get; set; }

    // ricorda tipo di operazione scelto true => Approva Proroga false => Rifiuta Proroga
    public boolean isApprova { get; set; }

    // ricorda il nr totale iniziale
    public integer initialTotal { get; set; }

    // Totale finale dei affidi lavorati
    public integer finalTotal { get; set; }

    // selezione del tipo d'operazione: Approva/Rifiuta
    Public String leftselected_SelTipo { get; set; }
    Public List<SelectOption> unSelectedValues_SelTipo { get; set; }
    List<String> originalValues_SelTipo = new List<String>();

    // Lista dei affidamenti da visualizzare
    public list<TAffidamento> listAffidamentiSelectable { get; set; }
    public transient list<Affidamento__c> listAffidamentiToView { get; set; }
    public List<Affidamento__c> AffidamentiDaElaborare { get; set; }

    // Fine: Proroga
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
    public List<String> rightValues_Lotto { get; set; }
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
                    && Utils.cebCheckFLSPermission('Lotto__c', 'name', gd).get('ACCESS')) {

                set<String> myValues = new Set<String>();
                originalValues_Lotto = new List<String>();

                List<Lotto__c> lottoList = new List<Lotto__C>();
                lottoList = [Select name from Lotto__c LIMIT 50000];
                //lottoList = [Select name from Lotto__c WITH SECURITY_ENFORCED LIMIT 50000];
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
    public List<String> rightValues_Collector { get; set; }
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
                    && Utils.cebCheckFLSPermission('Collector__c', 'name', gd).get('ACCESS')) {

                set<String> myValues = new Set<String>();
                originalValues_Collector = new List<String>();

                List<Collector__c> collectList = new List<Collector__C>();
                collectList = [Select name from Collector__c LIMIT 50000];
                //collectList = [Select name from Collector__c WITH SECURITY_ENFORCED LIMIT 50000];
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
    public List<String> rightValues_TipoCollector { get; set; }
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
            //if(originalValues_TipoCollector== null) {
            if (originalValues_TipoCollector == null
                    && Utils.cebCheckObjPermission('Collector__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Collector__c', 'tipo_collector__c', gd).get('ACCESS')) {

                set<String> myValues = new Set<String>();
                originalValues_TipoCollector = new List<String>();

                List<collector__C> collectList = new List<collector__C>();
                collectList = [Select tipo_collector__c from collector__c LIMIT 50000];
                //collectList = [Select tipo_collector__c from collector__c WITH SECURITY_ENFORCED LIMIT 50000];
                for (Collector__c l : collectList)
                    myValues.add(l.tipo_collector__c);
                originalValues_TipoCollector.addAll(myValues);
                return originalValues_TipoCollector;
            } else
                    return originalValues_TipoCollector;
        }
        set;
    }

    // Servizio
    public List<String> rightValues_Servizio { get; set; }
    public integer getrightValues_ServizioSize() {
        if (rightValues_Servizio == null) return 0;
        return rightValues_Servizio.size();
    }
    public integer getoriginalValues_ServizioSize() {
        if (originalValues_Servizio == null) return 0;
        return originalValues_Servizio.size();
    }
    public List<String> originalValues_Servizio {
        get {
            //if(originalValues_Servizio== null) {
            if (originalValues_Servizio == null
                    && Utils.cebCheckObjPermission('Servizio__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Servizio__c', 'RecordTypeId', gd).get('ACCESS')) {
                set<String> myValues = new Set<String>();
                originalValues_Servizio = new List<String>();

                List<Servizio__c> pratList = new List<Servizio__c>();
                pratList = [Select RecordType.Name from Servizio__c LIMIT 50000];
                //pratList = [Select RecordType.Name from Servizio__c WITH SECURITY_ENFORCED LIMIT 50000];
                for (servizio__c s : pratList)
                    myValues.add(s.RecordType.Name);
                originalValues_Servizio.addAll(myValues);
                return originalValues_Servizio;
            } else
                    return originalValues_Servizio;
        }
        set;
    }

    // Fine: Filtri Affidamenti


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
            } else if (iIndex == 4) {
                // Servizio
                rightValues_Servizio.clear();
                if (sElenco != '') {
                    for (string s : elenco)
                        rightValues_Servizio.add(s);
                }
            }

        } catch (Exception e) {
            System.Debug('Eccezione nel metodo UpdateListe: ' + e.getMessage());
        }
    }
    public integer getNumberOfSelectedRecords() {
        return recordsSelected.size();
    }

    // ============= Costruttore ===================
    public GestioneProrogaCTRL1() {
        erroreSeverityInfo = false;
        confirmationOP = false;
        ErrorValidateDecimal = false;
        errorValidateNrProroga = false;
        nrGiorniProrogaVuoto = false;
        bAllSel = true;
        conditionPraticaBloccoManuale = TagHelper.getValueText('StatoPraticaBloccoManuale');
        LimitQuery = TagHelper.getValueInteger('MaxProrogaSizeList');

        System.debug('**Costruttore GestioneProrogaCTRL1');
        rightValues_Lotto = new list<String>();
        rightValues_Collector = new list<String>();
        rightValues_TipoCollector = new list<String>();
        rightValues_Servizio = new list<String>();

        // E.S.
        originalValues_SelTipo.add('Approva Proroga');
        originalValues_SelTipo.add('Rifiuta Proroga');
        leftselected_SelTipo = 'Approva Proroga';
        unSelectedValues_SelTipo = getunSelectedValues(originalValues_SelTipo);

        QueryAffid = null;
        Indice = 0;
        MapSelezione = new Map<String, Boolean>();
        recordsSelected = new set<string>();
        recordsUnSelected = new set<string>();

        // inizia container
        tmpAff = new Affidamento__C();

        //Make a Filter on filters if possible
        reducefilters();

    }

    // ================================== 1st Level =====================0

    // Metodo per controllare se ci sono dei affidi da prorogare oppure
    // riducere i filtri della proroga.
    public void reduceFilters() {
        ciSonoAffidamentiDaLavorare = false;
        /*if(Utils.checkFLSPermission('Affidamento__c', 'Tipo_servizio__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Tipo_collector__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'codice_lotto__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Nome_Collector__c').get('ACCESS'))*/
        if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Tipo_servizio__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Tipo_collector__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'codice_lotto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Giorni_di_proroga_richiesti_da_Collector__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Nome_Collector__c', gd).get('ACCESS')) {
            List<Affidamento__c> affList = [
                    Select id, Giorni_di_proroga_richiesti_da_Collector__c, Tipo_servizio__c,
                            Tipo_collector__c, Nome_Collector__c, codice_lotto__c
                    from Affidamento__C
                    where E_richiesta_una_proroga__c = true and stato__c = 'In corso'
                    and Pratica__r.stato__c != :conditionPraticaBloccoManuale
                    //WITH SECURITY_ENFORCED
                    limit :LimitQuery
            ];
            if (affList.size() > 0) ciSonoAffidamentiDaLavorare = true;
            hawmanyaffidamentiarePresent = affList.size();
            thereAreLessThanLimit = (hawmanyaffidamentiarePresent < LimitQuery);

            if (thereAreLessThanLimit) {
                set<String> setLotti = new set<String>();
                set<String> setCollector = new set<String>();
                set<String> setTipoCollector = new set<String>();
                set<String> setTipoServizio = new set<String>();
                for (affidamento__C a : affList) {
                    setLotti.add(a.codice_lotto__c);
                    setCollector.add(a.Nome_Collector__c);
                    setTipoCollector.add(a.Tipo_collector__c);
                    setTipoServizio.add(a.Tipo_servizio__c);
                }
                originalValues_Lotto = new List<String>();
                originalValues_Lotto.addAll(setLotti);

                originalValues_Collector = new List<String>();
                originalValues_Collector.addAll(setCollector);

                originalValues_TipoCollector = new List<String>();
                originalValues_TipoCollector.addAll(setTipoCollector);

                originalValues_Servizio = new List<String>();
                originalValues_Servizio.addAll(setTipoServizio);
            }
        }
    }
    // Querare i affidi secondo le specifiche dei filtri
    public void QueryAffidamenti() {
        String patDecimal = '(^(\\+|\\-)(0|([1-9][0-9]*))(\\.[0-9]{1,2})?$)|(^(0{0,1}|([1-9][0-9]*))(\\.[0-9]{1,2})?$)';

        // 1. Controllo la validitá dei dati inseriti dal Utente
        // ***** Proroga (Valori Corretti)
        if (decScadutoInizialeDa > decScadutoInizialea) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Il range di valori del filtro Scaduto Iniziale non è valido.'));
            ErrorValidateDecimal = true;
            return;
        }
        if (dataScadenzaLottoDa != null && dataScadenzaLottoA != null) {
            integer dayDiff1;
            dayDiff1 = dataScadenzaLottoDa.daysBetween(dataScadenzaLottoA);
            if (dayDiff1 < 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Il range di valori della data della scadenza del Lotto non sono validi.'));
                ErrorValidateDecimal = true;
                return;
            }
        }
        if (dataScadenzaAffidamentoDa != null && dataScadenzaAffidamentoA != null) {
            integer dayDiff2;
            dayDiff2 = dataScadenzaAffidamentoDa.daysBetween(dataScadenzaAffidamentoA);
            if (dayDiff2 < 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Il range di valori della data della scadenza del Affidamento non sono validi.'));
                ErrorValidateDecimal = true;
                return;
            }
        }


        // ****PROROGA
        /*if(Utils.checkFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Pratica__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Lotto__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Residuo_Totale__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Data_Apertura__c').get('ACCESS')
                && Utils.checkFLSPermission('Lotto__c', 'Data_Scadenza__c').get('ACCESS'))*/
        if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Giorni_di_proroga_richiesti_da_Collector__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Lotto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Residuo_Totale__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Apertura__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Data_Scadenza__c', gd).get('ACCESS')) {
            QueryAffid = 'Select id, Giorni_di_proroga_richiesti_da_Collector__c, Name, Pratica__r.Name,Lotto__r.Agenzia_di_Recupero__r.Name, Pratica__r.Account__r.Name, Pratica__r.Residuo_Totale__c, Pratica__r.Data_Apertura__c,pratica__r.Servizio_Fornitura__r.RecordType.Name, Lotto__r.Data_Scadenza__c, Lotto__r.Agenzia_di_Recupero__r.Tipo_Collector__c, Lotto__r.id, pratica__r.Servizio_Fornitura__r.LookupContratto__r.Comune__c, Data_fine_affidamento_prevista__c ';
            QueryAffid += ' From Affidamento__c Where E_richiesta_una_proroga__c = true and stato__c=\'In corso\' and Pratica__r.stato__c !=: conditionPraticaBloccoManuale';

            // ***PROROGA: COMPOSTA IL QUERY        
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
            if (rightValues_Servizio.size() > 0) {
                QueryAffid += ' And pratica__r.Servizio_Fornitura__r.RecordType.Name in:rightValues_Servizio ';
            }
            // considerare i altri intervali
            if (decScadutoInizialeDa != null && decScadutoInizialeDa != null && (decScadutoInizialea - decScadutoInizialeDa) > 0) {
                QueryAffid += ' And Scaduto_iniziale__c >= ' + decscadutoInizialeDa + ' AND Scaduto_iniziale__c<= ' + decscadutoInizialeA + ' ';
            }
            if (dataScadenzaLottoDa != null) {
                QueryAffid += ' And Lotto__r.Data_Scadenza__c >=:dataScadenzaLottoDa ';

            }
            if (dataScadenzaLottoA != null) {
                QueryAffid += ' And Lotto__r.Data_Scadenza__c <=:dataScadenzaLottoA ';
            }
            if (dataScadenzaAffidamentoA != null) {
                QueryAffid += ' And Data_fine_affidamento_prevista__c <=:dataScadenzaAffidamentoA ';
            }
            if (dataScadenzaAffidamentoDa != null) {
                QueryAffid += ' And Data_fine_affidamento_prevista__c >=:dataScadenzaAffidamentoDa ';
            }
            QueryAffidPag = QueryAffid;// Here I save the query generated by filters. So is possible to use Offeset and limits with it
            QueryAffid += ' Order By Name Desc Limit : LimitQuery';
            errorClass.logError('QUERY', QueryAffid);
            // ***Proroga
            listAffidamentiToView = database.Query(QueryAffid);
            System.debug('\n listAffidamentiToView: ' + listAffidamentiToView);
            initialTotal = listAffidamentiToView.size();
            totalSize = initialTotal;

            // controlla se ci sono affidamenti da processare
            if (initialTotal > 0) affidEsiste = true;
            else affidEsiste = false;

            //Meti check by default i affidamenti chiesti dal DB
            for (Affidamento__c aff : listAffidamentiToView) {
                //MapSelezione.put(aff.id,true);
                recordsSelected.add(aff.id);
            }
            listAffidamentiToView.clear();
            ListTabellaAffidamentoSelectable();
        }
    }
    // ***PROROGA: GESTISCI I AFFIDAMENTI SELEZIONABILI
    public void ListTabellaAffidamentoSelectable() {
        String debug = '\n Met. ListTabellaAffidamentoSelectable(): ';
        // inizio nuovo codice 13/04/17 inserimento check permission
        /*if (Utils.checkFLSPermission('Affidamento__C', 'stato__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__C', 'Note_elior__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__C', 'Data_scaduto_iniziale__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__C', 'id_Task_associato__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__C', 'Scaduto_iniziale__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__C', 'Data_Affidamento__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__C', 'Id_User_Assegnatario_Pratica__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__C', 'pratica__c').get('ACCESS'))*/

        if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Note_elior__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_scaduto_iniziale__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_iniziale__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Id_User_Assegnatario_Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'pratica__c', gd).get('ACCESS'))

        {
            List<Affidamento__c> listAffidamentiToView = Database.Query(QueryAffidPag + ' Order by Name Desc Limit ' + recXPage + ' OFFSET ' + (indice * recXPage));
            debug += '\n \n Query: ' + QueryAffidPag + ' Order by Name Desc Limit ' + recXPage + ' OFFSET ' + (indice * recXPage);
            debug += '\n \n listAffidamentiToView: ' + String.valueOf(listAffidamentiToView);
            integer i = 1;
            List<TAffidamento> tempAff = new List<TAffidamento>();
            for (Affidamento__c aff : listAffidamentiToView) {
                debug += '\n ' + i + ' Affido:';
                if (!recordsSelected.contains(aff.id) && !recordsUnSelected.contains(aff.id)) recordsSelected.add(aff.id);
                TAffidamento AffidSelect;
                if (recordsSelected.contains(aff.id)) AffidSelect = new TAffidamento(true, aff);
                else AffidSelect = new TAffidamento(false, aff);
                tempAff.add(AffidSelect);
                i++;
            }

            if (tempAff.size() > 0) {
                AffidEsiste = true;
            } else AffidEsiste = false;
            listAffidamentiSelectable = tempAff;
            debug += '\n Fine listAffidamentiSelectable!!';

        }
        // fine nuovo codice 13/04/17 inserimento check permission
        System.debug('\n ' + debug);
    }

    // =================================== Metodi per gestione paginazione
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

    // =============================== Metodi per adeguare il navigazione fra le pagine =========================

    // Prendi solo i affidi SELEZIONATI tramite checkbox
    public void confermaselezione() {
        AffidamentiDaElaborare = new List<Affidamento__c>();
        Set<String> NameSet = recordsSelected;
        /*if(Utils.checkFLSPermission('Affidamento__c', 'Note_Elior__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'id_Task_associato__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'E_richiesta_una_proroga__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_Termine_Proroga__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Giorni_di_proroga__c').get('ACCESS'))*/
        if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Note_Elior__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'E_richiesta_una_proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Termine_Proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Giorni_di_proroga__c', gd).get('ACCESS')) {
            String queryConferma = 'Select id,ID_task_target_revoca__c,Name,Note_Elior__c,id_Task_associato__c,E_richiesta_una_proroga__c,Data_Termine_Proroga__c,Data_fine_affidamento_prevista__c,Giorni_di_proroga__c from Affidamento__c where id in :NameSet';
            AffidamentiDaElaborare = Database.query(queryConferma);

            if (AffidamentiDaElaborare.size() > 0) {
                AffidamentoSelEsisti = false;
            } else {
                AffidamentoSelEsisti = true;
            }
        }
    }

    // ***Proroga:Selectall ListTabellaAffidamentoSelectable
    public void SelectAll() {
        if (bAllSel) {
            recordsSelected.addAll(recordsUnSelected);
            recordsUnSelected = new set<string>();
        } else {
            recordsUnSelected.addAll(recordsSelected);
            recordsSelected = new set<string>();
        }
        for (TAffidamento tb : listAffidamentiSelectable) {
            tb.isSelected = bAllSel;
        }
    }

    public void saveState() {
        //System.Debug('listAffidamentiSelectable --> ' + listAffidamentiSelectable);
        //System.Debug('listAffidamentiSelectable size --> ' + listAffidamentiSelectable.size());
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

    // *****Proroga Esegui il operazione Approva/Rifiuta
    /*
    *   idEsitiWhatId => si usa per memorizzare la id dei affidi e la data della termine di proroga
    *   List<Task> taskProcessoForUpdate => Task processo dei affidi
    *   List<Task> taskEsitoForUpdate => Task Esiti associati per una richiesta proroga
    */

    //  APPROVAZIONE
    public boolean ConfermaApprProroga() {

        List<Task> taskProcessoForUpdate = new List<Task>();
        List<Task> taskEsitoForUpdate = new List<Task>();
        Map<id, String> idEsitiWhatId = new Map<id, String>();
        finalTotal = 0;
        errorMsgStep3 = '';
        nomiAffidiConProb = '';
        totalRecNotProcessed = 0;
        List<Task> tasks = new List<Task>();
        for (Affidamento__c a : AffidamentiDaElaborare) {
            //if(a.ID_task_target_revoca__c != '' && a.ID_task_target_revoca__c!= null){
            if (a.id_Task_associato__c != '' && a.id_Task_associato__c != null) {
                Task t = new Task();
                //t.Id = a.ID_task_target_revoca__c;
                t.Id = a.id_Task_associato__c;
                tasks.add(t);
            }
        }
        Map<Id, ActivityExtended__c> task2Obj = Utils.getTaskWithActivityExtended(tasks);
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        // Modifica i affidamenti per la approvazione della proroga
        for (Affidamento__c a : AffidamentiDaElaborare) {
            // 2.1 Operazioni su i affidamenti
            if (a.Data_fine_affidamento_prevista__c != null) {
                a.Data_Termine_Proroga__c = a.Data_fine_affidamento_prevista__c.addDays(integer.valueOf(tmpAff.Giorni_di_proroga__c));
            } else {
                erroreSeverityInfo = true;
                nomiAffidiConProb += a.name + ', ';
                totalRecNotProcessed++;
                continue;
            }
            a.E_richiesta_una_proroga__c = false;
            a.Giorni_di_proroga__c = tmpAff.Giorni_di_proroga__c;
            a.Note_Elior__c = tmpAff.Note_elior__c;

            idEsitiWhatId.put(a.id, String.valueOf(a.Data_Termine_Proroga__c));
            System.debug('\n 2.1 Affido: ' + a);

            // 2.2 operazioni su i task associati controlla se esistono dei task da modificare

            //if(a.ID_task_target_revoca__c != '' && a.ID_task_target_revoca__c!= null){
            if (a.id_Task_associato__c != '' && a.id_Task_associato__c != null) {
                Task t = new Task();
                //t.id = a.ID_task_target_revoca__c;
                t.id = a.id_Task_associato__c;
                //if (task2Obj.containsKey(a.ID_task_target_revoca__c)) {
                if (task2Obj.containsKey(a.id_Task_associato__c)) {
                    //ActivityExtended__c ae = task2Obj.get(a.ID_task_target_revoca__c);
                    ActivityExtended__c ae = task2Obj.get(a.id_Task_associato__c);
                    ae.Expiration_date__c = a.Data_Termine_Proroga__c;
                    aes.add(ae);
                }

                System.debug('\n 2.2 Task Assocciato, modificato: ' + t);
                taskProcessoForUpdate.add(t);
            }
            finalTotal++;
        }
        //if (aes.size() > 0 && Utils.checkFLSPermission('ActivityExtended__c', 'Expiration_date__c').get('UPDATE')) update aes;
        if (aes.size() > 0
                && Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Expiration_date__c', gd).get('UPDATE')) {
            update aes;
        }
        if (taskProcessoForUpdate.size() > 0
                && Utils.cebCheckObjPermission('Task', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Task', 'Id', gd).get('UPDATE')) {
            update taskProcessoForUpdate;
        }
        // prendi i task esiti dei affidi
        //taskEsitoForUpdate = updateEsiti(true, idEsitiWhatId);
        if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'whatId', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c', gd).get('ACCESS')) {
            taskEsitoForUpdate = updateEsiti(true, idEsitiWhatId);
        }
        if (taskEsitoForUpdate != null && taskEsitoForUpdate.size() > 0
                && Utils.cebCheckObjPermission('Task', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Task', 'Id', gd).get('UPDATE')) {
            update taskEsitoForUpdate;
            System.debug('\n *ConfermaRifProroga(), Approva Esiti: ' + taskEsitoForUpdate);
        }

        //Da controllare i campi
        if (AffidamentiDaElaborare.size() > 0 && Utils.cebCheckObjPermission('Affidamento__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Termine_Proroga__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c', gd).get('UPDATE')) {
            update AffidamentiDaElaborare;
        }
        System.debug('\n AffidamentiDaElaborare modificati: ' + AffidamentiDaElaborare);
        return true;
    }

    // RIFIUTA
    public boolean ConfermaRifProroga() {

        List<Task> taskEsitoForUpdate = new List<Task>();
        Map<id, String> idEsitiWhatId = new Map<id, String>();
        finalTotal = 0;

        // Modifica i affidamenti per la approvazione della proroga
        for (Affidamento__c a : AffidamentiDaElaborare) {
            a.E_richiesta_una_proroga__c = false;
            a.Note_Elior__c = tmpAff.Note_elior__c;
            idEsitiWhatId.put(a.id, '');
        }

        // prendi i task esiti dei affidi
        //taskEsitoForUpdate = updateEsiti(false, idEsitiWhatId);
        if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'whatId', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c', gd).get('ACCESS')) {
            taskEsitoForUpdate = updateEsiti(false, idEsitiWhatId);
        }

        if (taskEsitoForUpdate != null && taskEsitoForUpdate.size() > 0
                && Utils.cebCheckObjPermission('Task', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Task', 'Id', gd).get('UPDATE')) {
            update taskEsitoForUpdate;
            System.debug('\n *ConfermaRifProroga(), Update Esiti: ' + taskEsitoForUpdate);
        }

        finalTotal = affidamentiDaElaborare.size();
        if (finalTotal > 0
                && Utils.cebCheckObjPermission('Affidamento__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'E_richiesta_una_proroga__c', gd).get('UPDATE')) {
            update affidamentiDaElaborare;
        }
        return true;
    }

    // Metodo per modificare i task esiti per i affidi
    // Input: Map<id Affido, dataTerminediAffido>
    public List<Task> updateEsiti(boolean approva, Map<id, String> idTaskEsiti) {
        List<Task> myTasks = new List<task>();
        Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();
        try {
            Map<string, Schema.RecordTypeInfo> nameID = new Map<string, Schema.RecordTypeInfo>();
            nameId = Schema.SObjectType.Task.getRecordTypeInfosByName();
            id rcrdTypid = nameId.get('EsitiCollector').getRecordTypeID();
            if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                    && Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'recordTypeId', gd).get('ACCESS')) {
                myTasks = [
                        Select whatId, ActivityExtended__r.proroga_Affido_ApprovRifiu__c, ActivityExtended__r.proroga_Giorni_di_Proroga__c,
                                ActivityExtended__r.proroga_data_lavorazione__c, ActivityExtended__r.proroga_Data_Termine__c,
                                ActivityExtended__r.proroga_Nota__c
                        From Task
                        Where whatId In :idTaskEsiti.keySet() and recordtypeId = :rcrdTypid
                        and ActivityExtended__r.Esiti_Collector__c = 'RICHIESTA DI PROROGA'
                        //WITH SECURITY_ENFORCED
                ];

                task2Obj = Utils.getTaskWithActivityExtended(myTasks);

                System.debug('\n *** \n UpdateEsiti()-- letto i task esiti!');
            }
        } catch (Exception e) {
            System.debug('\n Errore nel interroga delle task dei Esiti. Dettagli: ' + e.getMessage());
            return null;
        }
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        if (approva) {// Compila dati approva proroga
            System.debug('\n * \n Approvazione Proroga! ');
            Date todayDate = System.Today();
            for (Task t : myTasks) {
                System.debug('\n TASK----> ' + t + '\n Data del WhatID: ' + idTaskEsiti.get(t.whatId));
                ActivityExtended__c ae = task2Obj.get(t.Id);
                ae.proroga_Affido_ApprovRifiu__c = 'Approvata';
                ae.proroga_Giorni_di_Proroga__c = integer.valueOf(tmpAff.Giorni_di_proroga__c);
                ae.proroga_Data_Termine__c = Date.valueOf(idTaskEsiti.get(t.whatId));
                ae.proroga_Nota__c = tmpAff.Note_Elior__c;
                ae.proroga_data_lavorazione__c = system.now();
                aes.add(ae);
            }
        } else { // Compila Dati rifiuta proroga
            System.debug('\n * \n Rifiuta Proroga! ');
            for (Task t : myTasks) {
                ActivityExtended__c ae = task2Obj.get(t.Id);
                ae.proroga_Affido_ApprovRifiu__c = 'Rifiutata';
                ae.proroga_Nota__c = tmpAff.Note_Elior__c;
                ae.proroga_data_lavorazione__c = system.now();
                // sbianca altri campi proroga_...
                ae.proroga_Data_Termine__c = null;
                aes.add(ae);
            }
        }
        if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'proroga_Affido_ApprovRifiu__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'proroga_Nota__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'proroga_data_lavorazione__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'proroga_Data_Termine__c', gd).get('UPDATE')) {
            update aes;
        }
        return myTasks;
    }

    // ===================== PageREference methods to switch from pages ==========================
    public pageReference GestioneProrogaStep4() {
        if (leftselected_SelTipo == 'Approva Proroga') isApprova = true;
        else isApprova = false;
        System.debug('\n GestioneProrogaStep4, leftselected_SelTipo: ' + leftselected_SelTipo);
        return Page.GestioneProroga_3;
    }

    // Step FInale: Lavora affidi e task associati
    public string errorMsgStep3 { get; set; }
    public string nomiAffidiConProb { get; set; }
    public List<String> errorMsgStep3List { get; set; }
    public boolean erroreSeverityInfo { get; set; }
    public integer totalRecNotProcessed { get; set; }

    public pageReference GestioneProrogaConfirmOperation() {
        if (AffidamentiDaElaborare == null || AffidamentiDaElaborare.size() == 0) {
            System.debug('\n GestioneProrogaConfirmOperation, affidi da lavorare null!');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Prego di scegliere dei affidi da procedere con questo operazione!'));
            return null;
        }
        if (isApprova && (tmpAff.Giorni_di_proroga__c == null || tmpAff.Giorni_di_proroga__c == 0)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Prego di inserire il numero dei giorni di proroga!'));
            return null;
        }
        if (isApprova == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Non é stato specificato un approvazione oppure una rifiuta!'));
            return null;
        } else if (isApprova) {
            confirmationOP = ConfermaApprProroga();
        } else {
            confirmationOP = ConfermaRifProroga();
        }

        if (erroreSeverityInfo) {
            errorMsgStep3 = '\n I(Il) affidamenti(o) ' + nomiAffidiConProb + ' non contengono la data fine affidamento iniziale compilata!';
            errorMsgStep3 += '\n Ci sono ' + totalRecNotProcessed + ' affidamenti(o) non processati!';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, errorMsgStep3));
        }

        return null;
    }

    public pageReference GestioneProrogaIndietro_4_3() {
        return Page.GestioneProroga_2;
    }
    public pageReference GestioneProrogaIndietro_3_2() {
        return Page.GestioneProroga_1;
    }

    // - Conferma affidi selezionati.
    public pageReference GestioneProrogaStep3() {
        saveState();
        ConfermaSelezione();
        if (getNumberOfSelectedRecords() == 0 || getNumberOfSelectedRecords() == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, 'Devi selezionare almeno un Affido per poter procedere con questo operazione.'));
            return null;
        }
        System.debug('\n Go to Step3, Affidi selezionati: ' + AffidamentiDaElaborare);
        return Page.GestioneProroga_2;
    }
    public pageReference GestioneProrogaStep2() {
        QueryAffidamenti();
        bAllSel = true;
        return Page.GestioneProroga_1;
    }
    public pageReference GestioneProrogaStep1() {
        PageReference pageRef = new PageReference('/apex/GestioneProroga');
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