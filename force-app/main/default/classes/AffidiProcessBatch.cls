/*
*   Created by: KMeta
*   Description: La classe processa le lavorazioni degli Affidi
*   Date: 25/09/2014
*/

global with sharing class AffidiProcessBatch implements Database.Batchable<sObject>, Database.Stateful{
    public class AffidiProcessBatchException extends Exception{}
    public list<id> iLotti;
    public string tipoOperazione;
    public integer scopeSize;
    
    // Costruttore classe 
    global AffidiProcessBatch(List<Lotto__c> lotti){
        try{
            iLotti=new List<id>();
            for(lotto__c l:lotti){
                iLotti.add(l.id);
            }
            tipoOperazione='LottiInCreazione';
        }
        catch(Exception e){
            ErrorClass.LogError('AffidiProcessBatch.execute.Constructor','Errore: '+e.getMessage()+'\n linenumber:'+e.getlinenumber()+'\n stackTrace:' + e.getStackTraceString());
            throw new   AffidiProcessBatchException('Errore di sistema in IntegrationProcessAttachmentBatch.constructor. Contattare amministrazione.');
        }
    }
    global AffidiProcessBatch(list<id> lotti,string operation){
        try{
            iLotti=new list<id>();
            iLotti=lotti;
            tipoOperazione='PreparaPreLotti';
        }
        catch(Exception e){
            ErrorClass.LogError('AffidiProcessBatch.execute.Constructor','Errore: '+e.getMessage()+'\n linenumber:'+e.getlinenumber()+'\n stackTrace:' + e.getStackTraceString());
            throw new   AffidiProcessBatchException('Errore di sistema in IntegrationProcessAttachmentBatch.constructor. Contattare amministrazione.');
        }
    }   
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        string queryLocatorString='';
        system.debug('***tipoOperazione:'+tipoOperazione);
        if(tipoOperazione=='LottiInCreazione'){
            scopeSize=1;
            system.debug('***iLotti:'+iLotti);
            if(iLotti==null || iLotti.size()==0){
                ErrorClass.logError('AffidiProcessBatch.QueryLocator.LottiInCreazione','Deve essere presente almeno un lotto da lavorare');
                return null;
            }
            queryLocatorString=' Select '+Utils.getSOBJECTFieldsForQuery('Lotto__c')+' From Lotto__c Where id in:iLotti';
        }
        if(tipoOperazione=='PreparaPreLotti'){
            scopeSize=500;
            if(iLotti==null || iLotti.size()==0){
                ErrorClass.logError('AffidiProcessBatch.QueryLocator.PreparaPreLotti','Deve essere presente almeno un lotto da lavorare');
                return null;
            }
            queryLocatorString=' Select '+Utils.getSOBJECTFieldsForQuery('Affidamento__c')+' From Affidamento__c Where Lotto__c in:iLotti and stato__c!=\'Annullato\'';
            system.debug('***queryLocatorString:'+queryLocatorString);
        }
        try{
            // inizio nuovo codice 17/04/17 inserimento check permission
            if (Utils.checkFLSPermission('Lotto__c', 'tipo__c').get('ACCESS')
                && Utils.checkFLSPermission('Lotto__c', 'stato__c').get('ACCESS')
                && Utils.checkFLSPermission('Lotto__c', 'Pratiche_pre_lotto__c').get('ACCESS')
                && Utils.checkFLSPermission('Lotto__c', 'Affidamenti_support_Scaduto_Affidato__c').get('ACCESS')
                && Utils.checkFLSPermission('Lotto__c', 'Affidamenti_support_numero_affidi__c').get('ACCESS')
                && Utils.checkFLSPermission('Lotto__c', 'Agenzia_di_Recupero__c').get('ACCESS')
                && Utils.checkFLSPermission('Lotto__c', 'Affidamenti_support_collector_ragSoc__c').get('ACCESS')
                && Utils.checkFLSPermission('Lotto__c', 'Affidamenti_support_Percentuale_effettiv__c').get('ACCESS')
                && Utils.checkFLSPermission('Lotto__c', 'Affidamenti_support_Posizione__c').get('ACCESS')
                && Utils.checkFLSPermission('Lotto__c', 'Affidamenti_support_Codice_prelotto__c').get('ACCESS'))
            {
                return Database.getqueryLocator(queryLocatorString);
            }
            else return null;
            // fine nuovo codice 17/04/17 inserimento check permission
        }catch(Exception e){
            errorClass.LogError('AffidiProcessBatch.QueryLocator',e.getMessage()+ '\n'+e.getlinenumber()+'\n'+e.getStackTraceString());
            throw new   AffidiProcessBatchException('Exception-'+e.getMessage()+ '\n'+e.getlinenumber()+'\n'+e.getStackTraceString());
        }
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        if (scope.size()>scopeSize){
            ErrorClass.logError('AffidiProcessBatch.execute.ScopeSize','Lo scope scelto è più grande di quello di controllo'+scopeSize);
            return;
        }
        if(tipoOperazione=='LottiInCreazione'){
            for(lotto__c l:(List<Lotto__c>)Scope){
                AffidamentiManager.creaAffidamenti(l);
            }
        }
        else if(tipoOperazione=='PreparaPreLotti'){
            AffidamentiManager.preparaPreLotti((List<Affidamento__c>) scope);
        }
    }   

    global void finish(Database.BatchableContext BC){ 
        if(tipoOperazione=='LottiInCreazione'){
            Database.executeBatch(new AffidiProcessBatch(iLotti,'PreparaPreLotti'), 500);
        }
        BatchQueue.runBatches();
        
    }
    

}