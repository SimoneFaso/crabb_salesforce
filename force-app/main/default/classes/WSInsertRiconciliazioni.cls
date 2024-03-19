/* ---------------------------------------------------------------------------------------------------------------------
Name:            WSInsertRiconciliazioni.cls
Description:
Test class:      TestWSInsertRiconciliazioni.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
17-Nov-2020  0.1      M.Siotto             First Version
16-Sep-2022  0.2      C.Sanna & R.Kurti    Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/
@RestResource(urlMapping='/api/insert/riconciliazione/*')
global with sharing class WSInsertRiconciliazioni {

    @HttpPost
    global static String doPost(herokuRequest hRequest) {
        List<String> praticheNameList = hRequest.praticaNameList;
        List<String> accountNameList = hRequest.accountNameList;
        List<draft_Riconciliazioni> draftFileList = hRequest.draftRic;
        String recordType = Schema.SObjectType.Riconciliazione__c.getRecordTypeInfosByName().get('Bonifico').getRecordTypeId();

        List<Riconciliazione__c> draftRiconciliazioniList = new List<Riconciliazione__c>();
        List<Riconciliazione__c> newList = new List<Riconciliazione__c>();
        Map<String, Pratica__c> PraticheNameMap = new Map<String, Pratica__c>();
        Map<String, Pratica__c> PraticheIDMap = new Map<String, Pratica__c>();
        Map<String, Account> AccountNameMap = new Map<String, Account>();
        Map<String, Account> AccountIDMap = new Map<String, Account>();

        Map<String, String> mappingRiconciliazioniMap = new Map<String, String>();
        List<mapping_riconciliazioni__mdt> mappingRiconciliazioniList = [
                SELECT CRABB_DEV__draft_field__c, CRABB_DEV__riconciliazione_field__c,
                        CRABB_DEV__key_field__c, CRABB_DEV__type__c
                FROM CRABB_DEV__mapping_riconciliazioni__mdt
                WITH SECURITY_ENFORCED
        ];

        String accountFieldAPIName;
        String praticaFieldAPIName;
        for (mapping_riconciliazioni__mdt m : mappingRiconciliazioniList) {
            if (m.CRABB_DEV__draft_field__c == 'accountName') {
                accountFieldAPIName = m.CRABB_DEV__key_field__c;
            }
            if (m.CRABB_DEV__draft_field__c == 'praticaName') {
                praticaFieldAPIName = m.CRABB_DEV__key_field__c;
            }
            mappingRiconciliazioniMap.put(m.CRABB_DEV__riconciliazione_field__c, m.CRABB_DEV__type__c + '|' + m.CRABB_DEV__draft_field__c);
        }

        //List<CRABB_DEV__Pratica__c> queryPraticaNameList = [select Name,id,CRABB_DEV__Residuo_Totale__c from CRABB_DEV__Pratica__c where Name in :praticheNameList WITH SECURITY_ENFORCED];
        //List<Account> queryAccountNameList = [select Name,id,CRABB_DEV__Saldo_Totale__c from Account where Name in :accountNameList WITH SECURITY_ENFORCED];
        String queryPR = 'select id,CRABB_DEV__Residuo_Totale__c, ' + String.escapeSingleQuotes(praticaFieldAPIName) + ' from CRABB_DEV__Pratica__c ';
        queryPR += 'where ' + String.escapeSingleQuotes(praticaFieldAPIName) + ' in :praticheNameList WITH SECURITY_ENFORCED';
        List<Pratica__c> queryPraticaNameList = Database.query(queryPR);

        String queryACC = 'select id,CRABB_DEV__Saldo_Movimenti_Scaduti__c,  ' + String.escapeSingleQuotes(accountFieldAPIName) + ' from Account ';
        queryACC += 'where ' + String.escapeSingleQuotes(accountFieldAPIName) + ' in :accountNameList WITH SECURITY_ENFORCED';
        List<Account> queryAccountNameList = Database.query(queryACC);

        for (CRABB_DEV__Pratica__c pr : queryPraticaNameList) {
            PraticheNameMap.put((String) pr.get(praticaFieldAPIName), pr);
        }
        for (CRABB_DEV__Pratica__c pr : queryPraticaNameList) {
            PraticheIDMap.put(pr.id, pr);
        }

        for (Account acc : queryAccountNameList) {
            AccountNameMap.put((String) acc.get(accountFieldAPIName), acc);
        }//
        for (Account acc : queryAccountNameList) {
            AccountIDMap.put(acc.id, acc);
        }

        try {
            for (draft_Riconciliazioni draftRic : draftFileList) {
                Riconciliazione__c newRic = new Riconciliazione__c();

                Map<String, Object> extIdMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(draftRic));
                for (String key : mappingRiconciliazioniMap.keySet()) {
                    String riconciliazioneFieldName = key;
                    List<String> listValue = (mappingRiconciliazioniMap.get(key)).split('\\|');
                    String riconciliazioneType = listValue[0];
                    String draftFieldName = listValue[1];

                    if (riconciliazioneType == 'String') {
                        String fieldName = String.valueOf(extIdMap.get(draftFieldName));
                        if (draftFieldName == 'praticaName') {
                            if (PraticheNameMap.containsKey(fieldName)) {
                                newRic.put(riconciliazioneFieldName, PraticheNameMap.get(fieldName).Id);
                            } else {
                                newRic.put(riconciliazioneFieldName, null);
                            }
                        } else if (draftFieldName == 'accountName') {
                            if (AccountNameMap.containsKey(fieldName)) {
                                newRic.put(riconciliazioneFieldName, AccountNameMap.get(fieldName).Id);
                            } else {
                                newRic.put(riconciliazioneFieldName, null);
                            }
                        } else {
                            newRic.put(riconciliazioneFieldName, extIdMap.get(draftFieldName));
                        }
                    } else if (riconciliazioneType == 'Decimal') {
                        newRic.put(riconciliazioneFieldName, (Decimal) extIdMap.get(draftFieldName));
                    } else if (riconciliazioneType == 'Date') {
                        String dateValue = String.valueOf(extIdMap.get(draftFieldName));
                        newRic.put(riconciliazioneFieldName, Date.valueOf(dateValue));
                    } else if (riconciliazioneType == 'Integer') {
                        newRic.put(riconciliazioneFieldName, (Integer) extIdMap.get(draftFieldName));
                    }
                }
                newRic.RecordTypeId = recordType;
                draftRiconciliazioniList.add(newRic);
            }

            newList = generaTipologie(draftRiconciliazioniList, AccountIDMap, PraticheIDMap);

            System.debug('#################### LA LISTA DI INSERT E GRANDE: ' + newList.size());
            insert newList;
            sendMail(newList.size());
            return '###################### OK ANDATO BENE ######################';

        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public static void sendMail(Integer sizeRiconc) {
        List<CRABB_DEV__mailingListRiconciliazioni__mdt> mailList = [
                SELECT emailAddress__c, Label
                FROM CRABB_DEV__mailingListRiconciliazioni__mdt
                where Label = 'emails_destinatario_octo'
                WITH SECURITY_ENFORCED
                LIMIT 1
        ];
        String email = mailList[0].emailAddress__c;
        List<String> toAddresses = email.split(',');
        Messaging.SingleEmailMessage mailObj = new Messaging.SingleEmailMessage();
        String subject = 'Caricamento Riconciliazioni Completato';
        mailObj.setSubject(subject);
        mailObj.setToAddresses(toAddresses);
        mailObj.setPlainTextBody('Gentile utente,\n\nIl caricamento delle Riconciliazioni è stato completato.\nSono stati inseriti correttamente ' + sizeRiconc + ' record.' + '\n\n\nGrazie e Buona giornata,\nTeam CRABB');
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mailObj
        });
    }

    private static List<Riconciliazione__c> generaTipologie(List<Riconciliazione__c> ricList, Map<String, Account> AccountIDMap, Map<String, Pratica__c> PraticheIDMap) {
        List<Riconciliazione__c> newList = new List<Riconciliazione__c>();
        for (Riconciliazione__c ric : ricList) {
            if (ric.CRABB_DEV__Pratica__c == null && ric.CRABB_DEV__Account__c == null) {
                ric.CRABB_DEV__Tipologia_riconciliazione__c = 'Transazione con nessuna associazione';
            }

            if (ric.CRABB_DEV__Pratica__c != null) {
                if (PraticheIDMap.get(ric.CRABB_DEV__Pratica__c).Residuo_Totale__c == ric.CRABB_DEV__importo__c) {
                    ric.CRABB_DEV__Tipologia_riconciliazione__c = 'Transazione con associazione esatta';
                    ric.CRABB_DEV__Confermata__c = true;
                    ric.CRABB_DEV__stato_riconciliazione__c = 'Approvata';
                } else {
                    ric.CRABB_DEV__Tipologia_riconciliazione__c = 'Transazione con associazione parziale';
                }
            }

            if (ric.CRABB_DEV__Account__c != null && ric.CRABB_DEV__Pratica__c == null) {
                if (AccountIDMap.get(ric.CRABB_DEV__Account__c).CRABB_DEV__Saldo_Movimenti_Scaduti__c == ric.CRABB_DEV__importo__c) {
                    ric.CRABB_DEV__Tipologia_riconciliazione__c = 'Transazione con associazione esatta';
                    ric.CRABB_DEV__Confermata__c = true;
                    ric.CRABB_DEV__stato_riconciliazione__c = 'Approvata';
                } else {
                    ric.CRABB_DEV__Tipologia_riconciliazione__c = 'Transazione con associazione parziale';
                }
            }

            System.debug('########## dati riconciliazione da inserire: ');
            System.debug('CRABB_DEV__Pratica__c: ' + ric.CRABB_DEV__Pratica__c);
            System.debug('CRABB_DEV__Account__c: ' + ric.CRABB_DEV__Account__c);
            System.debug('CRABB_DEV__stato_riconciliazione__c: ' + ric.CRABB_DEV__stato_riconciliazione__c);
            System.debug('CRABB_DEV__Tipologia_riconciliazione__c: ' + ric.CRABB_DEV__Tipologia_riconciliazione__c);

            newList.add(ric);
        }
        return newList;
    }

    global class draft_Riconciliazioni {
        public Date dataContabile;
        public Date dataElaborazione;
        public Date dataElaborazioneFlusso;
        public Date dataValuta;
        public Decimal importo;
        public String praticaName;
        public String accountName;
        public String causale;
        public String descrizioneCausale;
        public String numeroConto;
        public String segnoImporto;
    }

    global class herokuRequest {
        public list<String> praticaNameList;
        public list<String> accountNameList;
        public list<draft_Riconciliazioni> draftRic;
    }

}