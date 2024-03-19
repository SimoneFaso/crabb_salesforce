trigger RiconciliazioneStagingTrigger on CRABB_DEV__Riconciliazione_Staging__c (before insert, before update, after update, after insert) {
    TriggerFactory.createHandler(Riconciliazione_Staging__c.sObjectType);
}