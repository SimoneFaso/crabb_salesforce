/* ---------------------------------------------------------------------------------------------------------------------
Name:            paginaDettagliCTRL.cls
Description:
Test class:      TestpaginaDettagliCTRL.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
   May-2014  0.1      ESino                     First Version
16-Jun-2016  0.2      ESino                Aggiunto il with sharing come richiesta da Salesforce.com per soddisfare le specifiche
                                           del Security Review.
28-Sep-2021  0.3      M.Pizzichini         Modified for adding check permission:
                                           fixing adding braces and cebCheckFLSPermission (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class paginaDettagliCTRL {

    public Strategia__c myTestata { get; set; }

    public String SelectedId { get; set; }
    public String showPage { get; set; }
    public list < Strategia__c>type { get; set; }
    public list < Strategia__c> myquery { get; set; }
    public list < Strategia__c> myStep { get; set; }
    public list < Strategia__c> mySalto { get; set; }
    public list < Strategia__c> myCDI { get; set; }
    public list < Strategia__c> myCDU { get; set; }
    public Id myId { get; set; }
    public List<String> opsDashboardList { get; set; }
    public Integer numPraticheIn { get; set; }
    public Map<String, Integer> mapStatoCount { get; set; }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public paginaDettagliCTRL(ApexPages.StandardController controller) {
        opsDashboardList = new List<String>{
                'CDI', 'CDU', 'S', 'J'
        };
        // prima, controlla se l'id e valido    
        if (idTestataValid(getMyId())) showPage = 'Correct';
        else showPage = 'Error';

        // chiedi il db la testata e suoi dettagli tramite LoadData() 
        myTestata = new Strategia__c();
        LoadData();
    }

    public void LoadData() {

        // inizia le liste dei oggetti correlati con questa testata
        myCDI = new list < Strategia__c>();
        myCDU = new list < Strategia__c>();
        myStep = new list < Strategia__c>();
        mySalto = new list < Strategia__c>();

        // il record type per controllare i tipi dei oggetti
        Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Strategia__c.getrecordtypeinfosbydevelopername();

        // Per una testata corretta chiedi il db
        if (getMyId() != null) {
            try {
                /*if(Utils.checkFLSPermission('Strategia__c', 'Stato__c').get('ACCESS')
                        && Utils.checkFLSPermission('Strategia__c', 'Nome__c').get('ACCESS')
                        && Utils.checkFLSPermission('Strategia__c', 'Descrizione__c').get('ACCESS')
                        && Utils.checkFLSPermission('Strategia__c', 'Versione__c').get('ACCESS')
                        && Utils.checkFLSPermission('Strategia__c', 'Tipo_Strategia__c').get('ACCESS')
                        && Utils.checkFLSPermission('Strategia__c', 'Activation_roles__c').get('ACCESS'))*/
                if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Stato__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Descrizione__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Versione__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Tipo_Strategia__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Activation_roles__c', gd).get('ACCESS')) {
                    myTestata = [
                            Select Id, toLabel(Stato__c), Nome__c, Descrizione__c, Versione__c, toLabel(Tipo_Strategia__c), Name, Activation_roles__c
                            from Strategia__C
                            Where id = :getMyId()
                            AND recordTypeId = :ctRecordTypes.get('Testata').getRecordTypeID()
                    ];
                }
            } catch (Exception e) {
                showPage = 'Error';
            }
        } else {
            // do nothing
        }

        // con una sola Query prendi tutti i dati dal DB
        /*if(Utils.checkFLSPermission('Strategia__c', 'isAutomaticJump__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Nome__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'industri_print_reference__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'E_da_affidare__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Attivit_Padre__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Activation_roles__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Tipologia__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Tipo_attivita__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Tipo_Strategia__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Document_code__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Jump_to__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Jump_from__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Descrizione__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Priority__c').get('ACCESS'))*/
        if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'isAutomaticJump__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'industri_print_reference__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'E_da_affidare__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Attivit_Padre__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Activation_roles__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Tipologia__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Tipo_attivita__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Tipo_Strategia__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Document_code__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Jump_to__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Jump_from__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Descrizione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Priority__c', gd).get('ACCESS')) {
            myquery = [
                    SELECT id, record_type__C, Nome__c, Activation_roles__c, isAutomaticJump__c, industri_print_reference__c, Name, E_da_affidare__c, Testata__c, Testata__r.nome__c, Attivit_Padre__c, Attivit_Padre__r.Nome__c,
                            Tipologia__c, toLabel(Tipo_attivita__c), toLabel(Tipo_Strategia__c), Document_code__c, Jump_to__c, Jump_to__r.nome__c, Jump_from__c, Jump_from__r.Nome__c, Descrizione__c, Priority__c
                    FROM Strategia__c
                    WHERE Testata__c = :myTestata.id
                    order by createdDAte
            ];

            // Carica anche i altri oggetti non Testata, e aggiungili nelle liste
            for (Strategia__c a : myquery) {
                if (a.record_type__C == 'Step') myStep.add(a);
                else if (a.record_type__C == 'Salto') mySalto.add(a);
                else if (a.record_type__C == 'Condizioni_di_Uscita') myCDU .add(a) ;
                else if (a.record_type__C == 'Condizioni_di_Ingresso') myCDI .add(a);
            }
        }

        String groupQuery = 'SELECT Count(Id) TOT, toLabel(Stato__c) STATO FROM Pratica__c WHERE Strategia__c = \'' + String.escapeSingleQuotes(myTestata.Id) + '\' GROUP BY Stato__c';
        List<AggregateResult> aggRes = Database.query(groupQuery);
        numPraticheIn = 0;
        mapStatoCount = new Map<String, Integer>();
        if (aggRes != null && !aggRes.isEmpty()) {
            for (AggregateResult agg : aggRes) {
                numPraticheIn += (Integer) agg.get('TOT');
                if (mapStatoCount.containsKey((String) agg.get('STATO'))) {
                    Integer current = mapStatoCount.get((String) agg.get('STATO'));
                    mapStatoCount.put((String) agg.get('STATO'), current + 1);
                } else {
                    mapStatoCount.put((String) agg.get('STATO'), (Integer) agg.get('TOT'));
                }
            }
        }
    }

    // prendi il id della testata nel URL
    public String getMyId() {
        try {
            //myId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('myId'));
            myId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('myId').escapeHtml4());
        } catch (Exception e) {
            return null;
        }
        return myId;
    }

    // controlla la validitá della testata 
    Public Boolean idTestataValid(String myTestataId) {

        if ((myTestataId == null) || (myTestataId == '')) {

            // we know there was an error with testataID
            return false;
        } else {

            // check if exists such an object
            Strategia__c tempStr = new Strategia__c();

            try {
                if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')) {
                    tempStr = [SELECT id FROM Strategia__c WHERE id = :myTestataId];
                }
            } catch (Exception e) {
                return false;
            }
            return true;
        }

    }


    // una methodi per prendere dal db una testata con un'certo ID
    // si usa nell'construttore, nel'controllo del'id
    public Strategia__c retrieveTestata(String testataId) {

        // variabile temporaria
        Strategia__c tempTestata = new Strategia__c();

        try {
            // chiedi il DB se esiste una tale strategia
            if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')) {
                tempTestata = [SELECT id FROM Strategia__c WHERE id = :testataID];
            }
        } catch (Exception e) {

            // se non esiste, dammi nulla
            return null;
        }
        return tempTestata;
    }

    //funzione per eliminare il record selezionato   
    Public void remove() {

        // il recordType per controllare i oggetti che si cancellerano
        Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Strategia__c.getrecordtypeinfosbydevelopername();

        // prendi dal DB, questo oggetto che sta per essere cancellato
        System.debug('ctRecordType-->' + ctRecordTypes);
        if(Utils.cebCheckObjPermission('Strategia__c',gd).get('ACCESS')
        && Utils.cebCheckFLSPermission('Strategia__c','recordtypeId',gd).get('ACCESS')) {
            strategia__c query1 = [Select id, recordtypeId from strategia__c where Id = :SelectedId];
            System.debug('query1-->' + query1);
            // controlla chi é questo oggetto
            if (query1.recordtypeid == ctRecordTypes.get('Condizioni_di_Ingresso').getRecordTypeID())type = mycdi;
            if (query1.recordtypeid == ctRecordTypes.get('Condizioni_di_Uscita').getRecordTypeID()) type = mycdu;
            if (query1.recordtypeid == ctRecordTypes.get('Step').getRecordTypeID()) type = myStep ;
            if (query1.recordtypeid == ctRecordTypes.get('Salto').getRecordTypeID())type = mySalto ;
        }
        // iniziala
        Strategia__c tobedeleted = new Strategia__c();

        // trovalo, e cancella
        for (Strategia__c a : type)
            if (a.Id == SelectedId) {
                tobeDeleted = a;
                if (Utils.checkObjPermission('Strategia__c').get('DELETE')) delete tobeDeleted;
                break;

            }

        //  update mytestata;,
        this.mycdi = mycdi;

        // refresh the data
        LoadData();


    }

    // cambi lo stato se la te stata e nello stato bozza, dal botton, in fondo
    public void cambiStato() {
        myTestata.Stato__c = 'Attiva';
        //if (Utils.checkFLSPermission('Strategia__c', 'Stato__c').get('UPDATE')) update myTestata;
        if (Utils.cebCheckObjPermission('Strategia__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Stato__c', gd).get('UPDATE')) {
            update myTestata;
        }
    }

    public void disattiva() {
        myTestata.Stato__c = 'Disattivata';
        //if(Utils.checkFLSPermission('Strategia__c', 'Stato__c').get('UPDATE')) update myTestata;
        if (Utils.cebCheckObjPermission('Strategia__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Stato__c', gd).get('UPDATE')) {
            update myTestata;
        }
    }


}