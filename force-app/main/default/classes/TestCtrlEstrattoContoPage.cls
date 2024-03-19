/* -----------------------------------------------------------------------------------------------------------
Name:            TestCtrlEstrattoContoPage.cls
Description:     Test class for code coverage of CtrlEstrattoContoPage.cls

Date         Version  Author             Summary of Changes
-----------  -------  -----------------  -----------------------------------------------------------------
             0.1      Balance            First Version
11-Mar-2021  0.2      Giulia Mameli      Added previewMethodTest()
---------------------------------------------------------------------------------------------------------- */

@IsTest
private class TestCtrlEstrattoContoPage {

    @TestSetup static void setup() {
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;

        acc = [SELECT Id FROM Account LIMIT 1];

        Pratica__c prat = new Pratica__c ();
        prat.Account__c = acc.Id;
        insert prat;

        prat = [SELECT Id, Account_Codice_Cliente__c FROM Pratica__c LIMIT 1];

        Movimento__c mov = new Movimento__c();
        mov.Pratica__c = prat.Id;
        mov.Account__c = acc.Id;
        mov.Data_Emissione__c = Date.today();
        mov.Data_Scadenza__c = Date.today();
        insert mov;

    }

    @IsTest static void test_with_CS() {
        Test.startTest();

        ListOfFields__c fep = new ListOfFields__c();
        fep.Name = 'Pdf_1';
        fep.Field__c = 'Name';
        fep.Object__c = 'Pratica__c';
        fep.Show__c = true;
        insert fep;

        fep = new ListOfFields__c();
        fep.Name = 'Pdf_2';
        fep.Field__c = 'Account_Codice_Cliente__c';
        fep.Object__c = 'Pratica__c';
        fep.Show__c = true;
        insert fep;

        fep = new ListOfFields__c();
        fep.Name = 'Pdf_3';
        fep.Field__c = 'Servizio_Fornitura__c';
        fep.Object__c = 'Pratica__c';
        fep.Show__c = true;
        insert fep;

        fep = new ListOfFields__c();
        fep.Name = 'Pdf_4';
        fep.Field__c = 'Data_Emissione__c';
        fep.Object__c = 'Movimento__c';
        fep.Show__c = true;
        insert fep;

        fep = new ListOfFields__c();
        fep.Name = 'Pdf_5';
        fep.Field__c = 'Data_Scadenza__c';
        fep.Field_Label__c = 'Data Scadenza';
        fep.Object__c = 'Movimento__c';
        fep.Show__c = true;
        insert fep;

        Pratica__c p = [SELECT Id,Account_Codice_Cliente__c FROM Pratica__c LIMIT 1];

        PageReference pag = Page.EstrattoContoPage;
        pag.getParameters().put('id', p.Id);
        Test.setCurrentPage(pag);
        ApexPages.StandardController sc = new ApexPages.StandardController(p);
        CtrlEstrattoContoPage ctrl = new CtrlEstrattoContoPage(sc);

        PageReference pagAcc = Page.EstrattoContoAccountPage;
        pagAcc.getParameters().put('id', p.Id);
        Test.setCurrentPage(pagAcc);
        ApexPages.StandardController scAcc = new ApexPages.StandardController(p);
        CtrlEstrattoContoPage ctrlACc = new CtrlEstrattoContoPage(scAcc);

        Test.stopTest();
    }

    @IsTest static void test_without_CS() {
        Test.startTest();

        ListOfFields__c fep = new ListOfFields__c();
        fep.Name = 'Pdf_4';
        fep.Field__c = 'Data_Emissione__c';
        fep.Object__c = 'Movimento__c';
        fep.Show__c = true;
        insert fep;

        fep = new ListOfFields__c();
        fep.Name = 'Pdf_5';
        fep.Field__c = 'Data_Scadenza__c';
        fep.Field_Label__c = 'Data Scadenza';
        fep.Object__c = 'Movimento__c';
        fep.Show__c = true;
        insert fep;

        Pratica__c p = [SELECT Id,Account_Codice_Cliente__c FROM Pratica__c LIMIT 1];

        PageReference pag = Page.EstrattoContoPage;
        pag.getParameters().put('id', p.Id);
        Test.setCurrentPage(pag);
        ApexPages.StandardController sc = new ApexPages.StandardController(p);
        CtrlEstrattoContoPage ctrl = new CtrlEstrattoContoPage(sc);

        PageReference pagAcc = Page.EstrattoContoAccountPage;
        pagAcc.getParameters().put('id', p.Id);
        Test.setCurrentPage(pagAcc);
        ApexPages.StandardController scAcc = new ApexPages.StandardController(p);
        CtrlEstrattoContoPage ctrlACc = new CtrlEstrattoContoPage(scAcc);

        Test.stopTest();
    }

    @IsTest static void test_with_partial_CS() {
        Test.startTest();

        ListOfFields__c fep = new ListOfFields__c();
        fep.Name = 'Pdf_2';
        fep.Field__c = 'Saldo_Spese__c';
        fep.Object__c = 'Pratica__c';
        fep.Show__c = true;
        insert fep;

        fep = new ListOfFields__c();
        fep.Name = 'Pdf_4';
        fep.Field__c = 'Data_Emissione__c';
        fep.Object__c = 'Movimento__c';
        fep.Show__c = true;
        insert fep;

        fep = new ListOfFields__c();
        fep.Name = 'Pdf_5';
        fep.Field__c = 'Data_Scadenza__c';
        fep.Field_Label__c = 'Data Scadenza';
        fep.Object__c = 'Movimento__c';
        fep.Show__c = true;
        insert fep;

        Pratica__c p = [SELECT Id,Account_Codice_Cliente__c FROM Pratica__c LIMIT 1];

        PageReference pag = Page.EstrattoContoPage;
        pag.getParameters().put('id', p.Id);
        Test.setCurrentPage(pag);
        ApexPages.StandardController sc = new ApexPages.StandardController(p);
        CtrlEstrattoContoPage ctrl = new CtrlEstrattoContoPage(sc);

        PageReference pagAcc = Page.EstrattoContoAccountPage;
        pagAcc.getParameters().put('id', p.Id);
        Test.setCurrentPage(pagAcc);
        ApexPages.StandardController scAcc = new ApexPages.StandardController(p);
        CtrlEstrattoContoPage ctrlACc = new CtrlEstrattoContoPage(scAcc);

        Test.stopTest();
    }

    @IsTest static void test_without_CS_Movimento() {
        Test.startTest();

        Pratica__c p = [SELECT Id,Account_Codice_Cliente__c FROM Pratica__c LIMIT 1];

        PageReference pag = Page.EstrattoContoPage;
        pag.getParameters().put('id', p.Id);
        Test.setCurrentPage(pag);
        ApexPages.StandardController sc = new ApexPages.StandardController(p);
        CtrlEstrattoContoPage ctrl = new CtrlEstrattoContoPage(sc);

        PageReference pagAcc = Page.EstrattoContoAccountPage;
        pagAcc.getParameters().put('id', p.Id);
        Test.setCurrentPage(pagAcc);
        ApexPages.StandardController scAcc = new ApexPages.StandardController(p);
        CtrlEstrattoContoPage ctrlACc = new CtrlEstrattoContoPage(scAcc);

        Boolean res = ctrl.getShowLogo();

        Test.stopTest();
    }

    /* --------------------------------------------------------------------------------------
    Author: Giulia Mameli
    Company: Balance
    Description: This method is used to test previewMethod().
    Inputs:  NA
    Returns: NA

    11-Mar-2021     0.1     G.Mameli        First Version
    ------------------------------------------------------------------------------------------- */

    @IsTest static void previewMethodTest() {

        Test.startTest();

        ListOfFields__c fep = new ListOfFields__c();
        fep.Name = 'Pdf_1';
        fep.Field__c = 'Name';
        fep.Object__c = 'Pratica__c';
        fep.Show__c = true;
        insert fep;

        fep = new ListOfFields__c();
        fep.Name = 'Pdf_2';
        fep.Field__c = 'Account_Codice_Cliente__c';
        fep.Object__c = 'Pratica__c';
        fep.Show__c = true;
        insert fep;

        fep = new ListOfFields__c();
        fep.Name = 'Pdf_3';
        fep.Field__c = 'Servizio_Fornitura__c';
        fep.Object__c = 'Pratica__c';
        fep.Show__c = true;
        insert fep;

        fep = new ListOfFields__c();
        fep.Name = 'Pdf_4';
        fep.Field__c = 'Data_Emissione__c';
        fep.Object__c = 'Movimento__c';
        fep.Show__c = true;
        insert fep;

        fep = new ListOfFields__c();
        fep.Name = 'Pdf_5';
        fep.Field__c = 'Data_Scadenza__c';
        fep.Field_Label__c = 'Data Scadenza';
        fep.Object__c = 'Movimento__c';
        fep.Show__c = true;
        insert fep;

        Pratica__c pratica = [SELECT Id, Account_Codice_Cliente__c FROM Pratica__c LIMIT 1];

        PageReference pageRef = Page.EstrattoContoPage;
        pageRef.getParameters().put('Id', pratica.Id);
        pageRef.getParameters().put('type', 'preview');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController standContr = new ApexPages.StandardController(pratica);
        CtrlEstrattoContoPage ctrlEstrContoPg = new CtrlEstrattoContoPage(standContr);

        PageReference pageRefAcc = Page.EstrattoContoAccountPage;
        pageRefAcc.getParameters().put('Id', pratica.Id);
        pageRefAcc.getParameters().put('type', 'preview');
        Test.setCurrentPage(pageRefAcc);
        ApexPages.StandardController standContrAcc = new ApexPages.StandardController(pratica);
        CtrlEstrattoContoPage ctrlEstrContoPgAcc = new CtrlEstrattoContoPage(standContrAcc);

        Test.stopTest();
    }
}