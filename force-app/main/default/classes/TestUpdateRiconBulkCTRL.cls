/**
 * Created by ssalaris on 26/05/2021.
 */
@isTest
public class TestUpdateRiconBulkCTRL {

    @isTest
    public static void testfileupload(){
        String str = 'Riconciliazione Id,Pratica Id,Value\n a0r0oood00000uHb9AAE,a0r0oood00000uHb9AAE,55\n a0r0oood00000uHb9AAE,a0r0oood00000uHb9AAE,55';
        ContentVersion objVersion = new ContentVersion(Title = 'Test',
                PathOnClient = 'Test.csv',
                VersionData = Blob.valueOf(str));
        insert objVersion;
        ContentDocument documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument Limit 1];

        Test.startTest();
        updateRiconBulkCTRL.readCSVFile(documents.id);
        Test.stopTest();
    }

    @isTest
    public static void TestBatch() {
        Account acc = new Account(Name = 'Account Test');
        insert acc;
        CRABB_DEV__Pratica__c pra = new CRABB_DEV__Pratica__c(CRABB_DEV__Account__c = acc.Id, CRABB_DEV__Stato__c = 'Affidata');
        insert pra;
        CRABB_DEV__Movimento__c mov = new CRABB_DEV__Movimento__c(CRABB_DEV__Tipo_Scadenza__c='Scaduto',CRABB_DEV__Sollecitabile__c=true,CRABB_DEV__Account__c=acc.Id,CRABB_DEV__pratica__c = pra.Id, CRABB_DEV__Residuo__c=250, CRABB_DEV__Data_Emissione__c = Date.today().addDays(-20), CRABB_DEV__Data_Scadenza__c=Date.today().addDays(-10));
        insert mov;
        CRABB_DEV__Riconciliazione__c ric = new CRABB_DEV__Riconciliazione__c(CRABB_DEV__Confermata__c = false, CRABB_DEV__stato_riconciliazione__c = 'In Lavorazione', CRABB_DEV__account__c=acc.Id, CRABB_DEV__Tipologia_riconciliazione__c = 'Transazione con associazione parziale', CRABB_DEV__Pratica__c=pra.id, CRABB_DEV__Importo__c = 100, CRABB_DEV__Bozza_movimento__c='[{"Value":"45","TipoServizio":null,"Stato":null,"Scaduto":null,"Name":null,"IdPratica":"'+pra.Id+'","IdNoleggio":null,"IdAccount":null,"EsitoUltimaAttivitaLavorazione":null,"Esito":"55","DataApertura":null,"AccountName":null},{"Value":null,"TipoServizio":null,"Stato":null,"Scaduto":null,"Name":null,"IdPratica":"aprov000d000oWrAAI","IdNoleggio":null,"IdAccount":null,"EsitoUltimaAttivitaLavorazione":null,"Esito":"ffff","DataApertura":null,"AccountName":null}]');
        insert ric;
        CRABB_DEV__Riconciliazione_Staging__c ricStag = new CRABB_DEV__Riconciliazione_Staging__c(CRABB_DEV__RiconciliazioneId__c = 'Idriconciliaznenum1', CRABB_DEV__Autore__c = userInfo.getUserId(), CRABB_DEV__PraticaId__c = 'Idpraticanum41', CRABB_DEV__Stato__c = 'Nuovo', CRABB_DEV__Value__c = '20');
        insert ricStag;
        
        List<String> status = new List<String>();
        test.startTest();
        status = updateRiconBulkCTRL.getStatusPratica();
        updateRiconBulkCTRL.callBatch();
        updateRiconBulkCTRL.deleteStagingRecords();
        updateRiconBulkCTRL.getExportData();
        test.stopTest();
    }
}