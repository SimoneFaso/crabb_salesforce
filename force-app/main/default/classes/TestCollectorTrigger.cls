/*
 * Creata Da: Endrit Sino
 * desc: Test CollectorTirgger
 * 8/10/2014
 */
@isTest
public class TestCollectorTrigger {
    static testmethod void testCollectorTrigg(){
        User u = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');
        
        Collector__c col = new Collector__c();
        col = TestClassFroDataGenAffidamenti.getCollector(u.id);
        insert col;
    }
}