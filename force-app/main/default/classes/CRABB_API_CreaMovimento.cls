/* ---------------------------------------------------------------------------------------------------------------------
Name:            CRABB_API_CreaMovimento.cls
Description:
Test class:

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
07-Apr-2020  0.1      M.Sala               First Version
16-Sep-2022  0.3      C.Sanna & R.Kurti    Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/
@RestResource(urlMapping='/CrabbCreaMovimento/*')
global with sharing class CRABB_API_CreaMovimento
{
    @HttpPost
    global static CRABB_API_Class.CrabbCreaMovimentoOutput doPost(CRABB_API_Class.CrabbCreaMovimentoInput mi)
    {

        CRABB_API_Class.CrabbCreaMovimentoOutput out = new CRABB_API_Class.CrabbCreaMovimentoOutput();
        try {
            Map<String, Map<String, String>> mMappingObjects = CRABB_API_Class.getPayloadMapping();
            out.ServizioIdSFDC = 'NA';
            out.PraticaCodeSFDC = 'NA';
            out.MovimentoIdSFDC = 'NA';
            out.AccountIdSFDC = 'NA';

            Boolean bPrat = false;

            String accountId = mi.IdAccountSFDC;
            String accountExtKey = mi.AccountExternalKey;
            String ServId = mi.IdServSFDC;
            String ServExternalKey = mi.ServExternalKey;
            String pratId = mi.IdPratSFDC;
            String MovExternalKey = mi.mov.MovExternalKey;

            List<Pratica__c> lPrat = new List<Pratica__c>();

            if (pratId != null && pratId != '') {
                lPrat = [SELECT Id,Account__c,Servizio_Fornitura__c FROM Pratica__c WHERE Id = :pratId WITH SECURITY_ENFORCED ];
                if (lPrat.size() > 0) {
                    accountId = lPrat[0].Account__c;
                    ServId = lPrat[0].Servizio_Fornitura__c;
                    pratId = lPrat[0].Id;
                    bPrat = true;

                }
            }

            if (!bPrat && accountId != null && accountId != '' && ServId != null && ServId != '') {
                List<Movimento__c> lMov = [
                        SELECT Account__c,Pratica__c,Servizio_Fornitura__c
                        FROM Movimento__c
                        WHERE Account__c = :accountId
                        AND Servizio_Fornitura__c = :ServId
                        WITH SECURITY_ENFORCED
                        order by CreatedDate Desc
                ];
                if (lMov.size() > 0) {
                    pratId = lMov[0].Pratica__c;
                    bPrat = true;
                }
            }

            if (!bPrat && accountExtKey != null && accountExtKey != '' && ServExternalKey != null && ServExternalKey != '') {
                Map<String, String> mFields = mMappingObjects.get('Account');
                String ExtKeyFields = mFields.get('AccountExternalKey');
                String qPrat = 'SELECT Account__c,Pratica__c,Servizio_Fornitura__c FROM Movimento__c WHERE Account__r.' + String.escapeSingleQuotes(ExtKeyFields) + ' = :accountExtKey AND Servizio_Fornitura__r.Id_Esterno__c = :ServExternalKey order by CreatedDate Desc';
                List<Movimento__c> lMov = database.query(qPrat);
                if (lMov.size() > 0) {
                    accountId = lMov[0].Account__c;
                    ServId = lMov[0].Servizio_Fornitura__c;
                    pratId = lMov[0].Pratica__c;
                    bPrat = true;
                }
            }

            if (bPrat) {
                Movimento__c m = new Movimento__c();
                //m.recordTypeId = sObjectType.Movimento__c.getRecordTypeInfosByName().get(mi.mov.RecordType).getRecordTypeId();
                m.recordTypeId = sObjectType.Movimento__c.getRecordTypeInfosByDeveloperName().get(mi.mov.RecordType).getRecordTypeId();
                m.Account__c = accountId;
                m.Pratica__c = pratId;
                m.Servizio_Fornitura__c = servId;
                m.IdentificativoFatturaExt__c = mi.mov.MovExternalKey;
                m.Data_Emissione__c = mi.mov.DataEmissione;
                m.Data_Integrazione__c = System.today();
                m.Importo__c = mi.mov.Importo;
                m.Residuo__c = mi.mov.Residuo;
                m.Sollecitabile__c = mi.mov.Sollecitabile;
                m.Data_Scadenza__c = mi.mov.DataScadenza;
                m.Tipo_Scadenza__c = 'Scaduto';
                m.Stato_Pratiica_Picklist__c = 'Da Elaborare';
                m = (Movimento__c) CRABB_API_Class.setPayloadField('Movimento__c', mMappingObjects, mi.mov.lPL, m);
                Map<String , List<String>> fieldObjectToCheck = new Map<String, List<String>>();
                fieldObjectToCheck.put('Movimento__c' , new List<String>{'RecordTypeId','Account__c','Pratica__c','Servizio_Fornitura__c'
                        , 'IdentificativoFatturaExt__c' , 'Data_Emissione__c' , 'Data_Integrazione__c' , 'Importo__c' , 'Residuo__c','Sollecitabile__c'
                        ,'Data_Scadenza__c' , 'Tipo_Scadenza__c' , 'Stato_Pratiica_Picklist__c'});
                String errorsSecurity = CRABB_API_Class.checkFLSPraticaServizioMovimento(fieldObjectToCheck);
                if (!String.isNotBlank(errorsSecurity)) {
                    Database.SaveResult srMov = Database.insert(m);
                    out.AccountIdSFDC = accountId;
                    out.ServizioIdSFDC = servId;
                    out.PraticaCodeSFDC = pratId;
                    out.MovimentoIdSFDC = srMov.getId();
                    out.Esito = 'OK';
                } else {
                    out.Esito = 'KO';
                    out.lErrors = new List<CRABB_API_Class.Error>();
                    CRABB_API_Class.Error e = new CRABB_API_Class.Error();
                    e.Code = 'CRABB-007';
                    e.Description = errorsSecurity;
                    out.lErrors.add(e);
                }
            } else {
                out.Esito = 'KO';
                out.lErrors = new List<CRABB_API_Class.Error>();
                CRABB_API_Class.Error e = new CRABB_API_Class.Error();
                e.Code = 'CRABB-006';
                e.Description = 'Pratica non trovata';
                out.lErrors.add(e);
            }
        }catch(Exception ex){
            out.Esito = 'KO';
            out.lErrors = new List<CRABB_API_Class.Error>();
            CRABB_API_Class.Error e = new CRABB_API_Class.Error();
            e.Code = 'CRABB-010';
            e.Description = ex.getMessage()+ ' - ' + ex.getStackTraceString() + ' - '+ ex.getLineNumber();
            out.lErrors.add(e);
        }
        return out;
    }
}