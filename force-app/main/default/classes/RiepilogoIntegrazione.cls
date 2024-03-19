/* ---------------------------------------------------------------------------------------------------------------------
Name:            RiepilogoIntegrazione.cls

Test class:      TestRiepilogoIntegrazione.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
              0.1                                      First Version
16-June-2016  0.2     E.Sino                           Aggiunto il with sharing come richiesta da Salesforce.com per soddisfare le specifiche
                                                       del Security Review.
14-Sep-2022   0.3     R. Kurti & C. Sanna              Modified for adding check permission: cebCheckFLSPermission/cebCheckObjPermission/WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class RiepilogoIntegrazione {
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public Map<String, Header> MapHeader { get; set; }
    public class Header {
        public String Contratto { get; set; }
        public DateTime UltCarMov { get; set; }
        public DateTime UltCarAna { get; set; }
        Public list<Content> lCont { get; set; }

        public Header() {
        }

        public Header(Header h) {
            this.Contratto = h.Contratto;
            this.UltCarMov = h.UltCarMov;
            this.UltCarAna = h.UltCarAna;
            this.lCont = new list<Content>(h.lCont);
        }
    }

    public class Content {
        public String Contratto { get; set; }
        public String FileName { get; set; }
        public DateTime UltCaricamento { get; set; }
        public Integer AccountTot { get; set; }
        public Integer AccountOK { get; set; }
        public Integer AccountKO { get; set; }
        public Integer MovimentiTot { get; set; }
        public Integer MovimentiOK { get; set; }
        public Integer MovimentiKO { get; set; }
        public Integer ServiziTot { get; set; }
        public Integer ServiziOK { get; set; }
        public Integer ServiziKO { get; set; }
        public Integer ServiziItemTot { get; set; }
        public Integer ServiziItemOK { get; set; }
        public Integer ServiziItemKO { get; set; }
        public Integer IndirizziTot { get; set; }
        public Integer IndirizziOK { get; set; }
        public Integer IndirizziKO { get; set; }
    }

    public List<Log__c> UltimiLog { get; set; }
    public List<Log__c> ErrorLog { get; set; }
    public Map<String, List<Log__c>> LogMap { get; set; }

    public RiepilogoIntegrazione() {
        MapHeader = new Map<String, Header>();

        if (Utils.cebCheckObjPermission('Log__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'Max_Data_Contratto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'Object_Id__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'Method__c', gd).get('ACCESS')) {
            List<AggregateResult> Logs = [
                    SELECT MAX(Max_Data_Contratto__c), Object_Id__c, Method__c
                    FROM Log__c
                    WHERE RecordType.Name = 'FinalLogIntegration'
                    WITH SECURITY_ENFORCED
                    GROUP BY Object_Id__c, Method__c
            ];
            system.debug('**************** ' + Logs.Size());

            List<String> MaxDate = new List<String>();
            for (AggregateResult ar : Logs) {
                MaxDate.add(String.valueof(ar.get('expr0')));
            }

            /* if (Utils.cebCheckObjPermission('Log__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Log__c', 'Integration_nome_del_documento__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Log__c', 'Account_KO__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Log__c', 'Method__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Log__c', 'Account_OK__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Log__c', 'Account_TOT__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Log__c', 'Indirizzi_KO__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Log__c', 'Indirizzi_OK__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Log__c', 'Indirizzi_TOT__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Log__c', 'Max_Data_Contratto__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Log__c', 'Movimenti_KO__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Log__c', 'Movimenti_OK__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Log__c', 'Movimenti_TOT__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Log__c', 'Servizi_Item_OK__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Log__c', 'Servizi_Item_KO__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Log__c', 'Servizi_Item_TOT__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Log__c', 'Servizi_OK__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Log__c', 'Servizi_KO__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Log__c', 'Servizi_TOT__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Log__c', 'ErrorLog__c', gd).get('ACCESS')) { */
            UltimiLog = [
                    SELECT Method__c, Integration_nome_del_documento__c, Account_KO__c, Account_OK__c, Account_TOT__c, Indirizzi_KO__c, Indirizzi_OK__c, Indirizzi_TOT__c,
                            Max_Data_Contratto__c, Movimenti_KO__c, Movimenti_OK__c, Movimenti_TOT__c, Object_Id__c, Servizi_Item_OK__c,
                            Servizi_Item_KO__c, Servizi_Item_TOT__c, Servizi_OK__c, Servizi_KO__c, Servizi_TOT__c, LastModifiedDate, ErrorLog__c
                    FROM Log__c
                    WHERE Max_Data_Contratto__C IN :MaxDate AND RecordType.Name = 'FinalLogIntegration'
                    WITH SECURITY_ENFORCED
                    ORDER BY Max_Data_Contratto__c, Object_Id__c
            ];

            system.debug('************ ' + UltimiLog.size());

            LogMap = new Map<String, List<Log__c>>();
            Set<Id> IdError = new Set<Id>();
            for (Log__c l : UltimiLog) {
                Content cont = new Content();
                cont.Contratto = l.Object_Id__c;
                cont.FileName = l.Integration_nome_del_documento__c;
                cont.UltCaricamento = l.LastModifiedDate;
                cont.AccountTot = Integer.ValueOf(l.Account_TOT__c);
                cont.AccountOK = Integer.ValueOf(l.Account_OK__c);
                cont.AccountKO = Integer.ValueOf(l.Account_KO__c);
                cont.MovimentiTot = Integer.ValueOf(l.Movimenti_TOT__c);
                cont.MovimentiOK = Integer.ValueOf(l.Movimenti_OK__c);
                cont.MovimentiKO = Integer.ValueOf(l.Movimenti_KO__c);
                cont.ServiziTot = Integer.ValueOf(l.Servizi_TOT__c);
                cont.ServiziOK = Integer.ValueOf(l.Servizi_OK__c);
                cont.ServiziKO = Integer.ValueOf(l.Servizi_KO__c);
                cont.ServiziItemTot = Integer.ValueOf(l.Servizi_Item_TOT__c);
                cont.ServiziItemOK = Integer.ValueOf(l.Servizi_Item_OK__c);
                cont.ServiziItemKO = Integer.ValueOf(l.Servizi_Item_KO__c);
                cont.IndirizziTot = Integer.ValueOf(l.Indirizzi_TOT__c);
                cont.IndirizziOK = Integer.ValueOf(l.Indirizzi_TOT__c);
                cont.IndirizziKO = Integer.ValueOf(l.Indirizzi_TOT__c);

                if (MapHeader.containsKey(cont.Contratto)) {
                    Header h = MapHeader.get(cont.Contratto);
                    if ((cont.UltCaricamento > h.UltCarMov && l.Method__c == 'MOVIMENTI') || (h.UltCarMov == null && l.Method__c == 'MOVIMENTI'))
                        h.UltCarMov = l.LastModifiedDate;//cont.UltCaricamento;
                    if ((cont.UltCaricamento > h.UltCarAna && l.Method__c == 'ANAGRAFICA') || (h.UltCarAna == null && l.Method__c == 'ANAGRAFICA'))
                        h.UltCarAna = l.LastModifiedDate;//cont.UltCaricamento;
                    h.lCont.add(cont);
                    MapHeader.put(cont.Contratto, new Header(h));
                } else {
                    Header h = new Header();
                    if (l.Method__c == 'MOVIMENTI')
                        h.UltCarMov = l.LastModifiedDate;//cont.UltCaricamento;
                    if (l.Method__c == 'ANAGRAFICA')
                        h.UltCarAna = l.LastModifiedDate;//cont.UltCaricamento;
                    h.Contratto = cont.Contratto;
                    h.lCont = new List<Content>();
                    h.lCont.add(cont);
                    MapHeader.put(cont.Contratto, new Header(h));
                }

                //     IdError.add(l.ErrorLog__c);

                LogMap.put(l.Object_Id__c, UltimiLog);
            }

    }
    //   system.debug('**************** ' + LogMap.size());

//        ErrorLog = [SELECT Error__c, RecordType.Name FROM Log__c WHERE RecordType.Name = 'Error' AND Id IN :IdError];
    //     system.debug('******* ' + ErrorLog);
}
}