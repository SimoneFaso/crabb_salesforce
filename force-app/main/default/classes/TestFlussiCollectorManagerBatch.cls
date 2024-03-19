/*
 * Creata da: Endrit Sino
 * desc: Test il batch con le due casisitiche
 * data: 10/10/2014
 */
@isTest
public class TestFlussiCollectorManagerBatch {
    
    static testmethod void testBatchForLotto(){
        
        // User => Collector => Lotto
        
        User u = TestClassFroDataGenAffidamenti.getUser('CRABB Credit Manager');
        Collector__c c = TestClassFroDataGenAffidamenti.getCollector(u.id);
        c.stato__c = 'Attivo';
        insert c;
        Lotto__c l = TestClassFroDataGenAffidamenti.getLotto(c.id);
        insert l;
        
        test.startTest();
        
        FLussiCollectorManagerBatch istanza2 = new FLussiCollectorManagerBatch('NuovoLottoAffidato');
        Id batchid = Database.executeBatch(istanza2);
        
        
        
        FLussiCollectorManagerBatch istanza4 = new FLussiCollectorManagerBatch('MovimentiSaldi');        
        batchid = Database.executeBatch(istanza4);
        
        FLussiCollectorManagerBatch istanza5 = new FLussiCollectorManagerBatch('AggiornamentoRevoche');        
        batchid = Database.executeBatch(istanza5);
        
        test.stopTest();
        
    }
    /*
    static testmethod void testScopeMaggiore1(){
        // User => Collector => Lotto
        
        User u = TestClassFroDataGenAffidamenti.getUser('mlml');
        Collector__c c = TestClassFroDataGenAffidamenti.getCollector(u.id);
        c.stato__c = 'Attivo';
        insert c;
        Lotto__c l = TestClassFroDataGenAffidamenti.getLotto(c.id);
        insert l;
        
        Lotto__c l1 = TestClassFroDataGenAffidamenti.getLotto(c.id);
        insert l1;
        
        test.startTest();
        FLussiCollectorManagerBatch istanza2 = new FLussiCollectorManagerBatch('NuovoLottoAffidato');
        Id batchid = Database.executeBatch(istanza2);
        test.stopTest();
    }*/
    
    static testmethod void testAggioAnagraf(){
         User u = TestClassFroDataGenAffidamenti.getUser('CRABB Credit Manager');
       // u = [Select Username, id From User where profile.name= 'CRABB Credit Manager' limit 1];
        
        Collector__c c = TestClassFroDataGenAffidamenti.getCollector(u.id);
        c.stato__c = 'Attivo';
        insert c;
        
        test.startTest();
        FLussiCollectorManagerBatch istanza3 = new FLussiCollectorManagerBatch('AggiornamentoAnagrafico');        
        id batchid = Database.executeBatch(istanza3, 1);
        
        test.stopTest();
    }
}