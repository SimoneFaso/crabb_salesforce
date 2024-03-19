/* ---------------------------------------------------------------------------------------------------------------------
Name:            ApprovaTaskManagerCTRL.cls
Description:     Controller for Task Approving. Starting class: MandaInApprovazioneCTR.cls
Test class:      TestApprovaTaskManagerCTRL.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
06-Feb-2015  0.1      E.Sino                          First Version
16-Jun-2016  0.2      E. Sino                         Added with sharing (Security Review)
12-Sep-2022  0.3      C. Sanna                        Modified for adding check permission:
                                                      cebCheckObjPermission, cebCheckFLSPermission and WITH SECURITY_ENFORCED
                                                      (Security Review)
10-Oct-2022  0.4      R.Kurti & C.Sanna               Removed WITH SECURITY ENFORCED
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class ApprovaTaskManagerCTRL {

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
    public string soggettoTaskDaRimuovere;
    public id userId, RoleId;
    public boolean isApproved;//Memorizzare se é una Rifiuta/approva

    public static string debugStr = '';
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    public ApprovaTaskManagerCTRL() {
        TaskA = 'NA';
        soggettoTaskDaRimuovere = '';
        erroreHappened = false;

        OriginalValuesTaskDa = new List<String>();
        lTasksOpened = new List<Task>();
        checkUserId();
        setPratId();// prendi Prat & co        
        getTasksOpened();// Prendi Task associati alla Prat.
        recuperaTaskOverride();//popola le liste dei task  
        debugStr += '\n Costruttore, UserId: ' + userId + '\n ManagerId(tasks): ' + lTasksOpened;
    }

    /*
     * ES: Sviluppi per mandare task in Approvazione
     */

    // check la id del utente che puó accedere la pagina
    public void checkUserId() {
        try {
            idUtenteCorretto = false;
            userId = UserInfo.getUserId();
            if (Utils.cebCheckObjPermission('User', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('User', 'managerId', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('User', 'UserRoleId', gd).get('ACCESS')) {   //new ceb check after removing WITH SECURITY ENFORCED from query User u
                User u = [Select id, managerId, UserRoleId From User where id = :userId];
                //User u = [Select id, managerId, UserRoleId From User where id=:userId WITH SECURITY_ENFORCED];
                this.userId = u.id;// perche eper filtrare le pratiche secondo il m¿anager, si comparano id di 15 caratteri.
                this.roleId = UserInfo.getUserRoleId();
                idUtenteCorretto = (this.roleId == getManagerRoleId());// É un manager??
                if (!idUtenteCorretto)erroreHappened = true;
                debugStr += '\n Utente Corretto: ' + String.valueOf(idUtenteCorretto);
            }
        } catch (Exception e) {
            System.debug('ApprovaTaskManagerCTRL, checkUserID() Dettagli: ' + Utils.getExceptionInString(e));
            //ErrorClass.logError('\n ApprovaTaskManagerCTRL, checkUserID()', 'Dettagli: ' + Utils.getExceptionInString(e));
        }
    }

    // Leggi il id del ruolo dei operatore
    public string getManagerRoleId() {
        return TagHelper.getValueText('Ruolo Credit Manager Id');
    }

    // Set le id della pratica e controlla la validitá del id.
    public void setPratId() {
        try {
            idPratCorretto = false;
            this.idPratica = String.isNotBlank(ApexPages.currentPage().getParameters().get('Id')) ? String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('Id')) : null;
            if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')){
                this.myPrat = [Select id From Pratica__c where id = :this.idPratica];
                //this.myPrat = [Select id From Pratica__c where id =: this.idPratica WITH SECURITY_ENFORCED];
                idPratCorretto = true;
                if (!idPratCorretto)erroreHappened = true;
                debugStr += '\n Pratica Corretta: ' + String.valueOf(idPratCorretto);
            }
        } catch (Exception e) {
            idPratCorretto = false;
            System.debug('ApprovaTaskManagerCTRL, setPratId() Dettagli: ' + Utils.getExceptionInString(e));
            //ErrorClass.logError('\n ApprovaTaskManagerCTRL, setPratId()', 'Dettagli: ' + Utils.getExceptionInString(e));
        }
    }

    // MEtodo per tradurrere i Task associati alla pratica in steps
    public void getTasksOpened() {
        try {
            /*
            if (Utils.checkFLSPermission('Task', 'ActivityExtended__c').get('ACCESS')
                    && Utils.checkFLSPermission('ActivityExtended__c', 'id_Manager_Da_Approvare__c').get('ACCESS'))
             */
            if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task','Status',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task','whatId',gd).get('ACCESS')
                    && Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_Manager_Da_Approvare__c', gd).get('ACCESS')) { // new cebCheck after removing WITH SECURITY ENFORCED
                //lTasksOpened = [Select Subject, ActivityExtended__r.id_Manager_Da_Approvare__c From Task where status = 'In approvazione' and whatId =: idPratica and RecordType.name = 'UI' and ActivityExtended__r.id_Manager_Da_Approvare__c =: userId WITH SECURITY_ENFORCED];
                lTasksOpened = [Select Subject, ActivityExtended__r.id_Manager_Da_Approvare__c From Task where status = 'In approvazione' and whatId = :idPratica and RecordType.name = 'UI' and ActivityExtended__r.id_Manager_Da_Approvare__c = :userId];
                System.debug('\n Task: ' + lTasksOpened);
                numSteps = lTasksOpened.size();
                if (numSteps == 0) {
                    erroreHappened = true; return;
                }// non ci sono task da lavorare
                debugStr += '\n NumSteps: ' + String.valueOf(numSteps);
            }
        } catch (Exception e) {
            System.debug('ApprovaTaskManagerCTRL, getTasksOpened() Dettagli: ' + Utils.getExceptionInString(e));
            //ErrorClass.logError('\n ApprovaTaskManagerCTRL, getTasksOpened()','\n Errore, getTasksOpened: '+ e.getStackTraceString());
        }
    }

    // // Compila lista da scegliere task        
    public void recuperaTaskOverride() {
        OriginalValuesTaskDa.clear();
        TaskA = 'NA';

        // Usata un set, per rimuovere i duplicati
        Set<String> OriginalValuesTaskDaTemp = new Set<String>();
        debugStr += '\n PicklistValues: ';
        for (Task t : lTasksOpened) {
            OriginalValuesTaskDaTemp.add(t.Subject);
            debugStr += '\n ' + t.Subject;
        }
        OriginalValuesTaskDa = new List<String>(OriginalValuesTaskDaTemp);
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

    /*
     * LAVORAZIONE: 2 CASISTICHE, APPROVA & RIFFIUTA
     */
    public pageReference approva() {
        isApproved = true;
        Conferma();
        return null;
    }

    public pageReference rifiuta() {
        isApproved = false;
        Conferma();
        return null;
    }

    public void Conferma() {
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
        debugStr += '\n Conferma(), Esito: ' + String.ValueOf(success);
    }

    public boolean lavoraStep() {
        try {
            /*if (Utils.checkFLSPermission('Task', 'ActivityExtended__c').get('ACCESS')
                    && Utils.checkFLSPermission('ActivityExtended__c', 'Stato_Approvazione__c').get('ACCESS')) {*/
            if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c', gd).get('ACCESS')
                    && Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Stato_Approvazione__c', gd).get('ACCESS')) {
                // List<Task> lt = [SELECT status, Subject, id, ActivityExtended__r.Stato_Approvazione__c FROM Task WHERE Subject = :TaskA AND whatId =: idPratica AND Status = 'In approvazione' WITH SECURITY_ENFORCED];
                List<Task> lt = [SELECT status, Subject, id, ActivityExtended__r.Stato_Approvazione__c FROM Task WHERE Subject = :TaskA AND whatId = :idPratica AND Status = 'In approvazione'];

                if (lt == null) {
                    return false;
                }
                updateTasks(lt, isApproved);
                ErrorClass.logError('ApprovazioneTaskManager, lavorastep()', '\n Esito Lavorazione: ' + debugStr);
                soggettoTaskDaRimuovere = TaskA;
                TaskA = 'NA';
            }
            return true;

        } catch (Exception e) {
            ErrorClass.logError('ApprovazioneTaskManager, lavorastep()', '\n Messaggio Errore: ' + e.getMessage());
            return false;
        }
    }


    private void updateTasks(List<Task> lt, boolean isApproved) {
        debugStr += '\n UpdateTAsks(), Esito: ';
        Map<Id, ActivityExtended__c> task2Obj = Utils.getTaskWithActivityExtended(lt);
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (Task t : lt) {
            t.status = 'Non iniziata';
            ActivityExtended__c ae = task2Obj.get(t.id);
            if (ae != null) {
                ae.Stato_Approvazione__c = (isApproved) ? 'OK' : 'KO';
                aes.add(ae);
            }
            debugStr += '\n Task Status: ' + t.status + '\n Approvazione Status: ' + isApproved;
        }
/*
if (Utils.checkFLSPermission('ActivityExtended__c', 'Stato_Approvazione__c').get('UPDATE')) update aes;
if (Utils.checkFLSPermission('Task', 'status').get('UPDATE')) update lt;
 */
        if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_Manager_Da_Approvare__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Stato_Approvazione__c', gd).get('UPDATE')) {
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
        TaskA = apexpages.currentpage().getparameters(). get ('pTaskA');

        return null;
    }

}