/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestOrkActivities.cls
Description:     Test Class for code coverage of OrkActivities.cls (Contiene la classe di test per la classe ErrorClass)


Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
04-Aug-2014  0.1      Klodjan Meta                    First Version
10-May-2021  0.2      Giulia Mameli                   Modified: orkActivities_Time(), orkActivities_Attesa_scaduto(),
                                                      orkActivities_noActivity() using a query to retrieve Tasks and added
                                                      TaskIds - ActsExt Map as input parameter for OrkActivities.execute()
13-May-2020  0.3      M.Siotto & G.Mameli             Reviewed for using ceb methods
----------------------------------------------------------------------------------------------------------------------*/

@IsTest
public class TestOrkActivities {
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    @IsTest
    static void orkActivities_Mail() {
        String activity = 'Mail';
        Map<String, Task> tMap = new Map<String, Task>();
        Map<String, Pratica__c> pMap = new Map<String, Pratica__c>();
        List<Log__c> logl = new List<Log__c>();

        Account acc = TestClassForDatagenerationCreateData.getTestAccount();
        insert acc;

        Pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        TestDM.AssociateAccountToPratica(acc, p);
        insert p;
        pMap.put(p.Id, p);

        List<SObject> t = OrkBL.newTask(p);
        insert t;
        Task tt = null;
        for (SObject tmp : t) {
            if (tmp instanceof Task) {
                tt = (Task) tmp;
                tMap.put(tt.Id, tt);
            }
        }

        Map<Id,ActivityExtended__c> taskId2ActExt = Utils.getTaskWithActivityExtended(tMap.values());

        Test.startTest();
        OrkActivities.execute(activity, tMap, pMap, logl, taskId2ActExt);
        OrkActivities.cebExecute(activity, tMap, pMap, logl, taskId2ActExt, gd);
        Test.stopTest();
    }

    @IsTest
    static void orkActivities_InvioAR() {
        String activity = 'InvioAR';
        Map<String, Task> tMap = new Map<String, Task>();
        Map<String, Pratica__c> pMap = new Map<String, Pratica__c>();
        List<Log__c> logl = new List<Log__c>();

        Account acc = TestClassForDatagenerationCreateData.getTestAccount();
        insert acc;

        Pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        TestDM.AssociateAccountToPratica(acc, p);

        insert p;
        pMap.put(p.Id, p);

        List<SObject> t = OrkBL.newTask(p);
        insert t;
        Task tt = null;
        for (SObject tmp : t) {
            if (tmp instanceof Task) {
                tt = (Task) tmp;
                tMap.put(tt.Id, tt);
            }
        }
        Map<Id,ActivityExtended__c> taskId2ActExt = Utils.getTaskWithActivityExtended(tMap.values());

        Test.startTest();
        OrkActivities.execute(activity, tMap, pMap, logl, taskId2ActExt);
        OrkActivities.cebExecute(activity, tMap, pMap, logl, taskId2ActExt, gd);
        Test.stopTest();
    }

    @IsTest
    static void orkActivities_Time() {
        String activity = 'Time';
        Map<String, Task> tMap = new Map<String, Task>();
        Map<String, Pratica__c> pMap = new Map<String, Pratica__c>();
        List<Log__c> logl = new List<Log__c>();

        Account acc = TestClassForDatagenerationCreateData.getTestAccount();
        insert acc;

        Pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        TestDM.AssociateAccountToPratica(acc, p);

        insert p;
        pMap.put(p.Id, p);
        User lUs = new User();
        lUs = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');

        //Crea Collector
        Collector__c col = TestClassFroDataGenAffidamenti.getCollector(lUs.Id);
        col.Tipo_Collector__c = 'ADR';
        insert col;

        //Crea Lotto
        Lotto__c lot = TestClassFroDataGenAffidamenti.getLotto(col.Id);
        insert lot;

        //Crea Pratica
        Contratto__c ct = TestClassFroDataGenAffidamenti.getContratto();
        insert ct;

        //Crea Affido
        Affidamento__c aff1 = TestClassFroDataGenAffidamenti.getAffido('In Corso', System.today(), lot.Id, p.Id);
        aff1.Scaduto_iniziale__c = 1000;
        aff1.Scaduto_finale__c = 500;
        insert aff1;

        List<SObject> tskActExt = OrkBL.newTask(p);
        insert tskActExt;

        List<Task> tList = new List<Task>();
        Task tsk = null;

        for (SObject tmp : tskActExt) {
            if (tmp instanceof Task) {
                tsk = (Task) tmp;
            }
        }

        //After insertion the Task Handler will couple Task and related Activity Extended,
        //so populate Task List with a query and not using Task from for loop.
        tList = [SELECT Id, ActivityExtended__c FROM Task WHERE Id =: tsk.Id];
        Map<Id,ActivityExtended__c> taskId2ActExt = Utils.getTaskWithActivityExtended(tList);
        ActivityExtended__c ae = taskId2ActExt.get(tsk.Id);
        ae.Expiration_date__c = System.today().addDays(-1);
        ae.id_affidamento__c = aff1.Id;
        update ae;
        tMap.put(tsk.Id, tsk);


        Test.startTest();
        OrkActivities.execute(activity, tMap, pMap, logl, taskId2ActExt);
        OrkActivities.cebExecute(activity, tMap, pMap, logl, taskId2ActExt, gd);
        OrkActivities.CreteLettersForAttachment(tsk.Id);
        Test.stopTest();
    }

    @IsTest
    static void orkActivities_Attesa() {
        String activity = 'Time';
        Map<String, Task> tMap = new Map<String, Task>();
        Map<String, Pratica__c> pMap = new Map<String, Pratica__c>();
        List<Log__c> logl = new List<Log__c>();

        Account acc = TestClassForDatagenerationCreateData.getTestAccount();
        Pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        TestDM.AssociateAccountToPratica(acc, p);

        insert p;
        pMap.put(p.Id, p);

        List<SObject> t = OrkBL.newTask(p);
        insert t;
        Task tt = null;
        for (SObject tmp : t) {
            if (tmp instanceof Task) {
                tt = (Task) tmp;
            }
        }
        //throw new Utils.BalanceException('AAA:'+tt);
        tMap.put(tt.Id, tt);
        Map<Id,ActivityExtended__c> taskId2ActExt = Utils.getTaskWithActivityExtended(tMap.values());
        //Utils.getTaskWithActivityExtended(tMap.values())
        // throw new Utils.BalanceException('BBB:'+tMap.values());
        //throw new Utils.BalanceException('AAA:'+Utils.getTaskWithActivityExtended(tMap.values()));
        Test.startTest();
        OrkActivities.execute(activity, tMap, pMap, logl, taskId2ActExt);
        OrkActivities.cebExecute(activity, tMap, pMap, logl, taskId2ActExt, gd);
        Test.stopTest();
    }

    @IsTest
    static void orkActivities_Attesa_scaduto() {
        String activity = 'Attesa';
        Map<String, Task> tMap = new Map<String, Task>();
        Map<String, Pratica__c> pMap = new Map<String, Pratica__c>();
        List<Log__c> logl = new List<Log__c>();

        Account acc = TestClassForDatagenerationCreateData.getTestAccount();
        Pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        TestDM.AssociateAccountToPratica(acc, p);

        insert p;
        pMap.put(p.Id, p);

        List<SObject> tskActExt = OrkBL.newTask(p);
        insert tskActExt;

        List<Task> tList = new List<Task>();
        Task tsk = null;

        for (SObject tmp : tskActExt) {
            if (tmp instanceof Task) {
                tsk = (Task) tmp;
            }
        }

        //After insertion the Task Handler will couple Task and related Activity Extended,
        //so populate Task List with a query and not using for loop.
        tList = [SELECT Id, ActivityExtended__c FROM Task WHERE Id =: tsk.Id];
        Map<Id,ActivityExtended__c> taskId2ActExt = Utils.getTaskWithActivityExtended(tList);
        ActivityExtended__c ae = taskId2ActExt.get(tsk.Id);
        ae.Expiration_date__c = System.today().addDays(-1);
        update ae;
        tMap.put(tsk.Id, tsk);

        Test.startTest();
        OrkActivities.execute(activity, tMap, pMap, logl, taskId2ActExt);
        OrkActivities.cebExecute(activity, tMap, pMap, logl, taskId2ActExt, gd);
        Test.stopTest();
    }

    @IsTest
    static void orkActivities_noActivity() {
        String activity = 'NOACTIVITY';
        Map<String, Task> tMap = new Map<String, Task>();
        Map<String, Pratica__c> pMap = new Map<String, Pratica__c>();
        List<Log__c> logl = new List<Log__c>();

        Account acc = TestClassForDatagenerationCreateData.getTestAccount();
        Pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        TestDM.AssociateAccountToPratica(acc, p);

        insert p;
        pMap.put(p.Id, p);

        List<SObject> tskActExt = OrkBL.newTask(p);
        insert tskActExt;

        List<Task> tList = new List<Task>();
        Task tsk = null;
        for (SObject tmp : tskActExt) {
            if (tmp instanceof Task) {
                tsk = (Task) tmp;
            }
        }

        //After insertion the Task Handler will couple Task and related Activity Extended,
        //so populate Task List with a query and not using Task from for loop.
        tList = [SELECT Id, ActivityExtended__c FROM Task WHERE Id =: tsk.Id];
        Map<Id,ActivityExtended__c> taskId2ActExt = Utils.getTaskWithActivityExtended(tList);
        tMap.put(tsk.Id, tsk);

        ActivityExtended__c ae = taskId2ActExt.get(tsk.Id);
        ae.Expiration_date__c = System.today().addDays(-1);

        Test.startTest();
        OrkActivities.execute(activity, tMap, pMap, logl, taskId2ActExt);
        OrkActivities.cebExecute(activity, tMap, pMap, logl, taskId2ActExt, gd);
        Test.stopTest();
    }
}