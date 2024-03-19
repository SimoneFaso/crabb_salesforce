/*
*   Created by: KMeta
*   Description: La classe processa le lavorazioni degli Affidi
*   Date: 24/10/2014
*/
global with sharing class AffidiSaldoPeriodoAffidamentoUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    public class AffidiSaldoPeriodoAffidamentoUpdateBatchException extends Exception{}  

    global AffidiSaldoPeriodoAffidamentoUpdateBatch(){}
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        string queryLocatorString='';
        queryLocatorString=' Select '+Utils.getSOBJECTFieldsForQuery('Affidamento__c')+' From Affidamento__c Where Scaduto_fine_periodo_affidamento__c=null and Data_fine_affidamento_prevista__c<=today';
        try{
            // inizio nuovo codice 17/04/17 inserimento check permission
            if (Utils.checkFLSPermission('Affidamento__c', 'Data_Affidamento__c').get('ACCESS')
               && Utils.checkFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c').get('ACCESS')
               && Utils.checkFLSPermission('Affidamento__c', 'Data_Revoca__c').get('ACCESS')
               && Utils.checkFLSPermission('Affidamento__c', 'Esito_Lavorazione__c').get('ACCESS')
               && Utils.checkFLSPermission('Affidamento__c', 'Giorni_di_proroga__c').get('ACCESS')
               && Utils.checkFLSPermission('Affidamento__c', 'Incassi_aggiornati__c').get('ACCESS')
               && Utils.checkFLSPermission('Affidamento__c', 'Incasso_periodo_affidamento__c').get('ACCESS'))
            {
                return Database.getqueryLocator(queryLocatorString);
            }
            else return null;
            // fine nuovo codice 17/04/17 inserimento check permission
        }catch(Exception e){
            errorClass.LogError('AffidiSaldoPeriodoAffidamentoUpdateBatch.QueryLocator',e.getMessage()+ '\n'+e.getlinenumber()+'\n'+e.getStackTraceString());
            throw new   AffidiSaldoPeriodoAffidamentoUpdateBatchException('Exception-'+e.getMessage()+ '\n'+e.getlinenumber()+'\n'+e.getStackTraceString());
        }
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        updateScaduto((List<Affidamento__c>) scope);
    }   

    global void finish(Database.BatchableContext BC){ 
        BatchQueue.runBatches();
    }
    
    public static void updateScaduto(List<Affidamento__c> aList){
        for(Affidamento__c a:aList){
            a.Data_Scaduto_fine_periodo_affidamento__c=a.Data_scaduto_pratica_for_logic__c;
            a.Scaduto_fine_periodo_affidamento__c=a.Scaduto_pratica_for_logic__c;
        }
        update aList;
    }
}