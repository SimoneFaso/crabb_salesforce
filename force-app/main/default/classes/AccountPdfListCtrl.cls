/* ---------------------------------------------------------------------------------------------------------------------
Name:            AccountPdfListCtrl
Description:
Test class:     

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
01-Jul-2021  0.1                                      First Version
07-Sep-2022  0.2      R. Kurti & C. Sanna             Modified for adding check permission:
                                                      cebCheckFLSPermission/cebCheckObjPermission/WITH SECURITY_ENFORCED (Security Review)
10-Oct-2022  0.3      R.Kurti & C.Sanna               Removed WITH SECURITY ENFORCED
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class AccountPdfListCtrl implements IWebComponentCtrl {
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    public Object callApexMethod(Map<String, Object> params) {
        String accountId = (String) params.get('accountId');
        List<AccountPdfListCtrl.PdfDocument> documentList = new List<AccountPdfListCtrl.PdfDocument>();
        Map<Id, CRABB_DEV__Pratica__c> accountDossiers = new
                Map<Id, CRABB_DEV__Pratica__c>([select id, Name from CRABB_DEV__Pratica__c where CRABB_DEV__Account__c = :accountId]);
        //List<ContentDocumentLink> documents = [SELECT id , LinkedEntityId , ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :accountDossiers.keySet()];
        List<ContentDocumentLink> documents = [select id, LinkedEntityId, ContentDocumentId from ContentDocumentLink where LinkedEntityId in :accountDossiers.keySet() WITH SECURITY_ENFORCED];
        for (ContentDocumentLink cdl : documents) {
            PdfDocument document = new PdfDocument();
            document.dossierName = accountDossiers.get(cdl.LinkedEntityId).Name;
            document.pdfId = cdl.ContentDocumentId;
            documentList.add(document);
        }
        return documentList;
    }

    public class PdfDocument {
        @AuraEnabled
        public String dossierName { get; set; }
        @AuraEnabled
        public String pdfId { get; set; }
    }
}