/*
 * Created by: Endrit Sino
 * Des: Classe di test per RiepilogoIntegrazione
 * data: 29/9/2014
 */

@isTest
public class TestRiepilogoIntegrazione {
    
    // test classe interne
    static testmethod void testInternClass(){
        test.startTest();
        RiepilogoIntegrazione.Header h = new RiepilogoIntegrazione.Header();
        h.contratto = 'Kot';
        h.UltcarMov = System.now();
        h.UltcarAna = System.now();
        h.lCont = new List<RiepilogoIntegrazione.Content>();
        h.lCont.add(new RiepilogoIntegrazione.Content());
        RiepilogoIntegrazione.Header h1 = new RiepilogoIntegrazione.Header(h);
        test.stopTest();
    }
    
    static testmethod void testEntireClass(){
        
        test.startTest();
        
        // crea log
        Log__C l = new Log__c();
        l.Object_Id__c = 'idnull';
        l.Method__c = 'met';
        l.Integration_nome_del_documento__c = 'nomeDoc';
        l.Account_TOT__c = 1.4;
        l.Account_KO__c = 1.1;
        l.Account_OK__c = 1.5;
        l.Movimenti_KO__c = 2.2;
        l.Movimenti_OK__c = 1.1;
        l.Movimenti_TOT__c = 1.5;
        l.Servizi_KO__c = 1.4;
        l.Servizi_OK__c = 1.4;
        l.Servizi_TOT__c = 3.3;
        l.Servizi_Item_KO__c = 1.1;
        l.Servizi_Item_OK__c = 1.1;
        l.Servizi_Item_TOT__c = 1.1;
        l.Indirizzi_TOT__c = 1.3;
        Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Log__c.getRecordTypeInfosByName();   
        l.RecordTypeId = ctRecordTypes.get('FinalLogIntegration').getRecordTypeID();
        insert l;
        
        RiepilogoIntegrazione istanza = new RiepilogoIntegrazione();
        
        test.stopTest();
    }
}