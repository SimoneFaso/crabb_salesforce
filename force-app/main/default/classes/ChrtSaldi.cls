/* ---------------------------------------------------------------------------------------------------------------------
Name:            ChrtSaldi.cls
Description:
Test class:

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
12-Sep-2022  0.2      C.Sanna & R. Kurti              Added cebCheck Obj/FLS security and WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class ChrtSaldi {

    public String dataSaldo { get; set; }
    public Decimal Scaduto { get; set; }
    public Decimal Importo { get; set; }
    public Decimal SaldoSpese { get; set; }
    public String DataIntegrazione { get; set; }
    public String TipoMovimentoSWH { get; set; }
    public Boolean WriteOff { get; set; }
    public String idSaldo { get; set; }
    public String RType { get; set; }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    //public List<Movimento__c> qResult { get; set; }
    //public Integer Offset = 10;

    /*public ChrtSaldi(String dataSaldo, Decimal Scaduto, Decimal Importo) 
    {  
        this.dataSaldo = dataSaldo;
        this.Scaduto = Scaduto;
        this.Importo = Importo;
    }*/

    private Static Integer Minus4Months(Integer a, Integer m) {
        if (m < 4) {
            a = a - 1;
            m = m + 9;
        } else
                m = m - 3;
        Integer am = a * 100 + m;
        return am;
    }

    public ChrtSaldi(String idSaldo, String RType, String dataSaldo, Decimal Scaduto, Decimal Importo, Decimal SaldoSpese, String DataIntegrazione, String TipoMovimentoSWH, Boolean WriteOff) {
        this.idSaldo = idSaldo;
        this.RType = RType;
        this.dataSaldo = dataSaldo;
        this.Scaduto = Scaduto;
        this.Importo = Importo;
        this.SaldoSpese = SaldoSpese;
        this.DataIntegrazione = DataIntegrazione;
        this.TipoMovimentoSWH = TipoMovimentoSWH;
        this.WriteOff = WriteOff;
    }

    public List<ChrtSaldi> Json2Chrt(Id oId, String obj) {
        List<ChrtSaldi> data = new List<ChrtSaldi>();
        Date d = date.today();
        List<Movimento__c> qResult;
        //Integer am = d.year()*100+d.month();
        Integer am = Minus4Months(d.year(), d.month());
        if (obj == 'Pratica') {
            if (Utils.cebCheckObjPermission('Movimento__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Buffer_Json__c', gd).get('ACCESS')) {
                qResult = [
                        SELECT Buffer_Json__c
                        FROM Movimento__c
                        Where Pratica__c = :oId AND RecordType.Name IN ('SALDO MESE', 'SALDO MESE CONSOLIDATO') and Anno_Mese__c >= :am
                        WITH SECURITY_ENFORCED
                        order by Anno_Mese__c DESC, Id_Esterno_Saldo_Mensile__c DESC, Id_Movimento_Ext__c DESC
                ];
            }
        } else if (obj == 'Cliente') {
            if (Utils.cebCheckObjPermission('Movimento__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Buffer_Json__c',gd).get('ACCESS')) {
                qResult = [
                        SELECT Buffer_Json__c
                        FROM Movimento__c
                        Where Account__c = :oId and RecordType.Name IN ('SALDO MESE', 'SALDO MESE CONSOLIDATO') and Anno_Mese__c >= :am
                        WITH SECURITY_ENFORCED
                        order by Anno_Mese__c DESC, Id_Esterno_Saldo_Mensile__c DESC, Id_Movimento_Ext__c DESC
                ];
            }
        }
        if (qResult.size() > 0) {
            for (Integer i = qResult.size() - 1; i >= 0; i--) {
                List<Map<String, String>> lMyMap = new List<Map<String, String>>();
                lMyMap = (List<Map<string, string>>) JSON.deserialize(qResult[i].Buffer_Json__c, List<Map<string, string>>.Class);
                for (Map<string, string> mss : lMyMap) {
                    String ids = '';
                    if (mss.get('Id') != null)
                        ids = String.ValueOF(mss.get('Id'));
                    String rt = '';
                    system.debug('Record Type = ' + mss.get('Record Type'));
                    if (mss.get('Record Type') != null)
                        rt = mss.get('Record Type');
                    system.debug('RT = ' + rt);
                    String ds = '';
                    if (mss.get('Data Saldo') != null)
                        ds = mss.get('Data Saldo');
                    String di = '';
                    if (mss.get('Data Integrazione') != null)
                        di = mss.get('Data Integrazione');
                    String tms = '';
                    if (tms != null)
                        tms = mss.get('Tipo Movimento SWH');
                    Boolean wo = false;
                    if (mss.get('WriteOff') != null)
                        wo = Boolean.ValueOf(mss.get('WriteOff'));
                    Decimal ss = 0;
                    if (mss.get('Saldo Spese') != null)
                        ss = Decimal.valueof(mss.get('Saldo Spese'));
                    Decimal sc = 0;
                    if (mss.get('Scaduto Saldo') != null)
                        sc = Decimal.valueof(mss.get('Scaduto Saldo'));
                    Decimal is = 0;
                    if (mss.get('Importo Saldo') != null)
                        is = Decimal.valueof(mss.get('Importo Saldo'));
                    data.add(new ChrtSaldi(ids, rt, ds, sc, is, ss, di, tms, wo));
                }
            }
        }
        return data;
    }

}