/**
 * Created by MatteoSala on 27/04/2021.
 */

trigger AssetTrigger on Asset (before insert, after insert, after update)
{
    Id recordTypeId = Schema.SObjectType.CRABB_DEV__Log__c.getRecordTypeInfosByDeveloperName().get('DataMapper').getRecordTypeId();
    public List<CRABB_DEV__Log__c> logToSync = new List<CRABB_DEV__Log__c>();
    public List<String> sourceFieldsList = MappingUtils.getMappingFields('Asset');
    Schema.SObjectField externalIDField = MappingUtils.getSobjectExternalId();
    List<Asset> ListAssNew = (List<Asset>) Trigger.new;
    CRABB_DEV__Log__c log;
    List<CRABB_DEV__Pratica__c> lPrat = new List<CRABB_DEV__Pratica__c>();
    

    if (sourceFieldsList.size() != 0 && Trigger.isInsert)
    {
        for (Asset assNew : ListAssNew) 
        {
            if(Trigger.isAfter)
            {
                log = new CRABB_DEV__Log__c();
                Map<String, Object> mapAss = new Map<String, Object>();
                for (String field : sourceFieldsList) {
                    mapAss.put(field, assNew.get(field));
                }
                String jsonToSave = JSON.serialize(mapAss);
                System.debug('Asset afterInsert jsonToSave --> ' + jsonToSave);
                logToSync.add(MappingUtils.buildLog(jsonToSave, 'Asset', String.valueOf(assNew.id), 'insert', 'Fatture', String.valueOf(recordTypeId)));
                System.debug('Asset afterInsert logToSync--> ' + logToSync);
            }

            if(Trigger.isBefore)
            {
                CRABB_DEV__Pratica__c p = new CRABB_DEV__Pratica__c(CRABB_DEV__Account__c = assNew.AccountId, CRABB_DEV__Esito_Processo_Automatico_Mensile__c = AssNew.Name);
                lPrat.add(p);
            }

        }
        
        if(Trigger.isBefore)
        {
            if(lPrat.size()>0) {
                insert lPrat;
            }
                
            for(CRABB_DEV__Pratica__c pr : lPrat)
            {
                    System.debug('Asset beforeInsert --> pr.CRABB_DEV__Esito_Processo_Automatico_Mensile__c: ' + pr.CRABB_DEV__Esito_Processo_Automatico_Mensile__c);
                    for(Asset a : ListAssNew)
                    {
                        if(a.Name == pr.CRABB_DEV__Esito_Processo_Automatico_Mensile__c)
                        {
                            a.SerialNumber = pr.Id;
                        }
                    }
            }
        }
    }

    if (sourceFieldsList.size() != 0 && Trigger.isUpdate)
    {
        for (Asset assUpd : ListAssNew)
        {
            log = new CRABB_DEV__Log__c();
            Map<String, Object> mapAss = new Map<String, Object>();
            System.debug('Asset afterUpdate sourceFieldsList --> ' + sourceFieldsList);
            for (String field : sourceFieldsList) {
                mapAss.put(field, assUpd.get(field));
            }

            String jsonToSave = JSON.serialize(mapAss);
            System.debug('Asset afterUpdate jsonToSave --> ' + jsonToSave);
            logToSync.add(MappingUtils.buildLog(jsonToSave, 'Asset', String.valueOf(assUpd.id), 'update', 'Default', String.valueOf(recordTypeId)));
            System.debug('Asset afterUpdate logToSync--> ' + logToSync);
        }


    }

    if (logToSync.size() > 0)
    {
        System.debug('Asset externalIDField --> ' + externalIDField);
        Database.UpsertResult[] resultLogList = Database.upsert(logToSync, externalIDField, false);
        System.debug('Asset resultLogList --> ' + resultLogList);
        //insert logToSync;
        MappingUtils.alreadyRun = true;
    }

}