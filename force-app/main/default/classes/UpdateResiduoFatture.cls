/* ---------------------------------------------------------------------------------------------------------------------
Name:            UpdateResiduoFatture.cls
Description:     Class invoked by Update Residuo Fatture Process Builder when a Collection Transaction is created.
                 It updates Residuo__c on Invoice Transactions with the sum of Importo__c of related Collection Transaction.

Test class:      TestUpdateResiduoFatture.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                        First version
             0.2       R.Kurti & C.Sanna                Added WITH SECURITY_ENFORCED and cebCheckObjPermission for security check
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class UpdateResiduoFatture {

    @InvocableMethod(Label='Update Residuo Fatture' Description='UpdateResiduoFatture')
    public static void UpdateResiduoFatture(List<Id> incassiIds) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        if (incassiIds.size() > 0) {
            List<Movimento__c> incassiList = new List<Movimento__c>();

            //if (Utils.checkFLSPermission('Movimento__c', 'IdentificativoFatturaExt__c').get('ACCESS')) {
                incassiList = [
                        SELECT IdentificativoFatturaExt__c
                        FROM Movimento__c
                        WHERE Id IN :incassiIds
                        WITH SECURITY_ENFORCED
                ];

            Set<String> fattureIds = new Set<String>();
            for (Movimento__c m : incassiList) {
                /*
                IdentificativoFatturaExt__c on collections contains an External Id referenced on the associated invoices
                IdentificativoFatturaExt__c AND Id_Movimento_Ext__c fields.
                */
                fattureIds.add(m.IdentificativoFatturaExt__c); //Id_Movimento_Ext__c
            }

            if (fattureIds.size() > 0) {
                List<Movimento__c> fatture2Updt = new List<Movimento__c>();
                List<Movimento__c> fattureList = new List<Movimento__c>();
                //if (Utils.checkFLSPermission('Movimento__c', 'IdentificativoFatturaExt__c').get('ACCESS')
                //        && Utils.checkFLSPermission('Movimento__c', 'Residuo__c').get('ACCESS')) {
                    fattureList = [
                            SELECT Id, IdentificativoFatturaExt__c, Residuo__c
                            FROM Movimento__c
                            WHERE Id_Movimento_Ext__c IN :fattureIds
                            WITH SECURITY_ENFORCED
                    ];

                //if (Utils.checkFLSPermission('Movimento__c', 'IdentificativoFatturaExt__c').get('ACCESS')
                //        && Utils.checkFLSPermission('Movimento__c', 'Importo__c').get('ACCESS')) {
                    //Importo__c on collections must be a negative number while Residuo__c must be set to zero
                    AggregateResult[] arResiduo = [
                            SELECT SUM(Importo__c), IdentificativoFatturaExt__c
                            FROM Movimento__c
                            WHERE IdentificativoFatturaExt__c IN :fattureIds
                            WITH SECURITY_ENFORCED
                            GROUP BY IdentificativoFatturaExt__c
                    ];
                    System.debug (arResiduo);

                    for (Movimento__c fatt : fattureList) {
                        for (AggregateResult ar : arResiduo) {
                            if (fatt.IdentificativoFatturaExt__c == ar.get(Utils.NAMESPACE + 'IdentificativoFatturaExt__c')) {
                                fatt.Residuo__c = Double.valueOf(ar.get('expr0'));
                                fatture2Updt.add(fatt);
                            }
                        }
                    }


                if (fatture2Updt.size() > 0 && Utils.cebCheckObjPermission('Movimento__c',gd).get('UPDATE')
                        && Utils.cebCheckFLSPermission('Movimento__c', 'IdentificativoFatturaExt__c',gd).get('UPDATE')
                        && Utils.cebCheckFLSPermission('Movimento__c', 'Residuo__c',gd).get('UPDATE')) {
                    update fatture2Updt;
                }

            }
        }
    }
}