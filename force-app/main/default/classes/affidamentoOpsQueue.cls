public with sharing class affidamentoOpsQueue implements Queueable {
    public List<Affidamento__c> affidamentoList;
    public List<Pratica__c> praticaList;
    public List<Task> taskList;

    public affidamentoOpsQueue(List<Affidamento__c> affidamentoList, List<Pratica__c> praticaList, List<Task> taskList) {
        this.affidamentoList = affidamentoList;
        this.praticaList = praticaList;
        this.taskList = taskList;
    }

    public void execute(QueueableContext context) {
        affidamentoOpsQueue queueUpdate;

        if(affidamentoList <> null) {
            if ( Utils.checkFLSPermission('Affidamento__c', 'id_Task_associato__c').get('UPDATE')
                    && Utils.checkFLSPermission('Affidamento__c', 'stato__c').get('UPDATE')
                    && Utils.checkFLSPermission('Affidamento__c', 'Data_scaduto_iniziale__c').get('UPDATE')
                    && Utils.checkFLSPermission('Affidamento__c', 'Scaduto_iniziale__c').get('UPDATE')
                    && Utils.checkFLSPermission('Affidamento__c', 'Data_Affidamento__c').get('UPDATE')
                    && Utils.checkFLSPermission('Affidamento__c', 'Note_elior__c').get('UPDATE')
                    && Utils.checkFLSPermission('Affidamento__c', 'Scaduto_finale__c').get('UPDATE')
                    && Utils.checkFLSPermission('Affidamento__c', 'Esito_Lavorazione__c').get('UPDATE')
                    && Utils.checkFLSPermission('Affidamento__c', 'Totale_Incassato_sull_Affidamento__c').get('UPDATE')
                    ) {
                update affidamentoList;
                queueUpdate = new affidamentoOpsQueue(null, praticaList, taskList);
            }
        } else if(praticaList <> null) {
            if (Utils.checkFLSPermission('Pratica__c', 'stato__c').get('UPDATE')
                    && Utils.checkFLSPermission('Pratica__c', 'Nome_Collector_Attivo__c').get('UPDATE')
                    ) {
                update praticaList;
                queueUpdate = new affidamentoOpsQueue(null, null, taskList);
            }
        } else if(taskList <> null) {
            if (Utils.checkFLSPermission('Task', 'Status').get('UPDATE'))
                update taskList;
        }


        if(queueUpdate <> null && !Test.isRunningTest()) System.enqueueJob(queueUpdate);
    }

}