trigger LottoTrigger on Lotto__c (after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(Lotto__c.sObjectType);
}