/**
 * Created by ssalaris on 16/06/2021.
 */

global with sharing class BatchDeleteRiconStagingScheduler implements Schedulable {
//Schedule batches
    global void execute(SchedulableContext sc) {
        try {
            BatchDeleteRiconStaging drs = new BatchDeleteRiconStaging();
            //
            Database.executeBatch(drs, 200);
        } catch (Exception e) {
            ErrorClass.logError('BatchDeleteRiconStaging.exception', 'Error: ' + system.now() + '\n\n' + utils.getExceptionInString(e));
        }
    }
}