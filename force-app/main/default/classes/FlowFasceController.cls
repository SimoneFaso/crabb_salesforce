/* ---------------------------------------------------------------------------------------------------------------------
Name:            FlowFasceController.cls
Description:
Test class:      TestFlowFasceController.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
                                                      First version
06-Jun-2016  0.2                                       Aggiunto il with sharing come richiesta da Salesforce.com per
                                                      soddisfare le specifiche del Security Review.
27-Sep-2021  0.3      Matteo Pizzichini               Modified Aggiornacollector for adding check permission:
                                                      cebCheckFLSPermission (Security Review)
13-Sep-2022  0.4      R.Kurti & C.Sanna               Added WITH SECURITY ENFORCED and cebCheckObjPermission.
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class FlowFasceController {

    public Flow.Interview.FlowAssegnaFasceCollector FAFC { get; set; }
    public String RagioneSocialeCollector { get; set; }
    public Integer LenFasce { get; set; }
    public Integer LenSoglie { get; set; }
    public List<String> ListFasceShow { get; set; }
    public List<String> ListSoglieShow { get; set; }
    public boolean ShowTermina { get; set; }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public Decimal CompensoUnivoco {

        get {

            if (FAFC != null)
                CompensoUnivoco = FAFC.CompensoUnivoco;
            return CompensoUnivoco;

        }
        set;
    }

    public String CompensoPrimaFascia { get; set; }


    public boolean ShowFine {

        get {

            if (FAFC != null)
                ShowFine = FAFC.ShowFine;
            return ShowFine;
        }
        set;
    }

    public List<FasceCompensiCollector__c> ListToLoop { get; set; }
    public List<Decimal> ListFasce {

        get {

            if (FAFC != null)
                ListFasce = FAFC.ListFasce;
            return ListFasce;
        }
        set;
    }

    public List<Decimal> ListSoglie {
        get {

            if (FAFC != null)
                ListSoglie = FAFC.ListSoglie;
            return ListSoglie;

        }
        set;
    }

    public String IdColl { get; set; }
    public Collector__c myColl { get; set; }

    public String SelFasce {

        get {
            if (FAFC != null) {
                SelFasce = FAFC.SelFasce;
            }
            return SelFasce;
        }
        set;
    }

    public boolean ShowFlow {
        get {
            if (FAFC != null) {
                ShowFlow = FAFC.ShowFlow;
            }
            return ShowFlow;
        }
        set;
    }

    public PageReference getFinishUrl() {

        return null;
    }

    public FlowFasceController() {

        ShowFlow = true;
        ShowTermina = false;
        LenFasce = 0;
        LenSoglie = 0;
        CompensoPrimaFascia = null;
        ShowFine = false;
        CompensoUnivoco = null;
        if (Utils.cebCheckObjPermission('FasceCompensiCollector__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('FasceCompensiCollector__c', 'Name', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('FasceCompensiCollector__c', 'Valore__c', gd).get('ACCESS')) {
            ListToLoop = [
                    Select name, Id, Valore__c
                    from FasceCompensiCollector__c
                    //WITH SECURITY_ENFORCED
                    order by name asc
                    LIMIT 50000
            ];
            ListSoglie = new List<Decimal>();
            ListFasce = new List<Decimal>();
            ListFasceShow = new List<String>();
            ListSoglieShow = new List<String>();
            SetColl();
            myColl = new Collector__c();
        }
    }
    public void SetColl() {

        this.IdColl = ApexPages.currentPage().getParameters().get('Id');
        this.RagioneSocialeCollector = ApexPages.currentPage().getParameters().get('RagioneSociale');
    }

    public PageReference AggiornaCollector() {
        /* if(Utils.cebCheckFLSPermission('Collector__c', 'TipoCompenso__c',gd).get('ACCESS')
                 && Utils.checkFLSPermission('Collector__c', 'CompensoMonoFascia__c').get('ACCESS')
                 && Utils.checkFLSPermission('Collector__c', 'PrimaSogliaCompenso__c').get('ACCESS')
                 && Utils.checkFLSPermission('Collector__c', 'SecondaSogliaCompenso__c').get('ACCESS')
                 && Utils.checkFLSPermission('Collector__c', 'TerzaSogliaCompenso__c').get('ACCESS')
                 && Utils.checkFLSPermission('Collector__c', 'QuartaSogliaCompenso__c').get('ACCESS'))*/
        if (Utils.cebCheckObjPermission('Collector__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Collector__c', 'TipoCompenso__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Collector__c', 'CompensoMonoFascia__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Collector__c', 'PrimaSogliaCompenso__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Collector__c', 'SecondaSogliaCompenso__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Collector__c', 'TerzaSogliaCompenso__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Collector__c', 'QuartaSogliaCompenso__c', gd).get('ACCESS')) {
            List<Collector__c> tmpColl = [
                    Select Id, TipoCompenso__c, CompensoMonoFascia__c, PrimaSogliaCompenso__c,
                            SecondaSogliaCompenso__c, TerzaSogliaCompenso__c, QuartaSogliaCompenso__c
                    From Collector__c
                    where id = :IdColl
                    //WITH SECURITY_ENFORCED
            ];
            myColl = (tmpColl.size() > 0) ? tmpColl.get(0) : null;
        }
        PageReference send;
        SObjectType type = Schema.getGlobalDescribe().get(Utils.NAMESPACE + 'Collector__c');
        String keyPrefix = type.getDescribe().getKeyPrefix();
        send = new PageReference('/' + keyPrefix);
        send.setRedirect(true);
        if (myColl == null) return send;
        if (SelFasce == '1') {

            myColl.CompensoMonoFascia__c = CompensoUnivoco;
            myColl.TipoCompenso__c = 'Fascia Unica';
            myColl.PrimaSogliaCompenso__c = null;
            myColl.SecondaSogliaCompenso__c = null;
            myColl.TerzaSogliaCompenso__c = null;
            myColl.QuartaSogliaCompenso__c = null;
            myColl.CompensoFasciaDue__c = null;
            myColl.CompensoFasciaTre__c = null;
            myColl.CompensoFasciaQuattro__c = null;
            myColl.CompensoFasciaCinque__c = null;

        } else if (SelFasce == '2') {

            myColl.PrimaSogliaCompenso__c = ListSoglie[0];
            myColl.SecondaSogliaCompenso__c = null;
            myColl.TerzaSogliaCompenso__c = null;
            myColl.QuartaSogliaCompenso__c = null;
            myColl.TipoCompenso__c = 'Due Fasce';
            myColl.CompensoMonoFascia__c = ListFasce[0];
            myColl.CompensoFasciaDue__c = ListFasce[1];
            myColl.CompensoFasciaTre__c = null;
            myColl.CompensoFasciaQuattro__c = null;
            myColl.CompensoFasciaCinque__c = null;
            //CompensoPrimaFascia =  String.ValueOf(ListFasce[0]);


            System.debug('Hai scelto due fasce');

        } else if (SelFasce == '3') {

            myColl.PrimaSogliaCompenso__c = ListSoglie[0];
            myColl.SecondaSogliaCompenso__c = ListSoglie[1];
            myColl.TerzaSogliaCompenso__c = null;
            myColl.QuartaSogliaCompenso__c = null;
            myColl.TipoCompenso__c = 'Tre Fasce';
            myColl.CompensoMonoFascia__c = ListFasce[0];
            myColl.CompensoFasciaDue__c = ListFasce[1];
            myColl.CompensoFasciaTre__c = ListFasce[2];
            myColl.CompensoFasciaQuattro__c = null;
            myColl.CompensoFasciaCinque__c = null;
            //CompensoPrimaFascia = String.ValueOf(ListFasce[0]);

            System.debug('Hai scelto tre fasce');

        } else if (SelFasce == '4') {

            myColl.PrimaSogliaCompenso__c = ListSoglie[0];
            myColl.SecondaSogliaCompenso__c = ListSoglie[1];
            myColl.TerzaSogliaCompenso__c = ListSoglie[2];
            myColl.QuartaSogliaCompenso__c = null;
            myColl.TipoCompenso__c = 'Quattro Fasce';
            myColl.CompensoMonoFascia__c = ListFasce[0];
            myColl.CompensoFasciaDue__c = ListFasce[1];
            myColl.CompensoFasciaTre__c = ListFasce[2];
            myColl.CompensoFasciaQuattro__c = ListFasce[3];
            myColl.CompensoFasciaCinque__c = null;
            // CompensoPrimaFascia = String.ValueOf(ListFasce[0]);


            System.debug('Hai scelto quattro fasce');

        } else if (SelFasce == '5') {

            myColl.PrimaSogliaCompenso__c = ListSoglie[0];
            myColl.SecondaSogliaCompenso__c = ListSoglie[1];
            myColl.TerzaSogliaCompenso__c = ListSoglie[2];
            myColl.QuartaSogliaCompenso__c = ListSoglie[3];
            myColl.TipoCompenso__c = 'Cinque Fasce';
            myColl.CompensoMonoFascia__c = ListFasce[0];
            myColl.CompensoFasciaDue__c = ListFasce[1];
            myColl.CompensoFasciaTre__c = ListFasce[2];
            myColl.CompensoFasciaQuattro__c = ListFasce[3];
            myColl.CompensoFasciaCinque__c = ListFasce[4];
            // CompensoPrimaFascia = String.ValueOf(ListFasce[0]);

            System.debug('Hai scelto cinque fasce');

        }
        /*if (Utils.checkFLSPermission('Collector__c', 'PrimaSogliaCompenso__c').get('UPDATE')
                && Utils.checkFLSPermission('Collector__c', 'SecondaSogliaCompenso__c').get('UPDATE')
                && Utils.checkFLSPermission('Collector__c', 'TerzaSogliaCompenso__c').get('UPDATE')
                && Utils.checkFLSPermission('Collector__c', 'QuartaSogliaCompenso__c').get('UPDATE')
                && Utils.checkFLSPermission('Collector__c', 'TipoCompenso__c').get('UPDATE')
                && Utils.checkFLSPermission('Collector__c', 'CompensoMonoFascia__c').get('UPDATE')
                && Utils.checkFLSPermission('Collector__c', 'CompensoFasciaDue__c').get('UPDATE')
                && Utils.checkFLSPermission('Collector__c', 'CompensoFasciaTre__c').get('UPDATE')
                && Utils.checkFLSPermission('Collector__c', 'CompensoFasciaQuattro__c').get('UPDATE')
                && Utils.checkFLSPermission('Collector__c', 'CompensoFasciaCinque__c').get('UPDATE')
                ) update(myColl);*/
        if (Utils.cebCheckObjPermission('Collector__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Collector__c', 'PrimaSogliaCompenso__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Collector__c', 'SecondaSogliaCompenso__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Collector__c', 'TerzaSogliaCompenso__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Collector__c', 'QuartaSogliaCompenso__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Collector__c', 'TipoCompenso__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Collector__c', 'CompensoMonoFascia__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Collector__c', 'CompensoFasciaDue__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Collector__c', 'CompensoFasciaTre__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Collector__c', 'CompensoFasciaQuattro__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Collector__c', 'CompensoFasciaCinque__c', gd).get('UPDATE')) {
            update (myColl);
        }


        send = new PageReference('/' + IdColl);
        send.setRedirect(true);
        return send;
    }

    public void Riepilogo() {

        ShowTermina = true;
        ShowFine = false;
        LenFasce = ListFasce.Size();
        LenSoglie = ListSoglie.size();
        Decimal cpf = (LenFasce > 0) ? ListFasce[0] : 0;
        if (CompensoUnivoco != null)
            CompensoPrimaFascia = String.ValueOf(CompensoUnivoco);
        else
                CompensoPrimaFascia = String.ValueOf(cpf);


        if (ListFasce.Size() > 0) {

            for (Decimal LF : ListFasce) {

                ListFasceShow.add(String.ValueOf(LF));
            }

        }

        if (ListSoglie.size() > 0) {

            for (Decimal LS : ListSoglie) {

                ListSoglieShow.add(String.ValueOf(LS));

            }

        }
    }

}