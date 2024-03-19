global with sharing class RevocaAutomaticaAffidiBatch implements Database.Batchable<sObject>, Database.Stateful 
{
    integer scopeSize=1000;
    
    public class RevocaAutomaticaAffidiBatchException extends Exception{}
    global RevocaAutomaticaAffidiBatch(){}
    
    //global (Database.QueryLocator | Iterable<sObject>) start(Database.BatchableContext bc) 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        // collect the batches of records or objects to be passed to execute
        string queryLocatorString='';
        if(Utils.checkFLSPermission('Affidamento__c', 'Data_Fine_Affidamento__c').get('ACCESS'))
        {
            queryLocatorString='SELECT Name, Data_Fine_Affidamento__c FROM Affidamento__c WHERE Data_Fine_Affidamento__c <= TODAY AND Stato__c = \'In Corso\'';
        }
        return Database.getqueryLocator(queryLocatorString);
    }

    //global void execute(Database.BatchableContext bc, List<P> records)
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        // process each batch of records
        
        if (scope.size()>scopeSize){
            ErrorClass.logError('RevocaAutomaticaAffidiBatch.execute.ScopeSize','Lo scope scelto è più grande di quello di controllo'+scopeSize);
            return;
        }

        Integer errorCode;
        String errorMessage;
        Map<Integer,String> mError = new Map<Integer,String>();
        mError.put(0,'OK');
        mError.put(1,'Errore - Le liste sono null. Contattare l\'amministratore');
        mError.put(2,'Errore - Una o più liste non presentano elementi. Contattare l\'amministratore. Le liste sono, affidmanento, pratiche, task');
        mError.put(3,'Errore - Le liste non presentano un eguale numero di elementi. Contattare l\'amministratore. Il numero di Task e affidamenti non sono uguali, oppure ages.Severity.ERROR,il numero di pratiche e affidamenti non sono uguali.');
        mError.put(4,'Errore - La revoca degli affidamenti non è andata a buon fine!');  
        List<id> ids=new list<id>();
        integer i = 1;
        List<Affidamento__c> AffidamentiDaElaborare = (List<Affidamento__c>) scope;
        for(Affidamento__c aff: AffidamentiDaElaborare){
            ids.add(aff.id);
        }
        //affidamentiAggiornaIncassi((List<Affidamento__c>) scope);
        try
        {
            if(ids.size()>0)
            {
                errorCode = AffidamentiManager.revocaListAffidamentiScaduti(ids,'Affidamento scaduto');
                //errorCode = AffidamentiManager.revocaListAffidamentiInt(ids,'Affidamento scaduto');
            }
            
            if(errorCode == 0)
                return;
            else
            {
                errorMessage = mError.get(errorCode);
                ErrorClass.logError('RevocaAutomaticaAffidiBatchException.execute', '\n STACKTRACE: \n \n **** \n \n ' + errorMessage);
                return;
            }
        }
        catch(Exception e)
        {
            System.debug('ko' + Utils.getExceptionInString(e));

        }
    }    

    global void finish(Database.BatchableContext bc)
    {
        // execute any post-processing operations
        BatchQueue.runBatches();
    }    

}