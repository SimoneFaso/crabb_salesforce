/* ---------------------------------------------------------------------------------------------------------------------
Name:            ErrorClass.cls
Description:     Error Class for managing errors that occur in code execution
                 The class in the non static objects can be used as a parameter, which helps to know if any error has occurred.
                 In case of static methods, the class can be passed as a parameter.
Test class:      TestErrorClass.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
12-May-2014  0.1      Klodjan Meta                    First Version
25-Aug-2021  0.2      Giulia Mameli                   Added checkOPFLSAndUpsertErrorLogs (Security Review)
13-Sep-2022  0.3      R.Kurti & C.Sanna               Added cebCheckObjPermission (security review)

----------------------------------------------------------------------------------------------------------------------*/

public with sharing class ErrorClass {
    public String className;
    public String method;
    public String lineNumber;
    public String type;
    public String errCode;
    public String errMessage;
    public String descError;
    public Log__c log;
    public Boolean enableEmailMsg;
    public static Map<String, Schema.RecordTypeInfo> nameID;
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public static void logError(String error) {
        Log__c log = new Log__c();
        log.Error__c = error;
        log.RecordTypeId = getRecordTypeId('Debug');
        if (Utils.cebCheckObjPermission('Log__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Class_Name__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Class_Name__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Method__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Line_number__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'type__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Error_code__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Error__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Message_Out__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'recordtypeid', gd).get('CREATE') && TagHelper.getValueBoolean('enableLog2Object')) {
            insert log;
        }

    }

    public static void logError(String className, String errorMess) {
        Log__c log = new Log__c();
        log.Class_Name__c = className;
        log.Error__c = errorMess;
        setEmailMessage(className, errorMess);
        log.RecordTypeId = getRecordTypeId('Error');

        if (Utils.cebCheckObjPermission('Log__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Class_Name__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Class_Name__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Method__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Line_number__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'type__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Error_code__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Error__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Message_Out__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'RecordtypeId', gd).get('CREATE') && TagHelper.getValueBoolean('enableLog2Object')) {
            insert log;
        }

    }

    public static Id getRecordTypeId(String RecordTypeName) {

        if (nameId == null) {
            nameId = Schema.SObjectType.Log__c.getRecordTypeInfosByDeveloperName();
        }

        return nameId.get(RecordTypeName).getRecordTypeId();
    }

    public static Log__c istanceError(String code, String message) {
        Log__c log = new Log__c();
        Error_register__c er = new Error_register__c();
        if (code != null && code.length() < 20) er = Error_register__c.getInstance(code);
        log.Error_code__c = code;
        log.Error__c = message;
        log.RecordTypeId = getRecordTypeId('Error');

        if (er != null) {
            log.Name__c = er.Name__c;
            log.info__c = er.Info__c;
            log.Message__c = er.Message__c;
            log.type__c = er.Type__c;
        }
        return log;
    }

    public static Log__c instanceError(String code, String message) {
        Log__c log = new Log__c();
        Error_register__c er = new Error_register__c();
        if (code != null && code.length() < 20) er = Error_register__c.getInstance(code);
        log.Error_code__c = code;
        log.Error__c = message;
        log.RecordTypeId = getRecordTypeId('Error');

        if (er != null) {
            log.Name__c = er.Name__c;
            log.info__c = er.Info__c;
            log.Message__c = er.Message__c;
            log.type__c = er.Type__c;
        }
        return log;
    }

    public static Log__c instanceError(Boolean debug, String code, String message) {
        Log__c log = new Log__c();
        Error_register__c er = new Error_register__c();
        if (code != null && code.length() < 20) er = Error_register__c.getInstance(code);
        log.Error_code__c = code;
        log.Error__c = message;
        if(debug) {
            log.RecordTypeId = getRecordTypeId('Debug');
        } else {
            log.RecordTypeId = getRecordTypeId('Error');
        }


        if (er != null) {
            log.Name__c = er.Name__c;
            log.info__c = er.Info__c;
            log.Message__c = er.Message__c;
            log.type__c = er.Type__c;
        }
        return log;
    }

    public ErrorClass() {
    }

    public ErrorClass(String className, String method, String lineNumber, String type, String errMessage, String errCode, String descError) {
        this.className = className;
        this.method = method;
        this.lineNumber = lineNumber;
        this.type = type;
        this.errMessage = errMessage;
        this.errCode = errCode;
        this.descError = descError;
        setLog();
    }

    public ErrorClass(String className, String method, String lineNumber, String type, String errMessage, String errCode) {
        this.className = className;
        this.method = method;
        this.lineNumber = lineNumber;
        this.type = type;
        this.errMessage = errMessage;
        this.errCode = errCode;
        setLog();
    }

    public ErrorClass(String className, String method, String lineNumber, String type, String errMessage) {
        this.className = className;
        this.method = method;
        this.lineNumber = lineNumber;
        this.type = type;
        this.errMessage = errMessage;
        setLog();
    }

    public void setLog() {
        log = new Log__c();
        log.Class_Name__c = className;
        log.Method__c = method;
        log.Line_number__c = lineNumber;
        log.type__c = type;
        log.Error_code__c = errCode;
        log.Error__c = errMessage;
        log.Message_Out__c = descError;
        log.RecordTypeId = getRecordTypeId('Error');
        this.setEmailMessage(className, method, lineNumber, errMessage + ' ' + descError);

    }

    private static void setEmailMessage(String s, String s1) {
        String body = 'Error report from orgid:' + UserInfo.getOrganizationId() + '<br/>' +
                'Customer Name:' + UserInfo.getOrganizationName() + ' UserEmail: ' + UserInfo.getUserEmail() + '<br/><br/>';

        body += 'User details, Firstname:' + UserInfo.getFirstName() + ' Lastname:' + UserInfo.getLastName() + ' <br/>';
        body += 'Code:' + s + '<br/>';
        body += 'Message:' + s1 + '<br/>';
        // Email the Batch Job's submitter that the Job is finished.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{
                'build@balanceconsulting.it'
        };
        mail.setToAddresses(toAddresses);
        mail.setSubject('[ERROR][Salesforce][CRABB]');
        mail.setHtmlBody(body);
        if (!Test.isRunningTest() && TagHelper.getValueBoolean('EnableEmailDebugMsg')) {
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                        mail
                });
            } catch (Exception e) {
                System.debug('Error sendEmail:' + e.getMessage());
            }
        }
    }

    private void setEmailMessage(String className, String method, String lineNumber, String errorMessage) {
        String body = 'Error report from orgid:' + UserInfo.getOrganizationId() + '<br/>' +
                'Customer Name:' + UserInfo.getOrganizationName() + ' UserEmail: ' + UserInfo.getUserEmail() + '<br/><br/>';

        body += 'User details, Firstname:' + UserInfo.getFirstName() + ' Lastname:' + UserInfo.getLastName() + ' <br/>';
        body += '<table>';
        body += '<tr><th>Class Name</th><th>Method</th><th>Line number</th><th>Error message</th></tr>';
        body += '<tr><td>' + className + '</td><td>' + method + '</td><td>' + lineNumber + '</td><td style="text-align:center">' + errorMessage + '</td></tr>';
        body += '</table><br/>';
        // Email the Batch Job's submitter that the Job is finished.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{
                'build@balanceconsulting.it'
        };
        mail.setToAddresses(toAddresses);
        mail.setSubject('[ERROR][Salesforce][CRABB]');
        mail.setHtmlBody(body);
        if (!Test.isRunningTest() && TagHelper.getValueBoolean('EnableEmailDebugMsg')) {
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                        mail
                });
            } catch (Exception e) {
                System.debug('Error sendEmail:' + e.getMessage());
            }
        }
    }

    public void logError() {
        /*if (Utils.cebCheckObjPermission('Log__c',gd).get('CREATE')
                && Utils.checkFLSPermission('Log__c', 'Class_Name__c').get('CREATE')
                && Utils.checkFLSPermission('Log__c', 'Class_Name__c').get('CREATE')
                && Utils.checkFLSPermission('Log__c', 'Method__c').get('CREATE')
                && Utils.checkFLSPermission('Log__c', 'Line_number__c').get('CREATE')
                && Utils.checkFLSPermission('Log__c', 'type__c').get('CREATE')
                && Utils.checkFLSPermission('Log__c', 'Error_code__c').get('CREATE')
                && Utils.checkFLSPermission('Log__c', 'Error__c').get('CREATE')
                && Utils.checkFLSPermission('Log__c', 'Message_Out__c').get('CREATE')
                && Utils.checkFLSPermission('Log__c', 'recordtypeid').get('CREATE') && TagHelper.getValueBoolean('enableLog2Object')) {
            insert log;
        }*/
        if (Utils.cebCheckObjPermission('Log__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Class_Name__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Class_Name__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Method__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Line_number__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'type__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Error_code__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Error__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Message_Out__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'recordtypeid',gd).get('CREATE') && TagHelper.getValueBoolean('enableLog2Object')) {
            insert log;
        }

    }

    /*
    This method checks if the current user has the type of access required by operation param for the Log Object and fields
    and upsert logList.
    The logs upsert has been placed here and not in the class where the method is invoked because of Security Review requirements
    */
    public static void checkOPFLSAndUpsertErrorLogs(List<Log__c> logList, String operation, Map<String, Schema.SObjectType> gd) {
        if (logList.size() > 0
            && Utils.cebCheckObjPermission('Log__c', gd).get(operation)
            && Utils.cebCheckFLSPermission('Log__c', 'Class_Name__c', gd).get(operation)
            && Utils.cebCheckFLSPermission('Log__c', 'Method__c', gd).get(operation)
            && Utils.cebCheckFLSPermission('Log__c', 'Line_number__c', gd).get(operation)
            && Utils.cebCheckFLSPermission('Log__c', 'Error_code__c', gd).get(operation)
            && Utils.cebCheckFLSPermission('Log__c', 'Error__c', gd).get(operation)
            && Utils.cebCheckFLSPermission('Log__c', 'Message_Out__c', gd).get(operation)
            && Utils.cebCheckFLSPermission('Log__c', 'RecordTypeId', gd).get(operation)
            && Utils.cebCheckFLSPermission('Log__c', 'Name__c', gd).get(operation)
            && Utils.cebCheckFLSPermission('Log__c', 'info__c', gd).get(operation)
            && Utils.cebCheckFLSPermission('Log__c', 'Message__c', gd).get(operation)
            && Utils.cebCheckFLSPermission('Log__c', 'type__c', gd).get(operation)) {
            upsert logList;
        }


    }
}