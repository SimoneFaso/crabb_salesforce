/* ---------------------------------------------------------------------------------------------------------------------
Name:            GestioneWhiteListPageCTRL.cls
Description:
Test class:      TestGestioneWhiteList.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
              0.1     E.Sino                     First Version
16-Sep-2022   0.2     R.Kurti & C.Sanna     Added WITH SECURITY ENFORCED  and cebCheckObjPermissions(security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class GestioneWhiteListPageCTRL {
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    /* E.S. Funzionalitá White List Massivo
     *  Var usati dal implementazione da ENDRIT
    */
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
    public boolean isPutInWhiteList { get; set; }// E.S. Ancora non so se sará la stessa logica di usarlo come isBlocco
    public boolean accountSelEsisti { get; set; }

    public String QueryAccount { get; set; }
    public String QueryAccountPag { get; set; }

    public decimal decSaldoMovScadutoDa;
    public decimal decSaldoMovScadutoA;
    public decimal decSaldoTotaleDa;
    public decimal decSaldoTotaleA;


    public list<Account> ListAccountSelectable;
    // E.S. var per la gestione di paginazione
    public transient List<Account> ListAccountToView { get; set; }

    // Usate ance da me E.S.
    public boolean ErrorValidateDecimal { get; set; }
    public boolean BAllSel { get; set; }

    public Map<String, Boolean> MapSelezione;
    public string visibility { get; set; }
    public Integer Step { get; set; }

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
    Public Integer RecXPage;

    // numer totale dei record chiesti nel DB
    public static integer totalRecordsNr;

    /****** FILTRI ******/

    // ID Esterno Contratto (E.S.)
    public list<String> rightvalues_idEsternoContratto { get; set; }
    public List<String> originalvalues_idEsternoContratto {
        get {
            set<String> setidEsternoContratto = new Set<String>();
            if (originalvalues_idEsternoContratto == null) {
                if (Utils.cebCheckObjPermission('Account', gd).get('ACCESS')
                        && Utils.cebCheckObjPermission('Contratto__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Account', 'Contratto__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Contratto__c', 'id_Esterno__c', gd).get('ACCESS')) {
                    //List<Account> ListConAcc = new List<Account>([Select Contratto__r.id_Esterno__c from Account WITH SECURITY_ENFORCED LIMIT 50000]);
                    List<Account> ListConAcc = new List<Account>([Select Contratto__r.id_Esterno__c from Account LIMIT 50000]);

                    originalvalues_idEsternoContratto = new List<String>();
                    for (account act : ListConAcc)
                        setidEsternoContratto.add(act.Contratto__r.id_Esterno__c);
                }
            }
            originalvalues_idEsternoContratto.addAll(setidEsternoContratto);
            return originalvalues_idEsternoContratto;
        }
        set;
    }

    //COMUNE (E.S.)
    public List<String> rightValues_Comuni { get; set; }
    Public List<String> originalValues_Comuni {
        get {
            set<String> SetComuni = new set<String>();
            if (originalValues_Comuni == null) {
                if (Utils.cebCheckObjPermission('Account', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Account', 'Comune_Contratto__c', gd).get('ACCESS')) {
                    //List<Account> ListAccCom = new List<Account>([Select Comune_Contratto__c from Account WITH SECURITY_ENFORCED LIMIT 50000]);
                    List<Account> ListAccCom = new List<Account>([Select Comune_Contratto__c from Account LIMIT 50000]);

                    originalValues_comuni = new List<String>();
                    for (account act : ListAccCom)
                        setComuni.add(act.Comune_Contratto__c);
                }
            }
            originalValues_Comuni.addAll(SetComuni);
            return originalValues_Comuni;

        }
        set;
    }

    //STATO PRATICA (E.S.)
    public List<String> rightValues_Stato { get; set; }
    Public List<String> originalValues_Stato {
        get {
            List<String> valoriStato = new List<String>();
            if (originalValues_Stato == null) {
                valoriStato = CredManUtility.getPicklistValues('Account', 'Stato__c');
                originalValues_Stato = new List<String>();
                for (String s : valoriStato) {
                    originalValues_Stato.add(s);
                }
            }
            return originalValues_Stato;
        }
        set;
    }

    //CLASSE DI RISCHIO (E.S.)
    public List<String> rightValues_CdR { get; set; }
    Public List<String> originalValues_CdR {
        get {
            set<String> SetCdR = new set<String>();
            if (originalValues_CdR == null) {
                if (Utils.cebCheckObjPermission('Account', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Account', 'Classe_di_rischio__c', gd).get('ACCESS')) {
                    List<Account> ListaContAcc = new List<Account>([SELECT Classe_di_rischio__c FROM Account Limit 20]);
                    //List<Account> ListaContAcc = new List<Account>([SELECT Classe_di_rischio__c FROM Account WITH SECURITY_ENFORCED Limit 20]);
                    originalValues_CdR = new List<String>();
                    for (Account a : ListaContAcc)
                        SetCdR.add(a.Classe_di_rischio__c);

                }
            }
            originalValues_CdR.addAll(SetCdR);
            return originalValues_CdR;
        }
        set;
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
                    System.debug('*DOPO LA UPDATE DELLE LISTE:' + rightvalues_idEsternoContratto);
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
            if (Utils.cebCheckObjPermission('Page_layout_control__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Page_layout_control__c', 'Name', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Page_layout_control__c', 'TagName__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Page_layout_control__c', 'Page__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Page_layout_control__c', 'Visible__c', gd).get('ACCESS')) {
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

    public GestioneWhiteListPageCTRL() {
        Step = -1;

        ErrorValidateDecimal = false;
        bAllSel = true;

        rightvalues_idEsternoContratto = new List<String>();//AGGIUNTA (E.S.)
        System.debug('**INIZIATA: ' + rightvalues_idEsternoContratto);
        rightValues_Comuni = new list<String>();
        rightValues_Stato = new list<String>();
        rightValues_CdR = new list<String>();

        // E.S.
        //originalValues_SelTipo.add('Assegna White List');
        //originalValues_SelTipo.add('Rimuovi White List');
        originalValues_SelTipo.add(system.label.assign_white_list);
        originalValues_SelTipo.add(system.label.remove_white_list);
        leftselected_SelTipo = '';
        unSelectedValues_SelTipo = getunSelectedValues(originalValues_SelTipo);

        QueryAccount = null;
        Indice = 0;
        MapSelezione = new Map<String, Boolean>();
        RecXPage = 20;

    }

    /*
    *   Endrit: White List Massivo Feature(E.S.)
    *
    */
    // Il funzione per prendere dal DB le Account desiderati
    public void QueryAccount() {
        String patDecimal = '(^(\\+|\\-)(0|([1-9][0-9]*))(\\.[0-9]{1,2})?$)|(^(0{0,1}|([1-9][0-9]*))(\\.[0-9]{1,2})?$)';

        // 1. Controllo la validitá dei dati inseriti dal Utente
        validDaSaldoMovScaduto = pattern.matches(patDecimal, SaldoMovScadutoDa);
        validASaldoMovScaduto = pattern.matches(patDecimal, SaldoMovScadutoA);
        validDaSaldoTotale = pattern.matches(patDecimal, SaldoTotaleDa);
        validASaldoTotale = pattern.matches(patDecimal, SaldoTotaleA);

        if (!validDaSaldoMovScaduto) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Saldo Movimento Scaduto Da" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return;
        } else if (!validASaldoMovScaduto) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Saldo Movimento Scaduto A" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return;
        } else if (!validDaSaldoTotale) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Saldo Totale DA" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return;
        } else if (!validASaldoTotale) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il campo "Saldo Totale A" necessita un valore numerico o decimale. '));
            ErrorValidateDecimal = true;
            return;
        }
        // 2. Controllo che l'utente inserisce entrambi valori input Da-A
        //Controllo che gli utenti popolino entrambi gli input Da e A
        if ((SaldoMovScadutoDa == '' && SaldoMovScadutoA != '') || (SaldoMovScadutoA == '' && SaldoMovScadutoDa != '')) {
            system.debug('Error!');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Specificare entrambi i valori dello Saldo Movimento Scaduto che si vuole filtrare. '));
            ErrorValidateDecimal = true;
            return;
        }
        if ((SaldoTotaleDa == '' && SaldoTotaleA != '') || (SaldoTotaleA == '' && SaldoTotaleDa != '')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Specificare entrambi i valori dello Saldo Totale che si vuole filtrare.'));
            ErrorValidateDecimal = true;
            return;
        }

        // 3. Verifico che i range siano corretti
        if (SaldoMovScadutoDa != '' && SaldoMovScadutoA != '') {
            if (decimal.valueOf(SaldoMovScadutoDa) > decimal.valueOf(SaldoMovScadutoA)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Il range di valori del filtro di Saldo Movimento Scaduto non è valido.'));
                ErrorValidateDecimal = true;
                return;
            }
        }
        if (SaldoTotaleDa != '' && SaldoTotaleA != '') {
            if (decimal.valueOf(SaldoTotaleDa) > decimal.valueOf(SaldoTotaleA)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Il range di valori del filtro Saldo Totale non è valido.'));
                ErrorValidateDecimal = true;
                return;
            }
        }

        // 4. Costruisco il query
        QueryAccount = '';
        system.debug('Preparo la query..');
        if (Utils.cebCheckObjPermission('Account', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Classe_di_rischio__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Comune_Contratto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Contratto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Contratto__c', 'id_Esterno__c', gd).get('ACCESS')) {
            QueryAccount = 'SELECT id, Name, Stato__c, Classe_di_Rischio__c, Contratto__r.id_Esterno__c, Comune_Contratto__c ';

            // 4.1 Se vogliamo inserire un account su White List
            if (leftselected_SelTipo == 'Assegna White List')
                QueryAccount = QueryAccount + 'FROM Account WHERE White_List__c = false AND';
            else QueryAccount = QueryAccount + 'FROM Account WHERE White_List__c = true AND';

            // 4.2 Composto il query con i altri filtri specifichati
            SYSTEM.DEBUG('***VALORE PRIMA DI QUERY: ' + rightvalues_idEsternoContratto);
            if (rightvalues_idEsternoContratto.size() > 0) {
                QueryAccount = QueryAccount + ' Contratto__r.id_Esterno__c IN: rightvalues_idEsternoContratto AND';
            }
            if (rightValues_Comuni.size() > 0) {
                QueryAccount = QueryAccount + ' Comune_Contratto__c IN: rightValues_Comuni AND';
            }
            if (rightValues_Stato.size() > 0) {
                QueryAccount = QueryAccount + ' Stato__c IN: rightValues_Stato AND';
            }

            // anche la Classe di Rischio
            if (rightValues_CdR.size() > 0) {
                QueryAccount = QueryAccount + ' Classe_di_Rischio__c IN: rightValues_CdR AND';
            }

            // 4.3 Considerare le intervali del SaldoMovScad & SaldoTotale
            if (SaldoMovScadutoDa != '' && SaldoMovScadutoA != '') {
                decSaldoMovScadutoDa = Decimal.valueOf(SaldoMovScadutoDa);
                decSaldoMovScadutoA = Decimal.valueOf(SaldoMovScadutoA);
                QueryAccount = QueryAccount + ' Saldo_Movimenti_Scaduti__c>= :decSaldoMovScadutoDa AND Saldo_Movimenti_Scaduti__c<= :decSaldoMovScadutoA AND';
            }
            if (SaldoTotaleDa != '' && SaldoTotaleA != '') {
                decSaldoTotaleDa = Decimal.valueOf(SaldoTotaleDa);
                decSaldoTotaleA = Decimal.valueOf(SaldoTotaleA);
                QueryAccount = QueryAccount + ' Saldo_Totale__c>= :decSaldoTotaleDa AND Saldo_Totale__c<= :decSaldoTotaleA AND';
            }
            // remove last ' AND' token
            if (QueryAccount.endsWith(' AND')) {
                QueryAccount = QueryAccount.substring(0, QueryAccount.length() - 4);
            }
            System.Debug(QueryAccount);
            QueryAccountPag = QueryAccount + ' AND Name <= :PrimoName ORDER BY NAME DESC LIMIT 20'; //* Da fare un test con il condizione 'AND Name<= : PrimoName ....'

            // 5.Prendi l'account dal DB
            QueryAccount += ' ORDER BY Name DESC';

            ListAccountToView = new List<Account>();
            ListAccountToView = Database.Query(QueryAccount);
            System.debug('Nr. Acc Selezionati: ' + ListAccountToView.size());

            // memorizza il nr totale dei affidamenti estratti dal DB
            totalRecordsNr = ListAccountToView.size();

            // Controlla se esistono dei account secondo questi filtri
            if (totalRecordsNr > 0) accountEsiste = true;
            else accountEsiste = false;

            // Remove Order By name Desc, from queryAccount
            QueryAccount = QueryAccount.substring(0, QueryAccount.length() - 19);

            // 6. Ricorda il numero delle account scelte e metti selected nel checkbox
            LPrimoName = new List<String>();
            for (integer i = 0; i < ListAccountToView.size(); i++) {
                if (i == 0 || (math.mod(i, RecXPage) == 0))
                    LPrimoName.add(ListAccountToView[i].name);
                MapSelezione.put(ListAccountToView[i].Name, true);
            }
            TotalSize = MapSelezione.size();
            ListAccountToView.clear();

            System.debug('\n Step presente: ' + step);
            step++;// avanca sul step futuro    
            system.debug('\n Step futuro: ' + step);
        }
    }
    // E.S. => Prendi le account selezionabili

    public list<TabellaAccount> getListAccountSelectable() {
        system.debug('LPrimoName.size' + LPrimoName.size());

        // Si aggiusta la paginazione dei record
        if (LPrimoName.size() > 0) {
            String PrimoName = LPrimoName[Indice];
            List<Account> listAccountToView = new List<Account>();
            System.Debug('MIO QUERY: ' + QueryAccountPag);
            listAccountToView = Database.Query(QueryAccountPag); //
            PageSize = listAccountToView.size();

            List<TabellaAccount> tempAcc = new List<TabellaAccount>();
            for (Account acc : listAccountToView) {
                boolean bSel;
                if (MapSelezione.containsKey(acc.Name))
                    bSel = true;
                else
                        bSel = false;
                //system.debug('Boolean bSel = ' + bSel);
                TabellaAccount AccountSelect = new TabellaAccount(bSel, acc, acc.id);
                //system.debug('Primo giro: ' + AccountSelect);
                tempAcc.add(AccountSelect);
            }
            //system.debug('tempAcc.size' + tempAcc.size());
            if (tempAcc.size() > 0) {
                AccountEsiste = true;
            } else AccountEsiste = false;
            return tempAcc;
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

    /*
     * Dipendente del punto che l'utente sta navigando la pagina,
     * il sistema, fornisce il passo precedente.
     * 
     * Ordine dei step: Primo Secondo Terzo Quarto Quinto
     * Valore del step:    -1   0       1      2     3 
     */
    public void Indietro() {

        if (Step == 0) {
            isPutInWhiteList = null;
            leftselected_SelTipo = null;
        } else if (Step == 1) {
            MapSelezione.clear();
            LPrimoName.clear();

        }

        bAllSel = true;
        Indice = 0;

        System.debug('\n Step presente: ' + step);
        step--;// avanca sul step futuro    
        system.debug('\n Step futuro: ' + step);

    }

    // E.S. => Ottimizzata per selezionare le account
    public void ConfermaSelezione() {
        AccountDaElaborare = new List<Account>();
        Set<String> NameSet = mapSelezione.keySet(); // *ASICURATI CHE MapSelezione, HA SOLO VALORI RELATI A I ACCOUNT,NO A LE PRATICHE.
        if (Utils.cebCheckObjPermission('Account', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Ragione_WhiteList__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Inizio_White_List__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'White_List__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Limite_WhiteList__c', gd).get('ACCESS')) {
            String queryConferma = 'Select id, Name,Ragione_WhiteList__c,Inizio_White_List__c,White_List__c,Limite_WhiteList__c, Contratto__c from Account where name in :NameSet';
            AccountDaElaborare = Database.query(queryConferma);
        }
        if (AccountDaElaborare.size() > 0) {
            accountSelEsisti = false;
        } else {
            accountSelEsisti = true;
        }
        TotalSize = AccountDaElaborare.size();
        System.debug('\n Scelti ' + totalsize + ' account! ****');
        System.debug('\n Step presente: ' + step);
        step++;// avanca sul step futuro    
        system.debug('\n Step futuro: ' + step);

    }

    // E.S. => metodo per selezionare tutti gli account
    public PageReference SelectAll() {
        for (TabellaAccount tb : getlistAccountSelectable()) {
            tb.isSelected = bAllSel;
            if (MapSelezione.containsKey(tb.Acc.Name) && !bAllSel) {
                MapSelezione.remove(tb.Acc.Name);
            } else if (!MapSelezione.containsKey(tb.Acc.Name) && bAllSel)
                MapSelezione.put(tb.Acc.Name, true);
        }
        TotalSize = MapSelezione.size();
        return null;
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

    // E.S. => Il metodo ottimazzato per manipolare il flag White_List__c delle account.
    // * inoltre, mettere anche la data del inizio White List(Data messa in automatico)
    //   & La data Limite_White_List__c, impostata dal operatore

    public pageReference mettiInWhL() {//ASSEGNA WHITE LIST
        try {
            MettiRimuoviDaWhList mettiWLinstance = new MettiRimuoviDaWhList();
            mettiWLinstance.mettiAccSuWhList(AccountDaelaborare, myWhiteListLimit, RagioneWhiteList);
            TotalSize = AccountDaelaborare.size();
            System.debug('\n Totale: ' + AccountDaelaborare.size() + '\n Account: ' + AccountDaelaborare);

            System.debug('\n Step presente: ' + step);
            step++;// avanca sul step futuro    
            system.debug('\n Step futuro: ' + step);

        } catch (Exception e) {
            System.debug('Eccezione nel impostazione su WhiteList delle account: ' + e.getMessage());
        }
        return null;
    }

    public pageReference rimuoviDaWhL() {//RIMUOVI WHITELIST
        try {
            MettiRimuoviDaWhList mettiWLinstance = new MettiRimuoviDaWhList();
            mettiWLinstance.rimuoviAccDaWhList(AccountDaelaborare);
            TotalSize = AccountDaelaborare.size();
            System.debug('\n Totale: ' + AccountDaelaborare.size() + '\n Account: ' + AccountDaelaborare);

            System.debug('\n Step presente: ' + step);
            step++;// avanca sul step futuro    
            system.debug('\n Step futuro: ' + step);
        } catch (Exception e) {
            System.debug('Eccezione rimuovendo da WhiteList delle account: ' + e.getMessage());
        }
        return null;
    }
    //E.S.
    // il tipo del operazione che vuole procedere l'utente
    public void Continua() {
        //if(leftselected_SelTipo == 'Assegna White List') // leftselected_SelTipo=> Simbolizza la comanda del utente per mettere un record in White List
        if (leftselected_SelTipo == system.label.assign_white_list)
            isPutInWhiteList = true;
        else isPutInWhiteList = false;
        System.debug('\n Step presente: ' + step);
        step++;// avanca sul step futuro
        system.debug('\n Step futuro: ' + step);

    }

    // E.S. => Aggiornamento della lista account

    public pageReference AggiornaelementoLista() {
        /*String Sel = ApexPages.currentPage().getParameters().get('isSel');
        String Account = ApexPages.currentPage().getParameters().get('Codice_Account');*/
        String Sel = ApexPages.currentPage().getParameters().get('isSel').escapeHtml4();
        String Account = ApexPages.currentPage().getParameters().get('Codice_Account').escapeHtml4();
        system.debug('Prima: Account ' + Account + '\n isSelected: ' + Sel + '\n Is AllSelected:' + bAllSel);

        if (MapSelezione.containsKey(Account) && Sel == 'true') {
            MapSelezione.remove(Account);
        } else if (!MapSelezione.containsKey(Account) && Sel == 'false')
            MapSelezione.put(Account, true);

        TotalSize = MapSelezione.size();

        // aggiorna Select All
        if (totalSize == totalRecordsNr) {
            bAllSel = true;
        } else {
            bAllSel = false;
        }

        system.debug('Dopo: Account ' + Account + '\n isSelected: ' + Sel + '\n Is AllSelected:' + bAllSel);

        return null;
    }

}