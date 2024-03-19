@isTest
public class TestSaldiHelper {
	
    static testmethod void testGetValueMese(){
        test.startTest();
        	SaldiHelper.getValueMese('Mese');
        test.stopTest();
    }
    
    static testmethod void testGetValue(){
        test.startTest();
        	SaldiHelper.getValue('s', 'o');
        test.stopTest();
    }
}