/* ---------------------------------------------------------------------------------------------------------------------
Name:            UploadDataTosObject.cls
Description:     Extension Controller for UploadEsitiCollector page.
                 It is used by a Collector to set Bulk Outcomes on Activities Extended for Tasks which belong to Entrusted Dossier.
                 To work properly:
                 - Task.Status = 'Non iniziata'
                 - ActivityExtended__r.E_da_affidare__c = true
                 - Inserted Outcome must be registered in Esiti_Collector__c custom setting
Test class:      TestUploadDataTosObject.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
21-Sep-2021  0.2      Claudio Sanna                   Replaced checkFLSPermission with cebCheckFLSPermission (Security Review)
16-Sep-2022  0.3      R.Kurti & C.Sanna               Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/

global with sharing class UploadDataTosObject {
    public Integer size { get; set; }
    public Integer sizeOK { get; set; }
    public Integer sizeDup { get; set; }
    public Integer sizeErr { get; set; }
    public String myString { get; set; }
    public Boolean status { get; set; }
    public String message { get; set; }
    public String SurveyId { get; set; }
    public String fName { get; set; }
    public String IdColl { get; set; }
    public List<Collector__c> collectorList { get; set; }
    public List<SelectOption> collectorItems { get; set; }
    public Map<String, String> customSettingEsitiCollector { get; set; }
    public String resultCsvId { get; set; }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public UploadDataTosObject() {
        SurveyId = ApexPages.currentPage().getParameters().get('id');
        System.debug('--> SurveyId: ' + SurveyId);
        myString = '';
        fName = '';
        size = 0;
        sizeOK = 0;
        sizeDup = 0;
        sizeErr = 0;
        status = false;
        message = '';
        collectorList = new List<Collector__c>([SELECT Id, Name FROM Collector__c WHERE User__c = :UserInfo.getUserId() WITH SECURITY_ENFORCED ORDER BY Name]);

        if (collectorList == null || collectorList.size() == 0) {
            collectorList = new List<Collector__c>([SELECT Id, Name FROM CRABB_DEV__Collector__c WITH SECURITY_ENFORCED ORDER BY Name]);
        }

        if (collectorList <> null && collectorList.size() > 0) {
            IdColl = collectorList.get(0).Id;
        }

        collectorItems = new List<SelectOption>();
        for (Collector__c collector : collectorList) {
            collectorItems.add(new SelectOption(collector.Id, collector.Name));
        }

        List<Esiti_Collector__c> csEsitiCollector = Esiti_Collector__c.getAll().values();
        customSettingEsitiCollector = new Map<String, String>();
        for(Esiti_Collector__c csEsito : csEsitiCollector) {
            customSettingEsitiCollector.put(csEsito.Esito__c.toUpperCase(), csEsito.Esito__c);
        }
    }

    public PageReference parseData() {
        try {
            System.debug('--> Source String: ' + myString);
            parseJSONString();
            confermaLista();
        } catch (Exception e) {
            status = false;
            message = e.getMessage();
            //System.debug('--> Exception: ' + message);
        }
        return null;
    }

    public class EsitiCollector {
        public String Pratica { get; set; }
        public String Esito { get; set; }
        public String Commento { get; set; }
        public String isFinal { get; set; }
        public String fName { get; set; }
    }

    public List<EsitiCollector> eisitoCollectorList { get; set; }
    public Map<String, String> praticheMap { get; set; }
    public Integer praticheTotal { get; set; }
     public Integer praticheOK { get; set; }

    public void parseJSONString() {
        fName = System.now().format('yyyyMMddHHmmssSSS') + '_' + fName;
        eisitoCollectorList = new List<EsitiCollector>();
        praticheMap = new Map<String, String>();

        JSONParser parser = JSON.createParser(myString);

        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        EsitiCollector ec = (EsitiCollector) parser.readValueAs(EsitiCollector.class);
                        ec.fName = fName;

                        eisitoCollectorList.add(ec);
                        praticheMap.put(ec.Pratica, 'KO - Attivita\' non esitabile');

                        //String s = JSON.serialize(ec); //(spm - acc);
                        //System.debug('--> Serialized : ' + s);
                        parser.skipChildren();
                    }
                }
            }
        }

        Set<String> praticheEsistenti = new Set<String>();
        //if (Utils.cebCheckFLSPermission('Pratica__c', 'Id', gd).get('ACCESS') && Utils.cebCheckFLSPermission('Pratica__c', 'name', gd).get('ACCESS')) {
        //if (Utils.checkFLSPermission('Pratica__c', 'Id').get('ACCESS') && Utils.checkFLSPermission('Pratica__c', 'name').get('ACCESS')) {
            List<Pratica__c> praticheEsistentiList = new List<Pratica__c>([SELECT Id, Name FROM Pratica__c WHERE Name IN :praticheMap.keySet() WITH SECURITY_ENFORCED ]);

            for (Pratica__c p : praticheEsistentiList) {
                praticheEsistenti.add(p.Name);
            }


        for (String pratica : praticheMap.keySet()) {
            if (!praticheEsistenti.contains(pratica)) {
                praticheMap.put(pratica, 'KO - Pratica non trovata');
            }
        }

        //System.debug('--> praticheMap: ' + praticheMap);
        //System.debug('--> eistoCollectorList: ' + eisitoCollectorList);
    }

    public String esitiCollectorChiusuraAffidiBatchId { get; set; }
    public AsyncApexJob aaj { get; set; }
    public Boolean batchRunning { get; set; }
    public Integer countTask { get; set; }
    public String currentStep { get; set; }


    public PageReference confermaLista() {

        Set<String> praticheSet = praticheMap.keySet();
        praticheOK = 0;
        //System.debug('--> praticheSet: ' + praticheSet);

        if (Utils.cebCheckObjPermission('Task',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c', gd).get('ACCESS')
                && Utils.cebCheckObjPermission('ActivityExtended__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Scelta_utente__c', gd).get('ACCESS')) {
        //if (Utils.checkFLSPermission('Task', 'ActivityExtended__c').get('ACCESS') && Utils.checkFLSPermission('ActivityExtended__c', 'Scelta_utente__c').get('ACCESS')) {
            String taskWhereClause = 'WHERE What.Name IN :praticheSet AND Status IN (\'Non Iniziata\') AND ActivityExtended__r.E_da_affidare__c = true';
            String queryUPD = 'SELECT Id, Status, ActivityExtended__r.Scelta_utente__c, What.Name FROM Task ' + taskWhereClause;

            List<Task> taskUPD = new List<Task>();
            if (Utils.cebCheckObjPermission('Task',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'SLA__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Status', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Type', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Subject', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c', gd).get('ACCESS')) {
            /*if (Utils.checkFLSPermission('Task', 'SLA__c').get('ACCESS')
                    && Utils.checkFLSPermission('Task', 'Status').get('ACCESS')
                    && Utils.checkFLSPermission('Task', 'Type').get('ACCESS')
                    && Utils.checkFLSPermission('Task', 'Subject').get('ACCESS')
                    && Utils.checkFLSPermission('Task', 'ActivityExtended__c').get('ACCESS')) {*/
                taskUPD = Database.query(queryUPD);
            }

            //System.debug('--> taskUPD: ' + taskUPD);

            Map<Id, ActivityExtended__c> task2obj = Utils.getTaskWithActivityExtended(taskUPD);
            List<ActivityExtended__c> activityExtendedList = new List<ActivityExtended__c>();
            Set<Id> finalTaskIds = new Set<Id>();
            Set<Id> finalPraticaIds = new Set<Id>();

            for (Task t : taskUPD) {
                for (EsitiCollector ec : eisitoCollectorList) {
                    if (ec.Pratica == t.What.Name) {

                        String esito;

                        if (ec.isFinal != null && ec.isFinal.trim().toLowerCase() == 'true') {

                            esito = customSettingEsitiCollector.get(ec.Esito.toUpperCase());

                            if(esito != null) {
                                finalTaskIds.add(t.Id);
                                finalPraticaIds.add(t.WhatId);
                                praticheMap.put(ec.Pratica, 'OK Final');
                                praticheOK++;
                            }
                            else {
                                esito = ec.Esito;
                                praticheMap.put(ec.Pratica, 'KO - Esito finale non previsto: ' + esito);
                            }
                        }
                        else {
                            esito = ec.Esito;
                            praticheMap.put(ec.Pratica, 'OK Partial');
                            praticheOK++;
                        }

                        ActivityExtended__c ae = task2obj.get(t.Id);
                        if (ae != null) {
                            ae.Esito__c = esito;
                            ae.Note_Collector__c = ec.Commento;
                            ae.SubjectNew__c = ec.fName;
                            activityExtendedList.add(ae);
                        }
                    }
                }
            }

            //System.debug('--> praticheMap 2: ' + praticheMap);
            System.debug('--> finalTaskIds: ' + finalTaskIds);
            System.debug('--> finalPraticaIds: ' + finalPraticaIds);

            resultCsvId = FileEsitiUploadController.attachBlob(IdColl, '', (fName.contains('.xlsx') ? fName.substring(0, fName.lastIndexOf('.')) : fName) + '.csv', 'text/csv', getResultCsv()); //String parentId, String attachmentId, String fileName, String contentType, String base64BlobValue

            if (Utils.cebCheckObjPermission('ActivityExtended__c',gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Scelta_utente__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Esito__c', gd).get('UPDATE')) {
            //if (Utils.checkFLSPermission('ActivityExtended__c', 'Scelta_utente__c').get('UPDATE') && Utils.checkFLSPermission('ActivityExtended__c', 'Esito__c').get('UPDATE')) {
                update activityExtendedList;

                if (finalTaskIds != null && finalTaskIds.size() > 0 && finalPraticaIds != null && finalPraticaIds.size()>0) 
                {
                    esitiCollectorChiusuraAffidiBatchId = Database.executeBatch(new EsitiCollectorChiusuraAffidiBatch(new List<Id>(finalTaskIds),new List<Id>(finalPraticaIds)),20);
                    //System.debug('--> esitiCollectorChiusuraAffidiBatchBatchId: ' + esitiCollectorChiusuraAffidiBatchId);
                    aaj = [SELECT Id,Status,ExtendedStatus,CompletedDate,CreatedDate,TotalJobItems,JobItemsProcessed FROM AsyncApexJob WHERE Id = :esitiCollectorChiusuraAffidiBatchId LIMIT 1];
                    batchRunning = true;
                }
            }

            currentStep = '2';
            countTask = taskUPD.size();
            praticheTotal = praticheMap.size();
            //System.debug('--> countTask: ' + countTask);
        }

        return null;
    }

    public void empty() {
        aaj = [SELECT Id,Status,ExtendedStatus,CompletedDate,CreatedDate,TotalJobItems,JobItemsProcessed FROM AsyncApexJob WHERE Id = :esitiCollectorChiusuraAffidiBatchId LIMIT 1];
        //System.debug('--> aaj: ' + aaj);
        if (aaj.Status.equalsIgnoreCase('Completed') || aaj.Status.equalsIgnoreCase('Aborted') || aaj.Status.equalsIgnoreCase('Failed')) {
            batchRunning = false;
        }
    }

    private String getResultCsv() {

        //CSV Header
        String resultCsv = 'Pratica,Esito Caricamento\n';

        //CSV rows
        for (String pratica : praticheMap.keySet()) {
            resultCsv = resultCsv + '"' + pratica + '","' + praticheMap.get(pratica) + '"\n';
        }

        //System.debug('--> resultCsv: ' + resultCsv);
        return EncodingUtil.base64Encode(Blob.valueOf(resultCsv));
    }
 }