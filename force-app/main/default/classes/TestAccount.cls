/*
* CreatedBy: KMeta
* CreatedDate: 1/August/2014
* Description: contiene i test legati al trigger degli accout ( che avviano attività lato account )
*/

@isTest
public class TestAccount{
    
    static testMethod void CreazioneAccountSemplici(){
        integer i=5;
        List<Account> accList = TestClassForDatagenerationCreateData.getTestAccounts(i);
        test.startTest();
            insert accList;
        test.stopTest();
        
        System.assertEquals(i,accList.size());
        
    }
    static testMethod void deleteAccountSemplici(){
        integer i=5;
        List<Account> accList = TestClassForDatagenerationCreateData.getTestAccounts(i);
        insert accList;
        test.startTest();
            delete accList;
        test.stopTest();
        
        System.assertEquals(i,accList.size());
        
    }    
    static testMethod void updateAccountSemplici(){
        integer i=5;
        List<Account> accList = TestClassForDatagenerationCreateData.getTestAccounts(i);
        insert accList;
        test.startTest();
            update accList;
        test.stopTest();
        
        System.assertEquals(i,accList.size());
    }
    static testMethod void AccountAndPratica_1(){
        /*Scenario i Account senza pratica, a cui viene richiestao di aggiornare il numero di prache "Attive"
        * Trigger_cause__c viene posto a *0* che avvia la logica di ricalcolare il numero di pratiche "attive"
        */
        integer i=5;
        List<Account> accList = TestClassForDatagenerationCreateData.getTestAccounts(i);
        //throw new Utils.BalanceException('ACCLIST:'+accList);
        insert accList;
        TestDM.setAccountTriggerCause(accList);
        test.startTest();
            update accList;
        test.stopTest();
        System.assertEquals(i,accList.size());
    }
    static testMethod void AccountAndPratica_2(){
        /*Scenario i Account con pratica attiva, Il cambiamento dello stato della partica cambia anche l'account 
        * Trigger_cause__c viene posto a *0* che avvia la logica di ricalcolare il numero di pratiche "attive"
        */
        integer i=1;
        account a = new account();
        List<Account> accList = TestClassForDatagenerationCreateData.getTestAccounts(i);
        List<Pratica__c> pList = TestClassForDatagenerationCreateData.getTestPratica(i);
        
        insert accList;
        a= accList[0];
        TestDM.setAccountToPratica(a,pList);
        insert plist;
        TestDM.setPraticaStatusToInLavorazione(pList);
        
        test.startTest();
            update pList;
            Account aEnd=[Select id, Pratiche_In_Lavorazione__c from Account where id=:a.id];
        test.stopTest();
        System.assertEquals(1,aEnd.Pratiche_In_Lavorazione__c);
    }   
    
}