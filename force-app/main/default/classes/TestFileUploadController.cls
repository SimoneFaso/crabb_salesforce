/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestFileUploadController.cls
Description:     Test class for code coverage of FileEsitiUploadController and FileUploadController


Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
08-Oct-2021  0.2      Claudio Sanna                   Modified for coverage (Security Review)
----------------------------------------------------------------------------------------------------------------------*/
@isTest
private class TestFileUploadController {
	
    public static Pratica__c getTestPratica(){
        Pratica__c p = new Pratica__c();
        p.Anzianit_Pratica__c=system.today();
        p.Check_In_Lavorazione__c=false;
        p.Data_inizio_scaduto__c=system.today();
        p.Esci_e_chiudi__c=false;
        p.Fascia_di_rischio__c='1234';
        p.Importo_Incasso_Consolidato__c=0;
        p.Nome_Collector_Attivo__c='XXX';
        p.Request__c='Request XXX';
        p.Importo_saldo_Consolidato__c=0;
        p.Importo_Spese_Consolidato__c=0;
        p.Importo_Scaduto_Consolidato__c=0;
        p.Scaduto_Spese__c=0;
        p.Scaduto_Spese_Consolidato__c=0;
        p.Stato__c='Bozza';
        p.ownerid=userinfo.getuserid();
        return p;
    }

    static testMethod void UnitTest1() {
        
        FileUploadController fuc = new FileUploadController();
        Pratica__c TestPrat = getTestPratica();
        insert TestPrat;
        
        test.startTest();
    	
    	String AttId = FileUploadController.attachBlob(TestPrat.Id, '', 'test.doc', 'text', 'ciao');
    	String AttId2 = FileUploadController.attachBlob(TestPrat.Id, AttId, 'test.doc', 'text', 'ciao');
        String AttId3 = FileEsitiUploadController.attachBlob(TestPrat.Id, '', 'test.doc', 'text', 'ciao');
    	String AttId4 = FileEsitiUploadController.attachBlob(TestPrat.Id, AttId3, 'test.doc', 'text', 'ciao');
    	
    	test.stopTest();
    }
}