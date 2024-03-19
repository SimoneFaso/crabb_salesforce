/* ---------------------------------------------------------------------------------------------------------------------
Name:            CRABB_FlussiCollectorMapNewCTRL.cls
Description:
Test class:      CRABB_FlussiCollectorMapNewCTRL_Test.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
09-Jul-2020  0.1      M.Sala                          First Version
13-Sep-2022  0.2      R.Kurti & C.Sanna               Added WITH SECURITY ENFORCED and added cebCheckObjPermissions (security review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class CRABB_FlussiCollectorMapNewCTRL
{
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    public static final Map<String,String> mapObjLabel = new Map<String,String>
    {
            Utils.NAMESPACE+'Pratica__c' => 'Pratica',
            Utils.NAMESPACE+'Movimento__c' => 'Movimento'
    };

    public static final Map<String,List<String>> mapObjAvailable = new Map<String,List<String>>
    {
            'PDF' => new List<String>{Utils.NAMESPACE+'Pratica__c',Utils.NAMESPACE+'Movimento__c'},
            'CSVNEW' => new List<String>{'Account',Utils.NAMESPACE+'Pratica__c',Utils.NAMESPACE+'Movimento__c'}
    };

    /* Functions For Lightning Web Components */

    @AuraEnabled(cacheable=true)
    public static String getListObjectStatic (String what)
    {
        Map<String, String> listObject = new Map<String, String>();

        List<String> listStrObject = new List<String>();

        if(what != null && String.isNotBlank(what)){

            if(mapObjAvailable.containsKey(what)){

                //we will have {name, value}
                for(String str : mapObjAvailable.get(what)){
                    if(mapObjLabel.containsKey(str)){
                        listObject.put(mapObjLabel.get(str), str);
                    }else{
                        listObject.put(str, str);
                    }
                    listStrObject.add(str);
                }

            }
        }

        return JSON.serialize(listObject);
    }

    @AuraEnabled(cacheable=true)
    public static String retrieveListFieldsStatic(String selectedObj)
    {
        if(selectedObj != null && String.isNotBlank(selectedObj))
        {
            Map<String, String> listFields = new Map<String, String>();

            Map<String, Schema.SObjectField> temp = Schema.getGlobalDescribe().get(selectedObj).getDescribe().fields.getMap();

            for(String ss : temp.keySet()){
                Schema.DescribeFieldResult dfr = temp.get(ss).getDescribe();
                if(dfr.isAccessible()){

                    listFields.put(dfr.getLabel(), dfr.getName());
                }
            }
            return JSON.serialize(listFields);
        }

        return null;
    }

    @AuraEnabled
    public static String retrieveListOfFieldsRecords(String selectedObj)
    {
        List<ListOfFields__c> listLOF;

        String fieldString = String.escapeSingleQuotes(Utils.getSOBJECTFieldsForQuery('ListOfFields__c'));
        String nameLike = selectedObj+'%';
        String queryString = 'SELECT ' + fieldString + ' FROM ListOfFields__c WHERE Name Like :nameLike ORDER BY Name ASC';
        listLOF = Database.query(queryString);
        listLOF.sort();

        return JSON.serialize(listLOF);
    }

    @AuraEnabled
    public static Boolean addCSVNEWRecord (String selectedObj, String selectedField, Boolean selectedVisible)
    {
        try
        {
            if( selectedObj != null && selectedField != null &&
                    String.isNotBlank(selectedObj) && String.isNotBlank(selectedField) )
            {
                ListOfFields__c newLof = new ListOfFields__c();
                newLof.Show__c = selectedVisible;
                newLof.Field__c = selectedField.replaceFirst(Utils.NAMESPACE, '');

                Map<String,ListOfFields__c> mapLofs = ListOfFields__c.getAll();
                List<String> lofsName = new List<String>();

                newLof.Object__c = 'CSV||'+selectedObj.replaceFirst(Utils.NAMESPACE, '');

                for(String str : mapLofs.keySet()){
                    if(mapLofs.get(str).Name.startsWith('CSVNEW')){
                        lofsName.add(mapLofs.get(str).Name);
                    }
                }

                Map<String,String> listStrFields = new Map<String,String>();

                Map<String, Schema.SObjectField> temp = Schema.getGlobalDescribe().get(selectedObj).getDescribe().fields.getMap();

                for(String ss : temp.keySet())
                {
                    Schema.DescribeFieldResult dfr = temp.get(ss).getDescribe();
                    if(dfr.isAccessible())
                    {
                        listStrFields.put(dfr.getName(),dfr.getLabel());
                    }
                }

                newLof.Field_Label__c = listStrFields.get(selectedField);

                lofsName.sort();
                List<String> tempSplit = new List<String>();
                String newName = '';

                if(lofsName != null && !lofsName.isEmpty() && lofsName.size() > 0)
                {
                    tempSplit = lofsName[lofsName.size()-1].split('NEW');
                    Integer newIntName = Integer.valueOf(tempSplit[1])+1;
                    String tempOrder = String.valueOf(newIntName);
                    while(tempOrder.length()<7)
                    {
                        tempOrder += '0';
                    }

                    tempOrder = tempOrder.reverse();
                    newName = 'CSVNEW'+tempOrder;
                }
                else
                {
                    newName = 'CSVNEW0000000';
                }

                newLof.Name = newName;

                if(Utils.cebCheckObjPermission('ListOfFields__c', gd).get('CREATE') && Utils.cebCheckObjPermission('ListOfFields__c', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('ListOfFields__c', 'Field_Label__c', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('ListOfFields__c', 'Show__c', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('ListOfFields__c', 'Field__c', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('ListOfFields__c', 'Object__c', gd).get('INSERT')) {
                    insert newLof;
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return false;
            }
        }
        catch(Exception ex)
        {
            System.debug('@ Message : '+ex.getMessage());
            System.debug('@ StackTrace : '+ex.getStackTraceString());

            return false;
        }
    }

    @AuraEnabled
    public static String getListStrFieldsReversed(String selectedObj)
    {
        Map<String,String> listStrFields = new Map<String,String>();

        Map<String, Schema.SObjectField> temp = Schema.getGlobalDescribe().get(selectedObj).getDescribe().fields.getMap();

        for(String ss : temp.keySet())
        {
            Schema.DescribeFieldResult dfr = temp.get(ss).getDescribe();
            if(dfr.isAccessible())
            {
                listStrFields.put(dfr.getLabel(), dfr.getName());
            }
        }

        return JSON.serialize(listStrFields);
    }

    @AuraEnabled
    public static Boolean removeRecordsLightning(String objectId)
    {
        if(Utils.cebCheckObjPermission('ListOfFields__c', gd).get('DELETE')) {
            ListOfFields__c toRemove = new ListOfFields__c(Id=objectId);
            delete toRemove;
        }

        return true;
    }

    @AuraEnabled
    public static Boolean rearrangeRecordsLightning(String records)
    {
        Map<String, Object> newNamesMap = (Map<String, Object>) JSON.deserializeUntyped(records);

        // getting all the fields that need to be adjusted
        List<ListOfFields__c> fields = [select Id, Name from ListOfFields__c where Id in:newNamesMap.keySet() WITH SECURITY_ENFORCED];

        if(fields.isEmpty())
        {
            return null;
        }

        // adding different names to the fields so no FIELD_INTEGRITY_EXCEPTION is thrown
        for (ListOfFields__c lof: fields)
        {
            lof.Name = 'temp'+lof.Id;
        }
        if (Utils.cebCheckObjPermission('ListOfFields__c', gd).get('UPDATE')) {
            update fields;
        }
        //update fields;

        // updating the names with the proper ordering
        for (ListOfFields__c lof: fields)
        {
            lof.Name = newNamesMap.get(lof.Id).toString();
        }

        //update fields;
        if (Utils.cebCheckObjPermission('ListOfFields__c', gd).get('UPDATE')) {
            update fields;
        }

        return true;
    }

    @AuraEnabled
    public static String updateRecordsLightning(String records)
    {
        List<ListOfFields__c> objectsToSave = (List<ListOfFields__c>) JSON.deserialize(records, List<ListOfFields__c>.class);

        List<ListOfFields__c> existingFields;

        String fieldString = String.escapeSingleQuotes(Utils.getSOBJECTFieldsForQuery('ListOfFields__c'));
        String nameLike = 'CSVNEW'+'%';
        String queryString = 'SELECT '+fieldString+' FROM ListOfFields__c WHERE Name Like :nameLike ORDER BY Name ASC';
        existingFields = Database.query(queryString);
        existingFields.sort();

        Map<String,Integer> mapIdrecordOrder = new Map<String,Integer>();

        if(existingFields != null && !existingFields.isEmpty())
        {
            for(ListOfFields__c lof : existingFields)
            {
                mapIdrecordOrder.put(lof.Id,Integer.valueOf(lof.Name.substring(lof.Name.length()-6)));
            }
        }

        Set<Integer> tempSet = new Set<Integer>();
        Set<String> existingName = new Set<String>();
        Map<String,String> mapIdName = new Map<String,String>();

        if(objectsToSave != null && !objectsToSave.isEmpty())
        {
            for(ListOfFields__c l : objectsToSave)
            {
                mapIdName.put(l.Id,l.Name);

                if(!tempSet.contains(mapIdrecordOrder.get(l.Id)))
                {
                    tempSet.add(mapIdrecordOrder.get(l.Id));
                }
                else
                {
                    return '{"error": "Duplicate record error!"}';
                }
            }
        }

        //update objectsToSave;
        if (Utils.cebCheckObjPermission('ListOfFields__c', gd).get('UPDATE')) {
            update objectsToSave;
        }
        return '{"success":"Records updated"}';
    }
    /* End Of Functions For Lightning Web Components */
}