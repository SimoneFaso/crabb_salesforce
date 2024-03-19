/* ---------------------------------------------------------------------------------------------------------------------
Name:            BatchUpdateRiconciliazioniBulk.cls
Description:
Test class:      TestBatchUpdateRiconciliazioniBulk.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
24-May-2021  0.1      S. Salaris                      First Version

30-Sep-2021  0.2      Matteo Pizzichini               Modified Adding Ceb methods (FLS review)
----------------------------------------------------------------------------------------------------------------------*/

global with sharing class BatchUpdateRiconciliazioniBulk implements Database.Batchable<sObject>, Database.Stateful {

    public String autore;
    public String email;
    public List<String> pratStatusList = new List<String>();
    public String csvString;
    public static final Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();


    global BatchUpdateRiconciliazioniBulk(String autoreUpd, String emailSend, List<String> statusList){
        autore = autoreUpd;
        email = emailSend;
        pratStatusList = statusList;
        csvString = '';
    }

    //recupero di record di staging con stato 'Nuovo' e userId corrispondenti
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, CRABB_DEV__RiconciliazioneId__c, CRABB_DEV__PraticaId__c, CRABB_DEV__Value__c, CRABB_DEV__Stato__c, CRABB_DEV__Autore__c, CRABB_DEV__Nome_Autore__c FROM CRABB_DEV__Riconciliazione_Staging__c ';
        query += 'WHERE CRABB_DEV__Stato__c = \'Nuovo\' AND CRABB_DEV__Autore__c = :autore WITH SECURITY_ENFORCED order by CRABB_DEV__RiconciliazioneId__c asc, CreatedDate asc';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<CRABB_DEV__Riconciliazione_Staging__c> scope) {
        Set<String> ricIdSet = new Set<String>();
        Set<String> accIdSet = new Set<String>();
        List <Riconciliazione__c> ricWithEmptyDraft = new List<Riconciliazione__c>();
        List <Riconciliazione__c> ricToUpd = new List<Riconciliazione__c>();
        List<Riconciliazione_Staging__c> ricStagingToUpd = new List<Riconciliazione_Staging__c>();
        List<CRABB_DEV__Riconciliazione_Staging__c> ricStagingList;

        //recupero gli id validi delle riconciliazioni dallo scope della query
        Map<String,List<CRABB_DEV__Riconciliazione_Staging__c>> ricStagMap = new Map<String,List<CRABB_DEV__Riconciliazione_Staging__c>>();
        for(CRABB_DEV__Riconciliazione_Staging__c ricSt : scope) {
            if(ricSt.CRABB_DEV__RiconciliazioneId__c instanceOf Id) {
                ricIdSet.add(ricSt.CRABB_DEV__RiconciliazioneId__c);
            }
            if(ricStagMap.containsKey(ricSt.CRABB_DEV__RiconciliazioneId__c)) {
                ricStagingList = ricStagMap.get(ricSt.CRABB_DEV__RiconciliazioneId__c);
            } else {
                ricStagingList = new List<CRABB_DEV__Riconciliazione_Staging__c>();
            }
            ricStagingList.add(ricSt);
            ricStagMap.put(ricSt.CRABB_DEV__RiconciliazioneId__c, ricStagingList);
        }

        List<CRABB_DEV__Riconciliazione_Staging__c> ricStagListForAcc;
        String chiave;
        String draft;
        Riconciliazione__c ricon;
        Map<String, BozzaMovimento> draftMap;
        List<BozzaMovimento> MovimentoList_Stored;
        Map<String, List<CRABB_DEV__Riconciliazione_Staging__c>> mapAccWithRicStg = new Map<String, List<CRABB_DEV__Riconciliazione_Staging__c>>();
        Map<String, CRABB_DEV__Riconciliazione__c> riconMap = new Map<String, CRABB_DEV__Riconciliazione__c> ([SELECT Id, Name, CRABB_DEV__Bozza_movimento__c, CRABB_DEV__Account__c, CRABB_DEV__Tipologia_riconciliazione__c, CRABB_DEV__Pratica__c, CRABB_DEV__Importo__c, CRABB_DEV__stato_riconciliazione__c, CRABB_DEV__Confermata__c FROM CRABB_DEV__Riconciliazione__c WHERE Id in :ricIdSet AND CRABB_DEV__Confermata__c = false AND CRABB_DEV__stato_riconciliazione__c = 'In Lavorazione' AND ( CRABB_DEV__Tipologia_riconciliazione__c = 'Transazione con associazione parziale'  OR (CRABB_DEV__Tipologia_riconciliazione__c  = 'Transazione con nessuna associazione' AND CRABB_DEV__Account__c != null)) WITH SECURITY_ENFORCED]);
        Map<String, Map<String, BozzaMovimento>> mapRicWithDraftMap = new Map<String, Map<String, BozzaMovimento>>();

        for(String ricId : ricStagMap.keySet()) {
            if(riconMap.containsKey(ricId)) {
                ricon = riconMap.get(ricId);
                draft = ricon.CRABB_DEV__Bozza_movimento__c;
                if(mapRicWithDraftMap.containsKey(ricId)) {
                    draftMap = mapRicWithDraftMap.get(ricId);
                } else {
                    draftMap = new Map<String, BozzaMovimento>();
                }
                if(String.isNotBlank(draft)) {
                    MovimentoList_Stored = (List<BozzaMovimento>) JSON.deserialize(draft, List<BozzaMovimento>.class);

                    for (BozzaMovimento b : MovimentoList_Stored) {
                        //considero null tutti i value che sono stringa vuota, null o zero
                        if (string.isBlank(b.Value) || b.Value.equals('0')) {
                            b.Value = null;
                        }
                        draftMap.put(b.IdPratica, b);
                    }
                }
                mapRicWithDraftMap.put(ricId, draftMap);
                accIdSet.add(ricon.CRABB_DEV__Account__c);
                ricWithEmptyDraft.add(ricon);
                chiave = String.valueOf(ricon.Id) +'|'+ String.valueOf(ricon.CRABB_DEV__Account__c);
                if(!mapAccWithRicStg.containsKey(chiave)) {
                    ricStagListForAcc = new List<CRABB_DEV__Riconciliazione_Staging__c>();
                } else {
                    ricStagListForAcc = mapAccWithRicStg.get(chiave);
                }
                ricStagListForAcc.addAll(ricStagMap.get(ricId));
                mapAccWithRicStg.put(chiave, ricStagListForAcc);
            } else {
                for(CRABB_DEV__Riconciliazione_Staging__c rs: ricStagMap.get(ricId)) {
                    System.debug('@@@@@@@@@@ errore per riconciliazione non trovata');
                    rs.CRABB_DEV__Stato__c = 'Fallito';
                    csvString += rs.Id + ','+ rs.CRABB_DEV__Nome_Autore__c + ','+ rs.CRABB_DEV__RiconciliazioneId__c + ',' + rs.CRABB_DEV__PraticaId__c + ',' + rs.CRABB_DEV__Value__c + ',' + rs.CRABB_DEV__Stato__c + '\n';
                    ricStagingToUpd.add(rs);
                }
            }
        }

        List<CRABB_DEV__Pratica__c> pratList = [SELECT Id, Name, CRABB_DEV__Account__c, CRABB_DEV__Account__r.Name, Residuo_Totale__c, Strategia__c, Strategia__r.Tipo_Servizio__c, Data_Apertura__c, Esito_Ultima_Attivit_in_Lavorazione__c, CRABB_DEV__Stato__c from CRABB_DEV__Pratica__c where CRABB_DEV__Account__c in :accIdSet and CRABB_DEV__Stato__c in :pratStatusList WITH SECURITY_ENFORCED];
        List<CRABB_DEV__Pratica__c> pratListForAccount;
        Map<Id, List<CRABB_DEV__Pratica__c>> mapAccWithPrat = new Map<Id, List<CRABB_DEV__Pratica__c>>();
        accIdSet.clear();
        Map<String, CRABB_DEV__Pratica__c> pratWithAccMap = new Map<String, CRABB_DEV__Pratica__c>();
        for(CRABB_DEV__Pratica__c prat : pratList) {
            chiave = String.valueOf(prat.Id) +'|'+ String.valueOf(prat.CRABB_DEV__Account__c);
            pratWithAccMap.put(chiave, prat);
            accIdSet.add(prat.CRABB_DEV__Account__c);
            /*
            if(!mapAccWithPrat.containsKey(prat.Account__c)) {
                pratListForAccount = new List<CRABB_DEV__Pratica__c>();
            } else {
                pratListForAccount = mapAccWithPrat.get(prat.Account__c);
            }
            pratListForAccount.add(prat);
            mapAccWithPrat.put(prat.Account__c, pratListForAccount);*/
        }

        Boolean match;
        //list<BozzaMovimento> MovimentoList_Shown;
        CRABB_DEV__Pratica__c prat;
        BozzaMovimento b;
        for(Riconciliazione__c ric : ricWithEmptyDraft) {
            chiave = String.valueOf(ric.Id) + '|' + String.valueOf(ric.CRABB_DEV__Account__c);
            if (mapAccWithRicStg.containsKey(chiave)) {
                if (/*mapAccWithPrat.containsKey(ric.Account__c) && */accIdSet.contains(ric.CRABB_DEV__Account__c)) {
                    draftMap = mapRicWithDraftMap.get(ric.Id);
                    for (CRABB_DEV__Riconciliazione_Staging__c rs : mapAccWithRicStg.get(chiave)) {
                        match = false;
                        chiave = String.valueOf(rs.CRABB_DEV__PraticaId__c) + '|' + String.valueOf(ric.CRABB_DEV__Account__c);
                        if (pratWithAccMap.containsKey(chiave)) {
                            prat = pratWithAccMap.get(chiave);
                            if (prat.CRABB_DEV__Account__c.equals(ric.CRABB_DEV__Account__c)) {
                                if (draftMap.containsKey(prat.Id)) {
                                    b = draftMap.get(prat.Id);
                                } else {
                                    b = new BozzaMovimento();
                                    b.IdPratica = prat.id;
                                    b.Name = prat.Name;
                                    b.AccountName = prat.Account__r.Name;
                                    b.IdAccount = prat.Account__r.Id;
                                    b.Stato = prat.Stato__c;
                                    b.TipoServizio = prat.Strategia__r.Tipo_Servizio__c;
                                    b.DataApertura = String.valueOf(prat.Data_Apertura__c);
                                    b.EsitoUltimaAttivitaLavorazione = prat.Esito_Ultima_Attivit_in_Lavorazione__c;
                                    b.Scaduto = String.valueOf(prat.Residuo_Totale__c);
                                    b.totaleImportoRiconciliazione = String.valueOf(ric.CRABB_DEV__Importo__c);
                                    b.Value = rs.CRABB_DEV__Value__c;
                                    b.Esito = null;
                                }
                                b.value = String.isNotBlank(rs.CRABB_DEV__Value__c)? rs.CRABB_DEV__Value__c : b.value;
                                draftMap.put(b.IdPratica, b);
                                match = true;
                            }
                        }
                        if (match) {
                            rs.CRABB_DEV__Stato__c = 'Processato';
                        } else {
                            rs.CRABB_DEV__Stato__c = 'Fallito';
                            System.debug('@@@@@@@@@@ errore per pratica non trovata');
                            csvString += rs.Id + ',' + rs.CRABB_DEV__Nome_Autore__c + ',' + rs.CRABB_DEV__RiconciliazioneId__c + ',' + rs.CRABB_DEV__PraticaId__c + ',' + rs.CRABB_DEV__Value__c + ',' + rs.CRABB_DEV__Stato__c + '\n';
                        }
                        ricStagingToUpd.add(rs);
                    }
                    ric.CRABB_DEV__Bozza_movimento__c = JSON.serialize(draftMap.Values());

                    ricToUpd.add(ric);
                } else {
                    for (CRABB_DEV__Riconciliazione_Staging__c rs : mapAccWithRicStg.get(chiave)) {
                        System.debug('@@@@@@@@@@ errore per account non trovato');
                        rs.CRABB_DEV__Stato__c = 'Fallito';
                        csvString += rs.Id + ',' + rs.CRABB_DEV__Nome_Autore__c + ',' + rs.CRABB_DEV__RiconciliazioneId__c + ',' + rs.CRABB_DEV__PraticaId__c + ',' + rs.CRABB_DEV__Value__c + ',' + rs.CRABB_DEV__Stato__c + '\n';
                        ricStagingToUpd.add(rs);
                    }
                }
            }
        }


        System.debug('@@@@@@@@@@ la lista di riconciliazioni da aggiornare è lunga: ' + ricToUpd.size());
        System.debug('@@@@@@@@@@ la lista di staging da aggiornare è lunga: ' + ricStagingToUpd.size() + ' mentre lo scope è di: '+ scope.size());
        try {
            //Database.update(ricToUpd);
            if (Utils.cebCheckObjPermission('Riconciliazione__c', gd).get('UPDATE') && Utils.cebCheckFLSPermission('Riconciliazione__c', 'Bozza_movimento__c' , gd).get('UPDATE')) {
                 Database.update(ricToUpd);
            }

            //Database.update(ricStagingToUpd);
            if (Utils.cebCheckObjPermission('Riconciliazione_Staging__c', gd).get('UPDATE')) {
                Database.update(ricStagingToUpd);
            }

        } catch (Exception ex){
            System.debug('Exception in BatchUpdateRiconciliazioniBulk:execute() --> '+ex.getStackTraceString());
            ErrorClass.logError('BatchUpdateRiconciliazioniBulk:execute() --> '+ex.getMessage());
        }

    }

    global void finish(Database.BatchableContext BC){

        Messaging.SingleEmailMessage emailmex = new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {email};
        String subject ='Aggiornamento Riconciliazioni Completato';
        emailmex.setSubject(subject);
        emailmex.setToAddresses( toAddresses );
        emailmex.setPlainTextBody('Gentile utente,\n\nL\'aggiornamento delle Riconciliazioni è stato completato.\nNell\'eventualità in cui siano stati riscontrati errori, sarà allegato alla mail il file "Errori_UpdateRiconciliazioni.csv".\n\nGrazie e Buona giornata,\nTeam CRABB');

        if(String.isNotBlank(csvString)) {
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            csvString = 'staging Id,Nome Autore,Riconciliazione Id,Pratica Id,Value,Stato'+ '\n'+ csvString;
            blob csvBlob = Blob.valueOf(csvString);
            //System.debug('@@@@@@@@@@ csvString: '+csvString);
            string csvname= 'Errori_UpdateRiconciliazioni.csv';
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
            emailmex.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        }
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailmex});

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        System.debug('JobInfo: ' + job);
    }

    public class BozzaMovimento{
        public String IdPratica;
        public String IdAccount;
        public String AccountName;
        public String Stato;
        public String TipoServizio;
        public String DataApertura;
        public String EsitoUltimaAttivitaLavorazione;
        public String Scaduto;
        public String totaleImportoRiconciliazione;
        public String Name;
        public String Value;
        public String Esito;
    }
}