/* ---------------------------------------------------------------------------------------------------------------------
Name:            WSForCustomButtons.cls
Description:
Test class:

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
16-Sep-2022  0.2      C.Sanna & R.Kurti    Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/
global with sharing class WSForCustomButtons {
    webservice String a;

    // eseguI la strategia mensile su tutte le pratiche
    webservice static String BatchStrategiaMensile() {
        string sObjectName = 'Pratica__c';
        List<Strategia__c> sList = [
                Select id
                From Strategia__c
                Where Stato__c = 'Attiva' and Tipo_Strategia__c = 'Ricorsive'
                WITH SECURITY_ENFORCED
                LIMIT 1
        ];
        //List<Strategia__c> sList = [Select id From Strategia__c Where Stato__c='Attiva' and Tipo_Strategia__c='Ricorsive'];
        integer scope = 200;
        if (sList.size() == 0) return 'Nessuna strategia attiva';
        Database.executeBatch(new OrkBatch(sList[0].id), scope);
        return 'Batch avviato con successo';
    }
    webservice static String BatchTask() {
        string sObjectName = 'Task';
        integer scope = 200;
        Database.executeBatch(new OrkBatch(), scope);
        return 'Batch di lavorazione Task avviato con successo';
    }
    webservice static String workIntegrationLog(string action) {
        integer scope = 1;
        //Database.executeBatch(new IntegrationProcessLogBatch(action), scope);
        return 'Conmando non più attivo ' + action;
    }
}