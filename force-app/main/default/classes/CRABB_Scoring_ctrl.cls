/* ---------------------------------------------------------------------------------------------------------------------
Name:            CRABB_Scoring_ctrl.cls
Description:
Test class:      TestCoverageCruscottoPratica.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
12-Sep-2022  0.2      C.Sanna & R.Kurti    Added WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class CRABB_Scoring_ctrl {
    Public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    public static Database.SaveResult [] updateResult;

    @AuraEnabled
    public static Account getAccountInfo(String accountId) {
        system.debug('accountId ' + accountId);
        Account acc = new Account();
        /*
        if(Utils.cebCheckObjPermission('Account', gd).get('ACCESS')
                && Utils.checkFLSPermission('Account', 'CRABB_DEV__Scoring_Point__c').get('ACCESS')
                && Utils.checkFLSPermission('Account', 'CRABB_DEV__Last_scoring_evaluation_date__c').get('ACCESS')){
          */
        List<Account> accs = [
                SELECT CRABB_DEV__Scoring_Point__c, CRABB_DEV__Last_scoring_evaluation_date__c
                FROM Account
                WHERE Id = :AccountId
                WITH SECURITY_ENFORCED
        ];

        If (accs.size() > 0) {
            acc = accs[0];
        }

        system.debug('*** scoring ' + acc);
        return acc;
    }

    @AuraEnabled
    public static void elaborateScoring(list<string> recordIdList, string objtype) {
        System.debug('recordIdList ' + recordIdList);
        Map<string, list<CRABB_DEV__CRABB_Scoring_Points__mdt>> conditionMap = new map<string, list<CRABB_DEV__CRABB_Scoring_Points__mdt>>();
        List<sobject> records_to_update = new list<sobject>();


        //get all conditions for specified objtype
        List <CRABB_DEV__CRABB_Scoring_Points__mdt> scoringConfList = [
                SELECT Id, CRABB_DEV__CRABB_Scoring_Fields__r.CRABB_DEV__sObject__c, CRABB_DEV__CRABB_Scoring_Fields__r.CRABB_DEV__sField__c, CRABB_DEV__Filter_Type__c, CRABB_DEV__Values__c, CRABB_DEV__Points__c, CRABB_DEV__field_type__c
                FROM CRABB_DEV__CRABB_Scoring_Points__mdt
                WHERE CRABB_DEV__CRABB_Scoring_Fields__r.CRABB_DEV__sObject__c = :objtype
                WITH SECURITY_ENFORCED
        ];

        //get all fields without duplicates and define a map with conditions per field
        Set<string> fieldsList = new Set<string>();
        for (CRABB_DEV__CRABB_Scoring_Points__mdt s : scoringConfList) {
            fieldsList.add(s.CRABB_DEV__CRABB_Scoring_Fields__r.CRABB_DEV__sField__c);
            List<CRABB_DEV__CRABB_Scoring_Points__mdt> conditions = new list<CRABB_DEV__CRABB_Scoring_Points__mdt>();
            if (conditionMap.containsKey(s.CRABB_DEV__CRABB_Scoring_Fields__r.CRABB_DEV__sField__c)) {
                conditions = conditionMap.get(s.CRABB_DEV__CRABB_Scoring_Fields__r.CRABB_DEV__sField__c);
            }
            conditions.add(s);
            conditionMap.put(s.CRABB_DEV__CRABB_Scoring_Fields__r.CRABB_DEV__sField__c, conditions);
        }

        //create query
        string queryFields = '';
        for (string s : fieldsList) {
            if (Utils.checkFLSPermission(objtype, s).get('ACCESS')) {
                queryFields = String.isBlank(queryFields) ? s : queryFields + ',' + s;
            }
        }

        string query = 'select ' + String.escapeSingleQuotes(queryFields) + ',CRABB_DEV__Scoring_Point__c from ' + String.escapeSingleQuotes(objtype) + ' where id in:recordIdList WITH SECURITY_ENFORCED';
        List<sobject> recordList = Database.query(query);
        System.debug('recordList ' + recordList);
        sobject record_to_update = Schema.getGlobalDescribe().get(objtype).newSObject();

        //condition check and scorign assignment
        for (sobject so : recordList) {
            so.put('CRABB_DEV__Scoring_Point__c', 0);
            for (string key : conditionMap.keySet()) {
                list<CRABB_DEV__CRABB_Scoring_Points__mdt> conditions = conditionMap.get(key);
                for (CRABB_DEV__CRABB_Scoring_Points__mdt cond : conditions) {
                    System.debug('so.get(key) ' + so.get(key));
                    System.debug('string.valueof(so.get(key)) ' + string.valueof(so.get(key)));
                    System.debug('cond.CRABB_DEV__Values__c ' + cond.CRABB_DEV__Values__c);
                    System.debug('cond.CRABB_DEV__Filter_Type__c ' + cond.CRABB_DEV__Filter_Type__c);

                    if (Utils.checkConditionFieldValue(string.valueof(so.get(key)), cond.CRABB_DEV__Values__c, cond.CRABB_DEV__Filter_Type__c, cond.CRABB_DEV__field_type__c)) {
                        //if(OrkKernel.checkCondition(string.valueof(so.get(key)),cond.CRABB_DEV__Values__c,cond.CRABB_DEV__Filter_Type__c)){
                        Integer scoring = integer.valueof(so.get('CRABB_DEV__Scoring_Point__c')) + integer.valueof(cond.CRABB_DEV__Points__c);
                        System.debug('Scoring del campo ' + String.valueOf(key) + ' --> ' + scoring);
                        so.put('CRABB_DEV__Scoring_Point__c', scoring);
                    }
                }
                System.debug('So Object' + so);
            }

            record_to_update = Schema.getGlobalDescribe().get(objtype).newSObject();
            record_to_update.put('id', so.id);
            record_to_update.put('CRABB_DEV__Scoring_Point__c', integer.valueof(so.get('CRABB_DEV__Scoring_Point__c')));
            record_to_update.put('CRABB_DEV__Last_scoring_evaluation_date__c', System.now());

            records_to_update.add(record_to_update);
        }

        System.debug('records_to_update ---> ' + record_to_update);
        //record update
        if (Utils.cebCheckObjPermission(objtype,gd).get('UPDATE')
                && Utils.cebCheckFLSPermission(objtype, 'CRABB_DEV__Scoring_Point__c',gd).get('UPDATE')) {
            updateResult = Database.update(records_to_update, false);
        }


    }
}