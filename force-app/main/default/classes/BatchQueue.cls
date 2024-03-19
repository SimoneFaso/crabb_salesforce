/* ---------------------------------------------------------------------------------------------------------------------
Name:            BatchQueue.cls
Description:     This class manages Batch Queue custom setting for executing and storing the execution of system
                 scheduled batches
Test class:      TestBatchQueue.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
                                                      First Version
03-Sep-2021  0.2      Giulia Mameli                   Modified closeBatches() method for deleting closed Batch Queue
                                                      records and reviewed for Security Review
01-Oct-2021  0.3      Giulia Mameli                   Modified scheduleBatches() to create BatchQueue records only for
                                                      Managed by BatchScheduler Batch Processes
14-Sep-2022  0.4      R.Kurti & C.Sanna               Added cebCheckObjPermissions and WITH SECURITY_ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class BatchQueue {

    public class BatchQueueException extends Exception {
    }
    public static String exceptD = '';
    public static final Integer MAX_BATCHES = 5;
    public static List<String> batchSchedulerClasses = new List<String>();
    public static List<BatchProcess__c> batchProcesses = new List<BatchProcess__c>();
    public static final Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    /*
    This method retrieves classes' names from Batch Process custom setting where Managed By Batch Scheduler is true
    so to possibly exclude data mapping batches
    */
    private static void getClassesManagedByBatchScheduler() {
        if (batchProcesses.isEmpty()) {
            batchProcesses = [
                    SELECT Id, Code__c, Name__c, Name, Last_running__c, Last_scheduled_time__c, Managed_by_BatchScheduler__c, operation__c, Priority__c, run_at_time__c, Run_every_minutes__c, Scheduler__c, ScopeSize__c, Type__c
                    FROM BatchProcess__c
                    WHERE Managed_by_BatchScheduler__c = TRUE
            ];
        }

        for (BatchProcess__c batchP : batchProcesses) {
            batchSchedulerClasses.add(batchP.Name__c);
        }
    }

    /*
    This method compares id_batch__c field on Batch Queues records with completed AsyncApexJob Ids to set, in case of matching, isClosed__c to true
    and Closing_date_time__c to the batch CompletedDate. Updated Batch Queues records will be deleted in the next running.
    */
    public static Boolean closeBatches() {
        exceptD += '\n in closeBatches';
        try {
            // inizio nuovo codice 12/04 inserimento check permission
            if (Utils.cebCheckObjPermission('BatchQueue__c', gd).get('ACCESS')) {
                // fine nuovo codice 12/04 inserimento check permission
                String queryString = 'SELECT ' + Utils.getSOBJECTFieldsForQuery('BatchQueue__c') + ' FROM BatchQueue__c WHERE isClosed__c = false and Starting_date_time__c != null AND id_batch__c != null order by Priority__c, requested_date_time__c ASC';
                List<BatchQueue__c> bqqList = Database.query(String.escapeSingleQuotes(queryString));
                if (bqqList == null || bqqList.size() == 0) return true;

                List<BatchQueue__c> bqToUpdate = new List<BatchQueue__c>();
                List<Id> asyncApexJobIds = new List<Id>();

                for (BatchQueue__c bqq : bqqList) {
                    if (String.isNotEmpty(bqq.id_batch__c)) {
                        //Convert id_batch__c into a 18-characters Id to match AsyncApexJob Id
                        asyncApexJobIds.add(Id.valueOf(bqq.CRABB_DEV__id_batch__c));

                    }
                }

                List<AsyncApexJob> asyncApexJobs = [SELECT Id, CompletedDate FROM AsyncApexJob WHERE Id IN :asyncApexJobIds AND JobType = 'BatchApex' AND (Status != 'Processing' AND Status != 'Preparing')];

                Map<String, AsyncApexJob> asyncApexJobsMap = new Map<String, AsyncApexJob>(asyncApexJobs);

                for (BatchQueue__c bqq : bqqList) {
                    if (asyncApexJobsMap.get(Id.valueOf(bqq.CRABB_DEV__id_batch__c)) != null) {
                        bqq.isClosed__c = true;
                        bqq.Closing_date_time__c = asyncApexJobsMap.get(Id.valueOf(bqq.CRABB_DEV__id_batch__c)).CompletedDate;
                        bqToUpdate.add(bqq);
                    }
                }
                //throw new BatchQueueException('bqq:'+bqqList[0]);
                if (Utils.cebCheckObjPermission('BatchQueue__c', gd).get('UPDATE')) {
                    Database.SaveResult[] bqUpdateResult = Database.update(bqToUpdate);
                    System.debug('bqUpdateResult --> ' + bqUpdateResult);
                }
                exceptD += '\n out closeBatches true';
            }
            return true;

        } catch (Exception e) {
            exceptD += '\n out closeBatches false';
            ErrorClass.logError('BatchQueue.closeBatches', 'Error: ' + exceptD + '\n __' + System.now() + '\n\n' + Utils.getExceptionInString(e));
            return false;
        }
    }

    /*
        This method is the principal method that run 
        the logics to schedule and run new batches.
            
    */
    public static Boolean runBatches() {
        exceptD += '\n in runBatches ';

        //Fill in batchSchedulerClasses List with classes' names managed by BatchScheduler
        getClassesManagedByBatchScheduler();
        closeBatches();
        scheduleBatches();

        //Retrieve the number of running batches in the system (managed by BatchScheduler), so to establish if it's possible to run new batches.
        Integer runningBatches = [
                SELECT COUNT()
                FROM AsyncApexJob
                WHERE JobType = 'BatchApex'
                AND (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Queued')
                AND ApexClass.NamespacePrefix = 'CRABB_DEV'
                AND ApexClass.Name IN :batchSchedulerClasses
        ];

        //If running batches are less than MAX_BATCHES (5), then it's possible to run new batches.
        //MAX_BATCHES = (Test.isRunningTest())?10000:5;

        System.debug('MAX_BATCHES --> ' + MAX_BATCHES);
        System.debug('runningBatches --> ' + runningBatches);
        if (runningBatches < MAX_BATCHES) {
            Integer batchesLimit = MAX_BATCHES - runningBatches, newBatchesExecuted = 0;
            //are queried the records to process. The number of records to return has limit batchesLimit.

            // inizio nuovo codice 12/04 inserimento check permission
            if (Utils.cebCheckObjPermission('BatchQueue__c', gd).get('ACCESS')) {
                // fine nuovo codice 12/04 inserimento check permission
                String queryString = 'SELECT ' + String.escapeSingleQuotes(Utils.getSOBJECTFieldsForQuery('BatchQueue__c')) + ' FROM BatchQueue__c where Starting_date_time__c = null and ClassName__c != \'BatchScheduler\' ORDER BY Priority__c,requested_date_time__c LIMIT : batchesLimit';
                //System.debug('QUERY STRING IS: ' +queryString);
                String value = 'BatchScheduler';
                String queryString1 = 'SELECT ' + Utils.getSOBJECTFieldsForQuery('BatchQueue__c') + ' FROM BatchQueue__c where Starting_date_time__c = null and ClassName__c != ' + value +' ORDER BY Priority__c,requested_date_time__c LIMIT : batchesLimit';
                //System.debug('NEW QUERY STRING IS: ' + String.escapeSingleQuotes(queryString1));

                List<BatchQueue__c> bqqList = Database.query(queryString);

                try {
                    if (bqqList != null && bqqList.size() > 0) {
                        for (BatchQueue__c bqq : bqqList) {
                            newBatchesExecuted += executeBatch(bqq);
                        }
                        if (Utils.cebCheckObjPermission('BatchQueue__c', gd).get('UPDATE')) {
                            update bqqList;
                        }
                    }
                    //Se i batches in esecuzione == 1 e non sono stati processati nuovi batch allora richiedi uno schedule
                    if (runningBatches <= 1 && newBatchesExecuted == 0) {
                        requireSchedule(runningBatches);
                    } else {
                        exceptD += '\n runningBatches: ' + runningBatches;
                        exceptD += '\n newBatchesExecuted: ' + newBatchesExecuted;
                        List<AsyncApexJob> aaj = [SELECT Id, ApexClass.Name, Status FROM AsyncApexJob WHERE JobType = 'BatchApex' AND (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Queued')];
                        if (aaj.size() > 0) {
                            exceptD += '\n AsyncApexJob: ' + aaj;
                        }
                    }
                } catch (Exception e) {
                    exceptD += '\n exception runBatches ';
                    ErrorClass.logError('BatchQueue.Exception', 'Exception:' + exceptD + '\n ' + Utils.getExceptionInString(e));
                }
            }
        }
        exceptD += '\n exit runBatches ';
        return false;
    }

    public static void closeScheduler(String bname) {
        exceptD += '\n in closeScheduler ';
        BatchQueue__c bQ = BatchQueue__c.getValues(bname);
        if (bQ == null) {
            return;
        } else {
            bQ.isClosed__c = true;
            if (Utils.cebCheckObjPermission('BatchQueue__c',gd).get('UPDATE') && Utils.cebCheckFLSPermission('BatchQueue__c', 'scope__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('BatchQueue__c', 'Id_target__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('BatchQueue__c', 'operation__c', gd).get('UPDATE')) {
                update bQ;

            }
        }
        exceptD += '\n out closeScheduler ';
    }

    /*This method define if is necessary to process and require a new scheduled class.*/
    public static void requireSchedule(Integer numberOfBatchesRunning) {
        exceptD += '\n in requireSchedule';
        if (numberOfBatchesRunning > 1) {
            exceptD += '\n out requireSchedule too running batches';
            return;
        }

        BatchQueue__c scheduleBQ = BatchQueue__c.getValues('BatchScheduler');
        //Quando si avvia la gestione dei batches ed il record BatchScheduler non esiste ancora
        if (scheduleBQ == null) {
            scheduleBQ = new BatchQueue__c();
            scheduleBQ = createScheduledJob(scheduleBQ, 'a');

            //Se il BatchScheduler è chiuso, se ne avvia un altro.
        } else if (scheduleBQ.isClosed__c == true) {
            scheduleBQ = createScheduledJob(scheduleBQ, 'b');

            //Se il BatchScheduler risulta in corso, si va a osservare se è in esecuzione e che non sia stato interrotto. Nel caso non sia presente, si va a crearne uno.
        } else if (scheduleBQ.isClosed__c == false) {
            Map<Id, CronTrigger > async = new Map<Id, CronTrigger >([SELECT Id FROM CronTrigger WHERE Id = :scheduleBQ.id_batch__c]);
            if (async == null || async.isEmpty()) {
                scheduleBQ = createScheduledJob(scheduleBQ, 'c');
            }
        }

        if (Utils.cebCheckObjPermission('BatchQueue__c',gd).get('UPSERT') && Utils.cebCheckFLSPermission('BatchQueue__c', 'Scope__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('BatchQueue__c', 'Id_target__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('BatchQueue__c', 'operation__c', gd).get('UPSERT')) {
            upsert scheduleBQ;
        }

        exceptD += '\n out requireSchedule';
    }

    public static BatchQueue__c createScheduledJob(BatchQueue__c scheduleBQ, String sr) {
        exceptD += '\n in createScheduledJob';
        String stringTime = '' + System.currentTimeMillis();
        BatchScheduler BS = new BatchScheduler();
        Datetime dt = Datetime.now().addMinutes(10);
        String ora = String.valueOf(dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' * * ? *');
        Id sId2 = System.schedule('BatchSchedule_' + sr + '_' + stringTime, ora, BS);
        scheduleBQ.Name = 'BatchScheduler';
        scheduleBQ.ClassName__c = 'BatchScheduler';
        scheduleBQ.BatchProcess__c = 'BatchScheduler';
        scheduleBQ.Priority__c = 80;
        scheduleBQ.isClosed__c = false;
        scheduleBQ.id_batch__c = sId2;
        scheduleBQ.requested_date_time__c = dt;
        exceptD += '\n out createScheduledJob';
        return scheduleBQ;
    }

    /*
        This class has the logic to schedule and create the batches in the BatchQueue custom setting.
        There are two logics:
            - run every X minutes
            - run at time xx:yy ( where the time is set in minutes respect the time 00:00, for example 01:15 is 75 ( minutes after 00:00))
            needs to be defined something more solid
    */
    public static void scheduleBatches() {
        exceptD += '\n in scheduleBatches';
        try {

            System.debug('scheduleBatches batchProcesses --> ' + batchProcesses);
            if (batchProcesses.isEmpty()) {
                getClassesManagedByBatchScheduler();
            }

            Map<String, BatchProcess__c> allBatches = new Map<String, BatchProcess__c>(batchProcesses);

            Set<String> BatchProcesses = new Set<String>();
            Set<String> scheduledBatches = new Set<String>();

            BatchProcesses.addAll(allBatches.keySet());
            // inizio nuovo codice 12/04 inserimento check permission
            if (Utils.cebCheckObjPermission('BatchQueue__c', gd).get('ACCESS')) {
                // fine nuovo codice 12/04 inserimento check permission
                String queryString = 'Select ' + Utils.getSOBJECTFieldsForQuery('BatchQueue__c') + ' From BatchQueue__c where Starting_date_time__c=null and BatchProcess__c in: BatchProcesses order by Priority__c,requested_date_time__c ';
                List<BatchQueue__c> bqqList = Database.query(String.escapeSingleQuotes(queryString));
                System.debug('scheduleBatches bqqList --> ' + bqqList);

                for (BatchQueue__c bqq : bqqList) {
                    scheduledBatches.add(bqq.BatchProcess__c);
                }

                for (String s : allBatches.keySet()) {
                    BatchProcess__c myBP = allBatches.get(s);
                    if (scheduledBatches.contains(myBP.Name)) continue;

                    if (myBP.Last_scheduled_time__c == null) {
                        reqBatch(myBP);
                    } else if (myBP.Last_scheduled_time__c != null) {
                        if (myBP.Run_every_minutes__c != null) {
                            Long dt1Long = myBP.Last_scheduled_time__c.getTime();
                            Long dt2Long = Datetime.now().getTime();
                            Long milliseconds = dt2Long - dt1Long;
                            Long seconds = milliseconds / 1000;
                            Long minutes = seconds / 60;
                            if (myBP.Run_every_minutes__c <= minutes) {
                                reqBatch(myBP);
                            }
                        }
                        if (myBP.run_at_time__c != null && myBP.Last_scheduled_time__c.date() != System.today()) {
                            Long dt1Long = System.now().getTime();
                            dt1Long = dt1Long / 1000;
                            dt1Long = dt1Long / 60;
                            if (myBP.run_at_time__c <= dt1Long) {
                                reqBatch(myBP);
                            }
                        }
                    }
                }
                if (Utils.cebCheckFLSPermission('BatchProcess__c', 'Last_scheduled_time__c', gd).get('UPDATE')) {
                    update allBatches.values();
                }
            }
        } catch (Exception e) {
            exceptD += '\n exception scheduleBatches';
            ErrorClass.logError('BatchQueue.scheduleBatches', 'Error: ' + exceptD + '\n __' + System.now() + '\n\n' + Utils.getExceptionInString(e));
        }
        exceptD += '\n out scheduleBatches';
    }

    /*
        This method instances a Batch respect the BatchQueue record given. Each Batch has its own class and parameters. Each batch has its own
        logic to be created. It returns an integer, which say if a Batch has been processed or not.
        This happens if someone changes configuration and the method is not able to start a Batch. In this case it puts the record in
        error and return 0. If a batch is created the method return 1.
    */
    public static Integer executeBatch(BatchQueue__c bqq) {
        exceptD += '\n in executeBatch';
        /*the class in function of the class name*/
        if (bqq.ClassName__c == 'AffidiIncassiUpdateBatch') {
            AffidiIncassiUpdateBatch AIUB = new AffidiIncassiUpdateBatch();
            bqq.id_batch__c = Database.executeBatch(AIUB, Integer.valueOf(bqq.Scope__c));
            bqq.Starting_date_time__c = System.now();
        } else if (bqq.ClassName__c == 'AffidiSaldoPeriodoAffidamentoUpdateBatch') {
            AffidiSaldoPeriodoAffidamentoUpdateBatch ASPAUB = new AffidiSaldoPeriodoAffidamentoUpdateBatch();
            bqq.id_batch__c = Database.executeBatch(ASPAUB, Integer.valueOf(bqq.Scope__c));
            bqq.Starting_date_time__c = System.now();
        } else if (bqq.ClassName__c == 'FLussiCollectorManagerBatch') {
            FLussiCollectorManagerBatch FCMB = new FLussiCollectorManagerBatch(bqq.operation__c);
            bqq.id_batch__c = Database.executeBatch(FCMB, Integer.valueOf(bqq.Scope__c));
            bqq.Starting_date_time__c = System.now();
        } else if (bqq.ClassName__c == 'MovSaldiBatch') {
            MovSaldiBatch FCMB = new MovSaldiBatch(bqq.operation__c);
            bqq.id_batch__c = Database.executeBatch(FCMB, Integer.valueOf(bqq.Scope__c));
            bqq.Starting_date_time__c = System.now();
        } else if (bqq.ClassName__c == 'OrkBatchActivities') {
            OrkBatchActivities OBA = new OrkBatchActivities(bqq.operation__c);
            bqq.id_batch__c = Database.executeBatch(OBA, Integer.valueOf(bqq.Scope__c));
            bqq.Starting_date_time__c = System.now();
        } else if (bqq.ClassName__c == 'AffidiProcessBatch') {
            if (bqq.operation__c == null) {
                List<String> idLotti = Utils.sliptToListString(bqq.Id_target__c, ',');
                List<Lotto__c> lotti = [SELECT Id FROM Lotto__c WHERE Id IN :idLotti WITH SECURITY_ENFORCED ];
                AffidiProcessBatch APB = new AffidiProcessBatch(lotti);
                bqq.id_batch__c = Database.executeBatch(APB, Integer.valueOf(bqq.Scope__c));
                bqq.Starting_date_time__c = System.now();
            } else {
                List<String> idLotti = Utils.sliptToListString(bqq.Id_target__c, ',');
                List<Id> ids = new List<Id>();
                for (String s : idLotti) {
                    ids.add(Id.valueOf(s));
                }
                AffidiProcessBatch APB = new AffidiProcessBatch(ids, bqq.operation__c);
                bqq.id_batch__c = Database.executeBatch(APB, Integer.valueOf(bqq.Scope__c));
                bqq.Starting_date_time__c = System.now();
            }
        } else if (bqq.ClassName__c == 'OrkBatch') {
            OrkBatch OB;
            if (bqq.operation__c == null) {
                OB = new OrkBatch();
            } else {
                OB = new OrkBatch(bqq.operation__c);
            }
            bqq.id_batch__c = Database.executeBatch(OB, Integer.valueOf(bqq.Scope__c));
            bqq.Starting_date_time__c = System.now();
        } else {
            ErrorClass.logError('ExecuteBatch not found', 'Batch not found:' + exceptD + '\n ' + bqq);
            bqq.Starting_date_time__c = System.now();
            return 0;
        }
        exceptD += '\n out executeBatch';
        return 1;
    }

    /*
        reqBatch(BatchProcess__c) is used to insert in the Batch Queue a Batch that is configured in BatchProcess custom setting.
        When a BatchQueue is created, the batch is effectively created by the method runBatches/executeBatches.
    */
    public static Boolean reqBatch(BatchProcess__c bp) {
        exceptD += '\n in reqBatch_BP';

        try {
            BatchQueue__c bqq = new BatchQueue__c();
            Datetime dt = System.now();
            //String stringTime = '' + System.currentTimeMillis();
            do {
                String token = EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(1, 16);
                bqq.Name = bp.Code__c + dt.year() + dt.month() + dt.day() + token;
            } while (BatchQueue__c.getValues(bqq.Name) != null);

            bqq.ClassName__c = bp.Name__c;
            bqq.BatchProcess__c = bp.Name;
            bqq.Priority__c = bp.Priority__c;
            bqq.requested_date_time__c = System.now();
            bp.Last_scheduled_time__c = bqq.requested_date_time__c;
            bqq.operation__c = bp.operation__c;
            bqq.Scope__c = bp.ScopeSize__c;

            if (Utils.cebCheckObjPermission('BatchQueue__c',gd).get('INSERT') && Utils.cebCheckFLSPermission('BatchQueue__c', 'Scope__c', gd).get('INSERT')
                    && Utils.cebCheckFLSPermission('BatchQueue__c', 'Id_target__c', gd).get('INSERT')
                    && Utils.cebCheckFLSPermission('BatchQueue__c', 'operation__c', gd).get('INSERT')) {
                insert bqq;
            }
            exceptD += '\n out reqBatch_BP';
            return true;

        } catch (Exception e) {
            exceptD += '\n exception reqBatch_BP';
            ErrorClass.logError('BatchQueue.reqBatch_0', 'Error: ' + exceptD + '\n' + bp.Name + '__' + System.now() + '\n\n' + Utils.getExceptionInString(e) + '\n\n BP:' + bp);
            return false;
        }
    }

    /*
        reqBatch(......) is used to insert a Batch from code (triggers, apex etc )  in the Batch Queue.
        After a Batch Queue is created, it will be processed as soon as possible by the methods runBatches/executeBatches.
    */
    public static Boolean reqBatch(String code, String className, Integer priority, Integer scope, Id logId, String operation) {
        try {
            BatchQueue__c bqq = new BatchQueue__c();
            Datetime dt = System.now();
            //String stringTime = '' + System.currentTimeMillis();
            do {
                String token = EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(1, 16);
                bqq.Name = code + dt.year() + dt.month() + dt.day() + token;
            } while (BatchQueue__c.getValues(bqq.Name) != null);
            bqq.ClassName__c = className;
            bqq.Priority__c = priority;
            bqq.Scope__c = scope;
            bqq.Id_target__c = logId;
            bqq.operation__c = operation;
            bqq.requested_date_time__c = System.now();
            if (Utils.cebCheckObjPermission('BatchQueue__c',gd).get('INSERT') && Utils.cebCheckFLSPermission('BatchQueue__c', 'scope__c', gd).get('INSERT')
                    && Utils.cebCheckFLSPermission('BatchQueue__c', 'Id_target__c', gd).get('INSERT')
                    && Utils.cebCheckFLSPermission('BatchQueue__c', 'operation__c', gd).get('INSERT')) {
                insert bqq;
            }
            return true;

        } catch (Exception e) {
            ErrorClass.logError('BatchQueue.reqBatch_1', 'Error: ' + className + '__' + System.now() + '__' + logId + '\n\n' + Utils.getExceptionInString(e));
            return false;
        }
    }

    public static Boolean reqBatch(String code, String className, Integer priority, Integer scope, List<Lotto__c> lotti) {
        try {
            String ids = '';
            Integer i = 0;
            List<String> idlist = new List<String>();
            for (Lotto__c l : lotti) {
                idlist.add(l.Id);
                i++;
                if (i == 11) {
                    i = 0;
                    ids = Utils.joinStrings(idlist, ',');
                    reqBatch(code, className, priority, scope, ids, null);
                    idlist = new List<String>();
                }
            }
            return true;
        } catch (Exception e) {
            ErrorClass.logError('BatchQueue - reqBatch1()', 'Error: ' + className + '__' + System.now() + '__' + '\n\n' + Utils.getExceptionInString(e));
            return false;
        }
    }

    public static Boolean reqBatch(String code, String className, Integer priority, Integer scope, String operation, List<Id> lotti) {
        try {
            String ids = '';
            Integer i = 0;
            List<String> idlist = new List<String>();
            for (Id l : lotti) {
                idlist.add(l);
                i++;
                if (i == 11) {
                    i = 0;
                    ids = Utils.joinStrings(idlist, ',');
                    reqBatch(code, className, priority, scope, ids, operation);
                    idlist = new List<String>();
                }
            }
            return true;
        } catch (Exception e) {
            ErrorClass.logError('BatchQueue - reqBatch2()', 'Error: ' + className + '__' + System.now() + '__' + '\n\n' + Utils.getExceptionInString(e));
            return false;
        }
    }

    /*
        The method is used to clean the custom setting BatchQueue having isClosed__c = true; this because the custom setting has a limited size.
    */
    public static void deleteClosedBatches() {
        exceptD += '\n in deleteClosedBatches';
        try {
            // inizio nuovo codice 12/04 inserimento check permission
            if (Utils.cebCheckObjPermission('BatchQueue__c', gd).get('ACCESS')) {
                // fine nuovo codice 12/04 inserimento check permission
                String queryString = 'SELECT ' + Utils.getSOBJECTFieldsForQuery('BatchQueue__c') + ' FROM BatchQueue__c WHERE isClosed__c = TRUE ';

                List<Log__c> logsList = new List<Log__c>();
                logsList.add(ErrorClass.instanceError(true, 'BatchQueue.deleteClosedBatches.Info', 'Sono stati eliminati alcuni elementi dal custom setting BatchQueue'));
                List<BatchQueue__c> bqqList = Database.query(String.escapeSingleQuotes(queryString));
                if (bqqList == null || bqqList.size() == 0) return;
                ErrorClass.checkOPFLSAndUpsertErrorLogs(logsList, 'INSERT', gd);
                //if (Utils.cebCheckFLSPermission('Log__c', 'Error_code__c', gd).get('INSERT')) insert log;
                String debugString = '';
                for (BatchQueue__c bqq : bqqList) {
                    debugString += '\n\n ' + bqq;
                }
                attachDebug(logsList, debugString);

                if (Utils.cebCheckObjPermission('BatchQueue__c', gd).get('DELETE')) {
                    delete bqqList;
                }
            }

        } catch (Exception e) {
            exceptD += '\n exception deleteClosedBatches';
            ErrorClass.logError('BatchQueue - deleteClosedBatches()', 'Error: ' + exceptD + '\n' + System.now() + '__' + '\n\n' + Utils.getExceptionInString(e));
        }
    }

    /* Static method which attaches a string to a log. */
    public static void attachDebug(List<Log__c> logsList, String debugString) {
        for (Log__c log : logsList) {
            exceptD += '\n in attachDebug';
            Attachment att = new Attachment();
            att.Name = 'debug_' + log.Id + '.txt';
            att.Body = Blob.valueOf(debugString + '\n' + exceptD);
            att.ParentId = log.Id;

            if (Utils.cebCheckObjPermission('Attachment',gd).get('INSERT')
                    && Utils.cebCheckFLSPermission('Attachment', 'Name', gd).get('INSERT')
                    && Utils.cebCheckFLSPermission('Attachment', 'Body', gd).get('INSERT')
                    && Utils.cebCheckFLSPermission('Attachment', 'ParentId', gd).get('INSERT')) {
                insert att;
            }
            exceptD += '\n out attachDebug';
        }

    }

}