/* ---------------------------------------------------------------------------------------------------------------------
Name:            AffidiSettingsCTRL.cls
Description:
Test class:      TestAffidiSettingsCTRL.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
14-Sep-2022  0.2      R. Kurti & C. Sanna             Modified for adding check permission:
                                                      cebCheckObjPermission/WITH SECURITY_ENFORCED (Security Review)
11-Oct-2022  0.3      R.Kurti & C.Sanna               Removed WITH SECURITY ENFORCED and added cebCheckObjPermission
----------------------------------------------------------------------------------------------------------------------*/
global with sharing class AffidiSettingsCTRL {

    public Boolean show { get; set; }
    public List<AffidiSettings__c> listAffSettings { get; set; }
    public List<SelectOption> listItems { get; set; }
    public String selectedLocation { get; set; }
    public String selectedItem { get; set; }
    public Map<String, String> mapIdProfile { get; set; }
    public List<Profile> profilesList { get; set; }

    public List<SelectOption> tipoOptions { get; set; }
    public String selectedTipo { get; set; }

    public List<SelectOption> sottotipoOptions { get; set; }
    public List<String> sottotipoSelected { get; set; }

    public String addingProfile { get; set; }
    public String addingTipo { get; set; }
    public List<String> addingSotto { get; set; }
    public String addingSottoStr { get; set; }
    public List<AggregateResult> aggregateStrategie { get; set; }

    public List<SelectOption> allSottotipo { get; set; }
    public static Map<String, SObjectType> gd = Schema.getGlobalDescribe();

    public AffidiSettingsCTRL() {

        listAffSettings = new List<AffidiSettings__c>();
        mapIdProfile = new Map<String, String>();
        addingSotto = new List<String>();
        aggregateStrategie = new List<AggregateResult>();
        tipoOptions = new List<SelectOption>();
        sottotipoOptions = new List<SelectOption>();
        allSottotipo = new List<SelectOption>();
        show = true;

        Set<String> added = new Set<String>();

        String query = 'SELECT ' + String.escapeSingleQuotes(Utils.getSOBJECTFieldsForQuery('AffidiSettings__c')) + ' FROM AffidiSettings__c';
        listAffSettings = Database.query(query);

        if (listAffSettings != null && !listAffSettings.isEmpty()) {

            Set<String> tempIdSet = new Set<String>();

            for (AffidiSettings__c afs : listAffSettings) {
                tempIdSet.add(afs.SetupOwnerId);
            }

            if(Utils.cebCheckObjPermission('Profile',gd).get('ACCESS')) {
                profilesList = [SELECT Id, Name FROM Profile];
                //profilesList = [SELECT Id,Name FROM Profile WITH SECURITY_ENFORCED];
                if (profilesList != null && !profilesList.isEmpty()) {
                    for (Profile p : profilesList) {
                        if (tempIdSet.contains(p.Id)) {
                            mapIdProfile.put(p.Id, p.Name);
                        }
                    }
                }
            }

            AffidiSettings__c defaultAS = AffidiSettings__c.getOrgDefaults();
            mapIdProfile.put(defaultAS.SetupOwnerId, 'Organization Default');
        }

        String queryAggr = 'select Tipo_attivita__c,Sotto_tipo_attivita__c from Strategia__c where Tipologia__c = \'UI\' and recordtype.name = \'Step\' group by Tipo_attivita__c,Sotto_tipo_attivita__c';
        aggregateStrategie = Database.query(queryAggr);

        listItems = new List<SelectOption>();
        listItems.add(new SelectOption('', '-- None --'));

        for (Profile p : profilesList) {
            listItems.add(new SelectOption(p.Name, p.Name));
        }

        listItems.sort();

        Set<String> addedAllSotto = new Set<String>();
        tipoOptions.add(new SelectOption('', '-- None --'));
        if (aggregateStrategie != null && !aggregateStrategie.isEmpty()) {
            for (AggregateResult agg : aggregateStrategie) {
                if (!addedAllSotto.contains((String) agg.get(Utils.NAMESPACE + 'Sotto_tipo_attivita__c'))) {
                    allSottotipo.add(new SelectOption((String) agg.get(Utils.NAMESPACE + 'Sotto_tipo_attivita__c'), (String) agg.get(Utils.NAMESPACE + 'Sotto_tipo_attivita__c')));
                }
                if (!added.contains((String) agg.get(Utils.NAMESPACE + 'Tipo_attivita__c'))) {
                    tipoOptions.add(new SelectOption((String) agg.get(Utils.NAMESPACE + 'Tipo_attivita__c'), (String) agg.get(Utils.NAMESPACE + 'Tipo_attivita__c')));
                    added.add((String) agg.get(Utils.NAMESPACE + 'Tipo_attivita__c'));
                }
            }
        }
        tipoOptions.sort();
        allSottotipo.sort();

        sottotipoOptions.add(new SelectOption('', '-- None --'));

    }

    public void retrieveSottotipo() {
        sottotipoOptions.clear();
        System.debug('@! ' + addingTipo);
        sottotipoOptions.add(new SelectOption('', '-- None --'));
        Set<String> added = new Set<String>();
        if (addingTipo != null && String.isNotBlank(addingTipo)) {
            for (AggregateResult agg : aggregateStrategie) {
                if (((String) agg.get(Utils.NAMESPACE + 'Tipo_attivita__c')).equalsIgnoreCase(addingTipo)) {
                    if (!added.contains(((String) agg.get(Utils.NAMESPACE + 'Sotto_tipo_attivita__c')))) {
                        sottotipoOptions.add(new SelectOption((String) agg.get(Utils.NAMESPACE + 'Sotto_tipo_attivita__c'), (String) agg.get(Utils.NAMESPACE + 'Sotto_tipo_attivita__c')));
                        added.add(((String) agg.get(Utils.NAMESPACE + 'Sotto_tipo_attivita__c')));
                    }
                }
            }
        }
        sottotipoOptions.sort();
    }

    public void retrieveSottotipoTwo() {
        sottotipoOptions.clear();
        System.debug('@! ' + selectedTipo);
        sottotipoOptions.add(new SelectOption('', '-- None --'));
        Set<String> added = new Set<String>();
        if (selectedTipo != null && String.isNotBlank(selectedTipo)) {
            for (AggregateResult agg : aggregateStrategie) {
                if (((String) agg.get(Utils.NAMESPACE + 'Tipo_attivita__c')).equalsIgnoreCase(selectedTipo)) {
                    if (!added.contains(((String) agg.get(Utils.NAMESPACE + 'Sotto_tipo_attivita__c')))) {
                        sottotipoOptions.add(new SelectOption((String) agg.get(Utils.NAMESPACE + 'Sotto_tipo_attivita__c'), (String) agg.get(Utils.NAMESPACE + 'Sotto_tipo_attivita__c')));
                        added.add(((String) agg.get(Utils.NAMESPACE + 'Sotto_tipo_attivita__c')));
                    }
                }
            }
        }
        sottotipoOptions.sort();
    }

    @RemoteAction
    global static String removeRecords(String param) {
        if (Utils.cebCheckObjPermission('AffidiSettings__c', gd).get('DELETE')) {
            AffidiSettings__c toRemove = new AffidiSettings__c(Id = param);
            delete toRemove;
        }

        String result = '/apex/AffidiSettingsPage';
        return result;
    }

    public void emptyMethod() {
    }

    public PageReference addNewRecord() {
        try {
            if (addingProfile != null && String.isNotBlank(addingProfile)) {
                AffidiSettings__c newSetting = new AffidiSettings__c();

                for (Profile p : profilesList) {
                    if (p.Name.equalsIgnoreCase(addingProfile)) {
                        newSetting.SetupOwnerId = p.Id;
                        break;
                    }
                }

                if (addingTipo != null && String.isNotBlank(addingTipo)) {
                    newSetting.Tipo__c = addingTipo;
                }

                System.debug(']]] ' + addingSotto);

                if (addingSotto != null && !addingSotto.isEmpty()) {
                    String temp = '';
                    for (String str : addingSotto) {
                        temp += str + ';';
                    }
                    temp = temp.substring(0, temp.length() - 1);
                    newSetting.Sottotipo__c = temp;
                } else if (addingSottoStr != null && String.isNotBlank(addingSottoStr)) {
                    newSetting.Sottotipo__c = addingSottoStr;
                }

                if (Utils.cebCheckObjPermission('AffidiSettings__c', gd).get('CREATE')
                        && Utils.cebCheckObjPermission('AffidiSettings__c', gd).get('INSERT')) {
                    insert newSetting;
                }
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'No Profile selected.'));
                return null;
            }

            PageReference page = new PageReference('/apex/AffidiSettingsPage');
            page.setRedirect(true);
            return page;
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }

    @RemoteAction
    global static String editRecord(String idRecord, String loc, String tipo, String sotto) {
        if (idRecord == null || loc == null || tipo == null || sotto == null) {
            return '';
        } else {

            AffidiSettings__c aff = new AffidiSettings__c(Id = idRecord);

            if (Utils.cebCheckObjPermission('Profile', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Profile', 'Name', gd).get('ACCESS')) {  // new ceb check  after removing WITH SECURITY ENFORCED
                List<Profile> profList = [SELECT Id FROM Profile WHERE Name = :loc LIMIT 1];
                //List<Profile> profList = [SELECT Id FROM Profile WHERE Name = :loc WITH SECURITY_ENFORCED LIMIT 1];
                if (profList != null && !profList.isEmpty()) {
                    aff.SetupOwnerId = profList[0].Id;
                } else {
                    return 'error';
                }

                if (tipo != null && String.isNotBlank(tipo)) {
                    aff.Tipo__c = tipo;
                }

                if (sotto != null && String.isNotBlank(sotto)) {
                    aff.Sottotipo__c = sotto;
                }

                if (Utils.cebCheckObjPermission('AffidiSettings__c', gd).get('UPDATE')) {
                    update aff;
                }

            }
        }
        return '/apex/AffidiSettingsPage';
    }
}