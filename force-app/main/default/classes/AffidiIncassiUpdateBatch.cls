/*
*   Created by: KMeta
*   Description: La classe processa le lavorazioni degli Affidi
*   Date: 24/10/2014
*/
global with sharing class AffidiIncassiUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    public class affidiIncassiUpdateBatchException extends Exception{}  
    integer scopeSize=1000;
    
    public AffidiIncassiUpdateBatch(){}   
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        string queryLocatorString='';
        queryLocatorString=' Select '+Utils.getSOBJECTFieldsForQuery('Affidamento__c')+' From Affidamento__c Where Incassi_aggiornati__c=false';
        try{
            // inizio nuovo codice 17/04/17 inserimento check permission
            if (Utils.checkFLSPermission('Affidamento__c', 'Data_Affidamento__c').get('ACCESS')
               && Utils.checkFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c').get('ACCESS')
               && Utils.checkFLSPermission('Affidamento__c', 'Data_Revoca__c').get('ACCESS')
               && Utils.checkFLSPermission('Affidamento__c', 'Esito_Lavorazione__c').get('ACCESS')
               && Utils.checkFLSPermission('Affidamento__c', 'Giorni_di_proroga__c').get('ACCESS')
               && Utils.checkFLSPermission('Affidamento__c', 'Incassi_aggiornati__c').get('ACCESS')
               && Utils.checkFLSPermission('Affidamento__c', 'Incasso_periodo_affidamento__c').get('ACCESS')
               && !CEBUtils.newOrkVersionEnabled())
        {
            return Database.getqueryLocator(queryLocatorString);
        }
        else return null;
        // fine nuovo codice 17/04/17 inserimento check permission
        }catch(Exception e){
            errorClass.LogError('affidiIncassiUpdateBatch.QueryLocator',e.getMessage()+ '\n'+e.getlinenumber()+'\n'+e.getStackTraceString());
            throw new   affidiIncassiUpdateBatchException('Exception-'+e.getMessage()+ '\n'+e.getlinenumber()+'\n'+e.getStackTraceString());
        }
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        if (scope.size()>scopeSize){
            ErrorClass.logError('affidiIncassiUpdateBatch.execute.ScopeSize','Lo scope scelto è più grande di quello di controllo'+scopeSize);
            return;
        }
        affidamentiAggiornaIncassi((List<Affidamento__c>) scope);
    }   

    global void finish(Database.BatchableContext BC){ 
        BatchQueue.runBatches();
    }
    
    public static void affidamentiAggiornaIncassi(List<Affidamento__c> aList){
        List<id> idAffidamenti=new List<id>();
        for(affidamento__c a:aList){
            a.Incasso_periodo_affidamento__c=0;
            a.Incasso_periodo_proroga_piani_di_rientro__c=0;
            a.Incasso_periodo_affidamento_False__c=0;
            a.Incasso_periodo_proroga_PDR_False__c=0;      
        }
        Map<id,Affidamento__c> ma = new Map<id,Affidamento__c>(aList);
        idAffidamenti.addAll(ma.keyset());
        if(Utils.checkFLSPermission('movimento__C', 'Data_Scadenza__c').get('ACCESS')
            && Utils.checkFLSPermission('movimento__C', 'Importo__c').get('ACCESS')
            && Utils.checkFLSPermission('movimento__C', 'Flag_Incasso_Utente__c').get('ACCESS'))
        {
            List<Movimento__c> mList=[Select id,Affidamento__C, Data_Scadenza__c,pratica__c,Importo__c,Flag_Incasso_Utente__c From movimento__C where Affidamento__c in: idAffidamenti];
            for(Movimento__c m:mList){
                affidamento__c a=ma.get(m.Affidamento__C);
                if(a.Data_Affidamento__c<=m.data_scadenza__c && m.data_scadenza__c <= a.Data_fine_affidamento_prevista__c){
                    if(m.Flag_Incasso_Utente__c){
                        a.Incasso_periodo_affidamento__c+=m.Importo__c;
                    }
                    else{
                        a.Incasso_periodo_affidamento_False__c+=m.Importo__c;
                    }
                    a.Incassi_aggiornati__c=true;
                }
                else{
                    if(m.Flag_Incasso_Utente__c){
                        a.Incasso_periodo_proroga_piani_di_rientro__c+=m.Importo__c;
                    }
                    else{
                        a.Incasso_periodo_proroga_PDR_False__c+=m.Importo__c;
                    }
                    a.Incassi_aggiornati__c=true;
                }
            }
        }
        update ma.values();
    }
}