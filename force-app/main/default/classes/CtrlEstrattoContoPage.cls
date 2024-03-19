/* ---------------------------------------------------------------------------------------------------------------------
Name:            CtrlEstrattoContoPage.cls
Description:
Test class:

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
13-Sep-2022  0.2      C.Sanna & R. Kurti   Added WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class CtrlEstrattoContoPage {

    public Pratica__c currentPratica { get; set; }
    public List<Movimento__c> movList { get; set; }
    public String pratId { get; set; }
    public Boolean showMovList { get; set; }
    public Boolean showInfo { get; set; }
    public String filename { get; set; }
    public List<String> fieldsMovList { get; set; }
    public List<String> fieldsPratList { get; set; }
    public Map<String, String> fieldsLabel { get; set; }
    public Map<String, String> fieldsLabelNew { get; set; }
    public Boolean showLogo;
    public String filePath { get; set; }
    public Date dateNow { get; set; }
    public String timeNow { get; set; }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public Boolean getShowLogo() {
        //List<Document> docList = [SELECT Id FROM Document WHERE Name = 'ECLogo' LIMIT 1];
        List<Document> docList = [SELECT Id FROM Document WHERE Name = 'ECLogo' WITH SECURITY_ENFORCED LIMIT 1];
        filePath = '';
        if (docList != null && docList.size() > 0) {
            filePath = '/servlet/servlet.FileDownload?file=' + docList[0].Id;
            return true;
        }
        return false;
    }

    public CtrlEstrattoContoPage(ApexPages.StandardController stdController) {

        //String userLanguage = UserInfo.getLanguage().substring(0,2);
        //System.debug('@@@@@@@@@@@@@@@@@ account preferred language: '+ String.valueOf(currentPratica.Account__r.CRABB_DEV__Preferred_Language_for_Communications__c));

        String paramType = (ApexPages.currentPage().getParameters().get('type') != null && String.isNotBlank(ApexPages.currentPage().getParameters().get('type'))) ? ApexPages.currentPage().getParameters().get('type') : 'no';

        if (paramType.equalsIgnoreCase('preview')) {

            previewMethod();

        } else {

            if (stdController.getRecord() instanceof Pratica__c) {

                pratId = stdController.getId();
                //CRABB_DEV__Pratica__c prat = [SELECT Id, CRABB_DEV__Account__c, CRABB_DEV__Account__r.CRABB_DEV__Preferred_Language_for_Communications__c FROM CRABB_DEV__Pratica__c where Id = :pratId LIMIT 1];
                CRABB_DEV__Pratica__c prat = [
                        SELECT Id, CRABB_DEV__Account__c, CRABB_DEV__Account__r.CRABB_DEV__Preferred_Language_for_Communications__c
                        FROM CRABB_DEV__Pratica__c
                        where Id = :pratId
                        WITH SECURITY_ENFORCED
                        LIMIT 1
                ];

                String accLanguage = prat.CRABB_DEV__Account__r.CRABB_DEV__Preferred_Language_for_Communications__c;

                Datetime dnow = Datetime.now();
                dateNow = dnow.date();
                timeNow = String.valueOf(dnow.hour()) + ':' + String.valueOf(dnow.minute());

                fieldsLabel = new Map<String, String>();
                Map<String, ListOfFields__c> mapFields = ListOfFields__c.getAll();

                fieldsMovList = new List<String>();
                fieldsPratList = new List<String>();
                Map<Integer, String> orderMapPratFields = new Map<Integer, String>();
                Map<Integer, String> orderMapMovFields = new Map<Integer, String>();

                List<String> fPratList = new List<String>();
                List<String> fMovList = new List<String>();

                String fPratString = '';
                String fMoviString = '';

                for (String str : mapFields.keySet()) {
                    if (mapFields.get(str).Name.startsWith('Pdf_') &&
                            mapFields.get(str).Show__c &&
                            mapFields.get(str).Object__c.equalsIgnoreCase('Movimento__c')) {

                        orderMapMovFields.put(Integer.valueOf(mapFields.get(str).Name.substringAfter('_')), mapFields.get(str).Field__c);

                    } else if (mapFields.get(str).Name.startsWith('Pdf_') &&
                            mapFields.get(str).Show__c &&
                            mapFields.get(str).Object__c.equalsIgnoreCase('Pratica__c')) {

                        orderMapPratFields.put(Integer.valueOf(mapFields.get(str).Name.substringAfter('_')), mapFields.get(str).Field__c);
                    }

                    if (mapFields.get(str).Name.startsWith('Pdf_') && String.isNotBlank(mapFields.get(str).Field_Label__c) && accLanguage.equals('ITA')) {
                        fieldsLabel.put(mapFields.get(str).Field__c, mapFields.get(str).Field_Label__c);
                    } else if (mapFields.get(str).Name.startsWith('Pdf_') && String.isNotBlank(mapFields.get(str).Field_Label_eng__c) && accLanguage.equals('ENG')) {
                        fieldsLabel.put(mapFields.get(str).Field__c, mapFields.get(str).Field_Label_eng__c);
                    } else if (mapFields.get(str).Name.startsWith('Pdf_')) {
                        fieldsLabel.put(mapFields.get(str).Field__c, mapFields.get(str).Field__c);
                    }
                }

                List<Integer> tempOrder = new List<Integer>();
                tempOrder.addAll(orderMapPratFields.keySet());
                tempOrder.sort();
                for (Integer s : tempOrder) {
                    fieldsPratList.add(orderMapPratFields.get(s));
                }

                tempOrder.clear();
                tempOrder.addAll(orderMapMovFields.keySet());
                tempOrder.sort();
                for (Integer s : tempOrder) {
                    fieldsMovList.add(orderMapMovFields.get(s));
                }


                fPratString = String.join(fieldsPratList, ',');
                fMoviString = String.join(fieldsMovList, ',');


                if (Utils.checkObjPermission('Pratica__c').get('ACCESS')) {
                    //pratId = stdController.getId();

                    if (String.isNotBlank(fPratString)) {

                        if (!fpratString.containsIgnoreCase('Account_Codice_Cliente__c')) {
                            fPratString += ',Account_Codice_Cliente__c';
                        }
                        if (!fPratString.startsWithIgnoreCase('Name') && !fPratString.containsIgnoreCase(',Name')) {
                            fPratString += ',Name';
                        }
                        if (!fPratString.containsIgnoreCase('Servizio_Fornitura__c')) {
                            fPratString += ',Servizio_Fornitura__c';
                        }

                        String queryPratica = 'SELECT ' + String.escapeSingleQuotes(fPratString) + ' FROM Pratica__c WHERE Id =: pratId LIMIT 1';
                        System.debug('############################## stringa query: ' + queryPratica);
                        currentPratica = Database.query(queryPratica);

                        filename = 'EC_';
                        filename += currentPratica.Account_Codice_Cliente__c;
                        filename += '_' + currentPratica.Name;
                        filename += '_' + currentPratica.Servizio_Fornitura__c + '.pdf';

                        ApexPages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + filename);
                        showInfo = true;
                    } else {
                        showInfo = false;
                    }
                }

                if (Utils.cebCheckObjPermission('Movimento__c', gd).get('ACCESS')) {

                    if (String.isNotBlank(fMoviString)) {

                        if (!fMoviString.containsIgnoreCase('GG_di_Scaduto__c')) {
                            fMoviString += ',GG_di_Scaduto__c';
                        }

                        Integer count = Limits.getLimitQueryRows() - Limits.getQueryRows();
                        Integer lim = Math.min(count, 3000);
                        String query = 'SELECT ' + String.escapeSingleQuotes(fMoviString) + ' FROM Movimento__c WHERE Pratica__c =: pratId  AND Residuo__c > 0 ORDER BY Data_Scadenza__c DESC LIMIT :lim';

                        movList = Database.query(query);

                        showMovList = movList.size() > 0;
                    } else {
                        showMovList = false;
                    }

                }

            }

        }

    }

    public void previewMethod() {

        Datetime dnow = Datetime.now();
        dateNow = dnow.date();
        timeNow = String.valueOf(dnow.hour()) + ':' + String.valueOf(dnow.minute());
        showMovList = true;
        showInfo = true;

        fieldsLabel = new Map<String, String>();
        fieldsLabelNew = new Map<String, String>();
        Map<String, ListOfFields__c> mapFields = ListOfFields__c.getAll();

        fieldsMovList = new List<String>();
        fieldsPratList = new List<String>();
        Map<Integer, String> orderMapPratFields = new Map<Integer, String>();
        Map<Integer, String> orderMapMovFields = new Map<Integer, String>();

        List<String> fPratList = new List<String>();
        List<String> fMovList = new List<String>();

        String fPratString = '';
        String fMoviString = '';

        Map<String, Schema.SObjectField> tempMoveimentoFields = Schema.getGlobalDescribe().get(Utils.NAMESPACE + 'Movimento__c').getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> tempPraticaFields = Schema.getGlobalDescribe().get(Utils.NAMESPACE + 'Pratica__c').getDescribe().fields.getMap();
        system.debug('size' + tempMoveimentoFields.size());
        system.debug('size' + tempPraticaFields.size());
        for (String str : mapFields.keySet()) {
            system.debug('str--' + str);
            if (mapFields.get(str).Name.startsWith('Pdf_') &&
                    mapFields.get(str).Show__c &&
                    mapFields.get(str).Object__c.equalsIgnoreCase('Movimento__c')) {
                system.debug('M Name -- ' + mapFields.get(str).Name.substringAfter('_'));
                system.debug('M field c-- ' + mapFields.get(str).Field__c);
                orderMapMovFields.put(Integer.valueOf(mapFields.get(str).Name.substringAfter('_')), mapFields.get(str).Field__c);

            } else if (mapFields.get(str).Name.startsWith('Pdf_') &&
                    mapFields.get(str).Show__c &&
                    mapFields.get(str).Object__c.equalsIgnoreCase('Pratica__c')) {

                orderMapPratFields.put(Integer.valueOf(mapFields.get(str).Name.substringAfter('_')), mapFields.get(str).Field__c);
                system.debug('p Name -- ' + mapFields.get(str).Name.substringAfter('_'));
                system.debug(' p field c-- ' + mapFields.get(str).Field__c);
            }
            if (mapFields.get(str).Name.startsWith('Pdf_') && mapFields.get(str).Object__c.equalsIgnoreCase('Pratica__c') && mapFields.get(str).Show__c) {
                if (tempPraticaFields.containskey(Utils.NAMESPACE + mapFields.get(str).Field__c)) {
                    Schema.DescribeFieldResult dfr = tempPraticaFields.get(Utils.NAMESPACE + mapFields.get(str).Field__c).getDescribe();
                    fieldsLabel.put(mapFields.get(str).Field__c, dfr.getlabel());
                } else
                        fieldsLabel.put(mapFields.get(str).Field__c, mapFields.get(str).Field_Label__c);
            } else if (mapFields.get(str).Name.startsWith('Pdf_') && mapFields.get(str).Show__c && mapFields.get(str).Object__c.equalsIgnoreCase('Movimento__c')) {
                if (tempMoveimentoFields.containskey(Utils.NAMESPACE + mapFields.get(str).Field__c)) {
                    Schema.DescribeFieldResult dfr = tempMoveimentoFields.get(Utils.NAMESPACE + mapFields.get(str).Field__c).getDescribe();
                    fieldsLabel.put(mapFields.get(str).Field__c, dfr.getlabel());
                } else
                        fieldsLabel.put(mapFields.get(str).Field__c, mapFields.get(str).Field_Label__c);
            }
        }

        List<Integer> tempOrder = new List<Integer>();
        tempOrder.addAll(orderMapPratFields.keySet());
        tempOrder.sort();
        for (Integer s : tempOrder) {
            fieldsPratList.add(orderMapPratFields.get(s));
        }

        tempOrder.clear();
        tempOrder.addAll(orderMapMovFields.keySet());
        tempOrder.sort();
        for (Integer s : tempOrder) {
            fieldsMovList.add(orderMapMovFields.get(s));
        }


        fPratString = String.join(fieldsPratList, ',');
        fMoviString = String.join(fieldsMovList, ',');

        Map<String, Schema.SObjectField> tempMapFields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        Account previewAccount = new Account();
        for (String str : tempMapFields.keySet()) {

            Schema.DescribeFieldResult dfr = tempMapFields.get(str.toLowerCase()).getDescribe();
            String fld = dfr.getName();
            Schema.SoapType tempSoap = dfr.getSOAPType();

            if (!dfr.isCreateable() || !dfr.isAccessible()) {

            } else if (tempSoap.name().equalsIgnoreCase('Double')) {
                previewAccount.put(fld, 0);
            } else if (tempSoap.name().equalsIgnoreCase('Integer')) {
                previewAccount.put(fld, 0);
            } else if (tempSoap.name().equalsIgnoreCase('Boolean')) {
                previewAccount.put(fld, true);
            } else if (tempSoap.name().equalsIgnoreCase('Date')) {
                previewAccount.put(fld, Date.today());
            } else if (tempSoap.name().equalsIgnoreCase('DateTime')) {
                previewAccount.put(fld, DateTime.now());
            } else if (tempSoap.name().equalsIgnoreCase('ID')) {

            } else {
                previewAccount.put(fld, 'PREVIEW');
            }

        }

        tempMapFields = Schema.getGlobalDescribe().get(Utils.NAMESPACE + 'Pratica__c').getDescribe().fields.getMap();
        Pratica__c previewPratica = new Pratica__c();
        for (String str : tempMapFields.keySet()) {

            Schema.DescribeFieldResult dfr = tempMapFields.get(str.toLowerCase()).getDescribe();
            String fld = dfr.getName();
            system.debug('fld in practica' + fld.substringAfter('__'));
            Schema.SoapType tempSoap = dfr.getSOAPType();

            if (!dfr.isCreateable() || !dfr.isAccessible()) {

            } else if (tempSoap.name().equalsIgnoreCase('Double')) {
                previewPratica.put(fld, 0);
            } else if (tempSoap.name().equalsIgnoreCase('Integer')) {
                previewPratica.put(fld, 0);
            } else if (tempSoap.name().equalsIgnoreCase('Boolean')) {
                previewPratica.put(fld, true);
            } else if (tempSoap.name().equalsIgnoreCase('Date')) {
                previewPratica.put(fld, Date.today());
            } else if (tempSoap.name().equalsIgnoreCase('DateTime')) {
                previewPratica.put(fld, DateTime.now());
            } else if (tempSoap.name().equalsIgnoreCase('ID')) {

            } else {
                previewPratica.put(fld, 'PREVIEW');
            }

        }

        tempMapFields = Schema.getGlobalDescribe().get(Utils.NAMESPACE + 'Movimento__c').getDescribe().fields.getMap();
        Movimento__c previewMovimento = new Movimento__c();
        for (String str : tempMapFields.keySet()) {

            Schema.DescribeFieldResult dfr = tempMapFields.get(str.toLowerCase()).getDescribe();
            String fld = dfr.getName();
            Schema.SoapType tempSoap = dfr.getSOAPType();

            if (!dfr.isCreateable() || !dfr.isAccessible()) {

            } else if (tempSoap.name().equalsIgnoreCase('Double')) {
                previewMovimento.put(fld, 0);
            } else if (tempSoap.name().equalsIgnoreCase('Integer')) {
                previewMovimento.put(fld, 0);
            } else if (tempSoap.name().equalsIgnoreCase('Boolean')) {
                previewMovimento.put(fld, true);
            } else if (tempSoap.name().equalsIgnoreCase('Date')) {
                previewMovimento.put(fld, Date.today());
            } else if (tempSoap.name().equalsIgnoreCase('DateTime')) {
                previewMovimento.put(fld, DateTime.now());
            } else if (tempSoap.name().equalsIgnoreCase('ID')) {

            } else {
                previewMovimento.put(fld, 'PREVIEW');
            }

        }

        currentPratica = previewPratica;
        movList = new List<Movimento__c>();
        movList.add(previewMovimento);

    }

}