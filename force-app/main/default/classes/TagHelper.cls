/*
*   Created by: Klodjan Meta, 10/10/2014
*
*   Desc: Helper class for the Tag Custom setting to retrieve the values
*   configured there
*   
*   V 1
*/
public with sharing class TagHelper {

    public static String getValue(String s, String o) {
        if (Tag__c.getValues(s) == null) return '';
        return Tag__c.getValues(s).ValueText__c;
    }

    public static String getValueText(String s) {
        if (Tag__c.getValues(s) == null) return '';
        return Tag__c.getValues(s).ValueText__c;
    }

    public static String getValueTextOrNull(String s) {
        if (Tag__c.getValues(s) == null) {
            return null;
        }
        return Tag__c.getValues(s).ValueText__c;
    }

    public static Integer getValueInteger(String s) {
        if (Tag__c.getValues(s) == null) {
            return 10;
            /*try{
                Tag__c tag = new Tag__c();
                tag.name=s;
                tag.ValueInteger__c=10;
                if (Utils.checkFLSPermission('Tag__c', 'Name').get('CREATE')
                    && Utils.checkFLSPermission('Tag__c', 'ValueInteger__c').get('CREATE')
                    )
                    insert tag;
            }
            catch(Exception e){
                return null;
            }*/
        }
        return Integer.valueOf(Tag__c.getValues(s).ValueInteger__c);
    }

    public static Boolean getValueBoolean(String s) {
        if (Tag__c.getValues(s) == null) {
            return false;
        }
        return Tag__c.getValues(s).ValueBoolean__c;
    }
}