@isTest
private class TestCoverageCruscotto
{
    //Metodo creazione Account
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
    
    //Metodo Creazione Servizio
    public static Servizio__c getTestService(){
        Servizio__c serv = new Servizio__c();
        serv.metodo_di_pagamento__c='ALTRO';
        serv.id_softwarehouse__c='XXXX';
        serv.codice__c='POSTREF';
        serv.id_esterno__c='XXXX';
        serv.stato__c='ATTIVO';
        serv.nome__c='POSTPAGATO-REFEZIONE';
        return serv;
    }
    
    //Metodo Creazione pratica
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
    
    //Metodo Creazione lista movimenti
    public static List<Movimento__c> getTestMovimento(integer numberOfMovimento){
        List<Movimento__c> movList = new List<Movimento__c>();
        for(Integer x=0; x<numberOfMovimento; x++){
            Movimento__c mov = new Movimento__c();
            mov=getTestMovimento();
            mov.Importo_Saldo_1__c+=x;
            movList.add(mov);  
        }
        return movList;
    }
    public static Map<string, Schema.RecordTypeInfo> RTMovimentoNameID;
    public static id getRTMovimentoId(string RecordTypeName){
        if(RTMovimentoNameID==null){
            RTMovimentoNameID=Schema.SObjectType.Movimento__c.getRecordTypeInfosByName();         
        }
        return RTMovimentoNameID.get(RecordTypeName).getRecordTypeID();
    }
    //Metodo creazione movimento   
    public static Movimento__c getTestMovimento(){
        Movimento__c mov = new Movimento__c();
        mov.Calcola_SALDO_ANNO__c=false;
        mov.Causale__c='CAUSALE';
        mov.Causale_Non_Sollecitabile__c='Integrazione';
        mov.Data_Emissione__c=system.today();
        mov.Data_Integrazione__c=system.today();
        mov.Data_Integrazione_1__c=system.today();
        mov.Data_Pagamento__c=system.today();
        mov.Data_Scadenza__c=system.today()-2;
        mov.Data_Saldo_1__c=system.today();
        mov.Flag_Incasso_Utente__c=false;
        mov.Importo__c=1863;
        mov.Importo_Saldo_1__c=786;
        mov.IsFutureContext__c=false;
        mov.Mese__c='AGOSTO';
        mov.Redisuo__c=47;
        mov.Ritardo__c=1;
        mov.SALDO_ANNO_LAVORATO__c=false;
        mov.Sollecitabile__c=false;
        mov.Saldo__c=758;
        mov.Saldo_Mese_Precedente__c=99;
        mov.Saldo_Mese_Precedente_Data__c=system.today();
        mov.Saldo_Spese__c=150;
        mov.Saldo_Spese_1__c=100;
        mov.Saldo_Spese_Mese_Precedente__c=10;
        mov.Residuo__c=1;
        mov.Scaduto_Saldo_1__c=1;
        mov.Tipo_Movimento_SWH__c='SWH';
        mov.Tipo_Movimento_SWH_1__c='SWH 1';
        mov.Tipo_Scadenza__c='Scaduto';
        mov.Write_Off__c=false;
        mov.Write_Off_1__c=false;               
        
        return mov;
    }
    
    //metodo creazione task
    public static Task getTestTask(){
        Task t = new Task();
        t.subject='prova';
        ActivityExtended__c ae = new ActivityExtended__c();
        ae.Tipo__c = 'Proposta';
        insert ae;
        t.ActivityExtended__c=ae.Id;
        return t;
    }
    
    //Creazione lista note
    public static List<Nota__c> getTestNote(integer numberOfNote){
        List<Nota__c> noteList = new List<Nota__c>();
        
        for(Integer x=0; x<numberOfNote; x++){
            Nota__c note = new Nota__c();
            note=getTestNote();
            note.Nota__c+=x;
            
            noteList.add(note);  
       }
        return noteList;
    }
    //Creazione nota   
    public static Nota__c getTestNote(){
        Nota__c note = new Nota__c();
        note.Current_Note__c=1;
        note.Data_Inserimento__c=system.Today();
        note.Data_Inserimento_2__c=system.Today();
        note.Max_Note__c=7;
        note.Nota__c='ccc';
        note.Nota_2__c='xxx';
        note.User__c=userinfo.getFirstName() +' '+userinfo.getLastName();
        note.User_2__c=userinfo.getFirstName() +' '+userinfo.getLastName();
        note.Visibilit__c='Visibile a tutti';
        note.Visibilit_2__c='Visibile a tutti';     
        note.ownerid=userinfo.getuserid();
        return note;
    }
    
    //Creazione strategia
    public static Map<string, Schema.RecordTypeInfo> RTStrategiaNameID;
    public static id getRTStrategiaId(string RecordTypeName){
        if(RTStrategiaNameID==null){
            RTStrategiaNameID=Schema.SObjectType.Strategia__c.getRecordTypeInfosByName();         
        }
        return RTStrategiaNameID.get(RecordTypeName).getRecordTypeID();
    }
    public static Strategia__c getTestStrategiaTestata(){
        Strategia__c str = new Strategia__c();
        str.nome__c='STRATEGIA APPALTI';
        str.priority__c=0;
        str.stato__c='Attiva';
        str.Versione__c=1;
        str.recordtypeId=getRTStrategiaId('Testata');
        str.Tipo_Strategia__c='Standard';
        str.Activation_roles__c='R2014-07-01 11:58:54,R2014-06-27 08:08:28,R2014-07-02 11:48:39,R5,R4,R6,R7,R2014-07-21 10:00:52,R2014-07-02 11:43:56,R3,R2014-07-11 10:29:40';
        return str;
    }
    
       
    
     static testMethod void UnitTestCliente(){
        //Account
        Account TestAcc = getTestAccount();
        insert TestAcc;
        //Servizio
        Servizio__c TestServ = getTestService();
        TestServ.Account__c = TestAcc.Id;
        insert TestServ;
        //Pratica
        Pratica__c TestPrat = getTestPratica();
        TestPrat.Account__c = TestAcc.Id;
        TestPrat.Servizio_Fornitura__c = TestServ.Id;
        insert TestPrat;
        //Movimenti
        List<Movimento__c> LTestMov = getTestMovimento(5);
        for(Movimento__c m : LTestMov){
            m.Account__c = TestAcc.Id;
            m.Pratica__c = TestPrat.Id;
            m.RecordTypeId = getRTMovimentoId('SALDO MESE');
            m.Buffer_Json__c = '[ { "Mese Precedente" : null, "Saldo Spese" : null, "Importo Saldo" : "0.00", "Id" : "a04Z0000009LMRXIA4", "Record Type" : "SALDO", "Indice" : "4", "Data Integrazione" : "04/09/2014", "Tipo Movimento SWH" : null, "Scaduto Saldo" : "0.00", "Write Off" : "false", "Data Saldo" : "04/09/2014" } ]';
        }
        insert LTestMov;
        //Task
        Task TestTask = getTestTask();
        ActivityExtended__c ae = [SELECT Id,Account_id__c FROM ActivityExtended__c WHERE id = :TestTask.ActivityExtended__c LIMIT 1];
        ae.Account_id__c = TestAcc.Id;
        update ae;
        insert TestTask;
        //Custom Setting DefaultView
        DefaultView__c TestDV = new DefaultView__c();
        TestDV.Name = 'Account';
        TestDV.View_ID__c = '000000000000000';
        insert TestDV; 
        List<Fasce_di_Rischio__c> fdr = new List<Fasce_di_Rischio__c>();
        fdr.add(new Fasce_di_Rischio__c(Name = 'Fino a 10 gg',Ordine__c = 1));
        fdr.add(new Fasce_di_Rischio__c(Name = 'Tra 10 e 30 gg',Ordine__c = 2));
        fdr.add(new Fasce_di_Rischio__c(Name = 'Tra 30 e 60 gg',Ordine__c = 3));
        fdr.add(new Fasce_di_Rischio__c(Name = 'Tra 60 e 90 gg',Ordine__c = 4));
        fdr.add(new Fasce_di_Rischio__c(Name = 'Tra 90 e 120 gg',Ordine__c = 5));
        fdr.add(new Fasce_di_Rischio__c(Name = 'Tra 120 e 150 gg',Ordine__c = 6));
        fdr.add(new Fasce_di_Rischio__c(Name = 'Tra 150 e 180 gg',Ordine__c = 7));
        fdr.add(new Fasce_di_Rischio__c(Name = 'Più di 180 gg',Ordine__c = 8));
        insert fdr;
        
        test.startTest();
        TaskHandler.internalUpdate = true;
        //Inizializzazione pagina e controller
        //PageReference pageRef = Page.CruscottoClienteEmbedded;
        //Test.setCurrentPage(pageRef);
        ApexPages.StandardController con = new ApexPages.Standardcontroller(TestAcc);
        ApexPages.CurrentPage().getparameters().put('Id', TestAcc.Id);
        CruscottoClienteCTRL cc = new CruscottoClienteCTRL(con);
        
        //Metodi/Variabili Controller
        cc.PagAttuale = 1;
        cc.Fine = 5;
        cc.Inizio = 0;
        cc.NPag = 1;
        cc.Max = 0;
        cc.MaxRes = 0;
        cc.getStkData();
        cc.getPieData();
        cc.getListSaldi();
        //cc.Sollecito();
        cc.getTLTask();
        cc.Next();
        cc.Previous();
        cc.Beginning();
        cc.End();
        cc.getDisableNext();
        cc.getDisablePrevious();
        cc.Refresh();
        cc.getListViewId();
        
        
        test.stopTest();
        
    }

}