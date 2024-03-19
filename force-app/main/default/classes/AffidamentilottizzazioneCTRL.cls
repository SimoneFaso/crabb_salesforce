/* ---------------------------------------------------------------------------------------------------------------------
Name:            AffidamentilottizzazioneCTRL.cls
Description:
Test class:      TestAffidamentilottizzazioneCTRL.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
21-Dec-2021  0.1                                      First Version
16/Jun/2016  0.2      E.Sino                          Added with sharing (Security Review))
22-Feb-2021  0.3      Rajni                           Modified line 899 to replace getRecordTypeInfosByName() with
                                                      getRecordTypeInfosByDeveloperName()
08-Sep-2022  0.4      Claudio Sanna                   Added and replaced check permission:
                                                      cebCheckObjPermission/cebCheckFLSPermission/ WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class AffidamentilottizzazioneCTRL {
    public class AffidamentilottizzazioneCTRLException extends Exception {
    }

    public lotto__c lforFiltro { get; set; }
    //Variabili di debug
    public string queryExecuted { get; set; }

    //Manage the activity interessed by the process
    public string tipoAffido { get; set; }
    public list<string> categorieCollector { get; set; }

    public string tipoAffidoUrl { get; set; }
    public string ownrUrl { get; set; }
    public Id idLog;
    public Map<Id, Boolean> mPraticheSelezionate = new Map<Id, Boolean>();
    public Map<String, SObjectType> gd = Schema.getGlobalDescribe();
    //Gestione distribuzione
    public boolean sonoIDatiCongelati { get; set; }
    public pagereference congelaDati() {
        String debug = '\n congelaDati(): ';
        if (configurationSelected != null && String.isNotBlank(configurationSelected)) {

        } else if (collectorSelezionati == null || collectorSelezionati.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, 'Seleziona almeno un collector per procedere.'));
            return null;
        } else if (collectorSelezionati.size() > recordsSelected.size()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, 'Non puoi selezionare più collector che numero di pratiche da affidare.'));
            return null;
        }
        debug += '\n \n Entrando instanziaDati(): ';
        sonoIDatiCongelati = true;
        istanziaDati();
        /*debug += '\n \n Uscito instanziaDati(), entrando checkPercentForZeroValue(): ';
        checkPercentForZeroValue(collectorSelezionati);*/
        //ErrorClass.logError('\n AffidamentilottizzazioneCTRL' , '\n Fine congelaDati(), drList: ' + drList);
        return null;
    }

    public void istanziaDati() {
        CollectorAlgoritmoConfiguration__c currentCAC = null;
        if (configurationSelected != null && String.isNotBlank(configurationSelected)) {
            currentCAC = CollectorAlgoritmoConfiguration__c.getInstance(configurationSelected);
            if (currentCAC != null) {
                List<String> collectorIds = new List<String>();
                collectorIds = currentCAC.CollectorId__c.split(';');
                //for(Collector__c c:[SELECT Id, Name, Ragione_Sociale__c,Percentuale_Affido_Standard__c FROM Collector__c WHERE Id IN :collectorIds]){
                for (Collector__c c : [SELECT Id, Name, Ragione_Sociale__c, Percentuale_Affido_Standard__c FROM Collector__c WHERE Id IN :collectorIds WITH SECURITY_ENFORCED]) {
                    collectorSelezionati.add(new SelectOption(c.id, c.Ragione_Sociale__c));
                }
                //collectorSelezionati.add(new SelectOption(c.id,c.Ragione_Sociale__c));
                /*for(Integer i=0; i<collectorSelezionabili.size();i++){
                    SelectOption sos = collectorSelezionabili.get(i);
                    if(sos.getValue() == c.Id){
                        collectorSelezionabili.remove(i);
                        break;
                    }
                }*/

            }
        }
        String debug = '\n instanziaDati(): ';
        drList = new List<DistribResult>();
        integer i = 0, j = collectorSelezionati.size();
        double precentAssignment = 100;

        // ES: 
        Map<id, Double> ColValIniziali = new Map<id, Double>();
        Map<id, Double> ColValNormalizzato = new Map<id, Double>();
        Set<id> colId = new Set<id>();
        for (Selectoption colS : collectorSelezionati) {
            colId.add(colS.getValue());
        }
        debug += '\n \n collectorSelezionati: ' + collectorSelezionati;
/*        if (Utils.cebCheckObjPermission('Collector__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Collector__c', 'Percentuale_Affido_Standard__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Collector__c', 'Ragione_Sociale__c', gd).get('ACCESS'))
        {*/
        //List<Collector__c> collectors = [Select id, Percentuale_Affido_Standard__c, Ragione_Sociale__c From Collector__c where id in: colId];
        List<Collector__c> collectors = [Select id, Percentuale_Affido_Standard__c, Ragione_Sociale__c From Collector__c where id in :colId WITH SECURITY_ENFORCED];
        integer colSize = collectors.size();
        for (Collector__c c : collectors) {
            if (c.Percentuale_Affido_Standard__c == null) {
                if (colSize == 1) {
                    ColValIniziali.put(c.id, 100.0);
                } else {
                    ColValIniziali.put(c.id, Double.valueOf(100 / colSize));
                }
            } else {
                ColValIniziali.put(c.id, c.Percentuale_Affido_Standard__c);
            }
            /* DEbug Implementation!!!!
            if(c.Percentuale_Affido_Standard__c == null){
                //ColValIniziali.put(c.id, 0);
                debug += '\n 1. Primo If.';
                if(colSize == 1){debug += '\n 1.1 Secondo If.';ColValIniziali.put(c.id, 100.0);}
                else{debug += '\n 1.2 Secondo else. Valore calcolato: ' + Double.valueOf(100/colSize);ColValIniziali.put(c.id, Double.valueOf(100/colSize));}
            }else{
                debug += '\n 1. Primo else.';
                ColValIniziali.put(c.id, c.Percentuale_Affido_Standard__c);
            }debug+= '\n \n Per il Collector ' + c.Ragione_Sociale__c + ', messo il Percentuale: ' + ColValIniziali.get(c.id);
            */
        }
        //}
        ColValNormalizzato = normalizzaPercent(ColValIniziali);
        // ES Fine

        for (selectoption so : collectorSelezionati) {
            i++;
            DistribResult dr = new DistribResult();
            dr.l.Agenzia_di_Recupero__c = so.getValue();
            dr.l.Affidamenti_support_collector_ragSoc__c = so.getLabel();
            dr.l.Affidamenti_support_Posizione__c = i;
            dr.l.Affidamenti_support_numero_affidi__c = 0;
            dr.l.Affidamenti_support_Scaduto_Affidato__c = 0;
            dr.l.Affidamenti_support_Percentuale_effettiv__c = 0;
            dr.l.Affidamenti_support_Tipo_Affido__c = tipoAffido;
            dr.l.Affidamenti_support_Codice_prelotto__c = '' + system.now();
            dr.l.Affidamento_Percentuale_Affido_Standard__c = ColValIniziali.get(so.getValue());// ES: Valore default
            dr.mapTaskPratica = new map<string, string>();
            if (currentCAC != null) {

                Integer interC = 0;
                List<String> tempsplit = currentCAC.CollectorId__c.split(';');
                for (String str : tempsplit) {
                    if (so.getValue() == str) {
                        break;
                    }
                    interC++;
                }
                dr.l.Affidamenti_support_Percentuale__c = Double.valueOf(currentCAC.AllPercentage__c.split(';')[interC]);

            } else if (i == j) {

                dr.l.Affidamenti_support_Percentuale__c = precentAssignment;

            } else if (dr.l.Affidamenti_support_Percentuale__c == null) {
                dr.l.Affidamenti_support_Percentuale__c = 100 / j;
                precentAssignment -= dr.l.Affidamenti_support_Percentuale__c;
            } else {
                precentAssignment -= dr.l.Affidamenti_support_Percentuale__c;
            }
            // ES
            // Per non mandare via il vecchio implementazione, semplicemente, sovrascrivo il campo
            //dr.l.Affidamenti_support_Percentuale__c = ColValNormalizzato.get(so.getValue());
            drList.add(dr);
        }
        debug += '\n Fine procedura instanziaDati!';

        if (drList != null && !drList.isEmpty() && drList.size() == 1) {
            algoritmoScelto = 'RR';
            calcolaDistribuzione();
        } else if (currentCAC != null) {
            algoritmoScelto = currentCAC.Algoritmo__c;
            calcolaDistribuzione();
        }

        //ErrorClass.logError('AffidamentilottizzazioneCTRL', '\n instanziaDati: ' + debug);
    }

    /*
     * *
     * ES: 12/02/2015
     * Desc: Metodo per normalizzare i percentuali dei collector.
     * Collector         % Normalizzata          % Default
        Coll01                 21%                  25%
        Coll02                 54%                  65%
        Coll03                 25%                  30%
    *   Esempio:
        %Normalizzato Coll01 + %Normalizzato Coll02 + %Normalizzato Coll03 = 25/(25+65+30) + 65/(25+65+30) + 30/(25+65+30)
    */
    public Map<id, double> normalizzaPercent(Map<id, double> ColValIniziali) {
        Map<id, double> colValNorm = new Map<id, double>();
        double sumPercent = 0;

        //System.debug('\n AffidamentoLottCTRL, normalizzaPercent, Mappa ColValIniziali: ' + ColValIniziali);
        // Somma
        for (Double d : ColValIniziali.values()) {
            sumPercent += d;
        }
        sumPercent /= 100;
        // Nuovo percentuale, relativo alla somma totale
        for (id i : ColValIniziali.keySet()) {
            decimal percent = ColValIniziali.get(i);
            percent = (percent / sumPercent);
            percent = percent.setScale(2, RoundingMode.HALF_UP);
            colValNorm.put(i, percent);
        }
        return colValNorm;
    }

    //ES: Fine

    public void scongelaDati() {
        sonoIDatiCongelati = false;
        hasBeenRequiredDistribution = false;
        collectorSelezionabili = null;
        collectorSelezionabili = impostaCollectorSelezionabili();
        impostaSavedConfigurations();
        collectorSelezionati.clear();
    }
    public list<lotto__c> lottiupsert { get; set; }
    public PageReference confermaDistribuzione() {
        //Here are created In creation the records for prelotto
        List<lotto__c> LottiCreati = new List<lotto__c>();
        lottiupsert = new List<lotto__c>();
        list<id> idLotti = new list<id>();
        for (DistribResult dr : drList) {
            dr.l.tipo__c = 'Pre-Lotto';
            dr.l.stato__c = 'In Creazione';
            dr.l.Pratiche_pre_lotto__c = JSON.serialize(dr.mapTaskPratica);
            LottiCreati.add(dr.l);
        }
        if (Utils.cebCheckObjPermission('Lotto__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Lotto__c', 'stato__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Lotto__c', 'tipo__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Pratiche_pre_lotto__c', gd).get('UPSERT')) {
            upsert LottiCreati;
        }
        for (lotto__c l : LottiCreati) idLotti.add(l.id);

        lottiUpsert = [
                Select id, name, tipo__c, stato__c, Pratiche_pre_lotto__c, Affidamenti_support_Scaduto_Affidato__c,
                        Affidamenti_support_numero_affidi__c, Agenzia_di_Recupero__c, Affidamenti_support_collector_ragSoc__c,
                        Affidamenti_support_Percentuale_effettiv__c, Affidamenti_support_Posizione__c, Affidamenti_support_Codice_prelotto__c
                From Lotto__c
                where id = :idLotti
                WITH SECURITY_ENFORCED
        ];
        return Page.affidamentiviewPreLotti;
    }
    public PageReference creaAffidamenti() {
        list<id> idLotti = new List<id>();
        if (lottiupsert == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.warning, Label.CreaAffidamentiErr1));
            return null;
        }
        for (lotto__c l : lottiUpsert) {
            idLotti.add(l.id);
        }
        for (lotto__c l : lottiUpsert) {
            l.SystemCreationOfPreLotto__c = true;
        }
        if (Utils.cebCheckObjPermission('Lotto__c', gd).get('UPDATE') && Utils.cebCheckFLSPermission('Lotto__c', 'SystemCreationOfPreLotto__c', gd).get('UPDATE')) {
            update lottiUpsert;
        }
        //AffidamentiManager.createAffidamentiFuture(idLotti,tipoAffido);

        if (lottiUpsert.size() < 200) {//chiama direttamente il metodo
            for (Lotto__c l : lottiUpsert)
                AffidamentiManager.creaAffidamenti(l);
        } else// troppi record, schedula Batch
                BatchQueue.reqBatch('APB', 'AffidiProcessBatch', 1, 1, lottiupsert);
        //Database.executeBatch(new AffidiProcessBatch(lottiupsert), 1);

        string urlpage = '/apex/' + Utils.NAMESPACE + 'GestioneAffidamenti?TabToView=LICTab';
        PageReference pageRef = new PageReference(urlpage);
        pageRef.setRedirect(true);
        return pageRef;
    }
    public boolean hasBeenRequiredDistribution { get; set; }
    public List<DistribResult> drList { get; set; }
    public PageReference calcolaDistribuzione() {
        hasBeenRequiredDistribution = true;
        double percent = 0;
        resetDataConfigured();
        // ES: Impostare, che leggesse il Percentuale Standard del
        for (DistribResult dr : drList) percent += dr.l.Affidamenti_support_Percentuale__c;
        if (percent != 100) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, 'La somma delle % affidi non è 100. Correggere i dati prima di proseguire. Percentuale:' + percent));
            return null;
        }
        if (algoritmoScelto == 'RR') processRoundRobin();
        else if (algoritmoScelto == 'RRR') {
            try {
                processReverseRoundRobin();
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, 'Error:' + Utils.getExceptionInString(e)));
                return null;
            }
        } else if (algoritmoScelto == 'FIFO') processFifo();
        DelLog();
        praticheAssegnate = true;
        return null;
    }
    public void resetDataConfigured() {
        for (DistribResult dr : drList) {
            dr.l.Affidamenti_support_numero_affidi__c = 0;
            dr.l.Affidamenti_support_Scaduto_Affidato__c = 0;
            dr.l.Affidamenti_support_Percentuale_effettiv__c = 0;
        }
    }

    public void processRoundRobin() {
        Map<integer, integer> mfP = new Map<integer, integer>();
        indexes ix = new indexes();
        integer j = drList.size(), l;
        for (l = 0; l <= (j - 1); l++) {
            if (l == (j - 1)) mfP.put(l, 0);
            else mfP.put(l, l + 1);
        }
        ix.oldi = j - 1;
        ix.i = 0;
        ix.k = recordsSelected.size();

        for (pratica__c p : [Select id, Residuo_Totale__c from pratica__c where id in :recordsSelected WITH SECURITY_ENFORCED order by Residuo_Totale__c Desc]) {
            valutaMappa(ix, drList, mfp);
            drList[ix.i].l.Affidamenti_support_Scaduto_Affidato__c += p.Residuo_Totale__c;
            drList[ix.i].l.Affidamenti_support_numero_affidi__c++;
            drList[ix.i].l.Affidamenti_support_Percentuale_effettiv__c = drList[ix.i].l.Affidamenti_support_numero_affidi__c / ix.k * 100;
            drList[ix.i].mapTaskPratica.put(p.id, PraticaIdtaskId.get(p.id));
            ix.oldi = ix.i;//Oldi e il collector appena lovarato
            ix.i = mfp.get(ix.i); //i passa al nuovo collector da lavorare
        }
    }
    public static void valutaMappa(Indexes ix, List<DistribResult> drList, Map<integer, integer> mfP) {
        if ((drList[ix.i].l.Affidamenti_support_numero_affidi__c / ix.k * 100) >= drList[ix.i].l.Affidamenti_support_Percentuale__c) {
            ix.i = mfp.get(ix.i);
            mfp.put(ix.oldi, ix.i);
            valutaMappa(ix, drList, mfp);
        }

    }
    public class indexes {
        integer i;
        integer oldi;
        integer k;
    }

    /*
        la gestione del reverse round robin è fatta gestendo due mappe, chiave valore, dove il valore indica il prossimo elemento della catena
        nel caso specifico si gestiscono due mappe, uno che indica il percorso della catena usuale del round robin da "a" => "z"
        e una seconda indica la catena del reverse "z" => "a"
        
    */
    /* New Version, 14/04/2015 */
    public void processReverseRoundRobin() {
        Map<integer, integer> prr = new Map<integer, integer>();
        Map<integer, integer> prrr = new Map<integer, integer>();
        String debugstring = '';
        integer j = drList.size(), i = 0, oldi = 0, l, m = 0, k = recordsSelected.size();
        boolean roundIndex = true, isLast = false;
        rrrIconfig ric = new rrrIconfig();
        ric.k = recordsSelected.size();
        //popola la mappa prr = process roundRobin, è la prima parte di processo
        for (l = 0; l <= (j - 1); l++) {
            if (l == 0) {
                prr.put(-2, l);
                prr.put(l, l + 1);
            } else if (l == (j - 1)) prr.put(l, -1);
            else prr.put(l, l + 1);
        }
        //popolo la mappa prrr=process reverse round robin
        for (l = (j - 1); l >= 0; l--) {
            if (l == (j - 1)) {
                prrr.put(-1, l);
                prrr.put(l, l - 1);
            } else if (l == 0) prrr.put(0, -2);
            else prrr.put(l, l - 1);
        }

        debugstring += 'XXX prr:' + prr;
        debugstring += 'XXX prrr:' + prrr;
        l = 0;
        try {
            /*
                    - Questo verifica che ci siano più di un elemento da lavorare nelle mapper. 
                    Oldi  e i dovrebbero essere elementi diversi fino a quando non rimane 
                    solo l'ultimo elemento.
                    - il secondo if serve per cambiare gli indici delle mappe così un 
                    elemento indica il prossimo elemento.
                    Logica: consideriamo uno scenario con 3 elementi a,b,c.. Allora le mapper sono
                    prr map
                            -2 => a
                            a => b
                            b => c
                            c => -1
                    prrr map
                            -1 => c
                            c => b
                            b => a
                            a => -2
                    nel caso vogliamo togliere l'elemeto b, quindi il valore di i è'b', per procedere bisogna definire due variabili x,y
                    x=prrr.get(i)=prrr.get('b')= a
                    y=prr.get(i)=prr.get('b')= c
                    siccome dobbiamo togliere dal giro b, dobbiamo in prr rendere a => c e in prrr rendere c => a
                    quindi bisogna fare
                    prr.put(x,y)=prr.put(a,c);
                    prrr.put(y,x)=prrr.put(c,a);
                    a fronte della modifica diventano le mappe
                    prr map
                            -2 => a
                            a => c
                            b => c => non più accessibile 
                            c => -1
                    prrr map
                            -1 => c
                            c => a
                            b => a => non più accessbile
                            a => -2
                */
            //se devo togliere un indice dal giro delle mappe,

            for (pratica__c p : [Select id, Residuo_Totale__c from pratica__c where id in :recordsSelected WITH SECURITY_ENFORCED order by Residuo_Totale__c Desc]) {
                m++;
                valMappaRRR(rIc, drList, prr, prrr);
                drList[ric.i].l.Affidamenti_support_Scaduto_Affidato__c += p.Residuo_Totale__c;
                drList[ric.i].l.Affidamenti_support_numero_affidi__c++;
                drList[ric.i].l.Affidamenti_support_Percentuale_effettiv__c = (drList[ric.i].l.Affidamenti_support_numero_affidi__c / k) * 100;
                drList[ric.i].mapTaskPratica.put(p.id, PraticaIdtaskId.get(p.id));

                ric.nexti(prrr, prr);
            }
        } catch (Exception e) {
            throw new AffidamentilottizzazioneCTRLException('Mess:' + i + '\n\n' + 'prrr:' + prrr + '\n\n' + 'prr:' + prr + '\n\n' + 'error:' + utils.getExceptionInString(e));
        }
    }

    // ValRicorsivo per Reverse - Round -Robin
    public static void valMappaRRR(rrrIconfig rIc, List<DistribResult> drList, Map<Integer, Integer> prr, Map<Integer, Integer> prrr) {
        if (!ric.isLast) {
            if (((drList[ric.i].l.Affidamenti_support_numero_affidi__c / ric.k) * 100) >= drList[ric.i].l.Affidamenti_support_Percentuale__c) {
                integer x, y;
                x = prrr.get(ric.i);
                y = prr.get(ric.i);
                prr.put(x, y);
                prrr.put(y, x);
                ric.nexti(prrr, prr);
                valMappaRRR(rIc, drList, prr, prrr);
            }
        }
    }

    public class rrrIconfig {
        integer oldi, i, k;
        boolean roundIndex, isLast;
        public rrrIconfig() {
            oldi = 0;
            i = 0;
            roundIndex = true;
            isLast = false;
        }
        public void nexti(map<integer, integer> prrr, map<integer, integer> prr) {
            oldi = i;
            //gestire new index
            if (roundIndex) {
                i = prr.get(i);
                if (i == -1) {
                    i = prrr.get(i);
                    roundIndex = false;
                }
            } else {
                i = prrr.get(i);
                if (i == -2) {
                    i = prr.get(i);
                    roundIndex = true;
                }
            }
            if (i == -1 || i == -2) {
                i = oldi;
                isLast = true;
            }
        }
    }

    public void processFifo() {
        integer i = 0, k = recordsSelected.size(), l = drList.size();
        for (pratica__c p : [Select id, Residuo_Totale__c from pratica__c where id in :recordsSelected WITH SECURITY_ENFORCED order by Residuo_Totale__c Desc]) {
            if ((drList[i].l.Affidamenti_support_numero_affidi__c / k * 100) >= drList[i].l.Affidamenti_support_Percentuale__c) {
                drList[i].l.Affidamenti_support_Percentuale_effettiv__c = drList[i].l.Affidamenti_support_numero_affidi__c / k * 100;
                if ((i + 1) < l)i++;
            }
            if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Residuo_Totale__c', gd).get('ACCESS')) {
                drList[i].l.Affidamenti_support_Scaduto_Affidato__c += p.Residuo_Totale__c;
                drList[i].l.Affidamenti_support_numero_affidi__c++;
                drList[i].l.Affidamenti_support_Percentuale_effettiv__c = drList[i].l.Affidamenti_support_numero_affidi__c / k * 100;
                drList[i].mapTaskPratica.put(p.id, PraticaIdtaskId.get(p.id));
            }
        }
    }
    //Gestione dei collector da selezionare
    public list<SelectOption> collectorSelezionabili { get; set; }
    public list<SelectOption> collectorSelezionati { get; set; }

    //GEstione algoritmo
    public list<selectoption> algoritmi {
        get {
            if (algoritmi == null) {
                algoritmoScelto = 'RR';
                algoritmi = new list<SelectOption>();
                algoritmi.add(new SelectOption('RR', 'Round Robin - ABAB'));
                algoritmi.add(new SelectOption('RRR', 'Reverse Round Robin - ABBA'));
                algoritmi.add(new SelectOption('FIFO', 'FIFO - AABB'));
            }
            return algoritmi;
        }
        set;
    }
    public string algoritmoScelto { get; set; }

    // Lista dei affidamenti da visualizzare
    public list<TPratica> listTPraticaSelectable { get; set; }
    public set<string> recordsSelected;
    public set<string> recordsUnSelected;
    public void SelectAll() {
        if (bAllSel) {
            recordsSelected.addAll(recordsUnSelected);
            recordsUnSelected = new set<string>();
        } else {
            recordsUnSelected.addAll(recordsSelected);
            recordsSelected = new set<string>();
        }
        for (TPratica tb : listTPraticaSelectable) {
            tb.isS = bAllSel;
        }
    }

    //variabili per gestione dei dati da visualizzare
    public boolean BAllSel { get; set; }//Indica seleziona deseleziona tutti
    public Integer Indice { get; set; }
    public Integer TotalSize { get; set; }
    public integer maxTasksLottizzazione { get; set; }
    public string recordsForPage { get {if (recordsForPage == null) return '25'; return recordsForPage;} set; }

    public integer RecXPage {
        get {
            if (recordsForPage == null) RecXPage = 0;
            else RecXPage = integer.valueOf(recordsForPage);
            return RecXPage;
        }
        set;
    }
    public void sizeTable() {
        saveState();
        indice = 0;
        RecXPage = integer.valueOf(recordsForPage);
        executeQueryWithFilters();
    }
    public List<SelectOption> recordsForPageValues {
        get {
            List<SelectOption> records = new list<SelectOption>();
            records.add(new SelectOption('25', '25'));
            records.add(new SelectOption('50', '50'));
            records.add(new SelectOption('100', '100'));
            records.add(new SelectOption('200', '200'));
            return records;
        }
        set;
    }

    //TaskCandidati a essere lavorati
    public map<string, string> taskIdPraticaId { get; set; }
    public map<string, string> PraticaIdtaskId { get; set; }
    public string QueryBase { get; set; }
    public string conditionBase { get; set; }

    //To manage the pagination e message comunications
    public integer numbeOfActivities { get; set; }
    public boolean thereAreLessThanLimit { get; set; }

    //scaduto
    public double scadutoDa { get; set; }
    public double scadutoA { get; set; }
    public double scadutoCDa { get; set; }
    public double scadutoCA { get; set; }
    public double scadutoSDa { get; set; }
    public double scadutoSA { get; set; }

    //Saldi
    public double saldoDA { get; set; }
    public double saldoA { get; set; }
    public double saldoCDA { get; set; }
    public double saldoCA { get; set; }
    public double saldoSDA { get; set; }
    public double saldoSA { get; set; }

    //Aging
    public date agingDa { get; set; }
    public date agingA { get; set; }

    //List of Pratiche Filtered
    public list<Pratica__c> praticaList { get; set; }
    private Boolean isConstructor { get; set; }
    public Boolean saveDisabled { get; set; }

    public List<SelectOption> configurationOptions { get; set; }
    public String configurationSelected { get; set; }
    public Boolean praticheAssegnate { get; set; }
    public Set<Id> setCollSelezionabili { get; set; }

    public affidamentiLottizzazioneCTRL() {
        praticheAssegnate = false;
        isConstructor = true;
        lforFiltro = new lotto__c();
        tipoAffidoUrl = (String.isNotBlank(ApexPages.currentPage().getParameters().get('Type'))) ? String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('Type')) : null;
        ownrUrl = (String.isNotBlank(ApexPages.currentPage().getParameters().get('ownr'))) ? String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('ownr')) : null;
        maxTasksLottizzazione = TagHelper.getValueInteger('MaxLottizzazione');
        if (maxTasksLottizzazione == null) maxTasksLottizzazione = 500;
        QueryBase = 'SELECT id,Name,Comune__c,Account__c,Account__r.id,Account__r.Name,Owner_contratto__c, Residuo_Totale__c,Anzianit_Pratica__c, Tipo_Servizio__c, strategia__r.nome__c,Servizio_Fornitura__r.LookupContratto__r.id_Esterno__c,Servizio_Fornitura__r.LookupContratto__r.id  FROM Pratica__c ';
        if (recXPage == null) recXPage = 25;
        indice = 0;
        BAllSel = true;
        collectorSelezionati = new list<SelectOption>();
        numbeOfActivities = 0;
        thereAreLessThanLimit = false;
        TotalSize = 0;
        recordsSelected = new Set<string>();
        recordsUnSelected = new Set<string>();
        categorieCollector = ImpostaCategorieCollector(tipoAffidoUrl);
        collectorSelezionabili = impostaCollectorSelezionabili();

        impostaSavedConfigurations();
        configuraLeStrategieDisponibili();
        /* 20170308 MSALA - INIZIO*/
        //Map<Id, Boolean> mPraticheSelezionate = new Map<Id, Boolean>();
        idLog = ApexPages.currentPage().getParameters().get('idLog');
        if (idLog != null && String.isNotBlank(idLog)) {
            //CRABB_DEV__Log__c jsonResult = [SELECT  Integration_Json_file_data__c FROM Log__c WHERE Id = :idLog Limit 1];
            CRABB_DEV__Log__c jsonResult = [SELECT Integration_Json_file_data__c FROM Log__c WHERE Id = :idLog WITH SECURITY_ENFORCED Limit 1];
            if (jsonResult != null) {
                //System.debug('**** ' + ApexPages.currentPage().getParameters().get('jsonmap') + ' ****');
                //System.debug('**** ' + (Map<Id, Boolean>)JSON.deserialize(ApexPages.currentPage().getParameters().get('jsonmap'),Map<Id, Boolean>.class) + ' ****');
                mPraticheSelezionate = (Map<Id, Boolean>) JSON.deserialize(jsonResult.Integration_Json_file_data__c, Map<Id, Boolean>.class);
            }
        }
        Set<Id> sPratId = new Set<Id>();
        taskIdPraticaId = new map<string, string>();
        PraticaIdtaskId = new map<string, string>();
        totalSize = 0;
        for (Id pid : mPraticheSelezionate.keySet()) {
            if (mPraticheSelezionate.get(pid)) {
                sPratId.add(pid);
                recordsSelected.add(pid);
            }
        }
        if (mPraticheSelezionate != null) {
            for (task t : [
                    Select id, whatId
                    From Task
                    where ActivityExtended__r.id_attivita__c in :stepAttiveID
                    and status in ('Non Iniziata')
                    and ActivityExtended__r.id_affidamento__c = null
                    and whatId in :sPratId
                    WITH SECURITY_ENFORCED
                    order by createdDate
                            Desc
                    limit 50000
            ]) {
                taskIdPraticaId.put(t.id, t.whatid);
                PraticaIdtaskId.put(t.whatid, t.id);
                totalSize += 1;
            }
        }

        if (collectorSelezionabili != null && !collectorSelezionabili.isEmpty() && collectorSelezionabili.size() == 1) {

            praticheAssegnate = true;
            collectorSelezionati.addAll(collectorSelezionabili);
            congelaDati();

        }

        //throw new Utils.BalanceException('HHH:'+ taskIdPraticaId);
        if (taskIdPraticaId == null) {
            try {
                TasksCandidatiAEssereProcesssati();
            } catch (Exception e) {
                throw new AffidamentilottizzazioneCTRLException(e.getMessage() + '\n line:' + e.getLineNumber() + '\n stackTrace:' + e.getStackTRaceString() + '\\n stepAttiveID:' + stepAttiveID + '\\n :' + strategiaDisponibili);
            }
        }

        /* 20170308 MSALA - FINE*/
    }

    public void impostaSavedConfigurations() {
        List<CollectorAlgoritmoConfiguration__c> allConfig = CollectorAlgoritmoConfiguration__c.getAll().values();
        configurationOptions = new List<SelectOption>();
        configurationOptions.add(new SelectOption('', '-- None --'));
        configurationSelected = '';
        if (allConfig != null && !allConfig.isEmpty()) {

            for (CollectorAlgoritmoConfiguration__c cac : allConfig) {
                Boolean addToOptions = true;

                List<String> splitlist = cac.CollectorId__c.split(';');
                for (String str : splitlist) {
                    if (!setCollSelezionabili.contains(str)) {
                        addToOptions = false;
                        break;
                    }
                }

                if (addToOptions) {
                    if (cac.Algoritmo__c.equalsIgnoreCase('RR')) {
                        configurationOptions.add(new SelectOption(cac.Name, cac.Collector__c + ' | Round Robin - ABAB | ' + cac.AllPercentage__c));
                    } else if (cac.Algoritmo__c.equalsIgnoreCase('RRR')) {
                        configurationOptions.add(new SelectOption(cac.Name, cac.Collector__c + ' | Reverse Round Robin - ABBA | ' + cac.AllPercentage__c));
                    } else {
                        configurationOptions.add(new SelectOption(cac.Name, cac.Collector__c + ' | FIFO - AABB | ' + cac.AllPercentage__c));
                    }
                }
            }
        }
    }

    public void DelLog() {
        if (idLog != null) {

            //List<Log__c> logToDelete = [SELECT Id FROM Log__c WHERE Id = :idLog ];
            List<Log__c> logToDelete = [SELECT Id FROM Log__c WHERE Id = :idLog WITH SECURITY_ENFORCED];
            try {

                if (Utils.cebCheckObjPermission('Log__c', gd).get('DELETE') && logToDelete != null && !logToDelete.isEmpty()) {

                    if (!isConstructor) {
                        delete logToDelete;
                    }
                }

            } catch (DmlException e) {

            }

        }
        isConstructor = false;
    }

    //Metodo che genera e recupera i record lavorabili in questa sessione 
    public void TasksCandidatiAEssereProcesssati() {
        List<Task> tList = new List<Task>();
        taskIdPraticaId = new map<string, string>();
        PraticaIdtaskId = new map<string, string>();
        Set<string> tSet = new Set<string>();
        //if(ownrUrl!=null && ownrUrl!='') {
        if (ownrUrl != null && ownrUrl != '') {
            for (task t : [Select id, whatId From Task where ActivityExtended__r.id_attivita__c in :stepAttiveID and status in ('Non Iniziata') and ActivityExtended__r.id_affidamento__c = null and ActivityExtended__r.Owner_contratto__c = :ownrUrl WITH SECURITY_ENFORCED order by createdDate Desc limit :maxTasksLottizzazione]) {
                taskIdPraticaId.put(t.id, t.whatid);
                PraticaIdtaskId.put(t.whatid, t.id);
            }
        } else {
            for (task t : [Select id, whatId From Task where ActivityExtended__r.id_attivita__c in :stepAttiveID and status in ('Non Iniziata') and ActivityExtended__r.id_affidamento__c = null WITH SECURITY_ENFORCED order by createdDate Desc limit :maxTasksLottizzazione]) {
                taskIdPraticaId.put(t.id, t.whatid);
                PraticaIdtaskId.put(t.whatid, t.id);
            }
        }
        if (taskIdPraticaId.size() > 0) {
            tSet.addAll(taskIdPraticaId.Values());
        }
        totalSize = checkRecordsProcessabili();
        thereAreLessThanLimit = (totalSize < maxTasksLottizzazione);
    }
    public string getPraticaIds() {
        return '' + taskIdPraticaId.values();
    }
    public void saveState() {
        if (listTPraticaSelectable != null && listTPraticaSelectable.size() > 0) {
            for (TPratica tb : listTPraticaSelectable) {
                if (tb.isS) {
                    recordsSelected.add(tb.p.id);
                    recordsUnSelected.remove(tb.p.id);
                } else {
                    recordsSelected.remove(tb.p.id);
                    recordsUnSelected.add(tb.p.id);
                }
            }
        }
    }
    public integer checkRecordsProcessabili() {
        list<id> praticaIDs = taskIdPraticaId.values();
        String effectiveQuery;
        if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')) {
            effectiveQuery = 'Select count() From Pratica__c' + ' Where id in:praticaIDs and Stato__c in(\'Bloccata\',\'In Lavorazione\') ';
        }
        //string effectiveQuery='Select count() From Pratica__c'+' Where id in:praticaIDs and Stato__c in(\'Bloccata\',\'In Lavorazione\') ';
        //effectiveQuery+=' limit ' + maxTasksLottizzazione;
        effectiveQuery += ' limit :maxTasksLottizzazione';
        return Database.countQuery(effectiveQuery);

    }
    public void queryAllRecordS() {
        list<id> praticaIDs = taskIdPraticaId.values();
        // inizio nuovo codice 12/04/17 inserimento CheckFLSPermission
        if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Anzianit_Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Check_In_Lavorazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Esecuzione_Processo_Mensile__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Blocco__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Chiusura__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Dettaglio_Stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Incasso_Consolidato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Motivo_Blocco__c', gd).get('ACCESS')) {

            string effectiveQuery = QueryBase + ' Where id in:praticaIDs and Stato__c in(\'Bloccata\',\'In Lavorazione\') ';

            effectiveQuery += ' ' + stringWithFilters();
            effectiveQuery += ' Order by createdDAte Asc ';
            //effectiveQuery+=' limit '+TotalSize;
            effectiveQuery += ' limit :TotalSize';
            recordsSelected = new Set<string>();
            recordsUnSelected = new Set<string>();
            try {
                for (Pratica__c p : Database.Query(effectiveQuery)) {
                    recordsSelected.add(p.id);
                }
            } catch (Exception e) {
                ErrorClass.logError('AffidamentilottizzazioneCTRL-603', effectiveQuery);
                throw new AffidamentilottizzazioneCTRLException(effectiveQuery);
            }
            totalSize = recordsSelected.size();
        }
        // fine nuovo codice 12/04/17 inserimento CheckFLSPermission
    }
    public void executeQueryWithFilters() {
        list<id> praticaIDs = taskIdPraticaId.values();
        List<TPratica> tempTP = new List<TPratica>();

        // inizio nuovo codice 12/04 inserimento checkpermission
        if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Anzianit_Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Check_In_Lavorazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Esecuzione_Processo_Mensile__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Blocco__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Chiusura__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Dettaglio_Stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Incasso_Consolidato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Motivo_Blocco__c', gd).get('ACCESS')) {
            string effectiveQuery = QueryBase + 'Where id in:praticaIDs and Stato__c in(\'Bloccata\',\'In Lavorazione\') ';
            effectiveQuery += ' ' + stringWithFilters();
            effectiveQuery += ' Order by createdDAte Asc ';
            //effectiveQuery+=' limit '+recXPage+' OFFSET '+indice*RecXPage;
            Integer iOffset = indice * RecXPage;
            effectiveQuery += ' limit :recXPage OFFSET :iOffset';
            queryExecuted = effectiveQuery;
            List<Pratica__c> listPraticaToView = Database.Query(effectiveQuery);
            if (recordsSelected == null) recordsSelected = new Set<string>();
            if (recordsUnSelected == null) recordsUnSelected = new Set<string>();
            queryExecuted = QueryBase + 'Where id in:' + praticaIDs + ' ' + stringWithFilters() + ' Order by createdDAte Asc ' + ' limit ' + recXPage + ' OFFSET ' + indice * RecXPage;

            try {
                for (Pratica__c p : listPraticaToView) {
                    if (!recordsSelected.contains(p.id) && !recordsUnSelected.contains(p.id)) recordsSelected.add(p.id);
                    if (recordsSelected.contains(p.id)) tempTP.add(new TPratica(true, p));
                    else tempTP.add(new TPratica(false, p));
                    listTPraticaSelectable = tempTP;
                }
                //throw new AffidamentilottizzazioneCTRLException('listTPraticaSelectable:'+listTPraticaSelectable);
            } catch (Exception e) {
                //throw new AffidamentilottizzazioneCTRLException('listTPraticaSelectable:'+listTPraticaSelectable);
                throw new AffidamentilottizzazioneCTRLException('error:' + e.getMessage() + '\n line' + e.getLineNumber() + '\n stack:' + e.getStackTraceString());
            }
        }
        // fine nuovo codice 12/04 inserimento checkpermission
    }

    //Classi di rischio
    public list<string> classiDiRischioScelti { get; set; }
    public list<string> classiDiRischio {
        get {
            if (ClassiDiRischio == null) {
                ClassiDiRischio = new List<string>();
                ClassiDiRischio.add('A0'); ClassiDiRischio.add('A1'); ClassiDiRischio.add('A2'); ClassiDiRischio.add('A3'); ClassiDiRischio.add('A4');
                ClassiDiRischio.add('B0'); ClassiDiRischio.add('B1'); ClassiDiRischio.add('B2'); ClassiDiRischio.add('B3'); ClassiDiRischio.add('B4');
                ClassiDiRischio.add('C0'); ClassiDiRischio.add('C1'); ClassiDiRischio.add('C2'); ClassiDiRischio.add('C3'); ClassiDiRischio.add('C4');
                ClassiDiRischio.add('D0'); ClassiDiRischio.add('D1'); ClassiDiRischio.add('D2'); ClassiDiRischio.add('D3'); ClassiDiRischio.add('D4');
            }
            return ClassiDiRischio;
        }
        set;

    }

    //Servizio filtri

    public list<string> serviziSelezionati { get; set; }
    public list<string> serviziDisponibili {
        get {
            if (serviziDisponibili == null) {
                serviziDisponibili = new List<string>();
                Map<string, Schema.RecordTypeInfo> nameID = Schema.SObjectType.Servizio__c.getRecordTypeInfosByDeveloperName();
                //Map<string, Schema.RecordTypeInfo> nameID=Schema.SObjectType.Servizio__c.getRecordTypeInfosByName();
                for (string s : nameID.keyset()) {
                    serviziDisponibili.add(s);
                }
            }
            return serviziDisponibili;

        }
        set;

    }
    //Strategia filtri
    public list<string> strategiaSelezionati { get; set; }
    public list<string> strategiaAttiveID { get; set; }
    public list<string> stepAttiveID { get; set; }
    public list<string> strategiaDisponibili { get; set; }

    //Contratti filtri
    public list<string> contrattiSelezionati { get; set; }
    public list<string> contrattiDisponibili {
        get {
            //if(contrattiDisponibili==null){
            if (contrattiDisponibili == null) {
                contrattiDisponibili = new List<string>();
                //List<Contratto__c> contrList = new List<Contratto__c>([Select id_Esterno__c from Contratto__c LIMIT 50000]);
                List<Contratto__c> contrList = new List<Contratto__c>([Select id_Esterno__c from Contratto__c WITH SECURITY_ENFORCED LIMIT 50000]);
                for (Contratto__c c : contrList) {
                    contrattiDisponibili.add(c.id_Esterno__c);
                }
            }
            return contrattiDisponibili;

        }
        set;
    }

    //Comuni filtri
    public list<string> comuniSelezionati { get; set; }
    public list<string> comuniDisponibili {
        get {
            set<string> setComune = new set<String>();
            //if(comuniDisponibili==null){
            if (comuniDisponibili == null && Utils.cebCheckObjPermission('Contratto__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Contratto__c', 'Comune__c', gd).get('ACCESS')) {
                comuniDisponibili = new List<string>();

                List<Contratto__c> contrList = new List<Contratto__c>([Select Comune__c from Contratto__c LIMIT 50000]);
                for (Contratto__c c : contrList) {
                    setComune.add(c.Comune__c);
                }
            }
            comuniDisponibili.addAll(setComune);

            return comuniDisponibili;

        }
        set;

    }

    //Servizio stati pratica
    public list<string> statiPraticaSelezionati { get; set; }
    public list<string> statiPratica {
        get {
            if (statiPratica == null) {
                statiPratica = new List<string>();
                statiPratica.add('In Lavorazione');
                statiPratica.add('Bloccata');
            }
            return statiPratica;
        }
        set;

    }

    public PageReference RefreshRB() {
        return null;
    }
    public pageReference AnnullaFiltri() {
        return Page.GestioneAffidamenti;
    }
    public pageReference lavoraPreLottidaPreLotti() {
        PageReference pageRef = new PageReference('/');
        pageRef.setRedirect(true);
        return pageRef;
    }
    public pageReference homeDaPreLotti() {
        PageReference pageRef = new PageReference('/');
        pageRef.setRedirect(true);
        return pageRef;
    }
    public pageReference IndietroDaViewDataAdFiltri() {
        PageReference urlpage2 = Page.newLottizzazione;
        urlpage2.getParameters().put('Type', tipoAffidoUrl);
        //string urlpage='/apex/'+Utils.NAMESPACE+'newLottizzazione?Type='+tipoAffidoUrl;
        if (ownrUrl != null) urlpage2.getParameters().put('ownr', ownrUrl);//urlpage+='&ownr='+ownrUrl;
        //PageReference pageRef = new PageReference(urlpage);
        urlpage2.setRedirect(true);
        return urlpage2;
    }
    public pageReference IndietroAlgortmi() {
        return Page.TaskSemiAutomatici;
    }
    public pageReference IndietroDaAlgortmi() {
        return Page.TaskSemiAutomatici;
    }
    public pageReference ProseguiFiltri() {
        queryAllRecordS();
        executeQueryWithFilters();
        return Page.AffidamentiViewData;
    }
    public pageReference ProseguiAlgoritmi() {
        saveState();
        if (recordsSelected == null || recordsSelected.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, 'Devi selezionare almeno una pratica per poter procedere con la creazione dei lotti.'));
            return null;
        }
        return Page.AffidamentiConfermaLotti;
    }

    public void UpdateListe() {
        try {
            /*String sElenco = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('ValSelected'));
            Integer iIndex = Integer.valueOf(String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('IndexSelected')));*/
            String sElenco = Apexpages.currentPage().getParameters().get('ValSelected').escapeHtml4();
            Integer iIndex = Integer.valueOf(Apexpages.currentPage().getParameters().get('IndexSelected').escapeHtml4());

            List<String> elenco = sElenco.split(',');

            if (iIndex == 0) {
                // Strategie
                if (strategiaSelezionati == null) strategiaSelezionati = new list<string>();
                if (sElenco != '') {
                    for (string s : elenco)
                        strategiaSelezionati.add(s);
                }
            } else if (iIndex == 1) {
                // Contratti
                if (contrattiSelezionati == null) contrattiSelezionati = new list<string>();
                if (sElenco != '') {
                    for (string s : elenco)
                        contrattiSelezionati.add(s);
                }
            } else if (iIndex == 2) {
                // Comuni
                if (comuniSelezionati == null) comuniSelezionati = new list<string>();
                if (sElenco != '') {
                    for (string s : elenco)
                        comuniSelezionati.add(s);
                }
            } else if (iIndex == 3) {
                // Servizi
                if (serviziSelezionati == null) serviziSelezionati = new list<string>();
                if (sElenco != '') {
                    for (string s : elenco)
                        serviziSelezionati.add(s);
                }
            } else if (iIndex == 4) {
                // Stato Pratica
                if (statiPraticaSelezionati == null) statiPraticaSelezionati = new list<string>();
                if (sElenco != '') {
                    for (string s : elenco)
                        statiPraticaSelezionati.add(s);
                }
            } else if (iIndex == 5) {
                // Classe di rischio
                if (classiDiRischioScelti == null) classiDiRischioScelti = new list<string>();
                if (sElenco != '') {
                    for (string s : elenco)
                        classiDiRischioScelti.add(s);
                }
            }

        } catch (Exception e) {
            System.Debug('Eccezione nel metodo UpdateListe: ' + e.getMessage());
        }
    }

    public string getStringFilters() {
        list<id> praticaIDs = taskIdPraticaId.values();
        string effectiveQuery = QueryBase + 'Where id in:(' + praticaIDs + ')' ;
        return 'condition: ' + stringWithFilters() + '<br/> scadutoDa:' + scadutoDa;
    }

    public string stringWithFilters() {
        string conditionQuery = '';
        if (statiPraticaSelezionati != null && statiPraticaSelezionati.size() > 0) {
            set<string> statiSet = new set<string>();
            statiSet.addAll(statiPraticaSelezionati);
            if (statiSet.contains('In Lavorazione') && statiSet.contains('Bloccata')) {
                conditionQuery += ' And ( Stato__c=\'In Lavorazione\' or ( Stato__c=\'Bloccata\' and is_Blocco_PDR__c=true )) ';
            } else if (statiSet.contains('In Lavorazione'))
                conditionQuery += ' And Stato__c=\'In Lavorazione\' ';
            else if (statiSet.contains('Bloccata'))
                conditionQuery += ' And Stato__c=\'Bloccata\' and is_Blocco_PDR__c=true ';
        }

        //if(strategiaSelezionati!=null && strategiaSelezionati.size() > 0){ conditionQuery += ' And Strategia__r.Nome__c in ' +Utils.inStrings(strategiaSelezionati); }
        if (strategiaSelezionati != null && strategiaSelezionati.size() > 0) {
            String sStrategiaSelezionati = Utils.inStrings(strategiaSelezionati);
            conditionQuery += ' And Strategia__r.Nome__c in :sStrategiaSelezionati';
        }

        //if(comuniSelezionati!=null && comuniSelezionati.size() > 0){ conditionQuery += ' And Servizio_Fornitura__r.LookupContratto__r.Comune__c in ' +Utils.inStrings(comuniSelezionati); }
        if (comuniSelezionati != null && comuniSelezionati.size() > 0) {
            String sComuniSelezionati = Utils.inStrings(comuniSelezionati);
            conditionQuery += ' And Servizio_Fornitura__r.LookupContratto__r.Comune__c in :sComuniSelezionati';
        }

        //if(contrattiSelezionati!=null && contrattiSelezionati.size() > 0){ conditionQuery += ' And Servizio_Fornitura__r.LookupContratto__r.id_Esterno__c in ' +Utils.inStrings(contrattiSelezionati); }
        if (contrattiSelezionati != null && contrattiSelezionati.size() > 0) {
            String sContrattiSelezionati = Utils.inStrings(contrattiSelezionati);
            conditionQuery += ' And Servizio_Fornitura__r.LookupContratto__r.id_Esterno__c in :sContrattiSelezionati';
        }

        //if(serviziSelezionati!=null && serviziSelezionati.size() > 0){ conditionQuery += ' And Servizio_Fornitura__r.RecordType.Name in ' +Utils.inStrings(serviziSelezionati); }
        if (serviziSelezionati != null && serviziSelezionati.size() > 0) {
            String sServiziSelezionati = Utils.inStrings(serviziSelezionati);
            conditionQuery += ' And Servizio_Fornitura__r.RecordType.Name in :sServiziSelezionati';
        }

        if (classiDiRischioScelti != null && classiDiRischioScelti.size() > 0) {
            //conditionQuery += ' And Account__r.Classe_di_Rischio__c in ' +Utils.inStrings(classiDiRischioScelti);
            String sClassiDiRischioScelti = Utils.inStrings(classiDiRischioScelti);
            conditionQuery += ' And Account__r.Classe_di_Rischio__c in :sClassiDiRischioScelti';
        }

        if (lforFiltro.FF_scaduto_da__c != null && lforFiltro.FF_scaduto_da__c > 0) {
            //conditionQuery += ' And Residuo_Totale__c >= '+lforFiltro.FF_scaduto_da__c ; 
            conditionQuery += ' And Residuo_Totale__c >= :lforFiltro.FF_scaduto_da__c' ;
        }

        if (lforFiltro.FF_scaduto_a__c != null && lforFiltro.FF_scaduto_a__c > 0) {
            //conditionQuery += ' And Residuo_Totale__c <= '+lforFiltro.FF_scaduto_a__c ;
            conditionQuery += ' And Residuo_Totale__c <= :lforFiltro.FF_scaduto_a__c';
        }

        if (lforFiltro.FF_scaduto_consolidato_da__c != null && lforFiltro.FF_scaduto_consolidato_da__c > 0) {
            //conditionQuery += ' And Importo_Scaduto_Consolidato__c >= '+lforFiltro.FF_scaduto_consolidato_da__c ;
            conditionQuery += ' And Importo_Scaduto_Consolidato__c >= :lforFiltro.FF_scaduto_consolidato_da__c';
        }

        if (lforFiltro.FF_scaduto_consolidato_a__c != null && lforFiltro.FF_scaduto_consolidato_a__c > 0) {
            //conditionQuery += ' And Importo_Scaduto_Consolidato__c <= '+lforFiltro.FF_scaduto_consolidato_a__c ;
            conditionQuery += ' And Importo_Scaduto_Consolidato__c <= :lforFiltro.FF_scaduto_consolidato_a__c';
        }

        if (lforFiltro.FF_scaduto_spese_da__c != null && lforFiltro.FF_scaduto_spese_da__c > 0) {
            conditionQuery += ' And Scaduto_Spese__c >= :lforFiltro.FF_scaduto_spese_da__c';
        }

        if (lforFiltro.FF_scaduto_spese_a__c != null && lforFiltro.FF_scaduto_spese_a__c > 0) {
            //conditionQuery += ' And Scaduto_Spese__c <= '+lforFiltro.FF_scaduto_spese_a__c ;
            conditionQuery += ' And Scaduto_Spese__c <= :lforFiltro.FF_scaduto_spese_a__c';
        }

        if (lforFiltro.FF_saldo_da__c != null && lforFiltro.FF_saldo_da__c > 0) {
            //conditionQuery += ' And Saldo__c >= '+lforFiltro.FF_saldo_da__c ;
            conditionQuery += ' And Saldo__c >= :lforFiltro.FF_saldo_da__c';
        }

        if (lforFiltro.FF_saldo_a__c != null && lforFiltro.FF_saldo_a__c > 0) {
            //conditionQuery += ' And Saldo__c <= '+lforFiltro.FF_saldo_a__c ;
            conditionQuery += ' And Saldo__c <= :lforFiltro.FF_saldo_a__c';
        }

        if (lforFiltro.FF_saldo_consolidato_da__c != null && lforFiltro.FF_saldo_consolidato_da__c > 0) {
            //conditionQuery += ' And Importo_saldo_Consolidato__c >= '+lforFiltro.FF_saldo_consolidato_da__c ;
            conditionQuery += ' And Importo_saldo_Consolidato__c >= :lforFiltro.FF_saldo_consolidato_da__c';
        }

        if (lforFiltro.FF_saldo_consolidato_a__c != null && lforFiltro.FF_saldo_consolidato_a__c > 0) {
            //conditionQuery += ' And Importo_saldo_Consolidato__c <= '+lforFiltro.FF_saldo_consolidato_a__c ;
            conditionQuery += ' And Importo_saldo_Consolidato__c <= :lforFiltro.FF_saldo_consolidato_a__c';
        }

        if (lforFiltro.FF_saldo_spese_da__c != null && lforFiltro.FF_saldo_spese_da__c > 0) {
            //conditionQuery += ' And Saldo_Spese__c >= '+lforFiltro.FF_saldo_spese_da__c ; 
            conditionQuery += ' And Saldo_Spese__c >= :lforFiltro.FF_saldo_spese_da__c';
        }

        if (lforFiltro.FF_saldo_spese_a__c != null && lforFiltro.FF_saldo_spese_a__c > 0) {
            //conditionQuery += ' And Saldo_Spese__c <= '+lforFiltro.FF_saldo_spese_a__c ;
            conditionQuery += ' And Saldo_Spese__c <= :lforFiltro.FF_saldo_spese_a__c';
        }

        if (lforFiltro.FF_ageing_pratica_da__c != null) {
            agingDa = lforFiltro.FF_ageing_pratica_da__c;
            conditionQuery += ' And Anzianit_Pratica__c >=: agingDa';
        }

        if (lforFiltro.FF_ageing_pratica_a__c != null) {
            agingA = lforFiltro.FF_ageing_pratica_a__c;
            conditionQuery += ' And Anzianit_Pratica__c <=: agingA';
        }

        return conditionQuery;
    }

    //metodi per gestione paginazione
    public void Beginning() {
        saveState();
        Indice = 0; executeQueryWithFilters();
    }
    public void Previous() {
        saveState();
        if (indice > 0) {
            Indice--; executeQueryWithFilters();
        }
    }
    public void Next() {
        saveState();
        if (recXPage < TotalSize && indice * recXPage < TotalSize) {
            Indice++; executeQueryWithFilters();
        }
    }
    public void End() {
        saveState();
        indice = integer.valueof(TotalSize / recXPage); executeQueryWithFilters();
    }
    public boolean getIsBeginningVisibility() {
        return indice > 0;
    }
    public boolean getIsEndVisibility() {
        if (recXPage >= TotalSize) return false;
        return indice < integer.valueof(TotalSize / recXPage);
    }


    public list<string> ImpostaCategorieCollector(string myTipoAffido) {
        //List<Collector_Tipo_Affido__c> mcs = Collector_Tipo_Affido__c.getall().values();
        List<Collector_con_Tipo_Affido__c> mcs = Collector_con_Tipo_Affido__c.getall().values();
        list<string> cc = new list<string>();
        tipoAffido = myTipoAffido;
        for (Collector_con_Tipo_Affido__c c : mcs) {
            if (c.Tipo_Affido__c == tipoAffido) cc.add(c.Categoria_Collector__c);
        }
        return cc;
    }
    public void configuraLeStrategieDisponibili() {
        if (strategiaDisponibili == null) {
            strategiaDisponibili = new List<string>();
            strategiaAttiveID = new List<string>();
            stepAttiveID = new List<string>();
            tipoAffido = (String.isBlank(tipoAffido)) ? '' : String.escapeSingleQuotes(tipoAffido);

            // inizio nuovo codice 12/04/17 inserimento checkpermission
            if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'Anzianita_scaduto__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'BaseType__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'CAP_Massimo__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'CAP_Minimo__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'Cattivo_Pagatore__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'Data_attivazione__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'Data_disattivazione_strategia__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'Descrizione__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'Esito__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'Tipologia__c', gd).get('ACCESS')) {
                string myqueryOnStrategia = 'Select id, nome__c,testata__c,testata__r.nome__c  from Strategia__c where recordType.Name=\'Step\' and testata__r.stato__c=\'Attiva\' and  Sotto_tipo_attivita__c=\'' + String.escapeSingleQuotes(tipoAffido) + '\'' ;
                List<Strategia__c> strList = database.query(myqueryOnStrategia);
                for (Strategia__c s : strList) {
                    strategiaAttiveID.add(s.testata__c);
                    stepAttiveID.add(s.id);
                    strategiaDisponibili.add(s.testata__r.nome__c);
                }
            }
            // fine nuovo codice 12/04/17 inserimento checkpermission
        }
    }
    public list<SelectOption> impostaCollectorSelezionabili() {
        //if(collectorSelezionabili==null){
        if (collectorSelezionabili == null && Utils.cebCheckObjPermission('Collector__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Collector__c', 'name', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Collector__c', 'Ragione_Sociale__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Collector__c', 'Percentuale_Affido_Standard__c', gd).get('ACCESS')) {
            list<SelectOption> str = new List<SelectOption>();
            setCollSelezionabili = new Set<Id>();
            for (Collector__c c : [Select id, name, Ragione_Sociale__c, Percentuale_Affido_Standard__c from Collector__c where Tipo_Collector__c in :categorieCollector WITH SECURITY_ENFORCED ]) {
                setCollSelezionabili.add(c.Id);
                str.add(new SelectOption(c.id, c.Ragione_Sociale__c));
            }
            return str;
        }
        return collectorSelezionabili;

    }
    public class TPratica implements Attributeable {
        public boolean isS { get; set; }
        public Pratica__c p { get; set; }
        public TPratica(Boolean isSelected, Pratica__c pratica) {
            this.p = pratica;
            this.isS = isSelected;
        }
    }
    public class DistribResult {
        public Lotto__c l { get; set; }
        public Map<string, string> mapTaskPratica;
        public double percentuale;

        public DistribResult() {
            l = new lotto__c();
            mapTaskPratica = new map<string, string>();
            percentuale = 0;
        }

    }

    public void saveConfiguration() {
        List<CollectorAlgoritmoConfiguration__c> listConfiguration = [SELECT Id, Name, Collector__c, Algoritmo__c, CollectorId__c, AllPercentage__c FROM CollectorAlgoritmoConfiguration__c WITH SECURITY_ENFORCED ORDER BY Name DESC LIMIT 1];
        CollectorAlgoritmoConfiguration__c newCAC = new CollectorAlgoritmoConfiguration__c();

        String newName = 'CONF_00000';
        if (listConfiguration != null && !listConfiguration.isEmpty() && listConfiguration.size() > 0) {

            Integer newIntName = Integer.valueOf(listConfiguration[0].Name.split('_')[1]) + 1;
            String tempIntName = String.valueOf(newIntName);
            while (tempIntName.length() < 5) {
                tempIntName = '0' + tempIntName;
            }
            newName = 'CONF_' + tempIntName;
        }

        if (Utils.cebCheckObjPermission('CollectorAlgoritmoConfiguration__c', gd).get('CREATE') && Utils.cebCheckFLSPermission('CollectorAlgoritmoConfiguration__c', 'AllPercentage__c', gd).get('CREATE') &&
                Utils.cebCheckFLSPermission('CollectorAlgoritmoConfiguration__c', 'Name', gd).get('CREATE') &&
                Utils.cebCheckFLSPermission('CollectorAlgoritmoConfiguration__c', 'Collector__c', gd).get('CREATE') &&
                Utils.cebCheckFLSPermission('CollectorAlgoritmoConfiguration__c', 'CollectorId__c', gd).get('CREATE') &&
                Utils.cebCheckFLSPermission('CollectorAlgoritmoConfiguration__c', 'Algoritmo__c', gd).get('CREATE')) {

            String selectedCollId = '';
            String selectedCollName = '';
            for (SelectOption so : collectorSelezionati) {
                selectedCollId += so.getValue() + ';';
                selectedCollName += so.getLabel() + ';';
            }

            if (selectedCollId.endsWith(';')) {
                selectedCollId = selectedCollId.substring(0, selectedCollId.length() - 1);
            }

            if (selectedCollName.endsWith(';')) {
                selectedCollName = selectedCollName.substring(0, selectedCollName.length() - 1);
            }

            newCAC.AllPercentage__c = '';
            for (DistribResult dr : drList) {
                newCAC.AllPercentage__c += dr.l.Affidamenti_support_Percentuale__c + ';';
            }
            newCAC.AllPercentage__c = newCAC.AllPercentage__c.substring(0, newCAC.AllPercentage__c.length() - 1);
            newCAC.Name = newName;
            newCAC.Collector__c = selectedCollName;
            newCAC.CollectorId__c = selectedCollId;
            newCAC.Algoritmo__c = algoritmoScelto;

            if (listConfiguration != null && !listConfiguration.isEmpty() && listConfiguration.size() > 0) {
                List<CollectorAlgoritmoConfiguration__c> existingConfiguration = [SELECT Id, Name, Collector__c, Algoritmo__c, CollectorId__c FROM CollectorAlgoritmoConfiguration__c WHERE Collector__c = :selectedCollName AND CollectorId__c = :selectedCollId AND AllPercentage__c = :newCAC.AllPercentage__c WITH SECURITY_ENFORCED LIMIT 1];
                if (existingConfiguration != null && !existingConfiguration.isEmpty() && existingConfiguration.size() > 0) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, 'Configurazione già presente tra quelle salvate.'));
                    saveDisabled = true;
                    return;
                }
            }
            /* if(Utils.checkObjPermission('CollectorAlgoritmoConfiguration__c').get('ACCESS') && Utils.checkObjPermission('CollectorAlgoritmoConfiguration__c').get('INSERT')){
                 insert newCAC;
             }*/
            if (Utils.cebCheckObjPermission('CollectorAlgoritmoConfiguration__c', gd).get('ACCESS')
                    && Utils.cebCheckObjPermission('CollectorAlgoritmoConfiguration__c', gd).get('INSERT')) {
                insert newCAC;
            }

            saveDisabled = true;
        }
    }

    public PageReference goBackRiepilogoTask() {
        PageReference page = new PageReference('/apex/RiepilogoTask');
        page.setRedirect(true);
        return page;
    }

}