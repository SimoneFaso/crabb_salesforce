/**
 * Created by MatteoSala on 26/06/2020.
 */

@IsTest
private class CRABB_MsgViewerCtrl_TEST
{
    @IsTest
    static void testBehavior()
    {
        Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        insert con;

        Account ac = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert ac;

        Pratica__c p = TestClassFroDataGenAffidamenti.getPratica(ac.Id);
        p.Stato__c = 'Da elaborare';
        insert p;

        ActivityExtended__c ae1 = new ActivityExtended__c();
        ae1.Message_Status__c = 'Sent';
        ae1.Message_Type__c = 'SMS';
        ae1.Message_Body__c = 'TEST';
        insert ae1;

        ActivityExtended__c ae2 = new ActivityExtended__c();
        ae2.Message_Status__c = 'Error';
        ae2.Message_Type__c = 'EMAIL';
        String action = EncodingUtil.base64Encode(Blob.valueOf('emp'));
        ae2.Message_Body__c = action;
        insert ae2;

        Task t1 = new Task();
        t1.WhatId = p.Id;
        t1.ActivityExtended__c = ae1.Id;
        insert t1;

        Task t2 = new Task();
        t2.WhatId = p.Id;
        t2.ActivityExtended__c = ae2.Id;
        insert t2;

        test.startTest();

        CRABB_MsgViewerCtrl.ListMsg(p.Id);

        test.stopTest();
    }
}