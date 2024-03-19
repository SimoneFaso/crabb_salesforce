/* ---------------------------------------------------------------------------------------------------------------------
Name:            HandleMappingSyncBatchScheduler.cls
Description:     Scheduler class for HandleMappingSyncBatch.cls. Invoked when DataMapper Logs are created by a batch
                 processing Source Object records.
Test class:      TestLogTrigger.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
20-Apr-2021  0.1      G.Mameli                        First Version
----------------------------------------------------------------------------------------------------------------------*/

global without sharing class HandleMappingSyncBatchScheduler implements Schedulable {
    //batchSize is dataMapperScopeSize
    Integer batchSize;

    global HandleMappingSyncBatchScheduler(Integer batchsize) {
        this.batchSize = batchsize;
    }

    global void execute(System.SchedulableContext sc) {

        Database.executeBatch(new HandleMappingSyncBatch(), batchSize);

    }

}