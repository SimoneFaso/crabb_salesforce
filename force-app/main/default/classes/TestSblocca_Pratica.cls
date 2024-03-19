@isTest
public class TestSblocca_Pratica {
	static testmethod void testTrig(){
        // 1. cra PDR
        
        // inserisci tag custom setting
        Tag__c t1 = new Tag__c();
        t1.Name = 'PDRStatodiChiusura';
        t1.ValueText__c = 'Chiuso';
        insert t1;
        Tag__c t2 = new Tag__c();
        t2.Name = 'PDRStatoPerPDRDisatteso';
        t2.ValueText__c = 'Disatteso';
        insert t2;
        
        
        // 2. Assegna pratiche al pdr
        test.startTest();
        Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        insert con;
        
        Account ac = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert ac;
        
        Pratica__c p = TestClassFroDataGenAffidamenti.getPratica(ac.Id);
        p.Stato__c = 'Da elaborare';
        insert p;
        
        Piano_di_Rientro__c pdr = new Piano_di_Rientro__c();
        pdr.Stato__c = 'Attivo';
        pdr.Pratica__c = p.id;
        pdr.Importo_Totale__c = 123;
        insert pdr;
                    
        pdr.Data_Stipula_Piano__c = system.today();
        pdr.Stato__c = 'Chiuso';
        System.assertEquals('Da elaborare', p.Stato__c);
        update pdr;
            
        test.stopTest();
    
    }
}