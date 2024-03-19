/* ---------------------------------------------------------------------------------------------------------------------
Name:            ImportCusSettings.cls
Description:
Test class:      TestImportCusSettings.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                            First Version
16-Sep-2022  0.2      R.Kurti & C.Sanna     Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class ImportCusSettings {

    public static List<String> hierarchySettingUsers = new List<String>();
    public static List<String> hierarchySettingProfiles = new List<String>();

    public static void getData() {

        StaticResource Fields = [SELECT Id, Body FROM StaticResource WHERE Name = 'Fields' WITH SECURITY_ENFORCED];
        StaticResource Datas = [SELECT Id, Body FROM StaticResource WHERE Name = 'Datas' WITH SECURITY_ENFORCED];

        String bodyFields = Fields.Body.toString();
        String bodyDatas = Datas.Body.toString();

        Map<String, List<String>> fieldMap = getMapFromCSV(bodyFields);
        Map<String, List<String>> dataMap = getMapFromCSV(bodyDatas);

        Map<String, String> UsersMap = getUsersMap();
        Map<String, String> ProfilesMap = getProfilesMap();

        list<sobject> sobjList = new list<sobject>();
        sobject sobj;
        String FieldValue;

        //obj iteration
        for (String fieldMapKey : fieldMap.keyset()) {

            //get all setting fields
            list<String> objFields = fieldMap.get(fieldMapKey)[0].split('\\~');

            if (!getFlsCheck(fieldMapKey, objFields)) break;

            //get all setting records 
            list<String> objrecords = dataMap.get(fieldMapKey);

            for (String record : objrecords) {
                sobj = Schema.getGlobalDescribe().get(fieldMapKey).newSObject();
                list<String> FieldValues = record.split('\\~');
                for (integer i = 0; i < objFields.size(); i++) {

                    if (objFields[i] == 'SetupOwnerId' && FieldValues[i].contains('$$')) {
                        list<String> SetupOwnerIdFields = FieldValues[i].split('\\$\\$');

                        if (SetupOwnerIdFields[0] == 'User') {
                            FieldValue = UsersMap.get(SetupOwnerIdFields[1]);
                        } else if (SetupOwnerIdFields[0] == 'Profile') {
                            FieldValue = ProfilesMap.get(SetupOwnerIdFields[1]);
                        }

                    } else {
                        FieldValue = FieldValues[i];
                    }

                    if (String.isNotBlank(objFields[i]) && String.isNotBlank(FieldValues[i])) {

                        //SObjectType customSettingType = Schema.getGlobalDescribe().get(fieldMapKey);
                        String ObjName = Schema.describeSObjects(new String[]{
                                fieldMapKey
                        })[0].getName();
                        DescribeSObjectResult customSettingType = ((SObject) (Type.forName('Schema.' + ObjName).newInstance())).getSObjectType().getDescribe();
//                      Map<String,Schema.SObjectField> mfields = customSettingType.getDescribe().fields.getMap();
                        Map<String, Schema.SObjectField> mfields = customSettingType.fields.getMap();

                        Schema.DescribeFieldResult dfr = mfields.get(objFields[i]).getDescribe();
                        Schema.DisplayType t = dfr.getType();

                        if (String.valueOf(t).toLowerCase().equals('boolean')) {
                            sobj.put(objFields[i], Boolean.valueOf(FieldValue));
                        } else if (String.valueOf(t).toLowerCase().equals('decimal') || String.valueOf(t).toLowerCase().equals('currency')) {
                            sobj.put(objFields[i], Decimal.valueOf(FieldValue));
                        } else if (String.valueOf(t).toLowerCase().equals('date')) {
                            sobj.put(objFields[i], Date.valueOf(FieldValue));
                        } else if (String.valueOf(t).toLowerCase().equals('datetime')) {
                            sobj.put(objFields[i], (DateTime) JSON.deserialize('"' + FieldValue + '"', DateTime.class));
                        } else if (String.valueOf(t).toLowerCase().equals('integer')) {
                            sobj.put(objFields[i], Integer.valueOf(FieldValue));
                        } else if (String.valueOf(t).toLowerCase().equals('double')) {
                            sobj.put(objFields[i], Double.valueOf(FieldValue));
                        } else {
                            sobj.put(objFields[i], FieldValue);
                        }
                    }

                }
                sobjList.add(sobj);
            }
        }

        insert sobjList;

    }

    public static Map<String, List<String>> getMapFromCSV(String csv) {
        Map<String, List<String>> dataMap = new Map<String, List<String>>();
        List<String> sList;

        list<String> CsvRows = csv.split('\n');
        CsvRows.remove(0); //for removing header

        for (String row : CsvRows) {
            sList = new List<String>();
            list<String> CsvColumns = row.split(';');

            if (String.isNotBlank(CsvColumns[0]) && String.isNotBlank(CsvColumns[1])) {

                //check if hierarchy setting and find out if related to profile or to user
                if (CsvColumns[1].contains('$$')) {
                    list<String> fields = CsvColumns[1].split('\\~');
                    list<String> SetupOwnerIdFields = fields[0].split('\\$\\$');

                    if (SetupOwnerIdFields[0] == 'User') {
                        hierarchySettingUsers.add(SetupOwnerIdFields[1]);
                    } else if (SetupOwnerIdFields[0] == 'Profile') {
                        hierarchySettingProfiles.add(SetupOwnerIdFields[1]);
                    }

                }

                //add value to map
                if (dataMap.containsKey(CsvColumns[0])) {
                    sList = dataMap.get(CsvColumns[0]);
                }

                sList.add(CsvColumns[1]);
                dataMap.put(CsvColumns[0], sList);
            }

        }

        return dataMap;
    }

    public static Map<String, String> getUsersMap() {
        Map<String, String> resMap = new Map<String, String>();

        //if(Utils.checkFLSPermission('User', 'id').get('ACCESS') && Utils.checkFLSPermission('User', 'name').get('ACCESS')){

        list<User> userList = [select id, name from User where name in :hierarchySettingUsers WITH SECURITY_ENFORCED];
        for (User u : userList) {
            resMap.put(u.name, u.id);
        }

        //}
        return resMap;
    }

    public static Map<String, String> getProfilesMap() {
        Map<String, String> resMap = new Map<String, String>();

        //if(Utils.checkFLSPermission('Profile', 'id').get('ACCESS') && Utils.checkFLSPermission('Profile', 'name').get('ACCESS')){

        list<Profile> profList = [select id, name from Profile where name in :hierarchySettingProfiles WITH SECURITY_ENFORCED];
        for (Profile p : profList) {
            resMap.put(p.name, p.id);
        }

        //}
        return resMap;
    }

    public static Boolean getFlsCheck(String objtype, list<String> objFields) {
        if (String.isNotBlank(objtype)) {
            for (String s : objFields) {
                if (String.isNotBlank(s) && (!Utils.checkFLSPermission(objtype, s).get('ACCESS') || !Utils.checkFLSPermission(objtype, s).get('CREATE'))) {
                    return false;
                }
            }
        }

        return true;
    }


}