/* ---------------------------------------------------------------------------------------------------------------------
Name:            CambioAttivitaPuntualeCTRL.cls
Description:
Test class:      TestCambioAttivitaPuntualeCTRL.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
02-Feb-2015  0.1      E.Sino                          First Version
12-Sep-2022  0.2      C.Sanna & R. Kurti              Added cebCheck Obj/FLS security and WITH SECURITY_ENFORCED (Security Review)
10-Oct-2022  0.3      R.Kurti & C.Sanna               Removed WITH SECURITY ENFORCED
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class CambioAttivitaPuntualeCTRL {

    public class CambioAttivitaPuntualeCTRLException extends Exception {
    }

    /*Gestione selezioni iniziali*/
    public String StrategieSelectable { get; set; }
    public String TaskDa { get; set; }
    public list<String> OriginalValuesTaskDa { get; set; }
    public List<SelectOption> UnselectedTaskDa { get; set; }
    public String TaskA { get; set; }
    public list<String> OriginalValuesTaskA { get; set; }
    public List<SelectOption> UnselectedTaskA { get; set; }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();


    //ES
    public boolean idPratCorretto { get; set; }
    public id idPratica { get; set; }
    public pratica__c myPrat;
    public id idTestata { get; set; }
    public strategia__c myTestata;
    public List<Strategia__c> mySteps { get; set; }
    public integer numSteps { get; set; }
    public List<Task> lTasksOpened;
    public boolean isOnlyOneStep { get; set; }
    public boolean erroreHappened { get; set; }
    public set<id> StepStrAssocATaskOpen;

    public string errorMsg { get; set; }

    public CambioAttivitaPuntualeCTRL() {
        TaskDa = 'NA';
        TaskA = 'NA';
        OriginalValuesTaskDa = new List<String>();
        OriginalValuesTaskA = new List<String>();
        StrategieSelectable = '';

        errorMsg = '';
        erroreHappened = false;

        mySteps = new list<Strategia__c>();
        StepStrAssocATaskOpen = new Set<id>();
        lTasksOpened = new List<Task>();
        setPratId();// prendi Prat & co
        getTasksOpened();// Prendi Task associati alla Prat.
        System.debug('\n Steps(Tasks): ' + lTasksOpened);
        popolaTestataESteps();// Prendi testata&step
        System.debug('\n Pratica__c: ' + myPrat + '\n MyTestata: ' + myTestata);
        System.debug('\n Steps(STR): ' + mySteps);
        recuperaTaskOverride();
        System.debug('\n isOnlyOneStep: ' + isOnlyOneStep + '\n Errore? ' + erroreHappened);
    }

    /*
     * ES: Sviluppi per il cambio puntuale.
     * 
     */

    // Set le id della pratica e controlla la validitá del id.
    public void setPratId() {
        try {
            if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Strategia__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Name', gd).get('ACCESS')) {
                this.idPratica = ApexPages.currentPage().getParameters().get('Id');
                //this.myPrat = [Select id, Strategia__c, Name From Pratica__c where id = :this.idPratica WITH SECURITY_ENFORCED];
                this.myPrat = [Select id, Strategia__c, Name From Pratica__c where id = :this.idPratica];
            }
        } catch (Exception e) {
            System.debug('\n Linea: ' + e.getLineNumber() + '\n **SetPratId(): Id scorretto!');
            errorMsg = 'Attenzione: Questa pratica non é valida!';
            erroreHappened = true;
        }
    }

    // MEtodo per tradurrere i Task associati alla pratica in steps
    public void getTasksOpened() {
        try {
            if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'whatId', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'status', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'SLA__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Subject', gd).get('ACCESS')
                    && Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('ACCESS')) {
                /*lTasksOpened = [
                    Select id, whatId, ActivityExtended__r.id_attivita__c, Subject, status, SLA__c, Giorni_di_completamento_attivita__c
                    From Task
                    where isClosed = false and Status != 'Completata' and whatId = :idPratica and Record_Type__c = 'UI'
                    WITH SECURITY_ENFORCED
            ];*/
                lTasksOpened = [
                        Select id, whatId, ActivityExtended__r.id_attivita__c, Subject, status, SLA__c, Giorni_di_completamento_attivita__c
                        From Task
                        where isClosed = false and Status != 'Completata' and whatId = :idPratica and Record_Type__c = 'UI'
                ];
                System.debug('\n getTasksOpened(), lTasksOpened: ' + lTasksOpened);
                numSteps = lTasksOpened.size();
                if (numSteps == 0) {
                    errorMsg = 'Attenzione: Non esistono task aperti per questa pratica!';
                    erroreHappened = true;
                    return;
                }
                isOnlyOneStep = (numSteps == 1);
                for (Task t : lTasksOpened) {
                    StepStrAssocATaskOpen.add(t.ActivityExtended__r.id_attivita__c);
                }
                System.debug('\n CambioAttiPunt, getTasksOpened(): ' + StepStrAssocATaskOpen);
            }
        } catch (Exception e) {
            errorMsg = 'Attenzione: Non esistono task aperti per questa pratica!';
            erroreHappened = true;
            System.debug('\n Errore, getTasksOpened: ' + e.getStackTraceString());
        }
    }

    // Leggi la testata e i step allegati
    public void popolaTestataESteps() {
        try {
            if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'Tipologia__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'Testata__c', gd).get('ACCESS')) {
                myTestata = [Select id, Nome__c From Strategia__c where id = :myPrat.Strategia__c];
                //myTestata = [Select id, Nome__c From Strategia__c where id = :myPrat.Strategia__c WITH SECURITY_ENFORCED];
                idTestata = myTestata.id;
                StrategieSelectable = myTestata.nome__c;
                //mySteps = [SELECT Id, Nome__c, Tipologia__c FROM Strategia__c WHERE Testata__c = :idTestata AND RecordType.Name = 'Step' WITH SECURITY_ENFORCED];
                mySteps = [SELECT Id, Nome__c, Tipologia__c FROM Strategia__c WHERE Testata__c = :idTestata AND RecordType.Name = 'Step'];
            }
        } catch (Exception e) {
            this.errorMsg = 'Attenzione: la strategia o gli step associati alla strategia non esistono!';
            this.erroreHappened = true;
            System.debug('\n Errore*****: ' + e.getMessage() + '\n Linea: ' + e.getLineNumber());
        }
    }

    // Overide per gestire il caso puntuale
    // Scenario 1: C'é solo un task di partenza(visualizza solo TaskDa)
    // Scenario 2: Ci sono piú di un task di partenza(Lascia il metodo standard di scelta)
    public void recuperaTaskOverride() {
        try {
            OriginalValuesTaskDa.clear();
            OriginalValuesTaskA.clear();
            TaskDa = 'NA';
            TaskA = 'NA';
            if (isOnlyOneStep) {
                for (Strategia__c tmp : mySteps) {
                    if (tmp.Nome__c.equalsIgnoreCase(lTasksOpened.get(0).Subject)) {
                        TaskDA = tmp.Nome__c;
                        break;
                    }
                }
                //TaskDA = mySteps[0].Nome__c;
            }
            System.debug('\n **recuperaTaskOverride, idTestata: ' + idTestata);
            if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                    && Utils.checkFLSPermission('Strategia__c', 'Nome__c').get('ACCESS')
                    && Utils.checkFLSPermission('Strategia__c', 'Tipologia__c').get('ACCESS')) {
                List<Strategia__c> TaskAttivi = [
                        SELECT Id, Nome__c, Tipologia__c
                        FROM Strategia__c
                        //WHERE Testata__c = :idTestata AND RecordType.Name = 'Step'];
                        WHERE Testata__c = :idTestata AND RecordType.Name = 'Step'
                        //WITH SECURITY_ENFORCED
                ];
                System.debug('\n **recuperaTaskOverride, taskAttivi: ' + TaskAttivi);
                for (Strategia__c s : TaskAttivi) {
                    if (s.Tipologia__c == 'UI') {
                        OriginalValuesTaskA.add(s.Nome__c);
                    }/* Old Filters: More Specific for Elior
    				if(StrategieSelectable=='STRATEGIA CONCESSIONE' && (s.Nome__c =='Gestione Manuale post diffida' || s.Nome__c == 'Attesa verifica condizioni' || s.Tipologia__c=='UI')){
                        OriginalValuesTaskA.add(s.Nome__c);
                    }
                    if(StrategieSelectable=='STRATEGIA APPALTI' && (s.Nome__c == 'Doppio invio completato' || s.Tipologia__c=='UI')){
                        OriginalValuesTaskA.add(s.Nome__c);
                    }
                    if(StrategieSelectable=='STRATEGIA CONCESSIONE COMUNE DI RHO' && (s.Nome__c == 'Candidato per invio lettera' || s.Tipologia__c=='UI')){
                        OriginalValuesTaskA.add(s.Nome__c);
                    }
                    if(StrategieSelectable=='STRATEGIA AUTOMATICA MENSILE' && (s.Nome__c == 'Clienti non sollecitabili da normalizzare' || s.Tipologia__c=='UI')){
                        OriginalValuesTaskA.add(s.Nome__c);
                    }     */
                }
            }
            if (!isOnlyOneStep) {
                /* OLD Implementation 
				for(Strategia__c s: mySteps){
                    OriginalValuesTaskDa.add(s.Nome__c);
                }*/
                for (Task s : lTasksOpened) {
                    OriginalValuesTaskDa.add(s.subject);
                }
                UnselectedTaskDa = getunSelectedValues(OriginalValuesTaskDa);
            }
            UnselectedTaskA = getunSelectedValues(OriginalValuesTaskA);
        } catch (Exception e) {
            System.debug('\n Errore*****: ' + e.getMessage() + '\n Linea: ' + e.getLineNumber());
        }

    }

    public List<SelectOption> getunSelectedValues(List<String> original) {
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(original);
        for (string b : tempList)
            options.add(new SelectOption(b, b));
        return options;
    }

    // Passa il task aperto, switch
    public pageReference Conferma() {
        // 1. Leggi il step scelto:
        System.debug('\n Conferma(), \n TaskDA: ' + TaskDA + '\nTaskA: ' + TaskA);
        Task TaskScelta = new Task();
        Boolean taskOk = false;
        for (Task t : lTasksOpened) {
            if (t.Subject == TaskDa) {
                TaskScelta = t;
                taskOk = true;
                break;
            }
        }

        // 2. Switch task as chosen by user
        if (taskOk && lavoraStep(TaskScelta)) {
            PageReference p = new pageReference('/' + idPratica);
            //p.setRedirect(true);
            return p;
        } else {
            errorMsg = 'Attenzione: errore durante la lavorazione!';
            erroreHappened = true;
            System.debug(errorMsg);
            return null;
        }
    }

    public boolean lavoraStep(Task t) {
        if (t == null) {
            return false;
        }
        if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Nome__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Testata__c').get('ACCESS')
                && Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'isForcedoperation__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Go_to_Strategia__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Go_to_task_of_strategie__c', gd).get('ACCESS')) {
            System.debug('lavora Step task is:' + t);
            //Id IdStepA = [SELECT Id FROM Strategia__c WHERE RecordType.Name = 'Step' AND Nome__c = :TaskA AND Testata__c = :idTestata WITH SECURITY_ENFORCED LIMIT 1].Id;
            Id IdStepA = [SELECT Id FROM Strategia__c WHERE RecordType.Name = 'Step' AND Nome__c = :TaskA AND Testata__c = :idTestata LIMIT 1].Id;
            System.debug('TASK lavora step:' + t);
            ActivityExtended__c ae = [
                    Select isForcedOperation__c, Go_to_Strategia__c, Go_to_task_of_strategie__c
                    //from ActivityExtended__c where Id = :t.ActivityExtended__c LIMIT 1];
                    from ActivityExtended__c
                    where Id = :t.ActivityExtended__c
                    //WITH SECURITY_ENFORCED
                    LIMIT 1
            ];
            ae.isForcedOperation__c = true;
            ae.Go_to_Strategia__c = idTestata;
            ae.Go_to_task_of_strategie__c = IdStepA;
            System.debug('\n Extended Task BeforeUpdate: ' + ae);
            if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                    && Utils.cebCheckObjPermission('Task', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'isForcedOperation__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Go_to_Strategia__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Go_to_task_of_strategie__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Task', 'Subject', gd).get('UPDATE')) {
                update ae;
                update t;
            } else {
                System.debug('Problem with permissions');
                return false;
            }

            System.debug('\n Task AfterUpdate: ' + t);
        }
        return true;

    }
    //MSala 12/01/2015 Inizio
    public pageReference UpdateTaskDa() {
        TaskDa = String.isNotBlank(apexpages.currentpage().getparameters(). get ('pTaskDa')) ? String.escapeSingleQuotes(apexpages.currentpage().getparameters(). get ('pTaskDa')) : null;

        return null;
    }

    public pageReference UpdateTaskA() {
        TaskA = String.isNotBlank(apexpages.currentpage().getparameters().get('pTaskA')) ? String.escapeSingleQuotes(apexpages.currentpage().getparameters().get('pTaskA')) : null;

        return null;
    }
}