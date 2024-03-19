@isTest
public class TestUpdateResiduoFatture {
  
    static testmethod void UpdateResiduoFatture(){
        
        MovSaldiBatch istanza = new MovSaldiBatch('Movimento__c');
        
        // crea una pratica
        Contratto__c con = TestClassFroDataGEnAffidamenti.getContratto();
        insert con;
        Account acc = TestClassFroDataGEnAffidamenti.getAccount(con.Id);
        insert acc;
        
        Pratica__c p = TestClassFroDataGEnAffidamenti.getPratica(acc.Id);
        insert p;
        
        Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Movimento__c.getRecordTypeInfosByName();
                
        List<Movimento__c> movFatt = new List<Movimento__c>();
        movFatt.add(new Movimento__c(recordtypeId= ctRecordTypes.get('FATTURE').getRecordTypeID(), Account__c = acc.id, Pratica__c = p.id, Data_Emissione__c = System.today(), data_scadenza__c = system.today(),Id_Movimento_Ext__c = 'TEST001',IdentificativoFatturaExt__c='TEST001'));
        movFatt.add(new Movimento__c(recordtypeId= ctRecordTypes.get('FATTURE').getRecordTypeID(), Account__c = acc.id, Pratica__c = p.id, Data_Emissione__c = System.today(), data_scadenza__c = system.today(),Id_Movimento_Ext__c = 'TEST002',IdentificativoFatturaExt__c='TEST002'));
                        
        insert movFatt;
        
        Id process = Database.executeBatch(istanza);
        
        
        //Creazione della fattura
        //...
        
        
        test.startTest();
        //Creazione Incasso
        //...

        List<Movimento__c> movInc = new List<Movimento__c>();
        movInc.add(new Movimento__c(recordtypeId= ctRecordTypes.get('INCASSO').getRecordTypeID(), Account__c = acc.id, Pratica__c = p.id, Data_Emissione__c = System.today(), data_scadenza__c = system.today(),Id_Movimento_Ext__c = 'INCTEST001',IdentificativoFatturaExt__c='TEST001'));
        movInc.add(new Movimento__c(recordtypeId= ctRecordTypes.get('INCASSO').getRecordTypeID(), Account__c = acc.id, Pratica__c = p.id, Data_Emissione__c = System.today(), data_scadenza__c = system.today(),Id_Movimento_Ext__c = 'INCTEST002',IdentificativoFatturaExt__c='TEST002'));
        
        insert movInc;
        
        test.stopTest();
    }
}