/* ---------------------------------------------------------------------------------------------------------------------
Name:            CrabbEsitiMassiviLngCtrl.cls
Description:     Controller for crabbEsitiMassiviLng LWC
Test class:

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
28-Sep-2021  0.1      Matteo Sala          First Version
19-Sep-2022  0.2      C.Sanna              Modified default outcomes "Nessun Esito" and " " on mapEsiti. Is it possible to
                                           proceed without those outcome, based on the value of CS Tag__c
                                           Record - SkipNessunEsitoEsitazioneMassiva.
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class CrabbEsitiMassiviLngCtrl
{
    private static final Set<String> statiPratica = getDossierStatusesList('EsitiMassivi', 'CRABB_DEV__stati_in_lavorazione__c');

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

    /*public static String fetchUserSessionId() {
        String sessionId = '';
        // Refer to the Page
        PageReference reportPage = Page.CRABB_DEV__SessionId;
        // Get the content of the VF page
        String vfContent;
        try{
            vfContent = reportPage.getContent().toString();
        } catch(Exception e) {
            //insert for test class
            vfContent = 'Start_Of_Session_IdSessionIDEnd_Of_Session_Id';
        }
        System.debug('vfContent ' + vfContent);
        // Find the position of Start_Of_Session_Id and End_Of_Session_Id
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                endP = vfContent.indexOf('End_Of_Session_Id');
        // Get the Session Id
        sessionId = vfContent.substring(startP, endP);
        System.debug('sessionId ' + sessionId);
        // Return Session Id
        return sessionId;
    }*/

    /*@AuraEnabled(Cacheable=true)
    public static String getQueryListView(String listViewId, String TipoSottotipo) {
        String newTipoSottotipo = TipoSottotipo.contains('_') ? TipoSottotipo.replace('_', ' ') : TipoSottotipo;
        HttpRequest req = new HttpRequest();
        String query = '';
        String baseUrl = Url.getSalesforceBaseUrl().toExternalForm();
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
        query = modifyQuery(query, newTipoSottotipo);

        System.debug(query);
        return query;
    }*/

    @AuraEnabled(Cacheable=true)
    public static String getQueryListView(String listViewId, String TipoSottotipo) {
        String newTipoSottotipo = TipoSottotipo.contains('_') ? TipoSottotipo.replace('_', ' ') : TipoSottotipo;
        HttpRequest req = new HttpRequest();
        String query = '';
        req.setEndpoint('callout:Crabb_Bulk_Activities/services/data/v50.0/sobjects/CRABB_DEV__Pratica__c/listviews/' + listViewId + '/describe');
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(req);
        if (response.getStatusCode() == 200) {
            Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            query = (String) tokenResponse.get('query');

        }
        //query = query.replaceFirst('SELECT ', 'SELECT Id ,');
        query = modifyQuery(query, newTipoSottotipo);

        System.debug(query);
        return query;
    }

    private static List<Id> DossierList(String TipoSottotipo)
    {
        Map<String, SObjectType> gd = Schema.getGlobalDescribe();
        List<Id> lPratId = new List<Id>();
        /*
        if(Utils.cebCheckFLSPermission('Task', 'WhatId', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'CRABB_DEV__ActivityExtended__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Status', gd).get('ACCESS')) { */
            for (Task t : [SELECT WhatId FROM Task
            WHERE CRABB_DEV__ActivityExtended__r.CRABB_DEV__Tipo_Sottotipo__c = : TipoSottotipo AND Status = 'Non iniziata'
            WITH SECURITY_ENFORCED ])
            {
                lPratId.add(t.WhatId);
            }


        return lPratId;
    }

    private static String modifyQuery(String query, String TipoSottotipo)
    {
        List<Id> lPratId = DossierList(TipoSottotipo);

        Pattern r = Pattern.compile('SELECT (.*) FROM (.*) WHERE (.*) ORDER BY (.*)');
        Pattern r2 = Pattern.compile('SELECT (.*) FROM (.*) ORDER BY (.*)');
        Pattern r3 = Pattern.compile('SELECT (.*) FROM (.*) WHERE (.*)');
        Pattern r4 = Pattern.compile('SELECT (.*) FROM (.*)');
        Matcher rm = r.matcher(query);
        Matcher rm2 = r2.matcher(query);
        Matcher rm3 = r3.matcher(query);
        Matcher rm4 = r4.matcher(query);
        String textToReplace = '';
        String resultQuery = '';
        String whereClause = '';

        if (rm.find()) {
            textToReplace = rm.group(3);
            whereClause = rm.group(3) + ' AND Stato__c in :statiPratica';
            if(lPratId.size()>0)
                whereClause += ' AND Id IN :lPratId' ;
            else
                whereClause += ' AND Name = \'1234567890\'';

            resultQuery = 'SELECT ' + rm.group(1);
            resultQuery +=  ' FROM ' + rm.group(2);
            resultQuery +=  ' WHERE ' + whereClause;
            resultQuery +=  ' ORDER BY ' + rm.group(4);
        } else if(rm2.find()) {
            whereClause = 'Stato__c in :statiPratica';
            if(lPratId.size()>0)
                whereClause += ' AND Id IN :lPratId' ;
            else
                whereClause += ' AND Name = \'1234567890\'';


            resultQuery = 'SELECT ' + rm2.group(1);
            resultQuery +=  ' FROM ' + rm2.group(2);
            resultQuery += ' WHERE ' + whereClause;
            resultQuery +=  ' ORDER BY ' + rm2.group(3);
        } else if(rm3.find()) {
            textToReplace = rm3.group(3);
            whereClause = rm3.group(3) + ' AND Stato__c = in :statiPratica';
            if(lPratId.size()>0)
                whereClause += ' AND Id IN :lPratId' ;
            else
                whereClause += ' AND Name = \'1234567890\'';

            resultQuery = 'SELECT ' + rm3.group(1);
            resultQuery +=  ' FROM ' + rm3.group(2);
            resultQuery +=  ' WHERE ' + whereClause;
        } else if(rm4.find()) {
            whereClause = 'Stato__c = \'In Lavorazione\'';
            if(lPratId.size()>0)
                whereClause += ' AND Id IN :lPratId' ;
            else
                whereClause += ' AND Name = \'1234567890\'';

            resultQuery = 'SELECT ' + rm4.group(1);
            resultQuery +=  ' FROM ' + rm4.group(2);
            resultQuery += ' WHERE ' + whereClause;
        }

        return resultQuery;
    }

    @AuraEnabled(Cacheable=true)
    public static Integer getMaxRecords()
    {
        Integer maxRecord = 1000;
        if (Tag__c.getValues('MaxRecordEsitiMassivi') == null)
            return maxRecord;
        else
            return Integer.valueOf(Tag__c.getValues('MaxRecordEsitiMassivi').ValueInteger__c);
    }

    @AuraEnabled(Cacheable=true)
    public static List<CRABB_DEV__Pratica__c> getQueryListRows(String query , Integer limitClause , Integer offsetClause, String offsetValue , String TipoSottotipo)
    {
        String newTipoSottotipo = TipoSottotipo.contains('_') ? TipoSottotipo.replace('_', ' ') : TipoSottotipo;
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        System.debug(query);
        System.debug(newTipoSottotipo);

        List<Id> lPratId = DossierList(newTipoSottotipo);

        String fieldsQuery = '';
        String objectQuery = '';
        String whereConditions = '';
        String oldOrderBy = '';
        String newWhereConditions = '';
        String newOrderBy = '';
        String newQuery='';

        Pattern r = Pattern.compile('SELECT (.*) FROM (.*) WHERE (.*) ORDER BY (.*)');
        Pattern r2 = Pattern.compile('SELECT (.*) FROM (.*) WHERE (.*)');
        Pattern r3 = Pattern.compile('SELECT (.*) FROM (.*) ORDER BY (.*)');
        Pattern r4 = Pattern.compile('SELECT (.*) FROM (.*)');
        Matcher rm = r.matcher(query);
        Matcher rm2 = r2.matcher(query);
        Matcher rm3 = r3.matcher(query);
        Matcher rm4 = r4.matcher(query);

        if (rm.find()) {
            fieldsQuery = rm.group(1);
            objectQuery = rm.group(2);
            whereConditions = rm.group(3);
            oldOrderBy = rm.group(4);

            newWhereConditions = whereConditions != null ? ' WHERE ' + whereConditions + ' AND Name > \'' + offsetValue + '\'' : objectQuery + ' WHERE Name >  \'' + offsetValue + '\'';
            newOrderBy = oldOrderBy.replace(rm.group(4), 'Name ASC');

            newQuery = 'SELECT ' + fieldsQuery + ' FROM ' + objectQuery + ' ' + newWhereConditions + ' ORDER BY ' + newOrderBy + ' LIMIT ' + limitClause;

        } else if(rm2.find()) {
            fieldsQuery = rm2.group(1);
            objectQuery = rm2.group(2);
            whereConditions = rm2.group(3);

            newWhereConditions = whereConditions != null ? ' WHERE ' + whereConditions + ' AND Name > \'' + offsetValue + '\'' : objectQuery + ' WHERE Name >  \'' + offsetValue + '\'';

            newQuery = 'SELECT ' + fieldsQuery + ' FROM ' + objectQuery + ' ' + newWhereConditions + ' LIMIT ' + limitClause;

        } else if(rm3.find()) {
            fieldsQuery = rm3.group(1);
            objectQuery = rm3.group(2);
            oldOrderBy = rm3.group(3);

            newWhereConditions = ' Name >  \'' + offsetValue + '\'';

            newOrderBy = oldOrderBy.replace(rm3.group(3), 'Name ASC');

            newQuery = 'SELECT ' + fieldsQuery + ' FROM ' + objectQuery + ' WHERE ' + newWhereConditions + ' ORDER BY ' + newOrderBy + ' LIMIT ' + limitClause;

        } else if(rm4.find()) {
            fieldsQuery = rm4.group(1);
            objectQuery = rm4.group(2);

            newWhereConditions = ' Name >  \'' + offsetValue + '\'';

            newQuery = 'SELECT ' + fieldsQuery + ' FROM ' + objectQuery + ' WHERE ' + newWhereConditions + ' LIMIT ' + limitClause;
        }


        System.debug('Query rows ' + newQuery);

        List<String> listOfFields = removeToLabelFromString(fieldsQuery.split(','));
        Map<String , List<String>> objectFieldsToCheck = new Map<String, List<String>>();

        List<CRABB_DEV__Pratica__c> res = new List<CRABB_DEV__Pratica__c>();

        if(objectQuery.contains(' USING')) {
            objectQuery = objectQuery.substringBefore(' USING').remove(Utils.NAMESPACE).remove(Utils.NAMESPACE.toLowerCase());
        } else {
            objectQuery = objectQuery.remove(Utils.NAMESPACE).remove(Utils.NAMESPACE.toLowerCase());
        }

        objectFieldsToCheck.put(objectQuery, listOfFields);

        if(Utils.checkOPFLSForObjAndFields('ACCESS', objectFieldsToCheck, gd)) {
            res = Database.query(newQuery);
        }
        return res;
    }

    @AuraEnabled(Cacheable=true)
    public static Integer countQueryListViewRows(String query, String TipoSottotipo)
    {
        String newTipoSottotipo = TipoSottotipo.contains('_') ? TipoSottotipo.replace('_', ' ') : TipoSottotipo;
        System.debug(query);
        System.debug(newTipoSottotipo);

        List<Id> lPratId = DossierList(newTipoSottotipo);
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        Integer cont = 0;
        Pattern r = Pattern.compile('SELECT (.*) FROM (.*) WHERE (.*) ORDER BY (.*)');
        Pattern r2 = Pattern.compile('SELECT (.*) FROM (.*) ORDER BY (.*)');
        Pattern r3 = Pattern.compile('SELECT (.*) FROM (.*) WHERE (.*)');
        Pattern r4 = Pattern.compile('SELECT (.*) FROM (.*)');
        Matcher rm = r.matcher(query);
        Matcher rm2 = r2.matcher(query);
        Matcher rm3 = r3.matcher(query);
        Matcher rm4 = r4.matcher(query);
        String textToReplace = '';
        String objQuery = '';
        if (rm.find()) {
            textToReplace = rm.group(1);
            objQuery = rm.group(2);
            //imgMapFeed.put(  String.valueOf(feedCont) + '_'+contComment , rm.group(1));
        } else if(rm2.find()) {
            textToReplace = rm2.group(1);
            objQuery = rm2.group(2);
        } else if(rm3.find()) {
            textToReplace = rm3.group(1);
            objQuery = rm3.group(2);
        } else if(rm4.find()) {
            textToReplace = rm4.group(1);
            objQuery = rm4.group(2);
        }
        System.debug('countQueryListViewRows query --> ' + query);
        String countQuery = query.replace(textToReplace, ' count(Id) ');

        if (countQuery.contains('ORDER BY')) {
            countQuery = countQuery.substring(0, countQuery.indexOf('ORDER BY'));
        }
        List<AggregateResult> res = new List<AggregateResult>();
        System.debug('countQueryListViewRows countQuery --> ' + countQuery);
        if(objQuery.contains(' USING')) {
            objQuery = objQuery.substringBefore(' USING').remove(Utils.NAMESPACE).remove(Utils.NAMESPACE.toLowerCase());
        } else {
            objQuery = objQuery.remove(Utils.NAMESPACE).remove(Utils.NAMESPACE.toLowerCase());
        }
        if(Utils.cebCheckFLSPermission(objQuery, 'Id', gd).get('ACCESS'))
            res = Database.query(countQuery);

        cont = (Integer) res.get(0).get('expr0');
        System.debug('Number for query rows -> ' + cont);
        return cont;
    }

    @AuraEnabled(Cacheable=true)
    public static Wrapper getSelezioni()
    {
        Wrapper w;
        List<TSWrapper> lTS = new List<TSWrapper>();
        Map<String,String> lTMap = new Map<String,String>();
        List<LVWrapper> lLV = new List<LVWrapper>();
        EsitiMassiviProfile__c currentAS = EsitiMassiviProfile__c.getInstance(UserInfo.getProfileId());
        Set<String> splitSotto = new Set<String>();
        if (currentAS != null) {
            splitSotto.addAll(currentAS.Sottotipo__c.split(';'));
        }
        String q = 'SELECT Id, Tipo_attivita__c,Sotto_tipo_attivita__c ';
        q += 'FROM Strategia__c ';
        q += 'WHERE Recordtype.Name = \'Step\' AND Tipologia__c = \'UI\' AND Stato_testata__c = \'Attiva\' AND Sotto_tipo_attivita__c IN :splitSotto';
        List<Strategia__c> listStrategie = Database.query(q);

        for (Strategia__c strat : listStrategie)
        {
            String l = strat.Tipo_attivita__c + ' ' + strat.Sotto_tipo_attivita__c;
            String v = strat.Tipo_attivita__c + '_' + strat.Sotto_tipo_attivita__c;

            lTMap.put(l,v);
        }

        for(String label : ltMap.keySet()) {
            TSWrapper ts = new TSWrapper(label,lTMap.get(label));
            lTS.add(ts);
        }

        for (ListView lv : [SELECT Id, Name,DeveloperName FROM ListView
        WHERE SobjectType = 'CRABB_DEV__Pratica__c'
        WITH SECURITY_ENFORCED ])
        {
            String l = lv.Name;
            String v = lv.Id;
            LVWrapper tlv = new LVWrapper(l,v);
            lLV.add(tlv);
        }

        w = new Wrapper(lTS,lLV);

        return w;
    }

    @AuraEnabled
    public static String ConfermaListaOld(List<Id> lPratDaElaborare, String selectedEsitiPickValue, String tipoesotto)
    {
        Map<String, SObjectType> gd = Schema.getGlobalDescribe();
        String totalTipo = (tipoesotto.contains('_')) ? tipoesotto.replace('_', ' ') : tipoesotto;
        String tip = (tipoesotto.contains('_')) ? tipoesotto.split('_')[0] : '';
        Boolean isLettera = false;

        /*String taskWhereClause = 'WHERE WhatId IN :idPratiche  AND ActivityExtended__r.Tipo_Sottotipo__c = \'' + String.escapeSingleQuotes(totalTipo) + '\' ';*/

        if (Utils.cebCheckObjPermission('Task',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Scelta_utente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'SLA__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Count_of_Events__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Count_of_Tasks__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_Fuori_SLA__c', gd).get('ACCESS'))
        {
            List<Task> taskUPD = [SELECT Id, Status, ActivityExtended__r.Scelta_utente__c
            FROM Task
            WHERE WhatId IN :lPratDaElaborare
            AND Status = 'Non iniziata'
            AND ActivityExtended__r.Tipo_Sottotipo__c = :totalTipo
            WITH SECURITY_ENFORCED ];

            Map<Id, ActivityExtended__c> task2obj = Utils.getTaskWithActivityExtended(taskUPD);
            List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
            Map<String, String> mapEsiti = getMapEsiti(tipoesotto);
            for (Task t : taskUPD)
            {
                System.debug('Status before:' + t.Status);
                System.debug(mapEsiti.get(selectedEsitiPickValue));
                if (mapEsiti.get(selectedEsitiPickValue) == 'Final')
                    t.Status = 'Lavorata';
                System.debug('Status after:' + t.Status);

                ActivityExtended__c ae = task2obj.get(t.Id);
                if (ae != null) {
                    ae.Esito__c = selectedEsitiPickValue;

                    aes.add(ae);
                }
            }

            if (Utils.cebCheckObjPermission('ActivityExtended__c',gd).get('UPDATE') &&
                    Utils.cebCheckFLSPermission('ActivityExtended__c', 'Scelta_utente__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Esito__c', gd).get('UPDATE')) {
                update aes;
            }

            Id batchId = Database.executeBatch(new BatchElaboraPratiche(taskUPD), 20);
            AsyncApexJob aaj = [SELECT Id,Status,ExtendedStatus,CompletedDate,CreatedDate,TotalJobItems,JobItemsProcessed FROM AsyncApexJob WHERE Id = :batchId LIMIT 1];
            String currentStep = '2';
            Boolean batchRunning = true;
            Integer countTask = taskUPD.size();
        }
        return null;
    }

    @AuraEnabled
    public static AsyncApexJob ConfermaLista(List<Id> lPratDaElaborare, String selectedEsitiPickValue, String tipoesotto)
    {
        AsyncApexJob aaj = new AsyncApexJob();
        Map<String, SObjectType> gd = Schema.getGlobalDescribe();
        String totalTipo = (tipoesotto.contains('_')) ? tipoesotto.replace('_', ' ') : tipoesotto;
        String tip = (tipoesotto.contains('_')) ? tipoesotto.split('_')[0] : '';
        Boolean isLettera = false;

        /*String taskWhereClause = 'WHERE WhatId IN :idPratiche  AND ActivityExtended__r.Tipo_Sottotipo__c = \'' + String.escapeSingleQuotes(totalTipo) + '\' ';*/

        /*if (Utils.cebCheckObjPermission('Task',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Scelta_utente__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'SLA__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Count_of_Events__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Count_of_Tasks__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_Fuori_SLA__c', gd).get('ACCESS'))
        {*/
            List<Task> taskUPD = [SELECT Id, Status, ActivityExtended__r.Scelta_utente__c
            FROM Task
            WHERE WhatId IN :lPratDaElaborare
            AND Status = 'Non iniziata'
            AND ActivityExtended__r.Tipo_Sottotipo__c = :totalTipo
            WITH SECURITY_ENFORCED ];

            Map<Id, ActivityExtended__c> task2obj = Utils.getTaskWithActivityExtended(taskUPD);
            List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
            Map<String, String> mapEsiti = getMapEsiti(tipoesotto);
            for (Task t : taskUPD)
            {
                System.debug('Status before:' + t.Status);
                System.debug(mapEsiti.get(selectedEsitiPickValue));
                if (mapEsiti.get(selectedEsitiPickValue) == 'Final')
                    t.Status = 'Lavorata';
                System.debug('Status after:' + t.Status);

                ActivityExtended__c ae = task2obj.get(t.Id);
                if (ae != null) {
                    ae.Esito__c = selectedEsitiPickValue;

                    aes.add(ae);
                }
            }

            if (Utils.cebCheckObjPermission('ActivityExtended__c',gd).get('UPDATE') &&
                    Utils.cebCheckFLSPermission('ActivityExtended__c', 'Scelta_utente__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Esito__c', gd).get('UPDATE')) {
                update aes;
            }

            Id batchId = Database.executeBatch(new BatchElaboraPratiche(taskUPD), 20);
            aaj = [SELECT Id,Status,ExtendedStatus,CompletedDate,CreatedDate,TotalJobItems,JobItemsProcessed, NumberOfErrors
            FROM AsyncApexJob WHERE Id = :batchId LIMIT 1];
            String currentStep = '2';
            Boolean batchRunning = true;
            Integer countTask = taskUPD.size();
        //}
        return aaj;
    }


    private static Map<String, String> getMapEsiti(String tipoesotto) {
        Esiti_Massivi__mdt[] EM = [SELECT Allowed_Outcomes__c, Allowed_Final_Outcomes__c, Allowed_Partial_Outcomes__c
        FROM Esiti_Massivi__mdt WHERE Tipo_Sottotipo__c = :tipoesotto
        WITH SECURITY_ENFORCED ];
        List<String> ls = new List<String>();

        Map<String, String> mapEsiti = new Map<String, String>();
        /*mapEsiti.put('Nessun Esito', 'Partial');
        mapEsiti.put('', 'Partial');*/
        if (TagHelper.getValueBoolean('SkipNessunEsitoEsitazioneMassiva') == false) {
            mapEsiti.put('Nessun Esito', 'Partial');
            mapEsiti.put('', 'Partial');
        }
        if (EM.size() > 0) {
            ls = EM[0].Allowed_Outcomes__c.split(';');
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

    @AuraEnabled
    public static AsyncApexJob refreshTable(String batchId) {
        AsyncApexJob aaj = [SELECT Id,Status,ExtendedStatus,CompletedDate,CreatedDate,TotalJobItems,JobItemsProcessed,NumberOfErrors FROM AsyncApexJob WHERE Id = :batchId LIMIT 1];
        return aaj;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Map<String, String>> getEsitiPickListValues(String tipoesotto) {
        List<Map<String, String>> EsitipicklistValues = new List<Map<String, String>>();

/*        EsitipicklistValues.add(new Map<String, String>{
                '' => '--- Select one ---'
        });
        EsitipicklistValues.add(new Map<String, String>{
                'Nessun Esito' => 'Nessun Esito'
        });*/
        if (TagHelper.getValueBoolean('SkipNessunEsitoEsitazioneMassiva') == false) {
            EsitipicklistValues.add(new Map<String, String>{
                    '' => '--- Select one ---'
            });
            EsitipicklistValues.add(new Map<String, String>{
                    'Nessun Esito' => 'Nessun Esito'
            });
        }

        Esiti_Massivi__mdt[] EM = [SELECT Allowed_Outcomes__c, Allowed_Final_Outcomes__c, Allowed_Partial_Outcomes__c
        FROM Esiti_Massivi__mdt WHERE Tipo_Sottotipo__c = :tipoesotto WITH SECURITY_ENFORCED ];
        List<String> ls = new List<String>();

        Map<String, String> mapEsiti = new Map<String, String>();
        /*mapEsiti.put('Nessun Esito', 'Partial');
        mapEsiti.put('', 'Partial');*/
        if (TagHelper.getValueBoolean('SkipNessunEsitoEsitazioneMassiva') == false) {
            mapEsiti.put('Nessun Esito', 'Partial');
            mapEsiti.put('', 'Partial');
        }

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

    private static List<String> removeToLabelFromString(List<String> fieldList) {
        for(Integer i=0; i<fieldList.size(); i++) {
            String newField;
            String str=fieldList[i].remove(Utils.NAMESPACE).remove(Utils.NAMESPACE.toLowerCase());
            if(str.containsIgnoreCase('toLabel')) {
                newField = str.toLowerCase().remove('tolabel(').remove(')');
                fieldList[i] = newField;
            } else {
                if(str.containsIgnoreCase(Utils.NAMESPACE)) {
                    fieldList[i] = str;
                }
            }
        }

        return fieldList;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String,String> getMapEsitiFinal(String tipoesotto) {
        Map<String, String> mapEsiti = getMapEsiti(tipoesotto);
        return mapEsiti;
    }

    public class Wrapper
    {
        @AuraEnabled
        public List<TSWrapper> lTS;
        @AuraEnabled
        public List<LVWrapper> lLV;

        public Wrapper(List<TSWrapper> lTS, List<LVWrapper> lLV)
        {
            this.lTS = lTS;
            this.lLV = lLV;
        }
    }

    public class TSWrapper
    {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }

        public TSWrapper(String l, String v)
        {
            label = l;
            value = v;
        }
    }

    public class LVWrapper
    {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }

        public LVWrapper(String l, String v)
        {
            label = l;
            value = v;
        }
    }
}