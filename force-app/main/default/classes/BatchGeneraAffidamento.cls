/* ---------------------------------------------------------------------------------------------------------------------
Name:            BatchGeneraAffidamento.cls
Description:
Test Class:      TestBatchGeneraAffidamento.cls


Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
11-Jun-2021  0.2      M.Siotto                        Reviewed for using ceb methods
30-Aug-2021  0.3      C.Sanna                         Modified and added cebCheckObjPermission and cebCheckFLSPermission
                                                      (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

global with sharing class BatchGeneraAffidamento implements Database.Batchable<sObject> {

    public String idLotto { get; set; }
    public String query { get; set; }
    public Integer restart = 4;
    Public Map<String, SObjectType> gd = Schema.getGlobalDescribe();

    global BatchGeneraAffidamento(String lottoId) {
        idLotto = lottoId;

        if (Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Revoca__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Esito_Lavorazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Giorni_di_proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Incassi_aggiornati__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Incasso_periodo_affidamento__c', gd).get('ACCESS')) {
            query = ' Select ' + Utils.cebGetSOBJECTFieldsForQuery('Affidamento__c', gd) + ' From Affidamento__c Where Lotto__c =:idLotto and stato__c=\'Da confermare\'';
            /*List<affidamento__c> affList=Database.query(queryAff);
            errorClass.logError('AffidamentiManager.generaAffidamentoFuture','affList:'+affList);
            generaAffidamento(affList);
            Lotto__c l= new lotto__c();
            l.id=idLotto;
            l.Tipo__c='Lotto';
            l.stato__c='Confermato';
            if ( Utils.checkFLSPermission('Lotto__c', 'stato__c').get('UPDATE')
                && Utils.checkFLSPermission('Lotto__c', 'Tipo__c').get('UPDATE')
            ) update l;*/
        }

    }

    global BatchGeneraAffidamento(String lottoId, Integer restart) {
        this.idLotto = lottoId;
        this.restart = restart;
        if (Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Revoca__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Esito_Lavorazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Giorni_di_proroga__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Incassi_aggiornati__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Incasso_periodo_affidamento__c', gd).get('ACCESS')) {
            query = ' Select ' + Utils.cebGetSOBJECTFieldsForQuery('Affidamento__c', gd) + ' From Affidamento__c Where Lotto__c =:idLotto and stato__c=\'Da confermare\'';
        }

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        try {

            errorClass.logError('AffidamentiManager.generaAffidamentoFuture', 'affList:' + (List<Affidamento__c>) scope);
            AffidamentiManager.generaAffidamento((List<Affidamento__c>) scope);

        } catch (Exception ex) {

            System.debug('Exception in BatchGeneraAffidamento::execute() --> ' + ex.getStackTraceString());
            ErrorClass.logError('BatchGeneraAffidamento::execute() --> ' + ex.getMessage());
        }

    }

    global void finish(Database.BatchableContext BC) {
        Lotto__c lot = [SELECT Id, Tipo__c, Stato__c, Affidi__c, Affidi_in_corso__c from Lotto__c where id =:idLotto];
        if(lot.Affidi__c == lot.Affidi_in_corso__c || restart == 0) {
            if(lot.Affidi__c == lot.Affidi_in_corso__c) {
                lot.Tipo__c = 'Lotto';
                lot.Stato__c = 'Confermato';
            } else {
                lot.Tipo__c = 'Pre-Lotto';
                lot.Stato__c = 'Confermato parzialmente';
                lot.SystemCreationOfLotto__c=false;
            }
            /*
            if (Utils.cebCheckFLSPermission('Lotto__c', 'stato__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'Tipo__c', gd).get('UPDATE'))
             */
            if (Utils.cebCheckObjPermission('Lotto__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'SystemCreationOfLotto__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'stato__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Lotto__c', 'Tipo__c', gd).get('UPDATE')) {
                update lot;
            }
        } else {
            restart--;
            System.debug('BatchGeneraAffidamento retrying to generate assignment --> ' + restart);
            Database.executeBatch(new BatchGeneraAffidamento(idLotto, restart),50);
        }

        /** 2021/07/22 Old Logic - START **/
        /*
        Lotto__c l = new lotto__c();
        l.id = idLotto;
        l.Tipo__c = 'Lotto';
        l.stato__c = 'Confermato';
        if (Utils.cebCheckFLSPermission('Lotto__c', 'stato__c', gd).get('UPDATE')
                && Utils.cebCheckFLSPermission('Lotto__c', 'Tipo__c', gd).get('UPDATE')
                ) update l;
         */
        /** 2021/07/22 Old Logic - END **/
    }
}