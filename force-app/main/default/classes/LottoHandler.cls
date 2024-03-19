/**
 * Created by: Klodjan Meta
 * Created date: 23/October/2014
 * Class name: LottoHandler
 */
public with sharing class LottoHandler implements ITrigger
{   
    public static boolean hasTriggerRunned=false;
    
    public LottoHandler(){}
    public void bulkBefore(){}
    public void bulkBefore(List<SObject> soListNew){}
        
    public void bulkAfter(){}
    public void bulkAfter(List<SObject> soListNew){}
    
    public void beforeInsert(LIST<SObject> soList){}
    public void beforeUpdate(LIST<SObject> oldList, LIST<SObject> newList){
        Map<id,Lotto__c> ml = new map<id,Lotto__c>((List<lotto__c> )oldList);
        lotto__c lo = new lotto__c();
        for(lotto__c l: (List<lotto__c> )newList){
            lo=ml.get(l.id);
            if(lo.stato__c=='Confermato' && l.affidi__c==l.Affidi_chiusi__c ) l.stato__c='Chiuso';
        }
    }
    public void beforeDelete(List<SObject> so){
    }
    
    public void afterInsert(List<SObject> soList){
    }
    
    
    public void afterUpdate(List<SObject> oldSo, List<SObject> so){
    }
    public void afterDelete(List<SObject> so){}
    public void andFinally(){}

}