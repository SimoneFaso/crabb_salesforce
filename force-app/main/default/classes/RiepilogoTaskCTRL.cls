/* ---------------------------------------------------------------------------------------------------------------------
Name:            RiepilogoTaskCTRL.cls

Test class:      TESTRiepilogoTaskCTRL.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
              0.1                                      First Version
14-Sep-2022   0.2     R. Kurti & C. Sanna              Modified for adding check permission: cebCheckFLSPermission/cebCheckObjPermission/WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class RiepilogoTaskCTRL {

    public Set<Id> setIdStrategie { get; set; }
    public Set<Id> idPratiche { get; set; }
    public List<AggregateResult> listAR { get; set; }
    public Set<String> tipoSet { get; set; }
    public Set<String> sottoSet { get; set; }
    public Map<String, List<ARWrapper>> mapWrapper { get; set; }
    public String currentUserName { get; set; }
    public String selectedVisibility { get; set; }
    public List<SelectOption> pickVisibilityResult {
        get {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('All_Task', 'All_Task'));
            options.add(new SelectOption('My_Task', 'My_Task'));
            return options;
        }
    }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    public Map<String, Integer> mapTipoTotal { get; set; }
    public Map<String, Decimal> mapTipoOldest { get; set; }
    public String currentStep { get; set; }
    public Map<String, Schema.FieldSetMember> mapSchema { get; set; }
    public List<String> searchFields { get; set; }
    public Set<String> splitSotto { get; set; }
    public Map<String, Boolean> mapSottoDisabled { get; set; }
    public String selectedPickValue { get; set; }
    public List<SelectOption> picklistValues { get; set; }
    public ApexPages.StandardSetController stdCtrl { get; set; }
    public Boolean isString { get; private set; }
    public Boolean isDate { get; private set; }
    public Boolean isInteger { get; private set; }
    public Boolean isDouble { get; private set; }
    public Boolean isObject { get; private set; }
    public Boolean isCheckbox { get; private set; }
    public Boolean isPicklist { get; private set; }
    public String selField { get; set; }
    public List<SelectOption> pkInputList { get; private set; }
    public String sInput { get; set; }
    public List<String> pInput { get; set; }
    public Date dInputStart { get; set; }
    public Date dInputFinish { get; set; }
    public Integer iInputStart { get; set; }
    public Integer iInputFinish { get; set; }
    public Double ndInputStart { get; set; }
    public Double ndInputFinish { get; set; }
    public Boolean cInput { get; set; }
    public Pratica__c anPratica { get; set; }
    public List<String> searchList { get; private set; }
    public List<String> filter { get; private set; }
    public String delF { get; set; }
    public Map<String, Boolean> mapSelected { get; set; }
    public Integer numSelected { get; set; }
    public List<SelectOption> numOfRecords { get; set; }
    public String selectedNumOfRec { get; set; }
    public Boolean selAll { get; set; }
    public String tipoesotto { get; set; }
    public String ownerOne { get; set; }
    public Boolean isAffido { get; set; }
    public Set<String> tipiAffido { get; set; }
    public String taskWhereClause { get; set; }
    public Boolean isLettera { get; set; }
    public String letteraStr { get; set; }
    public Integer countTask { get; set; }
    public Boolean selPage { get; set; }
    public Boolean batchRunning { get; set; }
    public String batchId { get; set; }
    public AsyncApexJob aaj { get; set; }

    public RiepilogoTaskCTRL(ApexPages.StandardController std) {

        isLettera = false;
        numOfRecords = new List<SelectOption>();
        numOfRecords.add(new SelectOption('10', '10'));
        numOfRecords.add(new SelectOption('20', '20'));
        numOfRecords.add(new SelectOption('50', '50'));
        numOfRecords.add(new SelectOption('100', '100'));
        anPratica = new Pratica__c();
        searchList = new List<String>();
        filter = new List<String>();
        currentUserName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        currentStep = (ApexPages.currentPage().getParameters().get('step') != null) ? ApexPages.currentPage().getParameters().get('step') : '0';
        AffidiSettings__c currentAS = AffidiSettings__c.getInstance(UserInfo.getProfileId());
        splitSotto = new Set<String>();
        mapSottoDisabled = new Map<String, Boolean>();
        if (currentAS != null) {
            splitSotto.addAll(currentAS.Sottotipo__c.split(';'));
        }
        createObjects();

        if (currentStep.equalsIgnoreCase('1')) {
            createStepOne();
        }

    }

    public void createObjects() {
        mapTipoTotal = new Map<String, Integer>();
        mapTipoOldest = new Map<String, Decimal>();

        List<Strategia__c> listStrategie = database.query('SELECT ' + Utils.getSOBJECTFieldsForQuery('Strategia__c') + ' FROM Strategia__c WHERE Recordtype.Name = \'Step\' AND Tipologia__c = \'UI\' AND Stato_testata__c = \'Attiva\'');
        setIdStrategie = new Set<Id>();
        for (Strategia__c strat : listStrategie) {
            setIdStrategie.add(strat.Id);
        }

        system.debug('########## 1 ' + setIdStrategie);

        String queryOnTasks = 'SELECT Id, WhatId FROM Task WHERE ActivityExtended__r.id_attivita__c IN :setIdStrategie AND Status =\'Non Iniziata\' AND ActivityExtended__r.id_affidamento__c = null';
        Set<Id> idPraticheTemp = new Set<Id>();
        for (Task t : (List<Task>) Database.query(queryOnTasks)) {
            idPraticheTemp.add(t.whatID);
        }

        system.debug('########## 2 ' + idPraticheTemp);

        String queryonPratiche = 'SELECT Id From Pratica__c WHERE Id IN :idPraticheTemp AND Stato__c IN (\'Affidata\',\'In Lavorazione\')';
        idPratiche = new Set<Id>();
        for (Pratica__c p : (List<Pratica__c>) Database.query(queryonPratiche)) {
            idPratiche.add(p.Id);
        }

        system.debug('########## 3 ' + idPratiche);

        String query = 'SELECT Count(Id) TOT,ActivityExtended__r.Tipo__c TIPO,MAX(Giorni_di_completamento_attivita__c) GIORNI,ActivityExtended__r.Sotto_Tipo__c SOTTO,ActivityExtended__r.Owner_contratto__c OWNERCONTRATTO FROM Task WHERE ActivityExtended__r.id_attivita__c IN :setIdStrategie AND WhatId IN :idPratiche AND Status in (\'Non Iniziata\') AND ActivityExtended__r.id_affidamento__c = null ';

        if (selectedVisibility != null && String.isNotBlank(selectedVisibility) && selectedVisibility.equalsIgnoreCase('My_Task')) {
            query += 'AND ActivityExtended__r.Owner_contratto__c = \'' + String.escapeSingleQuotes(currentUserName) + '\' ';
        }

        query += 'GROUP BY ActivityExtended__r.Tipo__c,ActivityExtended__r.Sotto_Tipo__c,ActivityExtended__r.Owner_contratto__c';

        listAR = Database.query(query);
        listAR = Database.query(query);

        system.debug('########## 4 ' + listAR);

        tipoSet = new Set<String>();
        sottoSet = new Set<String>();
        mapWrapper = new Map<String, List<ARWrapper>>();

        if (listAR != null && !listAR.isEmpty()) {
            for (AggregateResult ar : listAR) {

                String tipo = ((String) ar.get('TIPO') == null || String.isBlank((String) ar.get('TIPO'))) ? '' : (((String) ar.get('TIPO')).equalsIgnoreCase('NA')) ? '' : (String) ar.get('TIPO');
                String sotto = ((String) ar.get('SOTTO') == null || String.isBlank((String) ar.get('SOTTO'))) ? '' : (((String) ar.get('SOTTO')).equalsIgnoreCase('NA')) ? '' : (String) ar.get('SOTTO');
                String owner = ((String) ar.get('OWNERCONTRATTO') != null && String.isNotBlank((String) ar.get('OWNERCONTRATTO'))) ? (String) ar.get('OWNERCONTRATTO') : '';

                tipoSet.add(tipo);
                sottoSet.add(sotto);

                String tiposotto = (sotto != null && String.isNotBlank(sotto)) ? tipo + '_' + sotto : tipo;

                if (splitSotto.contains(sotto) || sotto == '') {
                    mapSottoDisabled.put(tiposotto, false);
                } else {
                    mapSottoDisabled.put(tiposotto, true);
                }

                if (!mapWrapper.containsKey(tiposotto)) {
                    List<ARWrapper> temparw = new List<ARWrapper>();
                    ARWrapper arw = new ARWrapper(sotto, owner, (Integer) ar.get('TOT'), (Decimal) ar.get('GIORNI'));
                    temparw.add(arw);
                    mapWrapper.put(tiposotto, temparw);
                } else {
                    List<ARWrapper> temparw = mapWrapper.get(tiposotto);
                    temparw.add(new ARWrapper(sotto, owner, (Integer) ar.get('TOT'), (Decimal) ar.get('GIORNI')));
                    mapWrapper.put(tiposotto, temparw);
                }

                if (!mapTipoTotal.containsKey(tiposotto)) {
                    mapTipoTotal.put(tiposotto, (Integer) ar.get('TOT'));
                } else {
                    Integer tempTot = mapTipoTotal.get(tiposotto);
                    mapTipoTotal.put(tiposotto, tempTot + (Integer) ar.get('TOT'));
                }

                if (!mapTipoOldest.containsKey(tiposotto)) {
                    mapTipoOldest.put(tiposotto, (Decimal) ar.get('GIORNI'));
                } else {
                    Decimal tempDec = mapTipoOldest.get(tiposotto);
                    if ((Decimal) ar.get('GIORNI') > tempDec) {
                        mapTipoOldest.put(tiposotto, (Decimal) ar.get('GIORNI'));
                    }
                }
            }
        }
    }

    public void createStepOne() {
        currentStep = '1';
        //searchList = new List<String>();
        //filter = new List<String>();
        picklistValues = new List<SelectOption>();
        picklistValues.add(new SelectOption('', '--- Select one ---'));
        mapSchema = new Map<String, Schema.FieldSetMember>();
        searchFields = new List<String>();
        for (Schema.FieldSetMember f : SObjectType.Pratica__c.FieldSets.Filtro_Lavorazione_Task.getFields()) {
            searchFields.add(f.getFieldPath());
            mapSchema.put(f.getFieldPath(), f);

            picklistValues.add(new SelectOption(f.getFieldPath(), f.getLabel()));
        }

        tipoesotto = (ApexPages.currentPage().getParameters().get('tipoesotto') != null && String.isNotBlank(ApexPages.currentPage().getParameters().get('tipoesotto'))) ? ApexPages.currentPage().getParameters().get('tipoesotto') :
                (tipoesotto != null && String.isNotBlank(tipoesotto)) ? tipoesotto : '';
        ownerOne = (ApexPages.currentPage().getParameters().get('owner') != null && String.isNotBlank(ApexPages.currentPage().getParameters().get('owner'))) ? ApexPages.currentPage().getParameters().get('owner') :
                (ownerOne != null && String.isNotBlank(ownerOne)) ? ownerOne : '';

        String tip = (tipoesotto.contains('_')) ? tipoesotto.split('_')[0] : '';

        if (tip.equalsIgnoreCase('Invio AR') || tip.equalsIgnoreCase('Invio Lettera di Posta Prioritaria Standard')) {
            isLettera = true;
            letteraStr = tip;
        }

        String sotp = (tipoesotto.contains('_')) ? tipoesotto.split('_')[1] : '';

        String totalTipo = (tipoesotto.contains('_')) ? tipoesotto.replace('_', ' ') : tipoesotto;
        String queryTask = '';
        if (ownerOne != null && ownerOne.equalsIgnoreCase('all')) {
            taskWhereClause = 'WHERE ActivityExtended__r.id_attivita__c IN :setIdStrategie AND WhatId IN :idPratiche AND Status IN (\'Non Iniziata\') AND ActivityExtended__r.id_affidamento__c = null AND ActivityExtended__r.Tipo_Sottotipo__c = \'' + String.escapeSingleQuotes(totalTipo) + '\' ';
            queryTask = 'SELECT Id,WhatId FROM Task ' + taskWhereClause;
        } else {
            taskWhereClause = 'WHERE ActivityExtended__r.id_attivita__c IN :setIdStrategie AND WhatId IN :idPratiche AND Status IN (\'Non Iniziata\') AND ActivityExtended__r.id_affidamento__c = null AND ActivityExtended__r.Owner_contratto__c = \'' + String.escapeSingleQuotes(ownerOne) + '\' AND ActivityExtended__r.Tipo_Sottotipo__c = \'' + String.escapeSingleQuotes(totalTipo) + '\' ';
            queryTask = 'SELECT Id,WhatId FROM Task ' + taskWhereClause;
        }

        List<Task> tasklist = Database.query(queryTask);

        Set<Id> idprats = new Set<Id>();
        for (Task t : tasklist) {
            idprats.add(t.WhatId);
        }

        String queryPratiche = 'SELECT ' + Utils.getSOBJECTFieldsForQuery('Pratica__c') + ' ,Servizio_Fornitura__r.LookupContratto__r.Id_Esterno__c, Strategia__r.Nome__c, Servizio_Fornitura__r.RecordType.Name, Servizio_Fornitura__r.LookupContratto__r.Comune__c, Servizio_Fornitura__r.Codice__c, Account__r.Classe_di_Rischio__c, Account__r.Name FROM Pratica__c WHERE Stato__c NOT IN (\'Bloccata\',\'Bloccata Manualmente\') AND Id IN :idprats ';
        if (filter != null && !filter.isEmpty()) {
            queryPratiche += 'AND ';
            for (String str : filter) {
                queryPratiche += str + '';
            }
        }
        queryPratiche += ' ORDER BY Name ASC';
        stdCtrl = null;
        stdCtrl = new ApexPages.StandardSetController(Database.getQueryLocator(queryPratiche));
        // MSALA 20181203 - INIZIO
        if (stdCtrl.getResultSize() > 2000)
            stdCtrl.setPageSize(2000);
        else
                stdCtrl.setPageSize(stdCtrl.getResultSize());
        // MSALA 20181203 - FINE
        mapSelected = new Map<String, Boolean>();
        for (Pratica__c prat : (List<Pratica__c>) stdCtrl.getRecords()) {
            mapSelected.put(prat.Id, true);
        }
        // MSALA 20181203 - INIZIO
        while (stdCtrl.GetHasNext()) {
            stdCtrl.next();
            for (Pratica__c prat : (List<Pratica__c>) stdCtrl.getRecords()) {
                mapSelected.put(prat.Id, true);
            }
        }
        // MSALA 20181203 - FINE
        stdCtrl.setPageSize(10);
        numSelected = stdCtrl.getResultSize();
        selAll = true;
        selPage = true;

        tipiAffido = new Set<String>();
        if(Utils.cebCheckObjPermission('Collector_con_Tipo_Affido__c',gd).get('ACCESS')
        && Utils.cebCheckFLSPermission('Collector_con_Tipo_Affido__c','Tipo_Affido__c',gd).get('ACCESS')) {
            for (Collector_con_Tipo_Affido__c cta : [SELECT Tipo_Affido__c FROM Collector_con_Tipo_Affido__c LIMIT 50000]) {
                //for (Collector_con_Tipo_Affido__c cta : [SELECT Tipo_Affido__c FROM Collector_con_Tipo_Affido__c WITH SECURITY_ENFORCED LIMIT 50000]) {
                if (cta.Tipo_Affido__c != null) tipiAffido.add(cta.Tipo_Affido__c.tolowercase());
            }
        }
        isAffido = (sotp != '' && String.isNotBlank(sotp) && tipiAffido.contains(sotp.toLowerCase())) ? true : false;
    }

    public void selectAll() {
        if (selAll) {
            for (String str : mapSelected.keySet()) {
                mapSelected.put(str, true);
            }
            numSelected = mapSelected.size();
            selPage = true;
        } else {
            for (String str : mapSelected.keySet()) {
                mapSelected.put(str, false);
            }
            numSelected = 0;
            selPage = false;
        }
    }

    public void selectPage() {
        if (selPage) {
            for (Pratica__c p : (List<Pratica__c>) stdCtrl.getRecords()) {
                mapSelected.put(p.Id, true);
            }
        } else {
            for (Pratica__c p : (List<Pratica__c>) stdCtrl.getRecords()) {
                mapSelected.put(p.Id, false);
            }
        }

        numSelected = 0;
        for (String str : mapSelected.keySet()) {
            if (mapSelected.get(str)) {
                numSelected++;
            }
        }

        if (numSelected == 0) {
            selAll = false;
        } else if (numSelected == mapSelected.size()) {
            selAll = true;
        }
    }

    public void picklistMethod() {
        isString = false;
        isDate = false;
        isObject = false;
        isInteger = false;
        isDouble = false;
        isCheckbox = false;
        isPicklist = false;

        if (selectedPickValue != null && String.isNotBlank(selectedPickValue)) {
            Schema.FieldSetMember p = mapSchema.get(selectedPickValue);
            selField = p.getLabel();

            if (p.getType() == Schema.DisplayType.String) {
                isString = true;
            } else if (p.getType() == Schema.DisplayType.Date) {
                isDate = true;
            } else if (p.getType() == Schema.DisplayType.Integer) {
                isInteger = true;
            } else if (p.getType() == Schema.DisplayType.Double || p.getType() == Schema.DisplayType.Currency) {
                isDouble = true;
            } else if (p.getType() == Schema.DisplayType.Boolean) {
                isCheckbox = true;
            } else if (p.getType() == Schema.DisplayType.Picklist) {
                isPicklist = true;
                getPicklistInput();
            } else if (p.getType() == Schema.DisplayType.Reference) {
                isObject = true;
            }
        } else {
            selField = '';
        }
    }

    public void getPicklistInput() {
        pkInputList = new List<SelectOption>();

        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Pratica__c');
        if (targetType == null) {
            targetType = Schema.getGlobalDescribe().get(Utils.NAMESPACE + 'Pratica__c');
            if (targetType == null) {
                targetType = Schema.getGlobalDescribe().get(Utils.NAMESPACE + 'Pratica__c');
            }
        }

        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(mapSchema.get(selectedPickValue).getFieldPath()).getDescribe().getPickListValues();

        for (Schema.PicklistEntry f : pick_list_values) {
            pkInputList.add(new SelectOption(f.getLabel(), f.getValue()));
        }
    }

    public void setFilter() {
        String filtro = '';
        String search = '';

        if (selectedPickValue != null && String.isNotBlank(selectedPickValue)) {
            if (isString == true) {
                if (sInput.containsIgnoreCase('%')) {
                    search = mapSchema.get(selectedPickValue).getLabel() + ' LIKE ' + sInput;
                    filtro = mapSchema.get(selectedPickValue).getFieldPath() + ' LIKE \'' + sInput + '\'';
                } else {
                    search = mapSchema.get(selectedPickValue).getLabel() + ' = ' + sInput;
                    filtro = mapSchema.get(selectedPickValue).getFieldPath() + ' = \'' + sInput + '\'';
                }
                sInput = null;
            } else if (isDate == true) {
                String newdis;
                String newdif;

                if (dInputStart != null) {
                    Date dis = Date.valueOf(dInputStart);
                    String meseS = string.valueOf(dis.month());
                    if (meseS.length() == 1) {
                        meseS = '0' + meseS;
                    }
                    String giornoS = string.valueOf(dis.day());
                    if (giornoS.length() == 1) {
                        giornoS = '0' + giornoS;
                    }
                    newdis = dis.year() + '-' + meseS + '-' + giornoS;
                }

                if (dInputFinish != null) {
                    Date dif = Date.valueOf(dInputFinish);
                    String meseF = string.valueOf(dif.month());
                    if (meseF.length() == 1) {
                        meseF = '0' + meseF;
                    }
                    String giornoF = string.valueOf(dif.day());

                    if (giornoF.length() == 1) {
                        giornoF = '0' + giornoF;
                    }
                    newdif = dif.year() + '-' + meseF + '-' + giornoF;
                }

                if (dInputStart != null && dInputFinish != null) {
                    filtro = mapSchema.get(selectedPickValue).getFieldPath() + ' >= ' + newdis + ' AND ' + mapSchema.get(selectedPickValue).getFieldPath() + ' < ' + newdif;
                    search = mapSchema.get(selectedPickValue).getLabel() + ' >= ' + newdis + ' AND ' + mapSchema.get(selectedPickValue).getLabel() + ' < ' + newdif;
                } else if (dInputStart != null) {
                    filtro = mapSchema.get(selectedPickValue).getFieldPath() + ' >= ' + newdis;
                    search = mapSchema.get(selectedPickValue).getLabel() + ' >= ' + newdis;

                } else if (dInputFinish != null) {
                    filtro = mapSchema.get(selectedPickValue).getFieldPath() + ' < ' + newdif;
                    search = mapSchema.get(selectedPickValue).getLabel() + ' < ' + newdif;
                }

                dInputStart = null;
                dInputFinish = null;
            } else if (isObject == true) {
                filtro = mapSchema.get(selectedPickValue).getFieldPath() + ' = \'' + anPratica.get(mapSchema.get(selectedPickValue).getFieldPath()) + '\'';
                search = mapSchema.get(selectedPickValue).getLabel() + ' = ' + anPratica.get(mapSchema.get(selectedPickValue).getFieldPath());
                anPratica = new Pratica__c();
            } else if (isInteger == true) {
                filtro = mapSchema.get(selectedPickValue).getFieldPath() + ' >= ' + iInputStart + ' AND ' + mapSchema.get(selectedPickValue).getFieldPath() + ' < ' + iInputFinish;
                search = mapSchema.get(selectedPickValue).getLabel() + ' >= ' + iInputStart + ' AND ' + mapSchema.get(selectedPickValue).getLabel() + ' < ' + iInputFinish;
            } else if (isDouble == true) {
                filtro = mapSchema.get(selectedPickValue).getFieldPath() + ' >= ' + ndInputStart + ' AND ' + mapSchema.get(selectedPickValue).getFieldPath() + ' < ' + ndInputFinish;
                search = mapSchema.get(selectedPickValue).getLabel() + ' >= ' + ndInputStart + ' AND ' + mapSchema.get(selectedPickValue).getLabel() + ' < ' + ndInputFinish;
            } else if (isCheckbox == true) {
                filtro = mapSchema.get(selectedPickValue).getFieldPath() + ' = ' + cInput;
                search = mapSchema.get(selectedPickValue).getLabel() + ' = ' + cInput;
            } else if (isPicklist == true) {
                if (pInput != null && !pInput.isEmpty()) {
                    String pickinput = String.join(pInput, '\',\'');
                    search = mapSchema.get(selectedPickValue).getLabel() + ' IN (' + pickinput + ')';
                    filtro = mapSchema.get(selectedPickValue).getFieldPath() + ' IN (\'' + pickinput + '\')';
                    pInput.clear();
                }
            }

            filter.add(filtro);
            searchList.add(search);
        }
    }

    public PageReference deleteFilter() {
        for (Integer j = 0; j < searchList.size(); j++) {
            if (searchList.get(j) == String.valueOf(delF)) {
                searchList.remove(j);
                filter.remove(j);
            }
        }
        return null;
    }

    public PageReference clearFilter() {
        searchList.clear();
        filter.clear();
        selectedPickValue = null;
        selField = '';
        isString = false;
        isDate = false;
        isInteger = false;
        isDouble = false;
        isObject = false;
        isCheckbox = false;
        isPicklist = false;
        sInput = null;
        dInputStart = null;
        dInputFinish = null;
        iInputStart = null;
        iInputFinish = null;
        ndInputStart = null;
        ndInputFinish = null;
        cInput = null;
        pInput = null;

        createStepOne();
        return null;
    }

    public void setNumOfRec() {
        Integer temp = Integer.valueOf(selectedNumOfRec);
        stdCtrl.setPageSize(temp);
    }

    public PageReference AffidaLista() {
        Pagereference page = new PageReference('/apex/AffidamentiConfermaLotti?Type=');
        if (tipoesotto != null && String.isNotBlank(tipoesotto)) {
            if (tipoesotto.contains('_')) {
                String stp = tipoesotto.split('_')[1];
                page = new PageReference('/apex/AffidamentiConfermaLotti?Type=' + stp);
            }
        }

        Map<Id, Boolean> selectedPratiche = new Map<Id, Boolean>();
        for (String str : mapSelected.keySet()) {
            if (mapSelected.get(str)) {
                selectedPratiche.put(str, true);
            }
        }

        String jsonmap = JSON.serialize(selectedPratiche);
        if (Utils.cebCheckObjPermission('Log__c', gd).get('CREATE') &&
                Utils.cebCheckFLSPermission('Log__c', 'Integration_Json_file_data__c',gd).get('CREATE')) {
            Log__c newLog = new Log__c(Integration_Json_file_data__c = jsonmap, info__c = '#infojson');
            insert newLog;
            page.getParameters().put('idLog', newLog.Id);
        }
        page.getParameters().put('jsonmap', jsonmap);
        page.setRedirect(true);
        return page;
    }

    public PageReference ConfermaLista() {

        List<Id> lPratDaElaborare = new List<Id>();
        for (String str : mapSelected.keySet()) {
            if (mapSelected.get(str)) {
                lPratDaElaborare.add(str);
            }
        }

        if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Scelta_utente__c',gd).get('ACCESS')) {

            String queryUPD = 'SELECT Id, Status, ActivityExtended__r.Scelta_utente__c FROM Task ' + taskWhereClause + ' AND WhatId IN :lPratDaElaborare';

            List<Task> taskUPD = new List<Task>();
            if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS') &&
                    Utils.cebCheckFLSPermission('Task', 'SLA__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Count_of_Events__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Count_of_Tasks__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Giorni_Fuori_SLA__c',gd).get('ACCESS')) {

                taskUPD = database.query(queryUPD);
            }
            Map<Id, ActivityExtended__c> task2obj = Utils.getTaskWithActivityExtended(taskUPD);
            List<ActivityExtended__c> aes = new List<ActivityExtended__c>();

            for (Task t : taskUPD) {
                t.Status = 'Lavorata';
                if (isLettera) {
                    ActivityExtended__c ae = task2obj.get(t.Id);
                    if (ae != null) {
                        ae.Scelta_utente__c = letteraStr;
                        aes.add(ae);
                    }
                }
            }

            if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE') &&
                    Utils.cebCheckFLSPermission('ActivityExtended__c', 'Scelta_utente__c',gd).get('UPDATE')) {
                update aes;
            }
            //if (Utils.cebCheckFLSPermission('Task', 'Status').get('UPDATE')) update taskUPD;
            batchId = Database.executeBatch(new BatchElaboraPratiche(taskUPD), 20);
            aaj = [SELECT Id, Status, ExtendedStatus, CompletedDate, CreatedDate, TotalJobItems, JobItemsProcessed FROM AsyncApexJob WHERE Id = :batchId LIMIT 1];
            currentStep = '2';
            batchRunning = true;
            countTask = taskUPD.size();
        }
        return null;
    }

    public void empty() {

        aaj = [SELECT Id, Status, ExtendedStatus, CompletedDate, CreatedDate, TotalJobItems, JobItemsProcessed FROM AsyncApexJob WHERE Id = :batchId LIMIT 1];
        if (aaj.Status.equalsIgnoreCase('Completed') || aaj.Status.equalsIgnoreCase('Aborted') || aaj.Status.equalsIgnoreCase('Failed')) {
            batchRunning = false;
        }

    }

    public Pagereference backTo() {
        PageReference pg = new Pagereference('/apex/RiepilogoTask');
        pg.setRedirect(true);
        return pg;
    }

    public Pagereference homePage() {
        return new Pagereference('/');
    }

    public class ARWrapper {

        public String sottotipo { get; set; }
        public String owner { get; set; }
        public Integer totCount { get; set; }
        public Decimal giorni { get; set; }

        public ARWrapper(String s, String o, Integer c, Decimal g) {
            sottotipo = s;
            owner = o;
            totCount = c;
            giorni = g;
        }

    }

    public PageReference goNext() {
        System.debug('aaa');
        if (stdCtrl != null) {
            System.debug('bbb');
            if (stdCtrl.getHasNext()) {
                System.debug('ccc');
                stdCtrl.next();
            }
        }
        return null;
    }
}