/* ---------------------------------------------------------------------------------------------------------------------
Name:            TraceLog.cls
Description:
Test class:

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
16-Sep-2022  0.2      C.Sanna & R.Kurti    Added WITH SECURITY ENFORCED and cebCheckObjPermissions(security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class TraceLog
{
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();


    public Static Id IntegrationLog(
        String CName,
        String Method,
        String Error,
        String OName,
        String OId)
    {
        Log__c el = new Log__c(
                Class_Name__c = CName,
                Method__c = Method,
                Error__c = Error,
                Object__c = OName,
                Object_Id__c = OId
                );
        /*if (Utils.checkFLSPermission('Log__c', 'Class_Name__c').get('CREATE')
            && Utils.checkFLSPermission('Log__c', 'Method__c').get('CREATE')
            && Utils.checkFLSPermission('Log__c', 'Error__c').get('CREATE')
            && Utils.checkFLSPermission('Log__c', 'Object__c').get('CREATE')
            && Utils.checkFLSPermission('Log__c', 'Object_Id__c').get('CREATE')) {*/
        if (Utils.cebCheckObjPermission('Log__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Class_Name__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Method__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Error__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Object__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Object_Id__c',gd).get('CREATE')) {
            insert el;
        }
        
        return el.Id;
    }
    
    public Static Id ErrorLog(
        String CName,
        String Method,
        String Error,
        String OName,
        String OId)
    {
        String obj4query = Utils.NAMESPACE+'Log__c';
        Id RecTypeId = [Select Id,SobjectType,Name From RecordType WHERE Name ='Error' and SobjectType =:obj4query WITH SECURITY_ENFORCED limit 1].Id;
        Log__c el = new Log__c(
                Class_Name__c = CName,
                Method__c = Method,
                Error__c = Error,
                Object__c = OName,
                Object_Id__c = OId,
                RecordTypeId = RecTypeId
                );
        /*if (Utils.checkFLSPermission('Log__c', 'Class_Name__c').get('CREATE')
            && Utils.checkFLSPermission('Log__c', 'Method__c').get('CREATE')
            && Utils.checkFLSPermission('Log__c', 'Error__c').get('CREATE')
            && Utils.checkFLSPermission('Log__c', 'Object__c').get('CREATE')
            && Utils.checkFLSPermission('Log__c', 'Object_Id__c').get('CREATE')
            && Utils.checkFLSPermission('Log__c', 'RecordTypeId').get('CREATE')) {*/
        if (Utils.cebCheckObjPermission('Log__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Class_Name__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Method__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Error__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Object__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Object_Id__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Log__c', 'RecordTypeId',gd).get('CREATE')) {
            insert el;
        }
        
        return el.Id;
    }

}