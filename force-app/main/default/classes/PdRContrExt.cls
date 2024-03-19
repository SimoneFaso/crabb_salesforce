/* ---------------------------------------------------------------------------------------------------------------------
Name:            PdRContrExt.cls
Description:
Test class:      TestCoverage_PdRContrExt.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
13-Mar-2014  0.2      Klodjan Meta                    Modified Submit(), ActionDeleteRate() methods
16-Jun-2016  0.3      ESino                           Added With Sharing for Security Review
08-Sep-2021  0.4      Giulia Mameli                   Modified PdRContrExt() and CalcolaPdR()
22-Sep-2021  0.5      C. Sanna                        Replaced checkFLSPermission with cebCheckFLSPermission
                                                      (Security Review)
15-Sep-2022  0.6      R.Kurti & C.Sanna               Added cebCheckObjPermission and WITH SECURITY_ENFORCED for security review
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class PdRContrExt {

    private final Piano_di_Rientro__c pdr;
    public Date d { get; set; }
    public Decimal Importo;
    public Decimal ImportoRata;
    public Decimal TotRate { get; set; }
    public Integer NumeroRate;
    public Map<Integer, Rateizzazione__c> mapRate { get; set; }
    public String actionSupportParameter { get; set; } //The element is added as support for actionfunctions. The element is cast on each method respect its function.
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public PdRContrExt(ApexPages.StandardController controller) {
        PageReference pageRef = ApexPages.currentPage();
        Id pratId = pageRef.getParameters().get('PraticaId');
        this.pdr = (Piano_di_Rientro__c) controller.getRecord();
        if(String.isBlank(pdr.Pratica__c )) {
            pdr.Pratica__c = pratId;
        }
        mapRate = new Map<Integer, Rateizzazione__c>();
        d = System.today();
        TotRate = 0;
    }

    public Decimal getImporto() {
        if (pdr.Pratica__c == null) {
            return 0.00;
        } else {
            List<AggregateResult> groupedResults = new List<AggregateResult>();
            //if (Utils.cebCheckFLSPermission('Movimento__c', 'Residuo__c', gd).get('ACCESS')) {
            //f (Utils.checkFLSPermission('Movimento__c', 'Residuo__c').get('ACCESS')) {
                groupedResults = [
                        SELECT SUM(Residuo__c) somma
                        FROM Movimento__c
                        WHERE Pratica__c = :pdr.Pratica__c
                        AND Sollecitabile__c = true
                        WITH SECURITY_ENFORCED
                ];

            System.debug('groupedResults: ' + groupedResults);
            Decimal importoMov = 0.00;

            if (groupedResults.size() > 0) {
                String groupedResStr = '' + groupedResults[0].get('somma') ;
                System.debug('Grouped Result String: ' + groupedResStr);
                if (groupedResStr == null || groupedResStr == '' || groupedResStr == 'null') {
                    importoMov = 0.00;
                } else {
                    importoMov = Decimal.valueOf(groupedResStr) ;
                }

            }
            pdr.Importo_Totale__c = importoMov;
            return importoMov;
        }
    }

    public Decimal getImportoRata() {
        if (ImportoRata == null) {
            return 0.00;
        } else {
            return ImportoRata;
        }

    }

    public Integer getNumeroRate() {
        if (NumeroRate == null) {
            return 0;
        } else {
            return NumeroRate;
        }

    }

    public PageReference CalcolaPdR() {
        if (pdr.Pratica__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Scegliere la pratica');
            ApexPages.addMessage(myMsg);
            System.debug('Severity Error: scegliere la pratica');
        } else if (pdr.Numero_di_Rate__c == null && pdr.Importo_Rata__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Popolare uno tra: Numero di rate e Importo Rata');
            ApexPages.addMessage(myMsg);
            System.debug('Severity Error: Popolare uno tra: Numero di rate e Importo Rata');
        } else {
            System.debug('Pratica not null & Numero Rate & Importo Rata not null');
            if (pdr.Numero_di_Rate__c != null && pdr.Importo_Rata__c == null) {
                NumeroRate = pdr.Numero_di_Rate__c.intValue();
                ImportoRata = pdr.Importo_Totale__c.divide(NumeroRate, 2);
                System.debug('Numero Rate not null & Importo Rata null');
            } else if (pdr.Importo_Rata__c != null) {
                ImportoRata = pdr.Importo_Rata__c;
                Decimal NRate = pdr.Importo_Totale__c.divide(ImportoRata, 2);
                NumeroRate = NRate.intValue();
                System.debug('Importo Rata not null & Numero Rate null');
                System.debug('ImportoRata 2 --> '+ImportoRata);
            }

            mapRate.clear();
            Date dataInizioRate = d;
            TotRate = 0;

            for (Integer i = 1; i <= NumeroRate + 1; i++) {
                System.debug('Prova OK 4');
                Decimal dNormTotRata = 0;
                System.debug('Rata: #' + String.valueOf(i));
                if (i <= NumeroRate) {
                    System.debug('Rata: #' + String.valueOf(i) + ' Ramo 1');
                    Rateizzazione__c rate = new Rateizzazione__c();
                    rate.Piano_di_Rientro__c = pdr.Id;
                    rate.Importo_Rata__c = ImportoRata;
                    rate.Modalit_di_Pagamento__c = 'RID';
                    rate.Data_Scadenza_Rata__c = dataInizioRate.addMonths(i - 1);
                    mapRate.put(i, rate);
                } else {
                    ImportoRata = pdr.Importo_Totale__c - (ImportoRata * (NumeroRate));
                    if (ImportoRata > 0) {
                        System.debug('Rata: #' + String.valueOf(i) + ' Ramo ImportoRata > 0');
                        Rateizzazione__c rate = new Rateizzazione__c();
                        rate.Piano_di_Rientro__c = pdr.Id;
                        rate.Importo_Rata__c = ImportoRata;
                        rate.Modalit_di_Pagamento__c = 'RID';
                        rate.Data_Scadenza_Rata__c = dataInizioRate.addMonths(i - 1);
                        mapRate.put(i, rate);
                        System.debug(String.valueOf(dataInizioRate) + ' + ' + String.valueOf(i - 1));
                    } else if (ImportoRata < 0) {
                        dNormTotRata = mapRate.get(i - 1).Importo_Rata__c;
                        System.debug('Rata: #' + String.valueOf(i) + ' Ramo ImportoRata < 0');
                        ImportoRata = (mapRate.get(i - 1).Importo_Rata__c) + ImportoRata;
                        Rateizzazione__c rate = new Rateizzazione__c();
                        rate.Piano_di_Rientro__c = pdr.Id;
                        rate.Importo_Rata__c = ImportoRata;
                        rate.Modalit_di_Pagamento__c = 'RID';
                        rate.Data_Scadenza_Rata__c = dataInizioRate.addMonths(i - 2);
                        mapRate.put(i - 1, rate);
                        System.debug(String.valueOf(dataInizioRate) + ' + ' + String.valueOf(i - 1));

                    }
                }
                TotRate = TotRate + ImportoRata - dNormTotRata;
            }
        }
        return null;
    }

    public void RicalcolaImpTot() {
        TotRate = 0;
        for (Integer x = 1; x <= mapRate.size(); x++) {
            Rateizzazione__c rt = mapRate.get(x);
            TotRate = TotRate + rt.Importo_Rata__c;
        }
    }

    public void AddRata() {
        Rateizzazione__c rt = new Rateizzazione__c();
        rt.Piano_di_Rientro__c = pdr.Id;
        rt.Importo_Rata__c = 0;
        rt.Modalit_di_Pagamento__c = 'RID';
        rt.Data_Scadenza_Rata__c = d;
        mapRate.put(mapRate.size() + 1, rt);
    }

    /*
        Owner: Matteo Sala
        change owner:Klodjan Meta
        changed on:13/March/2014
        Description: Changes
            Validation: It has been added a validation logic on the Instalments dates.
            Such logic is inserted in the method InstalmentsValidation
            MathodType: from void to PageReference, so the method can return to the page the error messages 
    */
    public PageReference Submit() {
        PageReference pageRef = ApexPages.currentPage();
        Id pratId = pageRef.getParameters().get('PraticaId');
        If (pratId == null)
            pratId = pdr.Pratica__c;
        PageReference pratica = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' + pratId);

        if (mapRate.size() > 0) {
            List<String> errorMessages = installmentsValidation(mapRate);
            if (errorMessages != null) {
                for (String err : errorMessages) {
                    System.debug('Submit error --> '+err);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, err));
                }
                return null;
            }
            List<Rateizzazione__c> lRt = new List<Rateizzazione__c>();
            System.debug('Id Pratica: ' + String.valueOf(pdr.Pratica__c));
            //pdr.Stato__c = 'Attivo';
            if (Utils.cebCheckObjPermission('Piano_di_Rientro__c',gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Importo_Rata__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Pratica__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Numero_di_Rate__c', gd).get('CREATE')) {
                insert pdr;
            }
/*            if (Utils.checkFLSPermission('Piano_di_Rientro__c', 'Importo_Rata__c').get('CREATE')
                    && Utils.checkFLSPermission('Piano_di_Rientro__c', 'Pratica__c').get('CREATE')
                    && Utils.checkFLSPermission('Piano_di_Rientro__c', 'Numero_di_Rate__c').get('CREATE')) insert pdr;*/

            for (Rateizzazione__c target : mapRate.values()) {
                target.Piano_di_Rientro__c = pdr.Id;
                lRt.add(target);
            }
            //Database.SaveResult[] SR = null;
            if (Utils.cebCheckObjPermission('Rateizzazione__c',gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Rateizzazione__c', 'Piano_di_Rientro__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Rateizzazione__c', 'Importo_Rata__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Rateizzazione__c', 'Modalit_di_Pagamento__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Rateizzazione__c', 'Data_Scadenza_Rata__c', gd).get('CREATE')) {
                insert(lRt);
            }
/*            if (Utils.checkFLSPermission('Rateizzazione__c', 'Piano_di_Rientro__c').get('CREATE')
                    && Utils.checkFLSPermission('Rateizzazione__c', 'Importo_Rata__c').get('CREATE')
                    && Utils.checkFLSPermission('Rateizzazione__c', 'Modalit_di_Pagamento__c').get('CREATE')
                    && Utils.checkFLSPermission('Rateizzazione__c', 'Data_Scadenza_Rata__c').get('CREATE')) insert(lRt);*/
        }
        return pratica;
    }

    /*
        Owner: Klodjan Meta
        CreatedDate:13/March/2014
        Description: The method is used in the PianoDiRientro page to remove an Instalment from the list created by the user.
        It permits to dinamically change the number of Instalments to be associated to the "Piano di rientro".
    */
    public void actionDeleteInstalment() {
        try {
            Integer mapsKey = Integer.valueOf(actionSupportParameter);
            mapRate.remove(mapsKey);
        } catch (Exception e) {//Here will be present some error handling
        }
    }

    /*
        Owner: Klodjan Meta
        CreatedDate:13/March/2014
        Description: The method is used to validate the Instalments before saving them.
        If there is any error, are returned some error messages
    */
    public List<String> installmentsValidation(Map<Integer, Rateizzazione__c> mapRates) {
        List<String> messages = new List<String>();
        Set<Date> dateAreDifferent = new Set<Date>();
        if (mapRates == null || mapRates.keySet().size() == 0) {
            //Here will be present some error handling
            return null;
        }
        System.debug('mapRates --> '+mapRates);
        for (Integer key : mapRates.keySet()) {
            if (mapRates.get(key).Data_Scadenza_Rata__c < Date.today()) messages.add('# Rata ' + key + ' presenta una data scadenza nel passato. Scegliere una data odierna o futura');
            dateAreDifferent.add(mapRates.get(key).Data_Scadenza_Rata__c);
        }
        if (mapRates.keySet().size() > dateAreDifferent.size()) messages.add('Non è permesso che due Rate abbiano la medesima data scadenza');
        if (messages.size() > 0) return messages;
        return null;
    }
}