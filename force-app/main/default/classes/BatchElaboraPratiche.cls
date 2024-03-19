global with sharing class BatchElaboraPratiche implements Database.Batchable<sObject> {
	
	public List<Task> taskList 		{get; set;}
	public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

	global BatchElaboraPratiche(List<Task> tlist){
		taskList = tlist;
	}
	
	global Iterable<SObject> start(Database.BatchableContext BC) {
		return taskList;
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		
		if(Utils.cebCheckObjPermission('Task',gd).get('ACCESS') && Utils.cebCheckObjPermission('Task',gd).get('UPDATE')){
   			update scope;
   		}

	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}