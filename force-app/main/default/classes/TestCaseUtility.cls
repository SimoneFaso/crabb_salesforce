/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestCaseUtility.cls
Description:     Test Class for Code Coverage of CaseUtility.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
10-Jun-2020  0.1      Matteo Lecca                    First Version
29-Mar-2021  0.2      Giulia Mameli                   Substituted Pratica in taskMap with a concatenation of Pratica and
                                                      Task Subject.
----------------------------------------------------------------------------------------------------------------------*/

@IsTest
public with sharing class TestCaseUtility {

    @TestSetup
    public static void createDate() {
        /*Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        insert con;

        Account ac = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert ac;

        Pratica__c p = TestClassFroDataGenAffidamenti.getPratica(ac.Id);
        p.Stato__c = 'Da elaborare';
        insert p;*/
    }

    @IsTest
    public static void checkCreateCase() {
        List<Strategia__c> sList = new List<Strategia__c>();
        Set<Id> praticsIds = new Set<Id>();
        Map<String, String> taskMap = new Map<String, String>();
        Strategia__c testata = new Strategia__c();
        Strategia__c step = new Strategia__c();
        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        step = TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.Id, testata.Id);
        insert step;
        update testata;
        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(2);
        insert pList;
        //operazione per creare dei task
        for (Pratica__c p : pList) {
            praticsIds.add(p.Id);
            p.byPassRole__c = '' + System.now();
        }
        update pList;
        String taskFields = TestStatic.getTaskAllFieds();
        String query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = Database.query(query);
        Set<Id> aeIds = new Set<Id>();
        for (Task t : tList) {
            String dossierIDSubject = t.WhatId + '~' + t.Subject;
            taskMap.put(t.ActivityExtended__c, dossierIDSubject);
            aeIds.add(t.ActivityExtended__c);
        }
        List<ActivityExtended__c> aeList = [SELECT Id, Tipo__c, Sotto_Tipo__c FROM ActivityExtended__c WHERE Id IN :aeIds];
        for (ActivityExtended__c ae : aeList) {
            ae.Tipo__c = 'Proposta di Attività';
            ae.Sotto_Tipo__c = 'Prima raccomandata';
        }
        update aeList;
        /*Ork ok = new Ork();
        ork.areLogsActive=true;
        test.startTest();
        ok.execute('Token',tList,tList);
        test.stopTest();*/
        CaseUtility.createCaseFromStep(aeList, praticsIds, taskMap);
    }
}