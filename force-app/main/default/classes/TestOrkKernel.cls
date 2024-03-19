/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestOrkActivities.cls
Description:     Test Class for code coverage of OrkKernel.cls


Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
06-Aug-2014  0.1      Klodjan Meta                    First Version
11-May-2021  0.2      Giulia Mameli                   Added TaskIds - ActsExt Map as input parameter for
                                                      OrkKernel.executeFirstActivities() and OrkKernel.forceOperation()
13-May-2021  0.3      M.Siotto & G.Mameli             Reviewed for using ceb methods
05-Oct-2021  0.4      C.Sanna, G.Mameli,              Modified for coverage and using ceb method, removed old test methods
                      M. Pizzichini                   for executeExit, nextJob, executeLoop and executeJump methods,
                                                      replaced testMethod with @isTest.
----------------------------------------------------------------------------------------------------------------------*/

@IsTest
public class TestOrkKernel {//Ork Funzioni Kernel dell'orchestratore
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    @TestSetup
    public static void generateStrategyRecords() {
        Map<string, Schema.RecordTypeInfo> RTStrategiaNameID =Schema.SObjectType.Strategia__c.getrecordtypeinfosbydevelopername();
        List<Strategia__c> strategyList = new List<Strategia__c>();

        Strategia__c testata = new Strategia__c();
        testata.nome__c='Strategy test';
        testata.priority__c=1;
        testata.stato__c='Attiva';
        testata.Versione__c=1;
        testata.recordtypeId=RTStrategiaNameID.get('Testata').getRecordTypeID();
        testata.Tipo_Strategia__c='Standard';
        testata.Activation_roles__c='R2015-03-04 11:35:16,R2021-03-03 14:52:18,R7,R2014-07-11 10:29:40';
        //strategyList.add(testata);
        insert testata;


        Strategia__c condIngresso = new Strategia__c();
        condIngresso.CRABB_DEV__Testata__c=testata.id;
        condIngresso.nome__c='Ingresso strategia test';
        condIngresso.priority__c=1;
        condIngresso.stato__c='Attiva';
        condIngresso.recordtypeId=RTStrategiaNameID.get('Condizioni_di_Ingresso').getRecordTypeID();
        condIngresso.RC_Rule_Name__c='R2021-03-03 14:52:18';
        strategyList.add(condIngresso);

        //Step Stand-By
        Strategia__c stepSB = new Strategia__c();
        stepSB.CRABB_DEV__Testata__c=testata.id;
        stepSB.CRABB_DEV__Attivit_Padre__c=testata.id;
        stepSB.CRABB_DEV__Tipo_attivita__c='Attività di Attesa';
        stepSB.nome__c='1 - Stand by';
        stepSB.Tipologia__c = 'Expectance';
        stepSB.priority__c=0;
        stepSB.stato__c='Attiva';
        stepSB.recordtypeId=RTStrategiaNameID.get('Step').getRecordTypeID();
        insert stepSB;

        //Step Crea Case
        Strategia__c stepCreaCase = new Strategia__c();
        stepCreaCase.CRABB_DEV__Testata__c=testata.id;
        stepCreaCase.CRABB_DEV__Attivit_Padre__c=stepSB.id;
        stepCreaCase.CRABB_DEV__Tipo_attivita__c='Invio SMS';
        stepCreaCase.sotto_tipo_attivita__c='Seconda Raccomandata';
        stepCreaCase.nome__c='Crea Case';
        stepCreaCase.Tipologia__c = 'UI';
        stepCreaCase.priority__c=1;
        stepCreaCase.stato__c='Attiva';
        stepCreaCase.recordtypeId=RTStrategiaNameID.get('Step').getRecordTypeID();
        strategyList.add(stepCreaCase);

        //Step Crea PDF
        Strategia__c stepCreaPDF = new Strategia__c();
        stepCreaPDF.CRABB_DEV__Testata__c=testata.id;
        stepCreaPDF.CRABB_DEV__Attivit_Padre__c=stepSB.id;
        stepCreaPDF.CRABB_DEV__Tipo_attivita__c='Proposta di Attività';
        stepCreaPDF.sotto_tipo_attivita__c='Lettera ordinaria';
        stepCreaPDF.nome__c='CREA PDF';
        stepCreaPDF.Tipologia__c = 'UI';
        stepCreaPDF.priority__c=2;
        stepCreaPDF.stato__c='Attiva';
        stepCreaPDF.recordtypeId=RTStrategiaNameID.get('Step').getRecordTypeID();
        strategyList.add(stepCreaPDF);

        insert strategyList;
        update testata;
    }

    @IsTest static void OrkKernel_instance() {
        test.startTest();
        OrkKernel ok = new OrkKernel();
        test.stopTest();
    }
    @IsTest static void OrkKernel_generatePraticheForupdateUseOnly_noPratiche() {
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>();
        Map<id, Sobject> sobjectsToUpdate = new Map<id, Sobject>();
        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(10);
        insert pList;
        boolean bool;

        test.startTest();
        bool = OrkKernel.generatePraticheForupdateUseOnly(pMap, sobjectsToUpdate);
        test.stopTest();
        System.assertEquals(true, bool);
    }
    @IsTest static void OrkKernel_generatePraticheForupdateUseOnly_withPratiche() {
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>();
        Map<id, Sobject> sobjectsToUpdate = new Map<id, Sobject>();
        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(10);
        insert pList;
        boolean bool;

        test.startTest();
        bool = OrkKernel.generatePraticheForupdateUseOnly(pMap, sobjectsToUpdate);
        test.stopTest();
        System.assertEquals(true, bool);
    }

    @IsTest static void OrkKernel_shieldLevelZero() {
        Map<string, task> tMap = new Map<string, task>();
        //Creazione delle pratiche
        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(5);
        insert pList;

        //operazione per creare dei task
        for (pratica__c p : pList)
            p.bypassRole__c = '' + system.now();
        update pList;

        //recupero i task
        string taskFields = TestStatic.getTaskAllFieds();
        string query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = database.query(query);
        Map<Id, ActivityExtended__c> aes2Obj = Utils.getTaskWithActivityExtended(tList);
        Map<Id, ActivityExtended__c> aes2Obj2 = Utils.cebGetTaskWithActivityExtended(tList, gd);
        ActivityExtended__c ae0 = aes2Obj.get(tList[0].id);
        ActivityExtended__c ae3 = aes2Obj.get(tList[3].id);
        ActivityExtended__c ae4 = aes2Obj.get(tList[4].id);
        ae0.recordTypeid = TestStatic.getTaskRTId('Standard');
        tList[1].status = 'Error';
        tList[2].status = 'Completato';
        ae3.recordTypeid = TestStatic.getTaskRTId('UI');
        tList[3].status = 'Lavorato';
        ae4.recordTypeid = TestStatic.getTaskRTId('Process');
        tList[4].status = 'Non iniziato';

        update tList;

        Boolean bool;
        Boolean bool2;

        test.startTest();
        /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
        //bool = OrkKernel.shieldLevelZero(tMap, tList, aes2Obj);
        /*** 20210513 MSiotto - Code Review - End Rimosso per nuova gestione CEB  ***/
        bool2 = OrkKernel.cebShieldLevelZero(tMap, tList, aes2Obj2, gd);
        test.stopTest();
        System.assertEquals(true, bool2);
    }

    @IsTest static void OrkKernel_shieldPostLoadConfiguration_TaskSenzaPratica() {
        //Creazione delle pratiche
        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(1);
        insert pList;
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>(pList);

        //operazione per creare dei task
        for (pratica__c p : pList)
            p.bypassRole__c = '' + system.now();
        update pList;

        //recupero i task
        string taskFields = TestStatic.getTaskAllFieds();
        string query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = database.query(query);
        Map<Id, ActivityExtended__c> aes2Obj = Utils.getTaskWithActivityExtended(tList);
        Map<Id, ActivityExtended__c> aes2Obj2 = Utils.cebGetTaskWithActivityExtended(tList, gd);
        tList[0].recordTypeid = TestStatic.getTaskRTId('Process');
        tList[0].status = 'Non iniziato';
        tList[0].WhatId = null;
        Map<string, task> tMap = new Map<string, task>(tList);
        Map<string, task> tMap2 = new Map<string, task>(tList);

        Test.startTest();
        /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
        //tMap = OrkKernel.shieldPostLoadConfiguration(tMap, pMap, aes2Obj);
        /*** 20210513 MSiotto - Code Review - End Rimosso per nuova gestione CEB ***/
        tMap2 = OrkKernel.cebshieldPostLoadConfiguration(tMap, pMap, aes2Obj2, gd);
        Test.stopTest();
        //System.assertEquals(true,tMap != null);
        //System.assertEquals(true,tMap2 != null);
    }

    @IsTest static void OrkKernel_shieldPostLoadConfiguration_BloccataManualmente() {
        Tag__c tag = new Tag__c();
        tag.ValueText__c = 'Bloccata Manualmente';
        tag.Name = 'ValoreStatoPraticaPerBloccoManuale';
        insert tag;

        //Creazione delle pratiche
        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(1);
        pList[0].Stato__c = 'Bloccata Manualmente';
        insert pList;
        Map<String, Pratica__c> pMap = new Map<String, Pratica__c>(pList);

        //operazione per creare dei task
        for (Pratica__c p : pList) {
            p.bypassRole__c = '' + System.now();
        }

        update pList;

        //recupero i task
        String taskFields = TestStatic.getTaskAllFieds();
        String query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = Database.query(query);
        Map<Id, ActivityExtended__c> aes2Obj = Utils.getTaskWithActivityExtended(tList);
        Map<Id, ActivityExtended__c> aes2Obj2 = Utils.cebGetTaskWithActivityExtended(tList, gd);
        tList[0].RecordTypeId = TestStatic.getTaskRTId('Process');
        tList[0].Status = 'Non iniziato';
        ActivityExtended__c ae = aes2Obj2.get(tList[0].Id);
        ae.E_da_affidare__c = false;
        update ae;

        Map<String, Task> tMap = new Map<String, Task>(tList);
        Map<String, Task> tMap2 = new Map<String, Task>(tList);

        test.startTest();
        /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
        //tMap = OrkKernel.shieldPostLoadConfiguration(tMap, pMap, aes2Obj);
        /*** 20210513 MSiotto - Code Review - End Rimosso per nuova gestione CEB ***/
        tMap2 = OrkKernel.cebshieldPostLoadConfiguration(tMap, pMap, aes2Obj2, gd);
        test.stopTest();
        //System.assertEquals(true,bool);
    }

    @IsTest static void OrkKernel_shieldPostLoadConfiguration_Bloccata() {
        Tag__c tag = new Tag__c();
        tag.ValueText__c = 'Bloccata';
        tag.Name = 'StatoPraticaBloccoPDR';
        insert tag;

        //Creazione delle pratiche
        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(1);
        pList[0].Stato__c = 'Bloccata';
        insert pList;
        Map<String, Pratica__c> pMap = new Map<String, Pratica__c>(pList);

        //operazione per creare dei task
        for (Pratica__c p : pList) {
            p.bypassRole__c = '' + System.now();
        }

        update pList;

        //recupero i task
        String taskFields = TestStatic.getTaskAllFieds();
        String query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = Database.query(query);
        Map<Id, ActivityExtended__c> aes2Obj = Utils.getTaskWithActivityExtended(tList);
        Map<Id, ActivityExtended__c> aes2Obj2 = Utils.cebGetTaskWithActivityExtended(tList, gd);
        tList[0].RecordTypeId = TestStatic.getTaskRTId('Process');
        tList[0].Status = 'Non iniziato';
        ActivityExtended__c ae = aes2Obj2.get(tList[0].Id);
        ae.E_da_affidare__c = false;
        update ae;

        Map<String, Task> tMap = new Map<String, Task>(tList);
        Map<String, Task> tMap2 = new Map<String, Task>(tList);

        test.startTest();
        /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
        //tMap = OrkKernel.shieldPostLoadConfiguration(tMap, pMap, aes2Obj);
        /*** 20210513 MSiotto - Code Review - End Rimosso per nuova gestione CEB ***/
        tMap2 = OrkKernel.cebshieldPostLoadConfiguration(tMap, pMap, aes2Obj2, gd);
        test.stopTest();
        //System.assertEquals(true,bool);
    }
    @IsTest static void OrkKernel_shieldPostLoadConfiguration_chiusa() {
        //Creazione delle pratiche
        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(1);
        pList[0].stato__c = 'Chiusa';
        insert pList;
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>(pList);

        //operazione per creare dei task
        for (pratica__c p : pList)
            p.bypassRole__c = '' + system.now();
        update pList;

        //recupero i task
        string taskFields = TestStatic.getTaskAllFieds();
        string query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = database.query(query);
        Map<Id, ActivityExtended__c> aes2Obj = Utils.getTaskWithActivityExtended(tList);
        Map<Id, ActivityExtended__c> aes2Obj2 = Utils.cebGetTaskWithActivityExtended(tList, gd);
        tList[0].recordTypeid = TestStatic.getTaskRTId('Process');
        tList[0].status = 'Non iniziato';
        Map<string, task> tMap = new Map<string, task>(tList);
        Map<string, task> tMap2 = new Map<string, task>(tList);

        test.startTest();
        /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
        //tMap = OrkKernel.shieldPostLoadConfiguration(tMap, pMap, aes2Obj);
        /*** 20210513 MSiotto - Code Review - End Rimosso per nuova gestione CEB ***/
        tMap2 = OrkKernel.cebshieldPostLoadConfiguration(tMap, pMap, aes2Obj2, gd);
        test.stopTest();
        //System.assertEquals(true,bool);
    }
    @IsTest static void OrkKernel_shieldPostLoadConfiguration_strNoATTIVA() {
        //Creazione delle pratiche
        List<Strategia__c> sList = new List<Strategia__c>();
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaTestata());
        sList[0].stato__c = 'Attiva';
        insert sList;

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(1);
        pList[0].stato__c = 'Bozza';
        insert pList;
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>(pList);

        //operazione per creare dei task
        for (pratica__c p : pList)
            p.bypassRole__c = '' + system.now();
        update pList;

        //recupero i task
        string taskFields = TestStatic.getTaskAllFieds();
        string query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = database.query(query);
        //Map<Id, ActivityExtended__c> aes2Obj = Utils.getTaskWithActivityExtended(tList);
        Map<Id, ActivityExtended__c> aes2Obj2 = Utils.cebGetTaskWithActivityExtended(tList, gd);
        ActivityExtended__c ae = new ActivityExtended__c();
        ae.recordTypeid = TestStatic.getTaskRTId('Process');
        ae.id = tList[0].ActivityExtended__c;
        System.Debug('sList[0].id -->' +sList[0].id);
        ae.id_strategia__c = sList[0].id;
        tList[0].status = 'Non iniziata';
        update ae;
        update tList[0];

        tList = Database.query(query);
        Map<string, task> tMap = new Map<string, task>(tList);
        Map<string, task> tMap2 = new Map<string, task>(tList);
        OrkStatic.strategies = new Map<id, Strategia__c>();

        sList[0].Stato__c = 'Bozza';
        update sList[0];

        test.startTest();
        /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
        //tMap = OrkKernel.shieldPostLoadConfiguration(tMap, pMap, aes2Obj);
        /*** 20210513 MSiotto - Code Review - End Rimosso per nuova gestione CEB ***/
        tMap = OrkKernel.cebshieldPostLoadConfiguration(tMap, pMap, aes2Obj2, gd);

        test.stopTest();
        //System.assertEquals(true,bool);
    }
    @IsTest static void OrkKernel_shieldPostLoadConfiguration_strNoStep() {
        //Creazione delle pratiche
        Strategia__c testata = new Strategia__c();
        Strategia__c step = new Strategia__c();
        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        step = TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id, testata.id);
        insert step;
        update testata;

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(1);
        pList[0].stato__c = 'Bozza';
        insert pList;
        //operazione per creare dei task
        for (pratica__c p : pList)
            p.bypassRole__c = '' + system.now();
        update pList;
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>(pList);

        //recupero i taska
        string taskFields = TestStatic.getTaskAllFieds();
        string query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = database.query(query);
        //Map<Id, ActivityExtended__c> aes2Obj = Utils.getTaskWithActivityExtended(tList);
        Map<Id, ActivityExtended__c> aes2Obj2 = Utils.cebGetTaskWithActivityExtended(tList, gd);
        ActivityExtended__c ae = aes2Obj2.get(tList[0].id);
        ae.recordTypeid = TestStatic.getTaskRTId('Process');
        tList[0].status = 'Non iniziato';
        ae.id_attivita__c = step.id;
        Map<string, task> tMap = new Map<string, task>(tList);
        Map<string, task> tMap2 = new Map<string, task>(tList);
        System.assertEquals(tList[0].whatid, pList[0].id);
        OrkStatic.strategies = new Map<id, Strategia__c>();

        test.startTest();
        /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
        //tMap = OrkKernel.shieldPostLoadConfiguration(tMap, pMap, aes2Obj);
        /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
        tMap2 = OrkKernel.cebshieldPostLoadConfiguration(tMap, pMap, aes2Obj2, gd);
        test.stopTest();
        //System.assertEquals(true,bool);
    }

    @IsTest
    static void OrkKernel_setDispatcher() {
        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(10);
        insert pList;
        Map<String, Pratica__c> pMap = new Map<String, Pratica__c>(pList);

        Strategia__c testata = new Strategia__c();
        Strategia__c step = new Strategia__c();
        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        step = TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id, testata.id);
        insert step;
        update testata;

        OrkStatic.cebRetrieveStrategie(gd);

        //Operazione per creare dei tasks
        for (Pratica__c p : pList)
            p.byPassRole__c = '' + System.now();
        update pList;

        //Recupero i tasks
        String taskFields = TestStatic.getTaskAllFieds();
        String query = 'Select ' + taskFields + ',ActivityExtended__r.isFirst__c,ActivityExtended__r.isForcedOperation__c From Task ';
        List<Task> tList = Database.query(query);
        System.debug('tList size --> '+tList.size());
        //Map<Id, ActivityExtended__c> aes2Obj = Utils.getTaskWithActivityExtended(tList);
        Map<Id, ActivityExtended__c> aes2Obj = Utils.cebGetTaskWithActivityExtended(tList, gd);

        List<ActivityExtended__c> actExtsList = new List<ActivityExtended__c>();
        ActivityExtended__c ae0 = aes2Obj.get(tList[0].Id);
        ActivityExtended__c ae1 = aes2Obj.get(tList[1].Id);
        ActivityExtended__c ae2 = aes2Obj.get(tList[2].Id);
        ActivityExtended__c ae3 = aes2Obj.get(tList[3].Id);
        ActivityExtended__c ae4 = aes2Obj.get(tList[4].Id);
        ActivityExtended__c ae5 = aes2Obj.get(tList[5].Id);

        ae0.isForcedOperation__c = true;
        ae0.Go_to_task_of_strategie__c = step.Id;
        actExtsList.add(ae0);


        ae1.isFirst__c = true;
        ae1.RecordTypeId = TestStatic.getTaskRTId('Process');
        ae1.Go_to_task_of_strategie__c = step.Id;
        actExtsList.add(ae1);

        ae2.isFirst__c = false;
        ae2.RecordTypeId = TestStatic.getTaskRTId('Process');
        ae2.Go_to_task_of_strategie__c = step.Id;
        actExtsList.add(ae2);

        ae3.isFirst__c = false;
        ae3.RecordTypeId = TestStatic.getTaskRTId('UI');
        ae3.Go_to_task_of_strategie__c = step.Id;
        actExtsList.add(ae3);

        ae4.isFirst__c = false;
        ae4.RecordTypeId = TestStatic.getTaskRTId('Expectance');
        ae4.Go_to_task_of_strategie__c = step.Id;
        actExtsList.add(ae4);

        ae5.isFirst__c = false;
        ae5.RecordTypeId = TestStatic.getTaskRTId('Standard');
        ae5.Go_to_task_of_strategie__c = step.Id;
        actExtsList.add(ae5);

        update actExtsList;
        update tList;

        tList = Database.query(query);

        Map<string, task> tMap = new Map<string, task>(tList);
        Map<string, Map<string, Task>> dispatcherMap = new Map<string, Map<string, Task>>();
        Map<string, Map<string, ActivityExtended__c>> dispatcherExMap = new Map<string, Map<string, ActivityExtended__c>>();
        boolean bool;
        boolean bool2;

        test.startTest();
        /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
        //bool = OrkKernel.setDispatcher(tMap, dispatcherMap, dispatcherExMap);
        /*** 20210513 MSiotto - Code Review - End Rimosso per nuova gestione CEB ***/
        bool2 = OrkKernel.cebSetDispatcher(tMap, dispatcherMap, dispatcherExMap, gd);
        test.stopTest();
        //System.assertEquals(true, bool);
        System.assertEquals(true, bool2);
    }

    @IsTest static void OrkKernel_forceOperation() {
        List<Strategia__c> sList = new List<Strategia__c>();
        Strategia__c testata = new Strategia__c();
        Strategia__c step = new Strategia__c();
        Strategia__c testata2 = new Strategia__c();
        Strategia__c step2 = new Strategia__c();
        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        testata2 = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert(new Strategia__c[]{testata,testata2});
        step = TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id, testata.id);
        step2 = TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata2.id, testata2.id);
        insert(new Strategia__c[]{step,step2});
        update testata;
        update testata2;

        OrkStatic.retrievestrategie();
        OrkStatic.cebRetrievestrategie(gd);

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(2);
        insert pList;
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>(pList);

        //operazione per creare dei task
        for (pratica__c p : pList)
            p.bypassRole__c = '' + system.now();
        update pList;

        //recupero i taska
        string taskFields = TestStatic.getTaskAllFieds();
        string query = 'Select ' + taskFields + ',ActivityExtended__r.Attivita_precedente_Esito__c,ActivityExtended__r.Account_id__c, ActivityExtended__r.Account_name__c,ActivityExtended__r.Servizio_id__c,ActivityExtended__r.Servizio_name__c,ActivityExtended__r.Comune_del_contratto__c,ActivityExtended__r.E_da_affidare__c,ActivityExtended__r.Owner_contratto__c,ActivityExtended__r.id_affidamento__c,ActivityExtended__r.id_lotto_associato__c,ActivityExtended__r.Document_code__c,ActivityExtended__r.Scaduto_iniziale__c,ActivityExtended__r.Attivita_precedente_name__c,ActivityExtended__r.Attivita_precedente__c,ActivityExtended__r.id_attivita__c,ActivityExtended__r.SLA__c,ActivityExtended__r.Expiration_date__c,ActivityExtended__r.Fase__c,ActivityExtended__r.Tipo__c,ActivityExtended__r.Sotto_Tipo__c,ActivityExtended__r.code_status__c, ActivityExtended__r.isFirst__c,ActivityExtended__r.Id_Strategia__c,ActivityExtended__r.record_type__c,ActivityExtended__r.Go_to_task_of_strategie__c From Task ';
        List<Task> tList = database.query(query);
        Map<Id, ActivityExtended__c> aes2Obj = Utils.getTaskWithActivityExtended(tList);
        Map<Id, ActivityExtended__c> aes2Obj2 = Utils.cebGetTaskWithActivityExtended(tList, gd);
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        List<ActivityExtended__c> aes2 = new List<ActivityExtended__c>();
        for (Task t : tList) {
            ActivityExtended__c ae = aes2Obj.get(t.Id);
            ae.Go_to_task_of_strategie__c = step.id;
            aes.add(ae);
        }
        update aes;

        for (Task t : tList) {
            ActivityExtended__c ae2 = aes2Obj2.get(t.Id);
            ae2.Go_to_task_of_strategie__c = step2.id;
            aes2.add(ae2);
        }
        update aes2;

        tList = database.query(query);
        Map<string, task> tMap = new Map<string, task>(tList);
        List<Sobject> sobjectsToInsert = new List<Sobject>();
        //throw new Utils.BalanceException('aes:'+aes2Obj.values());
        boolean bool;
        boolean bool2;
        test.startTest();
        //throw new Utils.BalanceException('tMap:'+tList[0].ActivityExtended__r.Go_to_task_of_strategie__c);
        /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
        //bool = OrkKernel.forceOperation(tMap, pMap, sobjectsToInsert, aes2Obj);
        /*** 20210513 MSiotto - Code Review - End Rimosso per nuova gestione CEB ***/
        bool2 = OrkKernel.cebForceOperation(tMap, pMap, sobjectsToInsert, aes2Obj2, gd);
        test.stopTest();
    }

    /*
    * Classi di test per il metodo executeFirstActivities, che verifica ed esegue le logiche per 
    * entrare in strategia. I test coinvolti sono:
    * - Tentativo di entrata in strategia, in una situazione dove non sono presenti le CDI
        è uno scenario di errore
    * - 
    */
    @IsTest
    static void OrkKernel_executeFirstActivities_noCDI() {
        Map<string, Task> tMap = new Map<string, Task>();
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>();
        Map<id, Sobject> sobjectsToUpdate = new Map<id, Sobject>();
        List<Sobject> sobjectsToInsert = new List<Sobject>();
        List<Log__c> logL = new List<Log__c>();

        List<Strategia__c> sList = new List<Strategia__c>();
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaTestata());
        insert sList;

        OrkStatic.retrievestrategie();
        OrkStatic.cebRetrievestrategie(gd);

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(2);
        insert pList;
        pMap = new Map<string, Pratica__c>(pList);

        //operazione per creare dei task e popolare soBjtoUpdate
        for (pratica__c p : pList) {
            p.bypassRole__c = '' + System.now();
            sobjectsToUpdate.put(p.id, p);
        }
        update pList;

        //recupero i tasks
        string taskFields = TestStatic.getTaskAllFieds();
        string query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = database.query(query);
        tMap = new Map<string, task>(tList);
        Map<Id,ActivityExtended__c> taskId2ActExt = Utils.getTaskWithActivityExtended(tList);
        Map<Id,ActivityExtended__c> taskId2ActExt2 = Utils.cebGetTaskWithActivityExtended(tList, gd);

        Boolean bool;
        Boolean bool2;
        Test.startTest();
        OrkKernel.executeFirstActivities(tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, taskId2ActExt);
        OrkKernel.cebExecuteFirstActivities(gd, tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, taskId2ActExt2);
        Test.stopTest();
    }

    @IsTest
    static void OrkKernel_executeFirstActivities_withCDI() {
        Map<string, Task> tMap = new Map<string, Task>();
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>();
        Map<id, Sobject> sobjectsToUpdate = new Map<id, Sobject>();
        List<Sobject> sobjectsToInsert = new List<Sobject>();
        List<Log__c> logL = new List<Log__c>();

        List<Strategia__c> sList = new List<Strategia__c>();
        Strategia__c testata = new Strategia__c();
        Strategia__c cdi = new Strategia__c();
        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        cdi = TestClassForDatagenerationCreateData.getTestStrategiaCDI(testata.id);
        cdi.Activation_roles__c = null;
        insert cdi;
        update testata;

        OrkStatic.retrievestrategie();
        OrkStatic.cebRetrievestrategie(gd);

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(2);
        insert pList;
        pMap = new Map<string, Pratica__c>(pList);

        //operazione per creare dei task e popolare soBjtoUpdate
        for (pratica__c p : pList) {
            p.bypassRole__c = '' + system.now();
            sobjectsToUpdate.put(p.id, p);
        }
        update pList;

        //recupero i tasks
        String taskFields = TestStatic.getTaskAllFieds();
        String query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = Database.query(query);
        tMap = new Map<String, Task>(tList);
        Map<Id,ActivityExtended__c> taskId2ActExt = Utils.getTaskWithActivityExtended(tList);
        Map<Id,ActivityExtended__c> taskId2ActExt2 = Utils.cebGetTaskWithActivityExtended(tList, gd);

        Test.startTest();
        OrkKernel.executeFirstActivities(tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, taskId2ActExt);
        OrkKernel.cebExecuteFirstActivities(gd, tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, taskId2ActExt2);
        Test.stopTest();
    }

    @IsTest
    static void OrkKernel_executeFirstActivities_withCDI_ResultNull() {
        Map<string, Task> tMap = new Map<string, Task>();
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>();
        Map<id, Sobject> sobjectsToUpdate = new Map<id, Sobject>();
        List<Sobject> sobjectsToInsert = new List<Sobject>();
        List<Log__c> logL = new List<Log__c>();

        List<Strategia__c> sList = new List<Strategia__c>();
        Strategia__c testata = new Strategia__c();
        Strategia__c cdi = new Strategia__c();
        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        cdi = TestClassForDatagenerationCreateData.getTestStrategiaCDI(testata.id);
        cdi.Activation_roles__c = 'hdjklafhlì';
        insert cdi;
        update testata;

        OrkStatic.retrievestrategie();
        OrkStatic.cebRetrievestrategie(gd);

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(2);
        insert pList;
        pMap = new Map<string, Pratica__c>(pList);

        //operazione per creare dei task e popolare soBjtoUpdate
        for (pratica__c p : pList) {
            p.bypassRole__c = '' + system.now();
            sobjectsToUpdate.put(p.id, p);
        }
        update pList;

        //recupero i taska
        String taskFields = TestStatic.getTaskAllFieds();
        String query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = Database.query(query);
        tMap = new Map<String, Task>(tList);
        Map<Id,ActivityExtended__c> taskId2ActExt = Utils.getTaskWithActivityExtended(tList);
        Map<Id,ActivityExtended__c> taskId2ActExt2 = Utils.cebgetTaskWithActivityExtended(tList, gd);

        Test.startTest();
        OrkKernel.executeFirstActivities(tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, taskId2ActExt);
        OrkKernel.cebExecuteFirstActivities(gd, tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, taskId2ActExt2);
        Test.stopTest();
    }

    @IsTest
    static void OrkKernel_executeFirstActivities_Exception() {
        Map<string, Task> tMap = new Map<string, Task>();
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>();
        Map<id, Sobject> sobjectsToUpdate = new Map<id, Sobject>();
        List<Sobject> sobjectsToInsert = new List<Sobject>();
        List<Log__c> logL = new List<Log__c>();

        List<Strategia__c> sList = new List<Strategia__c>();
        Strategia__c testata = new Strategia__c();
        Strategia__c cdi = new Strategia__c();
        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        cdi = TestClassForDatagenerationCreateData.getTestStrategiaCDI(testata.id);
        insert cdi;
        update testata;

        OrkStatic.retrievestrategie();

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(2);
        insert pList;
        pMap = new Map<string, Pratica__c>(pList);
        update pList;

        //recupero i taska
        string taskFields = TestStatic.getTaskAllFieds();
        taskFields = taskFields.replace('description,', '');
        taskFields = taskFields.replace('Description,', '');
        taskFields = taskFields.replace(',Description', '');

        String query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = Database.query(query);
        tMap = new Map<String, Task>(tList);
        Map<Id,ActivityExtended__c> taskId2ActExt = Utils.getTaskWithActivityExtended(tList);
        Map<Id,ActivityExtended__c> taskId2ActExt2 = Utils.cebGetTaskWithActivityExtended(tList, gd);

        for (Task t : tMap.values()) {
            t.WhatId = null;
        }


        Test.startTest();
        OrkKernel.executeFirstActivities(tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, taskId2ActExt);
        OrkKernel.cebExecuteFirstActivities(gd, tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, taskId2ActExt2);
        Test.stopTest();
    }

    /*Test executeExit */
    @IsTest static void OrkKernel_executeExit_noCDU() {
        Map<string, Task> tMap = new Map<string, Task>();
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>();
        Map<id, Sobject> sobjectsToUpdate = new Map<id, Sobject>();
        List<Sobject> sobjectsToInsert = new List<Sobject>();
        List<Log__c> logL = new List<Log__c>();

        List<Strategia__c> sList = new List<Strategia__c>();
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaTestata());
        insert sList;
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaSTEP(sList[0].Id, sList[0].Id));
        upsert sList;

        OrkStatic.retrievestrategie();
        OrkStatic.cebRetrievestrategie(gd);

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(2);
        insert pList;
        pMap = new Map<string, Pratica__c>(pList);

        //operazione per creare dei task e popolare soBjtoUpdate
        for (pratica__c p : pList) {
            p.bypassRole__c = '' + system.now();
            sobjectsToUpdate.put(p.id, p);
        }
        update pList;

        //recupero i taska
        string taskFields = TestStatic.getTaskAllFieds();
        string query = 'Select ' + taskFields + ',ActivityExtended__r.isFirst__c,ActivityExtended__r.record_type__c From Task ';
        List<Task> tList = database.query(query);
        tMap = new Map<string, task>(tList);

        test.startTest();
        //Map<Id, ActivityExtended__c> task2Obj = Utils.getTaskWithActivityExtended(tMap.values());
        Map<Id, ActivityExtended__c> task2Obj2 = Utils.cebGetTaskWithActivityExtended(tMap.values(), gd);
        ActivityExtended__c ae0 = task2Obj2.get(tList[0].Id);
        ActivityExtended__c ae1 = task2Obj2.get(tList[1].Id);
        System.debug('ae0 pre --> '+ae0);
        System.debug('ae1 pre --> '+ae1);
        ae0.isFirst__c = false;
        ae0.Go_to_task_of_strategie__c = sList[1].Id;
        tList[0].Status = 'In Lavorazione';
        ae0.RecordTypeId = TestStatic.getTaskRTId('Process');
        ae1.isFirst__c = true;
        ae1.Go_to_task_of_strategie__c = sList[0].Id;
        tList[1].Status = 'Error';
        ae1.RecordTypeId = TestStatic.getTaskRTId('Standard');
        update ae0;
        update ae1;
        update tList;

        //OrkKernel.executeExit('token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj);
        OrkKernel.cebExecuteExit(gd, 'token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj2);

        test.stopTest();
    }


    @IsTest static  void OrkKernel_cebExecuteExit_withCDU() {
        Map<String, Task> tMap = new Map<String, Task>();
        Map<String, Pratica__c> pMap = new Map<String, Pratica__c>();
        Map<id, Sobject> sobjectsToUpdate = new Map<id, Sobject>();
        List<Sobject> sobjectsToInsert = new List<Sobject>();
        List<Log__c> logL = new List<Log__c>();

        List<Strategia__c> sList = new List<Strategia__c>();
        Strategia__c testata = new Strategia__c();
        Strategia__c cdu = new Strategia__c();
        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        cdu = TestClassForDatagenerationCreateData.getTestStrategiaCDU(testata.id);
        cdu.Activation_roles__c = null;
        cdu.Esci_e_chiudi__c = true;
        insert cdu;
        testata.stato__c = 'Attiva';
        update testata;

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(1);
        insert pList;
        pMap = new Map<string, Pratica__c>(pList);
        List<Task> tskListAfterIns = [SELECT Id, Subject FROM Task];
        System.debug('tskListAfterIns --> '+tskListAfterIns);

        //operazione per creare dei task e popolare soBjtoUpdate
        for (pratica__c p : pList) {
            p.bypassRole__c = '' + system.now();
            sobjectsToUpdate.put(p.id, p);
        }
        update pList;

        //recupero i tasks
        string taskFields = TestStatic.getTaskAllFieds();
        string query = 'Select ' + taskFields + ',ActivityExtended__r.isFirst__c,ActivityExtended__r.Id_Strategia__c,ActivityExtended__r.record_type__c From Task ';
        List<Task> tList = database.query(query);
        System.debug('tList --> '+tList);

        boolean bool;
        test.startTest();
        OrkStatic.retrievestrategie();
        OrkStatic.cduPO.put(cdu.testata__c, new List<id>());
        OrkStatic.cduPO.get(cdu.testata__c).add(cdu.id);
        Map<Id, ActivityExtended__c> task2Obj2 = Utils.cebGetTaskWithActivityExtended(tList, gd);
        List<ActivityExtended__c> actExtesList = new List<ActivityExtended__c>();

        for (task t : tList) {
            ActivityExtended__c ae = task2Obj2.get(t.Id);
            t.Status ='Non iniziata';
            ae.id_strategia__c = cdu.testata__c;
            ae.isFirst__c = false;
            ae.RecordTypeId = TestStatic.getTaskRTId('Process');
            actExtesList.add(ae);
            tMap.put(t.id, t);
        }
        System.debug('actExtesList --> '+actExtesList);
        update actExtesList;
        update tList;
        OrkKernel.cebExecuteExit(gd, 'token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj2);
        test.stopTest();
    }

    @IsTest static void OrkKernel_executeExit_resultNull() {
        Map<string, Task> tMap = new Map<string, Task>();
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>();
        Map<id, Sobject> sobjectsToUpdate = new Map<id, Sobject>();
        List<Sobject> sobjectsToInsert = new List<Sobject>();
        List<Log__c> logL = new List<Log__c>();

        List<Strategia__c> sList = new List<Strategia__c>();
        Strategia__c testata = new Strategia__c();
        Strategia__c cdu = new Strategia__c();
        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        cdu = TestClassForDatagenerationCreateData.getTestStrategiaCDU(testata.id);
        insert cdu;
        testata.stato__c = 'Attiva';
        update testata;

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(1);
        insert pList;
        pMap = new Map<string, Pratica__c>(pList);

        //operazione per creare dei task e popolare soBjtoUpdate
        for (pratica__c p : pList) {
            p.bypassRole__c = '' + system.now();
            sobjectsToUpdate.put(p.id, p);
        }
        TaskHandler.internalUpdate = true;
        update pList;

        //recupero i taska
        string taskFields = TestStatic.getTaskAllFieds();
        string query = 'Select ' + taskFields + ',ActivityExtended__r.isFirst__c,ActivityExtended__r.record_type__c From Task ';
        List<Task> tList = database.query(query);

        boolean bool;
        test.startTest();
        OrkStatic.retrievestrategie();
        OrkStatic.cduPO.put(cdu.testata__c, new List<id>());
        OrkStatic.cduPO.get(cdu.testata__c).add(cdu.id);
        //Map<Id, ActivityExtended__c> aes2Obj = Utils.getTaskWithActivityExtended(tList);
        Map<Id, ActivityExtended__c> task2Obj2 = Utils.cebGetTaskWithActivityExtended(tList, gd);
        ActivityExtended__c ae = task2Obj2.get(tList[0].Id);
        for (task t : tList) {
            ae.id_strategia__c = cdu.testata__c;
            ae.isFirst__c = false;
            tMap.put(t.id, t);
        }
        //Map<Id, ActivityExtended__c> task2Obj = Utils.getTaskWithActivityExtended(tMap.values());
        //OrkKernel.executeExit('token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj);
        OrkKernel.cebExecuteExit(gd, 'token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj2);
        test.stopTest();
    }

    /*Test for jumps */
    @IsTest static void OrkKernel_executejump_noJump() {
        /*Il test prevvede due scenari semplici e sono
        . - fornire al metodo un oggetto che non deve essere lavorato dall'algoritmo per Jump
          - fornire un task che è lavorabile ma che nono ci sono record di jump per quel task
        */
        Map<string, Task> tMap = new Map<string, Task>();
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>();
        Map<id, Sobject> sobjectsToUpdate = new Map<id, Sobject>();
        List<Sobject> sobjectsToInsert = new List<Sobject>();
        List<Log__c> logL = new List<Log__c>();

        List<Strategia__c> sList = new List<Strategia__c>();
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaTestata());
        insert sList;

        OrkStatic.retrievestrategie();

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(2);
        insert pList;
        pMap = new Map<string, Pratica__c>(pList);

        //operazione per creare dei task e popolare soBjtoUpdate
        for (pratica__c p : pList) {
            p.bypassRole__c = '' + system.now();
            sobjectsToUpdate.put(p.id, p);
        }
        update pList;

        //recupero i taska
        string taskFields = TestStatic.getTaskAllFieds();
        // where Status != 'Lavorata' aggiungi alla query per rispettare condizioni if a riga 869??
        string query = 'Select ' + taskFields + ',ActivityExtended__r.isFirst__c,ActivityExtended__r.record_type__c From Task  ';
        List<Task> tList = database.query(query);
        Map<Id, ActivityExtended__c> aes2Obj = Utils.getTaskWithActivityExtended(tList);
        ActivityExtended__c ae = aes2Obj.get(tList[0].Id);
        ae.isFirst__c = false;
        tMap = new Map<string, task>(tList);
        Map<Id, ActivityExtended__c> task2Obj = Utils.getTaskWithActivityExtended(tMap.values());
        Map<Id, ActivityExtended__c> task2Obj2 = Utils.cebGetTaskWithActivityExtended(tList, gd);

        Map<String, SObject> objectForPraticaMap = CrabbEngineUtils.generateMapsFieldUpdate(pList, gd);

        test.startTest();
        //OrkKernel.executejump('token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj);
        OrkKernel.cebExecutejump(gd, 'token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj2);
        OrkKernel.cebExecutejump(objectForPraticaMap, gd, 'token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj2);
        test.stopTest();
    }

    @IsTest static void OrkKernel_executejump_withJump() {
        /*qualcosa non funziona in questo test */
        Map<string, Task> tMap = new Map<string, Task>();
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>();
        Map<id, Sobject> sobjectsToUpdate = new Map<id, Sobject>();
        List<Sobject> sobjectsToInsert = new List<Sobject>();
        List<Log__c> logL = new List<Log__c>();

        List<Strategia__c> sList = new List<Strategia__c>();
        Strategia__c testata = new Strategia__c();
        Strategia__c jump = new Strategia__c();
        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;

        //creazione step
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaStep(testata.id, testata.id));
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaStep(testata.id, testata.id));
        insert sList;

        jump = TestClassForDatagenerationCreateData.getTestStrategiaJump(testata.id, sList[0].id, sList[1].id);
        jump.Activation_roles__c = null;
        insert jump;

        testata.stato__c = 'Attiva';
        update testata;

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(1);
        insert pList;
        pMap = new Map<string, Pratica__c>(pList);

        //operazione per creare dei task e popolare soBjtoUpdate
        for (pratica__c p : pList) {
            p.bypassRole__c = '' + system.now();
            sobjectsToUpdate.put(p.id, p);
        }
        update pList;

        //recupero i taska
        string taskFields = TestStatic.getTaskAllFieds();
        string query = 'Select ' + taskFields + ',ActivityExtended__r.isFirst__c,ActivityExtended__r.Id_Strategia__c,ActivityExtended__r.record_type__c From Task ';
        List<Task> tList = database.query(query);
        Map<Id, ActivityExtended__c> task2Obj = Utils.getTaskWithActivityExtended(tList);
        Map<Id, ActivityExtended__c> task2Obj2 = Utils.cebGetTaskWithActivityExtended(tList, gd);
        for (task t : tList) {
            ActivityExtended__c ae = task2Obj.get(t.Id);
            ae.id_attivita__c = sList[0].id;
            ae.isFirst__c = false;
            ae.RecordTypeId = TestStatic.getTaskRTId('Process');
            t.status = 'Non iniziata';
            tMap.put(t.id, t);
        }

        Map<String, SObject> objectForPraticaMap = CrabbEngineUtils.generateMapsFieldUpdate(pList, gd);

        test.startTest();
        OrkStatic.retrievestrategie();
        //OrkKernel.executejump('token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj);
        OrkKernel.cebExecutejump(gd, 'token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj2);
        OrkKernel.cebExecutejump(objectForPraticaMap, gd, 'token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj2);
        test.stopTest();
    }

    @IsTest static void OrkKernel_cebExecutejump_withJump() {
        /*qualcosa non funziona in questo test */
        Map<string, Task> tMap = new Map<string, Task>();
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>();
        Map<id, Sobject> sobjectsToUpdate = new Map<id, Sobject>();
        List<Sobject> sobjectsToInsert = new List<Sobject>();
        List<Log__c> logL = new List<Log__c>();

        List<Strategia__c> sList = new List<Strategia__c>();
        Strategia__c testata = new Strategia__c();
        Strategia__c jump = new Strategia__c();
        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;

        //creazione step
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaStep(testata.id, testata.id));
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaStep(testata.id, testata.id));
        insert sList;

        jump = TestClassForDatagenerationCreateData.getTestStrategiaJump(testata.id, sList[0].id, sList[1].id);
        jump.Activation_roles__c = null;
        insert jump;

        testata.stato__c = 'Attiva';
        update testata;

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(1);
        insert pList;
        pMap = new Map<string, Pratica__c>(pList);

        //operazione per creare dei task e popolare soBjtoUpdate
        for (pratica__c p : pList) {
            p.bypassRole__c = '' + system.now();
            sobjectsToUpdate.put(p.id, p);
        }
        update pList;

        //recupero i taska
        string taskFields = TestStatic.getTaskAllFieds();
        string query = 'Select ' + taskFields + ',ActivityExtended__r.isFirst__c,ActivityExtended__r.Id_Strategia__c,ActivityExtended__r.record_type__c From Task ';
        List<Task> tList = database.query(query);
        Map<Id, ActivityExtended__c> task2Obj = Utils.getTaskWithActivityExtended(tList);
        Map<Id, ActivityExtended__c> task2Obj2 = Utils.cebGetTaskWithActivityExtended(tList, gd);
        for (task t : tList) {
            ActivityExtended__c ae = task2Obj2.get(t.Id);
            ae.id_attivita__c = sList[0].id;
            ae.isFirst__c = false;
            ae.RecordTypeId = TestStatic.getTaskRTId('Process');
            t.status = 'Non iniziata';
            tMap.put(t.id, t);
            system.debug('task2Obj2.get(t.Id);----> '+task2Obj2.get(t.Id));

        }

        Map<String, SObject> objectForPraticaMap = CrabbEngineUtils.generateMapsFieldUpdate(pList, gd);

        test.startTest();
        OrkStatic.retrievestrategie();
        //OrkKernel.executejump('token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj);
        OrkKernel.cebExecutejump(gd, 'token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj2);
        OrkKernel.cebExecutejump(objectForPraticaMap, gd, 'token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj2);
        test.stopTest();
    }

    @IsTest static void OrkKernel_cebExecutejump_withJump2() {
        /*qualcosa non funziona in questo test */
        Map<string, Task> tMap = new Map<string, Task>();
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>();
        Map<id, Sobject> sobjectsToUpdate = new Map<id, Sobject>();
        List<Sobject> sobjectsToInsert = new List<Sobject>();
        List<Log__c> logL = new List<Log__c>();

        List<Strategia__c> sList = new List<Strategia__c>();
        Strategia__c testata = new Strategia__c();
        Strategia__c jump = new Strategia__c();
        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;

        //creazione step
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaStep(testata.id, testata.id));
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaStep(testata.id, testata.id));
        insert sList;

        jump = TestClassForDatagenerationCreateData.getTestStrategiaJump(testata.id, sList[0].id, sList[1].id);
        jump.Activation_roles__c = null;
        insert jump;

        testata.stato__c = 'Attiva';
        update testata;

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(1);
        insert pList;
        pMap = new Map<string, Pratica__c>(pList);

        //operazione per creare dei task e popolare soBjtoUpdate
        for (pratica__c p : pList) {
            p.bypassRole__c = '' + system.now();
            sobjectsToUpdate.put(p.id, p);
        }
        update pList;

        //recupero i taska
        string taskFields = TestStatic.getTaskAllFieds();
        string query = 'Select ' + taskFields + ',ActivityExtended__r.isFirst__c,ActivityExtended__r.Id_Strategia__c,ActivityExtended__r.record_type__c From Task ';
        List<Task> tList = database.query(query);
        Map<Id, ActivityExtended__c> task2Obj = Utils.getTaskWithActivityExtended(tList);
        Map<Id, ActivityExtended__c> task2Obj2 = Utils.cebGetTaskWithActivityExtended(tList, gd);
        for (task t : tList) {
            ActivityExtended__c ae = task2Obj2.get(t.Id);
            ae.id_attivita__c = sList[0].id;
            ae.isFirst__c = false;
            ae.RecordTypeId = TestStatic.getTaskRTId('Process');
            t.status = 'Non iniziata';
            tMap.put(t.id, t);
        }

        Map<String, SObject> objectForPraticaMap = CrabbEngineUtils.generateMapsFieldUpdate(pList, gd);

        test.startTest();
        OrkStatic.retrievestrategie();
        //OrkKernel.executejump('token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj);
        //OrkKernel.cebExecutejump(gd, 'token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj2);
        OrkKernel.cebExecutejump(objectForPraticaMap, gd, 'token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj2);
        test.stopTest();
    }

    /*Test for llop */

    @IsTest static void OrkKernel_cebExecuteloop_withJump() {
        /*qualcosa non funziona in questo test */
        Map<string, Task> tMap = new Map<string, Task>();
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>();
        Map<id, Sobject> sobjectsToUpdate = new Map<id, Sobject>();
        List<Sobject> sobjectsToInsert = new List<Sobject>();
        List<Log__c> logL = new List<Log__c>();

        List<Strategia__c> sList = new List<Strategia__c>();
        Strategia__c testata = new Strategia__c();
        Strategia__c jump = new Strategia__c();
        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;

        //creazione step
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaStep(testata.id, testata.id));
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaStep(testata.id, testata.id));
        insert sList;
        jump = TestClassForDatagenerationCreateData.getTestStrategiaJump(testata.id, sList[0].id, sList[1].id);
        jump.Activation_roles__c = null;
        jump.isAutomaticJump__c = true;
        insert jump;

        testata.stato__c = 'Attiva';
        update testata;

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(1);
        insert pList;
        pMap = new Map<string, Pratica__c>(pList);


        //operazione per creare dei task e popolare soBjtoUpdate
        for (pratica__c p : pList) {
            p.bypassRole__c = '' + system.now();
            sobjectsToUpdate.put(p.id, p);
        }
        update pList;

        //recupero i taska
        string taskFields = TestStatic.getTaskAllFieds();
        string query = 'Select ' + taskFields + ',ActivityExtended__r.isFirst__c,ActivityExtended__r.Id_Strategia__c,ActivityExtended__r.record_type__c From Task ';

        ActivityExtended__c actExt = new ActivityExtended__c();
        actExt.Name = 'test';
        actExt.isFirst__c = false;
        actExt.id_attivita__c = sList[0].id;
        insert actExt;

        List<Task> tList = new List<Task>();
        task tsk = new task();
        tsk.Subject ='Test';
        tsk.type = 'Credito';
        tsk.Status = 'Non iniziata';
        tsk.WhatId = pList[0].id;
        tsk.ActivityExtended__c = actExt.Id;
        insert tsk;
        tList.add(tsk);
        update tList;
        tMap.put(tsk.id, tsk);

        Map<Id, ActivityExtended__c> task2Obj = Utils.getTaskWithActivityExtended(tList);
        Map<Id, ActivityExtended__c> task2Obj2 = Utils.cebGetTaskWithActivityExtended(tList, gd);

        /*for (task t : tList) {
            ActivityExtended__c ae = task2Obj2.get(t.Id);
            ae.id_attivita__c = sList[0].id;
            ae.isFirst__c = false;
            t.status = 'Lavorata';
            tMap.put(t.id, t);

        }*/

        Map<String, SObject> objectForPraticaMap = CrabbEngineUtils.generateMapsFieldUpdate(pList, gd);

        test.startTest();

        OrkStatic.retrievestrategie();
        //OrkKernel.executeloop('token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj);
        //OrkKernel.cebExecuteloop(gd, 'token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj2);
        OrkKernel.cebExecuteloop(objectForPraticaMap, gd, 'token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj2);
        test.stopTest();
    }

    @IsTest static void OrkKernel_executeloop_withJump_2() {
        /*Lo scenario prevede un task con id_attivita__c non corretto.*/
        Map<string, Task> tMap = new Map<string, Task>();
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>();
        Map<id, Sobject> sobjectsToUpdate = new Map<id, Sobject>();
        List<Sobject> sobjectsToInsert = new List<Sobject>();
        List<Log__c> logL = new List<Log__c>();

        List<Strategia__c> sList = new List<Strategia__c>();
        Strategia__c testata = new Strategia__c();
        Strategia__c jump = new Strategia__c();
        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;

        //creazione step
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaStep(testata.id, testata.id));
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaStep(testata.id, testata.id));
        insert sList;

        jump = TestClassForDatagenerationCreateData.getTestStrategiaJump(testata.id, sList[0].id, sList[1].id);
        jump.Activation_roles__c = null;
        jump.isAutomaticJump__c = true;
        insert jump;

        testata.stato__c = 'Attiva';
        update testata;

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(1);
        insert pList;
        pMap = new Map<string, Pratica__c>(pList);

        //operazione per creare dei task e popolare soBjtoUpdate
        for (pratica__c p : pList) {
            p.bypassRole__c = '' + system.now();
            sobjectsToUpdate.put(p.id, p);
        }
        update pList;

        //recupero i taska
        string taskFields = TestStatic.getTaskAllFieds();
        string query = 'Select ' + taskFields + ',ActivityExtended__r.isFirst__c,ActivityExtended__r.Id_Strategia__c,ActivityExtended__r.record_type__c From Task ';
        //List<Task> tList = database.query(query);

        ActivityExtended__c actExt = new ActivityExtended__c();
        actExt.Name = 'test';
        actExt.isFirst__c = false;
        actExt.id_attivita__c = sList[0].id;
        insert actExt;

        List<Task> tList = new List<Task>();
        task tsk = new task();
        tsk.Subject ='Test';
        tsk.type = 'Credito';
        tsk.Status = 'Non iniziata';
        tsk.WhatId = pList[0].id;
        tsk.ActivityExtended__c = actExt.Id;
        insert tsk;
        tList.add(tsk);
        update tList;
        tMap.put(tsk.id, tsk);

        Map<Id, ActivityExtended__c> task2Obj = Utils.cebgetTaskWithActivityExtended(tList, gd);
        /*for (task t : tList2) {
            ActivityExtended__c ae = task2Obj.get(t.Id);
            ae.id_attivita__c = testata.id;
            ae.isFirst__c = false;
            t.status = 'Lavorato';
            tMap.put(t.id, t);
            actExtList.add(ae);

        }*/

        boolean bool;

        Map<String, SObject> objectForPraticaMap = CrabbEngineUtils.generateMapsFieldUpdate(pList, gd);

        test.startTest();
        OrkStatic.retrievestrategie();
        //OrkKernel.executeloop('token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj);
        OrkKernel.cebExecuteloop(gd, 'token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj);
        //OrkKernel.cebExecuteloop(objectForPraticaMap, gd, 'token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj2);
        test.stopTest();
    }

    @IsTest static void OrkKernel_checkCondition_lessThan() {
        boolean bool;
        string condition = '<';
        date a, b; a = system.today(); b = a.adddays(1);
        datetime at, bt; at = system.now(); bt = at.adddays(1);
        Decimal ad, bd; ad = 1.45; bd = 1.68;
        String sa = '1', sb = '2';

        test.startTest();
        bool = OrkKernel.checkConditionForTestOnly(a, b, condition);
        bool = OrkKernel.checkConditionForTestOnly(at, bt, condition);
        bool = OrkKernel.checkConditionForTestOnly(ad, bd, condition);
        bool = OrkKernel.checkConditionForTestOnly(sa, sb, condition);
        test.stopTest();
    }
    @IsTest static void OrkKernel_checkCondition_lessOrEqual() {
        boolean bool;
        string condition = '<=';
        date a, b; a = system.today(); b = a.adddays(1);
        datetime at, bt; at = system.now(); bt = at.adddays(1);
        Decimal ad, bd; ad = 1.45; bd = 1.68;
        integer ai, bi; ai = 1; bi = 2;
        String sa = '1', sb = '2';

        test.startTest();
        bool = OrkKernel.checkConditionForTestOnly(a, b, condition);
        bool = OrkKernel.checkConditionForTestOnly(at, bt, condition);
        bool = OrkKernel.checkConditionForTestOnly(ad, bd, condition);
        bool = OrkKernel.checkConditionForTestOnly(sa, sb, condition);
        test.stopTest();
    }
    @IsTest static void OrkKernel_checkCondition_different() {
        boolean bool;
        string condition = '!=';
        date a, b; a = system.today(); b = a.adddays(1);
        datetime at, bt; at = system.now(); bt = at.adddays(1);
        Decimal ad, bd; ad = 1.45; bd = ad;
        integer ai, bi; ai = 1; bi = ai;
        string astr = 'xx', bstr = 'xx';
        boolean abool = true, bbool = false;
        String sa = '1', sb = '2';

        test.startTest();
        bool = OrkKernel.checkConditionForTestOnly(a, b, condition);
        bool = OrkKernel.checkConditionForTestOnly(at, bt, condition);
        bool = OrkKernel.checkConditionForTestOnly(ad, bd, condition);
        bool = OrkKernel.checkConditionForTestOnly(astr, bstr, condition);
        bool = OrkKernel.checkConditionForTestOnly(abool, bbool, condition);
        bool = OrkKernel.checkConditionForTestOnly(sa, sb, condition);
        test.stopTest();
    }
    @IsTest static void OrkKernel_checkCondition_Equal() {
        boolean bool;
        string condition = '==';
        date a, b; a = system.today(); b = a.adddays(1);
        datetime at, bt; at = system.now(); bt = at.adddays(1);
        Decimal ad, bd; ad = 1.45; bd = ad;
        integer ai, bi; ai = 1; bi = ai;
        string astr, bstr; astr = 'xx'; bstr = astr;
        boolean abool = true, bbool = false;
        String sa = '1', sb = '2';

        test.startTest();
        bool = OrkKernel.checkConditionForTestOnly(a, b, condition);
        bool = OrkKernel.checkConditionForTestOnly(at, bt, condition);
        bool = OrkKernel.checkConditionForTestOnly(ad, bd, condition);
        bool = OrkKernel.checkConditionForTestOnly(astr, bstr, condition);
        bool = OrkKernel.checkConditionForTestOnly(abool, bbool, condition);
        bool = OrkKernel.checkConditionForTestOnly(sa, sb, condition);
        test.stopTest();
    }
    @IsTest static void OrkKernel_checkCondition_greather() {
        boolean bool;
        string condition = '>';
        date a, b; a = system.today(); b = a.adddays(1);
        datetime at, bt; at = system.now(); bt = at.adddays(1);
        Decimal ad, bd; ad = 1.45; bd = ad;
        integer ai, bi; ai = 1; bi = ai;
        String sa = '1', sb = '2';

        test.startTest();
        bool = OrkKernel.checkConditionForTestOnly(a, b, condition);
        bool = OrkKernel.checkConditionForTestOnly(at, bt, condition);
        bool = OrkKernel.checkConditionForTestOnly(ad, bd, condition);
        bool = OrkKernel.checkConditionForTestOnly(sa, sb, condition);
        test.stopTest();
    }
    @IsTest static void OrkKernel_checkCondition_greatherEqual() {
        boolean bool;
        string condition = '>=';
        date a, b; a = system.today(); b = a.adddays(1);
        datetime at, bt; at = system.now(); bt = at.adddays(1);
        Decimal ad, bd; ad = 1.45; bd = ad;
        integer ai, bi; ai = 1; bi = ai;
        String sa = '1', sb = '2';

        test.startTest();
        bool = OrkKernel.checkConditionForTestOnly(a, b, condition);
        bool = OrkKernel.checkConditionForTestOnly(at, bt, condition);
        bool = OrkKernel.checkConditionForTestOnly(ad, bd, condition);
        bool = OrkKernel.checkConditionForTestOnly(sa, sb, condition);
        test.stopTest();
    }
    @IsTest static void OrkKernel_checkCondition_Includes() {
        boolean bool;
        string condition = 'includes';
        string a, b;
        a = 'a;b;c';
        b = 'c';

        test.startTest();
        bool = OrkKernel.checkConditionForTestOnly(a, b, condition);
        test.stopTest();
    }
    @IsTest static void OrkKernel_checkCondition_IsIncluded() {
        boolean bool;
        string condition = 'IsIncluded';
        string a, b;
        a = 'a;b;c';
        b = 'c;b';

        test.startTest();
        bool = OrkKernel.checkConditionForTestOnly(b, a, condition);
        test.stopTest();
    }
    @IsTest static void OrkKernel_checkCondition_escludes() {
        boolean bool;
        string condition = 'escludes';
        string a, b;
        a = 'a;b;c';
        b = 'd';
        string c, d;
        c = 'a;b;c';
        d = 'c';
        test.startTest();
        bool = OrkKernel.checkConditionForTestOnly(a, b, condition);
        bool = OrkKernel.checkConditionForTestOnly(c, d, condition);
        test.stopTest();
    }
    @IsTest static void OrkKernel_checkCondition_NoPresentCondition() {
        /*questo testa uno scenario in cui non gli viene fornita una condizione configurata */
        boolean bool;
        string condition = 'xxxxxx@@@@@';
        string a, b;
        a = 'a;b;c';
        b = 'd';
        test.startTest();
        bool = OrkKernel.checkConditionForTestOnly(a, b, condition);
        test.stopTest();
    }

    @IsTest static void OrkKernel_isRoleSatisfied() {
        Strategia__c testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        testata.Activation_roles__c = null;
        Pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        List<Log__c> logl = new List<Log__c>();
        task t = new task();
        boolean bool;

        test.startTest();
        bool = OrkKernel.isRoleSatisfied(p, testata, logl, t, null);
        test.stopTest();
    }
    @IsTest static void OrkKernel_isRoleSatisfied_2() {
        Strategia__c strategia = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        strategia.Activation_roles__c = 'R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,R13,R14,R15,R16,R17,R18,R19,R20,R21,R22,R23,R24,R25';
        strategia.Numero_figli__c = 1;
        strategia.Email_sollecito_popolata__c = false;
        strategia.Anzianita_scaduto__c = 65;
        strategia.Scaduto__c = 50;
        strategia.E_phone_SMS_popolato__c = false;
        strategia.White_list__c = false;
        Pratica__c pratica = TestClassForDatagenerationCreateData.getTestPratica();
        insert pratica;
        pratica.bypassRole__c = '' + system.now();
        update pratica;

        string praticaFields = TestStatic.getPraticaAllFieds();
        string query = 'Select ' + praticaFields + ' From Pratica__c where id=\'' + pratica.id + '\'';
        pratica = database.query(query);

        task t = new task();
        string taskFields = TestStatic.getTaskAllFieds();
        string queryTask = 'Select ' + taskFields + ' From task where whatid=\'' + pratica.id + '\'';
        t = database.query(queryTask);

        TestStatic.generaRuleControl();

        List<Log__c> logl = new List<Log__c>();

        boolean bool;
        List<Task> tasks = new List<Task>();
        tasks.add(t);
        Map<Id, ActivityExtended__c> task2Obj = Utils.getTaskWithActivityExtended(tasks);
        test.startTest();
        boolean isSatisfied = true;
        set<string> rules = new Set<string>(strategia.Activation_roles__c.split(','));
        system.debug('***OrkKernel_isRoleSatisfied_2:' + rules);

        bool = OrkKernel.isRoleSatisfied(pratica, strategia, logl, t, task2Obj);
        test.stopTest();
    }
    @IsTest static void OrkKernel_isRoleSatisfied_3() {
        Strategia__c strategia = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        strategia.Activation_roles__c = 'R26';
        strategia.Numero_figli__c = 1;
        strategia.Email_sollecito_popolata__c = false;
        strategia.Anzianita_scaduto__c = 65;
        strategia.Scaduto__c = 50;
        strategia.E_phone_SMS_popolato__c = false;
        strategia.White_list__c = false;
        Pratica__c pratica = TestClassForDatagenerationCreateData.getTestPratica();
        insert pratica;
        pratica.bypassRole__c = '' + system.now();
        update pratica;

        string praticaFields = TestStatic.getPraticaAllFieds();
        string query = 'Select ' + praticaFields + ' From Pratica__c where id=\'' + pratica.id + '\'';
        pratica = database.query(query);

        task t = new task();
        string taskFields = TestStatic.getTaskAllFieds();
        string queryTask = 'Select ' + taskFields + ' From task where whatid=\'' + pratica.id + '\'';
        t = database.query(queryTask);

        TestStatic.generaRuleControl();

        List<Log__c> logl = new List<Log__c>();

        boolean bool;
        List<Task> tasks = new List<Task>();
        tasks.add(t);
        Map<Id, ActivityExtended__c> task2Obj = Utils.getTaskWithActivityExtended(tasks);
        test.startTest();
        boolean isSatisfied = true;
        set<string> rules = new Set<string>(strategia.Activation_roles__c.split(','));
        system.debug('***OrkKernel_isRoleSatisfied_2:' + rules);

        bool = OrkKernel.isRoleSatisfied(pratica, strategia, logl, t, task2Obj);
        test.stopTest();
    }
    @IsTest static void OrkKernel_isRoleSatisfied_4() {
        Strategia__c strategia = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        strategia.Activation_roles__c = 'R25';
        strategia.Numero_figli__c = 1;
        strategia.Email_sollecito_popolata__c = false;
        strategia.Anzianita_scaduto__c = 65;
        strategia.Scaduto__c = 50;
        strategia.E_phone_SMS_popolato__c = false;
        strategia.White_list__c = false;
        Pratica__c pratica = TestClassForDatagenerationCreateData.getTestPratica();
        insert pratica;
        pratica.bypassRole__c = '' + system.now();
        update pratica;

        string praticaFields = TestStatic.getPraticaAllFieds();
        string query = 'Select ' + praticaFields + ' From Pratica__c where id=\'' + pratica.id + '\'';
        pratica = database.query(query);

        task t = new task();
        string taskFields = TestStatic.getTaskAllFieds();
        string queryTask = 'Select ' + taskFields + ' From task where whatid=\'' + pratica.id + '\'';
        t = database.query(queryTask);

        TestStatic.generaRuleControl();

        List<Log__c> logl = new List<Log__c>();

        boolean bool;
        List<Task> tasks = new List<Task>();
        tasks.add(t);
        Map<Id, ActivityExtended__c> task2Obj = Utils.getTaskWithActivityExtended(tasks);
        test.startTest();
        boolean isSatisfied = true;
        set<string> rules = new Set<string>(strategia.Activation_roles__c.split(','));
        system.debug('***OrkKernel_isRoleSatisfied_2:' + rules);

        bool = OrkKernel.isRoleSatisfied(pratica, strategia, logl, t, task2Obj);
        test.stopTest();
    }
    /* nextJob */

    @IsTest static void OrkKernel_cebNextJob() {
        Map<string, Task> tMap = new Map<string, Task>();
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>();
        Map<id, Sobject> sobjectsToUpdate = new Map<id, Sobject>();
        List<Sobject> sobjectsToInsert = new List<Sobject>();
        List<Log__c> logL = new List<Log__c>();


        Strategia__c strategia = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        strategia.Activation_roles__c = null;
        insert strategia;
        Strategia__c step1 = TestClassForDatagenerationCreateData.getTestStrategiaStep(strategia.id, strategia.id);
        insert step1;
        Strategia__c step2 = TestClassForDatagenerationCreateData.getTestStrategiaStep(strategia.id, step1.id);
        insert step2;
        update strategia;
        OrkStatic.retrievestrategie();

        Pratica__c pratica = TestClassForDatagenerationCreateData.getTestPratica();
        insert pratica;
        pratica.bypassRole__c = '' + system.now();
        update pratica;

        string praticaFields = TestStatic.getPraticaAllFieds();
        string query = 'Select ' + praticaFields + ' From Pratica__c where id=\'' + pratica.id + '\'';
        pratica = database.query(query);
        sobjectsToUpdate.put(pratica.id, pratica);
        pMap.put(pratica.id, pratica);

        task t = new task();
        string taskFields = TestStatic.getTaskAllFieds();
        string queryTask = 'Select ' + taskFields + ' From task where whatid=\'' + pratica.id + '\'';
        t = database.query(queryTask);
        t.status = 'Lavorata';
        ActivityExtended__c ae = new ActivityExtended__c();
        ae.id_attivita__c = step1.id;
        insert ae;
        t.ActivityExtended__c = ae.id;
        tMap.put(t.id, t);
        Map<Id, ActivityExtended__c> task2Obj2 = Utils.cebGetTaskWithActivityExtended(tMap.values(), gd);


        test.startTest();

        OrkKernel.cebNextJob(gd, 'token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logl, task2Obj2);

        test.stopTest();


    }

    @IsTest static void OrkKernel_cebSetNextJob() {
        Map<string, Task> tMap = new Map<string, Task>();
        Map<string, Pratica__c> pMap = new Map<string, Pratica__c>();
        Map<id, Sobject> sobjectsToUpdate = new Map<id, Sobject>();
        List<Sobject> sobjectsToInsert = new List<Sobject>();
        List<Log__c> logL = new List<Log__c>();


        Strategia__c strategia = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        strategia.Activation_roles__c = null;
        insert strategia;
        Strategia__c step1 = TestClassForDatagenerationCreateData.getTestStrategiaStep(strategia.id, strategia.id);
        insert step1;
        Strategia__c step2 = TestClassForDatagenerationCreateData.getTestStrategiaStep(strategia.id, step1.id);
        insert step2;
        update strategia;
        OrkStatic.retrievestrategie();

        Pratica__c pratica = TestClassForDatagenerationCreateData.getTestPratica();
        insert pratica;
        pratica.bypassRole__c = '' + system.now();
        update pratica;

        string praticaFields = TestStatic.getPraticaAllFieds();
        string query = 'Select ' + praticaFields + ' From Pratica__c where id=\'' + pratica.id + '\'';
        pratica = database.query(query);
        sobjectsToUpdate.put(pratica.id, pratica);
        pMap.put(pratica.id, pratica);

        task t = new task();
        string taskFields = TestStatic.getTaskAllFieds();
        string queryTask = 'Select ' + taskFields + ' From task where whatid=\'' + pratica.id + '\'';
        t = database.query(queryTask);
        t.status = 'Lavorata';
        ActivityExtended__c ae = new ActivityExtended__c();
        ae.id_attivita__c = step1.id;
        insert ae;
        t.ActivityExtended__c = ae.id;
        tMap.put(t.id, t);
        Map<Id, ActivityExtended__c> task2Obj2 = Utils.cebGetTaskWithActivityExtended(tMap.values(), gd);
        Map<String, SObject> objectForPraticaMap = CrabbEngineUtils.generateMapsFieldUpdate(pMap.values(),gd);
        Map<Id, ActivityExtended__c> filteredTsksActsExtMap = Ork.buildFilteredTasksActivitiesExtMap (task2Obj2, tMap);

        test.startTest();

        OrkKernel.cebSetNextJob(objectForPraticaMap, gd, 'token', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, filteredTsksActsExtMap);

        test.stopTest();


    }


}