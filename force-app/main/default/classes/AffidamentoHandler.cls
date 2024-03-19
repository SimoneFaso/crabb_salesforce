/* ---------------------------------------------------------------------------------------------------------------------
Name:            AffidamentoHandlera.cls
Description:
Test class:

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
16-Sep-2022  0.2      C.Sanna & R.Kurti    Added WITH SECURITY ENFORCED and replaced CheckFLSPermission with cebCheckFLSPermission (security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class AffidamentoHandler implements ITrigger{
    public static Map<String, SObjectType> gd = Schema.getGlobalDescribe();

    public AffidamentoHandler (){

    }
    public void bulkBefore(){

    }

    public void bulkAfter(){

    }

    public void bulkAfter(List<SObject> soListNew){

    }

    public void bulkAfter(List<SObject> soListOld,List<SObject> soListNew){

    }

    public void bulkBefore(List<SObject> soListNew){

    }

    public void bulkBefore(List<SObject> soListOld,List<SObject> soListNew){

    }

    public void beforeInsert(List<SObject> soListNew){

    }


    /* Endrit Sino Inizio 
    *  Metodo per il gestione della revoca dei affidamenti.
    *  Data: 10//9/2014
    */
    public void beforeUpdate(LIST<SObject> soList, LIST<SObject> oList){

        // typecast i nostri affidamenti
        List<Affidamento__c> newAffList = new List<Affidamento__c>();
        newAffList = (List<Affidamento__c>) soList;
        List<Affidamento__c> oldAffList = new List<Affidamento__c>();
        oldAffList = (List<Affidamento__c>) oList;

        // collection uttili
        Map<id, Affidamento__c> oldAffMap = new Map<id, Affidamento__c>(oldAffList);
        Map<id, Affidamento__c> newAffMap = new Map<id, Affidamento__c>(newAffList);

        // id delle pratiche associate
        Set<id> pratId = new Set<id>();

        // 1. controllo il cambio dello stato
        for(Affidamento__c oldAff: oldAffMap.values())
        {
            // leggi i valori futuri
            Affidamento__c newAff = new Affidamento__c();
            newAff = newAffMap.get(oldaff.id);

            /*
            *   Se lo stato non e cambiato da Attiva => Revocata
            *   la rimuoviamo dalla mapa newAffMap, che alla fine rimangono solo i affidamenti di interesse.
            */
            if(!(newAff.Stato__c == 'Revocata' && oldAff.Stato__c == 'In Corso'))
            {
                newAffMap.remove(oldAff.id);
                pratId.add(oldAff.Pratica__c);
            }
        }

        // 2. Chiedi le pratiche associate
        if(pratId.size() > 0){
            /*if(Utils.checkFLSPermission('pratica__c', 'Stato__c').get('ACCESS')
                    && Utils.checkFLSPermission('pratica__c', 'Residuo_Totale__c').get('ACCESS')) {*/
            if(Utils.cebCheckFLSPermission('pratica__c', 'Stato__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('pratica__c', 'Residuo_Totale__c',gd).get('ACCESS')) {
                Map<id, Pratica__c> pratMap = new Map<id, Pratica__c>([Select id, Stato__c, residuo_Totale__c From Pratica__c where id In :pratId WITH SECURITY_ENFORCED]);

                for (Pratica__c p : pratMap.Values()) {
                    // process pratiche di interesse
                }
            }

        }

        // 3. Vai a modificare Data_Scaduto_fine_periodo_affidamento__c & Scaduto_fine_periodo_affidamento__c, 
        // se qualche affido é scaduto
        updateAffidoDopoScaduto(oldAffList);

    }


    public void beforeDelete(List<SObject> so){

    }

    public void afterInsert(List<Affidamento__c> newaff)
    {
        CrabbSharing.AffidoSharing(newaff);

        //New Engine Management that creates ASS event on Object CEB__c for each Affidamento__c
        if(CEBUtils.newOrkVersionEnabled()) {
            List<Id> praList = new List<Id>();

            for(Affidamento__c aff : newaff) {
                if(aff.Pratica__c != null) {
                    praList.add(aff.Pratica__c);
                }
            }

            if(praList.size() > 0) {
                CEBUtils.addCebEvents(false, praList, 'ASS');
            }
        }
        /*String debug = '\n afterInsert(), ';
        Map<Id,String[]> pr = new Map<Id,String[]>();
        Map<Id, Affidamento__c> AffMap = new Map<Id, Affidamento__c>();
        Set<id> PraticaToRemoveShare=new set<id>();
        Set<id> AccountToRemoveShare=new set<id>();
        
        for (Affidamento__c aff : newaff) 
        {
            AffMap.put(aff.Id, aff);
            debug += '\n \n Nome Collector Calc: ' + aff.Nome_Collector__c;
            String[] aTemp = new String[]{aff.Nome_Collector__c,aff.Id_User_Assegnatario_Pratica__c};
            pr.put(aff.Pratica__c,aTemp);
        }
        List<Pratica__Share> pratShrs  = new List<Pratica__Share>();
        List<AccountShare> accShrs = new List<AccountShare>();

        if(Utils.checkFLSPermission('pratica__c', 'Nome_Collector_Attivo__c').get('ACCESS')
            && Utils.checkFLSPermission('pratica__c', 'Account__c').get('ACCESS'))
        {
            Map<Id,Pratica__c> prat = new Map<Id,Pratica__c>([Select Id,Nome_Collector_Attivo__c,Account__c From Pratica__c where Id in :pr.keySet()]);
            
            debug += '\n\n PraticaShare inizializzato!';
            debug += '\n Praticas to Process: ' + String.valueOf(prat);
            for(Pratica__c target : prat.values())
            {
                Id prId = target.Id;
                String NomeColl = pr.get(prId)[0];
                System.Debug('Pratica 2 ' + prId);
                System.Debug('Nome Collector 2 ' + NomeColl);
                target.Nome_Collector_Attivo__c = NomeColl;
                
                Pratica__Share ps = new Pratica__Share();
                Id userId = Id.ValueOf(pr.get(target.Id)[1]);
                ps.ParentId = target.Id;
                ps.AccessLevel = 'edit';
                ps.UserOrGroupId = userId;
                //ps.RowCause = Schema.Pratica__Share.RowCause.Affido__c;
                ps.RowCause = Schema.Pratica__Share.RowCause.Manual;
                pratShrs.add(ps); 
                
                AccountShare accs = new AccountShare();
                System.debug('Cliente: ' + string.valueOf(target.Account__c));
                accs.AccountId = target.Account__c;
                accs.AccountAccessLevel = 'edit';
                accs.CaseAccessLevel = 'edit';
                accs.OpportunityAccessLevel = 'edit';
                accs.UserOrGroupId = userId;
                //accs.RowCause = Schema.Pratica__Share.RowCause.Affido__c;
                accShrs.add(accs);
            }
            if (Utils.checkFLSPermission('Pratica__c', 'Nome_Collector_Attivo__c').get('UPDATE') ) update prat.values();        
        }
        try
        {
            if (Utils.checkFLSPermission('AccountShare', 'AccountId').get('CREATE') 
                && Utils.checkFLSPermission('AccountShare', 'AccountAccessLevel').get('CREATE')
                && Utils.checkFLSPermission('AccountShare', 'CaseAccessLevel').get('CREATE')
                && Utils.checkFLSPermission('AccountShare', 'OpportunityAccessLevel').get('CREATE')
                && Utils.checkFLSPermission('AccountShare', 'UserOrGroupId').get('CREATE')
            ) insert accShrs;
            debug += '\n Inseriti accShrs: ' + String.valueOf(accShrs);
        }
        catch(Exception e)
        {
            System.debug('Eccezione nel metodo sbianca: ' + e.getMessage());
            debug += '\n \n Eccezione nel inserimento dei Account Share! \n Dettagli: ' + e.getMessage();
        }
        
        Database.SaveResult[] lsr = null;
        if (Utils.checkFLSPermission('Pratica__Share', 'ParentId').get('CREATE')
            && Utils.checkFLSPermission('Pratica__Share', 'AccessLevel').get('CREATE')
            && Utils.checkFLSPermission('Pratica__Share', 'UserOrGroupId').get('CREATE')
            && Utils.checkFLSPermission('Pratica__Share', 'RowCause').get('CREATE')
            ) lsr = Database.insert(pratShrs,false);
        debug += '\n\n SaveResult Collection: ' + String.valueOF(lsr);
        Integer x=0;
        
        for(Database.SaveResult sr : lsr)
        {
            if(!sr.isSuccess())
            {
                Database.Error err = sr.getErrors()[0];
                debug += '\n\n SR ' + x + ', Error instance, err: ' + String.valueOF(err);
                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  err.getMessage().contains('AccessLevel')))
                {
                	AffMap.get(pratShrs[x].ParentId).addError('Unable to grant sharing access due to following exception: ' + err.getMessage());
                }           
            }
            x++;
        }
        ErrorClass.logError('\n AffidamentiHandler', '\n ' + debug);*/
    }

    public void afterUpdate(List<Affidamento__c> old_col, List<Affidamento__c> col){
        Map<id,Affidamento__C> amap=new Map<id,Affidamento__C>(old_col);
        set<string> statusActive = New set<string> ();
        set<string> statusInactive = New set<string>();
        Map<string,string>  ObjectsToRemoveShare=new Map<string,string> ();
        statusActive.add('In corso');
        statusActive.add('In creazione');
        statusActive.add('Da confermare');
        statusInactive.add('Paga Parzialmente');
        statusInactive.add('Paga Totalmente');
        statusInactive.add('Revocato');
        statusInactive.add('Scaduto');

        for(Affidamento__C a:col){
            Affidamento__C  aOld=amap.get(a.id);
            if(statusActive.contains(aOld.stato__c) && statusInactive.contains(a.stato__c) ){
                ObjectsToRemoveShare.put(a.pratica__c,a.FLow_Colelctor_user_id__c);
                ObjectsToRemoveShare.put(a.Flow_Id_Account__c,a.FLow_Colelctor_user_id__c);
            }
        }
        if(ObjectsToRemoveShare!=null && ObjectsToRemoveShare.size()>0){
            removeShare(ObjectsToRemoveShare);
        }
    }

    public void afterDelete(List<SObject> so){

    }
    public void andFinally(){

    }

    private void tasksForDaElaborare(List<SObject> oldSo, List<SObject> so){

    }

    // 
    // Metodi ausiliari
    public static void removeShare(Map<string,string> ObjectsToRemoveShare){
        set<string> idsObj = new set<string>();
        idsObj.addAll(ObjectsToRemoveShare.keyset());
        set<string> userIDs= new set<string>();
        userIDs.addAll(ObjectsToRemoveShare.values());

        List<AccountShare> accs=[Select id From AccountShare where accountid in:idsObj and UserOrGroupId in:userIDs and RowCause ='Manual' WITH SECURITY_ENFORCED];
        //List<AccountShare> accs=[Select id From AccountShare where accountid in:idsObj and UserOrGroupId in:userIDs and RowCause ='Manual'];
        List<Pratica__Share> ps=[Select id From Pratica__Share where ParentId in:idsObj and UserOrGroupId in:userIDs and RowCause IN ('Affido__c','Manual') WITH SECURITY_ENFORCED];
        //List<Pratica__Share> ps=[Select id From Pratica__Share where ParentId in:idsObj and UserOrGroupId in:userIDs and RowCause IN ('Affido__c','Manual')];
        //List<Pratica__Share> ps=[Select id From Pratica__Share where ParentId in:idsObj and UserOrGroupId in:userIDs and RowCause ='Affido__c'];
        if (Utils.cebCheckObjPermission('AccountShare', gd).get('DELETE')) {
            delete accs;
        }
        if (Utils.cebCheckObjPermission('Pratica__Share', gd).get('DELETE')) {
            delete ps;
        }

    }

    // E.S. Metodo per rinfrescare il affido, dopo di che si é stato passato nello stato scaduto.
    public void updateAffidoDopoScaduto(List<Affidamento__c> newaffList){
        for(affidamento__c a: newaffList){
            // compute condition
            boolean modify = (a.stato__c == 'Scaduto' || a.stato__c == 'Paga Parzialmente' || a.stato__c == 'Paga Totalmente' || a.stato__c == 'Revocato' ) && a.Scaduto_fine_periodo_affidamento__c == null ;
            if(modify){
                System.debug('É da modificare!' + a);
                a.Data_Scaduto_fine_periodo_affidamento__c=a.Data_scaduto_pratica_for_logic__c;
                a.Scaduto_fine_periodo_affidamento__c=a.Scaduto_pratica_for_logic__c;
            }
        }
    }
}