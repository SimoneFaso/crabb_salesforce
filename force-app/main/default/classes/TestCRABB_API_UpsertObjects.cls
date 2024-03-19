/**
 * Created by ssalaris on 16/12/2020.
 */

@IsTest
private class TestCRABB_API_UpsertObjects {

  @IsTest
    static void testAPI_UpsertObjects() {

        //data generation for test
        Account a = new Account(Codice_Cliente_CRABB__c = 'TestAcc', Name = 'AccName2');
        Account a2 = new Account(Codice_Cliente_CRABB__c = 'TestAcc', Name = 'AccName2');
        Account a3 = new Account(Codice_Cliente_CRABB__c = 'TestAcc3', Name = 'AccName3');
        insert a;
        insert a2;
        insert a3;

        Servizio__c serv = new Servizio__c(CRABB_DEV__Account__c = a.Id, CRABB_DEV__Id_Esterno__c = 'TestServ');
        Servizio__c serv2 = new Servizio__c(CRABB_DEV__Account__c = a2.Id, CRABB_DEV__Id_Esterno__c = 'TestServ2');
        insert serv;
        insert serv2;

        Pratica__c pra = new Pratica__c(CRABB_DEV__Stato__c = 'In Lavorazione', CRABB_DEV__Account__c = a.Id, CRABB_DEV__Servizio_Fornitura__c = serv.Id );
        insert pra;

        Movimento__c mov = new Movimento__c(CRABB_DEV__Account__c = a.Id, CRABB_DEV__Servizio_Fornitura__c = serv.Id, CRABB_DEV__Pratica__c = pra.Id, CRABB_DEV__Id_Movimento_Ext__c = 'TestMov', CRABB_DEV__Data_Emissione__c = System.today(), CRABB_DEV__Data_Scadenza__c = System.today());
        Movimento__c mov2 = new Movimento__c(CRABB_DEV__Account__c = a2.Id, CRABB_DEV__Servizio_Fornitura__c = serv2.Id, CRABB_DEV__Pratica__c = pra.Id, CRABB_DEV__Id_Movimento_Ext__c = 'TestMov2', CRABB_DEV__Data_Emissione__c = System.today(), CRABB_DEV__Data_Scadenza__c = System.today());
        insert mov;
        insert mov2;

        //input list and output list creation
        List<CRABB_API_Class.CrabbInput> piList = new List<CRABB_API_Class.CrabbInput>();
        List<CRABB_API_Class.CrabbOutput> outList = new List<CRABB_API_Class.CrabbOutput>();

        //test input request with Account SFDC Id
        CRABB_API_Class.CrabbInput pi = new CRABB_API_Class.CrabbInput();
        CRABB_API_Class.CrabbServizio servizio = new CRABB_API_Class.CrabbServizio();
        CRABB_API_Class.CrabbMovimento m = new CRABB_API_Class.CrabbMovimento();
        List<CRABB_API_Class.CrabbMovimento> mList = new List<CRABB_API_Class.CrabbMovimento>();
        pi.IdAccountSFDC = a.Id;
        servizio.IdServSFDC = serv.Id;
        servizio.RecordType = 'PENALE';
        servizio.UpdServizio = true;
        pi.Serv = servizio;
        m.IdMovSFDC = mov.Id;
        m.RecordType = 'INCASSO';
        m.UpdMovimento = true;
        mList.add(m);
        pi.lMov = mList;
        piList.add(pi);


        //test input request with External Id and no SFDC Id
        CRABB_API_Class.CrabbInput pi2 = new CRABB_API_Class.CrabbInput();
        CRABB_API_Class.CrabbServizio servizio2 = new CRABB_API_Class.CrabbServizio();
        CRABB_API_Class.CrabbMovimento m2 = new CRABB_API_Class.CrabbMovimento();
        List<CRABB_API_Class.CrabbMovimento> mList2 = new List<CRABB_API_Class.CrabbMovimento>();
        pi2.AccountExternalKey = a2.Codice_Cliente_CRABB__c;
        pi2.Serv = servizio2;
        m2.MovExternalKey = mov.CRABB_DEV__Id_Movimento_Ext__c;
        m2.UpdMovimento = false;
        mList2.add(m2);
        pi2.lMov = mList2;
        piList.add(pi2);


        //test input request without any Account Id nor extId
        CRABB_API_Class.CrabbInput pi3 = new CRABB_API_Class.CrabbInput();
        piList.add(pi3);

        //test input request with wrong Account Id
        CRABB_API_Class.CrabbInput pi4 = new CRABB_API_Class.CrabbInput();
        pi4.IdAccountSFDC = '888';
        piList.add(pi4);

        //test input request with wrong Account External Id
        CRABB_API_Class.CrabbInput pi5 = new CRABB_API_Class.CrabbInput();
        pi5.AccountExternalKey = '999';
        piList.add(pi5);

        //test input request with external Id associated to more than one account
        CRABB_API_Class.CrabbInput pi6 = new CRABB_API_Class.CrabbInput();
        pi6.AccountExternalKey = a3.Codice_Cliente_CRABB__c;
        piList.add(pi6);

        //test input request with Service external Id and no SFDC Id
        CRABB_API_Class.CrabbInput pi7 = new CRABB_API_Class.CrabbInput();
        CRABB_API_Class.CrabbServizio servizio3 = new CRABB_API_Class.CrabbServizio();
        CRABB_API_Class.CrabbMovimento m3 = new CRABB_API_Class.CrabbMovimento();
        List<CRABB_API_Class.CrabbMovimento> mList3 = new List<CRABB_API_Class.CrabbMovimento>();
        pi7.IdAccountSFDC = a2.Id;
        servizio3.ServExternalKey = serv2.CRABB_DEV__Id_Esterno__c;
        servizio3.RecordType = 'PENALE';
        servizio3.UpdServizio = true;
        pi7.Serv = servizio3;
        m3.MovExternalKey = mov2.CRABB_DEV__Id_Movimento_Ext__c;
        m3.UpdMovimento = true;
        m3.RecordType = 'INCASSO';
        mList3.add(m3);
        pi7.lMov = mList3;
        piList.add(pi7);

        //test input request with CrabbServizio = null
        CRABB_API_Class.CrabbInput pi8 = new CRABB_API_Class.CrabbInput();
        pi8.IdAccountSFDC = a3.Id;
        pi8.Serv = null;
        piList.add(pi8);

        //test input request without Service RecordType
        CRABB_API_Class.CrabbInput pi9 = new CRABB_API_Class.CrabbInput();
        CRABB_API_Class.CrabbServizio servizio4 = new CRABB_API_Class.CrabbServizio();
        CRABB_API_Class.CrabbMovimento m4 = new CRABB_API_Class.CrabbMovimento();
        List<CRABB_API_Class.CrabbMovimento> mlist4 = new List<CRABB_API_Class.CrabbMovimento>();
        pi9.IdAccountSFDC = a.Id;
        pi9.Serv = servizio4;
        m4.IdMovSFDC = mov.Id;
        m4.UpdMovimento = true;
        m4.RecordType = 'INCASSO';
        mlist4.add(m4);
        pi9.lMov = mlist4;
        piList.add(pi9);

      
        Test.startTest();
            outList = CRABB_API_UpsertObjects.doPost(piList);
        Test.stopTest();

    }
}