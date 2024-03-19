/* ---------------------------------------------------------------------------------------------------------------------
Name:            StampaPDF.cls

Test class:      TestCoverage_StampaPDF.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
              0.1                                      First Version
16-June-2016  0.2     E.Sino                           Aggiunto il with sharing come richiesta da Salesforce.com per soddisfare le specifiche
                                                       del Security Review.
14-Sep-2022   0.3     R. Kurti & C. Sanna              Modified for adding WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class StampaPDF {
    Public Boolean bId { get; set; }
    Public String Pagamento { get; set; }
    Public String Intestazione { get; set; }
    Public String Logo { get; set; }
    Public List<Servizi_Item__c> lFruitori { get; set; }
    private final Pratica__c prat;
    Public List<Movimento__c> ListMov { get; set; }
    public Movimento__c Mov { get; set; }
    public Contratto__c Contratto { get; set; }
    public String DocumType { get; set; }
    public String OggettoPDF { get; set; }
    public String idPratica { get; set; }
    public Date DataUltimoSaldo { get; set; }
    public Boolean ViewEsercenteSportello { get; set; }
    public boolean ViewReferentiComunali { get; set; }
    public boolean ViewReferentiElior { get; set; }
    public String sAzienda { get; set; }
    public map<String, Document_Type__c> MapDocumPerCode { get; set; }
    public String CampoFormattabile { get; set; }


    public StampaPDF(ApexPages.StandardController controller) {
        MapDocumPerCode = new map<String, Document_Type__c>();
        /*DocumType = ApexPages.currentPage().getParameters().get('Type');
        idPratica = ApexPages.currentPage().getParameters().get('Id');*/
        DocumType = ApexPages.currentPage().getParameters().get('Type').escapeHtml4();
        idPratica = ApexPages.currentPage().getParameters().get('Id').escapeHtml4();
        List<Document_Type__c> ListTypeDocument = Document_Type__c.getAll().values();
        for (Document_Type__c Dt : ListTypeDocument) {
            MapDocumPerCode.put(Dt.Document_Code__c, Dt);
        }
        if (MapDocumPerCode.get(DocumType) != null)
            OggettoPDF = MapDocumPerCode.get(DocumType).Name;
        if (idPratica == null) {
            bId = false;
        } else {
            bId = true;
            //if(Utils.checkFLSPermission('Pratica__c', 'Servizio_Fornitura__c').get('ACCESS')
            //    && Utils.checkFLSPermission('Servizio__c', 'Contratto__c').get('ACCESS')
            //    && Utils.checkFLSPermission('Contratto__c', 'Azienda__c').get('ACCESS'))
            //{
            prat = [
                    Select Id, Name, Servizio_Fornitura__r.RecordType.Name,
                            Servizio_Fornitura__r.LookupContratto__r.Azienda__c
                    from Pratica__c
                    where Id = :idPratica
                    WITH SECURITY_ENFORCED
            ];
            /* if(Utils.checkFLSPermission('Contratto__c', 'Esercenti_e_Sportello__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Referenti_Comunali__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Referenti_Gruppo_Elior__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Seconda_Raccomandata_Strategia_Appalti__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Prima_raccomandata_strategia_Appalti__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Prima_Lettera_AR_30_100__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Prima_Lettera_AR_Over100__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Prima_Lettera_Ordinaria_1_Figlio__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Prima_Lettera_Ordinaria_N_Figli__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Prima_Lettera_Ritardatari_1_Figlio__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Prima_Lettera_Ritardatari_N_Figli__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Seconda_Lettera_AR__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Seconda_Lettera_Ordinaria_30_100__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Seconda_Lettera_Ordinaria_Over100__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Terza_Raccomandata_Strategia_Appalti__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Mostra_Spese__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Sito_Internet__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Elenco_altre_forme_di_pagamento_x_letter__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Elenco_Esercenti_x_Lettera__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Lettera_Prioritaria_Mensile_RHO__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Lettera_AR_Mensile_RHO__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Testo_MAIL_Processo_Mensile__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Testo_SMS_Processo_Mensile__c').get('ACCESS')
                && Utils.checkFLSPermission('Contratto__c', 'Lettera_Diffida_Legale__c').get('ACCESS')){ */

            Contratto = [
                    Select Id, Esercenti_e_Sportello__c, Referenti_Comunali__c, Referenti_Gruppo_Elior__c, Prima_raccomandata_strategia_Appalti__c, Seconda_Raccomandata_Strategia_Appalti__c,
                            Prima_Lettera_AR_30_100__c, Prima_Lettera_AR_Over100__c, Prima_Lettera_Ordinaria_1_Figlio__c,
                            Prima_Lettera_Ordinaria_N_Figli__c, Prima_Lettera_Ritardatari_1_Figlio__c, Prima_Lettera_Ritardatari_N_Figli__c,
                            Seconda_Lettera_AR__c, Seconda_Lettera_Ordinaria_30_100__c, Seconda_Lettera_Ordinaria_Over100__c, Terza_Raccomandata_Strategia_Appalti__c,
                            Mostra_Spese__c, Sito_Internet__c, Elenco_altre_forme_di_pagamento_x_letter__c, Elenco_Esercenti_x_Lettera__c,
                            Lettera_Prioritaria_Mensile_RHO__c, Lettera_AR_Mensile_RHO__c, Testo_MAIL_Processo_Mensile__c,
                            Testo_SMS_Processo_Mensile__c, Lettera_Diffida_Legale__c
                    from Contratto__c
                    where Id = :prat.Servizio_Fornitura__r.LookupContratto__c
                    WITH SECURITY_ENFORCED
            ];
            //Controllo che il campo Esercenti Sportello sia popolato
            if (Contratto.Esercenti_e_Sportello__c != null && Contratto.Esercenti_e_Sportello__c != '')
                ViewEsercenteSportello = true;
            else
                    ViewEsercenteSportello = false;
            if (Contratto.Referenti_Comunali__c != null && Contratto.Referenti_Comunali__c != '')
                ViewReferentiComunali = true;
            else
                    ViewReferentiComunali = false;
            if (Contratto.Referenti_Gruppo_Elior__c != null && Contratto.Referenti_Gruppo_Elior__c != '')
                ViewReferentiElior = true;
            else
                    ViewReferentiElior = false;


            CampoFormattabile = (String) Contratto.get(MapDocumPerCode.get(DocumType).NameField__c);

            ListMov = [
                    Select Id, Pratica__c, Data_Scadenza__c, Sollecitabile__c
                    From Movimento__c
                    where Pratica__c = :idPratica and Sollecitabile__c = true
                    WITH SECURITY_ENFORCED
            ];
            if (ListMov.size() > 0) {
                Mov = ListMov[0];
                DataUltimoSaldo = Mov.Data_Scadenza__c;

            }
            String s2 = String.ValueOf(prat.Servizio_Fornitura__r.RecordType.Name).substring(0, 2);
            Pagamento = s2 == 'PR' ? 'PREPAGATO' : 'POSTPAGATO';
            lFruitori = [
                    SELECT Id, Cognome__c, Nome__c, Numero_Badge__c
                    FROM Servizi_Item__c
                    WHERE Servizio__c = :prat.Servizio_Fornitura__c
                    WITH SECURITY_ENFORCED
            ];
            sAzienda = prat.Servizio_Fornitura__r.LookupContratto__r.Azienda__c;
            Map<String, Azienda__c> lAz = Azienda__c.getAll();
            for (String s : lAz.keyset()) {
                if (s == sAzienda) {
                    Logo = lAz.get(s).Logo__c;
                    Intestazione = lAz.get(s).Intestazione__c + '<BR/>' + lAz.get(s).Indirizzo__c + '<BR/>' + lAz.get(s).Citta__c;
                }
            }
        }
    }


}