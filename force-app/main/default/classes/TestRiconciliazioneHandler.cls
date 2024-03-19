@isTest
public class TestRiconciliazioneHandler {
    
    @isTest
    public static void TestApprovalPratiche() {
        Account acc= new Account(name='test');
        insert acc;
        CRABB_DEV__Pratica__c pra= new CRABB_DEV__Pratica__c(CRABB_DEV__Account__c=acc.id);
        insert pra;

        Riconciliazione__c ric = new Riconciliazione__c(CRABB_DEV__account__c=acc.Id, CRABB_DEV__Pratica__c=pra.id, CRABB_DEV__Importo__c = 100);
        insert ric;

        test.startTest();
            ric.stato_riconciliazione__c='Approvata';
        	ric.CRABB_DEV__Bozza_movimento__c='[{"Value":"45","TipoServizio":null,"Stato":null,"Scaduto":null,"Name":null,"IdPratica":"'+pra.Id+'","IdNoleggio":null,"IdAccount":null,"EsitoUltimaAttivitaLavorazione":null,"Esito":"55","DataApertura":null,"AccountName":null},{"Value":null,"TipoServizio":null,"Stato":null,"Scaduto":null,"Name":null,"IdPratica":"'+pra.Id+'","IdNoleggio":null,"IdAccount":null,"EsitoUltimaAttivitaLavorazione":null,"Esito":"ffff","DataApertura":null,"AccountName":null},{"Value":null,"TipoServizio":null,"Stato":null,"Scaduto":null,"Name":null,"IdPratica":"'+pra.id+'","IdNoleggio":null,"IdAccount":null,"EsitoUltimaAttivitaLavorazione":null,"Esito":"","DataApertura":null,"AccountName":null},{"Value":"345","TipoServizio":null,"Stato":null,"Scaduto":null,"Name":null,"IdPratica":"'+pra.Id+'","IdNoleggio":null,"IdAccount":null,"EsitoUltimaAttivitaLavorazione":null,"Esito":"55","DataApertura":null,"AccountName":null}]';
            update ric;
        test.stopTest();
    }

    @isTest
    public static void TestApprovalAccountWithoutPratica() {
        Account acc= new Account(name='testAcc');
        insert acc;
        CRABB_DEV__Pratica__c pra= new CRABB_DEV__Pratica__c(CRABB_DEV__Account__c=acc.id);
        insert pra;

        CRABB_DEV__Movimento__c mov = new CRABB_DEV__Movimento__c(CRABB_DEV__Tipo_Scadenza__c='Scaduto',CRABB_DEV__Sollecitabile__c=true,CRABB_DEV__Account__c=acc.Id,CRABB_DEV__pratica__c = pra.Id, CRABB_DEV__Residuo__c=250, CRABB_DEV__Data_Emissione__c = Date.today().addDays(-20), CRABB_DEV__Data_Scadenza__c=Date.today().addDays(-10));
        insert mov;

        Riconciliazione__c ric = new Riconciliazione__c(CRABB_DEV__account__c=acc.Id, CRABB_DEV__Pratica__c=null, CRABB_DEV__Importo__c=250, CRABB_DEV__Confermata__c = true);
        insert ric;

        test.startTest();
            ric.stato_riconciliazione__c='Approvata';
            ric.CRABB_DEV__Bozza_movimento__c='[{"Value":"45","TipoServizio":null,"Stato":null,"Scaduto":null,"Name":null,"IdPratica":"'+pra.Id+'","IdNoleggio":null,"IdAccount":null,"EsitoUltimaAttivitaLavorazione":null,"Esito":"55","DataApertura":null,"AccountName":null},{"Value":null,"TipoServizio":null,"Stato":null,"Scaduto":null,"Name":null,"IdPratica":"'+pra.Id+'","IdNoleggio":null,"IdAccount":null,"EsitoUltimaAttivitaLavorazione":null,"Esito":"ffff","DataApertura":null,"AccountName":null},{"Value":null,"TipoServizio":null,"Stato":null,"Scaduto":null,"Name":null,"IdPratica":"'+pra.id+'","IdNoleggio":null,"IdAccount":null,"EsitoUltimaAttivitaLavorazione":null,"Esito":"","DataApertura":null,"AccountName":null},{"Value":"345","TipoServizio":null,"Stato":null,"Scaduto":null,"Name":null,"IdPratica":"'+pra.Id+'","IdNoleggio":null,"IdAccount":null,"EsitoUltimaAttivitaLavorazione":null,"Esito":"55","DataApertura":null,"AccountName":null}]';
            update ric;
        test.stopTest();
    }

    @isTest
    public static void TestNewRiconciliazioneEsatta() {
        Account acc= new Account(name='test');
        insert acc;
        CRABB_DEV__Pratica__c pra= new CRABB_DEV__Pratica__c(CRABB_DEV__Account__c=acc.id);
        insert pra;
        
        CRABB_DEV__Movimento__c mov = new CRABB_DEV__Movimento__c(CRABB_DEV__Tipo_Scadenza__c='Scaduto',CRABB_DEV__Sollecitabile__c=true,CRABB_DEV__Account__c=acc.Id,CRABB_DEV__pratica__c = pra.Id, CRABB_DEV__Residuo__c=250,CRABB_DEV__Importo__c=250, CRABB_DEV__Data_Emissione__c = Date.today().addDays(-20), CRABB_DEV__Data_Scadenza__c=Date.today().addDays(-10));
        insert mov;
       
        Riconciliazione__c ric = new Riconciliazione__c(CRABB_DEV__account__c=acc.Id, CRABB_DEV__Pratica__c=pra.id, CRABB_DEV__Importo__c = 250);

        test.startTest();
            ric.CRABB_DEV__Confermata__c = true;
            ric.CRABB_DEV__Tipologia_riconciliazione__c = 'Transazione con associazione esatta';
            insert ric;
        test.stopTest();
    }
    
    @isTest
    public static void TestRejection() {
        Riconciliazione__c ric = new Riconciliazione__c();
        insert ric;
        
        test.startTest();
            ric.stato_riconciliazione__c='Rifiutata';
            update ric;
        test.stopTest();
    }

}