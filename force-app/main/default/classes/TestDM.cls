/*
* CreatedBy: KMeta
* CreatedDate:04/08/2014
* Description: Questa classe ha lo scopo di generare dati del data model precompilati secondo le necessità. I dati sono presi da record esistenti a sistema e sono
*              stati modificati i dati sensibili o collegamenti tra oggetti (lookup). Sono dei pezzi di lego fondamentali per  poi costruire scenari di test
*              complessi. Sono tutti dati prototipo, poi bisogna che vengano manipolati secodo le neccessità per poter creare un vero e proprio caso di test
*              sono 
*/

@isTest
public class TestDM{
    /*Metodi di set lookup tra vari oggetti */
    public static void AssociateAccountToPratica(Account a,List<Pratica__c> pList) {
        for(pratica__c p:pList){
            p.Account__c=a.id;
        }
    }
    public static void AssociateAccountToPratica(Account a,Pratica__c p) {
        p.Account__c=a.id;
    }    
    public static void setAccountToPratica(Account a,List<Pratica__c> pList) {
        for(pratica__c p:pList){
            p.Account__c=a.id;
        }
    }   
    public static void setAccountTriggerCause(List<Account> accList) {
        for(Account a:accList){
            a.trigger_cause__c='*0*';
        }
    }   
   public static void setContrattoOnAccount(Contratto__c c, List<Account> accList) {
        for(Account a:accList){
            a.Contratto__c=c.id;
        }
    }   
   public static void setContrattoOnServizio(Contratto__c c, List<Servizio__c> serList) {
        for(Servizio__c s:serList){
            s.LookupContratto__c=c.id;
        }
    }       
   public static void setAccountOnServizio(Account a, List<Servizio__c> serList) {
        for(Servizio__c s:serList){
            s.Account__c=a.id;
        }
    }   
   public static void setServizioOnServizi_Item(servizio__c serv, List<Servizi_Item__c> sItemList) {
        for(Servizi_Item__c s:sItemList){
            s.Servizio__c=serv.id;
        }
    }   
   public static void setServizioOnPratica(servizio__c serv, List<Pratica__c> pList) {
        for(Pratica__c p:pList){
            p.Servizio_Fornitura__c=serv.id;
        }
    }       
   public static void setServizioOnMovimento(servizio__c serv, List<Movimento__C> mList) {
        for(Movimento__C m:mList){
            m.Servizio_Fornitura__c=serv.id;
        }
    }       
   public static void setServizioItemOnMovimento(Servizi_Item__c serv, List<Movimento__C> mList) {
        for(Movimento__C m:mList){
            m.Servizio_Item__c=serv.id;
        }
    }   
   public static void setAccountOnMovimento(Account a, List<Movimento__C> mList) {
        for(Movimento__C m:mList){
            m.Account__c=a.id;
        }
    }



    /*Metodi set Stato*/
    public static void setPraticaStatusToInLavorazione(List<Pratica__c> pList) {
        for(Pratica__c p:pList){
            p.stato__c='In Lavorazione';
        }
    } 
}