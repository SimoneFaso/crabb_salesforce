/* ---------------------------------------------------------------------------------------------------------------------
Name:            DataMapper.cls
Description:     Controller for DataMapper Page (Crabb Configuration - Balance Integration Layer)
Test class:      TestDataMapper.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
21-Nov-2016  0.1                                      First Version
02-Mar-2021  0.2      G.Mameli & C.Sanna              Modified getSourceObjectsName method
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class DataMapper {
    public String selObject { get; set; }
    public List<SelectOption> listOfFields { get; set; }
    public List<String> listSourceObjects { get; set; }
    public List<String> listTargetObjects { get; set; }
    public String SourceObj { get; set; }
    public String TargetObj { get; set; }
    public String SourceField { get; set; }
    public String TargetField { get; set; }
    public String mappingId { get; set; }
    public Boolean isRelationValid { get; set; }
    public List<Mapping__c> currRelations { get; set; }
    public String NAMESPACE { get; set; }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();


    public DataMapper() {
        NAMESPACE = Utils.NAMESPACE;

        if (Utils.cebCheckObjPermission('Mapping__c',gd).get('ACCESS') && Utils.cebCheckFLSPermission('Mapping__c', 'SourceObj__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'TargetObj__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'SourceField__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'TargetField__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'SourceFieldType__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'TargetFieldType__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'isUpsertKey__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'md5HashKey__c',gd).get('ACCESS')) {

            currRelations = [SELECT Id,SourceObj__c,TargetObj__c,SourceField__c,TargetField__c,SourceFieldType__c,TargetFieldType__c,isUpsertKey__c,md5HashKey__c
            FROM Mapping__c ORDER BY CreatedDate Desc LIMIT 1000];
            isRelationValid = checkExternalKey(currRelations);
        }
    }

    /* -----------------------------------------------------------------------------------------------------------------
      Author:
      Company: Balance
      Description: This method get a map of all sObject names for standard and custom objects defined in the organization;
      it filters them and create a list of SelectOption to be shown in Balance Integration Layer Source and Target Object
      dropdown lists.
      Inputs:  None
      Returns: List<SelectOption>
                   0.1                           First Version
      02-Mar-2021  0.2     G.Mameli C.Sanna      Filtered globalDescribeValues to exclude custom settings, custom metadata,
                                                 events and Standard Objects containing History, Share, Feed, Apex and
                                                 ChangeEvent strings
    ----------------------------------------------------------------------------------------------------------------- */

    public List<SelectOption> getSourceObjectsName() {

        List<Schema.sObjectType> globalDescribeValues = Schema.getGlobalDescribe().Values();
        System.debug('globalDescribeValues size: ' + globalDescribeValues.size());
        List<SelectOption> options = new List<SelectOption>();
        List<String> listSourceObjects = new List<String>();
        options.add(new SelectOption('', '--------Select--------'));

        for (Schema.sObjectType globalDescribeValue : globalDescribeValues) {
            Schema.DescribeSObjectResult descrSobjResult = globalDescribeValue.getDescribe();
            if (!descrSobjResult.isCustomSetting() && (descrSobjResult.isCustom() ||
                    (!descrSobjResult.getName().containsIgnoreCase('History')
                    && !descrSobjResult.getName().containsIgnoreCase('Share')
                    && !descrSobjResult.getName().containsIgnoreCase('Feed')
                    && !descrSobjResult.getName().containsIgnoreCase('Apex')
                    && !descrSobjResult.getName().containsIgnoreCase('ChangeEvent')))
                    && !descrSobjResult.getName().containsIgnoreCase('__e')
                    && !descrSobjResult.getName().containsIgnoreCase('__mdt')) {
                System.debug('name inside list: ' + descrSobjResult.getName());
                listSourceObjects.add(descrSobjResult.getName());
                options.add(new SelectOption(descrSobjResult.getName(), descrSobjResult.getLabel()));
            }
        }

        System.debug('listSourceObjects size: ' + listSourceObjects.size());

        listSourceObjects.sort();
        options.sort();
        return options;
    }

    public List<SelectOption> getTargetObjectsName() {
        return getSourceObjectsName();
    }

    public void getObjectFields() {
        if (String.isBlank(selObject) || selObject.equalsIgnoreCase('undefined')) return;
        System.debug('#######SELOBJECT####:' + selObject);
        Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(selObject).getDescribe().fields.getMap();
        listOfFields = new List<SelectOption>();
        for (Schema.SObjectField sfield : fieldMap.Values()) {
            Schema.describefieldresult dfield = sfield.getDescribe();
            System.debug('#######' + dfield);
            listOfFields.add(new SelectOption(dfield.getName(), dfield.getLabel()));
        }
    }

    public pageReference buildSingleRelation() {
        Mapping__c rowMapping = new Mapping__c();
        rowMapping.SourceObj__c = SourceObj;
        rowMapping.TargetObj__c = TargetObj;
        rowMapping.SourceField__c = SourceField;
        rowMapping.TargetField__c = TargetField;
        rowMapping.SourceFieldType__c = (String) Schema.getGlobalDescribe().get(SourceObj).getDescribe().fields.getMap().get(SourceField).getDescribe().getType().name();
        rowMapping.TargetFieldType__c = (String) Schema.getGlobalDescribe().get(TargetObj).getDescribe().fields.getMap().get(TargetField).getDescribe().getType().name();
        Blob keyBlob = Blob.valueOf(SourceObj + '|' + TargetObj + '|' + SourceField + '|' + TargetField);
        Blob hashMd5KeyBlob = Crypto.generateDigest('MD5', keyBlob);
        String md5HashKey = EncodingUtil.base64Encode(hashMd5KeyBlob);
        rowMapping.md5HashKey__c = md5HashKey;
        Map<String, Mapping__c> uniqRelations = new Map<String, Mapping__c>();
        if (currRelations == null) currRelations = new List<Mapping__c>();
        currRelations.add(rowMapping);
        for (Mapping__c tmp : currRelations) {
            uniqRelations.put(tmp.md5HashKey__c, tmp);
        }
        if (Utils.cebCheckObjPermission('Mapping__c',gd).get('CREATE') && Utils.checkFLSPermission('Mapping__c', 'SourceObj__c').get('CREATE')
                && Utils.cebCheckFLSPermission('Mapping__c', 'TargetObj__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Mapping__c', 'SourceField__c',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Mapping__c', 'TargetField__c',gd).get('CREATE')
                ) upsert uniqRelations.values() md5HashKey__c;
        currRelations.clear();
//currRelations.addAll(uniqRelations.values());
        currRelations = [SELECT Id, SourceObj__c, TargetObj__c, SourceField__c, TargetField__c, SourceFieldType__c, TargetFieldType__c, isUpsertKey__c, md5HashKey__c
        FROM Mapping__c ORDER BY CreatedDate Desc LIMIT 1000];
        isRelationValid = checkExternalKey(currRelations);
        return null;
    }

    private Boolean checkExternalKey(List<Mapping__c> relations) {
        Map<String, Boolean> object2ExternalKey = new Map<String, Boolean>();
        Set<String> sourceObjects = new Set<String>();
        Set<String> targetObjects = new Set<String>();
        for (Mapping__c tmp : relations) {
            sourceObjects.add(tmp.SourceObj__c);
            targetObjects.add(tmp.TargetObj__c);
            Map<String, Schema.SObjectField> sourceFieldTokens = Schema.getGlobalDescribe().get(tmp.SourceObj__c).getDescribe().fields.getMap();
            Map<String, Schema.SObjectField> targetFieldTokens = Schema.getGlobalDescribe().get(tmp.TargetObj__c).getDescribe().fields.getMap();
            Boolean isSourceExternalID;
            //If source type is ID set isSourceExternalID to true
            if(tmp.SourceFieldType__c != null && tmp.SourceFieldType__c.toUpperCase() == 'ID') isSourceExternalID = true;
            else isSourceExternalID = sourceFieldTokens.get(tmp.SourceField__c).getDescribe().isExternalID() || sourceFieldTokens.get(tmp.SourceField__c).getDescribe().isUnique();
            Boolean isTargetExternalID = targetFieldTokens.get(tmp.TargetField__c).getDescribe().isExternalID() || targetFieldTokens.get(tmp.TargetField__c).getDescribe().isUnique();
            if (isSourceExternalID) object2ExternalKey.put(tmp.SourceObj__c, isSourceExternalID);
            if (isTargetExternalID) object2ExternalKey.put(tmp.TargetObj__c, isTargetExternalID);
        }
        Boolean isSourceObjectOk = true;
        Boolean isTargetObjectOk = true;
        for (String tmp : sourceObjects) {
            if (!object2ExternalKey.containsKey(tmp)) {
                isSourceObjectOk = false;
                break;
            }
        }
        for (String tmp : targetObjects) {
            if (!object2ExternalKey.containsKey(tmp)) {
                isTargetObjectOk = false;
                break;
            }
        }
//throw new Utils.BalanceException('CHECK IS:'+(isSourceObjectOk && isTargetObjectOk));
        return isSourceObjectOk && isTargetObjectOk;
    }

    public pageReference deleteSingleRelation() {
        List<Mapping__c> relations2delete = new List<Mapping__c>();
        for (Mapping__c tmp : currRelations) {
            if (tmp.id == mappingId) {
                relations2delete.add(tmp);
                break;
            }
        }
        if (Utils.checkObjPermission('Mapping__c').get('DELETE')) {
            delete relations2delete;
        }
        if (Utils.cebCheckObjPermission('Mapping__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'SourceObj__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'TargetObj__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'SourceField__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'TargetField__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'SourceFieldType__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'TargetFieldType__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'isUpsertKey__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'md5HashKey__c',gd).get('ACCESS')) {
            currRelations = [SELECT Id, SourceObj__c, TargetObj__c, SourceField__c, TargetField__c, SourceFieldType__c,
                    TargetFieldType__c, isUpsertKey__c, md5HashKey__c FROM Mapping__c ORDER BY CreatedDate Desc LIMIT 1000];
            isRelationValid = checkExternalKey(currRelations);
        }
        return null;
    }

    public pageReference deleteRelations() {
        if (Utils.checkObjPermission('Mapping__c').get('DELETE')) {
            delete currRelations;
        }
        if (Utils.cebCheckObjPermission('Mapping__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'SourceObj__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'TargetObj__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'SourceField__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'TargetField__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'SourceFieldType__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'TargetFieldType__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'isUpsertKey__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Mapping__c', 'md5HashKey__c',gd).get('ACCESS')) {
            currRelations = [SELECT Id, SourceObj__c, TargetObj__c, SourceField__c, TargetField__c, SourceFieldType__c,
                    TargetFieldType__c, isUpsertKey__c, md5HashKey__c FROM Mapping__c ORDER BY CreatedDate Desc LIMIT 1000];
            isRelationValid = checkExternalKey(currRelations);
        }
        return null;
    }

}