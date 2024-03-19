/* ---------------------------------------------------------------------------------------------------------------------
Name:            StrategiaHandler.cls
Description:     This class implements the ITrigger, and ensures that the
                 trigger is bulkified, and is all in one place.
Test class:      TestStrategiaHandler.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
03-Jun-2014  0.1      D.Miraka & E.Sino               First Version

14-Sep-2022  0.2      R. Kurti & C. Sanna             Modified for adding check permission:
                                                      cebCheckObjPermission/WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class StrategiaHandler implements ITrigger {

    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();


    // Costruttore
    public StrategiaHandler(){
    }
    
    public void bulkBefore(){
    }
    
    public void bulkBefore(List <sObject> soList){}
    
    public void bulkAfter(){
    }
    
    public void bulkAfter(List <sObject> soList){}
            
    public void beforeInsert(LIST<SObject> soList){
    }
    
    public void beforeUpdate(LIST<SObject> oldSoList, LIST<SObject> soList){         
    }
    
    public void beforeDelete(LIST<SObject> soList){   
        cambiStatoTestata(soList);        
    }
    
    public void afterInsert(LIST<SObject> soList){   
        cambiStatoTestata(soList);
    }
    
    public void afterUpdate(LIST<SObject> oldSoList, LIST<SObject> soList){
        cambiStatoTestata(soList);  
    }
    
    public void afterDelete(LIST<SObject> soList)
    {
    }
    
    /**
     * cambiStatoTestata()
     *
     * Questo metodo e chiamato quando tutti i record sono processati dall trigger. Usa questo 
     * motodo per fare le operazioni finali come la impostazione dello stato in bozza, in caso se é in attiva.
     */
    public void cambiStatoTestata(List<sObject> soList){
        // le strategie che sono modificate
        List<Strategia__c> mieStrategie = (List <Strategia__c>) soList;
        
        // un set con i id delle testate che contengono questi oggetti non Testata
        Set<id> mieNonTestateId = new Set<id>();
        
        // il record type, si usera per controlo
        Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Strategia__c.getrecordtypeinfosbydevelopername();
                
        for(Strategia__c strTemp : mieStrategie)
            if(strTemp.recordTypeID != ctRecordTypes.get('Testata').getRecordTypeID()){
                mieNonTestateid.add(strTemp.Testata__C);
            }
        
        // Chiedi dal DB tutte le Testate da modificare
        List <Strategia__c> mieTestateDaModificare = new List<Strategia__c>();
        //if(Utils.checkFLSPermission('Strategia__c', 'Stato__c').get('ACCESS'))
        //{
            mieTestateDaModificare = [SELECT id, Stato__c FROM Strategia__c
            WHERE Id IN: mieNonTestateID AND Stato__c =: 'Attiva' WITH SECURITY_ENFORCED ];
        
            // cambi lo Stato delle Testate
            for (Strategia__c strTmp : mieTestateDaModificare)
                strTmp.Stato__c = 'Bozza';
            
            if (Utils.cebCheckObjPermission('Strategia__c',gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'Stato__c',gd).get('UPDATE')) {
                update mieTestateDaModificare;
            }
        //}
    }
    
    public void andFinally(){
    } 
}