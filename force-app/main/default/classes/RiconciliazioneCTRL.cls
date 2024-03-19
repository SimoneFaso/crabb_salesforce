/* ---------------------------------------------------------------------------------------------------------------------
Name:            RiconciliazioneCTRL.cls
Description:
Test class:      TestRiconciliazioneCTRL.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
21-Dec-2021  0.2      Claudio Sanna                   Added check permission:
                                                      cebCheckObjPermission and cebCheckFLSPermission (Security Review)
16-Sep-2022  0.2      C.Sanna & R.Kurti               Added WITH SECURITY ENFORCED (security review)

----------------------------------------------------------------------------------------------------------------------*/

public with sharing class RiconciliazioneCTRL {

    public static Map<String, SObjectType> gd = Schema.getGlobalDescribe();
    //metodo chiamato imperativamente, usato all'inizio per mostrare le pratiche dell'account e ad ogni cambiamento del filtro di ricerca
    @AuraEnabled
    public static list<BozzaMovimento> GetpraticheByAccount(String riconciliazioneId, String searchText) {

        System.debug('*** searchText:' + searchText);

        list<BozzaMovimento> MovimentoList_Stored = new list<BozzaMovimento >();
        list<BozzaMovimento> MovimentoList_Shown = new list<BozzaMovimento >();
        list<CRABB_DEV__Pratica__c > praticaList = new list<CRABB_DEV__Pratica__c >();
        Map<String, BozzaMovimento> draftMap = new Map<String, BozzaMovimento>();

        list<CRABB_DEV__Riconciliazione__c > ricList = [
                SELECT id, CRABB_DEV__Account__c, CRABB_DEV__Pratica__c,
                        CRABB_DEV__Bozza_movimento__c, CRABB_DEV__Importo__c, CRABB_DEV__stato_riconciliazione__c
                FROM CRABB_DEV__Riconciliazione__c
                WHERE id = :riconciliazioneId
                WITH SECURITY_ENFORCED
        ];

        if (String.isNotBlank(ricList.get(0).CRABB_DEV__Bozza_movimento__c)) {
            MovimentoList_Stored = (List<BozzaMovimento>) JSON.deserialize(ricList.get(0).CRABB_DEV__Bozza_movimento__c, List<BozzaMovimento>.class);
            for (BozzaMovimento b : MovimentoList_Stored) {
                draftMap.put(b.IdPratica, b);
            }
        }

        String accountId = ricList.get(0).CRABB_DEV__Account__c;
        String statusRic = ricList.get(0).CRABB_DEV__stato_riconciliazione__c;
        String QueryFieldsOnPratica = 'SELECT Id, Name, CRABB_DEV__Account__r.Name, CRABB_DEV__Account__r.Id, ' +
                'CRABB_DEV__Strategia__r.CRABB_DEV__Tipo_Servizio__c, CRABB_DEV__Data_Apertura__c, CRABB_DEV__Stato__c, ' +
                ' CRABB_DEV__Residuo_Totale__c, CRABB_DEV__Esito_Ultima_Attivit_in_Lavorazione__c from CRABB_DEV__Pratica__c';

        ID ProfileId = UserInfo.getProfileId();
        List<Profile> profileList = [SELECT Name from Profile WHERE Id = :ProfileId WITH SECURITY_ENFORCED];
        String profileName = String.valueof(profileList.get(0).Name);
        List<String> statusPraticaList = getStatusPratica(profileName, statusRic);

        if (String.isNotBlank(accountId)) {

            if (String.isBlank(searchText)) {
                //system.debug('sono nel caso blank '+searchText+' '+accountId);
                QueryFieldsOnPratica += ' WHERE CRABB_DEV__Account__c = \'' + String.escapeSingleQuotes(accountId) + '\'';
                if (statusPraticaList.size() > 0) {
                    QueryFieldsOnPratica += ' and CRABB_DEV__Stato__c in :statusPraticaList';
                }
                QueryFieldsOnPratica += ' WITH SECURITY_ENFORCED';
                praticaList = database.query(QueryFieldsOnPratica);
            } else {
                //system.debug('sono nel caso NON blank '+searchText+' '+accountId);
                QueryFieldsOnPratica += ' WHERE CRABB_DEV__Account__c = \'' + accountId + '\' and (name like \'%' + searchText + '%\')';
                if (statusPraticaList.size() > 0) {
                    QueryFieldsOnPratica += ' and CRABB_DEV__Stato__c in :statusPraticaList';
                }
                QueryFieldsOnPratica += ' WITH SECURITY_ENFORCED';
                praticaList = database.query(QueryFieldsOnPratica);
            }


            for (CRABB_DEV__Pratica__c pra : praticaList) {
                BozzaMovimento movimento = new BozzaMovimento();
                movimento.IdPratica = pra.id;
                movimento.Name = pra.Name;
                movimento.AccountName = pra.Account__r.Name;
                movimento.IdAccount = pra.Account__r.Id;
                movimento.Stato = pra.Stato__c;
                movimento.TipoServizio = pra.Strategia__r.Tipo_Servizio__c;
                movimento.DataApertura = pra.Data_Apertura__c;
                movimento.EsitoUltimaAttivitaLavorazione = pra.Esito_Ultima_Attivit_in_Lavorazione__c;
                movimento.Scaduto = pra.Residuo_Totale__c;
                movimento.totaleImportoRiconciliazione = ricList.get(0).CRABB_DEV__Importo__c;
                //movimento.IdNoleggio = null;
                if (draftMap.containsKey(pra.Id)) {
                    movimento.Value = draftMap.get(pra.Id).Value;
                    movimento.Esito = draftMap.get(pra.Id).Esito;
                } else {
                    if (movimento.IdPratica == riclist.get(0).CRABB_DEV__Pratica__c && riclist.get(0).CRABB_DEV__Importo__c != null) {
                        if (riclist.get(0).CRABB_DEV__Importo__c <= movimento.Scaduto) {
                            movimento.value = String.valueOf(riclist.get(0).CRABB_DEV__Importo__c);
                        } else {
                            movimento.value = String.valueOf(movimento.Scaduto);
                        }
                    } else {
                        movimento.Value = null;
                    }
                    movimento.Esito = null;
                }
                MovimentoList_Shown.add(movimento);
            }
        }
        return MovimentoList_Shown;
    }

    @AuraEnabled
    public static void SaveBozza(String riconciliazioneId, String bozzaJson) {
        System.debug('bozzaJson: ' + bozzaJson);
        System.debug(riconciliazioneId);

        Map<String, BozzaMovimento> draftMap = new Map<String, BozzaMovimento>();

        List<BozzaMovimento> MovimentoList_Stored = new List<BozzaMovimento>();
        list<CRABB_DEV__Riconciliazione__c > ricList = [
                SELECT id, CRABB_DEV__Account__c, CRABB_DEV__Bozza_movimento__c
                FROM CRABB_DEV__Riconciliazione__c
                WHERE id = :riconciliazioneId
                WITH SECURITY_ENFORCED
        ];

        //riprendo le pratiche memorizzate e le metto in lista
        if (String.isNotBlank(ricList.get(0).CRABB_DEV__Bozza_movimento__c)) {
            MovimentoList_Stored = (List<BozzaMovimento>) JSON.deserialize(ricList.get(0).CRABB_DEV__Bozza_movimento__c, List<BozzaMovimento>.class);
            for (BozzaMovimento b : MovimentoList_Stored) {
                //considero null tutti i value che sono stringa vuota, null o zero
                if (string.isBlank(b.Value) || b.Value.equals('0')) {
                    b.Value = null;
                }
                draftMap.put(b.IdPratica, b);
            }
        }
        //Inserisco nuove pratiche draft o aggiorno quelle già memorizzate
        List<BozzaMovimento> MovimentoList_Updates = (List<BozzaMovimento>) JSON.deserialize(bozzaJson, List<BozzaMovimento>.class);

        for (BozzaMovimento b : MovimentoList_Updates) {

            if (draftMap.containsKey(b.IdPratica)) {
                BozzaMovimento BozzaStored = draftMap.get(b.IdPratica);
                if (b.Esito == null) {
                    b.Esito = BozzaStored.Esito;
                }
                if (b.Value == null) {
                    b.Value = BozzaStored.Value;
                }
            }

            //considero null tutti i value che sono stringa vuota, null o zero
            if (string.isBlank(b.Value) || b.Value.equals('0')) {
                b.Value = null;
            }

            draftMap.put(b.IdPratica, b);
        }

        CRABB_DEV__Riconciliazione__c a = new CRABB_DEV__Riconciliazione__c();
        a.id = riconciliazioneId;
        a.CRABB_DEV__Bozza_movimento__c = JSON.serialize(draftMap.Values());
        //update a;
        if (Utils.cebCheckObjPermission('Riconciliazione__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Riconciliazione__c', 'Bozza_movimento__c', gd).get('UPDATE')) {
            update a;
        }
        System.debug('123');

    }

    @AuraEnabled
    public static Boolean isEditable(String riconciliazioneId) {

        Boolean editable = true;
        list<CRABB_DEV__Riconciliazione__c > ricList = [
                SELECT id, CRABB_DEV__Account__c, CRABB_DEV__stato_riconciliazione__c
                FROM CRABB_DEV__Riconciliazione__c
                WHERE id = :riconciliazioneId
                WITH SECURITY_ENFORCED
        ];
        if (ricList.get(0).CRABB_DEV__stato_riconciliazione__c == 'Approvata' || ricList.get(0).CRABB_DEV__stato_riconciliazione__c == 'Rifiutata' || ricList.get(0).CRABB_DEV__Account__c == null) {
            editable = false;
        }
        return editable;

    }

    @AuraEnabled
    public static void updateStatus(String riconciliazioneId, String status) {
        //CRABB_DEV__Riconciliazione__c  ric = new CRABB_DEV__Riconciliazione__c(id=riconciliazioneId,CRABB_DEV__stato_riconciliazione__c=status);
        CRABB_DEV__Riconciliazione__c riconciliazione = [
                SELECT Id, CRABB_DEV__Pratica__c, CRABB_DEV__Bozza_movimento__c,
                        CRABB_DEV__Importo__c, CRABB_DEV__Pratica__r.CRABB_DEV__Residuo_Totale__c
                FROM CRABB_DEV__Riconciliazione__c
                WHERE Id = :riconciliazioneId
                WITH SECURITY_ENFORCED
        ];
        BozzaMovimento movimento = new BozzaMovimento();
        List<BozzaMovimento> listBozze = new List<BozzaMovimento>();
        if (String.isBlank(riconciliazione.CRABB_DEV__Bozza_movimento__c) && riconciliazione.CRABB_DEV__Importo__c != null) {
            movimento.IdPratica = riconciliazione.Pratica__c;
            if (riconciliazione.CRABB_DEV__Importo__c <= riconciliazione.CRABB_DEV__Pratica__r.CRABB_DEV__Residuo_Totale__c) {
                movimento.value = String.valueOf(riconciliazione.Importo__c);
            } else {
                movimento.value = String.valueOf(riconciliazione.CRABB_DEV__Pratica__r.CRABB_DEV__Residuo_Totale__c);
            }
            listBozze.add(movimento);
            riconciliazione.CRABB_DEV__Bozza_movimento__c = JSON.serialize(listBozze);
        }
        riconciliazione.Id = riconciliazioneId;
        riconciliazione.stato_riconciliazione__c = status;

        //update riconciliazione;
        if (Utils.cebCheckObjPermission('Riconciliazione__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Riconciliazione__c', 'Bozza_movimento__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Riconciliazione__c', 'stato_riconciliazione__c', gd).get('UPDATE')) {
            update riconciliazione;
        }
    }

    public static List<String> getStatusPratica(String profileName, String ricStatus) {
        List<String> statusPraticaList = new List<String>();
        List<CRABB_DEV__riconciliazione_profile_view__mdt> listStati = [
                SELECT CRABB_DEV__Pratica_status__c, CRABB_DEV__Profile_Name__c, CRABB_DEV__Riconciliazione_status__c
                FROM CRABB_DEV__riconciliazione_profile_view__mdt
                WITH SECURITY_ENFORCED
        ];

        List<String> profiliList;
        List<String> ricStatusList;
        for (CRABB_DEV__riconciliazione_profile_view__mdt m : listStati) {
            ricStatusList = String.valueOf(m.get('CRABB_DEV__Riconciliazione_status__c')).split('\\|');
            profiliList = String.valueOf(m.get('CRABB_DEV__Profile_Name__c')).split('\\|');
            if (ricStatusList.contains(ricStatus) && profiliList.contains(profileName)) {
                if (String.isNotBlank(String.valueOf(m.get('CRABB_DEV__Pratica_status__c')))) {
                    statusPraticaList = String.valueOf(m.get('CRABB_DEV__Pratica_status__c')).split('\\|');
                    break;
                }
            }
        }
        return statusPraticaList;
    }

    public class BozzaMovimento {
        @AuraEnabled
        public String IdPratica;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Value;
        @AuraEnabled
        public String Esito;
        @AuraEnabled
        public string AccountName;
        @AuraEnabled
        public string IdAccount;
        @AuraEnabled
        public string Stato;
        @AuraEnabled
        public string TipoServizio;
        @AuraEnabled
        public Date DataApertura;
        @AuraEnabled
        public string EsitoUltimaAttivitaLavorazione;
        @AuraEnabled
        public Decimal Scaduto;
        //@AuraEnabled
        //public string IdNoleggio;
        @AuraEnabled
        public Decimal totaleImportoRiconciliazione;
    }

}