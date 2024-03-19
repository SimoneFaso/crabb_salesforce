/*
 * Created by: Endrit Sino
 * Desc: Classe di test, per il controller del gestione dei file da scaricare per i flussi
 * Data: 6/10/2014
 */
@isTest
public class TestFlussiColDownloadZipCTRL {
	
    static testmethod void testPrimaryMeth(){
        
        test.startTest();
        	// 1) crea flusso
        	User lUs = new User();
            lUs = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');
                    
            // Chiedi collector
            Collector__c col = TestClassFroDataGenAffidamenti.getCollector(lUs.id); 
            col.Tipo_Collector__c = 'ADR';
        	insert col;	
        
        	flussi_collector__c flussi = new flussi_collector__c();
        	flussi.Collector__c = col.id;	
        	
        	insert flussi;
        		
        	// 2) allega un attachment
            Blob b = Blob.valueOf('Test Data');
            Attachment at = new Attachment();  
            at.ParentId = flussi.id;  
            at.Name = 'Test Attachment for Parent';  
            at.Body = b;
        	//Attachment at = createAttach(flussi.id);
        	insert at;
        
        	// 3) istanzia il controller
            ApexPages.StandardController cont = new ApexPages.StandardController(flussi);
        	FlussiColDownloadZipCTRL istanza = new FlussiColDownloadZipCTRL(cont);
        	
        	// 4) scarica il attachment
        	Test.setCurrentPageReference(new PageReference('Page.testZipFIles'));
        	System.currentPageReference().getParameters().put('attachId', at.id);
        
        	istanza.AggiornaElementoLista();
        	System.assertNotEquals(null , istanza.fc.Track_Downloaded_File__c);
        	
        	//istanza = createControllerInstance(flussi);
        	// ) istanza controller con fc Nullo
        	
        test.stopTest();
    }
    
    // METODI AUSILIARI
    /*public static Attachment createAttach(id ParentId){
        Blob b = Blob.valueOf('Test Data');  
      
        Attachment attach = new Attachment();  
        attach.ParentId = parentId;  
        attach.Name = 'Test Attachment for Parent';  
        attach.Body = b; 
        
        return attach;
    }*/
    /*
    public static FlussiColDownloadZipCTRL createControllerInstance(Flussi_collector__c flusso){
        ApexPages.StandardController cont = new ApexPages.StandardController(flusso);
        FlussiColDownloadZipCTRL istanza = new FlussiColDownloadZipCTRL(cont);
        return istanza;
    }*/
}