/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestOrkBL.cls
Description:     Test Classe for code coverage of TestOrkBL.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
04-Aug-2014  0.1      Klodjan Meta                     First Version
05-Oct-2021  0.2      G. Mameli, C. Sanna,             Modified OrkBL_isNecessaryGoOut method for coverage
----------------------------------------------------------------------------------------------------------------------*/

@isTest
public class TestOrkBL{
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    @IsTest static void OrkBL_instance(){
        test.startTest();
            OrkBL ob = new OrkBL();
        test.stopTest();
    }
    
    @IsTest static void OrkBL_setNextStepError(){
        Task t = new task();
        ActivityExtended__c ae = new ActivityExtended__c();
        insert ae;
        t.ActivityExtended__c = ae.Id;
        test.startTest();
            OrkBL.setNextStepError(t);
        test.stopTest();
        System.assertEquals('Error',t.status);
    }   
    
    @IsTest static void OrkBL_setNoNextStep(){
        Task t = new task();
        ActivityExtended__c ae = new ActivityExtended__c();
        insert ae;
        t.ActivityExtended__c = ae.Id;
        test.startTest();
            OrkBL.setNoNextStep(t);
        test.stopTest();
        System.assertEquals('Completata',t.status);
    }

    @IsTest static void OrkBL_setExitError(){
        Task t = new task();
        ActivityExtended__c ae = new ActivityExtended__c();
        insert ae;
        t.ActivityExtended__c = ae.Id;
        test.startTest();
            OrkBL.setExitError(t,ae);
        test.stopTest();
        System.assertEquals('Error',t.status);
    }   

    @IsTest static void OrkBL_isTaskToEnterInOrchestration(){
        Task t = new task();
        ActivityExtended__c ae = new ActivityExtended__c();
        insert ae;
        t.ActivityExtended__c = ae.Id;
        boolean bool;
        test.startTest();
            bool=OrkBL.isTaskToEnterInOrchestration(t,ae);
        test.stopTest();
        System.assertEquals(false,bool);
    }   
  
    @IsTest static void OrkBL_isTaskForExit(){
        Task t = new task();
        boolean bool;
        test.startTest();
            bool=OrkBL.isTaskForExit(t);
        test.stopTest();
        System.assertEquals(true,bool);
    }   
    @IsTest static void OrkBL_isTaskForJump(){
        Task t = new task();
        boolean bool;
        
        test.startTest();
            bool=OrkBL.isTaskForJump(t);
        test.stopTest();
        System.assertEquals(false,bool);
    }   
    @IsTest static void OrkBL_isJumpAutomatico(){
        Task t = new task();
        pratica__c p= new pratica__c();
        strategia__c s= new strategia__c();
        
        boolean bool;
        test.startTest();
            bool=OrkBL.isJumpAutomatico(t,p,s);
        test.stopTest();
        System.assertEquals(true,bool);
    }   
    @IsTest static void OrkBL_isTaskForActivity(){
        Task t = new task();
        boolean bool;
        ActivityExtended__c ae = new ActivityExtended__c();
        insert ae;
        t.ActivityExtended__c = ae.Id;
        test.startTest();
            bool=OrkBL.isTaskForActivity(t);
        test.stopTest();
        System.assertEquals(false,bool);
    }
    @IsTest static void OrkBL_setEnteringInStrategiaError(){
        Task t = new task();
        boolean bool;
        ActivityExtended__c ae = new ActivityExtended__c();
        insert ae;
        t.ActivityExtended__c = ae.Id;
        test.startTest();
            bool=OrkBL.setEnteringInStrategiaError(t,ae);
        test.stopTest();
        System.assertEquals(true,bool);
    }
    @IsTest static void OrkBL_setActivitySuccess_ok(){
        Task t = new task();
        ActivityExtended__c ae = new ActivityExtended__c();
        insert ae;
        t.ActivityExtended__c = ae.Id;
        pratica__c p= new pratica__c();
        test.startTest();
            OrkBL.setActivitySuccess(t,ae,p,'OK');
        test.stopTest();
    }   
    @IsTest static void OrkBL_setActivitySuccess_ko(){
        task t = new task();
        ActivityExtended__c ae = new ActivityExtended__c();
        insert ae;
        t.ActivityExtended__c = ae.Id;
        pratica__c p= new pratica__c();
        test.startTest();
            OrkBL.setActivitySuccess(t,ae,p,'KO');
        test.stopTest();
    }       
    @IsTest static void OrkBL_isNextJob(){
        task t = new task();
        boolean bool;
         ActivityExtended__c ae = new ActivityExtended__c();
        insert ae;
        t.ActivityExtended__c = ae.Id;
        test.startTest();
            bool=OrkBL.isNextJob(t);
        test.stopTest();
        System.assertEquals(false,bool);
    }   
    @IsTest static void OrkBL_isTaskForLoop(){
        task t = new task();
        boolean bool;
        ActivityExtended__c ae = new ActivityExtended__c();
        insert ae;
        t.ActivityExtended__c = ae.Id;
        test.startTest();
            bool=OrkBL.isTaskForLoop(t);
        test.stopTest();
        System.assertEquals(false,bool);
    }   
    @IsTest static void OrkBL_setJumpError(){
        task t = new task();
        ActivityExtended__c ae = new ActivityExtended__c();
        insert ae;
        t.ActivityExtended__c = ae.Id;
        boolean bool;
        test.startTest();
            bool=OrkBL.setJumpError(t);
        test.stopTest();
        System.assertEquals(true,bool);
    }       
    @IsTest static void OrkBL_setLoopError(){
        task t = new task();
        ActivityExtended__c ae = new ActivityExtended__c();
        insert ae;
        t.ActivityExtended__c = ae.Id;
        boolean bool;
        test.startTest();
            bool=OrkBL.setLoopError(t);
        test.stopTest();
        System.assertEquals(true,bool);
    }           
    @IsTest static void OrkBL_newTask_pratica(){
        pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        insert p; 
        
        Task t = new task();
        ActivityExtended__c ae = new ActivityExtended__c();
        insert ae;
        t.ActivityExtended__c = ae.Id;
        test.startTest();
            List<SObject> tt = OrkBL.newTask(p);
        test.stopTest();
    }   
    @IsTest static void OrkBL_newTask_p_s_no_sla(){
    
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
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id,sList[2].id));
        sList[5].isAutomaticJump__c=true;
        upsert sList;
        testata.stato__c='Attiva';
        update testata;
        
        strategia__c strategia = new strategia__c();
        strategia=sList[2];
        
        pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        insert p; 
        
        Task t = new task();
        ActivityExtended__c ae = new ActivityExtended__c();
        insert ae;
        t.ActivityExtended__c = ae.Id;
        test.startTest();
            List<Sobject> tt = OrkBL.newTask(p,strategia);
        test.stopTest();
    }

    @IsTest static void OrkBL_newTask_p_s_t(){
    
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
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id,sList[2].id));
        sList[5].isAutomaticJump__c=true;
        upsert sList;
        testata.stato__c='Attiva';
        update testata;
        
        strategia__c strategia = new strategia__c();
        strategia=sList[2];
        strategia.isSLA_present__c=true;
        strategia.SLA__c=2;
        
        pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        insert p; 
        
        Task t = new task();

        List<Sobject> tt = OrkBL.newTask(p,strategia);
        insert tt;
        for (SObject tmp: tt) {
            if (tmp instanceof Task) {
                t = (Task) tmp;
            }
        } 
        Boolean perm = OrkBL.getTaskFielsPermission('CREATE');
        Boolean cebPerm = OrkBL.cebGetTaskFielsPermission(gd,'CREATE');
        String esito = '';
        test.startTest();
            TaskHandler.internalUpdate = true;
            List<Sobject> ttnew = OrkBL.newTask(t,p,strategia,'');
        ActivityExtended__c ae = [SELECT Id FROM ActivityExtended__c LIMIT 1];
        List<Pratica__c> praList = new List<Pratica__c>();
        praList.add(p);
        Map<String, SObject> objectForPraticaMap = CrabbEngineUtils.generateMapsFieldUpdate(praList, Schema.getGlobalDescribe());
        List<Sobject> cebttnew = OrkBL.CebNewTask(Schema.getGlobalDescribe(),t, ae, p,strategia,'');
        List<Sobject> cebttnewEng = OrkBL.cebEngineNewTask(Schema.getGlobalDescribe(),t, ae, p,strategia,'');

        Map<string,Pratica__c> pMap = new Map<string,Pratica__c> ();
        Map<string,Task> tMap = new Map<string,Task>();
        Map<id, SObject> sobjectsToUpdate = new Map<Id, SObject>();
        list<string> actExtIdList = new list<string>();
        for(Pratica__c prat : praList){
            pMap.put(prat.id,prat);
            if(prat.Tasks.size()>0){
                tMap.put(prat.Tasks[0].id,prat.Tasks[0]);
                sobjectsToUpdate.put(prat.Tasks[0].id,prat.Tasks[0]);
                if (prat.Tasks[0].ActivityExtended__c != null) actExtIdList.add(prat.Tasks[0].ActivityExtended__c);
            }
            sobjectsToUpdate.put(prat.id,prat);
        }
        List<Sobject> cebttnewEngSFU = OrkBL.cebEngineNewTask(objectForPraticaMap, sobjectsToUpdate, Schema.getGlobalDescribe(),t, ae, p,strategia,'');

        test.stopTest();
    }

    @IsTest static void OrkBL_newTaskfromJump(){
    
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
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id,sList[2].id));
        sList[5].isAutomaticJump__c=true;
        upsert sList;
        testata.stato__c='Attiva';
        update testata;
        
        strategia__c strategia = new strategia__c();
        strategia=sList[2];
        strategia.isSLA_present__c=true;
        strategia.SLA__c=2;
        
        pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        insert p; 
        
        Task t = new task();
        List<Sobject> tl = OrkBL.newTask(p,strategia);
        insert tl;
        for (SObject tmp: tl) {
            if (tmp instanceof Task) {
                t = (Task) tmp;
            }
        } 
        Boolean perm = OrkBL.getTaskFielsPermission('CREATE');
        Boolean cebPerm = OrkBL.cebGetTaskFielsPermission(gd,'CREATE');

        List<Pratica__c> praList = new List<Pratica__c>();
        praList.add(p);
        Map<String, SObject> objectForPraticaMap = CrabbEngineUtils.generateMapsFieldUpdate(praList, Schema.getGlobalDescribe());
        Map<string,Pratica__c> pMap = new Map<string,Pratica__c> ();
        Map<string,Task> tMap = new Map<string,Task>();
        Map<id, SObject> sobjectsToUpdate = new Map<Id, SObject>();
        list<string> actExtIdList = new list<string>();
        for(Pratica__c prat : praList){
            pMap.put(prat.id,prat);
            if(prat.Tasks.size()>0){
                tMap.put(prat.Tasks[0].id,prat.Tasks[0]);
                sobjectsToUpdate.put(prat.Tasks[0].id,prat.Tasks[0]);
                if (prat.Tasks[0].ActivityExtended__c != null) actExtIdList.add(prat.Tasks[0].ActivityExtended__c);
            }
            sobjectsToUpdate.put(prat.id,prat);
        }

        test.startTest();
            List<Sobject> tnew = OrkBL.newTaskFromJump(t,p,strategia);
            List<Sobject> tnewEngSFU = OrkBL.newSetTaskFromJump(objectForPraticaMap, sobjectsToUpdate, t,p,strategia);
        test.stopTest();
    }           
    
    @IsTest static void OrkBL_setEnteringInStrategia(){
    
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
        sList.add(TestClassForDatagenerationCreateData.getTestStrategiaSTEP(testata.id,sList[2].id));
        sList[5].isAutomaticJump__c=true;
        upsert sList;
        testata.stato__c='Attiva';
        update testata;
        
        strategia__c cdi = new strategia__c();
        cdi=sList[1];

        pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        insert p; 
        p.byPassRole__c=''+System.Now();
        update p;
        
        Map<id,SObject> sobjectsToUpdate = new Map<id,SObject>();
        sobjectsToUpdate.put(p.id,p);
        List<SObject> sobjectsToInsert = new List<SObject>();
        List<Log__c> logL =new List<Log__c>();
        
        task t = new Task();
        string taskFields =TestStatic.getTaskAllFieds();
        System.debug('taskFields' +taskFields);
        string query = 'Select '+ taskFields +', ActivityExtended__r.code_Status__c' + ' From Task Where whatid=\''+p.id+'\'';
        t=database.query(query);
        System.debug('task Rei'+t);
        ActivityExtended__c ae0 = new ActivityExtended__c();
        insert ae0;
        t.ActivityExtended__c = ae0.Id;
        Map<Id,ActivityExtended__c> aes2Obj = new Map<Id,ActivityExtended__c>();
        List<Task> tList = new List<Task>();
        tlist.add(t);
        aes2Obj = Utils.getTaskWithActivityExtended(tList);
        ActivityExtended__c ae = aes2Obj.get(t.Id);
        test.startTest();
            OrkBL.setEnteringInStrategia(t,ae,p,cdi, sobjectsToUpdate,sobjectsToInsert,logL );
        test.stopTest();
    } 
    @IsTest static void OrkBL_isNecessaryGoOut(){
        strategia__c testata = new strategia__c();
        testata= TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        insert p; 
        p.byPassRole__c=''+System.Now();
        update p;

        Map<id,SObject> sobjectsToUpdate = new Map<id,SObject>();
        sobjectsToUpdate.put(p.id,p);
        List<SObject> sobjectsToInsert = new List<SObject>();
        List<Log__c> logL =new List<Log__c>();
        task t = new Task();
        string taskFields =TestStatic.getTaskAllFieds();
        string query = 'Select '+ taskFields + ' From Task Where whatid=\''+p.id+'\'';
        t=database.query(query);
        ActivityExtended__c ae0 = new ActivityExtended__c();
        insert ae0;
        t.ActivityExtended__c = ae0.Id;
        Map<Id,ActivityExtended__c> aes2Obj = new Map<Id,ActivityExtended__c>();
        List<Task> tList = new List<Task>();
        tlist.add(t);
        aes2Obj = Utils.getTaskWithActivityExtended(tList);
        ActivityExtended__c ae = aes2Obj.get(t.Id);
        test.startTest();
            OrkBL.isNecessaryGoOut(t,ae,p,testata, sobjectsToUpdate,sobjectsToInsert,logL );
        test.stopTest();
    }   
    @IsTest static void OrkBL_isNecessaryGoOut_residuoTotale(){
        account acc = TestClassForDatagenerationCreateData.getTestAccount();
        insert acc;
        strategia__c testata = new strategia__c();
        testata= TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        
        pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        p.account__c=acc.id;
        insert p;

        movimento__c m = new movimento__c();
        m=TestClassForDatagenerationCreateData.getTestMovimento();
        m.Tipo_Scadenza__c='Scaduta';
        m.Sollecitabile__c=true;
        m.Residuo__c=0;
        m.Pratica__c=p.id;
        m.account__c=acc.id;
        insert m;
        
        p.byPassRole__c=''+System.Now();
        update p;
        string praticaFields =TestStatic.getPraticaAllFieds();
        string query = 'Select '+ praticaFields + ' From Pratica__c Where id=\''+p.id+'\'';
        p=database.query(query);
        
        Map<id,SObject> sobjectsToUpdate = new Map<id,SObject>();
        sobjectsToUpdate.put(p.id,p);
        List<SObject> sobjectsToInsert = new List<SObject>();
        List<Log__c> logL =new List<Log__c>();
        task t = new Task();
        string taskFields =TestStatic.getTaskAllFieds();
        query = 'Select '+ taskFields + ' From Task Where whatid=\''+p.id+'\'';
        t=database.query(query);
        ActivityExtended__c ae0 = new ActivityExtended__c();
        insert ae0;
        t.ActivityExtended__c = ae0.Id;
        Map<Id,ActivityExtended__c> aes2Obj = new Map<Id,ActivityExtended__c>();
        List<Task> tList = new List<Task>();
        tlist.add(t);
        aes2Obj = Utils.getTaskWithActivityExtended(tList);
        ActivityExtended__c ae = aes2Obj.get(t.Id);
        test.startTest();
            OrkBL.isNecessaryGoOut(t,ae,p,testata, sobjectsToUpdate,sobjectsToInsert,logL );
        test.stopTest();
    }   
    @IsTest static void OrkBL_setNextStep(){
    
        strategia__c testata = new strategia__c();
        testata= TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;

        pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        insert p; 
        p.byPassRole__c=''+System.Now();
        update p;
        
        Map<id,SObject> sobjectsToUpdate = new Map<id,SObject>();
        sobjectsToUpdate.put(p.id,p);
        List<SObject> sobjectsToInsert = new List<SObject>();
        List<Log__c> logL =new List<Log__c>();
        
        task t = new Task();
        string taskFields =TestStatic.getTaskAllFieds();
        string query = 'Select '+ taskFields + ' From Task Where whatid=\''+p.id+'\'';
        System.Debug('query --> ' + query);
        t=database.query(query);
        System.Debug('t --> ' + t);
        ActivityExtended__c ae0 = new ActivityExtended__c();
        insert ae0;
        t.ActivityExtended__c = ae0.Id;
        Map<Id,ActivityExtended__c> aes2Obj = new Map<Id,ActivityExtended__c>();
        List<Task> tList = new List<Task>();
        tlist.add(t);
        aes2Obj = Utils.getTaskWithActivityExtended(tList);
        ActivityExtended__c ae = aes2Obj.get(t.Id);

        List<Pratica__c> pList = new List<Pratica__c>();
        pList.add(p);
        Map<String, SObject> objectForPraticaMap = CrabbEngineUtils.generateMapsFieldUpdate(pList, gd);
        test.startTest();
            OrkBL.setNextStep(t,ae,p,testata, sobjectsToUpdate,sobjectsToInsert,logL );
            OrkBL.cebSetNextStep(objectForPraticaMap, t,ae,p,testata, sobjectsToUpdate,sobjectsToInsert,logL );
        test.stopTest();
    }   
    @IsTest static void OrkBL_setExitSuccess(){
        strategia__c testata = new strategia__c();
        testata= TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;

        pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        insert p; 
        p.byPassRole__c=''+System.Now();
        update p;
        
        Map<id,SObject> sobjectsToUpdate = new Map<id,SObject>();
        sobjectsToUpdate.put(p.id,p);
        List<SObject> sobjectsToInsert = new List<SObject>();
        List<Log__c> logL =new List<Log__c>();
        
        task t = new Task();
        string taskFields =TestStatic.getTaskAllFieds();
        string query = 'Select '+ taskFields + ' From Task Where whatid=\''+p.id+'\'';
        t=database.query(query);
        ActivityExtended__c ae0 = new ActivityExtended__c();
        insert ae0;
        t.ActivityExtended__c = ae0.Id;
        Map<Id,ActivityExtended__c> aes2Obj = new Map<Id,ActivityExtended__c>();
        List<Task> tList = new List<Task>();
        tlist.add(t);
        aes2Obj = Utils.getTaskWithActivityExtended(tList);
        ActivityExtended__c ae = aes2Obj.get(t.Id);
        test.startTest();
            OrkBL.setExitSuccess(t,ae,p,testata, sobjectsToUpdate,sobjectsToInsert,logL );
        test.stopTest();
    }      
    @IsTest static void OrkBL_setExitSuccess_withRules(){
        
        strategia__c testata = new strategia__c();
        testata= TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        testata.comune__c='ComuneTest';
        testata.Activation_roles__c='rc1';
        insert testata;
        
        Rule_control__c rc= new Rule_control__c();
        rc.name='rc1';
        rc.Api_field_name__c='Comune__c';
        rc.Api_object_name__c='Pratica__c';
        rc.condition__c='=';
        rc.Note__c='xx';
        rc.Rule_name__c='ruleforTest';
        rc.Strategia_api_field_name__c='Comune__c';
        insert rc;
        
        pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        insert p; 
        p.byPassRole__c=''+System.Now();
        update p;
        
        Map<id,SObject> sobjectsToUpdate = new Map<id,SObject>();
        sobjectsToUpdate.put(p.id,p);
        List<SObject> sobjectsToInsert = new List<SObject>();
        List<Log__c> logL =new List<Log__c>();
        
        task t = new Task();
        string taskFields =TestStatic.getTaskAllFieds();
        string query = 'Select '+ taskFields + ' From Task Where whatid=\''+p.id+'\'';
        t=database.query(query);
        ActivityExtended__c ae0 = new ActivityExtended__c();
        insert ae0;
        t.ActivityExtended__c = ae0.Id;
        Map<Id,ActivityExtended__c> aes2Obj = new Map<Id,ActivityExtended__c>();
        List<Task> tList = new List<Task>();
        tlist.add(t);
        aes2Obj = Utils.getTaskWithActivityExtended(tList);
        ActivityExtended__c ae = aes2Obj.get(t.Id);
        test.startTest();
            OrkBL.setExitSuccess(t,ae,p,testata, sobjectsToUpdate,sobjectsToInsert,logL );
        test.stopTest();
    }       
    @IsTest static void OrkBL_setExitSuccess_esciEchiudi(){
        strategia__c testata = new strategia__c();
        testata= TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        testata.esci_e_chiudi__c=true;
        insert testata;

        pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        insert p; 
        p.byPassRole__c=''+System.Now();
        update p;
        
        Map<id,SObject> sobjectsToUpdate = new Map<id,SObject>();
        sobjectsToUpdate.put(p.id,p);
        List<SObject> sobjectsToInsert = new List<SObject>();
        List<Log__c> logL =new List<Log__c>();
        
        task t = new Task();
        string taskFields =TestStatic.getTaskAllFieds();
        string query = 'Select '+ taskFields + ' From Task Where whatid=\''+p.id+'\'';
        t=database.query(query);
        ActivityExtended__c ae0 = new ActivityExtended__c();
        insert ae0;
        t.ActivityExtended__c = ae0.Id;
        Map<Id,ActivityExtended__c> aes2Obj = new Map<Id,ActivityExtended__c>();
        List<Task> tList = new List<Task>();
        tlist.add(t);
        aes2Obj = Utils.getTaskWithActivityExtended(tList);
        ActivityExtended__c ae = aes2Obj.get(t.Id);
        test.startTest();
            OrkBL.setExitSuccess(t,ae,p,testata, sobjectsToUpdate,sobjectsToInsert,logL );
        test.stopTest();
    }   
    @IsTest static void OrkBL_setJumpSuccess(){
        strategia__c testata = new strategia__c();
        testata= TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;

        pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        insert p; 
        p.byPassRole__c=''+System.Now();
        update p;
        
        Map<id,SObject> sobjectsToUpdate = new Map<id,SObject>();
        sobjectsToUpdate.put(p.id,p);
        List<SObject> sobjectsToInsert = new List<SObject>();
        List<Log__c> logL =new List<Log__c>();
        
        task t = new Task();
        string taskFields =TestStatic.getTaskAllFieds();
        string query = 'Select '+ taskFields + ' From Task Where whatid=\''+p.id+'\'';
        t=database.query(query);
        ActivityExtended__c ae0 = new ActivityExtended__c();
        insert ae0;
        t.ActivityExtended__c = ae0.Id;
        Map<Id,ActivityExtended__c> aes2Obj = new Map<Id,ActivityExtended__c>();
        List<Task> tList = new List<Task>();
        tlist.add(t);
        aes2Obj = Utils.getTaskWithActivityExtended(tList);
        ActivityExtended__c ae = aes2Obj.get(t.Id);
        test.startTest();
            OrkBL.setJumpSuccess(t,ae,p,testata, sobjectsToUpdate,sobjectsToInsert,logL );
        test.stopTest();
    }   
    @IsTest static void OrkBL_setLoopSuccess(){
        strategia__c testata = new strategia__c();
        testata= TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;

        pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        insert p; 
        p.byPassRole__c=''+System.Now();
        update p;
        
        Map<id,SObject> sobjectsToUpdate = new Map<id,SObject>();
        sobjectsToUpdate.put(p.id,p);
        List<SObject> sobjectsToInsert = new List<SObject>();
        List<Log__c> logL =new List<Log__c>();
        
        task t = new Task();
        string taskFields =TestStatic.getTaskAllFieds();
        string query = 'Select '+ taskFields + ' From Task Where whatid=\''+p.id+'\'';
        t=database.query(query);
        ActivityExtended__c ae0 = new ActivityExtended__c();
        insert ae0;
        t.ActivityExtended__c = ae0.Id;
        Map<Id,ActivityExtended__c> aes2Obj = new Map<Id,ActivityExtended__c>();
        List<Task> tList = new List<Task>();
        tlist.add(t);
        aes2Obj = Utils.getTaskWithActivityExtended(tList);
        ActivityExtended__c ae = aes2Obj.get(t.Id);
        test.startTest();
            OrkBL.setLoopSuccess(t,ae,p,testata, sobjectsToUpdate,sobjectsToInsert,logL );
        test.stopTest();
    }   
    
    @IsTest static void OrkBL_getPraticheProcessabili(){
        strategia__c testata = new strategia__c();
        testata= TestClassForDatagenerationCreateData.getTestStrategiaTestata();
        insert testata;
        List<pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(10);
        insert pList;
        pList[0].stato__c='Chiusa';
        pList[1].stato__c='Bloccata';
        Map<ID, pratica__c> pMap= new Map<id,pratica__c>(pList);
        
        test.startTest();
            OrkBL.getPraticheProcessabili('token',pMap, testata);
        test.stopTest();
    } 
    //ancora da fare
    /*
    - getPraticheProcessabili
    - setJumpSuccess
    - logRules
    - setLoopSuccess */
}