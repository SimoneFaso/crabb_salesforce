global with sharing class CrabbScoringBatch implements Database.Batchable<sObject>, Database.Stateful {

    public class ScoringBatchException extends Exception{}

    global CrabbScoringBatch(){}

    global Database.QueryLocator start(Database.BatchableContext BC) {
        try{

            if (Utils.checkFLSPermission('Account', 'CRABB_DEV__considered_in_scoring__c').get('ACCESS')
                && !CEBUtils.newOrkVersionEnabled()) {
                return Database.getqueryLocator('SELECT id,CRABB_DEV__considered_in_scoring__c FROM Account where CRABB_DEV__considered_in_scoring__c = true');
            } else {  return null; }

        } catch(Exception e){  errorClass.LogError('CrabbScoringBatch.QueryLocator',e.getMessage()+ '\n'+e.getlinenumber()+'\n'+e.getStackTraceString()); throw new ScoringBatchException('Exception-'+e.getMessage()+ '\n'+e.getlinenumber()+'\n'+e.getStackTraceString()); }
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {

        List<String> idList = new List<String>();
        for(Account a: scope){
            idList.add(a.id);
        }
        //test method elaborateScoring
        CRABB_Scoring_ctrl.elaborateScoring(idList,'Account');

    }

    global void finish(Database.BatchableContext BC){}

}