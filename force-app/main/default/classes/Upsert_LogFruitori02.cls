/* ---------------------------------------------------------------------------------------------------------------------
Name:            Upsert_LogFruitori02.cls
Description:
Test class:      TestUpser_LogFruitori02.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
16-Sep-2022  0.2      C.Sanna & R.Kurti    Replaced CheckFLSPermission with cebCheckFLSPermission and added cebCheckObjPermission (security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class Upsert_LogFruitori02 {

	public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

	public void Upsert_LogFruitori02(){
        
    } 	
    
    public static void UpsertFruitore(Id IdLogToWrite, DateTime DataInizio, 
    								map<Integer, String> ErrorStringPerInteger, 
                                    map<Integer, Servizi_Item__c> MapFruitoriToUpsertPerIndice, 
    								map<Integer, String> NewMapException){
	
		
		//Creo In Json gli esiti del caricamento del movimento e popolo il log 
		String allfieldsLog = CredManUtility.selectallShort('Log__c');
		Log__c LogToUpdate = new Log__c();
		/*if(Utils.checkFLSPermission('Log__c', 'Account_KO__c').get('ACCESS')
            && Utils.checkFLSPermission('Log__c', 'Account_OK__c').get('ACCESS')
            && Utils.checkFLSPermission('Log__c', 'Account_TOT__c').get('ACCESS')
            && Utils.checkFLSPermission('Log__c', 'Durata__c').get('ACCESS')
            && Utils.checkFLSPermission('Log__c', 'Error__c').get('ACCESS')
            && Utils.checkFLSPermission('Log__c', 'File_Caricati__c').get('ACCESS')
            && Utils.checkFLSPermission('Log__c', 'Fine__c').get('ACCESS')
            && Utils.checkFLSPermission('Log__c', 'info__c').get('ACCESS')
            && Utils.checkFLSPermission('Log__c', 'Line_number__c').get('ACCESS'))
        {*/
		if(Utils.cebCheckObjPermission('Log__c',gd).get('ACCESS')
				&& Utils.cebCheckFLSPermission('Log__c', 'Account_KO__c',gd).get('ACCESS')
				&& Utils.cebCheckFLSPermission('Log__c', 'Account_OK__c',gd).get('ACCESS')
				&& Utils.cebCheckFLSPermission('Log__c', 'Account_TOT__c',gd).get('ACCESS')
				&& Utils.cebCheckFLSPermission('Log__c', 'Durata__c',gd).get('ACCESS')
				&& Utils.cebCheckFLSPermission('Log__c', 'Error__c',gd).get('ACCESS')
				&& Utils.cebCheckFLSPermission('Log__c', 'File_Caricati__c',gd).get('ACCESS')
				&& Utils.cebCheckFLSPermission('Log__c', 'Fine__c',gd).get('ACCESS')
				&& Utils.cebCheckFLSPermission('Log__c', 'info__c',gd).get('ACCESS')
				&& Utils.cebCheckFLSPermission('Log__c', 'Line_number__c',gd).get('ACCESS'))
		{
			LogToUpdate = database.query(String.escapeSingleQuotes('SELECT '+allfieldsLog+
											' FROM Log__c WHERE Id = : IdLogToWrite '));
		}
		integer FruitoriOK = 0;
		integer FruitoriKO = 0;
		if(MapFruitoriToUpsertPerIndice.keyset().size()>0){
			Set<integer> IndiceMapFruitoriUpsert = MapFruitoriToUpsertPerIndice.keyset();
			list<Integer> ListIndiceSortFruitoriUpsert = new list<Integer>();
			for(Integer i : IndiceMapFruitoriUpsert){
				ListIndiceSortFruitoriUpsert.add(i);
			}
			ListIndiceSortFruitoriUpsert.sort();
			list<Servizi_Item__c> ListFruitoriUpsertSort = new list<Servizi_Item__c>();
			for(integer i : ListIndiceSortFruitoriUpsert){
				ListFruitoriUpsertSort.add(MapFruitoriToUpsertPerIndice.get(i));
			}

			// inizio nuovo codice 18/04/17 inserimento check permission
  
            /*if(Utils.checkFLSPermission('Servizi_Item__c', 'Nome__c').get('UPSERT')
  	            && Utils.checkFLSPermission('Servizi_Item__c', 'Codice__c').get('UPSERT')
                && Utils.checkFLSPermission('Servizi_Item__c', 'Note__c').get('UPSERT')
                && Utils.checkFLSPermission('Servizi_Item__c', 'Id_Esterno__c').get('UPSERT'))
            {*/
			if(Utils.cebCheckObjPermission('Servizi_Item__c',gd).get('UPSERT')
					&& Utils.cebCheckFLSPermission('Servizi_Item__c', 'Nome__c',gd).get('UPSERT')
					&& Utils.cebCheckFLSPermission('Servizi_Item__c', 'Codice__c',gd).get('UPSERT')
					&& Utils.cebCheckFLSPermission('Servizi_Item__c', 'Note__c',gd).get('UPSERT')
					&& Utils.cebCheckFLSPermission('Servizi_Item__c', 'Id_Esterno__c',gd).get('UPSERT'))
			{
			    List<Database.Upsertresult> upsertResultFruitori = Database.upsert(ListFruitoriUpsertSort, Servizi_Item__c.Id_Esterno__c, false);  
			    integer n3 = 0;
			    for(Database.Upsertresult ur : upsertResultFruitori){
			    	Integer ConteggioIndice = ListIndiceSortFruitoriUpsert[n3];
			    	string message = '';
			        if(!ur.isSuccess()){
			            message += 'KO3Upsert_WARNING: ';
			            for(Database.Error dbe : ur.getErrors())
			                message += dbe.message + ' - ';
			            message += '. The line ' + ConteggioIndice + ' will be ignored.\n';
			            ErrorStringPerInteger.put(ConteggioIndice, message);
			        }
			        n3++;
		    	}
		    }
		    // fine nuovo codice 18/04/17 inserimento check permission
		}

		Set<Integer> SetLogFinal = ErrorStringPerInteger.keyset();
        list<Integer> ListIndiceForLog = new list<Integer>();
        for(integer i : SetLogFinal){
        	ListIndiceForLog.add(i);
        }
		
		Integer IndiceCSVForLog;
        Integer RigaReale;
        map<Integer, String> MapErrorePerNRIGAFinal = new map<Integer, String>();
        for(integer i=0;i<ListIndiceForLog.size();i++){
        	IndiceCSVForLog = ListIndiceForLog[i];
        	//RigaReale = ListIndiceForLog[i]+2;
        	if(ErrorStringPerInteger.get(IndiceCSVForLog).startsWith('KO')){
        		//Gestione KO
        		if(ErrorStringPerInteger.get(IndiceCSVForLog).startsWith('KO3')){
        			//Gestione Log Servizi
        			FruitoriKO++;
        			if(ErrorStringPerInteger.get(IndiceCSVForLog).contains('Exception')){
	        			MapErrorePerNRIGAFinal.put(IndiceCSVForLog,'KO - Row '+IndiceCSVForLog+' - ERRORE INASPETTATO: '+NewMapException.get(IndiceCSVForLog));
	        		}else if(ErrorStringPerInteger.get(IndiceCSVForLog).substring(3,9) == 'Upsert'){
	        			MapErrorePerNRIGAFinal.put(IndiceCSVForLog,'KO - Row '+IndiceCSVForLog+' - ERRORE DURANTE IL SALVATAGGIO: '+ErrorStringPerInteger.get(IndiceCSVForLog).substring(10, ErrorStringPerInteger.get(IndiceCSVForLog).length()));
	        		}else{
	        			MapErrorePerNRIGAFinal.put(IndiceCSVForLog,'KO - Row '+IndiceCSVForLog+' - ERRORE DI DATI: '+ErrorStringPerInteger.get(IndiceCSVForLog).substring(4,ErrorStringPerInteger.get(IndiceCSVForLog).length()));
	        		}
        		}else{
        			MapErrorePerNRIGAFinal.put(IndiceCSVForLog,'KO - Row '+IndiceCSVForLog+' - ERRORE DI DATI: '+ErrorStringPerInteger.get(IndiceCSVForLog).substring(4,ErrorStringPerInteger.get(IndiceCSVForLog).length()));
        		}
        	}else{
        		//Gestion OK
    			FruitoriOK++;
    			MapErrorePerNRIGAFinal.put(IndiceCSVForLog, 'OK - Row '+IndiceCSVForLog+' ['+MapFruitoriToUpsertPerIndice.get(IndiceCSVForLog).Id_Esterno__c+'] - Fruitore Lavorato Correttamente');
        	}
        	
        }
        
        String MsgErrorForLog = '';
        set<Integer> IndiceForBuildLog = MapErrorePerNRIGAFinal.keyset();
        list<integer> IndiceLogCSV = new list<integer>(); 
        for(integer i : IndiceForBuildLog){
        	IndiceLogCSV.add(i);
        }
        IndiceLogCSV.sort();
		map<Integer, String> MapResultIntegrationLog = new map<Integer, String>();
        String JsonResult;
        for(Integer IndiceOrdinato : IndiceLogCSV){
			MapResultIntegrationLog.put(IndiceOrdinato, MapErrorePerNRIGAFinal.get(IndiceOrdinato));
          	JsonResult = Json.serialize(MapResultIntegrationLog);
	    }

		// Aggiorno il Log che mi è stato passato in input
		LogToUpdate.Servizi_Item_KO__c = FruitoriKO;	 
		LogToUpdate.Servizi_Item_OK__c = FruitoriOK;
		LogToUpdate.Servizi_Item_TOT__c = FruitoriKO+FruitoriOK;
		LogToUpdate.Integration_Result__c = JsonResult;
		LogToUpdate.Integration_processed__c = true;
		LogToUpdate.Inizio__c = DataInizio;
		/*if (Utils.checkFLSPermission('Log__c', 'Servizi_Item_KO__c').get('UPDATE')
			&& Utils.checkFLSPermission('Log__c', 'Servizi_Item_OK__c').get('UPDATE')
			&& Utils.checkFLSPermission('Log__c', 'Integration_Result__c').get('UPDATE')
			&& Utils.checkFLSPermission('Log__c', 'Integration_processed__c').get('UPDATE')
			&& Utils.checkFLSPermission('Log__c', 'Inizio__c').get('UPDATE')
			)*/
		if (Utils.cebCheckObjPermission('Log__c',gd).get('UPDATE')
				&& Utils.cebCheckFLSPermission('Log__c', 'Servizi_Item_KO__c',gd).get('UPDATE')
				&& Utils.cebCheckFLSPermission('Log__c', 'Servizi_Item_OK__c',gd).get('UPDATE')
				&& Utils.cebCheckFLSPermission('Log__c', 'Integration_Result__c',gd).get('UPDATE')
				&& Utils.cebCheckFLSPermission('Log__c', 'Integration_processed__c',gd).get('UPDATE')
				&& Utils.cebCheckFLSPermission('Log__c', 'Inizio__c',gd).get('UPDATE')){
			update LogToUpdate;
		}
	} 
	
}