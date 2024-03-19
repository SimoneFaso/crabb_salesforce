/* -----------------------------------------------------------------------------------------------------------
Name:            TestQueueableCalcoloEstrattoContoPratica.cls
Description:     Test class for code coverage of QueueableCalcoloEstrattoContoPratica.cls

Date         Version  Author             Summary of Changes
-----------  -------  -----------------  -----------------------------------------------------------------
             0.1      Balance            First Version
15-Dec-2021  0.2      C. Sanna           Modified for code coverage
---------------------------------------------------------------------------------------------------------- */


@isTest(seealldata = false)
public class TestQueueableCalcoloEstrattoContoPratica {

      static testmethod void testMethod1(){

        ListOfFields__c testLof = new ListOfFields__c(Name='Pdf_0000001',Field__c='Id',Field_Label__c='Id',Show__c=true,Object__c='Movimento__c');
        insert testLof;

        test.startTest();
        Movimento__c m = new Movimento__c();
  		Contratto__c con = TestClassFroDataGEnAffidamenti.getContratto();
        Database.insert(con, false);
        Account ac = TestClassFroDataGEnAffidamenti.getAccount(con.Id);
        insert ac;
        Pratica__c p = TestClassFroDataGEnAffidamenti.getPratica(ac.Id);
        //p.Stato__c = 'Da Elaborare';
        p.Stato__c = 'In lavorazione';
        insert p;
        
        m.Data_Emissione__c = System.today()-10;
        m.Data_Scadenza__c = System.today()-9;
        m.Pratica__c = p.id;
        m.Account__c = ac.id;
        m.Importo__c = 100;
        m.Residuo__c = 100;
        m.Check_Scadenza__c = true;  
        m.Sollecitabile__c = true;
        m.Tipo_Scadenza__c= 'Scaduto';
        Id idrt =  Schema.SObjectType.Movimento__c.getRecordTypeInfosByDeveloperName().get('Fatture').getRecordTypeId();
        m.RecordTypeId = idrt;
        insert m;
        test.stoptest();
      }
}