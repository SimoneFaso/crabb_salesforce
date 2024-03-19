/* ---------------------------------------------------------------------------------------------------------------------
Name:            CRABBSENDER_MailUP.cls
Description:
Test class:

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
              0.1                                      First Version
              0.2      F.Suraci                        Aggiunta parte relativa a MailUP
13-Sep-2022   0.3      R.Kurti & C.Sanna               Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class CRABBSENDER_MailUP
{
    //prova mlecca
    
    // - Mail_UP - classe Token -- START
    public class Token
    {
        public String endpoint      {get;set;}
        public String grant_type    {get;set;}
        public String username      {get;set;}
        public String password      {get;set;}
        public String client_id     {get;set;}
        public String client_secret {get;set;}

        public Token(String endpoint, String grant_type,String username,String password,String client_id,String client_secret)
        {
            this.grant_type = grant_type;
            this.username = username;
            this.password = password;
            this.client_id = client_id;
            this.client_secret = client_secret;
            this.endpoint = endpoint + '?grant_type='+ this.grant_type +'&username=' + this.username +  '&password=' + this.password + '&client_id=' + this.client_id + '&client_secret=' + this.client_secret;
        }

        public Token ()
        {
            
         CRABB_DEV__Credenziali_MailUp_Token__mdt credenziali_mailup = [SELECT
                                                                                   CRABB_DEV__client_id__c,
                                                                                   CRABB_DEV__client_secret__c,
                                                                                    CRABB_DEV__endpoint__c,
																					CRABB_DEV__grant_type__c,
																					CRABB_DEV__password__c,
																					CRABB_DEV__username__c
                                                                                FROM
                                                                                    CRABB_DEV__Credenziali_MailUp_Token__mdt
                                                                                WHERE DeveloperName = 'CRABB_MailUP_Token'  WITH SECURITY_ENFORCED LIMIT 1];
            
            this.grant_type = credenziali_mailup.CRABB_DEV__grant_type__c;
            this.username = credenziali_mailup.CRABB_DEV__username__c;
            this.password = credenziali_mailup.CRABB_DEV__password__c;
            this.client_id = credenziali_mailup.CRABB_DEV__client_id__c;
            this.client_secret = credenziali_mailup.CRABB_DEV__client_secret__c;
            this.endpoint = credenziali_mailup.CRABB_DEV__endpoint__c +'grant_type='+ this.grant_type +'&username=' + this.username +  '&password=' + this.password + '&client_id=' + this.client_id + '&client_secret=' + this.client_secret;
      
            
            
            /*        
            
            this.grant_type = 'password';
            this.username = 'm143929';
            this.password = 'Balance2020';
            this.client_id = 'bce7eefe-c713-4622-957b-a00497defa12';
            this.client_secret = '638c73e7-c465-4991-a4a0-0a36dae41990';
            this.endpoint = 'https://services.mailup.com/Authorization/OAuth/Token?grant_type='+ this.grant_type +'&username=' + this.username +  '&password=' + this.password + '&client_id=' + this.client_id + '&client_secret=' + this.client_secret;
        */

}
    }
    // - Mail_UP - classe Token -- END

    // - Mail_UP - classe TrackingInfo -- START
    public class TrackingInfo
    {
        private String CustomParams     {get;set;}
        private Boolean Enabled         {get;set;}
        private List<String> Protocols  {get;set;}

        public TrackingInfo ()
        {
            this.enabled=false;
            this.customParams='';
            this.protocols = new List<String>();
        }

        public TrackingInfo (String CustomParams, Boolean Enabled,List<String> Protocols )
        {
            this.Enabled=Enabled;
            this.CustomParams=CustomParams;
            this.Protocols = Protocols;
        }
    }
    // - Mail_UP - classe TrackingInfo -- END
                                                                                                            
    // - Mail_UP - classe CrabbMessageMailUp -- START
    public class CrabbMessageMailUp
    {
        //values for create_message/send message
        public String Subject               {get;set;}
        public Boolean IsConfirmation       {get;set;}
        public String Content               {get;set;}
        public String Notes                 {get;set;}
        public Boolean UseDynamicField      {get;set;}
        public Boolean Embed                {get;set;}
        public String PreHeader             {get;set;}
        public TrackingInfo TrackingInfo    {get;set;}
        public String Email                 {get;set;}
        public Integer idMessage            {get;set;}

        //constructor  for create_message
        public CrabbMessageMailUp(String Subject, Boolean IsConfirmation, String Content, String Notes, Boolean UseDynamicField, Boolean Embed, String PreHeader, TrackingInfo TrackingInfo)
        {

            this.Subject = Subject;
            this.IsConfirmation = IsConfirmation;
            this.Content = Content;
            this.Notes = Notes;
            this.UseDynamicField = UseDynamicField;
            this.Embed = Embed;
            this.PreHeader = PreHeader;
            this.TrackingInfo = TrackingInfo;
        }

        //constructor for send_message
        public CrabbMessageMailUp(String Email, Integer idMessage)
        {
            this.Email = Email;
            this.idMessage = idMessage;
        }

        public CrabbMessageMailUp()
        {}
    }
    // - Mail_UP - classe CrabbMessageMailUp -- END
                                               
    // - CRABB - classe CrabbMessage -- START
    public class CrabbMessage
    {
        public String customerid    {get;set;}
        public String messageType   {get;set;}
        public String sender        {get;set;}
        public String recipient     {get;set;}
        public String body_text     {get;set;}
        public String body_html     {get;set;}
        public String subject       {get;set;}
        public String message       {get;set;}
        public String phone         {get;set;}
    }
    // - CRABB - classe CrabbMessage -- END

    // public  HttpRequest req;
    //- Mail_UP - 
    public String token         {get;set;}
    public String refreshtoken  {get;set;}
    public Integer IDMessage    {get;set;}

    public CRABBSENDER_MailUP()
    {
        // Questa parte è stata spostata in un nuvo metodo 'init()'
        /*    CRABB_DEV__Credenziali_aws_per_invio_sms__mdt credenziali_aws = [SELECT
                                                                                    CRABB_DEV__Endpoint_AWS__c,
                                                                                    CRABB_DEV__Secret_Key_AWS__c,
                                                                                    CRABB_DEV__Service__c
                                                                                FROM
                                                                                    CRABB_DEV__Credenziali_aws_per_invio_sms__mdt
                                                                                WHERE DeveloperName = 'CRABB_Message' LIMIT 1];
        req = new HttpRequest();
        req.setEndpoint(credenziali_aws.CRABB_DEV__Endpoint_AWS__c);
        req.setMethod(credenziali_aws.CRABB_DEV__Service__c);
        req.setHeader('x-api-key', credenziali_aws.CRABB_DEV__Secret_Key_AWS__c);
     */
    }
    
    public HttpRequest init()
    {
        CRABB_DEV__Credenziali_aws_per_invio_sms__mdt credenziali_aws = [SELECT
                                                                                    CRABB_DEV__Endpoint_AWS__c,
                                                                                    CRABB_DEV__Secret_Key_AWS__c,
                                                                                    CRABB_DEV__Service__c
                                                                                FROM
                                                                                    CRABB_DEV__Credenziali_aws_per_invio_sms__mdt
                                                                                WHERE DeveloperName = 'CRABB_Message' WITH SECURITY_ENFORCED LIMIT 1];
        HttpRequest req;
        req = new HttpRequest();
        req.setEndpoint(credenziali_aws.CRABB_DEV__Endpoint_AWS__c);
        req.setMethod(credenziali_aws.CRABB_DEV__Service__c);
        req.setHeader('x-api-key', credenziali_aws.CRABB_DEV__Secret_Key_AWS__c);
        return req;
    }

    //metodo originale della classe CRABB_SENDER, con l'aggiunta solo di questa riga:  HttpRequest req= init();
    public String Send(CrabbMessage cm)
    {
        if(cm.messageType == 'SMS')
        {
            if (String.isBlank(cm.phone) ||String.isBlank(cm.message)|| String.isBlank(cm.sender))
            {
                System.debug('Phone:' + cm.phone + ' Message:' + cm.message + ' Sender:' + cm.sender);
                return 'Error: Blank phone number or message or sender';
            }
            if ((!cm.phone.startsWith('+') || !cm.phone.startsWith('00')) && (cm.phone.length() == 9 || cm.phone.length() == 10))
            {
                cm.phone = '+39' + cm.phone;
            }
            else if (!cm.phone.startsWith('+') && !cm.phone.startsWith('00'))
            {
                System.debug('Phone:' + cm.phone + ' Message:' + cm.message + ' Sender:' + cm.sender);
                return 'Error: wrong phone number';
            }
        }
        else if(cm.messageType == 'EMAIL')
        {
            if (String.isBlank(cm.recipient) ||String.isBlank(cm.body_html)|| String.isBlank(cm.sender))
            {
                //System.debug('Phone:' + cm.phone + ' Message:' + cm.message + ' Sender:' + cm.sender);
                return 'Error: Blank mail or message or sender';
            }
        }

        try
        {
            HttpRequest req= init();
            req.setBody(JSON.serialize(cm));
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('SMS RESPONSE IS:' + res.toString());
            System.debug('SMS RESPONSE BODY:' + res.getBody());
            if (res.getStatusCode() == 200)
            {
                return res.getBody();
            }
            else if (res !=null)
            {
                System.debug('Returned ERROR Response:' + res.getBody());
                return 'Error: ' + res.getBody();
            }
        }
        catch(System.CalloutException e)
        {
            System.debug('Callout error: ' + e);
            return 'Error: Callout failed' + e;
        }

        return '';
    }
    
    // metodo Get Token da MailUp -- con input parameters
    public String getToken(String endpoint,String grant_type,String username,String password,String client_id,String client_secret)
    {
        Token t = new Token(endpoint,  grant_type, username, password, client_id, client_secret);
        HttpRequest reqToken = new HttpRequest();
        //  try start
        try
        {
            reqToken.setMethod('GET');
            reqToken.setEndpoint(t.endpoint);
            reqToken.setHeader('Accept','*/*');
            reqToken.setHeader('Content-Type','application/x-www-form-urlencoded');
            Http binding = new Http();
            HttpResponse res = binding.send(reqToken);
            System.debug('Called url : ' +  t.endpoint);
            if (res.getStatusCode() == 200)
            {
                System.debug('Response : ' +  res.getBody());
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null)
                {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() =='access_token'))
                    {
                        parser.nextToken();
                        token= parser.getText();
                        System.debug('token : ' +  token);
                    }
                
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() =='refresh_token'))
                    {
                        parser.nextToken();
                        refreshtoken= parser.getText();
                        System.debug('refresh_token : ' +  refreshtoken);
                    }
                }
            }
            else
            {
                System.debug('Response is null');
                System.debug('Response code : ' + res.getStatusCode());
                System.debug('Response  : ' + res.getBody());
                return null;
            }
        }
        catch(System.CalloutException e)
        {
            System.debug('Callout error: ' + e);
            return 'Error: Callout failed' + e;
        }
        return token;
    }
    
    // metodo Get Token da MailUp - senza input parameters (usa quelli di default)  
    public String getToken()
    {
        Token t = new Token();
        HttpRequest reqToken = new HttpRequest();
        try
        {
            reqToken.setMethod('GET');
            reqToken.setEndpoint(t.endpoint);
            reqToken.setHeader('Accept','*/*');
            reqToken.setHeader('Content-Type','application/x-www-form-urlencoded');
            Http binding = new Http();
            HttpResponse res = binding.send(reqToken);
            System.debug('Called url : ' + t.endpoint);
               if (res.getStatusCode() == 200) {
                System.debug('Response : ' +  res.getBody());
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null) {
                   if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() =='access_token')){
                       parser.nextToken();
                       token= parser.getText();

                         System.debug('token : ' +  token);
                    }

                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() =='refresh_token')){
                       parser.nextToken();
                    refreshtoken= parser.getText();
                        System.debug('refresh_token : ' +  refreshtoken);
                    }
                }
            }
            else {
                System.debug('Response is null');
                System.debug('Response code : ' + res.getStatusCode());
                System.debug('Response  : ' + res.getBody());
               return token;
            }
        }
        catch(System.CalloutException e)
        {
            System.debug('Callout error: ' + e);
            return 'Error: Callout failed' + e;
        }
       
        return token;
    }
    
   
    // metodo create message MailUP    
    
    public Integer createMessage (CrabbMessageMailUp cmMailUp)  
               {
                   
     CRABB_DEV__CRABB_MailUP__mdt custom_mailup = [SELECT
                                                                                   CRABB_DEV__endpoint_create_message__c,                                                                                  
                                                                                    CRABB_DEV__id_list__c
                                                                                FROM
                                                                                    CRABB_DEV__CRABB_MailUP__mdt
                                                                                WHERE DeveloperName = 'CRABB_MailUP' WITH SECURITY_ENFORCED LIMIT 1];
                   
                   
        String customIdList= custom_mailup.CRABB_DEV__id_list__c;
        String customEndpoint= custom_mailup.CRABB_DEV__endpoint_create_message__c;
                   
        String endpoint= customEndpoint.replace('{id_List}', customIdList);
        String result='';
        try
        {
            String body = JSON.serialize(cmMailUp);
            System.debug('BODY Request CreateMessage: ' +  body);
            String IdList;
            String idMessage_value;

            HttpRequest reqCreateMessage = new HttpRequest();
            reqCreateMessage.setMethod('POST');
            reqCreateMessage.setEndpoint(endpoint);
            reqCreateMessage.setHeader('Accept','*/*');
            reqCreateMessage.setHeader('Content-Type','application/json');
            reqCreateMessage.setHeader('Authorization','Bearer ' + token);
      
            if (String.isBlank(cmMailUp.Content))
            {
                System.debug('Error : Blank mail or message');
                return 00000;
            }
      
            reqCreateMessage.setBody(body);
            Http binding = new Http();
            HttpResponse res = binding.send(reqCreateMessage);
            System.debug('Called url : ' +  endpoint);
            result= res.getBody();
            if (res.getStatusCode() == 401 || res.getBody().contains('Unauthorized') || res.getBody().contains('Authorization error'))
            {
                System.debug('ERROR Response createMessage : ' +  res.getBody());
                token = getToken();
                if(Test.isRunningTest()){
                    MockCRABBSender.mailupTOKEN='123253654';
                }
                createMessage(cmMailUp);
            }
            if (res.getStatusCode() == 200)
            {
                System.debug('Response : ' +  res.getBody());
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null)
                {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() =='IdList'))
                    {
                        parser.nextToken();
                        IdList= parser.getText();
                        // System.debug('IdList : ' +  IdList);
                    }

				    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() =='idMessage'))
                    {
                        parser.nextToken();
                        idMessage_value= parser.getText();
                        System.debug('idMessage : ' +  idMessage_value);
                   
                        IDMessage=integer.valueof(idMessage_value);
                    }
                    continue;
                }
            }
            else
            {
                System.debug('Response code createMessage : ' + res.getStatusCode());
                System.debug('Response createMessage : ' + res.getBody());
                return IDMessage;
            }
        }
        catch(System.CalloutException e)
        {
            System.debug('Callout error: ' + e);
            return 0000;
        }
        System.debug('Full response is : ' +  result);
     
        System.debug('ID_Message is : ' +  IDMessage);
		return IDMessage;    
    }  

    // metodo send Message MailUP
    
    public String sendToRecipient (CrabbMessageMailUp cmMailUp)
    {
        
         CRABB_DEV__CRABB_MailUP__mdt custom_mailup = [SELECT
                                                                                   CRABB_DEV__endpoint_send_message__c
                                                                                FROM
                                                                                    CRABB_DEV__CRABB_MailUP__mdt
                                                                                WHERE DeveloperName = 'CRABB_MailUP' WITH SECURITY_ENFORCED LIMIT 1];
                   
                   
        
        String endpoint= custom_mailup.CRABB_DEV__endpoint_send_message__c;   
        
       
        String result='';
        try
        {
            String body = JSON.serialize(cmMailUp);
            System.debug('BODY Request sendToRecipeint : ' +  body);
            String IdMessage_resp;
       
            HttpRequest reqSendMessage = new HttpRequest();
            reqSendMessage.setMethod('POST');
            reqSendMessage.setEndpoint(endpoint);
            reqSendMessage.setHeader('Accept','*/*');
            reqSendMessage.setHeader('Content-Type','application/json');
            reqSendMessage.setHeader('Authorization','Bearer ' + token);
       
            if (String.isBlank(cmMailUp.Email) || cmMailUp.Idmessage == null)
            {
                System.debug('Error : Blank email address or IdMessage');
                return 'Error : Blank email address or IdMessage';
            }
       
            reqSendMessage.setBody(body);
            Http binding = new Http();
            HttpResponse res = binding.send(reqSendMessage);
            System.debug('Called url : ' +  endpoint);
            result= res.getBody();
    
            if (res.getStatusCode() == 401 || res.getBody().contains('Unauthorized') || res.getBody().contains('Authorization error'))
            {
                System.debug('ERROR Response sendToRecipient: ' +  res.getBody());
      
                token = getToken();
		        sendToRecipient(cmMailUp);
            }
    
            if (res.getStatusCode() == 200)
            {
                System.debug('Response: ' +  res.getBody());
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null)
                {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() =='idMessage'))
                    {
                        parser.nextToken();
                        IdMessage_resp= parser.getText();
                        System.debug('IdMessage_resp: ' +  IdMessage_resp);
                    }
                }
            }
            else
            {
                System.debug('Response code sendMessage: ' + res.getStatusCode());
                System.debug('Response  sendMessage: ' + res.getBody());
                //return null;
                return 'Error:' + res.getStatusCode();//updated 22/09/2020
            }
        }
        catch(System.CalloutException e)
        {
            System.debug('Callout error: ' + e);
            return 'Error: Callout failed' + e;
        }
       
        System.debug('Full response is : ' +  result);
		return result;    
    }
}