/* ---------------------------------------------------------------------------------------------------------------------
Name:            GestioneRegolaCTRL.cls
Description:     Questa classe gestisce la configurazione di un record delle regole
Test class:      TestGestioneRegolaCTRL.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
5/2014       0.1      E.Sino               First Version
16-Jun-2016  0.2      E.Sino               Aggiunto il with sharing come richiesta da Salesforce.com per soddisfare le specifiche
                                           del Security Review.
16-Sep-2022  0.5      R.Kurti & C.Sanna    Replaced CheckObjPermission with cebCheckObjPermission and added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/
global with sharing class GestioneRegolaCTRL {
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public Boolean Error = false;//fleg per far vedere il block di errore
    public list<Rule_control__c> myRules;

    public List<SelectOption> afNameOptions { get; set; }
    public List<SelectOption> aoNameOptions { get; set; }
    public List<SelectOption> conditionOptions { get; set; }
    public List<SelectOption> safNameOptions { get; set; }

    public String selectedAFName { get; set; }
    public String selectedAOName { get; set; }
    public String selectedCondition { get; set; }
    public String selectedSAFName { get; set; }

    public Map<String, String> mapFieldHelp { get; set; }

    // costruttore carica le regole
    public GestioneRegolaCTRL() {
        this.Error = false;
        getmyRules();

        createOptions();
    }

    public list<Rule_control__c> getmyRules() {
        myRules = new list< Rule_control__c>();
        if(Utils.cebCheckObjPermission('Rule_control__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Rule_control__c','Name',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Rule_control__c','Api_field_name__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Rule_control__c','Api_object_name__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Rule_control__c','Condition__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Rule_control__c','Strategia_api_field_name__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Rule_control__c','Note__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Rule_control__c','Rule_name__c',gd).get('ACCESS')) {
            myRules = [
                    SELECT id, name, Api_field_name__c, Api_object_name__c, Condition__c, Strategia_api_field_name__c, Note__c, Rule_name__c
                    FROM Rule_control__c
                    //WITH SECURITY_ENFORCED
                    order by Api_field_name__c
                    LIMIT 50000
            ];
        }
        return myRules;
    }

    public void createOptions() {

        afNameOptions = new List<SelectOption>();
        aoNameOptions = new List<SelectOption>();
        conditionOptions = new List<SelectOption>();
        safNameOptions = new List<SelectOption>();
        mapFieldHelp = new Map<String, String>();

        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(Utils.NAMESPACE + 'Strategia__c').getDescribe().fields.getMap();
        mapFieldHelp.put('AFname', fieldMap.get('RC_Api_field_name__c').getDescribe().getInlineHelpText());
        List<Schema.PicklistEntry> values = fieldMap.get('RC_Api_field_name__c').getDescribe().getPickListValues();
        afNameOptions.add(new SelectOption('', '-- None --'));
        for (Schema.PicklistEntry a : values) {
            afNameOptions.add(new SelectOption(a.getValue(), a.getValue()));
        }

        values = new List<Schema.PicklistEntry>();
        mapFieldHelp.put('AOname', fieldMap.get('RC_Api_object_name__c').getDescribe().getInlineHelpText());
        values = fieldMap.get('RC_Api_object_name__c').getDescribe().getPickListValues();
        aoNameOptions.add(new SelectOption('', '-- None --'));
        for (Schema.PicklistEntry a : values) {
            aoNameOptions.add(new SelectOption(a.getValue(), a.getValue()));
        }

        values = new List<Schema.PicklistEntry>();
        mapFieldHelp.put('Cond', fieldMap.get('RC_Condition__c').getDescribe().getInlineHelpText());
        values = fieldMap.get('RC_Condition__c').getDescribe().getPickListValues();
        conditionOptions.add(new SelectOption('', '-- None --'));
        for (Schema.PicklistEntry a : values) {
            conditionOptions.add(new SelectOption(a.getValue(), a.getValue()));
        }

        values = new List<Schema.PicklistEntry>();
        mapFieldHelp.put('SAFname', fieldMap.get('RC_Strategia_api_field_name__c').getDescribe().getInlineHelpText());
        values = fieldMap.get('RC_Strategia_api_field_name__c').getDescribe().getPickListValues();
        safNameOptions.add(new SelectOption('', '-- None --'));
        for (Schema.PicklistEntry a : values) {
            safNameOptions.add(new SelectOption(a.getValue(), a.getValue()));
        }

        mapFieldHelp.put('Note', fieldMap.get('RC_Note__c').getDescribe().getInlineHelpText());
        mapFieldHelp.put('Rname', fieldMap.get('RC_Rule_Name__c').getDescribe().getInlineHelpText());

    }

    @RemoteAction
    global static String removeRecords(String param) {

        //if(Utils.checkObjPermission('Rule_control__c').get('DELETE')){
        if (Utils.cebCheckObjPermission('Rule_control__c', gd).get('DELETE')) {
            Rule_control__c toRemove = new Rule_control__c(Id = param);
            delete toRemove;
        }

        String result = '/apex/GestioneRegole';
        return result;
    }

    @RemoteAction
    global static String editRecord(String idrecord, String rname, String raoname, String rafname, String rcond, String rsafname, String rnote) {

        Rule_control__c rc = new Rule_control__c(Id = idRecord);

        if (rname != null && String.isNotBlank(rname)) rc.Rule_Name__c = rname;
        if (rafname != null && String.isNotBlank(rafname)) rc.Api_field_name__c = rafname;
        if (raoname != null && String.isNotBlank(raoname)) rc.Api_object_name__c = raoname;
        if (rcond != null && String.isNotBlank(rcond)) rc.Condition__c = rcond;
        if (rsafname != null && String.isNotBlank(rsafname)) rc.Strategia_api_field_name__c = rsafname;
        if (rnote != null && String.isNotBlank(rnote)) rc.Note__c = rnote;

        //if(Utils.checkObjPermission('Rule_control__c').get('UPDATE')){
        if (Utils.cebCheckObjPermission('Rule_control__c', gd).get('UPDATE')) {
            update rc;
        }

        return '/apex/GestioneRegole';
    }

    @RemoteAction
    global static String newRecord(String rname, String raoname, String rafname, String rcond, String rsafname, String rnote) {

        if (rname != null && rafname != null && raoname != null && rcond != null && rsafname != null &&
                String.isNotBlank(rname) && String.isNotBlank(rafname) && String.isNotBlank(raoname) && String.isNotBlank(rcond) && String.isNotBlank(rsafname)) {

            try {
                Rule_control__c rc = new Rule_control__c();

                rc.Name = 'R' + String.valueOf(Datetime.now());
                rc.Rule_Name__c = rname;
                rc.Api_field_name__c = rafname;
                rc.Api_object_name__c = raoname;
                rc.Condition__c = rcond;
                rc.Strategia_api_field_name__c = rsafname;
                rc.Note__c = (rnote != null && String.isNotBlank(rnote)) ? rnote : '';

                //if(Utils.checkObjPermission('Rule_control__c').get('INSERT') && Utils.checkObjPermission('Rule_control__c').get('CREATE')){
                if (Utils.cebCheckObjPermission('Rule_control__c', gd).get('INSERT')
                        && Utils.cebCheckObjPermission('Rule_control__c', gd).get('CREATE')) {
                    insert rc;
                }
            } catch (Exception ex) {
                System.debug('@@@ exception in GestioneRegolaCTRL::newRecord --> ' + ex.getStackTraceString());
            }

        }

        return '/apex/GestioneRegole';
    }

}