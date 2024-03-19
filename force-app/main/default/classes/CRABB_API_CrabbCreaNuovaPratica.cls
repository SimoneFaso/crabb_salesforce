/* ---------------------------------------------------------------------------------------------------------------------
Name:            CRABB_API_CrabbCreaNuovaPratica.cls
Description:
Test Class:      TestCRABB_API_CrabbCreaNuovaPratica.cl
Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
27-Mar-2020  0.1      M. Sala                         First Version
08-Sep-2021  0.2      C. Sanna                        Replaced getRecordTypeInfosByName() with
                                                      getRecordTypeInfosByDeveloperName()
13-Sep-2022  0.3      R.Kurti                         Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/

@RestResource(UrlMapping='/CrabbCreaNuovaPratica/*')
global with sharing class CRABB_API_CrabbCreaNuovaPratica {
    @HttpPost
    global static CRABB_API_Class.CrabbCreaNuovaPraticaOutput doPost(CRABB_API_Class.CrabbCreaNuovaPraticaInput pi) {
        /*List<ServicePaymentsMappingField__mdt> lMappingFields = [SELECT ObjectType__c,ObjectField__c,PayloadField__c
        FROM ServicePaymentsMappingField__mdt where isTest__c = false];
        Map<String,Map<String,String>> mMappingObjects = new Map<String,Map<String,String>>();
        for(ServicePaymentsMappingField__mdt mapping : lMappingFields)
        {
            Map<String,String> mMappingFields = new Map<String,String>();
            mMappingFields.put(mapping.PayloadField__c,mapping.ObjectField__c);
            mMappingObjects.put(mapping.ObjectType__c,mMappingFields);
        }*/
        Map<String, Map<String, String>> mMappingObjects = CRABB_API_Class.getPayloadMapping();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        CRABB_API_Class.CrabbCreaNuovaPraticaOutput out = new CRABB_API_Class.CrabbCreaNuovaPraticaOutput();
        out.ServizioIdSFDC = 'NA';
        out.PraticaCodeSFDC = 'NA';
        out.MovimentoIdSFDC = 'NA';
        out.AccountIdSFDC = 'NA';
        String accountId = pi.IdAccountSFDC;
        String accountExtKey = pi.AccountExternalKey;
        List<Account> lAcc;

        if (accountId != null && accountId != '') {
            lAcc = [SELECT Id, Name, Phone, Website FROM Account WHERE Id = :accountId WITH SECURITY_ENFORCED ];
        } else if (accountExtKey != null && accountExtKey != '') {
            Map<String, String> mFields = mMappingObjects.get('Account');
            String ExtKeyFields = mFields.get('AccountExternalKey');
            String accQuery = 'SELECT Id, Name, Phone, Website FROM Account WHERE ' + String.escapeSingleQuotes(ExtKeyFields) + ' = \'' + String.escapeSingleQuotes(accountExtKey) + '\'';
            lAcc = Database.query(accQuery);

        } else {
            out.Esito = 'KO';
            out.lErrors = new List<CRABB_API_Class.Error>();
            CRABB_API_Class.Error e = new CRABB_API_Class.Error();
            e.Code = 'CRABB-001';
            e.Description = 'Manca un Id con cui recuperare il Cliente';
            out.lErrors.add(e);
            return out;
        }

        if (lAcc.size() > 0) {
            Map<String, List<String>> fieldObjectToCheck = new Map<String, List<String>>();
            fieldObjectToCheck.put('Pratica__c', new List<String>{
                    'Servizio_Fornitura__c', 'Account__c'
            });
            fieldObjectToCheck.put('Servizio__c', new List<String>{
                    'RecordTypeId', 'Id_Esterno__c', 'Account__c', 'Nome__c', 'Stato__c'
            });
            fieldObjectToCheck.put('Movimento__c', new List<String>{
                    'RecordTypeId', 'Account__c', 'Pratica__c', 'Servizio_Fornitura__c'
                    , 'IdentificativoFatturaExt__c', 'Data_Emissione__c', 'Data_Integrazione__c', 'Importo__c', 'Residuo__c', 'Sollecitabile__c'
                    , 'Data_Scadenza__c', 'Tipo_Scadenza__c', 'Stato_Pratiica_Picklist__c'
            });
            String errorFls = CRABB_API_Class.checkFLSPraticaServizioMovimento(fieldObjectToCheck);
            if (pi.Serv != null && (SObjectType.Servizio__c.getRecordTypeInfosByDeveloperName().get(pi.Serv.RecordType) == null ||
                    (SObjectType.Servizio__c.getRecordTypeInfosByDeveloperName().get(pi.Serv.RecordType) != null
                            && !SObjectType.Servizio__c.getRecordTypeInfosByDeveloperName().get(pi.Serv.RecordType).isAvailable()))) {

                errorFls += 'Record type: ' + pi.Serv.RecordType + ' non disponibile';
            }
            if (String.isNotBlank(errorFls)) {
                out.Esito = 'KO';
                out.lErrors = new List<CRABB_API_Class.Error>();
                CRABB_API_Class.Error e = new CRABB_API_Class.Error();
                e.Code = 'CRABB-004';
                e.Description = errorFls;
                out.lErrors.add(e);
                return out;
            }
            if (lAcc.size() > 1) {
                out.Esito = 'KO';
                out.lErrors = new List<CRABB_API_Class.Error>();
                CRABB_API_Class.Error e = new CRABB_API_Class.Error();
                e.Code = 'CRABB-003';
                e.Description = 'La chiave esterna è presente su più Clienti';
                out.lErrors.add(e);
                return out;
            } else {
                accountId = lAcc[0].Id;
                out.AccountIdSFDC = accountId;

                if (pi.Serv != null) {
                    Servizio__c servizio = new Servizio__c();

                    servizio.RecordTypeId = SObjectType.Servizio__c.getRecordTypeInfosByDeveloperName().get(pi.Serv.RecordType).getRecordTypeId();

                    servizio.Id_Esterno__c = pi.Serv.ServExternalKey;
                    servizio.Account__c = accountId;
                    servizio.Nome__c = pi.Serv.Name;
                    servizio.Stato__c = 'ATTIVO';

                    servizio = (Servizio__c) CRABB_API_Class.setPayloadField('CRABB_DEV__Servizio__c', mMappingObjects, pi.Serv.lPL, servizio);

                    //servizio.Data_Fine_Contratto__c = Date.valueOf(pi.Serv.);
                    //servizio.Data_Inizio_Contratto__c = Date.valueOf(pi.Serv.);
                    //servizio.CRABB_DEV__Metodo_di_Pagamento__c = 'CARTA DI CREDITO';
                    //servizio.CRABB_DEV__Id_SoftwareHouse__c = sp.rentId;
                    //servizio.CRABB_DEV__POD__c = sp.vehicleType;

                    //insert servizio;
                    Database.SaveResult srServ = Database.insert(servizio);
                    String servId = srServ.getId();

                    //create pratica sobject
                    Pratica__c p = new Pratica__c(Account__c = accountId, Servizio_Fornitura__c = servId);
                    Database.SaveResult srPrat = Database.insert(p);
                    String pratId = srPrat.getId();

                    if (pi.lMov != null && pi.lMov.size() > 0) {
                        List<Movimento__c> lMov = new List<Movimento__c>();

                        for (CRABB_API_Class.CrabbMovimento mov : pi.lMov) {
                            Movimento__c m = new Movimento__c();
                            m.RecordTypeId = SObjectType.Movimento__c.getRecordTypeInfosByDeveloperName().get(mov.RecordType).getRecordTypeId();
                            m.Account__c = accountId;
                            m.Pratica__c = pratId;
                            m.Servizio_Fornitura__c = servId;
                            m.IdentificativoFatturaExt__c = mov.MovExternalKey;
                            m.Data_Emissione__c = mov.DataEmissione;
                            m.Data_Integrazione__c = System.today();
                            m.Importo__c = mov.Importo;
                            m.Residuo__c = mov.Residuo;
                            m.Sollecitabile__c = mov.Sollecitabile;
                            m.Data_Scadenza__c = mov.DataScadenza;
                            m.Tipo_Scadenza__c = 'Scaduto';
                            m.Stato_Pratiica_Picklist__c = 'Da Elaborare';
                            m = (Movimento__c) CRABB_API_Class.setPayloadField('CRABB_DEV__Movimento__c', mMappingObjects, mov.lPL, m);
                            lMov.add(m);
                        }

                        if (lMov.size() > 0) {
                            Database.SaveResult[] srMov = Database.insert(lMov);
                            for (Database.SaveResult sr : srMov) {
                                if (out.MovimentoIdSFDC == 'NA') {
                                    out.MovimentoIdSFDC = sr.getId();
                                } else {
                                    out.MovimentoIdSFDC += ',' + sr.getId();
                                }

                            }
                        }
                    }

                    out.ServizioIdSFDC = servId;
                    out.PraticaCodeSFDC = pratId;
                    out.Esito = 'OK';
                } else {
                    out.Esito = 'KO';
                    out.lErrors = new List<CRABB_API_Class.Error>();
                    CRABB_API_Class.Error e = new CRABB_API_Class.Error();
                    e.Code = 'CRABB-005';
                    e.Description = 'Il servizio non è valorizzato';
                    out.lErrors.add(e);
                    return out;
                }
            }

        } else {
            out.Esito = 'KO';
            out.lErrors = new List<CRABB_API_Class.Error>();
            CRABB_API_Class.Error e = new CRABB_API_Class.Error();
            e.Code = 'CRABB-002';
            e.Description = 'Id SFDC non presente a sistema';
            out.lErrors.add(e);
        }

        return out;
    }

}