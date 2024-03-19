trigger StrategiaTrigger on Strategia__c ( after insert, after update, before delete)
{
    TriggerFactory.createHandler(Strategia__c.sObjectType);
}