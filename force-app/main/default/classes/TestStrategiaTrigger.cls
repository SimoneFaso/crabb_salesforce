/*
* CreatedBy: KMeta
* CreatedDate: 16/August/2014
* Description: Contiene le classi di test per la classe Ork
*/

@isTest
public class TestStrategiaTrigger{

    static testMethod void Strategia_insert_testata(){
        Strategia__c testata= new Strategia__c();
        testata=TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        
        test.startTest();
            insert testata;
        test.stopTest();
    }
    
    static testMethod void Strategia_insert_step(){
        Strategia__c testata= new Strategia__c();
        Strategia__c step= new Strategia__c();
        
        test.startTest();
            testata=TestClassForDatagenerationCreateData.getTestStrategiaTestata();
            insert testata;
            step=TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id,testata.id);
            insert step;
            update  testata;
        test.stopTest();
    }

    static testMethod void Strategia_delete(){
        Strategia__c testata= new Strategia__c();
        Strategia__c step= new Strategia__c();
        testata=TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        step=TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id,testata.id);
        insert step;
        update  testata;
        
        test.startTest();
            delete [Select id From strategia__c ];
        test.stopTest();
    }




}