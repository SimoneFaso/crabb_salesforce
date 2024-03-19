/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestCoverage_ModificaPreLotti.cls
Description:     Test Class for code coverage of ModificaPreLotti.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
08-Sep-2021  0.2      Giulia Mameli                   Replaced getRecordTypeInfosByName() with
                                                      getRecordTypeInfosByDeveloperName()
----------------------------------------------------------------------------------------------------------------------*/

@IsTest
public class TestCoverage_ModificaPreLotti {

    @IsTest static void TestModificaPreLotti() {
        ModificaPreLotti mpl = new ModificaPreLotti();

    }

    @IsTest static void TestModificaPreLotti2() {
        ModificaPreLotti mpl = new ModificaPreLotti();
        mpl.indice = 5;
        mpl.Previous();
        mpl.Beginning();
        mpl.IndietroPrelotto();
        mpl.IndietroModificaLotti();
        try {
            mpl.CancellaPreLotto();
        } catch (Exception e) {
        }
        try {
            mpl.DeleteAffidamenti_PreLotti();
        } catch (Exception e) {
        }
        try {
            mpl.GeneraLotto();
        } catch (Exception e) {
        }
    }

    @IsTest static void myUnitTest() {
        /*Account ClienteADR = new Account();
        ClienteADR.Name = 'PROVA ADR';
        ClienteADR.Id_Esterno__c = 'ASDAS';
        ClienteADR.Mail1__c = 'AAAasd@gmail.com';
        insert ClienteADR;
        
        
        Id rtContact =  Schema.SObjectType.Contact.getRecordTypeInfosByName().get('RESIDENZA').getRecordTypeId();
        Contact Cont = new Contact();
        Cont.AccountId = ClienteADR.Id;
        Cont.FirstName = 'PROVA';
        Cont.LastName = 'ADR';
        Cont.RecordTypeId = rtContact;
        insert Cont;
        
        
        Profile prof = [select id, Name from profile where name like '%CRABB Partner%' limit 1];
        User Utente = new User ( isactive = true,
                    Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                    Email = 'Unassigned@god.it', Alias = 'Unassi',profileID = prof.id,
                    CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                    EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', ContactId = Cont.id
               );
        insert Utente;
        system.debug('****Prof.Id = ' + Prof.Id);
        system.debug('****Utente.Id = ' + Utente.Id +'- Profile.Name = ' + Prof.Name);*/
        /*Profile Prof = [Select Id, Name FROM Profile where Name = 'System Administrator'];
        
        User Utente = [Select Id, Name, Profile.Name from User where Profile.Id =: Prof.Id];*/

        User utente = TestClassFroDataGenAffidamenti.getUser('CRABB Operatore Credito');
        Collector__c Coll = new Collector__c();
        Coll.Prefisso_Lotto__c = 'AAA';
        Coll.Ragione_Sociale__c = 'Avv. Test Test';
        Coll.Tipo_Collector__c = 'LEGALE';
        Coll.User__c = utente.Id;
        insert Coll;

        Date dataInizio = Date.Today();
        Id rtContr_Concessione = Schema.SObjectType.Contratto__c.getRecordTypeInfosByDeveloperName().get('CONCESSIONE').getRecordTypeId();
        Contratto__c contratto = new Contratto__c();
        contratto.RecordTypeId = rtContr_Concessione;
        contratto.Dominio__c = 'Scuola';
        contratto.Id_Esterno__c = 'ETC';
        contratto.Data_Inizio__c = dataInizio;
        contratto.Partita_IVA__c = '64536475876';
        contratto.Titolo__c = 'Sign.';
        contratto.Comune__c = 'Milano';
        insert contratto;

        Account cliente = new Account();
        cliente.Name = 'CAINO PAOLO';
        cliente.Id_Esterno__c = 'ETC_91132_2567';
        cliente.Mail1__c = 'dasd@gmail.com';
        insert cliente;

        Id rtServ_Preref = Schema.SObjectType.Servizio__c.getRecordTypeInfosByDeveloperName().get('PREREF').getRecordTypeId();
        Servizio__c servizio = new Servizio__c();
        servizio.RecordTypeId = rtServ_Preref;
        servizio.Stato__c = 'Attivo';
        servizio.Nome__c = 'PREPAGATO-REFEZIONE';
        servizio.LookupContratto__c = contratto.Id;
        servizio.Account__c = cliente.Id;
        insert servizio;


        Lotto__c lotto = new Lotto__c();
        lotto.Agenzia_di_Recupero__c = Coll.Id;
        lotto.Tipo__c = 'PreLotto';
        lotto.Stato__c = 'Confermato';

        insert lotto;

        Pratica__c pratica = new Pratica__c();
        pratica.Account__c = cliente.Id;
        pratica.Servizio_Fornitura__c = servizio.Id;
        insert pratica;

        List<Affidamento__c> ListAff = new List<Affidamento__c>();
        for (Integer i = 0; i < 10; i++) {
            Affidamento__c affidList = new Affidamento__c();
            affidList.Lotto__c = lotto.Id;
            affidList.Pratica__c = pratica.Id;
            ListAff.add(affidList);
        }
        insert ListAff;

        Id IdPreLotto = ApexPages.currentPage().getParameters().put('IdPreLotto', lotto.Id);
        Id IdAffido = ApexPages.currentPage().getParameters().put('IdAffido', ListAff[0].Id);
        ModificaPreLotti controller = new ModificaPreLotti();
        controller.recordsForPage = '25';
        List<SelectOption> recForPageValues = controller.recordsForPageValues;
        controller.sizeTable();
        controller.Beginning();
        controller.Previous();
        controller.Next();
        controller.ReturnToLotti();
        controller.RevocaAffido();
        controller.Conferma();
        controller.RevocaAffido();
        controller.ReturnToLotti();
        controller.Conferma();
        controller.IndietroModificaLotti();
        controller.getIsBeginningVisibility();
        controller.getIsEndVisibility();
        //controller.Cancella();
        //controller.DeleteAffidamenti_PreLotti();
        controller.End();

    }
}