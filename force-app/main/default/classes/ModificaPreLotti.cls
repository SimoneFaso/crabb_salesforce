/* ---------------------------------------------------------------------------------------------------------------------
Name:            ModificaPreLotti.cls
Description:     Controller for ModificaPreLotti.page
Test class:      TestCoverage_ModificaPreLotti.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
14-Nov-2015  0.2      ESino                Modificato il metodo DeleteAffidamenti_PreLotti(), rinfrescando il totale
                                           degli affidi dopo aver cancellato un affido dai pre-lotti.
16-Jun-2016  0.3      ESino                Aggiunto il with sharing per soddisfare Security Review.
16-Sep-2022  0.2      C.Sanna & R.Kurti    Added WITH SECURITY ENFORCED and cebCheckObjPermission(security review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class ModificaPreLotti {
    public Id idLotto { get; set; }
    public List<Affidamento__c> ListAffidamenti { get; set; }
    private transient List<Affidamento__c> TotAffidamenti;
    public Id IdAffido { get; set; }
    public Affidamento__c Aff { get; set; }
    public Lotto__c lotto { get; set; }
    public Boolean isError { get; set; }
    public Boolean affidEsiste { get; set; }
    public Integer initialTotal { get; set; }
    public Integer Indice { get; set; }
    public Integer RecordTot { get; set; }
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    // COSTRUTTORE
    public ModificaPreLotti() {
        isError = false;
        affidEsiste = false;
        idLotto = String.isNotBlank(ApexPages.currentPage().getParameters().get('IdPreLotto')) ? String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('IdPreLotto')) : null;
        Indice = 0;

        if (idLotto != null) {
            lotto = [Select Id, Name from Lotto__c where Id = : idLotto WITH SECURITY_ENFORCED ];
            ListAffidamenti = getListAffidamenti();
        } else
                isError = true;
    }

    //metodi per gestione paginazione - Start
    public string recordsForPage {
        get {
            if (recordsForPage == null)
                return '25';
            return recordsForPage;
        }
        set;
    }

    public integer RecXPage {
        get {
            if (recordsForPage == null) RecXPage = 0; else RecXPage = integer.valueOf(recordsForPage);
            return RecXPage;
        }
        set;
    }


    public List<SelectOption> recordsForPageValues {
        get {
            List<SelectOption> records = new list<SelectOption>();
            records.add(new SelectOption('25', '25'));
            records.add(new SelectOption('50', '50'));
            records.add(new SelectOption('200', '100'));
            records.add(new SelectOption('200', '200'));
            return records;
        }
        set;
    }

    public void sizeTable() {
        indice = 0;
        system.debug('*****recordsForPage = ' + recordsForPage);
        RecXPage = integer.valueOf(recordsForPage);
        ListTabellaAffidamentoSelectable();
    }


    public void Beginning() {
        Indice = 0;
        ListTabellaAffidamentoSelectable();
    }
    public void Previous() {
        if (indice > 0)
            Indice--;
        ListTabellaAffidamentoSelectable();
    }
    public void Next() {
        if (indice * recXPage < initialTotal)
            Indice++;
        ListTabellaAffidamentoSelectable();
    }
    public void End() {
        indice = integer.valueof(initialTotal / recXPage);
        ListTabellaAffidamentoSelectable();
    }
    public boolean getIsBeginningVisibility() {
        system.debug('*****indice = ' + indice);
        return indice > 0;
    }
    public boolean getIsEndVisibility() {

        boolean A = indice < integer.valueof(initialTotal / recXPage);
        system.debug('indice<integer.valueof(initialTotal/recXPage) = ' + A);
        return indice < integer.valueof(initialTotal / recXPage);
    }

    public void ListTabellaAffidamentoSelectable() {
        String allfieldsAff = CredManUtility.selectallShort('Affidamento__c');
        if (Utils.cebCheckObjPermission('Affidamento__c',gd).get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_Affidamento__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_Revoca__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_Richiesta_Proroga__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'E_richiesta_una_proroga__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Esito_Lavorazione__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Giorni_di_proroga__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'id_Task_associato__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Pratica__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Comune__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Residuo_Totale__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Lotto__c').get('ACCESS')
                && Utils.checkFLSPermission('Lotto__c', 'Data_scadenza__c').get('ACCESS')) {
            Integer iOffset = indice * RecXPage;
            List<Affidamento__c> listAffidamentiToView = database.query('SELECT ' + String.escapeSingleQuotes(allfieldsAff) + ', Pratica__r.Comune__c, Pratica__r.Account__r.Name, Pratica__r.Account__r.Id, ' +
                    'Pratica__r.Residuo_Totale__c, Pratica__r.Data_Apertura__c, Pratica__r.Id, Pratica__r.Name, ' +
                    'Pratica__r.Servizio_Fornitura__r.Name, Lotto__r.Data_scadenza__c, Lotto__r.Id ' +
                    //'FROM Affidamento__c WHERE Lotto__c =: IdLotto AND Stato__c != \'Revocato\' Order by Name Desc Limit '+ recXPage +' OFFSET ' + (indice*recXPage ));
                    'FROM Affidamento__c WHERE Lotto__c =: idLotto AND Stato__c != \'Revocato\' Order by Name Desc Limit :recXPage OFFSET :iOffset');

            if (listAffidamentiToView.size() > 0) {
                AffidEsiste = true;
            } else AffidEsiste = false;

            ListAffidamenti = listAffidamentiToView;
        }
    }

    //metodi per gestione paginazione - End
    public List<Affidamento__c> getListAffidamenti() {
        system.debug('*****IdLotto = ' + idLotto);
        QueryAffidamenti();
        String allfieldsAff = CredManUtility.selectallShort('Affidamento__c');
        String PlayQuery = '';
        if (Utils.cebCheckObjPermission('Affidamento__c',gd).get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_Affidamento__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_Revoca__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_Richiesta_Proroga__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'E_richiesta_una_proroga__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Esito_Lavorazione__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Giorni_di_proroga__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'id_Task_associato__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Pratica__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Comune__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Residuo_Totale__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Lotto__c').get('ACCESS')
                && Utils.checkFLSPermission('Lotto__c', 'Data_scadenza__c').get('ACCESS')) {
            PlayQuery += 'SELECT ' + allfieldsAff + ', Pratica__r.Comune__c, Pratica__r.Account__r.Name, Pratica__r.Account__r.Id, ' +
                    'Pratica__r.Residuo_Totale__c, Pratica__r.Data_Apertura__c, Pratica__r.Id, Pratica__r.Name, ' +
                    'Pratica__r.Servizio_Fornitura__r.Name, Lotto__r.Data_scadenza__c, Lotto__r.Id ' +
                    'FROM Affidamento__c WHERE Lotto__c =: idLotto AND Stato__c != \'Revocato\'';
            // inizio nuovo codice 12/04 spostamento tre righe tra i commenti in check permission
            //list<Affidamento__c> ListAffCount =  database.query(PlayQuery + 'Order by Name Desc Limit '+ recXPage) ;
            list<Affidamento__c> ListAffCount = database.query(PlayQuery + 'Order by Name Desc Limit :recXPage') ;
            if (ListAffCount.size() > 0)
                affidEsiste = true;
            return ListAffCount;
        } else return null;
        // inizio nuovo codice 12/04 spostamento tre righe tra i commenti in check permission

    }

    public void QueryAffidamenti() {
        //if(IdLotto==null) return new list<Affidamento__c>();
        String allfieldsAff = CredManUtility.selectallShort('Affidamento__c');
        String PlayQuery = '';
        if (Utils.cebCheckObjPermission('Affidamento__c',gd).get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_Affidamento__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_Revoca__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Data_Richiesta_Proroga__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'E_richiesta_una_proroga__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Esito_Lavorazione__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Giorni_di_proroga__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'id_Task_associato__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Pratica__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Comune__c').get('ACCESS')
                && Utils.checkFLSPermission('Pratica__c', 'Residuo_Totale__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Lotto__c').get('ACCESS')
                && Utils.checkFLSPermission('Lotto__c', 'Data_scadenza__c').get('ACCESS')) {
            PlayQuery += 'SELECT ' + String.escapeSingleQuotes(allfieldsAff) + ', Pratica__r.Comune__c, Pratica__r.Account__r.Name, Pratica__r.Account__r.Id, ' +
                    'Pratica__r.Residuo_Totale__c, Pratica__r.Data_Apertura__c, Pratica__r.Id, Pratica__r.Name, ' +
                    'Pratica__r.Servizio_Fornitura__r.Name, Lotto__r.Data_scadenza__c, Lotto__r.Id ' +
                    'FROM Affidamento__c WHERE Lotto__c =: idLotto AND Stato__c != \'Revocato\'';
            // inizio nuovo codice 12/04 spostamento tre righe tra i commenti in check permission
            system.debug('*****--recXPage = ' + recXPage);
            list<Affidamento__c> ListAffCount = database.query(PlayQuery + 'Order by Name Desc Limit ' + recXPage);
            if (TotAffidamenti == null) TotAffidamenti = database.query(PlayQuery);
            initialTotal = TotAffidamenti.size();
            // fine nuovo codice 12/04 spostamento tre righe tra i commenti in check permission
        }

    }

    public PageReference RevocaAffido() {
        IdAffido = String.isNotBlank(ApexPages.currentPage().getParameters().get('IdAffido')) ? String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('IdAffido')) : null;
        if (IdAffido == null) return Page.RevocaAffido_PreLotti;
        Aff = [Select Id, Name, Note_elior__c, Lotto__c, Lotto__r.Name from Affidamento__c where Id = :IdAffido WITH SECURITY_ENFORCED ];
        return Page.RevocaAffido_PreLotti;
    }

    public PageReference ReturnToLotti() {
        PageReference Page = new PageReference('/apex/GestioneAffidamenti?TabToView=preLottiTab');
        return Page;
    }

    //RevocaAffido - dopo aver scritto la nota
    public PageReference Conferma() {
        Aff.Stato__c = 'Revocato';
        if (Utils.cebCheckObjPermission('Affidamento__c',gd).get('UPDATE') && Utils.cebCheckFLSPermission('Affidamento__c', 'Stato__c',gd).get('UPDATE')) {
            update Aff;
        }
        return Page.ModificaLotti;
    }

    public PageReference CancellaPreLotto() {
        PageReference page = new PageReference('/apex/GestioneAffidamenti?TabToView=preLottiTab');
        if (lotto == null) return page;
        AffidamentiManager.eliminaPreLotto(lotto.Id);
        return page;
    }

    public PageReference IndietroPreLotto() {
        PageReference Page = new PageReference('/apex/GestioneAffidamenti?TabToView=preLottiTab');
        return Page;
    }

    public PageReference IndietroModificaLotti() {
        return Page.ModificaPreLotti;
    }

    public PageReference DeleteAffidamenti_PreLotti() {
        IdAffido = ApexPages.currentPage().getParameters().get('IdAffido');
        if (String.isBlank(ApexPages.currentPage().getParameters().get('IdAffido'))) {
            return null;
        }
        //if (Utils.checkFLSPermission('Affidamento__c', 'Note_elior__c').get('ACCESS')
        //        && Utils.checkFLSPermission('Affidamento__c', 'Lotto__c').get('ACCESS')) {
            Aff = [Select Id, Name, Note_elior__c, Lotto__c, Lotto__r.Name from Affidamento__c where Id = :IdAffido WITH SECURITY_ENFORCED ];
            AffidamentiManager.eliminaPreAffidamento(Aff.Id);
        //}
        ListTabellaAffidamentoSelectable();
        initialTotal = ListAffidamenti.size();
        return null;
    }

    /* F.M - 19/9 */
    public PageReference GeneraLotto() {
        Lotto__c lotto = new Lotto__c();
        lotto.Id = idLotto;
        lotto.SystemCreationOfLotto__c = true;
        if (Utils.cebCheckObjPermission('Lotto__c',gd).get('UPDATE') && Utils.cebCheckFLSPermission('Lotto__c', 'SystemCreationOfLotto__c',gd).get('UPDATE')) {
            update lotto;
        }
        /*AffidamentiManager.generaAffidamentoFuture(idLotto);*/
        Id batchId = Database.executeBatch(new BatchGeneraAffidamento(idLotto), 50);
        PageReference page = new PageReference('/apex/GestioneAffidamenti?batch=' + batchId);
        page.setRedirect(true);
        return page;
    }

}