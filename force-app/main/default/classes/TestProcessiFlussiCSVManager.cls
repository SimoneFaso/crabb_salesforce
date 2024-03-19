/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestProcessiFlussiCSVManager.cls
Description:     Class for code coverage of ProcessiFlussiCSVManager.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
13-Oct-2014  0.1      E. Sino                          First Version
22-Sep-2021  0.2      C. Sanna                         Replaced getRecordTypeInfosByName() with
                                                       getRecordTypeInfosByDeveloperName() (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

@isTest
public class TestProcessiFlussiCSVManager

{
    static testmethod void testAggiornamentoAffidamento()
    {
        // 1. Crea lotto
        test.startTest();
        
        User u = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');
        
        Collector__c col = TestClassFroDataGenAffidamenti.getCollector(u.Id);
        insert col;

        ProcessiFlussiCSVManager.AggiornamentoAffidamento(col.id);
        
        test.stopTest();
    }
    
    static testmethod void testNuovoLottoAffidamento()
    {
        test.startTest();

        Tag__c tg = new Tag__c();
        tg.Name = 'AreFlowDebugInfoTurnedOn';
        tg.ValueBoolean__c = true;
        insert tg;

        // crea collector
        User u = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');
        
        Collector__c col = TestClassFroDataGenAffidamenti.getCollector(u.Id);
        insert col;
        
        Lotto__c lot = TestClassFroDataGenAffidamenti.getLotto(Col.Id);
        insert lot;
        
        // crea pratica
        Contratto__c cont = new Contratto__C();
        cont = TestClassFroDataGenAffidamenti.getContratto();
        Database.insert(cont,false);
        
        Account ac = new Account();
        ac = TestClassFroDataGenAffidamenti.getAccount(cont.id);
        insert ac;
        
        Pratica__c p = new Pratica__c();
        p = TestClassFroDataGenAffidamenti.getPratica(ac.id);
        insert p;

        /* MSala 20170418 - INIZIO*/
        Servizio__c s = new Servizio__c();
        s.Account__c = ac.id;
        insert s;

        p.Servizio_Fornitura__c = s.id;
        update p;
        
        Servizi_Item__c f = new Servizi_Item__c();
        f.Servizio__c = s.id;
                
        insert f;

        //Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Movimento__c.getRecordTypeInfosByName();
        Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Movimento__c.getRecordTypeInfosByDeveloperName();

        List<Movimento__c> movFatt = new List<Movimento__c>();
        movFatt.add(new Movimento__c(recordtypeId= ctRecordTypes.get('Fatture').getRecordTypeId(), Account__c = ac.id, Pratica__c = p.id, Data_Emissione__c = System.today(), data_scadenza__c = system.today(),Id_Movimento_Ext__c = 'TEST001',IdentificativoFatturaExt__c='TEST001'));
        movFatt.add(new Movimento__c(recordtypeId= ctRecordTypes.get('Fatture').getRecordTypeID(), Account__c = ac.id, Pratica__c = p.id, Data_Emissione__c = System.today(), data_scadenza__c = system.today(),Id_Movimento_Ext__c = 'TEST002',IdentificativoFatturaExt__c='TEST002'));
                        
        insert movFatt;

        /* MSala 20170418 - FINE*/

        ProcessiFlussiCSVManager.AggiornamentoMovimenti(col.id);

        Affidamento__c aff = TestClassFroDataGenAffidamenti.getAffido('In corso', System.today(), lot.id, p.id);
        aff.Pratica__c = p.Id;

        insert aff;/*
        System.assertEquals(null, lot.id);*/
        System.assertNotEquals(null, aff.id);

        ProcessiFlussiCSVManager.NuovoLottoAffidamento(lot.id);

        Affidamento__c aff2 = TestClassFroDataGenAffidamenti.getAffido('Scaduto', System.today(), lot.id, p.id);
        insert aff2;
        ProcessiFlussiCSVManager.AggiornamentoAffidamento(col.id);

        ProcessiFlussiCSVManager.AggiornamentoMovimenti(col.id);
        ProcessiFlussiCSVManager.AggiornamentoAnagrafico(col.id);

        List<ListOfFields__c> lLOF = new List<ListOfFields__c>();
        ListOfFields__c lof = new ListOfFields__c(name='CSVNEW000000',Field__c = 'Name',Object__c = 'CSV||Account',Show__c = true);
        lLOF.add(lof);
        lof = new ListOfFields__c(name='CSVNEW000001',Field__c = 'Name',Object__c = 'CSV||Pratica__c',Show__c = true);
        lLOF.add(lof);
        lof = new ListOfFields__c(name='CSVNEW000002',Field__c = 'Name',Object__c = 'CSV||Movimento__c',Show__c = true);
        lLOF.add(lof);
        lof = new ListOfFields__c(name='CSVUPD000000',Field__c = 'Name',Object__c = 'CSV||Account',Show__c = true);
        lLOF.add(lof);
        lof = new ListOfFields__c(name='CSVUPD000001',Field__c = 'Name',Object__c = 'CSV||Movimento__c',Show__c = true);
        lLOF.add(lof);
        lof = new ListOfFields__c(name='CSVDEL000000',Field__c = 'Name',Object__c = 'CSV||Account',Show__c = true);
        lLOF.add(lof);
        insert lLOF;

        ProcessiFlussiCSVManager.CreaCSV_per_Affidamento(lot.id,'CSVNEW');
        ProcessiFlussiCSVManager.CreaCSV_per_Affidamento(lot.id,'CSVUPD');
        ProcessiFlussiCSVManager.CreaCSV_per_Affidamento(lot.id,'CSVDEL');
        
        test.stoptest();
        
    }
}