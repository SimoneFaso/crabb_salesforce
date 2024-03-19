global with sharing class OrkBatchActivities implements Database.Batchable<sObject>{
    public class OrkBatchActivitiesException extends Exception {}
    boolean areLogsActive; 
    integer scopeSize=10;
    string sObjectName='',TaskStatus='', logToSend ='';
    SObjectType type;
    Map<String,Schema.SObjectField> mfields;
    
    string taskCondition = ' From Task where (Status=:TaskStatus ) order by lastmodifiedDate Asc';
    
    
    
    public OrkBatchActivities(string tstatus){
        this.sObjectName='Task';   
        this.TaskStatus=tstatus;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query='Select ';
         String sObjectName4Desc = sObjectName.endsWithIgnoreCase('__c')?Utils.NAMESPACE+sObjectName:sObjectName;
        try{
            type = Schema.getGlobalDescribe().get(sObjectName4Desc);
            mfields = type.getDescribe().fields.getMap();   
            query+= utils.joinStrings(mfields.keyset(),',');
            query+=taskCondition;
            // inizio nuovo codice 18/04/17 inserimento check permission 
            if(Utils.checkFLSPermission('Task', 'ActivityExtended__c').get('ACCESS')
                && Utils.checkFLSPermission('Task', 'Count_of_Events__c').get('ACCESS')
                && Utils.checkFLSPermission('Task', 'Count_of_Tasks__c').get('ACCESS')
                && Utils.checkFLSPermission('Task', 'Giorni_di_completamento_attivita__c').get('ACCESS')
                && Utils.checkFLSPermission('Task', 'Giorni_Fuori_SLA__c').get('ACCESS')
                && Utils.checkFLSPermission('Task', 'SLA__c').get('ACCESS')
                && Utils.checkFLSPermission('Task', 'Tipo_esecuzione__c').get('ACCESS'))
            {
                return Database.getQueryLocator(query);        
            }
            else return null;
        // fine nuovo codice 18/04/17 inserimento check permission 
        } catch(exception e){
            ErrorClass.logError('OrkBatch:7 Query batch \n '+ e.getMessage() + '\n'+ e.getLinenumber()+'\n'+e.getStackTraceString() +'\n'+query);
            throw new OrkBatchActivitiesException('OrkBatch:7 Query batch \n '+ e.getMessage() + '\n'+ e.getLinenumber()+'\n'+e.getStackTraceString() +'\n'+query);    
         }
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        //Removed SessionId -- CRABB security review
        /*logToSend+='Ora inizio batch: '+System.now()+' ';
        if (scope.size()>scopeSize){
            errorClass.logError('OrkBatch:7 logToSend','Scope > di '+ scopeSize+' :'+scope.size());
            return;
        }
        try{
            for(Task s:(List<Task>)scope){
                SWOutboudWSStampaPDF.WSStampaPDF pdf = new SWOutboudWSStampaPDF.WSStampaPDF();
                pdf.SessionHeader = new SWOutboudWSStampaPDF.SessionHeader_element();
                pdf.SessionHeader.sessionId=EndpointHelper.getToken('SWOutboudWSStampaPDF');
                string result = pdf.BatchStrategiaMensile(string.valueof(s.id));
            }
        }
        catch(Exception e){
            errorClass.logError('OrkActivities.CreteLettersForAttachmentFuture_3','Errore nella query:'+system.now()+'\n'+utils.getExceptionInString(e));
        }*/
    }
 
    global void finish(Database.BatchableContext BC){ 
        BatchQueue.runBatches();
    }
    
}