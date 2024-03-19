/* ---------------------------------------------------------------------------------------------------------------------
Name:            EsitiMassiviCTRL.cls
Description:     Extension Controller for Esiti_Massivi.page
Test class:      TESTEsitiMassiviCTRL.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
11-Dec-2018  0.2      Matteo Sala
05-Aug-2021  0.3      Giulia Mameli        Added statiPratica list and getStatusesList method to dynamically filter
                                           Dossiers on queries
13-Sep-2022  0.4      C.Sanna & R.Kurti    Added WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

global with sharing class EsitiMassiviCTRL {
    // @auraEnabled
    // public static List<Task> getTasks()
    // {
    //     return [select Subject,WhatId From Task where Status='Non iniziata' and Type = 'Credito' order by lastmodifiedDate Desc LIMIT 100];
    // }

    // @auraEnabled
    // public static List<AggregateResult> getTasksType()
    // {
    //     return [SELECT
    //                 CRABB_DEV__ActivityExtended__r.CRABB_DEV__Tipo__c,
    //                 CRABB_DEV__ActivityExtended__r.CRABB_DEV__Sotto_Tipo__c,
    //                 Count(Id) Conteggio
    //             FROM 
    //                 Task 
    //             WHERE 
    //                 Status='Non iniziata' and Type = 'Credito' 
    //                 AND CRABB_DEV__ActivityExtended__r.CRABB_DEV__Tipo__c <> ''
    //                 AND CRABB_DEV__ActivityExtended__r.CRABB_DEV__Sotto_Tipo__c <> ''
    //             GROUP BY 
    //                 CRABB_DEV__ActivityExtended__r.CRABB_DEV__Tipo__c, 
    //                 CRABB_DEV__ActivityExtended__r.CRABB_DEV__Sotto_Tipo__c];
    // }

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
    public Map<String, Integer> mapTipoTotal { get; set; }
    public Map<String, Decimal> mapTipoOldest { get; set; }
    public String currentStep { get; set; }
    public Map<String, Schema.FieldSetMember> mapSchema { get; set; }
    public List<String> searchFields { get; set; }
    public Set<String> splitSotto { get; set; }
    public Map<String, Boolean> mapSottoDisabled { get; set; }
    public String selectedPickValue { get; set; }
    public String selectedEsitiPickValue { get; set; }
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
    public String EsitoFinal { get; set; }
    public List<SelectOption> FinalValues { get; set; }
    public Map<String, String> mapEsiti { get; set; }

    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    //Retrieve Dossier Statuses used to filter Dossiers on Bulk Outcome functionality
    private static final Set<String> statiPratica = getDossierStatusesList('EsitiMassivi', 'CRABB_DEV__stati_in_lavorazione__c');

    public List<SelectOption> getEsitiPickListValues() {
        List<SelectOption> esitiPicklistValues = new List<SelectOption>();
        esitiPicklistValues.add(new SelectOption('', '--- Select one ---'));
        esitiPicklistValues.add(new SelectOption('Nessun Esito', 'Nessun Esito'));
        if (Utils.cebCheckObjPermission('Esiti_Massivi__mdt', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Esiti_Massivi__mdt', 'Allowed_Outcomes__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Esiti_Massivi__mdt', 'Allowed_Final_Outcomes__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Esiti_Massivi__mdt', 'Allowed_Partial_Outcomes__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Esiti_Massivi__mdt', 'Tipo_Sottotipo__c', gd).get('ACCESS')
        ) {
            Esiti_Massivi__mdt[] esitiMassivi = [
                    SELECT Allowed_Outcomes__c, Allowed_Final_Outcomes__c, Allowed_Partial_Outcomes__c
                    FROM Esiti_Massivi__mdt
                    WHERE Tipo_Sottotipo__c = :tipoesotto
                    //WITH SECURITY_ENFORCED
            ];
            //List<String> ls = new List<String>();

            mapEsiti = new Map<String, String>();
            mapEsiti.put('', 'Partial');
            mapEsiti.put('Nessun Esito', 'Partial');

            if (esitiMassivi.size() > 0) {
                //ls = EM[0].Allowed_Outcomes__c.split(';');
                // for(String s : ls)
                // {
                //    esitiPicklistValues.add(new SelectOption(s, s));
                // }

                //selectedEsitiPickValue = 'Nessun Esito';
                for (Esiti_Massivi__mdt em : esitiMassivi) {
                    if (em.Allowed_Final_Outcomes__c != null && em.Allowed_Final_Outcomes__c != '') {
                        for (String finalV : (em.Allowed_Final_Outcomes__c).split(';')) {
                            mapEsiti.put(finalV, 'Final');
                            esitiPicklistValues.add(new SelectOption(finalV, finalV));
                        }
                    }
                    if (em.Allowed_Partial_Outcomes__c != null && em.Allowed_Partial_Outcomes__c != '') {
                        for (String partialV : (em.Allowed_Partial_Outcomes__c).split(';')) {
                            mapEsiti.put(partialV, 'Partial');
                            esitiPicklistValues.add(new SelectOption(partialV, partialV));
                        }
                    }
                }
            }
        }
        // Schema.DescribeFieldResult fieldResult = ActivityExtended__c.Esito__c.getDescribe();
        // List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        // for( Schema.PicklistEntry pickListVal : ple)
        // {
        //     esitiPicklistValues.add(new SelectOption(pickListVal.getLabel(), pickListVal.getLabel()));
        // }
        return esitiPicklistValues;
    }

    public EsitiMassiviCTRL(ApexPages.StandardController std) {
        FinalValues = new List<SelectOption>();
        FinalValues.add(new SelectOption('Final', 'Final'));
        FinalValues.add(new SelectOption('Partial', 'Partial'));
        EsitoFinal = 'Final';
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
        //AffidiSettings__c currentAS = AffidiSettings__c.getInstance(UserInfo.getProfileId());


        //Aggiunta gestione degli accessi alle attivita lavorabili mediante custom metadato CRABB_DEV__EsitazioneMassivaPermission__mdt
        Map<String, CRABB_DEV__EsitazioneMassivaPermission__mdt> mapEsitiMassiviAcc = new Map<String, CRABB_DEV__EsitazioneMassivaPermission__mdt>();
        if (Utils.cebCheckObjPermission('CRABB_DEV__EsitazioneMassivaPermission__mdt', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('CRABB_DEV__EsitazioneMassivaPermission__mdt', 'CRABB_DEV__key__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('CRABB_DEV__EsitazioneMassivaPermission__mdt', 'CRABB_DEV__type__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('CRABB_DEV__EsitazioneMassivaPermission__mdt', 'CRABB_DEV__subtype__c', gd).get('ACCESS')) {
            List<CRABB_DEV__EsitazioneMassivaPermission__mdt> esitiMassiviProfileList = [
                    SELECT Id, CRABB_DEV__key__c, CRABB_DEV__type__c, CRABB_DEV__subtype__c
                    //FROM CRABB_DEV__EsitazioneMassivaPermission__mdt];
                    FROM CRABB_DEV__EsitazioneMassivaPermission__mdt
                    //WITH SECURITY_ENFORCED
            ];
            for (CRABB_DEV__EsitazioneMassivaPermission__mdt rec : esitiMassiviProfileList) {
                mapEsitiMassiviAcc.put(rec.CRABB_DEV__key__c, rec);
            }
        }

        //Cerco profilo e permission set contenenti la parola CRABB dell'utente che visualizza la pagina di esitazione massiva
        if (Utils.cebCheckObjPermission('PermissionSetAssignment', gd).get('ACCESS')
                && Utils.cebCheckObjPermission('PermissionSet',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('PermissionSet', 'Name', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('PermissionSet', 'Label', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('PermissionSet', 'ProfileId', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('PermissionSet', 'isOwnedByProfile', gd).get('ACCESS')
        ) {
            List<PermissionSetAssignment> profilePerSet = [
                    SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.Label, PermissionSet.ProfileId,
                            PermissionSet.Profile.Name, PermissionSet.IsOwnedByProfile, AssigneeId, Assignee.Name, Assignee.Profile.Name
                    FROM PermissionSetAssignment
                    WHERE PermissionSet.Name like '%CRABB%' and PermissionSet.IsOwnedByProfile = false and AssigneeId = :UserInfo.getUserId()
                    //WITH SECURITY_ENFORCED
                    order by PermissionSet.Name
            ];

            //Creo la chiave profilo|permission set ordinando per permissionSet.name
            String chiave = '';
            if (profilePerSet.size() > 0) {
                chiave = profilePerSet.get(0).Assignee.Profile.Name;
                for (PermissionSetAssignment ps : profilePerSet) {
                    chiave += '|' + ps.PermissionSet.Label;
                }
            } else {
                //List<Profile> prof = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
                if(Utils.cebCheckObjPermission('Profile',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Profile','Name',gd).get('ACCESS')) {
                    //List<Profile> prof = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() WITH SECURITY_ENFORCED];
                    List<Profile> prof = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
                    chiave = prof.get(0).Name;
                }
            }

            System.debug('######### chiave: ' + chiave);

            //Controllo se la mappa contiene un record con la chiave corrispondente
            CRABB_DEV__EsitazioneMassivaPermission__mdt esitiMassiviAccess = mapEsitiMassiviAcc.containsKey(chiave) ? mapEsitiMassiviAcc.get(chiave) : new CRABB_DEV__EsitazioneMassivaPermission__mdt();

            //Creo una lista di stringhe contenenti il profilo e i vari permission set dell'utente
            List<String> profilePermSetList = new List<String>();
            profilePermSetList = chiave.split('\\|');
            System.debug('############################## esiti massivi record prima del for: ' + esitiMassiviAccess);

            //Controllo se la mappa contiene altri record relativi al profilo o al singolo permission set dell'utente (e non alla combinazione profilo|permission set)
            for (String profileKey : mapEsitiMassiviAcc.keySet()) {
                if (profilePermSetList.contains(profileKey) && !profileKey.equals(chiave)) {
                    esitiMassiviAccess.CRABB_DEV__type__c += String.valueOf(esitiMassiviAccess.CRABB_DEV__type__c).endsWith(';') ? mapEsitiMassiviAcc.get(profileKey).CRABB_DEV__type__c : ';' + mapEsitiMassiviAcc.get(profileKey).CRABB_DEV__type__c;
                    esitiMassiviAccess.CRABB_DEV__subtype__c += String.valueOf(esitiMassiviAccess.CRABB_DEV__subtype__c).endsWith(';') ? mapEsitiMassiviAcc.get(profileKey).CRABB_DEV__subtype__c : ';' + mapEsitiMassiviAcc.get(profileKey).CRABB_DEV__subtype__c;
                }
            }

            System.debug('############################## esiti massivi record dopo il for: ' + esitiMassiviAccess);
            System.debug('@@@@@@@ sottotipo: ' + esitiMassiviAccess.CRABB_DEV__subtype__c);
            System.debug('@@@@@@@ tipo: ' + esitiMassiviAccess.CRABB_DEV__type__c);


            splitSotto = new Set<String>();
            mapSottoDisabled = new Map<String, Boolean>();
            mapEsiti = new Map<String, String>();

            //Controllo che esista il record del metadato, se non esiste richiamo la logica basata sul custom setting EsitiMassiviProfile__c
            if (esitiMassiviAccess != null && String.isNotBlank(esitiMassiviAccess.CRABB_DEV__subtype__c)) {
                splitSotto.addAll(esitiMassiviAccess.CRABB_DEV__subtype__c.split(';'));
            } else {
                EsitiMassiviProfile__c currentAS = EsitiMassiviProfile__c.getInstance(UserInfo.getProfileId());
                if (currentAS != null) {
                    splitSotto.addAll(currentAS.Sottotipo__c.split(';'));
                }
            }
            createObjects();

            if (currentStep.equalsIgnoreCase('1')) {
                createStepOne();
            }

            //old version, using custom setting records
            /*
        EsitiMassiviProfile__c currentAS = EsitiMassiviProfile__c.getInstance(UserInfo.getProfileId());


		if(currentAS != null)
        {
			splitSotto.addAll(currentAS.Sottotipo__c.split(';'));
		}
		createObjects();

		if(currentStep.equalsIgnoreCase('1')){
			createStepOne();
		}*/
        }
    }

    public void createObjects() {
        mapTipoTotal = new Map<String, Integer>();
        mapTipoOldest = new Map<String, Decimal>();
        String queryOnPratiche;

        List<Strategia__c> listStrategie = Database.query('SELECT ' + Utils.getSOBJECTFieldsForQuery('Strategia__c') + ' FROM Strategia__c WHERE Recordtype.Name = \'Step\' AND Tipologia__c = \'UI\' AND Stato_testata__c = \'Attiva\'');
        setIdStrategie = new Set<Id>();
        for (Strategia__c strat : listStrategie) {
            setIdStrategie.add(strat.Id);
        }

        String queryOnTasks = 'SELECT Id, WhatId FROM Task WHERE ActivityExtended__r.id_attivita__c IN :setIdStrategie AND Status =\'Non Iniziata\' AND ActivityExtended__r.id_affidamento__c = null';
        Set<Id> idPraticheTemp = new Set<Id>();
        for (Task t : (List<Task>) Database.query(queryOnTasks)) {
            idPraticheTemp.add(t.WhatId);
        }

        //String queryOnPratiche='SELECT Id From Pratica__c WHERE Id IN :idPraticheTemp AND Stato__c IN (\'Affidata\',\'In Lavorazione\')';

        if (statiPratica.size() > 0) {
            queryOnPratiche = 'SELECT Id FROM Pratica__c WHERE Id IN :idPraticheTemp AND Stato__c IN : statiPratica';
        } else {
            queryOnPratiche = 'SELECT Id From Pratica__c WHERE Id IN :idPraticheTemp AND Stato__c = \'In Lavorazione\'';
        }

        idPratiche = new Set<Id>();
        for (Pratica__c p : (List<Pratica__c>) Database.query(queryOnPratiche)) {
            idPratiche.add(p.Id);
        }

        String query = 'SELECT Count(Id) TOT, ActivityExtended__r.Tipo__c TIPO, MAX(Giorni_di_completamento_attivita__c) GIORNI, ActivityExtended__r.Sotto_Tipo__c SOTTO, ActivityExtended__r.Owner_contratto__c OWNERCONTRATTO FROM Task WHERE ActivityExtended__r.id_attivita__c IN :setIdStrategie AND WhatId IN :idPratiche AND Status in (\'Non Iniziata\') AND ActivityExtended__r.id_affidamento__c = null ';

        if (selectedVisibility != null && String.isNotBlank(selectedVisibility) && selectedVisibility.equalsIgnoreCase('My_Task')) {
            query += 'AND ActivityExtended__r.Owner_contratto__c = \'' + currentUserName + '\' ';
        }

        query += 'GROUP BY ActivityExtended__r.Tipo__c,ActivityExtended__r.Sotto_Tipo__c,ActivityExtended__r.Owner_contratto__c';

        listAR = Database.query(query);

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
     /*       System.debug('QUERY TASK IS!!!!!!: '+queryTask);
            System.debug('TaskWhereClause IS!!!!!!: '+taskWhereClause);*/

        } else {
            taskWhereClause = 'WHERE ActivityExtended__r.id_attivita__c IN :setIdStrategie AND WhatId IN :idPratiche AND Status IN (\'Non Iniziata\') AND ActivityExtended__r.id_affidamento__c = null AND ActivityExtended__r.Owner_contratto__c = \'' + String.escapeSingleQuotes(ownerOne) + '\' AND ActivityExtended__r.Tipo_Sottotipo__c = \'' + String.escapeSingleQuotes(totalTipo) + '\' ';
            queryTask = 'SELECT Id,WhatId FROM Task ' + taskWhereClause;
            /*System.debug('QUERY TASK IS!!!!!!: '+queryTask);
            System.debug('TaskWhereClause IS!!!!!!: '+taskWhereClause);*/

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
                /*Alessio Massidda: ISSUE #41*/
                if (filter.indexOf(str) < (filter.size() - 1)) {
                    queryPratiche += ' AND ';
                }
                /** **/
            }
        }
        queryPratiche += ' ORDER BY Name ASC';
        stdCtrl = null;
        stdCtrl = new ApexPages.StandardSetController(Database.getQueryLocator(queryPratiche));
        // MSALA 20181211 - INIZIO
        if (stdCtrl.getResultSize() > 2000) {
            stdCtrl.setPageSize(2000);
        } else {
            stdCtrl.setPageSize(stdCtrl.getResultSize());
        }
        // MSALA 20181211 - FINE
        mapSelected = new Map<String, Boolean>();
        for (Pratica__c prat : (List<Pratica__c>) stdCtrl.getRecords()) {
            mapSelected.put(prat.Id, true);
        }
        // MSALA 20181211 - INIZIO
        while (stdCtrl.getHasNext()) {
            stdCtrl.next();
            for (Pratica__c prat : (List<Pratica__c>) stdCtrl.getRecords()) {
                mapSelected.put(prat.Id, true);
            }
        }
        // MSALA 20181211 - FINE
        stdCtrl.setPageSize(10);
        numSelected = stdCtrl.getResultSize();
        selAll = true;
        selPage = true;

        tipiAffido = new Set<String>();
        if(Utils.cebCheckObjPermission('Collector_con_Tipo_Affido__c',gd).get('ACCESS')
        && Utils.cebCheckFLSPermission('Collector_con_Tipo_Affido__c','Tipo_Affido__c',gd).get('ACCESS')) {
            //for (Collector_con_Tipo_Affido__c cta : [SELECT Tipo_Affido__c FROM Collector_con_Tipo_Affido__c WITH SECURITY_ENFORCED LIMIT 50000]) {
            for (Collector_con_Tipo_Affido__c cta : [SELECT Tipo_Affido__c FROM Collector_con_Tipo_Affido__c LIMIT 50000]) {
                if (cta.Tipo_Affido__c != null)
                    tipiAffido.add(cta.Tipo_Affido__c.toLowerCase());
            }
        }
        isAffido = (sotp != '' && String.isNotBlank(sotp) && tipiAffido.contains(sotp.toLowerCase())) ? true : false;
    }

    //Returns a list of Dossier Statuses stored in the input field of Mapping Status Pratica metadata record named as the input devName
    public static Set<String> getDossierStatusesList(String devName, String field) {
        List<String> statusesList = new List<String>();
        List<SObject> mappingStatusList = new List<SObject>();
        //String query = 'SELECT ' + String.escapeSingleQuotes(field) + ' FROM CRABB_DEV__mapping_status_pratica__mdt where DeveloperName =: devName WITH SECURITY_ENFORCED';
        String query = 'SELECT ' + String.escapeSingleQuotes(field) + ' FROM CRABB_DEV__mapping_status_pratica__mdt where DeveloperName =: devName';
        mappingStatusList = Database.query(query);
        if (mappingStatusList.size() > 0) {
            statusesList = String.valueOf(mappingStatusList.get(0).get(field)).split('\\|');
        }
        return new Set<String>(statusesList);
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

            if (p.getType() == Schema.DisplayType.STRING) {
                isString = true;
            } else if (p.getType() == Schema.DisplayType.DATE) {
                isDate = true;
            } else if (p.getType() == Schema.DisplayType.INTEGER) {
                isInteger = true;
            } else if (p.getType() == Schema.DisplayType.DOUBLE || p.getType() == Schema.DisplayType.CURRENCY) {
                isDouble = true;
            } else if (p.getType() == Schema.DisplayType.BOOLEAN) {
                isCheckbox = true;
            } else if (p.getType() == Schema.DisplayType.PICKLIST) {
                isPicklist = true;
                getPicklistInput();
            } else if (p.getType() == Schema.DisplayType.REFERENCE) {
                isObject = true;
            }
        } else {
            selField = '';
        }
    }

    public void getPicklistInput() {
        pkInputList = new List<SelectOption>();

        Schema.SObjectType targetType = gd.get('Pratica__c');
        if (targetType == null) {
            targetType = gd.get(Utils.NAMESPACE + 'Pratica__c');
            if (targetType == null) {
                targetType = gd.get(Utils.NAMESPACE + 'Pratica__c');
            }
        }

        SObject Object_name = targetType.newSObject();
        Schema.SObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(mapSchema.get(selectedPickValue).getFieldPath()).getDescribe().getPicklistValues();

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
                    String meseS = String.valueOf(dis.month());
                    if (meseS.length() == 1) {
                        meseS = '0' + meseS;
                    }
                    String giornoS = String.valueOf(dis.day());
                    if (giornoS.length() == 1) {
                        giornoS = '0' + giornoS;
                    }
                    newdis = dis.year() + '-' + meseS + '-' + giornoS;
                }

                if (dInputFinish != null) {
                    Date dif = Date.valueOf(dInputFinish);
                    String meseF = String.valueOf(dif.month());
                    if (meseF.length() == 1) {
                        meseF = '0' + meseF;
                    }
                    String giornoF = String.valueOf(dif.day());

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

    // public PageReference AffidaLista()
    // {
    //     Pagereference page=new PageReference('/apex/AffidamentiConfermaLotti?Type=');
    //     if(tipoesotto != null && String.isNotBlank(tipoesotto))
    //     {
    //     	if(tipoesotto.contains('_'))
    //         {
    //     		String stp = tipoesotto.split('_')[1];
    //     		page=new PageReference('/apex/AffidamentiConfermaLotti?Type='+stp);
    //     	}
    //     }

    //     Map<Id,Boolean> selectedPratiche = new Map<Id,Boolean>();
    //     for(String str : mapSelected.keySet())
    //     {
    //     	if(mapSelected.get(str))
    //         {
    //     		selectedPratiche.put(str, true);
    //     	}
    //     }

    //     String jsonmap = JSON.serialize(selectedPratiche);
    //     if(Utils.checkFLSPermission('Log__c', 'Integration_Json_file_data__c').get('CREATE'))
    //     {
    //         Log__c newLog = new Log__c(Integration_Json_file_data__c = jsonmap, info__c='#infojson');
    //         insert newLog;
    //         page.getParameters().put('idLog', newLog.Id);
    //     }
    //     page.getParameters().put('jsonmap',jsonmap);
    //     page.setRedirect(true);
    //     return page;
    // }

    public PageReference ConfermaLista() {
        List<Id> lPratDaElaborare = new List<Id>();
        for (String str : mapSelected.keySet()) {
            if (mapSelected.get(str)) {
                lPratDaElaborare.add(str);
            }
        }

        if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Scelta_utente__c', gd).get('ACCESS')) {
            String queryUPD = 'SELECT Id, Status, ActivityExtended__r.Scelta_utente__c FROM Task ' + taskWhereClause + ' AND WhatId IN :lPratDaElaborare';

            List<Task> taskUPD = new List<Task>();
            if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'SLA__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Count_of_Events__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Count_of_Tasks__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Giorni_Fuori_SLA__c', gd).get('ACCESS')) {
                taskUPD = Database.query(queryUPD);
            }
            Map<Id, ActivityExtended__c> task2Act = Utils.getTaskWithActivityExtended(taskUPD);
            List<ActivityExtended__c> aes = new List<ActivityExtended__c>();

            for (Task t : taskUPD) {
                System.debug('Esito:' + EsitoFinal);
                System.debug('Status before:' + t.Status);
                System.debug(mapEsiti.get(selectedEsitiPickValue));
                //if(EsitoFinal == 'Final')
                if (mapEsiti.get(selectedEsitiPickValue) == 'Final')
                    t.Status = 'Lavorata';
                System.debug('Status after:' + t.Status);

                ActivityExtended__c ae = task2Act.get(t.Id);
                if (ae != null) {
                    ae.Esito__c = selectedEsitiPickValue;
                    if (isLettera)
                        ae.Scelta_utente__c = letteraStr;

                    aes.add(ae);
                }
            }

            if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE') &&
                    Utils.cebCheckFLSPermission('ActivityExtended__c', 'Scelta_utente__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Esito__c', gd).get('UPDATE')) {
                update aes;
            }
            //if (Utils.checkFLSPermission('Task', 'Status').get('UPDATE')) update taskUPD;
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

    public PageReference backTo() {
        //PageReference pg = new Pagereference('/apex/RiepilogoTask');
        PageReference pg = new PageReference('/apex/Esiti_Massivi');
        pg.setRedirect(true);
        return pg;
    }

    public PageReference homePage() {
        return new PageReference('/');
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