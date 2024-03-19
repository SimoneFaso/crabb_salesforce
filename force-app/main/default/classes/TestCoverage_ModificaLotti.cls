/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestCoverage_ModificaLotti.cls
Description:     Test Class for code coverage of ModificaLotti.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
08-Sep-2021  0.2      Giulia Mameli                   Replaced getRecordTypeInfosByName() with
                                                      getRecordTypeInfosByDeveloperName()
----------------------------------------------------------------------------------------------------------------------*/

@IsTest
public class TestCoverage_ModificaLotti {

    @IsTest static void myUnitTest() {

        /*
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];//rdonato
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
        UserRoleId = portalRole.Id,
        ProfileId = profile1.Id,
        Username = System.now().millisecond() + 'test2@test.com',
        Alias = 'batman',
        Email='bruce.wayne@wayneenterprises.com',
        EmailEncodingKey='UTF-8',
        Firstname='Bruce',
        Lastname='Wayne',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        TimeZoneSidKey='America/Chicago'
        );
        Database.insert(portalAccountOwner1);
        System.runAs ( portalAccountOwner1 ) {}
        Account ClienteADR = new Account();
        ClienteADR.Name = 'PROVA ADR';
        ClienteADR.Id_Esterno__c = 'ASDAS';
        ClienteADR.Mail1__c = 'AAAasd@gmail.com';
        ClienteADR.OwnerId = portalAccountOwner1.Id;
        insert ClienteADR;
        Id rtContact =  Schema.SObjectType.Contact.getRecordTypeInfosByName().get('RESIDENZA').getRecordTypeId();
        Contact Cont = new Contact();
        Cont.AccountId = ClienteADR.Id;
        Cont.FirstName = 'PROVA';
        Cont.LastName = 'ADR';
        Cont.RecordTypeId = rtContact;
        insert Cont;




        //TBD do we really need Partner portal?
        Profile prof = [select id, Name from profile where name='CRABB Partner ADR' limit 1];
        User Utente = new User ( isactive = true,
                    Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
                    Email = 'Unassigned@god.it', Alias = 'Unassi',profileID = prof.id,
                    CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
                    EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', ContactId = Cont.id
               );
        insert Utente;
        system.debug('****Prof.Id = ' + Prof.Id);
        system.debug('****Utente.Id = ' + Utente.Id +'- Profile.Name = ' + Prof.Name);

        LEGACY FLOW SHOULD BE REMOVED
        */
        User utente = TestClassFroDataGenAffidamenti.getUser('CRABB Operatore Credito');
        Collector__c coll = new Collector__c();
        coll.Prefisso_Lotto__c = 'AAA';
        coll.Ragione_Sociale__c = 'Avv. Test Test';
        coll.Tipo_Collector__c = 'LEGALE';
        coll.User__c = utente.Id;
        insert coll;

        Date dataInizio = Date.today();
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

        Account Cliente = new Account();
        Cliente.Name = 'CAINO PAOLO';
        Cliente.Id_Esterno__c = 'ETC_91132_2567';
        Cliente.Mail1__c = 'dasd@gmail.com';
        insert Cliente;

        Id rtServ_Preref = Schema.SObjectType.Servizio__c.getRecordTypeInfosByDeveloperName().get('PREREF').getRecordTypeId();
        Servizio__c servizio = new Servizio__c();
        servizio.RecordTypeId = rtServ_Preref;
        servizio.Stato__c = 'Attivo';
        servizio.Nome__c = 'PREPAGATO-REFEZIONE';
        servizio.LookupContratto__c = contratto.Id;
        servizio.Account__c = Cliente.Id;
        insert servizio;


        Lotto__c lotto = new Lotto__c();
        lotto.Agenzia_di_Recupero__c = coll.Id;
        lotto.Tipo__c = 'lotto';
        lotto.Stato__c = 'Confermato';

        insert lotto;

        Pratica__c pratica = new Pratica__c();
        pratica.Account__c = Cliente.Id;
        pratica.Servizio_Fornitura__c = servizio.Id;
        insert pratica;

        List<Affidamento__c> affidList = new List<Affidamento__c>();
        for (Integer i = 0; i < 10; i++) {
            Affidamento__c Aff = new Affidamento__c();
            Aff.Lotto__c = lotto.Id;
            Aff.Pratica__c = pratica.Id;
            affidList.add(Aff);
        }
        insert affidList;

        Id IdLotto = ApexPages.currentPage().getParameters().put('IdLotto', lotto.Id);
        Id IdAffido = ApexPages.currentPage().getParameters().put('IdAffido', affidList[0].Id);
        ModificaLotti Controller = new ModificaLotti();
        Controller.recordsForPage = '25';
        List<SelectOption> recForPageValues = Controller.recordsForPageValues;
        Controller.sizeTable();
        Controller.Beginning();
        Controller.Previous();
        Controller.Next();
        Controller.ReturnToLotti();
        Controller.RevocaAffido();
        Controller.Conferma();
        Controller.RevocaAffido();
        Controller.ReturnToLotti();
        Controller.Conferma();
        // Controller.Cancella(); // metodo nn esiste
        Controller.Indietro();
        Controller.IndietroModificaLotti();
        Controller.getIsBeginningVisibility();
        Controller.getIsEndVisibility();
        Controller.End();

    }
}