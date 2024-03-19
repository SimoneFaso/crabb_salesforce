/* ---------------------------------------------------------------------------------------------------------------------
Name:            PDFDetailPdfCtrl.cls
Description:
Test class:

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
11-Jun-2022   0.1     Matteo                First Version
16-Sep-2022   0.2     C.Sanna & R.Kurti    Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class PDFDetailPdfCtrl {

    public Piano_di_Rientro__c pdr { get; set; }
    public List<Rateizzazione__c> rate { get; set; }
    public String filePath { get; set; }
    public PDFDetailPdfCtrl() {
        Id pdrId = apexpages.currentpage().getparameters().get('pdrId');
        pdr = [
                select id, name, Data_Stipula_Piano__c, Pratica__r.Name, Importo_Totale__c,
                        Interessi_di_Dilazione__c, Interessi_di_Mora__c, Calcola_Interessi__c
                from Piano_di_Rientro__c
                where Id = :pdrId
                WITH SECURITY_ENFORCED
                limit 1
        ];
        RATE = [
                select id, Data_Scadenza_Rata__c, Importo_Rata__c, Stato__c
                from Rateizzazione__c
                WHERE Piano_di_Rientro__c = :pdr.Id
                WITH SECURITY_ENFORCED
                order by Data_Scadenza_Rata__c ASC
        ];
        List<Document> docList = [SELECT Id FROM Document WHERE Name = 'ECLogo' WITH SECURITY_ENFORCED LIMIT 1];
        filePath = '';
        if (docList != null && docList.size() > 0) {
            filePath = '/servlet/servlet.FileDownload?file=' + docList[0].Id;
        }
    }

}