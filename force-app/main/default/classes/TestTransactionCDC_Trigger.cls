@isTest 
public class TestTransactionCDC_Trigger
{
    static testmethod void TestTransactionCDC()
    {
        ListOfFields__c testLof = new ListOfFields__c(Name='Pdf_01',Field__c='RecordType.Name',Field_Label__c='Record Type',Show__c=true,Object__c='Movimento__c');
        insert testLof;
        
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
        
        
        Test.enableChangeDataCapture();
        
        insert movFatt;
        
        Test.getEventBus().deliver();
        
        List<Movimento__c> movFattUpd = new List<Movimento__c>();
        for(Movimento__c m : movFatt)
        {
            m.Sollecitabile__c = true;
            m.Residuo__c = 10;
            movFattUpd.add(m);
        }
        
        update movFattUpd;
        
        Test.getEventBus().deliver();
        
        List<Movimento__c> movFattUpdNeg = new List<Movimento__c>();
        for(Movimento__c m : movFattUpd)
        {
            m.Sollecitabile__c = true;
            m.Residuo__c = -10;
            movFattUpdNeg.add(m);
        }
        
        update movFattUpdNeg;
 
        Test.getEventBus().deliver();       
    }
}