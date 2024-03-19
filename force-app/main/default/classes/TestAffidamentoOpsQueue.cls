@IsTest
public class TestAffidamentoOpsQueue {
    @IsTest
    public static void testMethod1() {

        List<Affidamento__c> lAff = new List<Affidamento__c>();
        lAff.add(TestClassFroDataGenAffidamenti.getQuickAffido());
        lAff.add(TestClassFroDataGenAffidamenti.getQuickAffido());
        insert lAff;

        Account ac = new Account(Name='TestAccount');
        insert ac;

        List<Pratica__c> pList = new List<Pratica__c>();
        pList.add(new Pratica__c(Account__c = ac.id, Data_ultimo_Saldo__c = System.today()));
        insert pList;

        List<Task> taskList = new List<Task>();
        Task taskTest = new Task();
        taskList.add(taskTest);
        insert taskList;

        affidamentoOpsQueue queueTest = new affidamentoOpsQueue(lAff, pList, taskList);
        System.enqueueJob(queueTest);

        Test.startTest();
        queueTest = new affidamentoOpsQueue(null, pList, taskList);
        System.enqueueJob(queueTest);
        Test.stopTest();
    }
}