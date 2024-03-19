/* ---------------------------------------------------------------------------------------------------------------------
Name:            TaskSemiAutomaticiCTRL.cls
Description:
Test class:      TestTaskSemiAutomaticiCTRL.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
16-Jun-2022  0.2      E.Sino               Aggiunto il with sharing come richiesta da Salesforce.com per soddisfare le specifiche
                                           del Security Review.
16-Sep-2022  0.3      C.Sanna & R.Kurti    Added WITH SECURITY ENFORCED and cebCheckObjPermission (security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class TaskSemiAutomaticiCTRL {
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public String OptionPickVisibilityResult { get; set; }
    public lotto__c lforFiltro { get; set; }//é utilizzato per i filtri sulla pagina
    set<Id> SetIdStrategie = new set<Id>();//Contiene gli id delle strategie attive
    public Set<string> tipiDiAffidi { get; set; } //Contiene i diversi tipi di affido
    public Map<String, Header> MapHeader { get; set; }
    public string debugstring { get; set; }
    public integer step { get; set; }
    List<id> idPratiche = new List<id>();
    public List<SelectOption> pickVisibilityResult {
        get {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('All_Task', 'All_Task'));
            options.add(new SelectOption('My_Task', 'My_Task'));
            return options;
        }
    }
    public set<String> SetIdContr { get; set; }
    public List<String> originalValues_IdContratto {
        get {
            if (originalValues_IdContratto != null && originalValues_IdContratto.size() > 0) return originalValues_IdContratto;
            originalValues_IdContratto = new List<String>();
            Set<string> codiceContratto = new set<String>();
            if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Servizio_Fornitura__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Servizio_Fornitura__c', 'LookupContratto__c', gd).get('ACCESS')
                    && Utils.cebCheckObjPermission('Contratto__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Contratto__c', 'Id_Esterno__c', gd).get('ACCESS')) {
                for (Pratica__c st : ([
                        SELECT Servizio_Fornitura__r.LookupContratto__r.Id_Esterno__c
                        FROM Pratica__c
                        WHERE Id = :idPratiche and (NOT (stato__c = 'Bloccata' and is_Blocco_PDR__c = false))
                        and account__r.White_List__c = false
                        //WITH SECURITY_ENFORCED
                ])) {
                    codiceContratto.add(st.Servizio_Fornitura__r.LookupContratto__r.Id_Esterno__c);
                }
            } originalValues_IdContratto.addAll(codiceContratto);
            return originalValues_IdContratto;
        }
        set;
    }
    //Comuni
    public List<String> rightValues_Comune { get; set; }
    public set<String> SetComune { get; set; }
    public List<String> originalValues_Comune {
        get {
            if (originalValues_Comune == null) {
                if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                        && Utils.cebCheckObjPermission('Contratto__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Pratica__c', 'Servizio_Fornitura__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Servizio_Fornitura__c', 'LookupContratto__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Contratto__c', 'Comune__c', gd).get('ACCESS')) {
                    List<Pratica__c> ListaPrat = new List<Pratica__c>([
                            SELECT Id, Servizio_Fornitura__r.LookupContratto__r.Comune__c
                            FROM Pratica__c
                            WHERE Id = :idPratiche
                            //WITH SECURITY_ENFORCED
                    ]);

                    originalValues_Comune = new List<String>();
                    Set<string> SetComune = new set<String>();
                    for (Pratica__c st : ListaPrat) SetComune.add(st.Servizio_Fornitura__r.LookupContratto__r.Comune__c);
                    originalValues_Comune.addAll(SetComune);
                }
            }

            return originalValues_Comune;
        }
        set;
    }
    //Codice Servizio
    public List<String> rightValues_CodiceServizio { get; set; }
    public set<String> SetCodServ { get; set; }
    public List<String> originalValues_CodiceServizio {
        get {
            if (originalValues_CodiceServizio == null) {
                if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Pratica__c', 'Servizio_Fornitura__c', gd).get('ACCESS')) {
                    List<Pratica__c> ListaPrat = new List<Pratica__c>([
                            SELECT Id, Servizio_Fornitura__r.RecordType.Name
                            FROM Pratica__c
                            WHERE Id = :idPratiche
                            //WITH SECURITY_ENFORCED
                    ]);
                    originalValues_CodiceServizio = new List<String>();
                    Set<string> SetCodServ = new set<String>();
                    for (Pratica__c st : ListaPrat) SetCodServ.add(st.Servizio_Fornitura__r.RecordType.Name);
                    originalValues_CodiceServizio.addAll(SetCodServ);
                }
            }
            return originalValues_CodiceServizio;
        }
        set;
    }
    //Stato
    public List<String> rightValues_Stato { get; set; }
    public set<String> SetStato { get; set; }
    Public List<String> originalValues_Stato {
        get {
            if (originalValues_Stato == null) {
                if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c', gd).get('ACCESS')) {
                    List<Pratica__c> ListaPrat = new List<Pratica__c>([
                            SELECT Id, Stato__c
                            FROM Pratica__c
                            WHERE Id = :idPratiche
                            //WITH SECURITY_ENFORCED
                    ]);
                    originalValues_Stato = new List<String>();
                    Set<string> SetStato = new set<String>();
                    for (Pratica__c st : ListaPrat) SetStato.add(st.Stato__c);
                    originalValues_Stato.addAll(SetStato);
                }
            }
            return originalValues_Stato;
        }
        set;
    }
    //Classe di rischio
    public List<String> rightValues_ClasseDiRischio { get; set; }
    public set<String> SetRischio { get; set; }
    Public List<String> originalValues_ClasseDiRischio {
        get {
            if (originalValues_ClasseDiRischio == null) {
                if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Pratica__c', 'Account__c', gd).get('ACCESS')
                        && Utils.cebCheckObjPermission('Account', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Account', 'Classe_di_Rischio__c', gd).get('ACCESS')) {
                    List<Pratica__c> ListaPrat = new List<Pratica__c>([
                            SELECT Id, Account__r.Classe_di_Rischio__c
                            FROM Pratica__c
                            WHERE Id = :idPratiche
                            //WITH SECURITY_ENFORCED
                    ]);
                    originalValues_ClasseDiRischio = new List<String>();
                    SetRischio = new set<String>();
                    for (Pratica__c st : ListaPrat) SetRischio.add(st.Account__r.Classe_di_Rischio__c);
                    originalValues_ClasseDiRischio.addAll(SetRischio);
                }
            }
            return originalValues_ClasseDiRischio;
        }
        set;
    }
    public TaskSemiAutomaticiCTRL() {
        idPratiche = new List<id>();
        Map<String, Header> MapHeader = new Map<String, Header>();
        lforFiltro = new lotto__c();
        step = 0;
        RefreshQuery();
    }

    public PageReference HAVEOptionPickVisibilityResult() {
        RefreshQuery();
        return null;
    }
    public void RefreshQuery() {
        debugstring += '*** RefreshQuery  </br>' ;
        if (MapHeader == null) MapHeader = new Map<String, Header>();
        If (MapHeader.size() > 0) MapHeader.clear();

        debugstring += '*** retrieveStrategie  </br>' ;
        retrieveStrategie();
        debugstring += '*** taskAgregateResults enter </br>' ;
        List<AggregateResult> lt = taskAgregateResults();

        //da CAPIRE
        String concatenazione = '';
        integer nr = 0;
        integer totnr = 0;
        if (lt.size() == 0) return;
        for (AggregateResult aggres : lt) {
            Content cont = new Content();
            cont.Tipo = String.valueOf(aggres.get('Tipo__c'));

            if (cont.Tipo == null || cont.Tipo == '') cont.Tipo = 'NA';
            cont.SottoTipo = String.valueOf(aggres.get('Sotto_Tipo__c'));

            if (cont.SottoTipo == null || cont.SottoTipo == 'NA') cont.SottoTipo = '';

            cont.MaxGG = Integer.valueOf(aggres.get('GiorniCompletamento'));
            cont.NRecord = Integer.valueOf(aggres.get('Conteggio'));
            cont.Owner = String.valueOf(aggres.get('OwnerContratto'));
            debugstring += '*** UserInfo:' + UserInfo.getName() + '</br>' ;
            debugstring += '*** OwnerContratto:' + cont.Owner + '</br>' ;
            concatenazione = (cont.SottoTipo == '' || cont.SottoTipo == null ? cont.Tipo : cont.Tipo + '_' + cont.SottoTipo);

            if (MapHeader.containsKey(concatenazione)) {
                Header h = MapHeader.get(concatenazione);
                h.NRecord = h.NRecord + cont.NRecord;
                if (cont.MaxGG > h.MaxGG)
                    h.MaxGG = cont.MaxGG;
                h.lCont.add(cont);
                MapHeader.put(concatenazione, h);
            } else {
                Header h = new Header();
                h.Tipo = cont.Tipo;
                h.SottoTipo = cont.SottoTipo;
                h.MaxGG = Integer.valueOf(aggres.get('GiorniCompletamento'));
                h.NRecord = Integer.valueOf(aggres.get('Conteggio'));
                h.lCont = new List<Content>();
                h.lCont.add(cont);
                MapHeader.put(concatenazione, h);
            }
        }
    }
    public void retrieveStrategie() {
        if (SetIdStrategie != null && SetIdStrategie.size() > 0) return;

        String allfieldsStrategia = Utils.getSOBJECTFieldsForQuery('Strategia__c');
        if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'RC_Api_field_name__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'BaseType__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'CAP_Massimo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'CAP_Minimo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Cattivo_Pagatore__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'RC_Condition__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Data_attivazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Scaduto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Scelta_utente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Stato__c', gd).get('ACCESS')) {
            list<Strategia__c> ListStrategie = database.query('SELECT ' + String.escapeSingleQuotes(allfieldsStrategia) +
                    ' FROM Strategia__c WHERE Recordtype.Name = \'Step\' and Tipologia__c =\'UI\' and Stato_testata__c = \'Attiva\'');

            for (Strategia__c Strat : ListStrategie) {
                SetIdStrategie.add(Strat.Id);
            }
        }
    }

    public List<AggregateResult> taskAgregateResults() {
        debugstring += '*** taskAgregateResults entered  </br>' ;

        /*Il processo è, querare i task, dopo di che querare le pratiche, e raccogliere le pratiche lavorabili, e infine fare la query di gourp by */
        List<id> idPraticheTemp = new List<id>();
        idPratiche = new List<id>();

        //string queryOnTasks = 'Select id, whatid From Task Where id_attivita__c IN: SetIdStrategie AND  ((Status =\'Non Iniziata\') ) and id_affidamento__c=null limit 15000';
        string queryOnTasks = 'Select id, whatid From Task Where ActivityExtended__r.id_attivita__c IN: SetIdStrategie AND  ((Status =\'Non Iniziata\') ) and ActivityExtended__r.id_affidamento__c=null limit 100';
        // inizio nuovo codice 14/04/17 inserimento check permission
        if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Count_of_Events__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Count_of_Tasks__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Durata_Effettiva__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_Fuori_SLA__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'SLA__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Tipo_esecuzione__c', gd).get('ACCESS')) {
            for (task t : (List<Task>) database.query(queryOnTasks)) {
                idPraticheTemp.add(t.whatID);
            }
        }
        // fine nuovo codice 14/04/17 inserimento check permission
        debugstring += '*** idPraticheTemp:' + idPraticheTemp.size() + '</br>' ;
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
            for (pratica__c p : (List<pratica__c>) database.query(queryonPratiche)) {
                idPratiche.add(p.id);
            }
        }
        // fine nuovo codice 14/04 inserimento check permission
        debugstring += '*** idPratiche:' + idPratiche.size() + '</br>' ;
        String QueryAggregateResult = '';
        if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c', gd).get('ACCESS')
                && Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Tipo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Sotto_Tipo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Owner_contratto__c', gd).get('ACCESS')) {
            QueryAggregateResult += 'SELECT Count(Id) Conteggio,MAX(Giorni_di_completamento_attivita__c) GiorniCompletamento ,ActivityExtended__r.Tipo__c, ActivityExtended__r.Sotto_Tipo__c,';
            QueryAggregateResult += ' ActivityExtended__r.Owner_contratto__c OwnerContratto FROM Task WHERE';
            /*** MSALA 20170404 - BKW Issue 17 - INIZIO ***/
            //QueryAggregateResult+=' id_attivita__c IN: SetIdStrategie AND whatID in:idPratiche and Status in (\'Non Iniziata\') and id_affidamento__c=null ';
            QueryAggregateResult += ' ActivityExtended__r.id_attivita__c IN: SetIdStrategie AND whatID in:idPratiche and Status in (\'Non Iniziata\') ';
            /*** MSALA 20170404 - BKW Issue 17 - FINE ***/
        }
        if (OptionPickVisibilityResult == 'My_Task') {
            String NomeUtente = String.escapeSingleQuotes(UserInfo.getName());
            QueryAggregateResult = QueryAggregateResult + ' and ActivityExtended__r.Owner_contratto__c = \'' + NomeUtente + '\' ';
            queryOnTasks = ' and ActivityExtended__r.Owner_contratto__c = \'' + NomeUtente + '\' ';
        }

        QueryAggregateResult += ' GROUP BY ActivityExtended__r.Tipo__c, ActivityExtended__r.Sotto_Tipo__c, ActivityExtended__r.Owner_contratto__c ORDER By ActivityExtended__r.Tipo__c, ActivityExtended__r.Sotto_Tipo__c,Count(Id) DESC, MAX(Giorni_di_completamento_attivita__c) DESC ';
        debugstring += '</br>' + '###### idPraticheTemp:' + QueryAggregateResult + '</br>' ;
        // inizio nuovo codice 14/04/17 inserimento check permission
        if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Count_of_Events__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Count_of_Tasks__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Durata_Effettiva__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_Fuori_SLA__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'SLA__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Tipo_esecuzione__c', gd).get('ACCESS')) {
            System.debug('@@ ' + QueryAggregateResult);
            return database.query(QueryAggregateResult);
        } else return null;
        // fine nuovo codice 14/04/17 inserimento check permission
    }

    public pageReference VaiAFiltri() {
        //Content
        /*string TipoContent = ApexPages.currentPage().getParameters().get('TipoContent');
        string SottoTipoContent = ApexPages.currentPage().getParameters().get('SottoTipoContent');
        string OwnerContent = ApexPages.currentPage().getParameters().get('OwnerContent');
        string Header_Content = ApexPages.currentPage().getParameters().get('Header_Content');*/
        String TipoContent = (ApexPages.currentPage().getParameters().get('TipoContent') == null) ? ApexPages.currentPage().getParameters().get('TipoContent') : ApexPages.currentPage().getParameters().get('TipoContent').escapeHtml4().toLowerCase();

        String SottoTipoContent = (ApexPages.currentPage().getParameters().get('SottoTipoContent') == null) ? ApexPages.currentPage().getParameters().get('SottoTipoContent') : ApexPages.currentPage().getParameters().get('SottoTipoContent').escapeHtml4().toLowerCase();

        String OwnerContent = (ApexPages.currentPage().getParameters().get('OwnerContent') == null) ? ApexPages.currentPage().getParameters().get('OwnerContent') : ApexPages.currentPage().getParameters().get('OwnerContent').escapeHtml4().toLowerCase();

        String Header_Content = (ApexPages.currentPage().getParameters().get('Header_Content') == null) ? ApexPages.currentPage().getParameters().get('Header_Content') : ApexPages.currentPage().getParameters().get('Header_Content').escapeHtml4().toLowerCase();
        //Header
        /*string TipoH = ApexPages.currentPage().getParameters().get('TipoHeader');
        string SottoTipoH = ApexPages.currentPage().getParameters().get('SottoTipoHeader');
        string MHeader = ApexPages.currentPage().getParameters().get('Header');*/
        String TipoH = (ApexPages.currentPage().getParameters().get('TipoHeader') == null) ? ApexPages.currentPage().getParameters().get('TipoHeader') : ApexPages.currentPage().getParameters().get('TipoHeader').escapeHtml4().toLowerCase();

        String SottoTipoH = (ApexPages.currentPage().getParameters().get('SottoTipoHeader') == null) ? ApexPages.currentPage().getParameters().get('SottoTipoHeader') : ApexPages.currentPage().getParameters().get('SottoTipoHeader').escapeHtml4().toLowerCase();

        String MHeader = (ApexPages.currentPage().getParameters().get('Header') == null) ? ApexPages.currentPage().getParameters().get('Header') : ApexPages.currentPage().getParameters().get('Header').escapeHtml4().toLowerCase();

        setTipiAffido();

        if (TipoContent != null) TipoContent = TipoContent.tolowercase();
        if (SottoTipoContent != null) SottoTipoContent = SottoTipoContent.tolowercase();
        if (OwnerContent != null) OwnerContent = OwnerContent.tolowercase();
        if (Header_Content != null) Header_Content = Header_Content.tolowercase();

        if (tipiDiAffidi.contains(SottoTipoContent)) {
            Pagereference page = new PageReference('/apex/newLottizzazione?Type=' + SottoTipoContent + '&ownr=' + OwnerContent);
            page.setRedirect(true);
            return page;
        } else if (tipiDiAffidi.contains(SottoTipoH)) {
            Pagereference page = new PageReference('/apex/newLottizzazione?Type=' + SottoTipoH);
            page.setRedirect(true);
            return page;
        }
        step = 1;
        return Page.TaskSemiautomatici14_1;
    }
    //imposta i tipi di affidi
    public void setTipiAffido() {
        if (tipiDiAffidi == null && Utils.cebCheckObjPermission('Collector_con_Tipo_Affido__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Collector_con_Tipo_Affido__c', 'Tipo_Affido__c', gd).get('ACCESS')) {
            tipiDiAffidi = new set<string>();
            for (Collector_con_Tipo_Affido__c cta : [
                    Select Tipo_Affido__c
                    from Collector_con_Tipo_Affido__c
                    //WITH SECURITY_ENFORCED
                    LIMIT 50000
            ]) {
                if (cta.Tipo_Affido__c != null) tipiDiAffidi.add(cta.Tipo_Affido__c.tolowercase());
            }
        }
    }

    public pageReference ProseguiFiltri() {
        //queryAllRecordS();
        //executeQueryWithFilters();
        return Page.AffidamentiViewData;
    }

    public class Header {
        public Integer NRecord { get; set; }
        public Integer MaxGG { get; set; }
        public String Tipo { get; set; }
        public String SottoTipo { get; set; }
        public Boolean Rendered { get; set; }
        Public list<Content> lCont { get; set; }

        public Header() {
        }
    }
    public class Content {
        public Integer NRecord { get; set; }
        public Integer MaxGG { get; set; }
        public String Tipo { get; set; }
        public String SottoTipo { get; set; }
        public String Owner { get; set; }
        Public Content() {
        }
    }
}