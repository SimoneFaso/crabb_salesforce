/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestOrk.cls
Description:     Test Class for code coverage of Ork.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
16-Aug-2014  0.1      Klodjan Meta                    First Version
----------------------------------------------------------------------------------------------------------------------*/

@IsTest
public class TestOrk {//Ork Funzioni Kernel dell'orchestratore

    @TestSetup
    public static void generateStrategy() {
        generateStrategyRecords();
    }

    @IsTest static void Ork_instance() {
        Test.startTest();
        Ork ork = new Ork();
        Test.stopTest();
    }

    @IsTest static void Ork_execute_with_listempty() {
        List<Task> tlist = new List<Task>();
        Ork ork = new Ork();
        Test.startTest();
        ork.execute('Token', tList, tList);
        Test.stopTest();
    }

    @IsTest static void Ork_execute_with_istancesOfTask() {
        List<Task> tlist = new List<Task>();
        ActivityExtended__c ae = new ActivityExtended__c();
        OrkStatic.setTaskRecrdType();
        ae.RecordTypeId = OrkStatic.NameIdTasksRecordTyepesMap.get('Process').getRecordTypeId();
        insert ae;
        Task t = new Task();
        t.ActivityExtended__c = ae.Id;
        tlist.add(t);
        Ork ork = new Ork();
        Test.startTest();
        ork.execute('Token', tList, tList);
        Test.stopTest();
    }

    @IsTest static void Ork_execute_with_isForcedOperation() {
        List<Strategia__c> sList = new List<Strategia__c>();
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
        for (Pratica__c p : pList) p.byPassRole__c = '' + System.now();
        update pList;

        String taskFields = TestStatic.getTaskAllFieds();
        String query = 'Select ' + taskFields + ' ,ActivityExtended__r.Account_id__c, ActivityExtended__r.id_attivita__c ' + ' From Task ';
        List<Task> tList = Database.query(query);
        Map<Id, ActivityExtended__c> aes2Obj = new Map<Id, ActivityExtended__c>();
        aes2Obj = Utils.getTaskWithActivityExtended(tList);
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        OrkStatic.setTaskRecrdType();
        for (Task t : tList) {
            ActivityExtended__c ae = aes2Obj.get(t.Id);
            ae.isForcedOperation__c = true;
            ae.Go_to_task_of_strategie__c = step.id;
            ae.RecordTypeId = OrkStatic.NameIdTasksRecordTyepesMap.get('Process').getRecordTypeId();
            aes.add(ae);
        }
        update aes;
        Ork ork = new Ork();

        Test.startTest();
        //ork.executeDummy();
        ork.execute('Token', tList, tList);
        Test.stopTest();
    }

    @IsTest static void Ork_execute_with_logs() {
        List<Strategia__c> sList = new List<Strategia__c>();
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
        for (Pratica__c p : pList) p.byPassRole__c = '' + System.now();
        update pList;

        String taskFields = TestStatic.getTaskAllFieds();
        String query = 'Select ' + taskFields + ' ,ActivityExtended__r.Account_id__c, ActivityExtended__r.id_attivita__c ' + ' From Task ';
        List<Task> tList = Database.query(query);
        Map<Id, ActivityExtended__c> aes2Obj = new Map<Id, ActivityExtended__c>();
        aes2Obj = Utils.getTaskWithActivityExtended(tList);
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        OrkStatic.setTaskRecrdType();
        for (Task t : tList) {
            ActivityExtended__c ae = aes2Obj.get(t.Id);
            ae.isForcedOperation__c = true;
            ae.Go_to_task_of_strategie__c = step.Id;
            ae.RecordTypeId = OrkStatic.NameIdTasksRecordTyepesMap.get('Process').getRecordTypeId();
            aes.add(ae);
        }
        update aes;
        //throw new Utils.BalanceException('KKK:'+tList);
        Ork orkInstance = new Ork();
        Ork.areLogsActive = true;
        Test.startTest();
        orkInstance.execute('Token', tList, tList);
        Test.stopTest();
    }

    @IsTest static void Ork_execute_with_isFirst() {
        List<Strategia__c> sList = new List<Strategia__c>();
        Strategia__c testata = new Strategia__c();
        Strategia__c step = new Strategia__c();
        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        step = TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id, testata.id);
        insert step;
        update testata;

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(2);
        insert pList;

        //operazione per creare dei task
        for (Pratica__c p : pList) p.bypassRole__c = '' + system.now();
        update pList;

        String taskFields = TestStatic.getTaskAllFieds();
        String query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = Database.query(query);
        Ork orkInstance = new Ork();
        Ork.areLogsActive = true;
        Test.startTest();
        orkInstance.execute('Token', tList, tList);
        Test.stopTest();
    }

    @IsTest static void Ork_execute_with_isUI() {
        Strategia__c testata = new Strategia__c();
        List<Strategia__c> sList = new List<Strategia__c>();
        Strategia__c str = new Strategia__c();

        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        str = TestClassForDatagenerationCreateData.getTestStrategiaCDI(testata.id);
        str.Activation_roles__c = null;
        sList.add(str);
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaCDU(testata.id));
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id, testata.id));
        insert sList;
        update testata;

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(2);
        insert pList;

        //operazione per creare dei task
        for (Pratica__c p : pList) p.bypassRole__c = '' + system.now();
        update pList;

        String taskFields = TestStatic.getTaskAllFieds();

        String query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = Database.query(query);
        Map<Id, ActivityExtended__c> aes2Obj = new Map<Id, ActivityExtended__c>();
        aes2Obj = Utils.getTaskWithActivityExtended(tList);
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (task t : tList) {
            ActivityExtended__c ae = aes2Obj.get(t.Id);
            ae.recordtypeId = TestStatic.getTaskRTId('UI');
            t.status = 'Lavorata';
            aes.add(ae);
        }
        update aes;
        Test.startTest();
        update tList;
        Test.stopTest();
    }

    @IsTest static void Ork_execute_with_isProcess() {
        Strategia__c testata = new Strategia__c();
        List<Strategia__c> sList = new List<Strategia__c>();
        Strategia__c str = new Strategia__c();

        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        str = TestClassForDatagenerationCreateData.getTestStrategiaCDI(testata.id);
        str.Activation_roles__c = null;
        sList.add(str);
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaCDU(testata.id));
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id, testata.id));
        insert sList;
        update testata;

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(2);
        insert pList;

        //operazione per creare dei task
        for (Pratica__c p : pList) p.bypassRole__c = '' + system.now();
        update pList;

        String taskFields = TestStatic.getTaskAllFieds();

        String query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = Database.query(query);
        Map<Id, ActivityExtended__c> aes2Obj = new Map<Id, ActivityExtended__c>();
        aes2Obj = Utils.getTaskWithActivityExtended(tList);
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (task t : tList) {
            ActivityExtended__c ae = aes2Obj.get(t.Id);
            ae.isFirst__c = false;
            ae.recordtypeId = TestStatic.getTaskRTId('Process');
            t.status = 'Non Iniziata';
            aes.add(ae);
        }
        update aes;
        Test.startTest();
        //TaskHandler.internalUpdate=true;
        update tList;
        Test.stopTest();
    }

    @IsTest static void Ork_execute_with_isProcess_2() {
        Strategia__c testata = new Strategia__c();
        List<Strategia__c> sList = new List<Strategia__c>();
        Strategia__c str = new Strategia__c();

        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        str = TestClassForDatagenerationCreateData.getTestStrategiaCDI(testata.id);
        str.Activation_roles__c = null;
        sList.add(str);
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaCDU(testata.id));
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id, testata.id));
        insert sList;
        update testata;

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(2);
        insert pList;

        //operazione per creare dei task
        for (Pratica__c p : pList) p.bypassRole__c = '' + system.now();
        update pList;

        String taskFields = TestStatic.getTaskAllFieds();

        String query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = Database.query(query);
        Map<Id, ActivityExtended__c> aes2Obj = new Map<Id, ActivityExtended__c>();
        aes2Obj = Utils.getTaskWithActivityExtended(tList);
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for (task t : tList) {
            ActivityExtended__c ae = aes2Obj.get(t.Id);
            ae.isFirst__c = false;
            ae.recordtypeId = TestStatic.getTaskRTId('Process');
            t.status = 'Non iniziata';
            ae.Activity__c = 'Time';
            aes.add(ae);
        }
        update aes;
        Test.startTest();
        update tList;
        Test.stopTest();
    }

    @IsTest static void Ork_execute_with_Expetance() {
        Strategia__c testata = new Strategia__c();
        List<Strategia__c> sList = new List<Strategia__c>();
        Strategia__c str = new Strategia__c();

        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        str = TestClassForDatagenerationCreateData.getTestStrategiaCDI(testata.id);
        str.Activation_roles__c = null;
        sList.add(str);
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaCDU(testata.id));
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id, testata.id));
        insert sList;
        update testata;

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(2);
        insert pList;

        //operazione per creare dei task
        for (Pratica__c p : pList) p.bypassRole__c = '' + system.now();
        update pList;

        String taskFields = TestStatic.getTaskAllFieds();

        String query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = Database.query(query);

        List<Id> ids = new List<Id>();
        for (task t : tList) {
            t.SLA__c = 0;
            t.status = 'Non iniziata';
            ids.add(t.id);
        }
        Map<Id, ActivityExtended__c> aes = new Map<Id, ActivityExtended__c>([SELECT Id,recordtypeId,Activity__c,SLA__c,Expiration_date__c,Record_type__c FROM ActivityExtended__c WHERE Id in :ids]);
        List<ActivityExtended__c> aes2 = new List<ActivityExtended__c>();
        for (ActivityExtended__c tmp : aes.values()) {

            tmp.isFirst__c = false;
            tmp.recordtypeId = TestStatic.getTaskRTId('Expectance');
            tmp.Activity__c = 'Time';
            tmp.SLA__c = 0;
            tmp.Expiration_date__c = null;
            aes2.add(tmp);
        }
        update aes2;
        Test.startTest();
        //TaskHandler.internalUpdate = false;
        update tList;
        Test.stopTest();
    }

    @IsTest static void Ork_execute_with_Expetance_and_result() {
        Strategia__c testata = new Strategia__c();
        List<Strategia__c> sList = new List<Strategia__c>();
        Strategia__c str = new Strategia__c();

        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        str = TestClassForDatagenerationCreateData.getTestStrategiaCDI(testata.id);
        str.Activation_roles__c = null;
        sList.add(str);
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaCDU(testata.id));
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id, testata.id));
        insert sList;
        update testata;

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(2);
        insert pList;

        //operazione per creare dei task
        for (Pratica__c p : pList) p.bypassRole__c = '' + system.now();
        update pList;

        String taskFields = TestStatic.getTaskAllFieds();

        String query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = Database.query(query);
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        Map<Id, ActivityExtended__c> aes2Obj = Utils.getTaskWithActivityExtended(tList);
        for (task t : tList) {
            ActivityExtended__c ae = aes2Obj.get(t.Id);
            ae.isFirst__c = false;
            ae.recordtypeId = TestStatic.getTaskRTId('Expectance');
            t.status = 'Non iniziata';
            ae.Activity__c = 'Time';
            ae.SLA__c = 0;
            ae.Expiration_date__c = system.today();
            aes.add(ae);
        }
        update aes;
        //System.debug('Updated aes list is:'+Utils.getTaskWithActivityExtended(tList).values());
        // throw new Utils.BalanceException('AES:'+aes);
        Test.startTest();
        update tList;
        Test.stopTest();
    }

    @IsTest static void Ork_execute_delete_tasks() {
        Strategia__c testata = new Strategia__c();
        List<Strategia__c> sList = new List<Strategia__c>();
        Strategia__c str = new Strategia__c();

        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        str = TestClassForDatagenerationCreateData.getTestStrategiaCDI(testata.id);
        str.Activation_roles__c = null;
        sList.add(str);
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaCDU(testata.id));
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id, testata.id));
        insert sList;
        update testata;

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(2);
        insert pList;

        //operazione per creare dei task
        for (Pratica__c p : pList) p.bypassRole__c = '' + system.now();
        update pList;

        String taskFields = TestStatic.getTaskAllFieds();

        String query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = Database.query(query);

        Test.startTest();
        delete tList;
        Test.stopTest();
    }

    @IsTest static void taskHandler_LogActive() {
        TaskHandler.areLogsActive = true;
        Strategia__c testata = new Strategia__c();
        List<Strategia__c> sList = new List<Strategia__c>();
        Strategia__c str = new Strategia__c();

        testata = TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        str = TestClassForDatagenerationCreateData.getTestStrategiaCDI(testata.id);
        str.Activation_roles__c = null;
        sList.add(str);
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaCDU(testata.id));
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id, testata.id));
        insert sList;
        update testata;

        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(2);
        insert pList;

        //operazione per creare dei task
        for (Pratica__c p : pList) p.bypassRole__c = '' + system.now();
        update pList;

        String taskFields = TestStatic.getTaskAllFieds();

        String query = 'Select ' + taskFields + ' From Task ';
        List<Task> tList = Database.query(query);

        Test.startTest();
        delete tList;
        Test.stopTest();
    }

    private static void generateStrategyRecords() {
        Map<String, Schema.RecordTypeInfo> RTStrategiaNameID = Schema.SObjectType.Strategia__c.getrecordtypeinfosbydevelopername();
        List<Strategia__c> strategyList = new List<Strategia__c>();

        Strategia__c testata = new Strategia__c();
        testata.Nome__c = 'Strategy test';
        testata.Priority__c = 1;
        testata.Stato__c = 'Attiva';
        testata.Versione__c = 1;
        testata.recordtypeId = RTStrategiaNameID.get('Testata').getRecordTypeID();
        testata.Tipo_Strategia__c = 'Standard';
        testata.Activation_roles__c = 'R2015-03-04 11:35:16,R2021-03-03 14:52:18,R7,R2014-07-11 10:29:40';
        //strategyList.add(testata);
        insert testata;


        Strategia__c condIngresso = new Strategia__c();
        condIngresso.CRABB_DEV__Testata__c = testata.id;
        condIngresso.Nome__c = 'Ingresso strategia test';
        condIngresso.Priority__c = 1;
        condIngresso.Stato__c = 'Attiva';
        condIngresso.recordtypeId = RTStrategiaNameID.get('Condizioni_di_Ingresso').getRecordTypeID();
        condIngresso.RC_Rule_Name__c = 'R2021-03-03 14:52:18';
        strategyList.add(condIngresso);

        //Step Stand-By
        Strategia__c stepSB = new Strategia__c();
        stepSB.CRABB_DEV__Testata__c = testata.id;
        stepSB.CRABB_DEV__Attivit_Padre__c = testata.id;
        stepSB.CRABB_DEV__Tipo_attivita__c = 'Attività di Attesa';
        stepSB.Nome__c = '1 - Stand by';
        stepSB.Tipologia__c = 'Expectance';
        stepSB.Priority__c = 0;
        stepSB.Stato__c = 'Attiva';
        stepSB.recordtypeId = RTStrategiaNameID.get('Step').getRecordTypeID();
        insert stepSB;

        //Step Crea Case
        Strategia__c stepCreaCase = new Strategia__c();
        stepCreaCase.CRABB_DEV__Testata__c = testata.id;
        stepCreaCase.CRABB_DEV__Attivit_Padre__c = stepSB.id;
        stepCreaCase.CRABB_DEV__Tipo_attivita__c = 'Invio SMS';
        stepCreaCase.sotto_tipo_attivita__c = 'Seconda Raccomandata';
        stepCreaCase.Nome__c = 'Crea Case';
        stepCreaCase.Tipologia__c = 'UI';
        stepCreaCase.Priority__c = 1;
        stepCreaCase.Stato__c = 'Attiva';
        stepCreaCase.recordtypeId = RTStrategiaNameID.get('Step').getRecordTypeID();
        strategyList.add(stepCreaCase);

        //Step Crea PDF
        Strategia__c stepCreaPDF = new Strategia__c();
        stepCreaPDF.CRABB_DEV__Testata__c = testata.id;
        stepCreaPDF.CRABB_DEV__Attivit_Padre__c = stepSB.id;
        stepCreaPDF.CRABB_DEV__Tipo_attivita__c = 'Proposta di Attività';
        stepCreaPDF.sotto_tipo_attivita__c = 'Lettera ordinaria';
        stepCreaPDF.Nome__c = 'CREA PDF';
        stepCreaPDF.Tipologia__c = 'UI';
        stepCreaPDF.Priority__c = 2;
        stepCreaPDF.Stato__c = 'Attiva';
        stepCreaPDF.recordtypeId = RTStrategiaNameID.get('Step').getRecordTypeID();
        strategyList.add(stepCreaPDF);

        insert strategyList;
        update testata;

    }

}