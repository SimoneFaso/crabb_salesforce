/* ---------------------------------------------------------------------------------------------------------------------
Name:            AmministrazioneCTRL.cls
Description:
Test class:      TestAmministrazioneCTRL.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
             0.2      Matteo Siotto                   Added importMapping() method for triggering the mapping the first time
                                                      (Not Committed)
24-Aug-2021  0.3      Claudio Sanna                   Modified class from without sharing to with sharing
													  (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class AmministrazioneCTRL {

    public AmministrazioneSettings__c currentAS { get; set; }
    public static Integer mappingMigrationScopeSize = MappingUtils.getMappingMigrationScopeSize();

    public AmministrazioneCTRL() {

        currentAS = AmministrazioneSettings__c.getInstance(UserInfo.getProfileId());
        System.debug('@@@ ' + currentAS);

    }

    @AuraEnabled(Cacheable=true)
    public static AmministrazioneSettingCustomFiledNames getCurrentAS() {
        AmministrazioneCTRL amministrazioneCTRL = new AmministrazioneCTRL();
        AmministrazioneSettingCustomFiledNames customCurrentAS = new AmministrazioneSettingCustomFiledNames();

        customCurrentAS.ConfigurazioneAmministrazione = amministrazioneCTRL.currentAS.ConfigurazioneAmministrazione__c;
		customCurrentAS.FasceCollector = amministrazioneCTRL.currentAS.FasceCollector__c;
		customCurrentAS.ProfilazioneUtenti = amministrazioneCTRL.currentAS.ProfilazioneUtenti__c;
		customCurrentAS.AttivitaProfili = amministrazioneCTRL.currentAS.AttivitaProfili__c;
		customCurrentAS.ConfigurazioneStrategie = amministrazioneCTRL.currentAS.ConfigurazioneStrategie__c;
		customCurrentAS.EstrattoConto = amministrazioneCTRL.currentAS.EstrattoConto__c;
		customCurrentAS.CruscottoPratica = amministrazioneCTRL.currentAS.CruscottoPratica__c;
		customCurrentAS.ConfigurazioneCollector = amministrazioneCTRL.currentAS.ConfigurazioneCollector__c;
		customCurrentAS.FlussiCollector = amministrazioneCTRL.currentAS.FlussiCollector__c;
		customCurrentAS.AffidoCollector = amministrazioneCTRL.currentAS.AffidoCollector__c;
		customCurrentAS.GestioneOrkBatch = amministrazioneCTRL.currentAS.GestioneOrkBatch__c;
		customCurrentAS.ConfigurazioneMapping = amministrazioneCTRL.currentAS.ConfigurazioneMapping__c;
		customCurrentAS.EliminazioneLog = amministrazioneCTRL.currentAS.EliminazioneLog__c;
		customCurrentAS.CostiAttivita = amministrazioneCTRL.currentAS.CostiAttivita__c;
		customCurrentAS.ImportStrategie = amministrazioneCTRL.currentAS.ImportStrategie__c;
		customCurrentAS.ImportCustomSettings = amministrazioneCTRL.currentAS.Import_custom_settings__c;
		customCurrentAS.InitialImportMapping = amministrazioneCTRL.currentAS.InitialImportMapping__c;

        return customCurrentAS;
    }


    @AuraEnabled(Cacheable=true)
    public static String getUrl() {
        return URL.getSalesforceBaseUrl().toExternalForm();
        //System.debug('------>' + URL.getOrgDomainUrl().toExternalForm());
    }

    @AuraEnabled
    public static void importCustomSetting() {
        ImportCusSettings.getData();
    }

    @AuraEnabled
    public static void importMapping() {
        Database.executeBatch(new HandleMappingMigrationBatch(), mappingMigrationScopeSize);
    }

    public class AmministrazioneSettingCustomFiledNames {

        @AuraEnabled
        public Boolean ConfigurazioneAmministrazione { get; set; }
        @AuraEnabled
        public Boolean FasceCollector { get; set; }
        @AuraEnabled
        public Boolean ProfilazioneUtenti { get; set; }
        @AuraEnabled
        public Boolean AttivitaProfili { get; set; }
        @AuraEnabled
        public Boolean ConfigurazioneStrategie { get; set; }
        @AuraEnabled
        public Boolean EstrattoConto { get; set; }
        @AuraEnabled
        public Boolean CruscottoPratica { get; set; }
        @AuraEnabled
        public Boolean ConfigurazioneCollector { get; set; }
        @AuraEnabled
        public Boolean FlussiCollector { get; set; }
        @AuraEnabled
        public Boolean AffidoCollector { get; set; }
        @AuraEnabled
        public Boolean GestioneOrkBatch { get; set; }
        @AuraEnabled
        public Boolean ConfigurazioneMapping { get; set; }
        @AuraEnabled
        public Boolean EliminazioneLog { get; set; }
        @AuraEnabled
        public Boolean CostiAttivita { get; set; }
        @AuraEnabled
        public Boolean ImportStrategie { get; set; }
        @AuraEnabled
        public Boolean ImportCustomSettings { get; set; }
        @AuraEnabled
        public Boolean InitialImportMapping { get; set; }
    }
}