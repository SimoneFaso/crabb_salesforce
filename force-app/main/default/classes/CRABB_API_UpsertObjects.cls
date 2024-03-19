/* ---------------------------------------------------------------------------------------------------------------------
Name:            CRABB_API_UpsertObjects.cls
Description:
Test class:

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
11-Dec-2020  0.1      S.Salaris                       First Version
13-Sep-2022  0.3      R.Kurti & C.Sanna               Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/

@RestResource(urlMapping='/CRABB_API_UpsertObjects/*')
global with sharing class CRABB_API_UpsertObjects {

    public static List<CRABB_DEV__Servizio__c> serv_toUpsert = new List<CRABB_DEV__Servizio__c>();
    public static List<CRABB_DEV__Movimento__c> mov_toUpsert = new List<CRABB_DEV__Movimento__c>();
    public static List<CRABB_DEV__Pratica__c> pra_toUpsert = new List<CRABB_DEV__Pratica__c>();
    public static Map<String,Map<String,String>> mMappingObjects = CRABB_API_Class.getPayloadMapping();

    //contains, for each input, all transactions
    public static List<List<Movimento__c>> movCollection = new List<List<Movimento__c>>();


    @HttpPost
    global static List<CRABB_API_Class.CrabbOutput> doPost(List<CRABB_API_Class.CrabbInput> piList) {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<CRABB_API_Class.CrabbOutput> outList = new List<CRABB_API_Class.CrabbOutput>();

        List<String> accIdList = new List<String>();
        List<String> accExtIdList = new List<String>();
        List<String> servIdList = new List<String>();
        List<String> servExtIdList = new List<String>();
        List<String> movIdList = new List<String>();
        List<String> movExtIdList = new List<String>();

        //contains, for every input, the related account list
        Map<CRABB_API_Class.CrabbInput, List<Account>> mapPiAccList = new Map<CRABB_API_Class.CrabbInput, List<Account>>();

        //contains Account record for every Account SFid
        Map<String, Account> mapAccId = new Map<String, Account>();

        //contains Account record for every Account externalId
        Map<String, List<Account>> mapAccExtId = new Map<String, List<Account>>();

        //contains Service records for each externalId and SalesforceId
        Map<String, CRABB_DEV__Servizio__c> mapServ = new Map<String, CRABB_DEV__Servizio__c>();

        //contains Transaction records for each externalId and SalesforceId
        Map<String, CRABB_DEV__Movimento__c> mapMov = new Map<String, CRABB_DEV__Movimento__c>();

        //contains, for each Service SFId/extId, the related dossier
        Map<String, List<CRABB_DEV__Pratica__c>> mapServPra = new Map<String, List<CRABB_DEV__Pratica__c>>();

        //contains updatable services
        Map<String, CRABB_DEV__Servizio__c> mapUpdatableServ = new Map<String, CRABB_DEV__Servizio__c>();




        //check salesforce id and external id for accounts, services and transactions
        for (CRABB_API_Class.CrabbInput pi : piList) {

            if(String.isNotBlank(pi.IdAccountSFDC)) {
                accIdList.add(pi.IdAccountSFDC);
            } else if(String.isNotBlank(pi.AccountExternalKey)) {
                accExtIdList.add(pi.AccountExternalKey);
            }

            //we check if the service is not null before the population of the services list
            if(pi.Serv != null) {
                if(String.isNotBlank(pi.Serv.IdServSFDC)) {
                    servIdList.add(pi.Serv.IdServSFDC);
                } else if(String.isNotBlank(pi.Serv.ServExternalKey)) {
                    servExtIdList.add(pi.Serv.ServExternalKey);
                }
            }

            //we check if the transaction list is not null before the population of the transactions list
            if(pi.lMov != null) {
                for (CRABB_API_Class.CrabbMovimento m : pi.lMov) {
                    if(String.isNotBlank(m.IdMovSFDC)) {
                        movIdList.add(m.IdMovSFDC);
                    } else if(String.isNotBlank(m.MovExternalKey)) {
                        movExtIdList.add(m.MovExternalKey);
                    }
                }
            }

        }
        Map<String,String> mFields = mMappingObjects.get('Account');
        String ExtKeyFields = String.escapeSingleQuotes(mFields.get('AccountExternalKey'));

        //get all requested accounts
        String accQuery = 'SELECT Id, Name, Phone, Website, '+ ExtKeyFields +' FROM Account WHERE (' + ExtKeyFields + ' IN :accExtIdList OR Id IN :accIdList) WITH SECURITY_ENFORCED';
        List<Account> accList = Database.query(accQuery);

        //get all requested services with related dossiers
        List<String> statiChiusura = Utils.getStatusList('CRABB_DEV__stati_chiusura__c');
        String servQuery = 'SELECT id, CRABB_DEV__Id_Esterno__c,(select id from CRABB_DEV__Pratiche__r WHERE CRABB_DEV__Stato__c not in :statiChiusura) FROM CRABB_DEV__Servizio__c WHERE ((Id IN :servIdList) OR (CRABB_DEV__Id_Esterno__c IN :servExtIdList))' +
                ' AND ((CRABB_DEV__Account__r.id IN :accList) OR (CRABB_DEV__Account__r.'+ ExtKeyFields +' IN :accExtIdList)) WITH SECURITY_ENFORCED';
        List<CRABB_DEV__Servizio__c> servList = Database.query(String.escapeSingleQuotes(servQuery));

        //get all transactions
        String movQuery = 'SELECT Id, CRABB_DEV__Id_Movimento_Ext__c FROM CRABB_DEV__Movimento__c WHERE ((Id IN :movIdList) OR (CRABB_DEV__Id_Movimento_Ext__c IN :movExtIdList))' +
                ' AND ((CRABB_DEV__Account__r.id IN :accList) OR (CRABB_DEV__Account__r.'+ ExtKeyFields +' IN :accExtIdList)) WITH SECURITY_ENFORCED';
        List<CRABB_DEV__Movimento__c> movList = Database.query(String.escapeSingleQuotes(movQuery));

        for(Account acc : accList) {
            //get account for each SFid
            mapAccId.put(acc.Id, acc);
            String extId = (String)acc.get(ExtKeyFields);
            if(String.isNotBlank(extId)) {
                List<Account> accs = new List<Account>();
                if(mapAccExtId.containsKey(extId)) {
                    accs = mapAccExtId.get(extId);
                }
                accs.add(acc);
                //get all accounts with the same extId
                mapAccExtId.put(extId, accs);
            }
        }

        for(CRABB_DEV__Servizio__c s : servList) {
            mapServ.put(s.Id, s);
            if(String.isNotBlank(s.CRABB_DEV__Id_Esterno__c)) {
                mapServ.put(s.CRABB_DEV__Id_Esterno__c, s);
            }

            //we already have the Services, so we can use the complete key (SFid|extId)
            mapServPra.put(s.Id+'|'+s.CRABB_DEV__Id_Esterno__c, s.Pratiche__r);
        }

        for(CRABB_DEV__Movimento__c m : movList) {
            mapMov.put(m.Id, m);
            if(String.isNotBlank(m.CRABB_DEV__Id_Movimento_Ext__c)) {
                mapMov.put(m.CRABB_DEV__Id_Movimento_Ext__c, m);
            }
        }

        Map<String , List<String>> fieldObjectToCheck = new Map<String, List<String>>();
        fieldObjectToCheck.put('Pratica__c' , new List<String>{'Servizio_Fornitura__c' , 'Account__c'});
        fieldObjectToCheck.put('Servizio__c' , new List<String>{'RecordTypeId','Id_Esterno__c' ,'Account__c' ,'Nome__c' , 'Stato__c'});
        fieldObjectToCheck.put('Movimento__c' , new List<String>{'RecordTypeId','Account__c','Pratica__c','Servizio_Fornitura__c'
                , 'IdentificativoFatturaExt__c' , 'Data_Emissione__c' , 'Data_Integrazione__c' , 'Importo__c' , 'Residuo__c','Sollecitabile__c'
                ,'Data_Scadenza__c' , 'Tipo_Scadenza__c' , 'Stato_Pratiica_Picklist__c'});
        String errorFls = CRABB_API_Class.checkFLSPraticaServizioMovimento(fieldObjectToCheck);

        for (CRABB_API_Class.CrabbInput pi : piList) {
            Account accInput;
            List<Movimento__c> movToUpsertList = new List<Movimento__c>();
            CRABB_API_Class.CrabbOutput outputRes = new CRABB_API_Class.CrabbOutput();

            if(String.isNotBlank(pi.IdAccountSFDC)) {
                if(mapAccId.containsKey(pi.IdAccountSFDC)) {
                    accInput = mapAccId.get(pi.IdAccountSFDC);
                } else {
                    outputRes = errorHandler(outputRes, 'CRABB-002', 'Id SFDC non presente a sistema');
                    outList.add(outputRes);
                    movCollection.add(movToUpsertList);

                    continue;
                }
            } else if(String.isNotBlank(pi.AccountExternalKey)) {
                List<Account> accInputList = new List<Account>();
                if(mapAccExtId.containsKey(pi.AccountExternalKey)) {
                    accInputList = mapAccExtId.get(pi.AccountExternalKey);
                } else {
                    outputRes = errorHandler(outputRes, 'CRABB-007', 'Id SFDC ed External Id non presenti a sistema');
                    outList.add(outputRes);
                    movCollection.add(movToUpsertList);
                    continue;
                }

                //duplicated account in input
                if(accInputList.size() > 1) {
                    outputRes = errorHandler(outputRes, 'CRABB-003', 'La chiave esterna è presente su più Clienti');
                    outList.add(outputRes);
                    movCollection.add(movToUpsertList);
                    continue;
                }

                accInput = accInputList.get(0);


            } else {
                //no account in input
                outputRes = errorHandler(outputRes, 'CRABB-006', 'Nessun account presente nella richiesta');
                outList.add(outputRes);
                movCollection.add(movToUpsertList);
                continue;
            }

            // ###################################################################################### the output list's population starts here ###########################################################################################
            if(pi.Serv != null && (sObjectType.Servizio__c.getRecordTypeInfosByName().get(pi.Serv.RecordType) == null ||
                    ( sObjectType.Servizio__c.getRecordTypeInfosByName().get(pi.Serv.RecordType) != null
                            && !sObjectType.Servizio__c.getRecordTypeInfosByName().get(pi.Serv.RecordType).isAvailable()))
                    ) {
                errorFls+= 'Record type '+pi.Serv.RecordType + ' non disponibile';
            }

            if( String.isNotBlank( errorFls)){
                outputRes = errorHandler(outputRes, 'CRABB-004', errorFls);
                outList.add(outputRes);
                movCollection.add(movToUpsertList);
                continue;
            }

            outputRes.AccountIdSFDC = accInput.Id;
            outputRes.Esito = 'OK';

            if (pi.Serv != null) {
                Servizio__c servizio = new Servizio__c();

                if(String.isNotBlank(pi.Serv.IdServSFDC) && mapServ.containsKey(pi.Serv.IdServSFDC)) {
                    if(pi.Serv.UpdServizio) {
                        generateService(mapServ.get(pi.Serv.IdServSFDC), pi, accInput.Id);
                        mapUpdatableServ.put(pi.Serv.IdServSFDC, mapServ.get(pi.Serv.IdServSFDC));
                    }
                    outputRes.ServizioIdSFDC = mapServ.get(pi.Serv.IdServSFDC).Id;

                } else if (String.isNotBlank(pi.Serv.ServExternalKey) && mapServ.containsKey(pi.Serv.ServExternalKey)) {
                    if(pi.Serv.UpdServizio) {
                        generateService(mapServ.get(pi.Serv.ServExternalKey), pi, accInput.Id);
                        mapUpdatableServ.put(pi.Serv.ServExternalKey, mapServ.get(pi.Serv.ServExternalKey));
                    }
                    outputRes.ServizioIdSFDC = mapServ.get(pi.Serv.ServExternalKey).Id;

                } else {
                    generateService(servizio, pi, accInput.Id);
                    outputRes.ServizioIdSFDC = null;
                }

                //we check if the transaction list "lmov" is not null
                if(pi.lMov != null) {

                    // building a collection of "partial" transaction lists, one list for each input
                    // each transaction has dossierId = null and serviceId = null
                    for(CRABB_API_Class.CrabbMovimento mov : pi.lMov) {

                        //we check if every transaction in the transaction list has a valid record type
                        if((sObjectType.Movimento__c.getRecordTypeInfosByName().get(mov.RecordType) == null ||
                                ( sObjectType.Movimento__c.getRecordTypeInfosByName().get(mov.RecordType) != null
                                        && !sObjectType.Movimento__c.getRecordTypeInfosByName().get(mov.RecordType).isAvailable()))
                                ) {
                            errorFls+= 'Record type '+mov.RecordType + ' non disponibile';
                        }
                        if(String.isBlank(errorFls)) {
                            Movimento__c m = new Movimento__c();

                            if(String.isNotBlank(mov.IdMovSFDC) && mapMov.containsKey(mov.IdMovSFDC)) {
                                m = mapMov.get(mov.IdMovSFDC);
                                if(mov.UpdMovimento) {
                                    m = generateTransaction(mov, m, accInput.Id);
                                }
                            } else if (String.isNotBlank(mov.MovExternalKey) && mapMov.containsKey(mov.MovExternalKey)){
                                m = mapMov.get(mov.MovExternalKey);
                                if(mov.UpdMovimento) {
                                    m = generateTransaction(mov, m, accInput.Id);
                                }
                            } else {
                                //mov.UpdMovimento = true; 11/01/2021
                                mov.UpdMovimento = false;
                                m = generateTransaction(mov, m, accInput.Id);
                            }
                            movToUpsertList.add(m);
                        } else {
                            outputRes = errorHandler(outputRes, 'CRABB-008', errorFls);
                            continue;
                        }
                    }
                    movCollection.add(movToUpsertList);

                } else {
                    //outputRes = errorHandler(outputRes, 'CRABB-008', 'La lista di movimenti non è valorizzata');
                    outList.add(outputRes);
                    movCollection.add(movToUpsertList);
                    continue;
                }

                //we add every output in the for loop to the output list
                outList.add(outputRes);

            } else {
                outputRes = errorHandler(outputRes, 'CRABB-005', 'Il servizio non è valorizzato');
                outList.add(outputRes);
                movCollection.add(movToUpsertList);
                continue;
            }


        }

        //services insertion, dossiers creation and outputs recalculation
        List<Database.upsertResult> servResults = Database.upsert(serv_toUpsert,false);
        Integer cont = 0;
        for (CRABB_API_Class.CrabbOutput outItem : outList) {
            if(outItem.Esito != 'KO') {
                //if there is not any service we create a dossier
                if(String.isBlank(outItem.ServizioIdSFDC)) {
                    String servId = servResults.get(cont).getId();
                    outItem.ServizioIdSFDC = servId;
                    outItem.PraticaCodeSFDC = null;
                    Pratica__c p = new Pratica__c(Account__c = outItem.AccountIdSFDC, Servizio_Fornitura__c = servId);
                    pra_toUpsert.add(p);
                    cont++;
                } else { // if there is a service, we check if there is a related open dossier, otherwise we create it
                    if(mapServ.containsKey(outItem.ServizioIdSFDC)) {
                        Servizio__c s = mapServ.get(outItem.ServizioIdSFDC);
                        List<Pratica__c> prList = mapServPra.get(s.Id+'|'+s.CRABB_DEV__Id_Esterno__c);
                        if(prList.size() > 0) {
                            outItem.PraticaCodeSFDC = prList.get(0).Id;
                        } else {
                            outItem.PraticaCodeSFDC = null;
                            Pratica__c p = new Pratica__c(Account__c = outItem.AccountIdSFDC, Servizio_Fornitura__c = s.Id);
                            pra_toUpsert.add(p);
                        }
                    }
                    if(mapUpdatableServ.containsKey(outItem.ServizioIdSFDC)) {
                        cont++;
                    }
                }
            }
        }

        //dossiers insertion and outputs recalculation
        List<Database.upsertResult> praResults = Database.upsert(pra_toUpsert,false);
        cont = 0;
        Integer contCollection = 0;
        for (CRABB_API_Class.CrabbOutput outItem : outList) {
            if(outItem.Esito != 'KO') {
                if(String.isBlank(outItem.PraticaCodeSFDC)) {
                    String praId = praResults.get(cont).getId();
                    outItem.PraticaCodeSFDC = praId;
                    cont++;
                }
                //preparing/completing transactions
                for(Movimento__c m : movCollection.get(contCollection)) {
                    m.Pratica__c = outItem.PraticaCodeSFDC;
                    m.Servizio_Fornitura__c = outItem.ServizioIdSFDC;
                }
            }
            contCollection++;
        }

        //transactions insertion and outputs recalculation
        for (List<Movimento__c> lm : movCollection) {
            mov_toUpsert.addall(lm);
        }
        System.debug('############# lista mov'+ mov_toUpsert);
        List<Database.upsertResult> movResults = Database.upsert(mov_toUpsert,false);
        System.debug('############# lista mov result'+ movResults);

        Integer contMov = 0;
        Integer contOutput = 0;
        String MovimentoIdSFDC;
        String movId;

        //population of transaction ids for each ouput
        for (List<Movimento__c> lm : movCollection) {
            MovimentoIdSFDC = '';
            for(Movimento__c m : lm) {
                movId = String.isBlank(m.Id) ? movResults.get(contMov).getId() : m.Id;
                contMov++;

                if(String.isNotBlank(MovimentoIdSFDC)){
                    MovimentoIdSFDC+= ','+movId;
                } else {
                    MovimentoIdSFDC = movId;
                }
            }
            outList.get(contOutput).MovimentoIdSFDC = MovimentoIdSFDC;

            contOutput++;

        }


        return outList;

    }


    public static void generateService(Servizio__c servizio, CRABB_API_Class.CrabbInput pi, String accId) {

        servizio.recordTypeId = sObjectType.Servizio__c.getRecordTypeInfosByName().get(pi.Serv.RecordType).getRecordTypeId();

        //if it's an update and not an insert, we don't set the external Id
        if(String.isNotBlank(pi.Serv.ServExternalKey)) {
            servizio.Id_Esterno__c = pi.Serv.ServExternalKey;
        }
        servizio.Account__c = accId;
        servizio.Nome__c = pi.Serv.Name;
        servizio.Stato__c = 'ATTIVO';

        servizio = (Servizio__c)CRABB_API_Class.setPayloadField('CRABB_DEV__Servizio__c' , mMappingObjects , pi.Serv.lPL ,servizio );

        serv_toUpsert.add(servizio);

    }

    public static Movimento__c generateTransaction (CRABB_API_Class.CrabbMovimento mov, Movimento__c m, String accId) {

        m.recordTypeId = sObjectType.Movimento__c.getRecordTypeInfosByName().get(mov.RecordType).getRecordTypeId();
        List<grace_period__mdt> delay = [SELECT CRABB_DEV__Days__c FROM CRABB_DEV__grace_period__mdt where DeveloperName='Delay' WITH SECURITY_ENFORCED ];
        Date dGracePeriod = Date.today().addDays(-Integer.valueOf(delay.get(0).Days__c));

        //if it's an update and not an insert, we don't set the account Id to the transaction
        System.debug('################################################  updmovimento' + mov.UpdMovimento);

        if(!mov.UpdMovimento) {
            m.Account__c = accId;
            System.debug('################################################ account id' + accId);
        }

        m.Pratica__c = null;
        m.Servizio_Fornitura__c = null;

        //if it's an update and not an insert, we don't set the external Id
        if(String.isNotBlank(mov.MovExternalKey)) {
            m.IdentificativoFatturaExt__c = mov.MovExternalKey;
        }
        m.Data_Emissione__c = mov.DataEmissione;
        m.Data_Integrazione__c = System.today();
        m.Importo__c = mov.Importo;
        m.Residuo__c = mov.Residuo;
        m.Sollecitabile__c = mov.Sollecitabile;
        m.Data_Scadenza__c = mov.DataScadenza;
        if(m.Data_Scadenza__c < dGracePeriod)
            m.Tipo_Scadenza__c = 'Scaduto';
        else
            m.Tipo_Scadenza__c = 'In Scadenza';
        m.Stato_Pratiica_Picklist__c = 'Da Elaborare';
        m = (Movimento__c)CRABB_API_Class.setPayloadField('CRABB_DEV__Movimento__c' , mMappingObjects , mov.lPL ,m );
        System.debug('############'+ m);
        return m;

    }

    public static CRABB_API_Class.CrabbOutput errorHandler(CRABB_API_Class.CrabbOutput outputRes, String errorCode, String description) {
        outputRes.Esito = 'KO';
        outputRes.lErrors = new List<CRABB_API_Class.Error>();
        CRABB_API_Class.Error e = new CRABB_API_Class.Error();
        e.Code = errorCode;
        e.Description = description;
        outputRes.lErrors.add(e);

        return outputRes;
    }


}