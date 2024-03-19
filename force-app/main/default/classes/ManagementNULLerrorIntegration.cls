/* ---------------------------------------------------------------------------------------------------------------------
Name:            ManagementNULLerrorINtegration.cls
Description:
Test class:

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                             First Version
16-Sep-2022  0.2      R.Kurti & C.Sanna      Replaced CheckFLSPermission with cebCheckFLSPermission and added cebCheckObjPermission (security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class ManagementNULLerrorIntegration {

    public void ManagementNULLerrorIntegration() {

    }

    public static void UpsertMovimenti(Id IdLogToWrite, map<Integer,
            String> ErrorStringPerInteger,
            DateTime DataInizio) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        map<Integer, String> MapIndiceMovPerERROR = new map<Integer, String>();
        integer MovimentiKO = 0;

        //Creo In Json gli esiti del caricamento del movimento e popolo il log
        String allfieldsLog = CredManUtility.selectallShort('Log__c');
        if (Utils.cebCheckObjPermission('Log__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'Account_KO__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'Account_OK__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'Account_TOT__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'Class_Name__c ', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'CS_Tipo_Csv__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'Error_code__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'File_Caricati__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'File_Scartati__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'Fine__c', gd).get('ACCESS')) {
            Log__c LogToUpdate = database.query(String.escapeSingleQuotes('SELECT ' + allfieldsLog +
                    ' FROM Log__c WHERE Id = : IdLogToWrite '));
            system.debug('****ErrorStringPerInteger = ' + ErrorStringPerInteger);
            list<Integer> ListIndice = new list<Integer>();
            for (Integer i : ErrorStringPerInteger.keyset()) {
                MovimentiKO++;
                ListIndice.add(i);
                MapIndiceMovPerERROR.put(i, 'KO - Row ' + i + ' - ERRORE DI DATI: ' + ErrorStringPerInteger.get(i).Substring(2, ErrorStringPerInteger.get(i).length()));
            }

            map<Integer, String> MapResultIntegrationLog = new map<Integer, String>();
            String JsonResult;
            for (Integer IndiceOrdinato : ListIndice) {
                MapResultIntegrationLog.put(IndiceOrdinato, MapIndiceMovPerERROR.get(IndiceOrdinato));
                JsonResult = Json.serialize(MapResultIntegrationLog);
            }

            // Aggiorno il Log che mi è stato passato in input
            LogToUpdate.Movimenti_KO__c = MovimentiKO;
            LogToUpdate.Movimenti_TOT__c = MovimentiKO;
            LogToUpdate.Integration_Result__c = JsonResult;
            LogToUpdate.Inizio__c = DataInizio;
            if (Utils.cebCheckObjPermission('Log__c', gd).get('UPDATE ')
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

}