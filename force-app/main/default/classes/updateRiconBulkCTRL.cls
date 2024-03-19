/* ---------------------------------------------------------------------------------------------------------------------
Name:            updateRiconBulkCTRL.cls
Description:
Test class:      TestUpdateRiconBulkCTRL.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
21-May-2022   0.1      S.Salaris            First Version
16-Sep-2022   0.2      C.Sanna & R.Kurti    Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class updateRiconBulkCTRL {

    @AuraEnabled
    public static list<SObject> readCSVFile(Id idContentDocument) {
        list<SObject> ricStagList = new list<SObject>();
        if (idContentDocument != null) {

            // getting File Data based on document id
            ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId = :idContentDocument WITH SECURITY_ENFORCED];
            // split the file data
            list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');

            for (Integer i = 1; i < lstCSVLines.size(); i++) {
                CRABB_DEV__Riconciliazione_Staging__c ricStag = new CRABB_DEV__Riconciliazione_Staging__c();
                list<String> csvRowData = lstCSVLines[i].split(',');
                System.debug('csvRowData====> ' + csvRowData);
                ricStag.CRABB_DEV__RiconciliazioneId__c = csvRowData[0];// accName
                ricStag.CRABB_DEV__PraticaId__c = csvRowData[1];
                ricStag.CRABB_DEV__Value__c = csvRowData[2];
                ricStag.CRABB_DEV__Stato__c = 'Nuovo';
                ricStag.CRABB_DEV__Autore__c = UserInfo.getUserId();
                ricStag.CRABB_DEV__Nome_Autore__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
                ricStagList.add(ricStag);

            }

            try {
                if (!ricStagList.isEmpty()) {
                    System.debug('############## la lista di record di staging da inserire è grande: ' + ricStagList.size());
                    insert ricStagList;
                }
            } catch (Exception ex) {
                throw new AuraHandledException(ex.getMessage());
            }
        }
        return ricStagList;
    }

    @AuraEnabled
    public static String callBatch() {
        String autore = UserInfo.getUserId();
        String email = UserInfo.getUserEmail();

        List<String> statusList = getStatusPratica();

        try {
            BatchUpdateRiconciliazioniBulk istanza = new BatchUpdateRiconciliazioniBulk(autore, email, statusList);
            Id process = Database.executeBatch(istanza);
            return 'Batch di aggiornamento chiamato';
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String deleteStagingRecords() {
        String autore = UserInfo.getUserId();
        try {
            BatchDeleteRiconStaging istanza = new BatchDeleteRiconStaging(autore);
            Id process = Database.executeBatch(istanza);
            return 'Batch di annullamento chiamato';
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static List<String> getStatusPratica() {
        List<String> statusPraticaList = new List<String>();

        List<Profile> profileList = [SELECT Name from Profile WHERE Id = :UserInfo.getProfileId() WITH SECURITY_ENFORCED];
        String profileName = String.valueof(profileList.get(0).Name);

        List<CRABB_DEV__riconciliazione_profile_view__mdt> listStati = [
                SELECT CRABB_DEV__Pratica_status__c, CRABB_DEV__Profile_Name__c,
                        CRABB_DEV__Riconciliazione_status__c
                FROM CRABB_DEV__riconciliazione_profile_view__mdt
                WHERE CRABB_DEV__Riconciliazione_status__c = 'In Lavorazione'
                WITH SECURITY_ENFORCED
        ];

        List<String> profiliList;

        for (CRABB_DEV__riconciliazione_profile_view__mdt m : listStati) {
            profiliList = String.valueOf(m.get('CRABB_DEV__Profile_Name__c')).split('\\|');
            if (profiliList.contains(profileName)) {
                if (String.isNotBlank(String.valueOf(m.get('CRABB_DEV__Pratica_status__c')))) {
                    statusPraticaList = String.valueOf(m.get('CRABB_DEV__Pratica_status__c')).split('\\|');
                    break;
                }
            }
        }

        return statusPraticaList;
    }

    @AuraEnabled
    public static List<exportWr> getExportData() {

        List<CRABB_DEV__mapping_riconciliazioni__mdt> keyFieldList = [
                SELECT CRABB_DEV__riconciliazione_field__c, CRABB_DEV__key_field__c
                from CRABB_DEV__mapping_riconciliazioni__mdt
                WHERE CRABB_DEV__riconciliazione_field__c = 'Account__c'
                WITH SECURITY_ENFORCED
        ];

        String keyField = keyFieldList.get(0).CRABB_DEV__key_field__c;
        List<String> statusList = getStatusPratica();
        System.debug('@@@@@@ lista di stati pratica disponibili: ' + statusList);

        List<exportWr> wrList = new List<exportWr>();
        exportWr wr;
        Map<Id, CRABB_DEV__Riconciliazione__c> mapRicon = new Map<Id, CRABB_DEV__Riconciliazione__c>([
                SELECT Id, Name, Tipologia_riconciliazione__c,
                        CRABB_DEV__Confermata__c, CRABB_DEV__stato_riconciliazione__c, CRABB_DEV__Importo__c, CRABB_DEV__Account__c
                FROM CRABB_DEV__Riconciliazione__c
                WHERE CRABB_DEV__Account__c != null and CRABB_DEV__Confermata__c = false
                and CRABB_DEV__stato_riconciliazione__c = 'In Lavorazione'
                WITH SECURITY_ENFORCED
                order by CRABB_DEV__Account__c asc
        ]);
        System.debug('@@@@@@ dimensione mappa di Riconciliazioni: ' + mapRicon.size());


        Set<Id> accIdSet = new Set<Id>();
        Map<Id, List<CRABB_DEV__Riconciliazione__c>> mapAccWithRicon = new Map<Id, List<CRABB_DEV__Riconciliazione__c>>();
        List<CRABB_DEV__Riconciliazione__c> ricListForAcc;

        for (Id ricId : mapRicon.keySet()) {
            accIdSet.add(mapRicon.get(ricId).CRABB_DEV__Account__c);
            ricListForAcc = mapAccWithRicon.containsKey(mapRicon.get(ricId).CRABB_DEV__Account__c) ? mapAccWithRicon.get(mapRicon.get(ricId).CRABB_DEV__Account__c) : new List<CRABB_DEV__Riconciliazione__c>();
            ricListForAcc.add(mapRicon.get(ricId));
            mapAccWithRicon.put(mapRicon.get(ricId).CRABB_DEV__Account__c, ricListForAcc);
        }

        String queryPrat = 'SELECT Id, Name, Residuo_Totale__c, Stato__c, Account__c, CRABB_DEV__Account__r.Name';
        queryPrat += !queryPrat.contains(keyField) ? ', Account__r.' + String.escapeSingleQuotes(keyField) + ' ' : ' ';
        queryPrat += 'FROM CRABB_DEV__Pratica__c WHERE Account__c in :accIdSet ';
        queryPrat += statusList.size() > 0 ? 'AND Stato__c in :statusList WITH SECURITY_ENFORCED order by CRABB_DEV__Account__c asc' : 'WITH SECURITY_ENFORCED order by CRABB_DEV__Account__c asc';
        System.debug('@@@@queryprat: ' + queryPrat);
        List<CRABB_DEV__Pratica__c> pratList = Database.query(String.escapeSingleQuotes(queryPrat));

        for (CRABB_DEV__Pratica__c pra : pratList) {
            if (mapAccWithRicon.containsKey(pra.Account__c)) {
                for (CRABB_DEV__Riconciliazione__c ric : mapAccWithRicon.get(pra.Account__c)) {
                    wr = new exportWr();
                    wr.Account_Name = pra.CRABB_DEV__Account__r.Name;
                    wr.Codice_Cliente = String.valueOf(pra.CRABB_DEV__Account__r.get(keyField));
                    wr.Codice_Pratica = pra.Name;
                    wr.Pratica_Id = pra.Id;
                    wr.Pratica_Scaduto = String.valueOf(pra.CRABB_DEV__Residuo_Totale__c);
                    wr.Riconciliazione_Id = ric.Id;
                    wr.Riconciliazion_eName = ric.Name;
                    wr.Riconciliazione_Importo = String.valueOf(ric.CRABB_DEV__Importo__c);
                    wrList.add(wr);
                }
            }
        }

        System.debug('@@@@@@ dimensione lista di wrapper: ' + wrList.size());
        return wrList;
    }


    public class exportWr {
        @AuraEnabled
        public String Account_Name;
        @AuraEnabled
        public String Codice_Cliente;
        @AuraEnabled
        public String Codice_Pratica;
        @AuraEnabled
        public String Pratica_Id;
        @AuraEnabled
        public String Pratica_Scaduto;
        @AuraEnabled
        public String Riconciliazione_Id;
        @AuraEnabled
        public String Riconciliazion_eName;
        @AuraEnabled
        public String Riconciliazione_Importo;


    }
}