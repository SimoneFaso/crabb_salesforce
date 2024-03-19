/* ---------------------------------------------------------------------------------------------------------------------
Name:            GestioneWhiteListCTRL.cls
Description:     Controller per il wizard del gestione dei account su White List
Test class:      TestGestioneWhiteList.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
10-Sep-2014  0.1      E.Sino               First Version
17-Feb-2021   0.2      E.Sino               Used Custom Label for assign/remove whtie list
16-Sep-2022  0.3      R.Kurti & C.Sanna    Added WITH SECURITY ENFORCED  and cebCheckObjPermissions(security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class GestioneWhiteListCTRL {
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public class GestioneWhiteListCTRLException extends Exception {
    }

    public ApexPages.StandardSetController setCon { get; set; }
    /*get{
        if(setCon != null){
            return setCon;
        }

        if(Utils.checkFLSPermission('Account', 'Classe_di_Rischio__c').get('ACCESS')
            && Utils.checkFLSPermission('Account', 'Comune_Contratto__c').get('ACCESS')
            && Utils.checkFLSPermission('Account', 'Stato__c').get('ACCESS')
            && Utils.checkFLSPermission('Account', 'Contratto__c').get('ACCESS')
            && Utils.checkFLSPermission('Contratto__c', 'id_Esterno__c').get('ACCESS')
            && Utils.checkFLSPermission('Account', 'White_List__c').get('ACCESS')) {

            if(isPutInWhiteList != null && !isPutInWhiteList){
                setCon = new ApexPages.StandardSetController(Database.query('SELECT Id,Name, Contratto__r.Id_Esterno__c, Comune_Contratto__c, Stato__c, Classe_di_Rischio__c,White_List__c FROM Account WHERE White_List__c = true ORDER BY Name ASC LIMIT 10000'));
            }else{
                setCon = new ApexPages.StandardSetController(Database.query('SELECT Id,Name, Contratto__r.Id_Esterno__c, Comune_Contratto__c, Stato__c, Classe_di_Rischio__c,White_List__c FROM Account WHERE White_List__c = false ORDER BY Name ASC LIMIT 10000'));
            }
            if(String.isNotBlank(listViewId)) setCon.setFIlterId(listViewId);
            setCon.setPageSize(RecXPage);
            if(String.isNotBlank(listViewId) || (isPutInWhiteList != null && !isPutInWhiteList)){
                initialTotal = setCon.getResultSize();
            }else{
                initialTotal = 0;
            }

            tempSetCon = setCon;
        }
        return setCon;
    }set;
}*/

    public string recordsForPage { get {if (recordsForPage == null) return '25'; return recordsForPage;} set; }

    public integer RecXPage {
        get {
            if (recordsForPage == null) RecXPage = 0;
            else RecXPage = integer.valueOf(recordsForPage);
            return RecXPage;
        }
        set;
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

    public String SaldoMovScadutoDa { get; set; }
    public String SaldoMovScadutoA { get; set; }
    public String SaldoTotaleA { get; set; }
    public String SaldoTotaleDa { get; set; }
    public Date myWhiteListLimit { get; set; }
    public string RagioneWhiteList { get; set; }

    // controlli di validitá per i filtri 
    public Boolean validDaSaldoMovScaduto { get; set; }
    public Boolean validASaldoMovScaduto { get; set; }
    public Boolean validDaSaldoTotale { get; set; }
    public Boolean validASaldoTotale { get; set; }
    public boolean accountEsiste { get; set; }
    public boolean isPutInWhiteList { get; set; }
    public boolean accountSelEsisti { get; set; }

    public String QueryAccount { get; set; }
    public String QueryAccountPag { get; set; }

    public decimal decSaldoMovScadutoDa;
    public decimal decSaldoMovScadutoA;
    public decimal decSaldoTotaleDa;
    public decimal decSaldoTotaleA;

    public transient List<Account> ListAccountToView { get; set; }

    // Usate ance da me E.S.
    public boolean ErrorValidateDecimal { get; set; }
    public boolean BAllSel { get; set; }

    public Map<String, Boolean> MapSelezione;
    public string visibility { get; set; }

    // selezione del tipo d'operazione: Assegna/rimuovi
    Public String leftselected_SelTipo { get; set; }
    Public List<SelectOption> unSelectedValues_SelTipo { get; set; }
    List<String> originalValues_SelTipo = new List<String>();

    // E.S. => Tutte usate
    //variabili per gestione paginazione
    Public List<String> LPrimoName { get; set; }

    public List<Account> AccountDaElaborare { get; set; }
    public Integer Indice { get; set; }
    public Integer TotalSize { get; set; }
    public Integer PageSize;

    // numer totale dei record chiesti nel DB
    public static integer totalRecordsNr;

    /****** FILTRI ******/

    // ID Esterno Contratto (E.S.)
    public list<String> rightvalues_idEsternoContratto { get; set; }
    public List<String> originalvalues_idEsternoContratto { get; set; }/*{
        get{
            set<String> setidEsternoContratto = new Set<String>();
            if(originalvalues_idEsternoContratto == null){
                List<Account> ListConAcc = new List<Account>([Select Contratto__r.id_Esterno__c from Account]);
                originalvalues_idEsternoContratto = new List<String>(); 
                for(account act : ListConAcc)
                    setidEsternoContratto.add(act.Contratto__r.id_Esterno__c);
            }
            originalvalues_idEsternoContratto.addAll(setidEsternoContratto);
            return originalvalues_idEsternoContratto;
        }
        set;
    }*/

    //COMUNE (E.S.)
    public List<String> rightValues_Comuni { get; set; }
    Public List<String> originalValues_Comuni { get; set; }/*{
        get{
            set<String> SetComuni = new set<String>();
            if(originalValues_Comuni == null){
                List<Account> ListAccCom = new List<Account>([Select Comune_Contratto__c from Account]);
                originalValues_comuni = new List<String>();
                for(account act : ListAccCom)
                    setComuni.add(act.Comune_Contratto__c);            
            }
            originalValues_Comuni.addAll(SetComuni);
            return originalValues_Comuni;
            
        }
        set;
    }*/

    //STATO Account (E.S.)
    public List<String> rightValues_Stato { get; set; }
    Public List<String> originalValues_Stato { get; set; }/*{
        get{
            List<String> valoriStato = new List<String>();
            if(originalValues_Stato == null){
                valoriStato  = CredManUtility.getPicklistValues('Account', 'Stato__c');
                originalValues_Stato = new List<String>();
                for(String s : valoriStato){
                    originalValues_Stato.add(s);
                }    
            }
            return originalValues_Stato;
        }
        set;
    }*/

    //CLASSE DI RISCHIO (E.S.)
    public List<String> rightValues_CdR { get; set; }
    Public List<String> originalValues_CdR { get; set; }/*{
        get{
            set<String> SetCdR = new set<String>();
            if(originalValues_CdR == null){
                List<Account> ListaContAcc = new List<Account>([SELECT Classe_di_rischio__c FROM Account]);
                originalValues_CdR = new List<String>();
                for(Account a : ListaContAcc )
                        SetCdR.add(a.Classe_di_rischio__c );
            }
            originalValues_CdR.addAll(SetCdR);
            return originalValues_CdR;
        }
        set;
    }*/

    public List<SelectOption> listViews { get; set; }
    public String listViewId { get; set; }
    public List<Account> accountList { get; set; }
    public Map<String, Boolean> mapIdSelected { get; set; }

    public GestioneWhiteListCTRL() {
        totalsize = 0;


        mapIdSelected = new Map<String, Boolean>();
        accountList = new List<Account>();

        ErrorValidateDecimal = false;
        bAllSel = true;

        rightvalues_idEsternoContratto = new List<String>();
        System.debug('**INIZIATA, costruttore: ');
        rightValues_Comuni = new list<String>();
        rightValues_Stato = new list<String>();
        rightValues_CdR = new list<String>();

        limitQuery = TagHelper.getValueInteger('MaxAccountGestioneWhiteList');

        // E.S.
        //originalValues_SelTipo.add('Assegna White List');
        //originalValues_SelTipo.add('Rimuovi White List');
        originalValues_SelTipo.add(system.label.assign_white_list);
        originalValues_SelTipo.add(system.label.remove_white_list);

        leftselected_SelTipo = '';
        unSelectedValues_SelTipo = getunSelectedValues(originalValues_SelTipo);
        blankPageFlag = true;

        QueryAccount = null;
        Indice = 0;
        MapSelezione = new Map<String, Boolean>();
        recordsSelected = new set<string>();
        recordsUnSelected = new set<string>();
    }

    public void updateAccountList() {
        //setCon = null;
        accountList = new List<Account>();
        mapIdSelected = new Map<String, Boolean>();

        for (Account a : (List<Account>) this.setCon.getRecords()) {
            accountList.add(a);
            mapIdSelected.put(a.Id, true);
        }
        bAllSel = true;
        initialTotal = setCon.getResultSize();

    }

    public void aggiornaElemento() {
        String Sel = ApexPages.currentPage().getParameters().get('sel');
        String Acc = ApexPages.currentPage().getParameters().get('acc');
        if (String.isNotBlank(acc)) {
            if (String.isNotBlank(sel) && sel.equalsIgnoreCase('true')) {
                mapIdSelected.put(acc, false);
            } else {
                mapIdSelected.put(acc, true);
            }
        }
    }

    // ====== Ottimizazzione CLEAN METHs and VARs ===
    public boolean ciSonoAccountDaLavorare { get; set; }
    public boolean thereAreLessThanLimit { get; set; }
    public boolean blankPageFlag { get; set; }

    public integer hawmanyAccountarePresent { get; set; }
    public integer limitQuery;
    public integer initialTotal { get; set; }

    public List<TAccount> listAccountSelectable { get; set; }

    public set<string> recordsSelected;
    public set<string> recordsUnSelected;

    public integer getNumberOfSelectedRecords() {
        Integer countRecords = 0;
        for (String ss : mapIdSelected.keySet()) {
            if (mapIdSelected.get(ss) == true) {
                countRecords++;
            }
        }
        //return recordsSelected.size();
        return countRecords;
    }

    public void sizeTable() {
        indice = 0;
        RecXPage = integer.valueOf(recordsForPage);
        this.setCon.setPageSize(RecXPage);
        updateAccountList();
        //ListTabellaAccountSelectable();
    }

    // salva i affidamenti selezionati, durante le varie percorsi del utente
    // su il wizard
    public void saveState() {
        if (listAccountSelectable != null && listAccountSelectable.size() > 0) {
            for (TAccount tb : listAccountSelectable) {
                if (tb.isSelected) {
                    recordsSelected.add(tb.Acc.id);
                    recordsUnSelected.remove(tb.Acc.id);
                } else {
                    recordsSelected.remove(tb.Acc.id);
                    recordsUnSelected.add(tb.Acc.id);
                }
            }
        }

    }

    public void ListTabellaAccountSelectable() {
        System.debug('\n 1) met.ListTabellaAccountSelectable, bAllSel = ' + bAllSel);

        QueryAccountPag = String.escapeSinglequotes(QueryAccountPag);
        recXPage = Integer.ValueOf(String.escapeSinglequotes(String.Valueof(recXPage)));
        indice = Integer.ValueOf(String.escapeSinglequotes(String.Valueof(indice)));
        // inizio nuovo codice 13/04/17 inserimento check permission
        if (Utils.cebCheckObjPermission('Account', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Classe_di_Rischio__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Comune_Contratto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Contratto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Contratto__c', 'id_Esterno__c', gd).get('ACCESS')) {
            List<Account> listAccountiToView = Database.Query(String.escapeSingleQuotes(QueryAccountPag + ' Order by Name Desc Limit ' + recXPage + ' OFFSET ' + (indice * recXPage)));

            List<TAccount> tempacc = new List<TAccount>();
            for (Account acc : listAccountiToView) {
                System.debug('\n Acc: ' + acc);
                // secondo il bAllSel, se si desidera di visualizzare piu record, si compila il campo boolean           
                if (bAllSel) {
                    if (!recordsSelected.contains(acc.id) && !recordsUnSelected.contains(acc.id)) {
                        recordsSelected.add(acc.id);
                    }
                    TAccount accidSelect;
                    if (recordsSelected.contains(acc.id)) accidSelect = new TAccount(true, acc);
                    else accidSelect = new TAccount(false, acc);
                    System.debug('\n ***accidSelect: ' + accidSelect);
                    tempacc.add(accidSelect);
                } else {
                    if (!recordsSelected.contains(acc.id) && !recordsUnSelected.contains(acc.id)) {
                        recordsUnSelected.add(acc.id);
                    }
                    TAccount accidSelect;
                    if (recordsUnSelected.contains(acc.id)) accidSelect = new TAccount(false, acc);
                    else accidSelect = new TAccount(true, acc);
                    System.debug('\n ***accidSelect: ' + accidSelect);
                    tempacc.add(accidSelect);
                }
            }

            if (tempacc.size() > 0) {
                AccountEsiste = true;
            } else AccountEsiste = false;
            listAccountSelectable = tempacc;
        }
        // fine nuovo codice 13/04/17 inserimento check permission       
    }

    Public void reduceFilters() {

        List<Account> accList;
        if (Utils.cebCheckObjPermission('Account', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Account', 'Classe_di_Rischio__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Comune_Contratto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'White_List__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Contratto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Contratto__c', 'id_Esterno__c', gd).get('ACCESS')) {
            if (isPutInWhiteList) accList = [
                    Select id, Name, Contratto__r.id_Esterno__c, Comune_Contratto__c, Classe_di_Rischio__c, Stato__c
                    from Account
                    Where White_List__c = false
                    //WITH SECURITY_ENFORCED
                    limit :LimitQuery
            ];
            else accList = [
                    Select id, Name, Contratto__r.id_Esterno__c, Comune_Contratto__c, Classe_di_Rischio__c, Stato__c
                    from Account
                    Where White_List__c = true
                    //WITH SECURITY_ENFORCED
                    limit :LimitQuery
            ];

            System.debug('debug test');
            if (String.isNotBlank(listViewId) || !isPutInWhiteList) {
                accountList = accList;
                mapIdSelected.clear();
            }

            hawmanyAccountarePresent = accList.size();
            if (hawmanyAccountarePresent > 0) ciSonoAccountDaLavorare = true;
            else ciSonoAccountDaLavorare = false;

            thereAreLessThanLimit = (hawmanyAccountarePresent < LimitQuery);
            System.debug('\n *Red Filters: AccList Size = ' + hawmanyAccountarePresent);
            System.debug('\n ***Resuscita dei filtri: ' + accList + '\n Totale: ' + hawmanyAccountarePresent);
            //if(thereAreLessThanLimit){
            set<String> setContratti = new set<String>();
            set<String> setComuni = new set<String>();
            set<String> setClassiDiRischio = new set<String>();

            for (Account a : accList) {
                setContratti.add(a.Contratto__r.id_Esterno__c);
                setComuni.add(a.Comune_Contratto__c);
                setClassiDiRischio.add(a.Classe_di_Rischio__c);
                mapIdSelected.put(a.Id, true);
            }
            originalvalues_idEsternoContratto = new List<String>();
            originalvalues_idEsternoContratto.addAll(setContratti);

            originalValues_Comuni = new List<String>();
            originalValues_Comuni.addAll(setComuni);

            originalValues_Stato = new List<String>();
            originalValues_Stato = CredManUtility.getPicklistValues('Account', 'Stato__c');

            originalValues_CdR = new List<String>();
            originalValues_CdR.addAll(setClassiDiRischio);
            //}
        }
    }
    // Metodo per confermare le liste scelte del utente nei filtri rispettivi
    public void UpdateListe() {
        try {

            String sElenco = Apexpages.currentPage().getParameters().get('ValSelected');

            Integer iIndex = Integer.valueOf(Apexpages.currentPage().getParameters().get('IndexSelected'));
            List<String> elenco = sElenco.split(',');

            if (iIndex == 1) {
                //Id Contratto
                rightvalues_idEsternoContratto.clear();
                if (sElenco != '') {
                    for (string s : elenco)
                        rightvalues_idEsternoContratto.add(s);
                }
            } else if (iIndex == 2) {
                //Comuni
                rightValues_Comuni.clear();
                if (sElenco != '') {
                    for (string s : elenco)
                        rightValues_Comuni.add(s);
                }
            } else if (iIndex == 4) {
                //Stato pratica
                rightValues_Stato.clear();
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
                    && Utils.cebCheckFLSPermission('Page_layout_control__c','Visible__c',gd).get('ACCESS')) {
                for (Page_layout_control__c c : [
                        Select id, Name, TagName__c
                        From Page_layout_control__c
                        Where Page__c = :getTags and Visible__c = true
                        //WITH SECURITY_ENFORCED
                ]) {
                    visibilityTags += '*' + c.TagName__c + '*';
                }
            }
        } catch (Exception e) {

        }
        return visibilityTags;
    }

    public integer QueryAccount() {
        /*String patDecimal = '(^(\\+|\\-)(0|([1-9][0-9]*))(\\.[0-9]{1,2})?$)|(^(0{0,1}|([1-9][0-9]*))(\\.[0-9]{1,2})?$)';
        
        // 1. Controllo la validitá dei dati inseriti dal Utente
        validDaSaldoMovScaduto = pattern.matches(patDecimal, SaldoMovScadutoDa);
        validASaldoMovScaduto = pattern.matches(patDecimal, SaldoMovScadutoA);
        validDaSaldoTotale = pattern.matches(patDecimal, SaldoTotaleDa);
        validASaldoTotale = pattern.matches(patDecimal, SaldoTotaleA);
        
        if(!validDaSaldoMovScaduto){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Il campo "Saldo Movimento Scaduto Da" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return 1;
        }else if(!validASaldoMovScaduto){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Il campo "Saldo Movimento Scaduto A" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return 1;
        }else if(!validDaSaldoTotale){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Il campo "Saldo Totale DA" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return 1;
        }else if(!validASaldoTotale){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Il campo "Saldo Totale A" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return 1;
        }   
        // 2. Controllo che l'utente inserisce entrambi valori input Da-A
        //Controllo che gli utenti popolino entrambi gli input Da e A
        if((SaldoMovScadutoDa == '' && SaldoMovScadutoA != '' ) || (SaldoMovScadutoA == '' && SaldoMovScadutoDa != '')){
            system.debug('Error!');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Specificare entrambi i valori dello Saldo Movimento Scaduto che si vuole filtrare. '));
            ErrorValidateDecimal = true;
            return 1;    
        }
        if((SaldoTotaleDa == '' && SaldoTotaleA != '') || (SaldoTotaleA == '' && SaldoTotaleDa != '')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Specificare entrambi i valori dello Saldo Totale che si vuole filtrare.'));
            ErrorValidateDecimal = true;
            return 1;
        }
        
        // 3. Verifico che i range siano corretti
        if(SaldoMovScadutoDa != '' && SaldoMovScadutoA != ''){
            if(decimal.valueOf(SaldoMovScadutoDa) > decimal.valueOf(SaldoMovScadutoA)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Il range di valori del filtro di Saldo Movimento Scaduto non è valido.'));
                ErrorValidateDecimal = true;
                return 1;
            }
        }
        if(SaldoTotaleDa != '' && SaldoTotaleA != ''){
            if(decimal.valueOf(SaldoTotaleDa) > decimal.valueOf(SaldoTotaleA)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Il range di valori del filtro Saldo Totale non è valido.'));
                ErrorValidateDecimal = true;
                return 1;
            }
        }*/

        // 4. Costruisco il query
        QueryAccount = '';
        system.debug('Preparo la query..');
        if (Utils.cebCheckObjPermission('Account', gd).get('ACCESS')
                && Utils.checkFLSPermission('Account', 'Classe_di_Rischio__c').get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Comune_Contratto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Contratto__c', gd).get('ACCESS')
                && Utils.cebCheckObjPermission('Contratto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Contratto__c', 'id_Esterno__c', gd).get('ACCESS')) {
            QueryAccount = 'SELECT id, Name, Stato__c, Classe_di_Rischio__c, Contratto__r.id_Esterno__c, Comune_Contratto__c ';

            // 4.1 Se vogliamo inserire un account su White List
            if (leftselected_SelTipo == 'Assegna White List')
                QueryAccount = QueryAccount + 'FROM Account WHERE White_List__c = false AND';
            else QueryAccount = QueryAccount + 'FROM Account WHERE White_List__c = true AND';

            if (rightvalues_idEsternoContratto != null && rightvalues_idEsternoContratto.size() > 0) {
                QueryAccount = QueryAccount + ' Contratto__r.id_Esterno__c IN: rightvalues_idEsternoContratto AND';
            }
            if (rightValues_Comuni != null && rightValues_Comuni.size() > 0) {
                QueryAccount = QueryAccount + ' Comune_Contratto__c IN: rightValues_Comuni AND';
            }
            if (rightValues_Stato != null && rightValues_Stato.size() > 0) {
                QueryAccount = QueryAccount + ' Stato__c IN: rightValues_Stato AND';
            }

            // anche la Classe di Rischio
            if (rightValues_CdR != null && rightValues_CdR.size() > 0) {
                QueryAccount = QueryAccount + ' Classe_di_Rischio__c IN: rightValues_CdR AND';
            }

            // 4.3 Considerare le intervali del SaldoMovScad & SaldoTotale
            /*if(SaldoMovScadutoDa!= '' && SaldoMovScadutoA!=''){
                decSaldoMovScadutoDa = Decimal.valueOf(SaldoMovScadutoDa);
                decSaldoMovScadutoA = Decimal.valueOf(SaldoMovScadutoA);
                QueryAccount=QueryAccount+' Saldo_Movimenti_Scaduti__c>= :decSaldoMovScadutoDa AND Saldo_Movimenti_Scaduti__c<= :decSaldoMovScadutoA AND';
            }
            if(SaldoTotaleDa!= '' && SaldoTotaleA!=''){
                decSaldoTotaleDa = Decimal.valueOf(SaldoTotaleDa);
                decSaldoTotaleA = Decimal.valueOf(SaldoTotaleA);
                QueryAccount=QueryAccount+' Saldo_Totale__c>= :decSaldoTotaleDa AND Saldo_Totale__c<= :decSaldoTotaleA AND';
            }*/
            // remove last ' AND' token
            if (QueryAccount.endsWith(' AND')) {
                QueryAccount = QueryAccount.substring(0, QueryAccount.length() - 4);
            }
            System.Debug('\n Query dopo le condizioni: ' + QueryAccount);
            QueryAccountPag = QueryAccount; // Here I save the query generated by filters. So is possible to use Offeset and limits with it

            // 5.Prendi l'account dal DB
            QueryAccount += ' ORDER BY Name DESC limit : limitQuery';

            ListAccountToView = Database.Query(QueryAccount);
            initialTotal = (setCon != null) ? setCon.getResultSize() : 0;
            TotalSize = initialTotal;
            System.debug('Nr. Acc Selezionati: ' + initialTotal);
        }
        if (TotalSize > 0) {
            accountEsiste = true;
            //Meti check by default i accidamenti chiesti dal DB
            /*for(Account acc:ListAccountToView){
                recordsSelected.add(acc.id);
            }*/
            updateAccountList();
            //ListAccountToView.clear();
            //ListTabellaAccountSelectable();
        } else
                accountEsiste = false;
        return 0;
    }

    // chiamata dopo un check di un singolo account
    public void AggiornaelementoLista() {
        /*String Sel = ApexPages.currentPage().getParameters().get('isSel');
        String Acc = ApexPages.currentPage().getParameters().get('Codice_Account');*/
        String Sel = (ApexPages.currentPage().getParameters().get('isSel') == null) ? ApexPages.currentPage().getParameters().get('isSel') : ApexPages.currentPage().getParameters().get('isSel').escapeHtml4();

        String Acc = (ApexPages.currentPage().getParameters().get('Codice_Account') == null) ? ApexPages.currentPage().getParameters().get('Codice_Account') : ApexPages.currentPage().getParameters().get('Codice_Account').escapeHtml4();

        system.debug('\n AccountID ' + Acc + '\n isSelected: ' + Sel + '\n Is AllSelected:' + bAllSel);

        if (recordsSelected.contains(Acc) && Sel == 'true')
            recordsSelected.remove(Acc);
        else if (!recordsSelected.contains(Acc) && Sel == 'false')
            recordsSelected.add(Acc);
    }

    public void ConfermaSelezione() {
        AccountDaElaborare = new List<Account>();
        //Set<String> NameSet = recordsSelected;
        Set<String> NameSet = new Set<String>();
        for (String sel : mapIdSelected.keySet()) {
            if (mapIdSelected.get(sel)) {
                NameSet.add(sel);
            }
        }
        if (Utils.cebCheckObjPermission('Account', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Ragione_WhiteList__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Inizio_White_List__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'White_List__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Limite_WhiteList__c', gd).get('ACCESS')) {
            String queryConferma = 'Select id, Name,Ragione_WhiteList__c,Inizio_White_List__c,White_List__c,Limite_WhiteList__c, Contratto__c from Account where id in :NameSet';
            AccountDaElaborare = Database.query(queryConferma);

            if (AccountDaElaborare.size() > 0) {
                accountSelEsisti = false; System.debug('\n Metodo Conferma selezione == \n **Affidamenti selezionati: ' + AccountDaElaborare + '\n Nameset: ' + recordsSelected + '\n Flag NumberOfSelectedRecords: ' + getNumberOfSelectedRecords());
            } else {
                accountSelEsisti = true;
            }

            TotalSize = AccountDaElaborare.size();
            System.debug('\n Query: ' + queryConferma + '\n Scelti ' + totalsize + ' account! ****');
        }
    }
    public void SelectAll() {
        if (bAllSel) {
            //recordsSelected.addAll(recordsUnSelected);
            //recordsUnSelected=new set<string>();
            for (String str : mapIdSelected.keySet()) {
                mapIdSelected.put(str, true);
            }

        } else {
            //recordsUnSelected.addAll(recordsSelected);           
            //recordsSelected=new set<string>();
            for (String str : mapIdSelected.keySet()) {
                mapIdSelected.put(str, false);
            }
        }

        /*for(TAccount  tb : listAccountSelectable){
            tb.isSelected = bAllSel;
        }*/
    }

    public void setFilterView() {
        this.setCon.setFilterId(listViewId);
        updateAccountList();
    }

    // il tipo del operazione che vuole procedere l'utente
    public PageReference Continua() {
        blankPageFlag = false;

        //if(leftselected_SelTipo == 'Assegna White List'){
        if (leftselected_SelTipo == system.label.assign_white_list) {
            setCon = new ApexPages.StandardSetController(Database.getqueryLocator('SELECT Id,Name, Contratto__r.Id_Esterno__c, Comune_Contratto__c, Stato__c, Classe_di_Rischio__c,White_List__c FROM Account WHERE White_List__c = false ORDER BY Name ASC LIMIT 10000'));
            isPutInWhiteList = true;
            setCon.setPageSize(RecXPage);
        } else {
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator('SELECT Id,Name, Contratto__r.Id_Esterno__c, Comune_Contratto__c, Stato__c, Classe_di_Rischio__c,White_List__c FROM Account WHERE White_List__c = true ORDER BY Name ASC LIMIT 10000'));
            isPutInWhiteList = false;
            setCon.setPageSize(RecXPage);
        }

        if (!isPutInWhiteList) {
            initialTotal = setCon.getResultSize();
        } else {
            initialTotal = 0;
        }

        listViews = new List<SelectOption>();
        listViews.add(new SelectOption('', ''));
        listViews.addAll(setCon.getListViewOptions());
        setCon.setPageSize(RecXPage);

        /*if(leftselected_SelTipo == 'Assegna White List') // leftselected_SelTipo=> Simbolizza la comanda del utente per mettere un record in White List
            isPutInWhiteList= true;
        else isPutInWhiteList= false;*/
        ReduceFilters();
        bAllSel = true;
        QueryAccount();
        return Page.gestioneWhiteList_3;
        //return Page.gestioneWhiteList_2;
    }

    // metodi pageReference, per navigare il wizard con il bottone indietro
    // *Metodi Indietro****
    // Torna su step 1: Seleziona tipo operazione
    public pageReference GestioneWHLStepTipoOp() {
        leftselected_SelTipo = '';
        PageReference pageRef = new PageReference('/apex/GestioneWhiteList');
        pageRef.setRedirect(true);
        return pageRef;
    }

    // Torna su step 2: Imposta FIltri
    public pageReference GestioneWHLStepFiltri() {
        indietro();
        leftselected_SelTipo = null;
        return page.GestioneWhiteList;
    }

    // Vai su step 3: Seleziona 
    public pageReference GestioneWHLStepSelAcct() {
        return page.gestioneWhitelist_3;
    }

    // **Metodi Avanti****
    public pageReference Filtra() {
        System.debug('\n Filtrando acct. ');
        bAllSel = true;
        if (QueryAccount() == 1) return null;
        else return page.gestioneWhiteList_3;
    }

    public pagereference gestioneWhiteListStep4() {
        saveState();
        System.debug('\n Metodo gestioneWhiteListStep4 => Next meth: Conferma selezione');
        ConfermaSelezione();
        if (getNumberOfSelectedRecords() == 0 || getNumberOfSelectedRecords() == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, 'Devi selezionare almeno un Account per poter procedere con questo operazione.'));
            return null;
        }
        System.debug('\n AccountSelEsisti: ' + AccountSelEsisti + '\n isPutInWhiteList: ' + isPutInWhiteList);
        return Page.GestioneWhiteList_4;
    }


    //metodi per gestione paginazione
    /*public void Beginning() {saveState(); Indice = 0; ListTabellaAccountSelectable();  }
    public void Previous() {saveState(); if(indice>0){ Indice--;  ListTabellaAccountSelectable();   }}
    public void Next()  {saveState(); if(recXPage<initialTotal && indice*recXPage<initialTotal){ Indice++;  ListTabellaAccountSelectable(); } }
    public void End() {saveState(); indice=integer.valueof(initialTotal/recXPage );   ListTabellaAccountSelectable();}*/

    public Integer index { get; set; }

    public void Beginning() {
        this.setCon.first(); updateForPagination();
    }
    public void Previous() {
        this.setCon.previous(); updateForPagination();
    }
    public void Next() {
        this.setCon.next(); updateForPagination();
    }
    public void End() {
        this.setCon.last(); updateForPagination();
    }

    public void updateForPagination() {
        bAllSel = true;
        accountList = new List<Account>();
        mapIdSelected = new Map<String, Boolean>();
        for (Account a : (List<Account>) setCon.getRecords()) {
            accountList.add(a);
            mapIdSelected.put(a.Id, true);
        }

    }

    public Boolean getIsBeginningVisibility() {
        return accountList.size() > 0 && setCon.getHasPrevious();
    }

    public Boolean getIsEndVisibility() {
        return accountList.size() > 0 && setCon.getHasNext();
    }

    /* public boolean getIsBeginningVisibility(){ return indice>0;}
     public boolean getIsEndVisibility(){
             if(recXPage>=initialTotal) return false;
             return indice<integer.valueof(initialTotal/recXPage );}*/

    // === fine ottimi

    public pageReference Indietro() {
        System.debug('\n met. Indietro()=> \n a) Sbianca Filtri \n b) Chiama reduceFilters()');

        SaldoMovScadutoDa = null;
        SaldoMovScadutoA = null;
        SaldoTotaleA = null;
        SaldoTotaleDa = null;

        rightValues_CdR = null;
        rightValues_Comuni = null;
        rightvalues_idEsternoContratto = null;
        rightValues_Stato = null;
        reduceFilters();

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

    // E.S. => Il metodo ottimazzato per manipolare il flag White_List__c delle account.
    // * inoltre, mettere anche la data del inizio White List(Data messa in automatico)
    //   & La data Limite_White_List__c, impostata dal operatore

    public pageReference mettiInWhL() {//ASSEGNA WHITE LIST
        try {
            if (myWhiteListLimit == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, '*La data scadenza WhiteList, é obbligatoria!'));
                return page.GestioneWhiteList_4;
            }
            List<Account> accountToAdd = new List<Account>();
            for (Account acc : accountList) {
                if (mapIdSelected.containsKey(acc.Id) && mapIdSelected.get(acc.Id) == true) {
                    accountToAdd.add(acc);
                }
            }
            MettiRimuoviDaWhList mettiWLinstance = new MettiRimuoviDaWhList();
            mettiWLinstance.mettiAccSuWhList(accountToAdd, myWhiteListLimit, RagioneWhiteList);
            TotalSize = accountToAdd.size();
            System.debug('\n Totale: ' + accountToAdd.size() + '\n Account: ' + accountToAdd);

        } catch (Exception e) {
            System.debug('Eccezione nel impostazione su WhiteList delle account: ' + e.getMessage());
        }
        return page.GestioneWhiteList_5;
    }

    public pageReference rimuoviDaWhL() {//RIMUOVI WHITELIST
        try {
            MettiRimuoviDaWhList mettiWLinstance = new MettiRimuoviDaWhList();
            List<Account> accountToRemove = new List<Account>();
            for (Account acc : accountList) {
                if (mapIdSelected.containsKey(acc.Id) && mapIdSelected.get(acc.Id) == true) {
                    accountToRemove.add(acc);
                }
            }
            mettiWLinstance.rimuoviAccDaWhList(accountToRemove);
            TotalSize = accountToRemove.size();
            System.debug('\n Totale: ' + accountToRemove.size() + '\n Account: ' + accountToRemove);

        } catch (Exception e) {
            System.debug('Eccezione rimuovendo da WhiteList delle account: ' + e.getMessage());
        }
        return page.GestioneWhiteList_5;
    }

    // wrap class
    public with sharing class TAccount implements Attributeable {
        public boolean isSelected { get; set; }
        public Account Acc { get; set; }
        public Id idAcc { get; set; }

        public TAccount(Boolean isSelected, Account acc) {
            this.acc = acc;
            this.isSelected = isSelected;
        }
    }
}