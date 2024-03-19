/* ---------------------------------------------------------------------------------------------------------------------
Name:            TaskSemiAutomatici.cls
Description:
Test class:      TestCoverage_TaskSemiAutomatici.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
16-Jun-2016  0.2      E.Sino                          Aggiunto il with sharing come richiesta da Salesforce.com per soddisfare le specifiche
                                                      del Security Review. Inizialmente questo controller e' stato costruito con il Without Sharing.
14-Sep-2022  0.3      R. Kurti & C. Sanna             Modified for adding check permission:
                                                      cebCheckFLSPermission/cebCheckObjPermission/WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class TaskSemiAutomatici {
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public Map<String, Header> MapHeader { get; set; }
    public Set<string> tipiDiAffidi { get; set; }
    public integer Step { get; set; }
    set<Id> SetIdStrategie = new set<Id>();
    public transient list <PraticheSelectable> listPraticheSelectable { get; set; }
    public Integer Count { get; set; }

    public List<SelectOption> pickVisibilityResult { get; set; }
    public String OptionPickVisibilityResult { get; set; }
    public boolean TaskElab { get; set; }

    public List<String> originalValues_PickVisibilityResult = new List<String>{
            'All_Task', 'My_Task'
    };
    public Map<Id, Strategia__c> MapStrategiaPerIdPrat;
    Set<Id> SetIdPratica = new set<Id>();
    public list<Pratica__c> ListPraticaToView = new list<Pratica__c>();
    public transient list<Pratica__c> ListPraticaAll = new list<Pratica__c>();
    public boolean PraticheEsisti { get; set; }
    public string DaScaduto { get; set; }
    public string AScaduto { get; set; }
    public string DaScadutoConsolidato { get; set; }
    public string AScadutoConsolidato { get; set; }
    public string DaSaldoSpese { get; set; }
    public string ASaldoSpese { get; set; }
    public string DaSaldoConsolidato { get; set; }
    public string ASaldoConsolidato { get; set; }

    public string DaAnzianita_scaduto { get; set; }
    public string AAnzianita_scaduto { get; set; }
    public string DaSaldo_Totale { get; set; }
    public string ASaldo_Totale { get; set; }
    public string DaScaduto_Spese { get; set; }
    public string AScaduto_Spese { get; set; }

    public decimal decimalDaScaduto;
    public decimal decimalAScaduto;

    public boolean shouldRedirect { get; set; }
    public String url_Parent { get; set; }


    public decimal decimalDaScadutoConsolidato;
    public decimal decimalAScadutoConsolidato;

    public decimal decimalDaSaldoSpese;
    public decimal decimalASaldoSpese;

    public decimal decimalDaSaldoConsolidato;
    public decimal decimalASaldoConsolidato;

    public decimal decimalDaAnzianita_scaduto;
    public decimal decimalAAnzianita_scaduto;

    public decimal decimalDaSaldo_Totale;
    public decimal decimalASaldo_Totale;

    public decimal decimalDaScaduto_Spese;
    public decimal decimalAScaduto_Spese;
    public List<Pratica__c> lPratFiltro;


    // Pagination

    String Query_Prat_All;
    String Query_Prat_Limit;
    Public List<String> List_First_X_Page;
    Public Integer InizioL { get; set; }
    Public Integer FineL { get; set; }
    Public Integer TotaleRec { get; set; }
    Public Integer Controllo { get; set; }
    Public Integer CPage { get; set; }
    Public Integer RecXPage { get; set; }
    Public List<String> List_Firt_Rec_X_Page = new List<String>();
    Public Map<String, boolean> MapSelezione;


    //Id Contratto
    public List<String> rightValues_IdContratto { get; set; }
    public set<String> SetIdContr { get; set; }

    //Update Paginazione con Bootstrap 21/02/2017
    //Pierpaolo e Matteo

    public Integer noOfRecords { get; set; }
    public Integer n { get; set; }
    public Integer size { get; set; }
    public String PrtFilterId { get; set; }
    public List<String> searchFields { get; private set; }
    public Pratica__c anPratica { get; set; }
    public string whereClause { get; set; }
    public Map<String, Schema.FieldSetMember> m { get; private set; }
    public String vPickValue { get; set; }
    public List<SelectOption> picklistValues { get; set; }
    public String selField { get; set; }
    public String delF { get; set; }
    public Boolean isString { get; private set; }
    public Boolean isDate { get; private set; }
    public Boolean isInteger { get; private set; }
    public Boolean isDouble { get; private set; }
    public Boolean isObject { get; private set; }
    public Boolean isCheckbox { get; private set; }
    public Boolean isPicklist { get; private set; }
    public Integer iInputStart { get; set; }
    public Integer iInputFinish { get; set; }
    public Double ndInputStart { get; set; }
    public Double ndInputFinish { get; set; }
    public Schema.FieldSetMember oInput { get; set; }
    public String sInput { get; set; }
    public String pInput { get; set; }
    public Date dInputStart { get; set; }
    public Date dInputFinish { get; set; }
    public Boolean cInput { get; set; }
    public List<SelectOption> pkInputList { get; private set; }
    public List<String> filter { get; private set; }
    public List<String> searchList { get; private set; }

    // SI per Selezionare le pratiche estratte
    Public Boolean bAllSel { get; set; }

    // SI per gestire la scelta dell'invio Lettera
    Public String leftselected_Tipo_Lettera { get; set; }
    Public List<SelectOption> unSelectedValues_Tipo_Lettera { get; set; }
    Public List<String> originalValues_Tipo_Lettera; // = new List<String>{'Seleziona','Lettera Semplice','Raccomandata'};
    Public Boolean BLettera { get; set; }

    // Per gestire la scelta fatta dall'utente
    public String TipoContent { get; set; }
    String SottoTipoContent;
    String OwnerContent;
    String Header_Content;
    String TipoH;
    String SottoTipoH;
    String MHeader;
    String TipoCQuery;
    String SottoTipoCQuery;
    String TipoHQuery;
    String SottoTipoHQuery;
    String QueryTask;

    public boolean validDaScaduto { get; set; }
    public boolean validAScaduto { get; set; }
    public boolean validDaScadutoConsolidato { get; set; }
    public boolean validAScadutoConsolidato { get; set; }
    public boolean validDaSaldoSpese { get; set; }
    public boolean validASaldoSpese { get; set; }
    public boolean validDaSaldoConsolidato { get; set; }
    public boolean validASaldoConsolidato { get; set; }

    public boolean validDaAnzianita_scaduto { get; set; }
    public boolean validAAnzianita_scaduto { get; set; }

    public boolean validDaScaduto_Spese { get; set; }
    public boolean validAScaduto_Spese { get; set; }

    public boolean validDaSaldo_Totale { get; set; }
    public boolean validASaldo_Totale { get; set; }

    public boolean ErrorValidateDecimal { get; set; }

    public boolean isAffido { get; set; }

    public class Header {
        public Integer NRecord { get; set; }
        public Integer MaxGG { get; set; }
        public String Tipo { get; set; }
        public String SottoTipo { get; set; }
        public Boolean Rendered { get; set; }
        public list<Content> lCont { get; set; }

        public Header() {
        }
        public Header(Header h) {
            this.Nrecord = h.NRecord;
            this.MaxGG = h.MaxGG;
            this.Tipo = h.Tipo;
            this.SottoTipo = h.SottoTipo;
            this.Rendered = h.Rendered;
            this.lCont = new list<Content>(h.lCont);
        }
    }

    public class Content {
        public Integer NRecord { get; set; }
        public Integer MaxGG { get; set; }
        public String Tipo { get; set; }
        public String SottoTipo { get; set; }
        public String Owner { get; set; }
    }

    public class PraticheSelectable {
        public boolean isSelected { get; set; }
        public Pratica__c Prat { get; set; }
        public Strategia__c Strat { get; set; }
        public Integer Position { get; set; } // SI Aggiunto per gestire la selezione/deselezione puntuale
    }

    public Integer nr { get; set; }
    public Integer totnr { get; set; }
    public List<String> colonneTabella { get; set; }
    public List<String> colonneLabel { get; set; }

    public TaskSemiAutomatici() {
        isAffido = false;
        PraticheSelezionate = new Map<Id, Boolean>();
        // questa variabile booleana serve per far apparire il messaggio all'utente quando non ci sono task da lavorare
        TaskElab = true;
        MapHeader = new Map<String, Header>();
        lPratiche = new Set<Pratica__c>();

        if (tipiDiAffidi == null) {
            tipiDiAffidi = new set<string>();

            for (Collector_con_Tipo_Affido__c cta : [Select Tipo_Affido__c from Collector_con_Tipo_Affido__c WITH SECURITY_ENFORCED LIMIT 50000]) {
                if (cta.Tipo_Affido__c != null) tipiDiAffidi.add(cta.Tipo_Affido__c.tolowercase());
            }
        }

        colonneTabella = new String[]{
        };
        colonneLabel = new String[]{
        };
        for (Schema.FieldSetMember f : SObjectType.Pratica__c.FieldSets.Filtro_Lavorazione_Task_Tabella.getFields()) {
            colonneTabella.add(f.getFieldPath());
            colonneLabel.add(f.getLabel());
        }

        // Pagination
        InizioL = null;
        Controllo = null;
        TotaleRec = null;
        FineL = null;
        CPage = null;
        RecXPage = 15;
        String Query_Prat_All = null;
        String Query_Prat_Limit = null;
        List_Firt_Rec_X_Page = new List<String>();
        MapSelezione = new Map<String, Boolean>();

        shouldRedirect = false;

        Step = 0;
        Count = 0;
        PraticheEsisti = false;
        pickVisibilityResult = getunSelectedValues(originalValues_PickVisibilityResult);

        // Per gestire la scelta fatta dall'utente
        String TipoContent = null;
        String SottoTipoContent = null;
        String OwnerContent = null;
        String Header_Content = null;
        String TipoH = null;
        String SottoTipoH = null;
        String MHeader = null;
        String TipoCQuery = null;
        String SottoTipoCQuery = null;
        String TipoHQuery = null;
        String SottoTipoHQuery = null;
        String QueryTask = null;

        // SI per gestire la scelta del tipo lettera
        // Il tipo Lettera cambia valori in funzione del tipo di attività proposto unSelectedValues_Tipo_Lettera = getunSelectedValues(originalValues_Tipo_Lettera);
        BLettera = false;

        // Quando mostro le praratiche estratte saranno tutte selezionate
        bAllSel = true;

        //Update Paginazione con Bootstrap 21/02/2017
        //Pierpaolo e Matteo
        filter = new List<String>();
        searchList = new List<String>();
        anPratica = new Pratica__c();
        searchFields = new List<String>();
        picklistValues = new List<SelectOption>();
        vPickValue = '';
        m = new Map<String, Schema.FieldSetMember>();

        picklistValues.add(new SelectOption('none', '--- Select one ---'));

        for (Schema.FieldSetMember f : SObjectType.Pratica__c.FieldSets.Filtro_Lavorazione_Task.getFields()) {
            searchFields.add(f.getFieldPath());
            m.put(f.getFieldPath(), f);

            picklistValues.add(new SelectOption(f.getFieldPath(), f.getLabel()));
        }
        //Fine Update

        // Per il primo caricamento della pagina chiamo la funzione che carica i dati con la Visibilità All_Task, poi sarà l'utente a selezionare i valori della picklis
        RefreshQuery();
    }

    public void RefreshQuery() {
        If (MapHeader.size() > 0)
            MapHeader.clear();
        Profile Profilo = [Select Name from Profile where Id = :userinfo.getProfileid() WITH SECURITY_ENFORCED];
        String ProfileName = Profilo.Name;
        String UserFirstName = userinfo.getFirstName();
        String UserLastName = userinfo.getLastName();
        String NameUser = UserFirstName + ' ' + UserLastName;

        String allfieldsStrategia = CredManUtility.selectallShort('Strategia__c');
        allfieldsStrategia = allfieldsStrategia.replaceAll('lastreferenceddate, ', '');
        list<Strategia__c> ListStrategie = new list<Strategia__c>();
        if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Anzianita_scaduto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'BaseType__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'CAP_Massimo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'CAP_Minimo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Cattivo_Pagatore__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Data_attivazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Data_disattivazione_strategia__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Descrizione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Esito__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Tipologia__c', gd).get('ACCESS')) {
            ListStrategie = database.query('SELECT ' + String.escapeSingleQuotes(allfieldsStrategia) +
                    ' FROM Strategia__c WHERE Recordtype.Name = \'Step\' and Tipologia__c = \'UI\' and Stato_testata__c = \'Attiva\'');
            // SI: ho aggiunto il filtro sulla testata Attiva
            for (Strategia__c Strat : ListStrategie) {
                SetIdStrategie.add(Strat.Id);
            }
        }
        List<AggregateResult> lt = new List<AggregateResult>();
        if (SetIdStrategie.size() > 0)
            lt = taskAgregateResults(SetIdStrategie, OptionPickVisibilityResult, NameUser);
        System.debug('\n lt size: ' + lt.size());
        String concatenazione = '';
        nr = 0;
        totnr = 0;

        if (lt.size() > 0) {

            TaskElab = false;
            for (AggregateResult aggres : lt) {
                Content cont = new Content();
                //cont.Tipo = String.valueOf(aggres.get('ActivityExtended__r.Tipo__c'));
                cont.Tipo = String.valueOf(aggres.get('Tipo'));
                if (cont.Tipo == null || cont.Tipo == '')
                    cont.Tipo = 'NA';
                //cont.SottoTipo = String.valueOf(aggres.get('Sotto_Tipo__c'));
                cont.SottoTipo = String.valueOf(aggres.get('Sottotipo'));
                if (cont.SottoTipo == null || cont.SottoTipo == 'NA')
                    cont.SottoTipo = '';
                cont.MaxGG = Integer.valueOf(aggres.get('GiorniCompletamento'));
                cont.NRecord = Integer.valueOf(aggres.get('Conteggio'));
                cont.Owner = String.valueOf(aggres.get('OwnerContratto'));
                concatenazione = (cont.SottoTipo == '' || cont.SottoTipo == null ? cont.Tipo : cont.Tipo + '_' + cont.SottoTipo);

                if (MapHeader.containsKey(concatenazione)) {
                    Header h = MapHeader.get(concatenazione);
                    h.NRecord = h.NRecord + cont.NRecord;
                    if (cont.MaxGG > h.MaxGG)
                        h.MaxGG = cont.MaxGG;
                    h.lCont.add(cont);
                    MapHeader.put(concatenazione, new Header(h));
                } else {
                    Header h = new Header();
                    h.Tipo = cont.Tipo;
                    h.SottoTipo = cont.SottoTipo;
                    h.MaxGG = Integer.valueOf(aggres.get('GiorniCompletamento'));
                    h.NRecord = Integer.valueOf(aggres.get('Conteggio'));
                    h.lCont = new List<Content>();
                    h.lCont.add(cont);
                    MapHeader.put(concatenazione, new Header(h));
                }
            }
        }
    }

    public String StringaTEST { get; set; }
    public Pagereference VaiATabella() {
        step = 1;
        // SI parametri del link sul content

        TipoContent = (ApexPages.currentPage().getParameters().get('TipoContent') == null) ? ApexPages.currentPage().getParameters().get('TipoContent') : ApexPages.currentPage().getParameters().get('TipoContent').escapeHtml4().toLowerCase();

        SottoTipoContent = (ApexPages.currentPage().getParameters().get('SottoTipoContent') == null) ? ApexPages.currentPage().getParameters().get('SottoTipoContent') : ApexPages.currentPage().getParameters().get('SottoTipoContent').escapeHtml4().toLowerCase();

        OwnerContent = (ApexPages.currentPage().getParameters().get('OwnerContent') == null) ? ApexPages.currentPage().getParameters().get('OwnerContent') : ApexPages.currentPage().getParameters().get('OwnerContent').escapeHtml4().toLowerCase();

        Header_Content = (ApexPages.currentPage().getParameters().get('Header_Content') == null) ? ApexPages.currentPage().getParameters().get('Header_Content') : ApexPages.currentPage().getParameters().get('Header_Content').escapeHtml4().toLowerCase();


        // SI parametri del link sul MapHeader
        TipoH = (ApexPages.currentPage().getParameters().get('TipoHeader') == null) ? ApexPages.currentPage().getParameters().get('TipoHeader') : ApexPages.currentPage().getParameters().get('TipoHeader').escapeHtml4().toLowerCase();

        SottoTipoH = (ApexPages.currentPage().getParameters().get('SottoTipoHeader') == null) ? ApexPages.currentPage().getParameters().get('SottoTipoHeader') : ApexPages.currentPage().getParameters().get('SottoTipoHeader').escapeHtml4().toLowerCase();

        MHeader = (ApexPages.currentPage().getParameters().get('Header') == null) ? ApexPages.currentPage().getParameters().get('Header') : ApexPages.currentPage().getParameters().get('Header').escapeHtml4().toLowerCase();


        String allfieldsTask = CredManUtility.selectallShort('Task');
        allfieldsTask = allfieldsTask.replaceAll('lastreferenceddate, ', '');

        list<Task> ListTaskToView = new list<Task>();
        if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'SLA__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Count_of_Events__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Count_of_Tasks__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_Fuori_SLA__c', gd).get('ACCESS')) {
            QueryTask = 'SELECT ' + String.escapeSinglequotes(allfieldsTask) +
                    ' FROM Task WHERE ActivityExtended__r.id_attivita__c IN: SetIdStrategie AND Status = \'Non Iniziata\' AND';
        }
        // SI Faccio il controllo sul Header Content e MapHeader E quindi usare i parametri del Map Header o del Content

        StringaTEST = 'SottoTipoContent: ' + SottoTipoContent;
        StringaTEST += 'SottoTipoH: ' + SottoTipoH;
        if (tipiDiAffidi.contains(SottoTipoContent)) {
            isAffido = true;
            /*Pagereference page=new PageReference('/apex/newLottizzazione?Type='+SottoTipoContent+'&ownr='+OwnerContent);
            page.setRedirect(true);
            return page;*/
            StringaTEST += ' SottoTipoContent';
        } else if (tipiDiAffidi.contains(SottoTipoH)) {
            isAffido = true;
            /*Pagereference page=new PageReference('/apex/newLottizzazione?Type='+SottoTipoH);
            page.setRedirect(true);
            return page;*/
            StringaTEST += ' SottoTipoH';
        }

        if (Header_Content == 'Content') {
            if (TipoContent != '' && TipoContent != null) {
                TipoCQuery = TipoContent == 'NA' ? '' : TipoContent;
                QueryTask = QueryTask + ' ActivityExtended__r.Tipo__c =: TipoCQuery AND';
            }

            if (SottoTipoContent != '' && SottoTipoContent != null) {
                SottoTipoCQuery = SottoTipoContent == 'NA' ? '' : SottoTipoContent;
                QueryTask = QueryTask + ' ActivityExtended__r.Sotto_Tipo__c =: SottoTipoCQuery AND';
            }

            if (OwnerContent != '' && OwnerContent != null)
                QueryTask = QueryTask + ' ActivityExtended__r.Owner_contratto__c =: OwnerContent';

            if (TipoContent == 'Invio AR' || TipoContent == 'Invio Lettera di Posta Prioritaria Standard') {
                BLettera = true;
                if (TipoContent == 'Invio Lettera di Posta Prioritaria Standard') {
                    leftselected_Tipo_Lettera = 'Invio Lettera di Posta Prioritaria Standard';
                    originalValues_Tipo_Lettera = new List<String>{
                            'Invio Lettera di Posta Prioritaria Standard', 'Invio AR'
                    };
                } else {
                    originalValues_Tipo_Lettera = new List<String>{
                            'Invio AR', 'Invio Lettera di Posta Prioritaria Standard'
                    };
                    leftselected_Tipo_Lettera = 'Invio AR';
                }
                unSelectedValues_Tipo_Lettera = getunSelectedValues(originalValues_Tipo_Lettera);
            }
        } else if (MHeader == 'Header') {
            if (TipoH != '' && TipoH != null) {
                TipoHQuery = TipoH == 'NA' ? '' : TipoH;
                QueryTask = QueryTask + ' ActivityExtended__r.Tipo__c =: TipoHQuery AND';
            }

            if (SottoTipoH != '' && SottoTipoH != null) {
                SottoTipoHQuery = SottoTipoH == 'NA' ? '' : SottoTipoH;
                QueryTask = QueryTask + ' ActivityExtended__r.Sotto_Tipo__c =: SottoTipoHQuery AND';
            }

            if (TipoH == 'Invio AR' || TipoH == 'Invio Lettera di Posta Prioritaria Standard') {
                BLettera = true;
                if (TipoH == 'Invio Lettera di Posta Prioritaria Standard') {
                    originalValues_Tipo_Lettera = new List<String>{
                            'Invio Lettera di Posta Prioritaria Standard', 'Invio AR'
                    };
                    leftselected_Tipo_Lettera = 'Invio Lettera di Posta Prioritaria Standard';
                } else {
                    originalValues_Tipo_Lettera = new List<String>{
                            'Invio AR', 'Invio Lettera di Posta Prioritaria Standard'
                    };
                    leftselected_Tipo_Lettera = 'Invio AR';
                }
                unSelectedValues_Tipo_Lettera = getunSelectedValues(originalValues_Tipo_Lettera);

            }
        }

        if (QueryTask.endsWith(' AND')) {
            QueryTask = QueryTask + ' ActivityExtended__r.id_affidamento__c = null';
            //QueryTask = QueryTask.substring(0, QueryTask.length()-4);
        } else {
            QueryTask = QueryTask + ' AND ActivityExtended__r.id_affidamento__c = null';
        }

        //ListTaskToView = database.query(QueryTask+' limit 100');
        // inizio nuovo codice 13/04 inserimento check permission
        if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'SLA__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Count_of_Events__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Count_of_Tasks__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_Fuori_SLA__c', gd).get('ACCESS')) {
            ListTaskToView = database.query(QueryTask);
            listPraticheSelectable = new list<PraticheSelectable>();
            setIdPratica.clear();
            for (Task Activity : ListTaskToView) {
                SetIdPratica.add(Activity.WhatId);
            }
        }
        // fine nuovo codice 13/04 inserimento check permission
        String allfieldsStrategia = CredManUtility.selectallShort('Strategia__c');
        allfieldsStrategia = allfieldsStrategia.replaceAll('lastreferenceddate, ', '');
        list<Strategia__c> ListStrategieToView = new list<Strategia__c>();
        if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Anzianita_scaduto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'BaseType__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'CAP_Massimo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'CAP_Minimo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Cattivo_Pagatore__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Data_attivazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Data_disattivazione_strategia__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Descrizione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Pratica_di_riferimento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Tipologia__c', gd).get('ACCESS')) {
            ListStrategieToView = database.query('SELECT ' + String.escapeSinglequotes(allfieldsStrategia) +
                    ' FROM Strategia__c WHERE Pratica_di_riferimento__c IN: SetIdPratica');
        }
        MapStrategiaPerIdPrat = new map<Id, Strategia__c>();
        for (Strategia__c Strat : ListStrategieToView) {
            MapStrategiaPerIdPrat.put(Strat.Pratica_di_riferimento__c, Strat);
        }
        ListPraticaToView.clear();
        String allfieldsPratica = CredManUtility.selectallShort('Pratica__c');
        allfieldsPratica = allfieldsPratica.replaceAll('lastreferenceddate, ', '');

        // questa la eseguo una sola volta per caricare i primi record di ciascuna pagina
        if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Anzianit_Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Check_In_Lavorazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Esecuzione_Processo_Mensile__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Blocco__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Chiusura__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Dettaglio_Stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Incasso_Consolidato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Motivo_Blocco__c', gd).get('ACCESS')) {
            Query_Prat_All = 'SELECT ' + String.escapeSinglequotes(allfieldsPratica) + ' ,Servizio_Fornitura__r.LookupContratto__r.Id_Esterno__c, Strategia__r.Nome__c, Servizio_Fornitura__r.RecordType.Name,' +
                    ' Servizio_Fornitura__r.LookupContratto__r.Comune__c,' +
                    ' Servizio_Fornitura__r.Codice__c,' +
                    ' Account__r.Classe_di_Rischio__c,' +
                    ' Account__r.Name' +
                    ' FROM Pratica__c WHERE Stato__c not in (\'Bloccata\',\'Bloccata Manualmente\') And Id IN: SetIdPratica order by Name asc';
        }

        //Chiamo il metodo per la creazione della tabella.
        pagination();
        return null;
    }


    public void Indietro() {
        MapSelezione.clear();

        DaScaduto = null;
        AScaduto = null;
        DaScadutoConsolidato = null;
        AScadutoConsolidato = null;
        DaSaldoSpese = null;
        ASaldoSpese = null;
        DaSaldoConsolidato = null;
        ASaldoConsolidato = null;
        Blettera = false;
        step = 0;
    }

    public Pagereference BackTo() {
        shouldRedirect = true;
        PageReference pg = Page.TaskSemiAutomatici;
        //pg = new PageReference(Page.TaskSemiAutomatici);
        pg.setRedirect(true);
        return pg;
        //url_Parent = '/apex/TaskSemiAutomatici';
    }

    public Pagereference HomePage() {
        pagereference pg;
        pg = new pagereference('/');
        return pg;
    }

    public void FiltroQuery() {
        /*20170303 MSALA Eliminato il vecchio codice*/
    }

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

    // SI 
    public PageReference getleftselected_Tipo_Lettera() {
        return null;
    }

    // SI
    public PageReference SelectAll() {
        for (Pratica__c ot : ListPraticaAll) {
            if (MapSelezione.containsKey(ot.Name) && !bAllSel) {
                MapSelezione.remove(ot.Name);
            } else if (!MapSelezione.containsKey(ot.Name) && bAllSel)
                MapSelezione.put(ot.Name, true);
        }
        for (PraticheSelectable ot : listPraticheSelectable) {
            ot.isSelected = bAllSel;
        }
        return null;
    }

    // SI

    public PageReference HAVEOptionPickVisibilityResult() {
        //MapHeader.clear();
        RefreshQuery();
        Step = 0;
        return null;
    }

    public PageReference AggiornaElementoLista() {
        /*String Elem = ApexPages.currentPage().getParameters().get('Elem');
        String Sel = ApexPages.currentPage().getParameters().get('isSel');
        String Pratica = ApexPages.currentPage().getParameters().get('Codice_Pratica');*/
        String Elem = (ApexPages.currentPage().getParameters().get('Elem') == null) ? ApexPages.currentPage().getParameters().get('Elem') : ApexPages.currentPage().getParameters().get('Elem').escapeHtml4();

        String Sel = (ApexPages.currentPage().getParameters().get('isSel') == null) ? ApexPages.currentPage().getParameters().get('isSel') : ApexPages.currentPage().getParameters().get('isSel').escapeHtml4();

        String Pratica = (ApexPages.currentPage().getParameters().get('Codice_Pratica') == null) ? ApexPages.currentPage().getParameters().get('Codice_Pratica') : ApexPages.currentPage().getParameters().get('Codice_Pratica').escapeHtml4();



        if (MapSelezione.containsKey(Pratica) && Sel == 'true') {
            MapSelezione.remove(Pratica);
        } else if (!MapSelezione.containsKey(Pratica) && Sel == 'false')
            MapSelezione.put(Pratica, true);

        return null;
    }

    public PageReference AffidaLista() {
        Pagereference page = new PageReference('/apex/AffidamentiConfermaLotti?Type=');
        if (SottoTipoContent != '' && SottoTipoContent != null)
            page = new PageReference('/apex/AffidamentiConfermaLotti?Type=' + SottoTipoContent);
        if (SottoTipoH != '' && SottoTipoH != null)
            page = new PageReference('/apex/AffidamentiConfermaLotti?Type=' + SottoTipoH);


        //page.getParameters().put('jsonmap',JSON.serialize(PraticheSelezionate));
        /*Integer jsonCounter = [SELECT COUNT() FROM CRABB_DEV__Log__c WHERE CRABB_DEV__Info__C = '#infojson' LIMIT 1];
        if(jsonCounter == 0){*/
        String jsonmap = JSON.serialize(PraticheSelezionate);
        if (Utils.cebCheckObjPermission('Log__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Integration_Json_file_data__c', gd).get('CREATE')) {
            CRABB_DEV__Log__c newLog = new CRABB_DEV__Log__c(CRABB_DEV__Integration_Json_file_data__c = jsonmap, CRABB_DEV__info__c = '#infojson');
            insert newLog;
            page.getParameters().put('idLog', newLog.Id);
        }
        /*}
        else{
            CRABB_DEV__Log__c jsonRes = [SELECT CRABB_DEV__Info__C FROM CRABB_DEV__Log__c WHERE CRABB_DEV__Info__C = '#infojson' LIMIT 1];
            jsonRes.CRABB_DEV__Integration_Json_file_data__c = page.getParameters().get('jsonmap');
            update jsonRes;
        }*/
        //System.debug('log'+newLog+'log');
        //System.debug(page.getParameters().get('jsonmap'));
        page.setRedirect(true);
        return page;
    }

    public PageReference ConfermaLista() {
        // Uso la mappa MapSelezione per ricavare l'insieme delle pratiche scelte dall'utente.

        String ValMap = String.valueOF(MapSelezione.keySet());
        String ValMap2 = ValMap.replace('}', '\')');
        String ValMap3 = ValMap2.replace('{', '(\'');
        String ValMap4 = ValMap3.replace(',', '\',\'');
        String ValMap5 = ValMap4.replaceAll('\\s', '');
        System.debug('Trim: ' + ValMap5);
        System.debug('Tipologia: ' + TipoCQuery);

        List<Id> lTest = new List<Id>();
        List<Pratica__c> lPratDaElaborare = new List<Pratica__c>();
        for (Pratica__c p : lPratiche) {
            System.debug(p.Id);
            if (PraticheSelezionate.containsKey(p.Id)) {
                System.debug(p.Id);
                if (PraticheSelezionate.get(p.Id)) {
                    System.debug(PraticheSelezionate.get(p.Id));
                    lPratDaElaborare.add(p);
                    lTest.add(p.id);
                }
            }
        }

        //String QueryUPD = 'Select id, Status, ActivityExtended__r.Scelta_utente__c from Task '+QueryTask.substring(QueryTask.indexOf('WHERE',0),QueryTask.length())+' and WhatId IN (Select Id from Pratica__c where Name in '+ValMap5+')';
        if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Scelta_utente__c', gd).get('ACCESS')) {
            //String QueryUPD = 'Select id, Status, ActivityExtended__r.Scelta_utente__c from Task '+QueryTask.substring(QueryTask.indexOf('WHERE',0),QueryTask.length())+' and WhatId IN :lPratiche';
            String QueryUPD = 'Select id, Status, ActivityExtended__r.Scelta_utente__c from Task ' + QueryTask.substring(QueryTask.indexOf('WHERE', 0), QueryTask.length()) + ' and WhatId IN :lPratDaElaborare';

            System.debug('QueryUPD: ' + QueryUPD);
            // inizio nuovo codice 13/04 inserimento check permission
            List<Task> TaskUPD = new List<Task>();
            if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'SLA__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Count_of_Events__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Count_of_Tasks__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Giorni_Fuori_SLA__c', gd).get('ACCESS')) {
                TaskUPD = database.query(QueryUPD);
            }
            // fine nuovo codice 13/04 inserimento check permission    

            System.debug('Lista da aggiornare: ' + TaskUPD);
            System.debug('QueryUPDLunghezza: ' + TaskUPD.size());
            System.debug('Owner' + OwnerContent);
            System.debug('SetIdStrategie' + SetIdStrategie.size());
            Map<Id, ActivityExtended__c> task2obj = Utils.getTaskWithActivityExtended(TaskUPD);
            List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
            if (BLettera) {

                for (Task T : TaskUPD) {

                    T.Status = 'Lavorata';
                    ActivityExtended__c ae = task2obj.get(T.Id);
                    if (ae != null) {
                        ae.Scelta_utente__c = leftselected_Tipo_Lettera;
                        aes.add(ae);
                    }


                }
            } else {
                for (Task T : TaskUPD) {
                    T.Status = 'Lavorata';
                }
            }


            if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Scelta_utente__c', gd).get('UPDATE')) {
                update aes;
            }
            if (Utils.cebCheckObjPermission('Task', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Task', 'Status', gd).get('UPDATE')) {
                update TaskUPD;
            }

            step = 2;
            Count = TaskUPD.size();

        }
        return null;
    }

    public PageReference End() {
        //user clicked end
        system.debug('*****Controllo = ' + Controllo);
        CPage = Controllo + 1;
        system.debug('*****CPage = ' + CPage);
        system.debug('****RecXPage = ' + RecXPage);
        system.debug('****TotaleRec = ' + TotaleRec);
        Integer Pos = (CPage - 1) * RecXPage == TotaleRec ? CPage - 2 : CPage - 1;
        System.debug('VALE: ' + Controllo);
        System.debug('VALE 2: ' + CPage);
        InizioL = CPage == 1 ? 1 : ((Pos) * RecXPage) + 1;
        FineL = CPage == (Controllo + 1) ? TotaleRec : (TotaleRec < RecXPage ? TotaleRec : CPage * RecXPage);
        system.debug('****Query_Prat_AllEnd = ' + Query_Prat_All);
        system.debug('****PosEnd = ' + Pos);
        Query_Prat_Limit = QueryLimitPage(Query_Prat_All, Pos);
        // inizio nuovo codice 13/04/17 inserimento check permission
        if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_inizio_scaduto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_in_Lavorazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Corrente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Scaduto_Corrente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Strategia_Scaduto__c', gd).get('ACCESS')) {
            ListPraticaToView = database.query(Query_Prat_Limit);
            system.debug('****ListPraticaToView = ' + ListPraticaToView);
            aggiorna_Elenco(ListPraticaToView);
        }
        // fine nuovo codice 13/04/17 inserimento check permission
        return null;
    }

    public PageReference Next() {
        //user clicked next button
        CPage = CPage + 1;
        InizioL = CPage == 1 ? 1 : ((CPage - 1) * RecXPage) + 1;
        FineL = CPage == (Controllo + 1) ? TotaleRec : (TotaleRec < RecXPage ? TotaleRec : CPage * RecXPage);
        system.debug('****Query_Prat_AllNext = ' + Query_Prat_All);
        system.debug('****PosNext = ' + CPage);
        Query_Prat_Limit = QueryLimitPage(Query_Prat_All, CPage - 1);
        // inizio nuovo codice 13/04/17 inserimento check permission
        if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_inizio_scaduto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_in_Lavorazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Corrente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Scaduto_Corrente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Strategia_Scaduto__c', gd).get('ACCESS')) {
            ListPraticaToView = database.query(Query_Prat_Limit);
            aggiorna_Elenco(ListPraticaToView);
        }
        // fine nuovo codice 13/04/17 inserimento check permission
        return null;
    }


    public PageReference Beginning() {
        //user clicked beginning
        CPage = 1;
        InizioL = CPage == 1 ? 1 : ((CPage - 1) * RecXPage) + 1;
        FineL = CPage == (Controllo + 1) ? TotaleRec : (TotaleRec < RecXPage ? TotaleRec : CPage * RecXPage);
        Query_Prat_Limit = QueryLimitPage(Query_Prat_All, CPage - 1);
        // inizio nuovo codice 13/04/17 inserimento check permission
        if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_inizio_scaduto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_in_Lavorazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Corrente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Scaduto_Corrente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Strategia_Scaduto__c', gd).get('ACCESS')) {
            ListPraticaToView = database.query(Query_Prat_Limit);
            aggiorna_Elenco(ListPraticaToView);
        }
        // fine nuovo codice 13/04/17 inserimento check permission
        return null;
    }

    public PageReference Previous() {
        //user clicked previous button
        CPage = CPage - 1;
        InizioL = CPage == 1 ? 1 : ((CPage - 1) * RecXPage) + 1;
        FineL = CPage == (Controllo + 1) ? TotaleRec : (TotaleRec < RecXPage ? TotaleRec : CPage * RecXPage);
        Query_Prat_Limit = QueryLimitPage(Query_Prat_All, CPage - 1);
        // inizio nuovo codice 13/04/17 inserimento check permission
        if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_inizio_scaduto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_in_Lavorazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Corrente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Scaduto_Corrente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Strategia_Scaduto__c', gd).get('ACCESS')) {
            ListPraticaToView = database.query(Query_Prat_Limit);
            aggiorna_Elenco(ListPraticaToView);
        }
        // fine nuovo codice 13/04/17 inserimento check permission
        return null;
    }

    public boolean getEnablePrevious() {
        return CPage == 1 ? false : true;
    }

    public boolean getEnableNext() {

        return FineL == TotaleRec ? false : true;
    }

    public String QueryLimitPage(String Query_EXEC, Integer Position) {
        System.debug('Cosa arriva al limit page: ' + Query_EXEC);
        if (Test.isRunningTest()) {
            Position = List_Firt_Rec_X_Page.size();
        }

        String Prova = Query_EXEC.substring(0, Query_EXEC.length() - 18);
        if (List_Firt_Rec_X_Page.size() > 0) {
            Prova += ' and name >= \'' + List_Firt_Rec_X_Page[Position] + '\' order by Name asc limit ' + RecXPage;
        }

        System.debug('La query con il limite è: ' + Prova);
        return Prova;
    }

    public void aggiorna_Elenco(List<Pratica__c> ListToView) {

        listPraticheSelectable.clear();
        system.debug('***ListToView = ' + ListToView.size());
        for (integer i = 0; i < ListToView.size(); i++) {

            PraticheSelectable PraticaSelect = new PraticheSelectable();
            PraticaSelect.isSelected = MapSelezione.containsKey(ListToView[i].Name) ? true : false;
            PraticaSelect.Prat = ListToView[i];
            PraticaSelect.Position = i;

            if (MapStrategiaPerIdPrat.get(ListToView[i].Id) != null) {
                PraticaSelect.Strat = MapStrategiaPerIdPrat.get(ListToView[i].Id);
            }
            listPraticheSelectable.add(PraticaSelect);
        }

        system.debug('***listPraticheSelectable = ' + listPraticheSelectable.size());
        if (listPraticheSelectable.size() > 0) {
            PraticheEsisti = true;
        } else {
            PraticheEsisti = false;
            TotaleRec = 0;
            Controllo = 0;
            CPage = 1;
            InizioL = 0;
            FineL = 0;
        }

    }

    public void pagination() {
        if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_inizio_scaduto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_in_Lavorazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Corrente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Scaduto_Corrente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Strategia_Scaduto__c', gd).get('ACCESS')) {
            ListPraticaAll = database.query(Query_Prat_All);
        }
        /*Msala 20170331 Inizio */
        //ListaPraticheControllo = ListPraticaAll.clone();
        ListaPraticheControlloId = new Set<Id>();
        /*Msala 20170331 Fine */
        NumSelezioni = 0;

        If (ListPraticaAll.size() > 0) {
            /* 20170303 - MSALA INIZIO */
            for (Pratica__c a : ListPraticaAll) {
                if (!PraticheSelezionate.containsKey(a.Id)) {
                    PraticheSelezionate.put(a.Id, true);
                    NumSelezioni += 1;
                    /*Msala 20170331 Inizio */
                    ListaPraticheControlloId.add(a.Id);
                    /*Msala 20170331 Fine */
                }
            }

            for (Id idp : PraticheSelezionate.keyset()) {
                Boolean b = false;
                //NumSelezioni -= 1;
                for (Pratica__c a : ListPraticaAll) {
                    if (idp == a.id) {
                        if (PraticheSelezionate.get(idp)) {
                            b = true;
                            //NumSelezioni += 1;
                        }
                    }

                }
                PraticheSelezionate.put(idp, b);
            }
            /* 20170303 - MSALA FINE */

            System.debug('La lista è questa: ' + ListPraticaAll.size());

            // Suddivido i record estratti in blocchi (ogni blocco è composto da un tanti record in base al valore del parametro RecXPage)

            for (integer i = 0; i < ListPraticaAll.size(); i++) {
                if (i == 0 || (math.mod(i, RecXPage) == 0)) {
                    List_Firt_Rec_X_Page.add(ListPraticaAll[i].Name);
                }
                MapSelezione.put(ListPraticaAll[i].Name, true);
            }

            // Questa verrà eseguita ogni volta per mostrare i dati limitati. Il parametro passato al metodo permette di recuperare il primo record di ogni lista.

            Query_Prat_Limit = QueryLimitPage(Query_Prat_All, 0);
            // inizio nuovo codice 13/04/17 inserimento cebCheckFLSPermission
            if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Data_inizio_scaduto__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Data_in_Lavorazione__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Corrente__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Scaduto_Corrente__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Strategia_Scaduto__c', gd).get('ACCESS')) {
                ListPraticaToView = database.query(Query_Prat_Limit);
            }
            // fine nuovo codice 13/04/17 inserimento cebCheckFLSPermission
            // Pagination

            TotaleRec = ListPraticaAll.size();
            Controllo = TotaleRec / RecXPage;
            CPage = 1;
            InizioL = 1;
            FineL = TotaleRec < RecXPage ? TotaleRec : (CPage * RecXPage);

            // SI Ho modificato il codice con cui popolare la lista per gestire la selezione/deselezione sul singolo record

            If (ListPraticaToView.size() > 0) {
                for (integer i = 0; i < ListPraticaToView.size(); i++) {

                    PraticheSelectable PraticaSelect = new PraticheSelectable();
                    PraticaSelect.isSelected = true;
                    PraticaSelect.Prat = ListPraticaToView[i];
                    PraticaSelect.Position = i;


                    if (MapStrategiaPerIdPrat.get(ListPraticaToView[i].Id) != null) {
                        PraticaSelect.Strat = MapStrategiaPerIdPrat.get(ListPraticaToView[i].Id);
                    }
                    listPraticheSelectable.add(PraticaSelect);
                }
            }
        }

        if (listPraticheSelectable.size() > 0) {
            PraticheEsisti = true;
        } else {
            PraticheEsisti = false;
            TotaleRec = 0;
            Controllo = 0;
            CPage = 1;
            InizioL = 0;
            FineL = 0;
        }

    }

    public List<AggregateResult> taskAgregateResults(set<id> SetIdStr, string OptionPickVisibility, string NU) {
        /*Il processo è, querare i task, dopo di che querare le pratiche, e raccogliere le pratiche lavorabili, e infine fare la query di gourp by */

        List<id> idPraticheTemp = new List<id>();
        List<id> idPratiche = new List<id>();

        //string queryOnTasks = 'Select id, whatid From Task Where id_attivita__c IN: SetIdStr AND  ((Status =\'Non Iniziata\') ) and id_affidamento__c=null limit 15000';
        string queryOnTasks = 'Select id, whatid From Task Where ActivityExtended__r.id_attivita__c IN: SetIdStr AND  ((Status =\'Non Iniziata\') ) and ActivityExtended__r.id_affidamento__c=null limit 15000';
        System.debug('\n QueryOnTasks: ' + queryOnTasks);
        // inizio nuovo codice 13/04 inserimento check permission
        if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'SLA__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Count_of_Events__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Count_of_Tasks__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_Fuori_SLA__c', gd).get('ACCESS')) {
            for (task t : (List<Task>) database.query(queryOnTasks)) {
                idPraticheTemp.add(t.whatID);
            }
        }
        // fine nuovo codice 13/04 inserimento check permission 
        /*** MSALA 20170404 - BKW Issue 17 - INIZIO ***/
        //string queryonPratiche='Select id From Pratica__c'+' Where id in:idPraticheTemp and Stato__c in (\'Bloccata\',\'In Lavorazione\') ';
        string queryonPratiche = 'Select id From Pratica__c' + ' Where id in:idPraticheTemp and Stato__c in (\'Affidata\',\'In Lavorazione\') ';
        /*** MSALA 20170404 - BKW Issue 17 - FINE ***/
        // inizio nuovo codice 14/04 inserimento check permission
        if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_inizio_scaduto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_in_Lavorazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Corrente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Scaduto_Corrente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Strategia_Scaduto__c', gd).get('ACCESS')) {
            for (pratica__c p : (List<pratica__c>) database.query(String.escapeSingleQuotes(queryonPratiche))) {
                idPratiche.add(p.id);
            }
        }
        // fine nuovo codice 14/04 inserimento check permission
        string QueryAggregateResult = '';
        if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c', gd).get('ACCESS')
                && Utils.cebCheckObjPermission('ActvityExtended__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Tipo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Sotto_Tipo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Owner_contratto__c', gd).get('ACCESS')) {
            QueryAggregateResult += 'SELECT Count(Id) Conteggio,MAX(Giorni_di_completamento_attivita__c) GiorniCompletamento ,ActivityExtended__r.Tipo__c Tipo, ActivityExtended__r.Sotto_Tipo__c Sottotipo,';
            QueryAggregateResult += ' ActivityExtended__r.Owner_contratto__c OwnerContratto FROM Task WHERE';
            QueryAggregateResult += ' ActivityExtended__r.id_attivita__c IN: SetIdStr AND whatID in:idPratiche and Status in (\'Non Iniziata\') and ActivityExtended__r.id_affidamento__c=null ';
        }
        if (OptionPickVisibility == 'My_Task') {
            QueryAggregateResult = QueryAggregateResult + ' and ActivityExtended__r.Owner_contratto__c = \'' + NU + '\' ';
            queryOnTasks = ' and ActivityExtended__r.Owner_contratto__c = \'' + NU + '\' ';
        }
        QueryAggregateResult += ' GROUP BY ActivityExtended__r.Tipo__c, ActivityExtended__r.Sotto_Tipo__c, ActivityExtended__r.Owner_contratto__c ORDER By ActivityExtended__r.Tipo__c, ActivityExtended__r.Sotto_Tipo__c,Count(Id) DESC, MAX(ActivityExtended__r.Giorni_Completamento__c) DESC ';

        // inizio nuovo codice 14/04 inserimento check permission
        if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Tipo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Sotto_Tipo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Owner_contratto__c', gd).get('ACCESS')) {
            return database.query(String.escapeSingleQuotes(QueryAggregateResult));
        } else return null;
        // fine nuovo codice 13/04 inserimento check permission
    }


    //Update Paginazione con Bootstrap 21/02/2017
    //Pierpaolo e Matteo
    public void picklistMethod() {
        isString = false;
        isDate = false;
        isObject = false;
        isInteger = false;
        isDouble = false;
        isCheckbox = false;
        isPicklist = false;

        if (vPickValue != 'none') {
            Schema.FieldSetMember p = m.get(vPickValue);
            selField = p.getLabel();

            if (p.getType() == Schema.DisplayType.String) {
                isString = true;
            } else if (p.getType() == Schema.DisplayType.Date) {
                isDate = true;
            } else if (p.getType() == Schema.DisplayType.Integer) {
                isInteger = true;
            } else if (p.getType() == Schema.DisplayType.Double || p.getType() == Schema.DisplayType.Currency) {
                isDouble = true;
            } else if (p.getType() == Schema.DisplayType.Boolean) {
                isCheckbox = true;
            } else if (p.getType() == Schema.DisplayType.Picklist) {
                isPicklist = true;
                getPicklistInput();
            } else if (p.getType() == Schema.DisplayType.Reference) {
                isObject = true;
                //oInput = m.get(p.getFieldPath());
            }
        }
    }

    public void getPicklistInput() {
        pkInputList = new List<SelectOption>();
        //pkInputList.add(new SelectOption('none', '--- Select one ---'));

        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Pratica__c');
        if (targetType == null) {
            targetType = Schema.getGlobalDescribe().get('BALANCE_CRABB__Pratica__c');
            if (targetType == null) {
                targetType = Schema.getGlobalDescribe().get('CRABB_DEV__Pratica__c');
            }
        }

        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(m.get(vPickValue).getFieldPath()).getDescribe().getPickListValues();

        //Schema.DescribeFieldResult fieldResult = m.get(vPickValue).getFieldPath().getDescribe();
        //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f : pick_list_values) {
            pkInputList.add(new SelectOption(f.getLabel(), f.getValue()));
        }
    }

    public void setFilter() {
        String filtro = '';
        String search = '';
        /*if(isString == true){
            filtro = m.get(vPickValue).getFieldPath() + ' = \'' + sInput + '\'';
            search =  m.get(vPickValue).getLabel() + ' = ' + sInput;
            sInput = null;
        }*/
        // Inizio nuovo codice 4/4/17
        if (isString == true) {
            if (sInput.containsIgnoreCase('%')) {
                search = m.get(vPickValue).getLabel() + ' LIKE ' + sInput;
                filtro = m.get(vPickValue).getFieldPath() + ' LIKE \'' + sInput + '\'';
            } else {
                search = m.get(vPickValue).getLabel() + ' = ' + sInput;
                filtro = m.get(vPickValue).getFieldPath() + ' = \'' + sInput + '\'';
            }
            sInput = null;
        }  // Fine nuovo codice 4/4/17

        else if (isDate == true) {
            //Inizio nuovo codice 4/4/17
            String newdis;
            String newdif;

            if (dInputStart != null) {
                Date dis = Date.valueOf(dInputStart);
                String meseS = string.valueOf(dis.month());
                if (meseS.length() == 1) {
                    meseS = '0' + meseS;
                }
                String giornoS = string.valueOf(dis.day());
                if (giornoS.length() == 1) {
                    giornoS = '0' + giornoS;
                }
                newdis = dis.year() + '-' + meseS + '-' + giornoS;
            }

            if (dInputFinish != null) {
                Date dif = Date.valueOf(dInputFinish);
                String meseF = string.valueOf(dif.month());
                if (meseF.length() == 1) {
                    meseF = '0' + meseF;
                }
                String giornoF = string.valueOf(dif.day());

                if (giornoF.length() == 1) {
                    giornoF = '0' + giornoF;
                }
                newdif = dif.year() + '-' + meseF + '-' + giornoF;
            }

            if (dInputStart != null && dInputFinish != null) {
                filtro = m.get(vPickValue).getFieldPath() + ' >= ' + newdis + ' AND ' + m.get(vPickValue).getFieldPath() + ' < ' + newdif;
                search = m.get(vPickValue).getLabel() + ' >= ' + newdis + ' AND ' + m.get(vPickValue).getLabel() + ' < ' + newdif;
            } else if (dInputStart != null) {
                filtro = m.get(vPickValue).getFieldPath() + ' >= ' + newdis;
                search = m.get(vPickValue).getLabel() + ' >= ' + newdis;

            } else if (dInputFinish != null) {
                filtro = m.get(vPickValue).getFieldPath() + ' < ' + newdif;
                search = m.get(vPickValue).getLabel() + ' < ' + newdif;
            }

            dInputStart = null;
            dInputFinish = null;
        }
        // Fine nuovo codice 4/4/17

        else if (isObject == true) {
            filtro = m.get(vPickValue).getFieldPath() + ' = \'' + anPratica.get(m.get(vPickValue).getFieldPath()) + '\'';
            search = m.get(vPickValue).getLabel() + ' = ' + anPratica.get(m.get(vPickValue).getFieldPath());

            //oInput = null;
            anPratica = new Pratica__c();

            //ppp = m.get(vPickValue).getFieldPath() + ' = ' + anPratica.get(m.get(vPickValue).getFieldPath());
        }

        else if (isInteger == true) {
            filtro = m.get(vPickValue).getFieldPath() + ' >= ' + iInputStart + ' AND ' + m.get(vPickValue).getFieldPath() + ' < ' + iInputFinish;
            search = m.get(vPickValue).getLabel() + ' >= ' + iInputStart + ' AND ' + m.get(vPickValue).getLabel() + ' < ' + iInputFinish;
        }

        else if (isDouble == true) {
            filtro = m.get(vPickValue).getFieldPath() + ' >= ' + ndInputStart + ' AND ' + m.get(vPickValue).getFieldPath() + ' < ' + ndInputFinish;
            search = m.get(vPickValue).getLabel() + ' >= ' + ndInputStart + ' AND ' + m.get(vPickValue).getLabel() + ' < ' + ndInputFinish;
        }

        else if (isCheckbox == true) {
            filtro = m.get(vPickValue).getFieldPath() + ' = ' + cInput;
            search = m.get(vPickValue).getLabel() + ' = ' + cInput;
        } else if (isPicklist == true) {
            if (pInput != 'none') {
                pInput = pInput.remove('[');
                pInput = pInput.remove(']');

                search = m.get(vPickValue).getLabel() + ' in (' + pInput + ')';

                pInput = pInput.replace(',', '\',\'');

                filtro = m.get(vPickValue).getFieldPath() + ' in (\'' + pInput + '\')';

                pInput = null;
            }
        }

        filter.add(filtro);
        searchList.add(search);
    }

    public PageReference deleteFilter() {
        for (Integer j = 0; j < searchList.size(); j++) {
            if (searchList.get(j) == String.valueOf(delF)) {
                searchList.remove(j);
                filter.remove(j);
            }

        }

        return null;
    }

    public PageReference clearFilter() {
        searchList.clear();
        filter.clear();

        return null;
    }

    public pageReference refresh() {
        setCon = null;
        whereClause = null;

        for (Integer i = 0; i < filter.size(); i++) {
            whereClause += filter.get(i) + ' AND ';
        }

        if (whereClause != null) {
            if (whereClause.startsWith('null')) {
                whereClause = whereClause.replaceFirst('null', '');
            }
            if (whereClause.endsWith('AND ')) {
                whereClause = whereClause.substring(0, whereClause.length() - 4);
            }
        }

        //lPratiche = getPratica();
        lPratiche.addAll(getPratica());

        if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Id', gd).get('ACCESS')) {
            String queryFiltro = '';
            if (whereClause == null) {
                /*Msala 20170331 Inizio */
                //queryFiltro = 'Select Id from Pratica__c WHERE Id in :ListaPraticheControllo order by Name';
                queryFiltro = 'Select Id from Pratica__c WHERE Id in :ListaPraticheControlloId order by Name';
                /*Msala 20170331 Fine */
            } else {
                /*Msala 20170331 Inizio */
                //queryFiltro = 'Select Id from Pratica__c WHERE Id in :ListaPraticheControllo AND ' + whereClause + ' order by Name';
                queryFiltro = 'Select Id from Pratica__c WHERE Id in :ListaPraticheControlloId AND ' + whereClause + ' order by Name';
                /*Msala 20170331 Fine */
            }
            // inizio nuovo codice 12/04 inserimento check permission
            if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Data_inizio_scaduto__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Data_in_Lavorazione__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Corrente__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Scaduto_Corrente__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Strategia_Scaduto__c', gd).get('ACCESS')) {
                /*List<Pratica__c>*/ lPratFiltro = Database.Query(String.escapeSingleQuotes(queryFiltro));
                NumSelezioni = 0;

                for (Id idp : PraticheSelezionate.keyset()) {
                    Boolean b = false;
                    for (Pratica__c a : lPratFiltro) {
                        if (idp == a.id) {
                            if (PraticheSelezionate.get(idp)) {
                                b = true;
                                NumSelezioni += 1;
                            }
                        }
                    }
                    PraticheSelezionate.put(idp, b);
                }
                //System.debug('***'+PraticheSelezionate.size()+'***');
            }
            // fine nuovo codice 12/04 inserimento check permission
        }
        setCon.setPageNumber(1);
        return null;
    }

    public List<Pratica__c> getPratica() {
        List<Pratica__c> prtList = new List<Pratica__c>();
        Integer i = 1;

        for (Pratica__c a : (List<Pratica__c>) setCon.getRecords()) {
            prtList.add(a);
            lPratiche.add(a);
        }
        return prtList;
    }

    public Set<Pratica__c> lPratiche { get; set; }
    /*Msala 20170331 Inizio */
    //public List<Pratica__c> ListaPraticheControllo {get;set;}
    public Set<Id> ListaPraticheControlloId { get; set; }
    /*Msala 20170331 Fine */
    public Map<Id, Boolean> PraticheSelezionate { get; set; }
    Public boolean bool { get; set; }

    public ApexPages.StandardSetController setCon {
        get {
            string selectFields = '';
            string queryString = '';

            if (setCon == null) {
                size = 20;
                for (Integer i = 0; i < searchFields.size(); i++) {
                    // Inizio nuovo codice 7/4/17
                    if (searchFields.get(i).equalsIgnoreCase('Name')) continue;
                    // Fine nuovo codice 7/4/17
                    if (i == searchFields.size() - 1)
                        selectFields += searchFields.get(i);
                    else
                            selectFields += searchFields.get(i) + ',';
                }
                // Inizio nuovo codice 7/4/17
                selectFields = selectFields.removeEndIgnoreCase(',');
                // Fine nuovo codice 7/4/17
                if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Pratica__c', 'Data_inizio_scaduto__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Pratica__c', 'Data_in_Lavorazione__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Corrente__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Pratica__c', 'Scaduto_Corrente__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Pratica__c', 'Strategia_Scaduto__c', gd).get('ACCESS')) {
                    if (whereClause == null) {
                        queryString = 'Select Name, ' + selectFields +
                                ',Servizio_Fornitura__r.LookupContratto__r.Id_Esterno__c, Strategia__r.Nome__c, Servizio_Fornitura__r.RecordType.Name,' +
                                ' Servizio_Fornitura__r.LookupContratto__r.Comune__c,' +
                                ' Servizio_Fornitura__r.Codice__c,' +
                                ' Account__r.Classe_di_Rischio__c,' +
                                ' Account__r.Name' +
                                /*Msala 20170331 Inizio */
                                //' from Pratica__c WHERE Id in :ListaPraticheControllo order by Name';
                                ' from Pratica__c WHERE Id in :ListaPraticheControlloId order by Name';
                        /*Msala 20170331 Fine */
                    } else {
                        queryString = 'Select Name, ' + selectFields +
                                ',Servizio_Fornitura__r.LookupContratto__r.Id_Esterno__c, Strategia__r.Nome__c, Servizio_Fornitura__r.RecordType.Name,' +
                                ' Servizio_Fornitura__r.LookupContratto__r.Comune__c,' +
                                ' Servizio_Fornitura__r.Codice__c,' +
                                ' Account__r.Classe_di_Rischio__c,' +
                                ' Account__r.Name' +
                                /*Msala 20170331 Inizio */
                                //' from Pratica__c WHERE Id in :ListaPraticheControllo AND ' + whereClause + ' order by Name';
                                ' from Pratica__c WHERE Id in :ListaPraticheControlloId AND ' + whereClause + ' order by Name';
                        /*Msala 20170331 Fine */

                    }
                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                    setCon.setPageSize(size);
                }
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }
        set;
    }

    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('10', '10'));
        options.add(new SelectOption('30', '30'));
        options.add(new SelectOption('50', '50'));
        return options;
    }

    public Integer getNumber() {
        return n;
    }

    public void setNumber(Integer n) {
        this.n = n;
    }

    public pageReference test() {
        setCon = null;
        lPratiche.addAll(getPratica());
        setCon.setPageSize(getNumber());
        return null;
    }

    public Integer NumSelezioni { get; set; }

    public void AggiornaSelezione() {
        NumSelezioni = 0;
        for (Id p : PraticheSelezionate.keySet()) {
            if (PraticheSelezionate.get(p)) {
                NumSelezioni += 1;
            }
        }
    }

    public void SelezionaTutto() {
        if (whereclause == null) {
            NumSelezioni = PraticheSelezionate.size();
        } else {
            NumSelezioni = lPratFiltro.size();
        }

        for (Id p : PraticheSelezionate.keySet()) {
            if (lPratFiltro != null) {
                PraticheSelezionate.put(p, false);
                for (Pratica__c pf : lPratFiltro) {
                    if (p == pf.Id) {
                        PraticheSelezionate.put(p, true);
                    }
                }
            } else {
                PraticheSelezionate.put(p, true);
            }
        }
    }

    public void DeSelezionaTutto() {
        NumSelezioni = 0;
        for (Id p : PraticheSelezionate.keySet()) {
            PraticheSelezionate.put(p, false);
        }
    }
}