/*
 * Created by: Endrit Sino
 * Desc: Classe di test per il handler del Collector e Contatti
 * data: 7/10/2014
 */
 
@isTest
public class TestCollectorHandler {
    
    static testmethod void testCollectorHandler(){
        test.startTest();
        // test tiny empty methods
        CollectorHandler  istanza = new CollectorHandler();
        List<SObject> myObj = new List<SObject>();
        istanza.bulkAfter(myObj, myObj);
        istanza.bulkBefore(myObj, myObj);
        istanza.beforeDelete(myObj);
        istanza.afterDelete(myObj);
        istanza.bulkAfter();
        istanza.bulkBefore();
        istanza.bulkAfter(myObj);
        istanza.bulkBefore(myObj);
        istanza.beforeInsert(new List<Collector__c>());
        istanza.andFinally();
        
        // test l'insert di un record collector
        User u = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');
        
        Collector__c col = TestClassFroDataGenAffidamenti.getCollector(u.id);
        insert col;
        
        col.CAP__c = 'modifica';
        update col;
        test.stopTest();
    }
    
    static testmethod void testBeforeUpdate(){
        test.startTest();
        // crea un collector
        Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        insert con;
        Account acc = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert acc;
        User u = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');
        //User u = [Select id, ProfileId, UserRoleId, username, profile.name From User Where profile.name = 'CRABB ADR' limit 1];
        
        // 1. crea col
        Collector__c col = TestClassFroDataGenAffidamenti.getCollector(u.id);        
        insert col;
        
            
        // prendi il nome del collect
        Collector__c tmp = [Select name from Collector__c Where id =: col.id ]; 
        System.assertNotEquals(null, tmp.Name);
        
        // 2. inserisci pratica
        Pratica__c p = TestClassFroDataGenAffidamenti.getPratica(acc.Id);
        p.Nome_Collector_Attivo__c = tmp.name;
        insert p;
        
        List<SObject> oldL = new List<SObject>{(SObject)col};
        
        // ricorda il collect con il vecchio e nuovo  assegnatario
        User u1 = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');
        //User u1 = [Select id, ProfileId, UserRoleId From User Where Profile.name = 'CRABB ADR' limit 1];
        
        //  3. crea AccountShare(AccountId = acc.id) e praticaShare(ParentId = pratica.id)
        AccountShare acSh = TestClassFroDataGenAffidamenti.getAccountShare(acc.id, u1.id);
        acsh.RowCause = Utils.NAMESPACE+'Manual';
        
        // ESino, 30/6/2016: Test Class Fix
        //insert acsh;
        
        Pratica__Share pSh = TestClassFroDataGenAffidamenti.getPraticaShare(p.id, u1.id);
        insert psh;
        
        // 4. Fire beforeUpdate(): update collector
        col.User__c = u1.id;
        update col;
        List<SObject> newL = new List<SObject>{(SObject)col};
               
        //CollectorHandler  istanza = new CollectorHandler();
        //istanza.beforeUpdate(oldL, newl);
        test.stopTest();
    }
    
    // TestAfter Update: 1o scenario
    static testmethod void testafterUpdate(){
        User u = TestClassFroDataGenAffidamenti.getUser('CRABB Credit Manager');
        
        Collector__c col = TestClassFroDataGenAffidamenti.getCollector(u.id);        
        insert col;        
        List<Collector__c> oldL = new List<Collector__c>{col};
        List<Collector__c> L = new List<Collector__c>{col};
        
        test.startTest();
        CollectorHandler  istanza = new CollectorHandler();
        istanza.afterUpdate(oldL, L);
        
        Collector__c col1 = TestClassFroDataGenAffidamenti.getCollector(u.id);        
        insert col1;
        
        Collector__Share  cSh = new Collector__Share();
        cSh.RowCause = Utils.NAMESPACE+'Collector__c';
        csh.ParentId = col.id;
        csh.AccessLevel = 'Read';
        csh.UserOrGroupId = u.id;
        insert cSh;
        l.clear();
        l.add( col1);
        istanza.afterUpdate(oldL, L);
        
        Delete([Select id From Collector__Share where rowcause = 'Collector__c']);
        istanza.afterUpdate(oldL, L);
        
        test.stopTest();
    
    }
    
    // TestAfterUpdate: 2o scenario
    static testmethod void testAfterUpdate2(){
        User u = TestClassFroDataGenAffidamenti.getUser('CRABB Credit Manager');
        
        Collector__c col = TestClassFroDataGenAffidamenti.getCollector(u.id);        
        insert col;      
        List<Collector__c> oldL = new List<Collector__c>{col};
        List<Collector__c> L = new List<Collector__c>{col};
        
        // crea un collector_share
        Collector__c col1 = TestClassFroDataGenAffidamenti.getCollector(u.id);        
        insert col1;
        User u1 = TestClassFroDataGenAffidamenti.getUser('CRABB Operatore Credito');
        
        Collector__Share  cSh = new Collector__Share();
        cSh.RowCause = Utils.NAMESPACE+'Collector__c';
        csh.ParentId = col1.id;
        csh.AccessLevel = 'Read';
        csh.UserOrGroupId = u1.id;
        insert cSh;
                    
        test.startTest();
        CollectorHandler  istanza = new CollectorHandler();
        istanza.afterUpdate(oldL, L);
        
        test.stopTest();
    }
}