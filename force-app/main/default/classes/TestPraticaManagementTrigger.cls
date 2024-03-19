@isTest
public class TestPraticaManagementTrigger {
    Static testmethod void testTr(){
        test.startTest();
        Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        insert con;
        
        Account ac = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert ac;
        
        Pratica__c p = TestClassFroDataGenAffidamenti.getPratica(ac.Id);
        insert p;
        test.stopTest();
    }
}