/* ---------------------------------------------------------------------------------------------------------------------
Name:            CambioManualeAttivitaCTRLnew.cls
Description:
Test class:      TestCambioManualeAttivitaCTRLnew.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
12-Sep-2022  0.2      C.Sanna & R. Kurti              Added cebCheck Obj/FLS security and WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class CambioManualeAttivitaCTRLnew {

    /*Gestione selezioni iniziali*/
    public String StrategieSelectable { get; set; }
    public list<String> OriginalValuesStrategia { get; set; }
    public List<SelectOption> UnselectedStrategie { get; set; }
    public List<String> TaskSelectable { get; set; }
    public String TaskDa { get; set; }
    public list<String> OriginalValuesTaskDa { get; set; }
    public List<SelectOption> UnselectedTaskDa { get; set; }
    public String TaskA { get; set; }
    public list<String> OriginalValuesTaskA { get; set; }
    public List<SelectOption> UnselectedTaskA { get; set; }

    /*Gestione render pagina*/
    public Integer Step { get; set; }
    public Boolean StratIsSelected { get; set; }
    public boolean BAllSel { get; set; }

    /*Gestione paginazione/query*/
    public Id IdStrat;
    public Set<Id> IdPrat;
    public list<Pratica__c> PraticheAll;
    public String QueryPratica;
    public String QueryPraticaPag;
    public Integer RecXPage = 5;
    public Integer Indice;
    public Integer PageSize;
    public Integer TotalSize { get; set; }
    public List<String> LPrimoName;
    public Map<Id, Boolean> MapSelezione;
    public List<Task> LTask;
    public List<Task> TaskDaElaborare;
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public CambioManualeAttivitaCTRLnew() {
        TaskDa = 'NA';
        TaskA = 'NA';
        Step = 0;
        Indice = 0;
        BAllSel = true;
        OriginalValuesStrategia = new List<String>();
        OriginalValuesTaskDa = new List<String>();
        OriginalValuesTaskA = new List<String>();
        OriginalValuesStrategia.add('---');
        if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Stato__c', gd).get('ACCESS')) {
            //throw new TriggerFactory.TriggerException('QUI:'+[Select Id,Stato__c,Nome__c From Strategia__c]);
            for (Strategia__c s : [Select Nome__c From Strategia__c WHERE Stato__c = 'Attiva' AND Nome__c != '' ORDER BY Name]) {
                //for (Strategia__c s : [Select Nome__c From Strategia__c WHERE Stato__c = 'Attiva' AND Nome__c != '' WITH SECURITY_ENFORCED ORDER BY Name]) {
                OriginalValuesStrategia.add(s.Nome__c);
            }

            UnselectedStrategie = getunSelectedValues(OriginalValuesStrategia);
            StrategieSelectable = '';
            MapSelezione = new Map<Id, Boolean>();
            system.debug('Valori stringhe: ' + StrategieSelectable + ' ' + UnselectedStrategie);
        }
    }

    public List<SelectOption> getunSelectedValues(List<String> original) {
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(original);
        for (string b : tempList)
            options.add(new SelectOption(b, b));
        return options;
    }

    public pageReference RecuperaTask() {
        OriginalValuesTaskDa.clear();
        OriginalValuesTaskA .clear();
        TaskDa = 'NA';
        TaskA = 'NA';
        system.debug('****StrategieSelectable = ' + StrategieSelectable);
        if (StrategieSelectable.equalsIgnoreCase('---')) return null;
        if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Tipologia__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Testata__c', gd).get('ACCESS')) {
            IdStrat = [Select Id From Strategia__c WHERE Nome__c = :StrategieSelectable LIMIT 1].Id;
            List<Strategia__c> TaskAttivi = [SELECT Id, Nome__c, Tipologia__c FROM Strategia__c WHERE Testata__c = :IdStrat AND RecordType.Name = 'Step'];
            //List<Strategia__c> TaskAttivi = [SELECT Id, Nome__c, Tipologia__c FROM Strategia__c WHERE Testata__c = :IdStrat AND RecordType.Name = 'Step' WITH SECURITY_ENFORCED];
            system.debug('StrategiaSelected: ' + StrategieSelectable);
            for (Strategia__c s : TaskAttivi) {
                OriginalValuesTaskDa.add(s.Nome__c);
                OriginalValuesTaskA.add(s.Nome__c);
                /*if(StrategieSelectable=='STRATEGIA CONCESSIONE' && (s.Nome__c =='Gestione Manuale post diffida' || s.Nome__c == 'Attesa verifica condizioni' || s.Tipologia__c=='UI')){
                OriginalValuesTaskA.add(s.Nome__c);
            }
            if(StrategieSelectable=='STRATEGIA APPALTI' && (s.Nome__c == 'Doppio invio completato' || s.Tipologia__c=='UI')){
                OriginalValuesTaskA.add(s.Nome__c);
            }
            if(StrategieSelectable=='STRATEGIA CONCESSIONE COMUNE DI RHO' && (s.Nome__c == 'Candidato per invio lettera' || s.Tipologia__c=='UI')){
                OriginalValuesTaskA.add(s.Nome__c);
            }
            if(StrategieSelectable=='STRATEGIA AUTOMATICA MENSILE' && (s.Nome__c == 'Clienti non sollecitabili da normalizzare' || s.Tipologia__c=='UI')){
                OriginalValuesTaskA.add(s.Nome__c);
            }    */
            }

            UnselectedTaskDa = getunSelectedValues(OriginalValuesTaskDa);
            UnselectedTaskA = getunSelectedValues(OriginalValuesTaskA);
        }
        return null;
    }

    /* E.S.
     * Metodo che rifresca la seconda picklist, che
     * contiene i valori in cui, si modificerá il task(valore futuro).
     * Dettagli: Leggi il task da cambiare(TaskDa), é se esiste nel UnselectedTaskA,
     * rimuovila dal task finale in cui cambiarla.
     */

    public pageReference bonificaTask() {
        System.debug('\n *Scelta TaskDa: ' + TaskDa);

        // 1. prima di fare il cambio, rifresca la lista
        UnselectedTaskA = getunSelectedValues(OriginalValuesTaskA);

        // 2. filtra lista UnselectedTaskA
        filterListBy(TaskDa, UnselectedTaskA);

        return null;
    }

    //MSala 12/01/2015 Inizio
    public pageReference UpdateTaskDa() {
        TaskDa = apexpages.currentpage().getparameters().get('pTaskDa');

        return null;
    }

    public pageReference UpdateTaskA() {
        TaskA = apexpages.currentpage().getparameters().get('pTaskA');

        return null;
    }
    //MSala 12/01/2015 Fine

    /*
     * Metodo che rimuove da una picklist(selectOption)
     * un certo valore target su myList
     */
    public void filterListBy(String target, List<SelectOption> myList) {
        for (integer i = 0; i < myList.size(); i++) {
            if (myList[i].getValue() == target) {
                myList.remove(i);
                break;
            }
        }
    }

    // E.S.

    public pageReference Continua() {
        if (StrategieSelectable == '' || StrategieSelectable == '---') {
            StratIsSelected = true;
            return null;
        } else {
            Step++;
            StratIsSelected = false;
            Set<Id> IdStepDa = new Set<Id>();
            system.debug('***NomeStrat = ' + TaskDa);
            system.debug('***TestStrat = ' + idStrat);
            if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'Testata__c', gd).get('ACCESS')) {
                for (Strategia__c s : [
                        SELECT Id
                        FROM Strategia__c
                        WHERE RecordType.Name = 'Step' AND Nome__c = :TaskDa
                        AND Testata__c = :idStrat
                        //WITH SECURITY_ENFORCED
                ]) {
                    IdStepDa.add(s.Id);
                }
            }
            IdPrat = new Set<Id>();
            system.debug('****IdStepDa = ' + IdStepDa);
            if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
                    && Utils.cebCheckObjPermission('ActivityExtended__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'whatId', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Task', 'Status', gd).get('ACCESS')) {
                //LTask = [SELECT Id, WhatId, ActivityExtended__c FROM Task WHERE ActivityExtended__r.id_attivita__c IN :IdStepDa AND Status = 'Non Iniziata' WITH SECURITY_ENFORCED];
                LTask = [SELECT Id, WhatId, ActivityExtended__c FROM Task WHERE ActivityExtended__r.id_attivita__c IN :IdStepDa AND Status = 'Non Iniziata'];
                system.debug('****LTask.size() = ' + LTask.size());
                for (Task t : LTask) {
                    IdPrat.add(t.WhatId);
                }
            }
            if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c', gd).get('ACCESS')) {
                QueryPratica = 'SELECT Id,Name,Stato__c FROM Pratica__c WHERE Id IN :idPrat ORDER BY Name DESC';
                QueryPraticaPag = 'SELECT Id,Name,Stato__c FROM Pratica__c WHERE Id IN :idPrat AND Name <= :PrimoName ORDER BY Name DESC LIMIT 5';
                PraticheAll = database.query(QueryPratica);
            }
            system.debug('***PraticheAll = ' + PraticheAll.size());
            LPrimoName = new List<String>();
            for (integer i = 0; i < PraticheAll.size(); i++) {
                if (i == 0 || (math.mod(i, RecXPage) == 0))
                    LPrimoName.add(PraticheAll[i].name);
                MapSelezione.put(PraticheAll[i].Id, true);
            }
            TotalSize = MapSelezione.size();
            return null;
        }
    }

    public List<TabellaPratica> getlistPraticheSelectable() {
        if (LPrimoName.size() > 0) {
            String PrimoName = LPrimoName[Indice];
            // inizio nuovo codice 13/04/17 inserimento CheckFLSPermission
            if (Utils.cebCheckObjPermission('Task', gd).get('ACCESS')
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
                List<Pratica__c> ListPraticaToView = database.query(QueryPraticaPag);
                PageSize = ListPraticaToView.size();
                list<TabellaPratica> tempPrat = new list<TabellaPratica>();
                for (Pratica__c p : ListPraticaToView) {
                    boolean bSel;
                    if (MapSelezione.containsKey(p.Id))
                        bSel = true;
                    else
                            bSel = false;
                    TabellaPratica PraticaSelect = new TabellaPratica(bSel, p, p.id);
                    tempPrat.add(PraticaSelect);
                }
                return tempPrat;
            }
        }
        // fine nuovo codice 13/04/17 inserimento CheckFLSPermission
        return null;
    }

    public void Indietro() {
        Step--;
    }

    public void ConfermaSelezione() {
        Step++;
        TaskDaElaborare = new List<Task>();
        system.debug('***LTask = ' + LTask.size());
        for (Task t : LTask) {
            if (MapSelezione.containskey(t.WhatId)) {
                TaskDaElaborare.add(t);
            }
        }
        system.debug('****NomeTask = ' + TaskA);
        system.debug('*****Testata = ' + idStrat);
        //throw new TriggerFactory.TriggerException('Nome__c:'+TaskA+' Testata__c:'+idStrat);
        Id IdStepA = null;
        try {
            if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Nome__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c','Testata__c',gd).get('ACCESS')) {
                IdStepA = [SELECT Id FROM Strategia__c WHERE RecordType.Name = 'Step' AND Nome__c = :TaskA AND Testata__c = :idStrat LIMIT 1].Id;
            }
        } catch (Exception e) {
            System.debug('Errore su conferma selezione:' + e.getMessage());
            return;
        }
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        List<Id> aeids = new List<Id>();
        for (Task t : TaskDaElaborare) {
            aeids.add(t.ActivityExtended__c);
        }
        if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'isForcedOperation__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c','Go_to_Strategia__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c','go_to_task_of_strategie__c',gd).get('ACCESS')) {
            aes = [SELECT isForcedOperation__c, Go_to_Strategia__c, go_to_task_of_strategie__c FROM ActivityExtended__c WHERE Id in :aeids];
            //aes = [SELECT isForcedOperation__c, Go_to_Strategia__c, go_to_task_of_strategie__c FROM ActivityExtended__c WHERE Id in :aeids WITH SECURITY_ENFORCED];
            for (ActivityExtended__c tmp : aes) {
                ActivityExtended__c ae = new ActivityExtended__c();
                ae.isForcedOperation__c = true;
                ae.Go_to_Strategia__c = IdStrat;
                ae.go_to_task_of_strategie__c = IdStepA;
            }
        }
        if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('UPDATE') && Utils.cebCheckFLSPermission('ActivityExtended__c', 'isForcedOperation__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Go_to_Strategia__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'go_to_task_of_strategie__c', gd).get('UPDATE')
                && Utils.cebCheckObjPermission('Task', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Task', 'Subject', gd).get('UPDATE')) {
            update aes;
            update TaskDaElaborare;
        }
    }

    public pageReference AggiornaElementoLista() {
        String Sel = ApexPages.currentPage().getParameters().get('isSel').escapeHtml4();
        String Pratica = ApexPages.currentPage().getParameters().get('Codice_Pratica').escapeHtml4();

        if (MapSelezione.containsKey(Pratica) && Sel == 'true') {
            MapSelezione.remove(Pratica);
        } else if (!MapSelezione.containsKey(Pratica) && Sel == 'false')
            MapSelezione.put(Pratica, true);

        TotalSize = MapSelezione.size();

        return null;
    }

    public PageReference Beginning() {
        //user clicked beginning
        Indice = 0;
        return null;
    }

    public PageReference Previous() {
        //user clicked previous button
        Indice--;
        return null;
    }

    public PageReference Next() {
        //user clicked next button
        Indice++;
        return null;
    }

    public PageReference End() {
        //user clicked end
        Indice = LPrimoName.size() - 1;
        return null;
    }

    public Boolean getDisablePrevious() {
        //this will disable the previous and beginning buttons
        if (Indice > 0)
            return false;
        else
                return true;
    }

    public Boolean getDisableNext() {
        //this will disable the next and end buttons
        if (PageSize < RecXPage) {
            return true;
        } else
                return false;

    }

    public PageReference SelectAll() {
        return null;
    }

}