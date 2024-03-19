/* ---------------------------------------------------------------------------------------------------------------------
Name:            PDFfromEmailTemplateCTRL.cls
Description:
Test class:

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
13-Jul-2020   0.1     Matteo                First Version
16-Sep-2022   0.2     C.Sanna & R.Kurti     Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class PDFfromEmailTemplateCTRL

{
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public string PDFBody { get; set; }
    public string subject { get; set; }
    public PDFfromEmailTemplateCTRL() {
        Id objectId = apexpages.currentpage().getparameters().get('objectId');
        String templateName = apexpages.currentpage().getparameters().get('templateName');
        System.debug(templateName + ' - ' + objectId);

        /*String userLanguage = UserInfo.getLanguage().substring(0,2);

        If(userLanguage.equals('en')) {
            templateName+= '_eng';
        }*/

        EmailTemplate template = [select Id from EmailTemplate where DeveloperName = :templateName WITH SECURITY_ENFORCED];

        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(template.id, UserInfo.getUserId(), objectId);

        subject = email.getSubject();
        System.debug(subject);
        PDFBody = email.gethtmlBody();

        System.debug('object is ' + objectId.getsobjecttype().getDescribe().getName());
        if (objectId.getSobjectType().getDescribe().getName() == 'CRABB_DEV__Pratica__c') {
            CRABB_DEV__Pratica__c p = [
                    SELECT CRABB_DEV__EC_Account__c, CRABB_DEV__EC_Pratica__c
                    FROM CRABB_DEV__Pratica__c
                    WHERE Id = :objectId
                    WITH SECURITY_ENFORCED
            ];
            System.debug('BODY 1:' + PDFBody);
            PDFBody = PDFBody.replace('[$CRABB_EC_Account]', p.CRABB_DEV__EC_Account__c);
            System.debug('BODY 2:' + PDFBody);
            PDFBody = PDFBody.replace('[$CRABB_EC_Pratica]', p.CRABB_DEV__EC_Pratica__c);
            System.debug('BODY 3:' + PDFBody);
        }
        if (objectId.getSobjectType().getDescribe().getName() == 'CRABB_DEV__Piano_di_Rientro__c') {
            PDFBody = PDFBody.replace('[$CRABB_PDR]', createRateTable(objectId));
        }
        System.debug(PDFBody);
    }

    private String createRateTable(Id pdrId) {
        String tableHtml = '';
        if (Utils.cebCheckObjPermission('CRABB_DEV__Rateizzazione__c', gd).get('ACCESS')) {
            List<Rateizzazione__c> rate = [
                    select toLabel(CRABB_DEV__Stato__c), CRABB_DEV__Data_Scadenza_Rata__c, CRABB_DEV__Importo_Rata__c
                    from Rateizzazione__c
                    where CRABB_DEV__Piano_di_Rientro__c = :pdrId
                    with SECURITY_ENFORCED
            ];
            Map<String, Schema.SObjectField> objectField = Schema.getGlobalDescribe().get('CRABB_DEV__Rateizzazione__c').getDescribe().fields.getMap();
            if (rate.size() > 0) {
                tableHtml += '<table width="50%" style="border:1px solid;" >';
                tableHtml += '<tr>';
                tableHtml += '<td style="border:1px solid;" ><b>' + objectField.get('CRABB_DEV__Stato__c').getDescribe().getLabel() + '</b></td>';
                tableHtml += '<td style="border:1px solid;" ><b>' + objectField.get('CRABB_DEV__Data_Scadenza_Rata__c').getDescribe().getLabel() + '</b></td>';
                tableHtml += '<td style="border:1px solid;" ><b>' + objectField.get('CRABB_DEV__Importo_Rata__c').getDescribe().getLabel() + '</b></td>';
                tableHtml += '</tr>';
                for (Rateizzazione__c r : rate) {
                    tableHtml += '<tr>';
                    tableHtml += '<td style="border:1px solid;" >' + r.CRABB_DEV__Stato__c + '</td>';
                    tableHtml += '<td style="border:1px solid;" >' + r.CRABB_DEV__Data_Scadenza_Rata__c.format() + '</td>';
                    tableHtml += '<td style="border:1px solid;" >' + r.CRABB_DEV__Importo_Rata__c + ' €</td>';
                    tableHtml += '</tr>';
                }
                tableHtml += '</table>';
            }
        }
        return tableHtml;
    }
}