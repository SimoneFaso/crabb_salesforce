/* ---------------------------------------------------------------------------------------------------------------------
Name:            CostiAttivitaCTRL.cls
Description:
Test class:

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
16-Jun-2016  0.2      E. Sino                         Added With Sharing (Security Review)
08-Oct-2021  0.3      C.Sanna                         Modified for replacing of checkFLSPermission methods with
                                                      cebCheckFLSPermission (Security Review)
13-Sep-2022  0.4      R.Kurti & C.Sanna               Added WITH SECURITY ENFORCED and cebObj checks (Security review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class CostiAttivitaCTRL {
    public Map<String, Map<String, Decimal>> mCosti { get; set; }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    public String Debug { get; set; }
    public Decimal Cost { get; set; }
    public String Tipo { get; set; }
    private final Collector__c coll;

    public CostiAttivitaCTRL(ApexPages.StandardController controller) {
        Debug = 'Costruttore';
        if (!Test.isRunningTest()) {
            controller.addFields(new List<String>{
                    'Name'
            });
        }
        this.coll = (Collector__c) controller.getRecord();
        costruisciMap();
    }

    public void costruisciMap() {
        if (Utils.cebCheckObjPermission('CostoAttivita__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('CostoAttivita__c', 'Collector__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('CostoAttivita__c', 'Tipo_Sottotipo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('CostoAttivita__c', 'Costo__c', gd).get('ACCESS')) {
            List<CostoAttivita__c> lCA = [
                    Select Id, Collector__c, Tipo_Sottotipo__c, Costo__c
                    from CostoAttivita__c
                    where (Collector__c = :coll.Name OR Collector__c = 'All')
                    //WITH SECURITY_ENFORCED
                    order by Collector__c ASC
            ];
            mCosti = new Map<String, Map<String, Decimal>>();
            for (CostoAttivita__c ca : lCA) {
                String c = ca.Collector__c;
                if (c != 'All')
                    c = 'Personalizzata';
                Map<String, Decimal> m = new Map<String, Decimal>();
                m.put(c, ca.Costo__c);
                mCosti.put(ca.Tipo_Sottotipo__c, m);
            }
        }
    }

    public PageReference Personalizza() {
        /*Cost = Decimal.ValueOf(ApexPages.currentPage().getParameters().get('Costo'));
        Tipo = ApexPages.currentPage().getParameters().get('Tipologia');*/
        Cost = Decimal.ValueOf(ApexPages.currentPage().getParameters().get('Costo').escapeHtml4());
        Tipo = ApexPages.currentPage().getParameters().get('Tipologia').escapeHtml4();
        Debug = 'Personalizza';
        System.Debug('Personalizza');
        return null;
    }

    public PageReference Modifica() {
        /*Cost = Decimal.ValueOf(ApexPages.currentPage().getParameters().get('Costo'));
        Tipo = ApexPages.currentPage().getParameters().get('Tipologia');*/
        Cost = Decimal.ValueOf(ApexPages.currentPage().getParameters().get('Costo').escapeHtml4());
        Tipo = ApexPages.currentPage().getParameters().get('Tipologia').escapeHtml4();
        Debug = 'Modifica';
        System.Debug('Modifica');
        return null;
    }

    public void ConfermaModifica() {
        if (Utils.cebCheckObjPermission('CostoAttivita__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('CostoAttivita__c', 'Collector__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('CostoAttivita__c', 'Tipo_Sottotipo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('CostoAttivita__c', 'Costo__c', gd).get('ACCESS')) {
            CostoAttivita__c ca = [
                    SELECT Costo__c
                    FROM CostoAttivita__c
                    where Tipo_Sottotipo__c = :Tipo
                    AND Collector__c = :coll.Name
                    //WITH SECURITY_ENFORCED
                    LIMIT 1
            ];
            //if (Utils.checkFLSPermission('CostoAttivita__c', 'Costo__c').get('UPDATE')) update ca;
            if (Utils.cebCheckObjPermission('CostoAttivita__c', gd).get('UPDATE') &&
                    Utils.cebCheckFLSPermission('CostoAttivita__c', 'Costo__c', gd).get('UPDATE')) {
                update ca;
            }
        }
        Debug = 'Spegni';
        costruisciMap();
    }

    public String StaccaChiaveCS() {

        List<CostoAttivita__c> lCA = new List<CostoAttivita__c>();
        if (Utils.cebCheckObjPermission('CostoAttivita__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('CostoAttivita__c', 'Name', gd).get('ACCESS')) {
            //lCA = [Select Name FROM CostoAttivita__c WITH SECURITY_ENFORCED Limit 100];
            lCA = [Select Name FROM CostoAttivita__c Limit 100];

        }
        String sKey = '00001';
        if (lCA.size() > 0) {
            if (Utils.cebCheckObjPermission('CostoAttivita__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('CostoAttivita__c', 'Name', gd).get('ACCESS')) {
                //sKey = [Select Name FROM CostoAttivita__c WITH SECURITY_ENFORCED order by Name Desc LIMIT 1].Name;
                sKey = [Select Name FROM CostoAttivita__c order by Name Desc LIMIT 1].Name;
            }
            System.debug('sKey -->' + sKey);
            sKey = sKey.substring(5, sKey.length());
            System.debug('sKey 2 -->' + sKey);
            Integer iKey = Integer.ValueOf(sKey);
            System.debug('iKey -->' + iKey);
            iKey++;
            if (iKey < 10)
                sKey = '0000' + String.ValueOf(iKey);
            else if (iKey < 100)
                sKey = '000' + String.ValueOf(iKey);
            else if (iKey < 1000)
                sKey = '00' + String.ValueOf(iKey);
            else if (iKey < 10000)
                sKey = '0' + String.ValueOf(iKey);
            else if (iKey < 100000)
                sKey = '' + String.ValueOf(iKey);

        }

        return 'Costo' + sKey;
    }

    public void ConfermaPersonalizza() {
        CostoAttivita__c ca = new CostoAttivita__c();
        ca.Costo__c = Cost;
        ca.Tipo_Sottotipo__c = Tipo;
        ca.Collector__c = coll.Name;
        ca.Collector__c = coll.Name;
        ca.Name = StaccaChiaveCS();
        /*if (Utils.checkFLSPermission('CostoAttivita__c', 'Costo__c').get('CREATE')
            && Utils.checkFLSPermission('CostoAttivita__c', 'Tipo_Sottotipo__c').get('CREATE')
            && Utils.checkFLSPermission('CostoAttivita__c', 'Collector__c').get('CREATE')
            && Utils.checkFLSPermission('CostoAttivita__c', 'Name').get('CREATE')
        ) insert ca;*/
        System.debug('ca to insert -->' + ca);
        if (Utils.cebCheckObjPermission('CostoAttivita__c', gd).get('CREATE') &&
                Utils.cebCheckFLSPermission('CostoAttivita__c', 'Costo__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('CostoAttivita__c', 'Tipo_Sottotipo__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('CostoAttivita__c', 'Collector__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('CostoAttivita__c', 'Name', gd).get('CREATE')) {
            insert ca;
        }

        Debug = 'Spegni';
        costruisciMap();
    }

    public void AnnullaModificaPersonalizza() {
        Debug = 'Annulla';
    }

    public List<selectOption> soType { get; set; }
    public String Type { get; set; }
    public Boolean bPersonalizzata { get; set; }

    public void NuovoCosto() {
        if(Utils.checkFLSPermission('Strategia__c', 'Nome__c').get('ACCESS'))
        if (Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('ACCESS')
        && Utils.cebCheckFLSPermission('Strategia__c','Record_Type__c',gd).get('ACCESS')) {
            List<AggregateResult> lAR = [
                    SELECT count(Id), Nome__c
                    FROM Strategia__c
                    WHERE Record_Type__c = 'STEP'
                    //WITH SECURITY_ENFORCED
                    Group by Nome__c
            ];
            system.debug(lAR);
            soType = new List<selectOption>();
            Type = '';
            for (AggregateResult ar : lAR) {
                system.debug(ar.get(Utils.NAMESPACE + 'Nome__c'));
                if (mCosti.get(String.ValueOf(ar.get(Utils.NAMESPACE + 'Nome__c'))) == null) {
                    soType.add(new selectOption(String.ValueOf(ar.get(Utils.NAMESPACE + 'Nome__c')), String.ValueOf(ar.get(Utils.NAMESPACE + 'Nome__c'))));
                    Type = String.ValueOf(ar.get(Utils.NAMESPACE + 'Nome__c'));
                }
            }
        }

        bPersonalizzata = true;
        Cost = 0;
        Debug = 'Nuovo';
    }

    public void ConfermaNuovoCosto() {
        CostoAttivita__c ca = new CostoAttivita__c();
        ca.Costo__c = Cost;
        ca.Tipo_Sottotipo__c = Type;
        if (bPersonalizzata)
            ca.Collector__c = coll.Name;
        else
                ca.Collector__c = 'All';

        if (ca.Collector__c != null && ca.Collector__c != '') {
            ca.Name = StaccaChiaveCS();
            /*    if (Utils.checkFLSPermission('CostoAttivita__c', 'Costo__c').get('CREATE')
                    && Utils.checkFLSPermission('CostoAttivita__c', 'Tipo_Sottotipo__c').get('CREATE')
                    && Utils.checkFLSPermission('CostoAttivita__c', 'Collector__c').get('CREATE')
                    && Utils.checkFLSPermission('CostoAttivita__c', 'Name').get('CREATE'))
                    insert ca;*/
            if (Utils.cebCheckObjPermission('CostoAttivita__c', gd).get('CREATE') &&
                    Utils.cebCheckFLSPermission('CostoAttivita__c', 'Costo__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('CostoAttivita__c', 'Tipo_Sottotipo__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('CostoAttivita__c', 'Collector__c', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('CostoAttivita__c', 'Name', gd).get('CREATE')) {
                insert ca;
            }

            costruisciMap();
            Debug = 'Inserito';
        } else {
            costruisciMap();
            Debug = 'Non Inserito';
        }
    }
}