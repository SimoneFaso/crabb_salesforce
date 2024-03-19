/* ---------------------------------------------------------------------------------------------------------------------
Name:            PianiDiRientroHandler.cls
Description:
Test class:      TestPDRHandler.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
21/Jul/2014  0.1      Silvio Ivaldi                   First Version
17-Jun-2016  0.2      E. Sino                         Security Check/Review
22-Aug-2022  0.3      Claudio Sanna                   Modified after insert/update. Is now possible to skip the Lock/Unlock
                                                      functionality on the related Dossier, based on the value of
                                                      CS Tag__c Record - SkipBloccoPraticaPDR.
16-Sep-2022  0.4     C.Sanna & R.Kurti                Added WITH SECURITY ENFORCED (security review)

----------------------------------------------------------------------------------------------------------------------*/

public with sharing class PianiDiRientroHandler implements ITrigger {

    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public PianiDiRientroHandler() {
    }

    public void bulkBefore() {
    }

    public void bulkAfter() {
    }

    public void bulkAfter(List<SObject> soListNew) {
    }

    public void bulkAfter(List<SObject> soListOld, List<SObject> soListNew) {
    }

    public void bulkBefore(List<SObject> soListNew) {
    }

    public void bulkBefore(List<SObject> soListOld, List<SObject> soListNew) {
    }

    public void beforeInsert(LIST<SObject> soList) {
    }

    public void beforeUpdate(LIST<SObject> soList, LIST<SObject> oList) {
    }
    public void beforeDelete(List<SObject> so) {
    }

    /*
    *	ESino: Nell'afterInsert() e' previsto il blocco della pratica come conseguenza
    *	dell'attivazione del piano di Rientroi.
    */
    public void afterInsert(List<SObject> soList) {


        Map<Id, Piano_di_Rientro__c> newPdrMap = new Map<Id, Piano_di_Rientro__c>((List<Piano_di_Rientro__c>) soList);
        String motivoPDR = Label.PianoDiRientro;
        String notePDR = Label.activePDRinsertion;

        /* if(Utils.checkFLSPermission('Pratica__c', 'Stato__c').get('ACCESS')
            && Utils.checkFLSPermission('Pratica__c', 'Data_Blocco__c').get('ACCESS')
            && Utils.checkFLSPermission('Pratica__c', 'Motivo_Blocco__c').get('ACCESS')
            && Utils.checkFLSPermission('Pratica__c', 'Note_Blocco__c').get('ACCESS')
            && Utils.checkFLSPermission('Pratica__c', 'is_Blocco_PDR__c').get('ACCESS'))
        { */
        List<Pratica__c> Lista_Pr = [
                SELECT Id, Stato__c, Data_Blocco__c, Motivo_Blocco__c, Note_Blocco__c, is_Blocco_PDR__c
                FROM Pratica__c
                where Id in (
                        Select Pratica__c
                        from Piano_di_Rientro__c
                        where Stato__c = 'Attivo'
                        and Id in :newPdrMap.keySet()
                )
                WITH SECURITY_ENFORCED
        ];


        /*for(Pratica__c PR: Lista_Pr){
             if(pr.stato__c==TagHelper.getValueText('ValoreStatoPraticaPerBloccoManuale')) continue;
             PR.Stato__c = 'Bloccata';
             PR.Data_Blocco__c = System.Today();
             PR.Motivo_Blocco__c = 'Piano di Rientro';
             PR.Note_Blocco__c = notePDR;
         }*/
        for (Pratica__c PR : Lista_Pr) {
            if (PR.Stato__c == TagHelper.getValueText('ValoreStatoPraticaPerBloccoManuale')) {
                continue;
            }
            if (TagHelper.getValueBoolean('SkipBloccoPraticaPDR') == false) {
                PR.Stato__c = 'Bloccata';
                PR.Data_Blocco__c = System.today();
                PR.Motivo_Blocco__c = 'Piano di Rientro';
                PR.Note_Blocco__c = notePDR;
            }
        }
        /* if (Utils.checkFLSPermission('Pratica__c', 'Stato__c').get('UPDATE')
                && Utils.checkFLSPermission('Pratica__c', 'Data_Blocco__c').get('UPDATE')
                && Utils.checkFLSPermission('Pratica__c', 'Note_Blocco__c').get('UPDATE')
                && Utils.checkFLSPermission('Pratica__c', 'Nota_Sblocco__c').get('UPDATE')) {
            update Lista_Pr;
        }*/
        if (Utils.cebCheckObjPermission('Pratica__c',gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c',gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Blocco__c',gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Note_Blocco__c',gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Nota_Sblocco__c',gd).get('UPDATE')) {
            update Lista_Pr;
        }
    }


    /* 
    * 	Modificato da: Endrit Sino(15/9/2014)
    * 	Scopo: Il sistema deve lavorare solo le pratiche con  il 
    *	cammpo is_Blocco_Pdr__c compilato true.
    */
    public void afterUpdate(List<SObject> oldSo, List<SObject> so) {
        Map<Id, Piano_di_Rientro__c> oldPdrMap = new Map<Id, Piano_di_Rientro__c>((List<Piano_di_Rientro__c>) oldSo);
        Map<Id, Piano_di_Rientro__c> newPdrMap = new Map<Id, Piano_di_Rientro__c>((List<Piano_di_Rientro__c>) so);

        /*lavoraPratichePDRDisatteso(newPdrMap);
        sbloccaPratiche(newPdrMap);*/
        if (TagHelper.getValueBoolean('SkipBloccoPraticaPDR') == false) {
            lavoraPratichePDRDisatteso(newPdrMap);
            sbloccaPratiche(newPdrMap);
        }
    }

    public void afterDelete(List<SObject> so) {
    }

    public void andFinally() {
    }

    // Helper Methods
    public void lavoraPratichePDRDisatteso(Map<Id, Piano_di_Rientro__c> newPdrMap) {

        String notaSblocco = Label.NotaSblocco;
        String bstratexst = null, pdrStatoDiChiusura, pdrStatoPerPDRDisatteso;
        Set<id> idPRaticas = new Set<id>();
        List<Pratica__c> Lista_Pr ;

        pdrStatoDiChiusura = TagHelper.getValueText('PDRStatodiChiusura');
        pdrStatoPerPDRDisatteso = TagHelper.getValueText('PDRStatoPerPDRDisatteso');

        for (Piano_di_Rientro__c pdr : newPdrMap.values()) {
            if (!pdr.stato__c.equals(pdrStatoDiChiusura) && !pdr.stato__c.equals(pdrStatoPerPDRDisatteso)) continue;
            idPraticas.add(pdr.pratica__C);
        }

        Lista_Pr = [
                SELECT Id, Strategia__c, Nota_Sblocco__c, Stato__c, Data_Blocco__c, Motivo_Blocco__c, Note_Blocco__c, is_Blocco_PDR__c, Name
                FROM Pratica__c
                where Stato__c = 'Bloccata' and Id in :idPraticas
                WITH SECURITY_ENFORCED
        ];

        if (Lista_Pr == null || Lista_Pr.size() == 0) {
            return;
        }

        for (Pratica__c PR : Lista_Pr) {
            bstratexst = PR.Strategia__c != null ? 'Y' : 'N'; // 20140710 SI: Va inserito il controllo sugli Affidi che al momento non saranno rilasciati
            PR.Stato__c = bstratexst == 'Y' ? 'In Lavorazione' : 'Da Elaborare';
            PR.Data_Blocco__c = null;
            PR.Motivo_Blocco__c = null;
            PR.Note_Blocco__c = null;
            PR.Nota_Sblocco__c = notaSblocco;
        }
        if (Utils.cebCheckObjPermission('Pratica__c',gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c',gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Blocco__c',gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Note_Blocco__c',gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Nota_Sblocco__c',gd).get('UPDATE')) {
            update Lista_Pr;
        }
    }

    public void sbloccaPratiche(Map<Id, Piano_di_Rientro__c> newPdrMap) {

        List <String> statiPDR = new List<String>();
        statiPDR.add('Disatteso');
        statiPDR.add('Chiuso');
        List<Pratica__c> Lista_Pr = [
                SELECT Id, Strategia__c, Nota_Sblocco__c, Stato__c, Data_Blocco__c, Motivo_Blocco__c, Note_Blocco__c
                FROM Pratica__c
                where Stato__c = 'Bloccata' and
                Id in (
                        Select Pratica__c
                        from Piano_di_Rientro__c
                        where Stato__c in :statiPDR
                        and Id in :newPdrMap.keySet()
                )
                WITH SECURITY_ENFORCED
        ];
        String bstratexst = null;
        String notaSblocco = Label.NotaSblocco;
        for (Pratica__c PR : Lista_Pr) {

            bstratexst = PR.Strategia__c != null ? 'Y' : 'N'; // 20140710 SI: Va inserito il controllo sugli Affidi che al momento non saranno rilasciati
            PR.Stato__c = bstratexst == 'Y' ? 'In Lavorazione' : 'Da Elaborare';
            PR.Data_Blocco__c = null;
            PR.Motivo_Blocco__c = null;
            PR.Note_Blocco__c = null;
            PR.Nota_Sblocco__c = notaSblocco;
        }
        /*if (Utils.checkFLSPermission('Pratica__c', 'Stato__c').get('UPDATE')
                && Utils.checkFLSPermission('Pratica__c', 'Data_Blocco__c').get('UPDATE')
                && Utils.checkFLSPermission('Pratica__c', 'Note_Blocco__c').get('UPDATE')
                && Utils.checkFLSPermission('Pratica__c', 'Nota_Sblocco__c').get('UPDATE')) update Lista_Pr; */

        if (Utils.cebCheckObjPermission('Pratica__c',gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c',gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Blocco__c',gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Note_Blocco__c',gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Nota_Sblocco__c',gd).get('UPDATE')) {
            update Lista_Pr;
        }
    }
}