@isTest
private class PermissionAccessCtrlTest {

    static testMethod void myUnitTest() {
        Account Acc = new Account(Name ='Giovanni', phone = '0116776534' );
        insert Acc;
        
        Apexpages.Standardcontroller SC = new Apexpages.Standardcontroller(Acc);
        Apexpages.currentPage().getparameters().put('retURL','/');
        PermissionAccessCtrl E = New PermissionAccessCtrl(SC);

        E.ritorna();

    }
}