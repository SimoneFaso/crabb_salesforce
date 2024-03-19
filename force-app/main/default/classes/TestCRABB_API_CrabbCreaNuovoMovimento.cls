/**
 * Created by Matteo on 09/04/2020.
 */
@isTest
public with sharing class TestCRABB_API_CrabbCreaNuovoMovimento {


    @TestSetup
    public static void initData(){
        Account a = TestClassForDatagenerationCreateData.getTestAccount();
        a.Codice_Cliente_CRABB__c='213456';
        insert a;

        Servizio__c s = TestClassForDatagenerationCreateData.getTestService();
        s.Account__c = a.Id;
        s.Id_Esterno__c='s1';
        insert s;

        Pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
        p.Account__c = a.Id ;
        p.Servizio_Fornitura__c = s.Id;
        insert p;

        Movimento__c m = TestClassForDatagenerationCreateData.getTestMovimento();
        m.Account__c = a.Id;
        m.Pratica__c = p.Id;
        m.IdentificativoFatturaExt__c = 'm1';
        m.Servizio_Fornitura__c = s.Id;
        insert m;
    }

    @IsTest
    static void testAPI() {
        Account a  = [select id , Id_Esterno__c , Codice_Cliente_CRABB__c  from Account limit 1];
        CRABB_API_Class.CrabbCreaMovimentoInput mi = new CRABB_API_Class.CrabbCreaMovimentoInput();
        //Check error
        mi.AccountExternalKey='';
        CRABB_API_Class.CrabbCreaMovimentoOutput out =  CRABB_API_CreaMovimento.doPost(mi);
        System.assertEquals('KO' , out.Esito);

        mi.AccountExternalKey = '213456';
        mi.IdPratSFDC='123456789012345678';
        mi.mov = new CRABB_API_Class.CrabbMovimento();
        out =  CRABB_API_CreaMovimento.doPost(mi);
        System.debug('Response: '+out);
        System.assertEquals('KO' , out.Esito);

        mi.IdPratSFDC= null ;
        mi.ServExternalKey = 's1';
        mi.mov = new CRABB_API_Class.CrabbMovimento();
        mi.mov.MovExternalKey = 'm1';
        mi.mov.RecordType = 'ADDEBITO';
        mi.mov.DataEmissione = Date.today();
        mi.mov.Sollecitabile = false;
        mi.mov.DataScadenza = Date.today();
        out =  CRABB_API_CreaMovimento.doPost(mi);
        System.debug('Response: '+out);
        System.assertEquals('OK' , out.Esito);
    }
}