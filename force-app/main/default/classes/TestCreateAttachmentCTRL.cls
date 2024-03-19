@isTest
private class TestCreateAttachmentCTRL {
	
	@isTest static void test_method_one() {
		Test.startTest();

		Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        insert con;
        
        Account ac = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert ac;
        
        Pratica__c p = TestClassFroDataGenAffidamenti.getPratica(ac.Id);
        insert p;
        
        Movimento__c  m =  new movimento__c();
        m.Account__c = ac.id;
        m.Pratica__c = p.id;
        m.Data_Emissione__c = System.today();
		m.Data_Scadenza__c = system.today();
		Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Movimento__c.getRecordTypeInfosByName();
        m.RecordTypeId = ctRecordTypes.get('FATTURE').getRecordTypeID();    
        insert m;

		CreateAttachmentCTRL ctrl = new CreateAttachmentCTRL();
		CreateAttachmentCTRL.createAttachment(p.Id);

		Test.stopTest();
	}
	
}