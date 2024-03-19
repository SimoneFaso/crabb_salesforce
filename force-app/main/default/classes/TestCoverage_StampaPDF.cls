@isTest
private class TestCoverage_StampaPDF {

    static testMethod void myUnitTest() {
       
        Id rtIdAcc1 =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('CONSUMER').getRecordTypeId();
    //    Id rtIdServ2 =  Schema.SObjectType.Servizio__c.getRecordTypeInfosByName().get('PREREF').getRecordTypeId();
        Id rtIdServ2 =  Schema.SObjectType.Servizio__c.getRecordTypeInfosByName().get('CRABB 1').getRecordTypeId();

        Contratto__c Contratto1 = new Contratto__c();
        Date dataInizio = Date.today();
        Contratto1.Data_Inizio__c = DataInizio;
        Contratto1.Titolo__c = 'Contratto1'; 
        Contratto1.Partita_IVA__c = '02197312389';
        Contratto1.Comune__c = 'Milano';
        insert Contratto1;
        
        Account Acc = new Account();
        Acc.Id_Esterno__c = 'ETC_Cont_IdExt_ETC2_Account_IdExt_ETC2'; 
        Acc.Name = 'Account1';
        Acc.RecordTypeId = rtIdAcc1;
        insert Acc;
        
        Servizio__c Serv = new Servizio__c();
        Serv.Id_Esterno__c = 'ETC_Cont_IdExt_ETC2_Account_IdExt_ETC2_POSTREF';
        Serv.RecordTypeId = rtIdServ2;
        Serv.Account__c = Acc.Id;
        Serv.LookupContratto__c = Contratto1.Id;
        Insert Serv;
        
        Servizi_Item__c Fruit = new Servizi_Item__c();
        Fruit.Servizio__c = Serv.id;
        Fruit.Classe__c = 'VB';
        Fruit.Cognome__c = 'Pinturicchio';
        Fruit.Data_di_Nascita__c = date.newInstance(1989, 03, 03);
        Fruit.Nome__c = 'Albertino';
        Fruit.Luogo_di_Nascita__c = 'Torino';
        Fruit.MF__c = 'MASCHIO';
        Fruit.Scuola__c = 'ENIGEN';
        Fruit.Id_Esterno__c = 'ETC_Cont_IdExt_ETC3_Fru_Id_ETC3';
        INSERT Fruit;
        
        Pratica__c Prat = new Pratica__c();
        Prat.Account__c = Acc.Id;
        Prat.Servizio_Fornitura__c = Serv.Id;
        Prat.Stato__c = 'Bozza';
        Insert Prat;
       
       Movimento__c MovSaldo1 = new Movimento__c();
        MovSaldo1.Id_Movimento_Ext__c = 'ETC_Cont_IdExt_ETC3_Account_IdExt_ETC3_POSTREF_201405'; 
        MovSaldo1.Id_Esterno_Saldo_Mensile__c = 'ETC_Cont_IdExt_ETC3_Account_IdExt_ETC3_POSTREF_201405';
        MovSaldo1.Pratica__c = Prat.Id;
        MovSaldo1.Account__c = Acc.Id;
        MovSaldo1.Servizio_Fornitura__c = Serv.Id;
        MovSaldo1.Data_Scadenza__c = Date.newInstance(2015, 03, 03);
        MovSaldo1.Data_Emissione__c = Date.newInstance(2013, 03, 03);
        MovSaldo1.Servizio_Item__c = Fruit.Id;  
        MovSaldo1.Residuo__c = 20.20;
        insert MovSaldo1;
       
       
       Piano_di_Rientro__c PdR = new Piano_di_Rientro__c();
       PdR.Pratica__c = Prat.Id;
       PdR.Importo_Totale__c = 20.90;
       PdR.Stato__c = 'Attivo';
       insert PdR;
       
       Document_Type__c DT = new Document_Type__c();
       DT.Document_Code__c = '013';
       dt.Name = 'Seconda Lettera Ordinaria (30-100)';
       dt.NameField__c = 'Seconda_Lettera_Ordinaria_30_100__c';
       insert DT;
       
       Id idPratica = ApexPages.currentPage().getParameters().put('Id', Prat.Id);
       String DocumType = ApexPages.currentPage().getParameters().put('Type', '013');
       
       ApexPages.StandardController StdContr = new ApexPages.StandardController(Prat);
       StampaPDF ctrl = new StampaPDF(StdContr);
    }
}