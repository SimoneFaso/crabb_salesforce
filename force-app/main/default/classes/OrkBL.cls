/* ---------------------------------------------------------------------------------------------------------------------
Name:            OrkBL.cls
Description:     Ork Business Logic. Gestisce tutte le verifiche puntuali e le logiche associate all'Ork
Test class:      TestOrkBL.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
06-May-2014  0.1      Klodjan Meta                     First Version
09-May-2017  0.2      Matteo Sala                      Added isTaskForJump method
11-May-2021  0.3      Matteo Siotto                    Reviewed for using ceb methods
27-May-2021  0.4      Matteo Sala                      Added cebEngineNewTask method for reviewing query loop
10-Jun-2021  0.5      Matteo Siotto                    Added stepFieldsUpdate method
11-Jun-2021  0.6      Matteo Siotto                    Added cebSetNextStep method
16-Jun-2021  0.7      Giulia Mameli                    Modified cebNewTask for taking current Activity Extended as input
                                                       (Review query loop)
13-Jul-2021  0.8      Matteo Siotto                    Added cebSetNextStep, cebEngineNewTask, newSetTaskFromJump and
                                                       stepFieldsUpdate methods
12-Aug-2021  0.9      Giulia Mameli                    Modified newTask method for using custom labels for Task Subject
                                                       and Activity Extended Type
05-Oct-2021  0.10     G. Mameli, C. Sanna,             Modified isNecessaryGoOut method to use Custom Metadata
                      M. Pizzichini                    skip trigger metadata Skip_Exit_from_Strategy
15-Sep-2022  0.11     R.Kurti & C.Sanna                Added cebCheckObjPermission, WITH SECURITY_ENFORCED for security review
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class OrkBL {//Ork business logic

    /*setEnteringInStrategia
    *   Il metodo configura e popola i dati per l'entrata in strategia della pratica. Popolando sia il task, che la partica
    *   o altri dati utili correlati
    */
    public static Map<String, List<ActivityExtended__c>> aes2processUpdate;
    public static Map<String, List<ActivityExtended__c>> aes2processInsert;
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    //If skip trigger metadata Skip_Exit_from_Strategy is set to true then skip exit from Strategy when Expired Amount is <= 0
    public static final Boolean skipExit = skipTrigger.skip('Pratica_CeckResiduo') != null ? skipTrigger.skip('Pratica_CeckResiduo') : false;

    private static void buildaesProcessMap(String methodName, ActivityExtended__c ae2process, String operation) {
        if (operation.equalsIgnoreCase('UPDATE')) {
            if (aes2processUpdate == null) {
                aes2processUpdate = new Map<String, List<ActivityExtended__c>>();
                aes2processUpdate.put(methodName, new List<ActivityExtended__c>());
            } else if (!aes2processUpdate.containsKey(methodName)) {
                aes2processUpdate.put(methodName, new List<ActivityExtended__c>());
            }
            aes2processUpdate.get(methodName).add(ae2process);
        } /*else {
            if (aes2processInsert==null) {
            aes2processInsert = new Map<String,List<ActivityExtended__c>>();
            aes2processInsert.put(methodName,new List<ActivityExtended__c>());
            } else if (!aes2processInsert.containsKey(methodName)) {
                aes2processInsert.put(methodName,new List<ActivityExtended__c>());
            }
            aes2processInsert.get(methodName).add(ae2process);
        }*/
    }

    public static boolean setEnteringInStrategia(Task t, ActivityExtended__c ae, Pratica__c pratica, Strategia__c str,
            Map<id, SObject> sobjectsToUpdate, List<SObject> sobjectsToInsert, List<Log__c> logL) {
        pratica__c praticaToUpdate = (Pratica__c) sobjectsToUpdate.get(pratica.id);

        t.Status = 'Lavorata';
        ae.code_Status__c = TagHelper.getValue('setEnteringInStrategiaCodeStatus', t.ActivityExtended__r.code_Status__c);

        ae.Id_Strategia__c = str.Testata__c;
        ae.Strategia__c = str.Nome_strategia__c;
        ae.Activity__c = str.testata__c;
        ae.Activity_name__c = str.Nome__c;
        ae.id_attivita__c = str.testata__c;
        ae.id_condizioni_di_ingresso__c = str.id;
        buildaesProcessMap('setEnteringInStrategia', ae, 'UPDATE');
        /*
        if (Utils.checkFLSPermission('ActivityExtended__c', 'code_status__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Strategia__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Id_Strategia__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Activity__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'id_Attivita__C').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Activity_name__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'id_condizioni_di_ingresso__c').get('UPDATE')
            ) update ae;*/
        praticaToUpdate.strategia__c = str.Testata__c;
        praticaToUpdate.ConDiIng__c = str.id;
        praticaToUpdate.service__c += ',CreaStorico';
        praticaToUpdate.debug__c += '\n setEnteringInStrategia' + pratica.service__c ;
        if (str.Activation_roles__c != null && str.Activation_roles__c != '') {
            praticaToUpdate.CDI_Json__c = logRules(pratica, str);
        }
        sobjectsToUpdate.put(praticaToUpdate.id, praticaToUpdate);
        return true;
    }
    public static boolean setEnteringInStrategiaError(Task t, ActivityExtended__c ae) {
        t.Status = 'Error';
        ae.code_status__c = TagHelper.getValue('RicercaStrategiaErrorCodeStatus', t.ActivityExtended__r.code_status__c);
        //if (Utils.checkFLSPermission('ActivityExtended__c', 'code_status__c').get('UPDATE')) update ae;
        buildaesProcessMap('setEnteringInStrategiaError', ae, 'UPDATE');
        return true;
    }

    public static Boolean isNecessaryGoOut(Task t, ActivityExtended__c ae, Pratica__c pratica, Strategia__c str, Map<Id, SObject> sobjectsToUpdate, List<SObject> sobjectsToInsert, List<Log__c> logL) {
        Pratica__c praticaToUpdate = (Pratica__c) sobjectsToUpdate.get(pratica.Id);
        //if (pratica.Residuo_Totale__c <= 0) {
        if (pratica.Residuo_Totale__c <= 0 && skipExit == false) {
            t.Status = 'Completata';
            ae.Esito__c = 'Pagamento effettuato';
            //if (Utils.checkFLSPermission('ActivityExtended__c', 'Esito__c').get('UPDATE')) update ae;
            buildaesProcessMap('isNecessaryGoOut', ae, 'UPDATE');
            praticaToUpdate.Service__c = 'UscitaSenzaChiusura';
            sobjectsToUpdate.put(pratica.Id, pratica);
            return true;
        }
        return false;
    }

    public static boolean setNextStepError(Task t) {
        t.Status = 'Error';
        t.Description += '\n setNextStepError:' + TagHelper.getValue('NextStepErrorCodeStatus', t.ActivityExtended__r.code_status__c);
        return true;
    }
    public static boolean setNoNextStep(Task t) {
        t.Status = 'Completata';
        t.Description += '\n setNoNextStep:' + TagHelper.getValue('noNextJobCodeStatus', t.ActivityExtended__r.code_status__c);
        return true;
    }
    public static boolean setNextStep(Task t, ActivityExtended__c ae, Pratica__c pratica, Strategia__c str, Map<id, SObject> sobjectsToUpdate, List<SObject> sobjectsToInsert, List<Log__c> logL) {
        pratica__c praticaToUpdate = (Pratica__c) sobjectsToUpdate.get(pratica.id);
        t.Status = 'Completata';
        t.Description += '\n setNextStep: task completato';
        ae.Data_chiusura__c = system.now();
        ae.Scaduto_finale__c = pratica.Residuo_Totale__c;
        ae.Chiuso_da_id__c = UserInfo.getUserId();
        ae.Chiuso_da_name__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        /*if (Utils.checkFLSPermission('ActivityExtended__c', 'code_status__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Data_chiusura__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Scaduto_finale__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Chiuso_da_id__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Chiuso_da_name__c').get('UPDATE')
            ) update ae;*/
        buildaesProcessMap('setNextStep', ae, 'UPDATE');
        sobjectsToUpdate.put(pratica.id, pratica);
        return true;
    }

    /**2021-06-10 MSiotto -- New Method for new Engine that sets fields values mapped in the CRABB_DEV__Step_Field_Update__c object when a Task is closed - START **/
    public static boolean cebSetNextStep(Map<String, SObject> objectForPraticaMap, Task t, ActivityExtended__c ae, Pratica__c pratica, Strategia__c str, Map<id, SObject> sobjectsToUpdate, List<SObject> sobjectsToInsert, List<Log__c> logL) {
        System.debug('cebSetNextStep START');
        pratica__c praticaToUpdate = (Pratica__c) sobjectsToUpdate.get(pratica.id);
        t.Status = 'Completata';
        t.Description += '\n setNextStep: task completato';
        ae.Data_chiusura__c = system.now();
        ae.Scaduto_finale__c = pratica.Residuo_Totale__c;
        ae.Chiuso_da_id__c = UserInfo.getUserId();
        ae.Chiuso_da_name__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();

        buildaesProcessMap('setNextStep', ae, 'UPDATE');
        stepFieldsUpdate(sobjectsToUpdate, objectForPraticaMap, pratica, ae, 'isClosed');
        //sobjectsToUpdate.put(pratica.id, pratica);
        return true;
    }
    /**2021-06-10 MSiotto -- New Method for new Engine that sets fields values mapped in the CRABB_DEV__Step_Field_Update__c object when a Task is closed - END **/

    /*
    *   Il metodo verifica quali pratiche sono processabili o meno per le strategie ricorsive.
    *   
    */
    public static set<id> getPraticheProcessabili(string token, Map<id, Pratica__c> pMap, strategia__c strategia) {
        set<id> idSetOfPraticasProcessable = new set<id>();
        for (id idp : pMap.keyset()) {
            pratica__c p = pMap.get(idp);
            if (p.stato__c == 'Chiusa') continue; else if (p.white_list__c) continue; else if (p.stato__c == 'Bloccata') continue; else idSetOfPraticasProcessable.add(idp);
        }
        return idSetOfPraticasProcessable;
    }


    /*
    *   I metodi "set Success" impostano i task che hanno avuto sucesso
    */
    public static boolean setExitSuccess(Task t, ActivityExtended__c ae, Pratica__c pratica, Strategia__c cdu, Map<id, SObject> sobjectsToUpdate, List<SObject> sobjectsToInsert, List<Log__c> logL) {
        pratica__c praticaToUpdate = (Pratica__c) sobjectsToUpdate.get(pratica.id);
        ae.Id_Strategia__c = cdu.Testata__c;
        ae.Strategia__c = cdu.Nome_strategia__c;
        t.Status = 'Exit';
        ae.esito__c = cdu.esito__c;
        t.description += '\n setExitSuccess';
        ae.code_status__c += '_isExit';
        ae.isExit_Jump__c = true;
        ae.Condizione_di_uscita__c = cdu.id;
        ae.Data_chiusura__c = system.now();
        ae.Scaduto_finale__c = pratica.Residuo_Totale__c;
        ae.Chiuso_da_id__c = UserInfo.getUserId();
        ae.Chiuso_da_name__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        /*if (Utils.checkFLSPermission('ActivityExtended__c', 'code_status__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Condizione_di_uscita__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'esito__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Strategia__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Id_Strategia__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'isExit_Jump__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Data_chiusura__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Scaduto_finale__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Chiuso_da_id__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Chiuso_da_name__c').get('UPDATE')
            ) update ae;*/
        buildaesProcessMap('setExitSuccess', ae, 'UPDATE');
        praticaToUpdate.Condizioni_di_uscita__c = cdu.id;
        praticaToUpdate.CDU_Json__c = logRules(pratica, cdu);
        if (cdu.Esci_e_chiudi__c)
            praticaToUpdate.Service__c += ',UscitaConChiusura'; else
                praticaToUpdate.Service__c += ',UscitaSenzaChiusura';
        sobjectsToUpdate.put(praticaToUpdate.id, praticaToUpdate);

        return true;
    }

    public static boolean setJumpSuccess(Task t, ActivityExtended__c ae, Pratica__c pratica, Strategia__c jump, Map<id, SObject> sobjectsToUpdate, List<SObject> sobjectsToInsert, List<Log__c> logL) {
        pratica__c praticaToUpdate = (Pratica__c) sobjectsToUpdate.get(pratica.id);
        t.description += '\n setJumpSuccess';
        t.Status = 'Saltata';
        ae.code_status__c += '_isSalto';
        ae.Condizione_di_salto__c += jump.id + ';';
        ae.isExit_Jump__c = true;
        ae.Data_chiusura__c = system.now();
        ae.Scaduto_finale__c = pratica.Residuo_Totale__c;
        ae.Chiuso_da_id__c = UserInfo.getUserId();
        ae.Chiuso_da_name__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        /*if (Utils.checkFLSPermission('ActivityExtended__c', 'code_status__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Condizione_di_salto__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'isExit_Jump__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Data_chiusura__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Scaduto_finale__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Chiuso_da_id__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Chiuso_da_name__c').get('UPDATE')
            ) update ae;*/
        buildaesProcessMap('setJumpSuccess', ae, 'UPDATE');
        sobjectsToUpdate.put(praticaToUpdate.id, praticaToUpdate);
        return true;
    }
    public static void setActivitySuccess(Task t, ActivityExtended__c ae, Pratica__c pratica, string esito) {
        t.Status = 'Lavorata';
        ae.code_status__c += '_isActivity';
        if (esito == 'OK')ae.Esito__c = 'OK'; else ae.esito__c = 'KO';
        buildaesProcessMap('setActivitySuccess', ae, 'UPDATE');
        /*if (Utils.checkFLSPermission('ActivityExtended__c', 'code_status__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'esito__c').get('UPDATE')
            ) update ae;*/
    }

    /*
    *   I metodi "set Error" impostano i task in errore 
    *   per quella funzionalità o meno
    */
    public static void setExitError(Task t, ActivityExtended__c ae) {
        t.status = 'Error';
        ae.substatus__c = 'Non è stato possibile verificare le regole';
        /*if (Utils.checkFLSPermission('ActivityExtended__c', 'substatus__c').get('UPDATE')) update ae;*/
        buildaesProcessMap('setExitError', ae, 'UPDATE');
        t.description += '\n setExitError: verifica delle condizioni è ritornato null';
    }


    /*
    *   I seguenti con prefisso "is" sono dei metodi che verificano se il task deve essere elaborato 
    *   per quella funzionalità o meno
    */
    public static boolean isJumpAutomatico(Task t, Pratica__c pratica, strategia__C cdi) {
        //Here some logic
        return true;
    }
    public static boolean isTaskToEnterInOrchestration(Task t, ActivityExtended__c ae) {
        set<string> statusToRefuse = new set<string>{
                'Completata', 'Completato', 'Exit', 'Saltata', 'Saltato', 'Error', '', null
        };
        set<string> recordTypesToRefuse = new set<string>{
                'Standard', '', null
        };
        boolean result = (!statusToRefuse.contains(t.status)) && !recordTypesToRefuse.contains(t.ActivityExtended__r.Record_type__c);
        if (result) ae.code_status__c += '_isConfig2'; else ae.code_status__c += '_NoConfig';
        /*if (Utils.checkFLSPermission('ActivityExtended__c', 'code_status__c').get('UPDATE')) update ae;*/
        buildaesProcessMap('isTaskToEnterInOrchestration', ae, 'UPDATE');
        return result;
    }

    public static boolean isTaskForExit(Task t) {
        return !t.ActivityExtended__r.isFirst__c && t.status != 'Error' && t.ActivityExtended__r.record_type__c != 'Standard';
    }
    public static boolean isTaskForJump(Task t) {
        return !t.ActivityExtended__r.isFirst__c && t.status != 'Error' && t.status != 'In approvazione' && t.status != 'Exit' && t.ActivityExtended__r.record_type__c != null && t.ActivityExtended__r.record_type__c != 'Standard';
    }
    /* MSala 20170509 - INIZIO*/
    public static boolean isTaskForJump(Task t, ActivityExtended__c ae) {
        return !ae.isFirst__c && t.status != 'Error' && t.status != 'In approvazione' && t.status != 'Exit' && ae.record_type__c != null && ae.record_type__c != 'Standard';
    }
    /* MSala 20170509 - FINE*/
    public static boolean isTaskForActivity(Task t) {
        set<string> rt = new set<string>{
                'Standard', '', null
        };
        return !t.ActivityExtended__r.isFirst__c && t.status != 'Error' && t.status != 'In approvazione' && t.status != 'Exit' && t.status != 'Saltato' && t.status != 'Saltata' && t.ActivityExtended__r.Activity__c != null && !rt.contains(t.ActivityExtended__r.record_type__c);
    }

    /*** MSALA 20170403 - Modifica per Chiusura Task di Attesa - INIZIO ***/
    public static boolean isTaskForActivity(Task t, ActivityExtended__c ae) {
        set<string> rt = new set<string>{
                'Standard', '', null
        };
        return !t.ActivityExtended__r.isFirst__c && t.status != 'Error' && t.status != 'In approvazione' && t.status != 'Exit' && t.status != 'Saltato' && t.status != 'Saltata' && ae.Activity__c != null && !rt.contains(ae.record_type__c);
    }
    /*** MSALA 20170403 - Modifica per Chiusura Task di Attesa - FINE ***/

    public static boolean isNextJob(Task t) {
        return (t.Status == 'Lavorata' || t.Status == 'Lavorato') && t.ActivityExtended__r.record_type__c != 'Standard';
    }
    public static boolean isTaskForLoop(Task t) {
        /*** Msala 20180727 - Aggiunto lo stato 'Non iniziata' per far funzionare i Jump Automatici  ***/
        set<string> status = new set<string>{
                'Lavorata', 'Lavorato', 'Non iniziata'
        };
        return !t.ActivityExtended__r.isFirst__c && status.contains(t.status) && t.status != 'In approvazione';
    }
    /* 
    *   I seguenti metodi sono dedicati alla creazione dei nuovi task a 
    *   seconda delle casisitiche. :))
    */
    //Nuovo Task in fase di lavorazione di una strategia Standard
    public static List<Sobject> newTask(Task t, Pratica__c p, Strategia__c s, String esito) {
        Task nt = new Task();
        ActivityExtended__c ae = new ActivityExtended__c();
        List<Task> currentTask = new List<Task>{
                t
        };
        Map<Id, ActivityExtended__c> aes = Utils.getTaskWithActivityExtended(currentTask);
        ActivityExtended__c currentAe = aes.get(t.id);
        OrkStatic.setTaskRecrdType();
        nt.whatID = t.whatId;
        if (String.isNotBlank(esito)) ae.Esito__c = esito;
        ae.Account_id__c = t.ActivityExtended__r.Account_id__c;
        ae.idAccount__c = p.account__c;
        ae.Account_Name__c = p.Account_Name__c;
        ae.Servizio_id__c = p.Servizio_Fornitura__c;
        ae.Servizio_Name__c = p.Servizio_name__c;
        ae.Comune_del_contratto__c = p.comune__c;
        //ae.Attivita_precedente_Esito__c=t.ActivityExtended__r.Esito__c;
        if (s.E_da_affidare__c) {
            ae.E_da_affidare__c = s.E_da_affidare__c;
            if (currentAe.id_affidamento__c == '' || currentAe.id_affidamento__c == null)
                ae.Collector__c = 'ERROR: ' + currentAe.Id; else
                    ae.id_affidamento__c = currentAe.id_affidamento__c;
            ae.id_lotto_associato__c = currentAe.id_lotto_associato__c;
        }
        ae.Owner_contratto__c = p.Owner_contratto__c;
        nt.Ownerid = p.ownerid;
        ae.Document_code__c = s.document_code__c;
        ae.scaduto_iniziale__c = p.Residuo_Totale__c;
        ae.Attivita_precedente__c = t.id;
        ae.Attivita_precedente_name__c = t.subject;
        nt.Subject = s.Nome__c;
        ae.Strategia__c = s.Nome_strategia__c;
        ae.id_attivita__c = s.id;
        nt.type = 'Credito';
        if (s.isSLA_present__c == false) nt.SLA__c = -1; else {
            nt.SLA__c = s.SLA__c;
            ae.SLA__c = s.SLA__c;
            ae.Expiration_date__c = system.today().AddDays(integer.valueof(s.SLA__c));
        }
        ae.Fase__c = s.Fase__c;
        //nt.tipo_attivita__c=s.tipo_attivita__c;
        ae.tipo__c = s.tipo_attivita__c;
        //nt.sotto_tipo_attivita__c=s.sotto_tipo_attivita__c;
        ae.sotto_tipo__c = s.sotto_tipo_attivita__c;

        nt.WhoId = t.WhoId;
        ae.id_strategia__c = s.Testata__c;//t.ActivityExtended__r.id_Strategia__c;
        ae.Id_Attivit_Precedente__c = t.ActivityExtended__r.id_attivita__c;
        ae.recordTypeid = OrkStatic.NameIdTasksRecordTyepesMap.get(s.Tipologia__c).getRecordTypeID();
        nt.Status = 'Non iniziata';
        ae.code_status__c = nt.status;
        String dummykey = Utils.generateRandomString(200);
        ae.DummyObjectLink__c = dummykey;
        /*if (Utils.checkFLSPermission('ActivityExtended__c', 'Account_id__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'E_da_affidare__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Account_Name__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Servizio_Name__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Comune_del_contratto__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Owner_contratto__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Strategia__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'id_strategia__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Document_code__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'id_attivita__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Expiration_date__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Fase__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'tipo__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'sotto_tipo__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'recordTypeid').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'code_status__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Servizio_id__c').get('CREATE')) insert ae;*/
        nt.ActivityExtended__r = new ActivityExtended__c(DummyObjectLink__c = dummykey);
        return new List<Sobject>{
                ae, nt
        };
    }

    //Nuovo Task in fase di lavorazione di una strategia Standard per CRABB new engine 11-05-2021
    /*** 20210511 MSiotto - Code Review - Start ***/
    public static List<Sobject> cebNewTask(Map<String, Schema.SObjectType> globalDesc, Task t, ActivityExtended__c aeInput, Pratica__c p, Strategia__c s, String esito) {
        Task nt = new Task();
        ActivityExtended__c ae = new ActivityExtended__c();
        List<Task> currentTask = new List<Task>{
                t
        };

        OrkStatic.setTaskRecrdType();
        nt.whatID = t.whatId;
        if (String.isNotBlank(esito)) ae.Esito__c = esito;
        ae.Account_id__c = t.ActivityExtended__r.Account_id__c;
        ae.idAccount__c = p.account__c;
        ae.Account_Name__c = p.Account_Name__c;
        ae.Servizio_id__c = p.Servizio_Fornitura__c;
        ae.Servizio_Name__c = p.Servizio_name__c;
        ae.Comune_del_contratto__c = p.comune__c;
        //ae.Attivita_precedente_Esito__c=t.ActivityExtended__r.Esito__c;
        if (s.E_da_affidare__c) {
            ae.E_da_affidare__c = s.E_da_affidare__c;
            if (aeInput.id_affidamento__c == '' || aeInput.id_affidamento__c == null)
                ae.Collector__c = 'ERROR: ' + aeInput.Id; else
                    ae.id_affidamento__c = aeInput.id_affidamento__c;
            ae.id_lotto_associato__c = aeInput.id_lotto_associato__c;
        }
        ae.Owner_contratto__c = p.Owner_contratto__c;
        nt.Ownerid = p.ownerid;
        ae.Document_code__c = s.document_code__c;
        ae.scaduto_iniziale__c = p.Residuo_Totale__c;
        ae.Attivita_precedente__c = t.id;
        ae.Attivita_precedente_name__c = t.subject;
        nt.Subject = s.Nome__c;
        ae.Strategia__c = s.Nome_strategia__c;
        ae.id_attivita__c = s.id;
        nt.type = 'Credito';
        if (s.isSLA_present__c == false) nt.SLA__c = -1; else {
            nt.SLA__c = s.SLA__c;
            ae.SLA__c = s.SLA__c;
            ae.Expiration_date__c = system.today().AddDays(integer.valueof(s.SLA__c));
        }
        ae.Fase__c = s.Fase__c;
        //nt.tipo_attivita__c=s.tipo_attivita__c;
        ae.tipo__c = s.tipo_attivita__c;
        //nt.sotto_tipo_attivita__c=s.sotto_tipo_attivita__c;
        ae.sotto_tipo__c = s.sotto_tipo_attivita__c;

        nt.WhoId = t.WhoId;
        ae.id_strategia__c = s.Testata__c;//t.ActivityExtended__r.id_Strategia__c;
        ae.Id_Attivit_Precedente__c = t.ActivityExtended__r.id_attivita__c;
        ae.recordTypeid = OrkStatic.NameIdTasksRecordTyepesMap.get(s.Tipologia__c).getRecordTypeID();
        nt.Status = 'Non iniziata';
        ae.code_status__c = nt.status;
        String dummykey = Utils.generateRandomString(200);
        ae.DummyObjectLink__c = dummykey;
        /*if (Utils.checkFLSPermission('ActivityExtended__c', 'Account_id__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'E_da_affidare__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Account_Name__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Servizio_Name__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Comune_del_contratto__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Owner_contratto__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Strategia__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'id_strategia__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Document_code__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'id_attivita__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Expiration_date__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Fase__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'tipo__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'sotto_tipo__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'recordTypeid').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'code_status__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Servizio_id__c').get('CREATE')) insert ae;*/
        nt.ActivityExtended__r = new ActivityExtended__c(DummyObjectLink__c = dummykey);
        return new List<Sobject>{
                ae, nt
        };
    }
    /*** 20210511 MSiotto - Code Review - End ***/

    //Nuovo Task in fase di lavorazione di una strategia Standard per CRABB new engine 11-05-2021
    /*** 20210527 MSala - Review Query Loop - Start ***/
    public static List<Sobject> cebEngineNewTask(Map<String, Schema.SObjectType> globalDesc, Task t, ActivityExtended__c aeInput, Pratica__c p, Strategia__c s, String esito) {
        System.debug('Strategia --> ' + s);
        Task nt = new Task();
        ActivityExtended__c ae = new ActivityExtended__c();
        List<Task> currentTask = new List<Task>{
                t
        };

        OrkStatic.setTaskRecrdType();
        nt.whatID = t.whatId;
        if (String.isNotBlank(esito)) ae.Esito__c = esito;
        ae.Account_id__c = t.ActivityExtended__r.Account_id__c;
        ae.idAccount__c = p.account__c;
        ae.Account_Name__c = p.Account_Name__c;
        ae.Servizio_id__c = p.Servizio_Fornitura__c;
        ae.Servizio_Name__c = p.Servizio_name__c;
        ae.Comune_del_contratto__c = p.comune__c;
        if (s.E_da_affidare__c) {
            ae.E_da_affidare__c = s.E_da_affidare__c;
            if (aeInput.id_affidamento__c == '' || aeInput.id_affidamento__c == null)
                ae.Collector__c = 'ERROR: ' + aeInput.Id; else
                    ae.id_affidamento__c = aeInput.id_affidamento__c;
            ae.id_lotto_associato__c = aeInput.id_lotto_associato__c;
        }
        ae.Owner_contratto__c = p.Owner_contratto__c;
        nt.Ownerid = p.ownerid;
        ae.Document_code__c = s.document_code__c;
        ae.scaduto_iniziale__c = p.Residuo_Totale__c;
        ae.Attivita_precedente__c = t.id;
        ae.Attivita_precedente_name__c = t.subject;
        nt.Subject = s.Nome__c;
        ae.Strategia__c = s.Nome_strategia__c;
        ae.id_attivita__c = s.id;
        nt.type = 'Credito';
        if (s.isSLA_present__c == false) nt.SLA__c = -1; else {
            nt.SLA__c = s.SLA__c;
            ae.SLA__c = s.SLA__c;
            ae.Expiration_date__c = system.today().AddDays(integer.valueof(s.SLA__c));
        }
        ae.Fase__c = s.Fase__c;
        ae.tipo__c = s.tipo_attivita__c;
        ae.sotto_tipo__c = s.sotto_tipo_attivita__c;

        nt.WhoId = t.WhoId;
        ae.id_strategia__c = s.Testata__c;
        ae.Id_Attivit_Precedente__c = t.ActivityExtended__r.id_attivita__c;
        ae.recordTypeid = OrkStatic.NameIdTasksRecordTyepesMap.get(s.Tipologia__c).getRecordTypeID();
        nt.Status = 'Non iniziata';
        ae.code_status__c = nt.status;
        String dummykey = Utils.generateRandomString(200);
        ae.DummyObjectLink__c = dummykey;
        nt.ActivityExtended__r = new ActivityExtended__c(DummyObjectLink__c = dummykey);
        return new List<Sobject>{
                ae, nt
        };
    }
    /*** 20210527 MSala - Review Query Loop - End ***/

    //Nuovo Task in fase di lavorazione di una strategia Standard per CRABB new engine 11-06-2021
    /*** 20210611 MSiotto - Step field Update if a new task is created - Start ***/
    public static List<Sobject> cebEngineNewTask(Map<String, SObject> objectForPraticaMap, Map<Id, SObject> sobjectsToUpdate, Map<String, Schema.SObjectType> globalDesc, Task t, ActivityExtended__c aeInput, Pratica__c p, Strategia__c s, String esito) {
        System.debug('cebEngineNewTask START');
        Task nt = new Task();
        ActivityExtended__c ae = new ActivityExtended__c();
        List<Task> currentTask = new List<Task>{
                t
        };
        //Map<Id, ActivityExtended__c> aes = new Map<Id, ActivityExtended__c>();//Utils.cebGetTaskWithActivityExtended(currentTask, globalDesc);
        //aes.put(aeInput.Id,aeInput);
        //ActivityExtended__c currentAe = aes.get(t.id);
        OrkStatic.setTaskRecrdType();
        nt.whatID = t.whatId;
        if (String.isNotBlank(esito)) ae.Esito__c = esito;
        ae.Account_id__c = t.ActivityExtended__r.Account_id__c;
        ae.idAccount__c = p.account__c;
        ae.Account_Name__c = p.Account_Name__c;
        ae.Servizio_id__c = p.Servizio_Fornitura__c;
        ae.Servizio_Name__c = p.Servizio_name__c;
        ae.Comune_del_contratto__c = p.comune__c;
        if (s.E_da_affidare__c) {
            ae.E_da_affidare__c = s.E_da_affidare__c;
            if (aeInput.id_affidamento__c == '' || aeInput.id_affidamento__c == null)
                ae.Collector__c = 'ERROR: ' + aeInput.Id; else
                    ae.id_affidamento__c = aeInput.id_affidamento__c;
            ae.id_lotto_associato__c = aeInput.id_lotto_associato__c;
        }
        ae.Owner_contratto__c = p.Owner_contratto__c;
        nt.Ownerid = p.ownerid;
        ae.Document_code__c = s.document_code__c;
        ae.scaduto_iniziale__c = p.Residuo_Totale__c;
        ae.Attivita_precedente__c = t.id;
        ae.Attivita_precedente_name__c = t.subject;
        nt.Subject = s.Nome__c;
        ae.Strategia__c = s.Nome_strategia__c;
        ae.id_attivita__c = s.id;
        nt.type = 'Credito';
        if (s.isSLA_present__c == false) nt.SLA__c = -1; else {
            nt.SLA__c = s.SLA__c;
            ae.SLA__c = s.SLA__c;
            ae.Expiration_date__c = system.today().AddDays(integer.valueof(s.SLA__c));
        }
        ae.Fase__c = s.Fase__c;
        ae.tipo__c = s.tipo_attivita__c;
        ae.sotto_tipo__c = s.sotto_tipo_attivita__c;

        nt.WhoId = t.WhoId;
        ae.id_strategia__c = s.Testata__c;
        ae.Id_Attivit_Precedente__c = t.ActivityExtended__r.id_attivita__c;
        ae.recordTypeid = OrkStatic.NameIdTasksRecordTyepesMap.get(s.Tipologia__c).getRecordTypeID();
        nt.Status = 'Non iniziata';
        ae.code_status__c = nt.status;
        String dummykey = Utils.generateRandomString(200);
        ae.DummyObjectLink__c = dummykey;
        nt.ActivityExtended__r = new ActivityExtended__c(DummyObjectLink__c = dummykey);
        stepFieldsUpdate(sobjectsToUpdate, objectForPraticaMap, p, ae, 'isCreated');
        //sobjectsToUpdate.put(p.id, p);
        return new List<Sobject>{
                ae, nt
        };
    }
    /*** 20210611 MSiotto - Step field Update if a new task is created - End ***/

    public static List<Sobject> newTaskFromJump(task t, pratica__c p, strategia__c s) {
        Task nt = new Task();
        ActivityExtended__c ae = new ActivityExtended__c();
        OrkStatic.setTaskRecrdType();
        nt.whatID = t.whatId;
        ae.Account_id__c = t.ActivityExtended__r.Account_id__c;
        ae.idAccount__c = p.account__c;
        ae.Account_Name__c = p.Account_Name__c;
        ae.Servizio_id__c = p.Servizio_Fornitura__c;
        ae.Servizio_Name__c = p.Servizio_name__c;
        ae.Comune_del_contratto__c = p.comune__c;
        ae.E_da_affidare__c = s.E_da_affidare__c;
        ae.Owner_contratto__c = p.Owner_contratto__c;
        nt.Ownerid = p.ownerid;
        ae.Document_code__c = s.document_code__c;
        ae.scaduto_iniziale__c = p.Residuo_Totale__c;
        ae.Attivita_precedente__c = t.id;
        ae.Attivita_precedente_name__c = t.subject;
        nt.Subject = s.Nome__c;
        ae.Strategia__c = s.Nome_strategia__c;
        ae.id_attivita__c = s.id;
        nt.type = 'Credito';
        if (s.isSLA_present__c == false) nt.SLA__c = -1; else {
            nt.SLA__c = s.SLA__c;
            ae.Expiration_date__c = system.today().AddDays(integer.valueof(s.SLA__c));
        }
        ae.Fase__c = s.Fase__c;
        //nt.tipo_attivita__c=s.tipo_attivita__c;
        ae.tipo__c = s.tipo_attivita__c;
        //nt.sotto_tipo_attivita__c=s.sotto_tipo_attivita__c;
        ae.sotto_tipo__c = s.sotto_tipo_attivita__c;

        nt.WhoId = t.WhoId;
        ae.id_strategia__c = (t.ActivityExtended__r.id_Strategia__c == null) ? s.Testata__c : t.ActivityExtended__r.id_Strategia__c;
        ae.Id_Attivit_Precedente__c = t.ActivityExtended__r.id_attivita__c;
        ae.recordTypeid = OrkStatic.NameIdTasksRecordTyepesMap.get(s.Tipologia__c).getRecordTypeID();
        nt.Status = 'Non iniziata';
        ae.code_status__c = nt.status;
        String dummykey = Utils.generateRandomString(200);
        ae.DummyObjectLink__c = dummykey;
        /*if (Utils.checkFLSPermission('ActivityExtended__c', 'Account_id__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'E_da_affidare__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Account_Name__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Servizio_Name__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Comune_del_contratto__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Owner_contratto__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Strategia__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'id_strategia__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Document_code__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'id_attivita__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Expiration_date__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Fase__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'tipo__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'sotto_tipo__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'recordTypeid').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'code_status__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Servizio_id__c').get('CREATE')) insert ae;*/
        nt.ActivityExtended__r = new ActivityExtended__c(DummyObjectLink__c = dummykey);
        return new List<Sobject>{
                ae, nt
        };
    }

    /*** 20210622 MSiotto - Step field Update if a new task is created - Start ***/
    public static List<Sobject> newSetTaskFromJump(Map<String, SObject> objectForPraticaMap, Map<Id, SObject> sobjectsToUpdate, task t, pratica__c p, strategia__c s) {
        System.debug('newSetTaskFromJump START');
        Task nt = new Task();
        ActivityExtended__c ae = new ActivityExtended__c();
        OrkStatic.setTaskRecrdType();
        nt.whatID = t.whatId;
        ae.Account_id__c = t.ActivityExtended__r.Account_id__c;
        ae.idAccount__c = p.account__c;
        ae.Account_Name__c = p.Account_Name__c;
        ae.Servizio_id__c = p.Servizio_Fornitura__c;
        ae.Servizio_Name__c = p.Servizio_name__c;
        ae.Comune_del_contratto__c = p.comune__c;
        ae.E_da_affidare__c = s.E_da_affidare__c;
        ae.Owner_contratto__c = p.Owner_contratto__c;
        nt.Ownerid = p.ownerid;
        ae.Document_code__c = s.document_code__c;
        ae.scaduto_iniziale__c = p.Residuo_Totale__c;
        ae.Attivita_precedente__c = t.id;
        ae.Attivita_precedente_name__c = t.subject;
        nt.Subject = s.Nome__c;
        ae.Strategia__c = s.Nome_strategia__c;
        ae.id_attivita__c = s.id;
        nt.type = 'Credito';
        if (s.isSLA_present__c == false) nt.SLA__c = -1; else {
            nt.SLA__c = s.SLA__c;
            ae.Expiration_date__c = system.today().AddDays(integer.valueof(s.SLA__c));
        }
        ae.Fase__c = s.Fase__c;
        //nt.tipo_attivita__c=s.tipo_attivita__c;
        ae.tipo__c = s.tipo_attivita__c;
        //nt.sotto_tipo_attivita__c=s.sotto_tipo_attivita__c;
        ae.sotto_tipo__c = s.sotto_tipo_attivita__c;

        nt.WhoId = t.WhoId;
        ae.id_strategia__c = (t.ActivityExtended__r.id_Strategia__c == null) ? s.Testata__c : t.ActivityExtended__r.id_Strategia__c;
        ae.Id_Attivit_Precedente__c = t.ActivityExtended__r.id_attivita__c;
        ae.recordTypeid = OrkStatic.NameIdTasksRecordTyepesMap.get(s.Tipologia__c).getRecordTypeID();
        nt.Status = 'Non iniziata';
        ae.code_status__c = nt.status;
        String dummykey = Utils.generateRandomString(200);
        ae.DummyObjectLink__c = dummykey;
        nt.ActivityExtended__r = new ActivityExtended__c(DummyObjectLink__c = dummykey);
        System.debug('newSetTaskFromJump pre stepFieldsUpdate --> sobjectsToUpdate --> ' + sobjectsToUpdate);
        stepFieldsUpdate(sobjectsToUpdate, objectForPraticaMap, p, ae, 'isCreated');
        return new List<Sobject>{
                ae, nt
        };
    }
    /*** 20210622 MSiotto - Step field Update if a new task is created - End ***/

    //creazione di un task da strategia ricorsiva
    public static List<Sobject> newTask(pratica__c p, strategia__c s) {
        Task nt = new Task();
        ActivityExtended__c ae = new ActivityExtended__c();
        OrkStatic.setTaskRecrdType();
        nt.whatID = p.id;
        ae.Account_id__c = p.Account__c;
        ae.idAccount__c = p.account__c;
        ae.E_da_affidare__c = s.E_da_affidare__c;
        ae.Account_Name__c = p.Account_Name__c;
        ae.Servizio_id__c = p.Servizio_Fornitura__c;
        ae.Servizio_Name__c = p.Servizio_name__c;
        ae.Comune_del_contratto__c = p.comune__c;
        ae.Owner_contratto__c = p.Owner_contratto__c;
        nt.Ownerid = p.ownerid;
        ae.scaduto_iniziale__c = p.Residuo_Totale__c;
        nt.Subject = s.Nome__c;
        ae.Strategia__c = s.Nome_strategia__c;
        ae.id_strategia__c = s.Testata__c;
        ae.Document_code__c = s.document_code__c;
        ae.id_attivita__c = s.id;
        nt.ownerid = p.ownerid;
        nt.type = 'Credito';
        if (s.isSLA_present__c == false) nt.SLA__c = -1; else {
            nt.SLA__c = s.SLA__c;
            ae.Expiration_date__c = system.today().AddDays(integer.valueof(s.SLA__c));
        }
        ae.Fase__c = s.Fase__c;
        //nt.tipo_attivita__c=s.tipo_attivita__c;
        ae.tipo__c = s.tipo_attivita__c;
        //nt.sotto_tipo_attivita__c=s.sotto_tipo_attivita__c;
        ae.sotto_tipo__c = s.sotto_tipo_attivita__c;
        ae.recordTypeid = OrkStatic.NameIdTasksRecordTyepesMap.get(s.Tipologia__c).getRecordTypeID();
        nt.Status = 'Non iniziata';
        ae.code_status__c = nt.status;
        String dummykey = Utils.generateRandomString(200);
        ae.DummyObjectLink__c = dummykey;
        /*if (Utils.checkFLSPermission('ActivityExtended__c', 'Account_id__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'E_da_affidare__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Account_Name__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Servizio_Name__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Comune_del_contratto__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Owner_contratto__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Strategia__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'id_strategia__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Document_code__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'id_attivita__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Expiration_date__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Fase__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'tipo__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'sotto_tipo__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'recordTypeid').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'code_status__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Servizio_id__c').get('CREATE')) insert ae;*/
        nt.ActivityExtended__r = new ActivityExtended__c(DummyObjectLink__c = dummykey);
        return new List<Sobject>{
                ae, nt
        };
    }

    //Creazione del primo Task della Strategia insieme alla prima Attività di ricerca strategia
    public static List<SObject> newTask(Pratica__c p) {
        Task nt = new Task();
        ActivityExtended__c ae = new ActivityExtended__c();
        OrkStatic.setTaskRecrdType();
        nt.WhatId = p.Id;
        ae.Account_id__c = p.Account__c;
        ae.IdAccount__c = p.Account__c;
        ae.Account_name__c = p.Account_Name__c;
        ae.Scaduto_iniziale__c = p.Residuo_Totale__c;
        ae.Servizio_id__c = p.Servizio_Fornitura__c;
        ae.Servizio_name__c = p.Servizio_name__c;
        ae.Comune_del_contratto__c = p.Comune__c;
        ae.Owner_contratto__c = p.Owner_contratto__c;
        nt.OwnerId = p.OwnerId;
        //ae.Tipo__c = 'Inserimento in strategia';
        ae.Tipo__c = Label.ActivityExtType;
        nt.Type = 'Credito';
        //nt.Subject = 'Attività per inserimento in strategia';
        nt.Subject = Label.InserimentoStrategia;
        ae.RecordTypeId = OrkStatic.NameIdTasksRecordTyepesMap.get('Process').getRecordTypeId();
        ae.isFirst__c = true;
        String dummykey = Utils.generateRandomString(200);
        ae.DummyObjectLink__c = dummykey;
        nt.Priority = 'Normal';
        nt.Status = 'Ricerca strategia';
        //nt.Status = Label.TaskStatus;
        nt.SLA__c = -1;
        /*if (Utils.checkFLSPermission('ActivityExtended__c', 'Account_id__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'E_da_affidare__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Account_Name__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Servizio_Name__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Comune_del_contratto__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Owner_contratto__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Strategia__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'id_strategia__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Document_code__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'id_attivita__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Expiration_date__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Fase__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'tipo__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'sotto_tipo__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'recordTypeid').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'code_status__c').get('CREATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Servizio_id__c').get('CREATE')) insert ae;*/
        nt.ActivityExtended__r = new ActivityExtended__c(DummyObjectLink__c = dummykey);
        return new List<SObject>{
                ae, nt
        };
    }

    /*
    *   Il metodo setta le regole di inserimento in strategia e le condizioni di uscita dalla strategia.
    *   Opera recuperando le regole e scrivento le informazioni su una lista di mappe.
    */
    public static string logRules(Pratica__c p, Strategia__c str) {
        if (str.Activation_roles__c == null || str.Activation_roles__c == '') return '';
        List<Map<string, object>> lMap = new List<Map<string, object>>();
        for (string rule : str.Activation_roles__c.split(',')) {
            Map<string, string> r = new Map<string, string>();
            rule_control__c rc = rule_control__c.getInstance(rule);
            if (rc == null) continue;
            r.put('objField', rc.Api_field_name__c);
            if (str == null) r.put('objValue', ''); else r.put('objValue', '' + p.get(rc.Api_field_name__c));
            r.put('condition', rc.Condition__c);
            r.put('strategiaField', rc.Strategia_api_field_name__c);
            r.put('strategiaValue', '' + str.get(rc.Strategia_api_field_name__c));
            r.put('RuleName', rc.Name);
            lMap.add(r);
        }
        return JSON.serialize(lMap);
    }


//////////////////////////////////////////////////////////////////////////////////////////////////////
    public static boolean setJumpError(Task t) {
        t.Status = 'Error';
        t.Description += '\n setJumpError';
        return true;

    }

    public static boolean getTaskFielsPermission(String operation) {
        return (Utils.checkFLSPermission('Task', 'whatID').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'Account_id__c').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'idAccount__c').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'Account_Name__c').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'Servizio_id__c').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'Servizio_Name__c').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'Comune_del_contratto__c').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'E_da_affidare__c').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'Owner_contratto__c').get(operation)
                && Utils.checkFLSPermission('Task', 'Ownerid').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'scaduto_iniziale__c').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'Attivita_precedente__c').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'Attivita_precedente_name__c').get(operation)
                && Utils.checkFLSPermission('Task', 'Subject').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'Strategia__c').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'id_attivita__c').get(operation)
                && Utils.checkFLSPermission('Task', 'type').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'SLA__c').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'Expiration_date__c').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'Fase__c').get(operation)
                && Utils.checkFLSPermission('Task', 'WhoId').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'id_strategia__c').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'Id_Attivit_Precedente__c').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'recordTypeid').get(operation)
                && Utils.checkFLSPermission('Task', 'Status').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'code_status__c').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'tipo__c').get(operation)
                && Utils.checkFLSPermission('ActivityExtended__c', 'sotto_tipo__c').get(operation));
    }

    //Nuovo metodo cebGetTaskFielsPermission per CRABB new engine 11-05-2021
    /*** 20210511 MSiotto - Code Review - Start ***/
    public static boolean cebGetTaskFielsPermission(Map<String, Schema.SObjectType> globalDesc, String operation) {
        return (Utils.cebCheckFLSPermission('Task', 'whatID', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Account_id__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'idAccount__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Account_Name__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Servizio_id__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Servizio_Name__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Comune_del_contratto__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'E_da_affidare__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Owner_contratto__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('Task', 'Ownerid', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'scaduto_iniziale__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Attivita_precedente__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Attivita_precedente_name__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('Task', 'Subject', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Strategia__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_attivita__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('Task', 'type', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'SLA__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Expiration_date__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Fase__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('Task', 'WhoId', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_strategia__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Id_Attivit_Precedente__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'recordTypeid', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('Task', 'Status', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'code_status__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'tipo__c', globalDesc).get(operation)
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'sotto_tipo__c', globalDesc).get(operation));
    }
    /*** 20210511 MSiotto - Code Review - End ***/

    public static boolean setLoopError(Task t) {
        t.Status = 'Error';
        t.Description += '\n setLoopError: ricordarsi che per rielaborare il task, partire dallo stato "Lavorata", in quanto l\'attività è stata già eseguita ';
        return true;
    }
    public static boolean setLoopSuccess(Task t, ActivityExtended__c ae, Pratica__c pratica, Strategia__c jump, Map<id, SObject> sobjectsToUpdate, List<SObject> sobjectsToInsert, List<Log__c> logL) {
        pratica__c praticaToUpdate = (Pratica__c) sobjectsToUpdate.get(pratica.id);
        t.description += '\n setJumpAutomaticoSuccess';
        ae.code_status__c += '_isLoop';
        ae.Condizione_di_salto__c += jump.id + ';';

        /*** 20180727 Msala - Aggiunto per Jump Automatici - Inizio ***/
        //t.description+='\n setJumpSuccess';
        t.Status = 'Saltata';
        //ae.code_status__c+='_isSalto';
        //ae.Condizione_di_salto__c+=jump.id+';';
        ae.isExit_Jump__c = true;
        ae.Data_chiusura__c = system.now();
        ae.Scaduto_finale__c = pratica.Residuo_Totale__c;
        ae.Chiuso_da_id__c = UserInfo.getUserId();
        ae.Chiuso_da_name__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        /*** 20180727 Msala - Aggiunto per Jump Automatici - Fine ***/

        /*if (Utils.checkFLSPermission('ActivityExtended__c', 'code_status__c').get('UPDATE')
            && Utils.checkFLSPermission('ActivityExtended__c', 'Condizione_di_salto__c').get('UPDATE')
            ) update ae;*/

        buildaesProcessMap('setLoopSuccess', ae, 'UPDATE');
        sobjectsToUpdate.put(praticaToUpdate.id, praticaToUpdate);
        return true;
    }

    public static void GestisciRevocaPerScadutoDegliAffidamenti(list<id> idperAffidamento) {
        /* if (Utils.cebCheckObjPermission('Affidamento__c',gd).get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'stato__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Esito_Lavorazione__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Note_elior__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_scaduto_finale__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Scaduto_finale__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Scaduto_iniziale__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Totale_Incassato_sull_Affidamento__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'pratica__c').get('ACCESS')
                && Utils.checkFLSPermission('pratica__c', 'Data_Ultimo_Saldo__c').get('ACCESS')) { */
            List<Affidamento__c> affList = [
                    select id,stato__c, Esito_Lavorazione__c,Data_chiusura_effettiva__c,
                            Note_elior__c,Data_scaduto_finale__c,Scaduto_finale__c,
                            Totale_Incassato_sull_Affidamento__c, Scaduto_iniziale__c,pratica__c,
                            pratica__r.Data_Ultimo_Saldo__c,pratica__r.stato__c,
                            pratica__r.residuo_totale__c
                    from Affidamento__c
                    where id in:idperAffidamento WITH SECURITY_ENFORCED
            ];
            List<pratica__c> pList = new List<pratica__c>();

            for (Affidamento__c a : affList) {
                if (a.pratica__r.stato__c == 'Affidata') {
                    pratica__c p = new pratica__c();
                    p.id = a.pratica__c;
                    p.stato__c = 'In Lavorazione';
                    pList.add(p);
                }
                a.stato__c = 'Scaduto';
                a.Esito_Lavorazione__c = 'Chiuso per scadenza affidamento';
                a.Data_chiusura_effettiva__c = system.today();
                a.Data_scaduto_finale__c = a.pratica__r.Data_Ultimo_Saldo__c;
                a.Scaduto_finale__c = a.pratica__r.residuo_totale__c;
                a.Totale_Incassato_sull_Affidamento__c = a.Scaduto_iniziale__c - a.Scaduto_finale__c;
            }
            if (Utils.cebCheckObjPermission('Affidamento__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'stato__c',gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Esito_Lavorazione__c',gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c',gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_scaduto_finale__c',gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_finale__c',gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Totale_Incassato_sull_Affidamento__c',gd).get('UPDATE')) {
                update affList;
            }

            if (pList != null && pList.size() > 0 && Utils.cebCheckObjPermission('pratica__c',gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('pratica__c', 'stato__c',gd).get('UPDATE')) {
                update pList;

        }
    }

    //12-May-2021 Created for using ceb methods
    /*** 20210512 GMameli - Code Review - Start ***/
    public static void cebGestisciRevocaPerScadutoDegliAffidamenti(list<id> idperAffidamento, Map<String, Schema.SObjectType> globalDesc) {
        if (Utils.cebCheckObjPermission('Affidamento__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'stato__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Esito_Lavorazione__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Note_elior__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_scaduto_finale__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_finale__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_iniziale__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Totale_Incassato_sull_Affidamento__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'pratica__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('pratica__c', 'Data_Ultimo_Saldo__c', globalDesc).get('ACCESS')) {
            List<Affidamento__c> affList = [
                    select id,stato__c, Esito_Lavorazione__c,Data_chiusura_effettiva__c,Note_elior__c,Data_scaduto_finale__c,Scaduto_finale__c,
                            Totale_Incassato_sull_Affidamento__c, Scaduto_iniziale__c,pratica__c, pratica__r.Data_Ultimo_Saldo__c,pratica__r.stato__c,
                            pratica__r.residuo_totale__c
                    from Affidamento__c
                    where id in:idperAffidamento WITH SECURITY_ENFORCED
            ];
            List<pratica__c> pList = new List<pratica__c>();

            for (Affidamento__c a : affList) {
                if (a.pratica__r.stato__c == 'Affidata') {
                    pratica__c p = new pratica__c();
                    p.id = a.pratica__c;
                    p.stato__c = 'In Lavorazione';
                    pList.add(p);
                }
                a.stato__c = 'Scaduto';
                a.Esito_Lavorazione__c = 'Chiuso per scadenza affidamento';
                a.Data_chiusura_effettiva__c = system.today();
                a.Data_scaduto_finale__c = a.pratica__r.Data_Ultimo_Saldo__c;
                a.Scaduto_finale__c = a.pratica__r.residuo_totale__c;
                a.Totale_Incassato_sull_Affidamento__c = a.Scaduto_iniziale__c - a.Scaduto_finale__c;
            }
            if (Utils.cebCheckObjPermission('Affidamento__c',gd).get('UPDATE') && Utils.cebCheckFLSPermission('Affidamento__c', 'stato__c', globalDesc).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Esito_Lavorazione__c', globalDesc).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c', globalDesc).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_scaduto_finale__c', globalDesc).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_finale__c', globalDesc).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Totale_Incassato_sull_Affidamento__c', globalDesc).get('UPDATE')) {
                update affList;
            }

            if (pList != null && pList.size() > 0 && Utils.cebCheckObjPermission('pratica__c',gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('pratica__c', 'stato__c', globalDesc).get('UPDATE')) {
                update pList;
            }
        }
    }
    /*** 20210512 GMameli - Code Review - End ***/


    /**2021-06-10 MSiotto -- New Method for new Engine that sets fields values mapped in the CRABB_DEV__Step_Field_Update__c object when a Task is closed - START **/
    public static void stepFieldsUpdate(Map<id, SObject> sobjectsToUpdate, Map<String, SObject> objectForPraticaMap, Pratica__c pratica, ActivityExtended__c ae, String triggerEvent) {
        try{
            Map<String, List<Step_Field_Update__c>> existingStepFieldsUpdates = new Map<String, List<Step_Field_Update__c>>();
            if(CrabbEngineUtils.existingStepFieldsUpdates.size() == 0 || CrabbEngineUtils.existingStepFieldsUpdates == null) {
                existingStepFieldsUpdates = Ork.existingStepFieldsUpdates;
            } else {
                existingStepFieldsUpdates =  CrabbEngineUtils.existingStepFieldsUpdates;
            }

            if(existingStepFieldsUpdates.containsKey(ae.id_attivita__c+'~'+triggerEvent)) {
                List<Step_Field_Update__c> stepFieldUpdates = existingStepFieldsUpdates.get(ae.id_attivita__c+'~'+triggerEvent);
                Account acc = new Account();
                Servizio__c serv = new Servizio__c();

                if(objectForPraticaMap.containsKey(pratica.Account__c + '_' + Account.getSObjectType().getDescribe().name)) {
                    acc = (Account) objectForPraticaMap.get(pratica.Account__c + '_' + Account.getSObjectType().getDescribe().name);
                }
                if(objectForPraticaMap.containsKey(pratica.servizio_fornitura__c + '_' + Servizio__c.getSObjectType().getDescribe().name)) {
                    serv = (Servizio__c) objectForPraticaMap.get(pratica.servizio_fornitura__c + '_' + Servizio__c.getSObjectType().getDescribe().name);
                }

                String NAMESPACE = Utils.NAMESPACE;

                /*
                Rimosso per errore System.LimitException: CRABB_DEV:Too many SOQL queries: 201
                //for (Step_Field_Update__c step : [SELECT id, CRABB_DEV__Object__c, CRABB_DEV__Field__c, CRABB_DEV__Text_Value__c, CRABB_DEV__Number_Value__c, CRABB_DEV__Checkbox_Value__c, CRABB_DEV__Date_Value__c, CRABB_DEV__Days_to_Add_or_Remove__c, CRABB_DEV__Type__c from CRABB_DEV__Step_Field_Update__c where CRABB_DEV__Strategia__c = :ae.id_attivita__c and CRABB_DEV__Trigger__c = :triggerEvent]) {
                */
                for (Step_Field_Update__c step : stepFieldUpdates) {
                    //CRABB_DEV__Datetime_Value__c, rimossi
                    String objName = step.CRABB_DEV__Object__c.contains(NAMESPACE) ? step.CRABB_DEV__Object__c : NAMESPACE + step.CRABB_DEV__Object__c;
                    objName = objName.contains('__c') ? objName : objName + '__c';
                    String fieldName = step.CRABB_DEV__Field__c.contains(NAMESPACE) ? step.CRABB_DEV__Field__c : NAMESPACE + step.CRABB_DEV__Field__c;
                    fieldName = fieldName.contains('__c') ? fieldName : fieldName + '__c';
                    Object fieldValue;


                    if (step.CRABB_DEV__Type__c == 'Text') {
                        fieldValue = step.CRABB_DEV__Text_Value__c;
                    } else if (step.CRABB_DEV__Type__c == 'Number') {
                        fieldValue = step.CRABB_DEV__Number_Value__c;
                    } else if (step.CRABB_DEV__Type__c == 'Checkbox') {
                        fieldValue = step.CRABB_DEV__Checkbox_Value__c;
                    } else if (step.CRABB_DEV__Type__c == 'Date') {
                        if(step.CRABB_DEV__Date_Value__c == 'TODAY +') {
                            fieldValue = Date.today().addDays(+Integer.valueOf(step.CRABB_DEV__Days_to_Add_or_Remove__c));
                        } else if(step.CRABB_DEV__Date_Value__c == 'TODAY -') {
                            fieldValue = Date.today().addDays(-Integer.valueOf(step.CRABB_DEV__Days_to_Add_or_Remove__c));
                        }
                    } else if (step.CRABB_DEV__Type__c == 'Datetime') {
                        if(step.CRABB_DEV__Date_Value__c == 'TODAY +') {
                            fieldValue = Datetime.now().addDays(+Integer.valueOf(step.CRABB_DEV__Days_to_Add_or_Remove__c));
                        } else if(step.CRABB_DEV__Date_Value__c == 'TODAY -') {
                            fieldValue = Datetime.now().addDays(-Integer.valueOf(step.CRABB_DEV__Days_to_Add_or_Remove__c));
                        }
                    }

                    if (objName == pratica.getSObjectType().getDescribe().name) {
                        //if (!String.valueOf(fieldValue).equalsIgnoreCase(String.valueOf(pratica.get(fieldName)))) {
                        pratica.put(fieldName, fieldValue);
                        //}
                    } else if (objName == serv.getSObjectType().getDescribe().name && pratica.CRABB_DEV__Servizio_Fornitura__c != null) {
                        //if (!String.valueOf(fieldValue).equalsIgnoreCase(String.valueOf(serv.get(fieldName))) && fieldValue!=null) {
                        serv.put(fieldName, fieldValue);
                        //}
                    } else if (step.CRABB_DEV__Object__c.equalsIgnoreCase(acc.getSObjectType().getDescribe().name) && pratica.CRABB_DEV__Account__c != null) {
                        //if (!String.valueOf(fieldValue).equalsIgnoreCase(String.valueOf(acc.get(fieldName))) && fieldValue!=null) {
                        acc.put(fieldName, fieldValue);
                        //}
                    }
                }

                if (pratica != null)
                    sobjectsToUpdate.put(pratica.id, pratica);
                if (pratica.CRABB_DEV__Account__c != null && !sobjectsToUpdate.containsKey(pratica.CRABB_DEV__Account__c))
                    sobjectsToUpdate.put(pratica.CRABB_DEV__Account__c, acc);
                if (pratica.CRABB_DEV__Servizio_Fornitura__c != null && !sobjectsToUpdate.containsKey(pratica.CRABB_DEV__Servizio_Fornitura__c))
                    sobjectsToUpdate.put(pratica.CRABB_DEV__Servizio_Fornitura__c, serv);
            }

        } catch(Exception e) {
            System.debug('Exception on stepFieldUpdate ' + e.getLineNumber() + ' - ' + e.getMessage());
        }


    }
    /**2021-06-10 MSiotto -- New Method for new Engine that sets fields values mapped in the CRABB_DEV__Step_Field_Update__c object when a Task is closed - END **/
}