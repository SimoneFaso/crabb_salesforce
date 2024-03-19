/* ---------------------------------------------------------------------------------------------------------------------
Name:            StackedData.cls
Description:     To create Staked Data graph, referenced in CruscottoClienteCTRL and CruscottoPraticaCTRL
Test class:

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1      Matteo Sala          First Version
05-Feb-2021  0.2      Giulia Mameli        Added filter on Current User Language when querying custom setting Fasce_di_Rischio__c
14-Sep-2022  0.3      C.Sanna & R.Kurti    Added WITH SECURITY_ENFORCED on the FLS fields for security check
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class StackedData {
    public String name { get; set; }
    public Integer data1 { get; set; }
    public Integer data2 { get; set; }
    public Integer data3 { get; set; }
    public Integer data4 { get; set; }
    public Integer data5 { get; set; }
    public Integer data6 { get; set; }
    public Integer data7 { get; set; }
    public Integer data8 { get; set; }
    public Decimal data21 { get; set; }
    public Decimal data22 { get; set; }
    public Decimal data23 { get; set; }
    public Decimal data24 { get; set; }
    public Decimal data25 { get; set; }
    public Decimal data26 { get; set; }
    public Decimal data27 { get; set; }
    public Decimal data28 { get; set; }
    public Integer Max { get; set; }
    public Decimal MaxRes { get; set; }

    public StackedData(String name,
            Integer data1, Integer data2, Integer data3, Integer data4, Integer data5, Integer data6, Integer data7, Integer data8,
            Decimal data21, Decimal data22, Decimal data23, Decimal data24, Decimal data25, Decimal data26, Decimal data27, Decimal data28) {
        this.name = name;
        this.data1 = data1;
        this.data2 = data2;
        this.data3 = data3;
        this.data4 = data4;
        this.data5 = data5;
        this.data6 = data6;
        this.data7 = data7;
        this.data8 = data8;
        this.data21 = data21;
        this.data22 = data22;
        this.data23 = data23;
        this.data24 = data24;
        this.data25 = data25;
        this.data26 = data26;
        this.data27 = data27;
        this.data28 = data28;
    }

    public List<StackedData> lStkData(Id oId, String obj) {
        Max = 0;
        MaxRes = 0;
        List<StackedData> stacked = new List<StackedData>();
        //Id pratId = prat.Id;
        List<Movimento__c> qResult;

        if (obj == 'Pratica') {
            //if (Utils.checkFLSPermission('Movimento__c', 'Fascia_di_Rischio__c').get('ACCESS')
            //        && Utils.checkFLSPermission('Movimento__c', 'Residuo__c').get('ACCESS')) {
                qResult = [
                        SELECT Fascia_di_Rischio__c,Residuo__c
                        FROM Movimento__c
                        Where Pratica__c = :oId
                        and Residuo__c > 0
                        and Tipo_scadenza__c = 'Scaduto'
                        and Sollecitabile__c = true
                        WITH SECURITY_ENFORCED
                ];

        } else if (obj == 'Cliente') {
        //    if (Utils.checkFLSPermission('Movimento__c', 'Fascia_di_Rischio__c').get('ACCESS')
        //            && Utils.checkFLSPermission('Movimento__c', 'Residuo__c').get('ACCESS')) {
                qResult = [
                        SELECT Fascia_di_Rischio__c,Residuo__c
                        FROM Movimento__c
                        where Account__c = :oId
                        and Residuo__c > 0
                        and Tipo_scadenza__c = 'Scaduto'
                        and Sollecitabile__c = true
                        WITH SECURITY_ENFORCED
                ];

        }
        if (qResult.size() > 0) {
            Map<String, Integer> tempMap = new Map<String, Integer>();
            Map<String, Decimal> tempMapResiduo = new Map<String, Decimal>();
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
                tempMapResiduo.put(fascia.Name, 0);
            }
            for (Movimento__c mov : qResult) {
                if (tempMap.containsKey(mov.Fascia_di_Rischio__c)) {
                    Integer i = tempMap.get(mov.Fascia_di_Rischio__c);
                    tempMap.put(mov.Fascia_di_Rischio__c, i + 1);
                } else {
                    tempMap.put(mov.Fascia_di_Rischio__c, 1);
                }
                if (tempMapResiduo.containsKey(mov.Fascia_di_Rischio__c)) {
                    Decimal res = tempMapResiduo.get(mov.Fascia_di_Rischio__c);
                    tempMapResiduo.put(mov.Fascia_di_Rischio__c, res + mov.Residuo__c);
                } else {
                    tempMapResiduo.put(mov.Fascia_di_Rischio__c, mov.Residuo__c);
                }
            }
            List<Integer> iFasce = new List<Integer>();
            List<Decimal> resFasce = new List<Decimal>();
            for (Fasce_di_Rischio__c fascia : qFasce) {
                iFasce.add(tempMap.get(fascia.Name));
                Max += tempMap.get(fascia.Name);
                resFasce.add(tempMapResiduo.get(fascia.Name));
                MaxRes += tempMapResiduo.get(fascia.Name);
            }
            if (iFasce.size() == 8) {
                stacked.add(new StackedData(Label.Range, iFasce.get(0), iFasce.get(1), iFasce.get(2), iFasce.get(3), iFasce.get(4), iFasce.get(5), iFasce.get(6), iFasce.get(7), resFasce.get(0), resFasce.get(1), resFasce.get(2), resFasce.get(3), resFasce.get(4), resFasce.get(5), resFasce.get(6), resFasce.get(7)));
            } else {
                stacked.add(new StackedData(Label.Range, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0));
            }

        }
        return stacked ;
    }
}