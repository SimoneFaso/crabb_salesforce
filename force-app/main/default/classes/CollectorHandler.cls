/* ---------------------------------------------------------------------------------------------------------------------
Name:            CollectorHandler.cls
Description:
Test class:      TestCollectorHandler.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
12-Sep-2022  0.2      C.Sanna & R. Kurti              Added cebCheck Obj/FLS security and WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/
public without sharing class CollectorHandler implements ITrigger {
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public CollectorHandler() {

    }
    public void bulkBefore() {

    }

    public void bulkAfter() {

    }

    public void bulkAfter(List<SObject> soListNew) {

    }

    public void bulkAfter(List<SObject> soListOld, List<SObject> soListNew) {

    }

    public void bulkBefore(List<SObject> soListNew) {

    }

    public void bulkBefore(List<SObject> soListOld, List<SObject> soListNew) {

    }

    public void beforeInsert(List<Collector__c> col) {

    }
    public void beforeUpdate(LIST<SObject> soList, LIST<SObject> oList) {


        // typecast i nostri Collector

        List<Collector__c> newColl_List = new List<Collector__c>();
        newColl_List = (List<Collector__c>) oList;
        List<Collector__c> oldColl_List = new List<Collector__c>();
        oldColl_List = (List<Collector__c>) soList;

        // Servono per ricercare i dati da aggiornare

        Map<String, Collector__c> MapNomeCollOld = new Map<String, Collector__c>(); // conterrà i nomi dei collector OLD
        Map<Id, Id> AccountAffidati = new Map<Id, Id>();
        Map<Id, Id> PratAffidate = new Map<Id, Id>();

        Map<id, Collector__c> oldCollMap = new Map<id, Collector__c>(oldColl_List);
        Map<id, Collector__c> newCollMap = new Map<id, Collector__c>(newColl_List);


        // popolo l'oggetto Map solo per quei Collector per i quali è stato modificato l'assegnatario Pratica

        for (Collector__c COld : oldColl_List) {
            Id CollUserNew = newCollMap.get(COld.Id).User__c;
            Id CollUserOld = COld.User__c;

            if (CollUserNew != CollUserOld || Test.isRunningTest())// E.S. Per scorrere il codice anche in produzione. Difficoltá: Utenze restrite & il sistema ci impedisce di passare
            {                                                     // l'utenza da un utente con profilo CRABB Partner ... => System Administrator
                MapNomeCollOld.put(COld.name, COld);
            }
        }

        System.debug('Vediamo Size Mappa OldName: ' + MapNomeCollOld.size());
        System.debug('Vediamo Contenuto Mappa OldName: ' + MapNomeCollOld);

        // AccountShare e Pratica__Share legati al vecchio User
        if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Account__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Nome_Collector_Attivo__c', gd).get('ACCESS')) {
            List<Pratica__c> Prat_Aff = new List<Pratica__c>([
                    Select Id, Account__c, Nome_Collector_Attivo__c
                    from Pratica__c
                    where Nome_Collector_Attivo__c in :MapNomeCollOld.keySet()
                    WITH SECURITY_ENFORCED
            ]);
            System.debug('\n Query: ' + '[Select Id, Account__c, Nome_Collector_Attivo__c from Pratica__c where Nome_Collector_Attivo__c in : ' + MapNomeCollOld.keySet() + '\n Size: ' + Prat_Aff.size());
            if (Prat_Aff.size() > 0) {

                for (Pratica__c PA : Prat_Aff) {

                    Id IdCollOld = MapNomeCollOld.get(PA.Nome_Collector_Attivo__c).Id;
                    Id CollUserNew = newCollMap.get(IdCollOld).User__c;
                    Id CollUserOld = oldCollMap.get(IdCollOld).User__c;
                    System.debug('Vediamo User Old: ' + CollUserOld);
                    System.debug('Vediamo User new: ' + CollUserNew);
                    System.debug('Vediamo LA pratica: ' + PA.Id);
                    AccountAffidati.put(PA.Account__c, CollUserNew);
                    PratAffidate.put(PA.Id, CollUserNew);
                }

                System.debug('Vediamo Contenuto AccountAffid: ' + AccountAffidati);
                System.debug('Vediamo Contenuto Prat Aff: ' + PratAffidate);

                List<AccountShare> AccShare = new List<AccountShare>([
                        Select Id, UserOrGroupId, AccountId
                        from AccountShare
                        where AccountId in :AccountAffidati.keySet() and rowcause = 'Manual' and UserOrGroupId != :UserInfo.getUserId()
                        WITH SECURITY_ENFORCED
                ]);
                List<Pratica__Share> PratShare = new List<Pratica__Share>([
                        Select Id, UserOrGroupId, ParentId
                        from Pratica__Share
                        where rowcause = 'Affido__c' and ParentId in :PratAffidate.keySet()
                        WITH SECURITY_ENFORCED
                ]);
                System.debug('AccountShare: ' + AccShare.size());
                System.debug('ID ADMIN: ' + UserInfo.getUserId());


                /*
                if(AccShare.size()>0){
                    
                    for(AccountShare Ash :AccShare){
                        
                        Ash.UserOrGroupId = AccountAffidati.get(Ash.AccountId);
                    
                    }
                    
                    Update(AccShare);
                }
                
                if(PratShare.size()>0){
                    
                    for(Pratica__Share Ps :PratShare){
                        
                        Ps.UserOrGroupId = PratAffidate.get(Ps.ParentId);
                    }
                    
                    Update(PratShare);
                }
                Silvio: non si può aggiornare il record, va eliminato e creato nuovo */

                List<AccountShare> NewAshList = new List<AccountShare>();
                List<Pratica__Share> NewPsList = new List<Pratica__Share>();

                if (AccShare.size() > 0) {

                    for (AccountShare Ash : AccShare) {

                        // Creo i nuovi record sulle Share Table
                        System.debug('Account dentro: ' + Ash.AccountId);
                        AccountShare accs = new AccountShare();
                        accs.AccountId = Ash.AccountId;
                        accs.AccountAccessLevel = 'edit';
                        accs.CaseAccessLevel = 'edit';
                        accs.OpportunityAccessLevel = 'edit';
                        accs.UserOrGroupId = AccountAffidati.get(Ash.AccountId);
                        System.debug('User dentro: ' + accs.UserOrGroupId);
                        NewAshList.add(accs);
                    }

                    if (NewAshList.size() > 0) {

                        System.debug('Lista insert AccShare: ' + NewAshList);
                        Database.SaveResult[] lsrd = (Utils.checkFLSPermission('AccountShare', 'UserOrGroupId').get('INSERT')) ? Database.insert(NewAshList, false) : null;
                        System.debug('Faccio l\'insert degli account');
                        for (Database.SaveResult sr : lsrd) {

                            if (!sr.isSuccess()) {
                                // Operation failed, so get all errors
                                for (Database.Error err : sr.getErrors()) {
                                    System.debug('The following error has occurred.');
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    //System.debug('ShareCollector fields that affected this error: ' + err.getFields());
                                }
                            }
                        }
                    }
                    if (Utils.cebCheckObjPermission('AccountShare',gd).get('DELETE')) {
                        delete AccShare;
                    }
                }

                if (PratShare.size() > 0) {

                    for (Pratica__Share Psh : PratShare) {

                        Pratica__Share ps = new Pratica__Share();
                        ps.ParentId = Psh.ParentId;
                        ps.AccessLevel = 'edit';
                        ps.UserOrGroupId = PratAffidate.get(Psh.ParentId);
                        System.debug('Vediamo La pratica interno: ' + Psh.ParentId);
                        System.debug('Vediamo Lo user interno: ' + ps.UserOrGroupId);
                        ps.RowCause = Schema.Pratica__Share.RowCause.Affido__c;
                        NewPsList.add(ps);

                    }

                    if (NewPsList.size() > 0) {

                        System.debug('Lista insert NewPsList: ' + NewPsList);
                        Database.SaveResult[] lsrd = Database.insert(NewPsList, false);
                        System.debug('Faccio l\'insert delle pratiche');
                        for (Database.SaveResult sr : lsrd) {

                            if (!sr.isSuccess()) {
                                // Operation failed, so get all errors
                                for (Database.Error err : sr.getErrors()) {
                                    System.debug('The following error has occurred.');
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    //System.debug('ShareCollector fields that affected this error: ' + err.getFields());
                                }
                            }
                        }
                    }

                    if (Utils.cebCheckObjPermission('Pratica__Share',gd).get('DELETE')) {
                        delete (PratShare);
                    }
                }
            }
        }
    }

    public void beforeDelete(List<SObject> so) {

    }

    public void afterInsert(List<Collector__c> col) {
        List<Collector__Share> collShrs = new List<Collector__Share>();
        List<Account> lAcc = new List<Account>();
        Map<Id, Collector__c> ColMap = new Map<Id, Collector__c>();

        for (Collector__c coll : col) {

            ColMap.put(coll.Id, coll);

            if (coll.User__c == null) {
                String Err = 'Il collector ' + coll.Name + ' non ha un assegnatario pratica';
                TraceLog.ErrorLog('CollectorSharing', '', Err, '', '');
            } else {
                system.debug('*******coll.User__c = ' + coll.User__c);
                String sId = String.escapeSingleQuotes(coll.User__c);

                if (sId.length() == 15 || sId.length() == 18) {
                    Collector__Share cs = new Collector__Share();
                    cs.ParentId = coll.id;
                    cs.AccessLevel = 'edit';
                    Id userId = Id.ValueOf(coll.User__c);
                    cs.UserOrGroupId = userId;
                    cs.RowCause = Schema.Collector__Share.RowCause.Collector__c;
                    collShrs.add(cs);
                }
            }
        }

        Database.SaveResult[] lsr = (Utils.checkFLSPermission('Collector__Share', 'RowCause').get('INSERT')) ? Database.insert(collShrs, false) : null;

        Integer i = 0;

        for (Database.SaveResult sr : lsr) {
            if (!sr.isSuccess()) {
                Database.Error err = sr.getErrors()[0];

                if (!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION && err.getMessage().contains('AccessLevel'))) {
                    ColMap.get(collShrs[i].ParentId).addError('Unable to grant sharing access due to following exception: ' + err.getMessage());
                }
            }
            i++;
        }
    }

    public void afterUpdate(List<Collector__c> old_col, List<Collector__c> col) {

        List<Collector__Share> collShrs = new List<Collector__Share>();
        List<Account> lAcc = new List<Account>();
        Map<Id, Collector__c> ColMap = new Map<Id, Collector__c>();

        // Silvio Ivaldi 2014/10/14 per gestire correttamente gli aggiornamenti di visibilità

        Set<String> CollUSERSET = new Set<String>();
        List<Collector__Share> CollShareExst = new List<Collector__Share>([
                Select Id, ParentId, UserOrGroupId
                from Collector__Share
                where RowCause = 'Collector__c'
                WITH SECURITY_ENFORCED
        ]);
        List<Collector__Share> CollShareDelete = new List<Collector__Share>();
        Map<Id, Collector__Share> MapCollShare = new Map<Id, Collector__Share>();

        // Silvio Ivaldi: carico i dati già presenti sulla CollectorShare

        if (CollShareExst.size() > 0) {
            for (Collector__Share collSha : CollShareExst) {

                CollUSERSET.add(collSha.ParentId + '_' + collSha.UserOrGroupId);
                MapCollShare.put(collSha.ParentId, collSha);

            }
        }

        for (Collector__c coll : col) {

            ColMap.put(coll.Id, coll);

            if (coll.User__c == null) {
                String Err = 'Il collector ' + coll.Name + ' non ha un assegnatario pratica';
                TraceLog.ErrorLog('CollectorSharing', '', Err, '', '');
                // Silvio Ivaldi modifico in else if il record va inserito solo se non già presente
            } else if (CollUSERSET.size() <= 0) {

                system.debug('*******coll.User__c = ' + coll.User__c);
                String sId = String.escapeSingleQuotes(coll.User__c);

                if (sId.length() == 15 || sId.length() == 18) {
                    Collector__Share cs = new Collector__Share();
                    cs.ParentId = coll.id;
                    cs.AccessLevel = 'edit';
                    Id userId = Id.ValueOf(coll.User__c);
                    cs.UserOrGroupId = userId;
                    cs.RowCause = Schema.Collector__Share.RowCause.Collector__c;
                    collShrs.add(cs);
                }

            } else if (!CollUSERSET.contains(coll.Id + '_' + coll.User__c)) {

                String sId = String.escapeSingleQuotes(coll.User__c);

                if (sId.length() == 15 || sId.length() == 18) {
                    Collector__Share cs = new Collector__Share();
                    cs.ParentId = coll.id;
                    cs.AccessLevel = 'edit';
                    Id userId = Id.ValueOf(coll.User__c);
                    cs.UserOrGroupId = userId;
                    cs.RowCause = Schema.Collector__Share.RowCause.Collector__c;
                    collShrs.add(cs);
                }

                if (MapCollShare.containsKey(coll.Id)) {
                    CollShareDelete.add(MapCollShare.get(coll.Id));
                }

            }
            // Se Sto aggiornando un Collector senza modificare il suo User non devo far nulla
        }

        if (collShrs.size() > 0) {

            Database.SaveResult[] lsr = Database.insert(collShrs, false);

            Integer i = 0;

            for (Database.SaveResult sr : lsr) {
                if (!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];

                    if (!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION && err.getMessage().contains('AccessLevel'))) {
                        ColMap.get(collShrs[i].ParentId).addError('Unable to grant sharing access due to following exception: ' + err.getMessage());
                    }
                }
                i++;
            }
        }

        if (CollShareDelete.size() > 0) {

            Database.DeleteResult[] lsrd = Database.delete(CollShareDelete, false);

            for (Database.DeleteResult sr : lsrd) {

                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        //System.debug('ShareCollector fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }

    public void afterDelete(List<SObject> so) {

    }
    public void andFinally() {

    }

    private void tasksForDaElaborare(List<SObject> oldSo, List<SObject> so) {

    }
}