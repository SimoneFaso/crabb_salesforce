/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestCoverage_PdRContrExt.cls
Description:     Test Class for code coverage of PdRContrExt.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
08-Sep-2021  0.2      Giulia Mameli                   Replaced getRecordTypeInfosByName() with
                                                      getRecordTypeInfosByDeveloperName()
22-Sep-2021  0.3      C. Sanna                        Modified for coverage
----------------------------------------------------------------------------------------------------------------------*/

@IsTest
private class TestCoverage_PdRContrExt {
    public static final Id ACC_RTID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CONSUMER').getRecordTypeId();
    public static final Id SERV_RTID = Schema.SObjectType.Servizio__c.getRecordTypeInfosByDeveloperName().get('PREREF').getRecordTypeId();

    @IsTest static void myUnitTest() {

        Contratto__c contratto = new Contratto__c();
        Date dataInizio = Date.today();
        contratto.Data_Inizio__c = dataInizio;
        contratto.Titolo__c = 'Contratto';
        contratto.Partita_IVA__c = '02197312389';
        contratto.Comune__c = 'Milano';
        insert contratto;

        Account account = new Account();
        account.Id_Esterno__c = 'ETC_Cont_IdExt_ETC2_Account_IdExt_ETC2';
        account.Name = 'Account1';
        account.RecordTypeId = ACC_RTID;
        insert account;

        Servizio__c servizio = new Servizio__c();
        servizio.Id_Esterno__c = 'ETC_Cont_IdExt_ETC2_Account_IdExt_ETC2_POSTREF';
        servizio.RecordTypeId = SERV_RTID;
        servizio.Account__c = account.Id;
        servizio.LookupContratto__c = contratto.Id;
        insert servizio;

        Servizi_Item__c serviziItem = new Servizi_Item__c();
        serviziItem.Servizio__c = servizio.Id;
        serviziItem.Classe__c = 'VB';
        serviziItem.Cognome__c = 'Pinturicchio';
        serviziItem.Data_di_Nascita__c = Date.newInstance(1989, 03, 03);
        serviziItem.Nome__c = 'Albertino';
        serviziItem.Luogo_di_Nascita__c = 'Torino';
        serviziItem.MF__c = 'MASCHIO';
        serviziItem.Scuola__c = 'ENIGEN';
        serviziItem.Id_Esterno__c = 'ETC_Cont_IdExt_ETC3_Fru_Id_ETC3';
        insert serviziItem;

        Pratica__c pratica = new Pratica__c();
        pratica.Account__c = account.Id;
        pratica.Servizio_Fornitura__c = servizio.Id;
        pratica.Stato__c = 'Bozza';
        insert pratica;

        Movimento__c movSaldo = new Movimento__c();
        movSaldo.Id_Movimento_Ext__c = 'ETC_Cont_IdExt_ETC3_Account_IdExt_ETC3_POSTREF_201405';
        movSaldo.Id_Esterno_Saldo_Mensile__c = 'ETC_Cont_IdExt_ETC3_Account_IdExt_ETC3_POSTREF_201405';
        movSaldo.Pratica__c = pratica.Id;
        movSaldo.Account__c = account.Id;
        movSaldo.Servizio_Fornitura__c = servizio.Id;
        movSaldo.Data_Scadenza__c = Date.newInstance(2015, 03, 03);
        movSaldo.Data_Emissione__c = Date.newInstance(2013, 03, 03);
        movSaldo.Servizio_Item__c = serviziItem.Id;
        movSaldo.Residuo__c = 20.20;
        movSaldo.Sollecitabile__c = true;
        insert movSaldo;


        Piano_di_Rientro__c pdr = new Piano_di_Rientro__c();
        pdr.Pratica__c = pratica.Id;
        pdr.Importo_Totale__c = 20.90;
        pdr.Stato__c = 'Attivo';
        pdr.Numero_di_Rate__c = 3;
        insert pdr;

        Id IdPratica = ApexPages.currentPage().getParameters().put('PraticaId', pratica.Id);

        ApexPages.StandardController stndController = new ApexPages.StandardController(pdr);
        PdRContrExt controller = new PdRContrExt(stndController);
        controller.getImporto();
        controller.getImportoRata();
        controller.getNumeroRate();
        controller.CalcolaPdR();
        controller.RicalcolaImpTot();
        controller.AddRata();
        controller.Submit();
        controller.actionDeleteInstalment();
        Map<Integer, Rateizzazione__c> mapRates = new Map<Integer, Rateizzazione__c>();
        controller.installmentsValidation(mapRates);

    }

    @IsTest static void myUnitTest2() {

        Contratto__c contratto = new Contratto__c();
        Date dataInizio = Date.today();
        contratto.Data_Inizio__c = dataInizio;
        contratto.Titolo__c = 'Contratto';
        contratto.Partita_IVA__c = '02197312389';
        contratto.Comune__c = 'Milano';
        insert contratto;

        Account account = new Account();
        account.Id_Esterno__c = 'ETC_Cont_IdExt_ETC2_Account_IdExt_ETC2';
        account.Name = 'Account1';
        account.RecordTypeId = ACC_RTID;
        insert account;

        Servizio__c servizio = new Servizio__c();
        servizio.Id_Esterno__c = 'ETC_Cont_IdExt_ETC2_Account_IdExt_ETC2_POSTREF';
        servizio.RecordTypeId = SERV_RTID;
        servizio.Account__c = account.Id;
        servizio.LookupContratto__c = contratto.Id;
        insert servizio;

        Servizi_Item__c serviziItem = new Servizi_Item__c();
        serviziItem.Servizio__c = servizio.Id;
        serviziItem.Classe__c = 'VB';
        serviziItem.Cognome__c = 'Pinturicchio';
        serviziItem.Data_di_Nascita__c = Date.newInstance(1989, 03, 03);
        serviziItem.Nome__c = 'Albertino';
        serviziItem.Luogo_di_Nascita__c = 'Torino';
        serviziItem.MF__c = 'MASCHIO';
        serviziItem.Scuola__c = 'ENIGEN';
        serviziItem.Id_Esterno__c = 'ETC_Cont_IdExt_ETC3_Fru_Id_ETC3';
        insert serviziItem;

        Pratica__c pratica = new Pratica__c();
        pratica.Account__c = account.Id;
        pratica.Servizio_Fornitura__c = servizio.Id;
        pratica.Stato__c = 'Bozza';
        insert pratica;

        Movimento__c movSaldo = new Movimento__c();
        movSaldo.Id_Movimento_Ext__c = 'ETC_Cont_IdExt_ETC3_Account_IdExt_ETC3_POSTREF_201405';
        movSaldo.Id_Esterno_Saldo_Mensile__c = 'ETC_Cont_IdExt_ETC3_Account_IdExt_ETC3_POSTREF_201405';
        movSaldo.Pratica__c = pratica.Id;
        movSaldo.Account__c = account.Id;
        movSaldo.Servizio_Fornitura__c = servizio.Id;
        movSaldo.Data_Scadenza__c = Date.newInstance(2015, 03, 03);
        movSaldo.Data_Emissione__c = Date.newInstance(2013, 03, 03);
        movSaldo.Servizio_Item__c = serviziItem.Id;
        movSaldo.Residuo__c = 20.20;
        movSaldo.Sollecitabile__c = true;
        insert movSaldo;


        Piano_di_Rientro__c pdr = new Piano_di_Rientro__c();
        pdr.Pratica__c = pratica.Id;
        pdr.Importo_Totale__c = 20.90;
        pdr.Stato__c = 'Attivo';
        pdr.Importo_Rata__c = 23;
        //pdr.Numero_di_Rate__c = 3;
        pdr.Importo_Totale__c = 20;
        insert pdr;

        Id IdPratica = ApexPages.currentPage().getParameters().put('PraticaId', pratica.Id);

        ApexPages.StandardController StController = new ApexPages.StandardController(pdr);
        PdRContrExt Controller = new PdRContrExt(StController);
        Controller.getImporto();
        Controller.getImportoRata();
        Controller.getNumeroRate();
        Controller.CalcolaPdR();
        Controller.RicalcolaImpTot();
        Controller.AddRata();
        Controller.Submit();
        Controller.actionDeleteInstalment();
        Map<Integer, Rateizzazione__c> mapRates = new Map<Integer, Rateizzazione__c>();
        Controller.installmentsValidation(mapRates);

    }

    @IsTest static void myUnitTest3() {

        Contratto__c contratto = new Contratto__c();
        Date dataInizio = Date.today();
        contratto.Data_Inizio__c = dataInizio;
        contratto.Titolo__c = 'Contratto';
        contratto.Partita_IVA__c = '02197312389';
        contratto.Comune__c = 'Milano';
        insert contratto;

        Account account = new Account();
        account.Id_Esterno__c = 'ETC_Cont_IdExt_ETC2_Account_IdExt_ETC2';
        account.Name = 'Account1';
        account.RecordTypeId = ACC_RTID;
        insert account;

        Servizio__c servizio = new Servizio__c();
        servizio.Id_Esterno__c = 'ETC_Cont_IdExt_ETC2_Account_IdExt_ETC2_POSTREF';
        servizio.RecordTypeId = SERV_RTID;
        servizio.Account__c = account.Id;
        servizio.LookupContratto__c = contratto.Id;
        insert servizio;

        Servizi_Item__c serviziItem = new Servizi_Item__c();
        serviziItem.Servizio__c = servizio.Id;
        serviziItem.Classe__c = 'VB';
        serviziItem.Cognome__c = 'Pinturicchio';
        serviziItem.Data_di_Nascita__c = Date.newInstance(1989, 03, 03);
        serviziItem.Nome__c = 'Albertino';
        serviziItem.Luogo_di_Nascita__c = 'Torino';
        serviziItem.MF__c = 'MASCHIO';
        serviziItem.Scuola__c = 'ENIGEN';
        serviziItem.Id_Esterno__c = 'ETC_Cont_IdExt_ETC3_Fru_Id_ETC3';
        insert serviziItem;

        Pratica__c pratica = new Pratica__c();
        pratica.Account__c = account.Id;
        pratica.Servizio_Fornitura__c = servizio.Id;
        pratica.Stato__c = 'Bozza';
        insert pratica;

        Movimento__c movSaldo = new Movimento__c();
        movSaldo.Id_Movimento_Ext__c = 'ETC_Cont_IdExt_ETC3_Account_IdExt_ETC3_POSTREF_201405';
        movSaldo.Id_Esterno_Saldo_Mensile__c = 'ETC_Cont_IdExt_ETC3_Account_IdExt_ETC3_POSTREF_201405';
        movSaldo.Pratica__c = pratica.Id;
        movSaldo.Account__c = account.Id;
        movSaldo.Servizio_Fornitura__c = servizio.Id;
        movSaldo.Data_Scadenza__c = Date.newInstance(2015, 03, 03);
        movSaldo.Data_Emissione__c = Date.newInstance(2013, 03, 03);
        movSaldo.Servizio_Item__c = serviziItem.Id;
        movSaldo.Residuo__c = 0;
        movSaldo.Sollecitabile__c = true;
        insert movSaldo;

        Piano_di_Rientro__c pdr = new Piano_di_Rientro__c();
        pdr.Pratica__c = pratica.Id;
        pdr.Importo_Totale__c = 20.90;
        pdr.Stato__c = 'Attivo';
        //pdr.Importo_Rata__c = 4;
        pdr.Numero_di_Rate__c = 3;
        pdr.Importo_Totale__c = 20;
        insert pdr;
        System.debug('Test pdr --> '+pdr);

        Id IdPratica = ApexPages.currentPage().getParameters().put('PraticaId', pratica.Id);

        ApexPages.StandardController StController = new ApexPages.StandardController(pdr);
        PdRContrExt controller = new PdRContrExt(StController);
        controller.getImporto();
        controller.getImportoRata();
        controller.getNumeroRate();
        controller.CalcolaPdR();
        controller.RicalcolaImpTot();
        controller.AddRata();
        controller.Submit();
        controller.actionDeleteInstalment();
        Map<Integer, Rateizzazione__c> mapRates = new Map<Integer, Rateizzazione__c>();
        controller.installmentsValidation(mapRates);

    }


}