/* ---------------------------------------------------------------------------------------------------------------------
Name:            RuleOperationCTRL.cls
Description:     This class manages the configurations of Rules
Test class:      TestRuleOperationCTRL.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
16-Jun-2016  0.2      E. Sino                         Added with sharing (Security Review)
25-Aug-2021  0.3      C. Sanna                        Modified and added cebCheckObjPermission and cebCheckFLSPermission
                                                      (Security Review), getRecordTypeInfosByDeveloperName()
14-Sep-2022  0.4      C.Sanna & R.Kurti               Added cebCheckObjPermission and WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class RuleOperationCTRL {

    public Strategia__c mieTestate;
    public Strategia__c str;
    public list<Strategia__c> TestateVisualizate { get; set; }
    public Rule_control__c rcToEdit;
    public string operation { get; set; }
    public string idRc;
    public boolean isError { get; set; }
    public string history { get; set; }
    public String foundDuplicate { get; set; }
    public String ruleContainedByTestata { get; set; }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public RuleOperationCTRL() {
        this.isError = false;

        this.foundDuplicate = (ApexPages.currentPage().getParameters().get('foundDuplicate') == null) ? ApexPages.currentPage().getParameters().get('foundDuplicate') : ApexPages.currentPage().getParameters().get('foundDuplicate').escapeHtml4();

        this.ruleContainedByTestata = (ApexPages.currentPage().getParameters().get('ruleContainedByTestata') == null) ? ApexPages.currentPage().getParameters().get('ruleContainedByTestata') : ApexPages.currentPage().getParameters().get('ruleContainedByTestata').escapeHtml4();

        this.idRc = (ApexPages.currentPage().getParameters().get('idRc') == null) ? ApexPages.currentPage().getParameters().get('idRc') : ApexPages.currentPage().getParameters().get('idRc').escapeHtml4();

        //this.operation = String.isBlank(ApexPages.currentPage().getParameters().get('operation')) ? 'new' : ApexPages.currentPage().getParameters().get('operation');
        this.operation = String.isBlank(ApexPages.currentPage().getParameters().get('operation')) ? 'new' : ApexPages.currentPage().getParameters().get('operation').escapeHtml4();

        this.history = 'constructor ' + operation + ' ' + idRc;
        this.isError = setError();
    }

    public strategia__c getStr() {
        if (operation == 'new') {
            history = '\n ' + operation;
            if (this.str == null)
                str = new strategia__c();
        } else if (operation == 'edit' || operation == 'delete') {
            history = ' edit';
            if (idRc == null) {
                isError = true;
                str = new strategia__c();
                str.RC_Rule_Name__c = 'cavolo è un errore e non lo vedo';
            } else {
                String myRcId = this.IdRc;
                /*
                this.rcToEdit =[SELECT id, name, Api_field_name__c,Api_object_name__c,Condition__c,Strategia_api_field_name__c,Note__c,Rule_name__c From Rule_control__c where id=:myRcId];
                if(rcToEdit == null) isError=true;
                else
                    str = getStrFromRule(rcToEdit );
                */
                try {
                    this.rcToEdit = [
                            SELECT id, name, Api_field_name__c, Api_object_name__c, Condition__c, Strategia_api_field_name__c, Note__c, Rule_name__c
                            From Rule_control__c
                            where id = :myRcId
                            WITH SECURITY_ENFORCED
                    ];
                    str = getStrFromRule(rcToEdit);
                } catch (Exception e) {
                    isError = false;
                    operation = 'new';
                    history = '\n ' + operation;
                    if (this.str == null)
                        str = new strategia__c();

                }
            }
        }
        return str;
    }

    public static strategia__c getStrFromRule(Rule_control__c rc) {
        strategia__c temp = new Strategia__c();
        temp.RC_Api_Field_Name__c = rc.Api_field_name__c;
        temp.RC_Api_Object_Name__c = rc.Api_object_name__c;
        temp.RC_Condition__c = rc.Condition__c;
        temp.RC_Note__c = rc.Note__c;
        temp.RC_Rule_Name__c = rc.Rule_name__c;
        temp.RC_Strategia_Api_Field_Name__c = rc.Strategia_api_field_name__c;
        return temp;

    }

    public PageReference executeOperation() {
        if (operation == 'new') {
            Rule_control__c rc = new Rule_control__c();
            rc.Api_field_name__c = str.RC_Api_Field_Name__c;
            rc.Api_object_name__c = str.RC_Api_Object_Name__c;
            rc.Condition__c = str.RC_Condition__c;
            rc.Name = 'R' + system.now();
            rc.Note__c = str.RC_Note__c;
            rc.Rule_name__c = str.RC_Rule_Name__c;
            rc.Strategia_api_field_name__c = str.RC_Strategia_Api_Field_Name__c;

            // prima di inserimento controla per duplicati
            if (!isDuplicate(rc.Api_Field_Name__c,
                    rc.Api_Object_Name__c,
                    rc.Condition__c,
                    rc.Strategia_Api_Field_Name__c)) {
                foundDuplicate = 'false';
                if (Utils.cebCheckObjPermission('Rule_control__c', gd).get('CREATE')
                        && Utils.cebCheckFLSPermission('Rule_control__c', 'Strategia_api_field_name__c', gd).get('CREATE')
                        && Utils.cebCheckFLSPermission('Rule_control__c', 'Api_field_name__c', gd).get('CREATE')
                        && Utils.cebCheckFLSPermission('Rule_control__c', 'Api_object_name__c', gd).get('CREATE')
                        && Utils.cebCheckFLSPermission('Rule_control__c', 'Condition__c', gd).get('CREATE')
                        && Utils.cebCheckFLSPermission('Rule_control__c', 'Name', gd).get('CREATE')
                        && Utils.cebCheckFLSPermission('Rule_control__c', 'Note__c', gd).get('CREATE')
                        && Utils.cebCheckFLSPermission('Rule_control__c', 'Rule_name__c', gd).get('CREATE')) {
                    insert rc;
                }
                /*if (Utils.checkFLSPermission('Rule_control__c', 'Strategia_api_field_name__c').get('CREATE')
                    && Utils.checkFLSPermission('Rule_control__c', 'Api_field_name__c').get('CREATE')
                    && Utils.checkFLSPermission('Rule_control__c', 'Api_object_name__c').get('CREATE')
                    && Utils.checkFLSPermission('Rule_control__c', 'Condition__c').get('CREATE')
                    && Utils.checkFLSPermission('Rule_control__c', 'Name').get('CREATE')
                    && Utils.checkFLSPermission('Rule_control__c', 'Note__c').get('CREATE')
                    && Utils.checkFLSPermission('Rule_control__c', 'Rule_name__c').get('CREATE')
                    ) insert rc;*/
            } else
                    foundDuplicate = 'true';
        } else if (operation == 'edit') {
            //Prima di fare update controla se e in una testata attiva
            if (containsRuleTestata(this.idRc))
                ruleContainedByTestata = 'true';
            else {
                ruleContainedByTestata = 'false';
                rcToEdit.Api_field_name__c = str.RC_Api_Field_Name__c;
                rcToEdit.Api_object_name__c = str.RC_Api_object_name__c;
                rcToEdit.Condition__c = str.RC_Condition__c;
                rcToEdit.Note__c = str.RC_Note__c;
                rcToEdit.Rule_name__c = str.RC_Rule_Name__c;
                rcToEdit.Strategia_api_field_name__c = str.RC_Strategia_Api_Field_Name__c;

                // prima di inserimento controla per duplicati
                if (!isDuplicate(str.RC_Api_Field_Name__c,
                        str.RC_Api_Object_Name__c,
                        str.RC_Condition__c,
                        str.RC_Strategia_Api_Field_Name__c)) {
                    foundDuplicate = 'false';
                    if (Utils.cebCheckObjPermission('Rule_control__c', gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('Rule_control__c', 'Strategia_api_field_name__c', gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('Rule_control__c', 'Api_field_name__c', gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('Rule_control__c', 'Api_object_name__c', gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('Rule_control__c', 'Condition__c', gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('Rule_control__c', 'Name', gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('Rule_control__c', 'Note__c', gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('Rule_control__c', 'Rule_name__c', gd).get('UPDATE')) {
                        update rcToEdit;
                    }
                    /*if (Utils.checkFLSPermission('Rule_control__c', 'Strategia_api_field_name__c').get('UPDATE')
                        && Utils.checkFLSPermission('Rule_control__c', 'Api_field_name__c').get('UPDATE')
                        && Utils.checkFLSPermission('Rule_control__c', 'Api_object_name__c').get('UPDATE')
                        && Utils.checkFLSPermission('Rule_control__c', 'Condition__c').get('UPDATE')
                        && Utils.checkFLSPermission('Rule_control__c', 'Name').get('UPDATE')
                        && Utils.checkFLSPermission('Rule_control__c', 'Note__c').get('UPDATE')
                        && Utils.checkFLSPermission('Rule_control__c', 'Rule_name__c').get('UPDATE')
                        ) update rcToEdit;*/
                } else // c'é una duplicata, metti un errore
                        foundDuplicate = 'true';
            }
        } else if (operation == 'delete') {
            if (containsRuleTestata(this.idRc))
                ruleContainedByTestata = 'true';
            else {
                ruleContainedByTestata = 'false';
                //if (Utils.checkObjPermission('Rule_control__c').get('DELETE')) delete rcToEdit;
                if (Utils.cebCheckObjPermission('Rule_control__c', gd).get('DELETE')) {
                    delete rcToEdit;
                }
            }
        }
        // controla se c'é stata una duplicata e manda un errore al utente
        if (foundDuplicate == 'true')
            return new pagereference('/apex/ruleOperation?foundDuplicate=true');

        // controla se c'é stata una testata che contiene questa regola
        if (ruleContainedByTestata == 'true')
            return new pagereference('/apex/ruleOperation?ruleContainedByTestata=true');

        return new pagereference('/apex/GestioneRegole');
    }

    public boolean setError() {
        if (operation == 'delete' && idRc == null) {
            return true;
        } else if (operation == 'edit' && idRc == null) {
            return true;
        } else if (operation == null) {
            return true;
        } else if (operation == 'new' && idRC != null) {
            return true;
        } else if (operation != 'edit' && operation != 'delete' && operation != 'new') {
            return true;
        }
        return false;
    }

    //Metodo boolean per controlare se la regola essiste
    public Boolean isDuplicate(String f1, String f2, String f3, String f4) {


        List <Rule_control__c> RegoleDaControlare = new list<Rule_Control__c>();
        if (operation != 'edit')
            RegoleDaControlare = [
                    SELECT Api_field_name__c, Api_object_name__c, Condition__c, Strategia_api_field_name__c
                    FROM Rule_Control__c
                    WITH SECURITY_ENFORCED
                    LIMIT 50000
            ];
        else
                // se stiamo modificando una regola esistente, controlla solo i altri record                      
                RegoleDaControlare = [
                        SELECT Api_field_name__c, Api_object_name__c, Condition__c, Strategia_api_field_name__c
                        FROM Rule_Control__c
                        WHERE id <> :idRc
                        WITH SECURITY_ENFORCED
                ];

        for (Rule_Control__c a : RegoleDaControlare) {
            if ((a.Api_field_name__c == f1) && (a.Api_object_name__c == f2) && (a.Condition__c == f3) && (a.Strategia_api_field_name__c == f4)) {
                return true;
            }
        }

        return false;
    }

    //metodo per la modifica , non si puo modifichare una regola se e pressente in una testata attiva


    // metodo per controllare prima di cancella regola, se
    // questa regola esiste in alcuna Testata
    public Boolean containsRuleTestata(String myRuleId) {

        // la regola che analizziamo
        Rule_Control__c myrule = new Rule_Control__c();
        myRule = [SELECT Name, id FROM Rule_Control__c WHERE Id = :myRuleId WITH SECURITY_ENFORCED];

        // le potenziali strategie che possono contenere questa regola
        List <Strategia__c> mieTestate = new List<Strategia__c>();
        //Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Strategia__c.getRecordTypeInfosByName();
        Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName();
        /*if(Utils.checkFLSPermission('Strategia__c', 'Activation_roles__c').get('ACCESS')
            && Utils.checkFLSPermission('Strategia__c', 'Stato__c').get('ACCESS'))*/
        if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Activation_roles__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Stato__c', gd).get('ACCESS')) {
            mieTestate = [
                    SELECT Nome__c, Activation_roles__c, Stato__c
                    FROM Strategia__c
                    WHERE recordTypeId = :ctRecordTypes.get('Testata').getRecordTypeID()
                    WITH SECURITY_ENFORCED
            ];
        }

        TestateVisualizate = new list <Strategia__c>();
        // iteriamo e controliamo ogni testata
        for (Strategia__c strTemp : mieTestate) {
            if (operation == 'edit') {
                if (strTemp.Activation_roles__c <> NULL) {
                    if ((strTemp.Activation_roles__c.contains(myRule.Name)) && (strTemp.Stato__c == 'Attiva'))TestateVisualizate.add(strTemp);
                }
            }
            if (operation != 'edit') {
                if (strTemp.Activation_roles__c <> NULL) {
                    if (strTemp.Activation_roles__c.contains(myRule.Name))TestateVisualizate.add(strTemp);
                }
            }
        }

        if (TestateVisualizate.size() <> 0) return true;
        else return false;
    }
}