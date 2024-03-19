@IsTest 
public class TestCrabbEngine {

    @TestSetup
    public static void generateTestData() {
        generateRecordsForStrategy();
        generateScheduleBatchRecords();
        generateStrategyRecords();
    }

    @IsTest
    public static void cEBInsertStrategyTest() {
        Test.startTest();
            Database.executeBatch(new CrabbStrategyInsertBatch(), 50);
        Test.stopTest();
    }

    @IsTest
    public static void cEBElaborateStrategyTest() {
        Test.startTest();
            Database.executeBatch(new CrabbEngine(), 50);
        Test.stopTest();
    }

    @IsTest
    public static void cEBUpdateStatusTest() {
        List<CRABB_DEV__Pratica__c> praList = [SELECT Id, CRABB_DEV__Stato__c from CRABB_DEV__Pratica__c limit 3];
        CEBUtils.addCebEvents(false,praList, 'DSU');

        Map<string,string> statusMap = new Map<String, String>();
        List<CRABB_DEV__Ceb__c> cebList = new List<CRABB_DEV__Ceb__c>();
        List<String> cebStatus = new List<String>{'Done', 'Error', 'Blocked'};

        cebList = [SELECT id from CRABB_DEV__Ceb__c limit 3];
        System.debug('Test ceb List --> ' + cebList);

        for(CRABB_DEV__Ceb__c ceb : cebList) {
            for(String str : cebStatus) {
                statusMap.put(ceb.id, str);
            }
        }

        Test.startTest();

            System.debug('statusMap --> ' + statusMap);
            Database.executeBatch(new CEBupdateStatusBatch(StatusMap), 50);
        Test.stopTest();
    }

    private static void generateScheduleBatchRecords() {
        CRABB_DEV__Schedule_Batch__c schBatch = new CRABB_DEV__Schedule_Batch__c();
        schBatch.name = 'Check Strategy Exit Criteria';
        schBatch.CRABB_DEV__Type__c = 'SCH';
        schBatch.CRABB_DEV__immediate_Action__c = false;
        schBatch.CRABB_DEV__isActive__c = true;
        schBatch.CRABB_DEV__Order__c = 1;
        schBatch.CRABB_DEV__Wait_Due_Date__c = false;

        CRABB_DEV__Schedule_Batch__c schBatch2 = new CRABB_DEV__Schedule_Batch__c();
        schBatch2.name = 'Check Expiration Type';
        schBatch2.CRABB_DEV__Type__c = 'CEX';
        schBatch2.CRABB_DEV__immediate_Action__c = true;
        schBatch2.CRABB_DEV__isActive__c = true;
        schBatch2.CRABB_DEV__Order__c = 2;
        schBatch2.CRABB_DEV__Wait_Due_Date__c = false;

        List<CRABB_DEV__Schedule_Batch__c> schBatchList = new List<CRABB_DEV__Schedule_Batch__c>();
        schBatchList.add(schBatch);
        schBatchList.add(schBatch2);

        insert schBatchList;
    }

    private static void generateRecordsForStrategy() {
        Account acc = new Account(name = 'accTest');
        insert acc;

        CRABB_DEV__Pratica__c pra = new CRABB_DEV__Pratica__c();
        pra.CRABB_DEV__Account__c = acc.id;
        insert pra;

        CRABB_DEV__Movimento__c mov = new CRABB_DEV__Movimento__c();
        mov.CRABB_DEV__Pratica__c = pra.id;
        mov.CRABB_DEV__Residuo__c = 1000;
        mov.CRABB_DEV__Importo__c= 1000;
        mov.CRABB_DEV__Data_Emissione__c = system.today().addDays(-30);
        mov.CRABB_DEV__Data_Scadenza__c = system.today().addDays(-20);
        mov.CRABB_DEV__Account__c = acc.id;
        mov.CRABB_DEV__Sollecitabile__c = true;
        mov.CRABB_DEV__Tipo_Scadenza__c = 'Scaduto';
        insert mov;

        Task t = [SELECT id, CRABB_DEV__ActivityExtended__c from Task where WhatId=:pra.id];

        CRABB_DEV__ActivityExtended__c ae = [SELECT id, CRABB_DEV__Expiration_date__c from CRABB_DEV__ActivityExtended__c where id = :t.CRABB_DEV__ActivityExtended__c];
        ae.CRABB_DEV__Expiration_date__c = System.today().addDays(-7);

        update ae;

    }

    private static void generateStrategyRecords(){
        Map<string, Schema.RecordTypeInfo> RTStrategiaNameID =Schema.SObjectType.Strategia__c.getrecordtypeinfosbydevelopername();
        List<Strategia__c> strategyList = new List<Strategia__c>();

        Strategia__c testata = new Strategia__c();
        testata.nome__c='Strategy test';
        testata.priority__c=1;
        testata.stato__c='Attiva';
        testata.Versione__c=1;
        testata.recordtypeId=RTStrategiaNameID.get('Testata').getRecordTypeID();
        testata.Tipo_Strategia__c='Standard';
        testata.Activation_roles__c='R2015-03-04 11:35:16,R2021-03-03 14:52:18,R7,R2014-07-11 10:29:40';
        //strategyList.add(testata);
        insert testata;


        Strategia__c condIngresso = new Strategia__c();
        condIngresso.CRABB_DEV__Testata__c=testata.id;
        condIngresso.nome__c='Ingresso strategia test';
        condIngresso.priority__c=1;
        condIngresso.stato__c='Attiva';
        condIngresso.recordtypeId=RTStrategiaNameID.get('Condizioni_di_Ingresso').getRecordTypeID();
        condIngresso.RC_Rule_Name__c='R2021-03-03 14:52:18';
        strategyList.add(condIngresso);

        //Step Stand-By
        Strategia__c stepSB = new Strategia__c();
        stepSB.CRABB_DEV__Testata__c=testata.id;
        stepSB.CRABB_DEV__Attivit_Padre__c=testata.id;
        stepSB.CRABB_DEV__Tipo_attivita__c='Attività di Attesa';
        stepSB.nome__c='1 - Stand by';
        stepSB.Tipologia__c = 'Expectance';
        stepSB.priority__c=0;
        stepSB.stato__c='Attiva';
        stepSB.recordtypeId=RTStrategiaNameID.get('Step').getRecordTypeID();
        insert stepSB;

        //Step Crea Case
        Strategia__c stepCreaCase = new Strategia__c();
        stepCreaCase.CRABB_DEV__Testata__c=testata.id;
        stepCreaCase.CRABB_DEV__Attivit_Padre__c=stepSB.id;
        stepCreaCase.CRABB_DEV__Tipo_attivita__c='Invio SMS';
        stepCreaCase.sotto_tipo_attivita__c='Seconda Raccomandata';
        stepCreaCase.nome__c='Crea Case';
        stepCreaCase.Tipologia__c = 'UI';
        stepCreaCase.priority__c=1;
        stepCreaCase.stato__c='Attiva';
        stepCreaCase.recordtypeId=RTStrategiaNameID.get('Step').getRecordTypeID();
        strategyList.add(stepCreaCase);

        //Step Crea PDF
        Strategia__c stepCreaPDF = new Strategia__c();
        stepCreaPDF.CRABB_DEV__Testata__c=testata.id;
        stepCreaPDF.CRABB_DEV__Attivit_Padre__c=stepSB.id;
        stepCreaPDF.CRABB_DEV__Tipo_attivita__c='Proposta di Attività';
        stepCreaPDF.sotto_tipo_attivita__c='Lettera ordinaria';
        stepCreaPDF.nome__c='CREA PDF';
        stepCreaPDF.Tipologia__c = 'UI';
        stepCreaPDF.priority__c=2;
        stepCreaPDF.stato__c='Attiva';
        stepCreaPDF.recordtypeId=RTStrategiaNameID.get('Step').getRecordTypeID();
        strategyList.add(stepCreaPDF);

        insert strategyList;
        update testata;

    }
}