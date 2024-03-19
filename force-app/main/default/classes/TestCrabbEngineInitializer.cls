@IsTest
public class TestCrabbEngineInitializer {
    @TestSetup
    public static void generateTestData() {
        generateRecordsForStrategy();
        generateScheduleBatchRecords();
    }

    @IsTest
    public static void cEBElaborateStrategyTest() {
        generateStrategyRecords();

        Test.startTest();
        Database.executeBatch(new CrabbStrategyInsertBatch(), 50);
        Database.executeBatch(new CrabbEngine(), 50);

        List<Pratica__c> praList = [select id, Account__c from Pratica__c];
        List<Task> taskList = [select id, subject, status, ActivityExtended__c from Task where WhatId in :praList];
        taskList.get(0).Status='Lavorata';


        //Generate Task With CEB EVENT PDF
        List<String> praIds = new List<String>();
        praIds.add(praList.get(0).id);

        ActivityExtended__c ae = new ActivityExtended__c();
        ae.Tipo__c='Proposta di Attività';
        ae.Sotto_Tipo__c='Lettera ordinaria';
        insert ae;
        Task tsk = new Task();
        tsk.Status = 'Non Iniziata';
        tsk.Subject = 'CREA PDF';
        tsk.Description = '';
        tsk.WhatId = praList.get(0).Id;
        tsk.Type = 'Credito';
        tsk.ActivityExtended__c=ae.id;
        insert tsk;

        //Generate Task With CEB EVENT NCA
        ActivityExtended__c ae2 = new ActivityExtended__c();
        ae2.Tipo__c='Invio SMS';
        ae2.Sotto_Tipo__c='Seconda Raccomandata';
        insert ae2;
        Task tsk2 = new Task();
        tsk2.Status = 'Non Iniziata';
        tsk2.Subject = 'Crea Case';
        tsk2.Description = '';
        tsk2.WhatId = praList.get(0).Id;
        tsk2.Type = 'Credito';
        tsk2.ActivityExtended__c=ae2.id;
        insert tsk2;

        Database.executeBatch(new CrabbEngineInitializer(), 50);

        Test.stopTest();
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

    private static void generateScheduleBatchRecords() {
        List<CRABB_DEV__Schedule_Batch__c> schBatchList = new List<CRABB_DEV__Schedule_Batch__c>();

        CRABB_DEV__Schedule_Batch__c schBatch = new CRABB_DEV__Schedule_Batch__c();
        schBatch.name = 'Check Strategy Exit Criteria';
        schBatch.CRABB_DEV__Type__c = 'SCH';
        schBatch.CRABB_DEV__immediate_Action__c = false;
        schBatch.CRABB_DEV__isActive__c = true;
        schBatch.CRABB_DEV__Order__c = 1;
        schBatch.CRABB_DEV__Wait_Due_Date__c = false;
        schBatchList.add(schBatch);


        CRABB_DEV__Schedule_Batch__c schBatch2 = new CRABB_DEV__Schedule_Batch__c();
        schBatch2.name = 'Check Expiration Type';
        schBatch2.CRABB_DEV__Type__c = 'CEX';
        schBatch2.CRABB_DEV__immediate_Action__c = true;
        schBatch2.CRABB_DEV__isActive__c = true;
        schBatch2.CRABB_DEV__Order__c = 2;
        schBatch2.CRABB_DEV__Wait_Due_Date__c = true;
        schBatchList.add(schBatch2);

        CRABB_DEV__Schedule_Batch__c schBatch3 = new CRABB_DEV__Schedule_Batch__c();
        schBatch3.name = 'Refresh EC';
        schBatch3.CRABB_DEV__Type__c = 'UEC';
        schBatch3.CRABB_DEV__immediate_Action__c = true;
        schBatch3.CRABB_DEV__isActive__c = true;
        schBatch3.CRABB_DEV__Order__c = 2;
        schBatch3.CRABB_DEV__Wait_Due_Date__c = false;
        schBatchList.add(schBatch3);

        CRABB_DEV__Schedule_Batch__c schBatch4 = new CRABB_DEV__Schedule_Batch__c();
        schBatch4.name = 'Create PDF';
        schBatch4.CRABB_DEV__Type__c = 'PDF';
        schBatch4.CRABB_DEV__immediate_Action__c = true;
        schBatch4.CRABB_DEV__isActive__c = true;
        schBatch4.CRABB_DEV__Order__c = 2;
        schBatch4.CRABB_DEV__Wait_Due_Date__c = false;
        schBatchList.add(schBatch4);

        CRABB_DEV__Schedule_Batch__c schBatch5 = new CRABB_DEV__Schedule_Batch__c();
        schBatch5.name = 'Create Case';
        schBatch5.CRABB_DEV__Type__c = 'NCA';
        schBatch5.CRABB_DEV__immediate_Action__c = true;
        schBatch5.CRABB_DEV__isActive__c = true;
        schBatch5.CRABB_DEV__Order__c = 2;
        schBatch5.CRABB_DEV__Wait_Due_Date__c = false;
        schBatchList.add(schBatch5);


        CRABB_DEV__Schedule_Batch__c schBatch6 = new CRABB_DEV__Schedule_Batch__c();
        schBatch6.name = 'Expectance End';
        schBatch6.CRABB_DEV__Type__c = 'WAI';
        schBatch6.CRABB_DEV__immediate_Action__c = false;
        schBatch6.CRABB_DEV__isActive__c = true;
        schBatch6.CRABB_DEV__Order__c = 2;
        schBatch6.CRABB_DEV__Wait_Due_Date__c = true;
        schBatchList.add(schBatch6);

        insert schBatchList;
    }

    private static void generateRecordsForStrategy() {
        Account acc = new Account(name = 'accTest');
        insert acc;

        CRABB_DEV__Pratica__c pra = new CRABB_DEV__Pratica__c();
        pra.CRABB_DEV__Account__c = acc.id;
        //pra.Stato__c = 'In Lavorazione';
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

        List<Task> tList = [SELECT id, Subject, Status, CRABB_DEV__ActivityExtended__c from Task where WhatId=:pra.id];

        List<String> aeIds = new List<String>();
        for(Task t : tList) {
            aeIds.add(t.CRABB_DEV__ActivityExtended__c);
        }

        List<CRABB_DEV__ActivityExtended__c> aeList = [SELECT id, CRABB_DEV__Expiration_date__c from CRABB_DEV__ActivityExtended__c where id in :aeIds];
        for(ActivityExtended__c ae : aeList) {
            ae.CRABB_DEV__Expiration_date__c = System.today().addDays(-7);
        }

        update aeList;

    }
}