@isTest
public class TestBlocca_PraticaTrigger {
    static testmethod void testTrig(){
        // 1. cra PDR
        // 2. Assegna pratiche al pdr
        test.startTest();
        Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        insert con;
        
        Account ac = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert ac;
        
        Pratica__c p = TestClassFroDataGenAffidamenti.getPratica(ac.Id);
        insert p;
        
        Account ac1 = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert ac1;
        
        Pratica__c p1 = TestClassFroDataGenAffidamenti.getPratica(ac1.Id);
        insert p1;
        
        Piano_di_Rientro__c pdr = new Piano_di_Rientro__c();
        pdr.Stato__c = 'Attivo';
        pdr.Pratica__c = p.id;
        pdr.Importo_Totale__c = 123;
        insert pdr;
        
        Piano_di_Rientro__c pdr1 = new Piano_di_Rientro__c();
        pdr1.Stato__c = 'Attivo';
        pdr1.Pratica__c = p1.id;
        pdr1.Importo_Totale__c = 123;
        insert pdr1;        
        
        test.stopTest();
    }
}