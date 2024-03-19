/* ---------------------------------------------------------------------------------------------------------------------
Name:            CaseHandler.cls
Description:
Test class:

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
14-Nov-2018  0.1      A. Massidda                     First Version
17-Nov-2021  0.2      C. Sanna                        Added blockingSR Boolean to control blockingSR cases only
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class CaseHandler implements ITrigger{

    //public List<SObject> mappingField_accountID = (List<SObject>) [SELECT CRABB_DEV__account_mapping__c from CRABB_DEV__BlockingSR_mapping__mdt limit 1];
    public List<CRABB_DEV__BlockingSR_mapping__mdt> mappingField_accountID = [SELECT CRABB_DEV__account_mapping__c from CRABB_DEV__BlockingSR_mapping__mdt limit 1];



    public CaseHandler(){}

    public void bulkBefore(){}
    public void bulkAfter(){}

    public void bulkBefore(List<SObject> lsObjects){}
    public void bulkAfter(List<SObject> lsObjects){}

    public void beforeInsert(List<SObject> lsObjects){}

    /*Alessio Massidda*/
    //block praticas of account related to cases if the flag CRABB_DEV__Blocking_SR__c is true
    public void afterInsert(List<SObject> lsObjects){
        //CRABB_DEV__BlockingSR_mapping__mdt listProva = (CRABB_DEV__BlockingSR_mapping__mdt) mappingField_accountID.get(0).CRABB_DEV__BlockingSR_mapping__mdt;
        String account_field = mappingField_accountID.get(0).CRABB_DEV__account_mapping__c;
        System.debug('****CRABB afterInsert Handler for Case records****');
        bloccoPratiche(lsObjects, account_field);
        System.debug('****FINE HANDLER afterInsert****');
    }
    /***/


    public void beforeUpdate(List<SObject> oldList, List<SObject> newList){}


    /*Alessio Massidda*/
    /*
    * Verify that there are no more open cases ( where CRABB_DEV__Blocking_SR__c = true) related to such
    * an account. If this condition occurs, unlock all his/her praticas
    */
    public void afterUpdate(List<SObject> oldList, List<SObject> newList){
        //CRABB_DEV__BlockingSR_mapping__mdt listProva = (CRABB_DEV__BlockingSR_mapping__mdt) mappingField_accountID.get(0).getSObject('CRABB_DEV__BlockingSR_mapping__mdt');
        //String account_field = listProva.CRABB_DEV__account_mapping__c;
        String account_field = mappingField_accountID.get(0).CRABB_DEV__account_mapping__c;

        System.debug('****CRABB afterUpdate Handler for Case records****');
        Map<Id, Case> oldMap = (Map<Id, Case>) Trigger.oldMap;
        Map<Id, Case> newMap = (Map<Id, Case>) Trigger.newMap;

        bloccoPratiche(newList, account_field);

        Set<Id> candidateAccounts = new Set<Id>();
        for(Id caseId : newMap.keySet()){
            System.debug('Processo il case ' + caseId);
            String oldStatus = oldMap.get(caseId).status;
            String newStatus = newMap.get(caseId).status;
            Boolean blockingSR = oldMap.get(caseId).Blocking_SR__c;

            //collect all the account Ids where one of its blocking cases have just been closed . . .
            //if(!oldStatus.equalsIgnoreCase(newStatus) && newStatus.equalsIgnoreCase('Closed')){
            if(!oldStatus.equalsIgnoreCase(newStatus) && newStatus.equalsIgnoreCase('Closed') && blockingSR){
                System.debug('Il case ' + caseId + ' è stato appena chiuso');
                if(String.isNotBlank((String) newMap.get(caseId).get(account_field))) {
                    candidateAccounts.add((Id) newMap.get(caseId).get(account_field));
                }
                else System.debug('Il case ' + caseId + ' non ha alcun account associato');
            }
        }

        System.debug('candidateAccounts ha ' + candidateAccounts.size()  + ' elementi (alcuni tra poco potrebbero essere eliminati)');

        //for the accounts collected in the previous step, check if there is at least one open blocking case
        // if such condition occurs, remove the accountId from the "candidate list"
        if(!candidateAccounts.isEmpty()){
            if (Utils.checkFLSPermission('Case', 'status').get('ACCESS')
                    && Utils.checkFLSPermission('Case', account_field).get('ACCESS'))
            {
                List<Case> caseList = new List<Case>();
                String query = 'SELECT status, ' + String.escapeSingleQuotes(account_field)+' FROM Case WHERE '+ String.escapeSingleQuotes(account_field)+' IN :candidateAccounts AND CRABB_DEV__Blocking_SR__c = true ORDER BY '+String.escapeSingleQuotes(account_field);
                caseList = Database.query(query);
                for(Case c : caseList){

                    if(!c.status.equalsIgnoreCase('Closed')){
                        candidateAccounts.remove((Id) c.get(account_field));
                        System.debug('Ho rimosso l\'accountId ' + c.get(account_field) + ' dalla lista dei candidati perché non tutti i suoi case bloccanti sono stati chiusi');
                    }
                }
            }
            else System.debug('L\'utente loggato ' + UserInfo.getUserName() + ' non ha i diritti per vedere i case associati agli accountIds');
            //now the "candidate list" collects only the accounts whose ALL blocking case are closed . . .

            //unlock all praticas of accounts collected earlier
            if (Utils.checkFLSPermission('Pratica__c', 'Strategia__c').get('ACCESS'))
            {
                System.debug('L\'utente loggato ' + UserInfo.getUserName() + ' sta per sbloccare le pratiche dei seguenti account: ' + candidateAccounts);
                new BloccoSbloccoPratiche().sbloccaPratiche(
                [SELECT Strategia__c FROM Pratica__c WHERE Account__c IN :candidateAccounts],
                        'Ticket Bloccanti Chiusi'
                );
            }
            else System.debug('L\'utente loggato ' + UserInfo.getUserName() + ' non ha i diritti per sbloccare pratiche');

        }
        else System.debug('Non ci sono account su cui bloccare pratiche');
        System.debug('****FINE HANDLER afterUpdate****');
    }
    /** **/

    public void beforeDelete(List<SObject> lsObjects){}
    public void afterDelete(List<SObject> lsObjects){}
    public void andFinally(){}

    public void bloccoPratiche(List<Case> lsObjects, String account_field){

        Set<Id> accountsIdInvolved = new Set<Id>();

        for(Case c : (List<Case>) lsObjects){
            //if the case hasn't an account related, just ignore it
            Id accId = (Id) c.get(account_field);
            String status = (String)c.get('Status');
            System.debug('Il case ' + c.Id + ' è associato all\'account ' + accId);
            if(String.isBlank(accId) || status.equalsIgnoreCase('Closed')) {
                System.debug('Il case ' + c.Id + ' non ha un account associato o ha status closed');
                continue;
            }
            //if this is a blocking case, collect its account
            if(c.Blocking_SR__c) accountsIdInvolved.add(accId);
        }
        System.debug('accountsIdInvolved ha ' + accountsIdInvolved.size()  + ' elementi');

        if(!accountsIdInvolved.isEmpty()){
            if (Utils.checkFLSPermission('Pratica__c', 'Account__c').get('ACCESS')
                    && Utils.checkFLSPermission('Pratica__c', 'Stato__c').get('ACCESS'))
            {
                System.debug('L\'utente loggato ' + UserInfo.getUserName() + ' sta per bloccare le pratiche dei seguenti account: ' + accountsIdInvolved);
                new BloccoSbloccoPratiche().BloccaPratiche(
                [SELECT ID FROM Pratica__c WHERE Account__c IN :accountsIdInvolved
                AND Stato__c = 'In Lavorazione'
                ], 'Esistono Ticket Bloccanti', 'Esistono Ticket Bloccanti'
                );
            }
            else System.debug('L\'utente loggato ' + UserInfo.getUserName() + ' non ha i diritti per bloccare pratiche');
        }
        else System.debug('Non ci sono account su cui bloccare pratiche');
    }

}