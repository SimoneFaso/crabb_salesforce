@isTest
public class TestPDRHandler {
    
    // test afterInsert 
    public static testmethod void testAfterInsert(){
        
        //istanza
        PianiDiRientroHandler pdr = new PianiDiRientroHandler();
               
        
        Account acc = new Account();
        acc.name = 'Test';
        insert acc;
        
        // 1. Crea una pratica
        Pratica__c p = new Pratica__c();        
        p.account__c = acc.id;
        p.Stato__c = 'Bozza';
        insert p;
        
        // 2. Crea un PDR assocciato alla pratica
        Piano_di_Rientro__c piano = new Piano_di_Rientro__c();
        piano.Stato__c = 'Attivo';
        piano.Importo_Totale__c = 45;
        piano.pratica__c = p.id;
        insert piano;
        /*
        // 3. Translate in standart object and call method
        List<Piano_di_Rientro__c> listPdr = new list<Piano_di_Rientro__c>();
        listPdr.add(piano);
        List<SObject> soList = new List<SObject>();
        soList = (List<SObject>)listPdr;
        pdr.afterInsert(soList);*/
    }
    
    // test beforeUpdate()
    public static testmethod void testAfterUpdate(){
        
        //istanze
        PianiDiRientroHandler pdr = new PianiDiRientroHandler();
        // inserisci tag custom setting
        Tag__c t1 = new Tag__c();
        t1.Name = 'PDRStatodiChiusura';
        t1.ValueText__c = 'Chiuso';
        insert t1;
        Tag__c t2 = new Tag__c();
        t2.Name = 'PDRStatoPerPDRDisatteso';
        t2.ValueText__c = 'Disatteso';
        insert t2;
        
        test.startTest();
        // 1. Crea una pratica        
        Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        insert con;
        Account acc = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert acc;
                
        Pratica__c p = TestClassFroDataGenAffidamenti.getPratica(acc.Id);
        p.Stato__c = 'Bloccata';
        insert p;
        
        // 2. Crea un PDR assocciato alla pratica
        Piano_di_Rientro__c piano = new Piano_di_Rientro__c();
        piano.Importo_Totale__c = 45;
        //piano.pratica__c = String.valueOf(p.id).Substring(0, 14);
        piano.pratica__c = p.id;
        piano.Stato__c = 'Chiuso';
        insert piano;
                
        // 2.1 Modifica il PDR
        piano.Importo_Totale__c = 9999;
        update piano;
        
        pdr.afterUpdate(new List<SOBJect>{(Sobject)piano}, new List<SOBJect>{(Sobject)piano});
        
        Pratica__c tmp = [Select Stato__c From Pratica__c where id =: p.Id];
        System.debug('\n Stato Dal test: ' + tmp.stato__c);
        
        tmp.stato__c = 'Bloccata';
        update tmp; 
        
        pdr.afterUpdate(new List<SOBJect>{(Sobject)piano}, new List<SOBJect>{(Sobject)piano});
        System.debug('\n Stato Dopo test: ' + tmp.stato__c);
                
        test.stopTest();
        
    }
    
    // test del bulk before & after
    public static testmethod void testBulk(){
        
        //istanza
        PianiDiRientroHandler pdr = new PianiDiRientroHandler();
        
        pdr.bulkbefore();
        pdr.bulkAfter();
        pdr.bulkAfter(null);
        pdr.bulkAfter(null, null);
        pdr.bulkBefore(null);
        pdr.bulkBefore(null, null);
    }
    
    // before delete
    public static testmethod void testBeforeDelete(){
        
        //istanza
        PianiDiRientroHandler pdr = new PianiDiRientroHandler();
        
        pdr.beforeDelete(null);
    }
    
    // after delete
    public static testmethod void testafterDelete(){
        
        //istanza
        PianiDiRientroHandler pdr = new PianiDiRientroHandler();
        
        pdr.afterDelete(null);
                
    }
    
    // test finally
    public static testmethod void testfinally(){
        
        //istanza
        PianiDiRientroHandler pdr = new PianiDiRientroHandler();
        
        pdr.andFinally();
                
    }
    
    // before insert
    public static testmethod void testBeforeInsert(){
        
        //istanza
        PianiDiRientroHandler pdr = new PianiDiRientroHandler();
        pdr.beforeInsert(null);
        
                
    }
    
    // before update 
    public static testmethod void testbeforeUpdate(){
        
        //istanza
        PianiDiRientroHandler pdr = new PianiDiRientroHandler();
        
        pdr.beforeUpdate(null, null);
                
    }
    /*
    // test tasksForDaElaborare
    public static testmethod void testtasksForDaElaborare(){
        
        //istanza
        PianiDiRientroHandler pdr = new PianiDiRientroHandler();
        
        pdr.tasksForDaElaborare(null, null);
                
    }*/
}