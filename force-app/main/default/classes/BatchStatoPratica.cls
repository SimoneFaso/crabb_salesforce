global class BatchStatoPratica implements Database.Batchable<sObject> {
	
	public String query 								{get; set;}
	public String pratId								{get; set;}
	public Set<String> setIdPratica						{get; set;}
	public Map<String,String> mapIdStato				{get; set;}

	global BatchStatoPratica(List<String> listIdPratica, Map<String,String> mapPraticaStato){
		if(setIdPratica == null) setIdPratica = new Set<String>();
		if(mapIdStato == null) mapIdStato = new Map<String,String>();

		if(listIdPratica != null)	setIdPratica.addAll(listIdPratica);
		if(mapPraticaStato != null) mapIdStato = mapPraticaStato;

		query = 'SELECT Stato_Pratiica_Picklist__c,Pratica__r.Stato__c FROM Movimento__c WHERE Pratica__c IN :setIdPratica';
	}
	
	global BatchStatoPratica(String idPratica, String statoPratica) {
		if(setIdPratica == null) setIdPratica = new Set<String>();
		if(mapIdStato == null) mapIdStato = new Map<String,String>();

		if(idPratica != null) pratId = idPratica;

		setIdPratica.add(pratId);
		mapIdStato.put(pratId,statoPratica);

		query = 'SELECT Stato_Pratiica_Picklist__c,Pratica__r.Stato__c FROM Movimento__c WHERE Pratica__c = :pratId';
	}

	global BatchStatoPratica(String idPratica, String statoPratica, Boolean resetStatic) {
		if(setIdPratica == null || resetStatic) setIdPratica = new Set<String>();
		if(mapIdStato == null || resetStatic) mapIdStato = new Map<String,String>();

		if(idPratica != null) pratId = idPratica;

		setIdPratica.add(pratId);
		mapIdStato.put(pratId,statoPratica);

		query = 'SELECT Stato_Pratiica_Picklist__c,Pratica__r.Stato__c FROM Movimento__c WHERE Pratica__c = :pratId';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		
   		try{

   			if(Utils.checkObjPermission('Movimento__c').get('ACCESS') && Utils.checkObjPermission('Movimento__c').get('UPDATE')){

	   			List<Movimento__c> movList = new List<Movimento__c>();
	   			if(scope != null && !scope.isEmpty()){
	   				for(SObject so : scope){

		   				Movimento__c m = (Movimento__c)so;
		   				System.debug('@@@@@@@ '+m.Stato_Pratiica_Picklist__c);
		   				System.debug('@@@@@@@ '+m.Pratica__r.Stato__c);
		   				if( m.Stato_Pratiica_Picklist__c != null &&
		   					m.Pratica__r.Stato__c != null && 
		   					!m.Stato_Pratiica_Picklist__c.equalsIgnoreCase(m.Pratica__r.Stato__c) ){

		   					m.Stato_Pratiica_Picklist__c = m.Pratica__r.Stato__c;
		   					movList.add(m);
		   				}else if( (m.Stato_Pratiica_Picklist__c == null || String.isBlank(m.Stato_Pratiica_Picklist__c)) && m.Pratica__r.Stato__c != null){
		   					m.Stato_Pratiica_Picklist__c = m.Pratica__r.Stato__c;
		   					movList.add(m);
		   				}

		   				if(movList != null && movList.size() == 1000){
		   					update movList;
		   					movList.clear();
		   				}

		   			}
		   		}

	   			if(movList != null && movList.size()>0) update movList;

	   		}

		}catch(Exception ex){

			System.debug('Exception in BatchStatoPratica::execute() --> '+ex.getStackTraceString());
			ErrorClass.logError('BatchStatoPratica::execute() --> '+ex.getMessage());
		}

	}
	
	global void finish(Database.BatchableContext BC) {
		if(setIdPratica != null && setIdPratica.contains(pratId)) setIdPratica.remove(pratId);
		//if(mapJobPratica != null && mapJobPratica.containsKey(pratId)) mapJobPratica.remove(pratId);
	}
	
}