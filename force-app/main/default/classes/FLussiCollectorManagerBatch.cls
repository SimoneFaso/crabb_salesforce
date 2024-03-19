/*
*   Created by: Klodjan Meta
*   Description: La classe processa i flussi collector da associare
*   Date: 02/10/2014
*/

global with sharing class FLussiCollectorManagerBatch implements Database.Batchable<sObject>, Database.Stateful{
    public class FLussiCollectorManagerBatchException extends Exception{}
    string op, idObject;
    integer scopeSize;
    public static string DebugStr = '\n FLussiCollectorManagerBatch - START: \n ';
    private List<Lotto__c> lotList = new List<Lotto__c>();
    
    // costruttore vuoto per impostare il tipo di operazione
    global FLussiCollectorManagerBatch (string operation){
        DebugStr += '\n Iniziato l\'Batch! Operazione:  ' + operation;
        op=operation;
        scopeSize=1;
    }
    
    /*
     * Se si chiama il batch per un nuovo lotto, lo scope deve fornire una lista di
     * di Lotti.
     * Diversamente: deve fornire una lista di Collector.
     */
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string queryObj='';
        DebugStr += '\n QueryLocator ';
        if(op=='NuovoLottoAffidato')
        {
            queryObj='Select id from Lotto__c where NuovoAffidamentoProcessed__c=false and Stato__c = \'Confermato\' ';
            DebugStr += '\n NuovoLottoAffidato';
        }
        else
            queryObj='Select id From Collector__c where stato__c = \'Attivo\' ';
        DebugStr += '\n Query: ' + queryObj;
        //errorClass.LogError('FLussiCollectorManagerBatch.Finish','L\'batch chiama altra operazione dal ' + op  + '\n Execution track: ' + debugStr);
        // inizio nuovo codice 17/04/17 inserimento CheckFLSPermission
        if(Utils.checkFLSPermission('Collector__c', 'TipoCompenso__c').get('ACCESS')
            && Utils.checkFLSPermission('Collector__c', 'CompensoMonoFascia__c').get('ACCESS')
            && Utils.checkFLSPermission('Collector__c', 'PrimaSogliaCompenso__c').get('ACCESS')
            && Utils.checkFLSPermission('Collector__c', 'SecondaSogliaCompenso__c').get('ACCESS')
            && Utils.checkFLSPermission('Collector__c', 'TerzaSogliaCompenso__c').get('ACCESS')
            && Utils.checkFLSPermission('Collector__c', 'QuartaSogliaCompenso__c').get('ACCESS'))
        {
            return Database.getqueryLocator(queryObj);
        }
        else return null;
        // fine nuovo codice 17/04/17 inserimento CheckFLSPermission
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        DebugStr += '\n Execute!!! Scope: ' + String.valueOf(scope.size());
        
        if (scope.size()>scopeSize){
            errorClass.LogError('FLussiCollectorManagerBatch.Execute','Scope > di scope size:'+scope.size()+' > '+ scopesize);
            return;
        }
        DebugStr += '\n Execute!';
        /*
         * Secondo le casistiche, chiama il metodo adatto del ProcessiFlussiCSV
         */
        if(op=='NuovoLottoAffidato')
        {
            DebugStr += '\n Lavorando l\'lotto!';
            List<Lotto__c> lotListTemp = new List<Lotto__c>();
            lotListTemp = (List<Lotto__c>)scope;
            
            for(Lotto__c l : lotListTemp) 
            {
                //DebugStr += '\n Chiamata ProcessiFlussiCSVManager.CreaCSV_per_Affidamento!';
                //ProcessiFlussiCSVManager.NuovoLottoAffidamento(l.id);
                //ProcessiFlussiCSVManager.CreaCSV_per_Affidamento(l.id, 'CSVNEW');
                lotList.add(l);
            }
        }
        else 
        {
            DebugStr += '\n Lavorando l\'Collector!';
            List<Collector__c> colList = new List<Collector__c>();
            colList = (List<Collector__c>)scope;
            
            if(op=='AggiornamentoAnagrafico'){
                for(Collector__c c: colList)
                    ProcessiFlussiCSVManager.AggiornamentoAnagrafico(c.id);
            }
            else if(op=='MovimentiSaldi'){
                for(Collector__c c: colList)
                    ProcessiFlussiCSVManager.AggiornamentoMovimenti(c.id);           
            }
            else if(op=='AggiornamentoRevoche'){
                for(Collector__c c: colList)
                    ProcessiFlussiCSVManager.AggiornamentoAffidamento(c.id);            
            }
        }
        //errorClass.LogError('FLussiCollectorManagerBatch.Finish','L\'batch chiama altra operazione dal ' + op  + '\n Execution track: ' + debugStr);
    }   
    
    /*imposta la cetena da farsi richiamare da se stessa
     * il ordine:     
        1) Nuovo lotto 
        2) Aggiornamento Anagrafico
        3) AggiornamentoMoviemnti
        4) AggiornamentoRevoche
     * Legende: "[If you are at step i, call step i+1]"
     */
    global void finish(Database.BatchableContext BC){ 
        DebugStr += '\n FINISH !';

        if(lotList.size()>0)
        {
            for(Lotto__c l : lotList) 
            {
                DebugStr += '\n Chiamata ProcessiFlussiCSVManager.CreaCSV_per_Affidamento!';
                //ProcessiFlussiCSVManager.NuovoLottoAffidamento(l.id);
                ProcessiFlussiCSVManager.CreaCSV_per_Affidamento(l.id, 'CSVNEW');
                //lotList.add(l);
            }
        }
        
        /*Commentato per poter separare le catene NuovoLottoAffidato e il giro aggiornamento. commentando questa parte si separano 
          le due parti.
        if(op == 'NuovoLottoAffidato')
            BatchQueue.reqBatch('FCMBB','FLussiCollectorManagerBatch',0,1,null,'AggiornamentoAnagrafico');*/
        if(op == 'AggiornamentoAnagrafico')
            BatchQueue.reqBatch('FCMBB','FLussiCollectorManagerBatch',0,1,null,'MovimentiSaldi');
        if(op == 'MovimentiSaldi')
            BatchQueue.reqBatch('FCMBB','FLussiCollectorManagerBatch',0,1,null,'AggiornamentoRevoche');
        
        errorClass.LogError('FLussiCollectorManagerBatch.Finish','L\'batch chiama altra operazione dal ' + op  + '\n Execution track: ' + debugStr);
        
        System.debug('FlussiCollector Batch calls runBatches');
        BatchQueue.runBatches();
        
        /*
        if(op == 'NuovoLottoAffidato') Database.executeBatch(new FLussiCollectorManagerBatch('AggiornamentoAnagrafico'), 1);        
        if(op == 'AggiornamentoAnagrafico')  Database.executeBatch(new FLussiCollectorManagerBatch('MovimentiSaldi'), 1);
        if(op == 'MovimentiSaldi') Database.executeBatch(new FLussiCollectorManagerBatch('AggiornamentoRevoche'), 1);    
        */
    }
}