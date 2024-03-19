@isTest
public class TestWSInsertRiconciliazioni {

    @IsTest
    static void doPostRiconciliazioniTest() {
        Account acc= new Account(name='test');
        Account acc2= new Account(name='test2');
        insert acc;
        insert acc2; 

        CRABB_DEV__Pratica__c pra= new CRABB_DEV__Pratica__c(CRABB_DEV__Account__c=acc.id);
        CRABB_DEV__Pratica__c pra2= new CRABB_DEV__Pratica__c(CRABB_DEV__Account__c=acc2.id);
        insert pra;
        insert pra2;

        CRABB_DEV__Movimento__c mov = new CRABB_DEV__Movimento__c(CRABB_DEV__Tipo_Scadenza__c='Scaduto',CRABB_DEV__Sollecitabile__c=true,CRABB_DEV__Account__c=acc.Id,CRABB_DEV__pratica__c = pra.Id, CRABB_DEV__Residuo__c=250, CRABB_DEV__Data_Emissione__c = Date.today().addDays(-20), CRABB_DEV__Data_Scadenza__c=Date.today().addDays(-10));
        insert mov;
        CRABB_DEV__Movimento__c mov2 = new CRABB_DEV__Movimento__c(CRABB_DEV__Stato_Pratiica_Picklist__c='In Lavorazione', CRABB_DEV__Tipo_Scadenza__c='Scaduto',CRABB_DEV__Sollecitabile__c=true,CRABB_DEV__Account__c=acc2.Id,CRABB_DEV__pratica__c = pra2.Id, CRABB_DEV__Residuo__c=250, CRABB_DEV__Data_Emissione__c = Date.today().addDays(-20), CRABB_DEV__Data_Scadenza__c=Date.today().addDays(-10));
        insert mov2;
        
        CRABB_DEV__Pratica__c InsertedPra=[SELECT id,name FROM CRABB_DEV__Pratica__c WHERE id=:pra.id WITH SECURITY_ENFORCED];
        CRABB_DEV__Pratica__c InsertedPra2=[SELECT id,name FROM CRABB_DEV__Pratica__c WHERE id=:pra2.id WITH SECURITY_ENFORCED];

        Account InsertedAcc=[SELECT id,name FROM Account WHERE id=:acc.id WITH SECURITY_ENFORCED];
        Account InsertedAcc2=[SELECT id,name FROM Account WHERE id=:acc2.id WITH SECURITY_ENFORCED];

        list<String> praticaNameList = new list<String>{InsertedPra.Name,InsertedPra2.Name};
        list<String> accountNameList = new list<String>{InsertedAcc.Name,InsertedAcc2.Name};
        String jsonString = '[{"importo":250, "dataElaborazione":"2020-11-19", "dataContabile":"2020-09-04", "segnoImporto":"+", "dataValuta":"2020-09-04", "causale":"NCOL", "descrizioneCausale":"                ", "dataElaborazioneFlusso":"2020-09-05", "numeroConto":"01452902", "praticaName":"'+InsertedPra.Name+'"}, {"importo":100, "dataElaborazione":"2020-11-19", "dataContabile":"2020-09-04", "segnoImporto":"+", "dataValuta":"2020-09-04", "causale":"NCOL", "descrizioneCausale":"                ", "dataElaborazioneFlusso":"2020-09-05", "numeroConto":"01452902", "praticaName":"'+InsertedPra2.Name+'"}, {"importo":545, "dataElaborazione":"2020-11-19", "dataContabile":"2020-09-04", "segnoImporto":"+", "dataValuta":"2020-09-04", "causale":"NCOL", "descrizioneCausale":"                ", "dataElaborazioneFlusso":"2020-09-05", "numeroConto":"01452902"}, {"importo":250, "dataElaborazione":"2020-11-19", "dataContabile":"2020-09-04", "segnoImporto":"+", "dataValuta":"2020-09-04", "causale":"NCOL", "descrizioneCausale":"                ", "dataElaborazioneFlusso":"2020-09-05", "numeroConto":"01452902", "accountName":"'+InsertedAcc2.Name+'"} ]';
        List<WSInsertRiconciliazioni.draft_Riconciliazioni> draftRic = (List<WSInsertRiconciliazioni.draft_Riconciliazioni>) JSON.deserialize(jsonString, List<WSInsertRiconciliazioni.draft_Riconciliazioni>.class);

        WSInsertRiconciliazioni.herokuRequest hRequest = new WSInsertRiconciliazioni.herokuRequest();
        hRequest.draftRic = draftRic;
        hRequest.praticaNameList = praticaNameList;
        hRequest.accountNameList = accountNameList;

        test.startTest();
            WSInsertRiconciliazioni.doPost((WSInsertRiconciliazioni.herokuRequest) hRequest); //create records
        test.stopTest();

    }

}