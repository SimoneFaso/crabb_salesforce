@isTest
private class TestCPaginazione {
    public static void LOF(string ObjectName){
        ListOfFields__c l = new ListOfFields__c();
        l.name=ObjectName;
        l.object__c=ObjectName;
        l.Field__c='Name';
        l.show__c=true;
        insert l;
    }
    public static void LOF(string ObjectName,string FieldName){
        ListOfFields__c l = new ListOfFields__c();
        l.name=ObjectName+'_'+FieldName;
        l.object__c=ObjectName;
        l.Field__c=FieldName;
        l.show__c=true;
        insert l;
    }

    static testMethod void UnitTestCliente() {
        LoF('Account');
        LoF('Pratica__c');        
        LoF('Affidamento__c');        
        LoF('Contact');        
        LoF('Servizio__c');                
        LoF('Movimento__c'); 
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        cPaginazione pag = new cPaginazione();
        
        test.startTest();
        
        pag.Refresh();
        pag.Beginning();
        pag.Previous();
        pag.Next();
        pag.End();
        pag.getDisablePrevious();
        pag.getDisableNext();
        pag.getTotal_size();
        pag.getPageNumber();
        pag.getTotalPages();
        pag.RevocaAff();
        pag.Email();
        pag.getlField();
        pag.NomeParent = 'Cliente';
        
        //Task
        pag.nomeObj = 'Task';
        pag.getlField();
        pag.getObject();
        //Movimento__c
        pag.nomeObj = 'Movimento__c';
        try{pag.getObject();}catch(exception e){}
        //Piano_di_Rientro__c
        pag.nomeObj = 'Piano_di_Rientro__c';
        pag.getObject();
        //Pratica__c
        pag.nomeObj = 'Pratica__c';
        pag.getObject();
        //Attachment
        pag.nomeObj = 'Attachment';
        pag.getObject();
        //Affidamento__c
        pag.nomeObj = 'Affidamento__c';
        pag.getObject();
        //Contact
        pag.nomeObj = 'Contact';
        pag.getObject();
        //Servizio__c
        pag.nomeObj = 'Servizio__c';
        pag.getObject();
        //Servizi_Item__c
        pag.nomeObj = 'Servizi_Item__c';
        pag.getObject();
        
        test.stopTest();
        
    }
    
    static testMethod void UnitTestPratica() {
        LoF('Account');
        LoF('Pratica__c');        
        LoF('Affidamento__c');        
        LoF('Contact');        
        LoF('Servizio__c');                
        LoF('Movimento__c');                
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;        
        cPaginazione pag = new cPaginazione();
        
        test.startTest();
        
        pag.NomeParent = 'Pratica';
        
        //Task
        pag.nomeObj = 'Task';
        pag.getlField();
        pag.getObject();
        //Movimento__c
        pag.nomeObj = 'Movimento__c';
        pag.getObject();
        //Piano_di_Rientro__c
        pag.nomeObj = 'Piano_di_Rientro__c';
        pag.getObject();
        //Pratica__c
        pag.nomeObj = 'Pratica__c';
        pag.getObject();
        //Attachment
        pag.nomeObj = 'Attachment';
        pag.getObject();
        //Affidamento__c
        pag.nomeObj = 'Affidamento__c';
        pag.getObject();
        //Contact
        pag.nomeObj = 'Contact';
        pag.getObject();
        //Servizio__c
        pag.nomeObj = 'Servizio__c';
        pag.getObject();
        //Servizi_Item__c
        pag.nomeObj = 'Servizi_Item__c';
        pag.getObject();
        
        
        test.stopTest();
        
    }
    
}