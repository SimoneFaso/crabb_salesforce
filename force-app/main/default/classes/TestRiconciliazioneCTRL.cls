@isTest
public class TestRiconciliazioneCTRL {

    @isTest
    public static void TestMethod1() {
        Account acc= new Account(name='test');
        Account acc2= new Account(name='test2');
        insert acc;
        insert acc2;

        CRABB_DEV__Pratica__c pra= new CRABB_DEV__Pratica__c(CRABB_DEV__Account__c=acc.id);
        CRABB_DEV__Pratica__c pra2= new CRABB_DEV__Pratica__c(CRABB_DEV__Account__c=acc2.id);
        insert pra;
        insert pra2;

        CRABB_DEV__Pratica__c InsertedPra=[SELECT id,name FROM CRABB_DEV__Pratica__c WHERE id=:pra.id WITH SECURITY_ENFORCED];
        CRABB_DEV__Pratica__c InsertedPra2=[SELECT id,name FROM CRABB_DEV__Pratica__c WHERE id=:pra2.id WITH SECURITY_ENFORCED];
        CRABB_DEV__Riconciliazione__c ric = new CRABB_DEV__Riconciliazione__c(account__c=acc.Id);
        CRABB_DEV__Riconciliazione__c ric2 = new CRABB_DEV__Riconciliazione__c(account__c=acc2.Id);
        String bozzaJson='[{"Value":"45","TipoServizio":null,"Stato":null,"Scaduto":null,"Name":null,"IdPratica":"a0d09000000TNVDAA4","IdNoleggio":null,"IdAccount":null,"EsitoUltimaAttivitaLavorazione":null,"Esito":"55","DataApertura":null,"AccountName":null},{"Value":null,"TipoServizio":null,"Stato":null,"Scaduto":null,"Name":null,"IdPratica":"a0d09000000TNVGAA4","IdNoleggio":null,"IdAccount":null,"EsitoUltimaAttivitaLavorazione":null,"Esito":"ffff","DataApertura":null,"AccountName":null},{"Value":null,"TipoServizio":null,"Stato":null,"Scaduto":null,"Name":null,"IdPratica":"a0d09000000TNVOAA4","IdNoleggio":null,"IdAccount":null,"EsitoUltimaAttivitaLavorazione":null,"Esito":"","DataApertura":null,"AccountName":null},{"Value":"345","TipoServizio":null,"Stato":null,"Scaduto":null,"Name":null,"IdPratica":"a0d09000000TNVPAA4","IdNoleggio":null,"IdAccount":null,"EsitoUltimaAttivitaLavorazione":null,"Esito":"55","DataApertura":null,"AccountName":null}]';
        String bozzaJson2=null;
        ric.CRABB_DEV__Bozza_movimento__c=bozzaJson;
        ric2.CRABB_DEV__Bozza_movimento__c=bozzaJson2;
        ric2.CRABB_DEV__Importo__c = 1;

        ric.CRABB_DEV__stato_riconciliazione__c='Approvata';
        ric2.CRABB_DEV__stato_riconciliazione__c='Approvata';

        insert ric;
        insert ric2;

        test.startTest();
        RiconciliazioneCTRL.GetpraticheByAccount(ric.id,'');
        RiconciliazioneCTRL.GetpraticheByAccount(ric.id,InsertedPra.name);
        RiconciliazioneCTRL.SaveBozza(ric.id,bozzaJson);
        RiconciliazioneCTRL.isEditable(ric.id);
        RiconciliazioneCTRL.updateStatus(ric.id, ric.CRABB_DEV__stato_riconciliazione__c);

        RiconciliazioneCTRL.updateStatus(ric2.id, ric2.CRABB_DEV__stato_riconciliazione__c);
        test.stopTest();
    }



}