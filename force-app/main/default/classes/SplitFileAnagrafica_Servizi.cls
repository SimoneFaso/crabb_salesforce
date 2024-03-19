global with sharing class SplitFileAnagrafica_Servizi implements Schedulable {
	/*private String StringContratti, MsgError, NomeCSV;
	private Id IdContrattoParentCSV;
	private list<GestioneCaricamentiAccount.ServiziInput> ListServiziInput ;
	private list<GestioneCaricamentiAccount.fruitoreInput> ListFruitoriInput ;
	private list<GestioneCaricamentiAccount.IndirizzoInput> ListIndirizziInput ;
	private integer start, limite, successi, errori;
	private Datetime DataInizio;
	private map<Integer, Account> MapAccountToUpsertPerIndice;
	private map<Integer, Servizio__c> MapServiziToUpsertPerIndice;
	private map<Integer, String> ErrorStringPerInteger; 
	private map<Integer, String> NewMapException;
	
	
	public void setException (map<Integer, String> NewMapException){
		this.NewMapException = NewMapException;
	}
	
	public void setStringContract(String StringContratti){
		this.StringContratti = StringContratti;
    }	
	
	public void setListServiziInput(List<GestioneCaricamentiAccount.ServiziInput> ListServiziInput){
		this.ListServiziInput = ListServiziInput;
    }
    
    public void setListFruitoriInput(List<GestioneCaricamentiAccount.fruitoreInput> ListFruitoriInput){
		this.ListFruitoriInput = ListFruitoriInput;
	}
    
    public void setListIndirizziInput(List<GestioneCaricamentiAccount.IndirizzoInput> ListIndirizziInput){
		this.ListIndirizziInput = ListIndirizziInput;			
    }
    
    public void setErrors(String MsgError){
		this.MsgError = MsgError;
    }
    
    public void setLimit(Integer start, Integer limite){
		this.start = start;
		this.limite = limite;
	}
	
    public void setContatori(Integer successi, Integer errori){ 
		this.successi = successi;
		this.errori = errori; 
	}
	
	public void setInfoCSV (String NomeCSV, Id IdContrattoParentCSV){
		this.IdContrattoParentCSV = IdContrattoParentCSV;
		this.NomeCSV = NomeCSV;
	}
	
	public void setDataInizio (Datetime DataInizio){
		this.DataInizio = DataInizio;
	} 
	
	public void setMapAccountUpsert (map<Integer, Account> MapAccountToUpsertPerIndice){
		this.MapAccountToUpsertPerIndice = MapAccountToUpsertPerIndice;
	}
	
	public void setMapServiziUpsert (map<Integer, Servizio__c> MapServiziToUpsertPerIndice){
		this.MapServiziToUpsertPerIndice = MapServiziToUpsertPerIndice; 
	}
	
	public void setMapRowPerErrorLog (map<Integer, String> ErrorStringPerInteger){
		this.ErrorStringPerInteger = ErrorStringPerInteger;
	} 
	
*/
	
	global void execute(SchedulableContext sc){
		/*System.abortJob(sc.getTriggerId());

		system.debug('*******start = ' + start); 
		system.debug('*******limite = ' + limite); 
		system.debug('*******MsgError = ' + MsgError); 
		system.debug('*******errori = ' + errori); 
		system.debug('*******successi = ' + successi); 
		system.debug('*******DataInizio = ' + DataInizio); 
		system.debug('*******NomeCSV = ' + NomeCSV); 
		system.debug('*******IdContrattoParentCSV = ' + IdContrattoParentCSV);
		system.debug('*******StringContratti = ' + StringContratti);
		
        GestioneCaricamentiAccount.UpsertServizi(ListServiziInput, StringContratti, start, limite, MsgError, errori, successi, NomeCSV, IdContrattoParentCSV, DataInizio, ErrorStringPerInteger, ListFruitoriInput,
												ListIndirizziInput,  MapServiziToUpsertPerIndice, NewMapException);*/
	}
}