/* ---------------------------------------------------------------------------------------------------------------------
Name:            BatchScheduler.cls
Description:     This Class is for scheduling System Batches.

Test class:

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
21-Oct-2014  0.1      Endrit Sino                    First Version
----------------------------------------------------------------------------------------------------------------------*/
  
global with sharing class BatchScheduler implements Schedulable {    
    //Schedule batches
    global void execute(SchedulableContext sc) {
        BatchQueue.exceptD+='\n in BatchScheduler';
        System.abortJob(sc.getTriggerId());
        try{
            BatchQueue__c scheduleBQ = BatchQueue__c.getValues('BatchScheduler');
            BatchQueue.closeScheduler('BatchScheduler');
            BatchQueue.runBatches();
            BatchQueue.deleteClosedBatches();        
        }
        catch(Exception e){
            BatchQueue.exceptD+='\n Exception BatchScheduler';    
            ErrorClass.logError('BatchScheduler.exception','Error: '+BatchQueue.exceptD +'\n __'+System.now()+'\n\n'+Utils.getExceptionInString(e));
        }
        BatchQueue.exceptD+='\n out BatchScheduler';
    }
}