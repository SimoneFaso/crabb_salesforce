/*
 * Creata da: Endrit Sino
 * Desc: Test Affidamenti trigger
 * 5/10/2014
 */
@isTest
public class TestAffidamentoTrigger {
    static testmethod void tetTrigger(){
        Affidamento__c aff = new Affidamento__c();
        aff = TestClassFroDataGenAffidamenti.getQuickAffido();
        insert aff;
        System.assert(true, aff.Stato__c == 'stato');

        update aff;
    }
}