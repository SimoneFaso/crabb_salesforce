@isTest
public class TestCoverage_CredManUtility {
    static testMethod void myUnitTest_isPresent() {
		String A = 'uno;due;tre;';
		String B = 'tre';
		CredManUtility CMU = new CredManUtility();
		CMU.isPresent(a, b);
    }
    
     static testMethod void myUnitTest_selectclick() {
		list<String> ListA = new list<String>();
		list<String> ListB = new list<String>();
		map<String, String> MapA = new map<String, String>();
		ListA.add('ABC');
		ListA.add('BCD');
		ListA.add('CDE');
		ListB.add('CBA');
		ListB.add('DCB');
		ListB.add('EDC');
		MapA.put('1', 'ASDAS');
		CredManUtility CMU = new CredManUtility();
		CMU.selectclick(ListA, ListB, MapA);
    }
    
    static testMethod void myUnitTest_selectclick2() {
		list<String> ListA = new list<String>();
		list<String> ListB = new list<String>();
		map<String, String> MapA = new map<String, String>();
		ListA.add('ABC');
		ListA.add('BCD');
		ListA.add('CDE');
		MapA.put('1', 'ASDAS');
		CredManUtility CMU = new CredManUtility();
		CMU.selectclick(ListA, ListB, MapA);
    }
    
    static testMethod void myUnitTest_unselectclick() {
		list<String> ListA = new list<String>();
		list<String> ListB = new list<String>();
		map<String, String> MapA = new map<String, String>();
		ListA.add('ABC');
		ListA.add('BCD');
		ListA.add('CDE');
		ListB.add('CBA');
		ListB.add('DCB');
		ListB.add('EDC');
		MapA.put('1', 'ASDAS');
		CredManUtility CMU = new CredManUtility();
		CMU.unselectclick(ListA, ListB, MapA);
    }
    
    static testMethod void myUnitTest_getunSelectedValues(){
    	list<String> ListA = new list<String>();
    	List<Integer> Daval = new list<Integer>();
    	List<Integer> Aval = new list<Integer>();
    	Date DateInput = Date.today();
    	Daval.add(1);
    	Daval.add(2);
    	Aval.add(3);
    	Aval.add(4);
    	ListA.add('ABC');
		ListA.add('BCD');
		ListA.add('CDE');
		CredManUtility CMU = new CredManUtility();
		CMU.getunSelectedValues(ListA);
		CMU.getSelectedValues(ListA);
		CMU.get_string_query(ListA, 'Test');
		CMU.Build_query(ListA, 'test', 3);
		CMU.get_string_range('test', 4, Daval, Aval, ListA);
		//CMU.selectall('Movimento__c');
		//CMU.selectallShort('Movimento__c');
		//CMU.resto(2, 4);
		//CMU.NumberMax(Aval);
		//CMU.getPicklistValues('Collector__c', 'Stato__c');
		//CMU.FindDoubleValueInInput(ListA);
		//CMU.CreateStringFromDate(DateInput);
		//CMU.DateToString(DateInput);
    }
    
    static testMethod void myUnitTest_getunSelectedValues2(){
    	list<String> ListA = new list<String>();
    	List<Integer> Daval = new list<Integer>();
    	List<Integer> Aval = new list<Integer>();
    	Date DateInput = Date.today();
    	Daval.add(1);
    	Daval.add(2);
    	Aval.add(3);
    	Aval.add(4);
    	ListA.add('ABC');
		ListA.add('BCD');
		ListA.add('CDE');
    	CredManUtility.selectall('Movimento__c');
		CredManUtility.selectallShort('Movimento__c');
		CredManUtility.resto(2, 4);
		CredManUtility.NumberMax(Aval);
		CredManUtility.getPicklistValues('Collector__c', 'Stato__c');
		CredManUtility.FindDoubleValueInInput(ListA);
		CredManUtility.CreateStringFromDate(DateInput);
		CredManUtility.DateToString(DateInput);
    }
    
    
}