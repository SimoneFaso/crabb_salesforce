/* ---------------------------------------------------------------------------------------------------------------------
Name:            CrabbSharing.cls
Description:
Test class:

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
              0.1                                      First Version
13-Sep-2022   0.2      R.Kurti & C.Sanna               Added WITH SECURITY ENFORCED, added cebCheckObj and replaced CheckFLSPermissions with cebCheckFLS (security review)
----------------------------------------------------------------------------------------------------------------------*/
public without sharing class CrabbSharing {

    public static void AffidoSharing(List<Affidamento__c> newaff) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        String debug = '\n afterInsert(), ';
        Map<Id, String[]> pr = new Map<Id, String[]>();
        Map<Id, Affidamento__c> AffMap = new Map<Id, Affidamento__c>();
        Set<id> PraticaToRemoveShare = new set<id>();
        Set<id> AccountToRemoveShare = new set<id>();

        for (Affidamento__c aff : newaff) {
            AffMap.put(aff.Id, aff);
            debug += '\n \n Nome Collector Calc: ' + aff.Nome_Collector__c;
            String[] aTemp = new String[]{
                    aff.Nome_Collector__c, aff.Id_User_Assegnatario_Pratica__c, aff.Ragione_Sociale_Collector__c
            };
            pr.put(aff.Pratica__c, aTemp);
        }
        List<Pratica__Share> pratShrs = new List<Pratica__Share>();
        List<AccountShare> accShrs = new List<AccountShare>();

        if (Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('pratica__c', 'Nome_Collector_Attivo__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('pratica__c', 'Account__c',gd).get('ACCESS')) {
            Map<Id, Pratica__c> prat = new Map<Id, Pratica__c>([
                    Select Id, Nome_Collector_Attivo__c, Account__c
                    From Pratica__c
                    where Id in :pr.keySet()
                    WITH SECURITY_ENFORCED
            ]);

            debug += '\n\n PraticaShare inizializzato!';
            debug += '\n Praticas to Process: ' + String.valueOf(prat);
            for (Pratica__c target : prat.values()) {
                Id prId = target.Id;
                String NomeColl = pr.get(prId)[0];
                String RagScColl = pr.get(prId)[2];
                System.Debug('Pratica 2 ' + prId);
                System.Debug('Nome Collector 2 ' + NomeColl);
                target.Nome_Collector_Attivo__c = NomeColl;
                target.Ragione_Sociale_Collector__c = RagScColl;

                Pratica__Share ps = new Pratica__Share();
                Id userId = Id.ValueOf(pr.get(target.Id)[1]);
                ps.ParentId = target.Id;
                ps.AccessLevel = 'edit';
                ps.UserOrGroupId = userId;
                //ps.RowCause = Schema.Pratica__Share.RowCause.Affido__c;
                //ps.RowCause = Schema.Pratica__Share.RowCause.Manual;
                pratShrs.add(ps);

                AccountShare accs = new AccountShare();
                System.debug('Cliente: ' + string.valueOf(target.Account__c));
                accs.AccountId = target.Account__c;
                accs.AccountAccessLevel = 'edit';
                accs.CaseAccessLevel = 'edit';
                accs.OpportunityAccessLevel = 'edit';
                accs.UserOrGroupId = userId;
                //accs.RowCause = Schema.Pratica__Share.RowCause.Affido__c;
                accShrs.add(accs);
            }
            if (Utils.cebCheckObjPermission('Pratica__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Pratica__c', 'Nome_Collector_Attivo__c',gd).get('UPDATE')) {
                update prat.values();
            }
        }
        try {
            /*if (Utils.cebCheckObjPermission('AccountShare', gd).get('CREATE')
                    && Utils.checkFLSPermission('AccountShare', 'AccountId').get('CREATE')
                    && Utils.checkFLSPermission('AccountShare', 'AccountAccessLevel').get('CREATE')
                    && Utils.checkFLSPermission('AccountShare', 'CaseAccessLevel').get('CREATE')
                    && Utils.checkFLSPermission('AccountShare', 'OpportunityAccessLevel').get('CREATE')
                    && Utils.checkFLSPermission('AccountShare', 'UserOrGroupId').get('CREATE')) {*/
            if (Utils.cebCheckObjPermission('AccountShare', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('AccountShare', 'AccountId', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('AccountShare', 'AccountAccessLevel', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('AccountShare', 'CaseAccessLevel', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('AccountShare', 'OpportunityAccessLevel', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('AccountShare', 'UserOrGroupId', gd).get('CREATE')) {
                insert accShrs;
            }
            debug += '\n Inseriti accShrs: ' + String.valueOf(accShrs);
        } catch (Exception e) {
            System.debug('Eccezione nel metodo sbianca: ' + e.getMessage());
            debug += '\n \n Eccezione nel inserimento dei Account Share! \n Dettagli: ' + e.getMessage();
        }

        Database.SaveResult[] lsr = null;
        // if (Utils.checkFLSPermission('Pratica__Share', 'ParentId').get('CREATE')
        //     && Utils.checkFLSPermission('Pratica__Share', 'AccessLevel').get('CREATE')
        //     && Utils.checkFLSPermission('Pratica__Share', 'UserOrGroupId').get('CREATE')
        //     && Utils.checkFLSPermission('Pratica__Share', 'RowCause').get('CREATE')
        //     ) lsr = Database.insert(pratShrs,false);
        /*if (Utils.cebCheckObjPermission('Pratica__Share', gd).get('CREATE')
                && Utils.checkFLSPermission('Pratica__Share', 'ParentId').get('CREATE')
                && Utils.checkFLSPermission('Pratica__Share', 'AccessLevel').get('CREATE')
                && Utils.checkFLSPermission('Pratica__Share', 'UserOrGroupId').get('CREATE')) {*/
        if (Utils.cebCheckObjPermission('Pratica__Share', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Pratica__Share', 'ParentId',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Pratica__Share', 'AccessLevel',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Pratica__Share', 'UserOrGroupId',gd).get('CREATE')) {
            lsr = Database.insert(pratShrs, false);
        }
        debug += '\n\n SaveResult Collection: ' + String.valueOF(lsr);
        Integer x = 0;

        for (Database.SaveResult sr : lsr) {
            if (!sr.isSuccess()) {
                Database.Error err = sr.getErrors()[0];
                debug += '\n\n SR ' + x + ', Error instance, err: ' + String.valueOF(err);
                if (!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION && err.getMessage().contains('AccessLevel'))) {
                    AffMap.get(pratShrs[x].ParentId).addError('Unable to grant sharing access due to following exception: ' + err.getMessage());
                }
            }
            x++;
        }
        ErrorClass.logError('\n AffidamentiHandler', '\n ' + debug);
    }
}