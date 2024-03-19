/**
 * Created by Francesco on 23/11/2018.
 */

global with sharing class EsitiCollectorChiusuraAffidiBatch implements Database.Batchable<SObject>, Database.Stateful{

    Integer scopeSize = 1000;

    public List<Id> tasks {get; set;}
    public List<Id> prats {get; set;}

    global EsitiCollectorChiusuraAffidiBatch(List<Id> tasks)
    {
        this.tasks = tasks;
    }

    global EsitiCollectorChiusuraAffidiBatch(List<Id> tasks,List<Id> prats)
    {
        this.tasks = tasks;
        this.prats = prats;
    }

    global Iterable<SObject> start(Database.BatchableContext param1) {

        String queryLocatorString = '';
        if(Utils.checkFLSPermission('Affidamento__c', 'Id').get('ACCESS') && Utils.checkFLSPermission('Affidamento__c', 'Codice_Pratica__c').get('ACCESS')  && Utils.checkFLSPermission('Affidamento__c', 'id_Task_associato__c').get('ACCESS'))
        {
            //queryLocatorString = 'SELECT Id, Codice_Pratica__c, id_Task_associato__c  FROM Affidamento__c WHERE id_Task_associato__c IN :tasks';
            queryLocatorString = 'SELECT Id, Codice_Pratica__c, id_Task_associato__c  FROM Affidamento__c WHERE Stato__c = \'In Corso\' AND Pratica__c IN :prats';
            System.debug(queryLocatorString);
            System.debug(tasks);
            System.debug(prats);
        }

        return Database.getQueryLocator(queryLocatorString);
    }

    global void execute(Database.BatchableContext param1, List<SObject> scope) {

        if (scope.size() > scopeSize){
            ErrorClass.logError('EsitiCollectorChiusuraAffidiBatch.execute.ScopeSize', 'Lo scope scelto è più grande di quello di controllo: ' + scopeSize);
        }

        List<Id> affidamentoiIds = new List<Id>();

        //System.debug('--> Batch scope: ' + scope);
        for(SObject sobj : scope)
        {
            affidamentoiIds.add(sobj.Id);
        }
        System.debug(affidamentoiIds);

        Integer resultCode = AffidamentiManager.revocaListAffidamentiScaduti(affidamentoiIds,'Esitazione Collector');
        //System.debug('--> Batch scope result: ' + resultCode);

        if(resultCode != 0) {
            ErrorClass.logError('EsitiCollectorChiusuraAffidiBatch.execute', 'Errore per lo scope:' + scope);
        }
    }

    global void finish(Database.BatchableContext param1) {
        // execute any post-processing operations
        BatchQueue.runBatches();
    }
}