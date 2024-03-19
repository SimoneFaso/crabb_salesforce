/**
 * Created by Alessandro on 25/03/2021.
 */

public with sharing class InitRecordsForCrabbEngineBatch implements Database.Batchable<sObject>, Schedulable {
    public static Integer crabbEngineScopeBatch = getBatchScopeSize();

    public Database.QueryLocator start(Database.BatchableContext BC) {
        string query = 'select id, pratica__c, Status__c,CRABB_DEV__Type__c, Wait_Due_Date__c, AE_Due_Date__c from CRABB_DEV__CEB__c where Status__c in (\'New\', \'Error\') and In_progress_Event__c = false';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<CRABB_DEV__CEB__c> scope) {

        for(CRABB_DEV__CEB__c ev: scope){
            ev.Status__c = 'In Progress';
        }

        update scope;

    }

    public void finish(Database.BatchableContext BC){
        Database.executeBatch(new CrabbEngine(), CrabbEngineScopeBatch);
    }

    //per scheduler
    public void execute(SchedulableContext sc){

        //we check in progress ceb because we can have only one process running
        List<CRABB_DEV__CEB__c> cebL = [select id,Status__c from CRABB_DEV__CEB__c where Status__c ='In Progress' ];
        if(cebL.size()==0){
            Database.executeBatch(new InitRecordsForCrabbEngineBatch());
        }

    }

    //To get the proper batch scopeSize for HandleMappingMigrationBatch from the related BatchProcess__c custom metadata
    public static Integer getBatchScopeSize(){
        CRABB_DEV__BatchProcess__c batchProcess = CRABB_DEV__BatchProcess__c.getValues('CrabbEngineScopeBatch');
        Integer scopeSize = batchProcess != null ? Integer.valueOf(batchProcess.CRABB_DEV__ScopeSize__c) : 25;

        return scopeSize;

    }

}