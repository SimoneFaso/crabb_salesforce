/**
 * Created by Alessandro on 29/03/2021.
 */ 
public with sharing class CEBupdateStatusBatch implements Database.Batchable<sObject>, Database.Stateful {

    public Map<string,string> statusMap;

    public CEBupdateStatusBatch(Map<string,string> statusMap){
        this.statusMap = statusMap;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        Set<String> ProcessedEvtIdList = (Set<String>) statusMap.keySet();
        //string query = 'select id,CRABB_DEV__Type__c,CRABB_DEV__Status__c, CRABB_DEV__Pratica__c, CRABB_DEV__Pratica__r.CRABB_DEV__Stato__c from CEB__c where id in:ProcessedEvtIdList';
        string query = 'select id,CRABB_DEV__Type__c,CRABB_DEV__Status__c, CRABB_DEV__Pratica__c, CRABB_DEV__Pratica__r.CRABB_DEV__Stato__c from CEB__c where id in:ProcessedEvtIdList';

        return Database.getQueryLocator(query);

    }

    public void execute(Database.BatchableContext BC, List<CEB__c> scope) {
        for(CEB__c c : scope){
            /*if(c.Type__c.equals('SCH')){
                c.Status__c = 'New';
            }else{
                c.Status__c = 'Done';
            }*/
            if(c.CRABB_DEV__Status__c!='Blocked') {
                if(c.CRABB_DEV__Type__c=='SCH' && c.CRABB_DEV__Pratica__r.CRABB_DEV__Stato__c == 'Chiusa') {
                    c.CRABB_DEV__Status__c = 'Done';
                } else {
                    c.CRABB_DEV__Status__c = this.statusMap.get(c.id);
                }
            }
        }

        update scope;
    }

    public void finish(Database.BatchableContext BC){
        Set<String> alreadyProcessedEvtIdList = (Set<String>) statusMap.keySet();
        List<CEB__c> cebNotWorked = [SELECT id, status__c from CEB__c where Status__c = 'In Progress' and id not in :alreadyProcessedEvtIdList];
        for(CEB__c ceb : cebNotWorked) {
            ceb.Status__c = 'New';
        }
        update cebNotWorked;
        System.debug('QUERY LIMIT CRABB ENGINE END ----> ' + Limits.getQueries());
    }

}