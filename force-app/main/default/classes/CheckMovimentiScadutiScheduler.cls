/**
 * Created by m.siotto on 12/11/2020.
 */
global with sharing class CheckMovimentiScadutiScheduler implements Schedulable {
//Schedule batches
    global void execute(SchedulableContext sc) {
        try {
            CheckMovimentiScadutiBatch cms = new CheckMovimentiScadutiBatch();
            //
            Database.executeBatch(cms, 200);
        } catch (Exception e) {
            ErrorClass.logError('CheckMovimentiScadutiBatch.exception', 'Error: ' + system.now() + '\n\n' + utils.getExceptionInString(e));
        }
    }
}