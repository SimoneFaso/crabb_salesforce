@isTest
public class TestAccountTrigger {
    static testmethod void testTrigg(){
        test.startTest();
        Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        insert con;
        
        Account ac = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert ac;
        System.assert(true,ac.Name == 'Test');
        test.stopTest();
    }
}