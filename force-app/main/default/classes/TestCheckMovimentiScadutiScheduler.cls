/**
 * Created by m.siotto on 12/11/2020.
 */
@isTest
public class TestCheckMovimentiScadutiScheduler {

    @isTest
    static void testmethod_ok() {
        List<Movimento__c> lmov = new List<Movimento__c>();
        lmov = TestMovimentoHandler.getMovimenti();
        lmov[0].Tipo_Scadenza__c = 'In Scadenza';
        lmov[0].Data_Scadenza__c = date.today() - 15;
        lmov[0].Residuo__c = -10;

        List<Movimento__c> lmovNEw = new List<Movimento__c>();
        lmovNEw = TestMovimentoHandler.getMovimenti();
        lmovNEw[0].Tipo_Scadenza__c = 'In Scadenza';
        lmovNEw[0].Data_Scadenza__c = date.today() + 15;
        lmovNEw[0].Residuo__c = 10;
        lmov.addAll(lmovNEw);

        lmovNEw = TestMovimentoHandler.getMovimenti();
        lmovNEw[0].Tipo_Scadenza__c = 'In Scadenza';
        lmovNEw[0].Data_Scadenza__c = date.today();
        lmovNEw[0].Residuo__c = 0;
        lmov.addAll(lmovNEw);

        lmovNEw = TestMovimentoHandler.getMovimenti();
        lmovNEw[0].Tipo_Scadenza__c = 'Scaduto';
        lmovNEw[0].Data_Scadenza__c = date.today() - 15;
        lmovNEw[0].Residuo__c = 10;
        lmov.addAll(lmovNEw);

        lmovNEw = TestMovimentoHandler.getMovimenti();
        lmovNEw[0].Tipo_Scadenza__c = 'Scaduto';
        lmovNEw[0].Data_Scadenza__c = date.today() + 5;
        lmovNEw[0].Residuo__c = 0;
        lmov.addAll(lmovNEw);

        lmovNEw = TestMovimentoHandler.getMovimenti();
        lmovNEw[0].Tipo_Scadenza__c = 'Scaduto';
        lmovNEw[0].Data_Scadenza__c = date.today() + 5;
        lmovNEw[0].Residuo__c = -10;
        lmov.addAll(lmovNEw);

        lmovNEw = TestMovimentoHandler.getMovimenti();
        lmovNEw[0].Tipo_Scadenza__c = 'Pagato';
        lmovNEw[0].Data_Scadenza__c = date.today() + 5;
        lmovNEw[0].Residuo__c = 10;
        lmov.addAll(lmovNEw);

        lmovNEw = TestMovimentoHandler.getMovimenti();
        lmovNEw[0].Tipo_Scadenza__c = 'Pagato';
        lmovNEw[0].Data_Scadenza__c = date.today() - 5;
        lmovNEw[0].Residuo__c = 10;
        lmov.addAll(lmovNEw);

        lmovNEw = TestMovimentoHandler.getMovimenti();
        lmovNEw[0].Tipo_Scadenza__c = 'Pagato';
        lmovNEw[0].Data_Scadenza__c = date.today() + 5;
        lmovNEw[0].Residuo__c = -10;
        lmov.addAll(lmovNEw);

        lmovNEw = TestMovimentoHandler.getMovimenti();
        lmovNEw[0].Tipo_Scadenza__c = 'Credito';
        lmovNEw[0].Data_Scadenza__c = date.today() + 5;
        lmovNEw[0].Residuo__c = 0;
        lmov.addAll(lmovNEw);

        lmovNEw = TestMovimentoHandler.getMovimenti();
        lmovNEw[0].Tipo_Scadenza__c = 'Credito';
        lmovNEw[0].Data_Scadenza__c = date.today() + 5;
        lmovNEw[0].Residuo__c = 10;
        lmov.addAll(lmovNEw);

        lmovNEw = TestMovimentoHandler.getMovimenti();
        lmovNEw[0].Tipo_Scadenza__c = 'Credito';
        lmovNEw[0].Data_Scadenza__c = date.today() - 5;
        lmovNEw[0].Residuo__c = 10;
        lmov.addAll(lmovNEw);

        insert lmov;

        test.startTest();
        CheckMovimentiScadutiScheduler sche = new CheckMovimentiScadutiScheduler();
        system.schedule('CheckMovimentiScaduti', '0 0 22 * * ? *', sche);
        test.stopTest();
    }

}