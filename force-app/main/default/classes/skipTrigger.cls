/* ---------------------------------------------------------------------------------------------------------------------
Name:            skipTrigger.cls
Description:     Utils class used to retrieve Skip Trigger Custom Metadata for a specific SObject used to disable its
                 related trigger if skip is true.
Test class:      TestSkipTrigger.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
03-Mar-2020  0.1      Alessandro Smiriglia            First Version
08-Jun-2021  0.2      Giulia Mameli                   Modified for using ceb methods and for using Test Case field
16-Sep-2022  0.3      C.Sanna & R.Kurti               Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class skipTrigger {
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    //Variable created for Account Handler testing purposes. It uses Test_Case__c field value to test both skip = true and skip = false
    public static String testCase {public get; public set;}

    public static Boolean skip(String objName) {
        Boolean skip = false;

        /*if (Utils.cebCheckFLSPermission('CRABB_DEV__Skip_trigger__mdt', 'CRABB_DEV__Sobject__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('CRABB_DEV__Skip_trigger__mdt', 'CRABB_DEV__Skip__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('CRABB_DEV__Skip_trigger__mdt', 'Id', gd).get('ACCESS')) {
*/
            List<CRABB_DEV__Skip_trigger__mdt> skipList = [SELECT Id, CRABB_DEV__Sobject__c, CRABB_DEV__Skip__c FROM CRABB_DEV__Skip_trigger__mdt
                                                           WHERE CRABB_DEV__Sobject__c =: objName AND CRABB_DEV__Skip__c = TRUE
                                                           AND Test_Case__c = :skipTrigger.testCase WITH SECURITY_ENFORCED ];
            System.debug('skipList --> '+skipList);
            if (skipList.size() > 0) {
                skip = true;
            }



        return skip;
    }

}