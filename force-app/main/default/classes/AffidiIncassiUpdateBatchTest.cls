/*
*   Creata: ESino, 01/07/2016
*
*   Desc: Classe di test per il AffidiIncassiUpdateBatch.
*/
@isTest (SeeAllData = false)
public class  AffidiIncassiUpdateBatchTest {
    
    static testmethod void executeBatch() {
        // Create Account, Pratica, Lotto, e Affido
        Contratto__c cont = TestClassFroDataGenAffidamenti.getContratto();
        insert cont;

        Account acc = TestClassFroDataGenAffidamenti.getAccount(cont.id);
        insert acc;

        Pratica__c prat = TestClassFroDataGenAffidamenti.getPratica(acc.id);
        insert prat;

        User u = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');

        Collector__c col = TestClassFroDataGenAffidamenti.getCollector(u.id);
        insert col;

        Lotto__c lotto = TestClassFroDataGenAffidamenti.getLotto(col.id);
        insert lotto;

        Affidamento__c affido = TestClassFroDataGenAffidamenti.getAffido('Da confermare', System.today(), lotto.id, prat.id);
        insert affido;

        Affidamento__c affidoTmp = new Affidamento__c(id = affido.id, Incassi_aggiornati__c = false);
        update affidoTmp;

        Test.startTest();
            Id BatchId = Database.executeBatch(new AffidiIncassiUpdateBatch(), 100);
        Test.stopTest();
    }
}