/* ---------------------------------------------------------------------------------------------------------------------
Name:            CrabbEngineUtils.cls
Description:
Test class:

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
25-Mar-2021  0.1      Alessandro                      First Version

13-Sep-2022  0.2      R.Kurti & C.Sanna               Added WITH SECURITY ENFORCED and cebCheckObjPermission (security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class CrabbEngineUtils {

    //ORK variables **** start
    Public Map<String, SObjectType> gd = Schema.getGlobalDescribe();
    public SObjectType type = gd.get(Utils.NAMESPACE + 'Pratica__c');
    public Map<String, Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
    public List<string> praticaFieldsList = new List<string>();
    public Map<string, Pratica__c> pMap = new Map<string, Pratica__c> ();
    public Map<string, Task> tMap = new Map<string, Task>();
    public list<string> actExtIdList = new list<string>();
    public List<Sobject> sobjectsToInsert = new List<Sobject>();
    public List<Log__c> logL = new List<Log__c>();
    public Map<id, Sobject> sobjectsToUpdate = new Map<id, Sobject>();
    public string query;
    public List<Account> accountsForMessage;
    public Map<Id, ActivityExtended__c> filteredTsksActsExtMap = new Map<Id, ActivityExtended__c>();
    public Map<Id, ActivityExtended__c> tskActExtMap = new Map<Id, ActivityExtended__c>();
    public static Map<String, CRABB_DEV__ManageCaseMapping__mdt> mappingCaseMdtMap = new Map<String, CRABB_DEV__ManageCaseMapping__mdt>();
    public List<String> listPratToBlock = new List<String>();
    public List<String> listPratToUnblock = new List<String>();
    public static Map<String, List<Step_Field_Update__c>> existingStepFieldsUpdates = new Map<String, List<Step_Field_Update__c>>();
    Map<Id, ActivityExtended__c> aesMap = new Map<Id, ActivityExtended__c>();
    List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
    Map<Id, ActivityExtended__c> task2Obj = new Map<Id, ActivityExtended__c>();
    //ORK variables **** finish

    List<CRABB_DEV__CRABB_PDF_from_Template__mdt> lPDF;
    Map<String, String> mTemplate;
    Map<String, String> mTemplateRev;
    Map<String, String> mTemplateId;
    Map<String, String> alpha2ToAlpha3;
    Map<String, String> mType;
    Map<Id, Account> mapAccountForMessage;
    Map<Id, CRABB_DEV__Pratica__c> mapPraticheForMessage;
    Map<String, String> mSender;
    List<Task> taskForSendMessage;
    public static Map<String, String> statusMap = new Map<String, String>();

    public Map<String, String> defineStrategy(String key, List<Pratica__c> praList) {
        Map<String, SObject> objectForPraticaMap = generateMapsFieldUpdate(praList, gd);
        existingStepFieldsUpdates = getStepFieldUpdates();

        switch on key {
            when 'Check Expiration Type', 'set Expiration Type' {//Done+Test
                System.debug('Check Expiration Type');
                try {
                    if (Utils.cebCheckObjPermission('Movimento__c', gd).get('ACCESS')
                            && Utils.cebCheckFLSPermission('Movimento__c', 'Tipo_Scadenza__c', gd).get('ACCESS')
                            && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Scadenza__c', gd).get('ACCESS')
                            && Utils.cebCheckFLSPermission('Movimento__c', 'Residuo__c', gd).get('ACCESS')
                            && Utils.cebCheckFLSPermission('Movimento__c', 'Ageing__c', gd).get('ACCESS')
                            && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Pagamento__c', gd).get('ACCESS')
                            && Utils.cebCheckFLSPermission('Movimento__c', 'Stato_Pratica__c', gd).get('ACCESS')
                            && Utils.cebCheckFLSPermission('Movimento__c', 'Check_Scadenza__c', gd).get('ACCESS')) {
                        List<Movimento__c> scope = [
                                select Tipo_Scadenza__c, Ageing__c, Data_Pagamento__c, Data_Scadenza__c, Residuo__c, Stato_Pratica__c, Check_Scadenza__c
                                from Movimento__c
                                where
                                        Check_Scadenza__c = true AND RecordType.Name IN ('ADDEBITO', 'FATTURE', 'NOTE DI DEBITO', 'SCONTRINO')
                                        AND Pratica__c in :praList
                                WITH SECURITY_ENFORCED
                        ];

                        new CheckMovimentiScadutiBatch().execute(null, scope);
                        responseBuilder(praList, 'Done');
                    }
                } catch (Exception e) {
                    System.debug('CrabbEngineUtils Exception: ' + e.getLineNumber() + ' - ' + e.getMessage());
                    responseBuilder(praList, 'Error');
                }


            }
            when 'Refresh EC' { //check if exec works
                System.debug('Refresh EC');
                try {
                    Set<Id> praticasToUpdate = new Set<Id>();
                    Set<Id> relatedAccounts = new Set<Id>();
                    for (Pratica__c p : praList) {
                        praticasToUpdate.add(p.id);
                        if (String.isNotBlank(p.Account__c)) relatedAccounts.add(p.Account__c);
                    }
                    if (praticasToUpdate.size() > 0 && relatedAccounts.size() > 0) {
                        Queueable_CalcoloEstrattoContoPratica ec = new Queueable_CalcoloEstrattoContoPratica(praticasToUpdate, relatedAccounts);
                        ec.execute(null);
                        responseBuilder(praList, 'Done');
                    }
                } catch (Exception e) {
                    System.debug('CrabbEngineUtils Exception: ' + e.getLineNumber() + ' - ' + e.getMessage());
                    responseBuilder(praList, 'Error');
                }
            }
            when 'Create PDF' { //done+tested, da valutare utils per codice ridondante tra questo metodo e il pdf batch
                System.debug('Create PDF');
                try {
                    List<Id> lIdAcc = new List<Id>();
                    List<Id> lIdAe = new List<Id>();

                    mTemplate = new Map<String, String>();
                    mTemplateRev = new Map<String, String>();
                    mTemplateId = new Map<String, String>();

                    lPDF = [
                            SELECT MasterLabel, CRABB_DEV__Template__c, CRABB_DEV__Tipo_Sottotipo__c, CRABB_DEV__Language__c
                            FROM CRABB_DEV__CRABB_PDF_from_Template__mdt
                            WHERE CRABB_DEV__Active__c = true
                            WITH SECURITY_ENFORCED
                    ];

                    alpha2ToAlpha3 = new Map<String, String>();
                    for (CRABB_DEV__CRABB_Languages__mdt r : [
                            SELECT CRABB_DEV__Alpha2__c, CRABB_DEV__Alpha3__c
                            FROM CRABB_DEV__CRABB_Languages__mdt
                            WITH SECURITY_ENFORCED
                    ]) {
                        alpha2ToAlpha3.put(r.CRABB_DEV__Alpha2__c, r.CRABB_DEV__Alpha3__c);
                    }

                    if (lPDF.size() > 0) {

                        for (CRABB_DEV__CRABB_PDF_from_Template__mdt p : lPDF) {
                            mTemplate.put(p.CRABB_DEV__Tipo_Sottotipo__c + '_' + p.CRABB_DEV__Language__c, p.CRABB_DEV__template__c);
                            mTemplateRev.put(p.CRABB_DEV__template__c, p.CRABB_DEV__Tipo_Sottotipo__c + '_' + p.CRABB_DEV__Language__c);
                        }

                        List<EmailTemplate> lTemplate = [
                                select Id, DeveloperName
                                from EmailTemplate
                                where DeveloperName IN :mTemplate.values()
                                WITH SECURITY_ENFORCED
                        ];

                        for (EmailTemplate et : lTemplate) {
                            mTemplateId.put(mTemplateRev.get(et.DeveloperName), et.Id);
                        }

                    }


                    Map<Id, CRABB_DEV__Pratica__c> mapPrat = new Map<Id, CRABB_DEV__Pratica__c>(praList);

                    string query = 'select Id,WhatId,Status,CRABB_DEV__ActivityExtended__c';
                    query += ' FROM task';
                    query += ' WHERE WhatId in: praList AND CRABB_DEV__ActivityExtended__r.CRABB_DEV__code_status__c = \'Non iniziata\'';
                    for (Integer i = 0; i < lPDF.size(); i++) {
                        if (i == 0)
                            query += ' AND (CRABB_DEV__ActivityExtended__r.CRABB_DEV__Tipo_Sottotipo__c = \'' + lPDF[i].CRABB_DEV__Tipo_Sottotipo__c + '\'';
                        else
                                query += ' OR CRABB_DEV__ActivityExtended__r.CRABB_DEV__Tipo_Sottotipo__c = \'' + lPDF[i].CRABB_DEV__Tipo_Sottotipo__c + '\'';
                    }
                    query += ') WITH SECURITY_ENFORCED LIMIT 50000';
                    List<task> lt = Database.query(String.escapeSingleQuotes(query));

                    List<string> aeidList = new List<string>();
                    for (task t : lt) {
                        aeidList.add(t.ActivityExtended__c);
                    }

                    List<CRABB_DEV__ActivityExtended__c> temp_recordsOfTransaction = [
                            select id, CRABB_DEV__IdAccount__c, CRABB_DEV__Carrier__c, CRABB_DEV__Carrier_del_date__c,
                                    CRABB_DEV__Carrier_status_activation_code__c, CRABB_DEV__Carrier_status_description__c, CRABB_DEV__Message_Email__c, CRABB_DEV__Message_Error__c,
                                    CRABB_DEV__Message_UniqueID__c, CRABB_DEV__Message_Body__c, CRABB_DEV__Esito__c, CRABB_DEV__Message_Phone_Number__c, CRABB_DEV__Message_Send_Date__c,
                                    CRABB_DEV__Scaduto_iniziale__c, CRABB_DEV__Message_SentId__c, CRABB_DEV__Message_Status__c, CRABB_DEV__Message_Type__c, CRABB_DEV__Tipo_Sottotipo__c
                            FROM CRABB_DEV__ActivityExtended__c
                            where id in :aeidList
                            WITH SECURITY_ENFORCED
                    ];

                    List<CRABB_DEV__ActivityExtended__c> lAEUpd = new List<CRABB_DEV__ActivityExtended__c>();
                    for (CRABB_DEV__ActivityExtended__c ae : temp_recordsOfTransaction) {
                        lIdAcc.add(ae.CRABB_DEV__IdAccount__c);
                        lIdAe.add(ae.Id);

                        ae.CRABB_DEV__Carrier__c = 'PDF-ATTACHMENT';
                        ae.CRABB_DEV__code_status__c = 'PDF Done';

                        lAEUpd.add(ae);
                    }


                    List<Account> lAcc = [
                            SELECT
                                    Id, CRABB_DEV__CRABB_Mobile_Phone__c,
                                    CRABB_DEV__CRABB_Email__c, CRABB_DEV__Preferred_Language_for_Communications__c
                            FROM Account
                            where Id IN :lIdAcc
                            WITH SECURITY_ENFORCED
                    ];

                    Map<Id, Account> mapAcc = new Map<Id, Account>(lAcc);


                    List<Task> lTUpd = new List<Task>();
                    List<ContentVersion> lCV = new List<ContentVersion>();
                    List<ContentDocumentLink> lCDL = new List<ContentDocumentLink>();

                    for (CRABB_DEV__ActivityExtended__c ae : temp_recordsOfTransaction) {
                        for (Task t : lT) {
                            if (t.CRABB_DEV__ActivityExtended__c == ae.Id) {
                                PageReference page = new PageReference('/apex/CRABB_DEV__PDFfromEmailTemplate');
                                page.getParameters().put('objectId', t.WhatId);
                                String tName = mTemplate.get(ae.CRABB_DEV__Tipo_Sottotipo__c + '_' + mapAcc.get(ae.CRABB_DEV__IdAccount__c).CRABB_DEV__Preferred_Language_for_Communications__c);
                                page.getParameters().put('templateName', tName);
                                System.debug(tName);
                                Blob PDFBody = Blob.valueOf('TEST PDF');
                                if (!Test.isRunningTest())
                                    PDFBody = page.getContentAsPDF();
                                String body = EncodingUtil.base64Encode(PDFBody);
                                String fName = mapPrat.get(t.WhatId).Name + '_' + tName + '.pdf';
                                ContentVersion cv = createContentVersion(fName, body, t.WhatId);
                                lCV.add(cv);
                                t.Status = 'Lavorata';
                                lTUpd.add(t);

                                break;
                            }
                        }
                    }


                    //inizio if

                    if (lCV.size() > 0
                            && Utils.cebCheckObjPermission('ContentVersion', gd).get('CREATE')
                            && Utils.cebCheckFLSPermission('ContentVersion', 'ContentLocation', gd).get('CREATE')
                            && Utils.cebCheckFLSPermission('ContentVersion', 'PathOnClient', gd).get('CREATE')
                            && Utils.cebCheckFLSPermission('ContentVersion', 'Title', gd).get('CREATE')
                            && Utils.cebCheckFLSPermission('ContentVersion', 'Description', gd).get('CREATE')
                            && Utils.cebCheckFLSPermission('ContentVersion', 'VersionData', gd).get('CREATE')) {
                        System.debug(lCV);
                        List<String> lCVId = new List<String>();
                        Database.SaveResult[] srList = Database.insert(lCV);
                        for (Database.SaveResult sr : srList) {
                            lCVId.add(sr.getId());
                        }

                        List<ContentVersion> lCVs = [
                                SELECT ContentDocumentId, Description
                                FROM ContentVersion
                                WHERE Id IN :lCVId
                                WITH SECURITY_ENFORCED
                        ];

                        if (lCVs.size() > 0
                                && Utils.cebCheckObjPermission('ContentDocumentLink', gd).get('CREATE')
                                && Utils.cebCheckFLSPermission('ContentDocumentLink', 'ContentDocumentId', gd).get('CREATE')
                                && Utils.cebCheckFLSPermission('ContentDocumentLink', 'LinkedEntityId', gd).get('CREATE')
                                && Utils.cebCheckFLSPermission('ContentDocumentLink', 'ShareType', gd).get('CREATE')) {
                            for (ContentVersion cv : lCVs) {
                                ContentDocumentLink cdl = createContentDocumentLink(cv.ContentDocumentId, Id.valueOf(cv.Description));
                                lCDL.add(cdl);
                            }

                            if (lCDL.size() > 0) {
                                System.debug(lCDL);
                                insert lCDL;

                                if (lAEUpd.size() > 0
                                        && Utils.cebCheckObjPermission('CRABB_DEV__ActivityExtended__c', gd).get('UPDATE')
                                        && Utils.cebCheckFLSPermission('CRABB_DEV__ActivityExtended__c', 'CRABB_DEV__Carrier__c', gd).get('UPDATE')
                                        && Utils.cebCheckFLSPermission('CRABB_DEV__ActivityExtended__c', 'CRABB_DEV__code_status__c', gd).get('UPDATE')) {
                                    update lAEUpd;
                                    if (lTUpd.size() > 0
                                            && Utils.cebCheckObjPermission('Task', gd).get('UPDATE')
                                            && Utils.cebCheckFLSPermission('Task', 'Status', gd).get('UPDATE')) {
                                        update lTUpd;
                                    }
                                }
                            }
                        } else {
                            if (lAEUpd.size() > 0
                                    && Utils.cebCheckObjPermission('CRABB_DEV__ActivityExtended__c', gd).get('UPDATE')
                                    && Utils.cebCheckFLSPermission('CRABB_DEV__ActivityExtended__c', 'CRABB_DEV__Carrier__c', gd).get('UPDATE')
                                    && Utils.cebCheckFLSPermission('CRABB_DEV__ActivityExtended__c', 'CRABB_DEV__code_status__c', gd).get('UPDATE')) {
                                for (Integer i = 0; i < lAEUpd.size(); i++) {
                                    lAEUpd[i].CRABB_DEV__code_status__c = 'PDF NOT Done - CDL';
                                }
                                update lAEUpd;
                            }
                        }
                    } else {
                        if (lAEUpd.size() > 0
                                && Utils.cebCheckObjPermission('CRABB_DEV__ActivityExtended__c', gd).get('UPDATE')
                                && Utils.cebCheckFLSPermission('CRABB_DEV__ActivityExtended__c', 'CRABB_DEV__Carrier__c', gd).get('UPDATE')
                                && Utils.cebCheckFLSPermission('CRABB_DEV__ActivityExtended__c', 'CRABB_DEV__code_status__c', gd).get('UPDATE')) {
                            for (Integer i = 0; i < lAEUpd.size(); i++) {
                                lAEUpd[i].CRABB_DEV__code_status__c = 'PDF NOT Done - CV';
                            }
                            update lAEUpd;
                        }
                    }
                    //fine if
                    responseBuilder(praList, 'Done');

                } catch (Exception e) {
                    System.debug('CrabbEngineUtils Exception: ' + e.getLineNumber() + ' - ' + e.getMessage());
                    responseBuilder(praList, 'Error');
                }
            }
            /*when 'Send Email' { //Done - Verify mailup
                System.debug('Send Email');
                try {
                    List<CRABB_DEV__ActivityExtended__c> activityExList = buildMessage(praList);
                    List<Task> taskListUpd = new List<Task>();
                    List<CRABB_DEV__ActivityExtended__c> aeListUpd = new List<CRABB_DEV__ActivityExtended__c>();

                    for (CRABB_DEV__ActivityExtended__c ae : activityExList) {
                        if (mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c) == 'EMAIL') {
                            ae.CRABB_DEV__Message_Email__c = mapAccountForMessage.get(ae.CRABB_DEV__Account__c).CRABB_DEV__CRABB_Email__c;
                            ae.CRABB_DEV__Message_UniqueID__c = ae.Id;
                            ae.CRABB_DEV__Carrier__c = 'AWS_EMAIL';
                        }

                        for (Task t : taskForSendMessage) {
                            if (ae.id == t.CRABB_DEV__ActivityExtended__c && mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c) == 'Email') {
                                CRABBSENDER_MailUP cs = new CRABBSENDER_MailUP();
                                CRABBSENDER_MailUP.CrabbMessage cm = new CRABBSENDER_MailUP.CrabbMessage();

                                cm.customerid = ae.CRABB_DEV__IdAccount__c;
                                cm.sender = mSender.get(ae.CRABB_DEV__Tipo_Sottotipo__c);
                                cm.messageType = mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c);
                                ae.CRABB_DEV__Carrier_status_activation_code__c = mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c);
                                ae.CRABB_DEV__Message_Type__c = mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c);

                                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(getEmailTemplateId(ae.CRABB_DEV__Tipo_Sottotipo__c, mapAccountForMessage.get(ae.CRABB_DEV__IdAccount__c).CRABB_DEV__Preferred_Language_for_Communications__c), UserInfo.getUserId(), t.WhatId);
                                System.debug(email.getPlainTextBody());

                                // INVIO EMAIL
                                String subject = email.getSubject();
                                String body = email.gethtmlBody();
                                body = body.replace('[$CRABB_EC_Account]', mapPraticheForMessage.get(t.whatId).CRABB_DEV__EC_Account__c);
                                body = body.replace('[$CRABB_EC_Pratica]', mapPraticheForMessage.get(t.whatId).CRABB_DEV__EC_Pratica__c);
                                cm.recipient = ae.CRABB_DEV__Message_Email__c;
                                cm.body_text = email.getPlainTextBody();
                                cm.body_html = EncodingUtil.base64Encode(Blob.valueOf(body));
                                cm.subject = subject;
                                ae.CRABB_DEV__Message_Body__c = cm.body_html;

                                String sendMsg = cs.Send(cm);
                                System.debug('SMS RESPONSE:' + sendMsg);
                                List<String> ls = sendMsg.split(':');
                                if (ls[0] == 'Error' || ls[0] == '{\"errorMessage\"') {
                                    ae.CRABB_DEV__Message_Status__c = 'Error';
                                    ae.CRABB_DEV__Esito__c = 'Messaggio in errore';
                                    ae.CRABB_DEV__Message_Error__c = sendMsg;
                                } else {
                                    ae.CRABB_DEV__Esito__c = 'Messaggio Inviato';
                                    ae.CRABB_DEV__Message_Status__c = 'Sent';
                                    ae.CRABB_DEV__Message_Send_Date__c = system.Now();
                                    t.Status = 'Lavorata';
                                    taskListUpd.add(t);

                                    if (mapPraticheForMessage.containsKey(t.whatId) && ae.CRABB_DEV__Carrier__c.equalsIgnoreCase('AWS_EMAIL')) {
                                        if (mapPraticheForMessage.get(t.whatId).CRABB_DEV__Data_Invio_Sollecito__c == null) {
                                            mapPraticheForMessage.get(t.whatId).CRABB_DEV__Data_Invio_Sollecito__c = Date.today();
                                        } else {
                                            mapPraticheForMessage.get(t.whatId).CRABB_DEV__Data_ultimo_invio_AR__c = Date.today();
                                        }
                                    }
                                }
                                aeListUpd.add(ae);
                            }
                        }
                    }

                    if (aeListUpd.size() > 0)
                        update aeListUpd;

                    if (taskListUpd.size() > 0)
                        update taskListUpd;

                    if (mapPraticheForMessage.values().size() > 0) {
                        update mapPraticheForMessage.values();
                    }
                    responseBuilder(praList, 'Done');
                } catch(Exception e) {
                    responseBuilder(praList, 'Error');
                }

            }
            when 'Send SMS' { //Done
                System.debug('Send SMS');
                try{
                    List<CRABB_DEV__ActivityExtended__c> activityExList = buildMessage(praList);
                    List<Task> taskListUpd = new List<Task>();
                    List<CRABB_DEV__ActivityExtended__c> aeListUpd = new List<CRABB_DEV__ActivityExtended__c>();

                    for(CRABB_DEV__ActivityExtended__c ae : activityExList) {
                        if(mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c) == 'SMS') {
                            ae.CRABB_DEV__Message_Phone_Number__c = mapAccountForMessage.get(ae.CRABB_DEV__Account__c).CRABB_DEV__CRABB_Mobile_Phone__c;
                            ae.CRABB_DEV__Message_UniqueID__c = ae.Id;
                            ae.CRABB_DEV__Carrier__c = 'AWS_SMS';
                        }

                        for(Task t : taskForSendMessage) {
                            if(ae.id == t.CRABB_DEV__ActivityExtended__c &&mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c) == 'SMS') {
                                CRABBSENDER_MailUP cs = new CRABBSENDER_MailUP();
                                CRABBSENDER_MailUP.CrabbMessage cm = new CRABBSENDER_MailUP.CrabbMessage();

                                cm.customerid = ae.CRABB_DEV__IdAccount__c;
                                cm.sender = mSender.get(ae.CRABB_DEV__Tipo_Sottotipo__c);
                                cm.messageType = mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c);
                                ae.CRABB_DEV__Carrier_status_activation_code__c = mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c);
                                ae.CRABB_DEV__Message_Type__c = mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c);

                                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(getEmailTemplateId(ae.CRABB_DEV__Tipo_Sottotipo__c, mapAccountForMessage.get(ae.CRABB_DEV__IdAccount__c).CRABB_DEV__Preferred_Language_for_Communications__c), UserInfo.getUserId(), t.WhatId);
                                System.debug(email.getPlainTextBody());

                                if(mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c) == 'SMS') {
                                    //INVIO SMS
                                    System.debug('Sono entrato nella parte di SMS');
                                    String body = email.getPlainTextBody();
                                    cm.message = body;
                                    cm.phone = ae.CRABB_DEV__Message_Phone_Number__c;
                                    ae.CRABB_DEV__Message_Body__c = cm.message;
                                }

                                String sms = cs.Send(cm);
                                System.debug('SMS RESPONSE:'+sms);

                                List<String> ls = sms.split(':');
                                if(ls[0] == 'Error' || ls[0] == '{\"errorMessage\"') {
                                    ae.CRABB_DEV__Message_Status__c = 'Error';
                                    ae.CRABB_DEV__Esito__c = 'Messaggio in errore';
                                    ae.CRABB_DEV__Message_Error__c = sms;
                                } else {
                                    ae.CRABB_DEV__Esito__c = 'Messaggio Inviato';
                                    ae.CRABB_DEV__Message_Status__c = 'Sent';
                                    ae.CRABB_DEV__Message_Send_Date__c = system.Now();
                                    t.Status = 'Lavorata';
                                    taskListUpd.add(t);

                                    if(mapPraticheForMessage.containsKey(t.whatId) && ae.CRABB_DEV__Carrier__c.equalsIgnoreCase('AWS_EMAIL')) {
                                        if(mapPraticheForMessage.get(t.whatId).CRABB_DEV__Data_Invio_Sollecito__c == null){
                                            mapPraticheForMessage.get(t.whatId).CRABB_DEV__Data_Invio_Sollecito__c = Date.today();
                                        } else{
                                            mapPraticheForMessage.get(t.whatId).CRABB_DEV__Data_ultimo_invio_AR__c = Date.today();
                                        }
                                    }
                                }
                                aeListUpd.add(ae);
                            }
                        }
                    }

                    if(aeListUpd.size() > 0)
                        update aeListUpd;

                    if(taskListUpd.size() > 0)
                        update taskListUpd;

                    if(mapPraticheForMessage.values().size()>0)
                    {
                        update mapPraticheForMessage.values();
                    }
                    responseBuilder(praList, 'Done');
                } catch(Exception e) {
                    responseBuilder(praList, 'Error');
                }
            }*/
            when 'Create CASE' { //done+test
                System.debug('Create CASE');
                try {
                    List<CRABB_DEV__ManageCaseMapping__mdt> mappingCaseMdt = [
                            SELECT Id, DeveloperName, CRABB_DEV__FieldTarget__c, CRABB_DEV__FieldSource__c, CRABB_DEV__StaticValue__c,
                                    CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__Tipo__c, CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__Sottotipo__c, CRABB_DEV__sObjectSource__c
                            FROM CRABB_DEV__ManageCaseMapping__mdt
                            WHERE CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__SourceObject__c = 'ActivityExtended__c'
                            WITH SECURITY_ENFORCED
                    ]; //AND CRABB_DEV__ManageCaseHeader__r.isTest__c = :isTest WITH SECURITY_ENFORCED];

                    for (CRABB_DEV__ManageCaseMapping__mdt mapCase : mappingCaseMdt) {
                        if (!mappingCaseMdtMap.containsKey(mapCase.CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__Tipo__c + ' ' + mapCase.CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__Sottotipo__c)) {
                            mappingCaseMdtMap.put(mapCase.CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__Tipo__c + ' ' + mapCase.CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__Sottotipo__c, mapCase);
                        }
                    }

                    List<Task> TaskList = [
                            select id, CRABB_DEV__ActivityExtended__c, WhatId, Status, Subject
                            from task
                            where WhatId in :praList and CRABB_DEV__ActivityExtended__r.CRABB_DEV__Tipo_Sottotipo__c in :mappingCaseMdtMap.keySet()
                            WITH SECURITY_ENFORCED
                    ];
                    Set<Id> pratIdList = new Set<Id>();
                    Map<String, String> taskMapForCaseInsert = new Map<String, String>();
                    Map<String, Task> taskMap = new Map<String, Task>();
                    for (Task t : TaskList) {
                        taskMapForCaseInsert.put(t.ActivityExtended__c, t.WhatId + '~' + t.Subject);
                        taskMap.put(t.id, t);
                    }

                    for (Pratica__c p : praList) {
                        pratIdList.add(p.id);
                    }

                    list<ActivityExtended__c> actToCreateCase = new list<ActivityExtended__c>();

                    Map<Id, ActivityExtended__c> maptaskae = Utils.cebGetTaskWithActivityExtended(TaskList, gd);
                    for (String keyV : maptaskae.keySet()) {
                        ActivityExtended__c act = maptaskae.get(keyV);
                        if (act != null && act.Tipo__c != null && act.Sotto_Tipo__c != null && 'NON INIZIATA'.equalsIgnoreCase(taskMap.get(keyV).Status)) {
                            actToCreateCase.add(act);
                        }
                    }
                    if (actToCreateCase.size() > 0) {
                        CaseUtility.createCaseFromStep(actToCreateCase, pratIdList, taskMapForCaseInsert);
                    }
                    responseBuilder(praList, 'Done');
                } catch (Exception e) {
                    System.debug('CrabbEngineUtils Exception: ' + e.getLineNumber() + ' - ' + e.getMessage());
                    responseBuilder(praList, 'Error');
                }
            }
            /*when 'Block Dossier' { //done
                System.debug('Block Dossier');
                List<CRABB_DEV__Pratica__c> statusUpd = new List<CRABB_DEV__Pratica__c>();
                try {
                    //new BloccoSbloccoPratiche().BloccaPratiche( praList, 'Esistono Ticket Bloccanti', 'Esistono Ticket Bloccanti' ); vecchia gestione
                    Map<Id, CRABB_DEV__Pratica__c> praMap = new Map<Id, CRABB_DEV__Pratica__c>(praList);

                    for(CRABB_DEV__CEB__c ceb : [SELECT Id, CRABB_DEV__Pratica__c, CRABB_DEV__Status__c, CRABB_DEV__Type__c FROM CRABB_DEV__CEB__c WHERE CRABB_DEV__Status__c = 'New' AND CRABB_DEV__Pratica__c in :praList AND CRABB_DEV__Type__c NOT IN ('CEX','UEC','DSU','DBL')]) {
                        listPratToBlock.add(ceb.CRABB_DEV__Pratica__c);
                    }
                    CEBUtils.updateCebEvents(listPratToBlock, 'Blocked');
                    new BloccoSbloccoPratiche().BloccaPratiche( praList, 'Esistono Ticket Bloccanti', 'Esistono Ticket Bloccanti' );

                    for(String str : listPratToBlock) {
                        statusUpd.add(praMap.get(str));
                    }

                    responseBuilder((List<Pratica__c>) statusUpd, 'Done');
                } catch(Exception e) {
                    responseBuilder((List<Pratica__c>) statusUpd, 'Error');
                }
            }
            when 'Unblock the dossier' { //done
                System.debug('Unblock the dossier');
                List<CRABB_DEV__Pratica__c> statusUpd = new List<CRABB_DEV__Pratica__c>();
                try {
                    //new BloccoSbloccoPratiche().sbloccaPratiche( praList,'Ticket Bloccanti Chiusi'); vecchia gestione
                    Map<Id, CRABB_DEV__Pratica__c> praMap = new Map<Id, CRABB_DEV__Pratica__c>(praList);

                    for(CRABB_DEV__CEB__c ceb : [SELECT Id, CRABB_DEV__Pratica__c, CRABB_DEV__Status__c, CRABB_DEV__Type__c FROM CRABB_DEV__CEB__c WHERE CRABB_DEV__Status__c = 'Blocked' AND CRABB_DEV__Status__c NOT IN ('Done','Error') AND CRABB_DEV__Pratica__c in :praList]) {
                        listPratToUnblock.add(ceb.CRABB_DEV__Pratica__c);
                    }
                    CEBUtils.updateCebEvents(listPratToUnblock, 'New');
                    new BloccoSbloccoPratiche().sbloccaPratiche( praList,'Ticket Bloccanti Chiusi');

                    for(String str : listPratToBlock) {
                        statusUpd.add(praMap.get(str));
                    }

                    responseBuilder((List<Pratica__c>) statusUpd, 'Done');
                } catch(Exception e) {
                    responseBuilder(praList, 'Error');
                }
            }*/
            when 'Check Strategy Exit Criteria' { //Done
                System.debug('Check Strategy Exit Criteria');

                try {
                    praticaFieldsList.addAll(mfields.keySet());

                    query = 'Select ' + utils.joinStrings(praticaFieldsList, ',') + ',(select id,subject,ActivityExtended__c,ActivityExtended__r.id_attivita__c,ActivityExtended__r.Account_id__c,ActivityExtended__r.isFirst__c,ActivityExtended__r.record_type__c,status,WhatId,description from Tasks where status=\'Non iniziata\' and ActivityExtended__c!=null) FROM Pratica__c where id in:praList';
                    List<Pratica__c>scope = Database.query(String.escapeSingleQuotes(query));

                    //1 - creating pmap, tmap, sobjectsToUpdate
                    dataBuilding(scope);

                    //2 - retrieve strategies
                    //OrkStatic.retrieveStrategie();
                    OrkStatic.cebRetrieveStrategie(gd);

                    //3 - execute first activities
                    //OrkKernel.executeFirstActivities(tMap,pMap, sobjectsToUpdate , sobjectsToInsert,logL );

                    //4 - get all activitiesextended
                    query = 'SELECT ' + Utils.cebGetSOBJECTFieldsForQuery('ActivityExtended__c', gd) + ' FROM ActivityExtended__c WHERE Id in:actExtIdList';
                    //if (Utils.checkFLSPermission('ActivityExtended__c', 'id_affidamento__c').get('UPDATE') && Utils.checkFLSPermission('ActivityExtended__c', 'id_lotto_associato__c').get('UPDATE')) {
                    if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_affidamento__c', gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_lotto_associato__c', gd).get('UPDATE')) {
                        aes = Database.query(String.escapeSingleQuotes(query));
                    }
                    for (ActivityExtended__c tmp : aes) {
                        aesMap.put(tmp.Id, tmp);
                    }

                    //5 - creating task2obk map
                    for (String tmp : tMap.keySet()) {
                        if (tMap.containsKey(tmp)) task2Obj.put(tmp, aesMap.get(tMap.get(tmp).ActivityExtended__c));
                    }

                    filteredTsksActsExtMap = buildFilteredTasksActivitiesExtMap(task2Obj, tMap);

                    //6 - executeExit
                    executeActivity(filteredTsksActsExtMap);
                    OrkKernel.cebExecuteExit(gd, 'Task_beforeUpdate', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, task2Obj);

                    //7 - dml ops
                    doDmlOps();
                    responseBuilder(praList, 'New');
                } catch (Exception e) {
                    System.debug('CrabbEngineUtils Exception: ' + e.getLineNumber() + ' - ' + e.getMessage());
                    responseBuilder(praList, 'Error');
                }

            }
            when 'Check Jump' {
                System.debug('Check Jump');
                try {
                    praticaFieldsList.addAll(mfields.keySet());

                    query = 'Select ' + utils.joinStrings(praticaFieldsList, ',') + ' FROM Pratica__c where id in:praList';
                    List<Pratica__c> scope = Database.query(String.escapeSingleQuotes(query));

                    //1 - creating pmap, tmap, sobjectsToUpdate
                    dataBuilding(scope, true);

                    //2 - retrieve strategies
                    OrkStatic.cebRetrieveStrategie(gd);

                    //3 - execute first activities
                    //OrkKernel.executeFirstActivities(tMap,pMap, sobjectsToUpdate , sobjectsToInsert,logL );

                    //4 - get all activitiesextended
                    query = 'SELECT ' + Utils.cebGetSOBJECTFieldsForQuery('ActivityExtended__c', gd) + ' FROM ActivityExtended__c WHERE Id in:actExtIdList';
                    if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_affidamento__c', gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_lotto_associato__c', gd).get('UPDATE')) {
                        aes = Database.query(String.escapeSingleQuotes(query));
                    }
                    for (ActivityExtended__c tmp : aes) {
                        aesMap.put(tmp.Id, tmp);
                    }

                    //5 - creating task2obk map
                    for (String tmp : tMap.keySet()) {
                        if (tMap.containsKey(tmp)) task2Obj.put(tmp, aesMap.get(tMap.get(tmp).ActivityExtended__c));
                    }

                    filteredTsksActsExtMap = buildFilteredTasksActivitiesExtMap(task2Obj, tMap);

                    //6 - executeJump
                    executeActivity(filteredTsksActsExtMap);
                    OrkKernel.cebExecuteJump(objectForPraticaMap, gd, 'Task_beforeUpdate', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, task2Obj);
                    OrkKernel.cebExecuteLoop(objectForPraticaMap, gd, 'Task_beforeUpdate', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, task2Obj);

                    //7 - dml ops
                    doDmlOps();
                    responseBuilder(praList, 'New');
                } catch (Exception e) {
                    System.debug('CrabbEngineUtils Exception: ' + e.getLineNumber() + ' - ' + e.getMessage());
                    responseBuilder(praList, 'Error');
                }

            }
            when 'Check Next Step' { //tbd filter on tasks
                System.debug('Check Next Step');

                try {
                    praticaFieldsList.addAll(mfields.keySet());

                    query = 'Select ' + utils.joinStrings(praticaFieldsList, ',') + ' FROM Pratica__c where id in:praList';
                    List<Pratica__c> scope = Database.query(String.escapeSingleQuotes(query));

                    //1 - creating pmap, tmap, sobjectsToUpdate
                    dataBuilding(scope, true);

                    //2 - retrieve strategies
                    OrkStatic.cebRetrieveStrategie(gd);

                    //3 - execute first activities
                    //OrkKernel.executeFirstActivities(tMap,pMap, sobjectsToUpdate , sobjectsToInsert,logL );

                    //4 - get all activitiesextended
                    query = 'SELECT ' + Utils.cebGetSOBJECTFieldsForQuery('ActivityExtended__c', gd) + ' FROM ActivityExtended__c WHERE Id in:actExtIdList';
                    if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_affidamento__c', gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_lotto_associato__c', gd).get('UPDATE')) {
                        aes = Database.query(String.escapeSingleQuotes(query));
                    }
                    for (ActivityExtended__c tmp : aes) {
                        aesMap.put(tmp.Id, tmp);
                    }

                    //5 - creating task2obk map
                    for (String tmp : tMap.keySet()) {
                        if (tMap.containsKey(tmp)) task2Obj.put(tmp, aesMap.get(tMap.get(tmp).ActivityExtended__c));
                    }

                    filteredTsksActsExtMap = buildFilteredTasksActivitiesExtMap(task2Obj, tMap);

                    //6 - defining next job
                    executeActivity(filteredTsksActsExtMap);
                    OrkKernel.cebSetNextJob(objectForPraticaMap, gd, 'Task_beforeUpdate', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, task2Obj);

                    //7 - dml ops
                    doDmlOps();
                    responseBuilder(praList, 'New');
                } catch (Exception e) {
                    System.debug('CrabbEngineUtils Exception: ' + e.getLineNumber() + ' - ' + e.getMessage());
                    responseBuilder(praList, 'Error');
                }

            }
            when 'Refresh Scoring' { //done
                System.debug('Refresh Scoring');
                List<string> idList = new List<string>();
                Map<String, List<CRABB_DEV__CEB__c>> accountEventsMap = new Map<String, List<CRABB_DEV__CEB__c>>();
                for (Pratica__c p : praList) {
                    List<CRABB_DEV__CEB__c> cebEvents = new List<CRABB_DEV__CEB__c>();
                    if (accountEventsMap.containsKey(p.Account__c)) {
                        cebEvents = accountEventsMap.get(p.account__c);
                    }
                    cebEvents.addAll(p.CRABB_DEV__Crabb_Events__r);
                    accountEventsMap.put(p.account__c, cebEvents);

                    idList.add(p.Account__c);
                }
                CRABB_Scoring_ctrl.elaborateScoring(idList, 'Account');

                Database.SaveResult [] scoringRes = CRABB_Scoring_ctrl.updateResult;
                Map<String, List<CRABB_DEV__CEB__c>> accountEventsErrMap = accountEventsMap; //this map is a copy of accountEventsMap

                for (Database.SaveResult sr : scoringRes) {
                    //we remove from the map accountEventsErrMap every record ok in the Database.SaveResult to have a map of errors
                    if (sr.isSuccess() && accountEventsMap.containsKey(sr.getId())) {
                        accountEventsErrMap.remove(sr.getId());
                    }
                }
                responseBuilder(accountEventsMap, accountEventsErrMap);

            }
            /*when 'CSV file for the collectors' { //Done
                System.debug('CSV file for the collectors');
                try{
                    String fileName = 'CRABB_NUOVOAFFIDAMENTO_';
                    String fName = 'CSVNEW';
                    Integer fileNumber = 1;
                    Integer rowsSize = 0;
                    List<String> lottoIdList = new List<String>();
                    List<CRABB_DEV__ListOfFields__c> listOfFieldsList = [SELECT CRABB_DEV__Field__c, CRABB_DEV__Object__c FROM CRABB_DEV__ListOfFields__c WHERE Name LIKE :fName + '%' AND Show__c = TRUE WITH SECURITY_ENFORCED ORDER BY Name];
                    String affidamentoFields = Utils.cebGetSOBJECTFieldsForQuery('Affidamento__c', gd);
                    String queryAffidamenti;

                    queryAffidamenti = 'SELECT ' + affidamentoFields + ', CRABB_DEV__lotto__r.CRABB_DEV__NuovoAffidamentoProcessed__c, ' +
                            'CRABB_DEV__Lotto__r.CRABB_DEV__Agenzia_di_Recupero__c,  CRABB_DEV__Lotto__r.CRABB_DEV__Agenzia_di_Recupero__r.name,  ' +
                            'CRABB_DEV__Lotto__r.name,  CRABB_DEV__Lotto__r.CRABB_DEV__Agenzia_di_Recupero__r.CRABB_DEV__Ultimo_aggiornamento_revoche__c ' +
                            'FROM Affidamento__c WHERE Pratica__c in :praList AND Stato__c=\'In Corso\' WITH SECURITY_ENFORCED';

                    List<CRABB_DEV__Affidamento__c> affList = Database.query(queryAffidamenti);
                    Map<String,String> tipoAffidamentoMap = new Map<String, String>();
                    Map<String, List<String>> praticheIdForLotto = new Map<String, List<String>>();
                    List<String> praticheListId;
                    for(CRABB_DEV__Affidamento__c aff : affList) {

                        praticheListId = new List<String>();
                        if(praticheIdForLotto.containsKey(aff.CRABB_DEV__Lotto__c)) {
                            praticheListId = praticheIdForLotto.get(aff.CRABB_DEV__Lotto__c);
                        }
                        praticheListId.add(aff.CRABB_DEV__Pratica__c);
                        praticheIdForLotto.put(aff.CRABB_DEV__Lotto__c, praticheListId);

                        lottoIdList.add(aff.CRABB_DEV__Lotto__c);
                        tipoAffidamentoMap.put(aff.CRABB_DEV__Pratica__c, aff.CRABB_DEV__Tipo__c);
                    }


                    Map<String, CRABB_DEV__Lotto__c> lottoMap = new Map<String, CRABB_DEV__Lotto__c>([SELECT id, CRABB_DEV__NuovoAffidamentoProcessed__c, CRABB_DEV__Agenzia_di_Recupero__c, CRABB_DEV__Agenzia_di_Recupero__r.name,name, CRABB_DEV__Agenzia_di_Recupero__r.Ultimo_aggiornamento_revoche__c FROM CRABB_DEV__Lotto__c WHERE id IN :lottoIdList  WITH SECURITY_ENFORCED]);
                    Map<String, String> fileNameMap = new Map<String, String>();
                    List<CRABB_DEV__Flussi_Collector__c> listFlussiCollector = new List<CRABB_DEV__Flussi_Collector__c>();

                    for(String lottoKey : lottoMap.keySet()) {
                        if(lottoMap.get(lottoKey).CRABB_DEV__NuovoAffidamentoProcessed__c == false && lottoMap.get(lottoKey).CRABB_DEV__Stato__c == 'Confermato') {
                            CRABB_DEV__Flussi_Collector__c flussiCollector = new CRABB_DEV__Flussi_Collector__c();
                            fileName += lottoMap.get(lottoKey).CRABB_DEV__Agenzia_di_Recupero__r.name + '_' + lottoMap.get(lottoKey).name + '_' + System.now().format('YYYYMMdd');
                            fileNameMap.put(lottoKey, fileName);
                            lottoMap.get(lottoKey).CRABB_DEV__NuovoAffidamentoProcessed__c = true;

                            flussiCollector.CRABB_DEV__Collector__c = lottoMap.get(lottoKey).CRABB_DEV__Agenzia_di_Recupero__c;
                            flussiCollector.CRABB_DEV__Lotti_Presenti__c = '1';
                            flussiCollector.CRABB_DEV__Numero_Record__c = rowsSize;
                            flussiCollector.CRABB_DEV__Tipo__c = 'NuovoAffidamento';
                            listFlussiCollector.add(flussiCollector);
                        }
                    }

                    if (Utils.cebCheckFLSPermission('Lotto__c', 'NuovoAffidamentoProcessed__c', gd).get('UPDATE')) {
                        update lottoMap.values();
                    }

                    Database.UpsertResult[] upsertRes;
                    if (Utils.cebCheckFLSPermission('Flussi_collector__c', 'Collector__c', gd).get('CREATE') && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Lotti_Presenti__c', gd).get('CREATE') && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Numero_Record__c', gd).get('CREATE') && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Tipo__c', gd).get('CREATE')){
                        upsertRes = Database.upsert(listFlussiCollector);
                    }

                    List<String> fCollectorId;
                    For(Database.UpsertResult stResult : upsertRes) {
                        if(stResult.isSuccess()){
                            fCollectorId.add(stResult.getId());
                        }
                    }

                    Map<String, CRABB_DEV__Flussi_collector__c> flussiCollectorMap = new Map<String, CRABB_DEV__Flussi_Collector__c>();
                    List<CRABB_DEV__Flussi_Collector__c> fCollList = [SELECT Id,CRABB_DEV__Collector__c, CRABB_DEV__Lotti_Presenti__c, CRABB_DEV__Numero_Record__c, CRABB_DEV__Tipo__c FROM CRABB_DEV__Flussi_collector__c WHERE id in : fCollectorId WITH SECURITY_ENFORCED];
                    for(CRABB_DEV__Flussi_Collector__c fcoll : fCollList) {
                        flussiCollectorMap.put(fcoll.CRABB_DEV__Collector__c, fcoll);
                    }

                    String CsvString = 'Id Lotto, Tipo Affido,';
                    Integer index = 0;
                    String queryPratField = '';
                    String queryMovField = '';

                    for (CRABB_DEV__ListOfFields__c lof : listOfFieldsList) {
                        index++;
                        CsvString += lof.CRABB_DEV__Object__c + ' ' + lof.CRABB_DEV__Field__c;
                        if (index < listOfFieldsList.size()) {
                            CsvString += ',';
                        } else {
                            CsvString += '\n';
                        }

                        if (lof.CRABB_DEV__Object__c == 'CSV||Account') {
                            if (queryPratField == '') {
                                queryPratField += 'Account__r.' + lof.CRABB_DEV__Field__c;
                            } else {
                                queryPratField += ',Account__r.' + lof.CRABB_DEV__Field__c;
                            }
                        }
                        if (lof.CRABB_DEV__Object__c == 'CSV||Pratica__c') {
                            if (queryPratField == '') {
                                queryPratField += lof.CRABB_DEV__Field__c;
                            } else {
                                queryPratField += ',' + lof.CRABB_DEV__Field__c;
                            }
                        }
                        if (lof.CRABB_DEV__Object__c == 'CSV||Movimento__c') {
                            if (queryMovField == '') {
                                queryMovField += lof.CRABB_DEV__Field__c;
                            } else {
                                queryMovField += ',' + lof.CRABB_DEV__Field__c;
                            }
                        }
                    }

                    String query = 'SELECT ' + queryPratField;
                    if (queryMovField != '') {
                        query += ',(SELECT ' + queryMovField + ' FROM Movimenti__r )';
                    }

                    query += ' FROM CRABB_DEV__Pratica__c WHERE Id in :praList WITH SECURITY_ENFORCED';

                    List<CRABB_DEV__Pratica__c> lPrat;
                    Map<Id, CRABB_DEV__Pratica__c> ptMap;
                    if (Utils.cebCheckFLSPermission('Pratica__c', 'Anzianit_Pratica__c', gd).get('ACCESS')
                            && Utils.cebCheckFLSPermission('Pratica__c', 'Check_In_Lavorazione__c', gd).get('ACCESS')
                            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Esecuzione_Processo_Mensile__c', gd).get('ACCESS')
                            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Blocco__c', gd).get('ACCESS')
                            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Chiusura__c', gd).get('ACCESS')
                            && Utils.cebCheckFLSPermission('Pratica__c', 'Dettaglio_Stato__c', gd).get('ACCESS')
                            && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c', gd).get('ACCESS')
                            && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Incasso_Consolidato__c', gd).get('ACCESS')
                            && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c', gd).get('ACCESS')
                            && Utils.cebCheckFLSPermission('Pratica__c', 'Motivo_Blocco__c', gd).get('ACCESS'))
                    {
                        lPrat = database.query(query);
                        ptMap = new Map<Id, CRABB_DEV__Pratica__c>(lPrat);
                    }

                    List<Attachment> listAttacchments = new List<Attachment>();
                    List<CRABB_DEV__Flussi_Collector__c> fCollectorToUpd = new List<CRABB_DEV__Flussi_Collector__c>();

                    //Iteriamo la collection di pratiche suddivise per lotto
                    for(String idLotto : praticheIdForLotto.keySet()) {
                        List<String> praticheConsiderateList = praticheIdForLotto.get(idLotto);
                        while(praticheConsiderateList.size() > 0) {

                            rowsSize = praticheConsiderateList.size() > 1000 ? 1000 : praticheConsiderateList.size();

                            for(Integer i=rowsSize-1; i>=0; i--) {
                                CRABB_DEV__Pratica__c praticaI = ptMap.get(praticheConsiderateList.get(i));
                                List<CRABB_DEV__Movimento__c> lMov = new List<CRABB_DEV__Movimento__c>();

                                if (!ptMap.get(praticaI.Id).CRABB_DEV__Movimenti__r.isEmpty()) {
                                    lMov = ptMap.get(praticaI.id).CRABB_DEV__Movimenti__r;
                                }

                                if (lMov.size() > 0) {
                                    for (CRABB_DEV__Movimento__c m : lMov) {
                                        CsvString += '"' + idLotto + '","' + tipoAffidamentoMap.get(praticaI.Id) + '",';

                                        for (CRABB_DEV__ListOfFields__c lof : listOfFieldsList) {
                                            if (lof.CRABB_DEV__Object__c == 'CSV||Account') {
                                                CsvString += '"' + praticaI.CRABB_DEV__Account__r.get(lof.CRABB_DEV__Field__c) + '"';
                                            }
                                            if (lof.CRABB_DEV__Object__c == 'CSV||Pratica__c') {
                                                CsvString += '"' + praticaI.get(lof.CRABB_DEV__Field__c) + '"';
                                            }
                                            if (lof.CRABB_DEV__Object__c == 'CSV||Movimento__c') {
                                                CsvString += '"' + m.get(lof.CRABB_DEV__Field__c) + '"';
                                            }
                                            CsvString += ',';
                                        }

                                        CsvString = CsvString.substring(0, CsvString.length() - 1);
                                        CsvString += '\n';
                                    }
                                } else {
                                    CsvString += '"' + idLotto + '","' + tipoAffidamentoMap.get(praticaI.Id) + '",';
                                    for (CRABB_DEV__ListOfFields__c lof : listOfFieldsList) {
                                        if (lof.CRABB_DEV__Object__c == 'CSV||Account') {
                                            CsvString += '"' + praticaI.CRABB_DEV__Account__r.get(lof.CRABB_DEV__Field__c) + '"';
                                        }
                                        if (lof.CRABB_DEV__Object__c == 'CSV||Pratica__c') {
                                            CsvString += '"' + praticaI.get(lof.CRABB_DEV__Field__c) + '"';
                                        }
                                        CsvString += ',';
                                    }
                                    CsvString = CsvString.substring(0, CsvString.length() - 1);
                                    CsvString += '\n';
                                }

                                praticheConsiderateList.remove(i);
                            }

                            CRABB_DEV__Flussi_Collector__c coll = new CRABB_DEV__Flussi_Collector__c();
                            Id flussiCollectorId = flussiCollectorMap.get(lottoMap.get(idLotto).CRABB_DEV__Agenzia_di_Recupero__c).Id;

                            //Creo attachment e lo aggiungo alla lista di attachment
                            Attachment att = new Attachment();
                            att.parentId = flussiCollectorId;
                            att.name = fileNameMap.get(idLotto) + '_' + fileNumber + '.csv';
                            att.body = Blob.valueof(CsvString);
                            listAttacchments.add(att);

                            fileNumber++;
                            coll.CRABB_DEV__Numero_Record__c = praticheConsiderateList.size() > 0 ? praticheConsiderateList.size() : 0;
                            if(coll.CRABB_DEV__Numero_Record__c != 0) {
                                fCollectorToUpd.add(coll);
                            }
                        }

                    }

                    if (Utils.cebCheckFLSPermission('Attachment', 'parentId', gd).get('CREATE') && Utils.cebCheckFLSPermission('Attachment', 'name', gd).get('CREATE')&& Utils.cebCheckFLSPermission('Attachment', 'body', gd).get('CREATE')) {
                        insert listAttacchments;
                    }

                    if (Utils.cebCheckFLSPermission('Flussi_collector__c', 'Collector__c', gd).get('CREATE') && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Lotti_Presenti__c', gd).get('CREATE') && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Numero_Record__c', gd).get('CREATE') && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Tipo__c', gd).get('CREATE')){
                        update fCollectorToUpd;
                    }

                    responseBuilder(praList, 'Done');

                } catch(Exception e){
                    responseBuilder(praList, 'Error');
                    System.debug('Step CSV file for the collectors - Exception *Errore ' + e.getMessage() + ' Dettagli: ' + '\n ' + e.getStackTraceString());
                }

            }*/
            when 'Expectance End' {//Done+Tested
                System.debug('Expectance End');

                try {
                    praticaFieldsList.addAll(mfields.keySet());

                    //query = 'Select '+utils.joinStrings(praticaFieldsList,',')+',(select id,subject,ActivityExtended__c,status,WhatId,description from Tasks where status=\'Ricerca strategia\' and ActivityExtended__c!=null) FROM Pratica__c where id in:praList';
                    //query = 'Select ' + utils.joinStrings(praticaFieldsList, ',') + ',(select id,subject,ActivityExtended__c,ActivityExtended__r.id_attivita__c,ActivityExtended__r.Account_id__c,ActivityExtended__r.isFirst__c,ActivityExtended__r.record_type__c,status,WhatId,description,ActivityExtended__r.code_status__c from Tasks where status=\'Non iniziata\' and ActivityExtended__c!=null and CRABB_DEV__ActivityExtended__r.RecordType.name = \'Expectance\') FROM Pratica__c where id in:praList';
                    query = 'Select ' + utils.joinStrings(praticaFieldsList, ',') + ' FROM Pratica__c where id in:praList';
                    List<Pratica__c> scope = Database.query(String.escapeSingleQuotes(query));


                    //1 - creating pmap, tmap, sobjectsToUpdate
                    dataBuilding(scope, true);

                    //2 - retrieve strategies
                    OrkStatic.cebRetrieveStrategie(gd);

                    //3 - execute first activities
                    //OrkKernel.executeFirstActivities(tMap,pMap, sobjectsToUpdate , sobjectsToInsert,logL );

                    //4 - get all activitiesextended
                    query = 'SELECT ' + Utils.cebGetSOBJECTFieldsForQuery('ActivityExtended__c', gd) + ' FROM ActivityExtended__c WHERE Id in:actExtIdList';
                    if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_affidamento__c', gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_lotto_associato__c', gd).get('UPDATE')) {
                        aes = Database.query(String.escapeSingleQuotes(query));
                    }
                    for (ActivityExtended__c tmp : aes) {
                        aesMap.put(tmp.Id, tmp);
                    }

                    //5 - creating task2obk map
                    for (String tmp : tMap.keySet()) {
                        if (tMap.containsKey(tmp)) task2Obj.put(tmp, aesMap.get(tMap.get(tmp).ActivityExtended__c));
                    }

                    filteredTsksActsExtMap = buildFilteredTasksActivitiesExtMap(task2Obj, tMap);

                    //6 - execute
                    executeActivity(filteredTsksActsExtMap);
                    OrkKernel.cebExecuteExit(gd, 'Task_beforeUpdate', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, task2Obj);
                    OrkKernel.cebExecuteJump(objectForPraticaMap, gd, 'Task_beforeUpdate', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, task2Obj);
                    OrkKernel.cebExecuteLoop(objectForPraticaMap, gd, 'Task_beforeUpdate', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, task2Obj);
                    OrkKernel.cebSetNextJob(objectForPraticaMap, gd, 'Task_beforeUpdate', tMap, pMap, sobjectsToUpdate, sobjectsToInsert, logL, task2Obj);

                    //7 - dml ops
                    doDmlOps();
                    responseBuilder(praList, 'Done');
                } catch (Exception e) {
                    System.debug('CrabbEngineUtils Exception: ' + e.getLineNumber() + ' - ' + e.getMessage());
                    responseBuilder(praList, 'Error');
                }

            }
            when 'Transaction Dossier Status Update' {//Done
                System.debug('Transaction Dossier Status Update');
                try {
                    String query = 'SELECT Stato_Pratiica_Picklist__c,Pratica__r.Stato__c FROM Movimento__c WHERE Pratica__c IN :praList';
                    List<CRABB_DEV__Movimento__c> movList = Database.query(String.escapeSingleQuotes(query));

                    List<CRABB_DEV__Movimento__c> movToUpd = new List<CRABB_DEV__Movimento__c>();
                    if (movList != null && !movList.isEmpty()) {
                        for (CRABB_DEV__Movimento__c m : movList) {

                            if (m.CRABB_DEV__Stato_Pratiica_Picklist__c != null &&
                                    m.CRABB_DEV__Pratica__r.CRABB_DEV__Stato__c != null &&
                                    !m.CRABB_DEV__Stato_Pratiica_Picklist__c.equalsIgnoreCase(m.CRABB_DEV__Pratica__r.CRABB_DEV__Stato__c)) {

                                m.CRABB_DEV__Stato_Pratiica_Picklist__c = m.CRABB_DEV__Pratica__r.CRABB_DEV__Stato__c;
                                movToUpd.add(m);
                            } else if ((m.CRABB_DEV__Stato_Pratiica_Picklist__c == null || String.isBlank(m.CRABB_DEV__Stato_Pratiica_Picklist__c)) && m.CRABB_DEV__Pratica__r.CRABB_DEV__Stato__c != null) {
                                m.CRABB_DEV__Stato_Pratiica_Picklist__c = m.CRABB_DEV__Pratica__r.CRABB_DEV__Stato__c;
                                movToUpd.add(m);
                            }
                            //if(movToUpd != null && movToUpd.size() == 1000){
                            if (movToUpd != null && movToUpd.size() == 1000
                                    && Utils.cebCheckObjPermission('Movimento__c', gd).get('UPDATE')
                                    && Utils.cebCheckFLSPermission('Movimento__c', 'Stato_Pratiica_Picklist__c', gd).get('UPDATE')) {
                                update movToUpd;
                                movToUpd.clear();
                            }
                        }
                        if (movToUpd != null && movToUpd.size() > 0
                                && Utils.cebCheckObjPermission('Movimento__c', gd).get('ACCESS')
                                && Utils.cebCheckObjPermission('Movimento__c', gd).get('UPDATE')) {
                            update movToUpd;
                        }

                        responseBuilder(praList, 'Done');
                    }
                } catch (Exception e) {
                    responseBuilder(praList, 'Error');
                }
            }
        /*when 'Assignment Costs Update' {
            System.debug('Assignment Costs Update');

            String Query = 'Select Id, CRABB_DEV__Incasso_periodo_affidamento__c, CRABB_DEV__Incasso_periodo_proroga_piani_di_rientro__c, CRABB_DEV__Incasso_periodo_affidamento_False__c, ' +
                    'CRABB_DEV__Incasso_periodo_proroga_PDR_False__c, CRABB_DEV__Data_Affidamento__c, CRABB_DEV__Data_fine_affidamento_prevista__c, CRABB_DEV__Incassi_aggiornati__c ' +
                    'From CRABB_DEV__Affidamento__c Where CRABB_DEV__Incassi_aggiornati__c=false and CRABB_DEV__Pratica__c in :praList';

            List<CRABB_DEV__Affidamento__c> affList = Database.query(query);

            AffidiIncassiUpdateBatch.affidamentiAggiornaIncassi((List<Affidamento__c>) affList);

        }*/
        }

        return statusMap;
    }

    /* Restituisce una Map<String, SObject> dove l'oggetto può essere Account o Servizio.
       La chiave, per evitare sovrascritture, è una chiave composta da pratica Id concatenata al tipo di oggetto
       (_serivzio oppure _account)
    */
    public static Map<String, SObject> generateMapsFieldUpdate(List<Pratica__c> praList, Map<String, SObjectType> gd) {
        SObjectType typeAccount = gd.get('Account');
        Map<String, Schema.SObjectField> mfieldsAccount = typeAccount.getDescribe().fields.getMap();

        SObjectType typeServizio = gd.get(Utils.NAMESPACE + 'Servizio__c');
        Map<String, Schema.SObjectField> mfieldsService = typeServizio.getDescribe().fields.getMap();

        List<String> accIds = new List<String>();
        List<String> servIds = new List<String>();
        for (Pratica__c pra : praList) {
            if (pra.CRABB_DEV__Account__c != null) {
                accIds.add(pra.Account__c);
            }
            if (pra.CRABB_DEV__Servizio_Fornitura__c != null) {
                servIds.add(pra.CRABB_DEV__Servizio_Fornitura__c);
            }
        }

        String fieldsService = objectFieldsForQuery(mfieldsService.keySet());
        String fieldsAccount = objectFieldsForQuery(mfieldsAccount.keySet());

        String queryServizio = 'Select ' + fieldsService + ' from Servizio__c where Id in :servIds';
        String queryAccount = 'Select ' + fieldsAccount + ' from Account where Id in :accIds';

        List<Account> accList = new List<Account>();
        List<Servizio__c> servList = new List<Servizio__c>();

        if (accIds.size() > 0) {
            accList = Database.query(String.escapeSingleQuotes(queryAccount));
        }
        if (servIds.size() > 0) {
            servList = (List<Servizio__c>) Database.query(String.escapeSingleQuotes(queryServizio));
        }

        Map<Id, Account> accMap = new Map<Id, Account>();
        Map<Id, Servizio__c> servMap = new Map<Id, Servizio__c>();

        if (accList.size() > 0) {
            accMap = new Map<Id, Account>(accList);
        }
        if (servList.size() > 0) {
            servMap = new Map<Id, Servizio__c>(servList);
        }

        Map<String, SObject> objectForPraticaMap = new Map<String, SObject>();
        for (Pratica__c pra : praList) {
            if (accMap.containsKey(pra.Account__c) && pra.Account__c != null) {
                objectForPraticaMap.put(pra.Account__c + '_' + accMap.get(pra.Account__c).getSObjectType().getDescribe().name, accMap.get(pra.Account__c));
            }
            if (servMap.containsKey(pra.CRABB_DEV__Servizio_Fornitura__c) && pra.CRABB_DEV__Servizio_Fornitura__c != null) {
                objectForPraticaMap.put(pra.CRABB_DEV__Servizio_Fornitura__c + '_' + servMap.get(pra.CRABB_DEV__Servizio_Fornitura__c).getSObjectType().getDescribe().name, servMap.get(pra.CRABB_DEV__Servizio_Fornitura__c));
            }
        }

        return objectForPraticaMap;
    }

    public void responseBuilder(List<Pratica__c> scope, String status) {
        list<CRABB_DEV__CEB__c> cebL = new list<CRABB_DEV__CEB__c>();
        for (Pratica__c prat : scope) {
            cebL.addAll(prat.CRABB_DEV__Crabb_Events__r);
        }

        for (CRABB_DEV__CEB__c c : cebL) {
            statusMap.put(c.id, status);
        }
    }

    public void responseBuilder(Map<String, List<CRABB_DEV__CEB__c>> accountEventsMap, Map<String, List<CRABB_DEV__CEB__c>> accountEventsErrMap) {
        String status;
        for (String key : accountEventsMap.keySet()) {
            status = accountEventsErrMap.containsKey(key) ? 'Error' : 'New';
            for (CRABB_DEV__CEB__c cb : accountEventsMap.get(key)) {
                statusMap.put(cb.id, status);
            }
        }
    }

    public void dataBuilding(List<Pratica__c> scope) {
        for (Pratica__c p : scope) {
            pMap.put(p.id, p);
            if (p.Tasks.size() > 0) {
                tMap.put(p.Tasks[0].id, p.Tasks[0]);
                sobjectsToUpdate.put(p.Tasks[0].id, p.Tasks[0]);
                if (p.Tasks[0].ActivityExtended__c != null) actExtIdList.add(p.Tasks[0].ActivityExtended__c);
            }
            sobjectsToUpdate.put(p.id, p);
        }
    }

    public void dataBuilding(List<Pratica__c> scope, Boolean queryTask) {
        for (Pratica__c p : scope) {
            pMap.put(p.id, p);
            if (p.Tasks.size() > 0 && !queryTask) {
                tMap.put(p.Tasks[0].id, p.Tasks[0]);
                sobjectsToUpdate.put(p.Tasks[0].id, p.Tasks[0]);
                if (p.Tasks[0].ActivityExtended__c != null) actExtIdList.add(p.Tasks[0].ActivityExtended__c);
            }
            sobjectsToUpdate.put(p.id, p);
        }
        if (queryTask) {
            for (Task t : [
                    select id, subject, ActivityExtended__c, ActivityExtended__r.id_attivita__c,
                            ActivityExtended__r.Account_id__c, ActivityExtended__r.isFirst__c, ActivityExtended__r.record_type__c,
                            status, WhatId, description, ActivityExtended__r.id_Strategia__c, ActivityExtended__r.code_status__c
                    from Task
                    where status in ('Non Iniziata', 'Lavorata') and ActivityExtended__c != null and WhatId in :scope
                    WITH SECURITY_ENFORCED
            ]) {
                tMap.put(t.id, t);
                sobjectsToUpdate.put(t.id, t);
                if (t.ActivityExtended__c != null)
                    actExtIdList.add(t.ActivityExtended__c);
            }
        }
    }

    public void doDmlOps() {
        if (sobjectsToInsert.size() > 0) {
            sobjectsToInsert = Utils.sortTaskActivities(sobjectsToInsert);
            insert sobjectsToInsert;
        }
        if (sobjectsToUpdate.keyset() != null && sobjectsToUpdate.keyset().size() > 0) {
            //update sobjectsToUpdate.Values();
            update Utils.sortTaskActivities(sobjectsToUpdate.Values());
        }
    }

    public ContentVersion createContentVersion(String name, String body, String oId) {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S';
        contentVersion.PathOnClient = name;
        contentVersion.Title = name;
        contentVersion.Description = oId;
        contentVersion.VersionData = EncodingUtil.base64Decode(body);
        return contentVersion;
    }

    public ContentDocumentLink createContentDocumentLink(Id contentDocumentId, Id parentId) {
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentDocumentId;
        contentDocumentLink.LinkedEntityId = parentId;
        contentDocumentLink.ShareType = 'I';
        return contentDocumentLink;
    }

    /* Commentato provvisoriamente
    public List<sObject> buildMessage(List<Pratica__c> praList) {
        List<CRABB_DEV__CRABB_Sollecito__mdt> Soll;

        Soll = [SELECT MasterLabel, CRABB_DEV__Template__c, CRABB_DEV__Tipo_Sottotipo__c,  CRABB_DEV__Type__c, CRABB_DEV__Sender__c,CRABB_DEV__Language__c
        FROM CRABB_DEV__CRABB_Sollecito__mdt WHERE CRABB_DEV__Active__c = true];

        alpha2ToAlpha3 = new Map<String, String>();
        for(CRABB_DEV__CRABB_Languages__mdt r : [SELECT CRABB_DEV__Alpha2__c, CRABB_DEV__Alpha3__c FROM CRABB_DEV__CRABB_Languages__mdt]) {
            alpha2ToAlpha3.put(r.CRABB_DEV__Alpha2__c, r.CRABB_DEV__Alpha3__c);
        }

        if(Soll.size()>0) {
            for (CRABB_DEV__CRABB_Sollecito__mdt s : Soll) {
                mSender.put(s.CRABB_DEV__Tipo_Sottotipo__c, s.CRABB_DEV__Sender__c);
                mType.put(s.CRABB_DEV__Tipo_Sottotipo__c, s.CRABB_DEV__Type__c);

                mTemplate.put(s.CRABB_DEV__Tipo_Sottotipo__c + '_' + s.CRABB_DEV__Language__c, s.CRABB_DEV__template__c);
                mTemplateRev.put(s.CRABB_DEV__template__c, s.CRABB_DEV__Tipo_Sottotipo__c + '_' + s.CRABB_DEV__Language__c);
            }

            system.debug(mTemplate.values());
            List<EmailTemplate> lTemplate = [select Id,Name from EmailTemplate where Name IN :mTemplate.values()];
            system.debug(lTemplate);

            for (EmailTemplate et : lTemplate) {
                system.debug(et.Name);
                system.debug(et.Id);
                mTemplateId.put(mTemplateRev.get(et.Name), et.Id);
                System.debug('mTemplateId: ' + mTemplateId);
            }
        }

        string queryTsk = 'select Id,WhatId,Status,CRABB_DEV__ActivityExtended__c';
        queryTsk += ' FROM task';
        queryTsk += ' WHERE WhatId in: praList AND CRABB_DEV__ActivityExtended__r.CRABB_DEV__code_status__c = \'Non iniziata\'';
        for(Integer i=0; i < lPDF.size(); i++)
        {
            if(i == 0)
                queryTsk += ' AND (CRABB_DEV__ActivityExtended__r.CRABB_DEV__Tipo_Sottotipo__c = \'' + Soll[i].CRABB_DEV__Tipo_Sottotipo__c + '\'';
            else
                    queryTsk += ' OR CRABB_DEV__ActivityExtended__r.CRABB_DEV__Tipo_Sottotipo__c = \'' + Soll[i].CRABB_DEV__Tipo_Sottotipo__c + '\'';
        }
        queryTsk += ') WITH SECURITY_ENFORCED LIMIT 50000';

        taskForSendMessage = Database.query(queryTsk);

        List<string> aeidList = new List<string>();
        for(task t : taskForSendMessage){
            aeidList.add(t.CRABB_DEV__ActivityExtended__c);
        }

        List<CRABB_DEV__ActivityExtended__c> aeList = [SELECT ID,CRABB_DEV__IdAccount__c,CRABB_DEV__Carrier__c,CRABB_DEV__Carrier_del_date__c,
                CRABB_DEV__Carrier_status_activation_code__c,CRABB_DEV__Carrier_status_description__c,CRABB_DEV__Message_Email__c, CRABB_DEV__Message_Error__c,
                CRABB_DEV__Message_UniqueID__c,CRABB_DEV__Message_Body__c,CRABB_DEV__Esito__c, CRABB_DEV__Message_Phone_Number__c,CRABB_DEV__Message_Send_Date__c,
                CRABB_DEV__Scaduto_iniziale__c, CRABB_DEV__Message_SentId__c,CRABB_DEV__Message_Status__c,CRABB_DEV__Message_Type__c,CRABB_DEV__Tipo_Sottotipo__c
        From CRABB_DEV__ActivityExtended__c WHERE ID IN :aeidList AND CRABB_DEV__code_status__c = 'Non iniziata'  AND CRABB_DEV__Message_Status__c != 'Sent' WITH SECURITY_ENFORCED];

        List<Id> lIdAcc = new List<Id>();
        List<Id> lIdAe = new List<Id>();

        for(CRABB_DEV__ActivityExtended__c ae : aeList)
        {
            lIdAcc.add(ae.CRABB_DEV__IdAccount__c);
            lIdAe.add(ae.Id);
        }

        accountsForMessage = [SELECT Id, CRABB_DEV__CRABB_Mobile_Phone__c, CRABB_DEV__CRABB_Email__c,CRABB_DEV__CRABB_Email_PEC__c,
                CRABB_DEV__Preferred_Language_for_Communications__c FROM Account where Id IN :lIdAcc WITH SECURITY_ENFORCED ];

        mapAccountForMessage = new Map<Id, Account>(accountsForMessage);
        mapPraticheForMessage = new Map<Id, CRABB_DEV__Pratica__c>(praList);

        return aeList;
    }

    private Id getEmailTemplateId(String sottotipo, String lingua_alpha2)
    {
        System.Debug('getEmailTemplateId: ' + mTemplate + ' - ' +  sottotipo + ' - ' + lingua_alpha2 + ' - ' + alpha2ToAlpha3.get(lingua_alpha2.touppercase()) + ' - ' + alpha2ToAlpha3);
        Id templateId = mTemplateId.get(sottotipo + '_' + alpha2ToAlpha3.get(lingua_alpha2.touppercase()));
        System.debug(sottotipo + '_' + alpha2ToAlpha3.get(lingua_alpha2.touppercase()) + ' **** ' + templateId);
        if(templateId == null)
        {
            return mTemplateId.get(sottotipo + '_' + 'ITA');
        }
        return templateId;
    }*/

    /*executeActivity
    * il metodo esegue le attività associate al singolo record, clusterizza i task
    * per attività nella mappa activityTask ed elabora i task per attività.
    * la classe non è definitiva
    */
    private void executeActivity(Map<Id, ActivityExtended__c> filteredTskActExtMap) {
        Map<String, Map<String, Task>> activityTask = getTaskActivityMap(tMap, pMap, filteredTskActExtMap);
        logL.add(ErrorClass.istanceError('999999', 'Ork : executeActivity activityTask = ' + activityTask));
        if (activityTask == null) return;
        for (String s : activityTask.keySet()) {
            //logL.add(errorClass.istanceError('999999','Ork : executeActivity s = ' + s));
            //Map<String, String> result = OrkActivities.execute(s, activityTask.get(s), pMap, logL, filteredTskActExtMap);
            Map<String, String> result = OrkActivities.cebExecute(s, activityTask.get(s), pMap, logL, filteredTskActExtMap, gd);
            Map<String, Task> tMapProcessed = activityTask.get(s);
            //Map<Id, ActivityExtended__c> taskId2Obj = Utils.getTaskWithActivityExtended(tMapProcessed.values());
            for (String tsk : tMapProcessed.keySet()) {
                Task t = tMap.get(tsk);
                //ActivityExtended__c ae = taskId2Obj.get(t.Id);
                ActivityExtended__c ae = filteredTskActExtMap.get(t.Id);
                Pratica__c pratica = pMap.get(t.WhatId);
                if (t.Status == 'Lavorata') {
                    OrkBL.setActivitySuccess(t, ae, pratica, 'OK');
                }
            }
        }
    }

    //This method filters the global TaskIds - Activities Extended Map, excluding items not contained in tMap.
    private Map<Id, ActivityExtended__c> buildFilteredTasksActivitiesExtMap(Map<Id, ActivityExtended__c> tskActExtMap, Map<String, Task> tMap) {
        Map<Id, ActivityExtended__c> filteredTsksActsExtMap = new Map<Id, ActivityExtended__c>();

        if (tskActExtMap == null) {
            //filteredTsksActsExtMap = Utils.getTaskWithActivityExtended(tMap.values());
            filteredTsksActsExtMap = Utils.cebGetTaskWithActivityExtended(tMap.values(), gd);
        } else {
            for (Task tsk : tMap.values()) {
                if (tskActExtMap.get(tsk.Id) != null) {
                    filteredTsksActsExtMap.put(tsk.Id, tskActExtMap.get(tsk.Id));
                }
            }
        }

        return filteredTsksActsExtMap;
    }

    private Map<String, Map<String, Task>> getTaskActivityMap(Map <String, Task> tasksMap, Map <String, Pratica__c> pMap, Map<Id, ActivityExtended__c> filteredTskActExtMap) {
        Map<String, Map<String, Task>> actExTypeTaskMap = new Map<String, Map<String, Task>>();
        if (tasksMap.keySet() == null || tasksMap.keySet().size() == 0) return null;
        //Map<Id, ActivityExtended__c> taskActExMap = Utils.getTaskWithActivityExtended(tasksMap.values());
        Map<Id, ActivityExtended__c> taskActExMap = filteredTskActExtMap;
        //List<ActivityExtended__c> aelist = new List<ActivityExtended__c>();
        for (String tskId : tasksMap.keySet()) {
            Task t = tasksMap.get(tskId);
            ActivityExtended__c ae = taskActExMap.get(t.Id);
            //logL.add(errorClass.istanceError('999999','Ork : getTaskActivityMap isTaskForActivity: !t.ActivityExtended__r.isFirst__c &&  t.status!=Error &&  t.status!=In approvazione && t.status!=Exit && t.status!=Saltato && t.status!=Saltata && t.ActivityExtended__r.Activity__c!=null =' + !t.ActivityExtended__r.isFirst__c + t.status + t.ActivityExtended__r.Activity__c + t.ActivityExtended__r.Record_Type__c));
            if (!OrkBL.isTaskForActivity(t, ae)) {
                // ae.code_status__c+='_NoActivity';
                sobjectsToUpdate.put(ae.Id, ae);
                //logL.add(errorClass.istanceError('999999','Ork : getTaskActivityMap sobjectsToUpdate 1'));
                continue;
            } else {
                //   ae.code_status__c+='_inActivity';
                sobjectsToUpdate.put(ae.Id, ae);
                //logL.add(errorClass.istanceError('999999','Ork : getTaskActivityMap sobjectsToUpdate 2'));
            }
            if (t.Status == 'Lavorata') {
                OrkBL.setActivitySuccess(t, ae, pMap.get(t.WhatId), 'OK');
                //logL.add(errorClass.istanceError('999999','Ork : getTaskActivityMap Lavorata'));
                continue;
            }
            //if(activ.get(t.ActivityExtended__r.activity__c)==null)
            if (actExTypeTaskMap.get(ae.Activity__c) == null) {
                //logL.add(errorClass.istanceError('999999','Ork : activity__c null'));
                //activ.put(t.ActivityExtended__r.activity__c, new map<string,Task>());
                actExTypeTaskMap.put(ae.Activity__c, new Map<String, Task>());
            }
            logL.add(ErrorClass.istanceError('999999', 'Ork : getTaskActivityMap Activ:' + ae.Activity__c + ' - ' + tskId));
            //activ.get(t.ActivityExtended__r.activity__c).put(s,t);
            actExTypeTaskMap.get(ae.Activity__c).put(tskId, t);
        }
        logL.add(ErrorClass.istanceError('999999', 'Ork : getTaskActivityMap activ = ' + actExTypeTaskMap));
        return actExTypeTaskMap;
    }

    //This method close the tasks retrieved updating field Status to 'Lavorata'
    public static void setTasksToWorked(List<id> aeList) {
        List<Task> TaskList = [
                select id, Status
                from task
                where CRABB_DEV__ActivityExtended__c in :aeList
                WITH SECURITY_ENFORCED
        ];
        for (Task t : TaskList) {
            t.status = 'Lavorata';
        }
        update TaskList;
    }

    public static String objectFieldsForQuery(Set<String> objectFields) {
        Set<String> mFieldsSet = new Set<String>();
        String newField;
        for (String str : objectFields) {
            if (str.toUpperCase().containsIgnoreCase(Utils.NAMESPACE.toUpperCase())) {
                newField = str.toUpperCase().remove(Utils.NAMESPACE.toUpperCase());
            } else {
                newField = str.toUpperCase();
            }

            if (!mFieldsSet.contains(newField.toUpperCase())) {
                mFieldsSet.add(newField.toUpperCase());
            }
        }

        return utils.joinStrings(mFieldsSet, ',');
    }

    public static Map<String, List<Step_Field_Update__c>> getStepFieldUpdates() {
        Map<String, List<Step_Field_Update__c>> mapStepFieldUpdates = new Map<String, List<Step_Field_Update__c>>();
        List<CRABB_DEV__Strategia__c> testate = [
                select id
                from CRABB_DEV__Strategia__c
                where CRABB_DEV__Stato__c = 'Attiva'
                WITH SECURITY_ENFORCED
        ];
        List<CRABB_DEV__Strategia__c> strategie = [
                select id, CRABB_DEV__Testata__c, CRABB_DEV__Nome__c, CRABB_DEV__Stato__c
                from CRABB_DEV__Strategia__c
                where CRABB_DEV__Testata__c = :testate
                WITH SECURITY_ENFORCED
        ];

        List<Step_Field_Update__c> stepFieldUpdatesList = [
                SELECT id, CRABB_DEV__Strategia__c, CRABB_DEV__Object__c, CRABB_DEV__Field__c,
                        CRABB_DEV__Text_Value__c, CRABB_DEV__Number_Value__c, CRABB_DEV__Checkbox_Value__c, CRABB_DEV__Date_Value__c,
                        CRABB_DEV__Days_to_Add_or_Remove__c, CRABB_DEV__Type__c, CRABB_DEV__Trigger__c
                from CRABB_DEV__Step_Field_Update__c
                where CRABB_DEV__Strategia__c in :strategie
                WITH SECURITY_ENFORCED
        ];

        for (Step_Field_Update__c step : stepFieldUpdatesList) {
            List<Step_Field_Update__c> stepList = new List<Step_Field_Update__c>();
            String key = String.valueOf(step.CRABB_DEV__Strategia__c) + '~' + String.valueOf(step.CRABB_DEV__Trigger__c);
            if (mapStepFieldUpdates.containsKey(key)) {
                stepList = mapStepFieldUpdates.get(key);
            }
            stepList.add(step);
            mapStepFieldUpdates.put(key, stepList);
        }

        return mapStepFieldUpdates;
    }

}