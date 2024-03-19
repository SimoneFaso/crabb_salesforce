/**
 * Created by Francesco on 13/12/2018.
 */

global with sharing class CreaCsvAffidamentoBatch implements Database.Batchable<SObject>, Database.Stateful {

    Integer scopeSize = 1000;
    String affidamentoFields;
    String Servizi_ItemFelds;
    String idLotto;
    String fName;
    String fileName;
    Integer fileNumber;
    Lotto__c lotto;
    Flussi_collector__c flussiCollector;
    List<ListOfFields__c> listOfFieldsList;
    String queryServizi;
    Integer rowsSize;

    global CreaCsvAffidamentoBatch(Id idLotto, String fName) {
        this.idLotto = idLotto;
        this.fName = fName;
        this.fileNumber = 1;
        this.flussiCollector = new Flussi_collector__c();
        this.affidamentoFields = Utils.getSOBJECTFieldsForQuery('Affidamento__c');
        this.Servizi_ItemFelds = Utils.getSOBJECTFieldsForQuery('Servizi_Item__c');
        this.listOfFieldsList = [SELECT Field__c, Object__c FROM ListOfFields__c WHERE Name LIKE :fName + '%' AND Show__c = TRUE ORDER BY Name];
        this.queryServizi = 'Select ' + Servizi_ItemFelds + ' From Servizi_Item__c ';
        this.rowsSize = 0;

        if (fName == 'CSVUPD') {
            this.fileName = 'CRABB_AGGIORNAMENTOAFFIDAMENTO_';
        }
        else if (fName == 'CSVDEL')
        {
            this.fileName = 'CRABB_REVOCAAFFIDAMENTO_';
        }
        else {
            this.fileName = 'CRABB_NUOVOAFFIDAMENTO_';
        }

        if(Utils.checkFLSPermission('Lotto__c', 'NuovoAffidamentoProcessed__c').get('ACCESS') && Utils.checkFLSPermission('Lotto__c', 'Agenzia_di_Recupero__c').get('ACCESS'))
        {
            lotto = [SELECT id,
                    NuovoAffidamentoProcessed__c,
                    Agenzia_di_Recupero__c,
                    Agenzia_di_Recupero__r.name,name,
                    Agenzia_di_Recupero__r.Ultimo_aggiornamento_revoche__c
            FROM Lotto__c
            WHERE Id=:idLotto];

            fileName += lotto.Agenzia_di_Recupero__r.name + '_' + lotto.name + '_' + System.now().format('YYYYMMdd');
            lotto.NuovoAffidamentoProcessed__c = true;
        }

        if (Utils.checkFLSPermission('Lotto__c', 'NuovoAffidamentoProcessed__c').get('UPDATE')) {
            update lotto;
        }

        System.debug('CreaCsvAffidamentoBatch - Id Lotto: ' + idLotto);
        //System.debug('CreaCsvAffidamentoBatch - queryServizi: ' + queryServizi);

        flussiCollector.Collector__c = lotto.Agenzia_di_Recupero__c;
        flussiCollector.Lotti_Presenti__c = '1';
        flussiCollector.Numero_Record__c = rowsSize;
        flussiCollector.Tipo__c = 'NuovoAffidamento';

        if (Utils.checkFLSPermission('Flussi_collector__c', 'Collector__c').get('CREATE') && Utils.checkFLSPermission('Flussi_collector__c', 'Lotti_Presenti__c').get('CREATE') && Utils.checkFLSPermission('Flussi_collector__c', 'Numero_Record__c').get('CREATE') && Utils.checkFLSPermission('Flussi_collector__c', 'Tipo__c').get('CREATE')){
            upsert flussiCollector;
            System.debug('CreaCsvAffidamentoBatch - Id Lotto: ' + idLotto + ' - Flussi Collector inserito: ' + flussiCollector);
        }
    }

    global Iterable<SObject> start(Database.BatchableContext param1) {

        String queryLocatorString = '';
        if (Utils.checkFLSPermission('Affidamento__c', 'Data_Affidamento__c').get('ACCESS') && Utils.checkFLSPermission('Affidamento__c', 'Data_Termine_Proroga__c').get('ACCESS') && Utils.checkFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c').get('ACCESS') && Utils.checkFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c').get('ACCESS')) {
            queryLocatorString = 'SELECT ' + affidamentoFields + ' FROM Affidamento__c WHERE Lotto__c=:idLotto AND Stato__c=\'In Corso\'';
            //System.debug('--> CreaCsvAffidamentoBatch queryLocatorString: ' + queryLocatorString);
        }

        return Database.getQueryLocator(queryLocatorString);
    }

    global void execute(Database.BatchableContext param1, List<SObject> scope) {

        //System.debug('--> START LOTTO' + idLotto + ' - FILE ' + fileNumber + ' <--');

        if (scope.size() > scopeSize) {
            ErrorClass.logError('CreaCsvAffidamentoBatch - Id Lotto: ' + idLotto + 'Lo scope scelto è più grande di quello di controllo: ' + scopeSize);
        } else if (scope == null || scope.size() <= 0) {
            errorClass.logError('CreaCsvAffidamentoBatch - Id Lotto: ' + idLotto + 'Nella creazione del flusso NuovoAffidamento non sono stati ritrovati affidamenti');
        } else {

            try{
                String debug = '';
                Map<Id, String> tipoAffidamentoMap = new Map<Id, String>();
                List<String> pratiche = new List<String>();

                for (SObject affidamento : scope) {
                    pratiche.add(((Affidamento__c) affidamento).pratica__c);
                    tipoAffidamentoMap.put(((Affidamento__c) affidamento).pratica__c, ((Affidamento__c) affidamento).Tipo__c);
                }

                //System.debug('--> CreaCsvAffidamentoBatch tipoAffidamentoMap: ' + tipoAffidamentoMap);
                //System.debug('--> CreaCsvAffidamentoBatch pratiche: ' + pratiche);
                //System.debug('--> CreaCsvAffidamentoBatch listOfFieldsList: ' + listOfFieldsList);

                String CsvString = 'Id Lotto, Tipo Affido,';
                Integer index = 0;
                String queryPratField = '';
                String queryMovField = '';

                for (ListOfFields__c lof : listOfFieldsList) {
                    index++;
                    CsvString += lof.Object__c + ' ' + lof.Field__c;
                    if (index < listOfFieldsList.size()) {
                        CsvString += ',';
                    } else {
                        CsvString += '\n';
                    }

                    if (lof.Object__c == 'CSV||Account') {
                        if (queryPratField == '') {
                            queryPratField += 'Account__r.' + lof.Field__c;
                        } else {
                            queryPratField += ',Account__r.' + lof.Field__c;
                        }
                    }
                    if (lof.Object__c == 'CSV||Pratica__c') {
                        if (queryPratField == '') {
                            queryPratField += lof.Field__c;
                        } else {
                            queryPratField += ',' + lof.Field__c;
                        }
                    }
                    if (lof.Object__c == 'CSV||Movimento__c') {
                        if (queryMovField == '') {
                            queryMovField += lof.Field__c;
                        } else {
                            queryMovField += ',' + lof.Field__c;
                        }
                    }
                }

                String query = 'SELECT ' + queryPratField;
                if (queryMovField != '') {
                    query += ',(SELECT ' + queryMovField + ' FROM Movimenti__r )';
                }

                query += ' FROM Pratica__c WHERE Id in :pratiche';
                //System.debug(query);

                if (Utils.checkFLSPermission('Pratica__c', 'Anzianit_Pratica__c').get('ACCESS')
                        && Utils.checkFLSPermission('Pratica__c', 'Check_In_Lavorazione__c').get('ACCESS')
                        && Utils.checkFLSPermission('Pratica__c', 'Data_Esecuzione_Processo_Mensile__c').get('ACCESS')
                        && Utils.checkFLSPermission('Pratica__c', 'Data_Blocco__c').get('ACCESS')
                        && Utils.checkFLSPermission('Pratica__c', 'Data_Chiusura__c').get('ACCESS')
                        && Utils.checkFLSPermission('Pratica__c', 'Dettaglio_Stato__c').get('ACCESS')
                        && Utils.checkFLSPermission('Pratica__c', 'Fascia_di_rischio__c').get('ACCESS')
                        && Utils.checkFLSPermission('Pratica__c', 'Importo_Incasso_Consolidato__c').get('ACCESS')
                        && Utils.checkFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c').get('ACCESS')
                        && Utils.checkFLSPermission('Pratica__c', 'Motivo_Blocco__c').get('ACCESS'))
                {
                    List<Pratica__c> lPrat = database.query(query);
                    Map<Id, Pratica__c> ptMap = new Map<Id, Pratica__c>(lPrat);

                    //System.debug('--> CreaCsvAffidamentoBatch lPrat: ' + lPrat);
                    //System.debug('--> CreaCsvAffidamentoBatch ptMap: ' + ptMap);

                    for (Pratica__c p : lPrat) {
                        //CsvString += '' + idLotto + ',' + mTipoAffido.get(p.Id) + ',';
                        List<Movimento__c> lMov = new List<Movimento__c>();

                        if (!ptMap.get(p.Id).Movimenti__r.isEmpty()) {
                            lMov = ptMap.get(p.id).Movimenti__r;
                        }

                        if (lMov.size() > 0) {
                            for (Movimento__c m : lMov) {
                                CsvString += '"' + idLotto + '","' + tipoAffidamentoMap.get(p.Id) + '",';
                                /*CsvString += p.Account__r.Name+',';
                                CsvString += p.Name+',';
                                CsvString += m.Name+'\n';*/

                                for (ListOfFields__c lof : listOfFieldsList) {
                                    if (lof.Object__c == 'CSV||Account') {
                                        CsvString += '"' + p.Account__r.get(lof.Field__c) + '"';
                                    }
                                    if (lof.Object__c == 'CSV||Pratica__c') {
                                        CsvString += '"' + p.get(lof.Field__c) + '"';
                                    }
                                    if (lof.Object__c == 'CSV||Movimento__c') {
                                        CsvString += '"' + m.get(lof.Field__c) + '"';
                                    }
                                    CsvString += ',';
                                }

                                CsvString = CsvString.substring(0, CsvString.length() - 1);
                                CsvString += '\n';
                            }
                        } else {
                            CsvString += '"' + idLotto + '","' + tipoAffidamentoMap.get(p.Id) + '",';
                            for (ListOfFields__c lof : listOfFieldsList) {
                                if (lof.Object__c == 'CSV||Account') {
                                    CsvString += '"' + p.Account__r.get(lof.Field__c) + '"';
                                }
                                if (lof.Object__c == 'CSV||Pratica__c') {
                                    CsvString += '"' + p.get(lof.Field__c) + '"';
                                }
                                CsvString += ',';
                            }
                            CsvString = CsvString.substring(0, CsvString.length() - 1);
                            CsvString += '\n';
                        }
                        rowsSize++;
                    }

                    debug += '\n\n CsvString: ' + CsvString;
                }

                /*creazione dei file */

                Attachment att = new Attachment();
                att.parentId = flussiCollector.id;
                att.name = fileName + '_' + fileNumber + '.csv';
                att.body = Blob.valueof(CsvString);

                if (Utils.checkFLSPermission('Attachment', 'parentId').get('CREATE') && Utils.checkFLSPermission('Attachment', 'name').get('CREATE')&& Utils.checkFLSPermission('Attachment', 'body').get('CREATE')) {
                    insert att;
                }

                //debug += '\n \n Attachment inserito: \n \n ' + att.body.toString();
                //System.debug('ESITO: CreaCsvAffidamentoBatch \n STACKTRACE: \n \n **** \n \n ' + debug);
                //ErrorClass.logError('ESITO: CreaCsvAffidamentoBatch', '\n STACKTRACE: \n \n **** \n \n ' + debug);
            }
            catch(QueryException e){
                System.debug('CreaCsvAffidamentoBatch - Id Lotto: ' + idLotto + ' - QueryException *Errore nell\' eseguire la query* \n Dettagli: '
                        + e.getMessage() + '\n '
                        + e.getStackTraceString()
                        //+ '\n\n idServiziList:'+idSListIdA.keyset()
                        + '\n\n queryServiziExecuted:'
                        + queryServizi);
                ErrorClass.logError('CreaCsvAffidamentoBatch - Id Lotto: ' + idLotto + ' - *Errore nell\' eseguire la query* \n Dettagli: ' + e.getMessage() + '\n ' + e.getStackTraceString()+'\n\n queryServiziExecuted:'+queryServizi);
            }
            catch(Exception e){
                System.debug('CreaCsvAffidamentoBatch - Id Lotto: ' + idLotto + ' - Exception *Errore \n Dettagli: '
                        + e.getMessage() + '\n '
                        + e.getStackTraceString()
                        //+ '\n\n idServiziList:'+idSListIdA.keyset()
                        + '\n\n queryServiziExecuted: '
                        + queryServizi);
                ErrorClass.logError('CreaCsvAffidamentoBatch - Id Lotto: ' + idLotto + ' - *Errore: ' + e.getMessage() + '\n ' + e.getStackTraceString());
            }
        }

        //System.debug('--> END LOTTO' + idLotto + ' - FILE ' + fileNumber + ' <--');
        fileNumber++;
    }

    global void finish(Database.BatchableContext param1) {
        flussiCollector.Numero_Record__c = rowsSize;
        if (Utils.checkFLSPermission('Flussi_collector__c', 'Collector__c').get('CREATE') && Utils.checkFLSPermission('Flussi_collector__c', 'Lotti_Presenti__c').get('CREATE') && Utils.checkFLSPermission('Flussi_collector__c', 'Numero_Record__c').get('CREATE') && Utils.checkFLSPermission('Flussi_collector__c', 'Tipo__c').get('CREATE')){
            upsert flussiCollector;
        }

        BatchQueue.runBatches();
    }
}