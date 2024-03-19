/*
*   CreatedBy: Klodjan Meta
*   description: il metodo contiene le variabili statiche per gestire i processi. Sono quelle variabili di configurazione dell'orkestratore
*                e utilizzate per determinare le logiche. Tutte le logiche di configurazione sono riportate all'interno di questa classe in modo
*                centralizzato ed adeguabile secondo le necessità
*/
/* ---------------------------------------------------------------------------------------------------------------------
Name:            OrkStatic.cls
Description:     Il metodo contiene le variabili statiche per gestire i processi. Sono quelle variabili di configurazione dell'orkestratore
*                e utilizzate per determinare le logiche. Tutte le logiche di configurazione sono riportate all'interno di questa classe in modo
*                centralizzato ed adeguabile secondo le necessità
Test class:      TestOrkStatic.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1      K.Meta                First Version
13-Sep-202   0.2      R.Kurti & C.Sanna     Added cebCheckObjPermission (security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class OrkStatic {//orkObjectOperations
    public class OrkStaticException extends Exception {
    }
    /*
    *   sono valirabili statiche per utility e per evitare
    *   areStrategiesLoaded
    *   areStrategiaFieldsLoaded 
    *   arePraticaFieldsLoaded
    *   areTasksRecordTypeLoaded
    *       :determinano se una certa operazione è già stata effettuata. Se si escono dal metodo senza fare ulteriori operazioni
    *   strategiaFieldsList / praticaFieldsList : Contengono i campi degli oggetti, i quali vengono recuperati dallo schema
    *   IdNameTasksRecordTyepesMap / NameIdTasksRecordTyepesMap: sono mappe per gestire i record type dei task, e recuperarli per nome o id
    */
    private static boolean areStrategiesLoaded = false;
    private static boolean areStrategiaFieldsLoaded = false;
    private static boolean arePraticaFieldsLoaded = false;
    private static boolean areTasksRecordTypeLoaded = false;
    public static List<String> strategiaFieldsList;
    public static List<String> praticaFieldsList;
    public static List<String> taskFieldsList;
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    public static Map<ID, Schema.RecordTypeInfo> IdNameTasksRecordTyepesMap;
    public static Map<string, Schema.RecordTypeInfo> NameIdTasksRecordTyepesMap;
    /*
    *   Sono varibili che fanno cache delle strategie configurate. 
    *   strategies= contiene tutti i record di tipo strategia che definiscono i processi configurati e che sono Attivi
    *   sPO= è una lista di id delle strategie ordinate per priorità e contiene solo gli id delle strategie standard
    *   le altre variabili sono delle mappe che contengono delle liste ordinate per priorità
    *   jAPO= <id attività , Lista id dei record jump automatici configurati per quella attività>
    *   jSPO= <id attività , Lista id dei record jump standard configurati per quella attività>
    *   cdiPO= id processo, lista delle condizioni di ingresso
    *   cduPO= id processo, condizioni di uscita dalla strategia
    *   nSPO= id attività, lista delle attività successive
    */
    public static Map<id, strategia__c> strategies;
    public static List<id> sPO;
    public static Map<id, List<id>> jAPO;
    public static Map<id, List<id>> jSPO;
    public static Map<id, List<id>> cdiPO;
    public static Map<id, List<id>> cduPO;
    public static Map<id, List<id>> nSPO;

    public static void setAreStrategiesLoaded(boolean bool) {
        areStrategiesLoaded = bool;
    }

    /*
    * i seguenti metodi servono per setting delle variabili statiche
    */
    public static void setPraticaFieldsList() {
        if (praticaFieldsList != null) return;
        SObjectType type = Schema.getGlobalDescribe().get(Utils.NAMESPACE + 'Pratica__c');
        Map<String, Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        praticaFieldsList = new List<string>();
        praticaFieldsList.addAll(mfields.keySet());
    }

    /*** 20210512 MSiotto - Review Code - Start ***/
    public static void cebSetPraticaFieldsList(Map<String, Schema.SObjectType> globalDesc) {
        if (praticaFieldsList != null) return;
        SObjectType type = globalDesc.get(Utils.NAMESPACE + 'Pratica__c');
        Map<String, Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        praticaFieldsList = new List<string>();
        praticaFieldsList.addAll(mfields.keySet());
    }
    /*** 20210512 MSiotto - Review Code - End ***/

    public static void setStrategiaFieldsList() {
        if (strategiaFieldsList != null) return;
        SObjectType type = Schema.getGlobalDescribe().get(Utils.NAMESPACE + 'Strategia__c');
        Map<String, Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        strategiaFieldsList = new List<string>();
        strategiaFieldsList.addAll(mfields.keySet());
    }

    /*** 20210510 MSiotto - Code Review - Start ***/
    public static void cebSetStrategiaFieldsList(Map<String, Schema.SObjectType> globalDesc) {
        if (strategiaFieldsList != null) return;
        SObjectType type = globalDesc.get(Utils.NAMESPACE + 'Strategia__c');
        Map<String, Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        strategiaFieldsList = new List<string>();
        strategiaFieldsList.addAll(mfields.keySet());
    }
    /*** 20210510 MSiotto - Code Review - End ***/

    /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
    /*
    public static void setTaskFieldsList() {
        if (taskFieldsList != null) return;
        SObjectType type = Schema.getGlobalDescribe().get('Task');
        Map<String, Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        taskFieldsList = new List<string>();
        taskFieldsList.addAll(mfields.keySet());
    }
    */
    /*** 20210513 MSiotto - Code Review - End Rimosso per nuova gestione CEB ***/

    /*** 20210512 MSiotto - Review Code - Start ***/
    public static void cebSetTaskFieldsList(Map<String, Schema.SObjectType> globalDesc) {
        if (taskFieldsList != null) return;
        SObjectType type = globalDesc.get('Task');
        Map<String, Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        taskFieldsList = new List<string>();
        taskFieldsList.addAll(mfields.keySet());
    }
    /*** 20210512 MSiotto - Review Code - End ***/

    /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
    /*
    * Il metodo recupera le pratiche associate ai record di task. dei TMap presenti
    */
    /*public static boolean retrievePratiche(Map<string, Task> tMap, map<string, Pratica__c> pMap) {
        set<id> setIdPratica = new set<id>();
        List<Pratica__c> pList = new List<Pratica__c>();
        for (Task t : tMap.Values()) {
            setIdPratica.add(t.WhatId);
        }
        if (praticaFieldsList == null) {
            SObjectType type = Schema.getGlobalDescribe().get(Utils.NAMESPACE + 'Pratica__c');
            Map<String, Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
            praticaFieldsList = new List<string>();
            praticaFieldsList.addAll(mfields.keySet());
        }
        // inizio nuovo codice 13/04/17 inserimento CheckFLSPermission
        if (Utils.checkFLSPermission('Pratica__c', 'Anzianit_Pratica__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Check_In_Lavorazione__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Data_Esecuzione_Processo_Mensile__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Data_Blocco__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Data_Chiusura__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Dettaglio_Stato__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Fascia_di_rischio__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Importo_Incasso_Consolidato__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Motivo_Blocco__c').get('ACCESS')) {
            string query = 'Select ' + utils.joinStrings(praticaFieldsList, ',');
            query += ' FROM Pratica__c where id in:setIdPratica';

            for (Pratica__c p : (List<Pratica__c>) database.query(query)) {
                pMap.put(p.id, p);
            }
        }
        // fine nuovo codice 13/04/17 inserimento CheckFLSPermission
        return true;
    }*/
    /*** 20210513 MSiotto - Code Review - End Rimosso per nuova gestione CEB ***/

    /*** 20210512 MSiotto - Review Code - Start ***/
    public static boolean cebRetrievePratiche(Map<string, Task> tMap, map<string, Pratica__c> pMap, Map<String, Schema.SObjectType> globalDesc) {
        set<id> setIdPratica = new set<id>();
        List<Pratica__c> pList = new List<Pratica__c>();
        for (Task t : tMap.Values()) {
            setIdPratica.add(t.WhatId);
        }
        if (praticaFieldsList == null) {
            SObjectType type = globalDesc.get(Utils.NAMESPACE + 'Pratica__c');
            Map<String, Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
            praticaFieldsList = new List<string>();
            praticaFieldsList.addAll(mfields.keySet());
        }
        // inizio nuovo codice 13/04/17 inserimento CheckFLSPermission
        if (Utils.cebCheckObjPermission('Pratica__c',globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Anzianit_Pratica__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Check_In_Lavorazione__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Esecuzione_Processo_Mensile__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Blocco__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Chiusura__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Dettaglio_Stato__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Incasso_Consolidato__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Motivo_Blocco__c', globalDesc).get('ACCESS')) {
            string query = 'Select ' + string.escapeSingleQuotes(utils.joinStrings(praticaFieldsList, ','));
            query += ' FROM Pratica__c where id in:setIdPratica';

            for (Pratica__c p : (List<Pratica__c>) database.query(query)) {
                pMap.put(p.id, p);
            }
        }
        // fine nuovo codice 13/04/17 inserimento CheckFLSPermission
        return true;
    }
    /*** 20210512 MSiotto - Review Code - End ***/

    public static void setTaskRecrdType() {
        if (areTasksRecordTypeLoaded) return;
        IdNameTasksRecordTyepesMap = Schema.SObjectType.ActivityExtended__c.getRecordTypeInfosById();
        NameIdTasksRecordTyepesMap = Schema.SObjectType.ActivityExtended__c.getRecordTypeInfosByName();
        areTasksRecordTypeLoaded = true;
    }

    public static void setPraticaFieldsLoaded() {
        if (arePraticaFieldsLoaded) return;
        strategiaFieldsList = new List<String>();
        SObjectType type = Schema.getGlobalDescribe().get(Utils.NAMESPACE + 'Pratica__c');
        Map<String, Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        strategiaFieldsList.addAll(mfields.keyset());
        arePraticaFieldsLoaded = true;
    }

    /*** 20210512 MSiotto - Review Code - Start ***/
    public static void cebSetPraticaFieldsLoaded(Map<String, Schema.SObjectType> globalDesc) {
        if (arePraticaFieldsLoaded) return;
        strategiaFieldsList = new List<String>();
        SObjectType type = globalDesc.get(Utils.NAMESPACE + 'Pratica__c');
        Map<String, Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        strategiaFieldsList.addAll(mfields.keyset());
        arePraticaFieldsLoaded = true;
    }
    /*** 20210512 MSiotto - Review Code - End ***/

    public static void initializeStrategiaObjects() {
        sPO = new List<id>();
        jSPO = new Map<id, List<id>>();
        jAPO = new Map<id, List<id>>();
        cdiPO = new Map<id, List<id>>();
        cduPO = new Map<id, List<id>>();
        nsPO = new Map<id, List<id>>();
    }

    //popola i dati con la strategia
    public static void retrieveStrategie() {
        if (areStrategiesLoaded) return;
        if (!areStrategiaFieldsLoaded) setStrategiaFieldsList();

        List<Strategia__c> strategieOrdinatePerPriorita = new List<Strategia__c>();
        string queryString = 'Select ';
        if (Utils.cebCheckObjPermission('Strategia__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'RC_Api_field_name__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'BaseType__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'CAP_Massimo__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'CAP_Minimo__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Cattivo_Pagatore__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'RC_Condition__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Data_attivazione__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Descrizione__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Email_sollecito_popolata__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Esito__c',gd).get('ACCESS')) {
            queryString += string.escapeSingleQuotes(utils.joinStrings(strategiaFieldsList, ','));
            queryString += ' FROM Strategia__c where Stato_testata__c=\'Attiva\' and recordType.DeveloperName != \'Storico\' order by priority__c ' ;

            strategieOrdinatePerPriorita = (List<Strategia__c>) database.query(queryString);
        }
        strategies = new Map<id, Strategia__c>(strategieOrdinatePerPriorita);

        initializeStrategiaObjects();

        for (Strategia__c s : strategieOrdinatePerPriorita) {
            setStrategiaStructure(s);
        }
        areStrategiesLoaded = true;
    }

    /*** 20210510 MSiotto - Code Review - Start ***/
    public static void cebRetrieveStrategie(Map<String, Schema.SObjectType> globalDesc) {
        if (areStrategiesLoaded) return;
        if (!areStrategiaFieldsLoaded) cebSetStrategiaFieldsList(globalDesc);

        List<Strategia__c> strategieOrdinatePerPriorita = new List<Strategia__c>();
        string queryString = 'Select ';
        if (Utils.cebCheckObjPermission('Strategia__c',globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'RC_Api_field_name__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'BaseType__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'CAP_Massimo__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'CAP_Minimo__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Cattivo_Pagatore__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'RC_Condition__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Data_attivazione__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Descrizione__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Email_sollecito_popolata__c', globalDesc).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Esito__c', globalDesc).get('ACCESS')) {
            queryString += string.escapeSingleQuotes(utils.joinStrings(strategiaFieldsList, ','));
            queryString += ' FROM Strategia__c where Stato_testata__c=\'Attiva\' and recordType.DeveloperName != \'Storico\' order by priority__c ' ;

            strategieOrdinatePerPriorita = (List<Strategia__c>) database.query(queryString);
        }
        strategies = new Map<id, Strategia__c>(strategieOrdinatePerPriorita);

        initializeStrategiaObjects();

        for (Strategia__c s : strategieOrdinatePerPriorita) {
            setStrategiaStructure(s);
        }
        areStrategiesLoaded = true;
    }
    /*** 20210510 MSiotto - Code Review - End ***/

    public static void setStrategiaStructure(Strategia__c s) {
        integer priority = integer.valueof(s.priority__c);
        if (priority == null) priority = 0;

        //In base al record type viene configurato il corrispettivo oggetto    
        if (s.record_type__c == 'Testata' && s.Tipo_Strategia__c == 'Standard') sPO.add(s.id); else if (s.record_type__c == 'Step') {
            if (nsPO.get(s.attivit_padre__c) == null) nsPO.put(s.attivit_padre__c, new List<id>());
            nsPO.get(s.attivit_padre__c).add(s.id);
        } else if (s.record_type__c == 'Condizioni_di_Ingresso') {
            if (cdiPO.get(s.testata__c) == null) cdiPO.put(s.testata__c, new List<id>());
            cdiPO.get(s.testata__c).add(s.id);
        } else if (s.record_type__c == 'Condizioni_di_Uscita') {
            if (cduPO.get(s.testata__c) == null) cduPO.put(s.testata__c, new List<id>());
            cduPO.get(s.testata__c).add(s.id);
        } else if (s.record_type__c == 'Salto') {
            if (s.isAutomaticJump__c) {
                if (jAPO.get(s.Jump_from__c) == null) jAPO.put(s.Jump_from__c, new List<id>());
                jAPO.get(s.Jump_from__c).add(s.id);
            } else {
                if (jSPO.get(s.Jump_from__c) == null) jSPO.put(s.Jump_from__c, new List<id>());
                jSPO.get(s.Jump_from__c).add(s.id);
            }
        }
    }
}