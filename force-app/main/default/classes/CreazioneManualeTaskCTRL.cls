/* ---------------------------------------------------------------------------------------------------------------------
Name:            CreazioneManualeTaskCTRL.cls
Description:
Test class:      TestCreazioneManualeTask.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
06-Feb-2015  0.1      E. Sino                         First Version
12-Sep-2022  0.2      E. Sino                         With Sharing (Security Review)
12-Sep-2022  0.3      C.Sanna & R. Kurti              Added cebCheck Obj/FLS security and WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class CreazioneManualeTaskCTRL {

    public list<String> OriginalValuesTaskDa { get; set; }
    public List<SelectOption> UnselectedTaskDa { get; set; }
    public String TaskA { get; set; }
    public boolean idPratCorretto { get; set; }
    public id idPratica { get; set; }
    public pratica__c myPrat;

    public boolean erroreHappened { get; set; }
    public string soggettoTaskDaRimuovere;

    // creazione manuale task
    public Id IdStrat;
    public String StrategieSelectable { get; set; }
    public list<String> OriginalValuesStrategia { get; set; }
    public integer numStrManuali { get; set; }
    public List<SelectOption> UnselectedStrategie { get; set; }

    public list<Strategia__c> stratSteps { get; set; }
    public integer numSteps { get; set; }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public CreazioneManualeTaskCTRL() {
        TaskA = 'NA';
        soggettoTaskDaRimuovere = '';
        erroreHappened = false;

        StrategieSelectable = '';

        OriginalValuesStrategia = new List<String>();
        OriginalValuesTaskDa = new List<String>();

        setPratId();// prendi Prat & co        
        getStrategieMan();
    }

    /*
     * PART I: Prepara ambiente di esecuzione.
     */

    // Set le id della pratica e controlla la validitá del id.
    public void setPratId() {
        try {
            this.idPratica = ApexPages.currentPage().getParameters().get('Id');
            if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Strategia__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Name', gd).get('ACCESS')) {
                this.myPrat = [Select id, Strategia__c, Name From Pratica__c where id = :this.idPratica];
                //this.myPrat = [Select id, Strategia__c, Name From Pratica__c where id = :this.idPratica WITH SECURITY_ENFORCED];

            }
            erroreHappened = false;

        } catch (Exception e) {
            System.debug('CreazioneManualeTaskCTRL setPratId(): Errore durante la richiesta in DB della pratica! Dettagli: ' + e.getMessage());
            //ErrorClass.logError('CreazioneManualeTaskCTRL, setPratId()', '\nErrore durante la richiesta in DB della pratica! \nDettagli: ' + e.getMessage());
            erroreHappened = true;
        }
    }

    // Leggi le strategie manuali
    public void getStrategieMan() {
        try {
            OriginalValuesStrategia.add('---');
            if (Utils.checkFLSPermission('Strategia__c', 'Nome__c').get('ACCESS')) {
                for (Strategia__c s : [
                        Select Nome__c
                        From Strategia__c
                        WHERE Stato__c = 'Attiva' AND Nome__c != '' And Tipo_Strategia__c = 'Manuale'
                        //        WITH SECURITY_ENFORCED
                        ORDER BY Name
                ]) {
                    OriginalValuesStrategia.add(s.Nome__c);
                }
            }
            UnselectedStrategie = getunSelectedValues(OriginalValuesStrategia);
            erroreHappened = (OriginalValuesStrategia.size() <= 1);
        } catch (Exception e) {
            //ErrorClass.logError('CreazioneManualeTaskCTRL, getStrategieMan()', '\nErrore durante la richiesta in DB dei STR! \nDettagli: ' + e.getMessage());
            System.debug('CreazioneManualeTaskCTRL setPratId(): Errore durante la richiesta in DB della pratica! Dettagli: ' + e.getMessage());
            erroreHappened = true;
        }
    }

    // Leggi i step dalla strategia manuale Dopo la scelta della str*
    public pageReference RecuperaTask() {
        OriginalValuesTaskDa.clear();
        TaskA = 'NA';
        if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Testata__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Tipologia__c', gd).get('ACCESS')) {

            //IdStrat = [Select Id From Strategia__c WHERE Nome__c = :StrategieSelectable WITH SECURITY_ENFORCED].Id;
            IdStrat = [Select Id From Strategia__c WHERE Nome__c = :StrategieSelectable].Id;
            List<Strategia__c> TaskAttivi = [
                    SELECT Nome__c
                    FROM Strategia__c
                    WHERE Testata__c = :IdStrat AND RecordType.Name = 'Step' AND Tipologia__c = 'UI'
                    //WITH SECURITY_ENFORCED
            ];
            system.debug('StrategiaSelected: ' + StrategieSelectable);
            for (Strategia__c s : TaskAttivi) {
                // prendi i step UI
                OriginalValuesTaskDa.add(s.Nome__c);
            }
        }
        UnselectedTaskDa = getunSelectedValues(OriginalValuesTaskDa);
        return null;
    }

    public List<SelectOption> getunSelectedValues(List<String> original) {
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(original);
        for (string b : tempList)
            options.add(new SelectOption(b, b));
        return options;
    }

    /*
     * PART II: Esegui l'operazione
     */

    // Crea task=> Usa OrkBl, sbianca il TaskA e rimuovi dalla lista
    public pageReference creaTaskManuale() {
        try {
            if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Anzianit_Pratica__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Check_In_Lavorazione__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Blocco__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Data_inizio_scaduto__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Fascia_di_rischio__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Flag_Chiusura__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Importo_Incasso_Consolidato__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Modalit_Invio_Sollecito__c', gd).get('ACCESS'))

            {
                // Prendi tutti i campi di Pratica e Strategia
                String queryPratica = 'Select ';
                queryPratica += utils.getSOBJECTFieldsForQuery('Pratica__c');
                queryPratica += ' From Pratica__c Where id=:idPratica';
                Pratica__c p = Database.query(QueryPratica);

                if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'BaseType__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Cattivo_Pagatore__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Data_attivazione__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Descrizione__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Esito__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Fase__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Max_Scaduto__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Modalit_Invio_Sollecito__c', gd).get('ACCESS')) {
                    String queryStr = 'Select ';
                    queryStr += utils.getSOBJECTFieldsForQuery('Strategia__c');
                    queryStr += ' From Strategia__c Where Testata__c=:idStrat And Nome__c=:TaskA';
                    Strategia__c s = Database.query(QueryStr);
                    soggettoTaskDaRimuovere = s.Nome__c;

                    List<Sobject> t = OrkBl.newTask(p, s);

                    for (SObject sobj : t) {
                        if (sobj instanceof ActivityExtended__c) {
                            sobj.put('Creata_Manualmente__c', 'TRUE');
                        }
                    }

                    if (OrkBL.getTaskFielsPermission('CREATE') && Utils.cebCheckObjPermission('Task', gd).get('INSERT')) {
                        insert t;
                    }

                    System.debug('\n Task inserito: ' + t);
                    // metti via dalla lista da sceglier task
                    cleanTaskSpot();
                }
            }

            PageReference pg = new PageReference('/' + this.idPratica);
            return pg;
        } catch (Exception e) {
            System.debug('\n Errore ****: ' + e.getMessage() + '\n linea: ' + e.getLineNumber());
            ErrorClass.logError('CreazioneManualeTaskCTRL, creaTaskManuale()', '\nErrore durante la creazione del task manuale! \nDettagli: ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Errore durante la creazione del task!'));
            return null;
        }
    }

    public void cleanTaskSpot() {
        integer len = OriginalValuesTaskDa.size();
        for (integer i = 0; i < len; i++) {
            if (OriginalValuesTaskDa[i] == soggettoTaskDaRimuovere) {
                OriginalValuesTaskDa.remove(i);
                soggettoTaskDaRimuovere = '';
                break;
            }
        }
        TaskA = 'NA';
    }

    public pageReference Indietro() {
        Pagereference p = new Pagereference('/' + this.idPratica);
        return p;
    }

    public pageReference UpdateTaskA() {
        TaskA = apexpages.currentpage().getparameters().get('pTaskA');

        return null;
    }

}