/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestErrorClass.cls
Description:     Test Class for code coverage of ErrorClass.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
04-Aug-2014  0.1      Klodjan Meta                    First Version
25-Aug-2021  0.2      Giulia Mameli                   Added TestcheckOPFLSForErrorLog, errorClassInstanceDebugNoCustSett,
                                                      errorClassInstanceDebugWithCustSett (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

@IsTest
public class TestErrorClass {
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    @IsTest static void errorClassInstance_1() {
        Test.startTest();
        Tag__c t = new Tag__c();
        t.Name = 'enableLog2Object';
        t.ValueBoolean__c = true;
        insert t;
        ErrorClass err = new ErrorClass();
        Test.stopTest();
    }

    @IsTest static void errorClassInstance_2() {
        Test.startTest();
        Tag__c t = new Tag__c();
        t.Name = 'enableLog2Object';
        t.ValueBoolean__c = true;
        insert t;
        ErrorClass err = new ErrorClass('className', 'method', 'lineNumber', 'type', 'errMessage', 'errCode', 'descError');
        Test.stopTest();
    }

    @IsTest static void errorClassInstance_3() {
        Test.startTest();
        Tag__c t = new Tag__c();
        t.Name = 'enableLog2Object';
        t.ValueBoolean__c = true;
        insert t;
        ErrorClass err = new ErrorClass('className', 'method', 'lineNumber', 'type', 'errMessage', 'errCode');
        err.logError();
        Test.stopTest();
    }

    @IsTest static void errorClassInstance_4() {
        Test.startTest();
        Tag__c t = new Tag__c();
        t.Name = 'enableLog2Object';
        t.ValueBoolean__c = true;
        insert t;
        ErrorClass err = new ErrorClass('className', 'method', 'lineNumer', 'type', 'errMessage');
        err.logError();
        Test.stopTest();
    }

    @IsTest static void errorClasslogError_1() {
        Log__c log = new Log__c();
        Test.startTest();
        Tag__c t = new Tag__c();
        t.Name = 'enableLog2Object';
        t.ValueBoolean__c = true;
        insert t;
        ErrorClass.logError('xxx');
        log = [Select Id, Error__c From Log__c limit 1] ;
        Test.stopTest();
        System.assertEquals('xxx', log.Error__c);
    }

    @IsTest static void errorClasslogError_2() {
        Log__c log = new Log__c();
        Test.startTest();
        Tag__c t = new Tag__c();
        t.Name = 'enableLog2Object';
        t.ValueBoolean__c = true;
        insert t;
        ErrorClass.logError('xxx', 'yyy');
        log = [Select Id, Error__c, Class_Name__c From Log__c limit 1] ;
        Test.stopTest();
        System.assertEquals('xxx', log.Class_Name__c);
        System.assertEquals('yyy', log.Error__c);
    }

    @IsTest static void errorClassIstanceError_1() {
        /* No custom setting */
        Log__c log = new Log__c();
        Log__c log1 = new Log__c();

        Test.startTest();

        Tag__c t = new Tag__c();
        t.Name = 'enableLog2Object';
        t.ValueBoolean__c = true;
        insert t;

        log = ErrorClass.IstanceError('xxx', 'yyy');
        log1 = ErrorClass.InstanceError('xxx', 'yyy');
        insert log;
        insert log1;


        Test.stopTest();

        System.assertEquals('xxx', log.Error_code__c);
        System.assertEquals('yyy', log.Error__c);

        System.assertEquals('xxx', log1.Error_code__c);
        System.assertEquals('yyy', log1.Error__c);
        Id errorLogRTId = ErrorClass.getRecordTypeId('Error');
        System.assertEquals(errorLogRTId, log1.RecordTypeId);

    }

    @IsTest static void errorClassIstanceError_2() {
        /* With custom setting */
        Log__c log = new Log__c();
        Log__c log1 = new Log__c();

        Error_register__c er = new Error_register__c();
        er.Name__c = 'name';
        er.Name = 'xxx';
        er.Info__c = 'zzz';
        er.Message__c = 'Message';
        er.Type__c = 'Tipo';
        insert er;

        Test.startTest();

        Tag__c t = new Tag__c();
        t.Name = 'enableLog2Object';
        t.ValueBoolean__c = true;
        insert t;

        log = ErrorClass.IstanceError('xxx', 'yyy');
        log1 = ErrorClass.InstanceError('xxx', 'yyy');
        insert log;
        insert log1;

        Test.stopTest();
        System.assertEquals('xxx', log.Error_code__c);
        System.assertEquals('yyy', log.Error__c);
        System.assertEquals('name', log.Name__c);
        System.assertEquals('zzz', log.info__c);
        System.assertEquals('Message', log.Message__c);
        System.assertEquals('Tipo', log.type__c);

        System.assertEquals('xxx', log1.Error_code__c);
        System.assertEquals('yyy', log1.Error__c);
        System.assertEquals('name', log1.Name__c);
        System.assertEquals('zzz', log1.info__c);
        System.assertEquals('Message', log1.Message__c);
        System.assertEquals('Tipo', log1.type__c);

    }

    @IsTest static void  testCheckOPFLSForErrorLog() {
        List<Log__c> logsList = new List<Log__c>();

        Error_register__c er = new Error_register__c();
        er.Name__c = 'name';
        er.Name = 'xxx';
        er.Info__c = 'zzz';
        er.Message__c = 'Message';
        er.Type__c = 'Tipo';
        insert er;

        Test.startTest();


        logsList.add(ErrorClass.InstanceError('xxx', 'yyy'));

        ErrorClass.checkOPFLSAndUpsertErrorLogs(logsList,'INSERT',gd);


        Test.stopTest();
        System.assertEquals('xxx', logsList[0].Error_code__c);
        System.assertEquals('Message', logsList[0].Message__c);

    }

    @IsTest static void errorClassInstanceDebugNoCustSett() {
        /* No custom setting */
        Log__c log = new Log__c();

        Test.startTest();

        Tag__c t = new Tag__c();
        t.Name = 'enableLog2Object';
        t.ValueBoolean__c = true;
        insert t;

        log = ErrorClass.InstanceError(t.ValueBoolean__c, 'xxx', 'yyy');
        insert log;

        Test.stopTest();

        System.assertEquals('xxx', log.Error_code__c);
        System.assertEquals('yyy', log.Error__c);
        Id debugLogRTId = ErrorClass.getRecordTypeId('Debug');
        System.assertEquals(debugLogRTId, log.RecordTypeId);

    }

    @IsTest static void errorClassInstanceDebugWithCustSett() {
        /* With custom setting */
        Log__c log = new Log__c();

        Error_register__c er = new Error_register__c();
        er.Name__c = 'name';
        er.Name = 'xxx';
        er.Info__c = 'zzz';
        er.Message__c = 'Message';
        er.Type__c = 'Tipo';
        insert er;

        Test.startTest();

        Tag__c t = new Tag__c();
        t.Name = 'enableLog2Object';
        t.ValueBoolean__c = false;
        insert t;

        log = ErrorClass.InstanceError(t.ValueBoolean__c, 'xxx', 'yyy');
        insert log;

        Test.stopTest();

        System.assertEquals('xxx', log.Error_code__c);
        System.assertEquals('yyy', log.Error__c);
        Id debugLogRTId = ErrorClass.getRecordTypeId('Error');
        System.assertEquals(debugLogRTId, log.RecordTypeId);

    }
}