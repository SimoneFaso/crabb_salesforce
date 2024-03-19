/* ---------------------------------------------------------------------------------------------------------------------
Name:            CrabbEsitiMassiviCtrl.cls
Description:     Controller for crabbEsitiMassivi LWC
Test class:

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
05-Aug-2020  0.1      Matteo Sala          First Version
05-Aug-2021  0.2      Giulia Mameli        Added statiPratica list  and getStatusesList method to dynamically filter
                                           Dossiers on queries
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class CrabbEsitiMassiviCtrl {

    private static final Set<String> statiPratica = getDossierStatusesList('EsitiMassivi', 'CRABB_DEV__stati_in_lavorazione__c');

    @AuraEnabled(Cacheable=true)
    public static EsitiMassiviWrapperOutput getActivityExtendedData(String selectedVisibility , Integer limitData , Integer offsetData) {
        EsitiMassiviWrapperOutput out = new EsitiMassiviWrapperOutput();
        EsitiMassiviProfile__c currentAS = EsitiMassiviProfile__c.getInstance(UserInfo.getProfileId());
        Set<String> splitSotto = new Set<String>();
        Set<String> tipoSet = new Set<String>();
        Set<String> sottoSet = new Set<String>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        String queryOnPratiche;
        out.mapSottoDisabled = new Map<String, Boolean>();
        out.idPratiche = new Set<Id>();
        Map<String, String> mapEsiti = new Map<String, String>();
        if (currentAS != null) {
            splitSotto.addAll(currentAS.Sottotipo__c.split(';'));
        }
        String currentUserName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        out.mapTipoTotal = new Map<String, Integer>();
        out.mapTipoOldest = new Map<String, Decimal>();

        List<Strategia__c> listStrategie = Database.query('SELECT ' + Utils.getSOBJECTFieldsForQuery('Strategia__c') + ' FROM Strategia__c WHERE Recordtype.Name = \'Step\' AND Tipologia__c = \'UI\' AND Stato_testata__c = \'Attiva\'');
        Set<Id> setIdStrategie = new Set<Id>();
        for (Strategia__c strat : listStrategie) {
            setIdStrategie.add(strat.Id);
        }

        String queryOnTasks = 'SELECT Id, WhatId FROM Task WHERE ActivityExtended__r.id_attivita__c IN :setIdStrategie AND Status =\'Non Iniziata\' AND ActivityExtended__r.id_affidamento__c = null LIMIT '+ limitData + ' OFFSET '+offsetData;
        Set<Id> idPraticheTemp = new Set<Id>();
        for (Task t : (List<Task>) Database.query(queryOnTasks)) {
            idPraticheTemp.add(t.WhatId);
        }

        if(statiPratica.size() > 0 ) {
            queryOnPratiche = 'SELECT Id FROM Pratica__c WHERE Id IN :idPraticheTemp AND Stato__c IN : statiPratica';
        } else {
            queryOnPratiche='SELECT Id From Pratica__c WHERE Id IN :idPraticheTemp AND Stato__c = \'In Lavorazione\'';
        }

        for (Pratica__c p : (List<Pratica__c>) Database.query(queryonPratiche)) {
            out.idPratiche.add(p.Id);
        }
        Set<Id> idPratiche = out.idPratiche;
        String query = 'SELECT Count(Id) TOT,ActivityExtended__r.Tipo__c TIPO,MAX(Giorni_di_completamento_attivita__c) GIORNI,ActivityExtended__r.Sotto_Tipo__c SOTTO,ActivityExtended__r.Owner_contratto__c OWNERCONTRATTO FROM Task WHERE ActivityExtended__r.id_attivita__c IN :setIdStrategie AND WhatId IN :idPratiche AND Status in (\'Non Iniziata\') AND ActivityExtended__r.id_affidamento__c = null ';

        if (selectedVisibility != null && String.isNotBlank(selectedVisibility) && selectedVisibility.equalsIgnoreCase('My_Task')) {
            query += 'AND ActivityExtended__r.Owner_contratto__c = \'' + currentUserName + '\' ';
        }

        query += 'GROUP BY ActivityExtended__r.Tipo__c,ActivityExtended__r.Sotto_Tipo__c,ActivityExtended__r.Owner_contratto__c';

        List<AggregateResult> listAR = Database.query(query);


        out.mapWrapper = new Map<String, List<ARWrapper>>();
        if (listAR != null && !listAR.isEmpty()) {
            for (AggregateResult ar : listAR) {
                String tipo = ((String) ar.get('TIPO') == null || String.isBlank((String) ar.get('TIPO'))) ? '' : (((String) ar.get('TIPO')).equalsIgnoreCase('NA')) ? '' : (String) ar.get('TIPO');
                String sotto = ((String) ar.get('SOTTO') == null || String.isBlank((String) ar.get('SOTTO'))) ? '' : (((String) ar.get('SOTTO')).equalsIgnoreCase('NA')) ? '' : (String) ar.get('SOTTO');
                String owner = ((String) ar.get('OWNERCONTRATTO') != null && String.isNotBlank((String) ar.get('OWNERCONTRATTO'))) ? (String) ar.get('OWNERCONTRATTO') : '';

                tipoSet.add(tipo);
                sottoSet.add(sotto);

                String tiposotto = (sotto != null && String.isNotBlank(sotto)) ? tipo + '_' + sotto : tipo;

                if (splitSotto.contains(sotto) || sotto == '') {
                    out.mapSottoDisabled.put(tiposotto, false);
                } else {
                    out.mapSottoDisabled.put(tiposotto, true);
                }

                if (!out.mapWrapper.containsKey(tiposotto)) {
                    List<ARWrapper> temparw = new List<ARWrapper>();
                    ARWrapper arw = new ARWrapper(sotto, owner, (Integer) ar.get('TOT'), (Decimal) ar.get('GIORNI'));
                    temparw.add(arw);
                    out.mapWrapper.put(tiposotto, temparw);
                } else {
                    List<ARWrapper> temparw = out.mapWrapper.get(tiposotto);
                    temparw.add(new ARWrapper(sotto, owner, (Integer) ar.get('TOT'), (Decimal) ar.get('GIORNI')));
                    out.mapWrapper.put(tiposotto, temparw);
                }

                if (!out.mapTipoTotal.containsKey(tiposotto)) {
                    out.mapTipoTotal.put(tiposotto, (Integer) ar.get('TOT'));
                } else {
                    Integer tempTot = out.mapTipoTotal.get(tiposotto);
                    out.mapTipoTotal.put(tiposotto, tempTot + (Integer) ar.get('TOT'));
                }

                if (!out.mapTipoOldest.containsKey(tiposotto)) {
                    out.mapTipoOldest.put(tiposotto, (Decimal) ar.get('GIORNI'));
                } else {
                    Decimal tempDec = out.mapTipoOldest.get(tiposotto);
                    if ((Decimal) ar.get('GIORNI') > tempDec) {
                        out.mapTipoOldest.put(tiposotto, (Decimal) ar.get('GIORNI'));
                    }
                }
            }
        }

        return out;

    }

    @AuraEnabled
    public static EsitiMassiviWrapperOutput createObjects(String selectedVisibility) {
        String currentUserName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        EsitiMassiviWrapperOutput out = new EsitiMassiviWrapperOutput();
        out.mapTipoTotal = new Map<String, Integer>();
        out.mapTipoOldest = new Map<String, Decimal>();
        out.mapSottoDisabled = new Map<String, Boolean>();
        Set<String> splitSotto = new Set<String>();
        List<Strategia__c> listStrategie = Database.query('SELECT ' + Utils.getSOBJECTFieldsForQuery('Strategia__c') + ' FROM Strategia__c WHERE Recordtype.Name = \'Step\' AND Tipologia__c = \'UI\' AND Stato_testata__c = \'Attiva\'');
        out.setIdStrategie = new Set<Id>();
        for (Strategia__c strat : listStrategie) {
            out.setIdStrategie.add(strat.Id);
        }

        String queryOnTasks = 'SELECT Id, WhatId FROM Task WHERE ActivityExtended__r.id_attivita__c IN :setIdStrategie AND Status =\'Non Iniziata\' AND ActivityExtended__r.id_affidamento__c = null';
        Set<Id> idPraticheTemp = new Set<Id>();
        for (Task t : (List<Task>) Database.query(queryOnTasks)) {
            idPraticheTemp.add(t.WhatId);
        }

        //String queryonPratiche='SELECT Id From Pratica__c WHERE Id IN :idPraticheTemp AND Stato__c IN (\'Affidata\',\'In Lavorazione\')';

        String queryonPratiche = 'SELECT Id From Pratica__c WHERE Id IN :idPraticheTemp AND Stato__c IN : statiPratica';

        out.idPratiche = new Set<Id>();
        for (Pratica__c p : (List<Pratica__c>) Database.query(queryonPratiche)) {
            out.idPratiche.add(p.Id);
        }

        String query = 'SELECT Count(Id) TOT,ActivityExtended__r.Tipo__c TIPO,MAX(Giorni_di_completamento_attivita__c) GIORNI,ActivityExtended__r.Sotto_Tipo__c SOTTO,ActivityExtended__r.Owner_contratto__c OWNERCONTRATTO FROM Task WHERE ActivityExtended__r.id_attivita__c IN :setIdStrategie AND WhatId IN :idPratiche AND Status in (\'Non Iniziata\') AND ActivityExtended__r.id_affidamento__c = null ';

        if (selectedVisibility != null && String.isNotBlank(selectedVisibility) && selectedVisibility.equalsIgnoreCase('My_Task')) {
            query += 'AND ActivityExtended__r.Owner_contratto__c = \'' + currentUserName + '\' ';
        }

        query += 'GROUP BY ActivityExtended__r.Tipo__c,ActivityExtended__r.Sotto_Tipo__c,ActivityExtended__r.Owner_contratto__c';

        List<AggregateResult> listAR = Database.query(query);

        Set<String> tipoSet = new Set<String>();
        Set<String> sottoSet = new Set<String>();
        Map<String, List<ARWrapper>> mapWrapper = new Map<String, List<ARWrapper>>();

        if (listAR != null && !listAR.isEmpty()) {
            for (AggregateResult ar : listAR) {
                String tipo = ((String) ar.get('TIPO') == null || String.isBlank((String) ar.get('TIPO'))) ? '' : (((String) ar.get('TIPO')).equalsIgnoreCase('NA')) ? '' : (String) ar.get('TIPO');
                String sotto = ((String) ar.get('SOTTO') == null || String.isBlank((String) ar.get('SOTTO'))) ? '' : (((String) ar.get('SOTTO')).equalsIgnoreCase('NA')) ? '' : (String) ar.get('SOTTO');
                String owner = ((String) ar.get('OWNERCONTRATTO') != null && String.isNotBlank((String) ar.get('OWNERCONTRATTO'))) ? (String) ar.get('OWNERCONTRATTO') : '';

                tipoSet.add(tipo);
                sottoSet.add(sotto);

                String tiposotto = (sotto != null && String.isNotBlank(sotto)) ? tipo + '_' + sotto : tipo;

                if (splitSotto.contains(sotto) || sotto == '') {
                    out.mapSottoDisabled.put(tiposotto, false);
                } else {
                    out.mapSottoDisabled.put(tiposotto, true);
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

                if (!out.mapTipoTotal.containsKey(tiposotto)) {
                    out.mapTipoTotal.put(tiposotto, (Integer) ar.get('TOT'));
                } else {
                    Integer tempTot = out.mapTipoTotal.get(tiposotto);
                    out.mapTipoTotal.put(tiposotto, tempTot + (Integer) ar.get('TOT'));
                }

                if (!out.mapTipoOldest.containsKey(tiposotto)) {
                    out.mapTipoOldest.put(tiposotto, (Decimal) ar.get('GIORNI'));
                } else {
                    Decimal tempDec = out.mapTipoOldest.get(tiposotto);
                    if ((Decimal) ar.get('GIORNI') > tempDec) {
                        out.mapTipoOldest.put(tiposotto, (Decimal) ar.get('GIORNI'));
                    }
                }
            }
        }
        return out;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Report> getReportList() {
        return [SELECT Id, Name,DeveloperName FROM Report WHERE Format = 'Tabular' WITH SECURITY_ENFORCED ];
    }

    @AuraEnabled(Cacheable=true)
    public static List<ListView> getDossierListView() {
        return [SELECT Id, Name,DeveloperName FROM ListView WHERE SobjectType = 'CRABB_DEV__Pratica__c' WITH SECURITY_ENFORCED ];
    }

    @AuraEnabled(Cacheable=true)
    public static List<Map<String, String>> getEsitiPickListValues(String tipoesotto) {
        List<Map<String, String>> EsitipicklistValues = new List<Map<String, String>>();
        EsitipicklistValues.add(new Map<String, String>{
                '' => '--- Select one ---'
        });
        EsitipicklistValues.add(new Map<String, String>{
                'Nessun Esito' => 'Nessun Esito'
        });

        Esiti_Massivi__mdt[] EM = [SELECT Allowed_Outcomes__c, Allowed_Final_Outcomes__c, Allowed_Partial_Outcomes__c
        FROM Esiti_Massivi__mdt WHERE Tipo_Sottotipo__c = :tipoesotto WITH SECURITY_ENFORCED ];
        List<String> ls = new List<String>();

        Map<String, String> mapEsiti = new Map<String, String>();
        mapEsiti.put('', 'Partial');
        mapEsiti.put('Nessun Esito', 'Partial');

        if (EM.size() > 0) {
            ls = EM[0].Allowed_Outcomes__c.split(';');
            // for(String s : ls)
            // {
            //    EsitipicklistValues.add(new SelectOption(s, s));
            // }

            //selectedEsitiPickValue = 'Nessun Esito';
            for (Esiti_Massivi__mdt r : EM) {
                if (r.Allowed_Final_Outcomes__c != null && r.Allowed_Final_Outcomes__c != '') {
                    for (String finalV : (r.Allowed_Final_Outcomes__c).split(';')) {
                        mapEsiti.put(finalV, 'Final');
                        EsitipicklistValues.add(new Map<String, String>{
                                finalV => finalV
                        });
                    }
                }
                if (r.Allowed_Partial_Outcomes__c != null && r.Allowed_Partial_Outcomes__c != '') {
                    for (String partialV : (r.Allowed_Partial_Outcomes__c).split(';')) {
                        mapEsiti.put(partialV, 'Partial');
                        EsitipicklistValues.add(new Map<String, String>{
                                partialV => partialV
                        });
                    }
                }
            }
        }

        return EsitipicklistValues;
    }

    @AuraEnabled
    public static EsitiMassiviWrapperOutput createStepOne(String tipoesotto, String ownerOne, List<String> idPratiche) {
        EsitiMassiviWrapperOutput out = new EsitiMassiviWrapperOutput();
        Boolean isLettera = false;
        String letteraStr = '';
        //currentStep = '1';
        /*picklistValues = new List<SelectOption>();
        picklistValues.add(new SelectOption('', '--- Select one ---'));
        mapSchema = new Map<String, Schema.FieldSetMember>();
        searchFields = new List<String>();
        for(Schema.FieldSetMember f : SObjectType.Pratica__c.FieldSets.Filtro_Lavorazione_Task.getFields())
        {
            searchFields.add(f.getFieldPath());
            mapSchema.put(f.getFieldPath(), f);

            picklistValues.add(new SelectOption(f.getFieldPath(), f.getLabel()));
        }*/

        //tipoesotto = (ApexPages.currentPage().getParameters().get('tipoesotto') != null && String.isNotBlank(ApexPages.currentPage().getParameters().get('tipoesotto'))) ? ApexPages.currentPage().getParameters().get('tipoesotto') :
        // (tipoesotto != null && String.isNotBlank(tipoesotto)) ? tipoesotto : '';
        //ownerOne = (ApexPages.currentPage().getParameters().get('owner') != null && String.isNotBlank(ApexPages.currentPage().getParameters().get('owner'))) ? ApexPages.currentPage().getParameters().get('owner') :
        //(ownerOne != null && String.isNotBlank(ownerOne)) ? ownerOne : '';
        List<Strategia__c> listStrategie = Database.query('SELECT ' + Utils.getSOBJECTFieldsForQuery('Strategia__c') +
                ' FROM Strategia__c WHERE Recordtype.Name = \'Step\' AND Tipologia__c = \'UI\' AND Stato_testata__c = \'Attiva\'');
        out.setIdStrategie = new Set<Id>();
        for (Strategia__c strat : listStrategie) {
            out.setIdStrategie.add(strat.Id);
        }
        String tip = (tipoesotto.contains('_')) ? tipoesotto.split('_')[0] : '';

        if (tip.equalsIgnoreCase('Invio AR') || tip.equalsIgnoreCase('Invio Lettera di Posta Prioritaria Standard')) {
            isLettera = true;
            letteraStr = tip;
        }

        String sotp = (tipoesotto.contains('_')) ? tipoesotto.split('_')[1] : '';

        String totalTipo = (tipoesotto.contains('_')) ? tipoesotto.replace('_', ' ') : tipoesotto;
        String queryTask = '';
        String taskWhereClause = '';
        Set<Id> setIdStrategie = out.setIdStrategie;
        if (ownerOne != null && ownerOne.equalsIgnoreCase('all')) {
            taskWhereClause = 'WHERE ActivityExtended__r.id_attivita__c IN :setIdStrategie AND WhatId IN :idPratiche AND Status IN (\'Non Iniziata\') AND ActivityExtended__r.id_affidamento__c = null AND ActivityExtended__r.Tipo_Sottotipo__c = \'' + String.escapeSingleQuotes(totalTipo) + '\' ';
            queryTask = 'SELECT Id,WhatId FROM Task ' + taskWhereClause;
        } else {
            taskWhereClause = 'WHERE ActivityExtended__r.id_attivita__c IN :setIdStrategie AND WhatId IN :idPratiche AND Status IN (\'Non Iniziata\') AND ActivityExtended__r.id_affidamento__c = null AND ActivityExtended__r.Owner_contratto__c = \'' + String.escapeSingleQuotes(ownerOne) + '\' AND ActivityExtended__r.Tipo_Sottotipo__c = \'' + String.escapeSingleQuotes(totalTipo) + '\' ';
            queryTask = 'SELECT Id,WhatId FROM Task ' + taskWhereClause;
        }

        List<Task> tasklist = (List<Task>) Database.query(queryTask);

        Set<Id> idprats = new Set<Id>();
        for (Task t : tasklist) {
            idprats.add(t.WhatId);
        }

        String queryPratiche = 'SELECT ' + String.escapeSingleQuotes(Utils.getSOBJECTFieldsForQuery('Pratica__c')) + ' ,Servizio_Fornitura__r.LookupContratto__r.Id_Esterno__c, Strategia__r.Nome__c, Servizio_Fornitura__r.RecordType.Name, Servizio_Fornitura__r.LookupContratto__r.Comune__c, Servizio_Fornitura__r.Codice__c, Account__r.Classe_di_Rischio__c, Account__r.Name FROM Pratica__c WHERE Stato__c NOT IN (\'Bloccata\',\'Bloccata Manualmente\') AND Id IN :idprats ';

        queryPratiche += ' ORDER BY Name ASC';
        List<CRABB_DEV__Pratica__c> praticheList = (List<CRABB_DEV__Pratica__c>) Database.query(queryPratiche);
        out.praticheList = praticheList;

        // MSALA 20181211 - FINE


        /*tipiAffido = new Set<String>();
        for(Collector_con_Tipo_Affido__c cta : [SELECT Tipo_Affido__c FROM Collector_con_Tipo_Affido__c LIMIT 50000])
        {
            if(cta.Tipo_Affido__c != null)
                tipiAffido.add(cta.Tipo_Affido__c.tolowercase());
        }

        isAffido = (sotp != '' && String.isNotBlank(sotp) && tipiAffido.contains(sotp.toLowerCase())) ? true : false;*/
        return out;
    }

    @AuraEnabled
    public static String ConfermaLista(List<Id> lPratDaElaborare, String ownerOne, String selectedEsitiPickValue, String tipoesotto) {

        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        /*List<Id> lPratDaElaborare = new List<Id>();
        for(String str : mapSelected.keySet())
        {
            if(mapSelected.get(str))
            {
                lPratDaElaborare.add(str);
            }
        }*/
        String totalTipo = (tipoesotto.contains('_')) ? tipoesotto.replace('_', ' ') : tipoesotto;
        String tip = (tipoesotto.contains('_')) ? tipoesotto.split('_')[0] : '';
        Boolean isLettera = false;
        String letteraStr = tip;
        if (tip.equalsIgnoreCase('Invio AR') || tip.equalsIgnoreCase('Invio Lettera di Posta Prioritaria Standard')) {
            isLettera = true;
            letteraStr = tip;
        }
        Set<Id> setIdStrategie = new Set<Id>();
        List<Strategia__c> listStrategie = Database.query('SELECT ' + Utils.getSOBJECTFieldsForQuery('Strategia__c') +
                ' FROM Strategia__c WHERE Recordtype.Name = \'Step\' AND Tipologia__c = \'UI\' AND Stato_testata__c = \'Attiva\'');

        for (Strategia__c strat : listStrategie) {
            setIdStrategie.add(strat.Id);
        }
        String taskWhereClause = '';
        if (ownerOne != null && ownerOne.equalsIgnoreCase('all')) {
            taskWhereClause = 'WHERE ActivityExtended__r.id_attivita__c IN :setIdStrategie AND WhatId IN :idPratiche AND Status IN (\'Non Iniziata\') AND ActivityExtended__r.id_affidamento__c = null AND ActivityExtended__r.Tipo_Sottotipo__c = \'' + String.escapeSingleQuotes(totalTipo) + '\' ';

        } else {
            taskWhereClause = 'WHERE ActivityExtended__r.id_attivita__c IN :setIdStrategie AND WhatId IN :idPratiche AND Status IN (\'Non Iniziata\') AND ActivityExtended__r.id_affidamento__c = null AND ActivityExtended__r.Owner_contratto__c = \'' + String.escapeSingleQuotes(ownerOne) + '\' AND ActivityExtended__r.Tipo_Sottotipo__c = \'' + String.escapeSingleQuotes(totalTipo) + '\' ';

        }

        if (Utils.cebCheckObjPermission('Task',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Scelta_utente__c',gd).get('ACCESS')) {
            String queryUPD = 'SELECT Id, Status, ActivityExtended__r.Scelta_utente__c FROM Task ' + taskWhereClause + ' AND WhatId IN :lPratDaElaborare';

            List<Task> taskUPD = new List<Task>();
            if (Utils.cebCheckObjPermission('Task',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'SLA__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Count_of_Events__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Count_of_Tasks__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Giorni_Fuori_SLA__c',gd).get('ACCESS')) {
                taskUPD = (List<Task>) Database.query(queryUPD);
            }
            Map<Id, ActivityExtended__c> task2obj = Utils.getTaskWithActivityExtended(taskUPD);
            List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
            Map<String, String> mapEsiti = getMapEsiti(tipoesotto);
            for (Task t : taskUPD) {
                //System.debug('Esito:' + EsitoFinal);
                System.debug('Status before:' + t.Status);
                System.debug(mapEsiti.get(selectedEsitiPickValue));
                //if(EsitoFinal == 'Final')
                if (mapEsiti.get(selectedEsitiPickValue) == 'Final')
                    t.Status = 'Lavorata';
                System.debug('Status after:' + t.Status);

                ActivityExtended__c ae = task2obj.get(t.Id);
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
            Id batchId = Database.executeBatch(new BatchElaboraPratiche(taskUPD), 20);
            AsyncApexJob aaj = [SELECT Id,Status,ExtendedStatus,CompletedDate,CreatedDate,TotalJobItems,JobItemsProcessed FROM AsyncApexJob WHERE Id = :batchId LIMIT 1];
            String currentStep = '2';
            Boolean batchRunning = true;
            Integer countTask = taskUPD.size();
        }
        return null;
    }

    @AuraEnabled
    public static void ConfermaLista2(List<Id> lPratDaElaborare) {
        system.debug('ConfermaLista Pratiche da elaborare');
        for(Id idPratica : lPratDaElaborare) {
            System.debug('ConfermaLista --> ' + idPratica);
        }
    }

    private static Map<String, String> getMapEsiti(String tipoesotto) {
        Esiti_Massivi__mdt[] EM = [SELECT Allowed_Outcomes__c, Allowed_Final_Outcomes__c, Allowed_Partial_Outcomes__c
        FROM Esiti_Massivi__mdt
        WHERE Tipo_Sottotipo__c = :tipoesotto
        WITH SECURITY_ENFORCED];
        List<String> ls = new List<String>();

        Map<String, String> mapEsiti = new Map<String, String>();
        mapEsiti.put('', 'Partial');
        mapEsiti.put('Nessun Esito', 'Partial');

        if (EM.size() > 0) {
            ls = EM[0].Allowed_Outcomes__c.split(';');
            // for(String s : ls)
            // {
            //    EsitipicklistValues.add(new SelectOption(s, s));
            // }

            //selectedEsitiPickValue = 'Nessun Esito';
            for (Esiti_Massivi__mdt r : EM) {
                if (r.Allowed_Final_Outcomes__c != null && r.Allowed_Final_Outcomes__c != '') {
                    for (String finalV : (r.Allowed_Final_Outcomes__c).split(';')) {
                        mapEsiti.put(finalV, 'Final');

                    }
                }
                if (r.Allowed_Partial_Outcomes__c != null && r.Allowed_Partial_Outcomes__c != '') {
                    for (String partialV : (r.Allowed_Partial_Outcomes__c).split(';')) {
                        mapEsiti.put(partialV, 'Partial');

                    }
                }
            }
        }
        return mapEsiti;
    }

    /** Sostituito **/
    /*@AuraEnabled(Cacheable=true)
    public static List<CRABB_DEV__Pratica__c> getQueryListRows(String query , Integer limitClause , Integer offsetClause ) {
        query += ' LIMIT ' + limitClause + ' OFFSET '+ offsetClause;
        System.debug('Query rows ' + query);
        List<CRABB_DEV__Pratica__c> res = Database.query(query );
        return res;

    }*/

    @AuraEnabled(Cacheable=true)
    public static List<CRABB_DEV__Pratica__c> getQueryListRows(String query , Integer limitClause , Integer offsetClause, String offsetValue ) {
        System.debug('getQueryListRows - START');
        System.debug('getQueryListRows - offsetClause -> ' + offsetClause);
        System.debug('getQueryListRows - limitClause -> ' + limitClause);
        System.debug('getQueryListRows - QUERY -> ' + query);

        String fieldsQuery = '';
        String objectQuery = '';
        String whereConditions = '';
        String oldOrderBy = '';

        Pattern r = Pattern.compile('SELECT (.*) FROM (.*) WHERE (.*) ORDER BY (.*)');
        Matcher rm = r.matcher(query);
        if (rm.find()) {
            fieldsQuery = rm.group(1);
            objectQuery = rm.group(2);
            whereConditions = rm.group(3);
            oldOrderBy = rm.group(4);
        }

        String newWhereConditions = whereConditions != null ? ' WHERE ' + whereConditions + ' AND Name > \'' + offsetValue + '\'': objectQuery + ' WHERE Name >  \'' + offsetValue + '\'';
        String newOrderBy = oldOrderBy.replace(rm.group(4), 'Name ASC');

        String newQuery = 'SELECT ' + fieldsQuery + ' FROM ' + objectQuery + ' ' + newWhereConditions + ' ORDER BY ' + newOrderBy + ' LIMIT ' + limitClause;

        //query += ' AND Name > ' + offsetValue + ' ORDER BY Name LIMIT ' + limitClause;
        //query += ' LIMIT ' + limitClause + ' OFFSET '+ offsetClause;

        System.debug('Query rows ' + newQuery);
        List<CRABB_DEV__Pratica__c> res = Database.query(String.escapeSingleQuotes(newQuery));
        return res;

    }

    @AuraEnabled(Cacheable=true)
    public static Integer countQueryListViewRows(String query) {
        Integer cont = 0;
        Pattern r = Pattern.compile('SELECT (.*) FROM (.*) WHERE (.*) ORDER BY (.*)');
        Matcher rm = r.matcher(query);
        String textToReplace = '';
        if (rm.find()) {
            System.debug(' match Comment 1' + rm.group(1));
            System.debug(' match Comment 2' + rm.group(2));
            System.debug(' match Comment 3' + rm.group(3));
            System.debug(' match Comment 4' + rm.group(4));
            textToReplace = rm.group(1);
            //imgMapFeed.put(  String.valueOf(feedCont) + '_'+contComment , rm.group(1));
        }
        String countQuery = query.replace(textToReplace, ' count(Id) ');
        if (countQuery.contains('ORDER BY')) {
            countQuery = countQuery.substring(0, countQuery.indexOf('ORDER BY'));
        }
        System.debug('Query count rows ' + countQuery);
        List<AggregateResult> res = Database.query(countQuery);

        cont = (Integer) res.get(0).get('expr0');
        System.debug('Number for query rows -> ' + cont);
        return cont;

    }

    @AuraEnabled(Cacheable=true)
    public static String getQueryListView(String listViewId) {
        HttpRequest req = new HttpRequest();
        String query = '';
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String endPoinURL = baseUrl + '/services/data/v50.0/sobjects/CRABB_DEV__Pratica__c/listviews/' + listViewId + '/describe';
        req.setEndpoint(endPoinURL);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + fetchUserSessionId());
        Http http = new Http();
        HttpResponse response = http.send(req);
        if (response.getStatusCode() == 200) {
            Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            query = (String) tokenResponse.get('query');

        }
        //query = query.replaceFirst('SELECT ', 'SELECT Id ,');
        System.debug(query);
        return query;
    }

    public static String fetchUserSessionId() {
        String sessionId = '';
        // Refer to the Page
        PageReference reportPage = Page.CRABB_DEV__SessionId;
        // Get the content of the VF page
        String vfContent = reportPage.getContent().toString();
        System.debug('vfContent ' + vfContent);
        // Find the position of Start_Of_Session_Id and End_Of_Session_Id
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                endP = vfContent.indexOf('End_Of_Session_Id');
        // Get the Session Id
        sessionId = vfContent.substring(startP, endP);
        System.debug('sessionId ' + sessionId);
        // Return Session Id
        return sessionId;
    }

    //Returns a list of Dossier Statuses stored in the input field of Mapping Status Pratica metadata record named as the input devName
    public static Set<String> getDossierStatusesList(String devName, String field) {
        List<String> statusesList = new List<String>();
        List<SObject> mappingStatusList = new List<SObject>();
        String query = 'SELECT ' + String.escapeSingleQuotes(field) + ' FROM CRABB_DEV__mapping_status_pratica__mdt where DeveloperName =: devName WITH SECURITY_ENFORCED';
        mappingStatusList = Database.query(query);
        if(mappingStatusList.size() > 0) {
            statusesList = String.valueOf(mappingStatusList.get(0).get(field)).split('\\|');
        }
        return new Set<String>(statusesList);
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String,String> getMapEsitiFinal(String tipoesotto) {
        Map<String, String> mapEsiti = getMapEsiti(tipoesotto);
        return mapEsiti;
    }

    public class EsitiMassiviWrapperOutput {
        @AuraEnabled
        public Map<String, List<ARWrapper>> mapWrapper { get; set; }
        @AuraEnabled
        public Map<String, Boolean> mapSottoDisabled { get; set; }
        @AuraEnabled
        public Map<String, Integer> mapTipoTotal { get; set; }
        @AuraEnabled
        public Map<String, Decimal> mapTipoOldest { get; set; }
        @AuraEnabled
        public Set<Id> setIdStrategie { get; set; }
        @AuraEnabled
        public Set<Id> idPratiche { get; set; }
        @AuraEnabled
        public List<CRABB_DEV__Pratica__c> praticheList { get; set; }
    }

    public class ARWrapper {
        @AuraEnabled
        public String sottotipo { get; set; }
        @AuraEnabled
        public String owner { get; set; }
        @AuraEnabled
        public Integer totCount { get; set; }
        @AuraEnabled
        public Decimal giorni { get; set; }

        public ARWrapper(String s, String o, Integer c, Decimal g) {
            sottotipo = s;
            owner = o;
            totCount = c;
            giorni = g;
        }
    }
}