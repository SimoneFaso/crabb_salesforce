/**
 * Created by msala on 04/05/2020.
 */

public with sharing class CRABB_ColumnChart
{
    public class CRABBIstogramma {
        @AuraEnabled
        public String titolo {get;set;}
        @AuraEnabled
        public Integer size {get;set;}
        @AuraEnabled
        public List<CRABBSerie> serie {get;set;}
    }

    public class CRABBSerie {
        @AuraEnabled
        public String descrizione {get;set;}
        @AuraEnabled
        public Decimal valore {get;set;}
        @AuraEnabled
        public Integer quantitativo {get;set;}
        @AuraEnabled
        public String colore {get;set;}
    }
}