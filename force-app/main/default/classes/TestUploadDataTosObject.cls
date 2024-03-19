@IsTest
private class TestUploadDataTosObject 
{
    static testMethod void UnitTest1()
    {
        User u = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');

        insert TestClassForDatagenerationCreateData.getTestPratica();
        Pratica__c pratica = [SELECT Id, Name FROM Pratica__c LIMIT 1];
       
        Collector__c col = new Collector__c();
        col = TestClassFroDataGenAffidamenti.getCollector(u.Id);
        insert col;

        Affidamento__c aff = TestClassFroDataGenAffidamenti.getQuickAffido();
        insert aff;

        Task t = new Task();
        t.Type = 'Credito';
        ActivityExtended__c ae = new ActivityExtended__c();
        ae.E_da_affidare__c = true;
        ae.id_affidamento__c = aff.Id;
        insert ae;

        t.ActivityExtended__c = ae.Id;
        t.Status = 'Non Iniziata';
        t.WhatId = pratica.Id;
        insert t;

        Task testTask = [SELECT Id, What.Name, What.Id FROM Task LIMIT 1];
        System.debug('-----> testTask: ' + testTask);

        insert new Esiti_Collector__c(Name = 'ALTRO', Esito__c = 'ALTRO', Codice_Esito__c = 'N08');

        Test.startTest();

        UploadDataTosObject udto = new UploadDataTosObject();
        udto.fName = 'TEST';
        udto.IdColl = col.Id;

        //Pratica final
        udto.myString = '{"EsitiCollector": [{"Pratica": "' + testTask.What.Name + '","Esito": "Altro","Commento": "Altro","isFinal": "true"}]}';
        udto.parseData();
        udto.empty();

        //Pratica esito ginale non previsto
        udto.myString = '{"EsitiCollector": [{"Pratica": "' + testTask.What.Name + '","Esito": "Non previsto","Commento": "Altro","isFinal": "true"}]}';
        udto.parseData();
        udto.empty();

        //Pratica non final
        udto.myString = '{"EsitiCollector": [{"Pratica": "' + testTask.What.Name + '","Esito": "Altro","Commento": "Altro","isFinal": "false"}]}';
        udto.parseData();

        //Pratica non trovata
        udto.myString = '{"EsitiCollector": [{"Pratica": "' + 'PR_NON_PRESENTE' + '","Esito": "Altro","Commento": "Altro","isFinal": "false"}]}';
        udto.parseData();
        
        Test.stopTest();
    }
}