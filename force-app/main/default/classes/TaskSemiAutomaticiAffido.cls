/* ---------------------------------------------------------------------------------------------------------------------
Name:            TaskSemiAutomaticiAffido.cls
Description:
Test class:      TestSemiAutomaticiAffido.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
26-Oct-2015  0.1      E.Sino                          First Version

14-Sep-2022  0.2      R. Kurti & C. Sanna             Modified for adding check permission:
                                                      cebCheckFLSPermission/cebCheckObjPermission/WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class TaskSemiAutomaticiAffido {
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public Map<String, Header> MapHeader { get; set; }
    public Set<string> tipiDiAffidi { get; set; }
    public integer Step { get; set; }
    set<Id> SetIdStrategie = new set<Id>();
    public list <PraticheSelectable> listPraticheSelectable { get; set; }
    Public Integer Count { get; set; }

    public List<SelectOption> pickVisibilityResult { get; set; }
    public String OptionPickVisibilityResult { get; set; }
    public boolean TaskElab { get; set; }// questa variabile booleana serve per far apparire il messaggio all'utente quando non ci sono task da lavorare

    public List<String> originalValues_PickVisibilityResult = new List<String>{
            'All_Task', 'My_Task'
    };
    public Map<Id, Strategia__c> MapStrategiaPerIdPrat;
    Set<Id> SetIdPratica = new set<Id>();
    List<Pratica__c> ListPraticaToView = new list<Pratica__c>();
    List<Pratica__c> ListPraticaAll = new list<Pratica__c>();
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
    Public List<String> originalValues_IdContratto {
        get {
            if (originalValues_IdContratto == null) {
                //if(Utils.cebCheckFLSPermission('Pratica__c', 'Servizio_Fornitura__c').get('ACCESS')
                //    && Utils.cebCheckFLSPermission('Servizio__c', 'Contratto__c').get('ACCESS')
                //    && Utils.cebCheckFLSPermission('Contratto__c', 'Id_Esterno__c').get('ACCESS')){
                List<Pratica__c> ListaPrat = new List<Pratica__c>([
                        SELECT Id, Servizio_Fornitura__r.LookupContratto__r.Id_Esterno__c
                        FROM Pratica__c
                        WHERE Id = :SetIdPratica and (NOT (stato__c = 'Bloccata' and is_Blocco_PDR__c = false))
                        and account__r.White_List__c = false
                        WITH SECURITY_ENFORCED
                ]);
                originalValues_IdContratto = new List<String>();
                SetIdContr = new set<String>();
                for (Pratica__c st : ListaPrat) {
                    SetIdContr.add(st.Servizio_Fornitura__r.LookupContratto__r.Id_Esterno__c);
                }
                for (String S : SetIdContr) {
                    originalValues_IdContratto.add(S);
                }

            }
            return originalValues_IdContratto;
        }
        set;
    }

    //Comune
    public List<String> rightValues_Comune { get; set; }
    public set<String> SetComune { get; set; }
    Public List<String> originalValues_Comune {
        get {
            if (originalValues_Comune == null) {
                //if (Utils.cebCheckFLSPermission('Pratica__c', 'Servizio_Fornitura__c').get('ACCESS')
                //        && Utils.cebCheckFLSPermission('Servizio__c', 'Contratto__c').get('ACCESS')
                //        && Utils.cebCheckFLSPermission('Contratto__c', 'Comune__c').get('ACCESS')) {
                List<Pratica__c> ListaPrat = new List<Pratica__c>([
                        SELECT Id, Servizio_Fornitura__r.LookupContratto__r.Comune__c
                        FROM Pratica__c
                        WHERE Id = :SetIdPratica
                        WITH SECURITY_ENFORCED
                ]);
                originalValues_Comune = new List<String>();
                SetComune = new set<String>();
                for (Pratica__c st : ListaPrat)
                    SetComune.add(st.Servizio_Fornitura__r.LookupContratto__r.Comune__c);

                for (String S : SetComune)
                    originalValues_Comune.add(S);
            }

            return originalValues_Comune;
        }
        set;
    }

//Codice Servizio
    public List<String> rightValues_CodiceServizio { get; set; }
    public set<String> SetCodServ { get; set; }
    Public List<String> originalValues_CodiceServizio {
        get {
            if (originalValues_CodiceServizio == null) {
                //if (Utils.cebCheckFLSPermission('Pratica__c', 'Servizio_Fornitura__c').get('ACCESS')) {
                List<Pratica__c> ListaPrat = new List<Pratica__c>([
                        SELECT Id, Servizio_Fornitura__r.RecordType.Name
                        FROM Pratica__c
                        WHERE Id = :SetIdPratica
                        WITH SECURITY_ENFORCED
                ]);
                originalValues_CodiceServizio = new List<String>();
                SetCodServ = new set<String>();
                for (Pratica__c st : ListaPrat)
                    SetCodServ.add(st.Servizio_Fornitura__r.RecordType.Name);
                for (String S : SetCodServ)
                    originalValues_CodiceServizio.add(S);
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
            //if (Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c').get('ACCESS')) {
                List<Pratica__c> ListaPrat = new List<Pratica__c>([SELECT Id, Stato__c FROM Pratica__c 
                WHERE Id = :SetIdPratica WITH SECURITY_ENFORCED ]);
                originalValues_Stato = new List<String>();
                SetStato = new set<String>();
                for (Pratica__c st : ListaPrat) {
                    SetStato.add(st.Stato__c);
                }
                for (String S : SetStato)
                    originalValues_Stato.add(S);
            
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
            //if (Utils.cebCheckFLSPermission('Pratica__c', 'Account__c').get('ACCESS')
            //        && Utils.cebCheckFLSPermission('Account', 'Classe_di_Rischio__c').get('ACCESS')) {
                List<Pratica__c> ListaPrat = new List<Pratica__c>([SELECT Id, Account__r.Classe_di_Rischio__c 
                FROM Pratica__c WHERE Id = :SetIdPratica WITH SECURITY_ENFORCED ]);
                originalValues_ClasseDiRischio = new List<String>();
                SetRischio = new set<String>();
                for (Pratica__c st : ListaPrat)
                    SetRischio.add(st.Account__r.Classe_di_Rischio__c);
                for (String s : SetRischio)
                    originalValues_ClasseDiRischio.add(s);
            }
        
        return originalValues_ClasseDiRischio;
    }
    set;
}

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

public class Header {
    public Integer NRecord { get; set; }
    public Integer MaxGG { get; set; }
    public String Tipo { get; set; }
    public String SottoTipo { get; set; }
    public Boolean Rendered { get; set; }
    Public list<Content> lCont { get; set; }

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

Public Integer nr { get; set; }
Public Integer totnr { get; set; }
public TaskSemiAutomaticiAffido() {
    TaskElab = true;
    MapHeader = new Map<String, Header>();
    if (tipiDiAffidi == null) {
        tipiDiAffidi = new set<string>();
        for (Collector_con_Tipo_Affido__c cta : [Select Tipo_Affido__c from Collector_con_Tipo_Affido__c WITH SECURITY_ENFORCED LIMIT 50000]) {
            
            /*
            *   Modificato: ESino, 27/10/2015
            *   Desc: I valori aggiunti in lowercase, perché i parametri letti dal MapHeader
            *   dell'operatore, si leggono in lowercase.
            */
            if (cta.Tipo_Affido__c != null) {
                String toLowCase = cta.Tipo_Affido__c.toLowerCase();
                tipiDiAffidi.add(toLowCase);
            }
        }
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
    rightValues_IdContratto = new list<String>();
    rightValues_Comune = new list<String>();
    rightValues_CodiceServizio = new list<String>();
    rightValues_Stato = new list<String>();
    rightValues_ClasseDiRischio = new list<String>();
    DaScaduto = null;
    AScaduto = null;
    DaScadutoConsolidato = null;
    AScadutoConsolidato = null;
    DaSaldoSpese = null;
    ASaldoSpese = null;
    DaSaldoConsolidato = null;
    ASaldoConsolidato = null;

    DaAnzianita_scaduto = null;
    AAnzianita_scaduto = null;
    DaSaldo_Totale = null;
    ASaldo_Totale = null;
    DaScaduto_Spese = null;
    AScaduto_Spese = null;

    validDaScaduto = null;
    validAScaduto = null;
    validDaScadutoConsolidato = null;
    validAScadutoConsolidato = null;
    validDaSaldoSpese = null;
    validASaldoSpese = null;
    validDaSaldoConsolidato = null;
    validASaldoConsolidato = null;

    validDaAnzianita_scaduto = null;
    validAAnzianita_scaduto = null;

    validDaScaduto_Spese = null;
    validAScaduto_Spese = null;

    validDaSaldo_Totale = null;
    validASaldo_Totale = null;

    decimalDaScaduto = null;
    decimalAScaduto = null;

    decimalDaScadutoConsolidato = null;
    decimalAScadutoConsolidato = null;

    decimalDaSaldoSpese = null;
    decimalASaldoSpese = null;

    decimalDaSaldoConsolidato = null;
    decimalASaldoConsolidato = null;

    decimalDaAnzianita_scaduto = null;
    decimalAAnzianita_scaduto = null;

    decimalDaSaldo_Totale = null;
    decimalASaldo_Totale = null;

    decimalDaScaduto_Spese = null;
    decimalAScaduto_Spese = null;

    ErrorValidateDecimal = false;

    // Per il primo caricamento della pagina chiamo la funzione che carica i dati con la Visibilità All_Task, poi sarà l'utente a selezionare i valori della picklis
    RefreshQuery();
}

public void RefreshQuery() {
    String debugStr = '\n RefreshQuery() - Start: ';
    If (MapHeader.size() > 0) {
        MapHeader.clear();
    }
    Profile Profilo = [Select Name from Profile where Id = :userinfo.getProfileid() WITH SECURITY_ENFORCED];
    String ProfileName = Profilo.Name;
    String UserFirstName = userinfo.getFirstName();
    String UserLastName = userinfo.getLastName();
    String NameUser = UserFirstName + ' ' + UserLastName;

    String allfieldsStrategia = CredManUtility.selectallShort('Strategia__c');
    allfieldsStrategia = allfieldsStrategia.replaceAll('lastreferenceddate, ', '');
    list<Strategia__c> ListStrategie = new list<Strategia__c>();
    if (Utils.cebCheckObjPermission('Strategia__c',gd).get('ACCESS') 
            && Utils.cebCheckFLSPermission('Strategia__c', 'RC_Api_field_name__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Strategia__c', 'BaseType__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Strategia__c', 'CAP_Massimo__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Strategia__c', 'CAP_Minimo__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Strategia__c', 'Cattivo_Pagatore__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Strategia__c', 'RC_Condition__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Strategia__c', 'Data_attivazione__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Strategia__c', 'Scaduto__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Strategia__c', 'Scelta_utente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Strategia__c', 'Stato__c',gd).get('ACCESS')) {
        ListStrategie = database.query('SELECT ' + String.escapeSingleQuotes(allfieldsStrategia) +
                ' FROM Strategia__c WHERE Recordtype.Name = \'Step\' and Tipologia__c = \'UI\' and Stato_testata__c = \'Attiva\'');
        // SI: ho aggiunto il filtro sulla testata Attiva
        for (Strategia__c Strat : ListStrategie) {
            SetIdStrategie.add(Strat.Id);
        }
    }
    debugStr += '\n \n 1) Vediamo le strategie: ' + SetIdStrategie;
    debugStr += '\n \n 2)Vediamo le Le opzioni: ' + OptionPickVisibilityResult;
    debugStr += '\n \n 3)Vediamo lo user: ' + NameUser;
    List<AggregateResult> lt = taskAgregateResults(SetIdStrategie, OptionPickVisibilityResult, NameUser);
    debugStr += '\n \n 4) AggregateResult, lt: ' + lt + '\n lt size: ' + lt.size();
    String concatenazione = '';
    nr = 0;
    totnr = 0;
    debugStr += '\n \n 5)Compilando MapHeader: \n';
    integer i = 0;
    if (lt.size() > 0) {
        debugStr += '\n \n \n 6) Entrato if, entrando for: ';
        TaskElab = false;
        //throw new TriggerFactory.TriggerException('HHHHHH:'+lt);
        for (AggregateResult aggres : lt) {
            Content cont = new Content();
            cont.Tipo = String.valueOf(aggres.get(Utils.NAMESPACE + 'Tipo__c'));
            if (cont.Tipo == null || cont.Tipo == '')
                cont.Tipo = 'NA';
            cont.SottoTipo = String.valueOf(aggres.get(Utils.NAMESPACE + 'Sotto_Tipo__c'));
            if (cont.SottoTipo == null || cont.SottoTipo == 'NA')
                cont.SottoTipo = '';
            cont.MaxGG = Integer.valueOf(aggres.get('GiorniCompletamento'));
            cont.NRecord = Integer.valueOf(aggres.get('Conteggio'));
            cont.Owner = String.valueOf(aggres.get('OwnerContratto'));
            concatenazione = (cont.SottoTipo == '' || cont.SottoTipo == null ? cont.Tipo : cont.Tipo + '_' + cont.SottoTipo);
            debugStr += '\n ***Elemento ' + i + ': \n Content: ' + cont + '\n concatenazione: ' + concatenazione;
            if (MapHeader.containsKey(concatenazione)) {
                Header h = MapHeader.get(concatenazione);
                h.NRecord = h.NRecord + cont.NRecord;
                if (cont.MaxGG > h.MaxGG)
                    h.MaxGG = cont.MaxGG;
                h.lCont.add(cont);
                MapHeader.put(concatenazione, new Header(h));
                debugStr += '\n Compilato nel If, con Header: ' + h;
            } else {
                Header h = new Header();
                h.Tipo = cont.Tipo;
                h.SottoTipo = cont.SottoTipo;
                h.MaxGG = Integer.valueOf(aggres.get('GiorniCompletamento'));
                h.NRecord = Integer.valueOf(aggres.get('Conteggio'));
                h.lCont = new List<Content>();
                h.lCont.add(cont);
                MapHeader.put(concatenazione, new Header(h));
                debugStr += '\n Compilato nel else, con Header: ' + h;
            }
        }
        debugStr += '\n \n \n 7)Uscito for, MapHeader: ' + String.valueOf(MapHeader);
    }
    System.debug('TaskSemiAutomaticiAffido, RefreshQuery(), \n Esito: ' + debugStr);
}

public Pagereference VaiATabella() {
    String debug = '\n Met vaiATabella() - START: ';
    step = 1;
    // SI parametri del link sul content
    //TipoContent = ApexPages.currentPage().getParameters().get('TipoContent');
    TipoContent = ApexPages.currentPage().getParameters().get('TipoContent').escapeHtml4();
    if (TipoContent != null) TipoContent = TipoContent.tolowercase();
    //SottoTipoContent = ApexPages.currentPage().getParameters().get('SottoTipoContent');
    SottoTipoContent = ApexPages.currentPage().getParameters().get('SottoTipoContent').escapeHtml4();
    if (SottoTipoContent != null) SottoTipoContent = SottoTipoContent.tolowercase();
    //OwnerContent = ApexPages.currentPage().getParameters().get('OwnerContent');
    OwnerContent = ApexPages.currentPage().getParameters().get('OwnerContent').escapeHtml4();
    if (OwnerContent != null) OwnerContent = OwnerContent.tolowercase();
    //Header_Content = ApexPages.currentPage().getParameters().get('Header_Content');
    Header_Content = ApexPages.currentPage().getParameters().get('Header_Content').escapeHtml4();
    if (Header_Content != null) Header_Content = Header_Content.tolowercase();
    debug += '\n - 1. Parametri del link, bonificati: \n \n';
    debug += '\n a) TipoContent: ' + TipoContent;
    debug += '\n b) SottoTipoContent: ' + SottoTipoContent;
    debug += '\n c) OwnerContent: ' + OwnerContent;
    debug += '\n d) Header_Content: ' + Header_Content;

    // SI parametri del link sul MapHeader
/*    TipoH = ApexPages.currentPage().getParameters().get('TipoHeader');
    SottoTipoH = ApexPages.currentPage().getParameters().get('SottoTipoHeader');
    MHeader = ApexPages.currentPage().getParameters().get('Header');
    */
    TipoH = ApexPages.currentPage().getParameters().get('TipoHeader').escapeHtml4();
    SottoTipoH = ApexPages.currentPage().getParameters().get('SottoTipoHeader').escapeHtml4();
    MHeader = ApexPages.currentPage().getParameters().get('Header').escapeHtml4();

    debug += '\n - 2. Parametri del mapHeader, bonificati: \n \n';
    debug += '\n a) TipoH: ' + TipoH;
    debug += '\n b) SottoTipoH: ' + SottoTipoH;
    debug += '\n c) MHeader: ' + MHeader;

    String allfieldsTask = CredManUtility.selectallShort('Task');
    allfieldsTask = allfieldsTask.replaceAll('lastreferenceddate, ', '');

    list<Task> ListTaskToView = new list<Task>();
    if (Utils.cebCheckObjPermission('Task',gd).get('ACCESS') 
            && Utils.cebCheckFLSPermission('Task', 'Count_of_Events__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Count_of_Tasks__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Durata_Effettiva__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Giorni_Fuori_SLA__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'SLA__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Tipo_esecuzione__c',gd).get('ACCESS')) {
        QueryTask = 'SELECT ' + String.escapeSingleQuotes(allfieldsTask) +
                ' FROM Task WHERE ActivityExtended__r.id_attivita__c IN: SetIdStrategie AND Status = \'Non Iniziata\' AND';
    }
    // SI Faccio il controllo sul Header Content e MapHeader E quindi usare i parametri del Map Header o del Content
    debug += '\n\n 3. tipiDiAffidi: ' + String.valueOf(tipiDiAffidi) + '\n \n SottoTipoContent: ' + SottoTipoContent + '\n \n MapHeader: ' + String.valueOf(MapHeader);

    /*
    *   Modificato: ESino, 27/10/2015
    *   Il controllo del sottotipoheader per il Link'Vedi Tutti', si fa in lowercase
    *   perché anche i valori dei tipi dei affidi, sono salvati tutti in lowercase.
    */
    if (!String.isBlank(SottoTipoH)) {
        SottoTipoH = SottoTipoH.toLowerCase();
        debug += '\n\n 4. SottoTipoH(modificato il lowercase): ' + SottoTipoH;
    }
    if (tipiDiAffidi.contains(SottoTipoContent)) {
        debug += '\n Primo if - 1, ';
        Pagereference page = new PageReference('/apex/newLottizzazione?Type=' + SottoTipoContent + '&ownr=' + OwnerContent);
        page.setRedirect(true);
        ErrorClass.logError('\n TaskSemiAutomaticiAffido, VaiATabella()', '\n MANDANDO Nella pagina newLottizzazione: ' + debug);
        return page;
    } else if (tipiDiAffidi.contains(SottoTipoH)) {
        debug += '\n \n Secondo if - 2, ';
        Pagereference page = new PageReference('/apex/newLottizzazione?Type=' + SottoTipoH);
        page.setRedirect(true);
        ErrorClass.logError('\n TaskSemiAutomaticiAffido, VaiATabella()', '\n MANDANDO Nella pagina newLottizzazione: ' + debug);
        return page;
    }
    if (Header_Content.equalsIgnoreCase('Content')) {
        debug += '\n Terzo if - 3, ';
        if (TipoContent != '' && TipoContent != null) {
            TipoCQuery = TipoContent == 'NA' ? '' : TipoContent;
            //QueryTask= QueryTask+' Tipo__c =: TipoCQuery AND';
            QueryTask = QueryTask + ' ActivityExtended__r.Tipo__c =: TipoCQuery AND';
        }
        if (SottoTipoContent != '' && SottoTipoContent != null) {
            SottoTipoCQuery = SottoTipoContent == 'NA' ? '' : SottoTipoContent;
            //QueryTask= QueryTask+' Sotto_Tipo__c =: SottoTipoCQuery AND';
            QueryTask = QueryTask + ' ActivityExtended__r.Sotto_Tipo__c =: SottoTipoCQuery AND';
        }
        if (OwnerContent != '' && OwnerContent != null) {
            //QueryTask= QueryTask+' Owner_contratto__c =: OwnerContent';
            QueryTask = QueryTask + ' ActivityExtended__r.Owner_contratto__c =: OwnerContent';
        }

        if (TipoContent.equalsIgnoreCase('Invio AR') || TipoContent.equalsIgnoreCase('Invio Lettera di Posta Prioritaria Standard')) {
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
    } else if (MHeader.equalsIgnoreCase('Header')) {
        debug += '\n\n Quarto if - 4, ';
        if (TipoH != '' && TipoH != null) {
            TipoHQuery = TipoH == 'NA' ? '' : TipoH;
            //QueryTask= QueryTask+' Tipo__c =: TipoHQuery AND';
            QueryTask = QueryTask + ' ActivityExtended__r.Tipo__c =: TipoHQuery AND';
        }
        if (SottoTipoH != '' && SottoTipoH != null) {
            SottoTipoHQuery = SottoTipoH == 'NA' ? '' : SottoTipoH;
            //QueryTask= QueryTask+' Sotto_Tipo__c =: SottoTipoHQuery AND';
            QueryTask = QueryTask + ' ActivityExtended__r.Sotto_Tipo__c =: SottoTipoHQuery AND';
        }
        if (TipoH.equalsIgnoreCase('Invio AR') || TipoH.equalsIgnoreCase('Invio Lettera di Posta Prioritaria Standard')) {
            BLettera = true;
            if (TipoH.equalsIgnoreCase('Invio Lettera di Posta Prioritaria Standard')) {
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
        QueryTask = QueryTask.substring(0, QueryTask.length() - 4);
    }
    System.Debug(QueryTask + ' limit 100');
    // inizio nuovo codice 14/04/17 inserimento check permission
    if (Utils.cebCheckObjPermission('Task',gd).get('ACCESS') 
            && Utils.cebCheckFLSPermission('Task', 'Count_of_Events__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Count_of_Tasks__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Durata_Effettiva__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Giorni_Fuori_SLA__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'SLA__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Tipo_esecuzione__c',gd).get('ACCESS')) {
        ListTaskToView = database.query(QueryTask + ' limit 100');
    }
    // fine nuovo codice 14/04/17 inserimento check permission
    listPraticheSelectable = new list<PraticheSelectable>();
    setIdPratica.clear();
    //throw new Utils.BalanceException('tttttt:'+ListTaskToView);
    for (Task Activity : ListTaskToView) {
        SetIdPratica.add(Activity.WhatId);
    }
    String allfieldsStrategia = CredManUtility.selectallShort('Strategia__c');
    allfieldsStrategia = allfieldsStrategia.replaceAll('lastreferenceddate, ', '');
    list<Strategia__c> ListStrategieToView = new list<Strategia__c>();
    // inizio nuovo codice 14/04/17 inserimento check permission
    if (Utils.cebCheckObjPermission('Strategia__c',gd).get('ACCESS') 
            && Utils.cebCheckFLSPermission('Strategia__c', 'RC_Api_field_name__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Strategia__c', 'BaseType__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Strategia__c', 'CAP_Massimo__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Strategia__c', 'CAP_Minimo__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Strategia__c', 'Cattivo_Pagatore__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Strategia__c', 'RC_Condition__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Strategia__c', 'Data_attivazione__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Strategia__c', 'Scaduto__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Strategia__c', 'Scelta_utente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Strategia__c', 'Stato__c',gd).get('ACCESS')) {
        ListStrategieToView = database.query(String.escapeSingleQuotes('SELECT ' + allfieldsStrategia +
                ' FROM Strategia__c WHERE Pratica_di_riferimento__c IN: SetIdPratica'));
    }
    // fine nuovo codice 14/04/17 inserimento check permission
    MapStrategiaPerIdPrat = new map<Id, Strategia__c>();
    for (Strategia__c Strat : ListStrategieToView) {
        MapStrategiaPerIdPrat.put(Strat.Pratica_di_riferimento__c, Strat);
    }
    ListPraticaToView.clear();
    String allfieldsPratica = CredManUtility.selectallShort('Pratica__c');
    allfieldsPratica = allfieldsPratica.replaceAll('lastreferenceddate, ', '');

    // questa la eseguo una sola volta per caricare i primi record di ciascuna pagina
    if (Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS') 
            && Utils.cebCheckFLSPermission('Pratica__c', 'Anzianit_Pratica__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'byPassRole__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Check_In_Lavorazione__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Esecuzione_Processo_Mensile__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Blocco__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Chiusura__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_inizio_scaduto__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_in_Lavorazione__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Esci_e_chiudi__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Flag_Chiusura__c',gd).get('ACCESS')) {
        Query_Prat_All = 'SELECT ' + allfieldsPratica + ' ,Servizio_Fornitura__r.LookupContratto__r.Id_Esterno__c, Strategia__r.Nome__c, Servizio_Fornitura__r.RecordType.Name,' +
                ' Servizio_Fornitura__r.LookupContratto__r.Comune__c,' +
                ' Servizio_Fornitura__r.Codice__c,' +
                ' Account__r.Classe_di_Rischio__c,' +
                ' Account__r.Name' +
                ' FROM Pratica__c WHERE Id IN: SetIdPratica order by Name asc';
    }
    //Chiamo il metodo per la creazione della tabella.
    ErrorClass.logError('\n TaskSemiAutomaticiAffido, VaiATabella()', '\n ESITO prima di Pagination: ' + debug);
    //throw new Utils.BalanceException('HHHHHH:'+Query_Prat_All);
    pagination();
    return null;
}

public void Indietro() {
    MapSelezione.clear();
    rightValues_IdContratto.clear();
    rightValues_Comune.clear();
    rightValues_CodiceServizio.clear();
    rightValues_Stato.clear();
    rightValues_ClasseDiRischio.clear();
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

public void BackTo() {
    shouldRedirect = true;
    url_Parent = '/apex/RiepilogoTask';
}

public Pagereference HomePage() {
    pagereference pg;
    pg = new pagereference('/');
    return pg;
}

public void UpdateListe() {
    try {
        String sElenco = Apexpages.currentPage().getParameters().get('ValSelected');
        Integer iIndex = Integer.valueOf(Apexpages.currentPage().getParameters().get('IndexSelected'));
        List<String> elenco = sElenco.split(',');

        if (iIndex == 1) {
            rightValues_IdContratto.clear();
            //Id Contratto
            if (sElenco != '') {
                for (string s : elenco)
                    rightValues_IdContratto.add(s);
            }
        } else if (iIndex == 2) {
            //Comune
            rightValues_Comune.clear();
            if (sElenco != '') {
                for (string s : elenco)
                    rightValues_Comune.add(s);
            }
        } else if (iIndex == 3) {
            //Fascia ISEE
            rightValues_CodiceServizio.clear();
            if (sElenco != '') {
                for (string s : elenco)
                    rightValues_CodiceServizio.add(s);
            }
        } else if (iIndex == 4) {
            //Rating
            rightValues_Stato.clear();
            if (sElenco != '') {
                for (string s : elenco)
                    rightValues_Stato.add(s);
            }
        } else if (iIndex == 5) {
            //Rating
            rightValues_ClasseDiRischio.clear();
            if (sElenco != '') {
                for (string s : elenco)
                    rightValues_ClasseDiRischio.add(s);
            }
        }
    } catch (Exception e) {
        String LineError = String.ValueOf(e.getLineNumber());
        system.debug(logginglevel.INFO, '*****Eccezione nel metodo UpdateListe: ' + e.getMessage() + ' LineError = ' + LineError);
    }
}

public void FiltroQuery() {

    String patDecimal = '(^(\\+|\\-)(0|([1-9][0-9]*))(\\.[0-9]{1,2})?$)|(^(0{0,1}|([1-9][0-9]*))(\\.[0-9]{1,2})?$)';

    if (ListPraticaAll.size() > 0)
        ListPraticaAll.clear();

    if (MapSelezione.size() > 0)
        MapSelezione.clear();

    if (ListPraticaToView.size() > 0)
        ListPraticaToView.clear();

    if (listPraticheSelectable.size() > 0)
        listPraticheSelectable.clear();

    if (List_Firt_Rec_X_Page.size() > 0)
        List_Firt_Rec_X_Page.clear();

    validDaScaduto = pattern.matches(patDecimal, DaScaduto);
    validAScaduto = pattern.matches(patDecimal, AScaduto);
    validDaScadutoConsolidato = pattern.matches(patDecimal, DaScadutoConsolidato);
    validAScadutoConsolidato = pattern.matches(patDecimal, AScadutoConsolidato);
    validDaSaldoSpese = pattern.matches(patDecimal, DaSaldoSpese);
    validASaldoSpese = pattern.matches(patDecimal, ASaldoSpese);
    validDaSaldoConsolidato = pattern.matches(patDecimal, DaSaldoConsolidato);
    validASaldoConsolidato = pattern.matches(patDecimal, ASaldoConsolidato);

    validDaAnzianita_scaduto = pattern.matches(patDecimal, DaAnzianita_scaduto);
    validAAnzianita_scaduto = pattern.matches(patDecimal, AAnzianita_scaduto);
    validDaScaduto_Spese = pattern.matches(patDecimal, DaScaduto_Spese);
    validAScaduto_Spese = pattern.matches(patDecimal, AScaduto_Spese);
    validASaldo_Totale = pattern.matches(patDecimal, ASaldo_Totale);
    validDaSaldo_Totale = pattern.matches(patDecimal, DaSaldo_Totale);

    if (!validDaScaduto) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Scaduto Da" necessita un valore numerico o decimale.  (ES: 123.45)'));
        ErrorValidateDecimal = true;
        return;

    } else if (!validAScaduto) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Scaduto A" necessita un valore numerico o decimale.  (ES: 123.45)'));
        ErrorValidateDecimal = true;
        return;

    } else if (!validDaScadutoConsolidato) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Scaduto Consolidato DA" necessita un valore numerico o decimale.  (ES: 123.45)'));
        ErrorValidateDecimal = true;
        return;

    } else if (!validAScadutoConsolidato) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Scaduto Consolidato A" necessita un valore numerico o decimale.  (ES: 123.45)'));
        ErrorValidateDecimal = true;
        return;

    } else if (!validDaSaldoSpese) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Saldo Spese DA" necessita un valore numerico o decimale.  (ES: 123.45)'));
        ErrorValidateDecimal = true;
        return;

    } else if (!validASaldoSpese) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Saldo Spese A" necessita un valore numerico o decimale.  (ES: 123.45)'));
        ErrorValidateDecimal = true;
        return;

    } else if (!validDaSaldoConsolidato) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Saldo Consolidato DA" necessita un valore numerico o decimale.  (ES: 123.45)'));
        ErrorValidateDecimal = true;
        return;

    } else if (!validASaldoConsolidato) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Saldo Consolidato A" necessita un valore numerico o decimale.  (ES: 123.45)'));
        ErrorValidateDecimal = true;
        return;
    } else if (!validDaSaldo_Totale) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Saldo Da" necessita un valore numerico o decimale.  (ES: 123.45)'));
        ErrorValidateDecimal = true;
        return;
    } else if (!validASaldo_Totale) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Saldo A" necessita un valore numerico o decimale.  (ES: 123.45)'));
        ErrorValidateDecimal = true;
        return;
    } else if (!validDaScaduto_Spese) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Scaduto Spese Da" necessita un valore numerico o decimale.  (ES: 123.45)'));
        ErrorValidateDecimal = true;
        return;
    } else if (!validAScaduto_Spese) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Scaduto Spese A" necessita un valore numerico o decimale.  (ES: 123.45)'));
        ErrorValidateDecimal = true;
        return;
    } else if (!validDaAnzianita_scaduto) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Ageing Da" necessita un valore numerico o decimale.  (ES: 123.45)'));
        ErrorValidateDecimal = true;
        return;
    } else if (!validAAnzianita_scaduto) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Ageing A" necessita un valore numerico o decimale.  (ES: 123.45)'));
        ErrorValidateDecimal = true;
        return;
    }
    //Controllo che gli utenti popolino entrambi gli input Da e A
    if ((DaScaduto == '' && AScaduto != '') || (AScaduto == '' && DaScaduto != '')) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Specificare entrambi i valori dello Scaduto che si vuole filtrare. '));
        ErrorValidateDecimal = true;
        return;
    }
    if ((DaScadutoConsolidato == '' && AScadutoConsolidato != '') || (AScadutoConsolidato == '' && DaScadutoConsolidato != '')) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Specificare entrambi i valori dello Scaduto Consolidato che si vuole filtrare.'));
        ErrorValidateDecimal = true;
        return;
    }
    if ((DaSaldoSpese == '' && ASaldoSpese != '') || (ASaldoSpese == '' && DaSaldoSpese != '')) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Specificare entrambi i valori del Saldo Spese che si vuole filtrare.'));
        ErrorValidateDecimal = true;
        return;
    }
    if ((DaSaldoConsolidato == '' && ASaldoConsolidato != '') || (ASaldoConsolidato == '' && DaSaldoConsolidato != '')) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Specificare entrambi i valori del Saldo Consolidato che si vuole filtrare.'));
        ErrorValidateDecimal = true;
        return;
    }

    if ((DaAnzianita_scaduto == '' && AAnzianita_scaduto != '') || (AAnzianita_scaduto == '' && DaAnzianita_scaduto != '')) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Specificare entrambi i valori dell\'Ageing che si vuole filtrare. '));
        ErrorValidateDecimal = true;
        return;
    }
    if ((DaSaldo_Totale == '' && ASaldo_Totale != '') || (ASaldo_Totale == '' && DaSaldo_Totale != '')) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Specificare entrambi i valori del Saldo che si vuole filtrare. '));
        ErrorValidateDecimal = true;
        return;
    }

    if ((DaScaduto_Spese == '' && AScaduto_Spese != '') || (AScaduto_Spese == '' && DaScaduto_Spese != '')) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Specificare entrambi i valori dello scaduto spese che si vuole filtrare. '));
        ErrorValidateDecimal = true;
        return;
    }

    //Verifico che il range che inseriscono sia valido
    if (DaScaduto != '' && AScaduto != '') {
        if (decimal.valueOf(DaScaduto) > decimal.valueOf(AScaduto)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Il range di valori del filtro Scaduto non è valido.'));
            ErrorValidateDecimal = true;
            return;
        }
    }
    if (DaScadutoConsolidato != '' && AScadutoConsolidato != '') {
        if (decimal.valueOf(DaScadutoConsolidato) > decimal.valueOf(AScadutoConsolidato)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Il range di valori del filtro Scaduto consolidato non è valido.'));
            ErrorValidateDecimal = true;
            return;
        }
    }
    if (DaSaldoSpese != '' && ASaldoSpese != '') {
        if (decimal.valueOf(DaSaldoSpese) > decimal.valueOf(ASaldoSpese)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Il range di valori del filtro Saldo Spese non è valido.'));
            ErrorValidateDecimal = true;
            return;
        }
    }
    if (DaSaldoConsolidato != '' && ASaldoConsolidato != '') {
        if (decimal.valueOf(DaSaldoConsolidato) > decimal.valueOf(ASaldoConsolidato)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Il range di valori del filtro Saldo Consolidato non è valido.'));
            ErrorValidateDecimal = true;
            return;
        }
    }

    if (DaAnzianita_scaduto != '' && AAnzianita_scaduto != '') {
        if (decimal.valueOf(DaAnzianita_scaduto) > decimal.valueOf(AAnzianita_scaduto)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Il range di valori del filtro sull\'Ageing non è valido.'));
            ErrorValidateDecimal = true;
            return;
        }
    }

    if (DaSaldo_Totale != '' && ASaldo_Totale != '') {
        if (decimal.valueOf(DaSaldo_Totale) > decimal.valueOf(ASaldo_Totale)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Il range di valori del filtro sul Saldo non è valido.'));
            ErrorValidateDecimal = true;
            return;
        }
    }

    if (DaScaduto_Spese != '' && AScaduto_Spese != '') {
        if (decimal.valueOf(DaScaduto_Spese) > decimal.valueOf(AScaduto_Spese)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Il range di valori del filtro Scaduto Spese non è valido.'));
            ErrorValidateDecimal = true;
            return;
        }
    }
    // Non faccio una nuova query ma uso la stringa del metodo vai a tabella: Query_Prat_All
    //rightValues_IdContratto, rightValues_Comune, rightValues_CodiceServizio, rightValues_Stato, rightValues_ClasseDiRischio
    // SI Controllo la stringa e tolgo la parte order by che ho inserito nel metodo VaiaTabella
    Query_Prat_All = Query_Prat_All.substring(0, (Query_Prat_All.indexOf('SetIdPratica')) + 12) + ' AND';

    if (rightValues_IdContratto.size() > 0) {
        Query_Prat_All = Query_Prat_All + ' Servizio_Fornitura__r.LookupContratto__r.Id_Esterno__c IN: rightValues_IdContratto AND';
    }
    if (rightValues_Comune.size() > 0) {
        Query_Prat_All = Query_Prat_All + ' Servizio_Fornitura__r.LookupContratto__r.Comune__c IN: rightValues_Comune AND';
    }
    if (rightValues_CodiceServizio.size() > 0) {
        Query_Prat_All = Query_Prat_All + ' Servizio_Fornitura__r.RecordType.Name IN: rightValues_CodiceServizio AND';
    }
    if (rightValues_Stato.size() > 0) {
        Query_Prat_All = Query_Prat_All + ' Stato__c IN: rightValues_Stato AND';
    }
    if (rightValues_ClasseDiRischio.size() > 0) {
        Query_Prat_All = Query_Prat_All + ' Classe_di_rischio__c IN: rightValues_ClasseDiRischio AND';
    }

    //Quero i Range
    if (DaScaduto != '' && AScaduto != '') {
        decimalDaScaduto = decimal.ValueOf(DaScaduto);
        decimalAScaduto = decimal.ValueOf(AScaduto);
        Query_Prat_All = Query_Prat_All + ' Residuo_Totale__c > ' + decimalDaScaduto + ' AND Residuo_Totale__c < ' + decimalAScaduto + ' AND';
    }
    if (DaScadutoConsolidato != '' && AScadutoConsolidato != '') {
        decimalDaScadutoConsolidato = decimal.ValueOf(DaScadutoConsolidato);
        decimalAScadutoConsolidato = decimal.ValueOf(AScadutoConsolidato);
        Query_Prat_All = Query_Prat_All + ' (Importo_Scaduto_Consolidato__c >: decimalDaScadutoConsolidato AND Importo_Scaduto_Consolidato__c <: decimalAScadutoConsolidato) AND';
    }
    if (DaSaldoSpese != '' && ASaldoSpese != '') {
        decimalDaSaldoSpese = decimal.ValueOf(DaSaldoSpese);
        decimalASaldoSpese = decimal.ValueOf(ASaldoSpese);
        Query_Prat_All = Query_Prat_All + ' (Saldo_Spese__c >: decimalDaSaldoSpese AND Saldo_Spese__c <: decimalASaldoSpese) AND';
    }
    if (DaSaldoConsolidato != '' && ASaldoConsolidato != '') {
        decimalDaSaldoConsolidato = decimal.ValueOf(DaSaldoConsolidato);
        decimalASaldoConsolidato = decimal.ValueOf(ASaldoConsolidato);
        Query_Prat_All = Query_Prat_All + ' (Importo_saldo_Consolidato__c >: decimalDaSaldoConsolidato AND Importo_saldo_Consolidato__c <: decimalASaldoConsolidato) AND';
    }

    if (DaAnzianita_scaduto != '' && AAnzianita_scaduto != '') {
        decimalDaAnzianita_scaduto = decimal.ValueOf(DaAnzianita_scaduto);
        decimalAAnzianita_scaduto = decimal.ValueOf(AAnzianita_scaduto);
        Query_Prat_All = Query_Prat_All + ' (Anzianita_scaduto__c >: decimalDaAnzianita_scaduto AND Anzianita_scaduto__c <: decimalAAnzianita_scaduto) AND';
    }

    if (DaSaldo_Totale != '' && ASaldo_Totale != '') {
        decimalDaSaldo_Totale = decimal.ValueOf(DaSaldo_Totale);
        decimalASaldo_Totale = decimal.ValueOf(ASaldo_Totale);
        Query_Prat_All = Query_Prat_All + ' (Saldo_Totale__c >: decimalDaSaldo_Totale AND Saldo_Totale__c <: decimalASaldo_Totale) AND';
    }


    if (DaScaduto_Spese != '' && AScaduto_Spese != '') {
        decimalDaScaduto_Spese = decimal.ValueOf(DaScaduto_Spese);
        decimalAScaduto_Spese = decimal.ValueOf(AScaduto_Spese);
        Query_Prat_All = Query_Prat_All + ' (Scaduto_Spese__c >: decimalDaScaduto_Spese AND Scaduto_Spese__c <: decimalAScaduto_Spese) AND';
    }

    if (Query_Prat_All.endsWith(' AND')) {
        Query_Prat_All = Query_Prat_All.substring(0, Query_Prat_All.length() - 4);
    }
    // Aggiungo l'order by
    Query_Prat_All = Query_Prat_All + ' order by Name asc';
    // Chiamo il metodo per inserire i dati in tabella
    pagination();

}

// SI
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

/*    String Elem = ApexPages.currentPage().getParameters().get('Elem');
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

public PageReference ConfermaLista() {
    String debug = '\n Met. ConfermaLista() - START: \n';
    // Uso la mappa MapSelezione per ricavare l'insieme delle pratiche scelte dall'utente.
    String ValMap = String.valueOF(MapSelezione.keySet());
    String ValMap2 = ValMap.replace('}', '\')');
    String ValMap3 = ValMap2.replace('{', '(\'');
    String ValMap4 = ValMap3.replace(',', '\',\'');
    String ValMap5 = ValMap4.replaceAll('\\s', '');
    debug += '\n \n Trim: ' + ValMap5;
    debug += '\n \n Tipologia: ' + TipoCQuery;

    String QueryUPD = '';
    if (Utils.cebCheckObjPermission('Task',gd).get('ACCESS') 
            && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c',gd).get('ACCESS')
            && Utils.cebCheckObjPermission('ActivityExtended__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Scelta_utente__c',gd).get('ACCESS')) {
        QueryUPD += 'Select id, Status, ActivityExtended__r.Scelta_utente__c from Task ' + QueryTask.substring(QueryTask.indexOf('WHERE', 0), QueryTask.length()) + ' and WhatId IN (Select Id from Pratica__c where Name in ' + ValMap5 + ')';
    }
    debug += '\n \n QueryUPD: ' + QueryUPD;

    // inizio nuovo codice 14/04/17 inserimento check permission
    List<Task> TaskUPD = new List<Task>();
    if (Utils.cebCheckObjPermission('Task',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Count_of_Events__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Count_of_Tasks__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Durata_Effettiva__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Giorni_Fuori_SLA__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'SLA__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Tipo_esecuzione__c',gd).get('ACCESS')) {
        TaskUPD = database.query(QueryUPD);
    }
    // fine nuovo codice 14/04/17 inserimento check permission
    debug += '\n \n Lista da aggiornare: ' + TaskUPD;
    debug += '\n \n QueryUPDLunghezza: ' + TaskUPD.size();
    debug += '\n \n Owner' + OwnerContent;
    debug += '\n \n SetIdStrategie' + SetIdStrategie.size();
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
    if (Utils.cebCheckObjPermission('ActivityExtended__c',gd).get('UPDATE')
            && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Scelta_utente__c',gd).get('UPDATE')) {
        update aes;
    }
    if (Utils.cebCheckObjPermission('Task',gd).get('UPDATE')
            && Utils.cebCheckFLSPermission('Task', 'Status',gd).get('UPDATE')) {
        update TaskUPD;
    }

    step = 2;
    Count = TaskUPD.size();
    debug += '\n \n FINE! \n Count: ' + Count;
    System.debug(debug);
    return null;
}

public PageReference End() {
    String debug = ' \n Met. PageReference End() - START!! \n';
    //user clicked end
    debug += '\n \n *****Controllo = ' + Controllo;
    CPage = Controllo + 1;
    debug += '\n \n *****CPage = ' + CPage;
    debug += '\n \n ****RecXPage = ' + RecXPage;
    debug += '\n \n ****TotaleRec = ' + TotaleRec;
    Integer Pos = (CPage - 1) * RecXPage == TotaleRec ? CPage - 2 : CPage - 1;
    debug += '\n \n VALE: ' + Controllo;
    debug += '\n \n VALE 2: ' + CPage;
    InizioL = CPage == 1 ? 1 : ((Pos) * RecXPage) + 1;
    FineL = CPage == (Controllo + 1) ? TotaleRec : (TotaleRec < RecXPage ? TotaleRec : CPage * RecXPage);
    debug += '\n \n ****Query_Prat_AllEnd = ' + Query_Prat_All;
    debug += '\n \n ****PosEnd = ' + Pos;
    Query_Prat_Limit = QueryLimitPage(Query_Prat_All, Pos);
    // inizio nuovo codice 14/04 inserimento check permission
    if (Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_inizio_scaduto__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_in_Lavorazione__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Corrente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Scaduto_Corrente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Strategia_Scaduto__c',gd).get('ACCESS')) {
        ListPraticaToView = database.query(Query_Prat_Limit);
        debug += '\n \n ****ListPraticaToView = ' + ListPraticaToView;
        aggiorna_Elenco(ListPraticaToView);
        System.debug(debug);
    }
    // fine nuovo codice 14/04 inserimento check permission
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
    // inizio nuovo codice 14/04 inserimento check permission
    if (Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_inizio_scaduto__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_in_Lavorazione__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Corrente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Scaduto_Corrente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Strategia_Scaduto__c',gd).get('ACCESS')) {
        ListPraticaToView = database.query(Query_Prat_Limit);
        aggiorna_Elenco(ListPraticaToView);
    }
    // fine nuovo codice 14/04 inserimento check permission
    return null;
}

public PageReference Beginning() {
    //user clicked beginning
    CPage = 1;
    InizioL = CPage == 1 ? 1 : ((CPage - 1) * RecXPage) + 1;
    FineL = CPage == (Controllo + 1) ? TotaleRec : (TotaleRec < RecXPage ? TotaleRec : CPage * RecXPage);
    Query_Prat_Limit = QueryLimitPage(Query_Prat_All, CPage - 1);
    // inizio nuovo codice 14/04 inserimento check permission
    if (Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_inizio_scaduto__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_in_Lavorazione__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Corrente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Scaduto_Corrente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Strategia_Scaduto__c',gd).get('ACCESS')) {
        ListPraticaToView = database.query(Query_Prat_Limit);
        aggiorna_Elenco(ListPraticaToView);
    }
    // fine nuovo codice 14/04 inserimento check permission
    return null;
}

public PageReference Previous() {
    //user clicked previous button
    CPage = CPage - 1;
    InizioL = CPage == 1 ? 1 : ((CPage - 1) * RecXPage) + 1;
    FineL = CPage == (Controllo + 1) ? TotaleRec : (TotaleRec < RecXPage ? TotaleRec : CPage * RecXPage);
    Query_Prat_Limit = QueryLimitPage(Query_Prat_All, CPage - 1);
    // inizio nuovo codice 14/04 inserimento check permission
    if (Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_inizio_scaduto__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_in_Lavorazione__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Corrente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Scaduto_Corrente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Strategia_Scaduto__c',gd).get('ACCESS')) {
        ListPraticaToView = database.query(Query_Prat_Limit);
        aggiorna_Elenco(ListPraticaToView);
    }
    // fine nuovo codice 14/04 inserimento check permission
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
    //throw new Utils.BalanceException('Cosa arriva al limit page: '+Query_EXEC);
    if (Test.isRunningTest()) {
        Position = List_Firt_Rec_X_Page.size() - 1;
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
    String debug = '\n Metodo Pagination(), START: ';
    debug += '\n \n 1) Query_Prat_All: ' + Query_Prat_All;
    // inizio nuovo codice 13/04/17 inserimento check permission
    if (Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_inizio_scaduto__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_in_Lavorazione__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Corrente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Scaduto_Corrente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Strategia_Scaduto__c',gd).get('ACCESS')) {
        ListPraticaAll = database.query(String.escapeSingleQuotes(Query_Prat_All));
    }
    // fine nuovo codice 13/04/17 inserimento check permission
    //throw new TriggerFactory.TriggerException('WWWWW:'+ListPraticaAll);          
    if (ListPraticaAll.size() > 0) {
        debug += '\n \n 2. CI SONO DELLE PRATICHE!!! \n Dimensione lista: ' + ListPraticaAll.size();

        // Suddivido i record estratti in blocchi (ogni blocco è composto da un tanti record in base al valore del parametro RecXPage)
        for (integer i = 0; i < ListPraticaAll.size(); i++) {
            if (i == 0 || (math.mod(i, RecXPage) == 0)) {
                List_Firt_Rec_X_Page.add(ListPraticaAll[i].Name);
            }
            MapSelezione.put(ListPraticaAll[i].Name, true);
        }

        // Questa verrà eseguita ogni volta per mostrare i dati limitati. Il parametro passato al metodo permette di recuperare il primo record di ogni lista.
        Query_Prat_Limit = QueryLimitPage(Query_Prat_All, 0);
        // inizio nuovo codice 13/04/17 inserimento check permission
        if (Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_inizio_scaduto__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_in_Lavorazione__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Corrente__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Scaduto_Corrente__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Strategia_Scaduto__c',gd).get('ACCESS')) {
            ListPraticaToView = database.query(Query_Prat_Limit);
        }
        // fine nuovo codice 13/04/17 inserimento check permission
        // Pagination
        TotaleRec = ListPraticaAll.size();
        Controllo = TotaleRec / RecXPage;
        CPage = 1;
        InizioL = 1;
        FineL = TotaleRec < RecXPage ? TotaleRec : (CPage * RecXPage);

        // SI Ho modificato il codice con cui popolare la lista 
        // per gestire la selezione/deselezione sul singolo record
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
    ErrorClass.logError('TaskSemiAutomaticiAffido - pagination()', 'STACKTRACE: \n ' + debug);
}

public List<AggregateResult> taskAgregateResults(set<id> SetIdStr, string OptionPickVisibility, string NU) {
    /*Il processo è, querare i task, dopo di 
    che querare le pratiche, e raccogliere le 
    pratiche lavorabili, e infine fare la query di gourp by */
    List<id> idPraticheTemp = new List<id>();
    List<id> idPratiche = new List<id>();
    String debugStr = '\n met taskAgregateResults(), Input, SetIdStr: ' + String.valueOf(SetIdStr);
    debugStr += '\n OptionPickVisibility: ' + OptionPickVisibility + '\n NU: ' + NU;
    //string queryOnTasks = 'Select id, whatid From Task Where id_attivita__c IN: SetIdStr AND  ((Status =\'Non Iniziata\') ) and id_affidamento__c=null limit 15000';
    string queryOnTasks = 'Select id, whatid From Task Where ActivityExtended__r.E_da_affidare__c = true AND ActivityExtended__r.id_attivita__c IN: SetIdStr AND  ((Status =\'Non Iniziata\') ) and ActivityExtended__r.id_affidamento__c=null limit 15000';
    //throw new TriggerFactory.TriggerException('JJJJ:'+[Select Id,E_da_affidare__c,id_attivita__c,id_affidamento__c,Status from Task]);
    System.debug('\n QueryOnTasks: ' + queryOnTasks);
    debugStr += '\n QueryOnTasks: ' + queryOnTasks;

    // inizio nuovo codice 14/04/17 inserimento check permission
    if (Utils.cebCheckObjPermission('Task',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Count_of_Events__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Count_of_Tasks__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Durata_Effettiva__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Giorni_Fuori_SLA__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'SLA__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Tipo_esecuzione__c',gd).get('ACCESS')) {
        for (task t : (List<Task>) database.query(queryOnTasks)) {
            idPraticheTemp.add(t.whatID);
        }
    }
    // fine nuovo codice 14/04/17 inserimento check permission
    string queryonPratiche = 'Select id From Pratica__c' + ' Where id in:idPraticheTemp and Stato__c in (\'Bloccata\',\'In Lavorazione\') ';
    debugStr += '\n queryonPratiche: ' + queryonPratiche;

    // inizio nuovo codice 13/04/17 inserimento check permission
    if (Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_inizio_scaduto__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_in_Lavorazione__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Corrente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Scaduto_Corrente__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Strategia_Scaduto__c',gd).get('ACCESS')) {
        for (pratica__c p : (List<pratica__c>) database.query(queryonPratiche)) {
            idPratiche.add(p.id);
        }
    }
    // fine nuovo codice 13/04/17 inserimento check permission
    String QueryAggregateResult = '';
    if (Utils.cebCheckObjPermission('Task',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c',gd).get('ACCESS')
            && Utils.cebCheckObjPermission('Task',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Tipo__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Sotto_Tipo__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Owner_contratto__c',gd).get('ACCESS')) {
        QueryAggregateResult += 'SELECT Count(Id) Conteggio,MAX(Giorni_di_completamento_attivita__c) GiorniCompletamento ,ActivityExtended__r.Tipo__c, ActivityExtended__r.Sotto_Tipo__c,';
        QueryAggregateResult += ' ActivityExtended__r.Owner_contratto__c OwnerContratto FROM Task WHERE';
        QueryAggregateResult += ' ActivityExtended__r.E_da_affidare__c = true AND ActivityExtended__r.id_attivita__c IN: SetIdStr AND whatID in:idPratiche and Status in (\'Non Iniziata\') and ActivityExtended__r.id_affidamento__c=null ';
    }
    if (OptionPickVisibility == 'My_Task') {
        QueryAggregateResult = QueryAggregateResult + ' and ActivityExtended__r.Owner_contratto__c = \'' + NU + '\' ';
        queryOnTasks = ' and ActivityExtended__r.Owner_contratto__c = \'' + NU + '\' ';
    }
    QueryAggregateResult += ' GROUP BY ActivityExtended__r.Tipo__c, ActivityExtended__r.Sotto_Tipo__c, ActivityExtended__r.Owner_contratto__c ORDER By ActivityExtended__r.Tipo__c, ActivityExtended__r.Sotto_Tipo__c,Count(Id) DESC, MAX(ActivityExtended__r.Giorni_Completamento__c) DESC ';
    debugStr += '\n QueryAggregateResult: ' + QueryAggregateResult;
    System.debug('\n TaskSemiAutomaticiAffido, taskAgregateResults()' + '\n Esito: ' + debugStr);
    // inizio nuovo codice 14/04/17 inserimento check permission
    if (Utils.cebCheckObjPermission('Task',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Count_of_Events__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Count_of_Tasks__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Durata_Effettiva__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Giorni_Fuori_SLA__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'SLA__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Tipo_esecuzione__c',gd).get('ACCESS')) {
        return database.query(QueryAggregateResult);
    } else return null;
    // fine nuovo codice 14/04/17 inserimento check permission
}
}