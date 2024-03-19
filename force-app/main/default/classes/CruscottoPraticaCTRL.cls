/* ---------------------------------------------------------------------------------------------------------------------
Name:            CruscottoPraticaCTRL.cls
Description:     Extension Controller for CruscottoPratica, CruscottoPraticaEmbedded, CruscottoDocuments, CruscottoSR,
                 CruscottoStrategy, ExpiredAmountAgeing Pages
Test class:      TestCoverageCruscottoPratica.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
17-Feb-2015  0.1                           First Version
15-Mar-2017  0.2      Matteo Sala          CruscottoPraticaCTRL Method
12-Apr-2017  0.3                           Modified getCDI Method: insterted CheckFLSPermission
25-Feb-2021  0.4      Giulia Mameli        Modified setMatStr Method: used Condition, ActualValue and InputValue Custom
                                           Labels when creating the Strategy Matrix
10-Mar-2021  0.5      Rajni			       Modified line 433, to show label in block reason picklist
13-Sep-2022  0.6      C.Sanna & R. Kurti   Added cebCheck FLS/Obj permission and WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class CruscottoPraticaCTRL {

    private final Pratica__c prat;
    private ApexPages.StandardController stdController;
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public List<Nota> getListNote() //{get; set;}
    {
        return Gestione_Note.queryNote(prat.Id);
    }

    // Dopo aver bloccato o sbloccato la pratica esegue un refresh dell'intera pagina.

    public boolean shouldRedirect { get; set; }{
        shouldRedirect = false;
    }
    public string url_Parent { get; set; }

    // Gestion Blocco/Sblocco

    Public String leftselected_Mot_Blo { get; set; }
    Public List<SelectOption> unSelectedValues_Mot_Blo { get; set; }
    Public List<String> originalValues_Mot_Blo { get; set; }
    Public String Note_Blocco { get; set; }
    Public String Note_Sblocco { get; set; }


    Public Boolean bId { get; set; }
    Public Boolean bPDR { get; set; }
    Public Boolean bServizio { get; set; }
    Public Boolean bStrategia { get; set; }
    Public Boolean bSospesa { get; set; }
    public Boolean bAffidamenti { get; set; }//E.S.

    Public Integer PagAttuale { get; set; }
    Public Integer NPag { get; set; }
    Public Integer Inizio { get; set; }
    Public Integer Fine { get; set; }

    Static Integer pSize = 10;
    Public Integer nAcc { get; set; }
    Public Integer totPage { get; set; }
    Public Integer Max { get; set; }

    Public Decimal MaxRes { get; set; }

    Public Id ServId { get; set; }
    Public Id IdRevoca { get; set; }

    /* Endri Sino */
    public id AffidamentoId { get; set; }

    Public String nRecord { get; set; }
    Public String CodPratica;
    Public String sEsito { get; set; }
    Public String sEsitoNote { get; set; }
    Public String selTab { get; set; }
    Public String sPratId { get; set; }
    Public String DRows { get; set; }

    public Nota__c n { get; set; }

    Public List<Nota__c> lNote { get; set; }
    Public List<Task> lTsk { get; set; }
    Public List<String> LastYear { get; set; }
    Public List<String> TipoAtt { get; set; }
    Public List<vStrategia> lStrat { get; set; }

    Public Map<String, Map<String, Integer>> mMesiAtt { get; set; }

    Public class TimeLine {
        String Id { get; set; }
        String content { get; set; }
        String start { get; set; }
        //String end {get; set;}
    }

    // ES, 02/02/2015: 
    // GEstione Cambio Attivitá Puntuale, manda nella pagina
    public pageReference CambioAttivitaPuntuale() {
        PageReference p = new pageReference('/apex/cambioAttivitaPuntuale');
        p.getParameters().put('id', this.Prat.id);
        return p;
    }

    // ES, 05/02/2015
    // Manda Task In Approvazione (operatore) & Approva task (Manager)
    public pageReference mandaTaskInApprovazione() {
        PageReference p = new pageReference('/apex/MandaInApprovazione');
        p.getParameters().put('id', this.Prat.id);
        p.setRedirect(true);
        return p;
    }

    public pageReference approvaTaskDalOperatore() {
        PageReference p = new pageReference('/apex/ApprovazioneTaskManager');
        p.getParameters().put('id', this.Prat.id);
        p.setRedirect(true);
        return p;
    }

    //ES

    Public String getTLTask() {
        List<TimeLine> ltl = new List<TimeLine>();
        if (Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Tipo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'CreatedDate', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Type', gd).get('ACCESS')) {
            List<Task> lt = [
                    SELECT ActivityExtended__r.Tipo__c, CreatedDate, LastModifiedDate
                    FROM Task
                    where WhatId = :prat.Id and Type = 'Credito'
                    //WITH SECURITY_ENFORCED
                    order by CreatedDate ASC
            ];
            List<Map<String, String>> lmss = new List<Map<String, String>>();
            Integer i = 0;

            for (Task t : lt) {
                TimeLine tl = new TimeLine();
                tl.Id = String.ValueOf(i);
                tl.content = t.ActivityExtended__r.Tipo__c;
                String anno = String.ValueOf(t.CreatedDate.year());
                String mese = String.ValueOf(t.CreatedDate.month());
                if (t.CreatedDate.month() < 10)
                    mese = '0' + t.CreatedDate.month();
                String giorno = String.ValueOf(t.CreatedDate.day());
                if (t.CreatedDate.day() < 10)
                    giorno = '0' + t.CreatedDate.day();
                tl.start = anno + '-' + mese + '-' + giorno;
                ltl.add(tl);
            }
        }
        return Json.serialize(ltl);
    }

    public ApexPages.StandardSetController con {
        get {
            if (con == null) {
                // inizio nuovo codice 17/04/17 inserimento CheckFLSPermission
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
                    con = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id, Stato__c FROM Pratica__c Order By Name LIMIT 50000]));
                }
                // fine nuovo codice 17/04/17 inserimento CheckFLSPermission
                // sets the number of records in each page set
                con.setPageSize(pSize);
                nAcc = [Select count() from Pratica__c LIMIT 50000];
                totPage = (nAcc / pSize);
                if (math.mod(nAcc, pSize) > 0)
                    totPage += 1;
            }

            return con;
        }
        set;
    }

    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            Integer nPage = con.getPageNumber();
            Integer fRec = (pSize * (nPage - 1)) + 1;
            Integer lRec = pSize * nPage;
            if (lRec > nAcc)
                lRec = nAcc;
            nRecord = string.valueOf(fRec) + '-' + string.valueOf(lRec);
            return nPage;
        }
        set;
    }

    /*
    // returns the first page of records
    public void first() {con.first();}
 
    // returns the last page of records
    public void last() {con.last();}
 
    // returns the previous page of records
    public void previous() {con.previous();}
 
    // returns the next page of records
    public void next() {con.next();}
 
    // returns the PageReference of the original page, if known, or the home page.
    public void cancel() {con.cancel();}*/

    public List<Pratica__c> getlPr() {
        List<Pratica__c> listPr = new List<Pratica__c>();
        for (Pratica__c p : (List<Pratica__c>) con.getRecords())
            listPr.add(p);

        return listPr;
    }

    /* Endrit Sino: Il tab dei Affidi */
    // container dei affidi presenti
    public List<Affidamento__c> ListAffidamenti {
        get {
            if (ListAffidamenti == null) {
                listAffidamenti = new List<Affidamento__c>();
                if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Affidamento__c', 'Nome_Collector__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Affidamento__c', 'Stato__c', gd).get('ACCESS')) {
                    listAffidamenti = [
                            Select id, Name, Stato__c, Data_Affidamento__c, Data_fine_affidamento_prevista__c, Nome_Collector__c
                            From Affidamento__c
                            //WITH SECURITY_ENFORCED
                            ORDER By Data_Affidamento__c Desc, Stato__c Desc
                            LIMIT 50000
                    ];
                }
                if (listAffidamenti.size() > 0)
                    return listAffidamenti;
                else
                        return null;
            } else
                    return listAffidamenti;
        }
        set;
    }

    // ES, 02/02/2015:7
    // Flag, per controllare se ci sono dei
    // task aperti da poter cambiare.
    public boolean taskApertoId {
        get {
            try {
                Integer countTaskOpen;
                if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Task', 'WhatId', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Task', 'isClosed', gd).get('ACCESS')) {
                    countTaskOpen = [
                            SELECT count()
                            FROM Task
                            WHERE WhatId = :this.prat.id
                            AND isClosed = false and RecordType.name = 'UI'
                            //WITH SECURITY_ENFORCED
                    ];
                }
                if (countTaskOpen > 0) {
                    return true;
                } else {
                    return false;
                }
            } catch (Exception e) {
                ErrorClass.logError('CruscottoPraticaCTRL', 'Errore durante la richiesta in DB dei task!');
                return false;
            }
        }
        set;
    }

    // ES, 05/02/2015
    // Gestire la visibilitá dei bottoni per il operatore&manager
    public boolean isVisibleMandaInAppr {
        get {
            // Controlla:
            // 1. se é Operatore 
            boolean sonoOperatore = (UserInfo.getUserRoleId() == tagHelper.getValueText('Ruolo Operatore Credito Id'));

            // 2. se sono dei UI tasks, da mandare per approvazione.
            string csValue = TagHelper.getValueTextOrNull('StatiTaskAperto');
            Set<String> statiTaskAperto;
            if (csValue == null || csValue == '') {
                statiTaskAperto = new set<String>{
                        'In corso'
                };
            } else {
                statiTaskAperto = Utils.SliptString(csValue, ',');
            }
            Integer countT;
            if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Status', gd).get('ACCESS')) {
                countT = [
                        Select count()
                        From Task
                        where status in :statiTaskAperto and whatId = :this.prat.id
                        and RecordType.name = 'UI' and ActivityExtended__r.Stato_Approvazione__c = 'NA'
                        //WITH SECURITY_ENFORCED
                ];
            }
            if (sonoOperatore && countT > 0) {
                return true;
            } else {
                return false;
            }
        }
        set;
    }

    public boolean isVisibleApprovaTaskManager {
        get {
            // Controlla:
            // Se c'é almeno un task, con id_Manager_Da_approvare__c uguale a quella del manager.
            id uid = userinfo.getUserId();
            Integer countT;
            if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Status', gd).get('ACCESS')) {
                countT = [
                        Select count()
                        From Task
                        where status = 'In approvazione'
                        and whatId = :this.prat.id and RecordType.name = 'UI' and ActivityExtended__r.id_Manager_Da_Approvare__c = :uId
                        //WITH SECURITY_ENFORCED
                ];
            }
            if (countT > 0) return true;
            else return false;
        }
        set;
    }

    public String getLingua() {
        return UserInfo.getLanguage();
    }

    /* 20170315 MSala - INIZIO */

    /*public CruscottoPraticaCTRL(ApexPages.StandardController controller) 
    {*/

    public String Label1 { get {return 'Expired Amounts Ageing';} set; }
    public String Label2 { get {return 'Statement of Account';} set; }
    public String Label3 { get {return 'Service/Product Detail';} set; }
    public String Label4 { get {return 'Repayment Plans';} set; }
    public String Label5 { get {return 'Service Requests';} set; }
    public String Label7 { get {return 'Activities';} set; }
    public String Label11 { get {return 'Assignments';} set; }
    public String Label8 { get {return 'Voices';} set; }
    public String Label9 { get {return 'Documentation';} set; }
    public String Label10 { get {return 'Strategy';} set; }
    public String Label12 { get {return 'Chatter';} set; }

    public Map<String, Boolean> mLof { get; set; }
    public CruscottoPraticaCTRL(ApexPages.StandardController controller) {
        mLof = new map<String, Boolean>();
        /* if(Utils.cebCheckObjPermission('ListOfFields__c',gd).get('ACCESS')
         && Utils.cebCheckFLSPermission('ListOfFields__c','Field__c',gd).get('ACCESS')
         && Utils.cebCheckFLSPermission('ListOfFields__c','Show__c',gd).get('ACCESS')) {*/
        //List<ListOfFields__c> lof = [SELECT Field__c, Show__c FROM ListOfFields__c WHERE Name like 'TabPrat%'];
        List<ListOfFields__c> lof = [SELECT Field__c, Show__c FROM ListOfFields__c WHERE Name like 'TabPrat%' WITH SECURITY_ENFORCED];

        for (ListOfFields__c l : lof) {
            mLof.put(l.Field__c, l.Show__c);
        }
        //}
        /* 20170315 MSala - FINE */

        url_Parent = controller.view().getUrl();
        system.debug('ENTRATA NEL COSTRUTTORE');
        n = new Nota__c();
        if (ApexPages.currentPage().getParameters().get('Id') == null)
            bId = false;
        else {
            bId = true;

            if (!test.isRunningTest()) {

                PagAttuale = 1;
                List<String> fields = new List<String>();

                // ES: Leggi tutti i campi, 17/02/2015
                SObjectType type = Schema.getGlobalDescribe().get(Utils.NAMESPACE + 'Pratica__c');
                Map<String, Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
                fields.addAll(mfields.keySet());
                // ES
                fields.add('Servizio_Fornitura__c');
                fields.add('Servizio_Fornitura__r.RecordType.Name');
                fields.add('Servizio_Fornitura__r.Metodo_di_Pagamento__c');
                fields.add('Strategia__r.Nome__c');
                fields.add('Strategia__r.Tipo_Cliente__c');
                fields.add('Account__r.Type');
                fields.add('Account__r.Rating');
                fields.add('Strategia__r.Tipo_Servizio__c');
                fields.add('Strategia__r.CAP_Massimo__c');
                fields.add('Strategia__r.CAP_Minimo__c');
                fields.add('Strategia__r.Min_Scaduto__c');
                fields.add('Strategia__r.Max_Scaduto__c');
                fields.add('Strategia__r.Stagionalit__c');
                fields.add('Strategia__r.Rating__c');
                fields.add('Strategia__r.Metodo_di_Pagamento__c');
                fields.add('Strategia__r.Fascia_di_Rischio__c');
                /* ES: Commentati per prenderli queryallfields
                fields.add('Name');
                fields.add('Stato__c');
                fields.add('Strategia__c');
                fields.add('Residuo_Totale__c');
                fields.add('Strategia_Tipo_Cliente__c');
                fields.add('Strategia_Tipo_Servizio__c');
                fields.add('Strategia_MDP__c');
                fields.add('Strategia_CAP__c');
                fields.add('Strategia_Scaduto__c');
                fields.add('Fascia_di_rischio__c');
                fields.add('Strategia_Fascia_di_Rischio__c');
                fields.add('Strategia_Rating__c');
                fields.add('Strategia_Stagionalit__c');
                fields.add('CDI_Json__c');*/
                //fields.add('');
                //fields.add('Nota_Sblocco__c');
                //fields.add('Note_Blocco__c');

                controller.addFields(fields);

                this.prat = (Pratica__c) controller.getRecord();
                system.debug('********THIS PRATICA: ' + this.prat);
            } else {
                if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                        && Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Pratica__c', 'Strategia__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Tipo_Cliente__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Tipo_Servizio__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'CAP_Massimo__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'CAP_Minimo__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Min_Scaduto__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Max_Scaduto__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Stagionalit__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Rating__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Metodo_di_Pagamento__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Fascia_di_Rischio__c', gd).get('ACCESS')) {
                    Id pid = ApexPages.currentPage().getParameters().get('Id');
                    String Query = 'Select ';
                    Query += Utils.getSOBJECTFieldsForQuery('Pratica__c');
                    // add lookup fields
                    Query += ', Servizio_Fornitura__r.RecordType.Name, Servizio_Fornitura__r.Metodo_di_Pagamento__c, Account__r.Type,Account__r.Rating,';
                    Query += 'Strategia__r.Nome__c,Strategia__r.Tipo_Cliente__c,Strategia__r.Tipo_Servizio__c,Strategia__r.CAP_Massimo__c,Strategia__r.CAP_Minimo__c,';
                    Query += 'Strategia__r.Min_Scaduto__c,Strategia__r.Max_Scaduto__c,Strategia__r.Stagionalit__c,Strategia__r.Rating__c, Strategia__r.Metodo_di_Pagamento__c,Strategia__r.Fascia_di_Rischio__c';
                    Query += ' from Pratica__c where Id = :pid LIMIT 1';

                    ApexPages.StandardSetController testCon = new ApexPages.StandardSetController(Database.getQueryLocator(Query));
                    List<Pratica__c> lP = testCon.getRecords();
                    this.prat = lP[0];
                    System.Debug('Cruscotto: ' + prat.Account__r.Rating);
                    System.Debug('Cruscotto: ' + string.ValueOf(prat.Id));
                    System.Debug('Cruscotto: ' + prat.Account__r.Type);
                }
            }

            Id pratId = prat.Id;
            sPratId = String.valueOf(prat.Id);
            CodPratica = prat.Name;
            sEsito = '';
            sEsitoNote = '';

            //controllo lo stato della pratica per visualizzare la creazione PDR
            String stato = prat.Stato__c;
            if (stato == 'Da Affidare' || stato == 'Affidata' || stato == 'In Lavorazione' || stato == 'Revocata') {
                bPDR = true;
            } else bPDR = false;
            system.debug('Booleano piano di rientro: ' + bPDR);

            originalValues_Mot_Blo = CredManUtility.getPicklistValues('Pratica__c', 'Motivo_Blocco__c');
            unSelectedValues_Mot_Blo = getPicklistValues('Pratica__c', 'Motivo_Blocco__c');
            //unSelectedValues_Mot_Blo = getunSelectedValues(originalValues_Mot_Blo);
            leftselected_Mot_Blo = null;
            Note_Blocco = null;
            Note_Sblocco = null;


            //Verifico se la pratica è BLOCCATA
            bSospesa = false;
            String pStato = prat.Stato__c;
            if (pStato == 'Bloccata' || pStato == 'Bloccata Manualmente') bSospesa = true;

            //Verifico se c'è il servizio e prendo i Servizi_Item legati ad esso
            bServizio = false;
            ServId = prat.Servizio_Fornitura__c;
            if (ServId != null)bServizio = true;

            /* Endrit Sino 
            // Verifico se c'i sono dei affidamenti associati
            bAffidamenti = false;
            //AffidamentoID = prat.A
            if(AffidamentoId != null)bAffidamenti = true;
            }*/

            //Verifico se c'è la strategia
            bStrategia = false;
            Id StratId = prat.Strategia__c;
            String StratName = prat.Strategia__r.Nome__c;
            if (StratId != null) {
                bStrategia = true;

                // Aggiungo la parte per gestire il chart sulla strategia

                if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                        && Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Sotto_Tipo__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Giorni_Completamento__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Tipo__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Esito__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Id_Attivit_Precedente__c', gd).get('ACCESS')) {
                    List<Task> TS = [
                            SELECT
                                    Createddate,
                                    Id,
                                    Status,
                                    ActivityExtended__r.Sotto_Tipo__c,
                                    ActivityExtended__r.Giorni_Completamento__c,
                                    ActivityExtended__r.Tipo__c,
                                    ActivityExtended__r.Esito__c,
                                    ActivityExtended__r.Id_Attivit_Precedente__c
                            FROM Task
                            where whatid = :prat.Id
                            and ActivityExtended__r.Strategia__c = :StratName
                            //WITH SECURITY_ENFORCED
                    ];

                    String s = '[';
                    Integer i = 0;

                    System.debug('whatId è ' + prat.Id);
                    System.debug('Strategia è ' + StratName);

                    for (Task t : TS) {
                        String parent = '';
                        String SottoTipo = '';
                        if (t.ActivityExtended__r.Id_Attivit_Precedente__c != null)
                            parent = t.ActivityExtended__r.Id_Attivit_Precedente__c;
                        Else
                                parent = 'Pratica: ' + prat.name;
                        if (t.ActivityExtended__r.Sotto_Tipo__c != null)
                            SottoTipo = t.ActivityExtended__r.Sotto_Tipo__c;
                        s = s +
                                '[{v:\'' +
                                t.Id +
                                '\', f:\'' +
                                t.ActivityExtended__r.Tipo__c + ' ' + SottoTipo
                                + '<div> ' + 'Stato: ' +
                                t.Status + '</div>' +
                                '<div>' + 'Esito: ' +
                                t.ActivityExtended__r.Esito__c +
                                '</div>' + '\'},' + '\'' + parent + '\',\'null' + '\']';
                        if (i < TS.size() - 1)
                            s = s + ',';
                        System.debug('La stringa parent è ' + parent);
                    }

                    s = s + ']';
                    DRows = s;
                    System.debug('La stringa DRows è ' + s);

                }
            }

            Refresh('all', 'Ageing');

            // ES: 13/02/2015
            // Desc: De-commentata, per rilascare il tab Strategy
            String debugStr = '\n *********************ENDRIT**************';
            lStrat = new List<vStrategia>();
            if (bStrategia) {
                setMatStr();
            }
            /*try{
                //Inizio Strategia
            lStrat = new List<vStrategia>();
            if(bStrategia)
            {
                CredManUtility CMU = new CredManUtility(); 
                
                //lStrat = new List<vStrategia>();
                // 1st Row(Demostration)
                debugStr += '\n 1st Row';
                lStrat.add(new vStrategia('',prat.Strategia__r.Nome__c,'Valori Attuali','Valori di Ingresso',true));
                
                // 2nd Row: Tipo Cliente
                debugStr += '\n 2nd Row, Dettails: ';
                String StratTCliente = prat.Strategia__r.Tipo_Cliente__c;
                debugStr += sendForDebug('\nprat.Strategia__r.Tipo_Cliente__c: ', String.valueOf(prat.Strategia__r.Tipo_Cliente__c));
                String tCliente = prat.Account__r.Type;
                debugStr += sendForDebug('\nprat.Account__r.Type: ', String.valueOf(prat.Account__r.Type));
                Boolean bTCliente = CMU.isPresent(StratTCliente , tCliente);                
                debugStr +=  sendForDebug('\nCMU.isPresent(StratTCliente , tCliente): ',String.valueOf(CMU.isPresent(StratTCliente , tCliente)));
                lStrat.add(new vStrategia('Tipo Cliente',StratTCliente,tCliente,prat.Strategia_Tipo_Cliente__c,bTCliente));
                
                // 3rd Row: Tipo Servizio
                debugStr += sendForDebug('\n 3rd Row, Dettails:', null);
                String tServizio = 'Servizio non presente';
                debugStr += sendforDebug('\ntServizio: ', tservizio);
                String StratTServ = prat.Strategia__r.Tipo_Servizio__c;
                debugStr += sendForDebug('\nStratServ: ', StratTServ);
                Boolean bServ = false;
                
                // 4th Row: Metodo di Pagamento
                debugStr += sendForDebug('\n 4th Row, Dettails:', null);
                String StratMDP = prat.Strategia__r.Metodo_di_Pagamento__c;
                DebugStr += sendfordebug('\nStratMDP: ', stratMdp);
                String ServMDP = 'Servizio non presente';
                Boolean bMDP = false;
                if(bServizio)
                {
                    //tServizio = prat.Servizio_Fornitura__r.Tipo__c;
                    ServMDP = prat.Servizio_Fornitura__r.Metodo_di_Pagamento__c;
                    bServ = CMU.isPresent(StratTServ, tServizio);
                    bMDP = CMU.isPresent(StratMDP, ServMDP);
                }
                else
                {
                   bServ = true;
                   bMDP = true;
                }
                // 3rd
                lStrat.add(new vStrategia('Tipo Servizio',StratTServ,tServizio,prat.Strategia_Tipo_Servizio__c,bServ));
                
                // 4th
                lStrat.add(new vStrategia('\nMetodo di Pagamento',StratMDP,ServMDP,prat.Strategia_MDP__c,bMDP));
                debugStr += sendForDebug('\n After 3rd and 4th row, bserv:', String.valueOf(bserv));
                debugStr += sendForDebug('\nbMDP:', String.valueOf(bMDP));
                // 5th: CAP
                debugStr += sendForDebug('\n 5th Row, Dettails:', null);
                String CAP = 'Da ' + prat.Strategia__r.CAP_Minimo__c + ' a ' + prat.Strategia__r.CAP_Massimo__c;
                debugStr += sendForDebug('\nprat.Strategia__r.CAP_Minimo__c: ', String.valueOf(prat.Strategia__r.CAP_Minimo__c));
                Contact ind = null;
                List<Contact> inds = 
                    [Select Cap__c from Contact 
                    where AccountId = :prat.Account__c AND Principale__c = true LIMIT 1];
                if(!inds.isEmpty()){
                    ind = inds[0];
                }
                    
                String stratCAP = '';
                Boolean bCAP = false;
                if(ind != null)
                {
                    stratCAP = ind.Cap__c;
                    Integer iCAP = Integer.ValueOf(stratCAP.left(3));
                    if(iCAP >= prat.Strategia__r.CAP_Minimo__c && iCAP <= prat.Strategia__r.CAP_Massimo__c)
                       bCAP = true;
                }
                lStrat.add(new vStrategia('Cap',CAP,stratCAP,prat.Strategia_CAP__c,bCAP));
                
                // 6th: Scaduto
                debugStr += sendForDebug('\n 6th Row, Dettails:', null);
                String Scaduto = 'Da €' + prat.Strategia__r.Min_Scaduto__c + ' a €' + prat.Strategia__r.Max_Scaduto__c;
                debugStr += sendForDebug('\nprat.Strategia__r.Min_Scaduto__c: ', String.valueOf(prat.Strategia__r.Min_Scaduto__c));
                debugStr += sendForDebug('\nprat.Strategia__r.Max_Scaduto__c: ', String.valueOf(prat.Strategia__r.Max_Scaduto__c));
                String ScadutoPrat = '€' + prat.Residuo_Totale__c;
                debugStr += sendForDebug('\nprat.Residuo_Totale__c: ', String.valueOf(prat.Residuo_Totale__c));
                Boolean bScad = false;
                if(prat.Residuo_Totale__c >= prat.Strategia__r.Min_Scaduto__c && 
                    prat.Residuo_Totale__c <= prat.Strategia__r.Max_Scaduto__c)
                {
                    bScad = true;
                }
                lStrat.add(new vStrategia('Scaduto',Scaduto,ScadutoPrat,'€' + String.ValueOf(prat.Strategia_Scaduto__c),bScad));
                
                // 7th: Fascia 
                debugStr += sendForDebug('\n 7th Row, Dettails:', null);
                String stratFascia = prat.Strategia__r.Fascia_di_Rischio__c;
                debugStr += sendForDebug('\nprat.Strategia__r.Fascia_di_Rischio__c: ', String.valueOf(prat.Strategia__r.Fascia_di_Rischio__c));
                String prFascia = prat.Fascia_di_rischio__c;

                Boolean bFascia = CMU.isPresent(stratFascia, prFascia);
                lStrat.add(new vStrategia('Fascia di Rischio',stratFascia, prFascia,prat.Strategia_Fascia_di_Rischio__c,bFascia));
                
                // 8th: Rating                
                debugStr += sendForDebug('\n 8th Row, Dettails:', null);
                String stratRating = prat.Strategia__r.Rating__c;
                debugStr += sendForDebug('\nprat.Strategia__r.Rating__c: ', String.valueOf(prat.Strategia__r.Rating__c));
                String clienteRating = prat.Account__r.Rating;
                debugStr += sendForDebug('\nprat.Account__r.Rating: ', String.valueOf(prat.Account__r.Rating));
                Boolean bRating = CMU.isPresent(stratRating , clienteRating);
                lStrat.add(new vStrategia('Rating',stratRating,clienteRating,prat.Strategia_Rating__c,bRating));
                
                Boolean bStag = false;
                String stratStag = prat.Strategia__r.Stagionalit__c;
                debugStr += sendForDebug('\nprat.Strategia__r.Stagionalit__c: ', stratStag);
                CMStagionalita__c stag = CMStagionalita__c.getInstance(stratStag);
                /*Stagionalita__c stag = 
                    [SELECT Giorno_Inizio__c,Mese_Inizio__c,Giorno_Fine__c,Mese_Fine__c 
                    FROM Stagionalita__c 
                    where Name = :stratStag LIMIT 1];*/
            /*Date d = System.today();
            Integer iGiorno = d.day();
            Integer iMese = d.month();
            String dStag = String.valueOf(d);
            System.debug('\n sTag: ' + stag);
            if(stag.Mese_Inizio__c < stag.Mese_Fine__c)
            {
                if(iMese>stag.Mese_Inizio__c && iMese<stag.Mese_Fine__c)
                    bStag = true;
                else if(iMese == stag.Mese_Inizio__c)
                {
                    if(iGiorno >= stag.Giorno_Inizio__c)
                        bStag = true;
                }
                else if(iMese == stag.Mese_Fine__c)
                {
                    if(iGiorno <= stag.Giorno_Fine__c)
                        bStag = true;
                }
            }
            else
            {
                if(iMese<stag.Mese_Inizio__c || iMese>stag.Mese_Fine__c)
                    bStag = true;
                else if(iMese == stag.Mese_Inizio__c)
                {
                    if(iGiorno >= stag.Giorno_Inizio__c)
                        bStag = true;
                }
                else if(iMese == stag.Mese_Fine__c)
                {
                    if(iGiorno <= stag.Giorno_Fine__c)
                        bStag = true;
                }
            }
            lStrat.add(new vStrategia('Stagionalità',stratStag,dStag,prat.Strategia_Stagionalit__c,bStag));
        /*}
        else
        {
            lStrat.add(new vStrategia('','','Valori Attuali',false));
            String tCliente = prat.Account__r.Type;
            lStrat.add(new vStrategia('Tipo Cliente','',tCliente,false));

            String tServizio = 'Servizio non presente';
            String ServMDP = 'Servizio non presente';
            Boolean bMDP = false;
            if(bServizio)
            {
                //tServizio = prat.Servizio_Fornitura__r.Tipo__c;
                ServMDP = prat.Servizio_Fornitura__r.Metodo_di_Pagamento__c;
            }
            lStrat.add(new vStrategia('Tipo Servizio','',tServizio,false));
            lStrat.add(new vStrategia('Metodo di Pagamento','',ServMDP,false));

            Contact ind = null;
            List<Contact> inds =
                [Select Cap__c from Contact
                where AccountId = :prat.Account__c AND Principale__c = true LIMIT 1];
            if(!inds.isEmpty()){
                ind = inds[0];
            }
            String stratCAP = '';
            Boolean bCAP = false;
            if(ind != null)
            {
                stratCAP = ind.Cap__c;
            }
            lStrat.add(new vStrategia('Cap','',stratCAP,false));

            String ScadutoPrat = string.ValueOf(prat.Residuo_Totale__c);
            lStrat.add(new vStrategia('Scaduto','','€' + ScadutoPrat,false));

            String prFascia = prat.Fascia_di_rischio__c;
            lStrat.add(new vStrategia('Fascia di Rischio','', prFascia,false));

            String clienteRating = prat.Account__r.Rating;
            lStrat.add(new vStrategia('Rating','',clienteRating,false));

            Date d = System.today();
            Integer iGiorno = d.day();
            Integer iMese = d.month();
            String dStag = String.valueOf(d);
            lStrat.add(new vStrategia('Stagionalità','',dStag,false));
        }
        }catch(Exception e){
            System.debug('\n Errore: ' + e.getMessage() + '\n Linea: ' + e.getLineNumber());
        }*/
            System.debug(debugStr);
            //ErrorClass.logError(debugStr);
            //Fine Strategia
        }
    }

    // ES, 17/02/2015
    // Metodo per compilare la matrice Strategia.
    public void setMatStr() {
        // 1. Leggi i dati del CDI, Valori di Ingresso, Valori Attuali
        // Mappe: Key = Nome del campo, Value = valore del campo
        List<Map<String, String>> lMapFromJson = new List<Map<String, String>>();
        System.debug('\n setMatStr prat.CDI_Json__C: ' + prat.CDI_Json__C);
        if (prat.CDI_Json__c != null)
            lMapFromJson = (List<Map<String, String>>) JSON.deserialize(prat.CDI_Json__c, List<Map<String, String>>.Class);
        else return;

        // 2. Compilare vStrategia:
        //  2.1 Campo x[Label] = {valore y, secondo il CDI}, {Valore z, nel momento del ingresso}, {Valore u, attualmente}
        Strategia__c cdi = getCDI(prat.Strategia__c, prat.ConDiIng__c);
        lStrat.add(new vStrategia('', prat.Strategia__r.Nome__c, Label.Condition, Label.ActualValue, Label.InputValue, true));

        for (Map<String, String> m : lMapFromJson) {
            String Label = getFieldLabel(m.get('objField'), 'Pratica__c');
            String valStrat = String.valueOf(m.get('strategiaValue'));
            String valCond = String.valueOf(m.get('condition'));
            String valObject = String.valueOf(m.get('objValue'));
            String vAttuale = String.valueOf(prat.get(m.get('objField')));
            Boolean isOk = OrkKernel.checkCondition(prat.get(m.get('objField')), cdi.get(m.get('strategiaField')), m.get('condition'));
            lStrat.add(new VStrategia(Label, valStrat, valCond, vAttuale, valObject, isOk));
        }
    }

    // Get CDI 
    public static Strategia__c getCDI(id idTest, id idCDI) {
        /*if(Utils.checkFLSPermission('Task', 'ActivityExtended__c').get('ACCESS')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Sotto_Tipo__c').get('ACCESS')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Giorni_Completamento__c').get('ACCESS')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Tipo__c').get('ACCESS')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Esito__c').get('ACCESS')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Id_Attivit_Precedente__c').get('ACCESS'))
        {*/
        // inizio nuovo codice 12/04/17 inserimento CheckFLSPermission
        if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Descrizione__c', gd).get('ACCESS')) {
            String queryS = 'Select ';
            queryS += Utils.getSOBJECTFieldsForQuery('Strategia__c');
            queryS += ' From Strategia__c Where Id = :idCDI'; // Testata__c =: idTest and recordtype.name = \'Condizioni di Ingresso\'
            //throw new TriggerFactory.TriggerException('RDONATO:'+queryS);
            Strategia__c s = Database.query(String.escapeSingleQuotes(queryS));
            return s;
        } else return null;
        // fine nuovo codice 12/04/17 inserimento CheckFLSPermission
    }

    // Prendi il label el campo, dinamicamente
    public String getFieldLabel(String fieldName, String ObjectName) {
        List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{
                objectName
        }); // this can accept list of strings, we describe only one object here
        Map<String, Schema.SObjectField> allFields = describeSobjectsResult[0].fields.getMap();
        String fieldLabel = allFields.get(utils.namespace + fieldName).getDescribe().getLabel();
        return fieldLabel;
    }

    // ES: Metodo per rintracciare vari campi o valori,
    // e memorizzarli in una stringa debug
    public static String sendForDebug(String DebugTag, String targetToDeb) {
        String debugStr = '\n';
        if (targetToDeb == null) {
            return DebugTag;
        }
        debugStr += DebugTag;
        debugStr += targetToDeb ;
        return debugStr;
    }
    // ES fine


    public void Refresh(String sAggiorna, String sTab) {
        Id pratId = prat.Id;
        ListOfObjects LOO = new ListOfObjects();
        if (sAggiorna == 'Note' || sAggiorna == 'all') {
            //Recupero le Note
            lNote = LOO.qNote('Pratica', pratId);
        }

        selTab = sTab;
    }

    public List<ChrtData> getPieData() {
        ChrtData cData = new ChrtData('', 0, 0);
        List<ChrtData> data = CData.lChrtData(prat.Id, 'Pratica');
        return data;
    }

    public List<ChrtSaldi> getChrtSaldi() {
        ChrtSaldi cSaldi = new ChrtSaldi('', '', '', 0, 0, 0, '', '', false);
        List<ChrtSaldi> saldi = cSaldi.Json2Chrt(prat.Id, 'Cliente');
        if (saldi == null || saldi.size() == 0) {
            return null;
        }
        return saldi;
    }

    public List<StackedData> getStkData() {
        Max = 0;
        MaxRes = 0;
        StackedData stkData = new StackedData('', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        List<StackedData> stacked = stkData.lStkData(prat.Id, 'Pratica');
        Max = stkData.Max;
        MaxRes = stkData.MaxRes;
        return stacked ;
    }

    public PageReference BloccaPratica() {
        BloccoSbloccoPratiche bsPrat = new BloccoSbloccoPratiche();
        String sCausale = leftselected_Mot_Blo;
        String sNota = Note_Blocco;
        List<Pratica__c> lPrat = new List<Pratica__c>();
        lPrat.add(prat);
        bsPrat.BloccaPratiche(lPrat, sCausale, sNota);
        bSospesa = true;
        shouldRedirect = true;
        //url_Parent = stdController.view().getUrl();
        return null;
    }

    public PageReference SbloccaPratica() {
        BloccoSbloccoPratiche bsPrat = new BloccoSbloccoPratiche();
        List<Pratica__c> lPrat = new List<Pratica__c>();
        lPrat.add(prat);
        String SBlNota = Note_Sblocco;
        bsPrat.SbloccaPratiche(lPrat, SBlNota);
        bSospesa = false;
        shouldRedirect = true;
        //url_Parent = 'https://cs11.salesforce.com/'+Prat.Id;
        //url_Parent = stdController.view().getUrl();
        return null;
    }


    public void AssociaStrategia() {
        /*Strategie strat = new Strategie();
        sEsito = strat.AssociaStrategia(prat,lStrat);
        selTab = 'Strat';*/
    }

    public void CambiaStrategia() {
        /*System.Debug('CambiaStrategia Inizio');
        Strategie strat = new Strategie();
        sEsito = strat.CambiaStrategia(prat,lStrat);
        selTab = 'Strat';
        System.Debug('CambiaStrategia Fine');*/
    }

    public void SaveNote() {
        if (n.Nota__c != '' && n.Nota__c != null) {
            system.debug('SaveNote()');
            sEsitoNote = Gestione_Note.insertNote(prat.Id, n.Nota__c, n.CreatedBy.Name, n.RecordTypeId, system.Now());
            n = new Nota__c();
            Refresh('Note', 'Note');
        } else
                sEsitoNote = 'ATTENZIONE !!! Non puoi inserire una nota senza contenuto !!!';
    }

    public void AggiornaNote() {
        Refresh('Note', 'Note');
    }

    public String getListViewId() {
        String internalListViewId = '';

        DefaultView__c cs = DefaultView__c.getValues('Pratica');
        if (cs == null) return '0';
        internalListViewId = cs.View_Id__c;
        return internalListViewId;
    }

    public List<ChrtSaldi> ChrtSaldi {
        get {
            ChrtSaldi cSaldi = new ChrtSaldi('', '', '', 0, 0, 0, '', '', false);
            if (prat.Id == null)
                return null;
            List<ChrtSaldi> saldi = cSaldi.Json2Chrt(prat.Id, 'Pratica');
            if (saldi == null || saldi.size() == 0) {
                return null;
            }
            return saldi;
        }

        set {
        }
    }

    public List<ChrtSaldi> getListSaldi() {
        if (ChrtSaldi == null) {
            NPag = 0;
            Inizio = 0;
            Fine = 0;
            PagAttuale = 0;
            return null;
        }
        NPag = ChrtSaldi.size() / 10;
        if (Math.Mod(ChrtSaldi.size(), 10) > 0) {
            NPag++;
        }
        Inizio = ChrtSaldi.size() - PagAttuale * 10 + 10;
        Fine = ChrtSaldi.size() - PagAttuale * 10;
        if (Fine < 0)
            Fine = 0;
        List<ChrtSaldi> lSaldi = new List<ChrtSaldi>();
        for (Integer i = Inizio - 1; i >= Fine; i--) {
            lSaldi.add(ChrtSaldi[i]);
        }
        return lSaldi;
    }

    public Boolean getDisableNext() {
        if (Fine == 0)
            return true;
        else
                return false;
    }

    public Boolean getDisablePrevious() {
        if (PagAttuale == 1 || NPag == 0)
            return true;
        else
                return false;
    }

    public PageReference Next() {
        PagAttuale++;
        return null;
    }

    public PageReference Previous() {
        PagAttuale--;
        return null;
    }

    public PageReference Beginning() {
        PagAttuale = 1;
        return null;
    }

    public PageReference End() {
        PagAttuale = NPag;
        return null;
    }

    Public void Refresh() {
    }

    // SI
    public List<SelectOption> getunSelectedValues(List<String> original) {
        Try {

            List<SelectOption> options = new List<SelectOption>();

            List<string> tempList = new List<String>();

            tempList.addAll(original);

            //tempList.sort();

            for (string b : tempList)

                options.add(new SelectOption(b, b));

            return options;
        } catch (Exception e) {
            System.debug('Eccezione nel caricamento dei valori di sinistra: ' + e.getMessage());
            return null;
        }
    }

    public String getleftselected_Mot_Blo() {
        return leftselected_Mot_Blo;
    }

    public List<SelectOption> getPicklistValues(String ObjectApi_name, String Field_name) {
        List<SelectOption> options = new List<SelectOption>();

        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(Utils.NAMESPACE + ObjectApi_name).getDescribe().fields.getmap();

        // Get the list of picklist values for this field.
        List<Schema.PicklistEntry> values = fieldMap.get(Utils.NAMESPACE + Field_name).getDescribe().getPickListValues();

        options.add(new SelectOption('', '-- None --'));

        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values) {
            //    options.add(new SelectOption(a.getLabel(), a.getValue())); to fix translation
            options.add(new SelectOption(a.getValue(), a.getLabel()));
        }
        system.debug(options);
        options.sort();

        return options;

    }
}