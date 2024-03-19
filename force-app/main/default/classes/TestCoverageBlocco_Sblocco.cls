/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestCoverageBlocco_Sblocco.cls
Description:     Test Class for code coverage of Blocco_Sblocco.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
02-Apr-2020  0.1      M. Sala                         First Version
08-Sep-2021  0.2      C. Sanna                        Replaced Service Record Type Name
----------------------------------------------------------------------------------------------------------------------*/

@IsTest
private class TestCoverageBlocco_Sblocco {

    public static final Id STR_RTID_STEP = Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    public static final Id STR_RTID_TESTATA = Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
    public static final Id ACC_RTID_TUTORE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CONSUMER').getRecordTypeId();
    public static final Id SERV_RTID_PRECE = Schema.SObjectType.Servizio__c.getRecordTypeInfosByDeveloperName().get('PRECE').getRecordTypeId();
    public static final Id MOV_RTID_SALDO = Schema.SObjectType.Movimento__c.getRecordTypeInfosByDeveloperName().get('Saldo').getRecordTypeId();
    public static final Id CONTR_RTID_APPALTO = Schema.SObjectType.Contratto__c.getRecordTypeInfosByDeveloperName().get('APPALTO').getRecordTypeId();

    @IsTest static void myUnitTest() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;

        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;

        List<String> stratgIdsList = new List<String>();
        for (Strategia__c str : strategieList) {
            stratgIdsList.add(String.valueOf(str.Id));
        }

        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account acc = new Account();
            acc.Name = 'PetreSeiLungo';
            acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(acc);
        }
        insert accountsList;

        //Creo 18 Pratiche
        List<Pratica__c> praticheSblocList = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c pratc = new Pratica__c();
            pratc.Stato__c = 'In Lavorazione';
            praticheSblocList.add(pratc);
        }
        insert praticheSblocList;

        //Creo 18 Movimenti
        
        List<Movimento__c> movList = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c mov = new Movimento__c();
            mov.Residuo__c = 12.5;
            mov.RecordTypeId = MOV_RTID_SALDO;
            mov.Account__c = accountsList[i].Id;
            mov.Pratica__c = praticheSblocList[i].Id;
            mov.Data_Scadenza__c = Date.today() + 20;
            mov.Data_Emissione__c = Date.today();
            mov.Sollecitabile__c = true;
            movList.add(mov);
        }
        insert movList;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : praticheSblocList)
            ListIdPratica.add(Prat.Id);

        Profile profile = [select id from Profile where name like '%admin%' limit 1];

        User Utente1 = new User (IsActive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', ProfileId = profile.Id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (IsActive = true,
                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = profile.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = stratgIdsList[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.WhatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Puppa');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '1');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '12.00';
        bloccSblCTRL.ScadutoA = '13.00';
        bloccSblCTRL.ScadutoConsolidatoDa = '12.00';
        bloccSblCTRL.ScadutoConsolidatoA = '13.00';
        bloccSblCTRL.SaldoSpeseDa = '12.00';
        bloccSblCTRL.SaldoSpeseA = '13.00';
        bloccSblCTRL.SaldoConsolidatoDa = '12.00';
        bloccSblCTRL.SaldoConsolidatoA = '13.00';
        bloccSblCTRL.SaldoDa = '12.00';
        bloccSblCTRL.SaldoA = '13.00';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();
        bloccSblCTRL.Next();
        bloccSblCTRL.End();

        bloccSblCTRL.Previous();
        bloccSblCTRL.Beginning();

    }

    @IsTest static void myUnitTest2() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'ExternalIdContratto');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '1');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '12.00';
        bloccSblCTRL.ScadutoA = '13.00';
        bloccSblCTRL.ScadutoConsolidatoDa = '';
        bloccSblCTRL.ScadutoConsolidatoA = '';
        bloccSblCTRL.SaldoSpeseDa = '';
        bloccSblCTRL.SaldoSpeseA = '';
        bloccSblCTRL.SaldoConsolidatoDa = '';
        bloccSblCTRL.SaldoConsolidatoA = '';
        bloccSblCTRL.SaldoDa = '';
        bloccSblCTRL.SaldoA = '';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();
        bloccSblCTRL.getListPraticheSelectable();
        bloccSblCTRL.Next();
        bloccSblCTRL.End();

        bloccSblCTRL.Previous();
        bloccSblCTRL.Beginning();
        bloccSblCTRL.getDisablePrevious();
        bloccSblCTRL.getDisableNext();
        bloccSblCTRL.Indietro();
        bloccSblCTRL.ConfermaSelezione();
        bloccSblCTRL.SelectAll();
        bloccSblCTRL.Blocca();
        bloccSblCTRL.Sblocca();
        bloccSblCTRL.Continua();
        bloccSblCTRL.AggiornaElementoLista();

    }

    @IsTest static void myUnitTest3() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'Torino');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '2');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '12.00';
        bloccSblCTRL.ScadutoA = '13.00';
        bloccSblCTRL.ScadutoConsolidatoDa = '';
        bloccSblCTRL.ScadutoConsolidatoA = '';
        bloccSblCTRL.SaldoSpeseDa = '';
        bloccSblCTRL.SaldoSpeseA = '';
        bloccSblCTRL.SaldoConsolidatoDa = '';
        bloccSblCTRL.SaldoConsolidatoA = '';
        bloccSblCTRL.SaldoDa = '';
        bloccSblCTRL.SaldoA = '';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();
        bloccSblCTRL.getListPraticheSelectable();
        bloccSblCTRL.Next();
        bloccSblCTRL.End();

        bloccSblCTRL.Previous();
        bloccSblCTRL.Beginning();
        bloccSblCTRL.getDisablePrevious();
        bloccSblCTRL.getDisableNext();
        bloccSblCTRL.Indietro();
        bloccSblCTRL.ConfermaSelezione();
        bloccSblCTRL.SelectAll();
        bloccSblCTRL.Blocca();
        bloccSblCTRL.Sblocca();
        bloccSblCTRL.Continua();
        bloccSblCTRL.AggiornaElementoLista();

    }

    @IsTest static void myUnitTest4() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        //Service PRECE RT Label = CRABB 2
        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'CRABB 2');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '3');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '12.00';
        bloccSblCTRL.ScadutoA = '13.00';
        bloccSblCTRL.ScadutoConsolidatoDa = '';
        bloccSblCTRL.ScadutoConsolidatoA = '';
        bloccSblCTRL.SaldoSpeseDa = '';
        bloccSblCTRL.SaldoSpeseA = '';
        bloccSblCTRL.SaldoConsolidatoDa = '';
        bloccSblCTRL.SaldoConsolidatoA = '';
        bloccSblCTRL.SaldoDa = '';
        bloccSblCTRL.SaldoA = '';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();
        bloccSblCTRL.getListPraticheSelectable();
        bloccSblCTRL.Next();
        bloccSblCTRL.End();

        bloccSblCTRL.Previous();
        bloccSblCTRL.Beginning();
        bloccSblCTRL.getDisablePrevious();
        bloccSblCTRL.getDisableNext();
        bloccSblCTRL.Indietro();
        bloccSblCTRL.ConfermaSelezione();
        bloccSblCTRL.SelectAll();
        bloccSblCTRL.Blocca();
        bloccSblCTRL.Sblocca();
        bloccSblCTRL.Continua();
        bloccSblCTRL.AggiornaElementoLista();

    }

    @IsTest static void myUnitTest5() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', 'In Lavorazione');
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '4');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '12.00';
        bloccSblCTRL.ScadutoA = '13.00';
        bloccSblCTRL.ScadutoConsolidatoDa = '';
        bloccSblCTRL.ScadutoConsolidatoA = '';
        bloccSblCTRL.SaldoSpeseDa = '';
        bloccSblCTRL.SaldoSpeseA = '';
        bloccSblCTRL.SaldoConsolidatoDa = '';
        bloccSblCTRL.SaldoConsolidatoA = '';
        bloccSblCTRL.SaldoDa = '';
        bloccSblCTRL.SaldoA = '';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();
        bloccSblCTRL.getListPraticheSelectable();
        bloccSblCTRL.Next();
        bloccSblCTRL.End();

        bloccSblCTRL.Previous();
        bloccSblCTRL.Beginning();
        bloccSblCTRL.getDisablePrevious();
        bloccSblCTRL.getDisableNext();
        bloccSblCTRL.Indietro();
        bloccSblCTRL.ConfermaSelezione();
        bloccSblCTRL.SelectAll();
        bloccSblCTRL.Blocca();
        bloccSblCTRL.Sblocca();
        bloccSblCTRL.Continua();
        bloccSblCTRL.AggiornaElementoLista();

    }

    @IsTest static void myUnitTes6() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        for (Account Acc : accountsList) {
            System.debug('Classe di Rischio = ' + Acc.Classe_di_Rischio__c);
        }
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', null);
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '5');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '12.00';
        bloccSblCTRL.ScadutoA = '13.00';
        bloccSblCTRL.ScadutoConsolidatoDa = '';
        bloccSblCTRL.ScadutoConsolidatoA = '';
        bloccSblCTRL.SaldoSpeseDa = '';
        bloccSblCTRL.SaldoSpeseA = '';
        bloccSblCTRL.SaldoConsolidatoDa = '';
        bloccSblCTRL.SaldoConsolidatoA = '';
        bloccSblCTRL.SaldoDa = '';
        bloccSblCTRL.SaldoA = '';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();
        bloccSblCTRL.getListPraticheSelectable();
        bloccSblCTRL.Next();
        bloccSblCTRL.End();

        bloccSblCTRL.Previous();
        bloccSblCTRL.Beginning();
        bloccSblCTRL.getDisablePrevious();
        bloccSblCTRL.getDisableNext();
        bloccSblCTRL.Indietro();
        bloccSblCTRL.ConfermaSelezione();
        bloccSblCTRL.SelectAll();
        bloccSblCTRL.Blocca();
        bloccSblCTRL.Sblocca();
        bloccSblCTRL.Continua();
        bloccSblCTRL.AggiornaElementoLista();

    }

    @IsTest static void myUnitTes7() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        for (Account Acc : accountsList) {
            System.debug('Classe di Rischio = ' + Acc.Classe_di_Rischio__c);
        }
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', null);
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '5');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '12.00';
        bloccSblCTRL.ScadutoA = '13.00';
        bloccSblCTRL.ScadutoConsolidatoDa = 'errore';
        bloccSblCTRL.ScadutoConsolidatoA = '';
        bloccSblCTRL.SaldoSpeseDa = '';
        bloccSblCTRL.SaldoSpeseA = '';
        bloccSblCTRL.SaldoConsolidatoDa = '';
        bloccSblCTRL.SaldoConsolidatoA = '';
        bloccSblCTRL.SaldoDa = '';
        bloccSblCTRL.SaldoA = '';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();

    }

    @IsTest static void myUnitTes8() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        for (Account Acc : accountsList) {
            System.debug('Classe di Rischio = ' + Acc.Classe_di_Rischio__c);
        }
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', null);
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '5');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = 'errore';
        bloccSblCTRL.ScadutoA = '34';
        bloccSblCTRL.ScadutoConsolidatoDa = '';
        bloccSblCTRL.ScadutoConsolidatoA = '';
        bloccSblCTRL.SaldoSpeseDa = '';
        bloccSblCTRL.SaldoSpeseA = '';
        bloccSblCTRL.SaldoConsolidatoDa = '';
        bloccSblCTRL.SaldoConsolidatoA = '';
        bloccSblCTRL.SaldoDa = '';
        bloccSblCTRL.SaldoA = '';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();

    }

    @IsTest static void myUnitTes9() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        for (Account Acc : accountsList) {
            System.debug('Classe di Rischio = ' + Acc.Classe_di_Rischio__c);
        }
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', null);
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '5');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '12.00';
        bloccSblCTRL.ScadutoA = 'errore';
        bloccSblCTRL.ScadutoConsolidatoDa = '';
        bloccSblCTRL.ScadutoConsolidatoA = '';
        bloccSblCTRL.SaldoSpeseDa = '';
        bloccSblCTRL.SaldoSpeseA = '';
        bloccSblCTRL.SaldoConsolidatoDa = '';
        bloccSblCTRL.SaldoConsolidatoA = '';
        bloccSblCTRL.SaldoDa = '';
        bloccSblCTRL.SaldoA = '';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();

    }

    @IsTest static void myUnitTes10() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        for (Account Acc : accountsList) {
            System.debug('Classe di Rischio = ' + Acc.Classe_di_Rischio__c);
        }
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', null);
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '5');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '12.00';
        bloccSblCTRL.ScadutoA = '13.00';
        bloccSblCTRL.ScadutoConsolidatoDa = '';
        bloccSblCTRL.ScadutoConsolidatoA = 'errore';
        bloccSblCTRL.SaldoSpeseDa = '';
        bloccSblCTRL.SaldoSpeseA = '';
        bloccSblCTRL.SaldoConsolidatoDa = '';
        bloccSblCTRL.SaldoConsolidatoA = '';
        bloccSblCTRL.SaldoDa = '';
        bloccSblCTRL.SaldoA = '';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();

    }

    @IsTest static void myUnitTes11() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        for (Account Acc : accountsList) {
            System.debug('Classe di Rischio = ' + Acc.Classe_di_Rischio__c);
        }
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', null);
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '5');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '12.00';
        bloccSblCTRL.ScadutoA = '13.00';
        bloccSblCTRL.ScadutoConsolidatoDa = '';
        bloccSblCTRL.ScadutoConsolidatoA = '';
        bloccSblCTRL.SaldoSpeseDa = 'errore';
        bloccSblCTRL.SaldoSpeseA = '';
        bloccSblCTRL.SaldoConsolidatoDa = '';
        bloccSblCTRL.SaldoConsolidatoA = '';
        bloccSblCTRL.SaldoDa = '';
        bloccSblCTRL.SaldoA = '';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();

    }

    @IsTest static void myUnitTes12() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        for (Account Acc : accountsList) {
            System.debug('Classe di Rischio = ' + Acc.Classe_di_Rischio__c);
        }
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', null);
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '5');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '12.00';
        bloccSblCTRL.ScadutoA = '13.00';
        bloccSblCTRL.ScadutoConsolidatoDa = '';
        bloccSblCTRL.ScadutoConsolidatoA = '';
        bloccSblCTRL.SaldoSpeseDa = '';
        bloccSblCTRL.SaldoSpeseA = '';
        bloccSblCTRL.SaldoConsolidatoDa = 'errore';
        bloccSblCTRL.SaldoConsolidatoA = '';
        bloccSblCTRL.SaldoDa = '';
        bloccSblCTRL.SaldoA = '';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();

    }

    @IsTest static void myUnitTes13() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        for (Account Acc : accountsList) {
            System.debug('Classe di Rischio = ' + Acc.Classe_di_Rischio__c);
        }
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', null);
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '5');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '12.00';
        bloccSblCTRL.ScadutoA = '13.00';
        bloccSblCTRL.ScadutoConsolidatoDa = '';
        bloccSblCTRL.ScadutoConsolidatoA = '';
        bloccSblCTRL.SaldoSpeseDa = '';
        bloccSblCTRL.SaldoSpeseA = '';
        bloccSblCTRL.SaldoConsolidatoDa = '';
        bloccSblCTRL.SaldoConsolidatoA = 'errore';
        bloccSblCTRL.SaldoDa = '';
        bloccSblCTRL.SaldoA = '';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();

    }

    @IsTest static void myUnitTes14() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        for (Account Acc : accountsList) {
            System.debug('Classe di Rischio = ' + Acc.Classe_di_Rischio__c);
        }
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', null);
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '5');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '12.00';
        bloccSblCTRL.ScadutoA = '13.00';
        bloccSblCTRL.ScadutoConsolidatoDa = '';
        bloccSblCTRL.ScadutoConsolidatoA = '';
        bloccSblCTRL.SaldoSpeseDa = '';
        bloccSblCTRL.SaldoSpeseA = '';
        bloccSblCTRL.SaldoConsolidatoDa = '';
        bloccSblCTRL.SaldoConsolidatoA = '';
        bloccSblCTRL.SaldoDa = 'errore';
        bloccSblCTRL.SaldoA = '';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();

    }

    @IsTest static void myUnitTes15() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        for (Account Acc : accountsList) {
            System.debug('Classe di Rischio = ' + Acc.Classe_di_Rischio__c);
        }
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', null);
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '5');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '12.00';
        bloccSblCTRL.ScadutoA = '13.00';
        bloccSblCTRL.ScadutoConsolidatoDa = '';
        bloccSblCTRL.ScadutoConsolidatoA = '';
        bloccSblCTRL.SaldoSpeseDa = '';
        bloccSblCTRL.SaldoSpeseA = '';
        bloccSblCTRL.SaldoConsolidatoDa = '';
        bloccSblCTRL.SaldoConsolidatoA = '';
        bloccSblCTRL.SaldoDa = '';
        bloccSblCTRL.SaldoA = 'errore';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();

    }

    @IsTest static void myUnitTes16() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        for (Account Acc : accountsList) {
            System.debug('Classe di Rischio = ' + Acc.Classe_di_Rischio__c);
        }
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', null);
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '5');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '12.00';
        bloccSblCTRL.ScadutoA = '13.00';
        bloccSblCTRL.ScadutoConsolidatoDa = '';
        bloccSblCTRL.ScadutoConsolidatoA = '';
        bloccSblCTRL.SaldoSpeseDa = '';
        bloccSblCTRL.SaldoSpeseA = 'errore';
        bloccSblCTRL.SaldoConsolidatoDa = '';
        bloccSblCTRL.SaldoConsolidatoA = '';
        bloccSblCTRL.SaldoDa = '';
        bloccSblCTRL.SaldoA = '';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();

    }

    @IsTest static void myUnitTes17() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        for (Account Acc : accountsList) {
            System.debug('Classe di Rischio = ' + Acc.Classe_di_Rischio__c);
        }
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', null);
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '5');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '12.00';
        bloccSblCTRL.ScadutoA = '';
        bloccSblCTRL.ScadutoConsolidatoDa = '';
        bloccSblCTRL.ScadutoConsolidatoA = '';
        bloccSblCTRL.SaldoSpeseDa = '';
        bloccSblCTRL.SaldoSpeseA = '';
        bloccSblCTRL.SaldoConsolidatoDa = '';
        bloccSblCTRL.SaldoConsolidatoA = '';
        bloccSblCTRL.SaldoDa = '';
        bloccSblCTRL.SaldoA = '';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();

    }

    @IsTest static void myUnitTes18() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        for (Account Acc : accountsList) {
            System.debug('Classe di Rischio = ' + Acc.Classe_di_Rischio__c);
        }
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', null);
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '5');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '';
        bloccSblCTRL.ScadutoA = '';
        bloccSblCTRL.ScadutoConsolidatoDa = '13.00';
        bloccSblCTRL.ScadutoConsolidatoA = '';
        bloccSblCTRL.SaldoSpeseDa = '';
        bloccSblCTRL.SaldoSpeseA = '';
        bloccSblCTRL.SaldoConsolidatoDa = '';
        bloccSblCTRL.SaldoConsolidatoA = '';
        bloccSblCTRL.SaldoDa = '';
        bloccSblCTRL.SaldoA = '';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();

    }

    @IsTest static void myUnitTes19() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        for (Account Acc : accountsList) {
            System.debug('Classe di Rischio = ' + Acc.Classe_di_Rischio__c);
        }
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', null);
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '5');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '12.00';
        bloccSblCTRL.ScadutoA = '13.00';
        bloccSblCTRL.ScadutoConsolidatoDa = '';
        bloccSblCTRL.ScadutoConsolidatoA = '';
        bloccSblCTRL.SaldoSpeseDa = '13.00';
        bloccSblCTRL.SaldoSpeseA = '';
        bloccSblCTRL.SaldoConsolidatoDa = '';
        bloccSblCTRL.SaldoConsolidatoA = '';
        bloccSblCTRL.SaldoDa = '';
        bloccSblCTRL.SaldoA = '';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();

    }

    @IsTest static void myUnitTes20() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        for (Account Acc : accountsList) {
            System.debug('Classe di Rischio = ' + Acc.Classe_di_Rischio__c);
        }
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', null);
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '5');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '12.00';
        bloccSblCTRL.ScadutoA = '13.00';
        bloccSblCTRL.ScadutoConsolidatoDa = '';
        bloccSblCTRL.ScadutoConsolidatoA = '';
        bloccSblCTRL.SaldoSpeseDa = '';
        bloccSblCTRL.SaldoSpeseA = '';
        bloccSblCTRL.SaldoConsolidatoDa = '13.00';
        bloccSblCTRL.SaldoConsolidatoA = '';
        bloccSblCTRL.SaldoDa = '';
        bloccSblCTRL.SaldoA = '';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();

    }

    @IsTest static void myUnitTes21() {
        List<Strategia__c> strategieList = new List<Strategia__c>();
        List<Strategia__c> testateList = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();

        for (Integer i = 0; i < 18; i++) {
            Strategia__c testata = new Strategia__c();
            testata.RecordTypeId = STR_RTID_TESTATA;
            testata.Tipologia__c = 'UI';
            testata.Stato__c = 'Attiva';

            testateList.add(testata);
        }
        insert testateList;
        for (Integer i = 0; i < 18; i++) {
            Strategia__c stratg = new Strategia__c();
            stratg.RecordTypeId = STR_RTID_STEP;
            stratg.Tipologia__c = 'UI';
            stratg.Stato__c = 'Attiva';
            stratg.Testata__c = testateList[i].Id;
            strategieList.add(stratg);
        }
        insert strategieList;
        List<String> ListIdstratg = new List<String>();
        for (Strategia__c Str : strategieList) {
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_Testata__c = ' + Str.Stato_Testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordType.Name);
            System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
            ListIdstratg.add(String.valueOf(Str.Id));
        }
        //Creo 18 Account
        
        List<Account> accountsList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account Acc = new Account();
            Acc.Name = 'PetreSeiLungo';
            Acc.RecordTypeId = ACC_RTID_TUTORE;
            accountsList.add(Acc);
        }
        insert accountsList;
        for (Account Acc : accountsList) {
            System.debug('Classe di Rischio = ' + Acc.Classe_di_Rischio__c);
        }
        //Creo il Contratto
        
        Contratto__c Contr = new Contratto__c ();
        Contr.Id_Esterno__c = 'ExternalIdContratto';
        Contr.RecordTypeId = CONTR_RTID_APPALTO;
        Contr.Titolo__c = 'Comune Torino';
        Contr.Comune__c = 'Torino';
        Contr.Partita_IVA__c = 'PRMNI87C371';
        Contr.Data_Inizio__c = date.today();
        insert Contr;

        //Creo il Servizio di Fornitura
        
        List<Servizio__c> ListServizio = new List<Servizio__c>();
        for (Integer i = 0; i < 18; i++) {
            Servizio__c Serv = new Servizio__c();
            Serv.RecordTypeId = SERV_RTID_PRECE;
            Serv.Account__c = accountsList[i].Id;
            Serv.LookupContratto__c = Contr.Id;
            ListServizio.add(Serv);
        }
        insert ListServizio;

        //Creo 18 Pratiche
        List<Pratica__c> ListPraticaSbloc = new List<Pratica__c>();
        for (Integer i = 0; i < 18; i++) {
            Pratica__c Prat = new Pratica__c();
            Prat.Stato__c = 'In Lavorazione';
            Prat.Servizio_Fornitura__c = ListServizio[i].Id;
            ListPraticaSbloc.add(Prat);
        }
        insert ListPraticaSbloc;

        //Creo 18 Movimenti
        
        List<Movimento__c> ListMov = new List<Movimento__c>();
        for (Integer i = 0; i < 18; i++) {
            Movimento__c Mov = new Movimento__c();
            Mov.Residuo__c = 12.5;
            Mov.RecordTypeId = MOV_RTID_SALDO;
            Mov.Account__c = accountsList[i].Id;
            Mov.Pratica__c = ListPraticaSbloc[i].Id;
            Mov.Data_Scadenza__c = Date.today() + 20;
            Mov.Sollecitabile__c = true;
            Mov.Data_Emissione__c = date.today();
            ListMov.add(Mov);
        }
        insert ListMov;

        List<Id> ListIdPratica = new List<Id>();
        for (Pratica__c Prat : ListPraticaSbloc)
            ListIdPratica.add(Prat.Id);

        Profile pro = [select id from profile where name like '%admin%' limit 1];

        User Utente1 = new User (isactive = true,
                Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                Email = 'Unassigned@god.it', Alias = 'Unassi', profileID = pro.id,
                CommunityNickname = 'guest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        User Utente2 = new User (isactive = true,

                Username = 'GEGGIO@acme.com', LastName = 'Aviva',
                Email = 'GEGGIO@god.it', Alias = 'UnassiSa', profileID = pro.id,
                CommunityNickname = 'guest2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente2;
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Integer i = 0; i < strategieList.size(); i++) {
            Task T = new Task();
            T.OwnerId = Utente1.Id;
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.id_attivita__c = ListIdstratg[i];
            T.Priority = 'Alta';
            ae.Tipo__c = 'Decreto';
            ae.Sotto_Tipo__c = 'Piano di rientro';
            T.Status = 'Non Iniziata';
            T.whatId = ListIdPratica[i];
            ae.Owner_contratto__c = 'Gelsomino';
            T.ActivityExtended__c = ae.Id;
            aes.add(ae);
            ListTask.add(T);
        }
        insert aes;
        insert ListTask;

        Page_layout_control__c PageLayout = new Page_layout_control__c();
        PageLayout.Page__c = 'LayoutPage';
        PageLayout.Visible__c = true;
        PageLayout.Name = 'LayoutPage';
        PageLayout.TagName__c = 'TagName';
        insert PageLayout;

        String sElenco = ApexPages.currentPage().getParameters().put('ValSelected', null);
        String iIndex = ApexPages.currentPage().getParameters().put('IndexSelected', '5');

        BloccoSbloccoCTRL bloccSblCTRL = new BloccoSbloccoCTRL();
        List<String> originalValues_IdContratto = bloccSblCTRL.originalValues_IdContratto;
        List<String> originalValues_Comuni = bloccSblCTRL.originalValues_Comuni;
        List<String> originalValues_Servizio = bloccSblCTRL.originalValues_Servizio;
        List<String> originalValues_Stato = bloccSblCTRL.originalValues_Stato;
        List<String> originalValues_CdR = bloccSblCTRL.originalValues_CdR;
        bloccSblCTRL.leftselected_SelTipo = 'Blocco';
        bloccSblCTRL.ScadutoDa = '12.00';
        bloccSblCTRL.ScadutoA = '13.00';
        bloccSblCTRL.ScadutoConsolidatoDa = '';
        bloccSblCTRL.ScadutoConsolidatoA = '';
        bloccSblCTRL.SaldoSpeseDa = '';
        bloccSblCTRL.SaldoSpeseA = '';
        bloccSblCTRL.SaldoConsolidatoDa = '';
        bloccSblCTRL.SaldoConsolidatoA = '';
        bloccSblCTRL.SaldoDa = '3.2';
        bloccSblCTRL.SaldoA = '';

        bloccSblCTRL.UpdateListe();
        bloccSblCTRL.getleftselected_Mot_Blo();
        bloccSblCTRL.QueryPratiche();

    }

}