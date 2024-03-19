@isTest
private class TestAffidiSettingsCTRL {
    
    @isTest static void testALL(){
        Test.startTest();

        AffidiSettings__c temp = new AffidiSettings__c(Name='Test',Tipo__c='TipoTest',Sottotipo__c='SottotipoTest',SetupOwnerId=UserInfo.getProfileId());
        insert temp;

        String tempSObj = Utils.NAMESPACE+'Strategia__c';
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = :tempSObj AND Name = 'Step' LIMIT 1];
        Strategia__c newS = new Strategia__c(Tipologia__c='UI',RecordTypeId=rt.Id,Tipo_Attivita__c='Test1',Sotto_tipo_attivita__c='Test2');
        insert newS;

        PageReference page = new pageReference('/apex/AffidiSettingsPage');
        Test.setCurrentPage(page);
        AffidiSettingsCTRL ctrl = new AffidiSettingsCTRL();

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

        AffidiSettingsCTRL.editRecord(temp.Id, 'System Administrator', 'tipo', 'sottotipo');
        AffidiSettingsCTRL.removeRecords(temp.Id);

        Test.stopTest();
    }
    
}