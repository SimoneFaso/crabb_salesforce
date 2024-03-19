/* ---------------------------------------------------------------------------------------------------------------------
Name:            CEBUtils.cls
Description:
Test class:      CEBUtils.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
08-Mar-2021  0.1      A. Smiriglia                    First Version
08-Oct-2021  0.2      C. Sanna                        Modified for adding check permission:
                                                      cebCheckFLSPermission (Security Review)
13-Sep-2022  0.3      R.Kurti & C.Sanna               Added WITH SECURITY ENFORCED and added cebCheckObjPermissions (security review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class CEBUtils {

    //check in custom setting if "new ork version" is enabled
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    public static Boolean newOrkVersionEnabled(){
        List<Ork_Logic_Version__c> OLV = Ork_Logic_Version__c.getall().values();
        if(OLV.size()==0) return false;
        return OLV[0].New_version_enabled__c;
    }

    //"add" operation for a given list of records
    public static void addCebEvents(Boolean isImmediate, List<CRABB_DEV__Pratica__c> praList, String type){
        List<CEB__c> evtList = new List<CEB__c>();
        CEB__c evt;
        for(CRABB_DEV__Pratica__c pra : praList){
            evt = new CEB__c();
            evt.CRABB_DEV__ActivityExtended__c=null;
            evt.CRABB_DEV__Immediate_Action__c=isImmediate;
            evt.CRABB_DEV__Pratica__c=pra.Id;
            evt.CRABB_DEV__Type__c=type;
            if(pra.CRABB_DEV__Stato__c == 'Bloccata' || pra.CRABB_DEV__Stato__c == 'Bloccata Manualmente' && type!='DSU' && type!='CEX' && type!='UEC'){
                evt.CRABB_DEV__Status__c='Blocked';
            } else {
                evt.CRABB_DEV__Status__c='New';
            }
            evtList.add(evt);
        }
//        insert evtList;
        if(Utils.cebCheckObjPermission('CEB__c',gd).get('INSERT')
                && Utils.cebCheckFLSPermission('CEB__c', 'ActivityExtended__c',gd).get('INSERT')
                && Utils.cebCheckFLSPermission('CEB__c', 'Immediate_Action__c',gd).get('INSERT')
                && Utils.cebCheckFLSPermission('CEB__c', 'Pratica__c',gd).get('INSERT')
                && Utils.cebCheckFLSPermission('CEB__c', 'Type__c',gd).get('INSERT')
                && Utils.cebCheckFLSPermission('CEB__c', 'Status__c',gd).get('INSERT')) {
            insert evtList;
        }
    }

    //"add" operation for a given list of strings
    public static void addCebEvents(Boolean isImmediate, List<String> praIdList, String type){
        //List<CRABB_DEV__Pratica__c> praList = new List<CRABB_DEV__Pratica__c>();
        List<CRABB_DEV__Pratica__c> praList = [SELECT Id,CRABB_DEV__Stato__c FROM CRABB_DEV__Pratica__c where Id IN :praIdList WITH SECURITY_ENFORCED ];
        //CRABB_DEV__Pratica__c pra; 
        addCebEvents(isImmediate,praList,type);
    }

    public static void updateCebEvents(List<String> cebIdList, String status) {
        List<CRABB_DEV__CEB__c> evtToUpdate = new List<CRABB_DEV__CEB__c>();
        List<CRABB_DEV__CEB__c> evtList = [SELECT id, CRABB_DEV__Status__c FROM CRABB_DEV__CEB__c where id IN :cebIdList WITH SECURITY_ENFORCED ];
        for(CRABB_DEV__CEB__c evt : evtList){
            evt.CRABB_DEV__Status__c=status;
            evtToUpdate.add(evt);
        }
        if(Utils.cebCheckObjPermission('CEB__c',gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('CEB__c', 'Status__c',gd).get('UPDATE')) {
            update evtToUpdate;
        }
    }

}