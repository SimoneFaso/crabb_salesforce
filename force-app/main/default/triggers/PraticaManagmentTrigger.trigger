trigger PraticaManagmentTrigger on Pratica__c(after delete, after insert, after update, before delete, before insert, before update)
{
    //if(!CredManUtility.IsTriggerEnabled())return;//rdonato try to fix performance issues on update bulk movimenti
    TriggerFactory.createHandler(Pratica__c.sObjectType);
}