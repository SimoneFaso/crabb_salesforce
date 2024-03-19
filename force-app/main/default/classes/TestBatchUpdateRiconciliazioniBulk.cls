/**
 * Created by ssalaris on 24/05/2021.
 */

@IsTest
public with sharing class TestBatchUpdateRiconciliazioniBulk {

    static testmethod void testBatch(){

        List<Account> accList = new List<Account>();
        List<CRABB_DEV__Pratica__c> pratList = new List<CRABB_DEV__Pratica__c>();
        List<CRABB_DEV__Riconciliazione__c> ricList = new List<CRABB_DEV__Riconciliazione__c>();
        List<CRABB_DEV__Riconciliazione_Staging__c> ricStagList = new List<CRABB_DEV__Riconciliazione_Staging__c>();
        List<String> statusList = new List<String>{'Affidata', 'In Lavorazione'};

        Account acc = new Account(Name = 'Account Test');
        accList.add(acc);

        Account acc2 = new Account(Name = 'Account Test2');
        accList.add(acc2);

        Account acc3 = new Account(Name = 'Account Test3');
        accList.add(acc3);

        insert accList;

        CRABB_DEV__Pratica__c pra = new CRABB_DEV__Pratica__c(CRABB_DEV__Account__c = acc.Id, CRABB_DEV__Stato__c = 'Affidata');
        pratList.add(pra);
        CRABB_DEV__Pratica__c pra2 = new CRABB_DEV__Pratica__c(CRABB_DEV__Account__c = acc2.Id, CRABB_DEV__Stato__c = 'Affidata');
        pratList.add(pra2);
        insert pratList;

        CRABB_DEV__Movimento__c mov = new CRABB_DEV__Movimento__c(CRABB_DEV__Tipo_Scadenza__c='Scaduto',CRABB_DEV__Sollecitabile__c=true,CRABB_DEV__Account__c=acc.Id,CRABB_DEV__pratica__c = pra.Id, CRABB_DEV__Residuo__c=250, CRABB_DEV__Data_Emissione__c = Date.today().addDays(-20), CRABB_DEV__Data_Scadenza__c=Date.today().addDays(-10));
        insert mov;

        CRABB_DEV__Riconciliazione__c ric = new CRABB_DEV__Riconciliazione__c(CRABB_DEV__Confermata__c = false, CRABB_DEV__stato_riconciliazione__c = 'In Lavorazione', CRABB_DEV__account__c=acc.Id, CRABB_DEV__Tipologia_riconciliazione__c = 'Transazione con associazione parziale', CRABB_DEV__Pratica__c=pra.id, CRABB_DEV__Importo__c = 100, CRABB_DEV__Bozza_movimento__c='[{"Value":"45","TipoServizio":null,"Stato":null,"Scaduto":null,"Name":null,"IdPratica":"'+pra.Id+'","IdNoleggio":null,"IdAccount":null,"EsitoUltimaAttivitaLavorazione":null,"Esito":"55","DataApertura":null,"AccountName":null},{"Value":null,"TipoServizio":null,"Stato":null,"Scaduto":null,"Name":null,"IdPratica":"aprov000d000oWrAAI","IdNoleggio":null,"IdAccount":null,"EsitoUltimaAttivitaLavorazione":null,"Esito":"ffff","DataApertura":null,"AccountName":null}]');
        ricList.add(ric);

        CRABB_DEV__Riconciliazione__c ric2 = new CRABB_DEV__Riconciliazione__c(CRABB_DEV__Confermata__c = false, CRABB_DEV__stato_riconciliazione__c = 'In Lavorazione', CRABB_DEV__account__c=acc.Id, CRABB_DEV__Tipologia_riconciliazione__c = 'Transazione con associazione parziale', CRABB_DEV__Pratica__c=pra.id, CRABB_DEV__Importo__c = 100, CRABB_DEV__Bozza_movimento__c='[{"Value":null,"TipoServizio":null,"Stato":null,"Scaduto":null,"Name":null,"IdPratica":"aprov000d000oWrAAI","IdNoleggio":null,"IdAccount":null,"EsitoUltimaAttivitaLavorazione":null,"Esito":"ffff","DataApertura":null,"AccountName":null}]');
        ricList.add(ric2);

        CRABB_DEV__Riconciliazione__c ric3 = new CRABB_DEV__Riconciliazione__c(CRABB_DEV__Confermata__c = false, CRABB_DEV__stato_riconciliazione__c = 'In Lavorazione', CRABB_DEV__account__c=acc2.Id, CRABB_DEV__Tipologia_riconciliazione__c = 'Transazione con associazione parziale', CRABB_DEV__Importo__c = 100);
        ricList.add(ric3);

        CRABB_DEV__Riconciliazione__c ric4 = new CRABB_DEV__Riconciliazione__c(CRABB_DEV__Confermata__c = false, CRABB_DEV__stato_riconciliazione__c = 'In Lavorazione', CRABB_DEV__account__c=acc3.Id, CRABB_DEV__Tipologia_riconciliazione__c = 'Transazione con associazione parziale', CRABB_DEV__Importo__c = 100);
        ricList.add(ric4);

        insert ricList;

        CRABB_DEV__Riconciliazione_Staging__c ricStag = new CRABB_DEV__Riconciliazione_Staging__c(CRABB_DEV__RiconciliazioneId__c = 'a0uHb9AAE', CRABB_DEV__Nome_Autore__c = 'Test Autore', CRABB_DEV__Autore__c = UserInfo.getUserId(), CRABB_DEV__PraticaId__c = pra.Id, CRABB_DEV__Stato__c = 'Nuovo', CRABB_DEV__Value__c = '320');
        ricStagList.add(ricStag);
        CRABB_DEV__Riconciliazione_Staging__c ricStag2 = new CRABB_DEV__Riconciliazione_Staging__c(CRABB_DEV__RiconciliazioneId__c = ric.Id, CRABB_DEV__Nome_Autore__c = 'Test Autore', CRABB_DEV__Autore__c = UserInfo.getUserId(), CRABB_DEV__PraticaId__c = pra.Id, CRABB_DEV__Stato__c = 'Nuovo', CRABB_DEV__Value__c = '320');
        ricStagList.add(ricStag2);
        CRABB_DEV__Riconciliazione_Staging__c ricStag3 = new CRABB_DEV__Riconciliazione_Staging__c(CRABB_DEV__RiconciliazioneId__c = ric2.Id, CRABB_DEV__Nome_Autore__c = 'Test Autore', CRABB_DEV__Autore__c = UserInfo.getUserId(), CRABB_DEV__PraticaId__c = pra.Id, CRABB_DEV__Stato__c = 'Nuovo', CRABB_DEV__Value__c = '20');
        ricStagList.add(ricStag3);
        CRABB_DEV__Riconciliazione_Staging__c ricStag4 = new CRABB_DEV__Riconciliazione_Staging__c(CRABB_DEV__RiconciliazioneId__c = ric3.Id, CRABB_DEV__Nome_Autore__c = 'Test Autore', CRABB_DEV__Autore__c = UserInfo.getUserId(), CRABB_DEV__PraticaId__c = pra.Id, CRABB_DEV__Stato__c = 'Nuovo', CRABB_DEV__Value__c = '20');
        ricStagList.add(ricStag4);
        CRABB_DEV__Riconciliazione_Staging__c ricStag5 = new CRABB_DEV__Riconciliazione_Staging__c(CRABB_DEV__RiconciliazioneId__c = ric4.Id, CRABB_DEV__Nome_Autore__c = 'Test Autore', CRABB_DEV__Autore__c = UserInfo.getUserId(), CRABB_DEV__PraticaId__c = pra.Id, CRABB_DEV__Stato__c = 'Nuovo', CRABB_DEV__Value__c = '20');
        ricStagList.add(ricStag5);

        insert ricStagList;

        test.startTest();
        BatchUpdateRiconciliazioniBulk istanza = new BatchUpdateRiconciliazioniBulk(UserInfo.getUserId(), 'testautore@gmail.com', statusList);
        Id process = Database.executeBatch(istanza);
        test.stopTest();
    }
}