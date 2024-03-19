/* ---------------------------------------------------------------------------------------------------------------------
Name:            PraticaHandler.cls
Description:     This class manage Storico of Dossier, Closing/Unlocking Dossier and create first task (Included in Strategy)
Test class:

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
06/May/2014  0.1      K. Meta                         First Version
01-Oct-2021  0.2      C. Sanna, M. Pizzichini,        Modified Code_Status__c (Act. Ext Field) during Unlocking process
                      G.Mameli                        of a Dossier
16-Sep-2022  0.3      C.Sanna & R.Kurti               Added WITH SECURITY ENFORCED (security review)

----------------------------------------------------------------------------------------------------------------------*/

public with sharing class PraticaHandler implements ITrigger {
    public class PraticaHandlerException extends Exception {
    }
    // Constructor
    public static String checkExecution = '';
    List<SObject> taskToInsert = new List<SObject>();
    Map<Id, Account> accToUpdate = new Map<Id, Account>();
    Map<Id, Task> tasksToUpdate = new Map<Id, Task>();
    List<ActivityExtended__c> actExtsToUpdate = new List<ActivityExtended__c>();
    Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Task.getRecordTypeInfosByName();
    Map<String, Schema.RecordTypeInfo> stRT = Schema.SObjectType.Strategia__c.getRecordTypeInfosByName();
    Map<Id, Strategia__c> putinHistory;
    private static Map<String, List<Id>> serviceToPratica;
    private static Map<String, List<Id>> internServiceToPratica;
    static Set<Id> praticheInRicercaStrategia;
    public static Boolean areLogsActive;
    public static Integer Count_trigger_istances = 0;
    private static Set<Id> movimentiDaPorreOld;
    private static Boolean bolmdpo = false;
    public static Boolean isRunning = false;
    Set<String> listPratWithCebDSUNew = new Set<String>();
    List<String> listCebToUnlock = new List<String>();
    List<String> listCebToBlock = new List<String>();


    // E.S: Lavorazione PostChiusuraGestioneAscadere
    private static Set<Id> praticheGestioneAScadere;
    private static Map<Id, Pratica__c> praticheGestioneAScadereMap;
    private static Map<Id, Movimento__c> movAScadere;// da update

    private static Map<String, Id> mapJobId;
    private static List<Case> casesList = new List<Case>();
    public static Map<String, SObjectType> gd = Schema.getGlobalDescribe();

    public PraticaHandler() {
        if (areLogsActive == null) areLogsActive = TagHelper.getValueBoolean('PraticaHandlerLogl');
        if (serviceToPratica != null) return;
        serviceToPratica = new Map<String, List<Id>>();
        serviceToPratica.put('UscitaConChiusura', new List<Id>());
        serviceToPratica.put('UscitaSenzaChiusura', new List<Id>());
        serviceToPratica.put('UpdateStorico', new List<Id>());

        //Servizi interni che si autorichiede la pratica
        internServiceToPratica = new Map<String, List<Id>>();
        internServiceToPratica.put('DaBozzaInDaElaborare', new List<Id>());
        internServiceToPratica.put('DaDaLavorareInInLavorazione', new List<Id>());

    }


    public void bulkBefore() {
        Count_trigger_istances++;
        movimentiDaPorreOld = new Set<Id>();
    }

    public void bulkAfter() {
        Count_trigger_istances++;
    }

    public void bulkAfter(List<SObject> soListNew) {
        if (CEBUtils.newOrkVersionEnabled() && !Trigger.isDelete) {
            Map<Id, CRABB_DEV__Pratica__c> mapNewPrats = new Map<Id, CRABB_DEV__Pratica__c>((List<CRABB_DEV__Pratica__c>) soListNew);
            for (CRABB_DEV__CEB__c ceb : [
                    SELECT CRABB_DEV__Pratica__c, CRABB_DEV__Status__c
                    FROM CRABB_DEV__CEB__c
                    WHERE CRABB_DEV__Pratica__c IN :mapNewPrats.keySet() and CRABB_DEV__Status__c = 'New' and CRABB_DEV__Type__c = 'DSU'
                    WITH SECURITY_ENFORCED
            ]) {
                listPratWithCebDSUNew.add(ceb.CRABB_DEV__Pratica__c);
            }

            for (CRABB_DEV__CEB__c ceb : [
                    SELECT Id, CRABB_DEV__Pratica__c, CRABB_DEV__Status__c, CRABB_DEV__Type__c
                    FROM CRABB_DEV__CEB__c
                    WHERE CRABB_DEV__Status__c = 'New' AND CRABB_DEV__Pratica__c in :mapNewPrats.keySet() AND CRABB_DEV__Type__c NOT IN ('CEX', 'UEC', 'DSU')
                    WITH SECURITY_ENFORCED
            ]) {
                listCebToBlock.add(ceb.Id);
            }

            for (CRABB_DEV__CEB__c ceb : [
                    SELECT Id, CRABB_DEV__Pratica__c, CRABB_DEV__Status__c, CRABB_DEV__Type__c
                    FROM CRABB_DEV__CEB__c
                    WHERE CRABB_DEV__Status__c = 'Blocked' AND CRABB_DEV__Pratica__c in :mapNewPrats.keySet()
                    WITH SECURITY_ENFORCED
            ]) {
                listCebToUnlock.add(ceb.Id);
            }
        }
    }

    public void beforeInsert(List<SObject> soList) {
        /*Alessio Massidda e Giorgio Bonifazi: gennaio 2019*/
        Set<Id> lAcc = new Set<Id>();
        Map<Id, List<Case>> mAccCases = new Map<Id, List<Case>>();

        for (Pratica__c p : (List<Pratica__c>) soList) {
            if (String.isNotBlank(p.Account__c)) lAcc.add(p.Account__c);
            System.debug('lAcc --> ' + lAcc);
        }

        List<Case> lCase = new List<Case>();

        //verifica se esitono case bloccanti associati all'account cui si riferisce la pratica
        if (Utils.cebCheckObjPermission('Case', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Case', 'AccountId', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Case', 'Blocking_SR__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Case', 'status', gd).get('ACCESS')) {

            lCase = [
                    SELECT AccountId
                    FROM Case
                    WHERE Blocking_SR__c = TRUE AND Status != 'Closed' AND AccountId IN :lAcc
                    //WITH SECURITY_ENFORCED
            ];
        }


            for (Case c : lCase) {
                if (!mAccCases.containsKey(c.AccountId)) mAccCases.put(c.AccountId, new List<Case>());
                (mAccCases.get(c.AccountId)).add(c);
            }

            Set<Id> lAccNew = mAccCases.keySet();
            List<Pratica__c> lPratToFreeze = new List<Pratica__c>();

            //seleziona le pratiche da bloccare
            //if (Utils.cebCheckFLSPermission('Pratica__c', 'Account__c', gd).get('ACCESS')
            //        && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c', gd).get('ACCESS')) {

            lPratToFreeze = [SELECT Id FROM Pratica__c WHERE Account__c IN :lAccNew WITH SECURITY_ENFORCED];


            //blocca le pratiche selezionate
            for (Pratica__c p : lPratToFreeze) {
                p.Stato__c = 'Bloccata Manualmente';
                p.Motivo_Blocco__c = 'Esistono Ticket Bloccanti';
                p.Data_Blocco__c = System.today();
                p.Note_Blocco__c = 'Esistono Ticket Bloccanti';
                p.Nota_Sblocco__c = '';
            }
        /* */
    }

    public void beforeDelete(List<SObject> so) {
    }

    public void afterInsert(List<SObject> soList) {
    }

    public void bulkBefore(List<SObject> soListNew) {
    }

    public void beforeUpdate(List<SObject> soList, List<SObject> so) {
        //errorClass.LogError('PraticaHandler'+so);
        /* vengono definiti i servizi da eseguire sulla pratica
            set services definisce le operazioni necessarie
            poi vengono eseguite le operazioni
        */
        Map<Id, Pratica__c> pMap = new Map<Id, Pratica__c>();
        pMap = new Map<Id, Pratica__c>((List<Pratica__c>) so);

        setDataUltimoAggiornamentoSaldo((List<Pratica__c>) soList, (List<Pratica__c>) so);

        setServices(serviceToPratica, (List<Pratica__c>) so);
        if (serviceToPratica.get('UscitaConChiusura') != null)
            UscitaConChiusura(serviceToPratica.get('UscitaConChiusura'), pMap);
        if (serviceToPratica.get('UscitaSenzaChiusura') != null)
            UscitaSenzaChiusura(serviceToPratica.get('UscitaSenzaChiusura'), pMap);
        if (serviceToPratica.get('CreaStorico') != null)
            CreaStorico(serviceToPratica.get('CreaStorico'), pMap);

        /*lookForChangeStatoServices( soList, so);
            if(internServiceToPratica.get('DaBozzaInDaElaborare')!=null)
                daBozzaInDaElaborare(internServiceToPratica.get('DaBozzaInDaElaborare'),pMap);
            if(internServiceToPratica.get('DaDaLavorareInInLavorazione')!=null)
                daDaLavorareInInLavorazione(internServiceToPratica.get('DaDaLavorareInInLavorazione'),pMap); */
        if (!movimentiDaPorreOld.isEmpty() && !System.isBatch() && !System.isFuture()) {
            setToOldMovimentiForClosedPratica(movimentiDaPorreOld);
        }
    }
    public static void setDataUltimoAggiornamentoSaldo(List<pratica__c> oldList, List<pratica__c> newList) {
        Map<id, Pratica__c> oMap = new Map<id, pratica__c>(oldList);
        for (pratica__c p : newList) {
            if (p.Data_ultimo_aggiornamento_saldo__c == null) p.Data_ultimo_aggiornamento_saldo__c = system.now();
            else if (p.saldo_corrente__c != oMap.get(p.id).saldo_corrente__c) p.Data_ultimo_aggiornamento_saldo__c = system.now();
        }
    }

    @Future
    public static void setToOldMovimentiForClosedPratica(set<id> mdp) {
        try {
            if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'AnnoMese_Ultimo_Saldo__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Id_Movimento_Ext__c', gd).get('ACCESS')) {
                List<Pratica__c> pList = [
                        Select id, AnnoMese_Ultimo_Saldo__c
                        From Pratica__c
                        where id in :mdp
                        //WITH SECURITY_ENFORCED
                ];
                map<string, integer> pam = new map<string, integer >();
                List<Movimento__c> mov = [
                        Select id, Id_Movimento_Ext__c
                        From Movimento__c
                        where pratica__c in :mdp and Anno_Mese__c in :pam.values()
                        //WITH SECURITY_ENFORCED
                ];
                for (Movimento__c m : mov) {
                    if (pam.get(m.pratica__c) == m.Anno_Mese__c)
                        m.Id_Movimento_Ext__c += '_old';
                }
                if (Utils.cebCheckObjPermission('Movimento__c', gd).get('UPDATE')
                        && Utils.cebCheckFLSPermission('Movimento__c', 'Id_Movimento_Ext__c', gd).get('UPDATE')) {
                    update mov;
                }
            }
        } catch (exception e) {
            ErrorClass.logError('PraticaHandler.setToOldMovimentiForClosedPratica', 'Error: ' + utils.getExceptionInString(e));
        }
    }

    public void afterUpdate(List<SObject> oldSo, List<SObject> so) {

        //Close related Cases if the Dossier has been closed.
        Map<Id, Pratica__c> praticaMap = new Map<Id, Pratica__c>((List<Pratica__c>) oldSo);
        closeMappingCases(praticaMap, (List<Pratica__c>) so);

        if (!Utils.triggerAssertedFromHandler) {
            // Memorizza le id e il nuovo stato delle pratiche
            Map<id, String> IdPratNewStato = new Map<Id, String>();

            /*  In after update vengono eseguiti gli aggiornamenti sulle altre entità
            */
            taskperEntrataInstrategia(oldSo, so);
            accountToUpdate(oldSo, so);
            sbloccoPratica(oldSo, so);
            taskToInsert = Utils.sortTaskActivities(taskToInsert);
            if (taskToInsert.size() > 0 && Utils.cebCheckObjPermission('Task',gd).get('INSERT')) {
                insert taskToInsert;
            }

            if (accToUpdate.keySet().size() > 0) {
                try {
                    if (Utils.cebCheckObjPermission('Account', gd).get('CREATE')
                            && Utils.cebCheckFLSPermission('Account', 'Trigger_cause__c', gd).get('CREATE')) {
                        update accToUpdate.values();
                    }
                } catch (Exception e) {
                    //update accToUpdate.values(); evitiamo di rifare update s genera exception, su error class gestiamo errore
                    ErrorClass.logError('PraticaHandler.UpdateAccount.UpdateFailed', 'ids' + accToUpdate.keyset());
                }
            }

            if (tasksToUpdate.keySet().size() > 0) {
                try {
                    if (Utils.cebCheckObjPermission('Task', gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('Task', 'Status', gd).get('UPDATE')) {
                        update tasksToUpdate.values();
                    }
                } catch (Exception ex) {
                    ErrorClass.logError('PraticaHandler afterUpdate', +ex.getStackTraceString() + ' - Update of tasksToUpdate failed for Ids:' + tasksToUpdate.keySet());
                }
            }

            if (actExtsToUpdate.size() > 0) {
                try {
                    if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('ActivityExtended__c', 'code_status__c', gd).get('UPDATE')) {
                        update (actExtsToUpdate);
                    }
                } catch (Exception ex) {
                    ErrorClass.logError('PraticaHandler afterUpdate', 'Update of actExtsToUpdate failed - ' + ex.getStackTraceString());
                }
            }

            if (serviceToPratica.get('updateStorico') != null)
                updateStorico(serviceToPratica.get('updateStorico'), so);

            internServiceToPratica.clear();
            serviceToPratica.clear();

            /* MSala 20140723 INIZIO */
            /* aggiunto per calcolare il flag sollecitabile sui movimenti */
            /*Map<String,Integer> mPrat = new Map<String,Integer>();
            Map<String,SObject> mOld = new Map<String,SObject>();
            for(SObject pr : oldSo)
            {
                mOld.put(pr.Id, pr);
            }
            for(SObject s :so)
            {
                Pratica__c pNew = (Pratica__c)s;
                Pratica__c pOld = (Pratica__c)mOld.get(pNew.Id);
                if(pNew.AnnoMese_Ultimo_Saldo__c != pOld.AnnoMese_Ultimo_Saldo__c){
                   mPrat.put(pNew.Id,Integer.ValueOf(pNew.AnnoMese_Ultimo_Saldo__c));
                }
                // 26/03/2015
                // ES: Used the same for cicle, for efficiency
                if(pNew.stato__c != pOld.stato__c){
                    IdPratNewStato.put(pNew.id, pNew.stato__c);
                }
            }
            if(mPrat.size()>0 )
                UpdSollecitabile(mPrat);*/
            /* MSala 20140723 FINE */

            // ES: 26/03/2015, if the praticas, have changed their stato__c
            // send them to elaborate
            /*if(IdPratNewStato.keySet().size()>0){
                if(updateStatoPratAtMovs(IdPratNewStato)){
                    // Success
                    ErrorClass.logError('\n PraticaHandler, '+System.now(), '\n Cambio dello stato delle pratiche su i movimenti, finito con successo!!!');
                }else{
                    ErrorClass.logError('\n PraticaHandler, '+System.now(), '\n Cambio dello stato delle pratiche su i movimenti, FALLITO!');
                }
            }*/

            if (mapJobId == null) mapJobId = new Map<String, Id>();
            List<String> listIdPratica = new List<String>();
            List<String> listIdPraticaBlocked = new List<String>();
            Map<String, String> mapPratStato = new Map<String, String>();
            for (SObject s : so) {
                Pratica__c pNew = (Pratica__c) s;

                /*if (!System.isFuture() && !System.isBatch()) {
                    if(pNew.Stato__c != praticaMap.get(pNew.id).Stato__c) {
                        listIdPratica.add(pNew.Id);
                        mapPratStato.put(pNew.Id, pNew.Stato__c);
                    }

                    /*if(BatchStatoPratica.setIdPratica == null || !BatchStatoPratica.setIdPratica.contains(pNew.Id)){
                        Id jobId = Database.executeBatch(new BatchStatoPratica(pNew.Id,pNew.Stato__c));
                        mapJobId.put(pNew.Id,jobId);
                    }else if(BatchStatoPratica.setIdPratica != null && BatchStatoPratica.setIdPratica.contains(pNew.id) &&
                            !BatchStatoPratica.mapIdStato.get(pNew.Id).equalsIgnoreCase(pNew.Stato__c) ){

                        System.abortJob(mapJobId.get(pNew.Id));
                        Id jobId = Database.executeBatch(new BatchStatoPratica(pNew.Id,pNew.Stato__c,true));
                        mapJobId.put(pNew.Id,jobId);
                    //}

                }*/

                if (!System.isFuture()) {
                    if (!CEBUtils.newOrkVersionEnabled() && !System.isBatch()) {
                        if (pNew.Stato__c != praticaMap.get(pNew.Id).Stato__c) {
                            listIdPratica.add(pNew.Id);
                            mapPratStato.put(pNew.Id, pNew.Stato__c);
                        }
                    } else if (CEBUtils.newOrkVersionEnabled()) {
                        if (!listPratWithCebDSUNew.contains(String.valueOf(pNew.id)) && pNew.Stato__c != praticaMap.get(pNew.Id).Stato__c) {
                            listIdPratica.add(pNew.Id);
                            mapPratStato.put(pNew.Id, pNew.Stato__c);
                        }/*
                        if(!listPratWithCebDSUBlocked.contains(String.valueOf(pNew.id))) {
                            listIdPraticaBlocked.add(pNew.Id());
                        }*/
                    }
                    /*if(BatchStatoPratica.setIdPratica == null || !BatchStatoPratica.setIdPratica.contains(pNew.Id)){
                        Id jobId = Database.executeBatch(new BatchStatoPratica(pNew.Id,pNew.Stato__c));
                        mapJobId.put(pNew.Id,jobId);
                    }else if(BatchStatoPratica.setIdPratica != null && BatchStatoPratica.setIdPratica.contains(pNew.id) &&
                            !BatchStatoPratica.mapIdStato.get(pNew.Id).equalsIgnoreCase(pNew.Stato__c) ){

                        System.abortJob(mapJobId.get(pNew.Id));
                        Id jobId = Database.executeBatch(new BatchStatoPratica(pNew.Id,pNew.Stato__c,true));
                        mapJobId.put(pNew.Id,jobId);
                    }*/

                }

                if (CEBUtils.newOrkVersionEnabled()) {
                    if ((pNew.Stato__c == 'Bloccata' && praticaMap.get(pNew.id).Stato__c != 'Bloccata') || (pNew.Stato__c == 'Bloccata Manualmente' && praticaMap.get(pNew.id).stato__c != 'Bloccata Manualmente')) {
                        CEBUtils.updateCebEvents(listCebToBlock, 'Blocked');
                    } else if ((pNew.Stato__c != 'Bloccata' && praticaMap.get(pNew.id).Stato__c == 'Bloccata') || (pNew.Stato__c != 'Bloccata Manualmente' && praticaMap.get(pNew.id).stato__c == 'Bloccata Manualmente')) {
                        CEBUtils.updateCebEvents(listCebToUnlock, 'New');
                    }
                }
            }

            if (listIdPratica != null && !listIdPratica.isEmpty() && mapPratStato != null && !mapPratStato.isEmpty()) {

                if (!CEBUtils.newOrkVersionEnabled()) {
                    Database.executeBatch(new BatchStatoPratica(listIdPratica, mapPratStato));
                } else {
                    //if new version enabled, create an event
                    CEBUtils.addCebEvents(false, listIdPratica, 'DSU');
                }

            }

            // ES: Lavorazione delle pratiche con mov 'A Scadere'
            if (praticheGestioneAScadere != null && praticheGestioneAScadere.size() > 0)
                elaborazionePostChiusura();
        }
    }

    // ES: 26/03/2015
    // Desc: Metodo che modifica il stato della pratica su i movimenti, nel caso di un cambio.
    /*** 20210514 MSiotto - Code Review - Start Rimosso in quanto inutilizzato ***/
    /*private boolean updateStatoPratAtMovs(Map<id, String> IdPratNewStato) {
        try {
            List<Movimento__c> movToUpdate = new List<Movimento__c>();
            if (Utils.cebCheckFLSPermission('Movimento__c', 'Pratica__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Stato_Pratiica_Picklist__c', gd).get('ACCESS')) {
                Map<id, Movimento__c> mMap = new Map<id, Movimento__c>([Select id, Pratica__c, name, Stato_Pratiica_Picklist__c from Movimento__c Where Pratica__c in :IdPratNewStato.keySet() ORDER BY CreatedDate DESC LIMIT 9000]);

                for (id idMov : mMap.keySet()) {
                    Movimento__c m = mMap.get(idMov);
                    String targetStatus = IdPratNewStato.get(m.Pratica__c);
                    m.Stato_Pratiica_Picklist__c = targetStatus;
                    movToUpdate.add(m);
                }
            }
            if (movToUpdate.size() > 0) {
                if (Utils.cebCheckFLSPermission('Movimento__c', 'Stato_Pratiica_Picklist__c', gd).get('UPDATE')) update movToUpdate;
            }
            return true;
        } catch (Exception e) {
            ErrorClass.logError('\n PraticaHandler, updateStatoPratAtMovs() ', '\n Errore durante la lavorazione dei Mov, Dettagli: ' + Utils.getExceptionInString(e));
            return false;
        }
    }*/
    /*** 20210514 MSiotto - Code Review - End Rimosso in quanto inutilizzato ***/

    /* MSala 20140723 INIZIO */
    /* aggiunto per calcolare il flag sollecitabile sui movimenti */
    public void UpdSollecitabile(Map<String, Integer> mPrat) {
        if (Utils.cebCheckFLSPermission('Movimento__c', 'Anno_Mese__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Sollecitabile__c', gd).get('ACCESS')) {
        List<Movimento__c> lMov = [
                Select Id, Anno_Mese__c, Sollecitabile__c, Pratica__c
                FROM Movimento__c
                WHERE Pratica__c in :mPrat.keySet()
                AND RecordType.Name IN ('SALDO MESE', 'SALDO MESE CONSOLIDATO')
                //WITH SECURITY_ENFORCED
        ];

        List<Movimento__c> lMovUpd = new List<Movimento__c>();
        Integer i = 0;
        for (Movimento__c m : lMov) {
            if (m.Anno_Mese__c == mPrat.get(m.Pratica__c) && m.Sollecitabile__c == false) {
                m.Sollecitabile__c = true;
                lMovUpd.add(m);
            } else if (m.Anno_Mese__c != mPrat.get(m.Pratica__c) && m.Sollecitabile__c == true) {
                m.Sollecitabile__c = false;
                lMovUpd.add(m);
            }
            i++;

        }
            if (lMovUpd.size() > 0 && Utils.cebCheckObjPermission('Movimento__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Sollecitabile__c', gd).get('UPDATE')) {
                update lMovUpd;
            }
        }
    }
    /* MSala 20140723 FINE */

    public void afterDelete(List<SObject> so) {
    }
    public void andFinally() {

        if (casesList.size() > 0 && Utils.cebCheckObjPermission('Case', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Case', 'Status', gd).get('UPDATE')) {
            update casesList;
        }

    }

    /*  questo metodo distribuisce le pratiche sulle attività da compiere in base a quanto
        è stato popolato il campo Service__c
    */
    private void setServices(Map<string, List<id>> smap, LIST<Pratica__c> soList) {
        for (Pratica__c p : soList) {
            //p.debug__c+='\n beforeUpdate setServices: ' +p.service__c + '\n Count_trigger_istances'+Count_trigger_istances+ '\n'+Utils.getlimits();

            if (p.service__c == null) continue;
            for (string s : utils.sliptString(p.service__c, ',')) {
                if (smap.get(s) == null) {
                    smap.put(s, new List<id>());
                }
                smap.get(s).add(p.id);
            }
            p.service__c = null;
        }
    }
    /*** 20210514 MSiotto - Code Review - Start Rimosso in quanto inutilizzato ***/
    /*private void lookForChangeStatoServices(LIST<Pratica__c> oldList, LIST<Pratica__c> newList) {
        Map<id, Pratica__c> oldMap = new Map<id, pratica__c>(oldList);
        pratica__c pold = new pratica__c();
        for (Pratica__c p : newList) {
            //p.debug__c+='\n lookForChangeStatoServices: ';
            pold = oldMap.get(p.id);
            if (pold.Residuo_Totale__c <= 0 && p.Residuo_Totale__c > 0 && pold.stato__c == 'Bozza') {
                internServiceToPratica.get('DaBozzaInDaElaborare').add(p.id);
            } else if (p.Residuo_Totale__c > 0 && p.stato__c == 'Bozza') {
                internServiceToPratica.get('DaBozzaInDaElaborare').add(p.id);
            } else if (pold.strategia__c == null && p.strategia__c != null && pold.stato__c == 'Da Elaborare') {
                internServiceToPratica.get('DaDaLavorareInInLavorazione').add(p.id);
            }
        }
    }*/
    /*** 20210514 MSiotto - Code Review - End Rimosso in quanto inutilizzato ***/
    /*E' previsto che venga salvato uno storico della pratica nell'oggetto strategie.
      questo metodo, aggiorna il record di storico. Salva le informazioni sulla strategia
      Per attivare la chiamata di questo metodo, è necessario che l'operazione venga richiesta
      tramite il campo Service__c della pratica. Questo vale per tutti i metodi legati alla
      storicizzazione
    */
    private void updateStorico(List<id> ids, List<Pratica__c> so) {
        List<Strategia__c> sL = new List<Strategia__c>();
        Map<id, Pratica__c> pMap = new map<id, pratica__c>(so);
        for (id idP : ids) {
            pratica__c p = pMap.get(idp);
            if (p.Storico_in_Corso__c == null) continue; // Gestire lo scenario di dato errato e fare throw error
            strategia__c s = new strategia__c();
            s.id = p.Storico_in_corso__c;
            s.Nome__c = string.valueof(System.Now());
            s.Strategia_Name__c = p.Name;
            s.CDU_Json__c = p.CDU_Json__c;
            sL.add(s);
        }
        if (Utils.cebCheckObjPermission('Strategia__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Strategia_Name__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Strategia__c', 'CDU_Json__c', gd).get('UPDATE')) {
            update sL;
        }
    }

    /*** 20210514 MSiotto - Code Review - Start Rimosso in quanto inutilizzato ***/
    /*private void daDaLavorareInInLavorazione(List<id> ids, Map<id, Pratica__c> pMap) {
        pratica__c p = new pratica__c();
        for (id idp : ids) {
            p = pMap.get(idp);
            p.Stato__c = 'In lavorazione';
        }
        creaStorico(ids, pMap);
    }*/
    /*** 20210514 MSiotto - Code Review - End Rimosso in quanto inutilizzato ***/

    private void UscitaConChiusura(List<Id> ids, Map<Id, Pratica__c> pMap) {
        for (Id idP : ids) {
            movimentiDaPorreOld.add(idP);
            Pratica__c p = pMap.get(idP);
            p.Stato__c = 'Chiusa';
        }

        chiudiStorico(ids, pMap);

        // ES: Filtra le pratiche per passaggio mov A Scadere
        setPraticasGestAScadere(ids, pMap);
        System.debug('\n UscitaConchiusura(), PraticheFIltrate, lista ID: ' + praticheGestioneAScadere + '\n Mappa: ' + praticheGestioneAScadereMap);
    }

    private void UscitaSenzaChiusura(List<Id> ids, Map<Id, Pratica__c> pMap) {
        for (Id idP : ids) {
            movimentiDaPorreOld.add(idP);
            Pratica__c p = pMap.get(idP);

            if (p.Residuo_Totale__c > 0) {
                p.Stato__c = 'Da Elaborare';
                p.byPassRole__c = String.valueOf(System.now());
            } else {
                p.stato__c = 'Bozza';
            }
        }

        chiudiStorico(ids, pMap);
    }

    private void chiudiStorico(List<Id> ids, Map<Id, Pratica__c> pMap) {
        List<Strategia__c> sL = new List<Strategia__c>();
        for (Id idP : ids) {
            Pratica__c p = pMap.get(idP);
            if (p == null || (p != null && p.Storico_in_Corso__c == null)) {
                continue;
            }
            Strategia__c s = new Strategia__c();
            s.Id = p.Storico_in_corso__c;
            s.Nome__c = String.valueOf(System.now());
            s.Strategia_Name__c = p.Name;
            s.CDU_Json__c = p.CDU_json__c;
            p.CDU_json__c = null;
            p.CDI_Json__c = null;
            p.Storico_in_corso__c = null;
            p.ConDiIng__c = null;
            p.Strategia__c = null;
            sL.add(s);
        }

        if (Utils.cebCheckObjPermission('Strategia__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Strategia_Name__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Strategia__c', 'CDU_Json__c', gd).get('UPDATE')) {
            update sL;
        }
    }

    private void creaStorico(List<Id> ids, Map<Id, Pratica__c> pMap) {
        List<Strategia__c> sL = new List<Strategia__c>();
        for (Id idP : ids) {
            Pratica__c p = pMap.get(idP);
            Strategia__c s = new Strategia__c();
            s.CreatedDate__c = p.LastModifiedDate;
            s.Strategia_Name__c = p.Name;
            s.Pratica_di_riferimento__c = p.Id;
            s.Nome__c = String.valueOf(System.now());
            //s.recordTypeid=stRT.get('Storico').getRecordTypeID();

            s.RecordTypeId = Schema.SObjectType.CRABB_DEV__Strategia__c.getRecordTypeInfosByDeveloperName().get('Storico').getRecordTypeId();
            s.CDI_Json__c = p.CDI_Json__c;
            //p.Debug__c+='\n dentro a creaStorico storico';
            sL.add(s);
        }
        if (Utils.cebCheckObjPermission('Strategia__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Strategia_Name__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Strategia__c', 'CDI_Json__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Strategia__c', 'CreatedDate__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Strategia__c', 'recordTypeid', gd).get('CREATE')) {
            insert sL;
        }

        for (Strategia__c s : sL) {
            Pratica__c p = pMap.get(s.Pratica_di_riferimento__c);
            p.Storico_in_corso__c = s.Id;
        }
    }

    /* Al cambio di stato della pratica è necessario aggiornare gli account, in quanto è stato richiesto che
       sugli account deve essere presente il numero di pratiche in un certo stato ( vedi logiche presenti sul trigger
       dell'account). Questo aggiorna l'account per permettere il ricalcolo del informazione
    */
    private void accountToUpdate(List<SObject> oldSo, List<SObject> so) {
        map<string, Pratica__c> oldPratMap = new Map<string, Pratica__c>((List<Pratica__c>) oldSo);
        string stringDebug = '';
        for (pratica__c p : (List<Pratica__c>) so) {

            if (oldPratMap.get(p.id).stato__c != p.stato__c
                    || oldPratMap.get(p.id).Flag_Accodamento__c != p.Flag_Accodamento__c) {
                accToUpdate.put(p.account__c, (new account(id = p.account__c, trigger_cause__C = '*0*')));
            }
        }

    }

    /*Questo metodo crea i task per entrare instrategia. Questo metodo crea i task per entrare in strategia.
      esso fa questa operazione al passaggio di stato da Bozza => in Lavorazione
      altra operazione è legata rispetto a byPassRole__c che serve a fini di test
    */
    private void taskperEntrataInstrategia(List<SObject> oldSo, List<SObject> so) {
        map<string, Pratica__c> oldPratMap = new Map<string, Pratica__c>((List<Pratica__c>) oldSo);
        string statoDaElaborare = TagHelper.getValueText('StatoPraticaPerEntrataInStrategia');
        if (praticheInRicercaStrategia == null) praticheInRicercaStrategia = new Set<id>();

        for (pratica__c p : (List<Pratica__c>) so) {
            if (praticheInRicercaStrategia.contains(p.id)) continue;
            if ((oldPratMap.get(p.id).byPassRole__c != p.byPassRole__c)) {
                taskToInsert.addAll(OrkBL.NewTask(p));
                praticheInRicercaStrategia.add(p.id);
            }
        }
    }

    private void sbloccoPratica(List<SObject> oldSo, List<SObject> so) {
        Map<String, Pratica__c> oldPratMap = new Map<String, Pratica__c>((List<Pratica__c>) oldSo);
        Set<Id> pratIdsDaSbloccare = new Set<Id>();
        String statoPratBloccataManualmente = TagHelper.getValueText('ValoreStatoPraticaPerBloccoManuale');
        String statoPratBloccata = TagHelper.getValueText('StatoPraticaBloccoPDR');
        //String statoPratBloccataManualmente = 'Bloccata Manualmente';
        //String statoPratBloccata = 'Bloccata';


        for (Pratica__c p : (List<Pratica__c>) so) {
            System.Debug('oldPratMap.get(p.Id).Stato__c --> ' + oldPratMap.get(p.Id).Stato__c);
            System.Debug('p.Stato__c --> ' + p.Stato__c);
            //if (oldPratMap.get(p.Id).Stato__c == statoPratBloccataManualmente && p.Stato__c != statoPratBloccataManualmente)
            if ((oldPratMap.get(p.Id).Stato__c == statoPratBloccataManualmente || oldPratMap.get(p.Id).Stato__c == statoPratBloccata)
                    && (p.Stato__c != statoPratBloccataManualmente && p.Stato__c != statoPratBloccata)) {
                pratIdsDaSbloccare.add(p.Id);
            }
        }

        //for (Task t : [SELECT Id, Status, ActivityExtended__c FROM Task WHERE WhatId IN : pratIdsDaSbloccare AND Status =: statoPratBloccataManualmente]) {
        for (Task t : [
                SELECT Id, Status, ActivityExtended__c
                FROM Task
                WHERE WhatId IN :pratIdsDaSbloccare
                AND (Status = :statoPratBloccataManualmente OR Status = :statoPratBloccata)
                WITH SECURITY_ENFORCED
        ]) {
            System.Debug('task --> ' + t);
            t.Status = 'Non Iniziata';
            tasksToUpdate.put(t.Id, t);
            ActivityExtended__c ae = new ActivityExtended__c();
            ae.Id = t.ActivityExtended__c;
            ae.code_status__c = 'Non iniziata';
            actExtsToUpdate.add(ae);

        }

    }

    /*
    *   Created: ESino, 12/01/2015
    *   Desc: Lavora le pratiche chiuse con dei movimenti a scadere.
    *   creane uno nuovo ogni volta, che si chiude una tale pratica, altrimenti, non
    *   crearle.
    *   -Part I(beforeUpdate()):setPraticasGestAScadere()=> Filtra solo le pratiche con movimenti a scadere
    *   e popola praticheGestioneAScadere&praticheGestioneAScadereMap
    *   -Part II(afterUpdate()):elaborazionePostChiusura()=> Crea le nuove pratiche, cambia i genitori dei movimenti
    */

    // Filtra le pratiche con movimenti
    private void setPraticasGestAScadere(list<id> ids, Map<id, Pratica__c>pMap) {
        // *Prendi i movimenti a scadere
        praticheGestioneAScadere = new set<id>();
        praticheGestioneAScadereMap = new Map<id, Pratica__c>();
        // = new Map<id, Movimento__c>([Select id, pratica__c From Movimento__c where GG_di_Scaduto__c<=0 AND Residuo__c > 0 AND pratica__c in:ids]);
        movAScadere = new Map<id, Movimento__c>([
                Select id, pratica__c
                From Movimento__c
                where GG_di_Scaduto__c < 0 AND Residuo__c > 0 AND pratica__c in :ids
                WITH SECURITY_ENFORCED
        ]);

        if (movAScadere.size() == 0) {
            //ErrorClass.logError('PraticaHandler.elaborazionePostChiusura', '\nNon ci sono pratiche con movimenti A scadere!\n'+movAScadere);
            return;
        }
        for (Movimento__c m : movAScadere.values()) {
            praticheGestioneAScadere.add(m.Pratica__c);
        }
        // lasci nella mapa, solo le pratiche di interesse
        for (Pratica__c p : pMap.values()) {
            if (praticheGestioneAScadere.contains(p.id))
                praticheGestioneAScadereMap.put(p.id, p);
        }
        System.debug('setPraticasGestAScadere(ids, pMap)* \nsetIDPrat: ' + praticheGestioneAScadere + '\n MappaPrat: ' + praticheGestioneAScadereMap);
    }

    // Creazione delle pratiche nuove, Cambio del Padre dei movimenti
    private void elaborazionePostChiusura() {
        List<Pratica__c> freshPrat = new List<Pratica__c>();            // Le nuove prat da inserire in DB
        Map<id, set<id>> pratWithItsData = new Map<id, Set<id>>();    // mappa fra idPratica <=> id dei movimenti 'A scadere'

        // 2. per ogni pratica, memorizza i suoi  Movimenti
        for (id idPrat : praticheGestioneAScadere) {
            Pratica__c p = praticheGestioneAScadereMap.get(idPrat);
            Map<String, Set<id>> datiTmpMap = new Map<String, Set<id>>();

            Set<id> idMov = new Set<id>();
            for (Movimento__c m : movAScadere.values()) {
                if (m.pratica__c == p.id)idMov.add(m.id);
            }

            // associa i Movimenti 'A scadere' con la pratica
            pratWithItsData.put(p.id, idMov);
        }

        // 3. Per tutte le pratiche crea nuove pratiche, con i dati copiati
        for (id idPrat : praticheGestioneAScadere) {
            Pratica__c p = praticheGestioneAScadereMap.get(idPrat);

            Pratica__c tmpP = new Pratica__c();
            tmpP.account__c = p.account__c;
            tmpP.Servizio_Fornitura__c = p.Servizio_Fornitura__c;
            tmpP.Pratica_Padre__c = p.id;
            tmpP.stato__c = 'Bozza';
            freshPrat.add(tmpP);
        }

        // 4. Insert new Prats per ottenere i id & Update Mov after reparenting
        utils.triggerAssertedFromHandler = true;
        if (Utils.cebCheckObjPermission('Pratica__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Pratica__c', 'account__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Servizio_Fornitura__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Pratica_Padre__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Pratica__c', 'stato__c', gd).get('CREATE')) {
            insert freshPrat;
        }
        System.debug('\n praticheGestioneAScadere: ' + praticheGestioneAScadere + '\n freshPrat: ' + freshPrat);

        for (Pratica__c freshP : freshPrat) {
            for (id idMov : pratWithItsData.get(freshP.Pratica_Padre__c)) {
                Movimento__c m = movAScadere.get(idMov);
                m.pratica__c = freshP.id;
            }
        }
        if (movAScadere.size() > 0) update movAScadere.values();
        System.debug('\n Movimenti after Re-parenting: ' + movAScadere);

        // Svuotare le collection
        movAScadere.clear();
        praticheGestioneAScadere.clear();
        praticheGestioneAScadereMap.clear();
    }

    /* -----------------------------------------------------------------------------------------------------------------
    Author: Giulia Mameli
    Description: This method checks if the Dossier Status has changed from an opening Status to Closed to close related
                 open Cases.
    Inputs:  Map<Id, Pratica__c> oldPratMap, List<Pratica__c> newPratList
    Returns: NA

    30-Apr-2021  0.1      Giulia Mameli                         First Version
    ----------------------------------------------------------------------------------------------------------------- */

    public void closeMappingCases(Map<Id, Pratica__c> oldPratMap, List<Pratica__c> newPratList) {

        Set<Id> pratCase = new Set<Id>();

        try {
            for (Pratica__c prt : newPratList) {
                if (prt.Stato__c.toUpperCase() == 'CHIUSA' && oldPratMap.get(prt.Id).Stato__c.toUpperCase() != 'CHIUSA') {
                    pratCase.add(prt.Id);
                }
            }

            if (pratCase.size() > 0 && Utils.cebCheckObjPermission('Case', gd).get('ACCESS')) {
                casesList = [SELECT Id FROM Case WHERE Pratica__c IN :pratCase AND Status != 'Closed'];
                //WITH SECURITY_ENFORCED];
            }

            if (casesList.size() > 0) {
                for (Case cs : casesList) {
                    cs.Status = 'Closed';
                }
            }

        } catch (Exception ex) {
            System.debug('closeMappingCases Exception: ' + ex.getMessage());
            ErrorClass.logError('PraticaHandler - closeMappingCases - Dossiers in exception: ' + pratCase + ' Exception message: ' + ex.getMessage());
        }
    }

}