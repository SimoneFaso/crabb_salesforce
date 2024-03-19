global with sharing class Scheduler_class implements Schedulable{

    public static String sched = '0 00 00 * * ?';  //Every Day at Midnight 

    global static String scheduleMe() {
        Scheduler_class SC = new Scheduler_class(); 
        return System.schedule('My batch Job', sched, SC);
    }

    global void execute(SchedulableContext sc) {

        MovSaldiBatch mvsb = new MovSaldiBatch('Movimento__c');
        ID batchprocessid = Database.executeBatch(mvsb,50);           
    }
}