@isTest
private class TestListOfObjects {
    public static void LOF(string ObjectName){
        ListOfFields__c l = new ListOfFields__c();
        l.name='Test';
        l.object__c=ObjectName;
        l.Field__c='Name';
        l.show__c=true;
        insert l;
    }
    public static void LOF(string ObjectName,string FieldName){
        ListOfFields__c l = new ListOfFields__c();
        l.name='Test';
        l.object__c=ObjectName;
        l.Field__c=FieldName;
        l.show__c=true;
        insert l;
    }
    public static Account getTestAccount(){
        account acc = new Account();
        
        acc.Indirizzo_Principale__c=false;
        acc.Phone_SMS__c='8888888888';
        acc.mail_sollecito__c='test@balanceconsulting.it';
        acc.White_List__c=false;
        acc.ShippingState='FI';
        acc.phone='0000000000';
        acc.Phone2__c='2222222222';
        acc.phone3__c='3333333333';
        acc.phone4__c='4444444444';
        acc.phone5__c='5555555555';
        acc.phone6__c='6666666666';
        acc.mail1__c='test1@balanceconsulting.it';
        acc.mail2__c='test2@balanceconsulting.it';
        acc.mail3__c='test3@balanceconsulting.it';
        acc.mail4__c='test4@balanceconsulting.it';
        acc.BillingState='FI';
        acc.Invio_Piano_di_Rientro__c=false;
        acc.BillingPostalCode='50063';
        acc.Codice_Fiscale__c='NA';
        acc.ShippingCity='FIGLINE VALDARNO';
        acc.Fascia_ISEE__c='764,33';
        acc.Pratiche_In_Lavorazione__c=0;
        acc.Scadenza_ISEE__c=date.valueof('2014-09-11');
        acc.ShippingStreet='P.ZZA S. FRANCESCO DASSISI, 1114';
        acc.Warning_Integration__c=false;
        acc.BillingStreet='P.ZZA S. FRANCESCO DASSISI, 1114';
        acc.Name='MORALES BATTISTA YAMILENIS';
        acc.BillingCity='FIGLINE VALDARNO';
        acc.Invio_Sollecito__c=false;
        acc.ShippingPostalCode='50063';
        acc.data_scaduto__c=system.today();
        acc.codice_account__c='Codice account Test';
        acc.stato__c='Attivo';
        acc.importo_incasso_corrente__c=0;
        acc.invio_piano_di_rientro__c=false;        
        acc.trigger_cause__c=null;
        
        return acc;
    }
    
    public static Pratica__c getTestPratica(){
        Pratica__c p = new Pratica__c();
        p.Anzianit_Pratica__c=system.today();
        p.Check_In_Lavorazione__c=false;
        p.Data_inizio_scaduto__c=system.today();
        p.Esci_e_chiudi__c=false;
        p.Fascia_di_rischio__c='1234';
        p.Importo_Incasso_Consolidato__c=0;
        p.Nome_Collector_Attivo__c='XXX';
        p.Request__c='Request XXX';
        p.Importo_saldo_Consolidato__c=0;
        p.Importo_Spese_Consolidato__c=0;
        p.Importo_Scaduto_Consolidato__c=0;
        p.Scaduto_Spese__c=0;
        p.Scaduto_Spese_Consolidato__c=0;
        p.Stato__c='Bozza';
        p.ownerid=userinfo.getuserid();
        return p;
    }

    static testMethod void UnitTestPraticaCount() {
        
        ListOfObjects LOO = new ListOfObjects();
        Pratica__c TestPrat = getTestPratica();
        String oPadre = 'Pratica';
        Id idPadre = TestPrat.Id;
        String TipoPadre = 'Saldo';
        
        test.startTest();
        
        LOO.qMov_Count(oPadre, IdPadre, TipoPadre);
        LOO.qInd_Count(oPadre, IdPadre);
        LOO.qPrat_Count(oPadre, IdPadre);
        LOO.qSer_Count(oPadre, IdPadre);
        LOO.qPDR_Count(oPadre, IdPadre);
        
        test.stopTest();
        
    }
    
    static testMethod void UnitTestClienteCount() {
        
        ListOfObjects LOO = new ListOfObjects();
        Account TestAcc = getTestAccount();
        String oPadre = 'Cliente';
        Id idPadre = TestAcc.Id;
        String TipoPadre = 'Saldo';
        
        test.startTest();
        
        LOO.qMov_Count(oPadre, IdPadre, TipoPadre);
        LOO.qInd_Count(oPadre, IdPadre);
        LOO.qPrat_Count(oPadre, IdPadre);
        LOO.qSer_Count(oPadre, IdPadre);
        LOO.qAff_Count(oPadre, IdPadre);
        
        test.stopTest();
        
    }
    static testMethod void UnitTestGetFields() {

       test.startTest();
         List<string> myList=   ListOfObjects.GetFields('Test');    
       test.stopTest();        
    }
    static testMethod void UnitTestGetFields2() {
        ListOfFields__c l = new ListOfFields__c();
        l.name='Test';
        l.object__c='Test';
        l.show__c=true;
        insert l;
        test.startTest();
            List<string> myList=   ListOfObjects.GetFields('Test');    
        test.stopTest();        
    }
    static testMethod void UnitTestConcatenateFields() {
        List<string> s =new List<string>();
        s.add('XX');
        s.add('YY');
        s.add('ZZ');
       test.startTest();
         string listToString=   ListOfObjects.ConcatenateFields(s);    
       test.stopTest();        
    }
    //Test per i Movimenti
    static testMethod void UnitTestQMov_Offset() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        LOF('Movimento__c');
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            List<Movimento__c> listToString=   lo.qMov_OffSet('Cliente',acc.id,'Consolidato',5,10);
            List<Movimento__c> listToString1=   lo.qMov_OffSet('Cliente',acc.id,'Saldo',5,10);
            List<Movimento__c> listToString2=   lo.qMov_OffSet('Cliente',acc.id,'Incasso',5,10);
        test.stopTest();        
    }
    static testMethod void UnitTestQMov_Offset2() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        insert p;
        LOF('Movimento__c');
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            List<Movimento__c> listToString=   lo.qMov_OffSet('Pratica',p.id,'Consolidato',5,10);
            List<Movimento__c> listToString1=   lo.qMov_OffSet('Pratica',p.id,'Saldo',5,10);
            List<Movimento__c> listToString2=   lo.qMov_OffSet('Pratica',p.id,'Incasso',5,10);
        test.stopTest();        
    }
    static testMethod void UnitTestQMov_Offset3() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        insert p;
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            try{
                List<Movimento__c> listToString=   lo.qMov_OffSet('Pratica',p.id,'Consolidato',5,10);
            }
            catch(Exception e){
            }
        test.stopTest();        
    }
    //Test Contatti
    static testMethod void UnitTestQInd_Offset() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        LOF('Contact');
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            List<Contact> listToString=   lo.qInd_OffSet('Cliente',acc.id,5,10);
        test.stopTest();        
    }
    //Test Servizio
    static testMethod void UnitTestQSer_Offset() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        LOF('Servizio__c');
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            List<Servizio__c> listToString=   lo.qSEr_OffSet('Cliente',acc.id,5,10);
        test.stopTest();        
    }   
    //Test Pratica
    static testMethod void UnitTestQPrat_Offset() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        LOF('Pratica__c');
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            List<Pratica__c> listToString=   lo.qPrat_OffSet('Cliente',acc.id,5,10);
        test.stopTest();        
    }   
    //Test PDR
    static testMethod void UnitTestQPDR_Offset2() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        insert p;
        LOF('Piano_di_Rientro__c');
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            List<Piano_di_Rientro__c> listToString=lo.qPDR_Offset('Pratica',p.id,05,10);
            List<Piano_di_Rientro__c> listToString2=lo.qPDR_Offset('Cliente',acc.id,5,10);
        test.stopTest();        
    }
    
    //Test PDR
    static testMethod void UnitTestQAtt_Offset2() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        insert p;
        LOF('Attachment');
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            List<Attachment> listToString=   lo.qAtt_Offset('Pratica',p.id,5,10);
            List<Attachment> listToString2=   lo.qAtt_Offset('Cliente',acc.id,5,10);
        test.stopTest();        
    }
    
    //Test Task
    static testMethod void UnitTestqqTsk_Offset() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        insert p;
        LOF('Task','status');
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            List<Task> listToString=   lo.qTsk_Offset('Pratica',p.id,5,10);
            List<Task> listToString2=   lo.qTsk_Offset('Cliente',acc.id,5,10);
        test.stopTest();        
    }   
    //Test Task
    static testMethod void UnitTestqqTsk_Offset2() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        insert p;
        LOF('MyTask','status');
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            List<Task> listToString3=   lo.qTsk_Offset('MyTask',acc.id,5,10);
        test.stopTest();        
    }   
    //Test ServiziItem
    static testMethod void UnitTestqSItem_Offset() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        insert p;
        LOF('Servizi_item__c');
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            List<Servizi_item__c> listToString=   lo.qSItem_Offset('Pratica',p.id,5,10);
            List<Servizi_item__c> listToString2=   lo.qSItem_Offset('Cliente',acc.id,5,10);
        test.stopTest();        
    }   
    //Test Affidamento
    static testMethod void UnitTestqAff_Offset() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        insert p;
        LOF('Affidamento__c');
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            List<Affidamento__c> listToString=   lo.qAff_Offset('Pratica',p.id,5,10);
        test.stopTest();        
    }   
    //Test Movimento
    static testMethod void UnitTestqMov_Count() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        insert p;
        LOF('Movimento__c');
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            integer listToString=   lo.qMov_Count('Pratica',p.id,'Consolidato');
            integer listToString2=   lo.qMov_Count('Pratica',p.id,'Saldo');
            integer listToString3=   lo.qMov_Count('Pratica',p.id,'Incasso');
        test.stopTest();        
    }   
    //Test Movimento
    static testMethod void UnitTestqMov_Count2() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        insert p;
        LOF('Movimento__c');
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            integer listToString=   lo.qMov_Count('Cliente',acc.id,'Consolidato');
            integer listToString2=   lo.qMov_Count('Cliente',acc.id,'Saldo');
            integer listToString3=   lo.qMov_Count('Cliente',acc.id,'Incasso');
        test.stopTest();        
    }   
    //Test qPrat_Count
    static testMethod void UnitTestqPrat_Count() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        insert p;
        LOF('Pratica__c');
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            integer listToString=   lo.qPrat_Count('Cliente',acc.id);
        test.stopTest();        
    }   
    //Test qPDR_Count
    static testMethod void UnitTestqPDR_Count() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        insert p;
        LOF('Piano_di_Rientro__c');
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            integer listToString=   lo.qPDR_Count('Cliente',acc.id);
            integer listToString2=   lo.qPDR_Count('Pratica',p.id);
        test.stopTest();        
    }   
    //Test qPDR_Count
    static testMethod void UnitTestqAtt_Count() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        insert p;
        LOF('Piano_di_Rientro__c');
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            integer listToString=   lo.qAtt_Count('Cliente',acc.id);
            integer listToString2=   lo.qAtt_Count('Pratica',p.id);
        test.stopTest();        
    }   
    //Test qTsk_Count
    static testMethod void UnitTestqTsk_Count() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        insert p;
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            integer listToString=   lo.qTsk_Count('Cliente',acc.id);
            integer listToString2=   lo.qTsk_Count('Pratica',p.id);
            integer listToString3=   lo.qTsk_Count('MyTask',p.id);
        test.stopTest();        
    }
    //Test qAff_Count
    static testMethod void UnitTestqAff_Count() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        insert p;
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            integer listToString2=   lo.qAff_Count('Pratica',p.id);
        test.stopTest();        
    }
    //Test qInd_Count
    static testMethod void UnitTestqInd_Count() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        insert p;
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            integer listToString2=   lo.qAff_Count('Cliente',acc.id);
        test.stopTest();        
    }
    
    //Test qSer_Count
    static testMethod void UnitTestqSer_Count() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        insert p;
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            integer listToString2=   lo.qSer_Count('Cliente',acc.id);
        test.stopTest();        
    }
    
    //Test qSer_Count
    static testMethod void UnitTestqqSItem_Count() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        insert p;
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            integer listToString=   lo.qSItem_Count('Pratica',p.id);
            integer listToString2=   lo.qSItem_Count('Cliente',acc.id);
        test.stopTest();        
    }
    
    //Test qNote
    static testMethod void UnitTestqNote() {
        account acc= new Account();
        acc.Name='Test';
        insert acc;
        Pratica__c p= new Pratica__c();
        p.account__C=acc.id;
        insert p;
        test.startTest();
            ListOfObjects lo=new ListOfObjects();
            List<Nota__c> listToString=   lo.qNote('Pratica',p.id);
            List<Nota__c> listToString2=   lo.qNote('Cliente',acc.id);
        test.stopTest();        
    }
}