public with sharing class PreViewDocuments {
    public string DocSelected{get;set;}
    public boolean ViewButtonOpen {get;set;}
    public boolean ViewPicklist {get;set;}
    public List<SelectOption> pickTipoDocumenti {get;set;}
    
    public PreViewDocuments(){
        ViewButtonOpen = false;
        ViewPicklist = false;
    }
    
    public void PrendiValori(){
    	List<Document_Type__c> ListTypeDocument = Document_Type__c.getAll().values();
        system.debug('****PrendiValori ');
        ViewPicklist = true;
        pickTipoDocumenti = new List<SelectOption>();
        for(Document_Type__c Dt : ListTypeDocument){
        	pickTipoDocumenti.add(new SelectOption(Dt.Document_Code__c,Dt.Name));
        }
        pickTipoDocumenti.add(new SelectOption('--None--','--None--'));
    }
    
    public void CheckString(){
        if(DocSelected != '--None--'){
            ViewButtonOpen = true;
        }else{
            ViewButtonOpen = false;
        }
    }
    
    
    
}