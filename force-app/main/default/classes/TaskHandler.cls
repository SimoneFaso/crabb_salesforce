/* ---------------------------------------------------------------------------------------------------------------------
Name:            TaskHandler.cls
Description:     Trigger Handler for the Task SObject. This class implements the ITrigger interface to ensure that the
                 trigger code is bulkified and all is in one place.
                 Questa classe gestisce tutta la logica dell'orchestratore legata al task. La lavorazione dei Tasks avviene
                 tramite l'oggetto Ork che contiene e gestisce tutte le logiche e le operazioni che sono legate al trigger.
                 La classe gestisce le seguenti operazioni principali:
                 - setTaskActivity: operazione che viene fatta in creazione del task. A ciascun task viene assegnata un'operazione
                 che il task deve eseguire. Essa dipende dalla tripletta del task che deriva dalla tripletta della strategia.

Test class:      TestTaskHandler.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
06-May-2014  0.1      Klodjan Meta                    First Version
30-Jun-2016  0.2      ESino                           Modified CostoAttivita method
29-Mar-2021  0.3      Giulia Mameli                   AfterUpdate: modified taskMapForCaseInsert Map value to receive
                                                      a concatenation of Task Dossier and Task Subject.
                                                      AfterUpdate: added Nome_Collector_Attivo__c when querying p (Dossier List)
14-Apr-2021  0.4      Giulia Mameli                   AfterInsert: moved createCaseFromStep() invocation here and commended
                                                      in AfterUpdate.
12-May-2021  0.5      M.Sala & M.Siotto               Modified for using ceb methods
02-Sep-2022  0.6      C.Sanna                         Modified After Update to include only task with Type = Credit (CRABB Task)
14-Sep-2022  0.7      C.Sanna & R.Kurti               Added cebCheckObjPermission and WITH SECURITY ENFORCED for security review
----------------------------------------------------------------------------------------------------------------------*/

global with sharing class TaskHandler implements ITrigger {

    public class TaskHandlerException extends Exception {
    }

    Ork ork = new Ork();
    public static Integer limit_the_number_of_trigger_istances = 10;
    public static Integer Count_trigger_instances;
    public static Boolean areLogsActive;
    public static final String CREDITO = 'Credito';

    public static String checkExecution = ''; //variabile presente per debug e conteggiare tutte le esecuzioni effettuate
    public List<Log__c> logL = new List<Log__c>();
    public static String staticString = 'Inizio';
    public static Map<String, List<Id>> serviceToTask;
    public static List<ActivityExtended__c> extTasks = new List<ActivityExtended__c>();
    public static Map<Id, ActivityExtended__c> aes2Obj = new Map<Id, ActivityExtended__c>();
    public static Boolean internalUpdate = false; // commented out 
    global static Boolean isCrabbTriggerOn = false;
    global static Map<String, String> sollecitoMap = new Map<String, String>();
    global static Set<String> PDFTemplateSet = new Set<String>();
    global static Map<String, CRABB_DEV__ManageCaseMapping__mdt> mappingCaseMdtMap = new Map<String, CRABB_DEV__ManageCaseMapping__mdt>();
    global static Map<Id, CRABB_DEV__ActivityExtended__c> aeForTasks = new Map<Id, CRABB_DEV__ActivityExtended__c>();
    global static List<Id> praListforCaseEvt = new List<Id>();
    global static List<Id> praListforSmsEvt = new List<Id>();
    global static List<Id> praListforEmailEvt = new List<Id>();
    global static List<Id> praListforPDFEvt = new List<Id>();
    global static Set<Id> praListforExpectanceEvt = new Set<Id>();
    /*** 20210512 MSala - Review Code - Start ***/
    global static List<CEB__c> lInsertCEB = new List<CEB__c>();
    public static final Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    /*** 20210512 MSala - Review Code - End ***/

    // Constructor
    public TaskHandler() {
        if (Count_trigger_instances == null) Count_trigger_instances = 0;
        if (areLogsActive == null) areLogsActive = TagHelper.getValueBoolean('TaskHandlerLogl');
        //if (extTasks !=null) extTasks.clear();
    }

    /**
     * bulkBefore:This method is called prior the execution of a BEFORE trigger. Use this to cache any data required into maps prior execution of the trigger.
     */
    public void bulkBefore() {
        Count_trigger_instances++;
    }

    public void bulkBefore(List<SObject> soListNew) {
    }

    public void bulkAfter() {
    }

    public void bulkAfter(List<SObject> soListNew) {
        if (!Trigger.isDelete) {
            List<Task> creditoTasks = new List<Task>();
            for (Task tsk : (List<Task>) soListNew) {
                if (tsk.Type == CREDITO) {
                    creditoTasks.add(tsk);
                }
            }

            if (creditoTasks.size() > 0) {
                try {
                    if (CEBUtils.newOrkVersionEnabled()) {
                        /*
                        New Engine Management --
                        - Collezioniamo i record dei custom metadata CRABB_DEV__CRABB_Sollecito__mdt, CRABB_DEV__ManageCaseMapping__mdt e
                        CRABB_DEV__CRABB_PDF_from_Template__mdt che serviranno per le verifiche nell'after insert.
                        - Creiamo una mappa delle activity extended, associate ai nuovi task, per collezionare i field CRABB_DEV__Tipo_Sottotipo__c
                        */
                        List<CRABB_DEV__CRABB_Sollecito__mdt> sollList = [
                                SELECT CRABB_DEV__Tipo_Sottotipo__c, CRABB_DEV__Type__c
                                FROM CRABB_DEV__CRABB_Sollecito__mdt
                                WHERE CRABB_DEV__Active__c = true
                                WITH SECURITY_ENFORCED
                        ];
                        for (CRABB_DEV__CRABB_Sollecito__mdt soll : sollList) {
                            if (!sollecitoMap.containsKey(soll.CRABB_DEV__Tipo_Sottotipo__c)) {
                                sollecitoMap.put(soll.CRABB_DEV__Tipo_Sottotipo__c, soll.CRABB_DEV__Type__c);
                            }
                        }

                        //Boolean isTest = Test.isRunningTest();
                        List<CRABB_DEV__ManageCaseMapping__mdt> mappingCaseMdt = [
                                SELECT Id, DeveloperName, CRABB_DEV__FieldTarget__c, CRABB_DEV__FieldSource__c, CRABB_DEV__StaticValue__c,
                                        CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__Tipo__c, CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__Sottotipo__c, CRABB_DEV__sObjectSource__c
                                FROM CRABB_DEV__ManageCaseMapping__mdt
                                WHERE CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__SourceObject__c = 'ActivityExtended__c'
                                WITH SECURITY_ENFORCED
                        ]; //AND CRABB_DEV__ManageCaseHeader__r.isTest__c = :isTest WITH SECURITY_ENFORCED];

                        for (CRABB_DEV__ManageCaseMapping__mdt mapCase : mappingCaseMdt) {
                            if (!mappingCaseMdtMap.containsKey(mapCase.CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__Tipo__c + ' ' + mapCase.CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__Sottotipo__c)) {
                                mappingCaseMdtMap.put(mapCase.CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__Tipo__c + ' ' + mapCase.CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__Sottotipo__c, mapCase);
                            }
                        }

                        List<CRABB_DEV__CRABB_PDF_from_Template__mdt> PDFTemplateList = [
                                SELECT CRABB_DEV__Tipo_Sottotipo__c
                                FROM CRABB_DEV__CRABB_PDF_from_Template__mdt
                                WHERE CRABB_DEV__Active__c = true
                                WITH SECURITY_ENFORCED
                        ];
                        for (CRABB_DEV__CRABB_PDF_from_Template__mdt pdfTemp : PDFTemplateList) {
                            PDFTemplateSet.add(String.valueOf(pdfTemp.CRABB_DEV__Tipo_Sottotipo__c));
                        }

                    }

                    List<String> actExtIds = new List<String>();
                    if (soListNew != null) {
                        for (Task t : (List<Task>) soListNew) {
                            if (t.ActivityExtended__c != null) {
                                actExtIds.add(t.ActivityExtended__c);
                            }
                        }
                    }

                    aeForTasks = new Map<Id, ActivityExtended__c> ([
                            SELECT Id, Tipo__c, Sotto_Tipo__c, Tipo_Sottotipo__c, Scaduto_iniziale__c
                            FROM ActivityExtended__c
                            WHERE Id IN :actExtIds
                            WITH SECURITY_ENFORCED
                    ]);

                } catch (Exception ex) {
                    logL.add(ErrorClass.istanceError('TaskHandler001', ex.getMessage()));
                }

            }
        }
    }

    public void beforeInsert(List<SObject> soList) {
        //internalUpdate = true;
        checkExecution += '_beforeInsert';
        //extTasks = new List<ActivityExtended__c>();
        for (Task t : (List<Task>) soList) {
            if (t.ActivityExtended__c == null && t.Type == CREDITO) {
                ActivityExtended__c extTask = new ActivityExtended__c();
                extTasks.add(extTask);
            }
        }
        insert extTasks;
        List<ActivityExtended__c> extToCreateCase = new List<ActivityExtended__c>();
        Integer i = 0;
        List<Id> aesIdWeHave = new List<Id>();
        for (Task t : (List<Task>) soList) {
            if (t.ActivityExtended__c == null && t.Type == CREDITO) {
                System.debug('AE Outer: ' + extTasks.get(i));
                t.ActivityExtended__c = extTasks.get(i).Id;
                /*if( String.isNotBlank( extTasks.get(i).Tipo__c ) && String.isNotBlank( extTasks.get(i).Sotto_Tipo__c ))
                {
                    System.debug('AE Inner: ' + extTasks.get(i));
                    extToCreateCase.add(extTasks.get(i));
                }*/
                i++;
            } else if (t.ActivityExtended__c != null && t.Type == CREDITO) {
                aesIdWeHave.add(t.ActivityExtended__c);
            }
        }
        /*System.debug('extToCreateCase: ' + extToCreateCase.size());
        if(extToCreateCase.size()>0)
            CaseUtility.createCaseFromStep(extToCreateCase);*/

        List<ActivityExtended__c> aes2update = new List<ActivityExtended__c>();
        /*** 20210512 MSala - Review Code - Start ***/
        if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Costo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Sotto_tipo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Fase__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Activity__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Tipo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Record_Type__c', gd).get('ACCESS')) {
            Map<Id, ActivityExtended__c> aesWeHave = new Map<Id, ActivityExtended__c>([
                    SELECT Id, Costo__c, Collector__c, Fase__c,
                            Sotto_Tipo__c, Activity__c, RecordTypeId, Tipo__c, Record_Type__c
                    FROM ActivityExtended__c
                    WHERE Id IN :aesIdWeHave
                    //WITH SECURITY_ENFORCED
            ]);
            aes2update.addAll(aesWeHave.values());
        }
        /*if (Utils.checkFLSPermission('ActivityExtended__c', 'Costo__c').get('ACCESS')
                && Utils.checkFLSPermission('ActivityExtended__c', 'Sotto_tipo__c').get('ACCESS')
                && Utils.checkFLSPermission('ActivityExtended__c', 'Fase__c').get('ACCESS')
                && Utils.checkFLSPermission('ActivityExtended__c', 'Activity__c').get('ACCESS')
                && Utils.checkFLSPermission('ActivityExtended__c', 'Tipo__c').get('ACCESS')
                && Utils.checkFLSPermission('ActivityExtended__c', 'Record_Type__c').get('ACCESS')) {
            Map<Id, ActivityExtended__c> aesWeHave = new Map<Id, ActivityExtended__c>([SELECT Id,Costo__c,Collector__c,Fase__c,Sotto_Tipo__c,Activity__c,RecordTypeId,Tipo__c,Record_Type__c FROM ActivityExtended__c WHERE Id IN :aesIdWeHave]);

            aes2update.addAll(aesWeHave.values());
        }*/
        /*** 20210512 MSala - Review Code - End ***/

        aes2update.addAll(extTasks);
        //List<ActivityExtended__c> aesfinal = setRecordTypeForStandardTasks((List<ActivityExtended__c> )aes2update);
        /*** 20210512 MSala - Review Code - Start ***/
        if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Fase__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Tipo__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Sotto_tipo__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Activity__c', gd).get('UPDATE')) {
            update setTaskActivity((List<ActivityExtended__c>) aes2update);
        }
        /*if (Utils.checkFLSPermission('ActivityExtended__c', 'Fase__c').get('UPDATE')
                && Utils.checkFLSPermission('ActivityExtended__c', 'Tipo__c').get('UPDATE')
                && Utils.checkFLSPermission('ActivityExtended__c', 'Sotto_tipo__c').get('UPDATE')
                && Utils.checkFLSPermission('ActivityExtended__c', 'Activity__c').get('UPDATE')
                ) update setTaskActivity((List<ActivityExtended__c>) aes2update);*/
        /*** 20210512 MSala - Review Code - End ***/
        //CostoAttivita((List<ActivityExtended__c> )aes.values());
        System.debug('\n Il task da inserire a DB: ' + (List<Task>) soList);

        //setRecordTypeForStandardTasks((List<Task> )soList);
        //setTaskActivity((List<Task> )soList);
        //CostoAttivita((List<Task> )soList);

        //MSALA 20200608
        //System.debug('extToCreateCase: ' + extToCreateCase.size());
        //if(aes2update.size()>0)
        //    CaseUtility.createCaseFromStep(aes2update);
    }

    /*** MSala - Costo Attività ***/
    /*
    *   ESino, 30/06/2016:
    *
    *   Modificata la logica della scrittura del costo:
    *   - La chiave "Key", deve essere condizionata dal fatto che il WhatId del
    *   task sia nella mappa o meno, perché altrimenti scatta l'errore Null Pointer Exception.
    */
    /*public void CostoAttivita(List<Task> soList) {
        List<String> lIdPrat = new List<String>();
        List<CostoAttivita__c> lCA = CostoAttivita__c.getall().values();
        Map<String, Decimal> mCA = new Map<String, Decimal>();
        aes2Obj = Utils.getTaskWithActivityExtended(soList);
        for (CostoAttivita__c ca : lCA) {
            String s = ca.Collector__c + '_' + ca.Tipo_Sottotipo__c;
            mCA.put(s, ca.Costo__c);
        }

        for (Task t : soList) {
            lIdPrat.add(String.ValueOf(t.WhatId));
        }

        Map<String, Pratica__c> mPrat = new Map<String, Pratica__c>([Select Id, Nome_Collector_Attivo__c from Pratica__c where Id IN :lIdPrat]);
        List<ActivityExtended__c> aeuplist = new List<ActivityExtended__c>();
        *//*** 20210512 MSala - Review Code - Start ***//*
        //if (Utils.checkFLSPermission('ActivityExtended__c', 'Collector__c').get('UPDATE') && Utils.checkFLSPermission('ActivityExtended__c', 'Costo__c').get('UPDATE'))
        if (Utils.cebCheckFLSPermission('ActivityExtended__c', 'Collector__c',gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Costo__c',gd).get('UPDATE'))
        *//*** 20210512 MSala - Review Code - End ***//*
        {
            for (Task t : soList) {
                String taskParentId = String.ValueOf(t.WhatId), key = null, KeyAll;
                ActivityExtended__c ae = aes2Obj.get(t.Id);
                if (ae != null) {
                    if (mPrat.containsKey(taskParentId)) {
                        if (mPrat.get(taskParentId).Nome_Collector_Attivo__c != null && String.isNotBlank(mPrat.get(taskParentId).Nome_Collector_Attivo__c)) {
                            ae.Collector__c = mPrat.get(taskParentId).Nome_Collector_Attivo__c;
                            Key = mPrat.get(taskParentId).Nome_Collector_Attivo__c + '_' + t.Subject;
                        } else {
                            Key = 'All_' + t.Subject;
                        }
                    }

                    KeyAll = 'All_' + t.Subject;

                    if (Key != null && mCA.get(Key) != null) {
                        ae.Costo__c = mCA.get(Key);
                    } else if (mCA.get(KeyAll) != null) {
                        ae.Costo__c = mCA.get(KeyAll);
                    } else {
                        ae.Costo__c = 0.0;
                    }
                    aeuplist.add(ae);
                }
            }

            *//*** 20210512 MSala - Review Code - Start ***//*
            //if (Utils.checkObjPermission('ActivityExtended__c').get('ACCESS') && Utils.checkObjPermission('ActivityExtended__c').get('INSERT')) {
            if (Utils.cebCheckObjPermission('ActivityExtended__c',gd).get('ACCESS')
                    && Utils.cebCheckObjPermission('ActivityExtended__c',gd).get('INSERT'))
            *//*** 20210512 MSala - Review Code - End ***//*
            {
                update aeuplist;
            }
        }
    }*/


    /*  Questa parte di codice definisce per quali task si effettua un update per procedere con le attività e l'esecuzione dei next steps.
        Si sceglie di effettuare un update post insert per evitare problemi legati alla mancanza degli id per i record 
        e problemi di gestione di attività legate a record che non sono ancora salvati su database.
    */
    public void afterInsert(List<SObject> soList) {
        //Gestione per l'associazione dei task con Affidamento
        //throw new Utils.BalanceException('extTasksRRR:'+extTasks);
        List<String> actExtIds = new List<String>();
        Integer i = 0;
        List<Task> tList = new List<Task>();
        for (Task t : (List<Task>) soList) {
            if (t.ActivityExtended__c == null && t.Type == CREDITO) {
                t.ActivityExtended__c = extTasks.get(i).Id;

                i++;
            } else if (t.ActivityExtended__c != null && t.Type == CREDITO) {
                actExtIds.add(t.ActivityExtended__c);
            }
        }

        /*** 20210512 MSala - Review Code - Start ***/
        //if (tList.size() > 0 && Utils.checkFLSPermission('Task', 'Status').get('UPDATE')) update tList;
        if (tList.size() > 0
                && Utils.cebCheckObjPermission('Task', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Task', 'Status', gd).get('UPDATE')) {
            update tList;
        }
        /*** 20210512 MSala - Review Code - End ***/
        /*setTaskActivity((List<Task> )soList);*/
        //CostoAttivita((List<Task> )soList);   
        /*setRecordTypeForStandardTasks((List<Task> )soList);*/
        /*** 20210512 MSala - Code Review - Start ***/
        //associaTaskAffidamento((List<Task>) soList);
        cebAssociaTaskAffidamento((List<Task>) soList, gd);
        /*** 20210512 MSala - Code Review - End ***/
        if (Count_trigger_instances >= limit_the_number_of_trigger_istances) {
            System.debug('ERROR --> max limit of number of trigger reached:' + Count_trigger_instances + ' limit is:' + limit_the_number_of_trigger_istances);
            logL.add(errorClass.istanceError('Task After Insert trigger ' + Count_trigger_instances, ' limit is:' + limit_the_number_of_trigger_istances));
            return;
        }//Verifica se il trigger ha eseguito il numero massimo di istances
        tList.clear();
        String statusToUpdate = TagHelper.getValueText('TaskInsertStatusToUpdate');
        Set<String> statusValues = Utils.sliptString(statusToUpdate, ',');
        checkExecution += '_afterInsert';
        for (Task t : (List<Task>) soList) {
            if (statusValues != null && statusValues.contains(t.Status)) {
                tList.add(new Task(Id = t.Id, Status = t.Status));
            }
            if (t.Status == 'Revocata')
                System.debug('\n Task Revocata After Insert: ' + t.Status);
        }


        /*** 20210512 MSala - Review Code - Start ***/
        //if (tList.size() > 0 && Utils.checkFLSPermission('Task', 'Status').get('UPDATE')) update tList;
        if (tList.size() > 0
                && Utils.cebCheckObjPermission('Task', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Task', 'Status', gd).get('UPDATE')) {
            update tList;
        }
        /*** 20210512 MSala - Review Code - End ***/

        //Map<Id, CRABB_DEV__ActivityExtended__c> aeForTasks;
        //aeForTasks = new Map<Id, ActivityExtended__c>([SELECT Id, Tipo__c, Sotto_Tipo__c, Tipo_Sottotipo__c, Scaduto_iniziale__c FROM ActivityExtended__c WHERE Id IN :actExtIds]);
        //System.debug('After Insert aeForTasks --> ' + aeForTasks);

        //Case creation
        Set<Id> pratIdList = new Set<Id>();
        Map<String, String> taskMapForCaseInsert = new Map<String, String>();
        List<ActivityExtended__c> actToCreateCase = new List<ActivityExtended__c>();
        //Map<Id, ActivityExtended__c> mapTaskActEx = Utils.getTaskWithActivityExtended(soList);
        //Build taskActExMap Map with Task Id as key and Activity Extended (Id, Tipo, Sottotipo as value)
        Map<Id, ActivityExtended__c> taskActExMap = new Map<Id, ActivityExtended__c>();
        for (Task tsk : (List<Task>) soList) {
            if (!aeForTasks.isEmpty()) {
                taskActExMap.put(tsk.Id, aeForTasks.get(tsk.ActivityExtended__c));
            }
        }

        for (Task tsk : (List<Task>) soList) {
            pratIdList.add(tsk.WhatId);
            String dossierIdSubject = tsk.WhatId + '~' + tsk.Subject;
            taskMapForCaseInsert.put(tsk.ActivityExtended__c, dossierIdSubject);
            if (!taskActExMap.isEmpty()) {
                ActivityExtended__c act = taskActExMap.get(tsk.Id);
                //If related Activity Extended has Tipo__c and Sotto_Tipo__c mapped in Manage Case Header
                //and Task Status is 'Non Iniziata', then the Activity Extended is added to the list for creating a Case
                if (act != null && act.Tipo__c != null && act.Sotto_Tipo__c != null && 'NON INIZIATA'.equalsIgnoreCase(tsk.Status)) {
                    actToCreateCase.add(act);
                }
            }
        }

        //Old engine management
        /*if (actToCreateCase.size() > 0) {
            CaseUtility.createCaseFromStep(actToCreateCase, pratIdList, taskMapForCaseInsert);
        }*/

        /*
        New Engine Management - Per ogni nuovo Task che passa per l'afterInsert si verifica se il task ha un
        Activity Extended con tipo_sottotipo uguale al tipo sotto_tipo dei custom metadata associati
        */
        if (CEBUtils.newOrkVersionEnabled()
                && Utils.cebCheckObjPermission('CEB__c', gd).get('ACCESS')
                && Utils.cebCheckObjPermission('CEB__c', gd).get('INSERT')) {
            System.debug('afterInserts CEBUtils.newOrkVersionEnabled() --> Enabled');
            for (Task t : (List<Task>) soList) {
                System.debug(' afterInserts for each task');
                String tiposottotipo = aeForTasks.containsKey(t.CRABB_DEV__ActivityExtended__c) ? aeForTasks.get(t.CRABB_DEV__ActivityExtended__c).CRABB_DEV__Tipo_Sottotipo__c : null;
                System.debug('afterInserts tiposottotipo --> ' + tiposottotipo);
                if (String.isNotBlank(tiposottotipo)) {
                    System.debug('afterInserts tiposottotipo not blank');
                    if (actToCreateCase.size() > 0) {
                        //if new version enabled, create an event
                        System.debug('tiposottotipo: ' + tiposottotipo);
                        System.debug('t.what.type: ' + t.What.type);
                        if (mappingCaseMdtMap.containsKey(tiposottotipo) && (CREDITO.equalsIgnoreCase(t.Type) || 'Pratica__c'.equalsIgnoreCase(t.type))) {
                            /*** 20210509 MSala - List of CEB with all fields - Start ***/

                            CEB__c c = new CEB__c(
                                    ActivityExtended__c = t.ActivityExtended__c,
                                    Immediate_Action__c = true,
                                    Pratica__c = t.WhatId,
                                    Status__c = 'New',
                                    Type__c = 'NCA'
                            );
                            lInsertCEB.add(c);

                            //praListforCaseEvt.add(t.WhatId);
                            /*** 20210509 MSala - List of CEB with all fields - End ***/
                        }
                    }

                    if (sollecitoMap.containsKey(tiposottotipo) && (CREDITO.equalsIgnoreCase(t.Type) || CREDITO.equalsIgnoreCase(t.type))) {
                        if ('SMS'.equalsIgnoreCase(sollecitoMap.get(tiposottotipo))) {
                            /*** 20210509 MSala - List of CEB with all fields - Start ***/

                            CEB__c c = new CEB__c(
                                    ActivityExtended__c = t.ActivityExtended__c,
                                    Immediate_Action__c = true,
                                    Pratica__c = t.WhatId,
                                    Status__c = 'New',
                                    Type__c = 'SMS'
                            );
                            lInsertCEB.add(c);

                            //praListforSmsEvt.add(t.WhatId);
                            /*** 20210509 MSala - List of CEB with all fields - End ***/
                        } else if ('EMAIL'.equalsIgnoreCase(sollecitoMap.get(tiposottotipo)) || 'MAILUP'.equalsIgnoreCase(sollecitoMap.get(t.CRABB_DEV__ActivityExtended__r.CRABB_DEV__Tipo_Sottotipo__c))) {
                            /*** 20210509 MSala - List of CEB with all fields - Start ***/

                            CEB__c c = new CEB__c(
                                    ActivityExtended__c = t.ActivityExtended__c,
                                    Immediate_Action__c = true,
                                    Pratica__c = t.WhatId,
                                    Status__c = 'New',
                                    Type__c = 'SEM'
                            );
                            lInsertCEB.add(c);

                            //praListforEmailEvt.add(t.WhatId);
                            /*** 20210509 MSala - List of CEB with all fields - End ***/
                        }
                    }

                    if (PDFTemplateSet.contains(tiposottotipo)) {
                        System.debug('afterInserts Creation of CEB PDF ');
                        /*** 20210509 MSala - List of CEB with all fields - Start ***/

                        CEB__c c = new CEB__c(
                                ActivityExtended__c = t.ActivityExtended__c,
                                Immediate_Action__c = true,
                                Pratica__c = t.WhatId,
                                Status__c = 'New',
                                Type__c = 'PDF'
                        );
                        lInsertCEB.add(c);

                        //praListforPDFEvt.add(t.WhatId);
                        /*** 20210509 MSala - List of CEB with all fields - End ***/
                    }
                }
                if (t.Record_Type__c == 'Expectance') {
                    /*** 20210509 MSala - List of CEB with all fields - Start ***/

                    CEB__c c = new CEB__c(
                            ActivityExtended__c = t.ActivityExtended__c,
                            Immediate_Action__c = false,
                            Pratica__c = t.WhatId,
                            Status__c = 'New',
                            Type__c = 'WAI'
                    );
                    lInsertCEB.add(c);

                    System.debug('EXPECTANCE What Id --> ' + t.WhatId + ' Task Id --> ' + t.id);
                    //praListforExpectanceEvt.add(t.WhatId);
                    /*** 20210509 MSala - List of CEB with all fields - End ***/
                }
            }
        } else {
            //Old engine management
            if (actToCreateCase.size() > 0) {
                CaseUtility.createCaseFromStep(actToCreateCase, pratIdList, taskMapForCaseInsert);
            }
        }
    }

    /*  In before i Tasks vengono processati attraverso l'oggetto Ork()
        a cui viene passata la lista di Tasks trigger old e trigger new.
        Tutte le logiche sono presenti nelle classi associate "Ork"
    */
    public void beforeUpdate(List<SObject> oldSo, List<SObject> so) {
        if (Count_trigger_instances >= limit_the_number_of_trigger_istances) {
            System.debug('We reached max trigger instances, current instances:' + Count_trigger_instances + ' limit:' + limit_the_number_of_trigger_istances);
            //throw new Utils.BalanceException('We reached max trigger instances, current instances:'+Count_trigger_istances+' limit:'+limit_the_number_of_trigger_istances);
            logL.add(ErrorClass.istanceError('Task After Insert trigger ' + Count_trigger_instances, ' limit is:' + limit_the_number_of_trigger_istances));
            return; //Verifica se il trigger ha eseguito il numero massimo di istances
        }//if (internalUpdate) return;
        checkExecution += '_beforeUpdate';
        //throw new Utils.BalanceException('QUI new tasks:'+so+' OLD tasks:'+oldSo);
        /* MSala 20170502 - INIZIO */
        List<SObject> soCredito = new List<SObject>();
        List<SObject> OldSoCredito = new List<SObject>();
        for (Task t1 : (List<Task>) so) {
            if (t1.Type == CREDITO) {
                System.debug('beforeUpdate task new status --> ' + t1.Status);
                soCredito.add(t1);
            }
        }
        for (Task t2 : (List<Task>) oldSo) {
            if (t2.Type == CREDITO) {
                System.debug('beforeUpdate task old status --> ' + t2.Status);
                OldSoCredito.add(t2);
            }
        }
        if (!CEBUtils.newOrkVersionEnabled())
            ork.execute('Task_beforeUpdate', soCredito, OldSoCredito);
        //o.execute('Task_beforeUpdate',so, oldSo);
        /* MSala 20170502 - FINE */
    }

    public void afterUpdate(List<SObject> oldSo, List<SObject> so) {

        //Test Simone per update ultima attivita ed esiti
        if (Count_trigger_instances >= limit_the_number_of_trigger_istances) {
            System.debug('We reached max trigger instances, current instances:' + Count_trigger_instances + ' limit:' + limit_the_number_of_trigger_istances);
            //throw new Utils.BalanceException('We reached max trigger instances, current instances:'+Count_trigger_istances+' limit:'+limit_the_number_of_trigger_istances);
            logL.add(ErrorClass.istanceError('Task After Update trigger ' + Count_trigger_instances, ' limit is:' + limit_the_number_of_trigger_istances));
            return; //Verifica se il trigger ha eseguito il numero massimo di istances
        }//if (internalUpdate) return;
        checkExecution += '_afterUpdate';

        List<Task> oldTaskList = (List<Task>) oldSo;
        List<Task> newTaskList = (List<Task>) so;
        Map<Id, Task> mapidtask = new Map<Id, Task>();
        Set<Id> pratIdList = new Set<Id>();
        Map<String, String> taskMapForCaseInsert = new Map<String, String>();
        for (Task t : newTaskList) {
            /*pratIdList.add(t.WhatId);
            mapidtask.put(t.WhatId, t);
            String dossierIdSubject = t.WhatId + '~' + t.Subject;
            taskMapForCaseInsert.put(t.ActivityExtended__c, dossierIdSubject);*/
            if (t.Type == CREDITO) {
                pratIdList.add(t.WhatId);
                mapidtask.put(t.WhatId, t);
                String dossierIdSubject = t.WhatId + '~' + t.Subject;
                taskMapForCaseInsert.put(t.ActivityExtended__c, dossierIdSubject);
            }
        }
        //Map<Id, ActivityExtended__c> maptaskae = Utils.cebGetTaskWithActivityExtended(newTaskList, gd);
        Map<Id, ActivityExtended__c> maptaskae = new Map<Id, ActivityExtended__c>();
        if (mapidtask.size() > 0) {
            maptaskae = Utils.cebGetTaskWithActivityExtended(newTaskList, gd);
        }
        System.debug('DEBUG 530: ' + newTaskList + ' - ' + maptaskae);
        List<Pratica__c> toUpdate = new List<Pratica__c>();
        List<ActivityExtended__c> actUpdate = new List<ActivityExtended__c>();
        //Map<Id, ActivityExtended__c> mapPraticaAE = Utils.getPraticaWithActivityExtended(newTaskList);

        List<CostoAttivita__c> lCA = CostoAttivita__c.getall().values();
        Map<String, Decimal> mCA = new Map<String, Decimal>();
        for (CostoAttivita__c ca : lCA) {
            String s = ca.Collector__c + '_' + ca.Tipo_Sottotipo__c;
            mCA.put(s, ca.Costo__c);
        }

        String Key = '';
        String KeyAll = '';
        List<ActivityExtended__c> actToCreateCase = new List<ActivityExtended__c>();

        if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Pratica__c', 'Data_Ultima_Attivit__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Pratica__c', 'Esito_Ultima_Attivit_Completata__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Pratica__c', 'Data_Attivit_in_Lavorazione__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Pratica__c', 'Ultima_Attivita__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Pratica__c','Ultima_Attivit__c',gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Pratica__c', 'Data_Ultima_Attivit__c', gd).get('UPDATE') &&
                Utils.cebCheckFLSPermission('Pratica__c', 'TipoStrategia__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Pratica__c', 'Residuo_Totale__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Pratica__c', 'Account__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Pratica__c', 'Nome_Collector_Attivo__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Pratica__c', 'Fase_Ultima_Attivit_Completata__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Pratica__c', 'Esito_Ultima_Attivit_Completata__c', gd).get('UPDATE') &&
                Utils.cebCheckFLSPermission('Pratica__c', 'Ultima_Attivita__c', gd).get('UPDATE') &&
                Utils.cebCheckFLSPermission('Pratica__c', 'Fase_Ultima_Attivit_Completata__c', gd).get('UPDATE')) {

            for (Pratica__c p : [
                    SELECT Id, Data_Ultima_Attivit__c, Esito_Ultima_Attivit_Completata__c, Data_Attivit_in_Lavorazione__c, Ultima_Attivita__c,
                            Ultima_Attivit__c, TipoStrategia__c, Residuo_Totale__c, Account__c, Account__r.Name, Nome_Collector_Attivo__c
                    FROM Pratica__c
                    WHERE Id IN :pratIdList
                    //WITH SECURITY_ENFORCED
            ]) {

                Task t = mapidtask.get(p.Id);

                /*** 20210512 MSala - Review Code - Start ***/
                /*if (Utils.checkFLSPermission('Pratica__c', 'Data_Ultima_Attivit__c').get('ACCESS') &&
                        Utils.checkFLSPermission('Pratica__c', 'Esito_Ultima_Attivit_Completata__c').get('ACCESS') &&
                        Utils.checkFLSPermission('Pratica__c', 'Ultima_Attivita__c').get('ACCESS') &&
                        Utils.checkFLSPermission('Pratica__c', 'Fase_Ultima_Attivit_Completata__c').get('ACCESS') &&
                        Utils.checkFLSPermission('Pratica__c', 'Data_Ultima_Attivit__c').get('UPDATE') &&
                        Utils.checkFLSPermission('Pratica__c', 'Esito_Ultima_Attivit_Completata__c').get('UPDATE') &&
                        Utils.checkFLSPermission('Pratica__c', 'Ultima_Attivita__c').get('UPDATE') &&
                        Utils.checkFLSPermission('Pratica__c', 'Fase_Ultima_Attivit_Completata__c').get('UPDATE'))*/
//            if (Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS') &&
//                    Utils.cebCheckFLSPermission('Pratica__c', 'Data_Ultima_Attivit__c', gd).get('ACCESS') &&
//                    Utils.cebCheckFLSPermission('Pratica__c', 'Esito_Ultima_Attivit_Completata__c', gd).get('ACCESS') &&
//                    Utils.cebCheckFLSPermission('Pratica__c', 'Ultima_Attivita__c', gd).get('ACCESS') &&
//                    Utils.cebCheckFLSPermission('Pratica__c', 'Fase_Ultima_Attivit_Completata__c', gd).get('ACCESS') &&
//                    Utils.cebCheckFLSPermission('Pratica__c', 'Data_Ultima_Attivit__c', gd).get('UPDATE') &&
//                    Utils.cebCheckFLSPermission('Pratica__c', 'Esito_Ultima_Attivit_Completata__c', gd).get('UPDATE') &&
//                    Utils.cebCheckFLSPermission('Pratica__c', 'Ultima_Attivita__c', gd).get('UPDATE') &&
//                    Utils.cebCheckFLSPermission('Pratica__c', 'Fase_Ultima_Attivit_Completata__c', gd).get('UPDATE'))
//            /*** 20210512 MSala - Review Code - End ***/ {


                if (t.Status.equalsIgnoreCase('Completata') || t.Status.equalsIgnoreCase('Saltata') || t.Status.equalsIgnoreCase('Revocata')) {
                    System.debug('DEBUG 575 IF: ' + newTaskList + ' - ' + maptaskae + ' - ' + t.Id);
                    p.Data_Ultima_Attivit__c = (maptaskae.get(t.Id).Data_chiusura__c == null || t.LastModifiedDate >= maptaskae.get(t.Id).Data_chiusura__c) ? t.LastModifiedDate.date() : (maptaskae.get(t.Id).Data_chiusura__c.date() != null) ? maptaskae.get(t.Id).Data_chiusura__c.date() : null;
                    p.Esito_Ultima_Attivit_Completata__c = maptaskae.get(t.Id).Esito__c;
                    p.Ultima_Attivita__c = maptaskae.get(t.Id).Tipo_Sottotipo__c;
                    p.Fase_Ultima_Attivit_Completata__c = maptaskae.get(t.Id).Fase__c;
                } else {
                    System.debug('DEBUG 581 ELSE: ' + newTaskList + ' - ' + maptaskae + ' - ' + t.Id);
                    p.Esito_Ultima_Attivit_in_Lavorazione__c = maptaskae.get(t.Id).Esito__c;
                    p.Data_Attivit_in_Lavorazione__c = (maptaskae.get(t.Id).Data_chiusura__c == null || t.LastModifiedDate >= maptaskae.get(t.Id).Data_chiusura__c) ? t.LastModifiedDate.date() : (maptaskae.get(t.Id).Data_chiusura__c.date() != null) ? maptaskae.get(t.Id).Data_chiusura__c.date() : null;
                    p.Ultima_Attivit__c = maptaskae.get(t.Id).Tipo_Sottotipo__c;
                    p.Fase_Ultima_Attivit_in_Lavorazione__c = maptaskae.get(t.Id).Fase__c;
                }

                toUpdate.add(p);


                ActivityExtended__c act = maptaskae.get(t.Id);
                if (act != null && act.Creata_Manualmente__c != null && act.Creata_Manualmente__c.equalsIgnoreCase('TRUE') && t.Status != null && t.Status.equalsIgnoreCase('Completata')) {
                    /*** 20210512 MSala - Review Code - Start ***/
                    /*if (Utils.checkFLSPermission('ActivityExtended__c', 'Data_Chiusura__c').get('ACCESS') &&
                            Utils.checkFLSPermission('ActivityExtended__c', 'Scaduto_finale__c').get('ACCESS') &&
                            Utils.checkFLSPermission('ActivityExtended__c', 'Data_Chiusura__c').get('UPDATE') &&
                            Utils.checkFLSPermission('ActivityExtended__c', 'Scaduto_finale__c').get('UPDATE'))*/
                    if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('ACCESS') &&
                            Utils.cebCheckFLSPermission('ActivityExtended__c', 'Data_Chiusura__c', gd).get('ACCESS') &&
                            Utils.cebCheckFLSPermission('ActivityExtended__c', 'Scaduto_finale__c', gd).get('ACCESS') &&
                            Utils.cebCheckFLSPermission('ActivityExtended__c', 'Data_Chiusura__c', gd).get('UPDATE') &&
                            Utils.cebCheckFLSPermission('ActivityExtended__c', 'Scaduto_finale__c', gd).get('UPDATE'))
                    /*** 20210512 MSala - Review Code - End ***/ {

                        act.Data_chiusura__c = System.now();
                        act.Scaduto_finale__c = p.Residuo_Totale__c;

                    }
                }

                /*** 20210512 MSala - Review Code - Start ***/
                //if (Utils.checkFLSPermission('ActivityExtended__c', 'Collector__c').get('UPDATE') && Utils.checkFLSPermission('ActivityExtended__c', 'Costo__c').get('UPDATE'))
                if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                        && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Collector__c', gd).get('UPDATE')
                        && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Costo__c', gd).get('UPDATE'))
                /*** 20210512 MSala - Review Code - End ***/ {
                    if (act != null) {
                        if (p.Nome_Collector_Attivo__c != null && String.isNotBlank(p.Nome_Collector_Attivo__c)) {
                            act.Collector__c = p.Nome_Collector_Attivo__c;
                            Key = p.Nome_Collector_Attivo__c + '_' + t.Subject;
                        } else {
                            Key = 'All_' + t.Subject;
                        }

                        KeyAll = 'All_' + t.Subject;

                        if (Key != null && mCA.get(Key) != null) {
                            act.Costo__c = mCA.get(Key);
                        } else if (mCA.get(KeyAll) != null) {
                            act.Costo__c = mCA.get(KeyAll);
                        } else {
                            act.Costo__c = 0.0;
                        }

                        act.Account_id__c = p.Account__c;
                        act.Account_name__c = p.Account__r.Name;

                        actUpdate.add(act);
                    }
                }
                if (act != null && act.Tipo__c != null && act.Sotto_Tipo__c != null && 'NON INIZIATA'.equalsIgnoreCase(t.Status)) {
                    actToCreateCase.add(act);
                }
            }
        }

        /* Old engine management
        if (actToCreateCase.size() > 0) {
            CaseUtility.createCaseFromStep(actToCreateCase, pratIdList, taskMapForCaseInsert);
        }*/

        /*** 20210512 MSala - Review Code - Start ***/
        //if (toUpdate != null && !toUpdate.isEmpty() && Utils.checkObjPermission('Pratica__c').get('ACCESS') && Utils.checkObjPermission('Pratica__c').get('UPDATE'))
        if (toUpdate != null
                && !toUpdate.isEmpty() && Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckObjPermission('Pratica__c', gd).get('UPDATE'))
        /*** 20210512 MSala - Review Code - End ***/ {
            update toUpdate;
        }

        if (actUpdate != null && !actUpdate.isEmpty()) {
            /*** 20210512 MSala - Review Code - Start ***/
            //if (Utils.checkObjPermission('ActivityExtended__c').get('UPDATE') && Utils.checkObjPermission('ActivityExtended__c').get('ACCESS'))
            if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                    && Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('ACCESS'))
            /*** 20210512 MSala - Review Code - End ***/ {
                update actUpdate;
            }
        }
    }

    public void beforeDelete(List<SObject> so) {
    }

    public void afterDelete(List<SObject> so) {
    }

    public void andFinally() {
        /*** 20210512 MSiotto - Review Code - Start ***/
        /*if (areLogsActive)
        {
            logL.add(errorClass.istanceError('TaskFinally_execution ' + Count_trigger_istances, checkExecution + '\n limits:' + Utils.getLimits()));
            if (Utils.checkObjPermission('Log__c').get('UPDATE')
                    && Utils.checkObjPermission('Log__c').get('INSERT')
                    && Utils.checkFLSPermission('Log__c', 'Type__c').get('UPSERT')
                    && Utils.checkFLSPermission('Log__c', 'Message__c').get('UPSERT')
                    && Utils.checkFLSPermission('Log__c', 'Info__c').get('UPSERT')
                    && Utils.checkFLSPermission('Log__c', 'Name__c').get('UPSERT')
                    && Utils.checkFLSPermission('Log__c', 'recordtypeid').get('UPSERT')
                    && Utils.checkFLSPermission('Log__c', 'Error__c').get('UPSERT')
                    && Utils.checkFLSPermission('Log__c', 'Error_code__c').get('UPSERT')) upsert logL;
        }*/

        if (areLogsActive) {
            logL.add(errorClass.istanceError('TaskFinally_execution ' + Count_trigger_instances, checkExecution + '\n limits:' + Utils.getLimits()));
            if (Utils.cebCheckObjPermission('Log__c', gd).get('UPDATE')
                    && Utils.cebCheckObjPermission('Log__c', gd).get('INSERT')
                    && Utils.cebCheckFLSPermission('Log__c', 'Type__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Log__c', 'Message__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Log__c', 'Info__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Log__c', 'Name__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Log__c', 'recordtypeid', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Log__c', 'Error__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Log__c', 'Error_code__c', gd).get('UPSERT')) {
                upsert logL;
            }
        }
        /*** 20210512 MSiotto - Review Code - End ***/

        //internalUpdate = false;
        if (CEBUtils.newOrkVersionEnabled()
                && Utils.cebCheckObjPermission('CEB__c', gd).get('ACCESS')
                && Utils.cebCheckObjPermission('CEB__c', gd).get('INSERT')) {
            /*** 20210509 MSala - List of CEB with all fields - Start ***/
            if (lInsertCEB.size() > 0) {
                System.debug('lInsertCEB: ' + lInsertCEB);
                insert lInsertCEB;
                lInsertCEB.clear();
            }

            /*** 20210509 MSala - List of CEB with all fields - End ***/
        }
    }

    /*Questo metodo assegna il recordType ai task Standard in quanto il layout standard dei task non
      prevede l'assegnazione d

    */
    // DEPRECATED : We are using a Custom Object as a Task Extension
    private List<ActivityExtended__c> setRecordTypeForStandardTasks(List<ActivityExtended__c> soList) {
        Map<String, Schema.RecordTypeInfo> NameIdTasksRecordTyepesMap = Schema.SObjectType.ActivityExtended__c.getRecordTypeInfosByName();
        String StandardRecordTypeID = NameIdTasksRecordTyepesMap.get('Standard').getRecordTypeID();
        for (ActivityExtended__c t : soList)
            t.recordTypeid = StandardRecordTypeID;
        return soList;

    }

    /*  Metodo utilizzato per definire quale attività dovrà eseguire il task che è stato creato.
        Esso recupera le configurazioni da Orch_activity_control__c e ricerca un'attività per il task creato.
    */
    private List<ActivityExtended__c> setTaskActivity(List<ActivityExtended__c> activitiesWithTasks) {
        //List<Task> tlist = new List<Task>();
        Map<String, String> tokenActivity = new Map<String, String>();
        String token;
        //crea la mappa delle attività da associare
        Map<String, Orch_activity_control__c> oac = Orch_activity_control__c.getAll();
        for (Orch_activity_control__c o : oac.Values()) {
            tokenActivity.put(o.Fase__c + '_' + o.Tipo_attivita__c + '_' + o.Sotto_tipo_attivita__c, o.Activity__c);
        }
        //popola l'attività solo per i task che devono averla
        //Map<Id,ActivityExtended__c> aes2Obj = Utils.getTaskWithActivityExtended(tasksList);
        for (ActivityExtended__c actExt : activitiesWithTasks) {
            System.debug('actExt Fase + Tipo + Sottotipo --> ' + actExt.Fase__c + ' - ' + actExt.Tipo__c + ' - ' + actExt.Sotto_Tipo__c + ' - ' + actExt.Activity__c);
            if (actExt.Fase__c != null && actExt.Tipo__c != null && actExt.Sotto_Tipo__c != null && (actExt.Activity__c == null || actExt.Activity__c == '')) {
                token = actExt.Fase__c + '_' + actExt.Tipo__c + '_' + actExt.Sotto_Tipo__c;
                actExt.Activity__c = tokenActivity.get(token);
            }
        }
        return activitiesWithTasks;
    }

    private static void associaTaskAffidamento(List<Task> tList) {
        List<Affidamento__c> aList = new List<Affidamento__c>();
        List<Log__c> logL = new List<Log__c>();
        /*Log__c l = new Log__c();
        l.Error_code__c = 'associaTaskAffidamento Inizio';
        insert l;*/
        Date mydate;
        for (Task t : tlist) {
            if (!t.ActivityExtended__r.E_da_affidare__c) {
                /*l = new Log__c();
                l.Error_code__c = 'Da Affidare False: ' + t.Subject;
                l.Error__c = 'Da Affidare False: ' + t.ActivityExtended__r.id_affidamento__c;
                insert l;*/

                continue;
            }
            if (t.ActivityExtended__r.id_affidamento__c == null) {
                /*l = new Log__c();
                l.Error_code__c = 'Affidamento null';
                insert l;*/

                continue;
            }

            Affidamento__c aff = new Affidamento__c();
            mydate = System.today();
            aff.Id = t.ActivityExtended__r.id_affidamento__c;
            aff.Data_fine_affidamento_prevista__c = mydate.addDays(Integer.valueOf(t.SLA__c));
            //a.Data_fine_affidamento_prevista__c=mydate.addDays(integer.valueof(t.ActivityExtended__r.SLA__c));
            aff.ID_task_target_revoca__c = t.Id;
            aList.add(aff);
        }

        if (logl.size() > 0) insert logl;
        /*
        if (Utils.checkFLSPermission('Affidamento__c', 'Data_Affidamento__c').get('UPDATE')
                && Utils.checkFLSPermission('Affidamento__c', 'ID_task_target_revoca__c').get('UPDATE')
                ) update aList;
         */
        if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'ID_task_target_revoca__c', gd).get('UPDATE')) {
            update aList;
        }
    }

    /*** 20210512 MSala - Review Code - Start ***/
    private static void cebAssociaTaskAffidamento(List<Task> tList, Map<String, Schema.SObjectType> gd) {
        List<Affidamento__c> aList = new List<Affidamento__c>();
        List<Log__c> logL = new List<Log__c>();
        Date mydate;
        for (Task t : tlist) {
            if (!t.ActivityExtended__r.E_da_affidare__c) {
                continue;
            }
            if (t.ActivityExtended__r.id_affidamento__c == null) {
                continue;
            }

            Affidamento__c aff = new Affidamento__c();
            mydate = System.today();
            aff.Id = t.ActivityExtended__r.id_affidamento__c;
            aff.Data_fine_affidamento_prevista__c = mydate.addDays(Integer.valueof(t.SLA__c));
            aff.ID_task_target_revoca__c = t.Id;
            aList.add(aff);
        }

        if (logl.size() > 0) insert logl;
        if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'ID_task_target_revoca__c', gd).get('UPDATE')) {
            update aList;
        }
    }
    /*** 20210512 MSala - Review Code - End ***/
}