/* ---------------------------------------------------------------------------------------------------------------------
Name:            RiconciliazioneHandler.cls
Description:
Test class:      TestRiconciliazioneHandler.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
16-Sep-2022  0.2      C.Sanna & R.Kurti    Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class RiconciliazioneHandler implements ITrigger {

    list<Movimento__c> IncassoList = new list<Movimento__c>();
    List<Pratica__c> praticheToUpdate = new List<Pratica__c>();
    Map<String, String> accountPraticheMap = new Map<String, String>();


    public RiconciliazioneHandler() {

    }
    public void bulkBefore() {

    }

    public void bulkAfter() {

    }

    public void bulkAfter(List<SObject> soListNew) {

    }

    public void bulkAfter(List<SObject> soListOld, List<SObject> soListNew) {

    }

    public void bulkBefore(List<Riconciliazione__c> soListNew) {
        List<id> praticaListID = new List<id>();
        List<Pratica__c> praticaList = new List<Pratica__c>();

        for (Riconciliazione__c new_record : soListNew) {
            if (new_record.CRABB_DEV__Pratica__c != null) {
                praticaListID.add(new_record.CRABB_DEV__Pratica__c);
            }
        }

        praticaList = [
                SELECT id, CRABB_DEV__Account__c
                FROM CRABB_DEV__Pratica__c
                where id IN :praticaListID
                AND CRABB_DEV__Account__c != null
                WITH SECURITY_ENFORCED
        ];

        for (Pratica__c pr : praticaList) {
            accountPraticheMap.put(pr.id, pr.CRABB_DEV__Account__c);
        }
    }

    public void beforeInsert(List<Riconciliazione__c> soListNew) {
        for (Riconciliazione__c ric : soListNew) {
            if (accountPraticheMap.containsKey(ric.CRABB_DEV__Pratica__c)) {
                ric.CRABB_DEV__Account__c = accountPraticheMap.get(ric.CRABB_DEV__Pratica__c);
            }
        }
    }

    public void beforeUpdate(List<Riconciliazione__c> soListOld, List<Riconciliazione__c> soListNew) {
        // collection utili
        Map<id, Riconciliazione__c> old_Map = new Map<id, Riconciliazione__c>(soListOld);

        for (Riconciliazione__c new_record : soListNew) {

            if (accountPraticheMap.containsKey(new_record.CRABB_DEV__Pratica__c)) {
                new_record.CRABB_DEV__Account__c = accountPraticheMap.get(new_record.CRABB_DEV__Pratica__c);
            }

            if (new_record.stato_riconciliazione__c == 'Rifiutata' && old_Map.get(new_record.id).stato_riconciliazione__c != 'Rifiutata') {
                new_record.CRABB_DEV__Tipologia_riconciliazione__c = 'Transazione con nessuna associazione';
                new_record.CRABB_DEV__Pratica__c = null;
                new_record.CRABB_DEV__Account__c = null;
            }

            if (new_record.stato_riconciliazione__c == 'Approvata' && old_Map.get(new_record.id).stato_riconciliazione__c != 'Approvata') {
                new_record.CRABB_DEV__Confermata__c = true;
            }

            if (new_record.stato_riconciliazione__c == 'Approvata' && old_Map.get(new_record.id).stato_riconciliazione__c != 'Approvata' && old_Map.get(new_record.id).CRABB_DEV__Tipologia_riconciliazione__c == 'Transazione con nessuna associazione') {
                new_record.CRABB_DEV__Tipologia_riconciliazione__c = 'Transazione con associazione parziale';
            }
        }
    }


    public void beforeDelete(List<SObject> so) {

    }

    public void afterInsert(List<Riconciliazione__c> new_riconciliazione) {
        List<String> accountList = new List<String>();
        List<String> praticheToCloseListID = new List<String>();
        List<Pratica__c> praticheWithAccount = new List<Pratica__c>();
        Map<String, List<Pratica__c>> praticheListMap = new Map<String, List<Pratica__c>>();

        for (Riconciliazione__c ricApp : new_riconciliazione) {
            if (ricApp.Confermata__c == true && ricApp.Pratica__c == null) {
                accountList.add(ricApp.Account__c);
            }
        }

        List<Pratica__c> praticheList = (List<Pratica__c>) [
                SELECT id, name, CRABB_DEV__Residuo_Totale__c, CRABB_DEV__Account__c
                FROM CRABB_DEV__Pratica__c
                WHERE CRABB_DEV__Account__c IN :accountList
                WITH SECURITY_ENFORCED
        ];
        for (String acc : accountList) {
            for (Pratica__c pr : praticheList) {
                if (acc == pr.Account__c) {
                    praticheWithAccount.add(pr);
                }
            }
            praticheListMap.put(acc, praticheWithAccount);
        }

        for (Riconciliazione__c ric : new_riconciliazione) {
            if (ric.Confermata__c == true) {
                if (ric.Pratica__c != null) {
                    Movimento__c Incasso = new Movimento__c();
                    Incasso.RecordTypeId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByName().get('INCASSO').getRecordTypeId();
                    Incasso.Importo__c = -ric.CRABB_DEV__Importo__c;
                    Incasso.Pratica__c = ric.CRABB_DEV__Pratica__c;
                    Incasso.Riconciliazione__c = ric.Id;
                    Incasso.Residuo__c = Incasso.Importo__c;
                    Incasso.Account__c = ric.CRABB_DEV__Account__c;
                    Incasso.IdentificativoFatturaExt__c = ric.Name + '-' + ric.CRABB_DEV__ID_Incasso_Progr__c;
                    Incasso.Data_Emissione__c = date.today();
                    Incasso.Data_Scadenza__c = date.today();
                    Incasso.Sollecitabile__c = true;
                    Incasso.Tipo_Scadenza__c = 'Scaduto';
                    IncassoList.add(Incasso);
                    praticheToCloseListID.add(ric.CRABB_DEV__Pratica__c);
                } else if (ric.Pratica__c == null && praticheListMap.containsKey(ric.Account__c)) {
                    for (Pratica__c pr : praticheListMap.get(ric.Account__c)) {
                        if (pr.Residuo_Totale__c > 0) {
                            Movimento__c Incasso = new Movimento__c();
                            Incasso.RecordTypeId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByName().get('INCASSO').getRecordTypeId();
                            Incasso.Importo__c = -pr.CRABB_DEV__Residuo_Totale__c;
                            Incasso.Pratica__c = pr.Id;
                            Incasso.Riconciliazione__c = ric.Id;
                            Incasso.Residuo__c = Incasso.Importo__c;
                            Incasso.IdentificativoFatturaExt__c = ric.Name + '-' + ric.CRABB_DEV__ID_Incasso_Progr__c;
                            Incasso.Account__c = pr.CRABB_DEV__Account__c;
                            Incasso.Data_Emissione__c = date.today();
                            Incasso.Data_Scadenza__c = date.today();
                            Incasso.Sollecitabile__c = true;
                            Incasso.Tipo_Scadenza__c = 'Scaduto';
                            IncassoList.add(Incasso);
                            praticheToCloseListID.add(pr.Id);
                        }
                    }
                }
            }
        }
        List<Pratica__c> praticheToCloseList = (List<Pratica__c>) [
                SELECT id, CRABB_DEV__Stato__c, CRABB_DEV__Residuo_Totale__c
                FROM CRABB_DEV__Pratica__c
                WHERE id IN :praticheToCloseListID
                WITH SECURITY_ENFORCED
        ];
        for (Pratica__c prat : praticheToCloseList) {
            //commentato perchè la pratica non deve essere chiusa --> deve essere gestita la chiusura dei task
            //prat.CRABB_DEV__Stato__c = 'Chiusa';
            praticheToUpdate.add(prat);
        }
    }

    public void afterUpdate(List<Riconciliazione__c> old_riconciliazione, List<Riconciliazione__c> new_riconciliazione) {
        List<String> praticheToCloseListID = new List<String>();
        Map<Id, Decimal> praticheWithImporto = new Map<Id, Decimal>();


        List<Riconciliazione__c> new_List = (List<Riconciliazione__c>) new_riconciliazione;
        List<Riconciliazione__c> old_List = (List<Riconciliazione__c>) old_riconciliazione;

        // collection utili
        Map<id, Riconciliazione__c> new_Map = new Map<id, Riconciliazione__c>(new_riconciliazione);
        Map<id, Riconciliazione__c> old_Map = new Map<id, Riconciliazione__c>(old_riconciliazione);

        for (Riconciliazione__c new_record : new_List) {
            if (new_record.stato_riconciliazione__c == 'Approvata' && old_Map.get(new_record.id).stato_riconciliazione__c != 'Approvata') {
                //creazione incassi
                Movimento__c Incasso;
                String IncassiDraft = new_record.Bozza_movimento__c;
                if (string.isNotBlank(IncassiDraft)) {

                    List<BozzaMovimento> MovimentoDraft_List = (List<BozzaMovimento>) JSON.deserialize(IncassiDraft, List<BozzaMovimento>.class);
                    for (BozzaMovimento bozza : MovimentoDraft_List) {
                        if (string.isNotBlank(bozza.Value)) {
                            Incasso = new Movimento__c();
                            Incasso.RecordTypeId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByDeveloperName().get('Incasso').getRecordTypeId();
                            Incasso.Importo__c = String.isBlank(bozza.Value) ? 0 : -decimal.valueOf(bozza.Value);
                            Incasso.CRABB_DEV__Causale__c = bozza.Esito;
                            Incasso.Pratica__c = bozza.IdPratica;
                            Incasso.Residuo__c = Incasso.Importo__c;
                            Incasso.Riconciliazione__c = new_record.id;
                            Incasso.IdentificativoFatturaExt__c = new_record.Name + '-' + new_record.CRABB_DEV__ID_Incasso_Progr__c;
                            Incasso.Account__c = new_record.Account__c;
                            Incasso.Data_Emissione__c = date.today();
                            Incasso.Data_Scadenza__c = date.today();
                            Incasso.Sollecitabile__c = true;
                            Incasso.Tipo_Scadenza__c = 'Scaduto';
                            IncassoList.add(Incasso);
                            praticheToCloseListID.add(bozza.IdPratica);
                            praticheWithImporto.put(bozza.IdPratica, decimal.valueOf(bozza.Value));
                        }
                    }
                }
            }
        }

        List<Pratica__c> praticheToCloseList = (List<Pratica__c>) [
                SELECT id, CRABB_DEV__Stato__c, CRABB_DEV__Residuo_Totale__c
                FROM CRABB_DEV__Pratica__c
                WHERE id IN :praticheToCloseListID
                WITH SECURITY_ENFORCED
        ];

        for (Pratica__c prat : praticheToCloseList) {
            if (praticheWithImporto.containsKey(prat.Id)) {
                if (prat.Residuo_Totale__c == praticheWithImporto.get(prat.Id)) {
                    //commentato perchè la pratica non deve essere chiusa --> deve essere gestita la chiusura dei task
                    //prat.CRABB_DEV__Stato__c = 'Chiusa';
                }
            }
            praticheToUpdate.add(prat);
        }
    }

    public void afterDelete(List<SObject> so) {

    }
    public void andFinally() {

        if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter) {
            if (IncassoList.size() > 0) {
                insert IncassoList;
            }
            //commentato perchè la pratica non deve essere chiusa --> deve essere gestita la chiusura dei task
            //if(praticheToUpdate.size() > 0) {
            //update praticheToUpdate;
            //}
        }
    }

    public class BozzaMovimento {
        public String IdPratica;
        public String Name;
        public String Value;
        public String Esito;
    }


}