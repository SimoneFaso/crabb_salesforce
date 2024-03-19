/* ---------------------------------------------------------------------------------------------------------------------
Name:            GestioneAffidamentiCTRL.cls
Description:     Controller for GestioneAffidamenti.page
Test class:      TestGestioneAffidamentiCTRL.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
29-Oct-2015  0.2      ESino                Modificati la lettura dei pre-lotti, per leggere il scaduto delle pratiche e
                                           calcolare il totale scaduto affidato, in real time.
                                           (Vedi metodo calcolaScadutoTotale())  => Versione con WRAPPER
16-Jun-2016  0.3      ESino                Aggiunto il with sharing per soddisfare Security Review.
28-Sep-2021  0.4      Matteo Pizzichini    Fixing FLS adding brace to if
13-Sep-2022  0.5      C.sanna & Rei Kurti  Modified for adding check permission: cebCheckFLSPermission/cebCheckObjPermission/
                                           WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class GestioneAffidamentiCTRL {
    public List<Lotto__c> lotti { get; set; }
    public List<Lotto__c> preLotti { get; set; }
    public List<PreLottiWrapper> preLottiWrapperList { get; set; }
    public List<Lotto__c> lottiFaseCreazione { get; set; }
    public Id IdLotto { get; set; }
    public Id IdPrelotto { get; set; }
    public Id IDLIC { get; set; }
    public String TabToView { get; set; }
    public String batchId { get; set; }
    public Boolean showErrorBatch { get; set; }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public GestioneAffidamentiCTRL() {
        TabToView = ApexPages.currentPage().getParameters().get('TabToView');
        batchId = ApexPages.currentPage().getParameters().get('batch');
        Boolean goOn = true;

        if (batchId != null && String.isNotBlank(batchId)) {
            showErrorBatch = false;

            List<AsyncApexJob> batchList = [SELECT Id, Status, CompletedDate FROM AsyncApexJob WHERE Id = :batchId LIMIT 1];
            if (batchList != null && !batchList.isEmpty() &&
                    ((!batchList[0].Status.equalsIgnoreCase('Completed') && !batchList[0].Status.equalsIgnoreCase('Failed') && !batchList[0].Status.equalsIgnoreCase('Aborted')) || batchList[0].CompletedDate == null)) {

                showErrorBatch = true;
                goOn = false;

            } else {
                goOn = true;
            }

        } else {
            goOn = true;
        }

        if (goOn) {

            preLottiWrapperList = new List<PreLottiWrapper>();

            /*if (Utils.cebCheckFLSPermission('Lotto__c', 'SystemCreationOfLotto__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'Codice__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'Stato__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'Affidi__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'Totale_da_affidare__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'Totale_Incassato_sul_Lotto__c', gd).get('ACCESS')) { */
            lotti = [
                    Select id, Name, SystemCreationOfLotto__c, Agenzia_di_Recupero__r.name, Codice__c, Stato__c, Affidi__c,
                            Affidi_in_corso__c, Totale_da_affidare__c, Totale_Incassato_sul_Lotto__c
                    from Lotto__c
                    where Tipo__c = 'Lotto' AND (Stato__c = 'Confermato' OR (Stato__c = 'Chiuso')
                    OR Stato__c = 'Confermato parzialmente')
                    WITH SECURITY_ENFORCED
                    ORDER BY Name DESC
            ];

            /*if (Utils.cebCheckFLSPermission('Lotto__c', 'SystemCreationOfLotto__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'Codice__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'Stato__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'Affidi__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'Totale_da_affidare__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'Affidamenti_support_Scaduto_Affidato__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'Totale_Incassato_sul_Lotto__c', gd).get('ACCESS')) { */

            preLotti = [
                    Select id, Name, SystemCreationOfLotto__c, Agenzia_di_Recupero__r.name, Codice__c, Stato__c,
                            Affidi__c, Affidi_in_corso__c, Totale_da_affidare__c, Affidamenti_support_Scaduto_Affidato__c,
                            Totale_Incassato_sul_Lotto__c
                    from Lotto__c
                    where Tipo__c = 'Pre-Lotto' and Stato__c in ('Da confermare', 'Confermato parzialmente')
                    WITH SECURITY_ENFORCED
                    ORDER BY Name DESC
            ];
            //throw new TriggerFactory.TriggerException('HAI:'+[Select Id,Stato__c,Tipo__c,Agenzia_di_Recupero__r.name from Lotto__c]);
            if (preLotti != null && preLotti.size() > 0) {
                calcolaScadutoTotale(preLotti);
            }

            lottiFaseCreazione();
        }
    }
    public void refreshTabToView() {
        TabToView = ApexPages.currentPage().getParameters().get('TabToView');
    }
    public void impostaTabToView(String s) {
        TabToView = s;
    }
    public void refreshLotti() {
        /*if (Utils.cebCheckFLSPermission('Lotto__c', 'SystemCreationOfLotto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Codice__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Affidi__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Totale_da_affidare__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Totale_Incassato_sul_Lotto__c', gd).get('ACCESS')) { */
        lotti = [Select id, Name, SystemCreationOfLotto__c, Agenzia_di_Recupero__r.name, Codice__c, Stato__c,
                Affidi__c, Affidi_in_corso__c, Totale_da_affidare__c, Totale_Incassato_sul_Lotto__c from Lotto__c
        where Tipo__c = 'Lotto' AND Stato__c = 'Confermato'
        WITH SECURITY_ENFORCED ORDER BY Name DESC];

    }
    public void refreshpreLotti() {
        /*if (Utils.cebCheckFLSPermission('Lotto__c', 'SystemCreationOfLotto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Codice__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Affidi__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Totale_da_affidare__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Affidamenti_support_Scaduto_Affidato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Totale_Incassato_sul_Lotto__c', gd).get('ACCESS')) { */
            preLotti = [Select id, Name, SystemCreationOfLotto__c, Affidamenti_support_Scaduto_Affidato__c,
                    Agenzia_di_Recupero__r.name, Codice__c, Stato__c, Affidi__c, Affidi_in_corso__c,
                    Totale_da_affidare__c, Totale_Incassato_sul_Lotto__c from Lotto__c where Tipo__c = 'Pre-Lotto' and Stato__c
                    in ('Da confermare', 'Confermato parzialmente')
                WITH SECURITY_ENFORCED ORDER BY Name DESC];
            if (preLotti != null && preLotti.size() > 0) {
                calcolaScadutoTotale(preLotti);
            }

    }
    public void lottiFaseCreazione() {
        /*if (Utils.cebCheckFLSPermission('Lotto__c', 'SystemCreationOfLotto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Codice__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Affidi__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Totale_da_affidare__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Affidamenti_support_Scaduto_Affidato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Affidamenti_support_numero_affidi__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Totale_Incassato_sul_Lotto__c', gd).get('ACCESS')) { */
            lottiFaseCreazione = [SELECT id, SystemCreationOfPreLotto__c, Name, Agenzia_di_Recupero__r.name, Codice__c,
                    Stato__c, Affidi__c, Affidi_in_corso__c, Affidamenti_support_Scaduto_Affidato__c, Totale_da_affidare__c,
                    Affidamenti_support_numero_affidi__c, Totale_Incassato_sul_Lotto__c from Lotto__c
            WHERE Tipo__c = 'Pre-Lotto' AND stato__c IN ('In creazione', 'In lavorazione')
            WITH SECURITY_ENFORCED ORDER BY Name DESC];

    }
    public Integer getSizelottiFaseCreazione() {
        return (lottiFaseCreazione != null) ? lottiFaseCreazione.size() : 0;
    }
    public Integer getSizePreLotti() {
        return (preLotti != null) ? preLotti.size() : 0;
    }
    public Integer getSizelotti() {
        return (lotti != null) ? lotti.size() : 0;
    }
    public PageReference startNewLotto() {
        return Page.newLottizzazione;
    }

    public PageReference ModificaLotti() {
        System.debug('ModificaLotti idLotto --> ' + Idlotto);
        PageReference Page = new PageReference('/apex/ModificaLotti?IdLotto=' + IdLotto);
        return Page;
    }

    public PageReference EliminaLotti() {
        System.debug('EliminaLotti idLotto --> ' + Idlotto);
        PageReference Page = new PageReference('/apex/EliminaLotto?IdLotto=' + IdLotto);
        return Page;
    }

    public PageReference ModificaPreLotti() {
        System.debug('ModificaPreLotti idPreLotto --> ' + IdPrelotto);
        PageReference Page = new PageReference('/apex/ModificaPreLotti?IdPreLotto=' + IdPreLotto);
        return Page;
    }

    public PageReference EliminaPreLotti() {
        System.debug('EliminaPreLotti idPreLotto --> ' + IdPrelotto);
        PageReference Page = new PageReference('/apex/EliminaPreLotto?IdPreLotto=' + IdPreLotto);
        return Page;
    }

    public PageReference EliminaIDLIC() {
        IDLIC = String.isNotBlank(ApexPages.currentPage().getParameters().get('IDLIC')) ? String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('IDLIC')) : null;
        if (IDLIC == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, 'Errore di sistema, l\'id del lotto risulta mancante. Contattare l\'Amministratore di sistema.'));
            return null;
        }
        if (Utils.cebCheckObjPermission('Lotto__c', gd).get('DELETE')) {
            delete [Select id from lotto__c where id = :IDLIC];
        }
        lottiFaseCreazione();
        impostaTabToView('LICTab');
        return null;
    }

    public PageReference GeneraPreLottoIDLIC() {
        IDLIC = String.isNotBlank(ApexPages.currentPage().getParameters().get('IDLIC')) ? String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('IDLIC')) : null;
        if (IDLIC == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Errore di sistema, l\'id del lotto risulta mancante. Contattare l\'Amministratore di sistema.'));
            return null;
        }
        try {
            Lotto__c lotto = new Lotto__c();
            lotto.Id = IDLIC;
            lotto.SystemCreationOfPreLotto__c = true;
            //if (Utils.cebCheckFLSPermission('Lotto__c', 'SystemCreationOfPreLotto__c', gd).get('UPDATE')) update lotto;
            if (Utils.cebCheckObjPermission('Lotto__c',gd).get('UPDATE') && Utils.cebCheckFLSPermission('Lotto__c', 'SystemCreationOfPreLotto__c', gd).get('UPDATE')) {
                update lotto;
            }
            List<Id> idLotti = new List<Id>();
            idLotti.add(IDLIC);
            AffidamentiManager.creaAffidamenti(idLotti, 'xx');
            lottiFaseCreazione();
            impostaTabToView('LICTab');
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Errore:' + e.getMessage()));
        }
        return null;
    }

    public void calcolaScadutoTotale(List<Lotto__c> preLotti) {
        String debug = '\n Met. CalcolaScadutoTotale() - START!';
        Integer i;
        Map<Id, Lotto__c> preLottiMap = new Map<Id, Lotto__c>();
        Map<Id, Decimal> scadutoPreLottoMap = new Map<Id, Decimal>();
        Map<Id, Affidamento__c> affMap;
        debug += '\n \n 1) Inizializzati i Collecton!';

        for (Lotto__c l : preLotti) {
            scadutoPreLottoMap.put(l.Id, 0);
            preLottiMap.put(l.Id, l);
        }
        debug += '\n \n 2) Mappa Lotto-Scaduto inizilizzata: ' + scadutoPreLottoMap + ', \n Mappa id-PreLotto, inizilizzata: ' + preLottiMap;

        affMap = new Map<Id, Affidamento__c>([Select Id, Name, Pratica__r.Residuo_Totale__c, Lotto__c From Affidamento__c Where Lotto__c in :preLottiMap.keySet() WITH SECURITY_ENFORCED ORDER BY Name DESC]);

        debug += '\n \n 3) Mappa id-Affido, inizilizzata: ' + affMap;
        debug += '\n \n 4) Calcolando il scaduto per i lotti: ';
        i = 1;
        for (Id aId : affMap.keySet()) {
            Affidamento__c a = affMap.get(aId);
            debug += '\n \n ' + i + '. Affido: ' + a;
            Decimal totaleScaduto = scadutoPreLottoMap.get(a.Lotto__c);
            debug += '\n *Scaduto del Lotto, letto dalla mappa: ' + totaleScaduto + '\n **Scaduto della pratica: ' + a.Pratica__r.Residuo_Totale__c;
            totaleScaduto += a.Pratica__r.Residuo_Totale__c;
            debug += '\n ***Scaduto scritto nella mappa: ' + totaleScaduto;
            scadutoPreLottoMap.put(a.Lotto__c, totaleScaduto);
            i++;
        }

        debug += '\n \n 6) Creando i preLotti Wrapper: ';
        i = 1;
        for (Id idPreLotto : preLottiMap.keySet()) {
            Decimal totaleScaduto = scadutoPreLottoMap.get(idPreLotto);
            Lotto__c l = preLottiMap.get(idPreLotto);
            debug += '\n \n ' + i + '. Lotto: ' + l.Name + '\n *Scaduto Corrispondente: ' + totaleScaduto;
            PreLottiWrapper plw = new PreLottiWrapper(l, totaleScaduto);
            preLottiWrapperList.add(plw);
            debug += '\n \n **Wrapper-PreLotto, generato: ' + plw;
            i++;
        }

        debug += '\n \n 7) Lista finale dei Wrapper: ' + preLottiWrapperList;
        System.debug(debug);
    }

    public class PreLottiWrapper {
        public Lotto__c l { get; set; }
        public Decimal totaleScaduto { get; set; }

        public PreLottiWrapper() {
        }

        public PreLottiWrapper(Lotto__c l, Decimal totaleScaduto) {
            this.l = l;
            this.totaleScaduto = totaleScaduto;
        }
    }
}