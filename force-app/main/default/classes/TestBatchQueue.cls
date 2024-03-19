/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestBatchQueue.cls
Description:     Test Class for code coverage of BatchQueue.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
25-Aug-2021  0.2      Giulia Mameli
----------------------------------------------------------------------------------------------------------------------*/

@IsTest
private class TestBatchQueue {
    public static final Id DEBUG_RT = Schema.SObjectType.Log__c.getRecordTypeInfosByDeveloperName().get('Debug').getRecordTypeId();

    @IsTest static void BatchQueueTest1() {
        BatchQueue bQueue = new BatchQueue();
        System.assertEquals(true, bQueue != null, 'Error in Batch Queue instantiation');

    }

    @IsTest static void BatchQueueCloseBatch() {
        Log__c log = new Log__c();
        log.RecordTypeId = DEBUG_RT;
        insert log;

        BatchQueue__c bQueue = new BatchQueue__c();
        bQueue.Name = 'Test BQ';
        bQueue.isClosed__c = false;
        bQueue.Starting_date_time__c = System.today();
        bQueue.id_batch__c = log.Id;
        insert bQueue;

        BatchQueue.closeBatches();
    }

    @IsTest static  void BatchQueueRunBatches() {
        BatchQueue.runBatches();
    }

    @IsTest static void BatchQueueCloseScheduler() {
        BatchQueue.closeScheduler('XXX');
    }

    @IsTest static void BatchQueueRequireSchedule() {
        BatchQueue.requireSchedule(5);
        BatchQueue.requireSchedule(0);
    }

    @IsTest static void BatchQueueAttachDebug() {
        List<Log__c> logsList = new List<Log__c>();
        logsList.add(ErrorClass.instanceError('BatchQueue.deleteClosedBatches.Info', 'Sono stati eliminati alcuni elementi dal custom setting BatchQueue'));
        insert(logsList);
        BatchQueue.attachDebug(logsList, 'XXXXX');
    }

    @IsTest static void BatchQueueDeleteClosedBatches() {
        BatchQueue__c bq = new BatchQueue__c();
        bq.Name = 'XX';
        bq.isClosed__c = true;
        insert bq;
        BatchQueue.deleteClosedBatches();
    }

    @IsTest static void batchQueueReqBatches() {
        BatchQueue__c bq = new BatchQueue__c();
        bq.Name = 'XX';
        bq.isClosed__c = true;
        insert bq;

        List<Id> ids = new List<Id>();
        ids.add(bq.Id);
        BatchQueue.reqBatch('xxx', 'MyClass', 1, 1, 'MyOperation', ids);
    }

    @IsTest static void batchQueueReqBatches2() {
        BatchQueue__c bq = new BatchQueue__c();
        bq.Name = 'XX';
        bq.isClosed__c = true;
        insert bq;
        List<Id> ids = new List<Id>();
        ids.add(bq.Id);
        ids.add(bq.Id);
        ids.add(bq.Id);
        ids.add(bq.Id);
        ids.add(bq.Id);
        ids.add(bq.Id);
        ids.add(bq.Id);
        ids.add(bq.Id);
        ids.add(bq.Id);
        ids.add(bq.Id);
        ids.add(bq.Id);
        ids.add(bq.Id);
        ids.add(bq.Id);
        BatchQueue.reqBatch('xxx', 'MyClass', 1, 1, 'MyOperation', ids);
    }

    @IsTest static void BatchQueueReqBatches3() {
        BatchProcess__c bp = new BatchProcess__c();
        BatchQueue.reqBatch(bp);
    }

    @IsTest static void BatchQueueReqBatches3_1() {
        BatchProcess__c bp;
        try {
            BatchQueue.reqBatch(bp);
        } catch (Exception ex) {
            System.debug('Exception --> '+ex);
        }
    }

    @IsTest static void BatchQueueReqBatches4() {
        Lotto__c lotto = new Lotto__c();
        List<Lotto__c> lottiList = new List<Lotto__c>();
        lottiList.add(lotto);
        BatchQueue.reqBatch('xxx', 'MyClass', 1, 1, lottiList);
    }

    @IsTest static void BatchQueueReqBatches5() {
        Lotto__c lotto = new Lotto__c();
        List<Lotto__c> lottiList = new List<Lotto__c>();
        lottiList.add(lotto);
        lottiList.add(lotto);
        lottiList.add(lotto);
        lottiList.add(lotto);
        lottiList.add(lotto);
        lottiList.add(lotto);
        lottiList.add(lotto);
        lottiList.add(lotto);
        lottiList.add(lotto);
        lottiList.add(lotto);
        lottiList.add(lotto);
        lottiList.add(lotto);
        BatchQueue.reqBatch('xxx', 'MyClass', 1, 1, lottiList);
    }

    @IsTest static void BatchQueueReqBatches6() {
        Log__c log = new Log__c();
        log.RecordTypeId = DEBUG_RT;
        insert log;
        BatchQueue.reqBatch('xxx', 'MyClass', 1, 1, log.Id, 'MyOperation');
    }

    @IsTest static void BatchQueueExecuteBatch() {
        BatchQueue__c bq = new BatchQueue__c();
        bq.ClassName__c = 'IntegrationProcessAttachmentBatch';

        Log__c log = new Log__c();
        log.Message_In__c = 'XX;XY';
        log.RecordTypeId = DEBUG_RT;
        insert log;

        bq.Id_target__c = log.Id;
        bq.Scope__c = 1;

        BatchQueue.executeBatch(bq);
    }

    @IsTest static void BatchQueueExecuteBatch2() {
        BatchQueue__c bq = new BatchQueue__c();
        bq.ClassName__c = 'AffidiIncassiUpdateBatch';

        Log__c log = new Log__c();
        log.Message_In__c = 'XX;XY';
        log.RecordTypeId = DEBUG_RT;
        insert log;

        bq.Id_target__c = log.Id;
        bq.Scope__c = 1;

        BatchQueue.executeBatch(bq);
    }

    @IsTest static void BatchQueueExecuteBatch3() {
        BatchQueue__c bq = new BatchQueue__c();
        bq.ClassName__c = 'AffidiSaldoPeriodoAffidamentoUpdateBatch';

        Log__c log = new Log__c();
        log.Message_In__c = 'XX;XY';
        log.RecordTypeId = DEBUG_RT;
        insert log;

        bq.Id_target__c = log.Id;
        bq.Scope__c = 1;

        BatchQueue.executeBatch(bq);
    }

    @IsTest static void BatchQueueExecuteBatch4() {
        BatchQueue__c bq = new BatchQueue__c();
        bq.ClassName__c = 'FLussiCollectorManagerBatch';
        bq.operation__c = 'Test';

        Log__c log = new Log__c();
        log.Message_In__c = 'XX;XY';
        log.RecordTypeId = DEBUG_RT;
        insert log;

        bq.Id_target__c = log.Id;
        bq.Scope__c = 1;

        BatchQueue.executeBatch(bq);
    }

    @IsTest static void BatchQueueExecuteBatch5() {
        BatchQueue__c bq = new BatchQueue__c();
        bq.ClassName__c = 'MovSaldiBatch';
        bq.operation__c = 'Test';

        Log__c log = new Log__c();
        log.Message_In__c = 'XX;XY';
        log.RecordTypeId = DEBUG_RT;
        insert log;

        bq.Id_target__c = log.Id;
        bq.Scope__c = 1;

        BatchQueue.executeBatch(bq);
    }

    @IsTest static void BatchQueueExecuteBatch6() {
        BatchQueue__c bq = new BatchQueue__c();
        bq.ClassName__c = 'OrkBatchActivities';
        bq.operation__c = 'Test';

        Log__c log = new Log__c();
        log.Message_In__c = 'XX;XY';
        log.RecordTypeId = DEBUG_RT;
        insert log;

        bq.Id_target__c = log.Id;
        bq.Scope__c = 1;

        BatchQueue.executeBatch(bq);
    }

    @IsTest static void BatchQueueExecuteBatch7() {
        BatchQueue__c bq = new BatchQueue__c();
        bq.ClassName__c = 'OrkBatch';

        Log__c log = new Log__c();
        log.Message_In__c = 'XX;XY';
        log.RecordTypeId = DEBUG_RT;
        insert log;

        bq.Id_target__c = log.Id;
        bq.Scope__c = 1;

        BatchQueue.executeBatch(bq);
    }

    @IsTest static void BatchQueueExecuteBatch8() {
        Strategia__c testata = TestClassFroDataGenAffidamenti.getStrategia('Testata');
        testata.Nome__c = 'Test';
        testata.Stato__c = 'Attiva';
        insert testata;

        Contratto__c ct = TestClassFroDataGenAffidamenti.getContratto();
        insert ct;

        //Create Account from requested Contract
        Account acc = TestClassFroDataGenAffidamenti.getAccount(ct.Id);
        insert acc;

        //Create Dossier from Account
        Pratica__c pr = TestClassFroDataGenAffidamenti.getPratica(acc.Id);
        pr.Stato__c = 'In Lavorazione';
        insert pr;

        BatchQueue__c bq = new BatchQueue__c();
        bq.ClassName__c = 'OrkBatch';
        bq.operation__c = 'Test';

        Log__c log = new Log__c();
        log.Message_In__c = 'XX;XY';
        log.RecordTypeId = DEBUG_RT;
        insert log;

        bq.Id_target__c = log.Id;
        bq.Scope__c = 1;

        BatchQueue.executeBatch(bq);
    }

    @IsTest static void BatchQueueExecuteBatch9() {
        BatchQueue__c bq = new BatchQueue__c();
        bq.ClassName__c = 'AffidiProcessBatch';
        bq.operation__c = 'Test';

        Log__c log = new Log__c();
        log.Message_In__c = 'XX;XY';
        log.RecordTypeId = DEBUG_RT;
        insert log;

        bq.Id_target__c = log.Id;
        bq.Scope__c = 1;

        BatchQueue.executeBatch(bq);
    }

}