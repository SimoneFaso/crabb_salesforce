trigger AffidamentoTrigger on Affidamento__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	    TriggerFactory.createHandler(Affidamento__c.sObjectType);
}