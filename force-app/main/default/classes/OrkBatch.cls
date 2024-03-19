/* ---------------------------------------------------------------------------------------------------------------------
Name:            OrkBatch.cls
Description:
Test class:

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
16-Jun-2016  0.2      E. Sino                         Added with sharing (Security Review)
24-Aug-2021  0.3      Claudio Sanna                   Modified Start and Execute for adding check permission:
                                                      cebCheckObjPermission and cebCheckFLSPermission (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

global with sharing class OrkBatch implements Database.Batchable<SObject>, Schedulable {
    public class OrkBatchException extends Exception {
    }
    String logToSend = '';
    Boolean areLogsActive;
    Integer scopeSize = 200;
    public String sObjectName = '';
    SObjectType type;
    public String strName;
    Map<String, Schema.SObjectField> mfields;
    List<Log__c> logList = new List<Log__c>();
    String taskCondition = ' From Task where (Status=\'Non iniziata\' or Status=\'Ricerca strategia\' ) order by lastmodifiedDate Asc';
    String praticaCondition = ' From Pratica__c where (NOT(stato__c in (\'Chiusa\',\'Bloccata\'))) order by lastmodifiedDate Asc';
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    //Vecchia query new engine
    //string taskCondition = ' From Task where Status=\'Non iniziata\' order by lastmodifiedDate Asc';
    //string praticaCondition =' From Pratica__c where (NOT(stato__c in (\'Chiusa\',\'Bloccata\',\'Da elaborare\'))) order by lastmodifiedDate Asc';

    global OrkBatch() {
        this.sObjectName = 'Task';
        areLogsActive = TagHelper.getValueBoolean('OrkBatchLogl');
    }

    global OrkBatch(String StrategiaName) {
        this.sObjectName = 'Pratica__c';
        this.strName = StrategiaName;
        areLogsActive = TagHelper.getValueBoolean('OrkBatchLogl');
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select ';
        logList.add(ErrorClass.instanceError('OrkBatch:3 batch query ', query));
        String sObjectName4Desc = sObjectName.endsWithIgnoreCase('__c') ? Utils.NAMESPACE + sObjectName : sObjectName;
        try {

            if (CEBUtils.newOrkVersionEnabled()) {
                //if new version enabled, skip
                String emptyQuery = 'SELECT Id FROM Task LIMIT 0';
                return Database.getQueryLocator(emptyQuery);
            }

            type = Schema.getGlobalDescribe().get(sObjectName4Desc);
            mfields = type.getDescribe().fields.getMap();
            query += Utils.joinStrings(mfields.keySet(), ',');

            if (sObjectName == 'Task') {
                query += taskCondition;
            } else if (sObjectName == 'Pratica__c') {
                query += praticaCondition;
            }

            logList.add(ErrorClass.instanceError('OrkBatch:4 batch query ', query));
            return Database.getQueryLocator(query);

        } catch (Exception e) {

            logList.add(ErrorClass.instanceError('OrkBatch:5 Query batch', query));
            logList.add(ErrorClass.instanceError('OrkBatch:6 Query batch', e.getMessage() + '\n' + e.getLineNumber() + '\n' + e.getStackTraceString()));
            if (areLogsActive) {
                ErrorClass.checkOPFLSAndUpsertErrorLogs(logList, 'UPSERT', gd);
            }
            //if (areLogsActive && Utils.cebCheckObjPermission('Log__c', gd).get('UPSERT')) upsert logList;
            //if(areLogsActive && Utils.checkObjPermission('Log__c').get('UPDATE') && Utils.checkObjPermission('Log__c').get('INSERT')) upsert logl;
            throw new OrkBatchException('OrkBatch:7 Query batch \n ' + e.getMessage() + '\n' + e.getLineNumber() + '\n' + e.getStackTraceString() + '\n' + query);
        }
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        logToSend += 'Ora inizio batch: ' + System.now() + ' ';
        if (scope.size() > scopeSize) {
            logList.add(ErrorClass.instanceError(areLogsActive, 'OrkBatch:7 logToSend', 'Scope > di ' + scopeSize + ' :' + scope.size()));
            if (areLogsActive) {
                ErrorClass.checkOPFLSAndUpsertErrorLogs(logList, 'UPSERT', gd);
            }
/*            if (areLogsActive && Utils.cebCheckObjPermission('Log__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Log__c', 'Class_Name__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Log__c', 'Method__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Log__c', 'Line_number__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Log__c', 'Error_code__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Log__c', 'Error__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Log__c', 'Message_Out__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Log__c', 'RecordTypeId', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Log__c', 'Name__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Log__c', 'info__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Log__c', 'Message__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Log__c', 'type__c', gd).get('UPSERT')) {
                upsert logList;
            }*/
            return;
        }
        try {
            if (sObjectName == 'Task') {
                //List<Task> lTask = new List<Task>();
                update scope;
                if (areLogsActive) {
                    ErrorClass.checkOPFLSAndUpsertErrorLogs(logList, 'UPSERT', gd);
                }
                //if (areLogsActive && Utils.cebCheckObjPermission('Log__c', gd).get('UPSERT')) upsert logList;
                //if(areLogsActive && Utils.checkObjPermission('Log__c').get('UPDATE') && Utils.checkObjPermission('Log__c').get('INSERT')) upsert logl;
            } else if (sObjectName == 'Pratica__c') {
                Map<Id, Pratica__c> pMap = new Map<Id, Pratica__c>((List<Pratica__c>) scope);
                Strategia__c str = [SELECT Id FROM Strategia__c WHERE Nome__c = :strName];

                OrkPratica orkPrt = new OrkPratica();
                orkPrt.executePratica('Periodiche', pMap, str);

                logList.add(ErrorClass.instanceError(areLogsActive, 'OrkBatch:8 logToSend', 'Il batch è stato eseguito con successo! \n Il metodo executePratica() è stato eseguito con successo!'));
                if (areLogsActive) {
                    ErrorClass.checkOPFLSAndUpsertErrorLogs(logList, 'UPSERT', gd);
                }
/*                if (areLogsActive && Utils.cebCheckObjPermission('Log__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'Class_Name__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'Method__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'Line_number__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'Error_code__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'Error__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'Message_Out__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'RecordTypeId', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'Name__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'info__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'Message__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'type__c', gd).get('UPSERT')) {
                    upsert logList;
                }*/
                //if(areLogsActive && Utils.checkObjPermission('Log__c').get('UPDATE') && Utils.checkObjPermission('Log__c').get('INSERT')) upsert logl;
            }

        } catch (Exception e) {
            ErrorClass.logError('OrkBatch.execute', 'Error: ' + Utils.getExceptionInString(e));
        }
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new OrkBatch());
    }

    global void finish(Database.BatchableContext BC) {
        if (areLogsActive) {
            ErrorClass.checkOPFLSAndUpsertErrorLogs(logList, 'UPSERT', gd);
        }
        //if (areLogsActive && Utils.cebCheckObjPermission('Log__c', gd).get('UPSERT')) upsert logList;
        //if(areLogsActive && Utils.checkObjPermission('Log__c').get('UPDATE') && Utils.checkObjPermission('Log__c').get('INSERT')) upsert logl;
        BatchQueue.runBatches();
    }

}