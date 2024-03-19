public with sharing class TblPraticaCTRL {
	
	public String queryPrat{get;set;} 
	//public list<TabellaPratica> lPrat{get;set;}	
	public boolean bAllSel {get;set;}
	public boolean PraticheEsisti {get;set;}
	public String nRecord { get; set;}
	/////////////////////
	private Integer counter = 0;
    private Integer list_size = 25;
    public Integer total_size = 0;
	///////////////////// 
	//Nuova gestione
	public String NamePrimoAttuale{get;set;}
	public String NameUltimoAttuale{get;set;}
	public Boolean isNext{get;set;}
	public Boolean isPrevious{get;set;}
	  
	public TblPraticaCTRL(){
		bAllSel = true;
		NamePrimoAttuale = null;
		NameUltimoAttuale = null;
		isNext = false;
		isPrevious = false;
		
		
	}
	
	public list<TabellaPratica> lPrat{
		get{
			system.debug('Query passata al component: ' + queryPrat);
			List<Pratica__c> PraticheToView = new List<Pratica__c>();
			if(NamePrimoAttuale == null && NameUltimoAttuale == null){
				system.debug('Primo giro');
			// inizio nuovo codice 14/04 inserimento check permission
            if (Utils.checkFLSPermission('Pratica__c', 'Data_inizio_scaduto__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Data_in_Lavorazione__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Fascia_di_rischio__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Saldo_Corrente__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Scaduto_Corrente__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Stato__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Strategia_Scaduto__c').get('ACCESS'))
            {
                total_size = Database.query(queryPrat).size();
            }
            // fine nuovo codice 14/04 inserimento check permission
            	queryPrat = queryPrat + ' ORDER BY Name DESC LIMIT 25';
			// inizio nuovo codice 14/04 inserimento check permission
            if (Utils.checkFLSPermission('Pratica__c', 'Data_inizio_scaduto__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Data_in_Lavorazione__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Fascia_di_rischio__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Saldo_Corrente__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Scaduto_Corrente__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Stato__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Strategia_Scaduto__c').get('ACCESS'))
            {
                PraticheToView = Database.query(queryPrat);
            }	
            // fine nuovo codice 14/04 inserimento check permission
                NameUltimoAttuale = PraticheToView[PraticheToView.size()-1].Name;
				NamePrimoAttuale = PraticheToView[0].Name;
				queryPrat = queryPrat.substring(0,queryPrat.length()-28);
			}	
			if(isNext){
				queryPrat = queryPrat + ' AND Name < :NameUltimoAttuale ORDER BY Name DESC LIMIT 25';
                System.debug('@@ '+queryPrat);
			// inizio nuovo codice 14/04 inserimento check permission
            if (Utils.checkFLSPermission('Pratica__c', 'Data_inizio_scaduto__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Data_in_Lavorazione__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Fascia_di_rischio__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Saldo_Corrente__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Scaduto_Corrente__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Stato__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Strategia_Scaduto__c').get('ACCESS'))
            {
                PraticheToView = Database.query(queryPrat);
            }	
            // fine nuovo codice 14/04 inserimento check permission
                NameUltimoAttuale = PraticheToView[PraticheToView.size()-1].Name;
				NamePrimoAttuale = PraticheToView[0].Name;
				queryPrat = queryPrat.substring(0,queryPrat.length()-58);
				isNext = false;
			}
			if(isPrevious){
				queryPrat = queryPrat + ' AND Name > :NamePrimoAttuale ORDER BY Name DESC LIMIT 25';
			// inizio nuovo codice 14/04 inserimento check permission
            if (Utils.checkFLSPermission('Pratica__c', 'Data_inizio_scaduto__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Data_in_Lavorazione__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Fascia_di_rischio__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Saldo_Corrente__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Importo_Spese_Consolidato__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Saldo_Spese_Corrente__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Scaduto_Corrente__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Stato__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Strategia_Scaduto__c').get('ACCESS'))
            {
                PraticheToView = Database.query(queryPrat);
            }
            // fine nuovo codice 14/04 inserimento check permission
                NameUltimoAttuale = PraticheToView[PraticheToView.size()-1].Name;
				NamePrimoAttuale = PraticheToView[0].Name;
				queryPrat = queryPrat.substring(0,queryPrat.length()-58);
				isPrevious = false;
			}
			
			list<TabellaPratica> tempPrat = new list<TabellaPratica>();
			for(Pratica__c p : PraticheToView){
				TabellaPratica PraticaSelect = new TabellaPratica(false, p, p.id);
            	tempPrat.add(PraticaSelect);
			}
			if(tempPrat.size()>0){
				PraticheEsisti = true;
			} else PraticheEsisti = false;
			
			return tempPrat;
		}
		set;
	}
	
	/*public static set<id> RecuperaPraticheSelezionate(){
		
		Set<id> IdPraticheDaElaborare = new Set<id>();
        for(TabellaPratica tb : lPrat){
            if(tb.isSelected){
                IdPraticheDaElaborare.add(tb.idPrat);
             }
        }
        
        return IdPraticheDaElaborare;
	}*/
	
	public PageReference Beginning() 
    { 
        //user clicked beginning
        counter = 0;
        return null;
    }
 
    public PageReference Previous() 
    { 
        //user clicked previous button
        isPrevious = true;
        counter -= list_size;
        return null;
    }
 
    public PageReference Next() 
    { 
        //user clicked next button
        isNext = true;
        counter += list_size;
        
        return null;
    }
 
    public PageReference End() 
    { 
        //user clicked end
        if(math.mod(total_size, list_size) == 0)
            counter = total_size - list_size;
        else
            counter = total_size - math.mod(total_size, list_size);
        return null;
    }
 
    public Boolean getDisablePrevious() 
    { 
        //this will disable the previous and beginning buttons
        if (counter>0) 
            return false; 
        else 
            return true;
    }
    
    public Boolean getDisableNext() 
    { 
        //this will disable the next and end buttons
        if (counter + list_size < total_size) 
            return false; 
        else 
            return true;
    }
    
    public Integer getTotal_size() 
    {
        return total_size;
    }
    
    public Integer getPageNumber() 
    {
        Integer nPage = counter/list_size + 1;
        Integer fRec = (list_size * (nPage - 1)) + 1;
        Integer lRec = list_size * nPage;
        if(lRec > Total_size)
           lRec = Total_size;
        nRecord = string.valueOf(fRec) + '-' + string.valueOf(lRec);
        return nPage;
    }
    
    public Integer getTotalPages() 
    {
        if (math.mod(total_size, list_size) > 0) 
        {
            return total_size/list_size + 1;
        } 
        else 
        {
            return (total_size/list_size);
        }
    }
	
	public PageReference SelectAll()
    {
        /*if(lPrat!=null){
        for(TabellaPratica tb : lPrat)
            tb.isSelected = bAllSel;}*/	
        return null;
    }
}