trigger CaseTrigger on Case (after insert, after update) {
    //check if skip trigger
    if(!skiptrigger.skip('Case')){
    	TriggerFactory.createHandler(Case.sObjectType);    
    }
    
}