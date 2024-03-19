/**
 * Modded by F.Suraci - Aggiunta parte relativa a MailUP
 */
global class CRABB_Batch_Solleciti_MailUP implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
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
    
    List<CRABB_DEV__CRABB_Sollecito__mdt> Soll     {get;set;}
    Map<String,String> mSender                          {get;set;}
    Map<String,String> mType                            {get;set;}
    Map<String,String> mTemplate                        {get;set;}
    Map<String,String> mTemplateRev                     {get;set;}
    Map<String,String> mTemplateId                      {get;set;}
    Map<String,String> alpha2ToAlpha3                   {get;set;}
  
    
    // MailUp inizio aggiunta
    CRABBSENDER_MailUP csToken;
    String token_mailup;
    // MailUp fine aggiunta

    global CRABB_Batch_Solleciti_MailUP()
    {
        mSender = new Map<String,String>();
        mType = new Map<String,String>();
        mTemplate = new Map<String,String>();
        mTemplateRev = new Map<String,String>();
        mTemplateId = new Map<String,String>();
        
        // MAilUp inizio aggiunta
        csToken= new CRABBSENDER_MailUP();
        token_mailup=csToken.getToken();
        // MailUp fine aggiunta

        Soll = [SELECT
                    MasterLabel, CRABB_DEV__Template__c, CRABB_DEV__Tipo_Sottotipo__c,
                    CRABB_DEV__Type__c, CRABB_DEV__Sender__c,CRABB_DEV__Language__c
                FROM
                    CRABB_DEV__CRABB_Sollecito__mdt
                WHERE
                    CRABB_DEV__Active__c = true];
        /*Alessio Massidda: ISSUE #52*/
        alpha2ToAlpha3 = new Map<String, String>();
        for(CRABB_DEV__CRABB_Languages__mdt r : [SELECT CRABB_DEV__Alpha2__c, CRABB_DEV__Alpha3__c FROM CRABB_DEV__CRABB_Languages__mdt])
        {
            alpha2ToAlpha3.put(r.CRABB_DEV__Alpha2__c, r.CRABB_DEV__Alpha3__c);
        }
        /* */

        if(Soll.size()>0)
        {
            for(CRABB_DEV__CRABB_Sollecito__mdt s : Soll)
            {
                mSender.put(s.CRABB_DEV__Tipo_Sottotipo__c,s.CRABB_DEV__Sender__c);
                mType.put(s.CRABB_DEV__Tipo_Sottotipo__c,s.CRABB_DEV__Type__c);

                /*Alessio Massidda: ISSUE #52*/
                //mTemplate.put(s.Tipo_Sottotipo__c,s.Template__c);
                //mTemplateRev.put(s.Template__c,s.Tipo_Sottotipo__c);
                //ho commentato le righe sopra perché non vi era distinzione di lingua nella mappa
                mTemplate.put(s.CRABB_DEV__Tipo_Sottotipo__c + '_' + s.CRABB_DEV__Language__c, s.CRABB_DEV__template__c);
                mTemplateRev.put(s.CRABB_DEV__template__c, s.CRABB_DEV__Tipo_Sottotipo__c + '_' + s.CRABB_DEV__Language__c);
                /* */
            }

            system.debug(mTemplate.values());
            List<EmailTemplate> lTemplate = [select Id,Name from EmailTemplate where Name IN : mTemplate.values()];
            system.debug(lTemplate);

            for(EmailTemplate et : lTemplate)
            {
                system.debug(et.Name);
                system.debug(et.Id);
                mTemplateId.put(mTemplateRev.get(et.Name),et.Id);
                System.debug('mTemplateId: ' + mTemplateId);
            }
           
            query = 'SELECT ID,CRABB_DEV__IdAccount__c,CRABB_DEV__Carrier__c,CRABB_DEV__Carrier_del_date__c,';
            query += 'CRABB_DEV__Carrier_status_activation_code__c,CRABB_DEV__Carrier_status_description__c,CRABB_DEV__Message_Email__c,';
            query += 'CRABB_DEV__Message_Error__c,CRABB_DEV__Message_UniqueID__c,CRABB_DEV__Message_Body__c,CRABB_DEV__Esito__c,';
            query += 'CRABB_DEV__Message_Phone_Number__c,CRABB_DEV__Message_Send_Date__c,CRABB_DEV__Scaduto_iniziale__c,';
            query += 'CRABB_DEV__Message_SentId__c,CRABB_DEV__Message_Status__c,CRABB_DEV__Message_Type__c,CRABB_DEV__Tipo_Sottotipo__c';
            query += ' From CRABB_DEV__ActivityExtended__c';
            query += ' WHERE CRABB_DEV__code_status__c = \'Non iniziata\'';
            query += ' AND CRABB_DEV__Message_Status__c != \'Sent\'';
            for(Integer i=0; i < Soll.size(); i++)
            {
                if(i == 0)
                    query += ' AND (CRABB_DEV__Tipo_Sottotipo__c = \'' + Soll[i].CRABB_DEV__Tipo_Sottotipo__c + '\'';
                else
                        query += ' OR CRABB_DEV__Tipo_Sottotipo__c = \'' + Soll[i].CRABB_DEV__Tipo_Sottotipo__c + '\'';
            }
            query += ') LIMIT 50000';
        }
        
       
        //   system.debug('query è :' + querytest);
        system.debug(query);
        system.debug(mSender);
        system.debug(mType);
        system.debug(mTemplateId);
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {    
   
        System.debug(query);
 
        System.debug('sono nello start');
        if(Soll.size()>0 && !CEBUtils.newOrkVersionEnabled())
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
        System.debug('sono in execute');
        List<CRABB_DEV__ActivityExtended__c> temp_recordsOfTransaction = (List<CRABB_DEV__ActivityExtended__c>) scope;
        List<Id> lIdAcc = new List<Id>();
        List<Id> lIdAe = new List<Id>();
        /*Alessio Massidda: ISSUE #46*/
        Set<Id> lIdPrat = new Set<Id>();
        /* */

        for(CRABB_DEV__ActivityExtended__c ae : temp_recordsOfTransaction)
        {
            lIdAcc.add(ae.CRABB_DEV__IdAccount__c);
            lIdAe.add(ae.Id);
        }

        System.debug('lIdAcc: ' + lIdAcc);
        System.debug('lIdAe: ' + lIdAe);

        List<Account> lAcc = [SELECT
                                    Id, CRABB_DEV__CRABB_Mobile_Phone__c,
                                    CRABB_DEV__CRABB_Email__c, CRABB_DEV__CRABB_Email_PEC__c, CRABB_DEV__Preferred_Language_for_Communications__c
                                FROM Account where Id IN :lIdAcc];
        /*Alessio Massidda: ISSUE #52*/
        Map<Id, Account> mapAcc = new Map<Id, Account>(lAcc);
        /* */
        lT = [Select Id,Status,CRABB_DEV__ActivityExtended__c,WhatId FROM Task Where CRABB_DEV__ActivityExtended__c IN :lIdAe];

        /*Alessio Massidda: ISSUE #46*/
        for(task t : lt)
        {
            lIdprat.add(t.whatId);
        }
        Map<Id, CRABB_DEV__Pratica__c> mapPrat = new Map<Id, CRABB_DEV__Pratica__c>(
            [SELECT CRABB_DEV__Data_Invio_Sollecito__c, CRABB_DEV__Data_ultimo_invio_AR__c,
                    CRABB_DEV__EC_Account__c,CRABB_DEV__EC_Pratica__c
            FROM CRABB_DEV__Pratica__c WHERE ID IN :lIdprat]
        );
        /* */

        List<CRABB_DEV__ActivityExtended__c> lAEUpd = new List<CRABB_DEV__ActivityExtended__c>();
        List<Task> lTUpd = new List<Task>();

        for(CRABB_DEV__ActivityExtended__c ae : temp_recordsOfTransaction)
        {
            for(Account a : lAcc)
            {
                if(ae.CRABB_DEV__IdAccount__c == a.Id)
                {
                    if(mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c) == 'EMAIL')
                    {
                        ae.CRABB_DEV__Message_Email__c = a.CRABB_DEV__CRABB_Email__c;
                        ae.CRABB_DEV__Message_UniqueID__c = ae.Id;
                        ae.CRABB_DEV__Carrier__c = 'AWS_EMAIL';
                    }// MailUP - inizio aggiunta -
                    if(mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c) == 'MAILUP')
                    {
                        ae.CRABB_DEV__Message_Email__c = a.CRABB_DEV__CRABB_Email_PEC__c;
                        ae.CRABB_DEV__Message_UniqueID__c = ae.Id;
                        ae.CRABB_DEV__Carrier__c = 'MAILUP';
                    }// MailUP - fine aggiunta
                    else if(mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c) == 'SMS')
                    {
                        ae.CRABB_DEV__Message_Phone_Number__c = a.CRABB_DEV__CRABB_Mobile_Phone__c;
                        ae.CRABB_DEV__Message_UniqueID__c = ae.Id;
                        ae.CRABB_DEV__Carrier__c = 'AWS_SMS';
                    }
                    break;
                }
            }

            for(Task t : lT)
            {
                //MailUP - inizio aggiunta - 
                if(t.CRABB_DEV__ActivityExtended__c == ae.Id &&  mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c) == 'MAILUP')
                {
                    System.debug('Sono entrato nella parte di MAILUP');
                    CRABBSENDER_MailUP csMailUp = new CRABBSENDER_MailUP();
                    csMailUp.token = token_mailup;
                    System.debug('creato  CRABBSENDER_MailUP csMailUp . Token: ' + csMailUp.token );
                    CRABBSENDER_MailUP.CrabbMessageMailUp cmMailUp = new CRABBSENDER_MailUP.CrabbMessageMailUp();
                  
                    System.debug('creato  CRABBSENDER_MailUP cmMailUp');
                    
                    ae.CRABB_DEV__Carrier_status_activation_code__c = mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c);
                    ae.CRABB_DEV__Message_Type__c = 'MAILUP';
                    System.debug('mTemplateId: ' + mTemplateId);
                    System.debug('ae.CRABB_DEV__Tipo_Sottotipo__c :' + ae.CRABB_DEV__Tipo_Sottotipo__c);
                    System.debug('getEmailTemplateId: ' + mapAcc.get(ae.CRABB_DEV__IdAccount__c).CRABB_DEV__Preferred_Language_for_Communications__c + ' - ' + mapAcc);
                 
                    Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(getEmailTemplateId(ae.CRABB_DEV__Tipo_Sottotipo__c, mapAcc.get(ae.CRABB_DEV__IdAccount__c).CRABB_DEV__Preferred_Language_for_Communications__c), UserInfo.getUserId(), t.WhatId);
                    System.debug('email.getPlainTextBody: ' + email.getPlainTextBody());
                            
                    //valorizzo i fields necessari per MailUp
                    cmMailUp.Subject= email.getSubject();
                    System.debug('Email Subject: ' +   cmMailUp.Subject);
                    cmMailUp.IsConfirmation= false;
                    cmMailUp.Notes='';
                    cmMailUp.UseDynamicField= false;
                    cmMailUp.Embed=false;
                    cmMailUp.PreHeader='';
                    CRABBSENDER_MailUP.TrackingInfo  TrackingInfo =   new  CRABBSENDER_MailUP.TrackingInfo();
                    cmMailUp.TrackingInfo= TrackingInfo;

                    String body = email.gethtmlBody();
                    System.debug('BODY 1:' + body);
                    body = body.replace('[$CRABB_EC_Account]',mapPrat.get(t.whatId).CRABB_DEV__EC_Account__c);
                    System.debug('BODY 2:' + body);
                    body = body.replace('[$CRABB_EC_Pratica]',mapPrat.get(t.whatId).CRABB_DEV__EC_Pratica__c);
                    System.debug('BODY 3:' + body);
                    cmMailUp.Content= body;
                    System.debug('Email body:' + cmMailUp.Content);
                    cmMailUp.Email = ae.CRABB_DEV__Message_Email__c;
                    System.debug('Email destinatario:' +   cmMailUp.Email);
                    ae.CRABB_DEV__Message_Body__c = cmMailUp.Content;
                    
                    // Create Message
                    csMailUp.createMessage(cmMailUp);
                    cmMailUp.idMessage= csMailUp.IDMessage;
                    System.debug('IdMessage:' +  cmMailUp.idMessage);

                    // 22/09/2020  start update - in case of template creation error, no message is sent
                    if(null==cmMailUp.idMessage){
                        ae.CRABB_DEV__Message_Status__c = 'Error';
                        ae.CRABB_DEV__Esito__c = 'Errore sulla creazione del template';
                        ae.CRABB_DEV__Message_Error__c = 'Errore sulla creazione del template, messaggio non inviato';
                        lAEUpd.add(ae);
                        break;
                    }
                    // 22/09/2020  end update

                    // Send Message
                    String resultSendMail= csMailUp.sendToRecipient(cmMailUp);                 
                    System.debug('MAilUp_RESPONSE:'+resultSendMail);
                    
                    if(resultSendMail.contains('Error'))
                    {
                        ae.CRABB_DEV__Message_Status__c = 'Error';
                        ae.CRABB_DEV__Esito__c = 'Messaggio in errore';
                        ae.CRABB_DEV__Message_Error__c = resultSendMail;
                    }
                    else
                    {
                        ae.CRABB_DEV__Esito__c = 'Messaggio Inviato';
                        ae.CRABB_DEV__Message_Status__c = 'Sent';
                        ae.CRABB_DEV__Message_Send_Date__c = system.Now();
                        t.Status = 'Lavorata';
                        lTUpd.add(t);
                        /*Alessio Massidda: ISSUE #46*/
                        if(mapPrat.containsKey(t.whatId) && ae.CRABB_DEV__Carrier__c.equalsIgnoreCase('AWS_EMAIL'))
                        {
                            if(mapPrat.get(t.whatId).CRABB_DEV__Data_Invio_Sollecito__c == null)
                            {
                                mapPrat.get(t.whatId).CRABB_DEV__Data_Invio_Sollecito__c = Date.today();
                            }
                            else
                            {
                                mapPrat.get(t.whatId).CRABB_DEV__Data_ultimo_invio_AR__c = Date.today();
                            }
                        }
                    }

                    lAEUpd.add(ae);
                    break;
                }
                // MailUP - fine aggiunta
                
                // if modificato per il caso SMS or EMAIL
                if(t.CRABB_DEV__ActivityExtended__c == ae.Id && (mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c) == 'SMS' || mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c) == 'EMAIL' ))
                {
                    System.debug('Sono entrato nella parte di SMS oppure EMAIL');
                    
                    // modificati in modo da usare la classe CRABBSENDER_MailUP
                    //CRABBSENDER cs = new CRABBSENDER();
                    //CRABBSENDER.CrabbMessage cm = new CRABBSENDER.CrabbMessage();
                    CRABBSENDER_MailUP cs = new CRABBSENDER_MailUP();
                    CRABBSENDER_MailUP.CrabbMessage cm = new CRABBSENDER_MailUP.CrabbMessage();
                    
                   
                    cm.customerid = ae.CRABB_DEV__IdAccount__c;
                    cm.sender = mSender.get(ae.CRABB_DEV__Tipo_Sottotipo__c);
                    cm.messageType = mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c);
                    ae.CRABB_DEV__Carrier_status_activation_code__c = mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c);
                    ae.CRABB_DEV__Message_Type__c = mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c);

                    System.debug(mTemplateId);
                    System.debug(ae.CRABB_DEV__Tipo_Sottotipo__c);
                    System.debug('getEmailTemplateId: ' + mapAcc.get(ae.CRABB_DEV__IdAccount__c).CRABB_DEV__Preferred_Language_for_Communications__c + ' - ' + mapAcc);

                    /*Alessio Massidda: #ISSUE 52*/
                    //Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(mTemplateId.get(ae.CRABB_DEV__Tipo_Sottotipo__c), UserInfo.getUserId(), t.WhatId);
                    Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(getEmailTemplateId(ae.CRABB_DEV__Tipo_Sottotipo__c, mapAcc.get(ae.CRABB_DEV__IdAccount__c).CRABB_DEV__Preferred_Language_for_Communications__c), UserInfo.getUserId(), t.WhatId);
                    System.debug(email.getPlainTextBody());

                    if(mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c) == 'EMAIL')
                    {
                        /** INVIO EMAIL **/
                        System.debug('Sono entrato nella parte di  EMAIL');
                        String  subject = email.getSubject();
                        String body = email.gethtmlBody();
                        System.debug('BODY 1:' + body);
                        body = body.replace('[$CRABB_EC_Account]',mapPrat.get(t.whatId).CRABB_DEV__EC_Account__c);
                        System.debug('BODY 2:' + body);
                        body = body.replace('[$CRABB_EC_Pratica]',mapPrat.get(t.whatId).CRABB_DEV__EC_Pratica__c);
                        System.debug('BODY 3:' + body);
                        cm.recipient = ae.CRABB_DEV__Message_Email__c;
                        cm.body_text = email.getPlainTextBody();
                        cm.body_html = EncodingUtil.base64Encode(Blob.valueOf(body));
                        cm.subject = subject;
                        ae.CRABB_DEV__Message_Body__c = cm.body_html;
                    }
                    else if(mType.get(ae.CRABB_DEV__Tipo_Sottotipo__c) == 'SMS')
                    {
                        /** INVIO SMS **/
                        System.debug('Sono entrato nella parte di SMS');
                        String body = email.getPlainTextBody();
                        cm.message = body; //+':'+BALANCE_Utils.generateRandomString(6); //'TEST CRABB ENJOY';
                        cm.phone = ae.CRABB_DEV__Message_Phone_Number__c;
                        ae.CRABB_DEV__Message_Body__c = cm.message;
                    }

                    String sms = cs.Send(cm);
                    System.debug('SMS RESPONSE:'+sms);
                    //ae.Carrier_status_description__c = sms.substring(0,254);
                    //system.debug(sms);
                    List<String> ls = sms.split(':');
                    if(ls[0] == 'Error' || ls[0] == '{\"errorMessage\"')
                    {
                        ae.CRABB_DEV__Message_Status__c = 'Error';
                        ae.CRABB_DEV__Esito__c = 'Messaggio in errore';
                        ae.CRABB_DEV__Message_Error__c = sms;
                    }
                    else
                    {
                        ae.CRABB_DEV__Esito__c = 'Messaggio Inviato';
                        ae.CRABB_DEV__Message_Status__c = 'Sent';
                        ae.CRABB_DEV__Message_Send_Date__c = system.Now();
                        t.Status = 'Lavorata';
                        lTUpd.add(t);
                        /*Alessio Massidda: ISSUE #46*/
                        if(mapPrat.containsKey(t.whatId) && ae.CRABB_DEV__Carrier__c.equalsIgnoreCase('AWS_EMAIL')){
                            if(mapPrat.get(t.whatId).CRABB_DEV__Data_Invio_Sollecito__c == null){
                                mapPrat.get(t.whatId).CRABB_DEV__Data_Invio_Sollecito__c = Date.today();
                            }
                            else{
                                mapPrat.get(t.whatId).CRABB_DEV__Data_ultimo_invio_AR__c = Date.today();
                            }
                        }
                        /* */
                    }

                    lAEUpd.add(ae);
                    break;
                }
            }
        }

        if(lAEUpd.size() > 0)
            update lAEUpd;

        if(lTUpd.size() > 0)
            update lTUpd;

        /*Alessio Massidda: ISSUE #46*/
        if(mapPrat.values().size()>0)
        {
            update mapPrat.values();
        }
        /* */
    }

    global void finish(Database.BatchableContext BC)
    {}

    /*Alessio Massidda: bug #52*/
    private Id getEmailTemplateId(String sottotipo, String lingua_alpha2)
    {
        System.Debug('getEmailTemplateId: ' + mTemplate + ' - ' +  sottotipo + ' - ' + lingua_alpha2 + ' - ' + alpha2ToAlpha3.get(lingua_alpha2.touppercase()) + ' - ' + alpha2ToAlpha3);
        //Id templateId = mTemplate.get(sottotipo + '_' + alpha2ToAlpha3.get(lingua_alpha2.touppercase()));
        Id templateId = mTemplateId.get(sottotipo + '_' + alpha2ToAlpha3.get(lingua_alpha2.touppercase()));
        System.debug(sottotipo + '_' + alpha2ToAlpha3.get(lingua_alpha2.touppercase()) + ' **** ' + templateId);
        if(templateId == null)
        {
            return mTemplateId.get(sottotipo + '_' + 'ITA');
        }
        return templateId;
    }
    /* */
}