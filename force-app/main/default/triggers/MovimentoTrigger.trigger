trigger MovimentoTrigger on Movimento__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) 
{
    if(!CredManUtility.IsTriggerEnabled())return;
    //CredManUtility.DisableTrigger();
    TriggerFactory.createHandler(Movimento__c.sObjectType);
    //CredManUtility.EnableTrigger();
}