@IsTest
public class TestCrabbEsitiMassiviLngCTRL {

    /*@IsTest
    public static void testFetchUserSessionId() {
        String st = CrabbEsitiMassiviLngCTRL.fetchUserSessionId();
    }*/

    @IsTest
    public static void getMapEsitiFinalTest(){
        List<CRABB_DEV__Esiti_Massivi__mdt> mdtList = [select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, CRABB_DEV__Allowed_Final_Outcomes__c, CRABB_DEV__Allowed_Outcomes__c, CRABB_DEV__Allowed_Partial_Outcomes__c, CRABB_DEV__Tipo_Sottotipo__c from CRABB_DEV__Esiti_Massivi__mdt];
        CRABB_DEV__Esiti_Massivi__mdt mdt = mdtList.get(0);
        String tiposottotipo = mdt.Tipo_Sottotipo__c;
        CrabbEsitiMassiviLngCtrl.getMapEsitiFinal(tiposottotipo);
    }

    @IsTest
    public static void getMaxRecordsTest() {
        CrabbEsitiMassiviLngCtrl.getMaxRecords();
    }


    @IsTest
    public static void getSelezioniTest(){
        EsitiMassiviProfile__c esitiProfile = new EsitiMassiviProfile__c();
        esitiProfile.Tipo__c = 'Approve';
        esitiProfile.Sottotipo__c = 'Cessione P.A.';
        insert esitiProfile;
        CrabbEsitiMassiviLngCtrl.getSelezioni();
    }

    @IsTest
    public static void getDossierStatusesListTest(){

        List<CRABB_DEV__mapping_status_pratica__mdt> mdtList = [select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, CRABB_DEV__stati_chiusura__c, CRABB_DEV__stati_in_lavorazione__c, CRABB_DEV__stati_PDR__c from CRABB_DEV__mapping_status_pratica__mdt];
        CRABB_DEV__mapping_status_pratica__mdt mdt = mdtList.get(0);
        CrabbEsitiMassiviLngCtrl.getDossierStatusesList(mdt.DeveloperName, 'CRABB_DEV__stati_in_lavorazione__c');
    }

    @IsTest
    public static void getEsitiPickListValuesTest(){
        List<CRABB_DEV__Esiti_Massivi__mdt> mdtList = [select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, CRABB_DEV__Allowed_Final_Outcomes__c, CRABB_DEV__Allowed_Outcomes__c, CRABB_DEV__Allowed_Partial_Outcomes__c, CRABB_DEV__Tipo_Sottotipo__c from CRABB_DEV__Esiti_Massivi__mdt];
        CRABB_DEV__Esiti_Massivi__mdt mdt = mdtList.get(0);
        CrabbEsitiMassiviLngCtrl.getEsitiPickListValues(mdt.Tipo_Sottotipo__c);

    }

    @IsTest
    public static void confermaListaTest() {
        String tiposottotipo='';
        List<CRABB_DEV__Esiti_Massivi__mdt> mdtList = [select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, CRABB_DEV__Allowed_Final_Outcomes__c, CRABB_DEV__Allowed_Outcomes__c, CRABB_DEV__Allowed_Partial_Outcomes__c, CRABB_DEV__Tipo_Sottotipo__c from CRABB_DEV__Esiti_Massivi__mdt];
        CRABB_DEV__Esiti_Massivi__mdt mdt = mdtList.get(0);
        CrabbEsitiMassiviLngCtrl.getEsitiPickListValues(mdt.Tipo_Sottotipo__c);
        tiposottotipo = mdt.Tipo_Sottotipo__c;
        Pratica__c prat = new Pratica__c();
        insert prat;
        list<id> pratId = new List<Id>();
        pratId.add(prat.id);
        CrabbEsitiMassiviLngCtrl.ConfermaLista(pratId, 'Parziale', tiposottotipo);
        CrabbEsitiMassiviLngCtrl.ConfermaListaOld(pratId, 'Parziale', tiposottotipo);
    }

    @IsTest
    public static void getQueryListRowsTest() {
        List<CRABB_DEV__Esiti_Massivi__mdt> mdtList = [select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, CRABB_DEV__Allowed_Final_Outcomes__c, CRABB_DEV__Allowed_Outcomes__c, CRABB_DEV__Allowed_Partial_Outcomes__c, CRABB_DEV__Tipo_Sottotipo__c from CRABB_DEV__Esiti_Massivi__mdt];
        CRABB_DEV__Esiti_Massivi__mdt mdt = mdtList.get(0);
        CrabbEsitiMassiviLngCtrl.getQueryListRows('select Id, toLabel(CRABB_DEV__Stato__c), CRABB_DEV__Residuo_Totale__c, CRABB_DEV__Account__c from CRABB_DEV__Pratica__c where id!=null order by id'.toUpperCase(), 0, 0, 'PR-000000', mdt.Tipo_Sottotipo__c);
        CrabbEsitiMassiviLngCtrl.getQueryListRows('select Id, toLabel(CRABB_DEV__Stato__c), CRABB_DEV__Residuo_Totale__c, CRABB_DEV__Account__c from CRABB_DEV__Pratica__c where id!=null'.toUpperCase(), 0, 0, 'PR-000000', mdt.Tipo_Sottotipo__c);
        CrabbEsitiMassiviLngCtrl.getQueryListRows('select Id, toLabel(CRABB_DEV__Stato__c), CRABB_DEV__Residuo_Totale__c, CRABB_DEV__Account__c from CRABB_DEV__Pratica__c order by id'.toUpperCase(), 0, 0, 'PR-000000', mdt.Tipo_Sottotipo__c);
        CrabbEsitiMassiviLngCtrl.getQueryListRows('select Id, toLabel(CRABB_DEV__Stato__c), CRABB_DEV__Residuo_Totale__c, CRABB_DEV__Account__c from CRABB_DEV__Pratica__c'.toUpperCase(), 0, 0, 'PR-000000', mdt.Tipo_Sottotipo__c);
    }

    @IsTest
    public static void countQueryListViewRowsTest() {
        List<CRABB_DEV__Esiti_Massivi__mdt> mdtList = [select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, CRABB_DEV__Allowed_Final_Outcomes__c, CRABB_DEV__Allowed_Outcomes__c, CRABB_DEV__Allowed_Partial_Outcomes__c, CRABB_DEV__Tipo_Sottotipo__c from CRABB_DEV__Esiti_Massivi__mdt];
        CRABB_DEV__Esiti_Massivi__mdt mdt = mdtList.get(0);
        CrabbEsitiMassiviLngCtrl.countQueryListViewRows('select Id, CRABB_DEV__Stato__c, CRABB_DEV__Residuo_Totale__c, CRABB_DEV__Account__c from CRABB_DEV__Pratica__c where id!=null order by id'.toUpperCase(), mdt.Tipo_Sottotipo__c);
        CrabbEsitiMassiviLngCtrl.countQueryListViewRows('select Id, CRABB_DEV__Stato__c, CRABB_DEV__Residuo_Totale__c, CRABB_DEV__Account__c from CRABB_DEV__Pratica__c where id!=null'.toUpperCase(), mdt.Tipo_Sottotipo__c);
        CrabbEsitiMassiviLngCtrl.countQueryListViewRows('select Id, CRABB_DEV__Stato__c, CRABB_DEV__Residuo_Totale__c, CRABB_DEV__Account__c from CRABB_DEV__Pratica__c order by id'.toUpperCase(), mdt.Tipo_Sottotipo__c);
        CrabbEsitiMassiviLngCtrl.countQueryListViewRows('select Id, CRABB_DEV__Stato__c, CRABB_DEV__Residuo_Totale__c, CRABB_DEV__Account__c from CRABB_DEV__Pratica__c'.toUpperCase(), mdt.Tipo_Sottotipo__c);
    }
}