public with sharing class TabellaAffidamento implements Attributeable{
        
    public boolean isSelected {get; set;}
    public Affidamento__C Aff{get; set;}
    public Id idAff{get;set;}
        
    public TabellaAffidamento (Boolean isSelected, Affidamento__c Aff, Id idAff){
        this.Aff= Aff;
        this.isSelected = isSelected;
        this.idAff= idAff;
    }
}