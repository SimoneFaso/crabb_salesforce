@isTest
public class TestMettiRimuovAccWhList {
    static testmethod void testEntireClass(){
        // crea dei account
        contratto__c con = testclassfrodataGenAffidamenti.getContratto();
        insert con;
        
        Account acc = testclassfrodataGenAffidamenti.getAccount(con.Id);
        insert acc;
        
        List<Account> la = new List<Account>{acc};
        
        //chiamiamo le metodi
        test.startTest();
        MettiRimuoviDaWhList mrwl = new MettiRimuoviDaWhList();
        mrwl.mettiAccSuWhList(la , system.today(), 'ragioneWhiteList');
        mrwl.mettiAccSuWhList(la , system.today());
        mrwl.rimuoviAccDaWhList(la);
        test.stopTest();
    }
}