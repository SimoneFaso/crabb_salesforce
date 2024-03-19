/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestCoverageCruscottoPratica.cls
Description:     Test class for code coverage of CRABB_PraticaAgeingCtrl.cls and CruscottoPraticaCTRL.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
10-Mar-2021  0.2      Giulia Mameli                   Substituted getRecordTypeInfosByName() with getRecordTypeInfosByDeveloperName()
                                                      to use Record Type Developer Names
----------------------------------------------------------------------------------------------------------------------*/

@IsTest
private class TestCoverageCruscottoPratica {

    //Metodo creazione Account
    public static Account getTestAccount() {
        Account acc = new Account();

        acc.Indirizzo_Principale__c = false;
        acc.Phone_SMS__c = '8888888888';
        acc.Mail_Sollecito__c = 'test@balanceconsulting.it';
        acc.White_List__c = false;
        acc.ShippingState = 'FI';
        acc.Phone = '0000000000';
        acc.Phone2__c = '2222222222';
        acc.Phone3__c = '3333333333';
        acc.Phone4__c = '4444444444';
        acc.Phone5__c = '5555555555';
        acc.Phone6__c = '6666666666';
        acc.Mail1__c = 'test1@balanceconsulting.it';
        acc.Mail2__c = 'test2@balanceconsulting.it';
        acc.Mail3__c = 'test3@balanceconsulting.it';
        acc.Mail4__c = 'test4@balanceconsulting.it';
        acc.BillingState = 'FI';
        acc.Invio_Piano_di_Rientro__c = false;
        acc.BillingPostalCode = '50063';
        acc.Codice_Fiscale__c = 'NA';
        acc.ShippingCity = 'FIGLINE VALDARNO';
        acc.Fascia_ISEE__c = '764,33';
        acc.Pratiche_In_Lavorazione__c = 0;
        acc.Scadenza_ISEE__c = Date.valueOf('2014-09-11');
        acc.ShippingStreet = 'P.ZZA S. FRANCESCO DASSISI, 1114';
        acc.Warning_Integration__c = false;
        acc.BillingStreet = 'P.ZZA S. FRANCESCO DASSISI, 1114';
        acc.Name = 'MORALES BATTISTA YAMILENIS';
        acc.BillingCity = 'FIGLINE VALDARNO';
        acc.Invio_Sollecito__c = false;
        acc.ShippingPostalCode = '50063';
        acc.Data_Scaduto__c = System.today();
        acc.Codice_Account__c = 'Codice account Test';
        acc.Stato__c = 'Attivo';
        acc.Importo_Incasso_Corrente__c = 0;
        acc.Invio_Piano_di_Rientro__c = false;
        acc.Trigger_cause__c = null;

        return acc;
    }

    //Metodo Creazione Servizio
    public static Servizio__c getTestService() {
        Servizio__c serv = new Servizio__c();
        serv.Metodo_di_Pagamento__c = 'ALTRO';
        serv.Id_SoftwareHouse__c = 'XXXX';
        serv.Codice__c = 'POSTREF';
        serv.Id_Esterno__c = 'XXXX';
        serv.Stato__c = 'ATTIVO';
        serv.Nome__c = 'POSTPAGATO-REFEZIONE';
        return serv;
    }

    //Metodo Creazione pratica
    public static Pratica__c getTestPratica() {
        Pratica__c p = new Pratica__c();
        p.Anzianit_Pratica__c = System.today();
        p.Check_In_Lavorazione__c = false;
        p.Data_inizio_scaduto__c = System.today();
        p.Esci_e_chiudi__c = false;
        p.Fascia_di_rischio__c = '1234';
        p.Importo_Incasso_Consolidato__c = 0;
        p.Nome_Collector_Attivo__c = 'XXX';
        p.Request__c = 'Request XXX';
        p.Importo_saldo_Consolidato__c = 0;
        p.Importo_Spese_Consolidato__c = 0;
        p.Importo_Scaduto_Consolidato__c = 0;
        p.Scaduto_Spese__c = 0;
        p.Scaduto_Spese_Consolidato__c = 0;
        p.Stato__c = 'Bozza';
        p.OwnerId = UserInfo.getUserId();
        return p;
    }

    //Metodo Creazione lista movimenti
    public static List<Movimento__c> getTestMovimento(Integer numberOfMovimento) {
        List<Movimento__c> movList = new List<Movimento__c>();
        for (Integer x = 0; x < numberOfMovimento; x++) {
            Movimento__c mov = new Movimento__c();
            mov = getTestMovimento();
            mov.Importo_Saldo_1__c += x;
            movList.add(mov);
        }
        return movList;
    }

    public static Map<String, Schema.RecordTypeInfo> RTMovimentoDevNameID;

    public static Id getRTMovimentoId(String RecordTypeDevName) {
        if (RTMovimentoDevNameID == null) {
            RTMovimentoDevNameID = Schema.SObjectType.Movimento__c.getRecordTypeInfosByDeveloperName();
        }
        return RTMovimentoDevNameID.get(RecordTypeDevName).getRecordTypeId();
    }

    //Metodo creazione movimento   
    public static Movimento__c getTestMovimento() {
        Movimento__c mov = new Movimento__c();
        mov.RecordTypeId = getRTMovimentoId('Fatture');
        mov.Calcola_SALDO_ANNO__c = false;
        mov.Causale__c = 'CAUSALE';
        mov.Causale_Non_Sollecitabile__c = 'Integrazione';
        mov.Data_Emissione__c = System.today();
        mov.Data_Integrazione__c = System.today();
        mov.Data_Integrazione_1__c = System.today();
        mov.Data_Pagamento__c = System.today();
        mov.Data_Scadenza__c = System.today();
        mov.Data_Saldo_1__c = System.today();
        mov.Flag_Incasso_Utente__c = false;
        mov.Importo__c = 1863;
        mov.Importo_Saldo_1__c = 786;
        mov.IsFutureContext__c = false;
        mov.Mese__c = 'AGOSTO';
        mov.Redisuo__c = 47;
        mov.Ritardo__c = 1;
        mov.SALDO_ANNO_LAVORATO__c = false;
        //mov.Sollecitabile__c=false;
        mov.Sollecitabile__c = true;
        mov.Saldo__c = 758;
        mov.Saldo_Mese_Precedente__c = 99;
        mov.Saldo_Mese_Precedente_Data__c = System.today();
        mov.Saldo_Spese__c = 150;
        mov.Saldo_Spese_1__c = 100;
        mov.Saldo_Spese_Mese_Precedente__c = 10;
        mov.Residuo__c = 1;
        mov.Scaduto_Saldo_1__c = 1;
        mov.Tipo_Movimento_SWH__c = 'SWH';
        mov.Tipo_Movimento_SWH_1__c = 'SWH 1';
        mov.Tipo_Scadenza__c = 'Scaduto';
        mov.Write_Off__c = false;
        mov.Write_Off_1__c = false;

        return mov;
    }

    //metodo creazione task
    public static Task getTestTask() {
        Task t = new Task();
        t.Subject = 'prova';
        ActivityExtended__c ae = new ActivityExtended__c();
        ae.Tipo__c = 'Proposta';
        insert ae;
        t.ActivityExtended__c = ae.Id;
        return t;
    }

    //Creazione lista note
    public static List<Nota__c> getTestNote(Integer numberOfNote) {
        List<Nota__c> noteList = new List<Nota__c>();

        for (Integer x = 0; x < numberOfNote; x++) {
            Nota__c note = new Nota__c();
            note = getTestNote();
            note.Nota__c += x;

            noteList.add(note);
        }
        return noteList;
    }
    //Creazione nota
    public static Nota__c getTestNote() {
        Nota__c note = new Nota__c();
        note.Current_Note__c = 1;
        note.Data_Inserimento__c = System.today();
        note.Data_Inserimento_2__c = System.today();
        note.Max_Note__c = 7;
        note.Nota__c = 'ccc';
        note.Nota_2__c = 'xxx';
        note.User__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        note.User_2__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        note.Visibilit__c = 'Visibile a tutti';
        note.Visibilit_2__c = 'Visibile a tutti';
        note.OwnerId = UserInfo.getUserId();
        return note;
    }

    //Creazione strategia
    public static Map<String, Schema.RecordTypeInfo> RTStrategiaDevNameID;

    public static Id getRTStrategiaId(String RecordTypeDevName) {
        if (RTStrategiaDevNameID == null) {
            RTStrategiaDevNameID = Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName();
        }
        return RTStrategiaDevNameID.get(RecordTypeDevName).getRecordTypeId();
    }

    public static Strategia__c getTestStrategiaTestata() {
        Strategia__c str = new Strategia__c();
        str.Nome__c = 'STRATEGIA APPALTI';
        str.Priority__c = 0;
        str.Stato__c = 'Attiva';
        str.Versione__c = 1;
        str.RecordTypeId = getRTStrategiaId('Testata');
        str.Tipo_Strategia__c = 'Standard';
        str.Activation_roles__c = 'R2014-07-01 11:58:54,R2014-06-27 08:08:28,R2014-07-02 11:48:39,R5,R4,R6,R7,R2014-07-21 10:00:52,R2014-07-02 11:43:56,R3,R2014-07-11 10:29:40';
        return str;
    }

    @IsTest
    static void UnitTestPratica() {

        //Account
        Account TestAcc = getTestAccount();
        insert TestAcc;

        //Servizio
        Servizio__c TestServ = getTestService();
        TestServ.Account__c = TestAcc.Id;
        insert TestServ;

        //Strategia
        Strategia__c TestStrat = getTestStrategiaTestata();
        insert TestStrat;

        //Pratica
        Pratica__c TestPrat = getTestPratica();
        TestPrat.Account__c = TestAcc.Id;
        TestPrat.Servizio_Fornitura__c = TestServ.Id;
        TestPrat.Strategia__c = TestStrat.Id;
        insert TestPrat;

        //Movimenti
        List<Movimento__c> LTestMov = getTestMovimento(5);
        for (Movimento__c m : LTestMov) {
            m.Account__c = TestAcc.Id;
            m.Pratica__c = TestPrat.Id;
            //m.Buffer_Json__c = '[ { "Mese Precedente" : "a04Z0000009LJG5IAO", "Saldo Spese" : null, "Importo Saldo" : "-59.33", "Id" : "a04Z0000009L3urIAC", "Record Type" : "SALDO", "Indice" : "31", "Data Integrazione" : "31/07/2014", "Tipo Movimento SWH" : null, "Scaduto Saldo" : "59.33", "Write Off" : "false", "Data Saldo" : "31/07/2014" } ]';
            //m.RecordTypeId = getRTMovimentoId('SALDO MESE');
        }
        insert LTestMov;

        //Task
        Task TestTask = getTestTask();
        TestTask.WhatId = TestPrat.Id;
        ActivityExtended__c ae = [SELECT Id,Strategia__c FROM ActivityExtended__c WHERE Id = :TestTask.ActivityExtended__c LIMIT 1];
        ae.Strategia__c = TestStrat.Nome__c;
        update ae;
        insert TestTask;

        //Note
        List<Nota__c> TestNote = getTestNote(10);
        for (Nota__c n : TestNote) {
            n.Pratica__c = TestPrat.Id;
        }
        insert TestNote;

        //Custom setting Max Note
        Max_Note__c testMaxNote = new Max_Note__c();
        testMaxNote.Name = 'Max';
        testMaxNote.Max_Note__c = 100;
        insert testMaxNote;

        Test.startTest();

        //Inizializzazione pagina e controller
        PageReference pageRef = Page.CruscottoPraticaEmbedded;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController con = new ApexPages.StandardController(TestPrat);
        ApexPages.currentPage().getParameters().put('Id', TestPrat.Id);
        CruscottoPraticaCTRL cp = new CruscottoPraticaCTRL(con);

        List<ChrtSaldi> ChartSaldi = cp.ChrtSaldi;
        cp.getListNote();
        cp.getTLTask();
        cp.getlPr();
        cp.getPieData();
        cp.getChrtSaldi();
        cp.getStkData();
        cp.BloccaPratica();
        cp.SbloccaPratica();
        cp.n = getTestNote();
        cp.SaveNote();
        cp.AggiornaNote();
        cp.AssociaStrategia();
        cp.CambiaStrategia();
        cp.getListSaldi();
        cp.Next();
        cp.Previous();
        cp.Beginning();
        cp.End();
        cp.getDisableNext();
        cp.getDisablePrevious();
        cp.Refresh();
        cp.getleftselected_Mot_Blo();
        DefaultView__c dv = new DefaultView__c(Name = 'Pratica', View_ID__c = 'str');
        insert dv;
        String s = cp.getListViewId();
        PageReference p = cp.CambioAttivitaPuntuale();
        p = cp.approvaTaskDalOperatore();
        p = cp.mandaTaskInApprovazione();

        // test dei property
        Boolean isTest = cp.hasNext;
        isTest = cp.hasPrevious;
        Integer num = cp.pageNumber;
        List<Affidamento__c> la = cp.ListAffidamenti;
        Boolean b = cp.taskApertoId;
        b = cp.isVisibleApprovaTaskManager;
        b = cp.isVisibleMandaInAppr;

        Test.stopTest();

    }

    static testMethod void testMatStr() {

        //Account
        Account TestAcc = getTestAccount();
        insert TestAcc;

        //Servizio
        Servizio__c TestServ = getTestService();
        TestServ.Account__c = TestAcc.Id;
        insert TestServ;

        //Strategia
        Strategia__c TestStrat = getTestStrategiaTestata();
        insert TestStrat;

        //Pratica
        Pratica__c testPrat = getTestPratica();
        testPrat.CDI_Json__c = testPrat.CDI_Json__c = '[{"objField":"Comune__c","strategiaField":"Comune__c","RuleName":"R2014-06-27 08:08:28","strategiaValue":"Rho","condition":"!=","objValue":"NOVATE"},{"objField":"Metodo_di_Pagamento__c","strategiaField":"Metodo_di_Pagamento__c","RuleName":"R5","strategiaValue":"RID","condition":"!=","objValue":"ALTRO"}]';
        testPrat.Account__c = TestAcc.Id;
        testPrat.Servizio_Fornitura__c = TestServ.Id;
        testPrat.Strategia__c = TestStrat.Id;
        insert testPrat;

        //Movimenti
        List<Movimento__c> movList = getTestMovimento(5);
        for (Movimento__c mov : movList) {
            mov.Account__c = TestAcc.Id;
            mov.Pratica__c = testPrat.Id;
            //m.Buffer_Json__c = '[ { "Mese Precedente" : "a04Z0000009LJG5IAO", "Saldo Spese" : null, "Importo Saldo" : "-59.33", "Id" : "a04Z0000009L3urIAC", "Record Type" : "SALDO", "Indice" : "31", "Data Integrazione" : "31/07/2014", "Tipo Movimento SWH" : null, "Scaduto Saldo" : "59.33", "Write Off" : "false", "Data Saldo" : "31/07/2014" } ]';
            //m.RecordTypeId = getRTMovimentoId('SALDO MESE');
        }
        insert movList;

        //Task
        Task TestTask = getTestTask();
        TestTask.WhatId = testPrat.Id;
        ActivityExtended__c ae = [SELECT Id,Strategia__c FROM ActivityExtended__c WHERE Id = :TestTask.ActivityExtended__c LIMIT 1];
        ae.Strategia__c = TestStrat.Nome__c;
        update ae;
        insert TestTask;

        // Crea CDI
        // ES: Matrice Strategia
        Strategia__c cdi = new Strategia__c();
        cdi.RecordTypeId = getRTStrategiaId('Condizioni_di_Ingresso');
        cdi.Testata__c = testPrat.Strategia__c;
        cdi.Comune__c = 'Rho';
        cdi.Metodo_di_Pagamento__c = 'ALTRO';
        insert cdi;
        testPrat.ConDiIng__c = cdi.Id;
        update testPrat;

        Fasce_di_Rischio__c fdr = new Fasce_di_Rischio__c(Name = 'Fino a 10 gg',Ordine__c = 1, Lingua_Utente__c = 'Italiano');
        insert fdr;

        Test.startTest();
        PageReference pageRef = Page.CruscottoPraticaEmbedded;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController con = new ApexPages.StandardController(testPrat);
        ApexPages.currentPage().getParameters().put('Id', testPrat.Id);
        CruscottoPraticaCTRL cp = new CruscottoPraticaCTRL(con);

        CRABB_ColumnChart.CRABBIstogramma Ist = CRABB_PraticaAgeingCtrl.getAgeing(testPrat.Id);

        Test.stopTest();
    }

}