/*
Author: Alessio Massidda

Purpose: batch che dato un insieme di ID di pratiche,
crea i record e le associazioni necessarie per la generazione di un affido
*/

public class BatchCreaAffidamento implements Database.Batchable<sObject> {
	public class BatchCreaAffidamentoException extends Exception{}
	
	String query;
	Map<String, String> mPraticheTask;
	Lotto__c lotto;
	Set<String> PIds;
	Map<String, SObjectType> gd = Schema.getGlobalDescribe();
	
	public BatchCreaAffidamento(Map<String, String> mapPraticheTask, Lotto__c lotto) {
		this.lotto = lotto;

		if (Utils.cebCheckFLSPermission('Pratica__c', 'Data_Ultimo_Saldo__c', gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Residuo_Totale__c', gd).get('ACCESS'))
		{
			mPraticheTask = mapPraticheTask;
			PIds = mPraticheTask.keySet();
			System.System.debug(PIds);
			//query = 'Select id,Data_Ultimo_Saldo__c,Residuo_Totale__c from Pratica__c where id in:mPraticheTask.keySet()';
			query = 'Select id,Data_Ultimo_Saldo__c,Residuo_Totale__c from Pratica__c where id in :PIds';
			System.System.debug(query);
		}
		else{
			throw new BatchCreaAffidamentoException('Non si ha accesso all\'oggetto Pratica__c e/o ai campi Data_Ultimo_Saldo__c e Residuo_Totale__c');
		}
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope) {
   		List<Affidamento__c> lAff = new list<Affidamento__c>();
		Map<id,Pratica__c> pMap = new Map<Id, Pratica__c>((List<Pratica__c>) scope);

		if (Utils.cebCheckFLSPermission('Pratica__c', 'Data_Ultimo_Saldo__c', gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Residuo_Totale__c', gd).get('ACCESS'))
		{
			//for(string s: mPraticheTask.keyset())
			for(string s: pMap.keyset())
			{
	            affidamento__c a = new affidamento__c();
	            a.Lotto__c=lotto.id;
	            a.id_Task_associato__c=mPraticheTask.get(s);
	            a.pratica__c=s;
	            a.Data_scaduto_iniziale__c=pMap.get(s).Data_Ultimo_Saldo__c;
	            a.Scaduto_iniziale__c=pMap.get(s).Residuo_Totale__c;
	            a.stato__c='In creazione';
	            lAff.add(a);
	        }
	    }
	    else{
	    	throw new BatchCreaAffidamentoException('Non si ha accesso all\'oggetto Pratica__c e/o ai campi Data_Ultimo_Saldo__c e Residuo_Totale__c');
	    }

	    if (Utils.cebCheckFLSPermission('Affidamento__c', 'Lotto__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'pratica__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'stato__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_scaduto_iniziale__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_iniziale__c', gd).get('CREATE')
        ) 
		{
        	insert lAff;	
		}
		else{
			throw new BatchCreaAffidamentoException('Non si ha permesso di creazione sull\'oggetto Affidamento__c e/o uno o più dei suoi campi');
		}
        
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        Set<Id> idTaskAssociati = new Set<Id>();
        for (Affidamento__c tmp : lAff) {
            idTaskAssociati.add((Id)tmp.id_Task_associato__c);
        }
        if (Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c', gd).get('ACCESS')){
            List<Task> currentTasks = [SELECT Id,ActivityExtended__c FROM Task WHERE Id in:idTaskAssociati];
            Map<Id,ActivityExtended__c> task2Obj = Utils.cebGetTaskWithActivityExtended(currentTasks, gd);
            
            for(affidamento__c a:lAff){
                if (!task2Obj.containsKey(a.id_Task_associato__c)) continue;
                ActivityExtended__c ae = task2Obj.get(a.id_Task_associato__c);
                ae.id_affidamento__c=a.id;
                ae.id_lotto_associato__c=a.lotto__c;
                aes.add(ae);
            }
            if (Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_affidamento__c', gd).get('UPDATE')
            	&& Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_lotto_associato__c', gd).get('UPDATE'))
            {
            	update aes;
            }
            else{
            	throw new BatchCreaAffidamentoException('Non si ha permesso di aggiornamento sull\'oggetto ActivityExtended__c e/o ai campi id_affidamento__c e id_lotto_associato__c');
            }
        }
        else{
			throw new BatchCreaAffidamentoException('Non si ha accesso all\'oggetto Task e/o al campo ActivityExtended__c');	
        }
	}
	
	public void finish(Database.BatchableContext BC) {
		
	}
	
}