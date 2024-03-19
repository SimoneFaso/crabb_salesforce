/**
 * Created by Alessandro on 30/03/2021.
 */

public with sharing class CEBdeletionBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    Date dPeriod;

    public CEBdeletionBatch(){
        List<grace_period__mdt>  Crabb_Event_Delete_Days = [SELECT CRABB_DEV__Days__c FROM CRABB_DEV__grace_period__mdt where DeveloperName='Crabb_Event_Delete'];
        this.dPeriod = Date.today().addDays(-Integer.valueOf(Crabb_Event_Delete_Days.get(0).Days__c));

    }

    public Database.QueryLocator start(Database.BatchableContext BC) {

        string query = 'select id,CRABB_DEV__Type__c,CRABB_DEV__Status__c from CEB__c where CRABB_DEV__Status__c = \'Done\' and lastModifiedDate < :dPeriod';
        return Database.getQueryLocator(query);

    }

    public void execute(Database.BatchableContext BC, List<CEB__c> scope) {
        delete scope;
    }

    public void finish(Database.BatchableContext BC){}

    //per scheduler
    public void execute(SchedulableContext sc){
        Database.executeBatch(new CEBdeletionBatch());
    }


}