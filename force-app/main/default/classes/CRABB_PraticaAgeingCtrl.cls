/* ---------------------------------------------------------------------------------------------------------------------
Name:            CRABB_PraticaAgeingCtrl.cls
Description:     Controller Class for crabbPraticaAgeing LWC used in Expired Amount Ageing tab on Pratica Object
Test class:      TestCoverageCruscottoPratica.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
04-May-2020  0.1      Matteo Sala          First Version
04-Feb-2021  0.2      Giulia Mameli        Modified getAgeing Method to add Current User Language filter when querying
                                           Fasce_di_Rischio__c
12-Sep-2022  0.3      C.Sanna & R.Kurti    Added WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class CRABB_PraticaAgeingCtrl {

    @AuraEnabled(Cacheable = true)
    public static CRABB_ColumnChart.CRABBIstogramma getAgeing(String praticaid) {

        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Map<String, Decimal> RiepMovimenti = new Map<String, Decimal>();
        CRABB_ColumnChart.CRABBIstogramma data = new CRABB_ColumnChart.CRABBIstogramma();
        List<CRABB_ColumnChart.CRABBSerie> serie = new List<CRABB_ColumnChart.CRABBSerie>();
        List<Movimento__c> qResult;

/*        if (Utils.cebCheckObjPermission('Movimento__c',gd).get('ACCESS')
                && Utils.checkFLSPermission('Movimento__c', 'Fascia_di_Rischio__c').get('ACCESS')
                && Utils.checkFLSPermission('Movimento__c', 'Residuo__c').get('ACCESS')) { */
            qResult = [
                    SELECT Fascia_di_Rischio__c,Residuo__c
                    FROM Movimento__c
                    WHERE Pratica__c = :praticaid
                    AND Residuo__c > 0
                    AND Tipo_scadenza__c = 'Scaduto'
                    AND Sollecitabile__c = true
                    WITH SECURITY_ENFORCED
            ];

            if (qResult.size() > 0) {
                Map<String, Integer> tempMap = new Map<String, Integer>();
                List<Fasce_di_Rischio__c> qFasce = [
                        SELECT Name, Ordine__c
                        FROM Fasce_di_Rischio__c
                        WHERE Lingua_Utente__c = :Label.Current_User_Language
                        WITH SECURITY_ENFORCED
                        ORDER BY Ordine__c
                        LIMIT 50000
                ];

                for (Fasce_di_Rischio__c fascia : qFasce) {
                    tempMap.put(fascia.Name, 0);
                    RiepMovimenti.put(fascia.Name, 0);
                }
                for (Movimento__c mov : qResult) {
                    if (tempMap.containsKey(mov.Fascia_di_Rischio__c)) {
                        Integer i = tempMap.get(mov.Fascia_di_Rischio__c);
                        tempMap.put(mov.Fascia_di_Rischio__c, i + 1);
                    } else {
                        tempMap.put(mov.Fascia_di_Rischio__c, 1);
                    }

                    if (RiepMovimenti.containsKey(mov.Fascia_di_Rischio__c)) {
                        Decimal d = RiepMovimenti.get(mov.Fascia_di_Rischio__c);
                        RiepMovimenti.put(mov.Fascia_di_Rischio__c, d + mov.Residuo__c);
                    } else {
                        RiepMovimenti.put(mov.Fascia_di_Rischio__c, mov.Residuo__c);
                    }
                }

                Decimal d = 0;
                for (Fasce_di_Rischio__c fascia : qFasce) {
                    //data.add(new ChrtData(fascia.Name, tempMap.get(fascia.Name), RiepMovimenti.get(fascia.Name)));
                    CRABB_ColumnChart.CRABBSerie s = new CRABB_ColumnChart.CRABBSerie();
                    s.colore = String.ValueOf(fascia.Ordine__c);
                    s.descrizione = fascia.Name;
                    s.valore = RiepMovimenti.get(fascia.Name);
                    s.quantitativo = tempMap.get(fascia.Name);
                    serie.add(s);
                    System.Debug(s);
                    d += RiepMovimenti.get(fascia.Name);
                }

                if(Label.Current_User_Language == 'Italiano'){
                    data.titolo = 'Pratica Ageing';
                } else {
                    data.titolo = 'Dossier Ageing';
                }
                data.size = Integer.ValueOf(d + ((d * 10) / 100));
                data.serie = serie;
                System.debug(data);
            }

        return data;
    }

}