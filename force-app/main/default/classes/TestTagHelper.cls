/*
* CreatedBy: KMeta
* CreatedDate: 04/August/2014
* Description: Contine la classe di test per la classe TagHelper
*/

@isTest (SeeAllData = false)
public class TestTagHelper{

    static testMethod void tagHelper_getValue_null(){
        string stringValue;
        integer intvalue;
        test.startTest();
            stringValue = TagHelper.getValue('xx',stringValue);
            intvalue = taghelper.getValueInteger('xxx');
        test.stopTest();
        System.assertEquals('',stringValue);
    }

    static testMethod void tagHelper_getValue_notNull(){
        string stringValue;
        integer intvalue;
        Tag__c tag = new Tag__c();
        tag.name='xx';
        tag.ValueText__c='xyz';
        tag.ValueInteger__c = 1.2;
        insert tag;     
        test.startTest();
            stringValue = TagHelper.getValue('xx',stringValue);
            intvalue = taghelper.getValueInteger('xx');
        
        test.stopTest();
        System.assertEquals('xyz',stringValue);
    }   

    static testMethod void tagHelper_getValueString_null(){
        string stringValue;
        test.startTest();
            stringValue = TagHelper.getValueTextOrNull('xx');
        test.stopTest();
        System.assertEquals(null,stringValue);
    }

    static testMethod void tagHelper_getValueString_notNull(){
        string stringValue;
        Tag__c tag = new Tag__c();
        tag.name='xx';
        tag.ValueText__c='xyz';
        insert tag;
        
        test.startTest();
            stringValue = TagHelper.getValueText('xx');
        test.stopTest();
        System.assertEquals('xyz',stringValue);
    }
    static testMethod void tagHelper_getValueBoolean_false(){
        boolean bool;
        test.startTest();
            bool = TagHelper.getValueBoolean('xx');
        test.stopTest();
        System.assertEquals(false,bool);
    }
    static testMethod void tagHelper_getValueBoolean_true(){
        boolean bool;
        Tag__c tag = new Tag__c();
        tag.name='xx';
        tag.ValueBoolean__c=true;
        insert tag;
        test.startTest();
            bool = TagHelper.getValueBoolean('xx');
        test.stopTest();
        System.assertEquals(true,bool );
    }           
    
}