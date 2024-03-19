public with sharing class TabellaAccount implements Attributeable{
        
    public boolean isSelected {get; set;}
    public Account Acc{get; set;}
    public Id idAcc{get;set;}
        
    public TabellaAccount (Boolean isSelected, Account Acc, Id idAcc){
        this.Acc= Acc;
        this.isSelected = isSelected;
        this.idAcc= idAcc;
    }
}