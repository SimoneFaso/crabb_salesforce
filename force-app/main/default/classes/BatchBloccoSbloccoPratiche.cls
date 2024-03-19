/*
Author: Alessio Massidda

Data: 11/12/2018

Purpose: sbloccare/bloccare pratiche di un account legato ad un case bloccante
	- scenario blocco : tutte le pratiche degli accounts correlati ai  cases il cui flag CRABB_DEV__Blocking_SR__c è settato
	- scenario sblocco: verifica che non ci siano più cases  bloccanti (CRABB_DEV__Blocking_SR__c = true) aperti  
						correlati a determinati account. Se tale condizione si verifica, sblocca tutte le sue pratiche 

*/

global class BatchBloccoSbloccoPratiche implements Database.Batchable<sObject>, Database.Stateful {
	global class BatchBloccoSbloccoPraticheException extends Exception {}
	
	String query;
	Boolean justInserted;
	Set<Id> caseIds;
	String textForEmail;
	Datetime lastExecutionOfTheBatch;
	
	global BatchBloccoSbloccoPratiche(){
        /*ottengo l'ID di questa classe*/
        String className = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
        Id classId = [SELECT ID FROM ApexClass WHERE Name = :className LIMIT 1].get(0).Id;
        /**/

        /*cerco la data di completamento dell'ultimo job eseguito per questa classe*/
        List<AsyncApexJob> lastApexJobOfThisClass = [SELECT completedDate FROM AsyncApexJob 
        	Where ApexClassId = :classId AND completedDate != NULL 
        	ORDER BY completedDate DESC LIMIT 1];
        /**/

        //se questo batch non è mai stato eseguito, setta come data di ultima esecuzione il 1 gennaio 1970
        lastExecutionOfTheBatch = lastApexJobOfThisClass.isEmpty() ? Datetime.newInstance(0) : lastApexJobOfThisClass.get(0).completedDate;
        System.debug('lastExecutionOfTheBatch: ' + lastExecutionOfTheBatch);
	}


	//deprecated
	global BatchBloccoSbloccoPratiche(Set<Id> caseIds, Boolean justInserted) {
		//verifica che l'utente abbia i diritti per effettuare la query della start sui Case
		if (Utils.checkFLSPermission('Case', 'status').get('ACCESS')
        	&& Utils.checkFLSPermission('Case', 'AccountId').get('ACCESS'))
		{
			this.justInserted = justInserted;
			this.caseIds = caseIds;
			textForEmail = '*** INIZIO ***\n\n';
			textForEmail += 'Ho processato Cases bloccanti appena '; 
			textForEmail += justInserted ? 'INSERITI' : 'MODIFICATI';
			textForEmail += '\n\n';
		}
		else throw new BatchBloccoSbloccoPraticheException('L\'utente ' + UserInfo.getUserName() + ' non ha i diritti per vedere i case associati agli accountIds');
	} 

	
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		query = 'SELECT accountID,Status FROM CASE WHERE  Blocking_SR__c = true AND accountId != null AND lastModifiedDate > :lastExecutionOfTheBatch  ORDER BY accountID,Status';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sobject> scope) {

   		List<case> caseJustInserted = new List<case>();
   		List<case> caseJustClosed = new List<case>();

		try{
			for(Case c :(List<case>)scope){

				if(!c.Status.equalsIgnoreCase('Closed')){
					caseJustInserted.add(c);
				}
				
				else if (c.Status.equalsIgnoreCase('Closed')) {
					caseJustClosed.add(c);
				}
			}

			handleJustInserted(caseJustInserted);
			handleJustClosed(caseJustClosed);	
		}
		catch(Exception e){
			textForEmail += '\n------------------------------\n';
			textForEmail += 'E\' occorsa una ECCEZIONE a riga ' + e.getLineNumber() + ' con il seguente messaggio: ';
			textForEmail += '\t' + e.getMessage();
			textForEmail += '\nStacktrace: \n\t' + e.getStackTraceString();
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		Boolean isSandbox = [SELECT isSandbox FROM Organization LIMIT 1].get(0).isSandbox;
		if(isSandbox){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] {'balancelabs@balanceconsulting.it'};
			mail.setToAddresses(toAddresses);
			mail.setSubject('Batch Blocco/Sblocco Pratiche su Cases bloccanti');
			mail.setPlainTextBody(textForEmail + '\n\n*** FINE ***');
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}


	/*gestisce i cases che sono appena stati creati*/
	private void handleJustInserted(List<Case> cases){
		textForEmail += 'Dovrei bloccare le pratiche dei seguenti account:\n';
		Set<Id> accountsIdInvolved = new Set<Id>();
        for(Case c :  cases){
            accountsIdInvolved.add(c.accountId);
            textForEmail += ('\t- Id: ' + c.accountId + '\n');
        }
        
        if(!accountsIdInvolved.isEmpty()){
        	List<Pratica__c> lp = new List<Pratica__c>();
            if (Utils.checkFLSPermission('Pratica__c', 'Account__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Stato__c').get('ACCESS'))
            {
            	lp = [SELECT ID FROM Pratica__c WHERE Account__c IN :accountsIdInvolved AND Stato__c != 'Bloccata Manualmente'];
            }
            else throw new BatchBloccoSbloccoPraticheException('L\'utente ' + UserInfo.getUserName() + ' non ha i diritti per bloccare pratiche');

            BloccoSbloccoPratiche bsp = new BloccoSbloccoPratiche();
            bsp.BloccaPratiche(lp, 'Esistono Ticket Bloccanti', 'Esistono Ticket Bloccanti'); 
            
            if(lp.isEmpty()) textForEmail = '\nNon ho trovato pratiche da bloccare.';
            else textForEmail += ('\nHo bloccato correttamente le seguenti pratiche: ' + (new Map<Id,Pratica__c>(lp)).keyset());
        }
        
	}
	/**/

	/*gestisce i cases che sono appena stati chiusi*/
	private void handleJustClosed(List<Case> cases){
		Set<Id> accountsToProcess = new Set<Id>();
		List<Case> casesToProcess = cases.clone();
		textForEmail += 'Dovrei sbloccare le pratiche dei seguenti account:\n';

		for(Case c : cases){
			accountsToProcess.add(c.accountId);
		}

		if (Utils.checkFLSPermission('Case', 'status').get('ACCESS')
        	&& Utils.checkFLSPermission('Case', 'AccountId').get('ACCESS'))
		{
			for(Case c : [SELECT accountID,Status FROM CASE WHERE Blocking_SR__c = true 
				AND Status != 'Closed' AND accountId IN :accountsToProcess ORDER BY accountID,Status])
			{
				casesToProcess.add(c);
			}
		}
		else throw new BatchBloccoSbloccoPraticheException('L\'utente ' + UserInfo.getUserName() + ' non ha i diritti per vedere i case associati agli accountIds');
		
		for(Case c : casesToProcess){

			if(!c.Status.equalsIgnoreCase('Closed')){
				if(accountsToProcess.contains(c.accountID)) accountsToProcess.remove(c.accountID);
			}
        }

        for(Id acc : accountsToProcess){	
        	textForEmail += ('\t- Id: ' + acc + '\n');
        }

        //a questo punto, la lista dei candidati contiene sono gli account i quali case bloccanti sono stati tutti chiusi
        if(!accountsToProcess.isEmpty()){
            //unlock all praticas of accounts collected earlier
			List<Pratica__c> praticheDaChiudere = new List<Pratica__c>();
            if (Utils.checkFLSPermission('Pratica__c', 'Strategia__c').get('ACCESS')){
            	praticheDaChiudere = [SELECT Strategia__c FROM Pratica__c WHERE Account__c IN :accountsToProcess];
            }
            else throw new BatchBloccoSbloccoPraticheException('L\'utente ' + UserInfo.getUserName() + ' non ha i diritti per sbloccare pratiche');
            
            BloccoSbloccoPratiche bsp = new BloccoSbloccoPratiche(); 
            bsp.sbloccaPratiche(praticheDaChiudere, 'Ticket Bloccanti Chiusi');

            if(praticheDaChiudere.isEmpty()) textForEmail = '\nNon ho trovato pratiche da sbloccare.';
            else textForEmail += ('\nHo sbloccato correttamente le seguenti pratiche: ' + (new Map<Id,Pratica__c>(praticheDaChiudere)).keyset());
        }
	}
	/**/
	
}