@IsTest
public class TestTaskTrigger {

    static testMethod void TestTaskTrigger() {

        Test.startTest();
        List<Task> tasksList = new List<Task>();
        ActivityExtended__c actExt = new ActivityExtended__c();
        Task tsk1 = new Task();
        tsk1.ActivityExtended__c = actExt.Id;
        tasksList.add(tsk1);

        Task tsk2 = new Task();
        tasksList.add(tsk2);
        insert tasksList;

        Test.stopTest();
    }
}