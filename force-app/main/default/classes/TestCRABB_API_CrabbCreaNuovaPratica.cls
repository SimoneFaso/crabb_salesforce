/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestCRABB_API_CrabbCreaNuovaPratica.cls
Description:     Test Class for code coverage of CRABB_API_CrabbCreaNuovaPratica.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
02-Apr-2020  0.1      M. Sala                         First Version
08-Sep-2021  0.2      C. Sanna                        Replaced Record Type Names with Developer Names
----------------------------------------------------------------------------------------------------------------------*/

@IsTest
private class TestCRABB_API_CrabbCreaNuovaPratica {

    @TestSetup
    public static void initData() {
        Account a = TestClassForDatagenerationCreateData.getTestAccount();
        a.Codice_Cliente_CRABB__c = '213456';
        insert a;
    }

    @IsTest
    static void testSetPayloadField() {
        List<ServicePaymentsMappingField__mdt> lMappingFields = [
                SELECT ObjectType__c,ObjectField__c,PayloadField__c
                FROM ServicePaymentsMappingField__mdt
                WHERE isTest__c = TRUE
        ];
        Map<String, Map<String, String>> mMappingObjects = new Map<String, Map<String, String>>();
        for (ServicePaymentsMappingField__mdt mapping : lMappingFields) {
            Map<String, String> mMappingFields = new Map<String, String>();
            mMappingFields.put(mapping.PayloadField__c, mapping.ObjectField__c);
            mMappingObjects.put(mapping.ObjectType__c, mMappingFields);
        }
        Account a = new Account();
        List<CRABB_API_Class.CrabbPayload> crabbPayload = new List<CRABB_API_Class.CrabbPayload>();
        CRABB_API_Class.CrabbPayload cp = new CRABB_API_Class.CrabbPayload() ;
        cp.Value = 'Test account';
        cp.Field = 'name';
        crabbPayload.add(cp);
        a = (Account) CRABB_API_Class.setPayloadField('Account', mMappingObjects, crabbPayload, a);
    }

    @IsTest
    static void testAPI_KO() {
        Account a = [SELECT Id, Id_Esterno__c, Codice_Cliente_CRABB__c FROM Account LIMIT 1];
        CRABB_API_Class.CrabbCreaNuovaPraticaInput pi = new CRABB_API_Class.CrabbCreaNuovaPraticaInput();

        //Check error
        pi.AccountExternalKey = '';
        CRABB_API_Class.CrabbCreaNuovaPraticaOutput stas = CRABB_API_CrabbCreaNuovaPratica.doPost(pi);
        System.assertEquals('KO', stas.Esito);

        pi.AccountExternalKey = null;
        pi.IdAccountSFDC = 'xxx';
        stas = CRABB_API_CrabbCreaNuovaPratica.doPost(pi);
        System.assertEquals('KO', stas.Esito);

        pi.IdAccountSFDC = null;
        pi.AccountExternalKey = a.Codice_Cliente_CRABB__c;
        stas = CRABB_API_CrabbCreaNuovaPratica.doPost(pi);
        System.assertEquals('KO', stas.Esito);

        //check controllo record type isavailable by profile
        pi.Serv = new CRABB_API_Class.CrabbServizio();
        pi.Serv.RecordType = 'CCCCC';
        stas = CRABB_API_CrabbCreaNuovaPratica.doPost(pi);
        System.assertEquals('KO', stas.Esito);

        //check duplicate account
        Account a2 = TestClassForDatagenerationCreateData.getTestAccount();
        a2.Codice_Cliente_CRABB__c = '213456';
        insert a2;
        stas = CRABB_API_CrabbCreaNuovaPratica.doPost(pi);
        System.assertEquals('KO', stas.Esito);
    }

    @IsTest
    static void testAPI_OK() {
        Account a = [SELECT Id, Id_Esterno__c, Codice_Cliente_CRABB__c FROM Account LIMIT 1];
        CRABB_API_Class.CrabbCreaNuovaPraticaInput pi = new CRABB_API_Class.CrabbCreaNuovaPraticaInput();
        CRABB_API_Class.CrabbCreaNuovaPraticaOutput po = new CRABB_API_Class.CrabbCreaNuovaPraticaOutput();
        pi.AccountExternalKey = a.Codice_Cliente_CRABB__c;

        pi.Serv = new CRABB_API_Class.CrabbServizio();
        pi.Serv.RecordType = 'POSTCE';
        pi.Serv.ServExternalKey = '123123123';
        pi.lMov = new List<CRABB_API_Class.CrabbMovimento>();
        CRABB_API_Class.CrabbMovimento mov = new CRABB_API_Class.CrabbMovimento();
        mov.MovExternalKey = '123123123';
        mov.RecordType = 'ADDEBITO';
        mov.DataEmissione = Date.today();
        mov.Sollecitabile = false;
        mov.DataScadenza = Date.today();
        pi.lMov.add(mov);
        po = CRABB_API_CrabbCreaNuovaPratica.doPost(pi);
        System.assertEquals('OK', po.Esito);
    }
}