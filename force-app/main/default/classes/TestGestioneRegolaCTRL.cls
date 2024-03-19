/*
* CreatedBy: DMiraka
* CreatedDate: 25/September/2014
* Description: Contine la classe di test per la classe GestioneRegolaCTRL
*/

@isTest
public class TestGestioneRegolaCTRL{
    
    @isTest static void TestmyRules(){
        Test.startTest();
        
        Rule_control__c rc = new Rule_control__c();
        rc.name = 'r1';
        rc.Api_object_name__c='Pratica__c';
        rc.Api_field_name__c ='Classe_di_rischio__c';
        rc.Strategia_api_field_name__c ='Classe_di_rischio__c';
        rc.Condition__c='IsIncluded';
        rc.Note__c='verifica se la classe di rischio è inclusa nella classe di rischio configurata nella strategia';
        rc.Rule_name__c='test';
    
        insert rc;
        
        GestioneRegolaCTRL gr = new GestioneRegolaCTRL ();
        
        GestioneRegolaCTRL.editRecord(rc.Id, rc.Rule_name__c, rc.Api_object_name__c, rc.Api_field_name__c, rc.Condition__c, rc.Strategia_api_field_name__c, rc.Note__c);
        GestioneRegolaCTRL.newRecord('Test', rc.Api_object_name__c, rc.Api_field_name__c, rc.Condition__c, rc.Strategia_api_field_name__c, 'TEST TEST');

        GestioneRegolaCTRL.removeRecords(rc.Id);

        Test.stopTest();
    }
}