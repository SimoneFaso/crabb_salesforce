/*
* CreatedBy: DMiraka
* CreatedDate: 25/September/2014
* Description: Contine la classe di test per la classe GestioneStrategieCTRL
*/

@isTest
public class TestGestioneStrategieCTRL{
    static testMethod void TestretriveList(){
    
    Strategia__c str= new Strategia__c();
    str.Nome__c= 'r1';
    str.Stato__c='Bozza';
    str.Descrizione__c='Questo é un test per strategia';
    Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Strategia__c.getrecordtypeinfosbydevelopername();   
    str.recordTypeId =ctRecordTypes.get('Testata').getRecordTypeID();
  
        test.startTest();
        insert(str);
        
        GestioneStrategieCTRL GStr = new GestioneStrategieCTRL();
        test.stopTest();
        }
}