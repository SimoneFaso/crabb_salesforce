/* ---------------------------------------------------------------------------------------------------------------------
Name:            ChrtData.cls
Description:     To create Chart Data, referenced in CruscottoClienteCTRL and CruscottoPraticaCTRL
Test class:

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1      Matteo Sala          First Version
05-Feb-2021  0.2      Giulia Mameli        Added filter on Current User Language when querying custom setting Fasce_di_Rischio__c
13-Sep-2022  0.3      R.Kurti & C.Sanna    Added WITH SECURITY ENFORCED and replaced CheckFLSPermission with cebChecks (Security review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class ChrtData {
    public String name { get; set; }
    public Integer data1 { get; set; }
    public Decimal data2 { get; set; }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public ChrtData(String name, Integer data1, Decimal data2) {
        this.name = name;
        this.data1 = data1;
        this.data2 = data2;
    }

    public List<ChrtData> lChrtData(Id oId, String obj) {
        Map<String, Decimal> RiepMovimenti = new Map<String, Decimal>();
        List<ChrtData> data = new List<ChrtData>();
        List<Movimento__c> qResult;
        if (obj == 'Pratica') {
            if (Utils.cebCheckObjPermission('Movimento__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Fascia_di_Rischio__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Residuo__c',gd).get('ACCESS')) {
                qResult = [
                        SELECT Fascia_di_Rischio__c,Residuo__c
                        FROM Movimento__c
                        Where Pratica__c = :oId
                        and Residuo__c > 0
                        and Tipo_scadenza__c = 'Scaduto'
                        and Sollecitabile__c = true
                        WITH SECURITY_ENFORCED
                ];
            }
        } else if (obj == 'Cliente') {
            if (Utils.cebCheckObjPermission('Movimento__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Fascia_di_Rischio__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Residuo__c',gd).get('ACCESS')) {
                qResult = [
                        SELECT Fascia_di_Rischio__c,Residuo__c
                        FROM Movimento__c
                        Where Account__c = :oId
                        and Residuo__c > 0
                        and Tipo_scadenza__c = 'Scaduto'
                        and Sollecitabile__c = true
                        WITH SECURITY_ENFORCED
                ];
            }
        }
        if (qResult.size() > 0) {
            Map<String, Integer> tempMap = new Map<String, Integer>();
            List<Fasce_di_Rischio__c> qFasce = [
                    SELECT Name
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
            for (Fasce_di_Rischio__c fascia : qFasce) {
                data.add(new ChrtData(fascia.Name, tempMap.get(fascia.Name), RiepMovimenti.get(fascia.Name)));
            }
        }
        return data;
    }
}