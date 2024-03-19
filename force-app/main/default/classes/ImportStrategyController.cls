/* ---------------------------------------------------------------------------------------------------------------------
Name:            ImportStrategyController.cls
Description:
Test class:      ImportStrategyController_Test.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
16-Sep-2022  0.2      C.Sanna & R.Kurti    Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class ImportStrategyController {
    	
    @AuraEnabled
    public static List<Strategia__c> readCSVFileAndUpload(Id idContentDocument) {
        system.debug('controller');
        try{
        if(idContentDocument != null) {
            
            // getting File Data based on document id 
            ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument WITH SECURITY_ENFORCED ];
        	ImportStrategie oimportStrategy = new ImportStrategie();
        	oimportStrategy.contentFile = objVersion.VersionData;
        	system.debug('version data' + objVersion.VersionData);
            oimportStrategy.ReadFile();
            system.debug('Read CSV successful');
        	return oimportStrategy.getuploadedStrategie();    
        }
        else
            return null;
        }
        catch(exception e){
            system.debug('Raise exception' + e.getCause() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getTypeName() );
            throw new AuraHandledException(e.getStackTraceString()+ ' ' + e.getMessage() + ' '  + e.getTypeName() );
                    }
    }

    @AuraEnabled
    public static void generateTestData( integer numAcc) {
        
        	ImportStrategie oimportStrategy = new ImportStrategie();
            oimportStrategy.numAccTest = numAcc;
            oimportStrategy.generateTestData();    
        
    }
    @AuraEnabled
    public static void runBatch() {
        OrkBatch FCMB = new OrkBatch();
        Database.executeBatch(FCMB, 1);
    }
    
}