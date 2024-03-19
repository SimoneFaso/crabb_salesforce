/* ---------------------------------------------------------------------------------------------------------------------
Name:            Ork.cls
Description:     Orchestrator on Tasks' activities.
                 La classe è un centro di gestione delle attività che vengono eseguite sui Tasks. Definisce l'ordine e la
                 priorità. La classe fa uso di diverse classi correlate per eseguire le logiche necessarie:
                 - OrkKernel: classe che contiene i metodi funzionali della gestione delle attività;
                 - OrkBL: classe che contiene le logiche specifiche, che definisce la business logic specifica (sono logiche
                          puntuali e delimitate su usecase specifici)
                 - OrkActivities: classe che gestisce le attività ( invio mail, notifica etc );
                 - OrkStatic: classe di supporto per recuperare dati necessari per il processo delle attività;
Test class:

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
06-May-2014  0.1      Klodjan Meta                     First Version
07-May-2021  0.2      Giulia Mameli                    Modified removing redundant invocations to getTaskWithActivityExtended
                                                       method
12-May-2021  0.3      G.Mameli & M.Siotto              Modified for using ceb methods
05-Oct-2021  0.4      G.Mameli, C.Sanna,               Modified buildFilteredTasksActivitiesExtMap method from private
                      M. Pizzichini                    to public static.
----------------------------------------------------------------------------------------------------------------------*/

public without sharing class Ork {
    public class OrkException extends Exception {
    }

    public static Boolean fatalError = false;
    public static Boolean processLog = false; //variabile che definisce se salvare i log o meno
    public static Boolean areLogsActive;

    /*Task manipulation gli oggetti che seguono vengono utilizzati per eseguire le operazioni necessarie:
        pMap = contiene le pratiche associate ai task triggerati
        tMap = mappa con i task da lavorare
        sobjectsToInsert = contiene tutti gli SObject da inserire
        sobjectsToUpdate = contiene tutti gli SObject da aggiornare
        logL = viene utilizzato per salvare i log di debug generati
        dispatcherMap = la mappa definisce la tipologia di percorso che deve essere eseguito
        tskActExtMap = mappa di tutti i Task Ids provenienti dal Task trigger e delle correlate Activities Extended
        filteredTsksActsExtMap = mappa dei Task Ids (che devono essere lavorati, cioè non completati o in errore o filtrati per tipo di operazione), e correlate activities Extended
        gd = variabile Schema.getGlobalDescribe(), introdotta per l'utilizzo dei metodi ceb, allo scopo di non ripetere l'estazione della mappa di oggetti.
    */

    public Map<String, Pratica__c> pMap = new Map<String, Pratica__c> ();
    public Map<String, Task> tMap = new Map<String, Task>();
    public Map<Id, SObject> sobjectsToUpdate = new Map<Id, SObject>();
    public List<SObject> sobjectsToInsert = new List<SObject>();
    public List<Log__c> logL = new List<Log__c>();
    private Map<String, Map<String, Task>> dispatcherMap = new Map<String, Map<String, Task>>();
    private Map<String, Map<String, ActivityExtended__c>> dispatcherExMap = new Map<String, Map<String, ActivityExtended__c>>();
    private Map<Id, ActivityExtended__c> tskActExtMap = new Map<Id, ActivityExtended__c>();
    private Map<Id, ActivityExtended__c> filteredTsksActsExtMap = new Map<Id, ActivityExtended__c>();
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    public static Map<String, List<Step_Field_Update__c>> existingStepFieldsUpdates = new Map<String, List<Step_Field_Update__c>>();

    /*il metodo è esposto pubblico ed definisce e sceglie il percorso che devono seguire i Tasks:
      Esso raccoglie le operazioni:
        - executeFirstActivities: essa lavora i task per ingresso in strategia, ricercando una possibile strategia da associare al task;
        - executeExit: il metodo verifica se sono soddisfate le condizioni di uscita dalla strategia. Se soddisfatte le condizioni di uscita,
                       smette di eseguire la strategia
        - executeJump: se verificate le condizioni, esegue il salto e chiude l'attività corrente.
        - executeActivity: esegue l'attività associata al task;
        - executeLoop: verifica se ci sono jump utilizzati come connessioni tra rami diversi della strategia.
                       Esso è un elemento che connette due attività che non sono legate secondo la relazione padre/figlio;
        - nextJob: istanzia le attività successive che sono legate secondo la gerarchia padre/figlio.
                        
    */
    public Boolean execute(String token, List<Task> soL, List<Task> oldSoL) {
        if (areLogsActive == null) areLogsActive = TagHelper.getValueBoolean('OrkLogl');
        Boolean result = true;

        //Build Task Id and related Activity Extended Map
        tskActExtMap = Utils.cebGetTaskWithActivityExtended(soL, gd);

        /*Le attività vengono filtrate, verificando quali sono processabili e quali no.
          Per esempio, quelle chiuse/in errore e non di processo non vengono lavorate.
        */
        result = OrkKernel.cebShieldLevelZero(tMap, soL, tskActExtMap, gd);

        if (tMap.keySet().size() == 0) {
            return false; //se non ci sono attività, chiude il processo
        }

        /*qui vengono caricati i dati necessari per processare i task, recuperando strategia e pratiche.
          Una volta caricati i dati viene verificato se le attività possono essere processate.
          Per esempio, pratiche bloccate, strategie non attive, etc...
        */

        OrkStatic.cebSetTaskFieldsList(gd);
        OrkStatic.setTaskRecrdType();
        OrkStatic.cebRetrieveStrategie(gd);
        OrkStatic.cebRetrievePratiche(tMap, pMap, gd);
        tMap = OrkKernel.cebShieldPostLoadConfiguration(tMap, pMap, tskActExtMap, gd);


        //istanziazione delle pratiche che verranno utilizzate per fare l'update.
        OrkKernel.generatePraticheForupdateUseOnly(pMap, sobjectsToUpdate);

        //qui viene definita la distribuzione e le operazioni che devono essere eseguite per pratica
        OrkKernel.cebSetDispatcher(tMap, dispatcherMap, dispatcherExMap, gd);

        /*In questa sezione vendono eseguiti i vari percorsi se ad essi sono associati delle attività
            isForceOperation: esegue le operazioni di cambio strategia e attività tramite operazione manuale;
            isFirst: sono le attività per ingresso in strategia;
            isUI: gestisce le operazioni di strategia eseguite dall'utente;
            isExpectance: esegue tutte le attività di attesa legate alla strategia;
            isProcess: esegue le attività automatiche della strategia;
        */

        /** 20210615 MSiotto - New CEB Engine Logic - START **/
        List<Pratica__c> praList = new List<Pratica__c>();
        for(String pKey : pMap.keySet()) {
            praList.add(pMap.get(pKey));
        }
        Map<String, SObject> objectForPraticaMap = CrabbEngineUtils.generateMapsFieldUpdate(praList,gd);
        existingStepFieldsUpdates = CrabbEngineUtils.getStepFieldUpdates();
        /** 20210615 MSiotto - New CEB Engine Logic - END **/

        if (dispatcherMap.get('isForceOperation').keySet().size() > 0) {
            tMap = dispatcherMap.get('isForceOperation');

            //Filter tskActExtMap leaving only Task Ids and related Activities Extended contained in tMap (isForceOperation activities)
            filteredTsksActsExtMap = buildFilteredTasksActivitiesExtMap(tskActExtMap, tMap);

            OrkKernel.cebForceOperation(tMap, pMap, sobjectsToInsert,filteredTsksActsExtMap, gd);
        }
        if (dispatcherMap.get('isFirst').keySet().size() > 0) {
            tMap = dispatcherMap.get('isFirst');

            //Filter tskActExtMap leaving only Task Ids and related Activities Extended contained in tMap (isFirst activities)
            filteredTsksActsExtMap = buildFilteredTasksActivitiesExtMap(tskActExtMap, tMap);

            OrkKernel.cebExecuteFirstActivities(gd, tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, filteredTsksActsExtMap);
            /** 20210615 MSiotto - New CEB Engine Logic - START **/
            OrkKernel.cebSetNextJob(objectForPraticaMap, gd, token, tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, filteredTsksActsExtMap);
            /** 20210615 MSiotto - New CEB Engine Logic - END **/
        }
        if (dispatcherMap.get('isUI').keySet().size() > 0) {
            tMap = dispatcherMap.get('isUI');

            //Filter tskActExtMap leaving only Task Ids and related Activities Extended contained in tMap (isUI activities)
            filteredTsksActsExtMap = buildFilteredTasksActivitiesExtMap(tskActExtMap, tMap);

            OrkKernel.cebExecuteExit(gd, token, tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, filteredTsksActsExtMap);
            /** 20210615 MSiotto - New CEB Engine Logic - START **/
            OrkKernel.cebExecuteJump(objectForPraticaMap, gd, token, tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, filteredTsksActsExtMap);
            OrkKernel.cebExecuteLoop(objectForPraticaMap, gd, token, tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, filteredTsksActsExtMap);
            OrkKernel.cebSetNextJob(objectForPraticaMap, gd, token, tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, filteredTsksActsExtMap);
            /** 20210615 MSiotto - New CEB Engine Logic - END **/
        }
        if (dispatcherMap.get('isExpectance').keySet().size() > 0) {
            tMap = dispatcherMap.get('isExpectance');

            //Filter tskActExtMap leaving only Task Ids and related Activities Extended contained in tMap (isExpectance activities)
            filteredTsksActsExtMap = buildFilteredTasksActivitiesExtMap(tskActExtMap, tMap);

            OrkKernel.cebExecuteExit(gd, token, tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, filteredTsksActsExtMap);
            /** 20210615 MSiotto - New CEB Engine Logic - START **/
            OrkKernel.cebExecuteJump(objectForPraticaMap, gd, token, tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, filteredTsksActsExtMap);
            /** 20210615 MSiotto - New CEB Engine Logic - END **/
            executeActivity(filteredTsksActsExtMap);
            /** 20210615 MSiotto - New CEB Engine Logic - START **/
            OrkKernel.cebExecuteLoop(objectForPraticaMap, gd, token, tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, filteredTsksActsExtMap);
            OrkKernel.cebSetNextJob(objectForPraticaMap, gd, token, tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, filteredTsksActsExtMap);
            /** 20210615 MSiotto - New CEB Engine Logic - END **/
        }
        if (dispatcherMap.get('isProcess').keySet().size() > 0) {
            tMap = dispatcherMap.get('isProcess');

            //Filter tskActExtMap leaving only Task Ids and related Activities Extended contained in tMap (isExpectance activities)
            filteredTsksActsExtMap = buildFilteredTasksActivitiesExtMap(tskActExtMap, tMap);

            OrkKernel.cebExecuteExit(gd, token, tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, filteredTsksActsExtMap);
            /** 20210615 MSiotto - New CEB Engine Logic - START **/
            OrkKernel.cebExecuteJump(objectForPraticaMap, gd, token, tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, filteredTsksActsExtMap);
            /** 20210615 MSiotto - New CEB Engine Logic - END **/
            executeActivity(filteredTsksActsExtMap);
            /** 20210615 MSiotto - New CEB Engine Logic - START **/
            OrkKernel.cebExecuteLoop(objectForPraticaMap, gd, token, tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, filteredTsksActsExtMap);
            OrkKernel.cebSetNextJob(objectForPraticaMap, gd, token, tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, filteredTsksActsExtMap);
            /** 20210615 MSiotto - New CEB Engine Logic - END **/
        }
        saveData();
        return true;
    }

    /*saveData
    * il metodo effettua il salvataggio dei dati modificati / da creare / dei log
    */
    private void saveData() {

        if (sobjectsToInsert.size() > 0) {
            sobjectsToInsert = Utils.sortTaskActivities(sobjectsToInsert);
            insert sobjectsToInsert;
        }
        if (sobjectsToUpdate.keySet() != null && sobjectsToUpdate.keySet().size() > 0) {
            List<SObject> soToUpdate = new List<SObject>();
            soToUpdate = Utils.sortTaskActivities(sobjectsToUpdate.values());
            update soToUpdate;
        }
        if (logL.size() > 0 && areLogsActive
                /*&& Utils.checkFLSPermission('Log__c', 'Class_Name__c').get('CREATE')
                && Utils.checkObjPermission('Log__c').get('INSERT'))*/
                && Utils.cebCheckFLSPermission('Log__c', 'Class_Name__c',gd).get('CREATE')
                && Utils.cebCheckObjPermission('Log__c',gd).get('INSERT')) {
            insert logL;
        }
    }

    /*executeActivity
    * il metodo esegue le attività associate al singolo record, clusterizza i task
    * per attività nella mappa activityTask ed elabora i task per attività.
    * la classe non è definitiva
    */
    private void executeActivity(Map<Id, ActivityExtended__c> filteredTskActExtMap) {
        Map<String, Map<String, Task>> activityTask = getTaskActivityMap(tMap, pMap, filteredTskActExtMap);
        logL.add(ErrorClass.istanceError('999999', 'Ork : executeActivity activityTask = ' + activityTask));
        if (activityTask == null) return;
        for (String s : activityTask.keySet()) {
            Map<String, String> result = OrkActivities.cebExecute(s, activityTask.get(s), pMap, logL, filteredTskActExtMap, gd);
            Map<String, Task> tMapProcessed = activityTask.get(s);
            for (String tsk : tMapProcessed.keySet()) {
                Task t = tMap.get(tsk);
                //ActivityExtended__c ae = taskId2Obj.get(t.Id);
                ActivityExtended__c ae = filteredTskActExtMap.get(t.Id);
                Pratica__c pratica = pMap.get(t.WhatId);
                if (t.Status == 'Lavorata') {
                    OrkBL.setActivitySuccess(t, ae, pratica, 'OK');
                }
            }
        }
    }

    private Map<String, Map<String, Task>> getTaskActivityMap(Map <String, Task> tasksMap, Map <String, Pratica__c> pMap, Map<Id, ActivityExtended__c> filteredTskActExtMap) {
        Map<String, Map<String, Task>> actExTypeTaskMap = new Map<String, Map<String, Task>>();
        if (tasksMap.keySet() == null || tasksMap.keySet().size() == 0) return null;
        Map<Id, ActivityExtended__c> taskActExMap = filteredTskActExtMap;
        for (String tskId : tasksMap.keySet()) {
            Task t = tasksMap.get(tskId);
            ActivityExtended__c ae = taskActExMap.get(t.Id);

            if (!OrkBL.isTaskForActivity(t, ae)) {
                sobjectsToUpdate.put(ae.Id, ae);
                continue;
            } else {
                sobjectsToUpdate.put(ae.Id, ae);
            }
            if (t.Status == 'Lavorata') {
                OrkBL.setActivitySuccess(t, ae, pMap.get(t.WhatId), 'OK');
                continue;
            }
            if (actExTypeTaskMap.get(ae.Activity__c) == null) {
                actExTypeTaskMap.put(ae.Activity__c, new Map<String, Task>());
            }
            logL.add(ErrorClass.istanceError('999999', 'Ork : getTaskActivityMap Activ:' + ae.Activity__c + ' - ' + tskId));
            actExTypeTaskMap.get(ae.Activity__c).put(tskId, t);
        }
        logL.add(ErrorClass.istanceError('999999', 'Ork : getTaskActivityMap activ = ' + actExTypeTaskMap));
        return actExTypeTaskMap;
    }

    /* -----------------------------------------------------------------------------------------------------------------
    Author: Giulia Mameli
    Description: This method filters the global TaskIds - Activities Extended Map, excluding items not contained in tMap.
    Inputs:  Map<Id, ActivityExtended__c> tskActExtMap, Map<String, Task> tMap
    Returns: Map<Id, ActivityExtended__c> filteredTskActExtMap

    07-May-2021  0.1      Giulia Mameli                         First Version
    17-May-2021  0.2      Giulia Mameli                         Modified for using ceb method cebGetTaskWithActivityExtended
    ----------------------------------------------------------------------------------------------------------------- */

    public static Map<Id, ActivityExtended__c> buildFilteredTasksActivitiesExtMap (Map<Id, ActivityExtended__c> tskActExtMap, Map<String, Task> tMap){
        Map<Id, ActivityExtended__c> filteredTsksActsExtMap = new Map<Id, ActivityExtended__c>();

        if(tskActExtMap == null){
            filteredTsksActsExtMap = Utils.cebGetTaskWithActivityExtended(tMap.values(), gd);
        } else {
            for(Task tsk : tMap.values()){
                if(tskActExtMap.get(tsk.Id) != null){
                    filteredTsksActsExtMap.put(tsk.Id, tskActExtMap.get(tsk.Id));
                }
            }
        }

        return filteredTsksActsExtMap;
    }
}