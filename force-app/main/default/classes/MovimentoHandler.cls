/* ---------------------------------------------------------------------------------------------------------------------
Name:            MovimentoHandler.cls
Description:
Test class:      TestMovimentoHandler.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
16-Sep-2022  0.2      R.Kurti & C.Sanna    Added WITH SECURITY ENFORCED and replaced CheckFLSPermission with cebCheckFLSPermission (security review)
02-Mar-2023  0.3      C.Sanna              Modified BulkAfter. Is it possible to proceed enqueue CalcoloEstrattoConto Job,
                                           based on the value of CS Tag__g Record: SkipNessunEsitoEsitazioneMassiva.
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class MovimentoHandler implements ITrigger {
    // var per il implementazione del calcolo dei Saldi
    private static string meseSaldoAnno;
    public static Boolean isRunning = false;
    private static ID idRTSaldoMeseConsolidato;
    private static set<id> movJson;
    public class MovimentoHandlerException extends Exception {
    }
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public MovimentoHandler() {
    }
    public void bulkBefore() {
    }
    public void bulkBefore(List<SObject> soListNew) {
    }
    public void bulkBefore(List<SObject> soListOld, List<SObject> soListNew) {
    }

    /*
     * Author: Alessio Massidda
     * Purpose: seleziona tutte le pratiche coinvolte nella transazione e pianifica l'esecuzione della schedulable che ricalcola i campi dell'estratto conto
     * Date: 19/06/2020
    */
    public void bulkAfter() {
        if (TagHelper.getValueBoolean('MovHandler_EnqueueECJob') == false) {
            Set<Id> praticasToUpdate = new Set<Id>();
            Set<Id> relatedAccounts = new Set<Id>();

            List<Movimento__c> ogniMovimento = new List<Movimento__c>();
            if (Trigger.old != null) ogniMovimento.addAll((List<Movimento__c>) Trigger.old);
            if (Trigger.new != null) ogniMovimento.addAll((List<Movimento__c>) Trigger.new);

            for (Movimento__c m : ogniMovimento) {
                if (String.isNotBlank(m.Pratica__c)) praticasToUpdate.add(m.Pratica__c);
                if (String.isNotBlank(m.Account__c)) relatedAccounts.add(m.Account__c);
            }

            if (!CEBUtils.newOrkVersionEnabled()) {
                System.enqueueJob(new Queueable_CalcoloEstrattoContoPratica(praticasToUpdate, relatedAccounts));
            }
        }

    }
    /***/
    public void bulkAfter(List<SObject> soListOld, List<SObject> soListNew) {
    }
    public void bulkAfter(List<SObject> soListNew) {
    }

    public void beforeDelete(List<Movimento__c> mov) {
    }

    public void afterInsert(List<Movimento__c> mov) {
        List<Id> IdMov = new List<Id>();
        for (Movimento__c M : mov) {
            IdMov.add(M.Id);
        }
        /*if(!IdMov.isEmpty() && !System.isBatch() && !System.isFuture()&& !test.isRunningTest())
            GestisciLogiche(IdMov);
        else if(System.isBatch() || test.isRunningTest())*/
        GestisciLogiche(Mov);
    }

    public void afterUpdate(List<Movimento__c> oldmov, List<Movimento__c> mov) {
        List<Id> IdMov = new List<Id>();
        for (Movimento__c M : mov) {
            IdMov.add(M.Id);
        }
        /* if(!IdMov.isEmpty() && !System.isBatch() && !System.isFuture())
             GestisciLogiche(IdMov);
         else if(System.isBatch())*/

        GestisciLogiche(Mov);
    }

    public void afterDelete(List<Movimento__c> mov) {
    }
    public void andFinally() {
    }

    // metodi da implementare le logiche per manipolare il 
    // campo Calcolo_SALDO_ANNO__c
    public void beforeInsert(List<Movimento__c> mov) {
        // Recupera il custom setting SALDOANNO & l'id del recordType SALDOMESECONSOLIDATO
        setVarAusiliariMeseRcrdTypeId();
        // chiama come ultimo op la verifica per il setting di calcola_SALDO_ANNO
        verificaPerSettingCalcolaSaldoAnno((List<Movimento__c>) mov);
    }

    public void beforeUpdate(List<SObject> oldSo, List<Movimento__c> mov) {
        // Recupera il custom setting SALDOANNO & l'id del recordType SALDOMESECONSOLIDATO
        setVarAusiliariMeseRcrdTypeId();
        // chiama come ultimo op la verifica per il setting di calcola_SALDO_ANNO
        verificaPerSettingCalcolaSaldoAnno((List<Movimento__c>) mov);
    }

    @future
    public static void GestisciLogiche(List<Id> idMov) {
        String allfieldsMovimenti = CredManUtility.selectall('Movimento__c');
        allfieldsMovimenti = allfieldsMovimenti.replaceAll('lastreferenceddate, ', '');
        list<Movimento__c> mov = new list<Movimento__c>();
        /*if(Utils.cebCheckObjPermission('Movimento__c',gd).get('ACCESS')
                && Utils.checkFLSPermission('Movimento__c', 'Cartolarizzazione__c').get('ACCESS')
            && Utils.checkFLSPermission('Movimento__c', 'Causale_Non_Sollecitabile__c').get('ACCESS')
            && Utils.checkFLSPermission('Movimento__c', 'Data_Emissione__c').get('ACCESS')
            && Utils.checkFLSPermission('Movimento__c', 'Data_Incasso__c').get('ACCESS')
            && Utils.checkFLSPermission('Movimento__c', 'Data_Integrazione__c').get('ACCESS')
            && Utils.checkFLSPermission('Movimento__c', 'Data_Pagamento__c').get('ACCESS')
            && Utils.checkFLSPermission('Movimento__c', 'Data_Scadenza__c').get('ACCESS')
            && Utils.checkFLSPermission('Movimento__c', 'Importo__c').get('ACCESS')
            && Utils.checkFLSPermission('Movimento__c', 'Mese__c').get('ACCESS'))
        {*/
        if (Utils.cebCheckObjPermission('Movimento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Cartolarizzazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Causale_Non_Sollecitabile__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Emissione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Incasso__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Integrazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Pagamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Scadenza__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Importo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Mese__c', gd).get('ACCESS')) {
            mov = database.query(String.escapeSingleQuotes('SELECT ' + allfieldsMovimenti + ', Account__r.Id_Esterno__c, Servizio_Item__r.Servizio__r.Id, Servizio_Item__r.Servizio__c, RecordType.Name' +
                    ' FROM Movimento__c WHERE Id IN : idMov'));

            Map<Id, Movimento__c> movMod = new Map<Id, Movimento__c>();
            List<Movimento__C> lm = new List<Movimento__C>();
            lm.addall(incassiAffidamentoConnection(mov));
            Map<Id, Movimento__c> movModTEmp = new Map<Id, Movimento__c>(lm); //(incassiAffidamentoConnection(mov));
            if (movModTEmp != null && !movModTEmp.isempty()) movMod.putAll(movModTemp);
            creaJSON(mov, MovMod);
            if (Test.isRunningTest()) PopolaIdMesePrecedente(mov, MovMod);

            CredManUtility.DisableTrigger();
            if (MovMod.size() > 0 && Utils.cebCheckObjPermission('Movimento__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Buffer_Json__c', gd).get('UPDATE')) {
                update MovMod.values();
            }
        }
    }
    /*
    *@Aggiunto da: KMeta
    *@In data: 30/July/2014
    *#Description: E' usata usata nel caso batch, dove il future non è possibile
    */
    public static void GestisciLogiche(List<Movimento__c> mov) {
        Map<Id, Movimento__c> movMod = new Map<Id, Movimento__c>();
        List<Movimento__C> lm = new List<Movimento__C>();
        lm.addall(incassiAffidamentoConnection(mov));
        Map<Id, Movimento__c> movModTEmp = new Map<Id, Movimento__c>(lm); //(incassiAffidamentoConnection(mov));

        if (movModTEmp != null && !movModTEmp.isempty()) movMod.putAll(movModTemp);
        creaJSON(mov, MovMod);
        if (Test.isRunningTest()) PopolaIdMesePrecedente(mov, MovMod);
        CredManUtility.DisableTrigger();
        if (MovMod.size() > 0 && Utils.cebCheckObjPermission('Movimento__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Buffer_Json__c', gd).get('UPDATE')) {
            update MovMod.values();
        }
    }
    public static void creaJSON(list<Movimento__c> mov, Map<id, Movimento__c> MovMod) {
        /*Id SaldoMeseRTId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByName().get('SALDO MESE').getRecordTypeId();
        Id SaldoMeseConRTId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByName().get('SALDO MESE CONSOLIDATO').getRecordTypeId();
        Id SaldoMeseFruRTId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByName().get('SALDO MESE FRUITORE').getRecordTypeId();
        Id SaldoMeseFruConRTId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByName().get('SALDO MESE FRUITORE CONSOLIDATO').getRecordTypeId();
*/
        Id SaldoMeseRTId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByDeveloperName().get('SALDO_MESE').getRecordTypeId();
        Id SaldoMeseConRTId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByDeveloperName().get('SALDO_MESE_CONSOLIDATO').getRecordTypeId();
        Id SaldoMeseFruRTId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByDeveloperName().get('SALDO_MESE_FRUITORE').getRecordTypeId();
        Id SaldoMeseFruConRTId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByDeveloperName().get('SALDO_MESE_FRUITORE_CONSOLIDATO').getRecordTypeId();

        Map<Id, String> MapRTNamePerId = new Map<Id, String>();
        String obj2query = Utils.NAMESPACE + 'Movimento__c';
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = :obj2query WITH SECURITY_ENFORCED]) {
            MapRTNamePerId.put(rt.id, rt.name);
        }
        //DEBUG throw new  TriggerFactory.TriggerException('RDONATO:'+MapRTNamePerId);
        map<Integer, Map<String, String>> mss = new map<Integer, Map<String, String>>();
        //List<map<Integer,Map<String,String>>> lMyMap = new List<map<Integer,Map<String,String>>>();
        for (Movimento__c s : mov) {
            Movimento__c m = s.clone(false, true, false, false);
            m.id = s.id;
            List<map<Integer, Map<String, String>>> lMyMap = new List<map<Integer, Map<String, String>>>();
            //throw new  TriggerFactory.TriggerException('RDONATO:'+m.RecordTypeId+'WWWW:'+SaldoMeseRTId);
            if (m.RecordTypeId == SaldoMeseRTId || m.RecordTypeId == SaldoMeseConRTId || m.RecordTypeId == SaldoMeseFruRTId || m.RecordTypeId == SaldoMeseFruConRTId) {
                SetMyMap(m, lMyMap, mss, MapRTNamePerId);
                set<integer> SetOrdinato = new set<integer>();
                list<integer> IndiceOrdinato = new list<integer>();
                for (map<Integer, Map<String, String>> Maps : lMyMap) {
                    for (integer n : Maps.keyset())
                        SetOrdinato.add(n);
                }
                for (integer n : SetOrdinato) {
                    IndiceOrdinato.add(n);
                }
                IndiceOrdinato.sort();
                Map<String, String> MapInputSerialize = new Map<String, String>();
                List<Map<String, String>> setInputSerialize = new List<Map<String, String>>();
                for (integer i : IndiceOrdinato) {
                    for (map<Integer, Map<String, String>> Maps : lMyMap) {
                        MapInputSerialize = Maps.get(i);
                        setInputSerialize.add(MapInputSerialize);
                    }
                }
                m.Buffer_Json__c = Json.serializePretty(setInputSerialize);
                //popolo la mappa da passare al metodo richiamato in GestisciLogiche
                MovMod.put(m.Id, m);
                mss.clear();
            }
        }
    }

    public static void SetMyMap(Movimento__c m, List<map<Integer, Map<String, String>>> lMyMap, map<Integer, Map<String, String>> mss, Map<Id, String> MapRTNamePerId) {
        mss.clear();
        for (Integer i = 1; i < 32; i++) {
            if (String.ValueOf(m.get('Data_Saldo_' + i + '__c')) != null) {
                Map<String, String> MapCampoValore = new map<String, String>();
                MapCampoValore.put('Indice', String.ValueOf(i));
                String datasaldo = CredManUtility.DateToString(Date.valueOf(m.get('Data_Saldo_' + i + '__c')));

                MapCampoValore.put('Data Saldo', datasaldo);
                MapCampoValore.put('Importo Saldo', String.ValueOf(m.get('Importo_Saldo_' + i + '__c')));
                MapCampoValore.put('Saldo Spese', String.ValueOf(m.get('Saldo_Spese_' + i + '__c')));
                MapCampoValore.put('Scaduto Saldo', String.ValueOf(m.get('Scaduto_Saldo_' + i + '__c')));
                MapCampoValore.put('Tipo Movimento SWH', String.ValueOf(m.get('Tipo_Movimento_SWH_' + i + '__c')));
                MapCampoValore.put('Write Off', String.ValueOf(m.get('Write_Off_' + i + '__c')));
                String dataintegr = CredManUtility.DateToString(Date.valueOf(m.get('Data_Integrazione_' + i + '__c')));
                MapCampoValore.put('Data Integrazione', dataintegr);
                MapCampoValore.put('Id', String.ValueOf(m.get('Id')));
                String rType = String.ValueOf(MapRTNamePerId.get(m.RecordTypeId));
                rType = rType.replace(' MESE', '');
                MapCampoValore.put('Record Type', rType);
                MapCampoValore.put('Mese Precedente', String.ValueOf(m.get('Mese_Precedente__c')));
                mss.put(i, MapCampoValore);
            }
        }
        lMyMap.add(mss);
    }

    // verifica se questo movimento é adeguato per applicare il calcolo dei saldi
    // chamata dentro un beforeUpdate()/BeforeInsert()
    Private static void verificaPerSettingCalcolaSaldoAnno(List<Movimento__c> mList) {
        for (movimento__C m : mList) {
            if (m.recordtypeID == idRTSaldoMeseConsolidato && m.mese__c == meseSaldoAnno)
                if (m.SALDO_ANNO_LAVORATO__c == false)
                    m.Calcola_SALDO_ANNO__c = true;
        }

    }

    // imposta i var statici: meseSaldoAnno & idRTSaldoMeseConsolidato
    public static void setVarAusiliariMeseRcrdTypeId() {
        if (meseSaldoAnno == null)
            meseSaldoAnno = SALDIHelper.getValueMese('SALDOANNO');
        if (idRTSaldoMeseConsolidato == null)
            idRTSaldoMeseConsolidato = Schema.SObjectType.Movimento__c.getRecordTypeInfosByDeveloperName().get('SALDO_MESE_CONSOLIDATO').getRecordTypeId();
    }

    public static void PopolaIdMesePrecedente(List<Movimento__c> mov, Map<Id, Movimento__c> MovMod) {
        Set<Id> AccId = new Set<Id>();
        Set<Id> FAccId = new Set<Id>();

        /*VARIABILI SALDI*/
        map<Id, list<map<decimal, Id>>> MapIdMovimentoPerAnnoMesePerAcc_Saldi = new map <Id, list<map<decimal, Id>>>();
        list<map<decimal, Id>> ListMapIdMovPerAnnoPrec_Saldi = new list<map<decimal, Id>>();
        map<Id, Movimento__c> MapMovimentoPerId = new map<Id, Movimento__c>();

        /*VARIABILI SALDI FRUITORE*/
        map<Id, list<map<decimal, Id>>> MapIdMovimentoPerAnnoMesePerAcc_Fruitore = new map <Id, list<map<decimal, Id>>>();
        list<map<decimal, Id>> ListMapIdMovPerAnnoPrec_Fruitore = new list<map<decimal, Id>>();
        map<Id, Movimento__c> MapMovimentoPerId_Fruitore = new map<Id, Movimento__c>();

        /*Id SaldoMeseRTId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByName().get('SALDO MESE').getRecordTypeId();
        Id SaldoMeseConRTId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByName().get('SALDO MESE CONSOLIDATO').getRecordTypeId();
        Id SaldoMeseFruRTId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByName().get('SALDO MESE FRUITORE').getRecordTypeId();
        Id SaldoMeseFruConRTId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByName().get('SALDO MESE FRUITORE CONSOLIDATO').getRecordTypeId();
        */
        Id SaldoMeseRTId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByDeveloperName().get('SALDO_MESE').getRecordTypeId();
        Id SaldoMeseConRTId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByDeveloperName().get('SALDO_MESE_CONSOLIDATO').getRecordTypeId();
        Id SaldoMeseFruRTId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByDeveloperName().get('SALDO_MESE_FRUITORE').getRecordTypeId();
        Id SaldoMeseFruConRTId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByDeveloperName().get('SALDO_MESE_FRUITORE_CONSOLIDATO').getRecordTypeId();


        for (Movimento__c m : mov) {
            if ((m.RecordTypeId == SaldoMeseRTId && m.Mese_Precedente__c == null) || (m.RecordTypeId == SaldoMeseConRTId && m.Mese_Precedente__c == null)) {
                AccId.add(m.Account__c);
            }
            if ((m.RecordTypeId == SaldoMeseFruRTId && m.Mese_Precedente__c == null) || (m.RecordTypeId == SaldoMeseFruConRTId && m.Mese_Precedente__c == null)) {
                FAccId.add(m.Account__c);
            }
        }
        /*
        Gestione Saldo MESE
        */
        set<Movimento__c> SetMovimentoToUpdate = new set<Movimento__c>();
        map<Id, list<Movimento__c>> MapMovPerIdAcc_Saldi = new map<Id, list<Movimento__c>>();
        //if(Utils.checkFLSPermission('Movimento__c', 'Anno_Mese__c').get('ACCESS')
        //    && Utils.checkFLSPermission('Movimento__c', 'Mese_Precedente__c').get('ACCESS')){
        for (Movimento__c m : [
                SELECT Id, Anno_Mese__c, Account__c, Mese_Precedente__c
                FROM Movimento__c
                WHERE Account__c IN :AccId AND
                (RecordTypeId = :SaldoMeseRTId OR
                RecordTypeId = :SaldoMeseConRTId)
                WITH SECURITY_ENFORCED
        ]) {
            MapMovimentoPerId.put(m.Id, m);
            if (MapMovPerIdAcc_Saldi.get(m.Account__c) == null)
                MapMovPerIdAcc_Saldi.put(m.Account__c, new list<Movimento__c>());
            MapMovPerIdAcc_Saldi.get(m.Account__c).add(m);
            //}
        }
        for (Id IdAcc : MapMovPerIdAcc_Saldi.keyset()) {
            map<decimal, Id> MapIdMovPerAnnoPrec_Saldi = new map <decimal, Id>();
            for (Movimento__c M : MapMovPerIdAcc_Saldi.get(IdAcc)) {
                MapIdMovPerAnnoPrec_Saldi.put(M.Anno_Mese__c, M.Id);
                if (MapIdMovimentoPerAnnoMesePerAcc_Saldi.get(IdAcc) == null)
                    MapIdMovimentoPerAnnoMesePerAcc_Saldi.put(IdAcc, new list<map<decimal, Id>>());
                MapIdMovimentoPerAnnoMesePerAcc_Saldi.get(IdAcc).add(MapIdMovPerAnnoPrec_Saldi);
            }
        }
        for (Id IdAcc : MapIdMovimentoPerAnnoMesePerAcc_Saldi.keyset()) {
            list<map<decimal, Id>> ListMapB = MapIdMovimentoPerAnnoMesePerAcc_Saldi.get(IdAcc);
            for (map<decimal, Id> ListMapIdPerAnnoMese : ListMapB) {
                for (decimal AnnoMese : ListMapIdPerAnnoMese.keyset()) {
                    Id IdMov = ListMapIdPerAnnoMese.get(AnnoMese);
                    if (MapMovimentoPerId.get(IdMov) != null) {
                        Movimento__c MovToUpdate = MapMovimentoPerId.get(IdMov);
                        if (String.ValueOf(AnnoMese).right(2) == '01') {
                            if (ListMapIdPerAnnoMese.get(AnnoMese - 89) != null) {
                                MovToUpdate.Mese_Precedente__c = ListMapIdPerAnnoMese.get(AnnoMese - 89);
                            }
                        } else {
                            if (ListMapIdPerAnnoMese.get(AnnoMese - 1) != null) {
                                MovToUpdate.Mese_Precedente__c = ListMapIdPerAnnoMese.get(AnnoMese - 1);
                            }
                        }
                        SetMovimentoToUpdate.add(MovToUpdate);
                    }
                }
            }
        }

        /*Gestione Saldo MESE Fruitore*/
        map<Id, list<Movimento__c>> MapMovPerIdAcc_Fruitore = new map<Id, list<Movimento__c>>();
        //if(Utils.checkFLSPermission('Movimento__c', 'Anno_Mese__c').get('ACCESS')
        //    && Utils.checkFLSPermission('Movimento__c', 'Mese_Precedente__c').get('ACCESS')){
        for (Movimento__c m : [
                SELECT Id, Anno_Mese__c, Account__c, Mese_Precedente__c
                FROM Movimento__c
                WHERE Account__c IN :FAccId AND
                (RecordTypeId = :SaldoMeseFruRTId OR
                RecordTypeId = :SaldoMeseFruConRTId)
                WITH SECURITY_ENFORCED
        ]) {
            MapMovimentoPerId_Fruitore.put(m.Id, m);
            if (MapMovPerIdAcc_Fruitore.get(m.Account__c) == null)
                MapMovPerIdAcc_Fruitore.put(m.Account__c, new list<Movimento__c>());
            MapMovPerIdAcc_Fruitore.get(m.Account__c).add(m);
            //}
        }

        for (Id IdAcc : MapMovPerIdAcc_Fruitore.keyset()) {
            map<decimal, Id> MapIdMovPerAnnoPrec_Fruitore = new map <decimal, Id>();
            for (Movimento__c M : MapMovPerIdAcc_Fruitore.get(IdAcc)) {
                MapIdMovPerAnnoPrec_Fruitore.put(M.Anno_Mese__c, M.Id);
                if (MapIdMovimentoPerAnnoMesePerAcc_Fruitore.get(IdAcc) == null)
                    MapIdMovimentoPerAnnoMesePerAcc_Fruitore.put(IdAcc, new list<map<decimal, Id>>());
                MapIdMovimentoPerAnnoMesePerAcc_Fruitore.get(IdAcc).add(MapIdMovPerAnnoPrec_Fruitore);
            }
        }
        for (Id IdAcc : MapIdMovimentoPerAnnoMesePerAcc_Fruitore.keyset()) {
            list<map<decimal, Id>> ListMapB = MapIdMovimentoPerAnnoMesePerAcc_Fruitore.get(IdAcc);
            for (map<decimal, Id> ListMapIdPerAnnoMese_Fruitore : ListMapB) {
                for (decimal AnnoMese : ListMapIdPerAnnoMese_Fruitore.keyset()) {
                    Id IdMov = ListMapIdPerAnnoMese_Fruitore.get(AnnoMese);
                    if (MapMovimentoPerId_Fruitore.get(IdMov) != null) {
                        Movimento__c MovToUpdate_Fruitore = MapMovimentoPerId_Fruitore.get(IdMov);
                        if (String.ValueOf(AnnoMese).right(2) == '01') {
                            if (ListMapIdPerAnnoMese_Fruitore.get(AnnoMese - 89) != null) {
                                MovToUpdate_Fruitore.Mese_Precedente__c = ListMapIdPerAnnoMese_Fruitore.get(AnnoMese - 89);
                            }
                        } else {
                            if (ListMapIdPerAnnoMese_Fruitore.get(AnnoMese - 1) != null) {
                                MovToUpdate_Fruitore.Mese_Precedente__c = ListMapIdPerAnnoMese_Fruitore.get(AnnoMese - 1);
                            }
                        }
                        SetMovimentoToUpdate.add(MovToUpdate_Fruitore);
                    }
                }
            }
        }

        if (SetMovimentoToUpdate.size() > 0) {
            //Da testare Lunedì 07/07
            for (Movimento__c Movimento : SetMovimentoToUpdate) {
                if (MovMod.get(Movimento.Id) == null) {
                    MovMod.put(Movimento.Id, Movimento);
                } else {
                    Movimento__c Attuale = Movimento;
                    Movimento__c VecchioValore = MovMod.get(Movimento.Id);
                    VecchioValore.put('Mese_Precedente__c', Attuale.get('Mese_Precedente__c'));
                    MovMod.put(VecchioValore.Id, VecchioValore);
                }
            }
        }
    }

    //public static List<Movimento__C> incassiAffidamentoConnection(List<Movimento__C> lm){
    public static Set<Movimento__C> incassiAffidamentoConnection(List<Movimento__C> lm) {
        Map<id, Movimento__c> movMap = new Map<id, Movimento__c>(lm);
        //List<Movimento__C> lMod= new List<Movimento__C>();
        Set<Movimento__C> lMod = new Set<Movimento__C>();
        Map<id, List<id>> pratMov = new Map<id, List<id>>();
        set<id> idPraticas = new set<id>();
        Set<Affidamento__c> laff = new Set<Affidamento__c>();
        date dataMin = system.today();
        Set<Id> idMovSet = new Set<Id>();

        string dr = 'for_';
        for (Movimento__c l : lm) {
            //throw new TriggerFactory.TriggerException('Debug:'+l.RecordType__c.contains('NCASS'));
            if (l.recordTypeID == null || !l.RecordType__c.contains('NCASS')) continue;

            if (dataMin > l.data_scadenza__c) dataMin = l.Data_Scadenza__c;

            if (pratMov.get(l.pratica__c) == null)
                pratMov.put(l.pratica__c, new List<id>());
            pratMov.get(l.pratica__c).add(l.id);
            idPraticas.add(l.pratica__c);
        }

        /*if(Utils.cebCheckObjPermission('Affidamento__c',gd).get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_Affidamento__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Data_Termine_Proroga__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c').get('ACCESS'))
        {*/
        if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Termine_Proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('ACCESS')) {
            List<Affidamento__c> aList = [
                    Select id, name, pratica__c, Data_Affidamento__c, Data_Termine_Proroga__c, Data_chiusura_effettiva__c,
                            Data_fine_affidamento_prevista__c, Lotto__r.Agenzia_di_Recupero__r.Grace_Period_Inizio_Affido__c, Lotto__r.Agenzia_di_Recupero__r.Grace_Period_Fine_Affido__c
                    From Affidamento__c
                    where pratica__c in :idPraticas and stato__c <> 'Annullato' and Data_Affidamento__c <= :dataMin
                    WITH SECURITY_ENFORCED
                    ORDER BY Data_Affidamento__c ASC
            ];

            String lName = '';
            lName += '  before for 5:';
            for (affidamento__c a : aList) {
                lName += '    a:' + a.name;
                for (id idMov : pratMov.get(a.pratica__c)) {
                    Movimento__c movtemp = movMap.get(idMov);
                    Movimento__c mov = New movimento__c();
                    mov.id = movTemp.id;
                    lName += '   a.Data_Affidamento__c:' + a.Data_Affidamento__c;
                    lName += '   a.Data_chiusura_effettiva__c:' + a.Data_chiusura_effettiva__c;
                    lName += '   mov.data_scadenza__c:' + mov.data_scadenza__c;
                    Date startDateAffido = a.Data_Affidamento__c.addDays(Integer.valueOf(a.Lotto__r.Agenzia_di_Recupero__r.Grace_Period_Inizio_Affido__c));
                    //Date endDateAffido = a.Data_fine_affidamento_prevista__c.addDays(Integer.valueOf(a.Lotto__r.Agenzia_di_Recupero__r.Grace_Period_Fine_Affido__c));
                    Date endDateChiusura = (a.Data_chiusura_effettiva__c != null) ? a.Data_chiusura_effettiva__c.addDays(Integer.valueOf(a.Lotto__r.Agenzia_di_Recupero__r.Grace_Period_Fine_Affido__c)) : null;

                    //errorClass.LogError('MovimentoHandler::Date','startDateAffido : '+startDateAffido+'\n endDateAffido : '+endDateAffido+'\n endDateChiusura : '+endDateChiusura);
                    errorClass.LogError('MovimentoHandler::Date', 'ID Aff: ' + a.id + '\nID Mov: ' + idMov + '\nstartDateAffido : ' + startDateAffido + '\n endDateChiusura : ' + endDateChiusura);

                    if (startDateAffido <= movtemp.data_scadenza__c && !idMovSet.contains(mov.Id)) {
                        /*if(startDateAffido<=movtemp.data_scadenza__c && movtemp.data_scadenza__c<endDateAffido){
                            lName+='   if 1:';
                            mov.Affidamento__c=a.id;
                            a.Incassi_aggiornati__c=false;
                            laff.add(a);
                            lMod.add(mov);
                        }
                        else*/
                        if (a.Data_chiusura_effettiva__c != null && endDateChiusura != null) {
                            if (movtemp.data_scadenza__c <= endDateChiusura) {
                                lName += '   if 2:';
                                mov.Affidamento__c = a.id;
                                a.Incassi_aggiornati__c = false;
                                laff.add(a);
                                lMod.add(mov);
                                idMovSet.add(mov.Id);
                            }
                        } else if (a.Data_chiusura_effettiva__c == null) {
                            lName += '   if 3:';
                            mov.Affidamento__c = a.id;
                            a.Incassi_aggiornati__c = false;
                            laff.add(a);
                            lMod.add(mov);
                            idMovSet.add(mov.Id);
                        }
                    }
                    lName += '    out if 4:';
                }
                lName += '  out for 5:';
                //throw new MovimentoHandlerException('dataMin:'+dataMin+'   Error:'+lname);
            }
        }

        List<Affidamento__c> laffUPD = new List<Affidamento__c>();
        laffUPD.addAll(laff);
        if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Incassi_aggiornati__c', gd).get('UPDATE')) {
            update laffUPD;
        }
        return lMod;
    }
}