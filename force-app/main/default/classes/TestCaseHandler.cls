/**
 * Created by amass on 14/11/2018.
 */

@IsTest
private class TestCaseHandler {
    @IsTest
    static void testInsertCase() {
        createTestData();
    }

    @isTest
    static void testCloseCase(){
        createTestData();
        List<Case> lc = [SELECT Id, AccountId, Blocking_SR__c FROM Case];

        Test.startTest();
        Integer offset = lc.size() - 2;
            for(Integer i = 0; i < offset; i++){
                lc.get(i).Status = 'Closed';
                lc.get(i).reason = 'Complex functionality';
            }
            update lc;

            for(Integer i = offset; i<lc.size(); i++){
                lc.get(i).Status = 'Closed';
                lc.get(i).reason = 'Complex functionality';
            }
            update lc;

        Test.stopTest();
    }

    @isTest
    static void testException(){
        createTestData();
        Case c = new Case(
                status = 'New', origin = 'Web', Blocking_SR__c = true
        );
        insert c;
    }


    private static void createTestData(){
        contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        insert con;
        Account a = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert a;

        List<Pratica__c> lp = new List<Pratica__c>();
        lp.add(
                new Pratica__c (Account__c = a.id, Stato__c =  'In Lavorazione')
        );
        lp.add(
                new Pratica__c(Account__c = a.id, Stato__c =  'Affidata')
        );
        insert lp;

        List<Case> lc = new List<Case>();
        lc.add(new Case(
                accountId = a.id, status = 'New', origin = 'Web', Blocking_SR__c = true
        ));
        lc.add(new Case(
                accountid = a.Id, status = 'New', origin = 'Phone', Blocking_SR__c = true
        ));
        lc.add(new Case(
                accountid = a.Id, status = 'New', origin = 'Web', Blocking_SR__c = false
        ));
        lc.add(new Case(
                accountid = a.Id, status = 'New', origin = 'Web', Blocking_SR__c = true
        ));
        insert lc;
    }
}