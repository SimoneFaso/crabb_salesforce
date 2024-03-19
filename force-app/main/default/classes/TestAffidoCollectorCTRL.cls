@isTest
private class TestAffidoCollectorCTRL {
    
    @isTest static void testALL(){
        Test.startTest();

        Collector_con_Tipo_Affido__c temp = new Collector_con_Tipo_Affido__c(Name='Test',Categoria_Collector__c='TipoTest',Tipo_Affido__c='SottotipoTest');
        insert temp;

        PageReference page = new pageReference('/apex/AffidoCollectorPage');
        Test.setCurrentPage(page);
        AffidoCollectorCTRL ctrl = new AffidoCollectorCTRL();

        ctrl.emptyMethod();
        ctrl.getListCollector();

        ctrl.addRecord();

        ctrl.newName = 'Test';
        ctrl.newCategoria = 'newCat';
        ctrl.newTipoAff = 'tipo';
        ctrl.addRecord();

        AffidoCollectorCTRL.editRecord(null, null, null, null, null);

        AffidoCollectorCTRL.editRecord(temp.Id, 'name', 'categoria', null, 'tipo');
        AffidoCollectorCTRL.removeRecords(temp.Id);
        
        Test.stopTest();
    }
    
}