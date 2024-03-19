/**
 * Created by User on 15/09/2022.
 */

@IsTest
public class TestCrabbAffidamentoMassiviLngCtrl {
    @TestSetup
    public static void dataSetup() {
        //AffidiSettings
        AffidiSettings__c affidiProfile = new AffidiSettings__c();
        affidiProfile.Tipo__c = 'Assign';
        affidiProfile.Sottotipo__c = 'Activity';
        insert affidiProfile;

        //Insert Strategy Records - Testata & Step
        insertStrategy();
        //Insert Collectors & Collector con tipo Affido CS
        insertCollectors();
    }
    @IsTest
    public static void getMaxRecordsTest() {
        CrabbAffidamentoMassiviLngCtrl.getMaxRecords();
    }
    @IsTest
    public static void getSelezioniTest() {
        CrabbAffidamentoMassiviLngCtrl.getSelezioni();
    }
    /*@IsTest
    public static void testFetchUserSessionId() {
        String st = crabbListViewUtilities.fetchUserSessionId();
    }*/
    @IsTest
    public static void getQueryListViewTest() {
        AffidiSettings__c affidiSetting = [SELECT Id, Tipo__c, Sottotipo__c FROM AffidiSettings__c LIMIT 1];
        String tipoSottotipo = affidiSetting.Tipo__c + ' ' + affidiSetting.Sottotipo__c;
        Id listViewID = [SELECT Id FROM ListView WHERE SobjectType = 'CRABB_DEV__Pratica__c' LIMIT 1].Id;
        String queryResp = '{"query":"SELECT toLabel(CRABB_DEV__Stato__c), CRABB_DEV__Account__r.Name FROM CRABB_DEV__Pratica__c ' +
                'WHERE CRABB_DEV__Stato__c = \'In Lavorazione\' ORDER BY CRABB_DEV__Stato__c ASC NULLS FIRST, Id ASC NULLS FIRST",' +
                '"relatedEntityId":null,"scope":"everything","scopeEntityId":null,"sobjectType":"CRABB_DEV__Pratica__c",' +
                '"whereCondition":{"field":"CRABB_DEV__Stato__c","operator":"equals","values":["\'In Lavorazione\'"]}}';

        MockHttpResponseGenerator responseMock = new MockHttpResponseGenerator(200, 'OK', queryResp, null);
        Test.setMock(HttpCalloutMock.class, responseMock);

        Test.startTest();
        CrabbAffidamentoMassiviLngCtrl.getQueryListView(listViewID, tipoSottotipo);
        Test.stopTest();
    }

    @IsTest
    public static void availableCollectorsTest() {
        AffidiSettings__c affidiSetting = [SELECT Id, Tipo__c, Sottotipo__c FROM AffidiSettings__c LIMIT 1];
        String tipo_Sottotipo = affidiSetting.Tipo__c + '_' + affidiSetting.Sottotipo__c;
        CrabbAffidamentoMassiviLngCtrl.availableCollectors(tipo_Sottotipo);
    }
    @IsTest
    public static void getQueryListRowsTest() {
        AffidiSettings__c affidiSetting = [SELECT Id, Tipo__c, Sottotipo__c FROM AffidiSettings__c LIMIT 1];
        String tipoSottotipo = affidiSetting.Tipo__c + ' ' + affidiSetting.Sottotipo__c;
        CrabbAffidamentoMassiviLngCtrl.getQueryListRows(('select Id, toLabel(CRABB_DEV__Stato__c) from CRABB_DEV__Pratica__c ' +
                'where id!=null order by id').toUpperCase(), 0, 0, 'PR-000000', tipoSottotipo);
        CrabbAffidamentoMassiviLngCtrl.getQueryListRows(('select Id from CRABB_DEV__Pratica__c ' +
                'where id!=null').toUpperCase(), 0, 0, 'PR-000000', tipoSottotipo);
        CrabbAffidamentoMassiviLngCtrl.getQueryListRows(('select Id from CRABB_DEV__Pratica__c ' +
                'order by id').toUpperCase(), 0, 0, 'PR-000000', tipoSottotipo);
        CrabbAffidamentoMassiviLngCtrl.getQueryListRows('select Id from CRABB_DEV__Pratica__c'
                .toUpperCase(), 0, 0, 'PR-000000', tipoSottotipo);
    }
    @IsTest
    public static void countQueryListViewRowsTest() {
        AffidiSettings__c affidiSetting = [SELECT Id, Tipo__c, Sottotipo__c FROM AffidiSettings__c LIMIT 1];
        String tipoSottotipo = affidiSetting.Tipo__c + ' ' + affidiSetting.Sottotipo__c;
        CrabbAffidamentoMassiviLngCtrl.countQueryListViewRows(('select Id, CRABB_DEV__Stato__c, CRABB_DEV__Residuo_Totale__c, CRABB_DEV__Account__c ' +
                'from CRABB_DEV__Pratica__c where id!=null order by id').toUpperCase(), tipoSottotipo);
        CrabbAffidamentoMassiviLngCtrl.countQueryListViewRows(('select Id, CRABB_DEV__Stato__c, CRABB_DEV__Residuo_Totale__c, CRABB_DEV__Account__c ' +
                'from CRABB_DEV__Pratica__c where id!=null').toUpperCase(), tipoSottotipo);
        CrabbAffidamentoMassiviLngCtrl.countQueryListViewRows(('select Id, CRABB_DEV__Stato__c, CRABB_DEV__Residuo_Totale__c, CRABB_DEV__Account__c ' +
                'from CRABB_DEV__Pratica__c order by id').toUpperCase(), tipoSottotipo);
        CrabbAffidamentoMassiviLngCtrl.countQueryListViewRows(('select Id, CRABB_DEV__Stato__c, CRABB_DEV__Residuo_Totale__c, CRABB_DEV__Account__c ' +
                'from CRABB_DEV__Pratica__c').toUpperCase(), tipoSottotipo);
    }
    @IsTest
    public static void modifyQueryTest() {
        AffidiSettings__c affidiSetting = [SELECT Id, Tipo__c, Sottotipo__c FROM AffidiSettings__c LIMIT 1];
        String tipoSottotipo = affidiSetting.Tipo__c + ' ' + affidiSetting.Sottotipo__c;
        crabbListViewUtilities.modifyQuery('SELECT Id FROM CRABB_DEV__Pratica__c WHERE id!=null ORDER BY id', tipoSottotipo);
        crabbListViewUtilities.modifyQuery('SELECT Id FROM CRABB_DEV__Pratica__c WHERE id!=null', tipoSottotipo);
        crabbListViewUtilities.modifyQuery('SELECT Id FROM CRABB_DEV__Pratica__c', tipoSottotipo);
        crabbListViewUtilities.modifyQuery('SELECT Id FROM CRABB_DEV__Pratica__c ORDER BY id', tipoSottotipo);
    }
    @IsTest
    ////////////////////////////////////////Da completare//////////////////////////////////////////////////////////////////////////
    //Da completare in funzione delle modifiche alla classe
    public static void distributeDossiersAndFinalizzaLottiTest() {
        //Insert Accounts, Dossiers, Transactions, Tasks & AEs
        List<String> dossIds = insertRecords();
        AffidiSettings__c affidiSetting = [SELECT Id, Tipo__c, Sottotipo__c FROM AffidiSettings__c LIMIT 1];
        String tipo_Sottotipo = affidiSetting.Tipo__c + '_' + affidiSetting.Sottotipo__c;
        List<Collector__c> collList = [SELECT Id FROM Collector__c];
        String collector = '[{"Collector":"' + collList[0].Id + '","Order":1,"TotAssignment":"2","EuroEntrusted":0,"PercentAssignments":0.4,"PercentDefault":0.1,"PreLot":"TBD","PercentEffective":0.4},' +
                '{"Collector":"' + collList[1].Id + '","Order":2,"TotAssignment":"2","EuroEntrusted":0,"PercentAssignments":0.6,"PercentDefault":0.15,"PreLot":"TBD","PercentEffective":0.6}]';

        String algoritmo = 'RRR';
        List<CrabbAffidamentoMassiviLngCtrl.DistribResult> listRRR = CrabbAffidamentoMassiviLngCtrl.distributeDossiers(tipo_Sottotipo, dossIds, collector, algoritmo);
        CrabbAffidamentoMassiviLngCtrl.finalizzaLotti(listRRR, JSON.serialize(listRRR));

        algoritmo = 'RR';
        CrabbAffidamentoMassiviLngCtrl.distributeDossiers(tipo_Sottotipo, dossIds, collector, algoritmo);

        algoritmo = 'FIFO';
        CrabbAffidamentoMassiviLngCtrl.distributeDossiers(tipo_Sottotipo, dossIds, collector, algoritmo);
    }
    public static void insertStrategy() {
        //RT Strategia
        Id STR_RTID_STEP = Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
        Id STR_RTID_TESTATA = Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();

        //Testata
        Strategia__c testata = new Strategia__c();
        testata.RecordTypeId = STR_RTID_TESTATA;
        testata.Tipologia__c = 'UI';
        testata.Stato__c = 'Attiva';
        insert testata;

        //Step Strategia
        Strategia__c stratg = new Strategia__c();
        stratg.RecordTypeId = STR_RTID_STEP;
        stratg.Tipologia__c = 'UI';
        stratg.Stato__c = 'Attiva';
        stratg.Testata__c = testata.Id;
        stratg.Sotto_tipo_attivita__c = 'Activity';
        insert stratg;

        testata.Stato__c = 'Attiva';
        update testata;
    }
    public static List<String> insertRecords() {
        List<Account> accList = new List<Account>();
        List<Pratica__c> dossList = new List<Pratica__c>();
        List<String> dossIds = new List<String>();
        List<Movimento__c> movList = new List<Movimento__c>();
        List<ActivityExtended__c> aeList = new List<ActivityExtended__c>();
        List<Task> tskList = new List<Task>();
        //Accounts
        for (Integer i = 0; i < 4; i++) {
            Account acc = new Account();
            acc.Name = 'test' + i;
            accList.add(acc);
        }
        insert accList;
        //Dossiers
        for (Integer i = 0; i < 4; i++) {
            Pratica__c prat = new Pratica__c();
            prat.Stato__c = 'In lavorazione';
            prat.Account__c = accList[i].Id;
            dossList.add(prat);
        }
        insert dossList;
        //Related Transactions
        for (Integer i = 0; i < 4; i++) {
            Movimento__c mov = new Movimento__c();
            mov.Data_Emissione__c = System.Date.today();
            mov.Data_Scadenza__c = System.Date.today();
            mov.Residuo__c = 100 + (10 * i);
            mov.Pratica__c = dossList[i].Id;
            mov.Account__c = accList[i].Id;
            movList.add(mov);
            dossIds.add(dossList[i].Id);
        }
        insert movList;
        //Related Tasks
        for (Integer i = 0; i < 4; i++) {
            Task tsk = new Task();
            tsk.Subject = 'test' + i;
            tsk.Status = 'Non iniziata';
            tsk.Type = 'Credito';
            tsk.WhatId = dossList[i].Id;
            tskList.add(tsk);
        }
        insert tskList;
        //Change AEs Types and Subtype to match with Affidi Settings CS
        for (ActivityExtended__c actExt : [SELECT Id FROM ActivityExtended__c]) {
            actExt.Tipo__c = 'Assign';
            actExt.Sotto_Tipo__c = 'Activity';
            aeList.add(actExt);
        }
        update aeList;
        return dossIds;
    }
    public static void insertCollectors() {
        //Collectors
        User utente = TestClassFroDataGenAffidamenti.getUser('CRABB Operatore Credito');
        List<Collector__c> collList = new List<Collector__c>();
        for (Integer i = 0; i < 3; i++) {
            Collector__c coll = new Collector__c();
            coll.Tipo_Collector__c = 'LEGALE';
            coll.Ragione_Sociale__c = 'COLL' + i;
            coll.User__c = utente.Id;
            collList.add(coll);
        }
        insert collList;

        //Collector CS
        Collector_con_Tipo_Affido__c collCS = new Collector_con_Tipo_Affido__c();
        collCS.Tipo_Affido__c = 'Activity';
        collCS.Name = 'collector';
        collCS.Categoria_Collector__c = 'LEGALE';
        insert collCS;
    }

}