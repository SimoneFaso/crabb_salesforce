/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestPraticalHandler.cls
Description:

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                       First Version
01-Oct-2021  0.2      M. Pizzichini, C. Sanna          Modified for coverage, added testUscConChiusura and modified
                                                       testlookforchangesinstato methods.

----------------------------------------------------------------------------------------------------------------------*/
@IsTest
public class TestPracticalHandler {//Ork Funzioni per gestire pratika

    static testMethod void PHandlerCallMetod() {

        List<SObject> soListNew = new List <SObject> ();
        LIST<SObject> soList = new List <SObject> ();
        LIST<SObject> oldSo = new List <SObject> ();
        List<SObject> so = new List <SObject> ();
        Map<String, Integer> mPrat = new Map<String, Integer> ();

        PraticaHandler ph = new PraticaHandler();
        ph.bulkBefore();
        ph.bulkAfter();
        ph.bulkBefore(soListNew);
        ph.bulkAfter(soListNew);
        ph.beforeInsert(soList);
        ph.beforeDelete(soList);
        ph.afterDelete(soList);
        ph.afterInsert(soList);
        ph.beforeDelete(so);
        ph.afterInsert(soList);
        ph.beforeUpdate(soList, so);
        ph.afterUpdate(oldSo, so);
        ph.UpdSollecitabile(mPrat);
        ph.andFinally();

    }

    // E.S. Metodo di test per elaborazione postchiusura    
    static testMethod void PHandlerTestMetodo() {
        // crea una praticha e handler
        Account a = testClassForDataGenerationCreateData.getTestAccount();
        insert a;

        Pratica__c p = testClassForDataGenerationCreateData.getTestPratica();
        p.account__c = a.id;
        insert p;

        Movimento__c m = testClassForDataGenerationCreateData.getTestMovimento();
        Date tmp = system.today();
        tmp.addDays(5);
        m.pratica__c = p.id;
        m.account__c = a.id;
        m.Data_Scadenza__c = tmp;
        insert m;

        // update la pratica
        p.service__c = 'UscitaConChiusura';
        test.startTest();
        TaskHandler.internalUpdate = true;
        update p;
        test.StopTest();
    }

    // Test BeforeUpdate()-CreaStorico
    static testmethod void testCreaStorico() {
        // crea una praticha e handler
        Account a = testClassForDataGenerationCreateData.getTestAccount();
        insert a;

        Pratica__c p = testClassForDataGenerationCreateData.getTestPratica();
        p.account__c = a.id;
        insert p;

        // update la pratica
        p.service__c = 'CreaStorico';
        test.startTest();
        update p;
        test.StopTest();
    }

    // Test BeforeUpdate()-uscitaSenzachiusura
    static testmethod void testUscSenzaChiu() {
        // crea una praticha e handler
        Account a = testClassForDataGenerationCreateData.getTestAccount();
        insert a;

        Pratica__c p = testClassForDataGenerationCreateData.getTestPratica();
        p.account__c = a.id;
        insert p;

        // update la pratica
        p.service__c = 'UscitaSenzaChiusura';
        test.startTest();
        update p;
        test.StopTest();
    }

    // Test BeforeUpdate()-uscitaConchiusura
    static testmethod void testUscConChiusura() {
        // crea una pratica e handler
        Account a = testClassForDataGenerationCreateData.getTestAccount();
        insert a;

        Pratica__c p = testClassForDataGenerationCreateData.getTestPratica();
        p.account__c = a.id;
        insert p;

        Strategia__c s = testClassForDataGenerationCreateData.getTestStrategiaTestata();
        s.recordtypeId = testClassForDataGenerationCreateData.getRTStrategiaId('Storico');
        s.Pratica_di_riferimento__c = p.id;
        insert s;

        //update service__c to test uscitaConChiusura with storico_in_corso__c != null;
        p.service__c = 'UscitaConChiusura';
        p.Storico_in_corso__c = s.id;
        test.startTest();
        update p;

        test.StopTest();
    }

    static testmethod void testsetToOldMovimentiForClosedPratica() {

    }

    static testmethod void testUpdateStorico() {
        // crea una praticha e handler
        Account a = testClassForDataGenerationCreateData.getTestAccount();
        insert a;

        Pratica__c p = testClassForDataGenerationCreateData.getTestPratica();
        p.account__c = a.id;
        insert p;

        Map<string, Schema.RecordTypeInfo> RTMovNameID =Schema.SObjectType.Movimento__c.getrecordtypeinfosbydevelopername();
        Movimento__c mov = new Movimento__c();
        mov.RecordTypeId = RTMovNameID.get('SALDO_MESE').getRecordTypeID();
        mov.Pratica__c = p.id;
        mov.Account__c = a.id;
        mov.Data_Emissione__c = System.today();
        mov.Data_Scadenza__c = System.today();
        mov.Sollecitabile__c = false;
        mov.Residuo__c = 1000;
        mov.Importo__c = 1000;
        insert mov;

        mov.Sollecitabile__c = true;
        mov.Data_Scadenza__c = System.today().addDays(5);
        mov.Tipo_Scadenza__c = 'In scadenza';
        update mov;

        // crea una strategia
        Strategia__c s = testClassForDataGenerationCreateData.getTestStrategiaTestata();
        s.recordtypeId = testClassForDataGenerationCreateData.getRTStrategiaId('Storico');
        s.Pratica_di_riferimento__c = p.id;
        insert s;

        // update la pratica
        p.service__c = 'updateStorico';
        p.storico_in_corso__c = s.id;
        test.startTest();
        update p;

        //update service__c to test uscitaConChiusura with storico_in_corso__c = null;
        p.service__c = 'UscitaConChiusura';
        TaskHandler.internalUpdate = true;
        p.storico_in_corso__c = null;
        update p;
        test.StopTest();
    }

    static testmethod void testUpdateSollecitabile1() {
        // crea una praticha e handler
        Account a = testClassForDataGenerationCreateData.getTestAccount();
        insert a;
        Pratica__c p = testClassForDataGenerationCreateData.getTestPratica();
        p.account__c = a.id;
        insert p;
/*        Id idmov = TestStatic.getMovimentoRTId('SALDO MESE');
        List<Movimento__c> movimenti = testClassForDataGenerationCreateData.getTestMovimento(1);
        for (Movimento__c tmp : movimenti) {
            tmp.recordtypeId = idmov;
            tmp.Pratica__c = p.id;
            tmp.Account__c = a.id;
            tmp.Sollecitabile__c = false;
            tmp.Data_Scadenza__c = System.today();
        }
        insert movimenti;*/
        Map<String, Integer> mPrat = new Map<String, Integer> ();
        String dateformula = String.valueOf(System.today().year()) + String.valueOf(System.today().month() + 1);
        mPrat.put(p.Id, Integer.valueOf(dateformula));
        PraticaHandler ph = new PraticaHandler();
        ph.UpdSollecitabile(mPrat);


    }

    static testmethod void testUpdateSollecitabile2() {
        // crea una praticha e handler
        Account a = testClassForDataGenerationCreateData.getTestAccount();
        insert a;
        Pratica__c p = testClassForDataGenerationCreateData.getTestPratica();
        p.account__c = a.id;
        insert p;
        Id idmov = TestStatic.getMovimentoRTId('SALDO MESE');
        List<Movimento__c> movimenti = testClassForDataGenerationCreateData.getTestMovimento(1);
        for (Movimento__c tmp : movimenti) {
            tmp.recordtypeId = idmov;
            tmp.Pratica__c = p.id;
            tmp.Account__c = a.id;
            tmp.Sollecitabile__c = true;
            tmp.Data_Scadenza__c = System.today() - 1;
        }
        insert movimenti;
        Map<String, Integer> mPrat = new Map<String, Integer> ();
        String dateformula = String.valueOf(System.today().year()) + String.valueOf(System.today().month() + 1);
        mPrat.put(p.Id, Integer.valueOf(dateformula));
        PraticaHandler ph = new PraticaHandler();
        ph.UpdSollecitabile(mPrat);


    }

    static testmethod void testlookforchangesinstato() {
        Tag__c tag = new Tag__c();
        tag.ValueText__c = 'Bloccata Manualmente';
        tag.Name = 'ValoreStatoPraticaPerBloccoManuale';
        Tag__c tag2 = new Tag__c();
        tag2.ValueText__c = 'Bloccata';
        tag2.Name = 'StatoPraticaBloccoPDR';
        insert tag;
        insert tag2;


        Account acc = testClassForDataGenerationCreateData.getTestAccount();
        insert acc;

        Pratica__c prt = testClassForDataGenerationCreateData.getTestPratica();
        prt.Account__c = acc.Id;
        prt.Stato__c = 'Bozza';
        insert prt;

        prt.Stato__c = 'In Lavorazione';
        update prt;

        Task tsk = new task();
        tsk.Subject ='test';
        tsk.WhatId = prt.id;
        tsk.Type = 'Credito';
        insert tsk;

        Case cas = new case();
        cas.Origin ='Phone';
        cas.Status = 'New';
        cas.AccountId = acc.Id;
        cas.Blocking_SR__c = true;
        insert cas;
        update cas;


        prt.Stato__c = 'Bloccata';
        tsk.Status = 'Bloccata';
        update prt;
        update tsk;
        prt.Stato__c = 'In Lavorazione';
        update prt;




    }
    static testmethod void testDaLavorareInLavorazione() {

    }

    /* -----------------------------------------------------------------------------------------------------------------
    Author: Giulia Mameli
    Description: Test Class for code coverage of closeMappingCases method in PraticaHandler.cls
    Inputs:  NA
    Returns: NA

    30-Apr-2021  0.1      Giulia Mameli                         First Version
    ----------------------------------------------------------------------------------------------------------------- */

    static testMethod void closeMappingCasesTest() {

        Account acc = testClassForDataGenerationCreateData.getTestAccount();
        insert acc;

        Pratica__c prt = testClassForDataGenerationCreateData.getTestPratica();
        prt.Account__c = acc.Id;
        prt.Stato__c = 'Bozza';
        insert prt;

        Case cs = new Case(Pratica__c = prt.Id, AccountId = acc.Id, Status = 'New');
        insert cs;

        prt.Stato__c = 'Chiusa';
        update prt;

        List<Case> casesList = [SELECT Id, Status FROM Case WHERE Id =: cs.Id];
        System.assertEquals(casesList[0].Status,'Closed');
    }

}