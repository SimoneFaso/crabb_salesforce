/* ---------------------------------------------------------------------------------------------------------------------
Name:            ConfigurationStrategiaCTRL.cls
Description:     Controller for ConfigurationStrategia page
Test class:      TestConfigurationStrategiaCTRL.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                          First Version
15-Jun-2022  0.2      C. Sanna & V.Doda   Modified for adding check permission: cebCheckObjPermission and
                                          cebCheckFLSPermission (Security Review)
13-Sep-2022  0.3     C. Sanna & R. Kurti  Modified for adding WITH SECURITY_ENFORCED (Security Review)
10-Oct-2022  0.4     R.Kurti & C.Sanna    Added cebChecks and removed WITH SECURITY ENFORCED 
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class ConfigurationStrategiaCTRL {
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    public List<SelectOption> tipoStratTestataOptions { get; set; }
    public String selectedTipoStratTestata { get; set; }
    public Id idTestata { get; set; }

    //new testata variables
    public String newTestataName { get; set; }
    public String newTestataDescr { get; set; }
    public Decimal newTestataVers { get; set; }
    public Integer newTestataPrior { get; set; }

    // new cdi variables
    public String newCDIName { get; set; }
    public String newCDIRules { get; set; }
    public Decimal newCDIVers { get; set; }
    public Integer newCDIPrior { get; set; }

    //new cdu variables
    public String newCDUName { get; set; }
    public String newCDUDescr { get; set; }
    public Integer newCDUPrior { get; set; }
    public String newCDUEsito { get; set; }
    public Boolean newCDUeec { get; set; }
    public String newCDURules { get; set; }

    public Strategia__c testata { get; set; }
    public List<Strategia__c> stepsList { get; set; }
    public List<Strategia__c> cdiList { get; set; }
    public List<Strategia__c> cduList { get; set; }
    public List<Strategia__c> jumpList { get; set; }

    public List<SelectOption> ruleCDIOptions { get; set; }
    public List<SelectOption> ruleCDUOptions { get; set; }

    public String selectedRuleCDI { get; set; }
    public String selectedRuleCDU { get; set; }
    public List<Strategia__c> stratList { get; set; }

    //new step variables
    public List<SelectOption> attivitaPadreList { get; set; }
    public String selectedAttivitaPadre { get; set; }
    public List<SelectOption> faseList { get; set; }
    public String selectedFase { get; set; }
    public List<SelectOption> tipologiaList { get; set; }
    public String selectedTipologia { get; set; }
    public List<SelectOption> tipoAttList { get; set; }
    public String selectedTipoAtt { get; set; }
    public List<SelectOption> sottotipoList { get; set; }
    public String selectedSottotipo { get; set; }
    public String newSname { get; set; }
    public String newSdescr { get; set; }
    public Integer newSprior { get; set; }
    public String newSsla { get; set; }
    public Boolean newSslapresent { get; set; }
    public Boolean newSfinal { get; set; }
    public List<SelectOption> ruleStepOptions { get; set; }
    public String selectedRuleStep { get; set; }

    // new jump variables
    public String newJname { get; set; }
    public String newJdescr { get; set; }
    public List<SelectOption> jumpFromOptions { get; set; }
    public String selectedJumpFrom { get; set; }
    public List<SelectOption> jumpToOptions { get; set; }
    public String selectedJumpTo { get; set; }
    public List<SelectOption> esitoOptions { get; set; }
    public String selectedEsito { get; set; }
    public Boolean isAutomaticJump { get; set; }
    public Integer newJprior { get; set; }
    public List<SelectOption> ruleJumpOptions { get; set; }
    public String selectedRuleJump { get; set; }

    public ConfigurationStrategiaCTRL() {

        idTestata = (ApexPages.currentPage().getParameters().get('testid') != null && String.isNotBlank(ApexPages.currentPage().getParameters().get('testid'))) ? ApexPages.currentPage().getParameters().get('testid') : null;

        tipoStratTestataOptions = new List<SelectOption>();
        tipoStratTestataOptions = getPicklistValues(new Strategia__c(), Utils.NAMESPACE + 'Tipo_Strategia__c');
        system.debug('Type ' + tipoStratTestataOptions);
        attivitaPadreList = new List<SelectOption>();
        attivitaPadreList.add(new SelectOption('', '-- None --'));

        jumpFromOptions = new List<SelectOption>();
        jumpFromOptions.add(new SelectOption('', '-- None --'));
        jumpToOptions = new List<SelectOption>();
        jumpToOptions.add(new SelectOption('', '-- None --'));

        faseList = getPicklistValues(new Strategia__c(), Utils.NAMESPACE + 'Fase__c');
        tipologiaList = getPicklistValues(new Strategia__c(), Utils.NAMESPACE + 'Tipologia__c');
        tipoAttList = getPicklistValues(new Strategia__c(), Utils.NAMESPACE + 'Tipo_attivita__c');
        system.debug('tipoAttList ' + tipoAttList);
        sottotipoList = getPicklistValues(new Strategia__c(), Utils.NAMESPACE + 'Sotto_tipo_attivita__c');
        system.debug('Sotto_tipo_attivita__c ' + tipoAttList);
        esitoOptions = getPicklistValues(new Strategia__c(), Utils.NAMESPACE + 'Esito__c');

        createStrategiaObjects();

        List<Rule_control__c> rcList = Rule_control__c.getAll().values();

        ruleCDIOptions = new List<SelectOption>();
        ruleCDUOptions = new List<SelectOption>();
        ruleStepOptions = new List<SelectOption>();
        ruleJumpOptions = new List<SelectOption>();

        if (rcList != null && !rcList.isEmpty()) {

            for (Rule_control__c rc : rcList) {

                ruleCDIOptions.add(new SelectOption(rc.Name, rc.Api_object_name__c + '.' + rc.Api_field_name__c + ' ' + rc.Condition__c + ' ' + rc.Api_object_name__c + '.' + rc.Strategia_api_field_name__c));
                ruleCDUOptions.add(new SelectOption(rc.Name, rc.Api_object_name__c + '.' + rc.Api_field_name__c + ' ' + rc.Condition__c + ' ' + rc.Api_object_name__c + '.' + rc.Strategia_api_field_name__c));
                ruleStepOptions.add(new SelectOption(rc.Name, rc.Api_object_name__c + '.' + rc.Api_field_name__c + ' ' + rc.Condition__c + ' ' + rc.Api_object_name__c + '.' + rc.Strategia_api_field_name__c));
                ruleJumpOptions.add(new SelectOption(rc.Name, rc.Api_object_name__c + '.' + rc.Api_field_name__c + ' ' + rc.Condition__c + ' ' + rc.Api_object_name__c + '.' + rc.Strategia_api_field_name__c));
            }

        } else {
            ruleCDIOptions.add(new SelectOption('', '-- No Rules Available --'));
            ruleCDUOptions.add(new SelectOption('', '-- No Rules Available --'));
            ruleStepOptions.add(new SelectOption('', '-- No Rules Available --'));
            ruleJumpOptions.add(new SelectOption('', '-- No Rules Available --'));
        }
    }

    public void createStrategiaObjects() {
        testata = null;
        stepsList = new List<Strategia__c>();
        cdiList = new List<Strategia__c>();
        cduList = new List<Strategia__c>();
        jumpList = new List<Strategia__c>();


        //if(idTestata != null){
        if (idTestata != null && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Strategia__c', 'Attivit_Padre__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Strategia__c', 'SLA__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Strategia__c', 'Tipo_attivita__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Strategia__c', 'Sotto_tipo_attivita__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Strategia__c', 'Tipo_Attivit__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Strategia__c', 'Sotto_Tipo_Attivit__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Strategia__c', 'RecordTypeId', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Strategia__c', 'Testata__c', gd).get('ACCESS') &&
                Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')) {
            testata = Database.query('SELECT ' + Utils.getSOBJECTFieldsForQuery('Strategia__c') + ' FROM Strategia__c WHERE Id = \'' + String.escapeSingleQuotes(idTestata) + '\' LIMIT 1');

            attivitaPadreList.add(new SelectOption(testata.Id, testata.Nome__c));

            List<Strategia__c> stratList = Database.query('SELECT ' + Utils.getSOBJECTFieldsForQuery('Strategia__c') + ',RecordType.Name FROM Strategia__c WHERE Testata__c = \'' + String.escapeSingleQuotes(idTestata) + '\'');
            if (stratList != null && !stratList.isEmpty()) {
                for (Strategia__c str : stratList) {
                    if (str.RecordType.Name.equalsIgnoreCase('Condizioni di Ingresso')) {
                        cdiList.add(str);
                    } else if (str.RecordType.Name.equalsIgnoreCase('Condizioni di Uscita')) {
                        cduList.add(str);
                    } else if (str.RecordType.Name.equalsIgnoreCase('Salto')) {
                        jumpList.add(str);
                    } else if (str.RecordType.Name.equalsIgnoreCase('Step')) {
                        attivitaPadreList.add(new SelectOption(str.Id, str.Nome__c));
                        jumpFromOptions.add(new SelectOption(str.Id, str.Nome__c));
                        jumpToOptions.add(new SelectOption(str.Id, str.Nome__c));
                        stepsList.add(str);
                    }
                }
            }
        }
    }

    public String getChartString() {
        String sJSon;
        String nomePratica = 'Strategia di riferimento';

        //if (idTestata != null) {
        if (idTestata != null && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Strategia__c', 'Attivit_Padre__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Strategia__c', 'SLA__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Strategia__c', 'Tipo_attivita__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Strategia__c', 'Sotto_tipo_attivita__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Strategia__c', 'Tipo_Attivit__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Strategia__c', 'Sotto_Tipo_Attivit__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Strategia__c', 'RecordTypeId', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Strategia__c', 'Testata__c', gd).get('ACCESS') &&
                Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')) {
            // Aggiungo la parte per gestire il chart sulla strategia
            nomePratica = testata.Nome__c;

            List<Strategia__c> lStr = [
                    SELECT Attivit_Padre__c, Nome__c, SLA__c, Tipo_attivita__c, Sotto_tipo_attivita__c, Tipo_Attivit__c, Sotto_Tipo_Attivit__c
                    //FROM Strategia__c where RecordType.Name = 'Step' AND Testata__c = :idTestata];
                    FROM Strategia__c
                    where RecordType.Name = 'Step' AND Testata__c = :idTestata
                    //WITH SECURITY_ENFORCED
            ];

            String s = '[';
            Integer i = 0;

            if (lStr != null && lStr.size() > 0) {
                for (Strategia__c str : lStr) {
                    String parent = '';
                    String sottoTipo = '';
                    String sla = 'NA';
                    if (str.SLA__c != null) sla = String.ValueOf(str.SLA__c);

                    if (str.Attivit_Padre__c == null || String.ValueOf(str.Attivit_Padre__c) == '' || String.ValueOf(str.Attivit_Padre__c) == idTestata) {
                        parent = nomePratica; //idTestata; //'***';
                    } else {
                        parent = str.Attivit_Padre__c;
                    }

                    if (str.Sotto_tipo_attivita__c != null) sottoTipo = str.Sotto_tipo_attivita__c;

                    s = s + '[{v:\'' + str.Id + '\', f:\'' + str.Nome__c + ' <BR/> ' + str.Tipo_attivita__c + ' ' + sottoTipo + '<div> ' + 'SLA: ' + SLA + '</div>' + '\'},' + '\'' + parent + '\',\'' + '\']';

                    if (i < lStr.size() - 1) s = s + ',';

                    System.debug('La stringa parent è ' + parent);
                    i++;
                }
            } else {

                s = s + '[{v:\'' + testata.Id + '\',f:\'' + testata.Nome__c + '\'},\'\',\'\']';
            }

            s = s + ']';
            sJSon = s;
            System.debug('La stringa DROWs è ' + sJSon);
        }

        return sJSon;
    }

    public List<SelectOption> getPicklistValues(sObject obj, String field) {

        List<SelectOption> options = new List<SelectOption>();

        Map<String, Schema.SObjectField> fieldMap = obj.getSObjectType().getDescribe().fields.getMap();

        // Get the list of picklist values for this field.
        List<Schema.PicklistEntry> values = fieldMap.get(field).getDescribe().getPickListValues();

        options.add(new SelectOption('', '-- None --'));

        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values) {
            //options.add(new SelectOption(a.getLabel(), a.getValue()));
            options.add(new SelectOption(a.getValue(), a.getLabel()));
        }

        options.sort();

        return options;

    }

    public PageReference createTestata() {

        if (testata != null && idTestata != null) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Testata già presente, non è possibile inserirne altre.'));
            return null;
        }

        if (newTestataName != null && newTestataVers != null && newTestataPrior != null && selectedTipoStratTestata != null && String.isNotBlank(newTestataName) && String.isNotBlank(selectedTipoStratTestata)) {

            if (Utils.cebCheckObjPermission('Strategia__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Versione__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Priority__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Descrizione__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Tipo_Strategia__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'RecordTypeId', gd).get('CREATE') &&
                    Utils.cebCheckObjPermission('Strategia__c', gd).get('INSERT')) {

                Strategia__c newT = new Strategia__c();
                newT.Nome__c = newTestataName;
                newT.Descrizione__c = newTestataDescr;
                newT.Versione__c = newTestataVers;
                newT.Priority__c = (newTestataPrior != null) ? newTestataPrior : 0;
                newT.Tipo_Strategia__c = selectedTipoStratTestata;

                String sobj = Utils.NAMESPACE + 'Strategia__c';
                if (Utils.cebCheckObjPermission('RecordType', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('RecordType', 'Name', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('RecordType', 'SobjectType', gd).get('ACCESS')) {
                    RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Testata' AND SobjectType = :sobj LIMIT 1];
                    //RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Testata' AND SobjectType = :sobj WITH SECURITY_ENFORCED LIMIT 1];

                    newT.RecordTypeId = rt.Id;

                    insert newT;

                    idTestata = newT.Id;
                }
                PageReference page = new PageReference('/apex/ConfigurationStrategia?testid=' + idTestata);
                page.setRedirect(true);
                return page;

            }
        } else {

            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Nuova Testata : Inserire tutti i dati.'));
            return null;

        }

        return null;
    }

    public PageReference createCDI() {

        if (testata == null || idTestata == null) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'E\' necessario inserire prima la testata.'));
            return null;
        }

        if (idTestata != null && newCDIName != null && newCDIPrior != null && newCDIVers != null && String.isNotBlank(newCDIName) && String.isNotBlank(idTestata)) {

            if (Utils.cebCheckObjPermission('Strategia__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Versione__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Priority__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Activation_roles__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Testata__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'RecordTypeId', gd).get('CREATE') &&
                    Utils.cebCheckObjPermission('Strategia__c', gd).get('INSERT')) {

                Strategia__c newCDI = new Strategia__c();
                newCDI.Nome__c = newCDIName;
                newCDI.Versione__c = newCDIVers;
                newCDI.Priority__c = (newCDIPrior != null) ? newCDIPrior : 0;
                newCDI.Activation_roles__c = newCDIRules;
                newCDI.Testata__c = idTestata;

                String sobj = Utils.NAMESPACE + 'Strategia__c';
                if (Utils.cebCheckObjPermission('RecordType', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('RecordType', 'Name', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('RecordType', 'SobjectType', gd).get('ACCESS')) {
                    RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Condizioni di Ingresso' AND SobjectType = :sobj LIMIT 1];
                    //RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Condizioni di Ingresso' AND SobjectType = :sobj WITH SECURITY_ENFORCED LIMIT 1];
                    newCDI.RecordTypeId = rt.Id;

                    insert newCDI;
                }
                /*PageReference page = new PageReference('/apex/ConfigurationStrategia?testid='+idTestata);
            page.setRedirect(true);
            return page;*/
                createStrategiaObjects();

            }
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Nuova CDI : Inserire tutti i dati.'));
        }
        return null;

    }

    public PageReference createCDU() {

        if (testata == null || idTestata == null) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'E\' necessario inserire prima la testata.'));
            return null;
        }
        System.debug('idTestata -->' + idTestata);
        System.debug('newCDUName -->' + newCDUName);
        System.debug('newCDUPrior -->' + newCDUPrior);
        System.debug('newCDUEsito -->' + newCDUEsito);


        if (idTestata != null && newCDUName != null && newCDUPrior != null && newCDUEsito != null && String.isNotBlank(newCDUName) && String.isNotBlank(idTestata) && String.isNotBlank(newCDUEsito)) {

            if (Utils.cebCheckObjPermission('Strategia__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Versione__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Priority__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Activation_roles__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Testata__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'RecordTypeId', gd).get('CREATE') &&
                    Utils.cebCheckObjPermission('Strategia__c', gd).get('INSERT')) {

                Strategia__c newCDU = new Strategia__c();
                newCDU.Nome__c = newCDUName;
                newCDU.Priority__c = (newCDUPrior != null) ? newCDIPrior : 0;
                newCDU.Activation_roles__c = (newCDURules != null && String.isNotBlank(newCDURules)) ? newCDURules : null;
                newCDU.Esito__c = newCDUEsito;
                newCDU.Testata__c = idTestata;

                String sobj = Utils.NAMESPACE + 'Strategia__c';
                if (Utils.cebCheckObjPermission('RecordType', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('RecordType', 'Name', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('RecordType', 'SobjectType', gd).get('ACCESS')) {
                    RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Condizioni di Uscita' AND SobjectType = :sobj LIMIT 1];
                    //RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Condizioni di Uscita' AND SobjectType = :sobj WITH SECURITY_ENFORCED LIMIT 1];
                    newCDU.RecordTypeId = rt.Id;

                    insert newCDU;
                }
                /*PageReference page = new PageReference('/apex/ConfigurationStrategia?testid='+idTestata);
                page.setRedirect(true);
                return page;*/
                createStrategiaObjects();
            }
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Nuova CDU : Inserire tutti i dati.'));
        }
        return null;

    }

    public PageReference createStep() {

        if (testata == null || idTestata == null) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'E\' necessario inserire prima la testata.'));
            return null;
        }

        if (idTestata != null && newSname != null && selectedFase != null && selectedTipologia != null && selectedTipoAtt != null && selectedSottotipo != null && newSprior != null &&
                String.isNotBlank(idTestata) && String.isNotBlank(newSname) && String.isNotBlank(selectedFase) && String.isNotBlank(selectedTipologia) && String.isNotBlank(selectedTipoAtt) && String.isNotBlank(selectedSottotipo)) {

            if (Utils.cebCheckObjPermission('Strategia__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Testata__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Tipologia__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Tipo_attivita__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Sotto_tipo_attivita__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Fase__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Attivit_Padre__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Priority__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'RecordTypeId', gd).get('CREATE') &&
                    Utils.cebCheckObjPermission('Strategia__c', gd).get('INSERT')) {

                Strategia__c newStep = new Strategia__c();
                newStep.Nome__c = newSname;
                newStep.Testata__c = idTestata;
                newStep.Tipologia__c = selectedTipologia;
                newStep.Tipo_attivita__c = selectedTipoAtt;
                newStep.Sotto_tipo_attivita__c = selectedSottotipo;
                newStep.Fase__c = selectedFase;
                newStep.Activation_roles__c = (selectedRuleStep != null && String.isNotBlank(selectedRuleStep)) ? selectedRuleStep : null;
                newStep.Attivit_Padre__c = (selectedAttivitaPadre != null && String.isNotBlank(selectedAttivitaPadre)) ? selectedAttivitaPadre : null;
                newStep.Priority__c = (newSprior != null) ? newSprior : 0;

                String sobj = Utils.NAMESPACE + 'Strategia__c';
                if(Utils.cebCheckObjPermission('RecordType',gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('RecordType','Name',gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('RecordType','SobjectType',gd).get('ACCESS')) {
                    RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Step' AND SobjectType = :sobj LIMIT 1];
                    //RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Step' AND SobjectType = :sobj WITH SECURITY_ENFORCED LIMIT 1];
                    newStep.RecordTypeId = rt.Id;

                    insert newStep;
                }
            }

            PageReference page = new PageReference('/apex/ConfigurationStrategia?testid=' + idTestata);
            page.setRedirect(true);
            return page;
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Nuovo Step: Inserire tutti i dati.'));
            return null;
        }
    }

    public PageReference createJump() {

        if (testata == null || idTestata == null) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'E\' necessario inserire prima la testata.'));
            return null;
        }

        if (idTestata != null && newJname != null && selectedJumpFrom != null && selectedJumpTo != null && String.isNotBlank(idTestata) && String.isNotBlank(newJname) && String.isNotBlank(selectedJumpFrom) && String.isNotBlank(selectedJumpTo)) {

            if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Testata__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Esito__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Jump_from__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Jump_to__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Activation_roles__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'Priority__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('Strategia__c', 'RecordTypeId', gd).get('CREATE') &&
                    Utils.cebCheckObjPermission('Strategia__c', gd).get('INSERT')) {

                Strategia__c newJump = new Strategia__c();
                newJump.Nome__c = newJname;
                newJump.Testata__c = idTestata;
                newJump.Esito__c = (selectedEsito != null && String.isNotBlank(selectedEsito)) ? selectedEsito : null;
                newJump.Jump_from__c = selectedJumpFrom;
                newJump.Jump_to__c = selectedJumpTo;
                newJump.Activation_roles__c = selectedRuleJump;
                newJump.Priority__c = (newJprior != null) ? newJprior : 0;

                String sobj = Utils.NAMESPACE + 'Strategia__c';
                if(Utils.cebCheckObjPermission('RecordType',gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('RecordType','Name',gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('RecordType','SobjectType',gd).get('ACCESS')) {
                    RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Salto' AND SobjectType = :sobj LIMIT 1];
                    //RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Salto' AND SobjectType = :sobj WITH SECURITY_ENFORCED LIMIT 1];

                    newJump.RecordTypeId = rt.Id;

                    insert newJump;
                }
                createStrategiaObjects();
            }
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Nuovo Jump: Inserire tutti i dati.'));
        }

        return null;
    }

}