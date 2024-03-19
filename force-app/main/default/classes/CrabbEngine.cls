public with sharing class CrabbEngine implements Database.Batchable<sObject>, Database.Stateful {

    public Map<integer,Schedule_Batch__c> opsMap = new Map<integer,Schedule_Batch__c> ();
    public Map<String,String> statusMap = new Map<String, String>();
    public List<Pratica__c> manualPraticaList = new List<Pratica__c>();
    public integer mapIndex;

    public string Type;
    public boolean Wait_Due_Date;
    public boolean immediate_Action;
    public string Action_name;
    public logWrapper logwr;
    public Integer recordSum=0;

    //first
    public CrabbEngine(){
        this.mapIndex=0;

        list<Schedule_Batch__c> Schedule_Batchlist =  [select Id, CRABB_DEV__Type__c, name,CRABB_DEV__isActive__c,CRABB_DEV__Wait_Due_Date__c, CRABB_DEV__Order__c,CRABB_DEV__immediate_Action__c from CRABB_DEV__Schedule_Batch__c where CRABB_DEV__isActive__c=true order by CRABB_DEV__immediate_Action__c desc,CRABB_DEV__Order__c];
        integer forIndex =0;
        for(Schedule_Batch__c sb: Schedule_Batchlist){
            opsMap.put(forIndex,sb);
            forIndex++;
        }

        this.Type=opsMap.get(mapIndex).CRABB_DEV__Type__c;
        this.Wait_Due_Date=opsMap.get(mapIndex).CRABB_DEV__Wait_Due_Date__c;
        this.immediate_Action=opsMap.get(mapIndex).CRABB_DEV__immediate_Action__c;
        this.Action_name=opsMap.get(mapIndex).name;

        //updateCebsStatus(this.Type);
        System.debug('CrabbEngineConstr opsMap --> ' + opsMap);
    }

    //next
    public CrabbEngine(List<Pratica__c> mPraList, integer mapIndex,Map<integer,Schedule_Batch__c> opsMap, Map<String,String> statusMap){
        this.statusMap=statusMap;
        this.opsMap=opsMap;
        this.mapIndex=mapIndex;
        this.Type=opsMap.get(mapIndex).CRABB_DEV__Type__c;
        this.Wait_Due_Date=opsMap.get(mapIndex).CRABB_DEV__Wait_Due_Date__c;
        this.immediate_Action=opsMap.get(mapIndex).CRABB_DEV__immediate_Action__c;
        this.Action_name=opsMap.get(mapIndex).name;
        if(mPraList.size()!=0) {
            this.manualPraticaList = mPraList;
        }

        //updateCebsStatus(this.Type);
        System.debug('CrabbEngineConstr opsMap --> ' + opsMap);
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        handleLog('start',0);
        String query = cebQueryInitializer(manualPraticaList, Type, immediate_Action);

        return Database.getQueryLocator(query);

    }

    public void execute(Database.BatchableContext BC, List<Pratica__c> scope) {
        System.debug('CrabbEngine Action_name Execute scope size --> ' + scope.size());
        updateCebsStatus(Type);
        Map<String,String> statusMapApp = new Map<String, String>();
        recordSum=recordSum+scope.size();
        if(scope.size()>0){
            //do ops
            statusMapApp=new CrabbEngineUtils().defineStrategy(Action_name,scope);
        }

        statusMap.putAll(statusMapApp);


        System.debug('CrabbEngine Action_name Execute action name --> ' + Action_name);
        System.debug('CrabbEngine StatusMap Execute statusMap size--> ' + statusMap.size());
    }

    public void finish(Database.BatchableContext BC){
        handleLog('finish',recordSum);

        string previousKey= this.Type+string.valueof(this.Wait_Due_Date)+string.valueof(this.immediate_Action);
        this.mapIndex=this.mapIndex+1;

        //in case of a next op available, go ahead
        if(this.opsMap.containsKey(this.mapIndex)){
            string nextKey= this.opsMap.get(this.mapIndex).Type__c+string.valueof(this.opsMap.get(this.mapIndex).Wait_Due_Date__c)+string.valueof(this.opsMap.get(this.mapIndex).immediate_Action__c);
            handleStatus(statusMap);
            Database.executeBatch(new CrabbEngine(this.manualPraticaList, this.mapIndex,this.opsMap,this.statusMap));
        } else {
            handleStatus(statusMap);
        }

        /*else{ //if no other ops are required, change ceb status

            //lancio un batch che aggiorna gli evt SCH a NEW, Tutti gli altri vanno in DONE
            //DA CAPIRE CON SALA..come gestire i passaggi da inprogress a new/done/error (e se salvassimo l'esito sul ceb? non mi convice la numerosità)
            //ricordarsi di eliminare gli sch se la pra si chiude
            System.debug('CrabbEngine StatusMap Finish --> ' + statusMap.size());
            Database.executeBatch(new CEBupdateStatusBatch(statusMap), 50);


        }*/
    }

    public void handleLog(string pos, Integer ProcessedRecords){
        if(pos=='start'){
            this.logwr = new logWrapper();
            this.logwr.Start=Datetime.now();
            this.logwr.Batch='CrabbEngine';
        }
        if(pos=='finish'){
            this.logwr.Finish=Datetime.now();
            this.logwr.ProcessedRecords=ProcessedRecords;
            list<string> sli = new list<string>();
            sli.add(JSON.serialize(this.logwr));
            CRABB_Log_Utils.publishCRABBLog(sli);
        }

    }

    public void handleStatus(Map<String, String> statusMap) {
        Set<String> ProcessedEvtIdList = (Set<String>) statusMap.keySet();
        //string query = 'select id,CRABB_DEV__Type__c,CRABB_DEV__Status__c, CRABB_DEV__Pratica__c, CRABB_DEV__Pratica__r.CRABB_DEV__Stato__c from CEB__c where id in:ProcessedEvtIdList';
        string query = 'select id,CRABB_DEV__Type__c,CRABB_DEV__Status__c, CRABB_DEV__Pratica__c, CRABB_DEV__Pratica__r.CRABB_DEV__Stato__c from CEB__c where id in:ProcessedEvtIdList';

        List<CEB__c> cebToUpdate = (List<CEB__c>) Database.query(query);

        for(CEB__c c : cebToUpdate){
            if(c.CRABB_DEV__Status__c!='Blocked') {
                if(c.CRABB_DEV__Type__c=='SCH' && c.CRABB_DEV__Pratica__r.CRABB_DEV__Stato__c == 'Chiusa') {
                    c.CRABB_DEV__Status__c = 'Done';
                } else {
                    c.CRABB_DEV__Status__c = this.statusMap.get(c.id);
                }
            }
        }

        update cebToUpdate;
    }

    public void updateCebsStatus(String cebType) {
        string query = 'select id, pratica__c, Status__c,CRABB_DEV__Type__c, Wait_Due_Date__c, AE_Due_Date__c from CRABB_DEV__CEB__c where Status__c in (\'New\', \'Error\') and Type__c = :cebType and In_progress_Event__c = false';

        List<CEB__c> cebInProgress = (List<CEB__c>) Database.query(query);
        for(CEB__c ceb : cebInProgress) {
            ceb.Status__c = 'In Progress';
        }

        update cebInProgress;
    }

    public String cebQueryInitializer( List<Pratica__c> manualPraticaList, String Type, Boolean immediate_Action) {
        System.debug('QUERY LIMIT CRABB ENGINE ----> ' + Limits.getQueries());
        //nel batch "InitRecordsForCrabbEngineBatch" abbiamo selezionato i record con duedate null o <=today
        //string Wait_Due_Date_Cond = this.Wait_Due_Date?'Wait_Due_Date__c!=null':'Wait_Due_Date__c=null';
        string Wait_Due_Date_Cond='';
        if(this.Type.equalsIgnoreCase('CEX')) {
            if(this.Wait_Due_Date) {
                Wait_Due_Date_Cond = ' and Wait_Due_Date__c!=null and Wait_Due_Date__c<TODAY ';
            }
        } else {
            Wait_Due_Date_Cond = this.Wait_Due_Date?' and CRABB_DEV__AE_Due_Date__c!=null and CRABB_DEV__AE_Due_Date__c<TODAY ':' and CRABB_DEV__AE_Due_Date__c=null ';
        }
        //nel batch "InitRecordsForCrabbEngineBatch" abbiamo messo i ceb "in progress", elaboriamo quelli
        //string queryWhere ='where Status__c =\'In Progress\' and Type__c=:Type and '+Wait_Due_Date_Cond+' and Immediate_Action__c=:immediate_Action';
        string queryWhere ='where Status__c =\'New\' and Type__c=:Type '+Wait_Due_Date_Cond+' and Immediate_Action__c=:immediate_Action';

        string query = 'select id,Account__c,CRABB_DEV__Data_Invio_Sollecito__c, CRABB_DEV__Data_ultimo_invio_AR__c, CRABB_DEV__EC_Account__c,CRABB_DEV__EC_Pratica__c,Name, CRABB_DEV__Servizio_Fornitura__c, (select id from CRABB_DEV__Crabb_Events__r '+queryWhere+') from CRABB_DEV__Pratica__c where ';
        if(manualPraticaList.size()!=0) {
            query=query+'id in :manualPraticaList and ';
        }
        query=query+'createdDate = today and id in (select CRABB_DEV__Pratica__c from CRABB_DEV__CEB__c '+queryWhere+')';
//name in ('PR-0030980','PR-0030981') AND
        System.debug('Wait_Due_Date_Cond CrabbEngine --> ' + Wait_Due_Date_Cond);
        System.debug('immediate_Action CrabbEngine --> ' + immediate_Action);
        System.debug('queryWhere CrabbEngine --> ' + queryWhere);
        System.debug('queryWhere CrabbEngine --> ' + type);
        System.debug('Query CrabbEngine --> ' + query);

        return query;
    }

    public class logWrapper{
        public Datetime Start;
        public Datetime Finish;
        public Integer ProcessedRecords;
        public string Batch;
    }

}