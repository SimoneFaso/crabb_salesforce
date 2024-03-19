global class PostInstallClass implements InstallHandler {
    global void onInstall(InstallContext context) {
        User u = [Select Id, Email from User where Id =:context.installerID()];   
        String toAddress= u.Email;
        String[] toAddresses = new String[]{toAddress};
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('build@balanceconsulting.it');
        mail.setSenderDisplayName('CRABB Support');
        String plainTextBody = '';
        if(context.previousVersion() == null) {                    
            mail.setSubject('Package install successful');
            plainTextBody = 'Thanks for installing the package.\n\nMore informations on our support site:\nhttps://www.crabb.it';
        }
        else
        if(context.previousVersion().compareTo(new Version(1,0)) == 0) {
            //'Upgrading from Version 1.0'
            mail.setSubject('Package upgrade from Version 1.0 successful');
            plainTextBody = 'Thanks for upgrading the package from release 1.0 to the newest release.\nMore informations on our support site:\nhttps://www.crabb.it';
        }
        if(context.isUpgrade()) {
            mail.setSubject('Package upgrade successful');
            plainTextBody = 'Thanks for installing the package.\nMore informations on our support site:\nhttps://www.crabb.it';
        }
        if(context.isPush()) {

        }
        mail.setPlainTextBody(plainTextBody);
        try {
            Messaging.sendEmail(new Messaging.Email[] { mail });
        } catch (Exception e) {
            System.debug('Error on send email from post install class:'+e.getMessage());
        }

        if(Utils.checkFLSPermission('AmministrazioneSettings__c', 'AffidoCollector__c').get('CREATE') &&
            Utils.checkFLSPermission('AmministrazioneSettings__c', 'AttivitaProfili__c').get('CREATE') &&
            Utils.checkFLSPermission('AmministrazioneSettings__c', 'ConfigurazioneAmministrazione__c').get('CREATE') &&
            Utils.checkFLSPermission('AmministrazioneSettings__c', 'ConfigurazioneCollector__c').get('CREATE') &&
            Utils.checkFLSPermission('AmministrazioneSettings__c', 'ConfigurazioneMapping__c').get('CREATE') &&
            Utils.checkFLSPermission('AmministrazioneSettings__c', 'ConfigurazioneStrategie__c').get('CREATE') &&
            Utils.checkFLSPermission('AmministrazioneSettings__c', 'CruscottoPratica__c').get('CREATE') &&
            Utils.checkFLSPermission('AmministrazioneSettings__c', 'EstrattoConto__c').get('CREATE') &&
            Utils.checkFLSPermission('AmministrazioneSettings__c', 'FlussiCollector__c').get('CREATE') &&
            Utils.checkFLSPermission('AmministrazioneSettings__c', 'GestioneOrkBatch__c').get('CREATE') &&
            Utils.checkFLSPermission('AmministrazioneSettings__c', 'EliminazioneLog__c').get('CREATE') &&
            Utils.checkFLSPermission('AmministrazioneSettings__c', 'ProfilazioneUtenti__c').get('CREATE') &&
            Utils.checkFLSPermission('AmministrazioneSettings__c', 'CostiAttivita__c').get('CREATE') &&
            Utils.checkFLSPermission('AmministrazioneSettings__c', 'SetupOwnerId').get('CREATE') &&
            Utils.checkFLSPermission('AmministrazioneSettings__c', 'FasceCollector__c').get('CREATE') &&
            Utils.checkObjPermission('AmministrazioneSettings__c').get('ACCESS') && 
            Utils.checkObjPermission('AmministrazioneSettings__c').get('UPDATE') && 
            Utils.checkObjPermission('AmministrazioneSettings__c').get('CREATE')){

            if(Utils.checkFLSPermission('AmministrazioneSettings__c', 'AffidoCollector__c').get('UPDATE') &&
                Utils.checkFLSPermission('AmministrazioneSettings__c', 'AttivitaProfili__c').get('UPDATE') &&
                Utils.checkFLSPermission('AmministrazioneSettings__c', 'ConfigurazioneAmministrazione__c').get('UPDATE') &&
                Utils.checkFLSPermission('AmministrazioneSettings__c', 'ConfigurazioneCollector__c').get('UPDATE') &&
                Utils.checkFLSPermission('AmministrazioneSettings__c', 'ConfigurazioneMapping__c').get('UPDATE') &&
                Utils.checkFLSPermission('AmministrazioneSettings__c', 'ConfigurazioneStrategie__c').get('UPDATE') &&
                Utils.checkFLSPermission('AmministrazioneSettings__c', 'CruscottoPratica__c').get('UPDATE') &&
                Utils.checkFLSPermission('AmministrazioneSettings__c', 'EstrattoConto__c').get('UPDATE') &&
                Utils.checkFLSPermission('AmministrazioneSettings__c', 'FlussiCollector__c').get('UPDATE') &&
                Utils.checkFLSPermission('AmministrazioneSettings__c', 'GestioneOrkBatch__c').get('UPDATE') &&
                Utils.checkFLSPermission('AmministrazioneSettings__c', 'EliminazioneLog__c').get('UPDATE') &&
                Utils.checkFLSPermission('AmministrazioneSettings__c', 'ProfilazioneUtenti__c').get('UPDATE') &&
                Utils.checkFLSPermission('AmministrazioneSettings__c', 'CostiAttivita__c').get('UPDATE') &&
                Utils.checkFLSPermission('AmministrazioneSettings__c', 'SetupOwnerId').get('UPDATE') &&
                Utils.checkFLSPermission('AmministrazioneSettings__c', 'FasceCollector__c').get('UPDATE')){
                try{
                    List<AmministrazioneSettings__c> listAS = new List<AmministrazioneSettings__c>();

                    AmministrazioneSettings__c def = AmministrazioneSettings__c.getOrgDefaults();
                    if(def == null){
                        def = new AmministrazioneSettings__c();
                    }
                    def.AffidoCollector__c = false;
                    def.AttivitaProfili__c = false;
                    def.ConfigurazioneAmministrazione__c = false;
                    def.ConfigurazioneCollector__c = false;
                    def.ConfigurazioneMapping__c = false;
                    def.ConfigurazioneStrategie__c = false;
                    def.CruscottoPratica__c = false;
                    def.EstrattoConto__c = false;
                    def.FlussiCollector__c = false;
                    def.GestioneOrkBatch__c = false;
                    def.EliminazioneLog__c = false;
                    def.ProfilazioneUtenti__c = false;
                    def.CostiAttivita__c = false;
                    def.FasceCollector__c = false;
                    def.SetupOwnerId = UserInfo.getOrganizationId();

                    listAS.add(def);

                    List<Profile> saId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Amministratore del sistema' LIMIT 1];

                    if(saId != null && !saId.isEmpty()){
                        AmministrazioneSettings__c sys = AmministrazioneSettings__c.getInstance(saId[0].Id);
                        if(sys == null){
                            sys = new AmministrazioneSettings__c();
                        }
                        sys.AffidoCollector__c = true;
                        sys.AttivitaProfili__c = true;
                        sys.ConfigurazioneAmministrazione__c = true;
                        sys.ConfigurazioneCollector__c = true;
                        sys.ConfigurazioneMapping__c = true;
                        sys.ConfigurazioneStrategie__c = true;
                        sys.CruscottoPratica__c = true;
                        sys.EstrattoConto__c = true;
                        sys.FlussiCollector__c = true;
                        sys.GestioneOrkBatch__c = true;
                        sys.EliminazioneLog__c = true;
                        sys.ProfilazioneUtenti__c = true;
                        sys.CostiAttivita__c = true;
                        sys.FasceCollector__c = true;
                        sys.SetupOwnerId = saId[0].Id;

                        listAS.add(sys);

                    }
                    upsert listAS;
                }catch(Exception ex){
                    ErrorClass.logError('PostInstallClass','Records AmministrazioneSettings__c \n'+ex.getMessage()+'\n'+ex.getStackTraceString());
                }
            }
        }

        if(Utils.checkFLSPermission('ListOfFields__c', 'Name').get('CREATE') &&
            Utils.checkFLSPermission('ListOfFields__c', 'Field__c').get('CREATE') &&
            Utils.checkFLSPermission('ListOfFields__c', 'Object__c').get('CREATE') &&
            Utils.checkFLSPermission('ListOfFields__c', 'Show__c').get('CREATE') &&
            Utils.checkObjPermission('ListOfFields__c').get('ACCESS') && 
            Utils.checkObjPermission('ListOfFields__c').get('UPDATE') && 
            Utils.checkObjPermission('ListOfFields__c').get('CREATE')){

            if(Utils.checkFLSPermission('ListOfFields__c', 'Name').get('UPDATE') &&
                Utils.checkFLSPermission('ListOfFields__c', 'Field__c').get('UPDATE') &&
                Utils.checkFLSPermission('ListOfFields__c', 'Object__c').get('UPDATE') &&
                Utils.checkFLSPermission('ListOfFields__c', 'Show__c').get('UPDATE')){

                try{

                    List<ListOfFields__c> tempListLOF = new List<ListOfFields__c>();
                    ListOfFields__c tmp1 = new ListOfFields__c(Name = 'TabPrat0000000',Field__c = 'Expired Amounts Ageing', Object__c = 'TabPrat', Show__c = true);
                    ListOfFields__c tmp2 = new ListOfFields__c(Name = 'TabPrat0000001',Field__c = 'Statement of Account', Object__c = 'TabPrat', Show__c = true);
                    ListOfFields__c tmp3 = new ListOfFields__c(Name = 'TabPrat0000002',Field__c = 'Activities', Object__c = 'TabPrat', Show__c = true);
                    ListOfFields__c tmp4 = new ListOfFields__c(Name = 'TabPrat0000003',Field__c = 'Repayment Plans', Object__c = 'TabPrat', Show__c = false);
                    ListOfFields__c tmp5 = new ListOfFields__c(Name = 'TabPrat0000004',Field__c = 'Service Requests', Object__c = 'TabPrat', Show__c = false);
                    ListOfFields__c tmp6 = new ListOfFields__c(Name = 'TabPrat0000005',Field__c = 'Service/Product Detail', Object__c = 'TabPrat', Show__c = false);
                    ListOfFields__c tmp7 = new ListOfFields__c(Name = 'TabPrat0000006',Field__c = 'Assignments', Object__c = 'TabPrat', Show__c = false);
                    ListOfFields__c tmp8 = new ListOfFields__c(Name = 'TabPrat0000007',Field__c = 'Voices', Object__c = 'TabPrat', Show__c = false);
                    ListOfFields__c tmp9 = new ListOfFields__c(Name = 'TabPrat0000008',Field__c = 'Documentation', Object__c = 'TabPrat', Show__c = false);
                    ListOfFields__c tmp10 = new ListOfFields__c(Name = 'TabPrat0000009',Field__c = 'Strategy', Object__c = 'TabPrat', Show__c = false);
                    ListOfFields__c tmp11 = new ListOfFields__c(Name = 'TabPrat0000010',Field__c = 'Chatter', Object__c = 'TabPrat', Show__c = false);
                    tempListLOF.add(tmp1);
                    tempListLOF.add(tmp2);
                    tempListLOF.add(tmp3);
                    tempListLOF.add(tmp4);
                    tempListLOF.add(tmp5);
                    tempListLOF.add(tmp6);
                    tempListLOF.add(tmp7);
                    tempListLOF.add(tmp8);
                    tempListLOF.add(tmp9);
                    tempListLOF.add(tmp10);
                    tempListLOF.add(tmp11);

                    Database.insert(tempListLOF,false);

                    tempListLOF.clear();

                    ListOfFields__c tmov1 = new ListOfFields__c(Name='FMov0000000',Field__c='Id',Object__c='Movimento__c',Show__c=true);
                    ListOfFields__c tmov2 = new ListOfFields__c(Name='FMov0000001',Field__c='RecordType.Name',Object__c='Movimento__c',Show__c=true);
                    ListOfFields__c tmov3 = new ListOfFields__c(Name='FMov0000002',Field__c='Data_Emissione__c',Object__c='Movimento__c',Show__c=true);
                    ListOfFields__c tmov4 = new ListOfFields__c(Name='FMov0000003',Field__c='Data_Scadenza__c',Object__c='Movimento__c',Show__c=true);
                    ListOfFields__c tmov5 = new ListOfFields__c(Name='FMov0000004',Field__c='Importo__c',Object__c='Movimento__c',Show__c=true);
                    ListOfFields__c tmov6 = new ListOfFields__c(Name='FMov0000005',Field__c='Residuo__c',Object__c='Movimento__c',Show__c=true);
                    ListOfFields__c tmov7 = new ListOfFields__c(Name='FMov0000006',Field__c='Sollecitabile__c',Object__c='Movimento__c',Show__c=true);
                    ListOfFields__c tmov8 = new ListOfFields__c(Name='FMov0000007',Field__c='Write_Off__c',Object__c='Movimento__c',Show__c=true);
                    ListOfFields__c tmov9 = new ListOfFields__c(Name='FMov0000008',Field__c='Pratica__r.Name',Object__c='Movimento__c',Show__c=true);
                    ListOfFields__c tmov10 = new ListOfFields__c(Name='FMov0000009',Field__c='Tipo_Servizio__c',Object__c='Movimento__c',Show__c=true);
                    ListOfFields__c tmov11 = new ListOfFields__c(Name='FMov0000010',Field__c='Cartolarizzazione__c',Object__c='Movimento__c',Show__c=true);
                    tempListLOF.add(tmov1);
                    tempListLOF.add(tmov2);
                    tempListLOF.add(tmov3);
                    tempListLOF.add(tmov4);
                    tempListLOF.add(tmov5);
                    tempListLOF.add(tmov6);
                    tempListLOF.add(tmov7);
                    tempListLOF.add(tmov8);
                    tempListLOF.add(tmov9);
                    tempListLOF.add(tmov10);
                    tempListLOF.add(tmov11);

                    Database.insert(tempListLOF,false);

                    tempListLOF.clear();

                    ListOfFields__c ttsk1 = new ListOfFields__c(Name='FTsk0000000',Field__c='Id',Object__c='Task',Show__c=true);
                    ListOfFields__c ttsk2 = new ListOfFields__c(Name='FTsk0000001',Field__c='CreatedDate',Object__c='Task',Show__c=true);
                    ListOfFields__c ttsk3 = new ListOfFields__c(Name='FTsk0000002',Field__c='ActivityExtended__r.Tipo__c',Object__c='Task',Show__c=true);
                    ListOfFields__c ttsk4 = new ListOfFields__c(Name='FTsk0000003',Field__c='Subject',Object__c='Task',Show__c=true);
                    ListOfFields__c ttsk5 = new ListOfFields__c(Name='FTsk0000004',Field__c='ActivityExtended__r.Fase__c',Object__c='Task',Show__c=true);
                    ListOfFields__c ttsk6 = new ListOfFields__c(Name='FTsk0000005',Field__c='Status',Object__c='Task',Show__c=true);
                    ListOfFields__c ttsk7 = new ListOfFields__c(Name='FTsk0000006',Field__c='ActivityExtended__r.Stato_Approvazione__c',Object__c='Task',Show__c=true);
                    ListOfFields__c ttsk8 = new ListOfFields__c(Name='FTsk0000007',Field__c='ActivityExtended__r.Esito__c',Object__c='Task',Show__c=true);
                    ListOfFields__c ttsk9 = new ListOfFields__c(Name='FTsk0000008',Field__c='ActivityExtended__r.Saldo_Attivit__c',Object__c='Task',Show__c=true);
                    ListOfFields__c ttsk10 = new ListOfFields__c(Name='FTsk0000009',Field__c='ActivityExtended__r.Costo__c',Object__c='Task',Show__c=true);
                    ListOfFields__c ttsk11 = new ListOfFields__c(Name='FTsk0000010',Field__c='ActivityExtended__r.SLA__c',Object__c='Task',Show__c=true);
                    ListOfFields__c ttsk12 = new ListOfFields__c(Name='FTsk0000011',Field__c='ActivityExtended__r.Strategia__c',Object__c='Task',Show__c=true);
                    ListOfFields__c ttsk13 = new ListOfFields__c(Name='FTsk0000012',Field__c='Type',Object__c='Task',Show__c=true);
                    ListOfFields__c ttsk14 = new ListOfFields__c(Name='FTsk0000013',Field__c='WhatId',Object__c='Task',Show__c=true);
                    ListOfFields__c ttsk15 = new ListOfFields__c(Name='FTsk0000014',Field__c='Description',Object__c='Task',Show__c=true);
                    ListOfFields__c ttsk16 = new ListOfFields__c(Name='FTsk0000015',Field__c='AccountId',Object__c='Task',Show__c=true);
                    tempListLOF.add(ttsk1);
                    tempListLOF.add(ttsk2);
                    tempListLOF.add(ttsk3);
                    tempListLOF.add(ttsk4);
                    tempListLOF.add(ttsk5);
                    tempListLOF.add(ttsk6);
                    tempListLOF.add(ttsk7);
                    tempListLOF.add(ttsk8);
                    tempListLOF.add(ttsk9);
                    tempListLOF.add(ttsk10);
                    tempListLOF.add(ttsk11);
                    tempListLOF.add(ttsk12);

                    tempListLOF.add(ttsk14);
                    tempListLOF.add(ttsk15);
                    tempListLOF.add(ttsk16);

                    Database.insert(tempListLOF,false);

                }catch(Exception ex){
                    ErrorClass.logError('PostInstallClass','Records Tab\n'+ex.getMessage()+'\n'+ex.getStackTraceString());
                }
            }
        }

        if(Utils.checkFLSPermission('AffidiSettings__c', 'SetupOwnerId').get('CREATE') && Utils.checkFLSPermission('AffidiSettings__c', 'SetupOwnerId').get('UPDATE')
            && Utils.checkObjPermission('AffidiSettings__c').get('CREATE') && Utils.checkObjPermission('AffidiSettings__c').get('ACCESS') && Utils.checkObjPermission('AffidiSettings__c').get('UPDATE') ){

            try{

                AffidiSettings__c adef = AffidiSettings__c.getOrgDefaults();
                if(adef == null){
                    adef = new AffidiSettings__c();
                }
                adef.SetupOwnerId = UserInfo.getOrganizationId();
                upsert adef;

            }catch(Exception ex){
                ErrorClass.logError('PostInstallClass','AffidiSettings default \n'+ex.getMessage()+'\n'+ex.getStackTraceString());   
            }
        }
    }
}