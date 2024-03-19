/*
 * Created by: Endrit Sino	
 * Desc: Classe di test per il trigger dei log e per la classe TraceLog.
 * Testate anche le classe CSVParser e TagHelper
 * Data: 7/10/2014
 */
@isTest
public class TestLogsClassEquipment {
	
    static testmethod void testLogTrigger(){
        test.startTest();
        // crea dei log
        tag__c tag = new tag__C();
                tag.name='isBatchInbActive';
        		tag.ValueBoolean__c = true;        
        insert tag;
        Log__c myLog = new Log__c();
        myLog.Message_In__c = 'Vlere1; vlere2; vlere3;';
        insert myLog;
        test.stopTest();
    }
    
    static testmethod void testTraceLog(){
        test.startTest();
        
        TraceLog.IntegrationLog('Cname', 'Method', 'Error', 'Object', 'ObjectId');
        TraceLog.ErrorLog('Cname', 'Method', 'Error', 'Object', 'ObjectId');
        
        test.stopTest();
    }
    
    static testmethod void testCSVParser(){
        test.startTest();
        String target = '\n first line \r \n second line';
        for(integer i = 0; i<10000; i++)
        	target += '\n this is line ' + i + ' continue \r';
        CSVParser.parseCSV(target);
        
        test.stopTest();
    }
    
    static testmethod void testTagHelper(){
        test.startTest();
        TagHelper.getValue('first', 'second');
        tagHelper.getValueText('first');
        TagHelper.getValue('first', 'second');
        tagHelper.getValueBoolean('random');
        tagHelper.getValueInteger('integer');
        
        test.stopTest();
    }
}