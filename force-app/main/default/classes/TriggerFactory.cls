/**
 *  Created by: Klodjan Meta
 *  Origin: Method initially copied from "http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers"
 *  Created Date: 06/May/2014
 *  Class TriggerFactory
 *  
 * Used to instantiate and execute Trigger Handlers associated with sObjects.
 */
public with sharing class TriggerFactory
{
    /*custom exception used to throw an exception*/
    public class TriggerException extends Exception {}

    /**
     * Public static method to create and execute a trigger handler
     * Arguments:   Schema.sObjectType soType - Object type to process (SObject.sObjectType)
     * Throws a TriggerException if no handler has been coded. This mean that there is no Handler for the particular sObjec
     */
    public static void createHandler(Schema.sObjectType soType)
    {
        // Get a handler appropriate to the object being processed
        ITrigger handler = getHandler(soType);
        
        // Make sure we have a handler registered, new handlers must be registered in the getHandler method.
        if (handler == null){
            throw new TriggerException('No Trigger Handler registered for Object Type: ' + soType);
        }
        
        // Execute the handler to fulfil the trigger
        execute(handler);
    }
    
    /**
     * private static method to control the execution of the handler
     * Arguments:   ITrigger handler - A Trigger Handler to execute. TheHandler execute Bulk operations
     */ 
    private static void execute(ITrigger handler)
    {
        // Before Trigger
        if (Trigger.isBefore)
        {
            // Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore();
            handler.bulkBefore(Trigger.new);            
            
            // Iterate through the records to be deleted passing them to the handler.
            if (Trigger.isDelete){
                //handler SOQL operations
                handler.beforeDelete(Trigger.old);
            }
            // Iterate through the records to be inserted passing them to the handler.
            else if (Trigger.isInsert){
                handler.beforeInsert(Trigger.new);
            }
            // Iterate through the records to be updated passing them to the handler.
            else if (Trigger.isUpdate){
                handler.beforeUpdate(Trigger.old, Trigger.new);
            }
            
            //handler DML operations
        }
        else
        {
            // Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter();
            handler.bulkAfter(Trigger.new);               
            // Iterate through the records deleted passing them to the handler.
            if (Trigger.isDelete){
                handler.afterDelete(Trigger.old);
            }
            // Iterate through the records inserted passing them to the handler.
            else if (Trigger.isInsert){
                handler.afterInsert(Trigger.new);
            }
            // Iterate through the records updated passing them to the handler.
            else if (Trigger.isUpdate){
                handler.afterUpdate(Trigger.old, Trigger.new );
            }
        }
        
        // Perform any post processing
        handler.andFinally();
    }
    
    /**
     * private static method to get the appropriate handler for the object type.
     * Modify this method to add any additional handlers.
     *
     * Arguments:   Schema.sObjectType soType - Object type tolocate (SObject.sObjectType)
     *
     * Returns:     ITrigger - A trigger handler if one exists or null.
     */
    private static ITrigger getHandler(Schema.sObjectType soType)
    {
        if(soType == Strategia__c.sObjectType){
            return new StrategiaHandler();
        }  
        else if (soType == Task.sObjectType){
            return new TaskHandler();
        }
        else if(soType == Pratica__c.sObjectType){
            return new PraticaHandler();
        }
        else if(soType == Contact.sObjectType){
            return new ContactHandler();
        }
        else if(soType == Account.sObjectType){
            return new AccountHandler();
        }
        else if(soType == Movimento__c.sObjectType){
            return new MovimentoHandler();
        }
        else if (soType == Piano_di_Rientro__c.sObjectType){
            return new PianiDiRientroHandler();
        }                        
        else if(soType == Collector__c.sObjectType){
            return new CollectorHandler();
        }
        else if(soType == Affidamento__c.sObjectType){
            return new AffidamentoHandler();
        }
        else if(soType == Lotto__c.sObjectType){
            return new LottoHandler();
        }
        else if(soType == ActivityExtended__c.sObjectType){
            return new ActivityExtendedHandler();
        }
        /*Alessio Massidda: blocca pratiche dell'account se il case è bloccante*/
        else if(soType == Case.sObjectType){
           return new CaseHandler();
        }
        else if(soType == Riconciliazione__c.sObjectType){
            return new RiconciliazioneHandler();
        }
        else if(soType == Riconciliazione_Staging__c.sObjectType){
            return new RiconciliazioneStagingHandler(); 
        }
        /***/
        return null;
    }
}