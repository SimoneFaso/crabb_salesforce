public with sharing class TabellaPratica implements Attributeable{
        
    public boolean isSelected {get; set;}
    public Pratica__c Prat{get; set;}
    public Id idPrat{get;set;}
        
    public TabellaPratica(Boolean isSelected, Pratica__c Prat, Id idPrat){
        this.Prat = Prat;
        this.isSelected = isSelected;
        this.idPrat = idPrat;
    }
}