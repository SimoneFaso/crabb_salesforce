/* ---------------------------------------------------------------------------------------------------------------------
Name:            CRABB_MsgViewerCtrl.cls
Description:
Test class:      CRABB_MsgViewerCtrl_TEST.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
26-Jun-2020  0.1      Matteo Sala          First Version
13-Sep-2022  0.2      C.Sanna & R. Kurti   Added WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class CRABB_MsgViewerCtrl
{
    @auraenabled(cacheable = true)
    public static List<Msg> ListMsg (String praticaid)
    {
        List<Msg> lMsg = new List<Msg>();
        List<String> lAEId = new List<String>();
        List<Task> lTasks = new List<Task>();
        List<ActivityExtended__c> lAEs = new List<ActivityExtended__c>();

            //lTasks = [SELECT ActivityExtended__c FROM Task WHERE WhatId = :praticaid];
            lTasks = [SELECT ActivityExtended__c FROM Task WHERE WhatId = :praticaid WITH SECURITY_ENFORCED];

        for (Task t : lTasks)
        {
            lAEId.add(t.ActivityExtended__c);
        }

            lAEs = [SELECT
                        Tipo_Sottotipo__c,
                        Message_Body__c,
                        Message_Email__c,
                        Message_Type__c,
                        Message_Send_Date__c,
                        Message_Phone_Number__c,
                        Message_Error__c,
                        Message_Status__c
                    FROM ActivityExtended__c
                    WHERE (Message_Status__c = 'Sent'
                    OR Message_Status__c = 'Error')
                    //AND Id in :lAEId
                    AND Id IN :lAEId WITH SECURITY_ENFORCED
                    ORDER BY CreatedDate];

        Integer i = 1;

        for(ActivityExtended__c ae : lAEs)
        {
            Msg m = new Msg();

            if(i<10)
                m.key = 'Msg-00' + i;
            else if(i<100)
                m.key = 'Msg-0' + i;
            else
                m.key = 'Msg-' + i;

            if(ae.Message_status__c == 'Error')
                m.isError = true;
            else
                m.isError = false;

            if(ae.Message_Type__c == 'EMAIL')
            {
                m.body = EncodingUtil.base64Decode(ae.Message_Body__c).toString();
                m.isSMS = false;
            }
            else
            {
                m.body = ae.Message_Body__c;
                m.isSMS = true;
            }

            m.email = ae.Message_Email__c;
            m.phone = ae.Message_Phone_Number__c;
            m.error = ae.Message_Error__c;
            m.send_dt = ae.Message_Send_Date__c;
            m.type = ae.Tipo_Sottotipo__c;

            lMsg.add(m);

            i++;
        }
        return lMsg;
    }

    public class Msg
    {
        @AuraEnabled
        Public String key { get; set; }
        @AuraEnabled
        Public Boolean isError { get; set; }
        @AuraEnabled
        Public Boolean isSMS { get; set; }
        @AuraEnabled
        Public String email { get; set; }
        @AuraEnabled
        Public String phone { get; set; }
        @AuraEnabled
        Public String body { get; set; }
        @AuraEnabled
        Public String error { get; set; }
        @AuraEnabled
        Public Datetime send_dt { get; set; }
        @AuraEnabled
        Public String type { get; set; }
    }
}