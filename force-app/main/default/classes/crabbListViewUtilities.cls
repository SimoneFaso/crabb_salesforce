/* ---------------------------------------------------------------------------------------------------------------------
Name:            crabbListViewUtilities.cls
Description:
Test class:

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
11-Jul-2022  0.1      M.Sala               First Version
16-Sep-2022  0.2      C.Sanna & R.Kurti    Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class crabbListViewUtilities {
    public class CollectorsWrapper {
        @AuraEnabled
        public List<OptionsWrapper> lOW;
        @AuraEnabled
        public List<Collector__c> lC;

        public CollectorsWrapper(List<OptionsWrapper> lOW, List<Collector__c> lC) {
            this.lOW = lOW;
            this.lC = lC;
        }
    }

    public class OptionsWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public OptionsWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    public class Wrapper {
        @AuraEnabled
        public List<TSWrapper> lTS;
        @AuraEnabled
        public List<LVWrapper> lLV;

        public Wrapper(List<TSWrapper> lTS, List<LVWrapper> lLV) {
            this.lTS = lTS;
            this.lLV = lLV;
        }
    }

    public class TSWrapper {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }

        public TSWrapper(String l, String v) {
            label = l;
            value = v;
        }
    }

    public class LVWrapper {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }

        public LVWrapper(String l, String v) {
            label = l;
            value = v;
        }
    }

    private static final Set<String> statiPratica = getDossierStatusesList('EsitiMassivi', 'CRABB_DEV__stati_in_lavorazione__c');

    public static Set<String> getDossierStatusesList(String devName, String field) {
        List<String> statusesList = new List<String>();
        List<SObject> mappingStatusList = new List<SObject>();
        String query = 'SELECT ' + String.escapeSingleQuotes(field) + ' FROM CRABB_DEV__mapping_status_pratica__mdt where DeveloperName =: devName WITH SECURITY_ENFORCED';
        mappingStatusList = Database.query(query);
        if (mappingStatusList.size() > 0) {
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
        try {
            vfContent = reportPage.getContent().toString();
        } catch (Exception e) {
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

    public static List<Id> DossierList(String TipoSottotipo) {
        Map<String, SObjectType> gd = Schema.getGlobalDescribe();
        List<Id> lPratId = new List<Id>();
        /*if(Utils.cebCheckFLSPermission('Task', 'WhatId', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'CRABB_DEV__ActivityExtended__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Status', gd).get('ACCESS'))
        {*/
        for (Task t : [
                SELECT WhatId
                FROM Task
                WHERE CRABB_DEV__ActivityExtended__r.CRABB_DEV__Tipo_Sottotipo__c = :TipoSottotipo
                AND Status = 'Non iniziata'
                WITH SECURITY_ENFORCED
        ]) {
            lPratId.add(t.WhatId);
        }


        return lPratId;
    }

    public static String modifyQuery(String query, String TipoSottotipo) {
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
            if (lPratId.size() > 0)
                whereClause += ' AND Id IN :lPratId' ;
            else
                    whereClause += ' AND Name = \'1234567890\'';

            resultQuery = 'SELECT ' + rm.group(1);
            resultQuery += ' FROM ' + rm.group(2);
            resultQuery += ' WHERE ' + whereClause;
            resultQuery += ' ORDER BY ' + rm.group(4);
        } else if (rm2.find()) {
            whereClause = 'Stato__c in :statiPratica';
            if (lPratId.size() > 0)
                whereClause += ' AND Id IN :lPratId' ;
            else
                    whereClause += ' AND Name = \'1234567890\'';

            resultQuery = 'SELECT ' + rm2.group(1);
            resultQuery += ' FROM ' + rm2.group(2);
            resultQuery += ' WHERE ' + whereClause;
            resultQuery += ' ORDER BY ' + rm2.group(3);
        } else if (rm3.find()) {
            textToReplace = rm3.group(3);
            whereClause = rm3.group(3) + ' AND Stato__c = in :statiPratica';
            if (lPratId.size() > 0)
                whereClause += ' AND Id IN :lPratId' ;
            else
                    whereClause += ' AND Name = \'1234567890\'';

            resultQuery = 'SELECT ' + rm3.group(1);
            resultQuery += ' FROM ' + rm3.group(2);
            resultQuery += ' WHERE ' + whereClause;
        } else if (rm4.find()) {
            whereClause = 'Stato__c = \'In Lavorazione\'';
            if (lPratId.size() > 0)
                whereClause += ' AND Id IN :lPratId' ;
            else
                    whereClause += ' AND Name = \'1234567890\'';

            resultQuery = 'SELECT ' + rm4.group(1);
            resultQuery += ' FROM ' + rm4.group(2);
            resultQuery += ' WHERE ' + whereClause;
        }

        return resultQuery;
    }

    /*public static decimal findAPIVersionOfOrg()
    {
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        String domainUrl=URL.getSalesforceBaseUrl().toExternalForm();
        system.debug('********domainUrl:'+domainUrl);
        req.setEndpoint(domainUrl+'/services/data');
        req.setMethod('GET');

        Http h = new Http();
        HttpResponse res = h.send(req);
        system.debug(res.getBody());

        String response=res.getBody();
        String apiVersion='';
        List<decimal> versionList=new List<decimal>();
        JSONParser  parser = JSON.createParser(Response);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                String fieldName = parser.getText();
                if(fieldName == 'version'){
                    parser.nextToken();
                    versionList.add(decimal.valueof(parser.getText()));
                }
            }
        }
        versionList.sort();
        system.debug('*******versionList'+versionList);
        system.debug('******Current API version:'+versionList[versionList.size()-1]);
        return versionList[versionList.size()-1];
    }*/

    public static List<String> removeToLabelFromString(List<String> fieldList) {
        for (Integer i = 0; i < fieldList.size(); i++) {
            String newField;
            String str = fieldList[i].remove(Utils.NAMESPACE).remove(Utils.NAMESPACE.toLowerCase());
            if (str.containsIgnoreCase('toLabel')) {
                newField = str.toLowerCase().remove('tolabel(').remove(')');
                fieldList[i] = newField;
            } else {
                if (str.containsIgnoreCase(Utils.NAMESPACE)) {
                    fieldList[i] = str;
                }
            }
        }

        return fieldList;
    }

}