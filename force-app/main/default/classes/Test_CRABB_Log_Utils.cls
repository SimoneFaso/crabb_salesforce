@isTest
public class Test_CRABB_Log_Utils 
{
    static testmethod void TestCLE() 
    {
        List<String> lS = new List<String>();
        lS.add('Test Platform Event Log 1');
        lS.add('Test Platform Event Log 2');
        
        Test.startTest();
        CRABB_DEV.CRABB_Log_Utils.publishCRABBLog(lS);
        Test.stopTest();
    }
}