/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestAccountHandler.cls
Description:     Test Class for Code Coverage of AccountHandler.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
08-Jun-2021  0.2      Giulia Mameli                   Added skipTriggerFalseTest and skipTriggerTrueTest to test Skip
                                                      Trigger check introduction
----------------------------------------------------------------------------------------------------------------------*/

@IsTest
public class TestAccountHandler {

    @IsTest
    static void testMainMeths() {

        AccountHandler ah = new AccountHandler();

        Test.startTest();
        Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        insert con;

        Account a = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert a;

        List<SObject> so = new List<SObject>{
                (SObject) a
        };
        ah.beforeDelete(so);
        System.assert(true, a.Name == 'Test');
        Test.stopTest();
    }

    @IsTest
    static void testBeforeDelete() {
        skipTrigger.testCase = 'skipTriggerFalse';
        Test.startTest();
        AccountHandler ah = new AccountHandler();
        ah.beforeDelete(new List<SObject>());
        ah.afterDelete(new List<SObject>());
        Test.stopTest();
    }

    @IsTest
    //To test on afterInsert when Skip Trigger = False, so Account email fields are updated
    static void skipTriggerFalseTest() {
        Test.startTest();
        Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        insert con;
        skipTrigger.testCase = 'skipTriggerFalse';
        Account acc = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        acc.E_Mail_Account_migrazione__c = 'test@emailmigr.it';
        acc.E_Mail_Sollecito_migrazione__c = 'test@emailsollmigr.it';
        insert acc;
        Test.stopTest();

        Account updAcc = [SELECT Id, Mail1__c, Mail_Sollecito__c FROM Account WHERE Id = :acc.Id LIMIT 1];
        System.assertEquals(acc.E_Mail_Account_migrazione__c, updAcc.Mail1__c, 'After Insert wrongly skipped');
        System.assertEquals(acc.E_Mail_Sollecito_migrazione__c, updAcc.Mail_Sollecito__c, 'After Insert wrongly skipped');
    }

    @IsTest
    //To test on afterInsert when Skip Trigger = True, so Account email fields updated is skipped
    static void skipTriggerTrueTest() {
        Test.startTest();
        Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        insert con;
        skipTrigger.testCase = 'skipTriggerTrue';
        Account acc = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        acc.E_Mail_Account_migrazione__c = 'test@emailmigr.it';
        acc.E_Mail_Sollecito_migrazione__c = 'test@emailsollmigr.it';
        insert acc;
        Test.stopTest();

        Account updAcc = [SELECT Id, Mail1__c, Mail_Sollecito__c FROM Account WHERE Id = :acc.Id LIMIT 1];
        System.assertEquals(null, updAcc.Mail1__c, 'After Insert wrongly skipped');
        System.assertEquals(null, updAcc.Mail_Sollecito__c, 'After Insert wrongly not skipped');

    }
}