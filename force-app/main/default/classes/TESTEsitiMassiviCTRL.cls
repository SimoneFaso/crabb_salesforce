/* ---------------------------------------------------------------------------------------------------------------------
Name:            TESTEsitiMassiviCTRL.cls
Description:     Test Class for code coverage of EsitiMassiviCTRL.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
05-Aug-2021  0.2      Giulia Mameli        Recalled setFilter() method to raise coverage
----------------------------------------------------------------------------------------------------------------------*/

@IsTest
private class TESTEsitiMassiviCTRL {
    
    @IsTest static void test_method_one() {

        Test.startTest();

        //AffidiSettings__c afs =new AffidiSettings__c();
        EsitiMassiviProfile__c esMassProf = new EsitiMassiviProfile__c();

        esMassProf.SetupOwnerId = UserInfo.getProfileId();
        esMassProf.Sottotipo__c = 'Prima raccomandata;Seconda Raccomandata;Phone Collection';
        esMassProf.Tipo__c = 'Proposta di Attività';
        insert esMassProf;


        List<Profile> prof = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        String chiave = prof.get(0).Name;

        CRABB_DEV__EsitazioneMassivaPermission__mdt eMps = getCustomMdt(chiave, 'Prima raccomandata;Seconda Raccomandata;Phone Collection', 'Proposta di Attività');

        Account a = testClassForDataGenerationCreateData.getTestAccount();
        insert a;
        
        Pratica__c p = testClassForDataGenerationCreateData.getTestPratica();
        p.Account__c = a.Id;
        p.Stato__c = 'In Lavorazione';
        insert p;
        
        Pratica__c p2 = testClassForDataGenerationCreateData.getTestPratica();
        p2.Account__c = a.Id;
        p2.Stato__c = 'Affidata';
        insert p2;

        Movimento__c m = testClassForDataGenerationCreateData.getTestMovimento();
        Date tmp = System.today();
        tmp.addDays(5);
        m.Pratica__c = p.Id;
        m.Account__c = a.Id;
        m.Data_Scadenza__c = tmp;
        insert m;

        List<Strategia__c> ListStrategie = new List<Strategia__c>();
        List<Strategia__c> ListTestata = new List<Strategia__c>();
        List<Task> ListTask = new List<Task>();
    	Id rtStrat_Step =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Step').getRecordTypeId();
    	Id rtStrat_Testata =  Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName().get('Testata').getRecordTypeId();
        System.debug('Step: ' + rtStrat_Step + ' - Testata - ' + rtStrat_Testata);
    	
    	for(Integer i=0; i<16; i++){
    		Strategia__c Testata = new Strategia__c();
			Testata.RecordTypeId = rtStrat_Testata;
			Testata.Tipologia__c = 'UI';
			Testata.Stato__c = 'Attiva';
        	
        	ListTestata.add(Testata);
    	}
    	insert ListTestata;

        for(Integer i=0; i<16; i++){
    		Strategia__c Strat = new Strategia__c();
			Strat.RecordTypeId=rtStrat_Step;
			Strat.Tipologia__c = 'UI';
			Strat.Stato__c = 'Attiva';
			Strat.Testata__c = ListTestata[i].Id;
        	ListStrategie.add(Strat);
    	}
        insert ListStrategie;

        List<Strategia__c> listStrTest = Database.query('SELECT '+Utils.getSOBJECTFieldsForQuery('Strategia__c')+' FROM Strategia__c WHERE Recordtype.Name = \'Testata\'');
        ListTestata.clear();
        for(Strategia__c s : listStrTest)
        {
            s.Stato__c = 'Attiva';
            ListTestata.add(s);
        }
        update ListTestata;

        List<String> ListIdStrat = new List<String>();
        for(Strategia__c Str : ListStrategie){
            System.debug('**TEST Str.Id = ' + Str.Id);
            System.debug('**TEST Str.Stato__c = ' + Str.Stato__c);
            System.debug('**TEST Str.Stato_testata__c = ' + Str.Stato_testata__c);
            System.debug('**TEST Str.RecordType = ' + Str.RecordTypeId);
        	System.debug('**TEST Str.Tipologia__c = ' + Str.Tipologia__c);
        	ListIdStrat.add(String.valueOf(Str.Id));
        }

        Profile profile = [SELECT Id FROM Profile WHERE Name LIKE '%admin%' LIMIT 1];
        User Utente1 = new User ( IsActive = true,
            Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
            Email = 'Unassigned@god.it', Alias = 'Unassi', ProfileId = profile.Id,
            CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
            EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        );
        insert Utente1;

        //list<Task> ListTask = new list<Task>();
        List<ActivityExtended__c> aes = new List<ActivityExtended__c>();
        for(Integer i=0; i<ListStrategie.size(); i++)
        {
        	ActivityExtended__c ae = new ActivityExtended__c();
        	ae.id_attivita__c = ListIdStrat[i];
            System.debug('ListIdStrat[i]: ' + ListIdStrat[i]);
        	ae.Tipo__c = 'Proposta di Attività';
            if(i==0)
                ae.Sotto_Tipo__c = 'Test';
            else
        	    ae.Sotto_Tipo__c = 'Prima raccomandata';
        	ae.Owner_contratto__c = 'Gelsomino';
            aes.add(ae);
        }
        insert aes;

        List<ActivityExtended__c> lAE = [SELECT Id,Sotto_Tipo__c FROM ActivityExtended__c];
        for(ActivityExtended__c ae : lAE)
        {
            Task tsk = new Task();
            tsk.OwnerId = Utente1.Id;
            tsk.Priority = 'Alta';
            tsk.Status = 'Non Iniziata';
            if(ae.Sotto_Tipo__c == 'Test')
                tsk.WhatId = p2.Id;
            else
                tsk.WhatId = p.Id;//ListIdPratica[i];
            tsk.ActivityExtended__c = ae.Id;
            ListTask.add(tsk);
        }
        insert ListTask;

        List<Strategia__c> listStr = database.query('SELECT '+Utils.getSOBJECTFieldsForQuery('Strategia__c')+' FROM Strategia__c WHERE Recordtype.Name = \'Step\' AND Tipologia__c = \'UI\' AND Stato_testata__c = \'Attiva\'');
        system.debug('listStr: ' + listStr);
        Set<Id> setIdStrategie = new Set<Id>();
        for(Strategia__c strat : listStrategie)
        {
            setIdStrategie.add(strat.Id);
        }
        // ActivityExtended__r.id_attivita__c IN :setIdStrategie AND
        String queryOnTasks = 'SELECT Id, WhatId, ActivityExtended__c, ActivityExtended__r.id_attivita__c FROM Task WHERE Status =\'Non Iniziata\' AND ActivityExtended__r.id_affidamento__c = null';
        Set<Id> idPraticheTemp = new Set<Id>();
        for(Task t : (List<Task>) Database.query(queryOnTasks))
        {
            system.debug('IdAES: ' + t.ActivityExtended__c);
            system.debug('IdAttività: ' + t.ActivityExtended__r.id_attivita__c);
            idPraticheTemp.add(t.whatID);
        }
        system.debug('idPraticheTemp: ' + idPraticheTemp);


        EsitiMassiviCTRL.ARWrapper arw = new EsitiMassiviCTRL.ARWrapper('sotto', 'owner', 1, 1);

        ApexPages.StandardController std = new ApexPages.StandardController(p);
        EsitiMassiviCTRL ctrl = new EsitiMassiviCTRL(std);        
        List<SelectOption> so = ctrl.getEsitiPickListValues();
        List<SelectOption> lso = ctrl.pickVisibilityResult;
        //ctrl.ownerOne = 'all';
        Test.setCurrentPageReference(new PageReference('Page.Esiti_Massivi'));
	    System.currentPageReference().getParameters().put('owner', 'all');
        ctrl.createStepOne();
        Test.setCurrentPageReference(new PageReference('Page.Esiti_Massivi'));
	    System.currentPageReference().getParameters().put('owner', 'Gelsomino');
        ctrl.createStepOne();
        ctrl.selAll = true;
        ctrl.selectAll();
        ctrl.selAll = false;
        ctrl.selectAll();
        ctrl.selPage = true;
        ctrl.selectPage();
        ctrl.selPage = false;
        ctrl.selectPage();
        ctrl.selectedPickValue = Utils.NAMESPACE+'Data_in_Lavorazione__c';
        ctrl.picklistMethod();
        ctrl.setFilter();

        ctrl.selectedPickValue = Utils.NAMESPACE+'Residuo_Totale__c';
        ctrl.picklistMethod();
        ctrl.setFilter();

        ctrl.selectedPickValue = Utils.NAMESPACE+'White_list__c';
        ctrl.picklistMethod();
        ctrl.setFilter();

        ctrl.selectedPickValue = Utils.NAMESPACE+'Modalit_Invio_Sollecito__c';
        ctrl.getPicklistInput();
        ctrl.setFilter();

        ctrl.selectedPickValue = Utils.NAMESPACE+'CAP__c';
        ctrl.sInput = '73028';
        ctrl.picklistMethod();
        ctrl.setFilter();

        ctrl.deleteFilter();
        ctrl.selectedNumOfRec = '10';
        ctrl.setNumOfRec();
        //ctrl.AffidaLista();
        ctrl.ConfermaLista();
        ctrl.empty();
        ctrl.backTo();
        ctrl.homePage();
        ctrl.clearFilter();
        ctrl.goNext();
        ctrl.selectedEsitiPickValue = '';
        ctrl.letteraStr = '';

        Test.stopTest();

    }

    public static CRABB_DEV__EsitazioneMassivaPermission__mdt getCustomMdt(String chiave, String subtype, String type) {
        CRABB_DEV__EsitazioneMassivaPermission__mdt theRecord = [SELECT Id, CRABB_DEV__key__c, CRABB_DEV__type__c, CRABB_DEV__subtype__c from CRABB_DEV__EsitazioneMassivaPermission__mdt LIMIT 1];
        theRecord.CRABB_DEV__key__c = chiave;
        theRecord.CRABB_DEV__subtype__c = subtype;
        theRecord.CRABB_DEV__type__c = type;
        return theRecord;
    }
    
}