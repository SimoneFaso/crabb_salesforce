/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestTaskHandler.cls
Description:     Test Class for code coverage of TaskHandler.cls


Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
06-Apr-2021  0.1      Giulia Mameli                   First Version (not covered CostoAttivita method, because not used)
----------------------------------------------------------------------------------------------------------------------*/

@IsTest
public class TestTaskHandler {

    @IsTest static void TestTaskHandler() {

        User collUser = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');
        List<ActivityExtended__c> actExtsList = new List<ActivityExtended__c>();
        List<Task> tasksList = new List<Task>();

        //Create Dossier
        Pratica__c prtc = new Pratica__c();
        prtc.Nome_Collector_Attivo__c = 'XXX';
        prtc.Data_Attivit_in_Lavorazione__c = System.today();
        insert prtc;

        //Create Collector
        Collector__c coll = new Collector__c();
        coll = TestClassFroDataGenAffidamenti.getCollector(collUser.Id);
        insert coll;

        //Create Lotto
        Lotto__c lotto = new Lotto__c();
        lotto.Agenzia_di_Recupero__c = coll.Id;
        insert lotto;

        //Create Affidamento
        Affidamento__c aff = new Affidamento__c();
        aff.Pratica__c = prtc.Id;
        aff.Lotto__c = lotto.Id;
        insert aff;

        //Create Activity Extended
        CRABB_DEV__ActivityExtended__c actExt = new CRABB_DEV__ActivityExtended__c();
        actExt.CRABB_DEV__Tipo__c ='Proposta di Attività';
        actExt.CRABB_DEV__Sotto_Tipo__c ='Seconda Raccomandata';
        actExt.Data_chiusura__c = System.today().addDays(5);
        actExt.id_affidamento__c = aff.Id;
        actExt.E_da_affidare__c = true;
        actExtsList.add(actExt);

        //Create Activity Extended 2
        CRABB_DEV__ActivityExtended__c actExt2 = new CRABB_DEV__ActivityExtended__c();
        actExt2.CRABB_DEV__Tipo__c ='Proposta di Attività';
        actExt2.CRABB_DEV__Sotto_Tipo__c ='Prima Raccomandata';
        actExt2.Data_chiusura__c = System.today().addDays(5);
        actExt2.Creata_Manualmente__c = 'true';
        actExtsList.add(actExt2);
        insert actExtsList;

        //Create Credito Task
        Task tsk = new Task();
        tsk.Description = 'Test';
        tsk.Type = 'Credito';
        tsk.Status = 'Non Iniziata';
        tsk.Subject = 'Proposta di Attività Seconda Raccomandata';
        tsk.CRABB_DEV__ActivityExtended__c = actExt.Id;
        tsk.WhatId = prtc.Id;
        tasksList.add(tsk);

        //Create Credito Task 2
        Task tsk2 = new Task();
        tsk2.Description = 'Test';
        tsk2.Type = 'Credito';
        tsk2.Status = 'Completata';
        tsk2.Subject = 'Proposta di Attività Prima Raccomandata';
        tsk2.CRABB_DEV__ActivityExtended__c = actExt2.Id;
        tsk2.WhatId = prtc.Id;
        tasksList.add(tsk2);
        insert tasksList;

        //Create Costo Attività
        CostoAttivita__c costAtt = new CostoAttivita__c();
        costAtt.Name = 'Proposta Prima Raccomandata';
        costAtt.Costo__c = 1;
        costAtt.Tipo_Sottotipo__c = 'Proposta di Attività Prima Raccomandata';
        costAtt.Collector__c = 'Test Collector';
        insert costAtt;

        //Test TaskHandler
        TaskHandler taskHandler = new TaskHandler();
        taskHandler.beforeInsert(tasksList);
        taskHandler.afterInsert(tasksList);
        taskHandler.beforeUpdate(tasksList, tasksList);
        taskHandler.afterUpdate(tasksList, tasksList);

    }
}