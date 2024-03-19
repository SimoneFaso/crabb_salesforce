/* ---------------------------------------------------------------------------------------------------------------------
Name:            GestioneCostiAttivitaCTRL.cls
Description:     Extension Controller for GestioneCostiAttivita Page
Test class:      TestGestioneCostiAttivitaCTRL.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
05-Nov-2021  0.2      Giulia Mameli        Modified queryAggr excluding Strategies with null Names,
                                           updated API Version from 39 to 51 and used ceb methods
02-Sep-2022  0.3      C.Sanna & R. Kurti   Modified/Added cebCheckFls Methods (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class GestioneCostiAttivitaCTRL {

    public Map<String, CostoAttivita__c> allCA        { get; set; }
    public String collectorSelected                   { get; set; }
    public List<SelectOption> collectorOptions        { get; set; }
    public List<SelectOption> newCollectorOptions     { get; set; }

    public String persCollector                       { get; set; }
    public String persTipoSottotipo                   { get; set; }
    public Decimal persCosto                          { get; set; }

    public String newCollector                        { get; set; }

    public String idRecord                            { get; set; }
    public Decimal costoModificato                    { get; set; }

    public String newCollectorSelected                { get; set; }
    public List<SelectOption> tipoOptions             { get; set; }

    public String addingTipo                          { get; set; }
    public List<AggregateResult> aggregateStrategie   { get; set; }

    public Decimal selectedCosto                      { get; set; }

    public static final Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public GestioneCostiAttivitaCTRL() {

        allCA = CostoAttivita__c.getAll();
        String queryAggr;
        if(Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c','Nome__c', gd).get('ACCESS')){
            queryAggr = 'SELECT Nome__c NOME FROM Strategia__c WHERE RecordType.Name = \'Step\' AND Nome__c != null GROUP BY Nome__c';
        }
        //String queryAggr = 'select Tipo_attivita__c,Sotto_tipo_attivita__c from Strategia__c where Tipologia__c = \'UI\' and recordtype.name = \'Step\' group by Tipo_attivita__c,Sotto_tipo_attivita__c';
        //String queryAggr = 'SELECT Nome__c NOME FROM Strategia__c WHERE RecordType.Name = \'Step\' AND Nome__c != null GROUP BY Nome__c';
        aggregateStrategie = Database.query(queryAggr);

        populateCollectorOptions();
        retrieveTipo();

    }

    public void retrieveTipo() {

        tipoOptions = new List<SelectOption>();
        tipoOptions.add(new SelectOption('', '-- None --'));

        if(aggregateStrategie != null && !aggregateStrategie.isEmpty()) {

            for(AggregateResult ar : aggregateStrategie) {

                tipoOptions.add(new SelectOption((String) ar.get('NOME'), (String) ar.get('NOME')));

            }

        }

        tipoOptions.sort();

    }

    public void populateCollectorOptions() {

        collectorOptions = new List<SelectOption>();
        collectorOptions.add(new SelectOption('All', 'All'));

        collectorSelected = (ApexPages.currentPage().getParameters().get('coll') != null && String.isNotBlank(ApexPages.currentPage().getParameters().get('coll'))) ? ApexPages.currentPage().getParameters().get('coll') : 'All';

        newCollectorOptions = new List<SelectOption>();

        //List<Collector__c> collList = [SELECT Id,Name FROM Collector__c];
        List<Collector__c> collList = [SELECT Id,Name FROM Collector__c WITH SECURITY_ENFORCED];
        if(collList != null && !collList.isEmpty()) {
            for(Collector__c c : collList) {
                collectorOptions.add(new SelectOption(c.Name, c.Name));
                newCollectorOptions.add(new SelectOption(c.Name, c.Name));
            }
            collectorOptions.sort();
            newCollectorOptions.sort();
        }
    }

    public String staccaChiaveCS() {
        //List<CostoAttivita__c> costoAttivitaList = [SELECT Name FROM CostoAttivita__c ORDER BY Name DESC LIMIT 1];
        List<CostoAttivita__c> costoAttivitaList = [SELECT Name FROM CostoAttivita__c WITH SECURITY_ENFORCED ORDER BY Name DESC LIMIT 1];
        String sKey = '';
        if(costoAttivitaList.size() > 0) {
            sKey = costoAttivitaList[0].Name;
            sKey = sKey.substring(5, sKey.length());
            sKey = String.valueOf(Integer.valueOf(sKey) + 1);
            while (sKey.length() < 5) {
                sKey = '0' + sKey;
            }
        }

        return 'Costo' + sKey;
    }

    public PageReference confermaPersonalizza() {

        try {
            if(persCosto != null && persCollector != null && persTipoSottotipo != null) {

                CostoAttivita__c ca = new CostoAttivita__c();
                ca.Costo__c = persCosto;
                ca.Tipo_Sottotipo__c = persTipoSottotipo;
                ca.Collector__c = persCollector;
                ca.Name = staccaChiaveCS();
                if (Utils.cebCheckObjPermission('CostoAttivita__c',gd).get('CREATE')
                        && Utils.cebCheckFLSPermission('CostoAttivita__c', 'Costo__c', gd).get('CREATE') &&
                        Utils.cebCheckFLSPermission('CostoAttivita__c', 'Tipo_Sottotipo__c', gd).get('CREATE') &&
                        Utils.cebCheckFLSPermission('CostoAttivita__c', 'Collector__c', gd).get('CREATE') &&
                        Utils.cebCheckFLSPermission('CostoAttivita__c', 'Name', gd).get('CREATE')) {
                    insert ca;
                }

            }
        } catch (Exception ex) {
            System.debug('confermaPersonalizza Exception getStackTraceString: ' + ex.getStackTraceString());
            System.debug('confermaPersonalizza Exception getMessage: ' + ex.getMessage());
            System.debug('confermaPersonalizza Exception getCause: ' + ex.getCause());
        }

        PageReference page = new PageReference('/apex/GestioneCostiAttivita');
        if(collectorSelected != null && String.isNotBlank(collectorSelected)) {
            page.getParameters().put('coll', collectorSelected);
        }
        page.setRedirect(true);
        return page;
    }

    public PageReference confermaModifica() {

        try {

            if(idRecord != null && costoModificato != null) {
                CostoAttivita__c ca = new CostoAttivita__c(Id = idRecord);
                ca.Costo__c = costoModificato;

                if(Utils.cebCheckObjPermission('CostoAttivita__c', gd).get('ACCESS')
                    && Utils.cebCheckObjPermission('CostoAttivita__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('CostoAttivita__c', 'Costo__c', gd).get('UPDATE')) {
                    update ca;
                }
            }

        } catch (Exception ex) {
            System.debug('confermaModifica Exception getStackTraceString: ' + ex.getStackTraceString());
            System.debug('confermaModifica Exception getMessage: ' + ex.getMessage());
            System.debug('confermaModifica Exception getCause: ' + ex.getCause());
        }

        PageReference page = new PageReference('/apex/GestioneCostiAttivita');
        if(collectorSelected != null && String.isNotBlank(collectorSelected)) {
            page.getParameters().put('coll', collectorSelected);
        }
        page.setRedirect(true);
        return page;
    }

    public PageReference addNewRecord() {

        try {
            System.debug('@@ Collector + tipo + costo: ' + newCollectorSelected + ' - ' + addingTipo + ' - ' + selectedCosto);
            if(newCollectorSelected != null && String.isNotBlank(newCollectorSelected) && addingTipo != null && String.isNotBlank(addingTipo)) {
                //List<CostoAttivita__c> costoList = [SELECT Id,Name FROM CostoAttivita__c ORDER BY Name DESC LIMIT 1];
                List<CostoAttivita__c> costoList = [SELECT Id,Name FROM CostoAttivita__c WITH SECURITY_ENFORCED ORDER BY Name DESC LIMIT 1];
                String recName = 'Costo00001';

                if(costoList != null && !costoList.isEmpty()) {
                    String tempNumber = costoList[0].Name.substring(5);
                    Integer newInteger = Integer.valueOf(tempNumber) + 1;
                    String tempName = String.valueOf(newInteger);
                    while (tempName.length() < 5) {
                        tempName = '0' + tempName;
                    }
                    recName = 'Costo' + tempName;
                }

                CostoAttivita__c newCosti = new CostoAttivita__c();
                newCosti.Collector__c = newCollectorSelected;
                newCosti.Costo__c = (selectedCosto != null) ? selectedCosto : 0;
                newCosti.Tipo_Sottotipo__c = addingTipo;
                newCosti.Name = recName;

                if (Utils.cebCheckFLSPermission('CostoAttivita__c', 'Costo__c', gd).get('CREATE') &&
                        Utils.cebCheckFLSPermission('CostoAttivita__c', 'Tipo_Sottotipo__c', gd).get('CREATE') &&
                        Utils.cebCheckFLSPermission('CostoAttivita__c', 'Collector__c', gd).get('CREATE') &&
                        Utils.cebCheckFLSPermission('CostoAttivita__c', 'Name', gd).get('CREATE') &&
                        Utils.cebCheckObjPermission('CostiAttivita__c', gd).get('ACCESS') &&
                        Utils.cebCheckObjPermission('CostiAttivita__c', gd).get('INSERT') &&
                        Utils.cebCheckObjPermission('CostiAttivita__c', gd).get('CREATE')) {

                    insert newCosti;
                }

            }

        } catch (Exception ex) {
            System.debug('addNewRecord Exception getStackTraceString: ' + ex.getStackTraceString());
            System.debug('addNewRecord Exception getMessage: ' + ex.getMessage());
            System.debug('addNewRecord Exception getCause: ' + ex.getCause());
        }

        PageReference page = new PageReference('/apex/GestioneCostiAttivita');
        if(collectorSelected != null && String.isNotBlank(collectorSelected)) {
            page.getParameters().put('coll', collectorSelected);
        }
        page.setRedirect(true);
        return page;
    }

    public PageReference removeRecord() {
        try {

            if(idRecord != null) {
                CostoAttivita__c ca = new CostoAttivita__c(Id = idRecord);

                if(Utils.cebCheckObjPermission('CostoAttivita__c', gd).get('ACCESS')
                   && Utils.cebCheckObjPermission('CostoAttivita__c', gd).get('DELETE')) {
                    delete ca;
                }
            }

        } catch (Exception ex) {
            System.debug('removeRecord Exception getStackTraceString: ' + ex.getStackTraceString());
            System.debug('removeRecord Exception getMessage: ' + ex.getMessage());
            System.debug('removeRecord Exception getCause: ' + ex.getCause());
        }

        PageReference page = new PageReference('/apex/GestioneCostiAttivita');
        if(collectorSelected != null && String.isNotBlank(collectorSelected)) {
            page.getParameters().put('coll', collectorSelected);
        }
        page.setRedirect(true);
        return page;
    }

}