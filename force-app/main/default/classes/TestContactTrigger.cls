@isTest
public class TestContactTrigger {
    static testmethod void testTrig(){
        test.startTest();
        Contact c = new Contact();
        c.LastName = 'Sl';
        insert c;
        test.stopTest();
    }
}