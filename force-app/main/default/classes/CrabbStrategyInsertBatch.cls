/** 
 * Created by Alessandro on 17/03/2021.
 */

public with sharing class CrabbStrategyInsertBatch implements Database.Batchable<sObject>, Schedulable {

    public Map<id, Sobject> sobjectsToUpdate = new Map<id, Sobject>();
    public List<Sobject> sobjectsToInsert = new List<Sobject>();
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public Database.QueryLocator start(Database.BatchableContext BC) {

        SObjectType type = gd.get(Utils.NAMESPACE + 'Pratica__c');
        Map<String, Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        List<string> praticaFieldsList = new List<string>();
        praticaFieldsList.addAll(mfields.keySet());

        string query = 'Select ' + utils.joinStrings(praticaFieldsList, ',') + ',(select id,subject,ActivityExtended__c,status,WhatId,description from Tasks where status=\'Ricerca strategia\' and ActivityExtended__c!=null) FROM Pratica__c where Stato__c = \'Da Elaborare\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Pratica__c> scope) {

        //1 - relating dossiers 2 strategies
        ORK_execute(scope);

        //2 - generating events in ceb
        if (sobjectsToUpdate.size() > 0) {
            List<CRABB_DEV__Pratica__c> praList = new List<CRABB_DEV__Pratica__c>();

            for (String key : sobjectsToUpdate.keySet()) {
                if (sobjectsToUpdate.get(key) instanceof CRABB_DEV__Pratica__c && sobjectsToUpdate.get(key).get('CRABB_DEV__Strategia__c') != null) {
                    praList.add((CRABB_DEV__Pratica__c) sobjectsToUpdate.get(key));
                }
            }
            if (praList.size() > 0) {
                CEBUtils.addCebEvents(false, praList, 'SCH');
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new CrabbStrategyInsertBatch());
    }

    public void ORK_execute(List<Pratica__c> scope) {
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c> ();
        Map<string, Task> tMap = new Map<string, Task>();
        list<string> actExtIdList = new list<string>();
        List<Sobject> sobjectsToInsert = new List<Sobject>();
        List<Log__c> logL = new List<Log__c>();

        //1 - creating pmap, tmap, sobjectsToUpdate
        for (Pratica__c p : scope) {
            pMap.put(p.id, p);
            if (p.Tasks.size() > 0) {
                tMap.put(p.Tasks[0].id, p.Tasks[0]);
                sobjectsToUpdate.put(p.Tasks[0].id, p.Tasks[0]);
                if (p.Tasks[0].ActivityExtended__c != null) actExtIdList.add(p.Tasks[0].ActivityExtended__c);
            }
            sobjectsToUpdate.put(p.id, p);
        }

        //2 - retrieve strategies
        //OrkStatic.retrieveStrategie();
        OrkStatic.cebRetrieveStrategie(gd);

        //3 - execute first activities
        //OrkKernel.executeFirstActivities(tMap,pMap, sobjectsToUpdate , sobjectsToInsert,logL );
        OrkKernel.cebExecuteFirstActivities(gd, tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, null);

        /**20210617 MSIOTTO - New Engine step field update  START**/
        Map<String, SObject> objectForPraticaMap = CrabbEngineUtils.generateMapsFieldUpdate(scope, gd);
        /**20210617 MSIOTTO - New Engine step field update END**/

        //4 - get all activitiesextended
        //String query = 'SELECT ' + Utils.getSOBJECTFieldsForQuery('ActivityExtended__c') + ' FROM ActivityExtended__c WHERE Id in:actExtIdList';
        String query = 'SELECT ' + Utils.cebGetSOBJECTFieldsForQuery('ActivityExtended__c', gd) + ' FROM ActivityExtended__c WHERE Id in:actExtIdList';
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        //if (Utils.checkFLSPermission('ActivityExtended__c', 'id_affidamento__c').get('UPDATE') && Utils.checkFLSPermission('ActivityExtended__c', 'id_lotto_associato__c').get('UPDATE')) {
        if (Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_affidamento__c', gd).get('UPDATE') && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_lotto_associato__c', gd).get('UPDATE')) {
            aes = Database.query(query);
        }
        Map<Id, ActivityExtended__c> aesMap = new Map<Id, ActivityExtended__c>();
        for (ActivityExtended__c tmp : aes) {
            aesMap.put(tmp.Id, tmp);
        }

        //5 - creating task2obk map
        Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();
        for (String tmp : tMap.keySet()) {
            if(tMap.containsKey(tmp)) task2Obj.put(tmp, aesMap.get(tMap.get(tmp).ActivityExtended__c));
        }

        //6 - defining next job
        //OrkKernel.nextJob('Task_beforeUpdate', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, null, task2Obj);
        OrkKernel.cebSetNextJob(objectForPraticaMap, gd,'Task_beforeUpdate', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, null, task2Obj);

        //7 - dml ops
        if(sobjectsToInsert.size() > 0) {
            sobjectsToInsert = Utils.sortTaskActivities(sobjectsToInsert);
            insert sobjectsToInsert;
        }
        if (sobjectsToUpdate.keyset() != null && sobjectsToUpdate.keyset().size() > 0) {
            //update sobjectsToUpdate.Values();
            update Utils.sortTaskActivities(sobjectsToUpdate.Values());
        }

    }

}