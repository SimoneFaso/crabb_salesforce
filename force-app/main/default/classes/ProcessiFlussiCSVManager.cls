/* ---------------------------------------------------------------------------------------------------------------------
Name:            ProcessiFlussiCSVManager.cls
Description:
Test class:      TestProcessiFlussiCSVManager.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                       First Version
23-Dec-2015  0.2      E. Sino                          NuovoLottoAffidamento()
22-Sep-2021  0.3      C. Sanna                         Replaced checkFLSPermission with cebCheckFLSPermission
                                                       (Security Review)
16-Sep-2022  0.4      R.Kurti & C.Sanna                Added WITH SECURITY ENFORCED and cebCheckObjPermissions (security review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class ProcessiFlussiCSVManager {
    public static string startline, fieldSeparator, newline, endFile;
    public class ProcessiFlussiCSVManagerException extends Exception {
    }
    public static final Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    /*
    * Metodo che genera il flusso dei movimenti verso i collector.
    * Il metodo fa uso di altri due metodi. uno che lavora i dati relativi ai saldi, e un altro metodo che genera i dati dei moviementi.
    * Questi dati sono raccolti 
    */
    public static void AggiornamentoMovimenti(id idCollector) {
        String debugStr = '\n';
        debugStr += '\n id del Coll: ' + idCollector;
        string CSVString = '', headerToken = '_____headerAndPositions', headerSaldi = '_____headerSALDI', headerIncassi = '_____headerINCASSI', affFields, movFields, fruitFields, NomeFile = 'CRABB_AGGIORNAMENTOMOVIMENTI_';
        integer rowsSize = 0;
        dateTime dt = system.now(), dtT;
        map<string, sobject> so = new map<string, sobject>();
        /*Flussi collector is the new record that will be stored in the database for the new flow. Attacchment is the file that will be attached to the new flow. It will be a CSV file.*/
        Flussi_collector__c fc = new Flussi_collector__c();
        Attachment att = new Attachment();
        //Is the target collector of the flow
        Collector__c co = new Collector__c();
        //if (Utils.cebCheckFLSPermission('Collector__c', 'Ultimo_aggiornamento_movimenti__c', gd).get('ACCESS'))
        //if(Utils.checkFLSPermission('Collector__c', 'Ultimo_aggiornamento_movimenti__c').get('ACCESS'))

        co = [
                Select id, name, Ultimo_aggiornamento_movimenti__c, createdDate
                from Collector__c
                where id = :idCollector
                WITH SECURITY_ENFORCED
        ];

        debugStr += '\n Nome Coll: ' + co.name;
        //Set used to define how many lottos are present in the CSV FLOW
        set<id> numLotti = new set<id>();//utilizata solo per calcolare il numero di lotti associati al flusso
        //Map that contains the structure of the CSV File. The Structure is saved in a static resource in JSON format
        //iHeader is a sub element of the structure, and define the header of the file. Is a map integer, string, where integer define the column of the column, while the string define the name of the column
        map<string, Map<string, string>> fileMap = setCSVCharatteristics('FlussiCollector_AggiornamentoMovimenti_JSON');
        map<integer, string> iHeader = setMapForTheHeader(fileMap, headerToken);
        map<integer, string> iHeaderIncassi = setMapForTheHeader(fileMap, headerIncassi);
        map<integer, string> iHeaderSaldi = setMapForTheHeader(fileMap, headerSaldi);

        Map<id, Affidamento__c> affMap;
        Map<id, id> IdPratidAff = new Map<id, id>(); //Mappa tra Pratica e Affidamento, which is supposed to be 1-1
        list<id> idPratiche = new List<id>();
        list<Movimento__c> movList = new List<Movimento__c>();
        /*The flow extract the data in delta (only the data changed from the last flow extracted). 
            So if the Ultimo_aggiornamento_movimenti__c is null, we define as a starting date the creation 
            date of the collector, this because there are no affidamenti older than the creation date of the 
            collector. the variable dt is a date time that set the date where has been extracted the flow. 
            The date is wrote on the name of the flow. It will correspond also to the new Ultimo_aggiornamento_movimenti__c */
        if (co.Ultimo_aggiornamento_movimenti__c == null)co.Ultimo_aggiornamento_movimenti__c = co.createdDate;
        NomeFile += co.name + '_' + dt.year();
        //is seted the month with double chars
        if (dt.month() < 10) NomeFile += '0' + dt.month();
        else NomeFile += dt.month();
        //is seted the day with double chars
        if (dt.day() < 10) NomeFile += '0' + dt.day();
        else NomeFile += dt.day();
        //Is written the header line of the flow
        CSVString = startline + getCSVHeader(iHeader);
        affFields = Utils.getSOBJECTFieldsForQuery('Affidamento__c');
        movFields = Utils.getSOBJECTFieldsForQuery('Movimento__c');

        if (co.Ultimo_aggiornamento_movimenti__c == null) co.Ultimo_aggiornamento_movimenti__c = co.createdDate;
        dtT = co.Ultimo_aggiornamento_movimenti__c;
        co.Ultimo_aggiornamento_movimenti__c = dt;

        // prendi affidi
        idCollector = String.escapeSingleQuotes(idCollector);
        // inizio nuovo codice 13/04/17 inserimento CheckFLSPermission
        /*if(Utils.checkFLSPermission('Affidamento__c', 'Data_Affidamento__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Data_Termine_Proroga__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c').get('ACCESS'))*/
        if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Termine_Proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('ACCESS')) {
            affMap = new Map<id, Affidamento__c>((List<Affidamento__C>) database.query('Select ' + String.escapeSingleQuotes(affFields) + ', Pratica__r.name, pratica__r.Data_ultimo_aggiornamento_saldo__c from Affidamento__c where Lotto__r.Agenzia_di_Recupero__c=\'' + idCollector + '\' and Stato__c in (\'In corso\', \'Revocato\',\'Paga Parzialmente\',\'Paga Totalmente\',\'Scaduto\') AND lastmodifiedDAte>=:dtT order by lastmodifieddate Desc '));
            //Is made a check if there are affidamenti to align, if no the class returns, if the logs are active, than is created a log for info
        }
        // fine nuovo codice 13/04/17 inserimento CheckFLSPermission
        if (affMap == null || affMap.keyset().size() == 0) {
            if (TagHelper.getValueBoolean('AreFlowDebugInfoTurnedOn') == true) {
                debugStr = '\n **** Errore: Nessun affido' ;
                errorClass.logError('Info.ProcessiFlussiCSVManager.AggiornamentoMovimenti', 'Nella creazione del flusso AggiornamentoAngraficho non sono stati ritrovati affidamenti:' + idCollector);
                errorClass.logError('Info.ProcessiFlussiCSVManager.AggiornamentoMovimenti', 'Select ' + affFields + ', Pratica__r.name, pratica__r.Data_ultimo_aggiornamento_saldo__c from Affidamento__c where Lotto__r.Agenzia_di_Recupero__c=\'' + idCollector + '\' and Stato__c in (\'In corso\', \'Revocato\',\'Paga Parzialmente\',\'Paga Totalmente\',\'Scaduto\') AND lastmodifiedDAte>=:dtT order by lastmodifieddate Desc ');
            }
            return;
        }

        debugStr += '\n Data dtT: ' + dtT + '\n Affidi & Pratiche: ';
        for (affidamento__c a : affMap.Values()) {
            DebugStr += '\n ' + a.name;
            IdPratidAff.put(a.pratica__c, a.id);
            idPratiche.add(a.pratica__c);
            debugStr += '\n data Pratica: ' + a.pratica__r.Data_ultimo_aggiornamento_saldo__c;
            //In questo blocco sono scritte le linee
            if (a.pratica__r.Data_ultimo_aggiornamento_saldo__c == null || a.pratica__r.Data_ultimo_aggiornamento_saldo__c >= dtT) {
                debugStr += '\n ' + a.Pratica__r.name;
                rowsSize++;
                so.put('Affidamento', a);
                numLotti.add(a.lotto__c);
                CSVString += '"\r\n"' + getCSVNewLine(so, fieldSeparator, iHeaderSaldi, fileMap);
            }
        }

        so = new map<string, sobject>();
        /*if(Utils.checkFLSPermission('Movimento__c', 'Cartolarizzazione__c').get('ACCESS')
            && Utils.checkFLSPermission('Movimento__c', 'Causale_Non_Sollecitabile__c').get('ACCESS')
            && Utils.checkFLSPermission('Movimento__c', 'Data_Emissione__c').get('ACCESS')
            && Utils.checkFLSPermission('Movimento__c', 'Data_Incasso__c').get('ACCESS')
            && Utils.checkFLSPermission('Movimento__c', 'Data_Integrazione__c').get('ACCESS')
            && Utils.checkFLSPermission('Movimento__c', 'Data_Pagamento__c').get('ACCESS')
            && Utils.checkFLSPermission('Movimento__c', 'Data_Scadenza__c').get('ACCESS')
            && Utils.checkFLSPermission('Movimento__c', 'Importo__c').get('ACCESS')
            && Utils.checkFLSPermission('Movimento__c', 'Mese__c').get('ACCESS'))*/
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
            String queryString = 'Select ' + String.escapeSingleQuotes(movFields) + ' From Movimento__c where recordType.name like \'%ncasso%\' and lastmodifieddate >=:dtT and pratica__c in:idPratiche order by lastModifiedDate Desc' ;
            debugStr += '\n Il query dei movimenti: ' + queryString + '\n Lavorando movimenti: ';
            movList = database.query(queryString);
            for (Movimento__c m : movList) {
                debugStr += '\n ' + m.name;
                rowsSize++;
                affidamento__c a = affMap.get(IdPratidAff.get(m.pratica__c));
                so.put('Affidamento', a);
                so.put('Movimento', m);
                CSVString += '"\r\n"' + getCSVNewLine(so, fieldSeparator, iHeaderIncassi, fileMap);
            }
        }
        // E.S. 14/01/2015
        // Check to make sure, that file has rows to show
        if (rowsSize == 0) {
            debugStr = '\n **** Errore: Nessuna riga nel file CSV' ;
            errorClass.logError('Info.ProcessiFlussiCSVManager.AggiornamentoMovimenti', 'Nella creazione del flusso AggiornamentoAngraficho non sono stati ritrovati affidamenti o movimenti, da fotografare nel file!');
            return;
        }

        CSVString += endFile;
        debugStr += '\n fine';
        /*creazione dei file */
        fc.Collector__c = co.id;
        fc.Lotti_Presenti__c = string.valueof(numLotti.size());
        fc.Numero_Record__c = rowsSize;
        fc.Tipo__c = 'Aggiornamenti movimenti';
        /*if (Utils.checkFLSPermission('Flussi_collector__c', 'Collector__c').get('CREATE')
            && Utils.checkFLSPermission('Flussi_collector__c', 'Lotti_Presenti__c').get('CREATE')
            && Utils.checkFLSPermission('Flussi_collector__c', 'Numero_Record__c').get('CREATE')
            && Utils.checkFLSPermission('Flussi_collector__c', 'Tipo__c').get('CREATE')
           ) insert fc;*/
        if (Utils.cebCheckObjPermission('Flussi_collector__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Collector__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Lotti_Presenti__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Numero_Record__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Tipo__c', gd).get('CREATE')) {
            insert fc;
        }

        att.parentId = fc.id;
        att.name = NomeFile + '.csv';
        att.body = Blob.valueof(CSVString);
        /*if (Utils.checkFLSPermission('Attachment', 'parentId').get('CREATE')
            && Utils.checkFLSPermission('Attachment', 'name').get('CREATE')
            && Utils.checkFLSPermission('Attachment', 'body').get('CREATE')
            ) insert att;*/
        if (Utils.cebCheckObjPermission('Attachment', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Attachment', 'parentId', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Attachment', 'name', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Attachment', 'body', gd).get('CREATE')) {
            insert att;
        }
        //if (Utils.checkFLSPermission('Collector__c', 'Ultimo_aggiornamento_movimenti__c').get('UPDATE')) update co;
        if (Utils.cebCheckObjPermission('Collector__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Collector__c', 'Ultimo_aggiornamento_movimenti__c', gd).get('UPDATE')) {
            update co;
        }
        System.debug(debugStr);
        return;
    }

    /*
    *  Metodo per gestire i aggiornamenti anagrafici.
    *  Dettagli:
    *       CSVString=contiene il body del file CSV che verrà associato al flussi collector
            headerToken= è una chiave per identificare la mappa nella staticResource dove è indicato la posizione e il nome delle colone
            affFields= stringa per fare la query sugli affidamenti
            NomeFile=variabile che contiene il nome finaledel file che verrà creato
            rowsSize= numero di righe nel file
            dt= riporta la data in cui è stato generato il file
            fc= flussi collector che verrà creato e a cui viene allegato il file CSV
            so=mappa stringa SOBject che serve per l'algoritmo che genera la riga del CSV e fa uso della static resource
            
    */
    public static void AggiornamentoAnagrafico(id idCollector) {
        /*CSVString is the string that will contain the body of the flow until it will be saved on an attachment. HeaderToken is just a parameter of the JSON structure of the csv that define in which block is contained the Header structure of the file
        affFields is a string that contain the fields, and is used in the queries 
        accFields is a string that contain the fields, and is used in the queries 
        fruitFields is a string that contain the fields, and is used in the queries 
        */
        string CSVString = '', headerToken = '_____headerAndPositions', affFields, accFields, fruitFields, NomeFile = 'CRABB_AGGIORNAMENTOANAGRAFICO_';
        integer rowsSize = 0;
        dateTime dt = system.now(), dtT;
        /*Flussi collector is the new record that will be stored in the database for the new flow. Attacchment is the file that will be attached to the new flow. It will be a CSV file.*/
        Flussi_collector__c fc = new Flussi_collector__c();
        Attachment att = new Attachment();
        //Is the target collector of the flow
        Collector__c co = new Collector__c();
        //if (Utils.cebCheckFLSPermission('Collector__c', 'Ultimo_Aggiornamento_Angrafico__c', gd).get('ACCESS'))
        //if(Utils.checkFLSPermission('Collector__c', 'Ultimo_Aggiornamento_Angrafico__c').get('ACCESS'))

        co = [
                Select id, name, Ultimo_Aggiornamento_Angrafico__c, createdDate
                from Collector__c
                where id = :idCollector
                WITH SECURITY_ENFORCED
        ];

        //Map used to get the info related
        map<string, sobject> so = new map<string, sobject>();

        //Set used to define how many lottos are present in the CSV FLOW
        set<id> numLotti = new set<id>();//utilizata solo per calcolare il numero di lotti associati al flusso

        //Map that contains the structure of the CSV File. The Structure is saved in a static resource in JSON format
        //iHeader is a sub element of the structure, and define the header of the file. Is a map integer, string, where integer define the column of the column, while the string define the name of the column
        map<string, Map<string, string>> fileMap = setCSVCharatteristics('FlussiCollector_AggiornamentoAnagrafiche_JSON');
        map<integer, string> iHeader = setMapForTheHeader(fileMap, headerToken);

        Map<id, Affidamento__c> affMap;
        Map<id, id> IdServidAff = new Map<id, id>(); //Mappa tra servizio e Affidamento, which is supposed to be 1-1
        list<id> listServOfAff = new List<id>();//utilizzata nelle query
        list<id> listAccOfAff = new List<id>();//utilizzata nelle query
        list<Servizi_Item__c> lFruiServ = new List<Servizi_item__c>();

        /*The flow extract the data in delta (only the data changed from the last flow extracted). 
            So if the Ultimo_aggiornamento_Anagrafico__c is null, we define as a starting date the creation 
            date of the collector, this because there are no affidamenti older than the creation date of the 
            collector. the variable dt is a date time that set the date where has been extracted the flow. 
            The date is wrote on the name of the flow. It will correspond also to the new Ultimo_aggiornamento_Anagrafico__c */
        if (co.Ultimo_Aggiornamento_Angrafico__c == null)co.Ultimo_Aggiornamento_Angrafico__c = co.createdDate;
        NomeFile += co.name + '_' + dt.year();
        //is seted the month with double chars
        if (dt.month() < 10) NomeFile += '0' + dt.month();
        else NomeFile += dt.month();
        //is seted the day with double chars
        if (dt.day() < 10) NomeFile += '0' + dt.day();
        else NomeFile += dt.day();

        //Is written the header line of the flow
        CSVString = startline + getCSVHeader(iHeader);
        affFields = Utils.getSOBJECTFieldsForQuery('Affidamento__c');
        accFields = Utils.getSOBJECTFieldsForQuery('Account');
        dtT = co.Ultimo_Aggiornamento_Angrafico__c;
        co.Ultimo_Aggiornamento_Angrafico__c = dt;
        // inizio nuovo codice 13/04/17 inserimento CheckFLSPermission
/*        if(Utils.checkFLSPermission('Affidamento__c', 'Data_Affidamento__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Data_Termine_Proroga__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c').get('ACCESS'))*/
        if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Termine_Proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('ACCESS')) {
            // prendi affidi
            affMap = new Map<id, Affidamento__c>((List<Affidamento__C>) database.query('Select ' + String.escapeSingleQuotes(affFields) + ' from Affidamento__c where Lotto__r.Agenzia_di_Recupero__c=:idCollector and ( Stato__c = \'In corso\' or lastmodifiedDAte>=:dtT ) order by lastmodifieddate Desc '));
        }
        // inizio nuovo codice 13/04/17 inserimento CheckFLSPermission 
        //Is made a check if there are affidamenti to align, if no the class returns, if the logs are active, than is created a log for info
        if (affMap != null && affMap.keyset().size() == 0) {
            if (TagHelper.getValueBoolean('AreFlowDebugInfoTurnedOn') == true) {
                errorClass.logError('Info.ProcessiFlussiCSVManager.AggiornamentoAngrafico', 'Nella creazione del flusso AggiornamentoAngraficho non sono stati ritrovati affidamenti:' + idCollector);
            }
            return;
        }

        for (Affidamento__c a : affMap.Values()) {
            listAccOfAff.add(a.Flow_Id_Account__c);
            listServOfAff.add(a.Flow_Id_Servizio__c);
            IdServidAff.put(a.Flow_Id_Servizio__c, a.id);
        }

        // inizio nuovo codice 13/04/17 inserimento CheckFLSPermission    
        /* 2 . Prendi Fruitori (tutti i campi) 
            costruzione della query secondo le casisitiche:
           - Fruitori da aggiungere come conseguenza di act modificate : AB
           - Fruitori da aggiungere come conseguenza di servizio modificato: DE
           - Fruitori modificato: AC
        */
        String queryString = 'Select ' + utils.getSOBJECTFieldsForQuery('Servizi_Item__c') ;
        queryString += ' From Servizi_Item__c Where ';
        //Questa condizione recupera tutti i Servizi item (fruitori ) che sono cambiati dall'ultimo allineamento
        queryString += ' (Servizio__c in: listServOfAff and (servizio__r.lastmodifiedDate >=: dtT OR lastmodifiedDate >=: dtT)) ';
        //questa condizione recupare tutti i serrvizi item che sono associati agli account modificati
        queryString += ' Or (Servizio__c in: listServOfAff and Servizio__r.Account__r.id in: listAccOfAff and Servizio__r.Account__r.lastmodifiedDate>=:dtT ) ';

        queryString += ' Order by lastmodifieddate Desc ';
        // inizio nuovo codice 13/04/17 inserimento CheckFLSPermission
        /*if(Utils.checkFLSPermission('Servizi_Item__c', 'Nome__c').get('ACCESS')
            && Utils.checkFLSPermission('Servizi_Item__c', 'Codice__c').get('ACCESS')
            && Utils.checkFLSPermission('Servizi_Item__c', 'Note__c').get('ACCESS')
            && Utils.checkFLSPermission('Servizi_Item__c', 'Id_Esterno__c').get('ACCESS'))*/
        if (Utils.cebCheckObjPermission('Servizi_Item__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Servizi_Item__c', 'Nome__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Servizi_Item__c', 'Codice__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Servizi_Item__c', 'Note__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Servizi_Item__c', 'Id_Esterno__c', gd).get('ACCESS')) {
            lFruiServ = database.query(String.escapeSingleQuotes(queryString));

            if (lFruiServ.size() == 0) {
                if (TagHelper.getValueBoolean('AreFlowDebugInfoTurnedOn') == true) {
                    errorClass.logError('ProcessiFlussiCSVManager.AggiornamentoAngrafico', 'Nella creazione del flusso AggiornamentoAngraficho non sono stati ritrovati dei Fruitori:' + idCollector);
                }
                return;
            }

            System.debug('\n IdServidAff: ' + IdServidAff);
            // 3. Compila dati del file
            for (Servizi_Item__c f : lFruiServ) {
                rowsSize++;
                so.put('Fruitore', f);
                //recupero l'id affidamento dalla mappa tramite l'id servizio, e recupero l'affidamento dalla mappa affMap
                Affidamento__c a = affMap.get(IdServidAff.get(f.Servizio__c));
                System.debug('\n il servizio del Fruitore' + f.servizio__c);
                numLotti.add(a.lotto__c);
                so.put('Affidamento', a);
                CSVString += '"\r\n"' + getCSVNewLine(so, fieldSeparator, iHeader, fileMap);
            }

            CSVString += endFile;
        }
        // fine nuovo codice 13/04/17 inserimento CheckFLSPermission
        /*creazione dei file */
        fc.Collector__c = co.id;
        fc.Lotti_Presenti__c = string.valueof(numLotti.size());
        fc.Numero_Record__c = rowsSize;
        fc.Tipo__c = 'Aggiornamento Anagrafico';
        /*if (Utils.checkFLSPermission('Flussi_collector__c', 'Collector__c').get('CREATE')
            && Utils.checkFLSPermission('Flussi_collector__c', 'Lotti_Presenti__c').get('CREATE')
            && Utils.checkFLSPermission('Flussi_collector__c', 'Numero_Record__c').get('CREATE')
            && Utils.checkFLSPermission('Flussi_collector__c', 'Tipo__c').get('CREATE')
           ) insert fc;*/
        if (Utils.cebCheckObjPermission('Flussi_collector__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Collector__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Lotti_Presenti__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Numero_Record__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Tipo__c', gd).get('CREATE')) {
            insert fc;
        }

        att.parentId = fc.id;
        att.name = NomeFile + '.csv';
        att.body = Blob.valueof(CSVString);
        /*if (Utils.checkFLSPermission('Attachment', 'parentId').get('CREATE')
            && Utils.checkFLSPermission('Attachment', 'name').get('CREATE')
            && Utils.checkFLSPermission('Attachment', 'body').get('CREATE')
            ) insert att;*/
        if (Utils.cebCheckObjPermission('Attachment', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Attachment', 'parentId', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Attachment', 'name', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Attachment', 'body', gd).get('CREATE')) {
            insert att;
        }
        //if (Utils.checkFLSPermission('Collector__c', 'Ultimo_aggiornamento_movimenti__c').get('UPDATE')) update co;
        if (Utils.cebCheckObjPermission('Collector__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Collector__c', 'Ultimo_aggiornamento_movimenti__c', gd).get('UPDATE')) {
            update co;
        }
        return;
    }

    public static void AggiornamentoAffidamento(id idCollector) {
        /*
            CSVString=contiene il body del file CSV che verrà associato al flussi collector
            headerToken= è una chiave per identificare la mappa nella staticResource dove è indicato la posizione e il nome delle colone
            affFields= stringa per fare la query sugli affidamenti
            NomeFile=variabile che contiene il nome finaledel file che verrà creato
            rowsSize= numero di righe nel file
            dt= riporta la data in cui è stato generato il file
            fc= flussi collector che verrà creato e a cui viene allegato il file CSV
            so=mappa stringa SOBject che serve per l'algoritmo che genera la riga del CSV e fa uso della static resource
            
        */
        string CSVString = '', headerToken = '_____headerAndPositions', affFields, NomeFile = 'CRABB_AGGIORNAMENTOREVOCHE_';
        String debugStr = '\n';
        debugStr += '\n idCollector: ' + idCollector;
        integer rowsSize = 0;
        dateTime dt = system.now();
        Flussi_collector__c fc = new Flussi_collector__c();
        map<string, sobject> so = new map<string, sobject>();
        Attachment att = new Attachment();
        set<id> numLotti = new set<id>();//utilizata solo per calcolare il numero di lotti associati al flusso

        map<string, Map<string, string>> fileMap = setCSVCharatteristics('FlussiCollector_AggiornamentoRevoche_JSON');

        map<integer, string> iHeader = setMapForTheHeader(fileMap, headerToken);
        Collector__c co = new Collector__c();
        //if(Utils.checkFLSPermission('Collector__c', 'Ultimo_aggiornamento_revoche__c').get('ACCESS'))
        //if (Utils.cebCheckObjPermission('Collector__c', gd).get('ACCESS')
        //        && Utils.cebCheckFLSPermission('Collector__c', 'Ultimo_aggiornamento_revoche__c', gd).get('ACCESS')) {
        co = [
                Select id, name, Ultimo_aggiornamento_revoche__c, createdDate
                from Collector__c
                where id = :idCollector
                WITH SECURITY_ENFORCED
        ];

        debugStr += '\n Nome Collector: ' + co.name;

        if (co.Ultimo_aggiornamento_revoche__c == null)co.Ultimo_aggiornamento_revoche__c = co.createdDate;
        NomeFile += co.name + '_' + dt.year();
        if (dt.month() < 10) NomeFile += '0' + dt.month();
        else NomeFile += dt.month();

        if (dt.day() < 10) NomeFile += '0' + dt.day();
        else NomeFile += dt.day();

        //CRABB_AGGIORNAMENTOREVOCHE_CODICECOLLECTOR_YYYYMMDD
        CSVString = startline + getCSVHeader(iHeader);//ho aggiunto un appostrofi perche mancava dalla compilamento
        affFields = Utils.getSOBJECTFieldsForQuery('Affidamento__c');
        dateTime dtT = co.Ultimo_aggiornamento_revoche__c;
        /*if(Utils.checkFLSPermission('Affidamento__c', 'Data_Affidamento__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Data_Revoca__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Data_Richiesta_Proroga__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'E_richiesta_una_proroga__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Esito_Lavorazione__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'Giorni_di_proroga__c').get('ACCESS')
            && Utils.checkFLSPermission('Affidamento__c', 'id_Task_associato__c').get('ACCESS'))*/
        if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Revoca__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Richiesta_Proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'E_richiesta_una_proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Esito_Lavorazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Giorni_di_proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c', gd).get('ACCESS')) {
            List<Affidamento__c> aList = database.query('Select ' + String.escapeSingleQuotes(affFields) + ' from Affidamento__c where Lotto__r.Agenzia_di_Recupero__c=:idCollector and Stato__c in(\'Scaduto\',\'Revocato\',\'Paga Parzialmente\',\'Paga Totalmente\' ) and lastmodifiedDate>=:dtT order by lastmodifieddate Desc');

            co.Ultimo_aggiornamento_revoche__c = dt;
            //update co;

            if (aList.size() == 0) {
                errorClass.logError('ProcessiFlussiCSVManager.Aggiornamentoffidamento', 'Nella creazione del flusso AggiornamentoAffidamento non sono stati ritrovati affidamenti:' + idCollector);
                return;
            }
            for (Affidamento__c a : aList) {
                debugStr += '\n Nome affido: ' + a.name;
                rowsSize++;
                numLotti.add(a.lotto__c);
                so.put('Affidamento', a);
                CSVString += '"\r\n"' + getCSVNewLine(so, fieldSeparator, iHeader, fileMap);
            }
        }
        CSVString += endFile;
        /*creazione dei file */
        fc.Collector__c = co.id;
        fc.Lotti_Presenti__c = string.valueof(numLotti.size());
        fc.Numero_Record__c = rowsSize;
        fc.Tipo__c = 'Aggiornamento Revoche';
        /*if (Utils.checkFLSPermission('Flussi_collector__c', 'Collector__c').get('CREATE')
            && Utils.checkFLSPermission('Flussi_collector__c', 'Lotti_Presenti__c').get('CREATE')
            && Utils.checkFLSPermission('Flussi_collector__c', 'Numero_Record__c').get('CREATE')
            && Utils.checkFLSPermission('Flussi_collector__c', 'Tipo__c').get('CREATE')
           ) insert fc;*/
        if (Utils.cebCheckObjPermission('Flussi_collector__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Collector__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Lotti_Presenti__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Numero_Record__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Tipo__c', gd).get('CREATE')) {
            insert fc;
        }
        debugStr += '\n FINE';
        att.parentId = fc.id;
        att.name = NomeFile + '.csv';
        att.body = Blob.valueof(CSVString);
        /*if (Utils.checkFLSPermission('Attachment', 'parentId').get('CREATE')
            && Utils.checkFLSPermission('Attachment', 'name').get('CREATE')
            && Utils.checkFLSPermission('Attachment', 'body').get('CREATE')
            ) insert att;*/
        if (Utils.cebCheckObjPermission('Attachment', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Attachment', 'parentId', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Attachment', 'name', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Attachment', 'body', gd).get('CREATE')) {
            insert att;
        }

        //if (Utils.checkFLSPermission('Collector__c', 'Ultimo_aggiornamento_movimenti__c').get('UPDATE')) update co;
        if (Utils.cebCheckObjPermission('Collector__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Collector__c', 'Ultimo_aggiornamento_movimenti__c', gd).get('UPDATE')) {
            update co;
        }
        System.debug(debugStr);
        return;

    }

    public static void NuovoLottoAffidamento(id idLotto) {
        string debug = '\n NuovoLottoAffidamento() - INPUT: ' + idLotto, CSVString = '', headerToken = '_____headerAndPositions', affFields, fFields, NomeFile = 'CRABB_NUOVOAFFIDAMENTO_';
        integer rowsSize = 0;
        date dt = system.today();
        map<string, sobject> so = new map<string, sobject>();
        Flussi_collector__c fc = new Flussi_collector__c();
        Attachment att = new Attachment();
        List<id> idsFruitori = new List<id>();

        //CODICECOLLECTOR_CODICELOTTO_YYYYMMDD
        map<string, Map<string, string>> fileMap = setCSVCharatteristics('FlussiCollector_NewAffidamenti_JSON');
        map<integer, string> iHeader = setMapForTheHeader(fileMap, headerToken);
        Lotto__c lotto = new Lotto__c();
        /*if(Utils.checkFLSPermission('Lotto__c', 'NuovoAffidamentoProcessed__c').get('ACCESS')
            && Utils.checkFLSPermission('Lotto__c', 'Agenzia_di_Recupero__c').get('ACCESS'))*/
        //if (Utils.cebCheckObjPermission('Lotto__c', gd).get('ACCESS')
        //        && Utils.cebCheckFLSPermission('Lotto__c', 'NuovoAffidamentoProcessed__c', gd).get('ACCESS')
        //        && Utils.cebCheckFLSPermission('Lotto__c', 'Agenzia_di_Recupero__c', gd).get('ACCESS')) {
        lotto = [
                select id, NuovoAffidamentoProcessed__c, Agenzia_di_Recupero__c, Agenzia_di_Recupero__r.name, name,
                        Agenzia_di_Recupero__r.Ultimo_aggiornamento_revoche__c
                from Lotto__c
                where id = :idLotto
                WITH SECURITY_ENFORCED
        ];
        NomeFile += lotto.Agenzia_di_Recupero__r.name + '_' + lotto.name + '_' + dt.year();
        lotto.NuovoAffidamentoProcessed__c = true;

        if (dt.month() < 10) NomeFile += '0' + dt.month();
        else NomeFile += dt.month();

        if (dt.day() < 10) NomeFile += '0' + dt.day();
        else NomeFile += dt.day();

        /*viene popolata la testata del file*/
        CSVString = startline + getCSVHeader(iHeader);//ho aggiunto un appostrofi perche mancava dalla compilamento
        affFields = Utils.getSOBJECTFieldsForQuery('Affidamento__c');
        ffields = Utils.getSOBJECTFieldsForQuery('Servizi_Item__c');
        //ffields=Utils.getSOBJECTFieldsForQuery('Servizio__c');
        Map<id, integer> idAPositionList = new Map<id, integer>();
        Map<id, id> idSListIdA = new Map<id, id>();
        string queryServizi = 'Select ' + ffields + ' From Servizi_Item__c ';
        //string queryServizi='Select ' + ffields + ' From Servizio__c ';
        debug += '\n \n queryServizi: \n ' + queryServizi;
        try {
            // inizio nuovo codice 13/04/17 inserimento CheckFLSPermission
            /*if(Utils.checkFLSPermission('Affidamento__c', 'Data_Affidamento__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_Termine_Proroga__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c').get('ACCESS'))*/
            if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Termine_Proroga__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('ACCESS')) {
                List<Affidamento__c> aList = database.query(String.escapeSingleQuotes('Select ' + affFields + ' from Affidamento__c where Lotto__c=:idLotto and Stato__c=\'In Corso\''));


                if (aList.size() == null) {
                    errorClass.logError('ProcessiFlussiCSVManager.NuovoLottoAffidamento', 'Nella creazione del flusso NuovoAffidamento non sono stati ritrovati affidamenti:' + idLotto);
                    return;
                }


                for (integer i = 0; i < aList.size(); i++) {
                    idSListIdA.put(aList[i].Flow_Id_Servizio__c, aList[i].id);
                    idAPositionList.put(aList[i].id, i);
                }
                debug += 'idSListIdA' + idSListIdA;
                debug += '\n\n idAPositionList:' + idAPositionList;
                idsFruitori.addAll(idSListIdA.keyset());
                debug += '\n\n idsFruitori:' + idsFruitori;
                // inizio nuovo codice 13/04/17 inserimento CheckFLSPermission
                /*if(Utils.checkFLSPermission('Servizi_Item__c', 'Nome__c').get('ACCESS')
                    && Utils.checkFLSPermission('Servizi_Item__c', 'Codice__c').get('ACCESS')
                    && Utils.checkFLSPermission('Servizi_Item__c', 'Note__c').get('ACCESS')
                    && Utils.checkFLSPermission('Servizi_Item__c', 'Id_Esterno__c').get('ACCESS'))*/
                if (Utils.cebCheckObjPermission('Servizi_Item__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Servizi_Item__c', 'Nome__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Servizi_Item__c', 'Codice__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Servizi_Item__c', 'Note__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Servizi_Item__c', 'Id_Esterno__c', gd).get('ACCESS')) {
                    queryServizi += ' where Servizio__c in : idsFruitori ';
                    //queryServizi+=' where Id in : idsFruitori ';
                    List<Servizi_Item__c> siList = database.query(String.escapeSingleQuotes(queryServizi));
                    //List<Servizio__c> siList=database.query(queryServizi);
                    if (siList.size() == 0) {
                        // errorClass.logError('1) ProcessiFlussiCSVManager.NuovoLottoAffidamento','Nella creazione del flusso NuovoAffidamento non sono stati ritrovati Fruitori per idLotto:'+idLotto + '\n \n StackTrace: ' + debug);
                        // return;
                        debug += '\n\n CSVString:' + CSVString + ' --- ' + so ;
                        errorClass.logError('1) ProcessiFlussiCSVManager.NuovoLottoAffidamento', 'Nella creazione del flusso NuovoAffidamento non sono stati ritrovati Fruitori per idLotto:' + idLotto + '\n \n StackTrace: ' + debug);
                        return;
                    }
                    debug += '\n\n siList:' + siList.size();
                    for (Servizi_item__c si : siList)
                    //for(Servizio__c si:siList)
                    {
                        debug += '\n\n siID:' + si.ID;
                        rowsSize++;
                        so.put('Fruitore', si);
                        id idAffido = idSListIdA.get(si.servizio__c);
                        //id idAffido=idSListIdA.get(si.Id);
                        so.put('Affidamento', aList[idAPositionList.get(idAffido)]);
                        CSVString += '"\r\n"' + getCSVNewLine(so, fieldSeparator, iHeader, fileMap);
                    }

                    /*Inserimento dell'ultimo carattere delfile
                    * Liberazione delle mappe e della memoria
                    */
                    CSVString += endFile;
                }
                // fine nuovo codice 13/04/17 inserimento CheckFLSPermission
                /*creazione dei file */
                fc.Collector__c = lotto.Agenzia_di_Recupero__c;
                fc.Lotti_Presenti__c = '1';
                fc.Numero_Record__c = rowsSize;
                fc.Tipo__c = 'NuovoAffidamento';
                /*if (Utils.checkFLSPermission('Flussi_collector__c', 'Collector__c').get('CREATE')
                    && Utils.checkFLSPermission('Flussi_collector__c', 'Lotti_Presenti__c').get('CREATE')
                    && Utils.checkFLSPermission('Flussi_collector__c', 'Numero_Record__c').get('CREATE')
                    && Utils.checkFLSPermission('Flussi_collector__c', 'Tipo__c').get('CREATE')
                   ) insert fc;*/
                if (Utils.cebCheckObjPermission('Flussi_collector__c', gd).get('CREATE')
                        && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Collector__c', gd).get('CREATE')
                        && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Lotti_Presenti__c', gd).get('CREATE')
                        && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Numero_Record__c', gd).get('CREATE')
                        && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Tipo__c', gd).get('CREATE')) {
                    insert fc;
                }
                debug += '\n \n 1) Flusso Coll inserito: \n \n' + fc;
                att.parentId = fc.id;
                att.name = NomeFile + '.csv';
                att.body = Blob.valueof(CSVString);
                /*if (Utils.checkFLSPermission('Attachment', 'parentId').get('CREATE')
                    && Utils.checkFLSPermission('Attachment', 'name').get('CREATE')
                    && Utils.checkFLSPermission('Attachment', 'body').get('CREATE')
                    ) insert att;*/
                if (Utils.cebCheckObjPermission('Attachment', gd).get('CREATE')
                        && Utils.cebCheckFLSPermission('Attachment', 'parentId', gd).get('CREATE')
                        && Utils.cebCheckFLSPermission('Attachment', 'name', gd).get('CREATE')
                        && Utils.cebCheckFLSPermission('Attachment', 'body', gd).get('CREATE')) {
                    insert att;
                }
                debug += '\n \n 2) Attachment inserito: \n \n ' + att.body.toString();
                //if (Utils.checkFLSPermission('Lotto__c', 'NuovoAffidamentoProcessed__c').get('UPDATE')) update lotto;
                if (Utils.cebCheckObjPermission('Lotto__c', gd).get('UPDATE')
                        && Utils.cebCheckFLSPermission('Lotto__c', 'NuovoAffidamentoProcessed__c', gd).get('UPDATE')) {
                    update lotto;
                }
                debug += '\n \n 3) Lotto modificato: \n \n ' + lotto;
                ErrorClass.logError('ESITO: ProcessiFlussiCSVManager - NuovoLottoAffidamento()', '\n STACKTRACE: \n \n **** \n \n ' + debug);
                return;
            }
            // fine nuovo codice 13/04/17 inserimento CheckFLSPermission                
        } catch (QueryException e) {
            ErrorClass.logError('ProcessiFlussiCSVManager.NuovoLottoAffidamento.QueryException', ' *Errore nell\' eseguire la query* \n Dettagli: ' + e.getMessage() + '\n ' + e.getStackTraceString() + '\n\n idServiziList:' + idSListIdA.keyset() + '\n\n queryServiziExecuted:' + queryServizi);
            return;
        } catch (Exception e) {
            ErrorClass.logError('ProcessiFlussiCSVManager.NuovoLottoAffidamento.Exception', ' *Errore: ' + e.getMessage() + '\n ' + e.getStackTraceString());
            return;
        }
    }


    //*** MSALA 20170220 - INIZIO ***//
    //*** Francesco Dessì - #51 Creazione file per flussi collector con più di 1200 record ***//

    public static void CreaCSV_per_Affidamento(id idLotto, String fName) {
        Database.executeBatch(new CreaCsvAffidamentoBatch(idLotto, fName), 1000);
    }

    //*** Francesco Dessì - #51 Creazione file per flussi collector con più di 1200 record ***//
    //*** MSALA 20170220 - FINE ***//


    /*
        Metodo che va a prendere la mappa headerToken all'interno della mappa generata dalla static resource
        e genera una mappa integer string, che serve per poter ciclare le colonne 
    */
    public static map<integer, string> setMapForTheHeader(map<string, Map<string, string>> fileMap, string headerToken) {
        map<integer, string> iName = new map<integer, string>();
        map<string, string> sName = fileMap.get(headerToken);

        for (string s : sName.keyset()) {
            iName.put(integer.valueof(s), sName.get(s));
        }
        return iName;
    }
    /*
        configura le caratteristiche del CSV (separator, new line etc. Dati che sono presenti nel custom setting Tag.
        Inoltre va a recuperare la static resource con nome che viene fornito nella variabile "staticResourceFileName"
        e genera una mappa di mappe che rappresenta la struttura del file e indica dove recuperare i dati che bisogna inserire nel file
    */
    private static map<string, Map<string, string>> setCSVCharatteristics(string staticResourceFileName) {
        map<string, Map<string, string>> fileMap = new map<string, Map<string, string>>();
        startline = tagHelper.getValueText('PFCSVM_startline');
        fieldSeparator = tagHelper.getValueText('PFCSVM_fieldSeparator');
        newline = '"\r\n"';
        endFile = tagHelper.getValueText('PFCSVM_startline');
        List<StaticResource> srList = [
                Select body, name
                from StaticResource
                where Name = :staticResourceFileName
                with SECURITY_ENFORCED
        ];
        try {
            fileMap = (Map<String, Map<String, string>>) JSON.deserialize(srList.get(0).body.toString(), Map<String, Map<String, string>>.class);
        } catch (Exception e) {
            ErrorClass.logError('ProcessiFlussiCSVManager.setCSVCharatteristics.Exception', ' *Errore: ' + e.getMessage() + '\n ' + e.getStackTraceString());
        }

        return fileMap;
    }
    /*
        crea effettivamente la riga di CSV con i dati presenti su DB
        SO=mappa dove sono contenute le informazioni del DB
        fs=field separator, indica con quali caratteri separare i campi
        iHeader= indica le colonne del file
        
    */
    private static string getCSVNewLine(Map<string, sobject> so, string fs, map<integer, string> iHeader, map<string, Map<string, string>> fileMap) {
        string fruitore = 'Fruitore', affidamento = 'Affidamento', movimento = 'Movimento', nooggetto = 'NO_OGGETTO', sobjField, fileColumn, rowString = '';
        map<string, string> objField = new map<string, string>();
        for (integer i = 1; 1 == 1; i++) {
            if (iHeader.get(i) == null) break;
            fileColumn = iHeader.get(i);
            objField = fileMap.get(fileColumn);
            try {
                if (objField.get(nooggetto) != null) {
                    rowString += objField.get(nooggetto) + fs;
                } else if (objField.get(affidamento) != null) {
                    sobjField = objField.get(affidamento);
                    if (so.get(affidamento).get(sobjField) == null) rowString += fs;
                    else rowString += so.get(affidamento).get(sobjField) + fs;
                } else if (objField.get(fruitore) != null) {
                    sobjField = objField.get(fruitore);
                    if (so.get(fruitore).get(sobjField) == null) rowString += fs;
                    else rowString += so.get(fruitore).get(sobjField) + fs;
                } else if (objField.get(movimento) != null) {
                    sobjField = objField.get(movimento);
                    if (so.get(movimento).get(sobjField) == null) rowString += fs;
                    else rowString += so.get(movimento).get(sobjField) + fs;
                }
            } catch (Exception e) {
                throw new ProcessiFlussiCSVManagerException('nooggetto:' + nooggetto + '\n fileColumn:' + fileColumn + '\n xxx:' + fileMap);
            }
        }
        rowString = rowString.substring(0, rowString.length() - fs.length());
        return rowString;
    }
    /*
        Genera l'header del file CSV scorrendo la mappa iHeader
        crea nuove colonne fino a quando l'intero ricercato non è presente nella mappa
        richiede che gli indici delle colonne siano coerenti e crescenti, non ci possono essere bucchi tra le colonne presenti
        se ci sono bucchi il sistema scriverà il file solo per le colonne che partono da 1 e di quelle che sono consecutive
    */
    private static string getCSVHeader(map<integer, string> iHeader) {
        string headerstring = '', fseparator = ProcessiFlussiCSVManager.fieldSeparator;
        integer i = 1;
        headerstring += iHeader.get(i);
        for (i = 2; 1 == 1; i++) {
            if (iHeader.get(i) == null) break;
            headerstring += fseparator + iHeader.get(i);
        }
        return headerstring;
    }
}