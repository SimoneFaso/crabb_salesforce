trigger AccountTrigger on Account (after delete, after insert, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(Account.SObjectType);
}