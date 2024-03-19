global with sharing class CrabbScoringScheduler implements Schedulable {

    integer batchsize;

    global CrabbScoringScheduler(integer batchsize){
        this.batchsize=batchsize;
    }
    //Schedule batches
    global void execute(SchedulableContext sc) {
        try {
            CrabbScoringBatch cms = new CrabbScoringBatch();
            Database.executeBatch(cms, batchsize);
        } catch (Exception e) { ErrorClass.logError('CrabbScoringScheduler.exception', 'Error: ' + system.now() + '\n\n' + utils.getExceptionInString(e)); }
    }
}