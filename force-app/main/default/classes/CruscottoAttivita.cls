/* ---------------------------------------------------------------------------------------------------------------------
Name:            CruscottoAttivita.cls
Description:
Test class:

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
              0.1                                      First Version
13-Sep-2022   0.2      R.Kurti & C.Sanna               Added WITH SECURITY ENFORCED, added cebCheckObj and replaced CheckFLSPermissions with cebCheckFLS (security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class CruscottoAttivita {
    public Map<String, Header> MapHeader { get; set; }
    public class Header {
        public Integer NRecord { get; set; }
        public Integer MaxGG { get; set; }
        public String Tipo { get; set; }
        public String SottoTipo { get; set; }
        Public list<Content> lCont { get; set; }

        public Header() {
        }

        public Header(Header h) {
            this.Nrecord = h.NRecord;
            this.MaxGG = h.MaxGG;
            this.Tipo = h.Tipo;
            this.SottoTipo = h.SottoTipo;
            this.lCont = new list<Content>(h.lCont);
        }
    }

    public class Content {
        public Integer NRecord { get; set; }
        public Integer MaxGG { get; set; }
        public String Tipo { get; set; }
        public String SottoTipo { get; set; }
        public String Owner { get; set; }
    }

    Public Integer nr { get; set; }
    Public Integer totnr { get; set; }

    public CruscottoAttivita() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        MapHeader = new Map<String, Header>();
        if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c', gd).get('ACCESS')
                && Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Tipo__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Sotto_Tipo__c', gd).get('ACCESS')) {
            List<AggregateResult> lt = [
                    SELECT Count(Id), MAX(Giorni_di_completamento_attivita__c), ActivityExtended__r.Tipo__c, ActivityExtended__r.Sotto_Tipo__c, Owner.Name
                    FROM Task
                    WHERE ActivityExtended__r.Automation_Flag__c = false AND Status != 'Completed'
                    WITH SECURITY_ENFORCED
                    GROUP BY ActivityExtended__r.Tipo__c, ActivityExtended__r.Sotto_Tipo__c, Owner.Name
                    ORDER By ActivityExtended__r.Tipo__c, ActivityExtended__r.Sotto_Tipo__c, Count(Id) DESC, MAX(Giorni_di_completamento_attivita__c) DESC
            ];

            String concatenazione = '';
            nr = 0;
            totnr = 0;

            for (AggregateResult aggres : lt) {
                Content cont = new Content();
                cont.Tipo = String.valueOf(aggres.get(Utils.NAMESPACE + 'Tipo__c'));
                if (cont.Tipo == null)
                    cont.Tipo = 'NA';
                cont.SottoTipo = String.valueOf(aggres.get(Utils.NAMESPACE + 'Sotto_Tipo__c'));
                if (cont.SottoTipo == null)
                    cont.SottoTipo = '';
                System.Debug(String.ValueOf(aggres.get('expr0')));
                System.Debug(String.ValueOf(aggres.get('expr1')));
                System.Debug(String.ValueOf(aggres.get('Name')));
                cont.MaxGG = Integer.valueOf(aggres.get('expr1'));
                System.Debug(String.ValueOf(cont.MaxGG));
                cont.NRecord = Integer.valueOf(aggres.get('expr0'));
                System.Debug(String.ValueOf(cont.NRecord));
                cont.Owner = String.valueOf(aggres.get('Name'));
                System.Debug(String.ValueOf(cont.Owner));

                concatenazione = cont.Tipo + ' ' + cont.SottoTipo;
                System.Debug('*** concatenazione *** ' + concatenazione);

                if (MapHeader.containsKey(concatenazione)) {
                    Header h = MapHeader.get(concatenazione);

                    h.NRecord = h.NRecord + cont.NRecord;
                    if (cont.MaxGG > h.MaxGG)
                        h.MaxGG = cont.MaxGG;
                    h.lCont.add(cont);
                    MapHeader.put(concatenazione, new Header(h));
                } else {
                    Header h = new Header();
                    h.Tipo = cont.Tipo;
                    h.SottoTipo = cont.SottoTipo;
                    h.MaxGG = Integer.valueOf(aggres.get('expr1'));
                    h.NRecord = Integer.valueOf(aggres.get('expr0'));
                    h.lCont = new List<Content>();
                    h.lCont.add(cont);
                    MapHeader.put(concatenazione, new Header(h));
                }
            }
        }
    }
}