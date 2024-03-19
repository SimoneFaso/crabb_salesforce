/* ---------------------------------------------------------------------------------------------------------------------
Name:            GestioneEsitoAffidamentiCTRL.cls
Description:
Test class:      TestGestioneEsitoAffidamenti.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
16-Sept-2014 0.1      E. Sino                         First Version
29-Sept-2014 0.2      Silvio                          Modified for lot extension request
             0.3                                      Modified  to fix English version - replace getRecordTypeInfosByName
                                                      with getrecordtypeinfosbydevelopername, line no 89
13-Sep-2022  0.4      C. Sanna & R. Kurti             Modified for adding check permission:
                                                      cebCheckObjPermission, cebCheckFLSPermission & WITH SECURITY_REVIEW (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class GestioneEsitoAffidamentiCTRL {
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    public String myAffId;
    public boolean validAffId{get;set;}
    
    public Task t;
    public ActivityExtended__c ae;
    public static Map<string, Schema.RecordTypeInfo> nameID;
        
    // costruttore
    public GestioneEsitoAffidamentiCTRL (){
        
        validAffId = isAffIdValid();
        //ErrorClass.logError('Costruttore.GestioneEsitoAffidi', 'Affido valido: ' + String.valueof(validAffid) + '.');
        t = getT();
        if (t.ActivityExtended__c == null) {
            ae = new ActivityExtended__c();
            t.ActivityExtended__c = ae.Id;
        }
    }
    
    // Bottoni per navigare la pagina
    // In questo metodo, non sono neccessari controlli sulla validitá
    // perche, si visualizza solo se al url, é passata un id valido dei affidamenti
    public pageReference salva(){
        
        // Leggi il Affidamento dal DB
        if(Utils.cebCheckObjPermission('Affidamento__c', gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Affidamento__c', 'E_richiesta_una_proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Tipo_Collector__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Giorni_di_proroga__c', gd).get('ACCESS'))
        {
            String queryAff = 'Select id, Tipo_Collector__c, E_richiesta_una_proroga__c, Giorni_di_proroga__c From Affidamento__c where id =: myAffId';
            Affidamento__c aff = new Affidamento__c();
            try{
                aff = Database.Query(queryAff);
            }catch(Exception e){
                System.Debug('\n Errore durante la resuscita dal DB al Affidamento! \n Dettagli: ' + e.getMessage());
            }
            System.debug('\n Mio query: ' + queryAff + '\n Mio aff: ' + aff);
        
            // compila dati del task in background
            t.Subject= 'Esito Puntuale';
            ae.Fase__c = aff.Tipo_Collector__c;
            t.WhatID = aff.Id;
            ae.RecordTypeId = getRecordTypeid('EsitiCollector');
            ae.Tipo__c = 'Esiti';
            ae.Sotto_Tipo__c = 'Collector';
            t.Status = 'Completato';
            t.Priority = 'Normale';
            
            if(ae!=null && t!=null && Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('INSERT')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Fase__c', gd).get('INSERT')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Tipo__c', gd).get('INSERT')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Sotto_Tipo__c', gd).get('INSERT')
                    && Utils.cebCheckObjPermission('Task', gd).get('INSERT')
                    && Utils.cebCheckFLSPermission('Task', 'Subject', gd).get('INSERT')
                    && Utils.cebCheckFLSPermission('Task', 'WhatID', gd).get('INSERT')
                    && Utils.cebCheckFLSPermission('Task', 'Status', gd).get('INSERT')
                    && Utils.cebCheckFLSPermission('Task', 'Priority', gd).get('INSERT')){
                insert ae;
                t.ActivityExtended__c = ae.Id;
                insert t;
                System.Debug('\n Il mio Task in DB: ' + t+' activity extended correlata:'+ae);
            }
            
            // Gestione Richiesta Proroga
            //if(t.ActivityExtended__r.Esiti_Collector__c == 'RICHIESTA DI PROROGA') {
            if(t.ActivityExtended__r.Esiti_Collector__c == 'RICHIESTA DI PROROGA'
                    && Utils.cebCheckObjPermission('Affidamento__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'E_richiesta_una_proroga__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Giorni_di_proroga__c', gd).get('UPDATE')) {
                try{
                    aff.E_richiesta_una_proroga__c = true;
                    aff.Giorni_di_proroga__c = null;
                    Database.SaveResult AffUpd = Database.update(aff);
                }catch(Exception e){
                    System.Debug('\n Errore in fase di update Affidamento'+ e.getMessage());
                }
            }
        }
        return new PageReference('/' + myAffId);
    }
    
    public pageReference cancella(){
        
        return new PageReference('/' + myAffId);
    }
    
    // prendi il id del record type EsitoCollector
    public static id getRecordTypeid(string RecordTypeName){

            if(nameID==null){
                nameId=Schema.SObjectType.ActivityExtended__c.getrecordtypeinfosbydevelopername();         
            }
            return nameId.get(RecordTypeName).getRecordTypeID();
    }
    
    // chiedi il task
    public Task getT(){
        
        if(t != null) return t;
        t = new Task();
        return t;
    }
    
    // leggi l'id dal URL
    public string getMyAffId(){
        MyAffId = ApexPages.currentPage().getParameters().get('id');
        return myAffId;
    }
    
    // controlla se l'id e valida
    public boolean isAffIdValid(){
        String myId = getMyAffid();
        
        if(myId == null || myId == ''){
            return false;
        }else if(myId.length() != 15){// le id nel URl sono composte da 15 caratteri
                System.debug('\n Mio Id dalla pagina: ' + myId + '\n Lungezza string: ' + myId.length());        
                return false;
             }else{
                 Affidamento__c aff = new Affidamento__c();
                 try{
                     if(Utils.cebCheckObjPermission('Affidamento__c',gd).get('ACCESS')) {
                         //aff = [Select id From Affidamento__c where id =: myId WITH SECURITY_ENFORCED];
                         aff = [Select id From Affidamento__c where id = :myId];
                     }
                     System.debug('\n Mio Aff: ' + aff);
                     return true;
                 }catch(Exception e){
                     return false;
                 }
            }
    } // end validation   
    
}