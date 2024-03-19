trigger CollectorTrigger on Collector__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	TriggerFactory.createHandler(Collector__c.sObjectType);
}