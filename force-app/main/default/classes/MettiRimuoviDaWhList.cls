public with sharing class MettiRimuoviDaWhList{

    /*
    *    Classe per gestire la categorizazzione delle varie
    *    accoun dentro o fuori whiteList. Questo, tramite
    *    il flag White_List__c e fissando l'intervalo della 
    *    durata del account nel WhiteList.
    */
    
    public void mettiAccSuWhList(List<Account> myAccDaElab, Date limitWhiteListDate){
        for(Account acc : myAccDaElab){
            acc.Limite_WhiteList__c = limitWhiteListDate;
            acc.Inizio_White_List__c = System.today();
            acc.White_List__c = true;
        }
        if (Utils.checkFLSPermission('Account', 'Limite_WhiteList__c').get('UPDATE') && Utils.checkFLSPermission('Account', 'Inizio_White_List__c').get('UPDATE')  && Utils.checkFLSPermission('Account', 'White_List__c').get('UPDATE') ) update myAccDaElab;
    }
    public void mettiAccSuWhList(List<Account> myAccDaElab, Date limitWhiteListDate, string ragioneWhiteList){
        for(Account acc : myAccDaElab){
            acc.Limite_WhiteList__c = limitWhiteListDate;
            acc.Inizio_White_List__c = System.today();
            acc.Ragione_WhiteList__c=ragioneWhiteList;
            acc.White_List__C = true;
        }
        if (Utils.checkFLSPermission('Account', 'Limite_WhiteList__c').get('UPDATE') && Utils.checkFLSPermission('Account', 'Ragione_WhiteList__c').get('UPDATE') && Utils.checkFLSPermission('Account', 'Inizio_White_List__c').get('UPDATE')  && Utils.checkFLSPermission('Account', 'White_List__c').get('UPDATE') ) update myAccDaElab;
    }    
    public void rimuoviAccDaWhList(List<Account> myAccDaElab){
        System.debug('Rimuovendo dal Whitelist: \n Acc: ' + myAccDaElab);
        for(Account acc : myAccDaElab){
            acc.Limite_WhiteList__c = Null;
            acc.Inizio_White_List__c = Null;
            acc.Ragione_WhiteList__c= '';
            acc.White_List__C = false;
        }
        if (Utils.checkFLSPermission('Account', 'Limite_WhiteList__c').get('UPDATE') && Utils.checkFLSPermission('Account', 'Inizio_White_List__c').get('UPDATE')  && Utils.checkFLSPermission('Account', 'White_List__c').get('UPDATE') ) update myAccDaElab;
    }
}