/* ---------------------------------------------------------------------------------------------------------------------
Name:            CtrlEstrattoContoAccount.cls
Description:
Test class:

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
13-Sep-2022  0.2      C.Sanna & R. Kurti   Added WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class CtrlEstrattoContoAccount {

    public Pratica__c currentPratica { get; set; }
    public Account currentAccount { get; set; }
    public List<Movimento__c> movList { get; set; }
    public String pratId { get; set; }
    public Boolean showMovList { get; set; }
    public Boolean showMovListForAccount { get; set; }
    public Boolean showInfo { get; set; }
    public String filename { get; set; }
    public List<String> fieldsMovList { get; set; }
    public List<String> fieldsPratList { get; set; }
    public List<String> fieldsAccList { get; set; }
    public List<Pratica__c> pratList { get; set; }
    public List<Movimento__c> movECList { get; set; }
    public Map<String, String> fieldsLabel { get; set; }
    public Map<String, String> fieldsLabelNew { get; set; }
    public Boolean showLogo;
    public String filePath { get; set; }
    public Date dateNow { get; set; }
    public String timeNow { get; set; }
    Public Map<String, SObjectType> gd = Schema.getGlobalDescribe();

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

    public CtrlEstrattoContoAccount(ApexPages.StandardController stdController) {

        String paramType = (ApexPages.currentPage().getParameters().get('type') != null && String.isNotBlank(ApexPages.currentPage().getParameters().get('type'))) ? ApexPages.currentPage().getParameters().get('type') : 'no';

        if (paramType.equalsIgnoreCase('preview')) {

            previewMethod();

        } else {

            if (stdController.getRecord() instanceof Pratica__c) {

                pratId = stdController.getId();
                //CRABB_DEV__Pratica__c prat = [SELECT Id, CRABB_DEV__Account__c, CRABB_DEV__Account__r.CRABB_DEV__Preferred_Language_for_Communications__c FROM CRABB_DEV__Pratica__c where Id = :pratId LIMIT 1];
                CRABB_DEV__Pratica__c prat = [SELECT Id, CRABB_DEV__Account__c, CRABB_DEV__Account__r.CRABB_DEV__Preferred_Language_for_Communications__c
                FROM CRABB_DEV__Pratica__c where Id = :pratId WITH SECURITY_ENFORCED LIMIT 1];
                String accLanguage = prat.CRABB_DEV__Account__r.CRABB_DEV__Preferred_Language_for_Communications__c;

                Datetime dnow = Datetime.now();
                dateNow = dnow.date();
                timeNow = String.valueOf(dnow.hour()) + ':' + String.valueOf(dnow.minute());

                fieldsLabel = new Map<String, String>();
                Map<String, ListOfFields__c> mapFields = ListOfFields__c.getAll();

                fieldsMovList = new List<String>();
                fieldsPratList = new List<String>();
                fieldsAccList = new List<String>();
                Map<Integer, String> orderMapPratFields = new Map<Integer, String>();
                Map<Integer, String> orderMapMovFields = new Map<Integer, String>();
                Map<Integer, String> orderMapAccFields = new Map<Integer, String>();

                List<String> fPratList = new List<String>();
                List<String> fMovList = new List<String>();

                String fPratString = '';
                String fAccString = '';
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
                    } else if (mapFields.get(str).Name.startsWith('Pdf_') &&
                            mapFields.get(str).Show__c &&
                            mapFields.get(str).Object__c.equalsIgnoreCase('Account')) {

                        orderMapAccFields.put(Integer.valueOf(mapFields.get(str).Name.substringAfter('_')), mapFields.get(str).Field__c);
                    }

                    if (mapFields.get(str).Name.startsWith('Pdf_') && String.isNotBlank(mapFields.get(str).Field_Label__c) && accLanguage.equals('ITA')) {
                        fieldsLabel.put(mapFields.get(str).Field__c, mapFields.get(str).Field_Label__c);
                    } else if (mapFields.get(str).Name.startsWith('Pdf_') && String.isNotBlank(mapFields.get(str).Field_Label_eng__c) && accLanguage.equals('ENG')) {
                        fieldsLabel.put(mapFields.get(str).Field__c, mapFields.get(str).Field_Label_eng__c);
                    } else if (mapFields.get(str).Name.startsWith('Pdf_')) {
                        fieldsLabel.put(mapFields.get(str).Field__c, mapFields.get(str).Field__c);
                    }
                }

                List<Integer> tempOrderPratica = new List<Integer>();
                List<Integer> tempOrderAccount = new List<Integer>();
                tempOrderPratica.addAll(orderMapPratFields.keySet());
                tempOrderAccount.addAll(orderMapAccFields.keySet());
                tempOrderPratica.sort();
                tempOrderAccount.sort();
                for (Integer s : tempOrderPratica) {
                    fieldsPratList.add(orderMapPratFields.get(s));
                }
                for (Integer s : tempOrderAccount) {
                    fieldsAccList.add(orderMapAccFields.get(s));
                }

                tempOrderPratica.clear();
                tempOrderPratica.addAll(orderMapMovFields.keySet());
                tempOrderPratica.sort();
                for (Integer s : tempOrderPratica) {
                    fieldsMovList.add(orderMapMovFields.get(s));
                }


                fPratString = String.join(fieldsPratList, ',');
                fAccString = String.join(fieldsAccList, ',');
                fMoviString = String.join(fieldsMovList, ',');


                Integer count;
                Integer lim;

                if (Utils.cebCheckObjPermission('Account', gd).get('ACCESS')) {
                    //pratId = stdController.getId();
                    System.debug('##### String.escapeSingleQuotes(fAccString) ' + String.escapeSingleQuotes(fAccString));
                    System.debug('##### String.escapeSingleQuotes(fMoviString) ' + String.escapeSingleQuotes(fMoviString));

                    if (String.isNotBlank(fAccString)) {

                        String accId = prat.Account__c;
                        String queryGetAccount = 'SELECT ' + String.escapeSingleQuotes(fAccString) + ' FROM Account WHERE Id =: accId LIMIT 1';
                        //String queryGetAccount = 'SELECT Id, Name FROM Account WHERE Id =: accId LIMIT 1';
                        currentAccount = Database.query(queryGetAccount);
                        filename = 'EC_';
                        filename += currentAccount.Name;
                        filename += '_.pdf';

                        String currAccount = currentAccount.id;
                        //String queryGetPraticheForAccount = 'SELECT Id, Movimento__c, ' + String.escapeSingleQuotes(fPratString) + ' from Pratica__c where id in: praticheIDsForAccount';
                        String queryGetPraticheForAccount = 'SELECT Id, Name from Pratica__c where Account__c = :currAccount';
                        pratList = Database.query(queryGetPraticheForAccount);

                        List<String> praIDsList = new List<String>();
                        for (Pratica__c pr : pratList) {
                            praIDsList.add(pr.id);
                        }

                        count = Limits.getLimitQueryRows() - Limits.getQueryRows();
                        lim = Math.min(count, 3000);

                        if( !fMoviString.containsIgnoreCase('GG_di_Scaduto__c') ){
                            fMoviString += ',GG_di_Scaduto__c';
                        }

                        String queryGetListMovimenti = 'SELECT ' + String.escapeSingleQuotes(fMoviString) + ' from Movimento__c where pratica__c in :praIDsList AND Residuo__c > 0 ORDER BY Data_Scadenza__c DESC LIMIT :lim';
                        movECList = Database.query(queryGetListMovimenti);

                        ApexPages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + filename);
                        showMovListForAccount = movECList.size() > 0 ? true : false;

                    } else {
                        showMovListForAccount = false;
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

        Map<String, Schema.SObjectField> tempMoveimentoFields = gd.get(Utils.NAMESPACE + 'Movimento__c').getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> tempPraticaFields = gd.get(Utils.NAMESPACE + 'Pratica__c').getDescribe().fields.getMap();

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

        List<Integer> tempOrderPratica = new List<Integer>();
        tempOrderPratica.addAll(orderMapPratFields.keySet());
        tempOrderPratica.sort();
        for (Integer s : tempOrderPratica) {
            fieldsPratList.add(orderMapPratFields.get(s));
        }

        tempOrderPratica.clear();
        tempOrderPratica.addAll(orderMapMovFields.keySet());
        tempOrderPratica.sort();
        for (Integer s : tempOrderPratica) {
            fieldsMovList.add(orderMapMovFields.get(s));
        }


        fPratString = String.join(fieldsPratList, ',');
        fMoviString = String.join(fieldsMovList, ',');

        Map<String, Schema.SObjectField> tempMapFields = gd.get('Account').getDescribe().fields.getMap();
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

        tempMapFields = gd.get(Utils.NAMESPACE + 'Pratica__c').getDescribe().fields.getMap();
        Pratica__c previewPratica = new Pratica__c();
        for (String str : tempMapFields.keySet()) {

            Schema.DescribeFieldResult dfr = tempMapFields.get(str.toLowerCase()).getDescribe();
            String fld = dfr.getName();
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

        tempMapFields = gd.get(Utils.NAMESPACE + 'Movimento__c').getDescribe().fields.getMap();
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