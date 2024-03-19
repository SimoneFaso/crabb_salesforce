/* ---------------------------------------------------------------------------------------------------------------------
Name:            BloccoSbloccoCTRL.cls
Description:     
Test class:      

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
              0.1                                      First Version
14-Sep-2022   0.2      R.Kurti & C.Sanna               Added cebCheckObjPermissions and WITH SECURITY_ENFORCED (security review)
10-Oct-2022   0.3      R.Kurti & C.Sanna               Removed WITH SECURITY ENFORCED and added cebCheckObj and FLS
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class BloccoSbloccoCTRL {

    //inserimenti importi
    public String ScadutoDa { get; set; }
    public String ScadutoA { get; set; }
    public String ScadutoConsolidatoDa { get; set; }
    public String ScadutoConsolidatoA { get; set; }
    public String ScadutoSpeseDa { get; set; }
    public String ScadutoSpeseA { get; set; }
    public String SaldoDa { get; set; }
    public String SaldoA { get; set; }
    public String SaldoConsolidatoDa { get; set; }
    public String SaldoConsolidatoA { get; set; }
    public String SaldoSpeseDa { get; set; }
    public String SaldoSpeseA { get; set; }
    public Decimal DecScadutoDa;
    public Decimal DecScadutoA;
    public Decimal DecScadutoConsolidatoDa;
    public Decimal DecScadutoConsolidatoA;
    public Decimal DecScadutoSpeseDa;
    public Decimal DecScadutoSpeseA;
    public Decimal DecSaldoDa;
    public Decimal DecSaldoA;
    public Decimal DecSaldoConsolidatoDa;
    public Decimal DecSaldoConsolidatoA;
    public Decimal DecSaldoSpeseDa;
    public Decimal DecSaldoSpeseA;
    //controlli di validità sugli input
    public boolean validDaScaduto { get; set; }
    public boolean validAScaduto { get; set; }
    public boolean validDaScadutoConsolidato { get; set; }
    public boolean validAScadutoConsolidato { get; set; }
    public boolean validDaScadutoSpese { get; set; }
    public boolean validAScadutoSpese { get; set; }
    public boolean validDaSaldoSpese { get; set; }
    public boolean validASaldoSpese { get; set; }
    public boolean validDaSaldo { get; set; }
    public boolean validASaldo { get; set; }
    public boolean validDaSaldoConsolidato { get; set; }
    public boolean validASaldoConsolidato { get; set; }

    public boolean ErrorValidateDecimal { get; set; }
    //public list<TabellaPratica> listPraticheSelectable{get;set;}
    public boolean PraticheEsisti { get; set; }
    public boolean PraticheSelEsisti { get; set; }
    public boolean BAllSel { get; set; }
    public string QueryPratica { get; set; }
    public string QueryPraticaPag { get; set; }
    public Map<String, Boolean> MapSelezione;

    public string visibility { get; set; }
    public Integer Step { get; set; }

    //step di inserimento campi blocco/sblocco
    Public String leftselected_Mot_Blo { get; set; }
    Public List<SelectOption> unSelectedValues_Mot_Blo { get; set; }
    Public List<String> originalValues_Mot_Blo { get; set; }
    Public String Note_Blocco { get; set; }
    Public String Note_Sblocco { get; set; }
    public boolean IsBlocco { get; set; }

    Public String leftselected_SelTipo { get; set; }
    Public List<SelectOption> unSelectedValues_SelTipo { get; set; }
    List<String> originalValues_SelTipo = new List<String>();
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    //variabili per gestione paginazione
    Public List<String> LPrimoName { get; set; }
    public transient list<Pratica__c> ListPraticaToView { get; set; }
    public list<Pratica__c> PraticheDaElaborare { get; set; }
    public Integer Indice { get; set; }
    public Integer TotalSize { get; set; }
    public Integer PageSize;
    Public Integer RecXPage;

    // Boolean: Pagina Bianca del errore
    public boolean blankPageFlag { get; set; }
    public boolean ciSonoPraticheDaLavorare { get; set; }
    public boolean isBeginningVisibility { get; set; }
    public boolean IsEndVisibility { get; set; }
    public integer initialTotal { get; set; }

    public string recordsForPage { get {if (recordsForPage == null) return '25'; return recordsForPage;} set; }
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

    public String getleftselected_Mot_Blo() {
        return leftselected_Mot_Blo;
    }

    public void sizeTable() {
        indice = 0;
        RecXPage = integer.valueOf(recordsForPage);
        //ListTabellaAccountSelectable();
    }

    /****** FILTRI ******/
    //ID CONTRATTO
    public List<String> rightValues_IdContratto { get; set; }
    Public List<String> originalValues_IdContratto {
        get {
            set<String> SetIdContratto = new set<String>();
            if (originalValues_IdContratto == null) {
                if(Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Pratica__c', 'Contratto__c',gd).get('ACCESS')
                        && Utils.cebCheckObjPermission('Contratto__c',gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Contratto__c', 'Id_Esterno__c',gd).get('ACCESS'))
                {
                List<Pratica__c> ListaContPrat = new List<Pratica__c>([
                        SELECT Servizio_Fornitura__r.LookupContratto__r.Id_Esterno__c
                        FROM Pratica__c
                        //WITH SECURITY_ENFORCED
                        LIMIT 50000
                ]);
                originalValues_IdContratto = new List<String>();
                for (Pratica__c p : ListaContPrat)
                    SetIdContratto .add(p.Servizio_Fornitura__r.LookupContratto__r.Id_Esterno__c);
            }
            originalValues_IdContratto.addAll(SetIdContratto);
            }
            return originalValues_IdContratto;

        }
        set;
    }

    //COMUNE
    public List<String> rightValues_Comuni { get; set; }
    Public List<String> originalValues_Comuni {
        get {
            set<String> SetComuni = new set<String>();
            if (originalValues_Comuni == null) {
                if (Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Pratica__c', 'Contratto__c',gd).get('ACCESS')
                        && Utils.cebCheckObjPermission('Contratto__c',gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Contratto__c', 'Comune__c',gd).get('ACCESS')) {
                List<Pratica__c> ListaContPrat = new List<Pratica__c>([
                        SELECT Servizio_Fornitura__r.LookupContratto__r.Comune__c
                        FROM Pratica__c
                        //WITH SECURITY_ENFORCED
                        LIMIT 50000
                ]);
                originalValues_Comuni = new List<String>();
                for (Pratica__c p : ListaContPrat)
                    SetComuni .add(p.Servizio_Fornitura__r.LookupContratto__r.Comune__c);
                }
                originalValues_Comuni.addAll(SetComuni);
            }
            return originalValues_Comuni;

        }
        set;
    }

    //CODICE SERVIZIO
    public List<String> rightValues_Servizio { get; set; }
    Public List<String> originalValues_Servizio {
        get {
            if (originalValues_Servizio == null) {
                originalValues_Servizio = CredManUtility.getPicklistValues('Servizio__c', 'Codice__c');
            }
            return originalValues_Servizio;
        }
        set;
    }

    //STATO PRATICA
    public List<String> rightValues_Stato { get; set; }
    Public List<String> originalValues_Stato {
        get {
            List<String> valoriStato = new List<String>();
            if (originalValues_Stato == null) {
                valoriStato = CredManUtility.getPicklistValues('Pratica__c', 'Stato__c');
                originalValues_Stato = new List<String>();
                for (String s : valoriStato) {
                    if (s != 'Bloccata' && s != 'Chiusa')
                        originalValues_Stato.add(s);
                }
            }
            return originalValues_Stato;
        }
        set;
    }

    //CLASSE DI RISCHIO
    public List<String> rightValues_CdR { get; set; }
    Public List<String> originalValues_CdR {
        get {
            set<String> SetCdR = new set<String>();
            if (originalValues_CdR == null) {
                if (Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Pratica__c', 'Classe_di_rischio__c',gd).get('ACCESS')) {
                //List<Pratica__c> ListaContPrat = new List<Pratica__c>([SELECT Classe_di_rischio__c FROM Pratica__c WITH SECURITY_ENFORCED LIMIT 50000]);
                List<Pratica__c> ListaContPrat = new List<Pratica__c>([SELECT Classe_di_rischio__c FROM Pratica__c LIMIT 50000]);
                originalValues_CdR = new List<String>();
                for (Pratica__c p : ListaContPrat)
                    SetCdR .add(p.Classe_di_rischio__c);
                }
            }
            originalValues_CdR.addAll(SetCdR);
            return originalValues_CdR;
        }
        set;
    }


    public void UpdateListe() {
        try {
            String sElenco = Apexpages.currentPage().getParameters().get('ValSelected');
            Integer iIndex = Integer.valueOf(Apexpages.currentPage().getParameters().get('IndexSelected'));
            List<String> elenco = sElenco.split(',');

            if (iIndex == 1) {
                //Id Contratto
                rightValues_IdContratto.clear();
                if (sElenco != '') {
                    for (string s : elenco)
                        rightValues_IdContratto.add(s);
                }
            } else if (iIndex == 2) {
                //Comuni
                rightValues_Comuni.clear();
                if (sElenco != '') {
                    for (string s : elenco)
                        rightValues_Comuni.add(s);
                }
            } else if (iIndex == 3) {
                //Codice servizio
                rightValues_Servizio.clear();
                if (sElenco != '') {
                    for (string s : elenco)
                        rightValues_Servizio.add(s);
                }
            } else if (iIndex == 4) {
                //Stato pratica
                //rightValues_Stato.clear();
                if (sElenco != '') {
                    for (string s : elenco)
                        rightValues_Stato.add(s);
                }
            } else if (iIndex == 5) {
                //Classe di rischio
                rightValues_CdR.clear();
                if (sElenco != '') {
                    for (string s : elenco)
                        rightValues_CdR.add(s);
                }
            }

        } catch (Exception e) {
            String Err = 'Eccezione nel metodo UpdateListe: ' + e.getMessage();
            /*TraceLog.ErrorLog('Crabb_Sollecito', 'UpdateListe', Err, '', '' );
            String LineError = String.ValueOf(e.getLineNumber());*/
        }
    }
    //KM: Metodo per generare e gestire la visibilità delle componenti html della pagina
    private string visibilityConfiguration(string getTags) {
        string visibilityTags = '';
        try {
            if(Utils.cebCheckObjPermission('Page_layout_control__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Page_layout_control__c','Name',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Page_layout_control__c','TagName__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Page_layout_control__c','Page__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Page_layout_control__c','Visible__c',gd).get('ACCESS')){
                //for (Page_layout_control__c c : [Select id, Name, TagName__c From Page_layout_control__c Where Page__c = :getTags and Visible__c = true WITH SECURITY_ENFORCED]) {
                for (Page_layout_control__c c : [Select id, Name, TagName__c From Page_layout_control__c Where Page__c = :getTags and Visible__c = true]) {
                    visibilityTags += '*' + c.TagName__c + '*';
                }
            }
        } catch (Exception e) {

        }
        return visibilityTags;

    }


    public BloccoSbloccoCTRL() {
        Step = -1;
        ScadutoDa = null;
        ScadutoA = null;
        ScadutoConsolidatoDa = null;
        ScadutoConsolidatoA = null;
        ScadutoSpeseDa = null;
        ScadutoSpeseA = null;
        SaldoDa = null;
        SaldoA = null;
        SaldoConsolidatoDa = null;
        SaldoConsolidatoA = null;
        SaldoSpeseDa = null;
        SaldoSpeseA = null;

        ErrorValidateDecimal = false;
        bAllSel = true;

        rightValues_IdContratto = new list<String>();
        rightValues_Comuni = new list<String>();
        rightValues_Servizio = new list<String>();
        rightValues_Stato = new list<String>();
        rightValues_CdR = new list<String>();

        originalValues_Mot_Blo = CredManUtility.getPicklistValues('Pratica__c', 'Motivo_Blocco__c');
        unSelectedValues_Mot_Blo = getunSelectedValues(originalValues_Mot_Blo);
        leftselected_Mot_Blo = '';
        if (Note_Blocco == null)
            Note_Blocco = '';
        Note_Sblocco = '';
        //  originalValues_SelTipo.add('Blocco');
        //  originalValues_SelTipo.add('Sblocco');
        originalValues_SelTipo.add(system.label.lock);
        originalValues_SelTipo.add(system.label.unlock);
        leftselected_SelTipo = '';
        unSelectedValues_SelTipo = getunSelectedValues(originalValues_SelTipo);

        QueryPratica = null;
        Indice = 0;
        MapSelezione = new Map<String, Boolean>();
        RecXPage = 20;

        // pagina del errore
        blankPageFlag = true;
    }


    public void QueryPratiche() {
        String patDecimal = '(^(\\+|\\-)(0|([1-9][0-9]*))(\\.[0-9]{1,2})?$)|(^(0{0,1}|([1-9][0-9]*))(\\.[0-9]{1,2})?$)';

        validDaScaduto = pattern.matches(patDecimal, ScadutoDa);
        validAScaduto = pattern.matches(patDecimal, ScadutoA);
        validDaScadutoConsolidato = pattern.matches(patDecimal, ScadutoConsolidatoDa);
        validAScadutoConsolidato = pattern.matches(patDecimal, ScadutoConsolidatoA);
        //validDaScadutoSpese = pattern.matches(patDecimal, ScadutoSpeseDa);
        //validAScadutoSpese = pattern.matches(patDecimal, ScadutoSpeseA);
        validDaSaldoSpese = pattern.matches(patDecimal, SaldoSpeseDa);
        validASaldoSpese = pattern.matches(patDecimal, SaldoSpeseA);
        validDaSaldoConsolidato = pattern.matches(patDecimal, SaldoConsolidatoDa);
        validASaldoConsolidato = pattern.matches(patDecimal, SaldoConsolidatoA);
        validDaSaldo = pattern.matches(patDecimal, SaldoDa);
        validASaldo = pattern.matches(patDecimal, SaldoA);
        system.debug('****validDaScaduto = ' + validDaScaduto);
        if (!validDaScaduto) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Scaduto Da" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return;
        } else if (!validAScaduto) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Scaduto A" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return;
        } else if (!validDaScadutoConsolidato) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Scaduto Consolidato DA" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return;
        } else if (!validAScadutoConsolidato) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Scaduto Consolidato A" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return;
        }/*else if(!validDaScadutoSpese){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Il campo "Scaduto Spese DA" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return;
        }else if(!validAScadutoSpese){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Il campo "Scaduto Spese A" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return;
        }*/ else if (!validDaSaldo) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Saldo DA" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return;
        } else if (!validASaldo) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Saldo A" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return;
        } else if (!validDaSaldoSpese) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Saldo Spese DA" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return;
        } else if (!validASaldoSpese) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Saldo Spese A" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return;
        } else if (!validDaSaldoConsolidato) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Saldo Consolidato DA" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return;
        } else if (!validASaldoConsolidato) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Saldo Consolidato A" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return;
        }

        //Controllo che gli utenti popolino entrambi gli input Da e A
        if ((ScadutoDa == '' && ScadutoA != '') || (ScadutoA == '' && ScadutoDa != '')) {
            system.debug('Error!');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Specificare entrambi i valori dello Scaduto che si vuole filtrare. '));
            ErrorValidateDecimal = true;
            return;
        }
        if ((ScadutoConsolidatoDa == '' && ScadutoConsolidatoA != '') || (ScadutoConsolidatoA == '' && ScadutoConsolidatoDa != '')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Specificare entrambi i valori dello Scaduto Consolidato che si vuole filtrare.'));
            ErrorValidateDecimal = true;
            return;
        }
        if ((SaldoSpeseDa == '' && SaldoSpeseA != '') || (SaldoSpeseA == '' && SaldoSpeseDa != '')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Specificare entrambi i valori del Saldo Spese che si vuole filtrare.'));
            ErrorValidateDecimal = true;
            return;
        }
        if ((SaldoConsolidatoDa == '' && SaldoConsolidatoA != '') || (SaldoConsolidatoA == '' && SaldoConsolidatoDa != '')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Specificare entrambi i valori del Saldo Consolidato che si vuole filtrare.'));
            ErrorValidateDecimal = true;
            return;
        }
        if ((SaldoDa == '' && SaldoA != '') || (SaldoA == '' && SaldoDa != '')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Specificare entrambi i valori del Saldo che si vuole filtrare.'));
            ErrorValidateDecimal = true;
            return;
        }
        /*if((ScadutoSpeseDa == '' && ScadutoSpeseA != '' ) || (SaldoSpeseA == '' && SaldoSpeseDa != '' )){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Specificare entrambi i valori del Saldo Spese che si vuole filtrare.'));
            ErrorValidateDecimal = true;
            return;
        }*/

        //Verifico che i range siano corretti
        if (ScadutoDa != '' && ScadutoA != '') {
            if (decimal.valueOf(ScadutoDa) > decimal.valueOf(ScadutoA)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Il range di valori del filtro Scaduto non è valido.'));
                ErrorValidateDecimal = true;
                return;
            }
        }
        if (ScadutoConsolidatoDa != '' && ScadutoConsolidatoA != '') {
            if (decimal.valueOf(ScadutoConsolidatoDa) > decimal.valueOf(ScadutoConsolidatoA)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Il range di valori del filtro Scaduto consolidato non è valido.'));
                ErrorValidateDecimal = true;
                return;
            }
        }
        if (SaldoSpeseDa != '' && SaldoSpeseA != '') {
            if (decimal.valueOf(SaldoSpeseDa) > decimal.valueOf(SaldoSpeseA)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Il range di valori del filtro Saldo Spese non è valido.'));
                ErrorValidateDecimal = true;
                return;
            }
        }
        /*if(ScadutoSpeseDa != '' && ScadutoSpeseA != ''){
            if(decimal.valueOf(ScadutoSpeseDa) > decimal.valueOf(ScadutoSpeseA)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Il range di valori del filtro Scaduto Spese non è valido.'));
                ErrorValidateDecimal = true;
                return;
            }
        }*/
        if (SaldoConsolidatoDa != '' && SaldoConsolidatoA != '') {
            if (decimal.valueOf(SaldoConsolidatoDa) > decimal.valueOf(SaldoConsolidatoA)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Il range di valori del filtro Saldo Consolidato non è valido.'));
                ErrorValidateDecimal = true;
                return;
            }
        }
        if (SaldoDa != '' && SaldoA != '') {
            if (decimal.valueOf(SaldoDa) > decimal.valueOf(SaldoA)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Il range di valori del filtro Saldo non è valido.'));
                ErrorValidateDecimal = true;
                return;
            }
        }

        //Costruisco la query
        if (Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Classe_di_rischio__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Contratto__c', 'Id_Esterno__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Contratto__c', 'Comune__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Account__c',gd).get('ACCESS')
                && Utils.cebCheckObjPermission('Account',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Classe_di_rischio__c',gd).get('ACCESS')) {
            QueryPratica = '';
            //listPraticheSelectable = new List<TabellaPratica>();
            system.debug('Preparo la query..');
            /*String allfieldsPratica = CredManUtility.selectall('Pratica__c');
            allfieldsPratica = allfieldsPratica.replaceAll('lastreferenceddate, ', '');*/
            QueryPratica = 'SELECT Id, Name, Stato__c, Servizio_Fornitura__r.LookupContratto__r.Id_Esterno__c,' +
                    ' Servizio_Fornitura__r.LookupContratto__r.Comune__c,' +
                    //' Servizio_Fornitura__r.Codice__c,'+
                    ' Account__r.Classe_di_Rischio__c,' +
                    ' Account__r.Name, Strategia__c ';
            if (leftselected_SelTipo == 'Blocco')
                QueryPratica = QueryPratica + 'FROM Pratica__c WHERE Stato__c != \'Bloccata\' AND';
            else QueryPratica = QueryPratica + 'FROM Pratica__c WHERE Stato__c = \'Bloccata\' AND';

            if (rightValues_IdContratto.size() > 0) {
                QueryPratica = QueryPratica + ' Servizio_Fornitura__r.LookupContratto__r.Id_Esterno__c IN: rightValues_IdContratto AND';
            }
            if (rightValues_Comuni.size() > 0) {
                QueryPratica = QueryPratica + ' Servizio_Fornitura__r.LookupContratto__r.Comune__c IN: rightValues_Comuni AND';
            }
            if (rightValues_Servizio.size() > 0) {
                QueryPratica = QueryPratica + ' Servizio_Fornitura__r.RecordType.Name IN: rightValues_Servizio AND';
            }
            if (rightValues_Stato.size() > 0) {
                QueryPratica = QueryPratica + ' Stato__c IN: rightValues_Stato AND';
            }
            if (rightValues_CdR.size() > 0) {
                QueryPratica = QueryPratica + ' Account__r.Classe_di_Rischio__c IN: rightValues_CdR AND';
            }
            if (ScadutoDa != '' && ScadutoA != '') {
                decScadutoDa = Decimal.valueOf(ScadutoDa);
                decScadutoA = Decimal.valueOf(ScadutoA);
                QueryPratica = QueryPratica + ' Residuo_Totale__c >= :DecScadutoDa AND Residuo_Totale__c <= :DecScadutoA AND';
            }
            if (SaldoDa != '' && SaldoA != '') {
                decSaldoDa = Decimal.valueOf(SaldoDa);
                decSaldoA = Decimal.valueOf(SaldoA);
                QueryPratica = QueryPratica + ' Saldo__c>= :decSaldoDa AND Saldo__c<= :decSaldoA AND';
            }
            if (SaldoConsolidatoDa != '' && SaldoConsolidatoA != '') {
                decSaldoConsolidatoDa = Decimal.valueOf(SaldoConsolidatoDa);
                decSaldoConsolidatoA = Decimal.valueOf(SaldoConsolidatoA);
                QueryPratica = QueryPratica + ' Importo_Saldo_Consolidato__c>= :DecSaldoConsolidatoDa AND Importo_Saldo_Consolidato__c<= :DecSaldoConsolidatoA AND';
            }
            if (ScadutoConsolidatoDa != '' && ScadutoConsolidatoA != '') {
                decScadutoConsolidatoDa = Decimal.valueOf(ScadutoConsolidatoDa);
                decScadutoConsolidatoA = Decimal.valueOf(ScadutoConsolidatoA);
                QueryPratica = QueryPratica + ' Importo_Scaduto_Consolidato__c>= :DecScadutoConsolidatoDa AND Importo_Scaduto_Consolidato__c<= :DecScadutoConsolidatoA AND';
            }
            if (SaldoSpeseDa != '' && SaldoSpeseA != '') {
                decSaldoSpeseDa = Decimal.valueOf(SaldoSpeseDa);
                decSaldoSpeseA = Decimal.valueOf(SaldoSpeseA);
                QueryPratica = QueryPratica + ' Saldo_Spese__c >= :DecSaldoSpeseDa AND Saldo_Spese__c <= :DecSaldoSpeseA AND';
            }
            if (QueryPratica.endsWith(' AND')) {
                QueryPratica = QueryPratica.substring(0, QueryPratica.length() - 4);
            }
            system.debug(logginglevel.INFO, '******QueryPraticaFinal = ' + QueryPratica);
            /*****QUERY*****/
            QueryPraticaPag = QueryPratica + ' AND Name <= :PrimoName ORDER BY NAME DESC LIMIT 20';
            QueryPratica += ' ORDER BY Name DESC';
            ListPraticaToView = database.query(QueryPratica);
            system.debug('***ListPraticaToView = ' + ListPraticaToView.size());
            if (ListPraticaToView.size() > 0)
                PraticheEsisti = true;
            else
                    PraticheEsisti = false;
            QueryPratica = QueryPratica.substring(0, queryPratica.length() - 19);
        }
        LPrimoName = new List<String>();
        for (integer i = 0; i < ListPraticaToView.size(); i++) {
            if (i == 0 || (math.mod(i, RecXPage) == 0))
                LPrimoName.add(ListPraticaToView[i].name);
            MapSelezione.put(ListPraticaToView[i].Name, true);
        }
        TotalSize = MapSelezione.size();
        ListPraticaToView.clear();
        Step++;

    }

    public List<TabellaPratica> getlistPraticheSelectable() {
        system.debug('LPrimoName.size' + LPrimoName.size());
        if (LPrimoName.size() > 0) {
            String PrimoName = LPrimoName[Indice];
            //QueryPraticaPag += ' AND Name < :PrimoName ORDER BY NAME DESC LIMIT 20';}
            // inizio nuovo codice 12/04/17 inserimento cebCheckFLSPermission
            if (Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Anzianit_Pratica__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Check_In_Lavorazione__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Esecuzione_Processo_Mensile__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Blocco__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Chiusura__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Dettaglio_Stato__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Incasso_Consolidato__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Motivo_Blocco__c',gd).get('ACCESS')) {

                List<Pratica__c> ListPraticaToView = database.query(QueryPraticaPag);
                PageSize = ListPraticaToView.size();
                //QueryPratica = QueryPratica.substring(0,queryPratica.length()-66);
                list<TabellaPratica> tempPrat = new list<TabellaPratica>();
                for (Pratica__c p : ListPraticaToView) {
                    boolean bSel;
                    if (MapSelezione.containsKey(p.Name))
                        bSel = true;
                    else
                            bSel = false;
                    system.debug('Boolean bSel = ' + bSel);
                    TabellaPratica PraticaSelect = new TabellaPratica(bSel, p, p.id);
                    system.debug('Primo giro: ' + PraticaSelect);
                    tempPrat.add(PraticaSelect);
                }
                system.debug('tempPrat.size' + tempPrat.size());
                if (tempPrat.size() > 0) {
                    PraticheEsisti = true;
                } else PraticheEsisti = false;
                return tempPrat;
            }
        }
        return null;
    }

    //metodi per gestione paginazione
    public PageReference Beginning() {
        //user clicked beginning
        Indice = 0;
        return null;
    }

    public PageReference Previous() {
        //user clicked previous button
        Indice--;
        return null;
    }

    public PageReference Next() {
        //user clicked next button
        Indice++;
        return null;
    }

    public PageReference End() {
        //user clicked end
        Indice = LPrimoName.size() - 1;
        return null;
    }

    public Boolean getDisablePrevious() {
        //this will disable the previous and beginning buttons
        if (Indice > 0)
            return false;
        else
                return true;
    }

    public Boolean getDisableNext() {
        //this will disable the next and end buttons
        if (PageSize < RecXPage) {
            return true;
        } else
                return false;

    }

    public void Indietro() {

        if (Step == 1) {
            //listPraticheSelectable.clear();
            //PraticheSelEsisti = false;
            /*rightValues_IdContratto.clear();
            rightValues_Comuni.clear();
            rightValues_Servizio.clear();
            rightValues_Stato.clear();
            rightValues_CdR.clear();
            ScadutoDa = null;
            ScadutoA = null;
            ScadutoConsolidatoDa = null;
            ScadutoConsolidatoA = null;
            ScadutoSpeseDa = null;
            ScadutoSpeseA = null;
            SaldoDa = null;
            SaldoA = null;
            SaldoSpeseDa = null;
            SaldoSpeseA = null;
            SaldoConsolidatoDa = null;
            SaldoConsolidatoa = null;*/
            MapSelezione.clear();
            LPrimoName.clear();
        }

        if (Step == 0) {
            isBlocco = null;
            leftselected_SelTipo = null;
        }

        bAllSel = true;

        Indice = 0;
        step--;
    }

    public void ConfermaSelezione() {

        PraticheDaElaborare = new List<Pratica__c>();
        Set<String> NameSet = MapSelezione.keySet();
        // inizio nuovo codice 12/04/17 inserimento cebCheckFLSPermission
        if (Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Anzianit_Pratica__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Check_In_Lavorazione__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Esecuzione_Processo_Mensile__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Blocco__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Chiusura__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Dettaglio_Stato__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Incasso_Consolidato__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Motivo_Blocco__c',gd).get('ACCESS')) {

            String queryConferma = 'Select Id,Name,Strategia__c from Pratica__c where Name in :NameSet';
            PraticheDaElaborare = Database.query(queryConferma);
            /*for(TabellaPratica tb : getlistPraticheSelectable()){
                if(tb.isSelected){
                    PraticheDaElaborare.add(tb.Prat);
                 }
            }*/

            if (PraticheDaElaborare.size() > 0) {
                PraticheSelEsisti = false;
            } else {
                PraticheSelEsisti = true;
            }

            Step++;
            system.debug('Pratiche da elaborare: ' + PraticheDaElaborare);
        }
    }

    public PageReference SelectAll() {
        for (TabellaPratica tb : getlistPraticheSelectable()) {
            tb.isSelected = bAllSel;
            if (MapSelezione.containsKey(tb.Prat.Name) && !bAllSel) {
                MapSelezione.remove(tb.Prat.Name);
            } else if (!MapSelezione.containsKey(tb.Prat.Name) && bAllSel)
                MapSelezione.put(tb.Prat.Name, true);
        }
        TotalSize = MapSelezione.size();
        return null;
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

    public pageReference Blocca() {
        try {
            BloccoSbloccoPratiche BSP = new BloccoSbloccoPratiche();
            system.debug('Motivo Blocco: ' + leftselected_Mot_Blo + ' - Note Blocco: ' + Note_Blocco);
            String BCausale = leftselected_Mot_Blo;
            String BNota = Note_Blocco;
            BSP.BloccaPratiche(PraticheDaElaborare, BCausale, BNota);
            totalsize = PraticheDaElaborare.size();
            step++;
        } catch (Exception e) {
            System.debug('Eccezione nel blocco delle praticge: ' + e.getMessage());
        }
        return null;
    }

    public pageReference Sblocca() {
        try {
            BloccoSbloccoPratiche BSP = new BloccoSbloccoPratiche();
            String SNota = Note_Sblocco;
            BSP.SbloccaPratiche(PraticheDaElaborare, SNota);
            totalsize = PraticheDaElaborare.size();
            step++;
        } catch (Exception e) {
            System.debug('Eccezione nel blocco delle praticge: ' + e.getMessage());
        }
        return null;
    }

    public void Continua() {
        // if(leftselected_SelTipo == 'Blocco')
        if (leftselected_SelTipo == system.label.lock)
            isBlocco = true;
        else isBlocco = false;

        step++;
    }

    public PageReference AggiornaElementoLista() {

        //String Elem = ApexPages.currentPage().getParameters().get('Elem');
        //String Sel = ApexPages.currentPage().getParameters().get('isSel');
        String Sel = (ApexPages.currentPage().getParameters().get('isSel') == null) ? ApexPages.currentPage().getParameters().get('isSel') : ApexPages.currentPage().getParameters().get('isSel').escapeHtml4();

        String Pratica = (ApexPages.currentPage().getParameters().get('Codice_Pratica') == null) ? ApexPages.currentPage().getParameters().get('Codice_Pratica') : ApexPages.currentPage().getParameters().get('Codice_Pratica').escapeHtml4();

        system.debug('Pratica ' + Pratica + 'isSelected: ' + Sel);

        if (MapSelezione.containsKey(Pratica) && Sel == 'true') {
            MapSelezione.remove(Pratica);
        } else if (!MapSelezione.containsKey(Pratica) && Sel == 'false')
            MapSelezione.put(Pratica, true);

        system.debug('Pratica ' + Pratica + 'isSelected: ' + Sel);
        TotalSize = MapSelezione.size();

        return null;

    }
}