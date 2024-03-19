/* ---------------------------------------------------------------------------------------------------------------------
Name:            Utils.cls
Description:     Utils class used in trigger handlers
Test class:      TestUtils.cls, TestOrk.cls, TestOrkBL.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
04-Aug-2014  0.1      Endrit Sino                     First Version
14-Apr-2017  0.2                                      Added check permission control
29-Apr-2021  0.3      Giulia Mameli                   Modified getTaskWithActivityExtended and getPraticaWithActivityExtended
                                                      methods to make tasksQuery and actExtsQuery variables for the whole
                                                      class to be reused if already set in a transaction.
07-May-2021  0.4      Giulia Mameli                   Modified getTaskWithActivityExtended removing Task query and commented
                                                      checkFLSPermission rows.
10-May-2021  0.5      Matteo Siotto                   Created new Engine methods cebCheckFLSPermission, cebGetTaskWithActivityExtended
                                                      cebGetSOBJECTFieldsForQuery
13-May-2021  0.6      M.Siotto & G.Mameli             Reviewed for using ceb methods
05-Nov-2020  0.7      M.Sala & G.Mameli               Added field.trim() to cebCheckFLSPermission and added
                                                      checkOPFLSForObjAndFields Method
16-Sep-2022  0.8      C.Sanna & R.Kurti               Added WITH SECURITY ENFORCED and cebCheckObjPermission (security review)
05-Oct-2022  0.9      R.Kurti & C.Sanna               Added if statements to add NAMESPACE to fields that don't already have it (security review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class Utils {

    // ES: Usata per la gestione trigger:
    public static Integer triggerCounterState = 0;
    public static Boolean triggerAssertedFromHandler = false;
    public static Boolean testEndritCambioAttivitaPuntuale = false;
    public static String NAMESPACE = 'CRABB_DEV__'; // empty this if not package mode
    public static String tasksQuery;
    public static String actExtsQuery;
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public static String getLimits() {
        String limitsMsg = '';
        limitsMsg += '\n CPUTime: ' + Limits.getCpuTime() + ' Vs ' + Limits.getLimitCpuTime();
        limitsMsg += '\n getDMLRows(): ' + Limits.getDmlRows() + ' Vs ' + Limits.getLimitDmlRows();
        limitsMsg += '\n getDMLStatements() : ' + Limits.getDmlStatements() + ' Vs ' + Limits.getLimitDmlStatements();
        limitsMsg += '\n getEmailInvocations()  : ' + Limits.getEmailInvocations() + ' Vs ' + Limits.getLimitEmailInvocations();
        //limitsMsg += '\n getFieldsDescribes(): ' + Limits.getFieldsDescribes() + ' Vs ' + Limits.getLimitFieldsDescribes();
        limitsMsg += '\n getHeapSize() : ' + Limits.getHeapSize() + ' Vs ' + Limits.getLimitHeapSize();
        limitsMsg += '\n getQueries() : ' + Limits.getQueries() + ' Vs ' + Limits.getLimitQueries();
        return limitsMsg;
    }

    public static Set<String> getStepsDaAffidamento() {
        List<Strategia__c> strl = [
                SELECT Id, Nome__c
                FROM Strategia__c
                WHERE E_da_affidare__c = true
                AND Testata__r.Stato__c = 'Attiva'
                WITH SECURITY_ENFORCED
        ];
        Set<String> strings = new Set<String>();
        for (Strategia__c s : strl) {
            strings.add(s.Nome__c);
        }
        return strings;
    }

    public static Set<String> sliptString(String stringValue, String separator) {
        if (stringValue == null) return new Set<String>();
        return new Set<String>(stringValue.split(separator));
    }

    /* Creata da Endrit (per un versione di lista)*/
    public static List<string> sliptToListString(string stringValue, string separator) {
        if (stringValue == null) return new List<string>();
        return new List<string>(stringValue.split(separator));
    }

    public static string inStrings(List<String> lstArg) {
        String fullString = '( ';
        for (String item : lstArg) {
            fullString += '\'' + item + '\',';
        }
        if (fullString.length() > 0)
            fullString = fullString.substring(0, fullString.length() - 1);
        fullString += ')';
        return fullString;
    }

    public static string joinStrings(List<String> lstArg, String separator) {
        String fullString = '';
        for (String item : lstArg) {
            fullString += item + separator;
        }
        if (fullString.length() > 0)
            fullString = fullString.substring(0, fullString.length() - 1);

        return String.escapeSingleQuotes(fullString);
    }

    public static string joinStrings(Set<String> lstArg, String separator) {
        list<string> l = new List<string>();
        l.addAll(lstArg);
        return String.escapeSingleQuotes(Utils.joinStrings(l, separator));
    }

    public static Boolean nullOrEmpty(Object o) {
        return (null == o) ||
                ((o instanceof String) && (0 == ((String) o).trim().length())) ||
                ((o instanceof List<object>) && (0 == ((List<object>) o).size()));
    }

    public static string getSOBJECTFieldsForQuery(string s) {
        SObjectType type = (s.containsIgnoreCase('__C') || s.containsIgnoreCase('__Share')) ? Schema.getGlobalDescribe().get(NAMESPACE + s) : Schema.getGlobalDescribe().get(s);
        Map<String, Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        return String.escapeSingleQuotes(Utils.joinStrings(mfields.keySet(), ','));
    }

    public static string cebGetSOBJECTFieldsForQuery(string s, Map<String, Schema.SObjectType> globalDesc) {
        SObjectType type = (s.containsIgnoreCase('__C') || s.containsIgnoreCase('__Share')) ? globalDesc.get(NAMESPACE + s) : globalDesc.get(s);
        Map<String, Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        return String.escapeSingleQuotes(Utils.joinStrings(mfields.keySet(), ','));
    }

    public static Map<String, Boolean> checkObjPermission(String s) {
        SObjectType type = (s.containsIgnoreCase('__C') || s.containsIgnoreCase('__Share')) ? Schema.getGlobalDescribe().get(NAMESPACE + s) : Schema.getGlobalDescribe().get(s);
        Map<String, Boolean> permMap = new Map<String, Boolean>();
        //if (SecuritySettings__c.getInstance().isSecure__c) {
        /*if(type.getDescribe().isCalculated())
        {*/
        permMap.put('CREATE', type.getDescribe().isCreateable());
        permMap.put('INSERT', type.getDescribe().isCreateable());
        permMap.put('UPDATE', type.getDescribe().isUpdateable());
        permMap.put('ACCESS', type.getDescribe().isAccessible());
        permMap.put('DELETE', type.getDescribe().isDeletable());
        permMap.put('QUERY', type.getDescribe().isQueryable());
        permMap.put('SEARCH', type.getDescribe().isSearchable());
        /*} 
        else 
        {
            permMap.put('CREATE',true);
            permMap.put('INSERT',true);
            permMap.put('UPDATE',true);
            permMap.put('ACCESS',true);
            permMap.put('DELETE',true);
            permMap.put('QUERY',true);
            permMap.put('SEARCH',true);
        }*/
        System.debug(permMap);
        return permMap;
    }

    /*** 20210512 MSala - Code Review - Start ***/
    public static Map<String, Boolean> cebCheckObjPermission(String sObj, Map<String, Schema.SObjectType> globalDesc) {
        //SObjectType type = (s.containsIgnoreCase('__C') || s.containsIgnoreCase('__Share')) ? Schema.getGlobalDescribe().get(NAMESPACE + s) : Schema.getGlobalDescribe().get(s);
        //SObjectType type = (sObj.containsIgnoreCase('__C') || sObj.containsIgnoreCase('__Share')) ? globalDesc.get(NAMESPACE + sObj) : globalDesc.get(sObj);
        SObjectType type = (sObj.containsIgnoreCase('__C') || sObj.containsIgnoreCase('__Share') || sObj.containsIgnoreCase('__mdt')) ? globalDesc.get(NAMESPACE + sObj) : globalDesc.get(sObj);
        Map<String, Boolean> permMap = new Map<String, Boolean>();
        permMap.put('CREATE', type.getDescribe().isCreateable());
        permMap.put('INSERT', type.getDescribe().isCreateable());
        permMap.put('UPDATE', type.getDescribe().isUpdateable());
        permMap.put('UPSERT', type.getDescribe().isCreateable() && type.getDescribe().isUpdateable());
        permMap.put('ACCESS', type.getDescribe().isAccessible());
        permMap.put('DELETE', type.getDescribe().isDeletable());
        permMap.put('QUERY', type.getDescribe().isQueryable());
        permMap.put('SEARCH', type.getDescribe().isSearchable());
        System.debug(permMap);
        return permMap;
    }
    /*** 20210512 MSala - Code Review - End ***/

    public static Map<String, Boolean> checkFLSPermission(String s, String field) {
        // field name without any namespace example: account__c instead of BALANCE_CRABB__Account__c
        if(field.containsIgnoreCase('__C')) {
            field= field.trim();
            if (!field.contains(Utils.NAMESPACE)) {
                field = NAMESPACE + field;
            }
        }
        SObjectType type = (s.containsIgnoreCase('__C') || s.containsIgnoreCase('__Share')) ? Schema.getGlobalDescribe().get(NAMESPACE + s) : Schema.getGlobalDescribe().get(s);
        Map<String, Boolean> permMap = new Map<String, Boolean>();
        if (type != null) {
            Map<String, Schema.SObjectField> fieldMap = type.getDescribe().fields.getMap();
            Schema.DescribeFieldResult fieldDesc = fieldMap.get(field.toLowerCase()).getDescribe();

            // if (SecuritySettings__c.getInstance().isSecure__c) {
            permMap.put('CREATE', fieldDesc.isCreateable());
            permMap.put('INSERT', fieldDesc.isCreateable());
            permMap.put('ACCESS', fieldDesc.isAccessible());
            permMap.put('UPDATE', fieldDesc.isUpdateable());
            permMap.put('UPSERT', fieldDesc.isUpdateable() && fieldDesc.isCreateable());
            /*} else {
                permMap.put('CREATE',true);
                permMap.put('ACCESS',true);
                permMap.put('UPDATE',true);
                permMap.put('INSERT',true);
                permMap.put('UPSERT',true);
            }    */

            //System.debug('Permission map is:'+permMap);
            return permMap;
        } else {
            permMap.put('CREATE', false);
            permMap.put('ACCESS', false);
            permMap.put('UPDATE', false);
            permMap.put('INSERT', false);
            permMap.put('UPSERT', false);
            return permMap;
        }
    }

    /*** 20210510 MSiotto - Code Review - Start ***/

    public static Map<String, Boolean> cebCheckFLSPermission(String sObj, String field, Map<String, Schema.SObjectType> globalDesc) {
        // field name without any namespace example: account__c instead of BALANCE_CRABB__Account__c

        if(field.containsIgnoreCase('__C')) {
            field= field.trim();
            if (!field.contains(Utils.NAMESPACE)) {
                field = NAMESPACE + field;
            }
        }
        //SObjectType type = (sObj.containsIgnoreCase('__C') || sObj.containsIgnoreCase('__Share')) ? globalDesc.get(NAMESPACE + sObj) : globalDesc.get(sObj);
        SObjectType type = (sObj.containsIgnoreCase('__C') || sObj.containsIgnoreCase('__Share')|| sObj.containsIgnoreCase('__mdt')) ? globalDesc.get(NAMESPACE + sObj) : globalDesc.get(sObj);

        Map<String, Boolean> permMap = new Map<String, Boolean>();
        if (type != null) {
            Map<String, Schema.SObjectField> fieldMap = type.getDescribe().fields.getMap();

            field = field.trim();

            Schema.DescribeFieldResult fieldDesc = fieldMap.get(field.toLowerCase()).getDescribe();

            // if (SecuritySettings__c.getInstance().isSecure__c) {
            permMap.put('CREATE', fieldDesc.isCreateable());
            permMap.put('INSERT', fieldDesc.isCreateable());
            permMap.put('ACCESS', fieldDesc.isAccessible());
            permMap.put('UPDATE', fieldDesc.isUpdateable());
            permMap.put('UPSERT', fieldDesc.isUpdateable() && fieldDesc.isCreateable());
            /*} else {
                permMap.put('CREATE',true);
                permMap.put('ACCESS',true);
                permMap.put('UPDATE',true);
                permMap.put('INSERT',true);
                permMap.put('UPSERT',true);
            }    */

            //System.debug('Permission map is:'+permMap);
            return permMap;
        } else {
            permMap.put('CREATE', false);
            permMap.put('ACCESS', false);
            permMap.put('UPDATE', false);
            permMap.put('INSERT', false);
            permMap.put('UPSERT', false);
            return permMap;
        }
    }

    /*** 20210510 MSiotto - Code Review - End ***/

    public static Boolean checkisAutoNumber(String objectName, String fieldName) {
        if(fieldName.containsIgnoreCase('__C')) {
            fieldName= fieldName.trim();
            if (!fieldName.contains(Utils.NAMESPACE)) {
                fieldName = NAMESPACE + fieldName;
            }
        }
        SObjectType objToken = Schema.getGlobalDescribe().get(Utils.NAMESPACE + objectName);
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap();
        return fields.get(fieldName).getDescribe().isAutoNumber();
    }

    /*** 20210512 MSiotto - Review Code - Start ***/
    public static Boolean cebCheckisAutoNumber(String objectName, String fieldName, Map<String, Schema.SObjectType> globalDesc) {
        if(fieldName.containsIgnoreCase('__C')) {
            fieldName= fieldName.trim();
            if (!fieldName.contains(Utils.NAMESPACE)) {
                fieldName = NAMESPACE + fieldName;
            }
        }
        SObjectType objToken = globalDesc.get(Utils.NAMESPACE + objectName);
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap();
        return fields.get(fieldName).getDescribe().isAutoNumber();
    }
    /*** 20210512 MSiotto - Review Code - End ***/

    public static Boolean checkisCalculated(String objectName, String fieldName) {
        if(fieldName.containsIgnoreCase('__C')) {
            fieldName= fieldName.trim();
            if (!fieldName.contains(Utils.NAMESPACE)) {
                fieldName = NAMESPACE + fieldName;
            }
        }
        SObjectType objToken = Schema.getGlobalDescribe().get(Utils.NAMESPACE + objectName);
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap();
        return fields.get(fieldName).getDescribe().isCalculated();
    }

    /*** 20210512 MSiotto - Review Code - Start ***/
    public static Boolean cebCheckisCalculated(String objectName, String fieldName, Map<String, Schema.SObjectType> globalDesc) {
        if(fieldName.containsIgnoreCase('__C')) {
            fieldName= fieldName.trim();
            if (!fieldName.contains(Utils.NAMESPACE)) {
                fieldName = NAMESPACE + fieldName;
            }
        }
        SObjectType objToken = globalDesc.get(Utils.NAMESPACE + objectName);
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap();
        return fields.get(fieldName).getDescribe().isCalculated();
    }
    /*** 20210512 MSiotto - Review Code - End ***/

    public class ActivityWithExtension {
        public Task t;
        public ActivityExtended__c ae;

        public ActivityWithExtension() {
        }

    }

    /*
        Returns a Map with Task Id as key and related ActivityExtended object as value
    */
    public static Map<Id, ActivityExtended__c> getTaskWithActivityExtended(List<Task> tasks) {
        List<Id> tasksIds = new List<Id>();

        for (Task tsk : tasks) {
            tasksIds.add(tsk.Id);
        }

        // inizio nuovo codice 14/04/17 inserimento check permission
        /*List<Task> tasks = new List<Task>();
        if (Utils.checkFLSPermission('Task', 'Count_of_Events__c').get('ACCESS')
                && Utils.checkFLSPermission('Task', 'Count_of_Tasks__c').get('ACCESS')
                && Utils.checkFLSPermission('Task', 'Durata_Effettiva__c').get('ACCESS')
                && Utils.checkFLSPermission('Task', 'Giorni_di_completamento_attivita__c').get('ACCESS')
                && Utils.checkFLSPermission('Task', 'Giorni_Fuori_SLA__c').get('ACCESS')
                && Utils.checkFLSPermission('Task', 'SLA__c').get('ACCESS')
                && Utils.checkFLSPermission('Task', 'Tipo_esecuzione__c').get('ACCESS')) {
            //tasks = Database.query(tasksQuery);
        }*/
        // fine nuovo codice 14/04/17 inserimento check permission

        Map<Id, Id> task2Ae = new Map<Id, Id>();
        for (Task tsk : tasks) {
            if (tsk.ActivityExtended__c != null) task2Ae.put(tsk.Id, tsk.ActivityExtended__c);
            System.debug(tsk.ActivityExtended__c + ' - ' + task2Ae);
        }

        List<Id> queryFilter = task2Ae.values();
        if (String.isBlank(actExtsQuery)) {
            actExtsQuery = 'SELECT ' + Utils.getSOBJECTFieldsForQuery('ActivityExtended__c') + ' FROM ActivityExtended__c WHERE Id in:queryFilter';
        }


        // inizio nuovo codice 14/04/17 inserimento check permission
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_affidamento__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_lotto_associato__c', gd).get('UPDATE')) {
            aes = Database.query(String.escapeSingleQuotes(actExtsQuery));
        }
        // fine nuovo codice 14/04/17 inserimento check permission

        Map<Id, ActivityExtended__c> aesMap = new Map<Id, ActivityExtended__c>();
        for (ActivityExtended__c actExt : aes) {
            aesMap.put(actExt.Id, actExt);
        }
        Map<Id, ActivityExtended__c> task2AeObj = new Map<Id, ActivityExtended__c>();
        for (Id tskId : task2Ae.keySet()) {
            task2AeObj.put(tskId, aesMap.get(task2Ae.get(tskId)));
        }
        return task2AeObj;
    }

    /*** 20210512 GMameli - Code Review - Start ***/
    /*
        Returns a Map with Task Id as key and related ActivityExtended object as value
    */
    public static Map<Id, ActivityExtended__c> cebGetTaskWithActivityExtended(List<Task> tasks, Map<String, Schema.SObjectType> globalDesc) {
        List<Id> tasksIds = new List<Id>();

        for (Task tsk : tasks) {
            tasksIds.add(tsk.Id);
        }
        System.debug('tasksIds --> ' + tasksIds);
        // inizio nuovo codice 14/04/17 inserimento check permission
        /*List<Task> tasks = new List<Task>();
        if (Utils.checkFLSPermission('Task', 'Count_of_Events__c').get('ACCESS')
                && Utils.checkFLSPermission('Task', 'Count_of_Tasks__c').get('ACCESS')
                && Utils.checkFLSPermission('Task', 'Durata_Effettiva__c').get('ACCESS')
                && Utils.checkFLSPermission('Task', 'Giorni_di_completamento_attivita__c').get('ACCESS')
                && Utils.checkFLSPermission('Task', 'Giorni_Fuori_SLA__c').get('ACCESS')
                && Utils.checkFLSPermission('Task', 'SLA__c').get('ACCESS')
                && Utils.checkFLSPermission('Task', 'Tipo_esecuzione__c').get('ACCESS')) {
            //tasks = Database.query(tasksQuery);
        }*/
        // fine nuovo codice 14/04/17 inserimento check permission

        Map<Id, Id> task2Ae = new Map<Id, Id>();
        for (Task tsk : tasks) {
            if (tsk.ActivityExtended__c != null) task2Ae.put(tsk.Id, tsk.ActivityExtended__c);
            System.debug(tsk.ActivityExtended__c + ' - ' + task2Ae);
        }

        List<Id> queryFilter = task2Ae.values();
        if (String.isBlank(actExtsQuery)) {
            actExtsQuery = 'SELECT ' + Utils.cebGetSOBJECTFieldsForQuery('ActivityExtended__c', globalDesc) + ' FROM ActivityExtended__c WHERE Id in:queryFilter';
        }


        // inizio nuovo codice 14/04/17 inserimento check permission
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_affidamento__c', globalDesc).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_lotto_associato__c', globalDesc).get('UPDATE')) {
            aes = Database.query(String.escapeSingleQuotes(actExtsQuery));
            System.debug('aes --> ' + aes);
        }
        // fine nuovo codice 14/04/17 inserimento check permission

        Map<Id, ActivityExtended__c> aesMap = new Map<Id, ActivityExtended__c>();
        for (ActivityExtended__c actExt : aes) {
            aesMap.put(actExt.Id, actExt);
        }
        Map<Id, ActivityExtended__c> task2AeObj = new Map<Id, ActivityExtended__c>();
        for (Id tskId : task2Ae.keySet()) {
            task2AeObj.put(tskId, aesMap.get(task2Ae.get(tskId)));
        }
        return task2AeObj;
    }
    /*** 20210512 GMameli - Code Review - End ***/

    public static Map<Id, ActivityExtended__c> getPraticaWithActivityExtended(List<Task> intasks) {
        List<Id> tasksIds = new List<Id>();
        for (Task temp : intasks) {
            tasksIds.add(temp.Id);
        }

        if (String.isBlank(tasksQuery)) {
            tasksQuery = 'SELECT ' + Utils.getSOBJECTFieldsForQuery('Task') + ' FROM Task WHERE Id in:tasksIds';
        }

        // inizio nuovo codice 14/04/17 inserimento check permission
        List<Task> tasks = new List<Task>();
        if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Count_of_Events__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Count_of_Tasks__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Durata_Effettiva__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_Fuori_SLA__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'SLA__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Tipo_esecuzione__c', gd).get('ACCESS')) {
            tasks = Database.query(String.escapeSingleQuotes(tasksQuery));
        }
        // fine nuovo codice 14/04/17 inserimento check permission
        Map<Id, Id> task2Ae = new Map<Id, Id>();
        Map<Id, Task> taskMap = new Map<Id, Task>();
        for (Task temp : tasks) {
            if (temp.ActivityExtended__c != null) task2Ae.put(temp.Id, temp.ActivityExtended__c);
            taskMap.put(temp.Id, temp);
        }
        List<Id> queryFilter = task2Ae.values();
        if (String.isBlank(actExtsQuery)) {
            actExtsQuery = 'SELECT ' + Utils.getSOBJECTFieldsForQuery('ActivityExtended__c') + ' FROM ActivityExtended__c WHERE Id in:queryFilter';
        }

        // inizio nuovo codice 14/04/17 inserimento check permission
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_affidamento__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_lotto_associato__c', gd).get('UPDATE')) {
            aes = Database.query(String.escapeSingleQuotes(actExtsQuery));
        }
        // fine nuovo codice 14/04/17 inserimento check permission

        Map<Id, ActivityExtended__c> aesMap = new Map<Id, ActivityExtended__c>();
        for (ActivityExtended__c tmp : aes) {
            aesMap.put(tmp.Id, tmp);
        }
        Map<Id, ActivityExtended__c> task2AeObj = new Map<Id, ActivityExtended__c>();
        for (Id tmp : taskMap.keySet()) {
            task2AeObj.put(taskMap.get(tmp).WhatId, aesMap.get(taskMap.get(tmp).ActivityExtended__c));
        }
        return task2AeObj;
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }

    public static List<SObject> sortTaskActivitiesOld(List<SObject> unsortedList) {
        List<SObject> sortedListA = new List<SObject>();
        List<SObject> sortedListB = new List<SObject>();
        for (SObject tmp : unsortedList) {
            if (tmp instanceof Task) {
                sortedListA.add(tmp);
            } else {
                sortedListB.add(tmp);
            }
        }
        sortedListB.addAll(sortedListA);
        return sortedListB;
    }

    public static List<SObject> sortTaskActivities(List<SObject> unsortedList) {
        List<SObject> sortedList = new List<SObject>();
        List<SObject> listObj;
        Map<String, List<sObject>> mapToSortObjects = new Map<String, List<sObject>>();
        for (SObject tmp : unsortedList) {
            listObj = new List<SObject>();
            String objName = tmp.getSObjectType().getDescribe().name;
            if (mapToSortObjects.containsKey(objName)) {
                listObj = mapToSortObjects.get(objName);
            }
            listObj.add(tmp);
            mapToSortObjects.put(objName, listObj);
        }

        for (String key : mapToSortObjects.keySet()) {
            sortedList.addAll(mapToSortObjects.get(key));
        }

        return sortedList;
    }

    public static string getExceptionInString(Exception e) {
        string errorString = '\n error:' + e.getmessage() + '\n line:' + e.getLineNumber() + '\n stack:' + e.getStackTraceString();
        return errorString;
    }

    //returns a list of picklist values with closed or open status
    public static List<String> getStatusList(String s) {
        List<String> statusList = new List<String>();
        List<SObject> mappingStatusList = new List<SObject>();
        String query2 = 'SELECT ' + String.escapeSingleQuotes(s) + ' FROM CRABB_DEV__mapping_status_pratica__mdt WITH SECURITY_ENFORCED';
        mappingStatusList = Database.query(query2);
        statusList = String.valueOf(mappingStatusList.get(0).get(s)).split('\\|');

        return statusList;

    }

    //used for Account scoring computation, returns a boolean after comparing 2 fields with the same field type
    public static boolean checkConditionFieldValue(object odb, object oconf, string condition, string fieldType) {
        Date date1, date2;
        Datetime dateTime1, dateTime2;
        If (fieldType.equalsIgnoreCase('date')) {
            date2 = Date.valueOf(String.valueOf(oconf));
            date1 = odb != null ? Date.valueOf(String.valueOf(odb)) : null;
        } else if (fieldType.equalsIgnoreCase('datetime')) {
            dateTime2 = datetime.valueOf(String.valueOf(oconf));
            dateTime1 = odb != null ? datetime.valueOf(String.valueOf(odb)) : null;
        } else if (fieldType.equalsIgnoreCase('decimal')) {
            odb = (odb != null) ? odb : '0';
        }

        if (condition == '<') {
            if (fieldType.equalsIgnoreCase('date')) return date1 < date2;
            if (fieldType.equalsIgnoreCase('datetime')) return dateTime1 < dateTime2;
            if (fieldType.equalsIgnoreCase('decimal')) return Double.valueOf(odb) < Double.valueOf(oconf);
            if (fieldType.equalsIgnoreCase('string')) return String.valueOf(odb) < String.valueOf(oconf);
        } else if (condition == '<=') {
            if (fieldType.equalsIgnoreCase('date')) return date1 <= date2;
            if (fieldType.equalsIgnoreCase('datetime')) return dateTime1 <= dateTime2;
            if (fieldType.equalsIgnoreCase('decimal')) return Double.valueOf(odb) <= Double.valueOf(oconf);
            if (fieldType.equalsIgnoreCase('string')) return String.valueOf(odb) <= String.valueOf(oconf);
        } else if (condition == '!=' || condition == '<>') {
            if (fieldType.equalsIgnoreCase('string') ||
                    fieldType.equalsIgnoreCase('boolean')) return String.valueOf(odb) != String.valueOf(oconf);
            if (fieldType.equalsIgnoreCase('date')) return date1 != date2;
            if (fieldType.equalsIgnoreCase('datetime')) return dateTime1 != dateTime2;
            if (fieldType.equalsIgnoreCase('decimal')) return Double.valueOf(odb) != Double.valueOf(oconf);
        } else if (condition == '>') {
            if (fieldType.equalsIgnoreCase('date')) return date1 > date2;
            if (fieldType.equalsIgnoreCase('datetime')) return dateTime1 > dateTime2;
            if (fieldType.equalsIgnoreCase('decimal')) return Double.valueOf(odb) > Double.valueOf(oconf);
            if (fieldType.equalsIgnoreCase('string')) return String.valueOf(odb) > String.valueOf(oconf);

        } else if (condition == '>=') {
            if (fieldType.equalsIgnoreCase('date')) return date1 >= date2;
            if (fieldType.equalsIgnoreCase('datetime')) return dateTime1 >= dateTime2;
            if (fieldType.equalsIgnoreCase('decimal')) return Double.valueOf(odb) >= Double.valueOf(oconf);
            if (fieldType.equalsIgnoreCase('string')) return String.valueOf(odb) >= String.valueOf(oconf);

        } else if (condition == '==' || condition == '=') {
            if (fieldType.equalsIgnoreCase('string') ||
                    fieldType.equalsIgnoreCase('boolean')) return String.valueOf(odb) == String.valueOf(oconf);
            if (fieldType.equalsIgnoreCase('date')) return date1 == date2;
            if (fieldType.equalsIgnoreCase('datetime')) return dateTime1 == dateTime2;
            if (fieldType.equalsIgnoreCase('decimal')) return Double.valueOf(odb) == Double.valueOf(oconf);
        } else if (condition == 'includes') {
            set<string> setOdb = new Set<string>(String.valueOf(odb).split(';'));
            set<string> setOconf = new Set<string>(String.valueOf(oconf).split(';'));
            map<string, string> mapOdb = getToMapFieldValue(setOdb);
            boolean inc = true;
            for (string s : setOconf) {
                if (mapOdb.get(s) == null) inc = false;
            }
            return inc;
        } else if (condition == 'IsIncluded') {
            set<string> setOdb = new Set<string>(String.valueOf(odb).split(';'));
            set<string> setOconf = new Set<string>(String.valueOf(oconf).split(';'));
            map<string, string> mapOconf = getToMapFieldValue(setOconf);
            boolean inc = true;
            for (string s : setOdb) {
                if (mapOconf.get(s) == null) {
                    inc = false;
                }
            }
            return inc;
        } else if (condition == 'escludes') {
            set<string> setOdb = new Set<string>(String.valueOf(odb).split(';'));
            set<string> setOconf = new Set<string>(String.valueOf(oconf).split(';'));
            map<string, string> mapOdb = getToMapFieldValue(setOdb);
            boolean inc = true;
            for (string s : setOconf) {
                if (inc && mapOdb.get(s) != null) {
                    inc = false;
                }
            }
            return inc;
        }
        return null;
    }

    private static map<string, string> getToMapFieldValue(set<string> setO) {
        map<string, string> mapOdb = new map<string, string>();
        for (string s : setO) mapOdb.put(s, s);
        return mapOdb;
    }

    public class BalanceException extends Exception {
    }

    public static Boolean checkOPFLSForErrorLog(String operation, Map<String, Schema.SObjectType> gd) {
        return (cebCheckObjPermission('Log__c', gd).get(operation)
                && cebCheckFLSPermission('Log__c', 'Class_Name__c', gd).get(operation)
                && cebCheckFLSPermission('Log__c', 'Method__c', gd).get(operation)
                && cebCheckFLSPermission('Log__c', 'Line_number__c', gd).get(operation)
                && cebCheckFLSPermission('Log__c', 'Error_code__c', gd).get(operation)
                && cebCheckFLSPermission('Log__c', 'Error__c', gd).get(operation)
                && cebCheckFLSPermission('Log__c', 'Message_Out__c', gd).get(operation)
                && cebCheckFLSPermission('Log__c', 'RecordTypeId', gd).get(operation)
                && cebCheckFLSPermission('Log__c', 'Name__c', gd).get(operation)
                && cebCheckFLSPermission('Log__c', 'info__c', gd).get(operation)
                && cebCheckFLSPermission('Log__c', 'Message__c', gd).get(operation)
                && cebCheckFLSPermission('Log__c', 'type__c', gd).get(operation));


    }

    /*
    This method takes as input the operation type, a Map with the Object API Name as key and a list of its related fields to check as value
    and global describe; it returns a Boolean resulting from object permission check and field level security checks
    */
    public static Boolean checkOPFLSForObjAndFields(String operation, Map<String, List<String>> objAndFields, Map<String, Schema.SObjectType> gd) {
        Boolean resultObjs = false;
        Boolean resultFields = false;

        for (String obj : objAndFields.keySet()) {
            System.debug('obj -->' + obj);

            resultObjs = cebCheckObjPermission(obj, gd).get(operation);
            System.debug('resultObjs -->' + resultObjs);
            List<String> fieldsList = objAndFields.get(obj);
            if (resultObjs) {
                for (String field : fieldsList) {
                    if (!field.contains(Utils.NAMESPACE) && field.contains('__r')) {
                        field = NAMESPACE +field;
                    }
                    if (field.containsIgnoreCase('__C')) {
                        field = field.trim();
                    }
                    if (field.containsIgnoreCase('(')) {
                        field = field.substringBetween('(', ')');
                    }
                    System.debug('field -->' + field);
                    if (field.containsIgnoreCase('__r'))
                        continue;

                    if (fieldsList.indexOf(field) == 0) {
                        resultFields = cebCheckFLSPermission(obj, field, gd).get(operation);
                        System.debug('resultFields 0 -->' + resultFields);
                    } else {
                        resultFields = resultFields && cebCheckFLSPermission(obj, field, gd).get(operation);
                        System.debug('resultFields Tot -->' + resultFields);
                    }
                }
            }
        }

        return (resultObjs && resultFields);
    }

}