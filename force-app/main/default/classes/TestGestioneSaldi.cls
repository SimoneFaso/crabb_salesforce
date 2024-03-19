/*
 * Created by: Endrit Sino
 * Desc: Classe di test per la classe del gestione Saldo Anno
 * Data: 30/9/2014
 * 
 */
@isTest
public class TestGestioneSaldi {
    
    // Req Fields: Account__c, Pratica__c, Data_Emissione__c, Data_Scadenza__c
    static testmethod void testExec(){
        test.startTest();
        // istanza
       /* GestioneSaldi istanza = new GestioneSaldi();
        
        // Crea Acct & Prat
        Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        insert con;        
        Account act = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert act;
        Pratica__c p = TestClassFroDataGenAffidamenti.getPratica(act.Id);
        insert p;
        
        // crea mov 
        List<Movimento__c> tmpList = new List<Movimento__c>();
        Movimento__c m = new Movimento__c();
        // req Fields:
        m.Data_Emissione__c = System.today();
        m.Data_Scadenza__c = System.today();
        m.Account__c = act.id;
        m.Pratica__c = p.id;
        Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Movimento__c.getRecordTypeInfosByName();          
        m.RecordTypeId = ctRecordTypes.get('FATTURE').getRecordTypeID();
        //Sbianco i campi indicizzati  del record SALDO ANNNO
        for(integer i=1; i<=31;i++){
                m.put('Data_Integrazione_'+i+'__c',System.today());
                m.put('Data_Saldo_'+i+'__c',System.today());
                m.put('Importo_Saldo_'+i+'__c',null);
                m.put('Saldo_Spese_'+i+'__c',null);
                m.put('Scaduto_Saldo_'+i+'__c',null);
                m.put('Tipo_Movimento_SWH_'+i+'__c',null);
                m.put('Write_Off_'+i+'__c',false);
        }
        insert m;
        tmpList.add(m);
        istanza.executeSaldiLogic(tmpList);
        */
        test.stopTest();
    }
}