/**
 * Created by MatteoSala on 03/06/2020.
 */

public with sharing class CRABB_PDR_Structure
{
    public class CRABB_Rate_Structure
    {
        @AuraEnabled
        public Date Data_Rata { get; set; }
        @AuraEnabled
        public Decimal Importo_Rata { get; set; }
    }

    @AuraEnabled
    public String Pratica { get; set; }
    @AuraEnabled
    public Integer Num_Rate { get; set; }
    @AuraEnabled
    public Decimal Int_Mora { get; set; }
    @AuraEnabled
    public Decimal Int_Dilazione { get; set; }
    @AuraEnabled
    public Decimal Importo_Tot { get; set; }
    @AuraEnabled
    public Decimal Importo_Tot_Acc { get; set; }
    @AuraEnabled
    public Boolean Calcolo_Int { get; set; }
    @AuraEnabled
    public List<CRABB_Rate_Structure> ListRate { get; set; }
    @AuraEnabled
    public String Type { get; set; }
    @AuraEnabled
    public String Reason { get; set; }

}