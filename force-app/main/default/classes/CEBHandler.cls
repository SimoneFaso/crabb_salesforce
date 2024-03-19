/**
 * Created by MatteoSala on 27/02/2021.
 */

public with sharing class CEBHandler implements ITrigger
{
    List<CEB__c> lCEB_IP = new List<CEB__c>();

    public CEBHandler(){}
    public void bulkBefore(){}
    public void bulkBefore(List<SObject> soListNew){}
    public void bulkBefore(List<SObject> soListOld,List<SObject> soListNew){}
    public void bulkAfter(){}
    public void bulkAfter(List<SObject> soListOld,List<SObject> soListNew){}
    public void bulkAfter(List<SObject> soListNew){}
    public void beforeInsert(List<Movimento__c> mov){}
    public void beforeDelete(List<Movimento__c> mov){}
    public void beforeUpdate(List<SObject> oldSo, List<Movimento__c> mov) {}
    public void afterInsert(List<Movimento__c> mov){

    }
    public void afterUpdate(List<Movimento__c> oldmov, List<Movimento__c> mov){}
    public void afterDelete(List<Movimento__c> mov){}
    public void andFinally(){}

}