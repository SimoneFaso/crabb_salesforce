/*
 * Creata da: Endrit Sinno
 * Desc: Classe di test per la classe batch MovSaldiBatch
 * data: 8/10/2014
 */

@isTest
public class TestMovSaldiBatch {
	
    static testmethod void testBatch(){
        test.startTest();
        MovSaldiBatch istanza = new MovSaldiBatch('Movimento__c');
        
        // crea dei movimenti test
        Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        insert con;
        Account ac = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert ac;
        Pratica__c p = TestClassFroDataGenAffidamenti.getPratica(ac.Id);
        insert p;
        
        Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Movimento__c.getRecordTypeInfosByName();
                
        List<Movimento__c> mov = new List<Movimento__c>();
        mov.add(new Movimento__c(recordtypeId= ctRecordTypes.get('SALDO MESE CONSOLIDATO').getRecordTypeID(), Calcola_SALDO_ANNO__c = true, Account__c = ac.id, Pratica__c = p.id, Data_Emissione__c = System.today(), data_scadenza__c = system.today()));
        mov.add(new Movimento__c(recordtypeId= ctRecordTypes.get('SALDO MESE CONSOLIDATO').getRecordTypeID(), Calcola_SALDO_ANNO__c = true, Account__c = ac.id, Pratica__c = p.id, Data_Emissione__c = System.today(), data_scadenza__c = system.today()));
                
        insert mov;
		
        Id process = Database.executeBatch(istanza);
        test.stopTest();
    }
}