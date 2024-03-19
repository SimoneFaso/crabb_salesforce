/**
 * Created by ssalaris on 21/05/2021.
 */

public with sharing class RiconciliazioneStagingHandler implements ITrigger{

    public RiconciliazioneStagingHandler (){

    }
    public void bulkBefore(){

    }

    public void bulkAfter(){

    }

    public void bulkAfter(List<SObject> soListNew){

    }

    public void bulkAfter(List<SObject> soListOld,List<SObject> soListNew){

    }

    public void bulkBefore(List<Riconciliazione_Staging__c> soListNew){
    }

    public void beforeInsert(List<Riconciliazione_Staging__c> soListNew){
    }

    public void beforeUpdate(List<Riconciliazione_Staging__c> soListOld, List<Riconciliazione_Staging__c> soListNew){
    }


    public void beforeDelete(List<SObject> so){
    }

    public void afterInsert(List<Riconciliazione_Staging__c> new_riconciliazione_Stagings) {
    }

    public void afterUpdate(List<Riconciliazione_Staging__c> old_riconciliazione_Stagings, List<Riconciliazione_Staging__c> new_riconciliazione_Stagings) {
    }

    public void afterDelete(List<SObject> so){

    }
    public void andFinally(){

    }
}