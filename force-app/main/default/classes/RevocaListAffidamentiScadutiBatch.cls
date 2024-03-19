/**
 * Created by Francesco on 23/11/2018.
 */

global with sharing class RevocaListAffidamentiScadutiBatch implements Database.Batchable<SObject>, Database.Stateful{

    public List<Id> tasks {get; set;}

    global RevocaListAffidamentiScadutiBatch(List<Id> tasks){
        this.tasks = tasks;
    }

    global Iterable<SObject> start(Database.BatchableContext param1) {

        String queryLocatorString = '';
        if(Utils.checkFLSPermission('Affidamento__c', 'id_Task_associato__c').get('ACCESS'))
        {
            queryLocatorString='SELECT Id FROM Affidamento__c WHERE id_Task_associato__c IN :tasks';
        }

        return Database.getQueryLocator(queryLocatorString);
    }

    global void execute(Database.BatchableContext param1, List<SObject> scope) {

        System.debug('--> Batch scope: ' + scope);
    }

    global void finish(Database.BatchableContext param1) {

    }


}