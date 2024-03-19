public with sharing class BloccoSbloccoPratiche
{
    public void BloccaPratiche(List<Pratica__c> lPrat, String sCausale, String sNota)
    {
        /* vecchia gestione CEB
        system.debug(' true / false' + CEBUtils.newOrkVersionEnabled());
        if(CEBUtils.newOrkVersionEnabled()){
            //if new version enabled, create an event
            CEBUtils.addCebEvents(false, lPrat, 'DB');
            return;
        }*/
		system.debug(' block pratica ');
        for (Pratica__c p: lPrat)
        {
            p.Stato__c = 'Bloccata Manualmente';
            p.Motivo_Blocco__c = sCausale;
            p.Data_Blocco__c = System.today();
            p.Note_Blocco__c = sNota;
            p.Nota_Sblocco__c = '';
        }
        if (Utils.checkFLSPermission('Pratica__c', 'Stato__c').get('UPDATE')
            && Utils.checkFLSPermission('Pratica__c', 'Motivo_Blocco__c').get('UPDATE')
            && Utils.checkFLSPermission('Pratica__c', 'Note_Blocco__c').get('UPDATE')
            && Utils.checkFLSPermission('Pratica__c', 'Nota_Sblocco__c').get('UPDATE')
            && Utils.checkFLSPermission('Pratica__c', 'Data_Blocco__c').get('UPDATE')
            ) update lPrat;
    }
    
    public void SbloccaPratiche(List<Pratica__c> lPrat, String SblNota)
    {
        /*Vecchia gestione CEB
        system.debug(' true / false' + CEBUtils.newOrkVersionEnabled());
        if(CEBUtils.newOrkVersionEnabled()){
            //if new version enabled, create an event
            CEBUtils.addCebEvents(false, lPrat, 'DU');
            return;
        }*/
        system.debug(' block pratica ');
        String bstratexst = null;

        for (Pratica__c p: lPrat)
        {
            bstratexst = p.Strategia__c != null?'Y':'N'; // 20140710 SI: Va inserito il controllo sugli Affidi che al momento non saranno rilasciati
            p.Stato__c = bstratexst == 'Y'?'In Lavorazione':'Da Elaborare';
            p.Motivo_Blocco__c = '';
            p.Data_Blocco__c = null;
            p.Note_Blocco__c = '';
            p.Nota_Sblocco__c = SblNota;
        }
        if (Utils.checkFLSPermission('Pratica__c', 'Stato__c').get('UPDATE')
            && Utils.checkFLSPermission('Pratica__c', 'Motivo_Blocco__c').get('UPDATE')
            && Utils.checkFLSPermission('Pratica__c', 'Note_Blocco__c').get('UPDATE')
            && Utils.checkFLSPermission('Pratica__c', 'Nota_Sblocco__c').get('UPDATE')
            && Utils.checkFLSPermission('Pratica__c', 'Data_Blocco__c').get('UPDATE')
            && Utils.checkFLSPermission('Pratica__c', 'Strategia__c').get('UPDATE')
            ) update lPrat;
    }
}