/* ---------------------------------------------------------------------------------------------------------------------
Name:            SALDIHelpers.cls
Description:
Test class:      TestSaldiHelper.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class SALDIHelper{

    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    // se il record non esiste, crealo 
    public static string getValueMese(string s){
        
        if(SALDI__c.getValues(s)==null && Utils.cebCheckObjPermission('SALDI__c',gd).get('INSERT')
        && Utils.cebCheckFLSPermission('SALDI__c','Mese__c',gd).get('INSERT')){
            SALDI__c saldi=new SALDI__c ();
            saldi.name=s;
            saldi.mese__c='AGOSTO';
            insert saldi;
            return saldi.mese__c;
        }
        return SALDI__c.getValues(s).mese__c;
    }
    
    public static string getValue(String s, String o){
        if(SALDI__c.getValues(s)==null && Utils.cebCheckObjPermission('SALDI__c',gd).get('INSERT')
                && Utils.cebCheckFLSPermission('SALDI__c','Mese__c',gd).get('INSERT')){
            SALDI__c saldi=new SALDI__c ();
            saldi.name=s;
            saldi.mese__c='AGOSTO';
            insert saldi;
            return saldi.mese__c;
        }
        return SALDI__c.getValues(s).mese__c;

    }
}