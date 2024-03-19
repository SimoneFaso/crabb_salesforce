/* ---------------------------------------------------------------------------------------------------------------------
Name:            ListOfFieldsCSCTRL.cls
Description:
Test class:      TestListOfFieldsCTRL.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
16-Sep-2022  0.2      C.Sanna & R.Kurti    Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/
global with sharing class ListOfFieldsCSCTRL {

    public List<ListOfFields__c> listLOF { get; set; }
    public String obj { get; set; }
    public String title { get; set; }
    public String subTitle { get; set; }
    public Boolean show { get; set; }
    public List<SelectOption> listObject { get; set; }
    public List<String> listStrObject { get; set; }
    public String selectedObj { get; set; }
    public String selectedField { get; set; }
    public List<SelectOption> listFields { get; set; }
    public Map<String, String> listStrFields { get; set; }
    public Boolean selectedVisible { get; set; }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public Map<String, Integer> mapIdrecordOrder { get; set; }
    public String filePath { get; set; }

    public Map<String, List<ListOfFields__c>> mapTabFields { get; set; }

    public List<SelectOption> listTabObjOptions { get; set; }
    public List<SelectOption> listObjFieldOptions { get; set; }
    public String selectedTO { get; set; }
    public String selectedOF { get; set; }
    public Boolean selectedTOFvisible { get; set; }

    public static final Map<String, List<String>> mapObjTitleSub = new Map<String, List<String>>{
            'TAB' => new List<String>{
                    'Cruscotto Pratica', 'Configurazione TAB'
            },
            'PDF' => new List<String>{
                    'Estratto Conto', 'Configurazione PDF'
            },
            'CSVNEW' => new List<String>{
                    'Flussi Collector', 'Configurazione CSV'
            }
    };

    public static final Map<String, List<String>> mapObjAvailable = new Map<String, List<String>>{
            'PDF' => new List<String>{
                    Utils.NAMESPACE + 'Pratica__c', Utils.NAMESPACE + 'Movimento__c'
            },
            'CSVNEW' => new List<String>{
                    'Account', Utils.NAMESPACE + 'Pratica__c', Utils.NAMESPACE + 'Movimento__c'
            }
    };

    public static final Map<String, String> mapObjLabel = new Map<String, String>{
            Utils.NAMESPACE + 'Pratica__c' => 'Pratica',
            Utils.NAMESPACE + 'Movimento__c' => 'Movimento'
    };

    public static final Map<String, String> mapTabRecName = new Map<String, String>{
            'Expired Amounts Ageing' => '',
            'Statement of Account' => 'FMov',
            'Activities' => 'FTsk',
            'Repayment Plans' => 'FPdR',
            'Service Requests' => 'FSR0',
            'Service/Product Detail' => 'FSer',
            'Assignments' => 'Whatever',
            'Voices' => '',
            'Documentation' => 'FAtt',
            'Strategy' => '',
            'Chatter' => '',
            'Funded Statement of Account' => ''
    };

    /*public static final Map<String,Boolean> mapShowTF = new Map<String,Boolean>{
        'Expired Amounts Ageing' => false,
        'Statement of Account' => true,
        'Activities' => true,
        'Repayment Plans' => true,
        'Service Requests' => true,
        'Service/Product Detail' => true,
        'Assignments' => true,
        'Voices' => false,
        'Documentation' => true,
        'Strategy' => false,
        'Chatter' => false,
        'Funded Statement of Account' => false
    };*/

    public static final Map<String, String> mapTabObj = new Map<String, String>{
            'Statement of Account' => Utils.NAMESPACE + 'Movimento__c',
            'Activities' => 'Task',
            'Repayment Plans' => Utils.NAMESPACE + 'Piano_di_Rientro__c',
            'Service/Product Detail' => Utils.NAMESPACE + 'Servizio__c',
            'Assignments' => Utils.NAMESPACE + 'Affidamento__c',
            'Documentation' => 'Attachment',
            'Service Requests' => Utils.NAMESPACE + 'SR__c'
    };

    public Map<String, String> getMapTabRecName() {
        return mapTabRecName;
    }

    public Map<String, Boolean> getMapShowTF() {

        String count1 = 'SELECT COUNT() FROM ListOfFields__c WHERE Name Like \'FMov%\'';
        String count2 = 'SELECT COUNT() FROM ListOfFields__c WHERE Name Like \'FTsk%\'';
        String count3 = 'SELECT COUNT() FROM ListOfFields__c WHERE Name Like \'FPdr%\'';
        String count4 = 'SELECT COUNT() FROM ListOfFields__c WHERE Name Like \'FSR0%\'';
        String count5 = 'SELECT COUNT() FROM ListOfFields__c WHERE Name Like \'FSer%\'';
        String count6 = 'SELECT COUNT() FROM ListOfFields__c WHERE Name Like \'Whatever%\'';
        String count7 = 'SELECT COUNT() FROM ListOfFields__c WHERE Name Like \'FAtt%\'';

        Integer int1 = Database.countQuery(count1);
        Integer int2 = Database.countQuery(count2);
        Integer int3 = Database.countQuery(count3);
        Integer int4 = Database.countQuery(count4);
        Integer int5 = Database.countQuery(count5);
        Integer int6 = Database.countQuery(count6);
        Integer int7 = Database.countQuery(count7);

        Map<String, Boolean> mapShowTF = new Map<String, Boolean>();
        mapShowTF.put('Expired Amounts Ageing', false);
        if (int1 > 0) mapShowTF.put('Statement of Account', true);
        else mapShowTF.put('Statement of Account', false);
        if (int2 > 0) mapShowTF.put('Activities', true);
        else mapShowTF.put('Activities', false);
        if (int3 > 0) mapShowTF.put('Repayment Plans', true);
        else mapShowTF.put('Repayment Plans', false);
        if (int4 > 0) mapShowTF.put('Service Requests', true);
        else mapShowTF.put('Service Requests', false);
        if (int5 > 0) mapShowTF.put('Service/Product Detail', true);
        else mapShowTF.put('Service/Product Detail', false);
        if (int6 > 0) mapShowTF.put('Assignments', true);
        else mapShowTF.put('Assignments', false);
        mapShowTF.put('Voices', false);
        if (int7 > 0) mapShowTF.put('Documentation', true);
        else mapShowTF.put('Documentation', false);
        mapShowTF.put('Strategy', false);
        mapShowTF.put('Chatter', false);
        mapShowTF.put('Funded Statement of Account', false);

        return mapShowTF;
    }

    public ListOfFieldsCSCTRL() {

        obj = (ApexPages.currentPage().getParameters().get('object') != null && String.isNotBlank(ApexPages.currentPage().getParameters().get('object'))) ? ApexPages.currentPage().getParameters().get('object') : '';
        show = true;
        listFields = new List<SelectOption>();
        listFields.add(new SelectOption('', '--- None ---'));
        if (obj == null || String.isBlank(obj)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'No type selected (CSVNEW, TAB, PDF).'));
            show = false;
            return;
        }

        if (mapObjTitleSub.containsKey(obj)) {
            title = (mapObjTitleSub.get(obj))[0];
            subTitle = (mapObjTitleSub.get(obj))[1];
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid type. Available CSVNEW, TAB, PDF'));
            show = false;
            return;
        }

        String fieldString = Utils.getSOBJECTFieldsForQuery('ListOfFields__c');
        String nameLike = obj + '%';
        String queryString = 'SELECT ' + fieldString + ' FROM ListOfFields__c WHERE Name Like :nameLike ORDER BY Name ASC';
        listLOF = Database.query(String.escapeSingleQuotes(queryString));
        listLOF.sort();

        mapIdrecordOrder = new Map<String, Integer>();
        if (listLOF != null && !listLOF.isEmpty()) {
            for (ListOfFields__c lof : listLOF) {
                if (obj != null && obj.equalsIgnoreCase('PDF')) {
                    mapIdrecordOrder.put(lof.Id, Integer.valueOf(lof.Name.substring(lof.Name.lastIndexOf('_') + 1)));
                } else if (obj != null && obj.equalsIgnoreCase('CSVNEW')) {
                    mapIdrecordOrder.put(lof.Id, Integer.valueOf(lof.Name.substring(lof.Name.length() - 6)));
                }
            }
        }

        if (String.isNotBlank(obj) && !obj.equalsIgnoreCase('TAB')) retrieveListObject(obj);

        if (String.isNotBlank(obj) && obj.equalsIgnoreCase('TAB')) {
            retrieveTabFields();
            createTabObj();
        }
    }

    public void createTabObj() {
        listTabObjOptions = new List<SelectOption>();
        listTabObjOptions.add(new SelectOption('', '-- None --'));
        for (String str : mapTabObj.keySet()) {
            listTabObjOptions.add(new SelectOption(str, str));
        }
        listTabObjOptions.sort();

        listObjFieldOptions = new List<SelectOption>();
        listObjFieldOptions.add(new SelectOption('', '-- None --'));
    }

    public PageReference retrieveTabObj() {
        if (selectedTO != null && String.isNotBlank(selectedTO)) {
            String objSel = mapTabObj.get(selectedTO);
            listObjFieldOptions = new List<SelectOption>();
            listObjFieldOptions.add(new SelectOption('', '-- None --'));

            Map<String, Schema.SObjectField> temp = Schema.getGlobalDescribe().get(objSel).getDescribe().fields.getMap();
            for (String ss : temp.keySet()) {
                Schema.DescribeFieldResult dfr = temp.get(ss).getDescribe();
                if (dfr.isAccessible()) {
                    listObjFieldOptions.add(new SelectOption(dfr.getName(), dfr.getLabel()));
                }
            }

            if (selectedTO.equalsIgnoreCase('Activities')) {
                Map<String, Schema.SObjectField> tempAct = Schema.getGlobalDescribe().get(Utils.NAMESPACE + 'ActivityExtended__c').getDescribe().fields.getMap();
                for (String ss : tempAct.keySet()) {
                    Schema.DescribeFieldResult dfr = tempAct.get(ss).getDescribe();
                    if (dfr.isAccessible()) {
                        String tempOName = (dfr.getName().startsWith(Utils.NAMESPACE)) ? dfr.getName().split(Utils.NAMESPACE.right(7))[1] : dfr.getName();
                        listObjFieldOptions.add(new SelectOption('ActivityExtended__r.' + tempOName, 'ActivityExtended__r.' + dfr.getLabel()));
                    }
                }
            }

            listObjFieldOptions.sort();
        }
        return null;
    }

    public PageReference addTabField() {
        if (selectedOF != null && String.isNotBlank(selectedOF) && selectedTO != null && String.isNotBlank(selectedTO)) {

            if (Utils.cebCheckObjPermission('ListOfFields__c', gd).get('CREATE')
                    && Utils.cebCheckObjPermission('ListOfFields__c', gd).get('INSERT')) {
                ListOfFields__c newTabField = new ListOfFields__c();
                newTabField.Field__c = (selectedOF.startsWith(Utils.NAMESPACE)) ? selectedOF.replace(Utils.NAMESPACE, '') : selectedOF;
                newTabField.Object__c = (mapTabObj.get(selectedTO).startsWith(Utils.NAMESPACE)) ? mapTabObj.get(selectedTO).replace(Utils.NAMESPACE, '') : mapTabObj.get(selectedTO);
                newTabField.Show__c = selectedTOFvisible;

                String likeName = mapTabRecName.get(selectedTO) + '%';
                String splitName = mapTabRecName.get(selectedTO).substring(1);
                if (Utils.cebCheckObjPermission('ListOfFields__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ListOfFields__c','Name',gd).get('ACCESS')) {
                    List<ListOfFields__c> existingLof = [
                            SELECT Id, Name
                            FROM ListOfFields__c
                            WHERE Name LIKE :likeName
                            //WITH SECURITY_ENFORCED
                            ORDER BY Name DESC
                            LIMIT 1
                    ];

                    String newName = '';
                    if (existingLof != null && !existingLof.isEmpty()) {
                        List<String> tempSplitName = existingLof[0].Name.split(splitName);
                        Integer tempInt = Integer.valueOf(tempSplitName[1]) + 1;
                        newName = String.valueOf(tempInt);
                        /*while(newName.length()<7){
                        newName = '0'+newName;
                    }*/
                    } else {
                        newName = '1';
                    }

                    if (mapTabRecName.get(selectedTO).equalsIgnoreCase('FSR0')) {
                        while (newName.length() < 6) {
                            newName = '0' + newName;
                        }
                    } else if (!mapTabRecName.get(selectedTO).equalsIgnoreCase('Whatever')) {
                        while (newName.length() < 7) {
                            newName = '0' + newName;
                        }
                    }

                    newTabField.Name = mapTabRecName.get(selectedTO) + newName;
                    insert newTabField;
                }
            }
        }

        PageReference page = new PageReference('/apex/ListOfFieldsCS?object=' + obj);
        page.setRedirect(true);
        return page;
    }

    public PageReference updateRecords() {

        if (obj != null && String.isNotBlank(obj) && obj.equalsIgnoreCase('TAB')) {

            if (Utils.cebCheckObjPermission('ListOfFields__c', gd).get('UPDATE')) {

                update listLOF;

                List<ListOfFields__c> allList = new List<ListOfFields__c>();
                for (String str : mapTabFields.keySet()) {
                    allList.addAll(mapTabFields.get(str));
                }

                update allList;

            }

        } else {

            Set<Integer> tempSet = new Set<Integer>();
            Set<String> existingName = new Set<String>();
            Map<String, String> mapIdName = new Map<String, String>();

            if (listLOF != null && !listLOF.isEmpty()) {
                for (ListOfFields__c l : listLOF) {
                    mapIdName.put(l.Id, l.Name);
                    if (!tempSet.contains(mapIdrecordOrder.get(l.Id))) {
                        tempSet.add(mapIdrecordOrder.get(l.Id));
                    } else {
                        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Duplicated Order : ' + mapIdrecordOrder.get(l.Id) + ' . Please review and correct.'));
                        return null;
                    }
                }
            }

            for (String str : mapIdrecordOrder.keySet()) {
                String tempName = '';
                if (obj != null && obj.equalsIgnoreCase('PDF')) {
                    String tempOrder = String.valueOf(mapIdrecordOrder.get(str));
                    while (tempOrder.length() < 2) {
                        tempOrder = '0' + tempOrder;
                    }
                    tempName = 'Pdf_' + tempOrder;
                } else if (obj != null && obj.equalsIgnoreCase('CSVNEW')) {
                    //tempName = 'CSVNEW00000'+mapIdrecordOrder.get(str);
                    String tempOrder = String.valueOf(mapIdrecordOrder.get(str));
                    while (tempOrder.length() < 7) {
                        tempOrder += '0';
                    }
                    tempOrder = tempOrder.reverse();
                    tempName = 'CSVNEW' + tempOrder;
                }

                for (String st : mapIdName.keySet()) {
                    if (mapIdName.get(st).equalsIgnoreCase(tempName)) {
                        existingName.add(st);
                    }
                }
            }

            for (ListOfFields__c l : listLOF) {

                if (existingName != null && !existingName.isEmpty() && existingName.contains(l.Id)) {

                    if (obj != null && obj.equalsIgnoreCase('PDF')) {

                        l.Name = 'Pdf_' + System.now() + mapIdrecordOrder.get(l.Id);

                    } else if (obj != null && obj.equalsIgnoreCase('CSVNEW')) {

                        l.Name = 'CSV' + System.now() + mapIdrecordOrder.get(l.Id);

                    }

                } else {

                    if (obj != null && obj.equalsIgnoreCase('PDF')) {
                        if (Integer.valueOf(l.Name.substring(l.Name.lastIndexOf('_') + 1)) != mapIdrecordOrder.get(l.Id)) {
                            l.Name = l.Name.substring(0, l.Name.lastIndexOf('_') + 1) + mapIdrecordOrder.get(l.Id);
                        }
                    } else if (obj != null && obj.equalsIgnoreCase('CSVNEW')) {
                        if (Integer.valueOf(l.Name.substring(l.Name.length() - 6)) != mapIdrecordOrder.get(l.Id)) {
                            l.Name = l.Name.substring(0, l.Name.length() - 2) + mapIdrecordOrder.get(l.Id);
                        }
                    }
                }
            }

            if (Utils.cebCheckObjPermission('ListOfFields__c', gd).get('UPDATE')) {
                update listLOF;
            }

            if (existingName != null && !existingName.isEmpty()) {

                List<ListOfFields__c> tempLOF = new List<ListOfFields__c>();

                for (ListOfFields__c ll : listLOF) {
                    if (existingName.contains(ll.Id)) {
                        if (obj != null && obj.equalsIgnoreCase('PDF')) {

                            ll.Name = 'Pdf_' + mapIdrecordOrder.get(ll.Id);

                        } else if (obj != null && obj.equalsIgnoreCase('CSVNEW')) {

                            String tempOrder = String.valueOf(mapIdrecordOrder.get(ll.Id));

                            while (tempOrder.length() < 7) {
                                tempOrder += '0';
                            }

                            tempOrder = tempOrder.reverse();

                            ll.Name = 'CSVNEW' + tempOrder;

                        }
                        tempLOF.add(ll);
                    }
                }

                if (Utils.cebCheckObjPermission('ListOfFields__c', gd).get('CREATE')) {
                    update tempLOF;
                }

            }

        }

        PageReference page = new PageReference('/apex/ListOfFieldsCS?object=' + obj);
        page.setRedirect(true);
        return page;

    }

    public PageReference addRecord() {
        System.debug('@@@ ' + selectedObj + ' - ' + selectedField);
        try {
            if (selectedObj != null && selectedField != null &&
                    String.isNotBlank(selectedObj) && String.isNotBlank(selectedField)) {

                ListOfFields__c newLof = new ListOfFields__c();
                newLof.Show__c = selectedVisible;
                newLof.Field__c = selectedField.replaceFirst(Utils.NAMESPACE, '');

                Map<String, ListOfFields__c> mapLofs = ListOfFields__c.getAll();
                List<String> lofsName = new List<String>();

                if (obj.equalsIgnoreCase('CSVNEW')) {
                    newLof.Object__c = 'CSV||' + selectedObj.replaceFirst(Utils.NAMESPACE, '');

                    for (String str : mapLofs.keySet()) {
                        if (mapLofs.get(str).Name.startsWith('CSVNEW')) {
                            lofsName.add(mapLofs.get(str).Name);
                        }
                    }

                } else if (obj.equalsIgnoreCase('PDF')) {

                    newLof.Object__c = selectedObj.replaceFirst(Utils.NAMESPACE, '');

                    for (String str : mapLofs.keySet()) {
                        if (mapLofs.get(str).Name.startsWith('Pdf')) {
                            lofsName.add(mapLofs.get(str).Name);
                        }
                    }

                    newLof.Field_Label__c = listStrFields.get(selectedField);
                }

                lofsName.sort();
                List<String> tempSplit = new List<String>();
                String newName = '';

                if (obj.equalsIgnoreCase('CSVNEW')) {
                    if (lofsName != null && !lofsName.isEmpty() && lofsName.size() > 0) {
                        tempSplit = lofsName[lofsName.size() - 1].split('NEW');
                        Integer newIntName = Integer.valueOf(tempSplit[1]) + 1;
                        String tempOrder = String.valueOf(newIntName);
                        while (tempOrder.length() < 7) {
                            tempOrder += '0';
                        }
                        tempOrder = tempOrder.reverse();
                        newName = 'CSVNEW' + tempOrder;
                    } else {
                        newName = 'CSVNEW0000000';
                    }
                } else if (obj.equalsIgnoreCase('PDF')) {
                    if (lofsName != null && !lofsName.isEmpty() && lofsName.size() > 0) {
                        tempSplit = lofsName[lofsName.size() - 1].split('_');
                        Integer newIntName = Integer.valueOf(tempSplit[1]) + 1;
                        String tempOrder = String.valueOf(newIntName);
                        while (tempOrder.length() < 2) {
                            tempOrder = '0' + tempOrder;
                        }
                        newName = 'Pdf_' + tempOrder;
                    } else {
                        newName = 'Pdf_01';
                    }
                }

                //Integer newIntName = Integer.valueOf(lofsName[lofsName.size()-1].substring(lofsName[lofsName.size()-1].length()-2))+1;
                //String newName = lofsName[lofsName.size()-1].substring(0,lofsName[lofsName.size()-1].length()-2)+newIntName;

                newLof.Name = newName;

                if (Utils.cebCheckObjPermission('ListOfFields__c', gd).get('CREATE') && Utils.cebCheckObjPermission('ListOfFields__c', gd).get('INSERT')) {
                    insert newLof;
                }
            } else if (selectedObj == null || String.isBlank(selectedObj)) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please select an object.'));
                return null;
            } else if (selectedField == null || String.isBlank(selectedField)) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please select a field.'));
                return null;
            }
        } catch (Exception ex) {
            System.debug('@ Message : ' + ex.getMessage());
            System.debug('@ StackTrace : ' + ex.getStackTraceString());
        }

        PageReference page = new PageReference('/apex/ListOfFieldsCS?object=' + obj);
        page.setRedirect(true);
        return page;
    }

    public void retrieveListObject(String what) {

        listObject = new List<SelectOption>();
        listStrObject = new List<String>();
        listObject.add(new SelectOption('', '--- None ---'));
        if (what != null && String.isNotBlank(what)) {

            if (mapObjAvailable.containsKey(what)) {
                for (String str : mapObjAvailable.get(what)) {
                    if (mapObjLabel.containsKey(str)) {
                        listObject.add(new SelectOption(str, mapObjLabel.get(str)));
                    } else {
                        listObject.add(new SelectOption(str, str));
                    }
                    listStrObject.add(str);
                }
                listObject.sort();
            }
        }
    }

    public void retrieveListFields() {
        if (selectedObj != null && String.isNotBlank(selectedObj)) {
            listFields = new List<SelectOption>();
            listStrFields = new Map<String, String>();
            listFields.add(new SelectOption('', '--- None ---'));
            Map<String, Schema.SObjectField> temp = Schema.getGlobalDescribe().get(selectedObj).getDescribe().fields.getMap();
            for (String ss : temp.keySet()) {
                Schema.DescribeFieldResult dfr = temp.get(ss).getDescribe();
                if (dfr.isAccessible()) {
                    listStrFields.put(dfr.getName(), dfr.getLabel());
                    listFields.add(new SelectOption(dfr.getName(), dfr.getLabel()));
                }
            }

            listFields.sort();
        } else {
            listFields = new List<SelectOption>();
            listStrFields = new Map<String, String>();
        }
    }

    public void retrieveTabFields() {
        mapTabFields = new Map<String, List<ListOfFields__c>>();
        List<ListOfFields__c> tempFieldsList = new List<ListOfFields__c>();
        Map<String, ListOfFields__c> mapCS = ListOfFields__c.getAll();
        Map<String, List<ListOfFields__c>> tempMap = new Map<String, List<ListOfFields__c>>();

        for (String ss : mapTabRecName.keySet()) {
            if (mapTabRecName.get(ss) != null && String.isNotBlank(mapTabRecName.get(ss))) {
                tempMap.put(mapTabRecName.get(ss), new List<ListOfFields__c>());
            }
        }

        for (String str : mapCS.keySet()) {
            ListOfFields__c t = mapCS.get(str);
            if (tempMap.containsKey(t.Name.substring(0, 4))) {
                List<ListOfFields__c> tList = tempMap.get(t.Name.substring(0, 4));
                tList.add(t);
                tempMap.remove(t.Name.substring(0, 4));
                tempMap.put(t.Name.substring(0, 4), tList);
            } else if (t.Name.startsWith('Whatever') && tempMap.containsKey('Whatever')) {
                List<ListOfFields__c> tList = tempMap.get('Whatever');
                tList.add(t);
                tempMap.remove('Whatever');
                tempMap.put('Whatever', tList);
            }
        }

        for (String str : mapTabRecName.keySet()) {
            if (mapTabRecName.get(str) != null && String.isNotBlank(mapTabRecName.get(str))) {
                mapTabFields.put(str, tempMap.get(mapTabRecName.get(str)));
            }
        }

    }

    @RemoteAction
    global static String removeRecords(String param, String obj) {

        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        if (Utils.cebCheckObjPermission('ListOfFields__c', gd).get('DELETE')) {
            ListOfFields__c toRemove = new ListOfFields__c(Id = param);
            delete toRemove;
        }

        String result = '/apex/ListOfFieldsCS?object=' + obj;
        return result;
    }

}