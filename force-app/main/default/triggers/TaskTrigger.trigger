trigger TaskTrigger on Task (after delete, after insert, after update, before delete, before insert, before update)
{
    TaskHandler.isCrabbTriggerOn = true;
    //OrkActivities.sessionIDFromTriggerTask=UserInfo.getSessionID();
    TriggerFactory.createHandler(Task.sObjectType);
    TaskHandler.isCrabbTriggerOn = false;
}