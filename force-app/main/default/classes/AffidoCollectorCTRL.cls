/* ---------------------------------------------------------------------------------------------------------------------
Name:            AffidoCollectorCTRL.cls
Description:     Controller Class for visualforce page
Test class:      

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
17-Feb-2021  0.1      Rajni                Line no 128 is modified to show the labels
12-Sep-2022  0.2      R.Kurti & C.Sanna    Modified for security review (CebCheck FLS methods)
----------------------------------------------------------------------------------------------------------------------*/
global with sharing class AffidoCollectorCTRL {

	public Map<String,Collector_con_Tipo_Affido__c> listCollAff 				{get; set;}
	public String newName 														{get; set;}
	public String newCategoria 													{get; set;}
	public Decimal newDurata 													{get; set;}
	public String newTipoAff 													{get; set;}

	public List<SelectOption> categoriaOptions                  				{get; set;}
    public String selectedCategoria                             				{get; set;}

    public String addingCategoria 												{get; set;}
	public static Map<String, SObjectType> gd = Schema.getGlobalDescribe();

	public AffidoCollectorCTRL() {
		listCollAff = new Map<String,Collector_con_Tipo_Affido__c>();
		listCollAff = Collector_con_Tipo_Affido__c.getAll();

		newName = '';
		newCategoria = '';
		newDurata = 0;
		newTipoAff = '';
		selectedCategoria = '';
		addingCategoria = '';

		categoriaOptions = new List<SelectOption>();
		categoriaOptions = getPicklistValues(new Collector__c(),Utils.NAMESPACE+'Tipo_Collector__c');
	}

	public List<Collector_con_Tipo_Affido__c> getListCollector(){
		return listCollAff.values();
	}

	@RemoteAction
    global static String removeRecords(String param){
    	if(Utils.checkObjPermission('Collector_con_Tipo_Affido__c').get('DELETE')){
    		Collector_con_Tipo_Affido__c toRemove = new Collector_con_Tipo_Affido__c(Id=param);
    		delete toRemove;
    	}
	
		String result = '/apex/AffidoCollectorPage';
    	return result;
    }

    @RemoteAction
	global static String editRecord(String idRecord, String nam, String cat, Decimal dur, String tip){

		if(idRecord == null || nam == null || cat == null || tip == null){
			return '';
		}else{

			Collector_con_Tipo_Affido__c aff = new Collector_con_Tipo_Affido__c(Id=idRecord);
			aff.Name = nam;

			if(cat != null && String.isNotBlank(cat)){
				aff.Categoria_Collector__c = cat;
			}

			aff.Durata__c = dur;
			aff.Tipo_Affido__c = tip;

			if(Utils.cebCheckObjPermission('Collector_con_Tipo_Affido__c',gd).get('UPDATE')){
				update aff;
			}

		}

        return '/apex/AffidoCollectorPage';
	}

	public PageReference addRecord(){
		
		if(newName == null || String.isBlank(newName)){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Name : Value is required.'));
            return null;
		}

		try{
			Collector_con_Tipo_Affido__c newRec = new Collector_con_Tipo_Affido__c();
			newRec.Name = newName;
			newRec.Categoria_Collector__c = addingCategoria;
			newRec.Durata__c = (newDurata != null) ? newDurata : null;
			newRec.Tipo_Affido__c = newTipoAff;

			if(Utils.cebCheckObjPermission('Collector_con_Tipo_Affido__c',gd).get('CREATE') && Utils.cebCheckObjPermission('Collector_con_Tipo_Affido__c',gd).get('INSERT')){
				insert newRec;
			}

			PageReference page = new PageReference('/apex/AffidoCollectorPage');
			page.setRedirect(true);
			return page;
		}catch(Exception ex){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
		}
	}

	public void emptyMethod(){}

	/**
     * @description utility method for getting a list of picklist values from an existing object field.
     *
     * @param obj the existing object 
     * @param field the field of the existing object
     * @return List of String with the picklist values
     */ 
     public List<SelectOption> getPicklistValues(sObject obj, String field) {
     
        List<SelectOption> options = new List<SelectOption>();
      
        Map<String, Schema.SObjectField> fieldMap = obj.getSObjectType().getDescribe().fields.getMap();
        
        // Get the list of picklist values for this field.
        List<Schema.PicklistEntry> values = fieldMap.get(field).getDescribe().getPickListValues();
        
        options.add(new SelectOption('','-- None --'));

        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values) { 
        //    options.add(new SelectOption(a.getLabel(), a.getValue())); to fix translation
            options.add(new SelectOption(a.getValue(), a.getLabel()));            
        }
		system.debug(options);
        options.sort();
        
        return options;
    
    }
}