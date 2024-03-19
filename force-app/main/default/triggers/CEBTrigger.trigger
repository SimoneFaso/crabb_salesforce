/**
 * Created by MatteoSala on 27/02/2021.
 */

trigger CEBTrigger on CEB__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    if(!CredManUtility.IsTriggerEnabled())return;
    TriggerFactory.createHandler(CEB__c.sObjectType);
}