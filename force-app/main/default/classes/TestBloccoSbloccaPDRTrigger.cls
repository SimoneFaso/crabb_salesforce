@isTest
public class TestBloccoSbloccaPDRTrigger {
    static testmethod void testTrig(){
        test.startTest();
        Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        insert con;
        
        Account ac = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert ac;
        
        Pratica__c p = TestClassFroDataGenAffidamenti.getPratica(ac.Id);
        insert p;
        
        Piano_di_Rientro__c pdr = new Piano_di_Rientro__c();
        pdr.Stato__c = 'Attivo';
        pdr.Pratica__c = p.id;
        pdr.Importo_Totale__c = 123;
        insert pdr;

        test.stopTest();
    }
}