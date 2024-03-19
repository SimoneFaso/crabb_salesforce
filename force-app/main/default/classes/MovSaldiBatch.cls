global with sharing class MovSaldiBatch implements Database.Batchable<sObject>{
    
    /*
    *   Creata da: Endrit Sino
    *   Desc: Questa classe calcolerá e creerá il record di tipo SALDO ANNO 
    *   tramite il execute().
    */
    
    // var usati durante l'esecuzione del Batch
    String logToSend ='';
    integer scopeSize=2000;
    string sObjectName='';
    SObjectType type;
    Map<String,Schema.SObjectField> mfields;
    List<Log__c> logl = new List<Log__c>();
    string movimentoCondition = ' From Movimento__c where RecordType.developername=\'SALDO_MESE_CONSOLIDATO\' and Calcola_SALDO_ANNO__c = true And SALDO_ANNO_LAVORATO__c  = false order by lastmodifiedDate Asc';
    
    /* 1. interrogare il oggetto Movimento con un query con
    *  tutti i campi e come condizione: Calcola_SALDO_ANNO__C = true
    */
    
    // Specificha i vari costruttori
    public MovSaldiBatch(String sObjectN){
        this.sObjectName = sObjectN;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query='Select ';
        String sObjectName4Desc = sObjectName.endsWithIgnoreCase('__c')?Utils.NAMESPACE+sObjectName:sObjectName;
        try{// carica tutti i parametri del Movimento
            type = Schema.getGlobalDescribe().get(sObjectName4Desc);
            mfields = type.getDescribe().fields.getMap();   
            query+= utils.joinStrings(mfields.keyset(),',');
            
            // fissa il condizione del movimento
            query += movimentoCondition;
            // inizio nuovo codice 18/04/17 inserimento check permission 
            if(Utils.checkFLSPermission('movimento__C', 'Data_Scadenza__c').get('ACCESS')
                && Utils.checkFLSPermission('movimento__C', 'Importo__c').get('ACCESS')
                && Utils.checkFLSPermission('movimento__C', 'Flag_Incasso_Utente__c').get('ACCESS'))
            {
                return Database.getQueryLocator(query);         
            }
            else return null;
            // fine nuovo codice 18/04/17 inserimento check permission 
        }catch(Exception e){
            logL.add(errorClass.istanceError('MovSaldiBatch.QueryLocator.Exception:Query batch',query));       
            logL.add(errorClass.istanceError('MovSaldiBatch.QueryLocator.Exception:Query batch',e.getMessage() + '\n'+ e.getLinenumber()+'\n'+e.getStackTraceString()));       
            // *cosa chiedere al DB, se si individua un errore?
            // inizio nuovo codice 18/04/17 inserimento check permission 
            if(Utils.checkFLSPermission('movimento__C', 'Data_Scadenza__c').get('ACCESS')
                && Utils.checkFLSPermission('movimento__C', 'Importo__c').get('ACCESS')
                && Utils.checkFLSPermission('movimento__C', 'Flag_Incasso_Utente__c').get('ACCESS'))
            {
                return Database.getQueryLocator('Select id from Movimento__c limit 10'); 
            }    
            else return null;
            // fine nuovo codice 18/04/17 inserimento check permission 
        }   
    }   
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        logToSend+='Ora inizio batch: '+System.now()+' ';
        // controlla se i oggetti che stano per essere processati rispettano lo scope size
        if (scope.size()>scopeSize){
            logL.add(errorClass.istanceError('MovSaldiBatch.Execute.logToSend','Scope > di '+ scopeSize+' :'+scope.size()));
            return;
        }
        
        // esegui un typecasting per i nostri movimenti
        //GestioneSaldi GSIstance = new GestioneSaldi();
        //GSIstance.executeSaldiLogic((List<Movimento__c>) scope);
        
    }   

    global void finish(Database.BatchableContext BC){ 
        upsert logl;
        BatchQueue.runBatches();
    }
}