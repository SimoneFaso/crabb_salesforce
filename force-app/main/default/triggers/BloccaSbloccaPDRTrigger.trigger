/*
*	Creato:
*
*	Modificato: ESino, 17/6/2016
*
*	Edit Notes: Modificato per indirizzare in un solo Handler, tutti scenari
*	del database.
*/
trigger BloccaSbloccaPDRTrigger on Piano_di_Rientro__c (after delete, after insert, after update, before delete, before insert, before update){
    TriggerFactory.createHandler(Piano_di_Rientro__c.sObjectType);
}