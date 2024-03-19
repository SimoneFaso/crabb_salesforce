/**
 * Created by MatteoSala on 08/06/2020.
 */

@IsTest
private class CRABB_PDRCtrl_TEST {
    @IsTest
    static void testBehavior()
    {
        Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        insert con;

        Account ac = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert ac;

        Pratica__c p = TestClassFroDataGenAffidamenti.getPratica(ac.Id);
        p.Stato__c = 'Da Elaborare';
        insert p;

        CRABB_PDR_Structure ps = new CRABB_PDR_Structure();
        ps.Pratica = p.Id;
        ps.Importo_Tot = 100;
        ps.Num_Rate = 1;
        ps.Calcolo_Int = true;
        ps.Int_Mora = 0.05;
        ps.Int_Dilazione = 0;
        ps.ListRate = new List<CRABB_PDR_Structure.CRABB_Rate_Structure>();
        CRABB_PDR_Structure.CRABB_Rate_Structure rs = new CRABB_PDR_Structure.CRABB_Rate_Structure();
        rs.Importo_Rata = 100;
        rs.Data_Rata = System.today();
        ps.ListRate.add(rs);

        test.startTest();

        CRABB_PDRCtrl.ExistPDR(p.Id);
        CRABB_PDRCtrl.CreatePDR(ps);
        List<Rateizzazione__c> rataList = CRABB_PDRCtrl.getRate(p.Id);
        CRABB_PDRCtrl.changeStatoRata(rataList.get(0).Id, 'Pagata');
        CRABB_PDRCtrl.getPraticaId(ac.Id);
        CRABB_PDRCtrl.getPraticaId(p.Id);
        CRABB_PDRCtrl.ExistPratica(ac.Id, false);
        CRABB_PDRCtrl.ListPDRAccount(ac.Id);
        CRABB_PDRCtrl.getStatoMap();
        CRABB_PDRCtrl.createAttachment(CRABB_PDRCtrl.CreatePDR(ps).Id, p.Id);


        test.stopTest();
    }
}