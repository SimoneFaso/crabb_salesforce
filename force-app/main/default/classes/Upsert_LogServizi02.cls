/* -----------------------------------------------------------------------------------------------------------------
Name:            Upsert_LogServizi02.cls
Description:
Test class:      ?.cls


             0.1                              First Version
08-oct-2021  0.2    Matteo Pizzichini         Fixing FLS adding braces to if and ceb methods
15-Sep-2022  0.3    R.Kurti & C.Sanna         Added cebObjCheckPermission for secuirty review

----------------------------------------------------------------------------------------------------------------- */
public with sharing class Upsert_LogServizi02 {
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    public void Upsert_LogServizi02() {

    }

    public static void UpsertServizio(Id IdLogToWrite, DateTime DataInizio,
            map<Integer, String> ErrorStringPerInteger, map<Integer, Servizio__c> MapServiziToUpsertPerIndice,
            map<Integer, String> NewMapException) {

        //Creo In Json gli esiti del caricamento del movimento e popolo il log
        String allfieldsLog = CredManUtility.selectallShort('Log__c');
        Log__c LogToUpdate = new Log__c();
        if (Utils.cebCheckObjPermission('Log__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'Account_KO__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'Account_OK__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'Account_TOT__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'Durata__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'Error__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'File_Caricati__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'Fine__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'info__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'Line_number__c', gd).get('ACCESS')) {
            LogToUpdate = database.query(String.escapeSingleQuotes('SELECT ' + allfieldsLog +
                    ' FROM Log__c WHERE Id = : IdLogToWrite '));
        }
        integer ServiziOK = 0;
        integer ServiziKO = 0;
        if (MapServiziToUpsertPerIndice.keyset().size() > 0) {
            Set<integer> IndiceMapServiziUpsert = MapServiziToUpsertPerIndice.keyset();
            list<Integer> ListIndiceSortServiziUpsert = new list<Integer>();
            for (Integer i : IndiceMapServiziUpsert) {
                ListIndiceSortServiziUpsert.add(i);
            }
            ListIndiceSortServiziUpsert.sort();
            list<Servizio__c> ListServiziUpsertSort = new list<Servizio__c>();
            for (integer i : ListIndiceSortServiziUpsert) {
                ListServiziUpsertSort.add(MapServiziToUpsertPerIndice.get(i));
            }
            // inizio nuovo codice 18/04/17 inserimento check permission
            if (Utils.cebCheckObjPermission('Servizio__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Servizio__c', 'Contratto__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Servizio__c', 'Data_Fine_Contratto__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Servizio__c', 'Codice__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Servizio__c', 'Data_Inizio_Contratto__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Servizio__c', 'Id_SoftwareHouse__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Servizio__c', 'Metodo_di_Pagamento__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Servizio__c', 'Nome__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Servizio__c', 'POD__c', gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Servizio__c', 'Stato__c', gd).get('UPSERT')) {
                List<Database.Upsertresult> upsertResultServizi = Database.upsert(ListServiziUpsertSort, Servizio__c.Id_Esterno__c, false);
                integer n2 = 0;
                for (Database.Upsertresult ur : upsertResultServizi) {
                    Integer ConteggioIndice = ListIndiceSortServiziUpsert[n2];
                    string message = '';
                    if (!ur.isSuccess()) {
                        message += 'KO2Upsert_WARNING: ';
                        for (Database.Error dbe : ur.getErrors())
                            message += dbe.message + ' - ';
                        message += '. The line ' + ConteggioIndice + ' will be ignored.\n';
                    }
                    ErrorStringPerInteger.put(ConteggioIndice, message);
                    n2++;
                }
            }
            // fine nuovo codice 18/04/17 inserimento check permission
        }


        Set<Integer> SetLogFinal = ErrorStringPerInteger.keyset();
        list<Integer> ListIndiceForLog = new list<Integer>();
        for (integer i : SetLogFinal) {
            ListIndiceForLog.add(i);
        }

        system.debug('*****ListIndiceForLog.size() = ' + ListIndiceForLog.size());
        Integer IndiceCSVForLog;
        Integer RigaReale;
        map<Integer, String> MapErrorePerNRIGAFinal = new map<Integer, String>();
        for (integer i = 0; i < ListIndiceForLog.size(); i++) {
            IndiceCSVForLog = ListIndiceForLog[i];
            RigaReale = ListIndiceForLog[i];
            if (ErrorStringPerInteger.get(IndiceCSVForLog).startsWith('KO')) {
                system.debug('******OKAcc');
                //Gestione KO
                if (ErrorStringPerInteger.get(IndiceCSVForLog).startsWith('KO2')) {
                    //Gestione Log Servizi
                    ServiziKO++;
                    system.debug('**** KO1 *** ErrorStringPerInteger = ' + ErrorStringPerInteger);
                    if (ErrorStringPerInteger.get(IndiceCSVForLog).contains('Exception')) {
                        MapErrorePerNRIGAFinal.put(RigaReale, 'KO - Row ' + RigaReale + ' - ERRORE INASPETTATO: ' + NewMapException.get(IndiceCSVForLog));
                    } else if (ErrorStringPerInteger.get(IndiceCSVForLog).substring(3, 9) == 'Upsert') {
                        MapErrorePerNRIGAFinal.put(RigaReale, 'KO - Row ' + RigaReale + ' - ERRORE DURANTE IL SALVATAGGIO: ' + ErrorStringPerInteger.get(IndiceCSVForLog).substring(10, ErrorStringPerInteger.get(IndiceCSVForLog).length()));
                    } else {
                        MapErrorePerNRIGAFinal.put(RigaReale, 'KO - Row ' + RigaReale + ' - ERRORE DI DATI: ' + ErrorStringPerInteger.get(IndiceCSVForLog).substring(4, ErrorStringPerInteger.get(IndiceCSVForLog).length()));
                    }
                } else {
                    MapErrorePerNRIGAFinal.put(RigaReale, 'KO - Row ' + RigaReale + ' - ERRORE DI DATI: ' + ErrorStringPerInteger.get(IndiceCSVForLog).substring(4, ErrorStringPerInteger.get(IndiceCSVForLog).length()));
                }
            } else {
                system.debug('******KOAcc');
                //Gestion OK
                ServiziOK++;
                MapErrorePerNRIGAFinal.put(RigaReale, 'OK - Row ' + RigaReale + ' [' + MapServiziToUpsertPerIndice.get(IndiceCSVForLog).Id_Esterno__c + '] - Servizio Lavorato Correttamente');
            }

        }

        String MsgErrorForLog = '';
        set<Integer> IndiceForBuildLog = MapErrorePerNRIGAFinal.keyset();
        list<integer> IndiceLogCSV = new list<integer>();
        for (integer i : IndiceForBuildLog) {
            IndiceLogCSV.add(i);
        }
        IndiceLogCSV.sort();
        map<Integer, String> MapResultIntegrationLog = new map<Integer, String>();
        String JsonResult;
        for (Integer IndiceOrdinato : IndiceLogCSV) {
            MapResultIntegrationLog.put(IndiceOrdinato, MapErrorePerNRIGAFinal.get(IndiceOrdinato));
            JsonResult = Json.serialize(MapResultIntegrationLog);

            /*String LogResult = MapErrorePerNRIGAFinal.get(IndiceOrdinato);
            MsgErrorForLog+=LogResult+'\n';*/
        }

        // Aggiorno il Log che mi è stato passato in input
        LogToUpdate.Servizi_KO__c = ServiziKO;
        LogToUpdate.Servizi_OK__c = ServiziOK;
        LogToUpdate.Servizi_TOT__c = ServiziOK + ServiziKO;
        LogToUpdate.Integration_Result__c = JsonResult;
        LogToUpdate.Integration_processed__c = true;
        LogToUpdate.Inizio__c = DataInizio;
        if (Utils.cebCheckObjPermission('Log__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Servizi_KO__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Servizi_OK__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Servizi_TOT__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Integration_Result__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Integration_processed__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Log__c', 'Inizio__c', gd).get('UPDATE')) {
            update LogToUpdate;
        }
    }

}