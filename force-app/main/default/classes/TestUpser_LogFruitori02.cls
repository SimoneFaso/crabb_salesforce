/*
 * Creata da: Endrit Sino
 * Desc: /Test/
 * data:8/10/2014
 */ 
@isTest
public class TestUpser_LogFruitori02 {
    static testmethod void testUpsertLog(){
        test.startTest();
        // 1.Crea un log(id)
        // 2.DateTime DataInizio
        // 3.Compila error string/int value
        // 4.Create map<integer, Servizio_Item__c>
        // 5.Create map<Integer, String> NewMapException
        Log__c l = new Log__c();
        l.Class_Name__c = 'Test';
        insert l;
        
        DateTime dataInizio = System.now();
        
        Map<Integer, String> er = new Map<Integer, String>();
        er.put(1, 'KOvalue');
        er.put(2, 'KO3valueopopop');
        
        // crea due Servizi_Item__c
        Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        insert con;
        
        Account ac1 = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert ac1;
        
        Servizio__c s = new Servizio__c();
        s.Account__c = ac1.id;
        insert s;
        
        Servizi_Item__c f = new Servizi_Item__c();
        f.Servizio__c = s.id;
                
        insert f;
        
        Map<Integer, Servizi_Item__c> mapF = new Map<Integer, Servizi_Item__c>();
        mapf.put(1, f);
        // exception map
        Map<integer, String> exc = new Map<integer, String>();
        exc.put(1, 'Excp 1');
        exc.put(2, 'Excp 2');
        
        Upsert_LogFruitori02.UpsertFruitore(l.id, DataInizio, er, mapf , exc);
        
        test.stopTest();
    }
}