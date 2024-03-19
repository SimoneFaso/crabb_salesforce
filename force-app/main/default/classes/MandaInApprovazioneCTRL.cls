/* ---------------------------------------------------------------------------------------------------------------------
Name:            MandaInApprovazioneCTRL.cls
Description:
Test class:      TestMandaInApprovazioneCTRL.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
05-Feb-2015  0.1      Endrit Sino                     First Version

16-Jun-2016  0.2      Endrit Sino                     Aggiunto il with sharing come richiesta da Salesforce.com
                                                      per soddisfare le specifichedel Security Review.
27-Sep-2021  0.3      Matteo Pizzichini               Modified for adding check permission:
                                                      Braces added to if, cebCheckFLSPermission (Security Review)
16-Sep-2022  0.4      C.Sanna & R.Kurti               Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class MandaInApprovazioneCTRL {

    public list<String> OriginalValuesTaskDa { get; set; }
    public List<SelectOption> UnselectedTaskDa { get; set; }
    public String TaskA { get; set; }
    public boolean idPratCorretto { get; set; }
    public id idPratica { get; set; }
    public pratica__c myPrat;

    public integer numSteps { get; set; }
    public List<Task> lTasksOpened;
    public boolean idUtenteCorretto { get; set; }
    public boolean erroreHappened { get; set; }
    public string soggettoTaskDaRimuovere, statiTaskAperto;
    public id userId, RoleId, managerId;
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public set<String> statiTaskApertoSet {
        get {
            if (statiTaskApertoSet == null) {
                statiTaskAperto = TagHelper.getValueTextOrNull('StatiTaskAperto');
                if (statiTaskAperto == null || statiTaskAperto == '') {
                    return new Set<String>{
                            'In corso'
                    };
                } else {
                    System.debug('\n dentro get-set: ' + statiTaskAperto);
                    return Utils.sliptString(statiTaskAperto, ',');
                }
            } else
                    return statiTaskApertoSet;
        }
        set;
    }

    public MandaInApprovazioneCTRL() {
        TaskA = 'NA';
        soggettoTaskDaRimuovere = '';
        erroreHappened = false;

        OriginalValuesTaskDa = new List<String>();
        lTasksOpened = new List<Task>();
        checkUserId();
        setPratId();// prendi Prat & co
        getTasksOpened();// Prendi Task associati alla Prat.
        recuperaTaskOverride();//popola le liste dei task        
    }

    /*
     * ES: Sviluppi per mandare task in Approvazione
     */

    // check la id del utente che puó accedere la pagina
    public void checkUserId() {
        try {
            idUtenteCorretto = false;
            userId = UserInfo.getUserId();
            if(Utils.cebCheckObjPermission('User',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('User','managerId',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('User','UserRoleId',gd).get('ACCESS')) {
                User u = [Select id, managerId, UserRoleId From User where id = :userId];
                //User u = [Select id, managerId, UserRoleId From User where id = :userId WITH SECURITY_ENFORCED];
                this.roleId = u.UserRoleId;
                this.managerId = u.ManagerId;
                idUtenteCorretto = (this.roleId == getOperatorRoleId());// É un operatore??
                if (!idUtenteCorretto)erroreHappened = true;
            }
        } catch (Exception e) {
            System.debug('\n checkUserId, Errore: ' + e.getMessage());
        }
    }

    // Leggi il id del ruolo dei operatore
    public string getOperatorRoleId() {
        return TagHelper.getValueText('Ruolo Operatore Credito Id');
    }

    // Set le id della pratica e controlla la validitá del id.
    public void setPratId() {
        try {
            idPratCorretto = false;
            this.idPratica = ApexPages.currentPage().getParameters().get('Id');
            if(Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS')) {
                //this.myPrat = [Select id From Pratica__c where id = :this.idPratica WITH SECURITY_ENFORCED];
                this.myPrat = [Select id From Pratica__c where id = :this.idPratica];
                idPratCorretto = true;
                if (!idPratCorretto)erroreHappened = true;
            }
        } catch (Exception e) {
            System.debug('\n setPratid(), Linea: ' + e.getLineNumber() + '\n **SetPratId(): Id scorretto!');
            idPratCorretto = false;
        }
    }

    // MEtodo per tradurrere i Task associati alla pratica in steps
    public void getTasksOpened() {
        try {
            System.debug('\n statiTaskApertoSet: ' + statiTaskApertoSet);
            if(Utils.cebCheckObjPermission('Task',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task','whatId',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task','Subject',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task','Status',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task','ActivityExtended__c',gd).get('ACCESS')) {
                lTasksOpened = [
                        Select id, whatId, Subject, status
                        From Task
                        where status in :statiTaskApertoSet
                        and whatId = :idPratica and RecordType.name = 'UI'
                        AND ActivityExtended__r.Stato_Approvazione__c = 'NA'
                        //WITH SECURITY_ENFORCED
                ];
                numSteps = lTasksOpened.size();
                if (numSteps == 0) {
                    erroreHappened = true; return;
                }// non ci sono task da lavorare
                System.debug('\n numSteps: ' + numSteps + '\n CambioAttiPunt, getTasksOpened(): ' + lTasksOpened);
            }
        } catch (Exception e) {
            System.debug('\n Errore, getTasksOpened: ' + e.getStackTraceString());
        }
    }

    // Compila lista da scegliere task    
    // *Nominata Override, perché ha soprascritto la funzionalitá simile
    // dal controller di partenza    
    public void recuperaTaskOverride() {
        OriginalValuesTaskDa.clear();
        TaskA = 'NA';

        // Usata un set, per rimuovere i duplicati
        Set<String> OriginalValuesTaskDaTemp = new Set<String>();
        for (Task t : lTasksOpened) {
            OriginalValuesTaskDaTemp.add(t.Subject);
        }
        OriginalValuesTaskDa = new List<String>(OriginalValuesTaskDaTemp);
        System.debug('\n Lista dei opzioni, OriginalValuesTaskDa: ' + OriginalValuesTaskDa);
        UnselectedTaskDa = getunSelectedValues(OriginalValuesTaskDa);
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
        boolean success = lavoraStep();
        // Rimuovi dalla lista i task da scegliere
        integer len = OriginalValuesTaskDa.size();
        for (integer i = 0; i < len; i++) {
            if (OriginalValuesTaskDa[i] == soggettoTaskDaRimuovere) {
                OriginalValuesTaskDa.remove(i);
                soggettoTaskDaRimuovere = '';
                break;
            }
        }
        System.debug('\n Conferma(), Esito: ' + success);
        return null;
    }
    // ES, 24/03/2015: *Da aggiustare per distinguere i duplicati   
    public boolean lavoraStep() {
        try {
            if(Utils.cebCheckObjPermission('Task',gd).get('ACCESS')
                    && Utils.cebCheckObjPermission('ActivityExtended__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Status',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Subject',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_Manager_Da_Approvare__c',gd).get('ACCESS'))
            {
            List<Task> lt = new List<Task>([
                    SELECT status, ActivityExtended__r.id_Manager_Da_Approvare__c
                    FROM Task
                    WHERE Subject = :TaskA AND WhatID = :idPratica AND Status in :statiTaskApertoSet
                    AND ActivityExtended__r.Stato_Approvazione__c = 'NA'
                    //WITH SECURITY_ENFORCED
            ]);
            if (lt == null || lt.size() == 0) return false;
            sendTasksForApproval(lt);
            soggettoTaskDaRimuovere = TaskA;
            TaskA = 'NA';
            System.debug('\n lavoraStep, Task modificato: ' + lt);
            }
            return true;
        } catch (Exception e) {
            System.debug('\n lavoraStep, errore: ' + e.getMessage());
            return false;
        }
    }

    // Metodo che manda task in approvazione
    private void sendTasksForApproval(List<Task> lt) {
        Map<Id, ActivityExtended__c> task2Obj = Utils.getTaskWithActivityExtended(lt);
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Task t : lt) {
            t.status = 'In approvazione';
            if (task2Obj.containsKey(t.Id)) {
                ActivityExtended__c ae = task2Obj.get(t.Id);
                ae.id_Manager_Da_Approvare__c = this.managerId;
                aes.add(ae);
            }
        }
        //if (Utils.checkFLSPermission('ActivityExtended__c', 'id_Manager_Da_Approvare__c').get('UPDATE')) update aes;
        //if (Utils.checkFLSPermission('Task', 'status').get('UPDATE')) update lt;
        if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_Manager_Da_Approvare__c', gd).get('UPDATE')) {
            update aes;
        }
        if (Utils.cebCheckObjPermission('Task', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Task', 'status', gd).get('UPDATE')) {
            update lt;
        }
    }

    public pageReference Indietro() {
        Pagereference p = new Pagereference('/' + this.idPratica);
        return p;
    }

    public pageReference UpdateTaskA() {
        TaskA = apexpages.currentpage().getparameters().get('pTaskA');

        return null;
    }

}