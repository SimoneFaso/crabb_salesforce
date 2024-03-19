/* ---------------------------------------------------------------------------------------------------------------------
Name:            OrkActivities.cls
Description:     Classe che gestisce le attività ( invio mail, notifica etc );
Test class:      TestOrkActivities.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
16-Jun-2016  0.1      ESino                            Aggiunto il with sharing come richiesta da Salesforce.com per
                                                       soddisfare le specifiche del Security Review.
07-May-2021  0.2      Giulia Mameli                    Added ActivityExtended__c> filteredTskActExtMap of execute and
                                                       closeExpired not to invoke getTaskWithActivityExtended method
14-Sep-2022  0.3      R.Kurti & C.Sanna                Added WITH SECURITY_ENFORCED for security review, commented sendEmail and sendAR
                                                       (SessionId not safe)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class OrkActivities {
    //public static String sessionIDFromTriggerTask;
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public static Map<String, String> execute(String activity, Map<String, Task> tasks, Map<String, Pratica__c> pMap, List<Log__c> logL, Map<Id, ActivityExtended__c> filteredTskActExtMap) {
        System.debug('Verifica Chiusura Automatica: ' + activity);
        /*if (activity == 'Mail')
            return sendMail(tasks, pMap);
        if (activity == 'InvioAR')
            return sendLettera(tasks, pMap);*/
        if (activity == 'Time')
            return closeExpired(tasks, pMap, logL, filteredTskActExtMap);
        if (activity == 'Attesa') {
            //logL.add(errorClass.istanceError('999999','OrkActivities: Attesa'));
            return closeExpired(tasks, pMap, logL, filteredTskActExtMap);
        }
        return new map<String, String>();
    }

    public static Map<String, String> cebExecute(String activity, Map<String, Task> tasks, Map<String, Pratica__c> pMap, List<Log__c> logL, Map<Id, ActivityExtended__c> filteredTskActExtMap, Map<String, Schema.SObjectType> globalDesc) {
        System.debug('Verifica Chiusura Automatica: ' + activity);
        /*if (activity == 'Mail')
            return sendMail(tasks, pMap);
        if (activity == 'InvioAR')
            return sendLettera(tasks, pMap);*/
        if (activity == 'Time')
            return cebCloseExpired(globalDesc, tasks, pMap, logL, filteredTskActExtMap);
        if (activity == 'Attesa') {
            //logL.add(errorClass.istanceError('999999','OrkActivities: Attesa'));
            return cebCloseExpired(globalDesc, tasks, pMap, logL, filteredTskActExtMap);
        }
        return new map<String, String>();
    }
    //Removed SessionId -- CRABB security review
    /*private static Map<String, String> sendMail(Map<String, Task> tasks, map<String, Pratica__c> pMap) {
        list<id> tidList = new list<id>();
        list<id> praticas = new list<id>();
        map<String, String> mails = new map<String, String>();
        String status = 'In corso_' + system.currentTimeMillis();

        for (String s : tasks.keyset()) {
            task t = tasks.get(s);
            t.status = status ;
            pratica__c p = pMap.get(t.whatid);
            tidList.add(t.id);
            praticas.add(t.whatid);
            p.Data_ultimo_invio_AR__c = system.today();
        }
        try {
            boolean isSessionIDToUpdate = EndpointHelper.isTokenToRefresh('SWOutboudWSStampaPDF');
            if (isSessionIDToUpdate)
                EndpointHelper.setToken('SWOutboudWSStampaPDF', sessionIDFromTriggerTask);
            BatchQueue.reqBatch('OBA', 'OrkBatchActivities', 0, 10, null, status);

            //Database.executeBatch(new OrkBatchActivities(tidList,sessionIDFromTriggerTask), 10);
        } catch (Exception e) {
            errorClass.logError('OrkActivities.Exception_1', 'Err:' + JSON.serialize(tidList) + '\n' + utils.getExceptionInString(e) + '\n sessionid:' + sessionIDFromTriggerTask);
        }
        return mails;
    }*/
    //Removed SessionId -- CRABB security review
    /*public static Map<String, String> sendLettera(Map<String, Task> tasks, map<String, Pratica__c> pMap) {
        list<id> tidList = new list<id>();
        list<id> praticas = new list<id>();
        String status = 'In corso_' + system.currentTimeMillis();
        map<String, String> mails = new map<String, String>();
        for (String s : tasks.keyset()) {
            task t = tasks.get(s);
            t.status = status;
            pratica__c p = pMap.get(t.whatid);
            tidList.add(t.id);
            praticas.add(t.whatid);
            p.Data_ultimo_invio_AR__c = system.today();
        }
        try {
            boolean isSessionIDToUpdate = EndpointHelper.isTokenToRefresh('SWOutboudWSStampaPDF');
            if (isSessionIDToUpdate)
                EndpointHelper.setToken('SWOutboudWSStampaPDF', sessionIDFromTriggerTask);
            BatchQueue.reqBatch('OBA', 'OrkBatchActivities', 0, 10, null, status);
            //Database.executeBatch(new OrkBatchActivities(tidList,sessionIDFromTriggerTask), 10);
        } catch (Exception e) {
            errorClass.logError('OrkActivities.Exception_2', 'Err:' + JSON.serialize(tidList) + '\n' + utils.getExceptionInString(e) + '\n sessionid:' + sessionIDFromTriggerTask);
        }
        return mails;
    }*/

    private static Map<String, String> closeExpired(Map<String, Task> tasks, Map<String, Pratica__c> pMap, List<Log__c> logL, Map<Id, ActivityExtended__c> filteredTskActExtMap) {
        Map<String, String> result = new Map<String, String>();
        List<Id> idperAffidamento = new List<Id>();
        //Map<Id,ActivityExtended__c> taskId2Obj = Utils.getTaskWithActivityExtended(tasks.values());
        for (String tskId : tasks.keySet()) {
            Task t = tasks.get(tskId);
            t.Description += '\n _Verifica Chiusura Automatica';
            //ActivityExtended__c ae = taskId2Obj.get(t.Id);
            ActivityExtended__c ae = filteredTskActExtMap.get(t.Id);
            Pratica__c p = pMap.get(t.WhatId);
            if (ae != null) {
                if (ae.Expiration_date__c == null) {
                    continue;
                } else if (p.Stato__c == TagHelper.getValueText('StatoPraticaBloccoPDR') && ae.Expiration_date__c < System.today()) {
                    ae.Expiration_date__c = System.today();
                } else if (ae.Expiration_date__c < System.today()) {
                    t.Status = 'Lavorata';
                    ae.Substatus__c = 'Chiuso in quanto scaduto';
                    if (ae.id_affidamento__c != null) {
                        idperAffidamento.add(t.WhatId);
                        idperAffidamento.add(ae.id_affidamento__c);
                    }
                    continue;
                }
            }
        }
        if (idperAffidamento.size() > 0) OrkBL.GestisciRevocaPerScadutoDegliAffidamenti(idperAffidamento);
        return result;
    }

    private static Map<String, String> cebCloseExpired(Map<String, Schema.SObjectType> globalDesc, Map<String, Task> tasks, Map<String, Pratica__c> pMap, List<Log__c> logL, Map<Id, ActivityExtended__c> filteredTskActExtMap) {
        Map<String, String> result = new Map<String, String>();
        List<Id> idperAffidamento = new List<Id>();
        //Map<Id,ActivityExtended__c> taskId2Obj = Utils.getTaskWithActivityExtended(tasks.values());
        for (String tskId : tasks.keySet()) {
            Task t = tasks.get(tskId);
            t.Description += '\n _Verifica Chiusura Automatica';
            //ActivityExtended__c ae = taskId2Obj.get(t.Id);
            ActivityExtended__c ae = filteredTskActExtMap.get(t.Id);
            Pratica__c p = pMap.get(t.WhatId);
            if (ae != null) {
                if (ae.Expiration_date__c == null) {
                    continue;
                } else if (p.Stato__c == TagHelper.getValueText('StatoPraticaBloccoPDR') && ae.Expiration_date__c < System.today()) {
                    ae.Expiration_date__c = System.today();
                } else if (ae.Expiration_date__c < System.today()) {
                    t.Status = 'Lavorata';
                    ae.Substatus__c = 'Chiuso in quanto scaduto';
                    if (ae.id_affidamento__c != null) {
                        idperAffidamento.add(t.WhatId);
                        idperAffidamento.add(ae.id_affidamento__c);
                    }
                    continue;
                }
            }
        }
        if (idperAffidamento.size() > 0) OrkBL.cebGestisciRevocaPerScadutoDegliAffidamenti(idperAffidamento, globalDesc);
        return result;
    }

    public static void CreteLettersForAttachment(String a) {
        //if (Utils.cebCheckObjPermission('Task',gd).get('ACCESS')
        // && Utils.checkFLSPermission('Task', 'ActivityExtended__c').get('ACCESS')
        //      && Utils.cebCheckObjPermission('ActivityExtended__c',gd).get('ACCESS')
        //    && Utils.checkFLSPermission('ActivityExtended__c', 'Document_code__c').get('ACCESS')) {
        Task t = [
                select id, whatid, ActivityExtended__r.Document_code__c, status
                From Task
                Where id = :a
                WITH SECURITY_ENFORCED
        ];
        Pratica__c p = [
                select id, Account_Codice_Cliente__c
                From Pratica__c
                Where id = :t.whatId
                WITH SECURITY_ENFORCED
        ];

        PageReference pdf = Page.StampaPDF;
        pdf.getParameters().put('Id', t.whatID);
        pdf.getParameters().put('Type', t.ActivityExtended__r.Document_code__c);

        Attachment attach = new Attachment();

        Blob body;
        if (Test.IsRunningTest()) body = Blob.valueOf('UNIT.TEST');
        else body = pdf.getContent();

        attach.Body = body;
        Date oggi = date.Today();
        String giorno = String.ValueOf(oggi.day());
        String mese = String.ValueOf(oggi.month());
        String anno = String.ValueOf(oggi.year());
        attach.Name = p.Account_Codice_Cliente__c + '_Sollecito_' + anno + mese + giorno + '.pdf';
        attach.IsPrivate = false;
        // attach the pdf to the account
        attach.ParentId = t.whatid;

        if (Utils.cebCheckObjPermission('Attachment', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Attachment', 'Body', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Attachment', 'Name', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Attachment', 'IsPrivate', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Attachment','ParentId',gd).get('CREATE')) {
            insert attach;
        }
    }

}