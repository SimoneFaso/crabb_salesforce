/*----------------------------------------------------------------------------------------------------------
Name:            TestGestione_Note.cls
Description:     Test Class for Code Coverage of Gestione_Note.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
27-Aug-2021  0.2      Claudio Sanna                   Modified and added cebCheckObjPermission and cebCheckFLSPermission
                                                      (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

@isTest
public class TestGestione_Note {
	
    static testmethod void firstUnitTest(){
        
        // crea una pratica
        Contratto__c con = TestClassFroDataGEnAffidamenti.getContratto();
        insert con;
        Account acc = TestClassFroDataGEnAffidamenti.getAccount(con.Id);
        insert acc;
        
        Pratica__c p = TestClassFroDataGEnAffidamenti.getPratica(acc.Id);
        insert p;
        // crea una nota alegata alla pratica
         Nota__c n = new Nota__c();
        n.Pratica__c = p.id;
        n.Current_Note__c = 2;
        insert n;
        
        // crea l'custom setting
        Max_Note__c m = new Max_Note__c();
        m.Max_Note__c = 2.0;
        m.Name = 'Max';
        insert m;
        
        test.startTest();
        Gestione_Note.queryNote(p.id);
        
        // test insert note
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Nota__c;
        Map<String,Schema.RecordTypeInfo> NotaRTInfo = cfrSchema.getRecordTypeInfosByDeveloperName();
        Id rtId = NotaRTInfo.get('Visibile_Internamente').getRecordTypeId();
        m.Max_Note__c = 1.0;
        update m;
        Gestione_Note.insertNote(p.id, 'Nota', 'User', rtId, System.now());
        test.stopTest();
    }
}