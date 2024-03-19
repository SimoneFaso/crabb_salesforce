public with sharing class lottizzazioneCTRL {
    public string tipoAffido{get;set;}
    Public List<SelectOption> tipiAffidi{
        get{
            List<SelectOption> options=new List<SelectOption>();
            for(string s:Utils.getStepsDaAffidamento()){ 
                if(tipoAffido==null) tipoAffido=s;
                options.add(new SelectOption(s,s)); 
            }
            return options;
        }
    }
    public lottizzazioneCTRL(){
    
    }
    
    public PageReference RefreshRB() { return null; }
}