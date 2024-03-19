public with sharing class ActivityExtendedHandler implements ITrigger
{   
    public static boolean hasTriggerRunned=false;
    
    public ActivityExtendedHandler(){}
    public void bulkBefore(){}
    public void bulkBefore(List<SObject> soListNew){}
        
    public void bulkAfter(){}
    public void bulkAfter(List<SObject> soListNew){}
    
    public void beforeInsert(LIST<SObject> soList){}
    public void beforeUpdate(LIST<SObject> oldList, LIST<SObject> newList){}
    public void beforeDelete(List<SObject> so){}
    
    public void afterInsert(List<SObject> soList){

/*        List<ActivityExtended__c> aeToCreateCase = new List<ActivityExtended__c>();
        for(ActivityExtended__c ae : (List<ActivityExtended__c>)soList){
//            System.debug('Old' + oldSo.get(cont));
            System.debug('New' + ae);
            if( ( ae.Tipo__c != null  ) ||
                    *//*( ae.Fase__c != null && ((List<ActivityExtended__c>)oldSo).get(cont).Tipo__c != ae.Fase__c ) ||*//*
                    ( ae.Sotto_tipo__c != null  )
                    *//* ( ae.Activity__c != null && ((List<ActivityExtended__c>)oldSo).get(cont).Activity__c != ae.Activity__c )*//*
                    ){
                aeToCreateCase.add(ae);
            }

        }
        System.debug('List create case: ' +aeToCreateCase);
        CaseUtility.createCaseFromStep(aeToCreateCase);*/
    }
    
    
    public void afterUpdate(List<SObject> oldSo, List<SObject> so){
/*        Integer cont = 0;
        List<ActivityExtended__c> aeToCreateCase = new List<ActivityExtended__c>();
        for(ActivityExtended__c ae : (List<ActivityExtended__c>)so){
            System.debug('Old' + oldSo.get(cont));
            System.debug('New' + ae);
            if( ( ae.Tipo__c != null && ((List<ActivityExtended__c>)oldSo).get(cont).Tipo__c != ae.Tipo__c ) ||
                    *//*( ae.Fase__c != null && ((List<ActivityExtended__c>)oldSo).get(cont).Tipo__c != ae.Fase__c ) ||*//*
                    ( ae.Sotto_tipo__c != null && ((List<ActivityExtended__c>)oldSo).get(cont).Sotto_tipo__c != ae.Sotto_tipo__c )
                   *//* ( ae.Activity__c != null && ((List<ActivityExtended__c>)oldSo).get(cont).Activity__c != ae.Activity__c )*//*
                    ){
                aeToCreateCase.add(ae);
            }
            cont++;
        }
        System.debug('List create case: ' +aeToCreateCase);
        CaseUtility.createCaseFromStep(aeToCreateCase);*/
    	/*Set<Id> taskIdSet = new Set<Id>();
    	Map<Id,ActivityExtended__c> mapidae = new Map<Id,ActivityExtended__c>();

    	for(ActivityExtended__c ae : (List<ActivityExtended__c>)so){
    		taskIdSet.add(ae.Id);
    		mapidae.put(ae.Id,ae);
    	}

    	List<Task> taskList = [SELECT Id, ActivityExtended_Esito__c, ActivityExtended_Data_Chiusura__c, ActivityExtended__c, ActivityExtended_TipoSottotipo__c, ActivityExtended_Fase__c FROM Task WHERE ActivityExtended__c IN :taskIdSet];
    	for(Task t : taskList){
    		ActivityExtended__c temp = mapidae.get(t.ActivityExtended__c);
    		t.ActivityExtended_Esito__c = temp.Esito__c;
    		t.ActivityExtended_Data_Chiusura__c = (temp.Data_chiusura__c != null) ? temp.Data_chiusura__c : null;
    		t.ActivityExtended_TipoSottotipo__c = temp.Tipo_Sottotipo__c;
    		t.ActivityExtended_Fase__c = temp.Fase__c;
    	}

    	update taskList;*/

    }
    public void afterDelete(List<SObject> so){}
    public void andFinally(){}

}