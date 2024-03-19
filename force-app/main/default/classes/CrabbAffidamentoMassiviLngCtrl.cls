/**
 * Created by MatteoSala on 07/07/2022.
 */

public with sharing class CrabbAffidamentoMassiviLngCtrl
{
    private static final Set<String> statiPratica = crabbListViewUtilities.getDossierStatusesList('Affidamento', 'CRABB_DEV__stati_in_lavorazione__c');

    @AuraEnabled(Cacheable=true)
    public static Integer getMaxRecords()
    {
        Integer maxRecord = 1000;
        if (Tag__c.getValues('MaxRecordAffidiMassivi') == null)
            return maxRecord;
        else
            return Integer.valueOf(Tag__c.getValues('MaxRecordAffidiMassivi').ValueInteger__c);
    }

    /*@AuraEnabled(Cacheable=true)
    public static String getQueryListView(String listViewId, String TipoSottotipo)
    {
        String newTipoSottotipo = TipoSottotipo.contains('_') ? TipoSottotipo.replace('_', ' ') : TipoSottotipo;
        HttpRequest req = new HttpRequest();
        String query = '';
        String baseUrl = Url.getSalesforceBaseUrl().toExternalForm();
        String endPoinURL = baseUrl + '/services/data/v50.0/sobjects/CRABB_DEV__Pratica__c/listviews/' + listViewId + '/describe';
        req.setEndpoint(endPoinURL);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + crabbListViewUtilities.fetchUserSessionId());
        Http http = new Http();
        HttpResponse response = http.send(req);
        if (response.getStatusCode() == 200) {
            Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            query = (String) tokenResponse.get('query');

        }
        //query = query.replaceFirst('SELECT ', 'SELECT Id ,');
        query = crabbListViewUtilities.modifyQuery(query, newTipoSottotipo);
        System.debug(query);
        return query;
    }*/

    @AuraEnabled
    public static String getQueryListView(String listViewId, String TipoSottotipo)
    {
        String newTipoSottotipo = TipoSottotipo.contains('_') ? TipoSottotipo.replace('_', ' ') : TipoSottotipo;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String query = '';
        request.setEndpoint('callout:Crabb_Bulk_Activities/services/data/v50.0/sobjects/CRABB_DEV__Pratica__c/listviews/' + listViewId + '/describe');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        System.Debug('Test Claudio - Response: ' +response.getBody() + response.getStatusCode());
        System.Debug('test response code: ' +request.getHeader('Authorization'));
        if (response.getStatusCode() == 200) {
            Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            query = (String) tokenResponse.get('query');

        } else {
            System.debug('### ' +response.getBody());
        }
        query = crabbListViewUtilities.modifyQuery(query, newTipoSottotipo);
        System.debug(query);
        return query;
    }

    @AuraEnabled(Cacheable=true)
    public static crabbListViewUtilities.Wrapper getSelezioni()
    {
        crabbListViewUtilities.Wrapper w;
        List<crabbListViewUtilities.TSWrapper> lTS = new List<crabbListViewUtilities.TSWrapper>();
        Map<String,String> lTMap = new Map<String,String>();
        List<crabbListViewUtilities.LVWrapper> lLV = new List<crabbListViewUtilities.LVWrapper>();
        //EsitiMassiviProfile__c currentAS = EsitiMassiviProfile__c.getInstance(UserInfo.getProfileId());
        AffidiSettings__c currentAS = AffidiSettings__c.getInstance(UserInfo.getProfileId());
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
            crabbListViewUtilities.TSWrapper ts = new crabbListViewUtilities.TSWrapper(label,lTMap.get(label));
            lTS.add(ts);
        }

        for (ListView lv : [SELECT Id, Name,DeveloperName FROM ListView WHERE SobjectType = 'CRABB_DEV__Pratica__c' WITH SECURITY_ENFORCED])
        {
            String l = lv.Name;
            String v = lv.Id;
            crabbListViewUtilities.LVWrapper tlv = new crabbListViewUtilities.LVWrapper(l,v);
            lLV.add(tlv);
        }

        w = new crabbListViewUtilities.Wrapper(lTS,lLV);

        return w;
    }

    @AuraEnabled(Cacheable=true)
    public static Integer countQueryListViewRows(String query, String TipoSottotipo)
    {
        String newTipoSottotipo = TipoSottotipo.contains('_') ? TipoSottotipo.replace('_', ' ') : TipoSottotipo;
        System.debug(query);
        System.debug(newTipoSottotipo);

        List<Id> lPratId = crabbListViewUtilities.DossierList(newTipoSottotipo);
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
        if (rm.find())
        {
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
    public static List<CRABB_DEV__Pratica__c> getQueryListRows(String query , Integer limitClause , Integer offsetClause, String offsetValue , String TipoSottotipo)
    {
        String newTipoSottotipo = TipoSottotipo.contains('_') ? TipoSottotipo.replace('_', ' ') : TipoSottotipo;
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        System.debug(query);
        System.debug(newTipoSottotipo);

        List<Id> lPratId = crabbListViewUtilities.DossierList(newTipoSottotipo);

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

        List<String> listOfFields = crabbListViewUtilities.removeToLabelFromString(fieldsQuery.split(','));
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
    //public static List<crabbListViewUtilities.OptionsWrapper> availableCollectors(string myTipoAffido)
    public static crabbListViewUtilities.CollectorsWrapper availableCollectors(string myTipoAffido)
    {
        System.Debug('AvailableCollectors --> ' + myTipoAffido);
        list<crabbListViewUtilities.OptionsWrapper> collectorSelezionabili = new list<crabbListViewUtilities.OptionsWrapper>();
        List<Collector__c> lC = new List<Collector__c>();
        List<String> lta = myTipoAffido.split('_');
        String ta = lta[1];
        List<Collector_con_Tipo_Affido__c> mcs = Collector_con_Tipo_Affido__c.getall().values();
        list<String> categorieCollector = new list<String>();
        System.Debug('AvailableCollectors --> ' + ta);

        for(Collector_con_Tipo_Affido__c c:mcs)
        {
            if(c.Tipo_Affido__c == ta)
                categorieCollector.add(c.Categoria_Collector__c);
        }
        System.Debug('AvailableCollectors --> ' + categorieCollector);
        System.Debug('AvailableCollectors --> ' + collectorSelezionabili);

        if(categorieCollector != null)
        {
            /*System.Debug('AvailableCollectors --> IF');*/
            for(Collector__c c : [Select id, name, Ragione_Sociale__c,Percentuale_Affido_Standard__c  from Collector__c where Tipo_Collector__c IN :categorieCollector WITH SECURITY_ENFORCED]) //'LEGALE'
            {
                System.Debug('AvailableCollectors --> ' + c);
                collectorSelezionabili.add(new crabbListViewUtilities.OptionsWrapper(c.Ragione_Sociale__c,c.id));
                lC.add(c);
            }
            crabbListViewUtilities.CollectorsWrapper cw = new crabbListViewUtilities.CollectorsWrapper(collectorSelezionabili,lC);
            return cw;
        }
        //System.Debug('AvailableCollectors --> ' + collectorSelezionabili);
        //return collectorSelezionabili;
        return null;
    }

    @AuraEnabled(Cacheable=true)
    public static List<DistribResult> distributeDossiers(string myTipoAffido,List<String> PraticheIds, String Collectors, String Alg)
    {
        /***
        System.debug('distributeDossiers ==> ' + myTipoAffido);
        System.debug('distributeDossiers ==> ' + PraticheIds);
        System.debug('distributeDossiers ==> ' + Collectors);
        System.debug('distributeDossiers ==> ' + Alg);***/
        Boolean multipleCurrencies = UserInfo.isMultiCurrencyOrganization();
        List<DistribResult> lDR = new List<DistribResult>();
        String sTipoeSottotipo = myTipoAffido.replace('_',' ');
        List<Object> values = (List<Object>)JSON.deserializeUntyped(Collectors);
        Map<Integer,Id> orderedColls = new Map<Integer,Id>();
        for(Object fld: values)
        {
            Map<String,Object> data = (Map<String,Object>)fld;
            orderedColls.put(Integer.valueOf(data.get('Order')),String.valueOf(data.get('Collector')));
            System.debug('distributeDossiers ==> ' + data.get('Collector'));
            System.debug('distributeDossiers ==> ' + data.get('Order'));
            DistribResult dr = new DistribResult();
            dr.collector = String.valueOf(data.get('Collector'));
            dr.position = Integer.valueOf(data.get('Order'));
            dr.percAff = Double.valueOf(data.get('PercentAssignments'));
            dr.percEff = 0;
            dr.totAmount = 0;
            dr.l.Agenzia_di_Recupero__c=String.valueOf(data.get('Collector'));
            dr.l.Affidamenti_support_collector_ragSoc__c=String.valueOf(data.get('Collector'));
            dr.l.tipo__c='Pre-Lotto';
            dr.l.stato__c='In Creazione';
            dr.l.Affidamenti_support_numero_affidi__c=0;
            dr.l.Affidamenti_support_Scaduto_Affidato__c=0;
            dr.l.Affidamenti_support_Percentuale_effettiv__c=0;
            dr.l.Affidamenti_support_Tipo_Affido__c = sTipoeSottotipo;
            lDR.add(dr);
            System.debug('distributeDossiers ==> dr: ' + dr);
        }
        System.debug('distributeDossiers ==> lDR: ' + lDR);

        Map<string,string> mapTaskPratica = new Map<string,string>();

        System.debug('distributeDossiers ==> orderedColls: ' + orderedColls);

        List<Task> lT = [SELECT
                                id, whatId
                        From
                                Task
                        where
                                ActivityExtended__r.Tipo_Sottotipo__c = :sTipoeSottotipo and
                                WhatId in :PraticheIds and
                                status in ('Non Iniziata') and
                                ActivityExtended__r.id_affidamento__c = null
                        WITH SECURITY_ENFORCED
                        order by
                                createdDate Desc
                        ];

        for(Task t: lT)
        {
            mapTaskPratica.put(t.WhatId,t.Id);
        }
        List<Pratica__c> lP = new List<Pratica__c>();
        if(multipleCurrencies) {
                                lP =   [SELECT
                                        Id, convertCurrency(Residuo_Totale__c)
                                FROM
                                        Pratica__c
                                WHERE
                                        Id IN :mapTaskPratica.keySet()
                                WITH SECURITY_ENFORCED
                                ORDER BY
                                        Residuo_Totale__c DESC
                                ];
        } else {
                                lP =   [SELECT
                                        Id, Residuo_Totale__c
                                FROM
                                        Pratica__c
                                WHERE
                                        Id IN :mapTaskPratica.keySet()
                                WITH SECURITY_ENFORCED
                                ORDER BY
                                        Residuo_Totale__c DESC
                                ];
        }



        Decimal totAmount = 0.0;
        Decimal maxAmount = 0.0;
        Decimal minAmount = 0.0;
        for(Pratica__c p: lP)
        {
            totAmount += p.Residuo_Totale__c;
            if(p.Residuo_Totale__c > maxAmount)
                maxAmount = p.Residuo_Totale__c;
            if(p.Residuo_Totale__c < minAmount || minAmount == 0)
                minAmount = p.Residuo_Totale__c;
        }

        /***
        for(DistribResult dr : lDR)
        {
            dr.l.tipo__c='Pre-Lotto';
            dr.l.stato__c='In Creazione';
            dr.l.Pratiche_pre_lotto__c=JSON.serialize(dr.mapTaskPratica);
            LottiCreati.add(dr.l);
        }
        ***/

        System.debug('distributeDossiers ==> ' + Alg);
        if(Alg == 'RR')
        {
            System.debug('distributeDossiers ==> Distribution Start RR');
            lDR = RoundRobin(lDR,lP,mapTaskPratica);
        }
        else if(Alg == 'RRR')
        {
            System.debug('distributeDossiers ==> Distribution Start RRR');
            lDR = ReverseRoundRobin(lDR,lP,mapTaskPratica);
        }
        else if(Alg == 'FIFO')
        {
            System.debug('distributeDossiers ==> Distribution Start FIFO');
            lDR = FIFO(lDR,lP,mapTaskPratica);
        }
        else
        {
            System.debug('distributeDossiers ==> Distribution Start ELSE');
            lDR = FIFO(lDR,lP,mapTaskPratica);
        }

        /***
            System.debug('distributeDossiers ==> ' + totAmount);
            System.debug('distributeDossiers ==> ' + maxAmount);
            System.debug('distributeDossiers ==> ' + minAmount);
        ***/
        System.debug('distributeDossiers ==> lDR: ' + lDR);

        return lDR;
    }

    public static List<DistribResult> RoundRobin(   List<DistribResult> lDR,
                                                    List<Pratica__c> lP,
                                                    Map<string,string> mapTaskPratica)
    {
        System.debug('RoundRobin => Start');
        List<DistribResult> retDR = new List<DistribResult>();
        Map<String,DistribResult> mDR = new Map<String,DistribResult>();
        Integer numPratAff = 0;
        Integer i = 1;
        Map<String,Integer> collectorsTotAff = new Map<String,Integer>();
        Integer numPratDaAff = lP.size();

        for(Pratica__c p : lP)
        {
            Map<Integer,String> availableCollectors = new Map<Integer,String>();
            Integer pos = 1;
            Integer totAvailableColls = lDR.size();
            for(DistribResult d: lDR)
            {
                String coll = d.collector;
                System.debug('RoundRobin => : ' + coll);
                Double collectorPercentage = 0;
                if(!collectorsTotAff.containsKey(coll))
                {
                    collectorsTotAff.put(coll,0);
                }
                else
                {
                    collectorPercentage = ((Double) collectorsTotAff.get(coll) / numPratDaAff);
                }

                System.debug('RoundRobin => : ' + collectorPercentage);
                System.debug('RoundRobin => : ' + d.percAff);
                if(collectorPercentage < d.percAff)
                {
                    System.debug('RoundRobin => : Available');
                    if(pos == totAvailableColls)
                        availableCollectors.put(0,coll);
                    else
                        availableCollectors.put(pos,coll);
                    pos++;
                }
                else
                {
                    totAvailableColls -= 1;
                }
            }
            Set<Integer> lKeys = availableCollectors.keySet();
            Integer maxKey = 0;
            for(Integer x : lKeys)
            {
                if(maxKey<x)
                    maxKey = x;
            }
            Map<Integer,String> availableCollectorsPosition = new Map<Integer,String>();
            Integer newPos = 0;
            Boolean isZero = false;
            for(Integer y = 0; y<=maxKey; y++)
            {
                if(availableCollectors.containsKey(y))
                {
                    if(y==0)
                        isZero = true;

                    if(!isZero && newPos == maxKey)
                        availableCollectorsPosition.put(0,availableCollectors.get(y));
                    else
                        availableCollectorsPosition.put(newPos,availableCollectors.get(y));

                    newPos++;
                }
            }
            availableCollectors = availableCollectorsPosition;

            //System.debug('RoundRobin => availableCollectors: ' + availableCollectors);
            Integer reminder = math.mod(i, availableCollectors.size());
            String c = availableCollectors.get(reminder);
            Integer pratAff = collectorsTotAff.get(c);
            pratAff = pratAff + 1;
            collectorsTotAff.put(c,pratAff);
            DistribResult d = new DistribResult();
            if(mDR.containsKey(c))
            {
                d = mDR.get(c);
            }
            else
            {
                for(DistribResult dr : lDR)
                {
                    if(dr.collector == c)
                        d = dr;
                }
            }
            d.mapTaskPratica.put(p.Id,mapTaskPratica.get(p.Id));
            d.totAmount += p.Residuo_Totale__c;
            d.totPrat = collectorsTotAff.get(c);
            d.percEff = ((Double) collectorsTotAff.get(c) / numPratDaAff);
            //System.debug('RoundRobin => collectorsTotAff: ' + collectorsTotAff);
            mDR.put(c,d);
            i++;
        }

        for(String s : mDr.keySet())
        {
            retDR.add(mDR.get(s));
        }
        //System.debug('RoundRobin => retDR: ' + retDR);
        return retDR;
    }

    public static List<DistribResult> ReverseRoundRobin(List<DistribResult> lDR,
                                                        List<Pratica__c> lP,
                                                        Map<string,string> mapTaskPratica)
    {
        System.debug('ReverseRoundRobin => Start');
        List<DistribResult> retDR = new List<DistribResult>();
        Map<String,DistribResult> mDR = new Map<String,DistribResult>();
        Integer numPratAff = 0;
        Integer i = 1;
        Map<String,Integer> collectorsTotAff = new Map<String,Integer>();
        Integer numPratDaAff = lP.size();
        Integer numRound = 1;

        for(Pratica__c p : lP)
        {
            Map<Integer,String> availableCollectors = new Map<Integer,String>();
            Integer pos = 1;
            Integer totAvailableColls = lDR.size();
            for(DistribResult d: lDR)
            {
                String coll = d.collector;
                System.debug('ReverseRoundRobin => : ' + coll);
                Double collectorPercentage = 0;
                if(!collectorsTotAff.containsKey(coll))
                {
                    collectorsTotAff.put(coll,0);
                }
                else
                {
                    collectorPercentage = ((Double) collectorsTotAff.get(coll) / numPratDaAff);
                }

                System.debug('ReverseRoundRobin => : ' + collectorPercentage);
                System.debug('ReverseRoundRobin => : ' + d.percAff);
                if(collectorPercentage < d.percAff)
                {
                    System.debug('ReverseRoundRobin => : Available');
                    if(pos == totAvailableColls)
                        availableCollectors.put(0,coll);
                    else
                        availableCollectors.put(pos,coll);
                    pos++;
                }
                else
                {
                    totAvailableColls -= 1;
                }
            }
            Set<Integer> lKeys = availableCollectors.keySet();
            Integer maxKey = 0;
            for(Integer x : lKeys)
            {
                if(maxKey<x)
                    maxKey = x;
            }
            Map<Integer,String> availableCollectorsPosition = new Map<Integer,String>();
            Integer newPos = 0;
            Boolean isZero = false;
            for(Integer y = 0; y<=maxKey; y++)
            {
                if(availableCollectors.containsKey(y))
                {
                    if(y==0)
                        isZero = true;

                    if(!isZero && newPos == maxKey)
                        availableCollectorsPosition.put(0,availableCollectors.get(y));
                    else
                        availableCollectorsPosition.put(newPos,availableCollectors.get(y));

                    newPos++;
                }
            }
            if(math.mod(numRound, 2) == 0)
            {
                availableCollectors.clear();
                Integer revPosition = 2;
                for(Integer z = availableCollectorsPosition.size(); z>=0;z--)
                {
                    if(availableCollectorsPosition.containsKey(z))
                    {
                        if(z == 0)
                            availableCollectors.put(1,availableCollectorsPosition.get(z));
                        else if(z == 1)
                            availableCollectors.put(0,availableCollectorsPosition.get(z));
                        else
                            availableCollectors.put(revPosition,availableCollectorsPosition.get(z));

                        revPosition++;
                    }
                }
            }
            else
                availableCollectors = availableCollectorsPosition;

            System.debug('ReverseRoundRobin => availableCollectors: ' + availableCollectors);
            Integer reminder = math.mod(i, availableCollectors.size());
            String c = availableCollectors.get(reminder);
            Integer pratAff = collectorsTotAff.get(c);
            pratAff = pratAff + 1;
            collectorsTotAff.put(c,pratAff);
            DistribResult d = new DistribResult();
            if(mDR.containsKey(c))
            {
                d = mDR.get(c);
            }
            else
            {
                for(DistribResult dr : lDR)
                {
                    if(dr.collector == c)
                        d = dr;
                }
            }
            d.mapTaskPratica.put(p.Id,mapTaskPratica.get(p.Id));
            d.totAmount += p.Residuo_Totale__c;
            d.totPrat = collectorsTotAff.get(c);
            d.percEff = ((Double) collectorsTotAff.get(c) / numPratDaAff);
            //System.debug('RoundRobin => collectorsTotAff: ' + collectorsTotAff);
            mDR.put(c,d);
            if(reminder == 0)
                numRound += 1;
            i++;
        }

        for(String s : mDr.keySet())
        {
            retDR.add(mDR.get(s));
        }
        //System.debug('RoundRobin => retDR: ' + retDR);
        return retDR;
    }

    public static List<DistribResult> FIFO( List<DistribResult> lDR,
                                            List<Pratica__c> lP,
                                            Map<string,string> mapTaskPratica)
    {
        //System.debug('FIFO => Start');
        //DistribResult dr = new DistribResult();
        List<DistribResult> retDR = new List<DistribResult>();
        //List<String> lPratAff = new List<String>();
        Integer numPratAff = 0;
        Integer i = 0;

        for(DistribResult d: lDR)
        {
            //System.debug('FIFO => ' + d);
            //System.debug('FIFO => ' + lP.size());
            Integer numPratDaAff = lP.size();
            /***numPratAff = lPratAff.size();***/
            numPratAff = 0;
            Double percAffAttuale = ((Double) numPratAff / numPratDaAff);
            Double pAffPrev = d.percAff;
            Double totAmount = 0.0;
            System.debug('FIFO => ' + percAffAttuale);
            System.debug('FIFO => ' + pAffPrev);

            while(i<lP.size() && percAffAttuale<pAffPrev)
            {
                d.mapTaskPratica.put(lP[i].Id,mapTaskPratica.get(lP[i].Id));
                //System.debug('FIFO => While: ' + d.mapTaskPratica);
                totAmount += lP[i].Residuo_Totale__c;
                i++;
                numPratAff++;
                //System.debug('FIFO => While: ' + numPratAff);
                //System.debug('FIFO => While: ' + numPratDaAff);
                percAffAttuale = ((Double) numPratAff / numPratDaAff);
                //System.debug('FIFO => While: ' + percAffAttuale);
            }
            d.totAmount = totAmount;
            d.percEff = percAffAttuale;
            d.totPrat = numPratAff;
            //System.debug('FIFO => For: ' + i);
            retDR.add(d);
        }
        //System.debug('FIFO => End');
        //System.debug('FIFO => ' + dr);
        return retDR;
    }

    public class DistribResult
    {
        @AuraEnabled
        public String collector;
        @AuraEnabled
        public Integer position;
        @AuraEnabled
        public Map<string,string> mapTaskPratica;
        @AuraEnabled
        public double percAff;
        @AuraEnabled
        public double percEff;
        @AuraEnabled
        public Double totAmount;
        @AuraEnabled
        public Integer totPrat;
        @AuraEnabled
        public Lotto__c l{get;set;}

        public DistribResult()
        {
            collector = '';
            position = 0;
            percAff = 0;
            percEff = 0;
            totAmount = 0;
            totPrat = 0;
            l=new lotto__c();
            l.Affidamenti_support_Codice_prelotto__c = ''+system.now();
            mapTaskPratica=new map<string,string>();
        }
    }

    @AuraEnabled(Cacheable=false)
    public static List<Lotto__c> finalizzaLotti(List<Object> lDR_Old, String sDR)
    {
        Map<String, SObjectType> gd = Schema.getGlobalDescribe();
        List<DistribResult> lDR = (List<DistribResult>)JSON.deserialize(sDR,List<DistribResult>.class);
        List<Lotto__c> lInsertLotti = new List<Lotto__c>();
        List<String> lIdColl = new List<String>();
        List<lotto__c> LottiCreati=new List<lotto__c>();

        for(DistribResult dr : lDR)
        {
            lIdColl.add(dr.collector);
        }

        Map<Id,Collector__c> mColl = new Map<Id,Collector__c>([SELECT Id, Ragione_Sociale__c,Percentuale_Affido_Standard__c
                                                                FROM Collector__c
                                                                WHERE Id in : lIdColl
                                                                WITH SECURITY_ENFORCED
                                                                ]);

        for(DistribResult dr : lDR)
        {
            Lotto__c l = dr.l;
            if(mColl.containsKey(dr.collector))
            {
                l.Affidamenti_support_collector_ragSoc__c = mColl.get(dr.collector).Ragione_Sociale__c;
                l.Affidamento_Percentuale_Affido_Standard__c = mColl.get(dr.collector).Percentuale_Affido_Standard__c;
            }
            l.Affidamenti_support_Posizione__c = dr.position;
            l.Affidamenti_support_numero_affidi__c = dr.totPrat;
            l.Affidamenti_support_Scaduto_Affidato__c = dr.totAmount;
            l.Affidamenti_support_Percentuale_effettiv__c = dr.percEff;
            l.Pratiche_pre_lotto__c = JSON.serialize(dr.mapTaskPratica);
            l.SystemCreationOfPreLotto__c=true;
            lInsertLotti.add(l);
        }

        System.debug(lInsertLotti);
        if(lInsertLotti.size()>0
            && Utils.cebCheckFLSPermission('Lotto__c', 'tipo__c', gd).get('INSERT')
            && Utils.cebCheckFLSPermission('Lotto__c', 'stato__c', gd).get('INSERT')
            && Utils.cebCheckFLSPermission('Lotto__c', 'Pratiche_pre_lotto__c', gd).get('INSERT')
            && Utils.cebCheckFLSPermission('Lotto__c', 'Affidamenti_support_Scaduto_Affidato__c', gd).get('INSERT')
            && Utils.cebCheckFLSPermission('Lotto__c', 'Affidamenti_support_numero_affidi__c', gd).get('INSERT')
            && Utils.cebCheckFLSPermission('Lotto__c', 'Agenzia_di_Recupero__c', gd).get('INSERT')
            && Utils.cebCheckFLSPermission('Lotto__c', 'Affidamenti_support_collector_ragSoc__c', gd).get('INSERT')
            && Utils.cebCheckFLSPermission('Lotto__c', 'Affidamenti_support_Percentuale_effettiv__c', gd).get('INSERT')
            && Utils.cebCheckFLSPermission('Lotto__c', 'Affidamenti_support_Posizione__c', gd).get('INSERT')
            && Utils.cebCheckFLSPermission('Lotto__c', 'Affidamenti_support_Codice_prelotto__c', gd).get('INSERT')) {
            insert lInsertLotti;

            list<id> idLotti= new list<id>();
            for(lotto__c l:lInsertLotti) idLotti.add(l.id);

            LottiCreati=[Select id, name, tipo__c, stato__c,Pratiche_pre_lotto__c,Affidamenti_support_Scaduto_Affidato__c,
                    Affidamenti_support_numero_affidi__c,Agenzia_di_Recupero__c,Affidamenti_support_collector_ragSoc__c,
                    Affidamenti_support_Percentuale_effettiv__c, Affidamenti_support_Posizione__c,Affidamenti_support_Codice_prelotto__c
                    From Lotto__c where id=:idLotti
                    WITH SECURITY_ENFORCED];
        }

        if(lInsertLotti.size()<200)
        {//chiama direttamente il metodo
            for(Lotto__c l: lInsertLotti)
                AffidamentiManager.creaAffidamenti(l);
        }
        else// troppi record, schedula Batch
                BatchQueue.reqBatch('APB','AffidiProcessBatch',1,1,lInsertLotti);

        return LottiCreati;
    }
}