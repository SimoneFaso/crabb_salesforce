global with sharing class BatchDeleteLogs implements Database.Batchable<sObject> {
	
	public String query {get; set;}
	public static final Id DATAMAPPER_RTID = Schema.SObjectType.CRABB_DEV__Log__c.getRecordTypeInfosByDeveloperName().get('DataMapper').getRecordTypeId();

	global BatchDeleteLogs() {
    	query =' Select '+Utils.getSOBJECTFieldsForQuery('Log__c')+' From Log__c WHERE RecordTypeId != \''+DATAMAPPER_RTID+'\'';
	}

	global BatchDeleteLogs(String queryStr){
		query = queryStr;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {

		//new ork version is enabled, skip batch
		//if (CEBUtils.newOrkVersionEnabled()) return null;

		return Database.getQueryLocator(query);

	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		if(Utils.checkObjPermission('Log__c').get('DELETE') && Utils.checkObjPermission('Log__c').get('ACCESS')){Database.delete(scope,false);}
	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('@ BatchDeleteLogs completed.');
    }
}