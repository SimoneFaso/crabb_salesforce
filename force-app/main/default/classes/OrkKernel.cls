/* ---------------------------------------------------------------------------------------------------------------------
Name:            OrkKernel.cls
Description:     Gestisce le funzionalità core dell'orchestratore (Ork)
Test class:      TestOrkKernel.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
06-May-2014  0.1      Klodjan Meta                     First Version
07-May-2021  0.2      Giulia Mameli                    Modified shieldLevelZero and shieldPostLoadConfiguration, removing
                                                       redundant invocations to getTaskWithActivityExtended method.
10-May-2021  0.5      Matteo Siotto                    Created new Engine method cebExecuteFirstActivities and cebNextJob
11-May-2021  0.6      Matteo Siotto                    Reviewed for using ceb methods
16-Jun-2021  0.7      Giulia Mameli                    Modified cebForceOperation (ae as input for cebNewTask)
13-Jul-2021  0.8      Matteo Siotto                    Added cebSetNextJob, cebExecuteLoop and cebExecuteJump methods
01-Oct-2021  0.9      Giulia Mameli, C. Sanna,         Modified cebShieldPostLoadConfiguration() for blocking Activities
                      M. Pizzichini                    Extended in case of blocked Dossier, commented old versions of:
                                                       executeExit, nextJob, executeLoop and executeJump methods.



----------------------------------------------------------------------------------------------------------------------*/

public with sharing class OrkKernel {

    public class OrkKernelException extends Exception {

    }
    public static Boolean executeLogOperations = false;
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    /*Metodo che istanzia delle pratiche vuote, le quali vengono utilizzate per fare degli update sulle pratiche, facendo update solo 
    * sui campi modificati. I campi sui quali fare update vengono settati durante il percorso di lavorazione. In questo modo si è garantiti che 
    * viene fatto un update solo sui campi che sono stati modificatti effettivamente.
    */
    public static Boolean generatePraticheForupdateUseOnly(Map<String, Pratica__c> pMap, Map<Id, SObject> sobjectsToUpdate) {
        if (sobjectsToUpdate == null) sobjectsToUpdate = new Map<Id, SObject>();
        for (Pratica__c p : pMap.values()) {
            sobjectsToUpdate.put(p.Id, new Pratica__c(Id = p.Id));
        }
        return true;
    }

    /*** 20210513 MSiotto - Code Review - Start
     * Rimosso per nuova gestione CEB
     * ***/
    /*shieldLevelZero:
    * Il metodo fa da filtro per le attività che si possono eseguire o meno.
    * Qui vengono eliminate dal processo tutte quelle attività che non sono state aggiornate
    * per essere processate (escluse quelle in Stato Errore o Completata).
    */
    /*
    public static Boolean shieldLevelZero(Map<String, Task> tMap, List<Task> soL, Map<Id, ActivityExtended__c> newTskActExtMap) {
        if (tMap == null) tMap = new Map<String, Task>();
        Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();

        //If global newTskActExtMap is empty then fill it with getTaskWithActivityExtended
        if (newTskActExtMap == null) {
            task2Obj = Utils.getTaskWithActivityExtended(soL);
        } else {
            task2Obj = newTskActExtMap;
        }

        //throw new Utils.BalanceException('lista task:'+soL);
        for (Task t : soL) {
            ActivityExtended__c ae = task2Obj.get(t.Id);
            //throw new Utils.BalanceException('aeid:'+t.ActivityExtended__c);
            if (ae == null && t.ActivityExtended__c != null) {
                Id idae = t.ActivityExtended__c;
                // inizio nuovo codice 13/04/17 inserimento check permission
                if (Utils.checkFLSPermission('Task', 'ActivityExtended__c').get('ACCESS')
                        && Utils.checkFLSPermission('ActivityExtended__c', 'id_attivita__c').get('ACCESS')
                        && Utils.checkFLSPermission('ActivityExtended__c', 'id_affidamento__c').get('ACCESS')
                        && Utils.checkFLSPermission('ActivityExtended__c', 'id_lotto_associato__c').get('ACCESS')) {
                    String queryae = 'SELECT ' + Utils.getSOBJECTFieldsForQuery('ActivityExtended__c') + ' FROM ActivityExtended__c WHERE Id =:idae';
                    ae = (ActivityExtended__c) Database.query(queryae).get(0);
                }
                // fine nuovo codice 13/04/17 inserimento check permission
            }
            if (ae != null && ae.Record_Type__c != null && ae.Record_Type__c != 'UI' && ae.Record_Type__c != 'Process' && ae.Record_Type__c != 'Expectance') continue; else if (t.Status == 'Error') continue; else if (t.Status == 'Completata') continue; else if (t.Status == 'Completato') continue; else if (t.Status == TagHelper.getValueText('ValoreStatoPraticaPerBloccoManuale')) continue; else if (ae != null && ae.Record_Type__c != null && ae.Record_Type__c == 'UI' && (t.Status != 'Lavorata' && t.Status != 'Non iniziata' && t.Status != 'Revocata')) continue; else {
                t.Description = '_OKsh0  \n';
                tMap.put(t.Id, t);
            }
        }
        return true;
    }
    */
    /*** 20210513 MSiotto - Code Review - End ***/

    /*** 20210512 GMameli/MSiotto - Code Review - Start ***/
    /*cebShieldLevelZero: shieldLevelZero modificato per ricevere in ingresso globalDesc e utilizzare i metodi ceb
    * Il metodo fa da filtro per le attività che si possono eseguire o meno.
    * Qui vengono eliminate dal processo tutte quelle attività che non sono state aggiornate
    * per essere processate (escluse quelle in Stato Errore o Completata).
    */

    public static Boolean cebShieldLevelZero(Map<String, Task> tMap, List<Task> soL, Map<Id, ActivityExtended__c> newTskActExtMap, Map<String, Schema.SObjectType> globalDesc) {
        if (tMap == null) tMap = new Map<String, Task>();
        Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();

        //If global newTskActExtMap is empty then fill it with getTaskWithActivityExtended
        if (newTskActExtMap == null) {
            task2Obj = Utils.cebGetTaskWithActivityExtended(soL, globalDesc);
        } else {
            task2Obj = newTskActExtMap;
        }

        //throw new Utils.BalanceException('lista task:'+soL);
        for (Task t : soL) {
            ActivityExtended__c ae = task2Obj.get(t.Id);
            //throw new Utils.BalanceException('aeid:'+t.ActivityExtended__c);
            if (ae == null && t.ActivityExtended__c != null) {
                Id aeId = t.ActivityExtended__c;
                // inizio nuovo codice 13/04/17 inserimento check permission
                if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c', globalDesc).get('ACCESS')
                        && Utils.cebCheckObjPermission('ACtivityExtended__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_attivita__c', globalDesc).get('ACCESS')
                        && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_affidamento__c', globalDesc).get('ACCESS')
                        && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_lotto_associato__c', globalDesc).get('ACCESS')) {
                    String queryAE = 'SELECT ' + Utils.cebGetSOBJECTFieldsForQuery('ActivityExtended__c', globalDesc) + ' FROM ActivityExtended__c WHERE Id =: aeId';
                    ae = (ActivityExtended__c) Database.query(String.escapeSingleQuotes(queryAE)).get(0);
                }
                // fine nuovo codice 13/04/17 inserimento check permission
            }
            if (ae != null && ae.Record_Type__c != null && ae.Record_Type__c != 'UI' && ae.Record_Type__c != 'Process' && ae.Record_Type__c != 'Expectance') {
                continue;
            } else if (t.Status == 'Error') continue;
            else if (t.Status == 'Completata') continue;
            else if (t.Status == 'Completato') continue;
            else if (t.Status == TagHelper.getValueText('ValoreStatoPraticaPerBloccoManuale')) continue;
            else if (ae != null && ae.Record_Type__c != null && ae.Record_Type__c == 'UI' && (t.Status != 'Lavorata' && t.Status != 'Non iniziata' && t.Status != 'Revocata')) continue;
            else {
                t.Description = '_OKsh0  \n';
                tMap.put(t.Id, t);
            }
        }
        return true;
    }
    /*** 20210512 GMameli/MSiotto - Code Review - End ***/

    /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
    /*shieldPostLoadConfiguration:
    * il metodo fa da filtro per le attività post caricamento dati.
    */
    /*public static Map<String, Task> shieldPostLoadConfiguration(Map<String, Task> tMap, Map<String, Pratica__c> pMap, Map<Id, ActivityExtended__c> newTskActExtMap) {
        if (tMap == null || pMap == null) return new Map<String, Task>();
        Map<String, Task> tempMap = new Map<String, Task>();
        Map<Id, ActivityExtended__c> aes2Obj = new Map<Id, ActivityExtended__c>();

        //If global newTskActExtMap is empty then fill it with getTaskWithActivityExtended
        if (newTskActExtMap == null) {
            aes2Obj = Utils.getTaskWithActivityExtended(tMap.values());
        } else {
            aes2Obj = newTskActExtMap;
        }

        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Task t : tMap.values()) {
            ActivityExtended__c ae = aes2Obj.get(t.Id);
            Pratica__c p = pMap.get(t.WhatId);
            if (p == null) {
                t.Status = 'Error';
                t.Description += '\n OrkKernel.shieldPostLoadConfiguration:Non può esistere un task di processo senza pratica';
            } else if (p.Stato__c == TagHelper.getValueText('ValoreStatoPraticaPerBloccoManuale')) {
                t.Status = TagHelper.getValueText('ValoreStatoPraticaPerBloccoManuale');
                t.Description += '\n _KOShPL0';continue;
            } else if (p.Stato__c == 'Chiusa') {
                t.Status = 'Completata';
                ae.Esito__c = 'Chiuso per chiusura pratica';
                t.Description += '\n_KOShPL1';
                aes.add(ae);
                continue;
            } else if (p.Stato__c == TagHelper.getValueText('StatoPraticaBloccoPDR') && ae.E_da_affidare__c == false) {
                t.Status = TagHelper.getValueText('StatoPraticaBloccoPDR'); continue;
            } else if (ae.Id_Strategia__c != null && OrkStatic.strategies.get(ae.Id_Strategia__c) == null) {
                t.Status = 'Error';
                ae.Esito__c = 'Strategia del task non più attiva';
                t.Description += '\n_KOShPL2';
                aes.add(ae); continue;
            } else if (ae.id_attivita__c != null && OrkStatic.strategies.get(ae.id_attivita__c) == null) {
                t.Status = 'Error';
                ae.Esito__c = 'Attività associata al task non più presente';
                t.Description += '\n_KOShPL3'; continue;
            } else {
                t.Description += '\n _OKShPL_else' + '_' + p.Stato__c;
                tempMap.put(t.Id, t);
            }
        }
        if (Utils.checkFLSPermission('ActivityExtended__c', 'esito__c').get('UPDATE')) update aes;
        return tempMap;
    }*/
    /*** 20210513 MSiotto - Code Review - End Rimosso per nuova gestione CEB ***/

    /*** 20210512 GMameli/MSiotto - Code Review - Start ***/
    /*cebShieldPostLoadConfiguration: shieldPostLoadConfiguration modificato per ricevere in ingresso globalDesc e utilizzare i metodi ceb
    * il metodo fa da filtro per le attività post caricamento dati.
    */
    public static Map<String, Task> cebShieldPostLoadConfiguration(Map<String, Task> tMap, Map<String, Pratica__c> pMap, Map<Id, ActivityExtended__c> newTskActExtMap, Map<String, Schema.SObjectType> globalDesc) {
        if (tMap == null || pMap == null) return new Map<String, Task>();
        Map<String, Task> tempMap = new Map<String, Task>();
        Map<Id, ActivityExtended__c> aes2Obj = new Map<Id, ActivityExtended__c>();

        //If global newTskActExtMap is empty then fill it with getTaskWithActivityExtended
        if (newTskActExtMap == null) {
            aes2Obj = Utils.cebGetTaskWithActivityExtended(tMap.values(), globalDesc);
        } else {
            aes2Obj = newTskActExtMap;
        }

        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Task t : tMap.values()) {
            ActivityExtended__c ae = aes2Obj.get(t.Id);
            Pratica__c p = pMap.get(t.WhatId);
            if (p == null) {
                t.Status = 'Error';
                t.Description += '\n OrkKernel.shieldPostLoadConfiguration: Non può esistere un Task di processo senza Pratica';
            } else if (p.Stato__c == TagHelper.getValueText('ValoreStatoPraticaPerBloccoManuale')) {
                t.Status = TagHelper.getValueText('ValoreStatoPraticaPerBloccoManuale');
                t.Description += '\n _KOShPL0';
                ae.code_status__c = TagHelper.getValueText('ValoreStatoPraticaPerBloccoManuale');
                aes.add(ae);
                continue;
            } else if (p.Stato__c == 'Chiusa') {
                t.Status = 'Completata';
                ae.Esito__c = 'Chiuso per chiusura Pratica';
                t.Description += '\n_KOShPL1';
                aes.add(ae);
                continue;
            } else if (p.Stato__c == TagHelper.getValueText('StatoPraticaBloccoPDR') && ae.E_da_affidare__c == false) {
                t.Status = TagHelper.getValueText('StatoPraticaBloccoPDR');
                ae.code_status__c = TagHelper.getValueText('StatoPraticaBloccoPDR');
                aes.add(ae);
                continue;
            } else if (ae.Id_Strategia__c != null && OrkStatic.strategies.get(ae.Id_Strategia__c) == null) {
                t.Status = 'Error';
                ae.Esito__c = 'Strategia del task non più attiva';
                t.Description += '\n_KOShPL2';
                aes.add(ae); continue;
            } else if (ae.id_attivita__c != null && OrkStatic.strategies.get(ae.id_attivita__c) == null) {
                t.Status = 'Error';
                ae.Esito__c = 'Attività associata al task non più presente';
                t.Description += '\n_KOShPL3'; continue;
            } else {
                t.Description += '\n _OKShPL_else' + '_' + p.Stato__c;
                tempMap.put(t.Id, t);
            }
        }
        if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'esito__c', globalDesc).get('UPDATE')) {
            update aes;
        }
        return tempMap;
    }
    /*** 20210512 GMameli/MSiotto - Code Review - End ***/

    /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
    /*setDispatcher:
    * il metodo crea una operazione di suddivisione per tipologia di processo o lavorazione
    */
    /*public static Boolean setDispatcher(Map<String, Task> tMap, Map<String, Map<String, Task>> dispatcherMap, Map<String, Map<String, ActivityExtended__c>> dispatcherExMap) {
        dispatcherMap.put('isForceOperation', new Map<String, Task>());
        dispatcherMap.put('isFirst', new Map<String, Task>());
        dispatcherMap.put('isProcess', new Map<String, Task>());
        dispatcherMap.put('isUI', new Map<String, Task>());
        dispatcherMap.put('isExpectance', new Map<String, Task>());
        dispatcherMap.put('isElse', new Map<String, Task>());
        dispatcherExMap.put('isForceOperation', new Map<String, ActivityExtended__c>());
        dispatcherExMap.put('isFirst', new Map<String, ActivityExtended__c>());
        dispatcherExMap.put('isProcess', new Map<String, ActivityExtended__c>());
        dispatcherExMap.put('isUI', new Map<String, ActivityExtended__c>());
        dispatcherExMap.put('isExpectance', new Map<String, ActivityExtended__c>());
        dispatcherExMap.put('isElse', new Map<String, ActivityExtended__c>());
        List<Id> aesids = new List<Id>();
        for (Task t : tMap.values()) {
            aesids.add(t.ActivityExtended__c);
        }
        //throw new Utils.BalanceException('FFFFF:'+aesids);
        if (Utils.checkFLSPermission('ActivityExtended__c', 'code_status__c').get('ACCESS')
                && Utils.checkFLSPermission('ActivityExtended__c', 'isForcedOperation__c').get('ACCESS')
                && Utils.checkFLSPermission('ActivityExtended__c', 'isFirst__c').get('ACCESS')) {
            Map<Id, ActivityExtended__c> aes = new Map<Id, ActivityExtended__c>([SELECT code_status__c, isForcedOperation__c, Record_Type__c, isFirst__c, RecordTypeId FROM ActivityExtended__c WHERE Id IN :aesids]);
            //throw new Utils.BalanceException('SSSS:'+aes.values());
            for (Task t : tMap.values()) {
                ActivityExtended__c ae = aes.get(t.ActivityExtended__c);
                ae.code_status__c = '';
                if (ae.isForcedOperation__c) {
                    ae.code_status__c += '_isForceOp';
                    dispatcherMap.get('isForceOperation').put(t.Id, t);
                    dispatcherExMap.get('isForceOperation').put(ae.Id, ae);
                } else if (ae.isFirst__c && ae.Record_Type__c == 'Process') {
                    ae.code_status__c += '_isFirst';
                    if (t.Status.toUpperCase() == 'RICERCA STRATEGIA' || t.Status.toUpperCase() == 'NON INIZIATA' || t.Status.toUpperCase() == 'LAVORATA') {
                        dispatcherMap.get('isFirst').put(t.Id, t);
                        dispatcherExMap.get('isFirst').put(ae.Id, ae);
                    }
                } else if (ae.Record_Type__c == 'Process') {
                    ae.code_status__c += '_isProcess';
                    dispatcherMap.get('isProcess').put(t.Id, t);
                    dispatcherExMap.get('isProcess').put(ae.Id, ae);
                } else if (ae.Record_Type__c == 'UI') {
                    ae.code_status__c += '_isUI';
                    dispatcherMap.get('isUI').put(t.Id, t);
                    dispatcherExMap.get('isUI').put(ae.Id, ae);
                } else if (ae.Record_Type__c == 'Expectance') {
                    ae.code_status__c += '_isExpectance';
                    dispatcherMap.get('isExpectance').put(t.Id, t);
                    dispatcherExMap.get('isExpectance').put(ae.Id, ae);
                } else {
                    ae.code_status__c += '_isElse'; dispatcherMap.get('isElse').put(t.Id, t); dispatcherExMap.get('isElse').put(ae.Id, ae);
                }
            }
        }
        return true;
    }*/
    /*** 20210513 MSiotto - Code Review - End Rimosso per nuova gestione CEB ***/

    /*** 20210512 GMameli/MSiotto - Code Review - Start ***/
    /*cebSetDispatcher: setDispatcher modificato per ricevere in ingresso globalDesc e utilizzare i metodi ceb
    * il metodo crea una operazione di suddivisione per tipologia di processo o lavorazione
    */
    public static Boolean cebSetDispatcher(Map<String, Task> tMap, Map<String, Map<String, Task>> dispatcherMap, Map<String, Map<String, ActivityExtended__c>> dispatcherExMap, Map<String, Schema.SObjectType> globalDesc) {
        dispatcherMap.put('isForceOperation', new Map<String, Task>());
        dispatcherMap.put('isFirst', new Map<String, Task>());
        dispatcherMap.put('isProcess', new Map<String, Task>());
        dispatcherMap.put('isUI', new Map<String, Task>());
        dispatcherMap.put('isExpectance', new Map<String, Task>());
        dispatcherMap.put('isElse', new Map<String, Task>());
        dispatcherExMap.put('isForceOperation', new Map<String, ActivityExtended__c>());
        dispatcherExMap.put('isFirst', new Map<String, ActivityExtended__c>());
        dispatcherExMap.put('isProcess', new Map<String, ActivityExtended__c>());
        dispatcherExMap.put('isUI', new Map<String, ActivityExtended__c>());
        dispatcherExMap.put('isExpectance', new Map<String, ActivityExtended__c>());
        dispatcherExMap.put('isElse', new Map<String, ActivityExtended__c>());
        List<Id> aesids = new List<Id>();
        for (Task t : tMap.values()) {
            aesids.add(t.ActivityExtended__c);
        }
        //throw new Utils.BalanceException('FFFFF:'+aesids);
        /*if (Utils.cebCheckObjPermission('ActivityExtended__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'code_status__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'isForcedOperation__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'isFirst__c', globalDesc).get('ACCESS')) {*/
        Map<Id, ActivityExtended__c> aes = new Map<Id, ActivityExtended__c>([
                SELECT code_status__c, isForcedOperation__c, Record_Type__c, isFirst__c, RecordTypeId
                FROM ActivityExtended__c
                WHERE Id IN :aesids
                WITH SECURITY_ENFORCED
        ]);
        //throw new Utils.BalanceException('SSSS:'+aes.values());
        for (Task t : tMap.values()) {
            ActivityExtended__c ae = aes.get(t.ActivityExtended__c);
            ae.code_status__c = '';
            if (ae.isForcedOperation__c) {
                ae.code_status__c += '_isForceOp';
                dispatcherMap.get('isForceOperation').put(t.Id, t);
                dispatcherExMap.get('isForceOperation').put(ae.Id, ae);
            } else if (ae.isFirst__c && ae.Record_Type__c == 'Process') {
                ae.code_status__c += '_isFirst';
                if (t.Status.toUpperCase() == 'RICERCA STRATEGIA' || t.Status.toUpperCase() == 'NON INIZIATA' || t.Status.toUpperCase() == 'LAVORATA') {
                    dispatcherMap.get('isFirst').put(t.Id, t);
                    dispatcherExMap.get('isFirst').put(ae.Id, ae);
                }
            } else if (ae.Record_Type__c == 'Process') {
                ae.code_status__c += '_isProcess';
                dispatcherMap.get('isProcess').put(t.Id, t);
                dispatcherExMap.get('isProcess').put(ae.Id, ae);
            } else if (ae.Record_Type__c == 'UI') {
                ae.code_status__c += '_isUI';
                dispatcherMap.get('isUI').put(t.Id, t);
                dispatcherExMap.get('isUI').put(ae.Id, ae);
            } else if (ae.Record_Type__c == 'Expectance') {
                ae.code_status__c += '_isExpectance';
                dispatcherMap.get('isExpectance').put(t.Id, t);
                dispatcherExMap.get('isExpectance').put(ae.Id, ae);
            } else {
                ae.code_status__c += '_isElse'; dispatcherMap.get('isElse').put(t.Id, t); dispatcherExMap.get('isElse').put(ae.Id, ae);
            }
        }
        //}
        return true;
    }
    /*** 20210512 GMameli/MSiotto - Code Review - End ***/

    /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
    /*
    * Il metodo gestisce le operazioni manuali concesse, come lo spostamento di attività
    */
    /*public static Boolean forceOperation(Map<String, Task> tMap, Map<String, Pratica__c> pMap, List<SObject> sobjectsToInsert, Map<Id, ActivityExtended__c> filteredTsksActsExtMap) {
        for (String idTask : tMap.keySet()) {
            Task t = tMap.get(idTask);
            Pratica__c pratica = pMap.get(t.WhatId);
            // throw new Utils.BalanceException('aaa:'+t.ActivityExtended__r.Go_to_task_of_strategie__c);//null
            //throw new Utils.BalanceException('Strategia id is:'+t.ActivityExtended__r.Id);//valorizzato correttamente
            Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();

            if (filteredTsksActsExtMap == null) {
                task2Obj = Utils.getTaskWithActivityExtended(tMap.values());
            } else {
                task2Obj = filteredTsksActsExtMap;
            }

            ActivityExtended__c ae = task2Obj.get(t.Id);
            Strategia__c st = OrkStatic.strategies.get(ae.Go_to_task_of_strategie__c);

            t.Status = 'Completata';
            String esito = 'Spostamento manuale';
            List<SObject> nt = OrkBL.newTask(t, pratica, st, esito);
            sobjectsToInsert.addAll(nt);
        }
        return true;
    }*/
    /*** 20210513 MSiotto - Code Review - End Rimosso per nuova gestione CEB ***/

    /*** 20210512 GMameli/MSiotto - Code Review - Start ***/
    /*
    * Il metodo gestisce le operazioni manuali concesse, come lo spostamento di attività
    */
    public static Boolean cebForceOperation(Map<String, Task> tMap, Map<String, Pratica__c> pMap, List<SObject> sobjectsToInsert, Map<Id, ActivityExtended__c> filteredTsksActsExtMap, Map<String, Schema.SObjectType> globalDesc) {
        for (String idTask : tMap.keySet()) {
            Task t = tMap.get(idTask);
            Pratica__c pratica = pMap.get(t.WhatId);
            // throw new Utils.BalanceException('aaa:'+t.ActivityExtended__r.Go_to_task_of_strategie__c);//null
            //throw new Utils.BalanceException('Strategia id is:'+t.ActivityExtended__r.Id);//valorizzato correttamente
            Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();

            if (filteredTsksActsExtMap == null) {
                task2Obj = Utils.cebGetTaskWithActivityExtended(tMap.values(), globalDesc);
            } else {
                task2Obj = filteredTsksActsExtMap;
            }

            ActivityExtended__c ae = task2Obj.get(t.Id);
            Strategia__c st = OrkStatic.strategies.get(ae.Go_to_task_of_strategie__c);


            t.Status = 'Completata';
            String esito = 'Spostamento manuale';
            List<SObject> nt = OrkBL.cebNewTask(globalDesc, t, ae, pratica, st, esito);
            sobjectsToInsert.addAll(nt);
        }
        return true;
    }
    /*** 20210512 GMameli/MSiotto - Code Review - End ***/

    /*executeFirstActivities
    * Il metodo esegue le verifiche per poter elaborare le attività che sono state clusterizzate come attività di inserimento in strategia
    * eseguendo le strategie "Standard" per priorità; viene anche tenuto conto delle attività lavorate e non, tramite il set "taskProcessati"
    */
    public static void executeFirstActivities(Map<String, Task> tMap, Map<String, Pratica__c> pMap, Map<Id, SObject> sobjectsToUpdate, List<SObject> sobjectsToInsert, List<Log__c> logL, Map<Id, ActivityExtended__c> filteredTsksActsExtMap) {
        Boolean result = false, goOut = false;
        Set<Id> taskProcessati = new Set<Id>();
        Pratica__c pratica = new Pratica__c();
        Pratica__c praticaToUpdate = new Pratica__c();
        Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();

        if (filteredTsksActsExtMap == null) {
            task2Obj = Utils.getTaskWithActivityExtended(tMap.values());
        } else {
            task2Obj = filteredTsksActsExtMap;
        }

        for (Id idsT : OrkStatic.sPO) {
            if (OrkStatic.cdiPO.get(idsT) == null) {
                logL.add(ErrorClass.istanceError('0000099', 'La lista con gli id delle cdi e nulla'));

                continue;
            }
            for (Id idcdi : OrkStatic.cdiPO.get(idsT)) {
                Strategia__c cdi = OrkStatic.strategies.get(idcdi);
                for (String idTask : tMap.keySet()) {
                    Task t = tMap.get(idTask);
                    ActivityExtended__c ae = task2Obj.get(t.Id);
                    if (taskProcessati.contains(idTask)) {
                        continue;
                    }
                    t.Description += '\n taskProcessati POST IF' + taskProcessati;

                    try {
                        pratica = pMap.get(t.WhatId);
                        praticaToUpdate = (Pratica__c) sobjectsToUpdate.get(t.WhatId);

                        t.Description += '\nOrkBL.isNecessaryGoOut:';
                        goOut = OrkBL.isNecessaryGoOut(t, ae, pratica, cdi, sobjectsToUpdate, sobjectsToInsert, logL);
                        t.Description += ' ' + goOut;

                        if (goOut) {
                            taskProcessati.add(t.Id);
                            continue;
                        }
                        t.Description += '\n CDI con nome:' + cdi.Nome__c;
                        result = OrkKernel.isRoleSatisfied(pratica, cdi, logL, t, task2Obj);

                        t.Description += ' ' + result;
                        if (result == null) {
                            taskProcessati.add(t.Id);
                            logL.add(errorClass.istanceError('executeFirstActivities ', ':' + t));
                            t.Description += '\n executeFirstActivities Error: result null' + 'Cdi:' + CDI.nome__c;
                            OrkBL.setEnteringInStrategiaError(t, ae);
                        } else if (result) {
                            taskProcessati.add(t.Id);

                            t.Description += '\n @@ aeidatt ' + ae.id_attivita__c;
                            OrkBL.setEnteringInStrategia(t, ae, pratica, cdi, sobjectsToUpdate, sobjectsToInsert, logL);

                            t.Description += '\n @@ ae ' + ae;
                            t.Description += '\n @@ strat ' + cdi;

                            t.Description += '\n executeFirstActivities success: CDI:' + CDI.nome__c;
                        }
                        sobjectsToUpdate.put(praticaToUpdate.id, praticaToUpdate);

                    } catch (Exception e) {
                        System.debug('excep ---> OrkKernel.executeFirstActivities E:' + e + 'linenumber ' + e.getLineNumber());
                        logL.add(ErrorClass.istanceError('000006', 'OrkKernel.executeFirstActivities E:' + e + '\n linenumber ' + e.getLinenumber())); t.status = 'Error'; t.description += '\n fatal error:' + 'OrkKernel.executeFirstActivities E:' + e + '\n linenumber ' + e.getLinenumber();
                    }
                }
            }
        }

        if (OrkBL.aes2processUpdate == null) return;
        List<ActivityExtended__c> aes2update = new List<ActivityExtended__c>();
        if (OrkBL.aes2processUpdate.get('isNecessaryGoOut') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('isNecessaryGoOut'));
            OrkBL.aes2processUpdate.remove('isNecessaryGoOut');
        }
        if (OrkBL.aes2processUpdate.get('setEnteringInStrategiaError') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setEnteringInStrategiaError')); OrkBL.aes2processUpdate.remove('setEnteringInStrategiaError');
        }
        if (OrkBL.aes2processUpdate.get('setEnteringInStrategia') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setEnteringInStrategia'));
            OrkBL.aes2processUpdate.remove('setEnteringInStrategia');
        }
        if (OrkBL.getTaskFielsPermission('UPDATE')) {
            update aes2update;
        }
    }

    /*** 20210511 MSiotto/GMameli - Code Review - Start ***/
    public static void cebExecuteFirstActivities(Map<String, Schema.SObjectType> globalDesc, Map<string, Task> tMap, Map<string, Pratica__c> pMap, Map<id, Sobject> sobjectsToUpdate, List<Sobject> sobjectsToInsert, List<Log__c> logL, Map<Id, ActivityExtended__c> filteredTsksActsExtMap) {
        boolean result = false, goout = false;
        set<id> taskProcessati = new set<id>();
        Pratica__c pratica = new Pratica__c();
        Pratica__c praticaToUpdate = new Pratica__c();
        Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();

        if (filteredTsksActsExtMap == null) {
            task2Obj = Utils.cebGetTaskWithActivityExtended(tMap.values(), globalDesc);
        } else {
            task2Obj = filteredTsksActsExtMap;
        }

        for (id idsT : OrkStatic.sPO) {
            if (OrkStatic.cdiPO.get(idsT) == null) {
                logL.add(errorClass.istanceError('0000099', 'La lista con gli id delle cdi e nulla'));
                continue;
            }
            for (id idcdi : OrkStatic.cdiPO.get(idsT)) {
                strategia__c cdi = OrkStatic.strategies.get(idcdi);
                for (string idTask : tMap.keySet()) {
                    Task t = tMap.get(idTask);
                    ActivityExtended__c ae = task2Obj.get(t.Id);
                    if (taskProcessati.contains(idTask)) {
                        continue;
                    }
                    t.description += '\n taskProcessati POST IF' + taskProcessati;
                    try {
                        pratica = pMap.get(t.whatId);
                        praticaToUpdate = (Pratica__c) sobjectsToUpdate.get(t.whatId);
                        t.description += '\nOrkBL.isNecessaryGoOut:';
                        goout = OrkBL.isNecessaryGoOut(t, ae, pratica, cdi, sobjectsToUpdate, sobjectsToInsert, logL);
                        t.description += ' ' + goout;
                        if (goout) {
                            taskProcessati.add(t.id);
                            continue;
                        }
                        t.Description += '\n CDI con nome:' + cdi.Nome__c;
                        result = OrkKernel.isRoleSatisfied(pratica, cdi, logL, t, task2Obj);
                        t.description += ' ' + result;
                        if (result == null) {
                            taskProcessati.add(t.id);
                            logL.add(errorClass.istanceError('executeFirstActivities ', ':' + t));
                            t.description += '\n executeFirstActivities Error: result null' + 'Cdi:' + CDI.nome__c;
                            OrkBL.setEnteringInStrategiaError(t, ae);
                        } else if (result) {
                            taskProcessati.add(t.id);
                            t.Description += '\n @@ aeidatt ' + ae.id_attivita__c;
                            OrkBL.setEnteringInStrategia(t, ae, pratica, cdi, sobjectsToUpdate, sobjectsToInsert, logL);
                            t.Description += '\n @@ ae ' + ae;
                            t.Description += '\n @@ strat ' + cdi;
                            t.Description += '\n executeFirstActivities success: CDI:' + CDI.nome__c;
                        }
                        sobjectsToUpdate.put(praticaToUpdate.id, praticaToUpdate);
                    } catch (Exception e) {
                        System.debug('excep ---> OrkKernel.executeFirstActivities E:' + e + 'linenumber ' + e.getLinenumber());
                        logL.add(errorClass.istanceError('000006', 'OrkKernel.executeFirstActivities E:' + e + '\n linenumber ' + e.getLinenumber())); t.status = 'Error'; t.description += '\n fatal error:' + 'OrkKernel.executeFirstActivities E:' + e + '\n linenumber ' + e.getLinenumber();
                    }
                }
            }
        }
        if (OrkBL.aes2processUpdate == null) return;
        List<ActivityExtended__c> aes2update = new List<ActivityExtended__c>();
        if (OrkBL.aes2processUpdate.get('isNecessaryGoOut') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('isNecessaryGoOut'));
            OrkBL.aes2processUpdate.remove('isNecessaryGoOut');
        }
        if (OrkBL.aes2processUpdate.get('setEnteringInStrategiaError') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setEnteringInStrategiaError')); OrkBL.aes2processUpdate.remove('setEnteringInStrategiaError');
        }
        if (OrkBL.aes2processUpdate.get('setEnteringInStrategia') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setEnteringInStrategia'));
            OrkBL.aes2processUpdate.remove('setEnteringInStrategia');
        }
        if (OrkBL.getTaskFielsPermission('UPDATE')) {
            update aes2update;
        }
    }
    /*** 20210511 MSiotto/GMameli - Code Review - End ***/

    /*executeExit
    * il metodo esegue le verifiche sui task da elaborare, se per essi è soddisfata la condizione di usctia dalla strategia
    * eseguendo le strategie "Standard" per priorità,viene tenuto conto quali attività sono state lavorate e quali no tramite il set "taskProcessati"
    * Il metodo parte eseguendo una verifica della possibilità di elaborazione del task. Non conosce se qualcosa che lo ha lavorato prima lo ha escluso 
    * dalla attuale elaborazione.
    */
    /*  public static void executeExit(String token, Map<String, Task> tMap, Map<String, Pratica__c> pMap, Map<Id, SObject> sobjectsToUpdate, List<SObject> sobjectsToInsert, List<Log__c> logL, Map<Id, ActivityExtended__c> filteredTsksActsExtMap) {
          Boolean result = false;
          Pratica__c praticaToUpdate = new Pratica__c();
          Pratica__c pratica = new Pratica__c();
          Map<Id, String> idEsitoForAffidamento = new Map<Id, String>();
          Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();

          if (filteredTsksActsExtMap == null) {
              task2Obj = Utils.getTaskWithActivityExtended(tMap.values());
          } else {
              task2Obj = filteredTsksActsExtMap;
          }

          for (String s : tMap.keySet()) {
              Task t = tMap.get(s);
              ActivityExtended__c ae = task2Obj.get(t.Id);
              if (!OrkBL.isTaskForExit(t)) {
                  t.Description += '\n _NoExit1';
                  continue;
              }
              //viene inserita la data dell'ultimo check sulle condizioni di uscita
              pratica = pMap.get(t.WhatId);
              praticaToUpdate = (Pratica__c) sobjectsToUpdate.get(t.WhatId);
              logL.add(ErrorClass.istanceError('ExecuteExit0', 'praticaToUpdate:' + praticaToUpdate));
              try {
                  logL.add(ErrorClass.istanceError('ExecuteExit1', 'OrkStatic:' + OrkStatic.cduPO));
                  if (OrkStatic.cduPO.get(ae.Id_Strategia__c) == null) continue;
                  t.Description += '\n Verificando le condizioni di uscita';
                  for (Id idcdu : OrkStatic.cduPO.get(ae.Id_Strategia__c)) {
                      Strategia__c cdu = OrkStatic.strategies.get(idcdu);
                      t.Description += '\n CDU con nome:' + cdu.Nome__c;
                      result = OrkKernel.isRoleSatisfied(pratica, cdu, logL, t, task2Obj);
                      logL.add(ErrorClass.istanceError('ExecuteExit2', 'OrkKernel result:' + result));
                      t.Description += ' ' + result;
                      praticaToUpdate.Last_exit_check__c = System.now();//Scrive sulla pratica la data ell'ultima verifica delle condizioni di uscita

                      if (result == null) {
                          OrkBL.setExitError(t, ae); t.Description += '\n executeExit Error: result null' + 'CDU:' + cdu.Nome__c;
                      }
                      if (result) {
                          OrkBL.setExitSuccess(t, ae, pratica, cdu, sobjectsToUpdate, sobjectsToInsert, logL);
                          t.Description += '\n executeExit success: CDU:' + cdu.Nome__c;
                          if (ae.id_affidamento__c != null) {
                              idEsitoForAffidamento.put(ae.id_affidamento__c, cdu.Esito__c);
                          }
                          break; // viene fatto break perché è sufficiente che una condizione sia stat verificata
                      }
                  }
                  sobjectsToUpdate.put(praticaToUpdate.id, praticaToUpdate);
                  if (!result) t.Description += '\n _NoExit2';

              } catch (Exception e) {
                  t.Status = 'Error';t.Description = '\n fatal error OrkKernel.executeExit:' + e.getMessage() + e.getLineNumber() + '\n ' + e.getStackTraceString();
                  logL.add(ErrorClass.istanceError('ExitException', 'E:' + e + e.getLineNumber() + '\n ' + e.getStackTraceString()));
              }
          }
          if (OrkBL.aes2processUpdate == null) return;
          List<ActivityExtended__c> aes2update = new List<ActivityExtended__c>();
          if (OrkBL.aes2processUpdate.get('isTaskForExit') != null) {
              aes2update.addAll(OrkBL.aes2processUpdate.get('isTaskForExit'));OrkBL.aes2processUpdate.remove('isTaskForExit');
          }
          if (OrkBL.aes2processUpdate.get('setExitError') != null) {
              aes2update.addAll(OrkBL.aes2processUpdate.get('setExitError'));OrkBL.aes2processUpdate.remove('setExitError');
          }
          if (OrkBL.aes2processUpdate.get('setExitSuccess') != null) {
              aes2update.addAll(OrkBL.aes2processUpdate.get('setExitSuccess'));OrkBL.aes2processUpdate.remove('setExitSuccess');
          }
          if (OrkBL.getTaskFielsPermission('UPDATE')) update aes2update;
          if (idEsitoForAffidamento.size() > 0) AffidamentiManager.revocaListAffidamentiUscitaStrategia(idEsitoForAffidamento);
      }
  */
    /*** 20210512 GMameli/MSiotto - Code Review - Start ***/
    /*executeExit
* il metodo esegue le verifiche sui task da elaborare, se per essi è soddisfata la condizione di usctia dalla strategia
* eseguendo le strategie "Standard" per priorità,viene tenuto conto quali attività sono state lavorate e quali no tramite il set "taskProcessati"
* Il metodo parte eseguendo una verifica della possibilità di elaborazione del task. Non conosce se qualcosa che lo ha lavorato prima lo ha escluso
* dalla attuale elaborazione.
*/
    public static void cebExecuteExit(Map<String, Schema.SObjectType> globalDesc, String token, Map<String, Task> tMap, Map<String, Pratica__c> pMap, Map<Id, SObject> sobjectsToUpdate, List<SObject> sobjectsToInsert, List<Log__c> logL, Map<Id, ActivityExtended__c> filteredTsksActsExtMap) {
        Boolean result = false;
        Pratica__c praticaToUpdate = new Pratica__c();
        Pratica__c pratica = new Pratica__c();
        Map<Id, String> idEsitoForAffidamento = new Map<Id, String>();
        Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();

        if (filteredTsksActsExtMap == null) {
            task2Obj = Utils.cebGetTaskWithActivityExtended(tMap.values(), globalDesc);
        } else {
            task2Obj = filteredTsksActsExtMap;
        }

        for (String s : tMap.keySet()) {
            Task t = tMap.get(s);
            ActivityExtended__c ae = task2Obj.get(t.Id);
            if (!OrkBL.isTaskForExit(t)) {
                t.Description += '\n _NoExit1';
                continue;
            }
            //viene inserita la data dell'ultimo check sulle condizioni di uscita
            pratica = pMap.get(t.WhatId);
            praticaToUpdate = (Pratica__c) sobjectsToUpdate.get(t.WhatId);
            logL.add(ErrorClass.istanceError('ExecuteExit0', 'praticaToUpdate:' + praticaToUpdate));
            try {
                logL.add(ErrorClass.istanceError('ExecuteExit1', 'OrkStatic:' + OrkStatic.cduPO));
                if (OrkStatic.cduPO.get(ae.Id_Strategia__c) == null) continue;
                t.Description += '\n Verificando le condizioni di uscita';
                for (Id idcdu : OrkStatic.cduPO.get(ae.Id_Strategia__c)) {
                    Strategia__c cdu = OrkStatic.strategies.get(idcdu);
                    t.Description += '\n CDU con nome:' + cdu.Nome__c;
                    result = OrkKernel.isRoleSatisfied(pratica, cdu, logL, t, task2Obj);
                    logL.add(ErrorClass.istanceError('ExecuteExit2', 'OrkKernel result:' + result));
                    t.Description += ' ' + result;
                    praticaToUpdate.Last_exit_check__c = System.now();//Scrive sulla pratica la data ell'ultima verifica delle condizioni di uscita

                    if (result == null) {
                        OrkBL.setExitError(t, ae); t.Description += '\n executeExit Error: result null' + 'CDU:' + cdu.Nome__c;
                    }
                    if (result) {
                        OrkBL.setExitSuccess(t, ae, pratica, cdu, sobjectsToUpdate, sobjectsToInsert, logL);
                        t.Description += '\n executeExit success: CDU:' + cdu.Nome__c;
                        if (ae.id_affidamento__c != null) {
                            idEsitoForAffidamento.put(ae.id_affidamento__c, cdu.Esito__c);
                        }
                        break; // viene fatto break perché è sufficiente che una condizione sia stat verificata
                    }
                }
                sobjectsToUpdate.put(praticaToUpdate.id, praticaToUpdate);
                if (!result) t.Description += '\n _NoExit2';

            } catch (Exception e) {
                t.Status = 'Error'; t.Description = '\n fatal error OrkKernel.executeExit:' + e.getMessage() + e.getLineNumber() + '\n ' + e.getStackTraceString();
                logL.add(ErrorClass.istanceError('ExitException', 'E:' + e + e.getLineNumber() + '\n ' + e.getStackTraceString()));
            }
        }
        if (OrkBL.aes2processUpdate == null) return;
        List<ActivityExtended__c> aes2update = new List<ActivityExtended__c>();
        if (OrkBL.aes2processUpdate.get('isTaskForExit') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('isTaskForExit')); OrkBL.aes2processUpdate.remove('isTaskForExit');
        }
        if (OrkBL.aes2processUpdate.get('setExitError') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setExitError')); OrkBL.aes2processUpdate.remove('setExitError');
        }
        if (OrkBL.aes2processUpdate.get('setExitSuccess') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setExitSuccess')); OrkBL.aes2processUpdate.remove('setExitSuccess');
        }
        //if (OrkBL.getTaskFielsPermission('UPDATE')) update aes2update;
        //if (idEsitoForAffidamento.size() > 0) AffidamentiManager.revocaListAffidamentiUscitaStrategia(idEsitoForAffidamento);
        if (OrkBL.cebGetTaskFielsPermission(globalDesc, 'UPDATE')) {
            update aes2update;
        }
        if (idEsitoForAffidamento.size() > 0) AffidamentiManager.cebRevocaListAffidamentiUscitaStrategia(idEsitoForAffidamento, globalDesc);
    }
    /*** 20210512 GMameli/MSiotto - Code Review - End ***/

    /*executejump
    * il metodo esegue le verifiche sui task da elaborare, e verifica se ci sono salti da eseguire. Viene gestita la priorità e le attività con priorità successiva
    * vengono elaborate, solo se non sono stati eseguiti degli jump con maggiore priorità
    */
    /* public static void executeJump(string token, Map<string, Task> tMap, Map<string, Pratica__c> pMap, Map<id, Sobject> sobjectsToUpdate, List<Sobject> sobjectsToInsert, List<Log__c> logL, Map<Id, ActivityExtended__c> filteredTsksActsExtMap) {
         boolean result = false;
         set<id> taskProcessed = new set<id>();
         integer prioritylevel, priorityElement;
         strategia__c jump = new strategia__c();
         Pratica__c pratica = new pratica__c();
         pratica__c praticaToUpdate = new pratica__c();
         Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();

         if (filteredTsksActsExtMap == null) {
             task2Obj = Utils.getTaskWithActivityExtended(tMap.values());
         } else {
             task2Obj = filteredTsksActsExtMap;
         }

         for (string s : tMap.keyset()) {
             Task t = tMap.get(s);
             ActivityExtended__c ae = task2Obj.get(t.Id);
             //if(!OrkBL.isTaskForJump(t)){
             if (!OrkBL.isTaskForJump(t, ae)) {
                 t.Description += '\n NoJump_isTaskForJump';
                 continue;
             }
             try {
                 if (OrkStatic.jSPO.get(ae.id_attivita__c) == null) { //verifica se ci sono jump associati al record

                     t.Description += '\n NoJump_NoJumpActivities';
                     continue;
                 }
                 pratica = pMap.get(t.whatId);
                 praticaToUpdate = (pratica__C) sobjectsToUpdate.get(t.whatID);

                 for (id idjump : OrkStatic.jSPO.get(ae.id_attivita__c)) {
                     jump = OrkStatic.strategies.get(idjump);
                     *//*
                    * questo verifica se passare al prossimo livello di prioritÃ . 
                    * Se il task Ã¨ lavorato, ed abbiamo cambiato livello, allora fa break e esce
                    * diversamente setta il prossimo livello ed esegue 
                    *//*
                    priorityElement = integer.valueof(jump.priority__c);
                    if (taskProcessed.contains(t.id) && prioritylevel != priorityElement) break; else if (prioritylevel != priorityElement) prioritylevel = priorityElement;

                    t.Description += '\n Saltata con nome:' + jump.Nome__c + 'result:' + result;
                    result = OrkKernel.isRoleSatisfied(pratica, jump, logL, t, task2Obj);
                    t.Description += '\n Risultato:' + 'result:' + result;

                    if (result == null) {
                        OrkBL.setJumpError(t);
                        t.Description += '\n executeJump Error: result null' + 'jump:' + jump.Nome__c;
                        taskProcessed.add(t.id);
                    } else if (result) {
                        OrkBL.setJumpSuccess(t, ae, pratica, jump, sobjectsToUpdate, sobjectsToInsert, logL);
                        if (OrkStatic.strategies.get(jump.jump_to__c) != null) {
                            t.Description += '\n executeJump success: jump:' + jump.id;
                            sobjectsToInsert.addAll(OrkBL.newTaskFromJump(t, pratica, OrkStatic.strategies.get(jump.jump_to__c)));
                        } else {
                            *//*** 20201216 MSala - Gestione Salti senza nuovo task ***//*
                            t.Description += '\n executeJump success: jump: ' + jump.id + ' - NO NEW TASK';
                        }
                        taskProcessed.add(t.id);
                    }
                }
                sobjectsToUpdate.put(praticaToUpdate.id, praticaToUpdate);
                if (!taskProcessed.contains(t.id)) t.Description += '_NoJump3';//serve per definire il percorso eseguito dal record
            } catch (Exception e) {
                t.status = 'Error';
                t.description = '\n fatal error OrkKernel.executeJump:' + e.getMessage() + e.getLinenumber() + '\n ' + e.getStackTraceString();
                logL.add(errorClass.istanceError('JumpException', 'E:' + e + '\n linenumber ' + e.getLinenumber() + '\n ' + e.getStackTraceString()));
            }
        }
        if (OrkBL.aes2processUpdate == null) return;
        List<ActivityExtended__c> aes2update = new List<ActivityExtended__c>();
        if (OrkBL.aes2processUpdate.get('isTaskForJump') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('isTaskForJump'));
            OrkBL.aes2processUpdate.remove('isTaskForJump');
        }
        if (OrkBL.aes2processUpdate.get('setJumpError') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setJumpError'));
            OrkBL.aes2processUpdate.remove('setJumpError');
        }
        if (OrkBL.aes2processUpdate.get('setJumpSuccess') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setJumpSuccess'));
            OrkBL.aes2processUpdate.remove('setJumpSuccess');
        }
        *//*** 20201223 MSala - Unique AE Update - Start ***//*
        Map<Id, ActivityExtended__c> uniqAes = new Map<Id, ActivityExtended__c>();
        for (ActivityExtended__c tmp : aes2update) {
            uniqAes.put(tmp.id, tmp);
        }
        if (OrkBL.getTaskFielsPermission('UPDATE')) update uniqAes.values();
        //if (OrkBL.getTaskFielsPermission('UPDATE')) update aes2update;
        *//*** 20201223 MSala - Unique AE Update - End ***//*
    }
*/
    /*** 20210512 GMameli/MSiotto - Code Review - Start ***/
    /*executejump
* il metodo esegue le verifiche sui task da elaborare, e verifica se ci sono salti da eseguire. Viene gestita la priorità e le attività con priorità successiva
* vengono elaborate, solo se non sono stati eseguiti degli jump con maggiore priorità
*/
    public static void cebExecuteJump(Map<String, Schema.SObjectType> globalDesc, string token, Map<string, Task> tMap, Map<string, Pratica__c> pMap, Map<id, Sobject> sobjectsToUpdate, List<Sobject> sobjectsToInsert, List<Log__c> logL, Map<Id, ActivityExtended__c> filteredTsksActsExtMap) {
        boolean result = false;
        set<id> taskProcessed = new set<id>();
        integer prioritylevel, priorityElement;
        strategia__c jump = new strategia__c();
        Pratica__c pratica = new pratica__c();
        pratica__c praticaToUpdate = new pratica__c();
        Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();

        if (filteredTsksActsExtMap == null) {
            task2Obj = Utils.cebGetTaskWithActivityExtended(tMap.values(), globalDesc);
        } else {
            task2Obj = filteredTsksActsExtMap;
        }

        for (string s : tMap.keyset()) {
            Task t = tMap.get(s);
            if (t.Status != 'Lavorata' && CEBUtils.newOrkVersionEnabled()) {
                t.Description += '\n NoJump_isTaskForJump';
                continue;
            } else {
                ActivityExtended__c ae = task2Obj.get(t.Id);
                //if(!OrkBL.isTaskForJump(t)){
                if (!OrkBL.isTaskForJump(t, ae)) {
                    t.Description += '\n NoJump_isTaskForJump';
                    continue;
                }
                try {
                    if (OrkStatic.jSPO.get(ae.id_attivita__c) == null) { //verifica se ci sono jump associati al record

                        t.Description += '\n NoJump_NoJumpActivities';
                        continue;
                    }
                    pratica = pMap.get(t.whatId);
                    praticaToUpdate = (pratica__C) sobjectsToUpdate.get(t.whatID);

                    for (id idjump : OrkStatic.jSPO.get(ae.id_attivita__c)) {
                        jump = OrkStatic.strategies.get(idjump);
                        /*
                        * questo verifica se passare al prossimo livello di prioritÃ .
                        * Se il task Ã¨ lavorato, ed abbiamo cambiato livello, allora fa break e esce
                        * diversamente setta il prossimo livello ed esegue
                        */
                        priorityElement = integer.valueof(jump.priority__c);
                        if (taskProcessed.contains(t.id) && prioritylevel != priorityElement) break;
                        else if (prioritylevel != priorityElement) prioritylevel = priorityElement;

                        t.Description += '\n Saltata con nome:' + jump.Nome__c + 'result:' + result;
                        result = OrkKernel.isRoleSatisfied(pratica, jump, logL, t, task2Obj);
                        t.Description += '\n Risultato:' + 'result:' + result;

                        if (result == null) {
                            OrkBL.setJumpError(t);
                            t.Description += '\n executeJump Error: result null' + 'jump:' + jump.Nome__c;
                            taskProcessed.add(t.id);
                        } else if (result) {
                            OrkBL.setJumpSuccess(t, ae, pratica, jump, sobjectsToUpdate, sobjectsToInsert, logL);
                            if (OrkStatic.strategies.get(jump.jump_to__c) != null) {
                                t.Description += '\n executeJump success: jump:' + jump.id;
                                sobjectsToInsert.addAll(OrkBL.newTaskFromJump(t, pratica, OrkStatic.strategies.get(jump.jump_to__c)));
                            } else {
                                /*** 20201216 MSala - Gestione Salti senza nuovo task ***/
                                t.Description += '\n executeJump success: jump: ' + jump.id + ' - NO NEW TASK';
                            }
                            taskProcessed.add(t.id);
                        }
                    }
                    sobjectsToUpdate.put(praticaToUpdate.id, praticaToUpdate);
                    if (!taskProcessed.contains(t.id)) t.Description += '_NoJump3';//serve per definire il percorso eseguito dal record
                } catch (Exception e) {
                    t.status = 'Error';
                    t.description = '\n fatal error OrkKernel.executeJump:' + e.getMessage() + e.getLinenumber() + '\n ' + e.getStackTraceString();
                    logL.add(errorClass.istanceError('JumpException', 'E:' + e + '\n linenumber ' + e.getLinenumber() + '\n ' + e.getStackTraceString()));
                }
            }
        }
        if (OrkBL.aes2processUpdate == null) return;
        List<ActivityExtended__c> aes2update = new List<ActivityExtended__c>();
        if (OrkBL.aes2processUpdate.get('isTaskForJump') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('isTaskForJump'));
            OrkBL.aes2processUpdate.remove('isTaskForJump');
        }
        if (OrkBL.aes2processUpdate.get('setJumpError') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setJumpError'));
            OrkBL.aes2processUpdate.remove('setJumpError');
        }
        if (OrkBL.aes2processUpdate.get('setJumpSuccess') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setJumpSuccess'));
            OrkBL.aes2processUpdate.remove('setJumpSuccess');
        }
        /*** 20201223 MSala - Unique AE Update - Start ***/
        Map<Id, ActivityExtended__c> uniqAes = new Map<Id, ActivityExtended__c>();
        for (ActivityExtended__c tmp : aes2update) {
            uniqAes.put(tmp.id, tmp);
        }
        //if (OrkBL.getTaskFielsPermission('UPDATE')) update uniqAes.values();
        if (OrkBL.cebGetTaskFielsPermission(globalDesc, 'UPDATE')) update uniqAes.values();
        //if (OrkBL.getTaskFielsPermission('UPDATE')) update aes2update;
        /*** 20201223 MSala - Unique AE Update - End ***/
    }
    /*** 20210512 GMameli/MSiotto - Code Review - End ***/

    /*** 20210622 MSiotto - Step field Update if a new task is created - Start ***/
    /*executejump
* il metodo esegue le verifiche sui task da elaborare, e verifica se ci sono salti da eseguire. Viene gestita la priorità e le attività con priorità successiva
* vengono elaborate, solo se non sono stati eseguiti degli jump con maggiore priorità
*/
    public static void cebExecuteJump(Map<String, SObject> objectForPraticaMap, Map<String, Schema.SObjectType> globalDesc, string token, Map<string, Task> tMap, Map<string, Pratica__c> pMap, Map<id, Sobject> sobjectsToUpdate, List<Sobject> sobjectsToInsert, List<Log__c> logL, Map<Id, ActivityExtended__c> filteredTsksActsExtMap) {
        boolean result = false;
        set<id> taskProcessed = new set<id>();
        integer prioritylevel, priorityElement;
        strategia__c jump = new strategia__c();
        Pratica__c pratica = new pratica__c();
        //pratica__c praticaToUpdate = new pratica__c();
        Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();

        if (filteredTsksActsExtMap == null) {
            task2Obj = Utils.cebGetTaskWithActivityExtended(tMap.values(), globalDesc);
        } else {
            task2Obj = filteredTsksActsExtMap;
        }

        for (string s : tMap.keyset()) {
            Task t = tMap.get(s);
            if (t.Status != 'Lavorata' && CEBUtils.newOrkVersionEnabled()) {
                t.Description += '\n NoJump_isTaskForJump';
                continue;
            } else {
                ActivityExtended__c ae = task2Obj.get(t.Id);
                //if(!OrkBL.isTaskForJump(t)){
                if (!OrkBL.isTaskForJump(t, ae)) {
                    t.Description += '\n NoJump_isTaskForJump';
                    continue;
                }
                try {
                    if (OrkStatic.jSPO.get(ae.id_attivita__c) == null) { //verifica se ci sono jump associati al record

                        t.Description += '\n NoJump_NoJumpActivities';
                        continue;
                    }
                    pratica = pMap.get(t.whatId);
                    //praticaToUpdate = (pratica__C) sobjectsToUpdate.get(t.whatID);

                    for (id idjump : OrkStatic.jSPO.get(ae.id_attivita__c)) {
                        jump = OrkStatic.strategies.get(idjump);
                        /*
                        * questo verifica se passare al prossimo livello di prioritÃ .
                        * Se il task Ã¨ lavorato, ed abbiamo cambiato livello, allora fa break e esce
                        * diversamente setta il prossimo livello ed esegue
                        */
                        priorityElement = integer.valueof(jump.priority__c);
                        if (taskProcessed.contains(t.id) && prioritylevel != priorityElement) break;
                        else if (prioritylevel != priorityElement) prioritylevel = priorityElement;

                        t.Description += '\n Saltata con nome:' + jump.Nome__c + 'result:' + result;
                        result = OrkKernel.isRoleSatisfied(pratica, jump, logL, t, task2Obj);
                        t.Description += '\n Risultato:' + 'result:' + result;

                        if (result == null) {
                            OrkBL.setJumpError(t);
                            t.Description += '\n executeJump Error: result null' + 'jump:' + jump.Nome__c;
                            taskProcessed.add(t.id);
                        } else if (result) {
                            OrkBL.setJumpSuccess(t, ae, pratica, jump, sobjectsToUpdate, sobjectsToInsert, logL);
                            if (OrkStatic.strategies.get(jump.jump_to__c) != null) {
                                t.Description += '\n executeJump success: jump:' + jump.id;
                                sobjectsToInsert.addAll(OrkBL.newSetTaskFromJump(objectForPraticaMap, sobjectsToUpdate, t, pratica, OrkStatic.strategies.get(jump.jump_to__c)));
                            } else {
                                /*** 20201216 MSala - Gestione Salti senza nuovo task ***/
                                t.Description += '\n executeJump success: jump: ' + jump.id + ' - NO NEW TASK';
                            }
                            taskProcessed.add(t.id);
                        }
                    }
                    //sobjectsToUpdate.put(praticaToUpdate.id, praticaToUpdate);
                    if (!taskProcessed.contains(t.id)) t.Description += '_NoJump3';//serve per definire il percorso eseguito dal record
                } catch (Exception e) {
                    t.status = 'Error';
                    t.description = '\n fatal error OrkKernel.executeJump:' + e.getMessage() + e.getLinenumber() + '\n ' + e.getStackTraceString();
                    logL.add(errorClass.istanceError('JumpException', 'E:' + e + '\n linenumber ' + e.getLinenumber() + '\n ' + e.getStackTraceString()));
                }
            }
        }
        if (OrkBL.aes2processUpdate == null) return;
        List<ActivityExtended__c> aes2update = new List<ActivityExtended__c>();
        if (OrkBL.aes2processUpdate.get('isTaskForJump') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('isTaskForJump'));
            OrkBL.aes2processUpdate.remove('isTaskForJump');
        }
        if (OrkBL.aes2processUpdate.get('setJumpError') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setJumpError'));
            OrkBL.aes2processUpdate.remove('setJumpError');
        }
        if (OrkBL.aes2processUpdate.get('setJumpSuccess') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setJumpSuccess'));
            OrkBL.aes2processUpdate.remove('setJumpSuccess');
        }
        /*** 20201223 MSala - Unique AE Update - Start ***/
        Map<Id, ActivityExtended__c> uniqAes = new Map<Id, ActivityExtended__c>();
        for (ActivityExtended__c tmp : aes2update) {
            uniqAes.put(tmp.id, tmp);
        }
        //if (OrkBL.getTaskFielsPermission('UPDATE')) update uniqAes.values();
        if (OrkBL.cebGetTaskFielsPermission(globalDesc, 'UPDATE')) update uniqAes.values();
        //if (OrkBL.getTaskFielsPermission('UPDATE')) update aes2update;
        /*** 20201223 MSala - Unique AE Update - End ***/
    }
    /*** 20210622 MSiotto - Step field Update if a new task is created - End ***/

    /*executeLoop
    * il metodo esegue le verifiche sui task da elaborare, e verifica se ci sono salti automatici da eseguire.
    */
    /*  public static void executeLoop(string token, Map<string, Task> tMap, Map<string, Pratica__c> pMap, Map<id, Sobject> sobjectsToUpdate, List<Sobject> sobjectsToInsert, List<Log__c> logL, Map<Id, ActivityExtended__c> filteredTsksActsExtMap) {
          boolean result = false;
          set<id> taskProcessed = new set<id>();
          integer prioritylevel, priorityElement;
          strategia__c jump = new strategia__c();
          Pratica__c pratica = new pratica__c();
          pratica__c praticaToUpdate = new pratica__c();
          Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();

          if (filteredTsksActsExtMap == null) {
              task2Obj = Utils.getTaskWithActivityExtended(tMap.values());
          } else {
              task2Obj = filteredTsksActsExtMap;
          }

          for (string s : tMap.keyset()) {
              Task t = tMap.get(s);
              ActivityExtended__c ae = task2Obj.get(t.Id);
              if (!OrkBL.isTaskForLoop(t)) {
                  t.Description += '\n _NOLoop_isTaskForLoop';
                  continue;
              }
              pratica = pMap.get(t.whatId);
              praticaToUpdate = (pratica__C) sobjectsToUpdate.get(t.whatID);

              if (OrkStatic.jAPO.get(ae.id_attivita__c) == null) {
                  t.Description += '\n _NOLoop_noLoopActivities';
                  continue;
              }
              try {
                  for (id idjump : OrkStatic.jAPO.get(ae.id_attivita__c)) {
                      jump = OrkStatic.strategies.get(idjump);
                      priorityElement = integer.valueof(jump.priority__c);
                      if (taskProcessed.contains(t.id) && prioritylevel != priorityElement) break; else if (prioritylevel != priorityElement) prioritylevel = priorityElement;

                      t.Description += '\n JumpAutomatico con nome:' + jump.Nome__c;
                      result = OrkKernel.isRoleSatisfied(pratica, jump, logl, t, task2Obj);
                      if (result == null) {
                          OrkBL.setLoopError(t);
                          t.Description += '\n executeLoop Error: result null' + 'jump:' + jump.nome__c;
                          taskProcessed.add(t.id);
                      } else if (result) {
                          OrkBL.setLoopSuccess(t, ae, pratica, jump, sobjectsToUpdate, sobjectsToInsert, logL);
                          if (OrkStatic.strategies.get(jump.jump_to__c) != null) {
                              strategia__c taskToJump = OrkStatic.strategies.get(jump.jump_to__c);
                              t.Description += '\n executeLoop Success:jumpAutomatico:' + jump.nome__c;
                              taskProcessed.add(t.id);
                              sobjectsToInsert.addAll(OrkBL.newTaskFromJump(t, pratica, taskToJump));
                          } else {
                              *//*** 20201216 MSala - Gestione Salti senza nuovo task ***//*
                            t.Description += '\n executeLoop Success:jumpAutomatico: ' + jump.nome__c + ' - NO NEW TASK';
                            taskProcessed.add(t.id);
                        }
                    }
                }
                sobjectsToUpdate.put(praticaToUpdate.id, praticaToUpdate);
                if (!taskProcessed.contains(t.id)) t.Description += '\n _NOLoop_NessunaCondizioneSoddisfata';
            } catch (Exception e) {
                t.status = 'Error';t.description = '\n fatal error OrkKernel.executeLoop:' + e.getMessage() + e.getLinenumber() + '\n ' + e.getStackTraceString();logL.add(errorClass.istanceError('JumpAutomaticoException', 'E:' + e + '\n linenumber ' + e.getLinenumber() + '\n ' + e.getStackTraceString()));
            }
        }
        if (OrkBL.aes2processUpdate == null) return;
        List<ActivityExtended__c> aes2update = new List<ActivityExtended__c>();
        if (OrkBL.aes2processUpdate.get('isTaskForLoop') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('isTaskForLoop'));
            OrkBL.aes2processUpdate.remove('isTaskForLoop');
        }
        if (OrkBL.aes2processUpdate.get('setLoopSuccess') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setLoopSuccess'));
            OrkBL.aes2processUpdate.remove('setLoopSuccess');
        }
        *//*** 20201223 MSala - Unique AE Update - Start ***//*
        Map<Id, ActivityExtended__c> uniqAes = new Map<Id, ActivityExtended__c>();
        for (ActivityExtended__c tmp : aes2update) {
            uniqAes.put(tmp.id, tmp);
        }
        if (OrkBL.getTaskFielsPermission('UPDATE')) update uniqAes.values();
        //if (OrkBL.getTaskFielsPermission('UPDATE')) update aes2update;
        *//*** 20201223 MSala - Unique AE Update - End ***//*
    }
*/
    /*** 20210512 GMameli/MSiotto - Code Review - Start ***/
    /*executeLoop
* il metodo esegue le verifiche sui task da elaborare, e verifica se ci sono salti automatici da eseguire.
*/
    public static void cebExecuteLoop(Map<String, Schema.SObjectType> globalDesc, string token, Map<string, Task> tMap, Map<string, Pratica__c> pMap, Map<id, Sobject> sobjectsToUpdate, List<Sobject> sobjectsToInsert, List<Log__c> logL, Map<Id, ActivityExtended__c> filteredTsksActsExtMap) {
        boolean result = false;
        set<id> taskProcessed = new set<id>();
        integer prioritylevel, priorityElement;
        strategia__c jump = new strategia__c();
        Pratica__c pratica = new pratica__c();
        pratica__c praticaToUpdate = new pratica__c();
        Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();

        if (filteredTsksActsExtMap == null) {
            task2Obj = Utils.cebGetTaskWithActivityExtended(tMap.values(), globalDesc);
        } else {
            task2Obj = filteredTsksActsExtMap;
        }

        for (string s : tMap.keyset()) {
            Task t = tMap.get(s);
            ActivityExtended__c ae = task2Obj.get(t.Id);
            if (!OrkBL.isTaskForLoop(t)) {
                t.Description += '\n _NOLoop_isTaskForLoop';
                continue;
            }
            pratica = pMap.get(t.whatId);
            praticaToUpdate = (pratica__C) sobjectsToUpdate.get(t.whatID);

            if (OrkStatic.jAPO.get(ae.id_attivita__c) == null) {
                t.Description += '\n _NOLoop_noLoopActivities';
                continue;
            }
            try {
                for (id idjump : OrkStatic.jAPO.get(ae.id_attivita__c)) {
                    jump = OrkStatic.strategies.get(idjump);
                    priorityElement = integer.valueof(jump.priority__c);
                    if (taskProcessed.contains(t.id) && prioritylevel != priorityElement) break;
                    else if (prioritylevel != priorityElement) prioritylevel = priorityElement;

                    t.Description += '\n JumpAutomatico con nome:' + jump.Nome__c;
                    result = OrkKernel.isRoleSatisfied(pratica, jump, logl, t, task2Obj);
                    if (result == null) {
                        OrkBL.setLoopError(t);
                        t.Description += '\n executeLoop Error: result null' + 'jump:' + jump.nome__c;
                        taskProcessed.add(t.id);
                    } else if (result) {
                        OrkBL.setLoopSuccess(t, ae, pratica, jump, sobjectsToUpdate, sobjectsToInsert, logL);
                        if (OrkStatic.strategies.get(jump.jump_to__c) != null) {
                            strategia__c taskToJump = OrkStatic.strategies.get(jump.jump_to__c);
                            t.Description += '\n executeLoop Success:jumpAutomatico:' + jump.nome__c;
                            taskProcessed.add(t.id);
                            sobjectsToInsert.addAll(OrkBL.newTaskFromJump(t, pratica, taskToJump));
                        } else {
                            /*** 20201216 MSala - Gestione Salti senza nuovo task ***/
                            t.Description += '\n executeLoop Success:jumpAutomatico: ' + jump.nome__c + ' - NO NEW TASK';
                            taskProcessed.add(t.id);
                        }
                    }
                }
                sobjectsToUpdate.put(praticaToUpdate.id, praticaToUpdate);
                if (!taskProcessed.contains(t.id)) t.Description += '\n _NOLoop_NessunaCondizioneSoddisfata';
            } catch (Exception e) {
                t.status = 'Error'; t.description = '\n fatal error OrkKernel.executeLoop:' + e.getMessage() + e.getLinenumber() + '\n ' + e.getStackTraceString(); logL.add(errorClass.istanceError('JumpAutomaticoException', 'E:' + e + '\n linenumber ' + e.getLinenumber() + '\n ' + e.getStackTraceString()));
            }
        }
        if (OrkBL.aes2processUpdate == null) return;
        List<ActivityExtended__c> aes2update = new List<ActivityExtended__c>();
        if (OrkBL.aes2processUpdate.get('isTaskForLoop') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('isTaskForLoop'));
            OrkBL.aes2processUpdate.remove('isTaskForLoop');
        }
        if (OrkBL.aes2processUpdate.get('setLoopSuccess') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setLoopSuccess'));
            OrkBL.aes2processUpdate.remove('setLoopSuccess');
        }
        /*** 20201223 MSala - Unique AE Update - Start ***/
        Map<Id, ActivityExtended__c> uniqAes = new Map<Id, ActivityExtended__c>();
        for (ActivityExtended__c tmp : aes2update) {
            uniqAes.put(tmp.id, tmp);
        }
        //if (OrkBL.getTaskFielsPermission('UPDATE')) update uniqAes.values();
        if (OrkBL.cebGetTaskFielsPermission(globalDesc, 'UPDATE')) update uniqAes.values();
        //if (OrkBL.getTaskFielsPermission('UPDATE')) update aes2update;
        /*** 20201223 MSala - Unique AE Update - End ***/
    }
    /*** 20210512 GMameli/MSiotto - Code Review - End ***/

    /*** 20210622 MSiotto - Step field Update if a new task is created - Start ***/
    /*executeLoop
* il metodo esegue le verifiche sui task da elaborare, e verifica se ci sono salti automatici da eseguire.
*/
    public static void cebExecuteLoop(Map<String, SObject> objectForPraticaMap, Map<String, Schema.SObjectType> globalDesc, string token, Map<string, Task> tMap, Map<string, Pratica__c> pMap, Map<id, Sobject> sobjectsToUpdate, List<Sobject> sobjectsToInsert, List<Log__c> logL, Map<Id, ActivityExtended__c> filteredTsksActsExtMap) {
        boolean result = false;
        set<id> taskProcessed = new set<id>();
        integer prioritylevel, priorityElement;
        strategia__c jump = new strategia__c();
        Pratica__c pratica = new pratica__c();
        //pratica__c praticaToUpdate = new pratica__c();
        Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();

        if (filteredTsksActsExtMap == null) {
            task2Obj = Utils.cebGetTaskWithActivityExtended(tMap.values(), globalDesc);
        } else {
            task2Obj = filteredTsksActsExtMap;
        }

        for (string s : tMap.keyset()) {
            Task t = tMap.get(s);
            ActivityExtended__c ae = task2Obj.get(t.Id);

            if (!OrkBL.isTaskForLoop(t)) {
                t.Description += '\n _NOLoop_isTaskForLoop';
                continue;
            }
            pratica = pMap.get(t.whatId);
            //praticaToUpdate = (pratica__C) sobjectsToUpdate.get(t.whatID);

            if (OrkStatic.jAPO.get(ae.id_attivita__c) == null) {
                t.Description += '\n _NOLoop_noLoopActivities';
                continue;
            }
            try {
                for (id idjump : OrkStatic.jAPO.get(ae.id_attivita__c)) {
                    jump = OrkStatic.strategies.get(idjump);
                    priorityElement = integer.valueof(jump.priority__c);
                    if (taskProcessed.contains(t.id) && prioritylevel != priorityElement) break;
                    else if (prioritylevel != priorityElement) prioritylevel = priorityElement;

                    t.Description += '\n JumpAutomatico con nome:' + jump.Nome__c;
                    result = OrkKernel.isRoleSatisfied(pratica, jump, logl, t, task2Obj);
                    if (result == null) {
                        OrkBL.setLoopError(t);
                        t.Description += '\n executeLoop Error: result null' + 'jump:' + jump.nome__c;
                        taskProcessed.add(t.id);
                    } else if (result) {
                        OrkBL.setLoopSuccess(t, ae, pratica, jump, sobjectsToUpdate, sobjectsToInsert, logL);
                        if (OrkStatic.strategies.get(jump.jump_to__c) != null) {
                            strategia__c taskToJump = OrkStatic.strategies.get(jump.jump_to__c);
                            t.Description += '\n executeLoop Success:jumpAutomatico:' + jump.nome__c;
                            taskProcessed.add(t.id);
                            //sobjectsToInsert.addAll(OrkBL.newTaskFromJump(t, pratica, taskToJump)); rimossa vecchia gestione
                            /**
                             rimosso provvisoriamente (verificare se è necessario usare sobjectsToInsert o sobjectsToUpdate per stepFieldUpdate negli executeLoop)
                             * Map<id, SObject> sobjectsToInsertMap = new Map<Id, Sobject>(sobjectsToInsert);
                             **/
                            sobjectsToInsert.addAll(OrkBL.newSetTaskFromJump(objectForPraticaMap, sobjectsToUpdate, t, pratica, taskToJump));
                        } else {
                            /*** 20201216 MSala - Gestione Salti senza nuovo task ***/
                            t.Description += '\n executeLoop Success:jumpAutomatico: ' + jump.nome__c + ' - NO NEW TASK';
                            taskProcessed.add(t.id);
                        }
                    }
                }
                //sobjectsToUpdate.put(praticaToUpdate.id, praticaToUpdate);
                if (!taskProcessed.contains(t.id)) t.Description += '\n _NOLoop_NessunaCondizioneSoddisfata';
            } catch (Exception e) {
                t.status = 'Error'; t.description = '\n fatal error OrkKernel.executeLoop:' + e.getMessage() + e.getLinenumber() + '\n ' + e.getStackTraceString(); logL.add(errorClass.istanceError('JumpAutomaticoException', 'E:' + e + '\n linenumber ' + e.getLinenumber() + '\n ' + e.getStackTraceString()));
            }
        }
        if (OrkBL.aes2processUpdate == null) return;
        List<ActivityExtended__c> aes2update = new List<ActivityExtended__c>();
        if (OrkBL.aes2processUpdate.get('isTaskForLoop') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('isTaskForLoop'));
            OrkBL.aes2processUpdate.remove('isTaskForLoop');
        }
        if (OrkBL.aes2processUpdate.get('setLoopSuccess') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setLoopSuccess'));
            OrkBL.aes2processUpdate.remove('setLoopSuccess');
        }
        /*** 20201223 MSala - Unique AE Update - Start ***/
        Map<Id, ActivityExtended__c> uniqAes = new Map<Id, ActivityExtended__c>();
        for (ActivityExtended__c tmp : aes2update) {
            uniqAes.put(tmp.id, tmp);
        }
        //if (OrkBL.getTaskFielsPermission('UPDATE')) update uniqAes.values();
        if (OrkBL.cebGetTaskFielsPermission(globalDesc, 'UPDATE')) update uniqAes.values();
        //if (OrkBL.getTaskFielsPermission('UPDATE')) update aes2update;
        /*** 20201223 MSala - Unique AE Update - End ***/
    }
    /*** 20210622 MSiotto - Step field Update if a new task is created - End ***/


    /*nextJob
     * il metodo istanzia le next activities da lavoare
     */
    /* public static void nextJob(string token, Map<string, Task> tMap, Map<string, Pratica__c> pMap, Map<id, Sobject> sobjectsToUpdate, List<Sobject> sobjectsToInsert, List<Log__c> logL, Map<Id, ActivityExtended__c> filteredTsksActsExtMap) {
         boolean result = false;
         integer prioritylevel, priorityElement;
         set<id> taskProcessed = new set<id>();
         Pratica__c pratica = new pratica__c();
         pratica__c praticaToUpdate = new pratica__c();
         Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();

         if (filteredTsksActsExtMap == null) {
             task2Obj = Utils.getTaskWithActivityExtended(tMap.values());
         } else {
             task2Obj = filteredTsksActsExtMap;
         }

         for (string r : tMap.Keyset()) {
             Task s = tMap.get(r);
             ActivityExtended__c ae = task2Obj.get(s.Id);

             if (s.Status != 'Lavorata') {
                 s.Description += '\n _NONextJob_Stato diverso da Lavorata';
                 continue;
             }
             pratica = pMap.get(s.whatId);
             praticaToUpdate = (pratica__C) sobjectsToUpdate.get(s.whatID);
             s.Description += '\n ae.id_attivita__c : ' + ae.id_attivita__c;
             if (OrkStatic.nSPO.get(ae.id_attivita__c) == null) {//significa che é un last activity per quel ramo
                 s.Description += '\n _NONextJob_Stato diverso da Lavorata - id_attivita__c null';
                 OrkBL.setNoNextStep(s);
                 continue;
             } else {
                 try {
                     for (id idst : OrkStatic.nSPO.get(ae.id_attivita__c)) {
                         Strategia__c st = OrkStatic.strategies.get(idst);
                         *//*
                        * questo verifica se passare al prossimo livello di prioritÃ . 
                        * Se il task é lavorato, ed abbiamo cambiato livello, allora fa break e esce
                        * diversamente setta il prossimo livello ed esegue 
                        *//*
                        priorityElement = integer.valueof(st.priority__c);
                        if (taskProcessed.contains(s.id) && prioritylevel != priorityElement) break; else if (prioritylevel != priorityElement) prioritylevel = priorityElement;

                        s.Description += '\n NextJob con nome:' + st.Nome__c;
                        result = OrkKernel.isRoleSatisfied(pratica, st, logL, s, task2Obj);
                        if (result == null) {
                            OrkBL.setNextStepError(s);
                            taskProcessed.add(s.id);
                            s.Description += '\n NextJob Error: result null' + 'nextJob:' + st.Nome__c;
                            break;
                        }
                        if (result) {
                            List<Sobject> nt = OrkBL.newTask(s, pratica, st, '');
                            OrkBL.setNextStep(s, ae, pratica, st, sobjectsToUpdate, sobjectsToInsert, logL);
                            taskProcessed.add(s.id);
                            s.Description += '\n NextJob success:' + 'nextJob:' + st.Nome__c;
                            sobjectsToInsert.addAll(nt);
                        }
                        sobjectsToUpdate.put(praticaToUpdate.id, praticaToUpdate);
                    }
                } catch (Exception e) {
                    s.status = 'Error';s.description = '\n fatal error OrkKernel.executeNextJob:' + e.getMessage() + e.getLinenumber() + '\n ' + e.getStackTraceString(); logL.add(errorClass.istanceError('JumpException', 'E:' + e + '\n' + e.getlinenumber() + '\n ' + e.getStackTraceString()));
                }
            }
        }
        if (OrkBL.aes2processUpdate == null) return;
        List<ActivityExtended__c> aes2update = new List<ActivityExtended__c>();
        if (OrkBL.aes2processUpdate.get('setNoNextStep') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setNoNextStep'));
            OrkBL.aes2processUpdate.remove('setNoNextStep');
        }
        if (OrkBL.aes2processUpdate.get('setNextStep') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setNextStep'));
            OrkBL.aes2processUpdate.remove('setNextStep');
        }
        //generate a unique list
        Map<Id, ActivityExtended__c> uniqAes = new Map<Id, ActivityExtended__c>();
        for (ActivityExtended__c tmp : aes2update) {
            uniqAes.put(tmp.id, tmp);
        }
        if (OrkBL.getTaskFielsPermission('UPDATE')) update uniqAes.values();
    }
    */
    /*** 20210512 GMameli/MSiotto - Code Review - Start ***/
    /*nextJob
    * il metodo istanzia le next activities da lavoare
    */
    public static void cebNextJob(Map<String, Schema.SObjectType> globalDesc, string token, Map<string, Task> tMap, Map<string, Pratica__c> pMap, Map<id, Sobject> sobjectsToUpdate, List<Sobject> sobjectsToInsert, List<Log__c> logL, Map<Id, ActivityExtended__c> filteredTsksActsExtMap) {
        boolean result = false;
        integer prioritylevel, priorityElement;
        set<id> taskProcessed = new set<id>();
        Pratica__c pratica = new pratica__c();
        pratica__c praticaToUpdate = new pratica__c();
        Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();

        if (filteredTsksActsExtMap == null) {
            task2Obj = Utils.cebGetTaskWithActivityExtended(tMap.values(), globalDesc);
        } else {
            task2Obj = filteredTsksActsExtMap;
        }

        for (string r : tMap.Keyset()) {
            Task s = tMap.get(r);
            ActivityExtended__c ae = task2Obj.get(s.Id);

            if (s.Status != 'Lavorata') {
                s.Description += '\n _NONextJob_Stato diverso da Lavorata';
                continue;
            }
            pratica = pMap.get(s.whatId);
            praticaToUpdate = (pratica__C) sobjectsToUpdate.get(s.whatID);
            s.Description += '\n ae.id_attivita__c : ' + ae.id_attivita__c;
            if (OrkStatic.nSPO.get(ae.id_attivita__c) == null) {//significa che é un last activity per quel ramo
                s.Description += '\n _NONextJob_Stato diverso da Lavorata - id_attivita__c null';
                OrkBL.setNoNextStep(s);
                continue;
            } else {
                try {
                    for (id idst : OrkStatic.nSPO.get(ae.id_attivita__c)) {
                        Strategia__c st = OrkStatic.strategies.get(idst);
                        /*
                        * questo verifica se passare al prossimo livello di prioritÃ .
                        * Se il task é lavorato, ed abbiamo cambiato livello, allora fa break e esce
                        * diversamente setta il prossimo livello ed esegue
                        */
                        priorityElement = integer.valueof(st.priority__c);
                        if (taskProcessed.contains(s.id) && prioritylevel != priorityElement) break;
                        else if (prioritylevel != priorityElement) prioritylevel = priorityElement;

                        s.Description += '\n NextJob con nome:' + st.Nome__c;
                        result = OrkKernel.isRoleSatisfied(pratica, st, logL, s, task2Obj);
                        if (result == null) {
                            OrkBL.setNextStepError(s);
                            taskProcessed.add(s.id);
                            s.Description += '\n NextJob Error: result null' + 'nextJob:' + st.Nome__c;
                            break;
                        }
                        if (result) {
                            /*** 20210527 MSala - Review Query Loop - Start ***/
                            //List<Sobject> nt = OrkBL.cebNewTask(globalDesc, s, pratica, st, '');
                            List<Sobject> nt = OrkBL.cebEngineNewTask(globalDesc, s, ae, pratica, st, '');
                            /*** 20210527 MSala - Review Query Loop - End ***/
                            OrkBL.setNextStep(s, ae, pratica, st, sobjectsToUpdate, sobjectsToInsert, logL);
                            taskProcessed.add(s.id);
                            s.Description += '\n NextJob success:' + 'nextJob:' + st.Nome__c;
                            sobjectsToInsert.addAll(nt);
                        }
                        sobjectsToUpdate.put(praticaToUpdate.id, praticaToUpdate);
                    }
                } catch (Exception e) {
                    s.status = 'Error'; s.description = '\n fatal error OrkKernel.executeNextJob:' + e.getMessage() + e.getLinenumber() + '\n ' + e.getStackTraceString(); logL.add(errorClass.istanceError('JumpException', 'E:' + e + '\n' + e.getlinenumber() + '\n ' + e.getStackTraceString()));
                }
            }
        }
        if (OrkBL.aes2processUpdate == null) return;
        List<ActivityExtended__c> aes2update = new List<ActivityExtended__c>();
        if (OrkBL.aes2processUpdate.get('setNoNextStep') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setNoNextStep'));
            OrkBL.aes2processUpdate.remove('setNoNextStep');
        }
        if (OrkBL.aes2processUpdate.get('setNextStep') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setNextStep'));
            OrkBL.aes2processUpdate.remove('setNextStep');
        }
        //generate a unique list
        Map<Id, ActivityExtended__c> uniqAes = new Map<Id, ActivityExtended__c>();
        for (ActivityExtended__c tmp : aes2update) {
            uniqAes.put(tmp.id, tmp);
        }
        if (OrkBL.cebGetTaskFielsPermission(globalDesc, 'UPDATE')) update uniqAes.values();
    }
    /*** 20210512 GMameli/MSiotto - Code Review - Start ***/

    /*** 20210610 MSiotto - New Engine step field update - Start ***/
    /*nextJob
    * il metodo istanzia le next activities da lavoare
    */
    public static void cebSetNextJob(Map<String, SObject> objectForPraticaMap, Map<String, Schema.SObjectType> globalDesc, string token, Map<string, Task> tMap, Map<string, Pratica__c> pMap, Map<id, Sobject> sobjectsToUpdate, List<Sobject> sobjectsToInsert, List<Log__c> logL, Map<Id, ActivityExtended__c> filteredTsksActsExtMap) {
        boolean result = false;
        integer prioritylevel, priorityElement;
        set<id> taskProcessed = new set<id>();
        Pratica__c pratica = new pratica__c();
        //pratica__c praticaToUpdate = new pratica__c(); removed for step field update
        Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();

        if (filteredTsksActsExtMap == null) {
            task2Obj = Utils.cebGetTaskWithActivityExtended(tMap.values(), globalDesc);
        } else {
            task2Obj = filteredTsksActsExtMap;
        }
        for (string r : tMap.Keyset()) {
            Task s = tMap.get(r);
            ActivityExtended__c ae = task2Obj.get(s.Id);

            if (s.Status != 'Lavorata') {
                s.Description += '\n _NONextJob_Stato diverso da Lavorata';
                continue;
            }
            pratica = pMap.get(s.whatId);
            //praticaToUpdate = (pratica__C) sobjectsToUpdate.get(s.whatID); removed for step field update
            //System.debug('cebSetNextJob praticaToUpdate -->' + praticaToUpdate); removed for step field update
            s.Description += '\n ae.id_attivita__c : ' + ae.id_attivita__c;
            if (OrkStatic.nSPO.get(ae.id_attivita__c) == null) {//significa che é un last activity per quel ramo
                s.Description += '\n _NONextJob_Stato diverso da Lavorata - id_attivita__c null';
                OrkBL.setNoNextStep(s);
                continue;
            } else {
                try {
                    for (id idst : OrkStatic.nSPO.get(ae.id_attivita__c)) {
                        Strategia__c st = OrkStatic.strategies.get(idst);
                        /*
                        * questo verifica se passare al prossimo livello di prioritÃ .
                        * Se il task é lavorato, ed abbiamo cambiato livello, allora fa break e esce
                        * diversamente setta il prossimo livello ed esegue
                        */
                        priorityElement = integer.valueof(st.priority__c);
                        if (taskProcessed.contains(s.id) && prioritylevel != priorityElement) break;
                        else if (prioritylevel != priorityElement) prioritylevel = priorityElement;

                        s.Description += '\n NextJob con nome:' + st.Nome__c;
                        result = OrkKernel.isRoleSatisfied(pratica, st, logL, s, task2Obj);
                        if (result == null) {
                            OrkBL.setNextStepError(s);
                            taskProcessed.add(s.id);
                            s.Description += '\n NextJob Error: result null' + 'nextJob:' + st.Nome__c;
                            break;
                        }
                        if (result) {
                            /*** 20210527 MSala - Review Query Loop - Start ***/
                            List<Sobject> nt = OrkBL.cebEngineNewTask(objectForPraticaMap, sobjectsToUpdate, globalDesc, s, ae, pratica, st, '');
                            /*** 20210527 MSala - Review Query Loop - End ***/
                            OrkBL.cebSetNextStep(objectForPraticaMap, s, ae, pratica, st, sobjectsToUpdate, sobjectsToInsert, logL);
                            taskProcessed.add(s.id);
                            s.Description += '\n NextJob success:' + 'nextJob:' + st.Nome__c;
                            sobjectsToInsert.addAll(nt);
                        }
                        //sobjectsToUpdate.put(pratica.id, pratica); removed for step field update
                    }
                } catch (Exception e) {
                    s.status = 'Error'; s.description = '\n fatal error OrkKernel.executeNextJob:' + e.getMessage() + e.getLinenumber() + '\n ' + e.getStackTraceString(); logL.add(errorClass.istanceError('JumpException', 'E:' + e + '\n' + e.getlinenumber() + '\n ' + e.getStackTraceString()));
                }
            }
        }
        if (OrkBL.aes2processUpdate == null) return;
        List<ActivityExtended__c> aes2update = new List<ActivityExtended__c>();
        if (OrkBL.aes2processUpdate.get('setNoNextStep') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setNoNextStep'));
            OrkBL.aes2processUpdate.remove('setNoNextStep');
        }
        if (OrkBL.aes2processUpdate.get('setNextStep') != null) {
            aes2update.addAll(OrkBL.aes2processUpdate.get('setNextStep'));
            OrkBL.aes2processUpdate.remove('setNextStep');
        }
        //generate a unique list
        Map<Id, ActivityExtended__c> uniqAes = new Map<Id, ActivityExtended__c>();
        for (ActivityExtended__c tmp : aes2update) {
            uniqAes.put(tmp.id, tmp);
        }
        if (OrkBL.cebGetTaskFielsPermission(globalDesc, 'UPDATE')) update uniqAes.values();
    }
    /*** 20210610 MSiotto - New Engine step field update  - Start ***/

    /*
    *   Di seguito i metodi per validare le regole che vengono applicate per eseguire le attività delle strategie.
    *   I metodi che seguono eseguono il controllo tra un campo del database e i campi della strategia secondo le regole configurate sull'oggetto Rule control
    *   La gestione avviene tra due metodi:
    *   isRoleSatisfied: processa tutte le regole associate a un determinato record della strategia (campo Activation_roles__c)
    *       checkCondition: che verifica la singola regola e confronta i valori tra i campi della strategia e quelli nel database.
    
    *   Il risultato ha tre configurazioni:
    *       true: condizione soddisfata
    *       false: condizione non è soddisfata
    */
    public static boolean isRoleSatisfied(Pratica__c pratica, Strategia__c strategia, List<Log__c> logL, Task t, Map<Id, ActivityExtended__c> task2Obj) {
        boolean isSatisfied = true;
        string errorCode;
        if (strategia.Activation_roles__c == null || strategia.Activation_roles__c == 'No rules selected') return isSatisfied;
        //List<Task> tasks = new List<Task>();
        //tasks.add(t);
        //Map<Id,ActivityExtended__c> task2Obj = Utils.getTaskWithActivityExtended(tasks);
        ActivityExtended__c ae = (task2Obj != null && task2Obj.containsKey(t.id)) ? task2Obj.get(t.Id) : new ActivityExtended__c();
        set<string> rules = new Set<string>(strategia.Activation_roles__c.split(','));
        for (string r : rules) {
            Rule_control__c rc = Rule_control__c.getValues(r);
            if (rc == null || rc.Api_object_name__c == null) {
                t.description += '\n \t\t Error_rc:' + rc;
                isSatisfied = false;
                break;
            } else if (rc.Api_object_name__c == 'pratica__c') {
                isSatisfied = checkCondition(pratica.get(rc.Api_field_name__c), strategia.get(rc.Strategia_api_field_name__c), rc.Condition__c);
                t.description += '\n rc.Name:' + rc.Api_field_name__c + rc.Condition__c + rc.Strategia_api_field_name__c + ' : ' + pratica.get(rc.Api_field_name__c) + rc.Condition__c + strategia.get(rc.Strategia_api_field_name__c);
            } else if (rc.Api_object_name__c == 'Task' && (rc.Api_field_name__c == 'Status' || rc.Api_field_name__c == 'Subject')) {
                isSatisfied = checkCondition(t.get(rc.Api_field_name__c), strategia.get(rc.Strategia_api_field_name__c), rc.Condition__c);
                t.description += '\n rc.Name:' + rc.Api_field_name__c + rc.Condition__c + rc.Strategia_api_field_name__c + ' : ' + t.get(rc.Api_field_name__c) + rc.Condition__c + strategia.get(rc.Strategia_api_field_name__c);
            } else if (rc.Api_object_name__c == 'Task') {
                isSatisfied = checkCondition(ae.get(rc.Api_field_name__c), strategia.get(rc.Strategia_api_field_name__c), rc.Condition__c);
                t.description += '\n rc.Name:' + rc.Api_field_name__c + rc.Condition__c + rc.Strategia_api_field_name__c + ' : ' + ae.get(rc.Api_field_name__c) + rc.Condition__c + strategia.get(rc.Strategia_api_field_name__c);
            } else {
                t.description += '\n \t\t Error_rc.Name:' + rc.name + ': ' + rc.Api_object_name__c;
                t.description += '  Non è stato possibile lavorare la regola, ' + rc.Api_object_name__c + ' non è tra gli sobject permessi';
                isSatisfied = false;
                break;
            }
            t.description += ' isSatisfied: ' + isSatisfied ;
            isSatisfied = (isSatisfied == null) ? false : isSatisfied;
            if (!isSatisfied) break;
        }
        return isSatisfied;
    }
    /*metodo non più utilizzato e rimascherato per non impattare il codice da altre parti*/
    public static Boolean isRoleSatisfied(Pratica__c pratica, Strategia__c strategia, List<Log__c> logL) {
        return isRoleSatisfied(pratica, strategia, logL, new task(), null);
    }

    public static Boolean checkConditionForTestOnly(object odb, object oconf, string condition) {
        if (Test.isRunningtest())
            return checkCondition(odb, oconf, condition);
        return null;
    }

    public static Boolean checkCondition(object odb, object oconf, string condition) {
        if (condition == '<') {
            if (oconf instanceof date) return (date) odb < (date) oconf;
            if (oconf instanceof datetime) return (datetime) odb < (datetime) oconf;
            if (oconf instanceof Decimal) return (Decimal) odb < (Decimal) oconf;
            if (oconf instanceof string) return (string) odb < (string) oconf;

        } else if (condition == '<=') {
            if (oconf instanceof date) return (date) odb <= (date) oconf;
            if (oconf instanceof datetime) return (datetime) odb <= (datetime) oconf;
            if (oconf instanceof Decimal) return (Decimal) odb <= (Decimal) oconf;
            if (oconf instanceof string) return (string) odb <= (string) oconf;

        } else if (condition == '!=' || condition == '<>') {
            if (oconf instanceof string) return (string) odb != (string) oconf;
            if (oconf instanceof date) return (date) odb != (date) oconf;
            if (oconf instanceof datetime) return (datetime) odb != (datetime) oconf;
            if (oconf instanceof Decimal) return (Decimal) odb != (Decimal) oconf;
            if (oconf instanceof boolean) return (boolean) odb != (boolean) oconf;

        } else if (condition == '>') {
            if (oconf instanceof date) return (date) odb > (date) oconf;
            if (oconf instanceof datetime) return (datetime) odb > (datetime) oconf;
            if (oconf instanceof Decimal) return (Decimal) odb > (Decimal) oconf;
            if (oconf instanceof string) return (string) odb > (string) oconf;

        } else if (condition == '>=') {
            if (oconf instanceof date) return (date) odb >= (date) oconf;
            if (oconf instanceof datetime) return (datetime) odb >= (datetime) oconf;
            if (oconf instanceof Decimal) return (Decimal) odb >= (Decimal) oconf;
            if (oconf instanceof string) return (string) odb >= (string) oconf;

        } else if (condition == '==' || condition == '=') {
            if (oconf instanceof string) return (string) odb == (string) oconf;
            if (oconf instanceof boolean) return (boolean) odb == (boolean) oconf;
            if (oconf instanceof date) return (date) odb == (date) oconf;
            if (oconf instanceof datetime) return (datetime) odb == (datetime) oconf;
            if (oconf instanceof Decimal) return (Decimal) odb == (Decimal) oconf;

        } else if (condition == 'includes') {
            Set<String> setOdb = new Set<String>(((String) odb).split(';'));
            Set<String> setOconf = new Set<String>();
            if (oconf != null) {
                Set<String> splitOconf = new Set<String>(((String) oconf).split(';'));
                setOconf.addAll(splitOconf);
            }

            Map<String, String> mapOdb = getToMap(setOdb);
            Boolean inc = true;
            for (String s : setOconf) {
                if (mapOdb.get(s) == null) inc = false;
            }
            return inc;

        } else if (condition == 'IsIncluded') {
            Set<String> setOdb = new Set<String>(((String) odb).split(';'));
            Set<String> setOconf = new Set<String>();
            if (oconf != null) {
                Set<String> splitOconf = new Set<String>(((String) oconf).split(';'));
                setOconf.addAll(splitOconf);
            }

            Map<String, String> mapOconf = getToMap(setOconf);
            Boolean inc = true;
            for (String s : setOdb) {
                if (mapOconf.get(s) == null) inc = false;
            }
            return inc;

        } else if (condition == 'escludes') {
            Set<String> setOdb = new Set<String>(((String) odb).split(';'));
            Set<String> setOconf = new Set<String>();
            if (oconf != null) {
                Set<String> splitOconf = new Set<String>(((String) oconf).split(';'));
                setOconf.addAll(splitOconf);
            }

            Map<String, String> mapOdb = getToMap(setOdb);
            Boolean inc = true;
            for (String s : setOconf) {
                if (inc && mapOdb.get(s) != null) {
                    inc = false;
                }
            }
            return inc;
        }
        return null;
    }

    private static Map<String, String> getToMap(Set<String> setO) {
        Map<String, String> mapOdb = new Map<String, String>();
        for (String s : setO) mapOdb.put(s, s);
        return mapOdb;
    }
}