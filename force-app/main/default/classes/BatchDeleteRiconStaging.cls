/* ---------------------------------------------------------------------------------------------------------------------
Name:            BatchDeleteRiconStaging.cls
Description:
Test class:      TestBatchDeleteRiconStaging.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
24-May-2021  0.1      Sara Salaris                    First Version
24-Aug-2021  0.2      Claudio Sanna                   Modified Execute for adding check permission (cebCheckObjPermission)
                                                      (Security Review)
----------------------------------------------------------------------------------------------------------------------*/
    global with sharing class BatchDeleteRiconStaging implements Database.Batchable<SObject>, Database.Stateful {

        public String autore;
        public String query;
        //public String dateFilt;
        //public List<CRABB_DEV__ricon_staging_date__mdt> ricStagDate;
        public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        global BatchDeleteRiconStaging(String autoreUpd){
            autore = autoreUpd;
            query = 'SELECT Id, CRABB_DEV__RiconciliazioneId__c, CRABB_DEV__PraticaId__c, CRABB_DEV__Value__c, CRABB_DEV__Stato__c, CRABB_DEV__Autore__c FROM CRABB_DEV__Riconciliazione_Staging__c ';
            query += 'WHERE CRABB_DEV__Stato__c = \'Nuovo\' AND CRABB_DEV__Autore__c = :autore WITH SECURITY_ENFORCED';
        }

        global BatchDeleteRiconStaging(){
            List<CRABB_DEV__ricon_staging_date__mdt> ricStagDate = [SELECT CRABB_DEV__date_filter__c, Label FROM CRABB_DEV__ricon_staging_date__mdt WHERE Label = 'dateFilter' WITH SECURITY_ENFORCED];
            String dateFilt = ricStagDate.get(0).CRABB_DEV__date_filter__c;
            query = 'SELECT Id, CRABB_DEV__RiconciliazioneId__c, CRABB_DEV__PraticaId__c, CRABB_DEV__Value__c, CRABB_DEV__Stato__c, CreatedDate FROM CRABB_DEV__Riconciliazione_Staging__c ';
            query += 'WHERE CreatedDate '+ String.escapeSingleQuotes(dateFilt) +' WITH SECURITY_ENFORCED';
        }

        global Database.QueryLocator start(Database.BatchableContext BC) {
            /*String query = 'SELECT Id, CRABB_DEV__RiconciliazioneId__c, CRABB_DEV__PraticaId__c, CRABB_DEV__Value__c, CRABB_DEV__Stato__c, CRABB_DEV__Autore__c FROM CRABB_DEV__Riconciliazione_Staging__c ';
            query += 'WHERE CRABB_DEV__Stato__c = \'Nuovo\' AND CRABB_DEV__Autore__c = :autore WITH SECURITY_ENFORCED';*/
            return Database.getQueryLocator(query);
        }

        global void execute(Database.BatchableContext BC, List<CRABB_DEV__Riconciliazione_Staging__c> scope) {
            try {
                //if(scope.size() > 0) {
                if (Utils.cebCheckObjPermission('Riconciliazione_Staging__c', this.gd).get('DELETE')){
                    Database.delete(scope);
                }
                //}
            } catch (Exception ex){
                System.debug('Exception in BatchDeleteRiconStaging:execute() --> '+ex.getStackTraceString());
                ErrorClass.logError('BatchDeleteRiconStaging:execute() --> '+ex.getMessage());
            }
        }

        global void finish(Database.BatchableContext BC){
            AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed,TotalJobItems  FROM AsyncApexJob WHERE Id = :BC.getJobId()];
            System.debug('JobInfo: ' + job);
        }
}