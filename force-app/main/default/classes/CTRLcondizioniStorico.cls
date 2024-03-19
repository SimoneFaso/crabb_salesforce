/* ---------------------------------------------------------------------------------------------------------------------
Name:            CTRLcondizioniStorico.cls
Description:
Test class:

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
12-Sep-2022  0.2      C.Sanna & R.Kurti    Added WITH SECURITY_ENFORCED (Security Review)
10-Oct-2022  0.3      C.Sanna & R.Kurti    Added cebChecks and removed WITH SECURITY ENFORCED
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class CTRLcondizioniStorico  {
    public Strategia__c condStrat{get;set;}
    public boolean cDI{get;set;}
    public boolean cDU{get;set;}
    public boolean msg{get;set;}

    public ApexPages.StandardController ctrl {get;set;}
    public string jsonString{get; set;}   
    public List<Map<string,object>> lMap{get;set;}
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    public List<Map<string,object>> lMapFromJson{get;set;} 
    public Strategia__C strat{get; set;} 
    public CTRLcondizioniStorico(ApexPages.StandardController controller) {
        this.ctrl= controller;
        msg = true;
        condStrat = (strategia__c) ctrl.getRecord();
        if(condStrat.id==null) return;
        lMap=new List<Map<string,object>>();
        lMapFromJson=new List<Map<string,object>>();
        if(Utils.cebCheckObjPermission('Strategia__c',gd).get('ACCESS')
        && Utils.cebCheckFLSPermission('Strategia__c','CDI_Json__c',gd).get('ACCESS')
        && Utils.cebCheckFLSPermission('Strategia__c','CDU_Json__c',gd).get('ACCESS')) {
            strat = [Select id, CDI_Json__c, CDU_Json__c From strategia__c where id = :condStrat.id];
            //strat=[Select id, CDI_Json__c,CDU_Json__c  From strategia__c  where id=:condStrat.id WITH SECURITY_ENFORCED];
            if (strat == null) {
                strat = new strategia__c();
            }
            if (strat.CDI_Json__c != null) {
                cDI = true;
                lMapFromJson = (List<Map<string, string>>) JSON.deserialize(strat.CDI_Json__c, List<Map<string, string>>.Class);
            } else cDI = false;
            if (strat.CDU_Json__c != null) {
                cDU = true;
                try {
                    lMap = (List<Map<string, string>>) JSON.deserialize(strat.CDU_Json__c, List<Map<string, string>>.Class);
                } catch (Exception e) {
                }
            } else cDU = false;
            msg = !(cDU || cDI);
        }
    }
}