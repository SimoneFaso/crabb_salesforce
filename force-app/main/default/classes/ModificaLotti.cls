/* ---------------------------------------------------------------------------------------------------------------------
Name:            ModificaLotti.cls
Description:     Controller for ModificaLotti.page
Test class:      TestCoverage_ModificaLotti.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
16-Jun-2016  0.2      ESino                Aggiunto il with sharing per soddisfare Security Review.
28-Sep-2021  0.3      M.Pizzichini         Modified  for adding check permission:
                                           fixing adding braces and cebCheckFLSPermission (Security Review)
16-Sep-2022  0.2      C.Sanna & R.Kurti    Added WITH SECURITY ENFORCED and added cebCheckObjPermissions(security review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class ModificaLotti {
    public class ModificaLottiException extends Exception {
    }

    public Id idLotto { get; set; }
    public List<Affidamento__c> ListAffidamenti { get; set; }
    public Id IdAffido { get; set; }
    public Affidamento__c Aff { get; set; }
    public Affidamento__c tmpAff { get; set; }
    public Lotto__c Lotto { get; set; }
    public Boolean isError { get; set; }
    public Boolean affidEsiste { get; set; }
    public Integer initialTotal { get; set; }
    Integer indice { get; set; }
    Integer RecordTot { get; set; }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    //metodi per gestione paginazione - Start
    public String recordsForPage {
        get {
            if (recordsForPage == null)
                return '25';
            return recordsForPage;
        }
        set;
    }

    public Integer RecXPage {
        get {
            if (recordsForPage == null) RecXPage = 0;
            else RecXPage = Integer.valueOf(recordsForPage);
            return RecXPage;
        }
        set;
    }


    public List<SelectOption> recordsForPageValues {
        get {
            List<SelectOption> records = new List<SelectOption>();
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
        System.debug('*****recordsForPage = ' + recordsForPage);
        RecXPage = Integer.valueOf(recordsForPage);
        ListTabellaAffidamentoSelectable();
    }


    public void Beginning() {
        indice = 0;
        ListTabellaAffidamentoSelectable();
    }
    public void Previous() {
        if (indice > 0)
            indice--;
        ListTabellaAffidamentoSelectable();
    }
    public void Next() {
        if (indice * recXPage < initialTotal)
            indice++;
        ListTabellaAffidamentoSelectable();
    }
    public void End() {
        indice = Integer.valueOf(initialTotal / recXPage);
        ListTabellaAffidamentoSelectable();
    }
    public Boolean getIsBeginningVisibility() {
        System.debug('*****indice = ' + indice);
        return indice > 0;
    }
    public Boolean getIsEndVisibility() {
        System.debug('*****integer.valueof(initialTotal/recXPage ) = ' + integer.valueof(initialTotal / recXPage));
        System.debug('*****initialTotal = ' + initialTotal);
        System.debug('*****recXPage = ' + recXPage);
        Boolean A = indice < integer.valueof(initialTotal / recXPage);
        System.debug('indice<integer.valueof(initialTotal/recXPage) = ' + A);
        return indice < integer.valueof(initialTotal / recXPage);
    }

    public void ListTabellaAffidamentoSelectable() {
        String allfieldsAff = CredManUtility.selectallShort('Affidamento__c');
        System.debug('***recXPage = ' + recXPage);
        System.debug('***indice = ' + indice);
        System.debug('***(indice*recXPage ) = ' + indice * recXPage);
        /*if (Utils.checkFLSPermission('Affidamento__c', 'Data_Affidamento__c').get('ACCESS')
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
                && Utils.checkFLSPermission('Pratica__c', 'Data_Apertura__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Lotto__c').get('ACCESS')
                && Utils.checkFLSPermission('Lotto__c', 'Data_scadenza__c').get('ACCESS'))*/
        if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Revoca__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Richiesta_Proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'E_richiesta_una_proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Esito_Lavorazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Giorni_di_proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Comune__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Residuo_Totale__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Apertura__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Lotto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Data_scadenza__c', gd).get('ACCESS')) {
            List<Affidamento__c> listAffidamentiToView = Database.query('SELECT ' + String.escapeSingleQuotes(allfieldsAff) + ', Pratica__r.Comune__c, Pratica__r.Account__r.Name, Pratica__r.Account__r.Id, ' +
                    'Pratica__r.Residuo_Totale__c, Pratica__r.Data_Apertura__c, Pratica__r.Id, Pratica__r.Name, ' +
                    'Pratica__r.Servizio_Fornitura__r.Name, Lotto__r.Data_scadenza__c, Lotto__r.Id ' +
                    'FROM Affidamento__c WHERE Lotto__c =: idLotto AND Stato__c != \'Revocato\' Order by Name Desc Limit ' + recXPage + ' OFFSET ' + (indice * recXPage));

            System.debug('*****listAffidamentiToView.size() = ' + listAffidamentiToView.size());
            if (listAffidamentiToView.size() > 0) {
                AffidEsiste = true;
            } else AffidEsiste = false;

            ListAffidamenti = listAffidamentiToView;
        }
    }
    //metodi per gestione paginazione - End

    public ModificaLotti() {
        tmpAff = new Affidamento__c();
        isError = false;
        affidEsiste = false;
        idLotto = String.isNotBlank(ApexPages.currentPage().getParameters().get('IdLotto')) ? String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('IdLotto')) : null;
        indice = 0;

        if (idLotto != null) {
            //if (Utils.checkFLSPermission('Lotto__c', 'stato__c').get('ACCESS')) {
            Lotto = [Select Id, Name, stato__c from Lotto__c where Id = :idLotto WITH SECURITY_ENFORCED];
            //}
            ListAffidamenti = getListAffidamenti();
        } else
                isError = true;
    }

    public List<Affidamento__c> getListAffidamenti() {
        System.debug('*****IdLotto = ' + idLotto);
        QueryAffidamenti();
        String allfieldsAff = CredManUtility.selectallShort('Affidamento__c');
        String PlayQuery = '';
        /*if (Utils.checkFLSPermission('Affidamento__c', 'Data_Affidamento__c').get('ACCESS')
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
                && Utils.checkFLSPermission('Pratica__c', 'Data_Apertura__c').get('ACCESS')
                && Utils.checkFLSPermission('Affidamento__c', 'Lotto__c').get('ACCESS')
                && Utils.checkFLSPermission('Lotto__c', 'Data_scadenza__c').get('ACCESS'))*/
        if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Revoca__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Richiesta_Proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'E_richiesta_una_proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Esito_Lavorazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Giorni_di_proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Comune__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Residuo_Totale__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Apertura__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Lotto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Data_scadenza__c', gd).get('ACCESS')) {
            PlayQuery += 'SELECT ' + String.escapeSingleQuotes(allfieldsAff) + ', Pratica__r.Comune__c, Pratica__r.Account__r.Name, Pratica__r.Account__r.Id, ' +
                    'Pratica__r.Residuo_Totale__c, Pratica__r.Data_Apertura__c, Pratica__r.Id, Pratica__r.Name, ' +
                    'Pratica__r.Servizio_Fornitura__r.Name, Lotto__r.Data_scadenza__c, Lotto__r.Id ' +
                    'FROM Affidamento__c WHERE Lotto__c =: idLotto AND Stato__c != \'Revocato\'';
            // inizio nuovo codice 12/04 spostamento tre righe tra i commenti in check permission
            List<Affidamento__c> ListAffCount = Database.query(PlayQuery + 'Order by Name Desc Limit ' + recXPage) ;
            if (ListAffCount.size() > 0)
                affidEsiste = true;
            return ListAffCount;
        } else return null;
        // fine nuovo codice 12/04 spostamento tre righe tra i commenti in check permission             
    }

    public void QueryAffidamenti() {
        //if(IdLotto==null) return new list<Affidamento__c>();
        String allfieldsAff = CredManUtility.selectallShort('Affidamento__c');
        String PlayQuery = '';
        if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Revoca__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Richiesta_Proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'E_richiesta_una_proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Esito_Lavorazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Giorni_di_proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Comune__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Residuo_Totale__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Apertura__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Lotto__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Data_scadenza__c', gd).get('ACCESS')) {
            PlayQuery += 'SELECT ' + String.escapeSingleQuotes(allfieldsAff) + ', Pratica__r.Comune__c, Pratica__r.Account__r.Name, Pratica__r.Account__r.Id, ' +
                    'Pratica__r.Residuo_Totale__c, Pratica__r.Data_Apertura__c, Pratica__r.Id, Pratica__r.Name, ' +
                    'Pratica__r.Servizio_Fornitura__r.Name, Lotto__r.Data_scadenza__c, Lotto__r.Id ' +
                    'FROM Affidamento__c WHERE Lotto__c =: idLotto AND Stato__c != \'Revocato\'';

            System.debug('*****--recXPage = ' + recXPage);
            // inizio nuovo codice 12/04 spostamento tre righe tra i commenti in check permission
            List<Affidamento__c> ListAffCount = Database.query(PlayQuery + 'Order by Name Desc Limit ' + recXPage);
            ListAffidamenti = Database.query(PlayQuery);
            initialTotal = ListAffidamenti.size();
            // fine nuovo codice 12/04 spostamento tre righe tra i commenti in check permission
        }
    }

    public PageReference RevocaAffido() {
        IdAffido = ApexPages.currentPage().getParameters().get('IdAffido');
        //if (Utils.cebCheckFLSPermission('Affidamento__c', 'Note_elior__c',gd).get('ACCESS')
        //        && Utils.cebCheckFLSPermission('Affidamento__c', 'Lotto__c',gd).get('ACCESS')) {
        Aff = [Select Id, Note_elior__c, Lotto__c from Affidamento__c where Id = :IdAffido WITH SECURITY_ENFORCED];
        //}

        return Page.RevocaAffido;
    }

    public PageReference ReturnToLotti() {
        PageReference page = new PageReference('/apex/GestioneAffidamenti?TabToView=lottiTab');
        return page;
    }

    //RevocaAffido - dopo aver scritto la nota
    public PageReference Conferma() {
        try {
            AffidamentiManager.revocaSingoloAffidamento(aff.Id, tmpAff.note_elior__c);
            QueryAffidamenti();
            return Page.ModificaLotti;
        } catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
    }

    public PageReference RevocaLotto() {

        try {
            if (Lotto != null) {
                Lotto.Stato__c = TagHelper.getValueText('LottoRevocaDaparteOperatore');
                //if (Utils.checkFLSPermission('Lotto__c', 'Stato__c').get('UPDATE')) update lotto;
                if (Utils.cebCheckObjPermission('Lotto__c',gd).get('UPDATE')
                        && Utils.cebCheckFLSPermission('Lotto__c', 'Stato__c', gd).get('UPDATE')) {
                    update lotto;
                }
                //throw new ModificaLottiException('E:'+tmpAff.Note_elior__c);
                AffidamentiManager.revocaLotto(lotto.id, tmpAff.Note_elior__c);
            }
            PageReference page = new PageReference('/apex/GestioneAffidamenti?TabToView=lottiTab');
            return page;
        } catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
    }

    public PageReference Indietro() {
        PageReference page = new PageReference('/apex/GestioneAffidamenti?TabToView=lottiTab');
        return page;
    }

    public PageReference IndietroModificaLotti() {
        return Page.ModificaLotti;
    }
}