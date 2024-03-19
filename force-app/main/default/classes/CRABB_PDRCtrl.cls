/* ---------------------------------------------------------------------------------------------------------------------
Name:            CRABB_PDRCtrl.cls
Description:
Test class:      CRABB_PDRCtrl_TEST.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
29-May-2020  0.1      Matteo Sala          First Version
13-Sep-2022  0.2      C.Sanna & R. Kurti   Added WITH SECURITY_ENFORCED and cebCheckObjPermissions (Security Review)
28-Dec-2022  0.3      C.Sanna              Added showRepaymentPlan Type, Reason and Custom Amount methods
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class CRABB_PDRCtrl {
    Public static Map<String, SObjectType> gd = Schema.getGlobalDescribe();
    @auraenabled(cacheable=true)
    public static Boolean ExistPDR(String praticaid) {
        //List<Piano_di_Rientro__c> lPDR = [Select Id FROM Piano_di_Rientro__c WHERE Pratica__c = :praticaid AND Stato__c = 'Attivo'];
        List<Piano_di_Rientro__c> lPDR = [Select Id FROM Piano_di_Rientro__c WHERE Pratica__c = :praticaid AND Stato__c = 'Attivo' WITH SECURITY_ENFORCED];
        System.debug('***** ' + lPDR);

        return (lPDR.size() > 0) ? true : false;
    }

    @AuraEnabled(Cacheable=true)
    public static Boolean showRepaymentPlanType()
    {
        return TagHelper.getValueBoolean('ShowRepaymentPlanType');
    }

    @AuraEnabled(Cacheable=true)
    public static Boolean showCustomAmount()
    {
        return TagHelper.getValueBoolean('ShowRepaymentPlanCustomAmount');
    }

    @AuraEnabled(Cacheable=true)
    public static Boolean showReason()
    {
        return TagHelper.getValueBoolean('ShowRepaymentPlanReason');
    }

    @AuraEnabled (Cacheable=true)
    public static Boolean ExistPratica(String accId, Boolean checkPratica) {

        Boolean existPratica = false;
        if (!checkPratica) {

            List<String> statusList = Utils.getStatusList('CRABB_DEV__stati_PDR__c');

            List<CRABB_DEV__Pratica__c> pratList = [
                    SELECT Id, CRABB_DEV__Stato__c, CRABB_DEV__Account__c
                    FROM CRABB_DEV__Pratica__c
                    WHERE CRABB_DEV__Account__c = :accId
                    AND CRABB_DEV__Stato__c IN :statusList AND CRABB_DEV__Motivo_Blocco__c != 'Piano di Rientro'
                    WITH SECURITY_ENFORCED
            ];

            existPratica = pratList.size() > 0 ? true : false;
        }
        return existPratica;
    }

    @AuraEnabled (Cacheable=true)
    public static List<CRABB_DEV__Piano_di_Rientro__c> ListPDRAccount(Id accountid) {

        List<CRABB_DEV__Piano_di_Rientro__c> pdrList = [
                SELECT Id, Name, CRABB_DEV__Stato__c, CreatedDate, CRABB_DEV__Data_Ultima_Rata__c, CRABB_DEV__Importo_Totale__c, CRABB_DEV__Pratica__c, CRABB_DEV__Pratica__r.Name, CRABB_DEV__Pratica__r.CRABB_DEV__Account__c, CRABB_DEV__Pratica__r.CRABB_DEV__Stato__c
                FROM CRABB_DEV__Piano_di_Rientro__c
                WHERE CRABB_DEV__Pratica__r.CRABB_DEV__Stato__c = 'Bloccata'
                AND CRABB_DEV__Pratica__r.CRABB_DEV__Account__c = :accountid AND CRABB_DEV__Stato__c = 'Attivo'
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate ASC
        ];

        pdrList = pdrList.size() > 0 ? pdrList : new List<CRABB_DEV__Piano_di_Rientro__c>();
        return pdrList;
    }

    @auraenabled//(cacheable = true)
    public static List<Rateizzazione__c> getRate(String praticaid) {
        List<Rateizzazione__c> listRate = new List<Rateizzazione__c>();
        List<Piano_di_Rientro__c> lPDR = [
                Select Id, toLabel(Stato__c)
                FROM Piano_di_Rientro__c
                WHERE Pratica__c = :praticaid AND Stato__c = 'Attivo'
                WITH SECURITY_ENFORCED
                order by CreatedDate DESC
                limit 1
        ];
        /*
        if(lPDR.size()==1 && Utils.cebCheckObjPermission('Rateizzazione__c', gd).get('ACCESS')
                && Utils.cebCheckObjPermission('Piano_di_Rientro__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Rateizzazione__c', 'Data_Scadenza_Rata__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Rateizzazione__c', 'Importo_Rata__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Rateizzazione__c', 'Piano_di_Rientro__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Rateizzazione__c', 'Stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Importo_Totale__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Interessi_di_Dilazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Interessi_di_Mora__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Data_Stipula_Piano__c', gd).get('ACCESS')){ */
        if (lPDR.size() == 1) {
            String pdrId = lPDR.get(0).Id;
            listRate = [
                    select
                            id, Data_Scadenza_Rata__c, Importo_Rata__c, toLabel(Stato__c),
                            Piano_di_Rientro__c, Piano_di_Rientro__r.Importo_Totale__c,
                            Piano_di_Rientro__r.Name, Piano_di_Rientro__r.Data_Stipula_Piano__c,
                            Piano_di_Rientro__r.Interessi_di_Dilazione__c,
                            Piano_di_Rientro__r.Interessi_di_Mora__c, Piano_di_Rientro__r.Type__c
                    from Rateizzazione__c
                    where Piano_di_Rientro__c = :pdrId
                    WITH SECURITY_ENFORCED
                    order by Data_Scadenza_Rata__c ASC
            ];
        }
        return listRate;

    }

    @auraenabled (cacheable=true)
    public static String getStatoMap() {
        Map<String, String> statoMap = new Map<String, String>();

        List<Schema.PicklistEntry> fieldResult = CRABB_DEV__Rateizzazione__c.Stato__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry f : fieldResult) {
            statoMap.put(f.getValue(), f.getLabel());
        }
        return JSON.serialize(statoMap);
    }

    @auraenabled
    public static Map<String, String> changeStatoRata(String rataid, String stato) {
        Map<String, String> res = new Map<String, String>();

        try {
            Rateizzazione__c r = new Rateizzazione__c(Id = rataId, Stato__c = stato);
            //update r;
            if (Utils.cebCheckObjPermission('Rateizzazione__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Rateizzazione__c', 'Stato__c', gd).get('UPDATE')) {
                update r;
            }
            changeStatoPDR(r.Id);
        } catch (Exception ex) {
            res.put('errorMessage', ex.getMessage());
        }
        return res;
    }

    public static void changeStatoPDR(Id rataId) {
        CRABB_DEV__Rateizzazione__c rata = [Select id, CRABB_DEV__Piano_di_Rientro__c, CRABB_DEV__Piano_di_Rientro__r.CRABB_DEV__Rate_Disattese__c, CRABB_DEV__Piano_di_Rientro__r.CRABB_DEV__Rate_Pagate__c, CRABB_DEV__Piano_di_Rientro__r.CRABB_DEV__Numero_di_Rate__c, CRABB_DEV__Piano_di_Rientro__r.CRABB_DEV__Rate__c, CRABB_DEV__Piano_di_Rientro__r.CRABB_DEV__Stato__c from CRABB_DEV__Rateizzazione__c where id = :rataId WITH SECURITY_ENFORCED];
        CRABB_DEV__Piano_di_Rientro__c pdr = new CRABB_DEV__Piano_di_Rientro__c(id = rata.CRABB_DEV__Piano_di_Rientro__c);

        Decimal rateTot = rata.CRABB_DEV__Piano_di_Rientro__r.CRABB_DEV__Rate__c;
        Decimal rateDisattese = rata.CRABB_DEV__Piano_di_Rientro__r.CRABB_DEV__Rate_Disattese__c;
        Decimal ratePagate = rata.CRABB_DEV__Piano_di_Rientro__r.CRABB_DEV__Rate_Pagate__c;

        if (rateTot == rateDisattese || (rateDisattese > 0 && rateTot == rateDisattese + ratePagate)) {
            pdr.Stato__c = 'Disatteso';
            if (Utils.cebCheckObjPermission('Piano_di_Rientro__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Stato__c', gd).get('UPDATE')) {
                update pdr;
            }
        } else if (rateTot == ratePagate) {
            pdr.Stato__c = 'Chiuso';
            if (Utils.cebCheckObjPermission('Piano_di_Rientro__c', gd).get('UPDATE') &&
                    Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Stato__c', gd).get('UPDATE')) {
                update pdr;
            }
        }
    }

    @AuraEnabled (Cacheable=true)
    public static Id getPraticaId(Id recordId) {
        String objType = recordId.getSObjectType().getDescribe().getName();
        if (objType == 'Account') {
            return getOlderPratica(recordId).Id;
        } else {
            return recordId;
        }
    }

    public static CRABB_DEV__Pratica__c getOlderPratica(Id accId) {

        List<String> statusList = Utils.getStatusList('CRABB_DEV__stati_PDR__c');

        List<CRABB_DEV__Pratica__c> pratList = [
                SELECT Id, CRABB_DEV__Stato__c, CRABB_DEV__Residuo_Totale__c, Name, CreatedDate, CRABB_DEV__Account__c, CRABB_DEV__Account__r.CRABB_DEV__Saldo_Movimenti_Scaduti__c, CRABB_DEV__Account__r.Name
                from CRABB_DEV__Pratica__c
                where CRABB_DEV__Account__c = :accId and CRABB_DEV__Stato__c in :statusList AND CRABB_DEV__Motivo_Blocco__c != 'Piano di Rientro'
                WITH SECURITY_ENFORCED
                order by CreatedDate asc
        ];

        CRABB_DEV__Pratica__c prat = !pratList.isEmpty() ? pratList.get(0) : new CRABB_DEV__Pratica__c();

        return prat;
    }

    @auraenabled//(cacheable = true)
    public static Piano_di_Rientro__c CreatePDR(CRABB_PDR_Structure PDR_Structure) {
        System.debug(PDR_Structure);

        if (Utils.cebCheckObjPermission('Piano_di_Rientro__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Importo_Rata__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Pratica__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Numero_di_Rate__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Importo_Totale__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Interessi_di_Dilazione__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Interessi_di_Mora__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Calcola_Interessi__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Data_Stipula_Piano__c', gd).get('CREATE')) {
            Piano_di_Rientro__c pdr = new Piano_di_Rientro__c();
            List<Rateizzazione__c> lRt = new List<Rateizzazione__c>();
            pdr.Pratica__c = PDR_Structure.Pratica;
            pdr.Importo_Totale__c = PDR_Structure.Importo_Tot;
            pdr.Interessi_di_Dilazione__c = PDR_Structure.Int_Dilazione;
            pdr.Interessi_di_Mora__c = PDR_Structure.Int_Mora;
            pdr.Calcola_Interessi__c = PDR_Structure.Calcolo_Int;
            pdr.Data_Stipula_Piano__c = System.today();
            pdr.Numero_di_Rate__c = PDR_Structure.Num_Rate;
            //Claudio Start
            pdr.Type__c = PDR_Structure.Type;
            pdr.Reason__c = PDR_Structure.Reason;
            //Claudio end
            System.debug(pdr);
            insert pdr;

            for (CRABB_PDR_Structure.CRABB_Rate_Structure rs : PDR_Structure.ListRate) {
                Rateizzazione__c r = new Rateizzazione__c();
                r.Piano_di_Rientro__c = pdr.Id;
                r.Data_Scadenza_Rata__c = rs.Data_Rata;
                r.Importo_Rata__c = rs.Importo_Rata;
                lRt.add(r);
            }

            System.debug(lRt);

            if (lRT.size() > 0 && Utils.cebCheckObjPermission('Rateizzazione__c', gd).get('CREATE') && Utils.cebCheckFLSPermission('Rateizzazione__c', 'Piano_di_Rientro__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Rateizzazione__c', 'Importo_Rata__c', gd).get('CREATE')
                    //&& Utils.cebCheckFLSPermission('Rateizzazione__c', 'Modalit_di_Pagamento__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Rateizzazione__c', 'Data_Scadenza_Rata__c', gd).get('CREATE')) {
                insert (lRt);
            }


            return pdr;
        }
        return null;
    }

    @auraenabled//(cacheable = true)
    public static String createAttachment(String pdrId, String praticaId) {
        //insert pdf attachment
        /*PageReference pdf = Page.PDRDetailPdf;
        pdf.getParameters().put('pdrId', pdrId);*/
        PageReference pdf = Page.PDFfromEmailTemplate;
        pdf.getParameters().put('objectId', pdrId);
        pdf.getParameters().put('templateName', 'PDR_ATTACHMENT');

        Blob b;
        if (Test.isRunningTest()) {
            b = blob.valueOf('Unit.Test');
        } else {
            b = pdf.getContent();
        }

        //Blob b = pdf.getContent();
        Datetime dt = System.now();
        String y = String.valueOf(dt.year());
        String m = '';
        System.debug(dt.month());
        System.debug(dt.day());
        if (Integer.valueOf(dt.month()) < 10)
            m = '0' + dt.month();
        else
                m = String.valueOf(dt.month());
        String d = '';
        if (Integer.valueOf(dt.day()) < 10)
            d = '0' + dt.day();
        else
                d = String.valueOf(dt.day());
        String pdrName = Label.PianoDiRientro;
        String attName = pdrName.replace(' ', '') + ' - ' + y + m + d + '.pdf';
//        Attachment att = new Attachment( Name=attName , Body = b , ParentId =praticaId) ;
//        insert att;
        if (Utils.cebCheckObjPermission('ContentVersion', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('ContentVersion', 'ContentLocation', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('ContentVersion', 'PathOnClient', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('ContentVersion', 'Title', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('ContentVersion', 'Description', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('ContentVersion', 'VersionData', gd).get('CREATE')) {
            ContentVersion cv = createContentVersion(attName, b, praticaId);
            Database.SaveResult sr = Database.insert(cv);
            if (sr.isSuccess()) {
                Id cvId = sr.getId();
                cv = [SELECT ContentDocumentId, Description FROM ContentVersion WHERE Id = :cvId WITH SECURITY_ENFORCED];
                if (Utils.cebCheckObjPermission('ContentDocumentLink', gd).get('CREATE')
                        && Utils.cebCheckFLSPermission('ContentDocumentLink', 'ContentDocumentId', gd).get('CREATE')
                        && Utils.cebCheckFLSPermission('ContentDocumentLink', 'LinkedEntityId', gd).get('CREATE')
                        && Utils.cebCheckFLSPermission('ContentDocumentLink', 'ShareType', gd).get('CREATE')) {
                    ContentDocumentLink cdl = createContentDocumentLink(cv.ContentDocumentId, praticaId);
                    insert cdl;
                }
            }
        }
        return null;
    }

    private static ContentVersion createContentVersion(String name, Blob body, String oId) {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S';
        contentVersion.PathOnClient = name;
        contentVersion.Title = name;
        contentVersion.Description = oId;
//        contentVersion.VersionData = EncodingUtil.base64Decode(body);
        contentVersion.VersionData = body;
        return contentVersion;
    }
    private static ContentDocumentLink createContentDocumentLink(Id contentDocumentId, Id parentId) {
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentDocumentId;
        contentDocumentLink.LinkedEntityId = parentId;
        contentDocumentLink.ShareType = 'I';
        return contentDocumentLink;
    }

    @AuraEnabled (Cacheable=true)
    public static List<CRABB_DEV__Movimento__c> getExpiredInvoices(String praticaId) {
        system.debug('praticaId -->' + praticaId);
        List<CRABB_DEV__Movimento__c> invoicesList = [
                SELECT Id, numero_documento__c, Importo__c, Residuo__c, Data_Emissione__c, Data_Scadenza__c
                FROM CRABB_DEV__Movimento__c
                WHERE CRABB_DEV__Pratica__c = :praticaId
                AND Data_Scadenza__c < :System.today()
                WITH SECURITY_ENFORCED
        ];
        system.debug('invoicelist -->' + invoicesList);

        invoicesList = invoicesList.size() > 0 ? invoicesList : new List<CRABB_DEV__Movimento__c>();
        return invoicesList;
    }
}