global with sharing class SplitFileMovimenti implements Schedulable { 
	/*private String StringContratti, MsgError, NomeCSV;
	private Id IdContrattoParentCSV;
	private list<Gestione_Movimenti_New.MovimentiInput> ListMovimentiInput ; 
	private integer start, limite, successi, errori;
	private Datetime DataInizio;
	
	public void setStringContract(String StringContratti){
		this.StringContratti = StringContratti;
		system.debug('*******StringContratti = ' + StringContratti);
    }	
	
	public void setListContrattiInput(List<Gestione_Movimenti_New.MovimentiInput> ListMovimentiInput){
		this.ListMovimentiInput = ListMovimentiInput;
    }
    
    public void setErrors(String MsgError){
		this.MsgError = MsgError;
		system.debug('*******MsgError = ' + MsgError);
    }
    
    public void setLimit(Integer start, Integer limite){
		this.start = start;
		this.limite = limite;
		system.debug('*******start = ' + start); 
		system.debug('*******limite = ' + limite);
	}
	
	
	public void setInfoCSV (String NomeCSV, Id IdContrattoParentCSV){
		this.IdContrattoParentCSV = IdContrattoParentCSV;
		this.NomeCSV = NomeCSV;
		system.debug('*******NomeCSV = ' + NomeCSV); 
		system.debug('*******IdContrattoParentCSV = ' + IdContrattoParentCSV);
	}
	
	public void setDataInizio (Datetime DataInizio){
		this.DataInizio = DataInizio;
		system.debug('*******DataInizio = ' + DataInizio);
	}
	*/
	
	global void execute(SchedulableContext sc){
		/*System.abortJob(sc.getTriggerId());
		
        Gestione_Movimenti_New.UpsertMovimenti(ListMovimentiInput, StringContratti, start, limite, MsgError, NomeCSV, IdContrattoParentCSV, DataInizio); 
		*/
	} 

}