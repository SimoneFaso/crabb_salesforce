/**
 * Created by MatteoSala on 14/07/2020.
 */

global with sharing class CRABB_Batch_PDF_Attachment implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    /** if true  the batch sends a debug email at the end of execution */
    global Boolean notifyResult;
    /** Max number of Account records managed by batch */
    global Integer limitQuery;
    /** String for debugging purposes */
    global  String debug = '';
    /** Number of "execute" methods executed by batch */
    global  Integer executeCounter = 1;
    private Integer errcount = 0;
    private String csvRecord = '';
    private Blob csvFile;
    private List<Task> lT = new List<Task>();
    global  Set<String> elaboratedAE = new Set<String>();
    global  Set<String> successAE = new Set<String>();
    global  Set<String> errorAE = new Set<String>();

    String query;
    List<CRABB_DEV__CRABB_PDF_from_Template__mdt> lPDF     {get;set;}
    Map<String,String> mTemplate                                {get;set;}
    Map<String,String> mTemplateRev                             {get;set;}
    Map<String,String> mTemplateId                              {get;set;}
    Map<String, String> alpha2ToAlpha3                          {get;set;}

    global CRABB_Batch_PDF_Attachment()
    {
        mTemplate = new Map<String,String>();
        mTemplateRev = new Map<String,String>();
        mTemplateId = new Map<String,String>();

        lPDF = [SELECT
                    MasterLabel, CRABB_DEV__Template__c, CRABB_DEV__Tipo_Sottotipo__c, CRABB_DEV__Language__c
                FROM
                    CRABB_DEV__CRABB_PDF_from_Template__mdt
                WHERE
                    CRABB_DEV__Active__c = true];

        alpha2ToAlpha3 = new Map<String, String>();
        for(CRABB_DEV__CRABB_Languages__mdt r : [SELECT CRABB_DEV__Alpha2__c, CRABB_DEV__Alpha3__c FROM CRABB_DEV__CRABB_Languages__mdt])
        {
            alpha2ToAlpha3.put(r.CRABB_DEV__Alpha2__c, r.CRABB_DEV__Alpha3__c);
        }

        if(lPDF.size()>0)
        {
            for(CRABB_DEV__CRABB_PDF_from_Template__mdt p : lPDF)
            {
                mTemplate.put(p.CRABB_DEV__Tipo_Sottotipo__c + '_' + p.CRABB_DEV__Language__c, p.CRABB_DEV__template__c);
                mTemplateRev.put(p.CRABB_DEV__template__c, p.CRABB_DEV__Tipo_Sottotipo__c + '_' + p.CRABB_DEV__Language__c);
            }

            system.debug(mTemplate.values());
            List<EmailTemplate> lTemplate = [select Id,DeveloperName from EmailTemplate where DeveloperName IN : mTemplate.values()];
            system.debug(lTemplate);

            for(EmailTemplate et : lTemplate)
            {
                system.debug(et.DeveloperName);
                system.debug(et.Id);
                mTemplateId.put(mTemplateRev.get(et.DeveloperName),et.Id);
                System.debug('mTemplateId: ' + mTemplateId);
            }

            query = 'SELECT ID,CRABB_DEV__IdAccount__c,CRABB_DEV__Carrier__c,CRABB_DEV__Carrier_del_date__c,';
            query += 'CRABB_DEV__Carrier_status_activation_code__c,CRABB_DEV__Carrier_status_description__c,CRABB_DEV__Message_Email__c,';
            query += 'CRABB_DEV__Message_Error__c,CRABB_DEV__Message_UniqueID__c,CRABB_DEV__Message_Body__c,CRABB_DEV__Esito__c,';
            query += 'CRABB_DEV__Message_Phone_Number__c,CRABB_DEV__Message_Send_Date__c,CRABB_DEV__Scaduto_iniziale__c,';
            query += 'CRABB_DEV__Message_SentId__c,CRABB_DEV__Message_Status__c,CRABB_DEV__Message_Type__c,CRABB_DEV__Tipo_Sottotipo__c';
            query += ' From CRABB_DEV__ActivityExtended__c';
            query += ' WHERE CRABB_DEV__code_status__c = \'Non iniziata\'';
            for(Integer i=0; i < lPDF.size(); i++)
            {
                if(i == 0)
                    query += ' AND (CRABB_DEV__Tipo_Sottotipo__c = \'' + lPDF[i].CRABB_DEV__Tipo_Sottotipo__c + '\'';
                else
                    query += ' OR CRABB_DEV__Tipo_Sottotipo__c = \'' + lPDF[i].CRABB_DEV__Tipo_Sottotipo__c + '\'';
            }
            query += ') WITH SECURITY_ENFORCED LIMIT 50000';
        }

        system.debug(query);
        system.debug(mTemplateId);
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('Start');
        System.debug(query);
        if(lPDF.size()>0 && !CEBUtils.newOrkVersionEnabled())
        {
            return Database.getQueryLocator(query);
        }
        else {
            query= 'SELECT Id From CRABB_DEV__ActivityExtended__c LIMIT 0';
            return Database.getQueryLocator(query);
        }
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        System.debug('Execute');
        List<CRABB_DEV__ActivityExtended__c> temp_recordsOfTransaction = (List<CRABB_DEV__ActivityExtended__c>) scope;
        List<Id> lIdAcc = new List<Id>();
        List<Id> lIdAe = new List<Id>();
        Set<Id> lIdPrat = new Set<Id>();

        for(CRABB_DEV__ActivityExtended__c ae : temp_recordsOfTransaction)
        {
            lIdAcc.add(ae.CRABB_DEV__IdAccount__c);
            lIdAe.add(ae.Id);
        }

        List<Account> lAcc = [SELECT
                                Id, CRABB_DEV__CRABB_Mobile_Phone__c,
                                CRABB_DEV__CRABB_Email__c, CRABB_DEV__Preferred_Language_for_Communications__c
                                FROM Account
                                where Id IN :lIdAcc
                                WITH SECURITY_ENFORCED];

        Map<Id, Account> mapAcc = new Map<Id, Account>(lAcc);

        lT = [Select
                Id,Status,CRABB_DEV__ActivityExtended__c,WhatId
                FROM Task
                Where CRABB_DEV__ActivityExtended__c IN :lIdAe
                WITH SECURITY_ENFORCED];

        for(task t : lt){
            lIdprat.add(t.whatId);
        }
        Map<Id, CRABB_DEV__Pratica__c> mapPrat = new Map<Id, CRABB_DEV__Pratica__c>(
        [SELECT
                CRABB_DEV__Data_Invio_Sollecito__c, CRABB_DEV__Data_ultimo_invio_AR__c,
                CRABB_DEV__EC_Account__c,CRABB_DEV__EC_Pratica__c,Name
            FROM CRABB_DEV__Pratica__c WHERE ID IN :lIdprat
            WITH SECURITY_ENFORCED]
        );

        List<CRABB_DEV__ActivityExtended__c> lAEUpd = new List<CRABB_DEV__ActivityExtended__c>();
        List<Task> lTUpd = new List<Task>();
        List<ContentVersion> lCV = new List<ContentVersion>();
        List<ContentDocumentLink> lCDL = new List<ContentDocumentLink>();

        for(CRABB_DEV__ActivityExtended__c ae : temp_recordsOfTransaction)
        {
            for (Account a : lAcc)
            {
                if (ae.CRABB_DEV__IdAccount__c == a.Id)
                {
                    ae.CRABB_DEV__Carrier__c = 'PDF-ATTACHMENT';
                    ae.CRABB_DEV__code_status__c = 'PDF Done';

                    lAEUpd.add(ae);

                    break;
                }
            }

            for(Task t : lT)
            {
                if(t.CRABB_DEV__ActivityExtended__c == ae.Id)
                {
                    PageReference page = new PageReference('/apex/CRABB_DEV__PDFfromEmailTemplate');
                    page.getParameters().put('objectId', t.WhatId);
                    String tName = mTemplate.get(ae.CRABB_DEV__Tipo_Sottotipo__c + '_' + mapAcc.get(ae.CRABB_DEV__IdAccount__c).CRABB_DEV__Preferred_Language_for_Communications__c);
                    page.getParameters().put('templateName', tName);
                    System.debug(tName);
                    Blob PDFBody = Blob.valueOf('TEST PDF');
                    if(!Test.isRunningTest())
                        PDFBody = page.getContentAsPDF();
                    String body = EncodingUtil.base64Encode(PDFBody);
                    String fName = mapPrat.get(t.WhatId).Name + '_' + tName + '.pdf';
                    ContentVersion cv = createContentVersion(fName,body,t.WhatId);
                    lCV.add(cv);
                    t.Status = 'Lavorata';
                    lTUpd.add(t);

                    break;
                }
            }
        }

        if(lCV.size()>0
            && Utils.checkFLSPermission('ContentVersion', 'ContentLocation').get('CREATE')
            && Utils.checkFLSPermission('ContentVersion', 'PathOnClient').get('CREATE')
            && Utils.checkFLSPermission('ContentVersion', 'Title').get('CREATE')
            && Utils.checkFLSPermission('ContentVersion', 'Description').get('CREATE')
            && Utils.checkFLSPermission('ContentVersion', 'VersionData').get('CREATE'))
        {
            System.debug(lCV);
            List<String> lCVId = new List<String>();
            Database.SaveResult[] srList = Database.insert(lCV);
            for (Database.SaveResult sr : srList)
            {
                lCVId.add(sr.getId());
            }

            List<ContentVersion> lCVs = [SELECT ContentDocumentId,Description FROM ContentVersion WHERE Id IN :lCVId WITH SECURITY_ENFORCED];

            if(lCVs.size()>0
                && Utils.checkFLSPermission('ContentDocumentLink', 'ContentDocumentId').get('CREATE')
                && Utils.checkFLSPermission('ContentDocumentLink', 'LinkedEntityId').get('CREATE')
                && Utils.checkFLSPermission('ContentDocumentLink', 'ShareType').get('CREATE'))
            {
                for(ContentVersion cv : lCVs)
                {
                    ContentDocumentLink cdl = createContentDocumentLink(cv.ContentDocumentId,Id.valueOf(cv.Description));
                    lCDL.add(cdl);
                }


                if(lCDL.size()>0)
                {
                    System.debug(lCDL);
                    insert lCDL;

                    if(lAEUpd.size()>0
                        && Utils.checkFLSPermission('CRABB_DEV__ActivityExtended__c', 'CRABB_DEV__Carrier__c').get('UPDATE')
                        && Utils.checkFLSPermission('CRABB_DEV__ActivityExtended__c', 'CRABB_DEV__code_status__c').get('UPDATE'))
                    {
                        update lAEUpd;
                        if(lTUpd.size()>0
                                && Utils.checkFLSPermission('Task', 'Status').get('UPDATE'))
                            update lTUpd;
                    }
                }
            }
            else
            {
                if(lAEUpd.size()>0
                        && Utils.checkFLSPermission('CRABB_DEV__ActivityExtended__c', 'CRABB_DEV__Carrier__c').get('UPDATE')
                        && Utils.checkFLSPermission('CRABB_DEV__ActivityExtended__c', 'CRABB_DEV__code_status__c').get('UPDATE'))
                {
                    for(Integer i = 0; i < lAEUpd.size(); i++)
                    {
                        lAEUpd[i].CRABB_DEV__code_status__c = 'PDF NOT Done - CDL';
                    }
                    update lAEUpd;
                }
            }
        }
        else
        {
            if(lAEUpd.size()>0
                    && Utils.checkFLSPermission('CRABB_DEV__ActivityExtended__c', 'CRABB_DEV__Carrier__c').get('UPDATE')
                    && Utils.checkFLSPermission('CRABB_DEV__ActivityExtended__c', 'CRABB_DEV__code_status__c').get('UPDATE'))
            {
                for(Integer i = 0; i < lAEUpd.size(); i++)
                {
                    lAEUpd[i].CRABB_DEV__code_status__c = 'PDF NOT Done - CV';
                }
                update lAEUpd;
            }
        }
    }

    global void finish(Database.BatchableContext BC)
    {
        System.debug('Finish');
    }

    private Id getEmailTemplateId(String sottotipo, String lingua_alpha2)
    {
        System.Debug('getEmailTemplateId: ' + mTemplate + ' - ' +  sottotipo + ' - ' + lingua_alpha2 + ' - ' + alpha2ToAlpha3.get(lingua_alpha2.touppercase()) + ' - ' + alpha2ToAlpha3);
        Id templateId = mTemplateId.get(sottotipo + '_' + alpha2ToAlpha3.get(lingua_alpha2.touppercase()));
        if(templateId == null){
            return mTemplateId.get(sottotipo + '_' + 'ITA');
        }
        return templateId;
    }

    private ContentVersion createContentVersion(String name, String body, String oId)
    {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S';
        contentVersion.PathOnClient = name;
        contentVersion.Title = name;
        contentVersion.Description = oId;
        contentVersion.VersionData = EncodingUtil.base64Decode(body);
        return contentVersion;
    }

    private ContentDocumentLink createContentDocumentLink(Id contentDocumentId, Id parentId)
    {
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentDocumentId;
        contentDocumentLink.LinkedEntityId = parentId;
        contentDocumentLink.ShareType = 'I';
        return contentDocumentLink;
    }
}