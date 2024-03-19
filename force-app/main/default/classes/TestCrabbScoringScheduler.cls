@isTest
public class TestCrabbScoringScheduler {

    @isTest
    static void testmethod_ok() {
        List<Account> accountList = new list<Account>();
        Account a1 = new Account();
        a1.Name = 'Test1';
        accountList.add(a1);
        Account a2 = new Account();
        a2.Name = 'Test2';
        a2.CRABB_DEV__considered_in_scoring__c = true;
        accountList.add(a2);
        insert accountList;

        test.startTest();
        CrabbScoringScheduler sche = new CrabbScoringScheduler(200);
        system.schedule('CrabbScoringScheduler', '0 0 22 * * ? *', sche);
        test.stopTest();
    }

}