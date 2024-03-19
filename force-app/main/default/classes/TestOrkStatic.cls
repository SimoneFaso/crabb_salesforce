/*
* CreatedBy: KMeta
* CreatedDate: 04/August/2014
* Description: Contine la classe di test per la classe ErrorClass
*/

@isTest
public class TestOrkStatic{
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    static testMethod void orkStatic_instance(){
        test.startTest();
            orkStatic os = new orkStatic();
        test.stopTest();
    }
    
    static testMethod void orkStatic_setPraticaFieldsList(){
        test.startTest();
            orkStatic.setPraticaFieldsList();
            orkStatic.cebSetPraticaFieldsList(gd);
        test.stopTest();
    }     
    static testMethod void orkStatic_setStrategiaFieldsList(){
        test.startTest();
            orkStatic.setStrategiaFieldsList();
            orkStatic.cebSetStrategiaFieldsList(gd);
        test.stopTest();
    }
    static testMethod void orkStatic_setTaskFieldsList(){
        test.startTest();
        /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
            //orkStatic.setTaskFieldsList();
        /*** 20210513 MSiotto - Code Review - End Rimosso per nuova gestione CEB  ***/
            orkStatic.cebSetTaskFieldsList(gd);
        test.stopTest();
    }  
    
    static testMethod void orkStatic_setTaskRecrdType(){
        test.startTest();
            orkStatic.setTaskRecrdType();
        test.stopTest();
    }   
    static testMethod void orkStatic_setPraticaFieldsLoaded(){
        test.startTest();
            orkStatic.setPraticaFieldsLoaded();
            orkstatic.cebSetPraticaFieldsLoaded(gd);
        test.stopTest();
    }       
    static testMethod void orkStatic_initializeStrategiaObjects(){
        test.startTest();
            orkStatic.initializeStrategiaObjects();
        test.stopTest();
    }   
    static testMethod void orkStatic_retrievePratiche_empty(){
        Map<string, task> tMap= new  Map<string,task>();
        map<string,Pratica__c> pMap = new Map<string,Pratica__c>();
        List<Log__c> logl= new List<Log__c>();
        
        test.startTest();
        /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
        //orkStatic.retrievePratiche(tMap,pMap);
        /*** 20210513 MSiotto - Code Review - End Rimosso per nuova gestione CEB ***/
            orkStatic.cebRetrievePratiche(tMap,pMap,gd);
        test.stopTest();
    }    
    static testMethod void orkStatic_retrievePratiche_withTandP(){
        pratica__c p= new Pratica__c();
        p= TestClassForDatagenerationCreateData.getTestPratica();
        insert p;
        List<Sobject> t =OrkBL.newTask(p);
        insert t;
        Task tt = null;
        for (SObject tmp: t) {
            if (tmp instanceof Task) {
                tt = (Task) tmp;
            }
        }        
        Map<string,Pratica__c> pMap = new Map<string,Pratica__c>();
        Map<string, task> tMap= new  Map<string,task>();
        tMap.put(tt.id,tt);       
        test.startTest();
        /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
            //orkStatic.retrievePratiche(tMap,pMap);
        /*** 20210513 MSiotto - Code Review - End Rimosso per nuova gestione CEB ***/
            orkStatic.cebRetrievePratiche(tMap,pMap,gd);
        test.stopTest();
    }  
    static testMethod void orkStatic_retrieveStrategie_null(){      
        test.startTest();
            orkStatic.retrieveStrategie();
            orkStatic.cebRetrieveStrategie(gd);
        test.stopTest();
    }  
    static testMethod void orkStatic_retrieveStrategie_Testata(){       
        strategia__c str = new strategia__c();
        str= TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert str;
        test.startTest();
            orkStatic.retrieveStrategie();
            orkStatic.cebRetrieveStrategie(gd);
        test.stopTest();
    }   
    static testMethod void orkStatic_retrieveStrategie_all(){       
        strategia__c testata = new strategia__c();
        testata= TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        
        List<Strategia__c> sList= new List<strategia__c>();
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaCDU(testata.id));
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaCDI(testata.id));
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id,testata.id));
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id,testata.id));
        
        insert sList;
        
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaJUMP(testata.id,sList[2].id,sList[3].id));
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaJUMP(testata.id,sList[2].id,sList[3].id));
        sList[5].isAutomaticJump__c=true;
        upsert sList;
        testata.stato__c='Attiva';
        update testata;
        
        test.startTest();
            orkStatic.retrieveStrategie();
            orkStatic.cebRetrieveStrategie(gd);
        test.stopTest();
    }       
    
}