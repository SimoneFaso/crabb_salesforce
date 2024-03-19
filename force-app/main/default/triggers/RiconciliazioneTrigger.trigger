trigger RiconciliazioneTrigger on Riconciliazione__c (before insert, before update, after update, after insert) {
    TriggerFactory.createHandler(Riconciliazione__c.sObjectType);
}