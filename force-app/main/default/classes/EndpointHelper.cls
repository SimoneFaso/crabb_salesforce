/* ---------------------------------------------------------------------------------------------------------------------
Name:            EndpointHelper.cls
Description:
Test class:      TestEndpointHelper.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
                                                      First Version
27-Sep-2021  0.2      Matteo Pizzichini               Modified EndpointHelper for adding check permission:
                                                      cebCheckFLSPermission (Security Review)
13-Sep-2022  0.3      C.Sanna & R.Kurti               Added cebCheckObjPermission ( security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class EndpointHelper {
    public class EndpointHelperException extends Exception {
    }
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    public static String endpoint(string name) {
        Endpoints__c e = Endpoints__c.getValues(name);
        if (e == null) {
            createRecord(name);
            e = Endpoints__c.getValues(name);
            return null;
        }
        return e.Endpoint__c;
    }

    public static void setToken(string name, string token) {

        Endpoints__c e = Endpoints__c.getValues(name);
        if (e == null) {
            createRecord(name);
            e = Endpoints__c.getValues(name);
        }
        e.token__c = token;
        e.Last_updated_token__c = system.now();
        /*if (Utils.checkFLSPermission('Endpoints__c', 'token__c').get('UPDATE')
                 && Utils.checkFLSPermission('Endpoints__c', 'Last_updated_token__c').get('UPDATE')
                 )  update e;*/
        if (Utils.cebCheckObjPermission('Endpoints__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Endpoints__c', 'token__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Endpoints__c', 'Last_updated_token__c', gd).get('UPDATE')) {
            update e;
        }

    }

    public static void setToken(string name, string token, integer sessionlength) {
        Endpoints__c e = Endpoints__c.getValues(name);
        if (e == null) {
            createRecord(name);
            e = Endpoints__c.getValues(name);
        }
        e.token__c = token;
        e.Last_updated_token__c = system.now();
        e.Refresh_every_x_minutes__c = sessionlength;
        /*if (Utils.checkFLSPermission('Endpoints__c', 'token__c').get('UPDATE')
                && Utils.checkFLSPermission('Endpoints__c', 'Last_updated_token__c').get('UPDATE')
                && Utils.checkFLSPermission('Endpoints__c', 'Refresh_every_x_minutes__c').get('UPDATE')
                ) update e;*/
        if (Utils.cebCheckObjPermission('Endpoints__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Endpoints__c', 'token__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Endpoints__c', 'Last_updated_token__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Endpoints__c', 'Refresh_every_x_minutes__c', gd).get('UPDATE')) {
            update e;
        }
    }

    public static String getToken(string name) {
        Endpoints__c e = Endpoints__c.getValues(name);
        if (e == null) {
            createRecord(name);
            e = Endpoints__c.getValues(name);
        }
        return e.token__c;
    }

    private static void createRecord(string name) {
        Endpoints__c e = new Endpoints__c();
        e.name = name;
//        if (Utils.checkFLSPermission('Endpoints__c', 'name').get('CREATE')) insert e;
        if (Utils.cebCheckObjPermission('Endpoints__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Endpoints__c', 'name', gd).get('CREATE')) {
            insert e;
        }
    }

    public static Boolean isTokenToRefresh(string name) {
        Endpoints__c e = Endpoints__c.getValues(name);
        if (e == null) {
            createRecord(name);
            e = Endpoints__c.getValues(name);
            return true;
        } else if (e.Last_updated_token__c == null || e.Refresh_every_x_minutes__c == null) {
            return true;
        }

        dateTime mdt = e.Last_updated_token__c.addMinutes(integer.valueof(e.Refresh_every_x_minutes__c));
        if (mdt < System.Now()) return true;
        else return false;
    }
}