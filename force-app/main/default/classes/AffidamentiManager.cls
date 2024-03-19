/* ---------------------------------------------------------------------------------------------------------------------
Name:            AffidamentiManager.cls
Description:
Test Class:      TestAffidamentiManager.cls


Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
13-May-2021  0.2      M.Siotto & G.Mameli             Reviewed for using ceb methods
11-Jun-2021  0.3      M.Siotto                        Reviewed for using ceb methods
04-Apr-2022  0.4      C.Sanna                         Reviewed for using cebcheckObjPermission (Security Review)
07-Sep-2022  0.5      R.Kurti & C.Sanna               Reviewed for using cebCheckObjPermissions and WITH SECURITY ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class AffidamentiManager {
    public class AffidamentiManagerException extends Exception {
    }

    Public static Map<String, SObjectType> gd = Schema.getGlobalDescribe();

    @Future
    public static void createAffidamentiFuture(List<Id> idLotti, String tipoAffidamento) {
        creaAffidamenti(idLotti, tipoAffidamento);
    }

    /*Questo Metodo genera dei Lotti e gli affidamenti associati al Lotto.
    In questo contesto si tratta di prelotti e i dati che vengono scritti sono indicativi, e possono subire modifiche quando il lotto viene confermato */
    public static void creaAffidamenti(List<Id> idLotti, String tipoAffidamento) {
        try {
            List<Affidamento__c> lAff = new List<Affidamento__c>();
            //List<Lotto__c> lLotto = [Select Id, Pratiche_pre_lotto__c, Stato__c From Lotto__c where id in:idLotti];
            List<Lotto__c> lLotto = [Select Id, Pratiche_pre_lotto__c, Stato__c From Lotto__c where id in :idLotti WITH SECURITY_ENFORCED];
            Map<id, map<string, string>> idLottoPraticaTask = new Map<id, map<string, string>>();
            Map<id, Pratica__c> pMap = new Map<id, Pratica__c>();//Serve per recuperare i dati dalle pratiche
            Set<string> idPractiche = new Set<string>();

            for (lotto__c l : lLotto) {
                l.stato__c = 'In Lavorazione';
                map<string, string> tp = (map<string, string>) JSON.deserialize(l.Pratiche_pre_lotto__c, map<string, string>.class);
                idLottoPraticaTask.put(l.id, tp);
                idPractiche.addAll(tp.keyset());
            }
            pMap = new Map<id, Pratica__c>([Select id, Data_Ultimo_Saldo__c, Residuo_Totale__c from Pratica__c where id in :idPractiche WITH SECURITY_ENFORCED]);
            if (pMap == null || pMap.size() == 0)
                throw new AffidamentiManagerException('Nessuna pratica recuperata tra quelle presenti sul lotto. Verificare che non siano state cancellate');

            for (lotto__c l : lLotto) {
                map<string, string> tp = idLottoPraticaTask.get(l.id);
                for (string s : tp.keyset()) {
                    affidamento__c a = new affidamento__c();
                    a.Lotto__c = l.id;
                    a.id_Task_associato__c = tp.get(s);
                    a.pratica__c = s;
                    a.stato__c = 'In creazione';
                    a.Data_scaduto_iniziale__c = pMap.get(s).Data_Ultimo_Saldo__c;
                    a.Scaduto_iniziale__c = pMap.get(s).Residuo_Totale__c;
                    lAff.add(a);
                }
            }
            if (Utils.cebCheckObjPermission('Lotto__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'stato__c', gd).get('UPDATE')) {
                update lLotto;
            }
            /*if (Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'stato__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_scaduto_iniziale__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_iniziale__c', gd).get('UPDATE')) {

                update lLotto;
            }*/

            if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'stato__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'pratica__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Lotto__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_scaduto_iniziale__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_iniziale__c', gd).get('CREATE')) {

                insert lAff;
            }
            /*if (Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'stato__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_scaduto_iniziale__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_iniziale__c', gd).get('CREATE')) {

                insert lAff;
            }*/
            //}
            //List<Task> tList=new List<Task>();
            List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
            Set<Id> idTaskAssociati = new Set<Id>();
            for (Affidamento__c tmp : lAff) {
                idTaskAssociati.add((Id) tmp.id_Task_associato__c);
            }
            //List<Task> currentTasks = [SELECT Id,ActivityExtended__c FROM Task WHERE Id in:idTaskAssociati];
            List<Task> currentTasks = [SELECT Id, ActivityExtended__c FROM Task WHERE Id in :idTaskAssociati WITH SECURITY_ENFORCED];
            Map<Id, ActivityExtended__c> task2Obj = Utils.cebGetTaskWithActivityExtended(currentTasks, gd);
            Set<Id> dupids = new Set<Id>();
            for (affidamento__c a : lAff) {
                if (!task2Obj.containsKey(a.id_Task_associato__c)) continue;
                ActivityExtended__c ae = task2Obj.get(a.id_Task_associato__c);
                if (dupids.contains(ae.Id)) continue;
                ae.id_affidamento__c = a.id;
                ae.id_lotto_associato__c = a.lotto__c;
                aes.add(ae);
                dupids.add(ae.Id);
            }
            if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_affidamento__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_lotto_associato__c', gd).get('UPDATE')) {

                update aes;
            }

            /* if (Utils.checkFLSPermission('Task', 'id').get('UPDATE')
                 && Utils.checkFLSPermission('ActivityExtended__c', 'id_affidamento__c').get('UPDATE')
                 && Utils.checkFLSPermission('ActivityExtended__c', 'id_lotto_associato__c').get('UPDATE')
                 ) update tList;*/
        } catch (Exception e) {
            errorClass.LogError('AffidamentiManager.creaAffidamenti', 'Errore:' + utils.getExceptionInString(e) + '\n idLotti:' + idLotti);
            throw new AffidamentiManagerException('Errore di sistema. Contattare amministratore' + utils.getExceptionInString(e));
        }
    }
    public static void creaAffidamenti(Lotto__c lotto) {
        //List<Affidamento__c> lAff = new list<Affidamento__c>();
        //List<Task> tList=new List<Task>();
        map<string, string> tp = new map<string, string>();
        tp = (map<string, string>) JSON.deserialize(lotto.Pratiche_pre_lotto__c, map<string, string>.class);

        /*
        *
        * Silvio non vengono creati gli Affidi
        */
        System.debug('Controlliamo il contenuto del lotto ' + lotto);
        System.debug('Controlliamo il deserialize ' + tp);

        /*Alessio Massidda: issue #49*/
        Database.executeBatch(new BatchCreaAffidamento(tp, lotto), 100);
        /* */

        /*for(affidamento__c a:lAff){
            Task t=new task();
            ActivityExtended__c ae = new ActivityExtended__c();
            t.id=a.id_Task_associato__c;
            ae.id_affidamento__c=a.id;
            ae.id_lotto_associato__c=a.lotto__c;
            t.ActivityExtended__c = ae.Id;
            aes.add(ae);
            tList.add(t);
        }
        upsert aes;*/
        /* if (Utils.checkFLSPermission('ActivityExtended__c', 'id').get('UPDATE')
                 && Utils.checkFLSPermission('ActivityExtended__c', 'id_affidamento__c').get('UPDATE')
                 && Utils.checkFLSPermission('ActivityExtended__c', 'id_lotto_associato__c').get('UPDATE')
                 ) update tList;*/
    }

    public static void preparaPreLotti(List<Affidamento__c> lAff) {
        set<lotto__c> lottiSet = new set<lotto__c>();
        for (Affidamento__c a : lAff) {
            lotto__c l = new lotto__c();
            a.Scaduto_iniziale__c = a.Scaduto_attuale__c;
            a.Stato__c = 'Da confermare';
            l.id = a.Lotto__c;
            l.stato__c = 'Da confermare';
            lottiSet.add(l);
        }
        list<lotto__c> lottiList = new List<lotto__c>();
        lottiList.addAll(lottiset);
        if (Utils.cebCheckObjPermission('Lotto__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Pratiche_pre_lotto__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Lotto__c', 'stato__c', gd).get('UPDATE')) {

            update lottiList;
        }

        //if (Utils.cebCheckFLSPermission('Lotto__c', 'stato__c', gd).get('UPDATE')) update lottiList;
        if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('UPDATE') &&
                Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'stato__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_scaduto_iniziale__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_iniziale__c', gd).get('UPDATE')) {
            update lAff;
        }
    }

    /*Vengono generati i lotti a partire da una lista di id di Lotti.
        il istema recupera prima gli affidamenti poi i task e le pratiche, infine va a compilare i dati.
        La durata viene popolata dal task dopo la creazione
    */
    public static void confermaAffidamentiTask(list<id> idLotti) {
        //recupero gli affidamenti
        List<Affidamento__c> laff = [
                Select id, stato__c, Note_elior__c, Data_scaduto_iniziale__c, id_Task_associato__c, Scaduto_iniziale__c, Data_Affidamento__c,
                        Id_User_Assegnatario_Pratica__c, pratica__c
                From Affidamento__C
                where lotto__c in :idLotti and stato__c <> 'Annullato'
                WITH SECURITY_ENFORCED
        ];
        //Variabili di puntamento
        List<id> idTAsk = new list<id>();
        List<id> idPratiche = new list<id>();

        //Preparo le liste per recuperare i task e le pratiche da modificare
        for (affidamento__c a : laff) {
            idTAsk.add(a.id_Task_associato__c);
            idPratiche.add(a.pratica__c);
        }

        Map<id, Task> idT = new Map<id, Task>([
                Select id, status, ActivityExtended__r.id_attivita__c, ActivityExtended__r.id_affidamento__c, ActivityExtended__r.id_lotto_associato__c
                From Task
                where id in :idTAsk and status = 'Non Iniziata'
                WITH SECURITY_ENFORCED
        ]);
        Map<id, pratica__c> pMap = new Map<id, pratica__c>([
                Select id, white_list__c, stato__c, is_Blocco_PDR__c, Data_Ultimo_Saldo__c, Residuo_Totale__c
                From pratica__c
                where id in :idPratiche
                WITH SECURITY_ENFORCED
        ]);

        Task t = new Task();
        Pratica__c p = new Pratica__c();

        for (Affidamento__c a : lAff) {
            p = pMap.get(a.pratica__c);
            if (idT.get(a.id_Task_associato__c) == null) {
                a.Note_elior__c = 'Task non più affidabile al momento di conferma dell\'affidamento';
                a.stato__c = 'Annullato';
                continue;
            }
            t = idT.get(a.id_Task_associato__c);
            boolean isAffidabile = (p.white_list__c == false && (p.stato__c == 'In Lavorazione' || (p.stato__c == TagHelper.getValueText('StatoPraticaBloccoPDR'))));
            if (isAffidabile) {
                p.stato__c = 'Affidata';
                a.Data_Affidamento__c = system.Today();
                a.Data_scaduto_iniziale__c = pMap.get(a.pratica__c).Data_Ultimo_Saldo__c;
                a.Scaduto_iniziale__c = pMap.get(a.pratica__c).Residuo_Totale__c;
                a.stato__c = 'In corso';
                t.Status = 'Lavorata';
            } else {
                a.stato__c = 'Annullato';
                a.Note_elior__c = 'Pratica non affidabile.' + '_stato pratica:' + p.stato__c + '_white list:' + p.white_list__c + '_è in pdr:' + p.is_Blocco_PDR__c;
            }

        }
        if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('UPDATE') &&
                Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'stato__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_scaduto_iniziale__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_iniziale__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Note_elior__c', gd).get('UPDATE')) {

            update lAff;
        }
        if (Utils.cebCheckFLSPermission('Pratica__c', 'stato__c', gd).get('UPDATE')) {
            update pMap.values();
        }
        if (Utils.cebCheckFLSPermission('Task', 'Status', gd).get('UPDATE')) {
            update idT.Values();
        }
    }
    public static void eliminaPreLotto(id idLotto) {
        Savepoint sp = Database.setSavepoint();
        try {
            List<Task> tl = [Select id, ActivityExtended__r.id_lotto_associato__c, ActivityExtended__r.id_affidamento__c From Task where ActivityExtended__r.id_lotto_associato__c = :idLotto and status = 'Non Iniziata' WITH SECURITY_ENFORCED];
            List<Affidamento__c> la = [Select id From Affidamento__c where Lotto__c = :idLotto WITH SECURITY_ENFORCED];
            List<Lotto__c> ll = [Select id From Lotto__c where id = :idLotto WITH SECURITY_ENFORCED];
            if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('DELETE') && la != null && la.size() > 0) {
                delete la;
            }
            if (Utils.cebCheckObjPermission('Lotto__c', gd).get('DELETE') && ll != null && ll.size() > 0) {
                delete ll ;
            }
            if (tl == null || tl.size() == 0) {
                return;
            }
            List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
            Map<Id, ActivityExtended__c> task2Obj = Utils.cebGetTaskWithActivityExtended(tl, gd);
            for (task t : tl) {
                ActivityExtended__c ae = task2Obj.get(t.Id);
                ae.id_lotto_associato__c = null;
                ae.id_affidamento__c = null;
                aes.add(ae);
            }
            if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE') &&
                    Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_affidamento__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_lotto_associato__c', gd).get('UPDATE')) {
                update aes;
            }
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AffidamentiManagerException('AffidamentiManager.eliminaPreLotto:DatabaseRollback eseguida' + utils.getExceptionInString(e));
        }
    }
    public static void eliminaPreAffidamento(id IDAffidamento) {
        Savepoint sp = Database.setSavepoint();
        try {
            List<Task> tl = [Select id, ActivityExtended__r.id_lotto_associato__c, ActivityExtended__r.id_affidamento__c, ActivityExtended__c From Task where ActivityExtended__r.id_affidamento__c = :IDAffidamento and status = 'Non Iniziata' WITH SECURITY_ENFORCED];
            List<Affidamento__c> la = [Select id From Affidamento__c where id = :IDAffidamento WITH SECURITY_ENFORCED];
            if (Utils.cebCheckObjPermission('Affidamento__c',gd).get('DELETE') && la != null && la.size() > 0) {
                delete la;
            }
            if (tl == null || tl.size() == 0) {
                return;
            }
            List<Id> aeids = new List<Id>();
            for (task t : tl) {
                aeids.add(t.ActivityExtended__c);
            }
            List<ActivityExtended__c> ae2null = new List<ActivityExtended__c>();
            ae2null = [Select id_lotto_associato__c, id_affidamento__c, id from ActivityExtended__c WHERE Id in :aeids WITH SECURITY_ENFORCED];
            if (ae2null != null) for (ActivityExtended__c tmp : ae2null) {
                tmp.id_lotto_associato__c = null;
                tmp.id_affidamento__c = null;
            }
            /* update ae2null;
            if (Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_affidamento__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_lotto_associato__c', gd).get('UPDATE')
                    ) update tl;*/

            if (Utils.cebCheckObjPermission('Task', gd).get('UPDATE')
                    && Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_affidamento__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_lotto_associato__c', gd).get('UPDATE')) {

                update ae2null;
                update tl;
            }
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AffidamentiManagerException('AffidamentiManager.eliminaPreLotto:DatabaseRollback eseguida' + utils.getExceptionInString(e));
        }
    }

    @Future
    public static void generaAffidamentoFuture(Id idLotto) {
        try {
            String queryAff = ' Select ' + Utils.getSOBJECTFieldsForQuery('Affidamento__c') + ' From Affidamento__c Where Lotto__c =:idLotto and stato__c=\'Da confermare\' WITH SECURITY_ENFORCED';
            List<Affidamento__c> affList = Database.query(queryAff);
            ErrorClass.logError('AffidamentiManager.generaAffidamentoFuture', 'affList:' + affList);
            generaAffidamento(affList);
            Lotto__c l = new Lotto__c();
            l.Id = idLotto;
            l.Tipo__c = 'Lotto';
            l.Stato__c = 'Confermato';
            if (Utils.cebCheckObjPermission('Lotto__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'stato__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'Tipo__c', gd).get('UPDATE')) {
                update l;
            }
        } catch (Exception e) {
            ErrorClass.logError('AffidamentiManager.generaAffidamentoFuture', 'Errore in Futture context:' + utils.getExceptionInString(e));
        }
    }
    public static void generaAffidamento(List<Affidamento__c> affList) {
        Savepoint sp = Database.setSavepoint();
        try {
            Map<Id, Id> praticaAffidamento = new Map<Id, Id>();
            Map<Id, Id> taskAffidamento = new Map<Id, Id>();
            Map<Id, Affidamento__c> mAff = new Map<Id, Affidamento__c>(affList);
            List<Pratica__c> pList = new List<Pratica__c>();
            List<Task> tlist = new List<Task>();
            Pratica__c p = new Pratica__c();
            Task t = new Task();
            for (Affidamento__c a : affList) {
                praticaAffidamento.put(a.Pratica__c, a.Id);
                taskAffidamento.put(a.id_Task_associato__c, a.Id);
            }
            Map<id, Task> idT = new Map<id, Task>([
                    Select id, status, ActivityExtended__r.id_attivita__c, ActivityExtended__r.id_affidamento__c, ActivityExtended__r.id_lotto_associato__c
                    From Task
                    where id in :taskAffidamento.keyset() and status = 'Non Iniziata'
                    WITH SECURITY_ENFORCED
            ]);
            Map<id, pratica__c> pMap = new Map<id, pratica__c>([
                    Select id, white_list__c, stato__c, is_Blocco_PDR__c, Data_Ultimo_Saldo__c, Residuo_Totale__c
                    From pratica__c
                    where id in :praticaAffidamento.keyset()
                    WITH SECURITY_ENFORCED
            ]);

            String SPBPDR = TagHelper.getValueText('StatoPraticaBloccoPDR');
            for (Affidamento__c a : affList) {
                p = pMap.get(a.pratica__c);
                if (idT.get(a.id_Task_associato__c) == null) {
                    a.Note_elior__c = 'Task non più affidabile al momento di conferma dell\'affidamento';
                    a.stato__c = 'Annullato';
                    continue;
                }
                t = idT.get(a.id_Task_associato__c);
                //boolean isAffidabile=(p.white_list__c==false && (p.stato__c=='In Lavorazione' || (p.stato__c==TagHelper.getValueText('StatoPraticaBloccoPDR') )) );
                boolean isAffidabile = (p.white_list__c == false && (p.stato__c == 'In Lavorazione' || (p.stato__c == SPBPDR)));
                if (isAffidabile) {
                    p.stato__c = 'Affidata';
                    a.Data_Affidamento__c = system.Today();
                    a.Data_scaduto_iniziale__c = pMap.get(a.pratica__c).Data_Ultimo_Saldo__c;
                    a.Scaduto_iniziale__c = pMap.get(a.pratica__c).Residuo_Totale__c;
                    a.stato__c = 'In corso';
                    t.Status = 'Lavorata';
                } else {
                    a.stato__c = 'Annullato';
                    a.Note_elior__c = 'Pratica non affidabile.' + '_stato pratica:' + p.stato__c + '_white list:' + p.white_list__c + '_è in pdr:' + p.is_Blocco_PDR__c;
                }
            }
            if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('UPDATE') && Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'stato__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_scaduto_iniziale__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_iniziale__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Note_elior__c', gd).get('UPDATE')) {
                update affList;
            }
            if (Utils.cebCheckObjPermission('Pratica__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'stato__c', gd).get('UPDATE')) {
                update pMap.values();
            }
            if (Utils.cebCheckObjPermission('Task', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Task', 'Status', gd).get('UPDATE')) {
                update idT.values();
            }
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AffidamentiManagerException('AffidamentiManager.eliminaPreLotto:DatabaseRollback eseguida' + utils.getExceptionInString(e));
        }
    }

    public static void revocaSingoloAffidamento(id idAffidamento, string note) {
        Savepoint sp = Database.setSavepoint();
        try {
            List<sobject> soList = new List<sobject>();
            affidamento__c aff = [Select id, lotto__c, pratica__c, stato__c, note_elior__c, Scaduto_finale__c, Scaduto_iniziale__c, Esito_Lavorazione__c, id_Task_associato__c, Data_chiusura_effettiva__c, Data_scaduto_finale__c, ID_task_target_revoca__c, Totale_Incassato_sull_Affidamento__c from affidamento__c where id = :idAffidamento WITH SECURITY_ENFORCED];
            pratica__c pr = [Select id, stato__c, Data_Ultimo_Saldo__c, Residuo_Totale__c, Nome_Collector_Attivo__c, Ragione_Sociale_Collector__c from pratica__c where id = :aff.pratica__c WITH SECURITY_ENFORCED];
            List<task> tList = [Select id, status from task where ActivityExtended__r.id_affidamento__c = :idAffidamento and status = 'Non Iniziata' WITH SECURITY_ENFORCED];
            task t = new task();
            if (tList == null || tList.size() == 0) {
                throw new AffidamentiManagerException('Errore, nessuna o attività associata all\'affidamento selezionato. Contattare l\'amministratore');
            } else if (tList.size() > 1) {
                throw new AffidamentiManagerException('Errore, nessuna o attività di attesa associata all\'affidamento selezionato contattare l\'amministratore');
            } else t = tList[0];

            if (pr.stato__c == 'Affidata') {
                pr.stato__c = 'In Lavorazione';
                //MSala 20170126 - Aggiunto per sbiancare il Collector sulla pratica
                pr.Nome_Collector_Attivo__c = '';
                pr.Ragione_Sociale_Collector__c = '';
            }
            aff.stato__c = 'Revocato';
            aff.Esito_Lavorazione__c = 'Revoca operatore';
            aff.note_elior__c = note;
            aff.Data_chiusura_effettiva__c = system.today();
            aff.Data_scaduto_finale__c = pr.Data_Ultimo_Saldo__c;
            aff.Scaduto_finale__c = pr.residuo_totale__c;
            aff.Totale_Incassato_sull_Affidamento__c = aff.Scaduto_iniziale__c - aff.Scaduto_finale__c;
            soList.add(aff);
            soList.add(pr);
            if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('UPDATE')
                    && Utils.cebCheckObjPermission('Pratica__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'stato__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_scaduto_iniziale__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_iniziale__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Note_elior__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'stato__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Nome_Collector_Attivo__c', gd).get('UPDATE')) {
                update soList;
            }

            if (t != null) {
                t.status = 'Revocata';
                if (Utils.cebCheckObjPermission('Task', gd).get('UPDATE') &&
                        Utils.cebCheckFLSPermission('Task', 'Status', gd).get('UPDATE')) {
                    update t;
                }
            } else {
                throw new AffidamentiManagerException('Errore: per l\'affidamento con id:' + idAffidamento + 'non è stato trovato un task da revocare. Verificare la cuasa di questo errore');
            }
        } catch (Exception e) {
            Database.rollback(sp);
            errorClass.LogError('AffidamentiManager.revocaSingoloAffidamento', 'Errore: ' + utils.getExceptionInString(e));
            throw new AffidamentiManagerException('...' + e.getmessage());
        }
    }

    public static void revocaLotto(id idLotto, string causaRevocaLotto) {
        Savepoint sp = Database.setSavepoint();
        try {
            lotto__c lotto;
            List<id> praticaIds = new list<id>();
            List<id> affidamentoIds = new list<id>();
            List<affidamento__c> affList = [Select id, lotto__c, pratica__c, stato__c, Scaduto_finale__c, Scaduto_iniziale__c, Esito_Lavorazione__c, id_Task_associato__c, Data_chiusura_effettiva__c, Data_scaduto_finale__c, ID_task_target_revoca__c, Totale_Incassato_sull_Affidamento__c from affidamento__c where Lotto__c = :idLotto and Stato__c = 'In corso' WITH SECURITY_ENFORCED];
            for (affidamento__c a : affList) {
                if (lotto == null) {
                    lotto = new lotto__c();
                    lotto.id = a.lotto__C;
                    lotto.stato__c = 'Revocato';
                }
                praticaIds.add(a.pratica__c);
                affidamentoIds.add(a.id);
            }

            map<id, pratica__c> pMap = new map<id, pratica__c>([Select id, stato__c, Data_Ultimo_Saldo__c, Residuo_Totale__c from pratica__c where id = :praticaIds WITH SECURITY_ENFORCED]);
            map<id, task> tMap = new map<id, task>([Select id, status from task where ActivityExtended__r.id_affidamento__c = :affidamentoIds and status = 'Non Iniziata' WITH SECURITY_ENFORCED]);

            for (pratica__c p : pMap.values()) {
                if (p.stato__c == 'Affidata') {
                    p.stato__c = 'In Lavorazione';
                    //MSala 20170126 - Aggiunto per sbiancare il Collector sulla pratica
                    p.Nome_Collector_Attivo__c = '';
                    p.Ragione_Sociale_Collector__c = '';
                }
            }
            for (Affidamento__c aff : affList) {
                aff.stato__c = 'Revocato';
                aff.Esito_Lavorazione__c = 'Revoca operatore';
                aff.Data_chiusura_effettiva__c = system.today();
                aff.Note_elior__c = causaRevocaLotto;
                aff.Data_scaduto_finale__c = pMap.get(aff.pratica__c).Data_Ultimo_Saldo__c;
                aff.Scaduto_finale__c = pMap.get(aff.pratica__c).residuo_totale__c;
                aff.Totale_Incassato_sull_Affidamento__c = aff.Scaduto_iniziale__c - aff.Scaduto_finale__c;
            }

            for (task t : tmap.values()) {
                t.status = 'Revocata';
            }

            if (Utils.cebCheckObjPermission('Lotto__c', gd).get('UPDATE') &&
                    Utils.cebCheckFLSPermission('Lotto__c', 'stato__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'Tipo__c', gd).get('UPDATE')) {
                update lotto;
            }

            if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'stato__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_scaduto_iniziale__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_iniziale__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Note_elior__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_finale__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Esito_Lavorazione__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Totale_Incassato_sull_Affidamento__c', gd).get('UPDATE')) {
                update affList;
            }

            if (Utils.cebCheckObjPermission('Pratica__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'stato__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Nome_Collector_Attivo__c', gd).get('UPDATE')) {
                update pmap.values();
            }

            if (Utils.cebCheckObjPermission('Task', gd).get('UPDATE') &&
                    Utils.cebCheckFLSPermission('Task', 'Status', gd).get('UPDATE')) {
                update tmap.values();
            }
        } catch (Exception e) {
            Database.rollback(sp);
            errorClass.LogError('AffidamentiManager.revocaSingoloAffidamento', 'Errore: ' + utils.getExceptionInString(e));
            throw new AffidamentiManagerException('...' + utils.getExceptionInString(e));
        }
    }

    /*
     * E.S.
     * Modificato per fornire un feedback alla pagina VF.
     * Error Codes:
     * 0 => No error.
     * 1 => Liste null
     * 2 => Manca una lista
     * 3 => Le liste non presentano uguali elementi
     * 4 => Errore sconosciuto.
     */
    public static integer revocaListAffidamentiInt(List<id> idAffidamenti, string causaRevocaLotto) {
        Savepoint sp = Database.setSavepoint();
        try {
            List<id> praticaIds = new list<id>();
            List<affidamento__c> affList = [Select id, lotto__c, pratica__c, stato__c, Scaduto_finale__c, Scaduto_iniziale__c, Esito_Lavorazione__c, id_Task_associato__c, Data_chiusura_effettiva__c, Data_scaduto_finale__c, ID_task_target_revoca__c, Totale_Incassato_sull_Affidamento__c from affidamento__c where id = :idAffidamenti WITH SECURITY_ENFORCED];
            for (affidamento__c a : affList) {
                praticaIds.add(a.pratica__c);
            }
            map<id, pratica__c> pMap = new map<id, pratica__c>([Select id, stato__c, Data_Ultimo_Saldo__c, Residuo_Totale__c from pratica__c where id = :praticaIds WITH SECURITY_ENFORCED]);
            map<id, task> tMap = new map<id, task>([Select id, status from task where ActivityExtended__r.id_affidamento__c = :idAffidamenti and status = 'Non Iniziata' WITH SECURITY_ENFORCED]);

            if (tMap == null || affList == null || pMap == null) {
                //throw new AffidamentiManagerException('Errore, Le liste sono null. Contattare l\'amministratore');
                return 1;
            } else if (tMap.size() == 0 || affList.size() == 0 || pMap.size() == 0) {
                //throw new AffidamentiManagerException('Errore, Una o più liste non presentano elementi. Contattare l\'amministratore. Le liste sono, affidmanento, pratiche, task');
                return 2;
            } else if (pMap.size() != affList.size() || affList.size() != tMap.size()) {
                //throw new AffidamentiManagerException('Errore, Le liste non presentano un eguale numero di elementi. Contattare l\'amministratore. Il numero di Task e affidamenti non sono uguali, oppure il numero di pratiche e affidamenti non sono uguali.');
                return 3;
            }

            for (pratica__c p : pMap.values()) {
                if (p.stato__c == 'Affidata') {
                    p.stato__c = 'In Lavorazione';
                    //MSala 20170126 - Aggiunto per sbiancare il Collector sulla pratica
                    p.Nome_Collector_Attivo__c = '';
                    p.Ragione_Sociale_Collector__c = '';
                }
            }
            for (Affidamento__c aff : affList) {
                aff.stato__c = 'Revocato';
                aff.Esito_Lavorazione__c = 'Revoca operatore';
                aff.Data_chiusura_effettiva__c = system.today();
                aff.Note_elior__c = causaRevocaLotto;
                aff.Data_scaduto_finale__c = pMap.get(aff.pratica__c).Data_Ultimo_Saldo__c;
                aff.Scaduto_finale__c = pMap.get(aff.pratica__c).residuo_totale__c;
                aff.Totale_Incassato_sull_Affidamento__c = aff.Scaduto_iniziale__c - aff.Scaduto_finale__c;
            }

            for (task t : tmap.values()) {
                t.status = 'Revocata';
            }

            affidamentoOpsQueue opsQueue = new affidamentoOpsQueue(affList, pmap.values(), tmap.values());
            System.enqueueJob(opsQueue);
            /* if ( Utils.checkFLSPermission('Affidamento__c', 'id_Task_associato__c').get('UPDATE')
                 && Utils.checkFLSPermission('Affidamento__c', 'stato__c').get('UPDATE')
                 && Utils.checkFLSPermission('Affidamento__c', 'Data_scaduto_iniziale__c').get('UPDATE')
                 && Utils.checkFLSPermission('Affidamento__c', 'Scaduto_iniziale__c').get('UPDATE')
                 && Utils.checkFLSPermission('Affidamento__c', 'Data_Affidamento__c').get('UPDATE')
                 && Utils.checkFLSPermission('Affidamento__c', 'Note_elior__c').get('UPDATE')
                 && Utils.checkFLSPermission('Affidamento__c', 'Scaduto_finale__c').get('UPDATE')
                 && Utils.checkFLSPermission('Affidamento__c', 'Esito_Lavorazione__c').get('UPDATE')
                 && Utils.checkFLSPermission('Affidamento__c', 'Totale_Incassato_sull_Affidamento__c').get('UPDATE')
                 )
                 update affList;


             if (Utils.checkFLSPermission('Pratica__c', 'stato__c').get('UPDATE')
                 && Utils.checkFLSPermission('Pratica__c', 'Nome_Collector_Attivo__c').get('UPDATE')
                 )
                 update pmap.values();


             if (Utils.checkFLSPermission('Task', 'Status').get('UPDATE'))
                 update tmap.values();
                 */

            return 0;
        } catch (Exception e) {
            Database.rollback(sp);
            errorClass.LogError('AffidamentiManager.revocaSingoloAffidamento', 'Errore: ' + utils.getExceptionInString(e));
            //throw new AffidamentiManagerException('...'+e.getmessage());
            return 4;
        }
    }


    //20181122 - MSALA Aggiunta nuova funzione per gestire gli affidi scaduti
    //Il task viene chiuso con stato "Lavorata" per poter procedere con la strategia
    public static integer revocaListAffidamentiScaduti(List<id> idAffidamenti, string causaRevocaLotto) {
        Savepoint sp = Database.setSavepoint();
        try {
            List<id> praticaIds = new list<id>();
            List<affidamento__c> affList = [Select id, lotto__c, pratica__c, stato__c, Scaduto_finale__c, Scaduto_iniziale__c, Esito_Lavorazione__c, id_Task_associato__c, Data_chiusura_effettiva__c, Data_scaduto_finale__c, ID_task_target_revoca__c, Totale_Incassato_sull_Affidamento__c from affidamento__c where id = :idAffidamenti WITH SECURITY_ENFORCED];
            for (affidamento__c a : affList) {
                praticaIds.add(a.pratica__c);
            }

            map<id, pratica__c> pMap = new map<id, pratica__c>([Select id, stato__c, Data_Ultimo_Saldo__c, Residuo_Totale__c from pratica__c where id = :praticaIds WITH SECURITY_ENFORCED]);
            map<id, task> tMap = new map<id, task>([Select id, status from task where ActivityExtended__r.id_affidamento__c = :idAffidamenti and status = 'Non Iniziata' WITH SECURITY_ENFORCED]);

            if (tMap == null || affList == null || pMap == null) {
                //throw new AffidamentiManagerException('Errore, Le liste sono null. Contattare l\'amministratore');
                return 1;
            } else if (tMap.size() == 0 || affList.size() == 0 || pMap.size() == 0) {
                //throw new AffidamentiManagerException('Errore, Una o più liste non presentano elementi. Contattare l\'amministratore. Le liste sono, affidmanento, pratiche, task');
                return 2;
            } else if (pMap.size() != affList.size() || affList.size() != tMap.size()) {
                //throw new AffidamentiManagerException('Errore, Le liste non presentano un eguale numero di elementi. Contattare l\'amministratore. Il numero di Task e affidamenti non sono uguali, oppure il numero di pratiche e affidamenti non sono uguali.');
                return 3;
            }

            for (pratica__c p : pMap.values()) {
                if (p.stato__c == 'Affidata') {
                    p.stato__c = 'In Lavorazione';
                    //MSala 20170126 - Aggiunto per sbiancare il Collector sulla pratica
                    p.Nome_Collector_Attivo__c = '';
                    p.Ragione_Sociale_Collector__c = '';
                }
            }
            for (Affidamento__c aff : affList) {
                aff.stato__c = 'Revocato';
                if (causaRevocaLotto == 'Esitazione Collector')
                    aff.Esito_Lavorazione__c = 'Esitazione Collector';
                else
                        aff.Esito_Lavorazione__c = 'Revoca Per Scadenza Affido';
                //aff.Esito_Lavorazione__c='Revoca Per Scadenza Affido';
                aff.Data_chiusura_effettiva__c = system.today();
                aff.Note_elior__c = causaRevocaLotto;
                aff.Data_scaduto_finale__c = pMap.get(aff.pratica__c).Data_Ultimo_Saldo__c;
                aff.Scaduto_finale__c = pMap.get(aff.pratica__c).residuo_totale__c;
                aff.Totale_Incassato_sull_Affidamento__c = aff.Scaduto_iniziale__c - aff.Scaduto_finale__c;
            }

            for (task t : tmap.values()) {
                t.status = 'Lavorata'; //t.status='Revocata';
            }
            if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'stato__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_scaduto_iniziale__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_iniziale__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Note_elior__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_finale__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Esito_Lavorazione__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Totale_Incassato_sull_Affidamento__c', gd).get('UPDATE')) {
                update affList;
            }

            if (Utils.cebCheckObjPermission('Pratica__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'stato__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Nome_Collector_Attivo__c', gd).get('UPDATE')) {
                update pmap.values();
            }

            if (Utils.cebCheckObjPermission('Task', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Task', 'Status', gd).get('UPDATE')) {
                update tmap.values();
            }
            return 0;
        } catch (Exception e) {
            Database.rollback(sp);
            errorClass.LogError('AffidamentiManager.revocaListAffidamentiScaduti', 'Errore: ' + utils.getExceptionInString(e));
            //throw new AffidamentiManagerException('...'+e.getmessage());
            return 4;
        }
    }

    // E.S.
    public static void revocaListAffidamentiUscitaStrategia(Map<id, string> idEsitoForAffidamento) {
        Savepoint sp = Database.setSavepoint();
        try {
            List<id> praticaIds = new list<id>();
            //List<affidamento__c> affList = [Select id, lotto__c, pratica__c,stato__c,Scaduto_finale__c,Scaduto_iniziale__c,Esito_Lavorazione__c, id_Task_associato__c,Data_chiusura_effettiva__c,Data_scaduto_finale__c, ID_task_target_revoca__c,Totale_Incassato_sull_Affidamento__c from affidamento__c where id = :idEsitoForAffidamento.keyset()];
            List<affidamento__c> affList = [Select id, lotto__c, pratica__c, stato__c, Scaduto_finale__c, Scaduto_iniziale__c, Esito_Lavorazione__c, id_Task_associato__c, Data_chiusura_effettiva__c, Data_scaduto_finale__c, ID_task_target_revoca__c, Totale_Incassato_sull_Affidamento__c from affidamento__c where id = :idEsitoForAffidamento.keyset() WITH SECURITY_ENFORCED];
            for (affidamento__c a : affList) {
                praticaIds.add(a.pratica__c);
            }

/*                if (Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('pratica__c', 'stato__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('pratica__c', 'Data_Ultimo_Saldo__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('pratica__c', 'Residuo_Totale__c', gd).get('ACCESS')) {*/
            //map<id, pratica__c> pMap = new map<id, pratica__c>([Select id, stato__c,Data_Ultimo_Saldo__c,Residuo_Totale__c from pratica__c where id = :praticaIds]);
            map<id, pratica__c> pMap = new map<id, pratica__c>([Select id, stato__c, Data_Ultimo_Saldo__c, Residuo_Totale__c from pratica__c where id = :praticaIds WITH SECURITY_ENFORCED]);
            for (pratica__c p : pMap.values()) {
                if (p.stato__c == 'Affidata') {
                    p.stato__c = 'In Lavorazione';
                    //MSala 20170126 - Aggiunto per sbiancare il Collector sulla pratica
                    p.Nome_Collector_Attivo__c = '';
                    p.Ragione_Sociale_Collector__c = '';
                }
            }
            for (Affidamento__c aff : affList) {
                aff.stato__c = idEsitoForAffidamento.get(aff.id);
                aff.Esito_Lavorazione__c = 'Revoca scaduto sotto soglia';
                aff.Data_chiusura_effettiva__c = system.today();
                aff.Data_scaduto_finale__c = pMap.get(aff.pratica__c).Data_Ultimo_Saldo__c;
                aff.Scaduto_finale__c = pMap.get(aff.pratica__c).residuo_totale__c;
                aff.Totale_Incassato_sull_Affidamento__c = (aff.Scaduto_iniziale__c == null ? 0 : aff.Scaduto_iniziale__c) - (aff.Scaduto_finale__c == null ? 0 : aff.Scaduto_finale__c);
            }
            if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'stato__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_scaduto_iniziale__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_iniziale__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Note_elior__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_finale__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Esito_Lavorazione__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Totale_Incassato_sull_Affidamento__c', gd).get('UPDATE')) {

                update affList;
            }
        } catch (Exception e) {
            Database.rollback(sp);
            errorClass.LogError('AffidamentiManager.revocaListAffidamentiUscitaStrategia', 'Errore: ' + utils.getExceptionInString(e));
            throw new AffidamentiManagerException('...' + utils.getExceptionInString(e));
        }
    }

    //12-May-2021 Created for using ceb methods
    public static void cebRevocaListAffidamentiUscitaStrategia(Map<Id, String> idEsitoForAffidamento, Map<String, Schema.SObjectType> globalDesc) {
        Savepoint sp = Database.setSavepoint();
        try {
            List<id> praticaIds = new list<id>();
            //List<affidamento__c> affList = [Select id, lotto__c, pratica__c,stato__c,Scaduto_finale__c,Scaduto_iniziale__c,Esito_Lavorazione__c, id_Task_associato__c,Data_chiusura_effettiva__c,Data_scaduto_finale__c, ID_task_target_revoca__c,Totale_Incassato_sull_Affidamento__c from affidamento__c where id = :idEsitoForAffidamento.keyset()];
            List<affidamento__c> affList = [Select id, lotto__c, pratica__c, stato__c, Scaduto_finale__c, Scaduto_iniziale__c, Esito_Lavorazione__c, id_Task_associato__c, Data_chiusura_effettiva__c, Data_scaduto_finale__c, ID_task_target_revoca__c, Totale_Incassato_sull_Affidamento__c from affidamento__c where id = :idEsitoForAffidamento.keyset() WITH SECURITY_ENFORCED];

            for (affidamento__c a : affList) {
                praticaIds.add(a.pratica__c);
            }
            //map<id, pratica__c> pMap = new map<id, pratica__c>([Select id, stato__c,Data_Ultimo_Saldo__c,Residuo_Totale__c from pratica__c where id = :praticaIds]);
            map<id, pratica__c> pMap = new map<id, pratica__c>([Select id, stato__c, Data_Ultimo_Saldo__c, Residuo_Totale__c from pratica__c where id = :praticaIds WITH SECURITY_ENFORCED]);
            for (pratica__c p : pMap.values()) {
                if (p.stato__c == 'Affidata') {
                    p.stato__c = 'In Lavorazione';
                    //MSala 20170126 - Aggiunto per sbiancare il Collector sulla pratica
                    p.Nome_Collector_Attivo__c = '';
                    p.Ragione_Sociale_Collector__c = '';
                }
            }
            for (Affidamento__c aff : affList) {
                aff.stato__c = idEsitoForAffidamento.get(aff.id);
                aff.Esito_Lavorazione__c = 'Revoca scaduto sotto soglia';
                aff.Data_chiusura_effettiva__c = system.today();
                aff.Data_scaduto_finale__c = pMap.get(aff.pratica__c).Data_Ultimo_Saldo__c;
                aff.Scaduto_finale__c = pMap.get(aff.pratica__c).residuo_totale__c;
                aff.Totale_Incassato_sull_Affidamento__c = (aff.Scaduto_iniziale__c == null ? 0 : aff.Scaduto_iniziale__c) - (aff.Scaduto_finale__c == null ? 0 : aff.Scaduto_finale__c);
            }
            if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c', globalDesc).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'stato__c', globalDesc).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_scaduto_iniziale__c', globalDesc).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_iniziale__c', globalDesc).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', globalDesc).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Note_elior__c', globalDesc).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Scaduto_finale__c', globalDesc).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Esito_Lavorazione__c', globalDesc).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Totale_Incassato_sull_Affidamento__c', globalDesc).get('UPDATE')) {

                update affList;
            }
        } catch (Exception e) {
            Database.rollback(sp);
            errorClass.LogError('AffidamentiManager.revocaListAffidamentiUscitaStrategia', 'Errore: ' + utils.getExceptionInString(e));
            throw new AffidamentiManagerException('...' + utils.getExceptionInString(e));
        }
    }

}