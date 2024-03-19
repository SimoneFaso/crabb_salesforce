trigger ActivityExtendedTrigger on ActivityExtended__c (after delete, after insert, after update, before delete, before insert, before update)
{
    TriggerFactory.createHandler(ActivityExtended__c.sObjectType);
}