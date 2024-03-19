/**
 * Created by MatteoSala on 10/07/2020.
 */

@isTest
public with sharing class CRABB_FlussiCollectorMapNewCTRL_Test
{
    @isTest
    static void testGetListObjects()
    {
        Test.startTest();
        String result = CRABB_FlussiCollectorMapNewCTRL.getListObjectStatic('CSVNEW');
        System.assertNotEquals(null, result);
        Map<String, String> objectMap = (Map<String, String>) JSON.deserialize(result, Map<String, String>.class);
        System.assert(objectMap.size()>0);
        Test.stopTest();
    }

    @isTest
    static void testGetListFields()
    {
        Test.startTest();
        String result = CRABB_FlussiCollectorMapNewCTRL.retrieveListFieldsStatic('');
        System.assert(result == NULL);
        result = CRABB_FlussiCollectorMapNewCTRL.retrieveListFieldsStatic('CRABB_DEV__Movimento__c');
        System.assertNotEquals(null, result);
        Map<String, String> objectMap = (Map<String, String>) JSON.deserialize(result, Map<String, String>.class);
        System.assert(objectMap.size()>0);
        Test.stopTest();
    }

    @isTest
    static void testGetListFieldsRecordsAddNewRecordAndDelete()
    {
        Test.startTest();
        String result = CRABB_FlussiCollectorMapNewCTRL.retrieveListOfFieldsRecords('CSVNEW');
        System.assertNotEquals(null, result);
        List<ListOfFields__c> listLOF = (List<ListOfFields__c>) JSON.deserialize(result, List<ListOfFields__c>.class);
        System.assert(listLOF.size()==0);
        CRABB_FlussiCollectorMapNewCTRL.addCSVNEWRecord('Account', 'Description', true);
        result = CRABB_FlussiCollectorMapNewCTRL.retrieveListOfFieldsRecords('CSVNEW');
        listLOF = (List<ListOfFields__c>) JSON.deserialize(result, List<ListOfFields__c>.class);
        System.assert(listLOF.size()>0);
        CRABB_FlussiCollectorMapNewCTRL.removeRecordsLightning(listLOF[0].Id);
        result = CRABB_FlussiCollectorMapNewCTRL.retrieveListOfFieldsRecords('CSVNEW');
        listLOF = (List<ListOfFields__c>) JSON.deserialize(result, List<ListOfFields__c>.class);
        System.assert(listLOF.size()==0);
        Test.stopTest();
    }

    @isTest
    static void addCSVNEWRecordsWithBadParams()
    {
        Test.startTest();
        Boolean result = CRABB_FlussiCollectorMapNewCTRL.addCSVNEWRecord('', 'Description', true);
        System.assert(result == false);
        Test.stopTest();
    }

    @isTest
    static void getListStrReversed()
    {
        Test.startTest();
        CRABB_FlussiCollectorMapNewCTRL.addCSVNEWRecord('Account', 'Description', true);
        String description = CRABB_FlussiCollectorMapNewCTRL.getListStrFieldsReversed('Account');
        System.assertNotEquals(null, description);
        Map<String,String> listStrFields = (Map<String, String>) JSON.deserialize(description, Map<String, String>.class);
        System.assert(listStrFields.size()>0);
        Test.stopTest();
    }

    @isTest
    static void testRearrangeRecords()
    {
        Test.startTest();
        ListOfFields__c testLof = new ListOfFields__c(Name='testNameOne',Field__c='Id',Field_Label__c='TestLabel',Show__c=false,Object__c='CSV||Pratica__c');
        insert testLof;
        ListOfFields__c testLof2 = new ListOfFields__c(Name='testNameTwo',Field__c='Id',Field_Label__c='TestLabel2',Show__c=false,Object__c='CSV||Pratica__c');
        insert testLof2;
        List<ListOfFields__c> initialFields = [select Id, Name from ListOfFields__c where Name='testNameOne' or Name='testNameTwo'];
        Map<String, ListOfFields__c> lofMap = new Map<String, ListOfFields__c>();
        for (ListOfFields__c lof : initialFields)
        {
            lofMap.put(lof.Name, lof);
        }
        String param = '{"'+initialFields[0].Id+'":"'+initialFields[1].Name+'","'+initialFields[1].Id+'":"'+initialFields[0].Name+'"}';
        Boolean result = CRABB_FlussiCollectorMapNewCTRL.rearrangeRecordsLightning(param);
        List<ListOfFields__c> resultFields = [select Id, Name from ListOfFields__c where Name='testNameOne' or Name='testNameTwo'];
        for (ListOfFields__c lof:resultFields)
        {
            if(lof.Name == 'testNameOne')
            {
                System.assertEquals(lof.Id, lofMap.get('testNameTwo').Id);
            }
            if(lof.Name == 'testNameTwo')
            {
                System.assertEquals(lof.Id, lofMap.get('testNameOne').Id);
            }
        }
        System.assertEquals(true, result);
        Test.stopTest();
    }

    @isTest
    static void testUpdateRecords()
    {
        Test.startTest();
        ListOfFields__c testLof = new ListOfFields__c(Name='testNameOne',Field__c='Id',Field_Label__c='TestLabel',Show__c=false,Object__c='CSV||Pratica__c');
        insert testLof;
        List<ListOfFields__c> initialFields = [select Id, Name from ListOfFields__c where Name='testNameOne' or Name='testNameTwo'];
        List<ListOfFields__c> initialFieldsClone = (List<ListOfFields__c>)initialFields.deepClone(true, true, true);
        initialFieldsClone[0].Name ='asdf';
        String result = CRABB_FlussiCollectorMapNewCTRL.updateRecordsLightning(JSON.serialize(initialFieldsClone));
        List<ListOfFields__c> resultFields = [select Id, Name FROM ListOfFields__c];
        System.assertEquals(resultFields[0].Name, 'asdf');
        Test.stopTest();
    }
}