@isTest
private class TestGestioneEsitiMassiviCTRL {
    
    @isTest static void testALL(){
        Test.startTest();

        EsitiMassiviProfile__c temp = new EsitiMassiviProfile__c(Name='Test',Tipo__c='TipoTest',Sottotipo__c='SottotipoTest',SetupOwnerId=UserInfo.getProfileId());
        insert temp;

        String tempSObj = Utils.NAMESPACE+'Strategia__c';
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = :tempSObj AND Name = 'Step' LIMIT 1];
        Strategia__c newS = new Strategia__c(Tipologia__c='UI',RecordTypeId=rt.Id,Tipo_Attivita__c='Test1',Sotto_tipo_attivita__c='Test2');
        insert newS;

        PageReference page = new pageReference('/apex/GestioneEsitiMassiviPage');
        Test.setCurrentPage(page);
        GestioneEsitiMassiviCTRL ctrl = new GestioneEsitiMassiviCTRL();

        ctrl.selectedLocation = 'Profile';

        ctrl.emptyMethod();

        ctrl.addNewRecord();

        ctrl.addingProfile = 'Read Only';
        ctrl.addingTipo = 'NewTipo';
        List<String> tempL = new List<String>{'test'};
        ctrl.addingSotto = tempL;
        ctrl.addNewRecord();

        ctrl.addingTipo = 'Test1';
        ctrl.retrieveSottotipo();

        ctrl.selectedTipo = 'Test1';
        ctrl.retrieveSottotipoTwo();

        GestioneEsitiMassiviCTRL.editRecord(temp.Id, 'System Administrator', 'tipo', 'sottotipo');
        GestioneEsitiMassiviCTRL.removeRecords(temp.Id);

        Test.stopTest();
    }
    
}