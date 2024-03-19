/* ---------------------------------------------------------------------------------------------------------------------
Name:            CreateAttachmentCTRL.cls
Description:
Test class:      TestCreateAttachmentCTRL.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
              0.1                                      First Version
13-Sep-2022   0.2      R.Kurti & C.Sanna               Added WITH SECURITY ENFORCED, added cebCheckObj (security review)
----------------------------------------------------------------------------------------------------------------------*/
public without sharing class CreateAttachmentCTRL {
    Public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public CreateAttachmentCTRL() {
    }

    @AuraEnabled
    public static String callCreateAttachment(string parentId) {
        try {
            createAttachment(parentId);
            return (Label.CRABB_DEV.ECmessage);
        } catch (Exception e) {
            return (e.getMessage());
        }
    }

    public static void createAttachment(String parentId) {
        if(Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS')
        && Utils.cebCheckFLSPermission('Pratica__c','Account_Name__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c','Name',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c','Servizio_Fornitura__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c','Account__c',gd).get('ACCESS')) {
            Pratica__c currentPratica = [
                    SELECT Id, Account_Name__c, Name, Servizio_Fornitura__r.Name, Account__c
                    FROM Pratica__c
                    WHERE Id = :parentId
                    //WITH SECURITY_ENFORCED
            ];
            Id parent = currentPratica.Account__c;
            if(Utils.cebCheckObjPermission('Account',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Account','Name',gd).get('ACCESS')){
            Account currentAccount = [SELECT Id, Name FROM Account WHERE Id = :parent WITH SECURITY_ENFORCED];
            //Account currentAccount = [SELECT Id, Name FROM Account WHERE Id = :parent WITH SECURITY_ENFORCED];
            PageReference pdf = Page.EstrattoContoPage;
            PageReference pdfECAccount = Page.EstrattoContoAccountPage;
            /*PageReference excel = Page.ExcelExport;*/

            pdf.getParameters().put('id', parentId);
            pdfECAccount.getParameters().put('id', parentId);
            /*excel.getParameters().put('id',parentId);*/

            Blob bodyPdf;
            Blob bodyAccountPdf;
            /*Blob bodyExcel;*/
            try {
                if (Test.IsRunningTest()) {
                    bodyPdf = Blob.valueOf('UNIT.TEST');
                    bodyAccountPdf = Blob.valueOf('UNIT.TEST');
                    /*bodyExcel = Blob.valueOf('UNIT.TEST');*/
                } else {
                    bodyPdf = pdf.getContent();
                    bodyAccountPdf = pdfECAccount.getContent();
                    /*bodyExcel = excel.getContent();*/
                }

                String filename = 'EC_';
                filename += (String.isNotBlank(currentPratica.Account_Name__c)) ? currentPratica.Account_Name__c : '';
                filename += (String.isNotBlank(currentPratica.Name)) ? '_' + currentPratica.Name : '';
                filename += (String.isNotBlank(currentPratica.Servizio_Fornitura__r.Name)) ? '_' + currentPratica.Servizio_Fornitura__r.Name : '';
                String checkFilename = filename + '_' + String.valueOf(Date.today()) + '.pdf';

                String filenameECAccount = 'EC_';
                filenameECAccount += (String.isNotBlank(currentAccount.Name)) ? currentAccount.Name : '';
                String checkFilenameAccount = filenameECAccount + '_' + String.valueOf(Date.today()) + '.pdf';

                /*if( Utils.CheckObjPermission('Attachment').get('ACCESS') &&
                    Utils.checkFLSPermission('Attachment', 'Body').get('ACCESS') &&
                    Utils.checkFLSPermission('Attachment', 'IsPrivate').get('ACCESS') &&
                    Utils.checkFLSPermission('Attachment', 'ParentId').get('ACCESS') &&
                    Utils.checkFLSPermission('Attachment', 'Name').get('ACCESS') ) {*/
                if( Utils.cebCheckObjPermission('Attachment',gd).get('ACCESS') &&
                        Utils.cebCheckFLSPermission('Attachment', 'Body',gd).get('ACCESS') &&
                        Utils.cebCheckFLSPermission('Attachment', 'IsPrivate',gd).get('ACCESS') &&
                        Utils.cebCheckFLSPermission('Attachment', 'ParentId',gd).get('ACCESS') &&
                        Utils.cebCheckFLSPermission('Attachment', 'Name',gd).get('ACCESS') ) {

                    List<Attachment> oldAtt = [SELECT Id, Body, IsPrivate, ParentId, Name FROM Attachment WHERE Name LIKE :checkFilename OR ParentId = :currentPratica.Id];
                    /*List<Attachment> oldAtt = [
                        SELECT Id, Body, IsPrivate, ParentId, Name
                        FROM Attachment
                        WHERE Name = :checkFilename
                        WITH SECURITY_ENFORCED
                ];*/
                List<Attachment> oldECAtt = [
                        SELECT Id, Body, IsPrivate, ParentId, Name
                        FROM Attachment
                        WHERE Name = :checkFilenameAccount
                        //WITH SECURITY_ENFORCED
                ];

                    String filenamePdf = filename + '_' + String.valueOf(Date.today()) + '.pdf';
                    String filenameAccountPdf = filenameECAccount + '_' + String.valueOf(Date.today()) + '.pdf';
                    /*String filenameExcel = filename + '_' + String.valueOf(Date.today()) + '.xls';*/

                    List<Attachment> attList = new List<Attachment>();
                    List<Attachment> attECAccountList = new List<Attachment>();

                    if (oldAtt == null || oldAtt.size() == 0 || oldAtt.isEmpty()) {
                        Attachment attachPdf = new Attachment();
                        attachPdf.IsPrivate = false;
                        attachPdf.ParentId = parent;
                        attachPdf.Body = bodyPdf;
                        attachPdf.Name = filenamePdf;

                        /*Attachment attachExcel = new Attachment();
                    attachExcel.IsPrivate = false;
                    attachExcel.ParentId = parent;
                    attachExcel.Body = bodyExcel;
                    attachExcel.Name = filenameExcel;*/

                        attList.add(attachPdf);
                        /*attList.add(attachExcel);*/
                        if (Utils.cebCheckObjPermission('Attachment', gd).get('INSERT')
                                && Utils.cebCheckFLSPermission('Attachment', 'Body', gd).get('INSERT')
                                && Utils.cebCheckFLSPermission('Attachment', 'IsPrivate', gd).get('INSERT')
                                && Utils.cebCheckFLSPermission('Attachment', 'ParentId', gd).get('INSERT')) {
                            Database.insert(attList);
                        }
                        //Database.insert(attList);
                    } else {

                        for (Attachment at : oldAtt) {

                            /*if( at.Name.endsWith('.pdf') ){*/
                            at.Body = bodyPdf;
                            at.Name = filenamePdf;
                            /*}else if( at.Name.endsWith('.xls') ){
                            at.Body = bodyExcel;
                            at.Name = filenameExcel;
                        }*/

                        }
                        if (Utils.cebCheckObjPermission('Attachment', gd).get('UPSERT')
                                && Utils.cebCheckFLSPermission('Attachment', 'Body', gd).get('UPSERT')) {
                            Database.upsert(oldAtt);
                        }
                        //Database.upsert(oldAtt);

                    }

                    if (oldECAtt == null || oldECAtt.size() == 0 || oldECAtt.isEmpty()) {
                        Attachment attachECAccountPdf = new Attachment();
                        attachECAccountPdf.IsPrivate = false;
                        attachECAccountPdf.ParentId = parent;
                        attachECAccountPdf.Body = bodyAccountPdf;
                        attachECAccountPdf.Name = filenameAccountPdf;

                        attECAccountList.add(attachECAccountPdf);

                        if (Utils.cebCheckObjPermission('Attachment', gd).get('INSERT')
                                && Utils.cebCheckFLSPermission('Attachment', 'Body', gd).get('INSERT')
                                && Utils.cebCheckFLSPermission('Attachment', 'IsPrivate', gd).get('INSERT')
                                && Utils.cebCheckFLSPermission('Attachment', 'ParentId', gd).get('INSERT')) {
                            Database.insert(attECAccountList);
                        }
                        //Database.insert(attECAccountList);
                    } else {

                        for (Attachment at : oldECAtt) {
                            at.Body = bodyAccountPdf;
                            at.Name = filenameAccountPdf;
                        }
                        if (Utils.cebCheckObjPermission('Attachment', gd).get('UPSERT')
                                && Utils.cebCheckFLSPermission('Attachment', 'Body', gd).get('UPSERT')) {
                            Database.upsert(oldECAtt);
                        }
                        //Database.upsert(oldECAtt);


                    }

                }
            } catch (Exception ex) {
                System.debug('@@@ Exception in cPaginazione::createAttachment() : ' + ex.getMessage() + ' - ' + ex.getStackTraceString());
                if (Utils.cebCheckObjPermission('Log__c', gd).get('INSERT') &&
                        Utils.cebCheckFLSPermission('Log__c', 'error__c', gd).get('INSERT') &&
                        Utils.cebCheckFLSPermission('Log__c', 'Integration_Result__c', gd).get('INSERT')) {

                    Log__c newLog = new Log__c();
                    newLog.error__c = 'Line number : ' + ex.getLineNumber();
                    newLog.Integration_Result__c = ex.getCause() + '\n' + ex.getMessage() + '\n' + ex.getStackTraceString();
                    insert newLog;
                }
            }
        }
        }
    }
}