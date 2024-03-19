/*
* CreatedBy: KMeta
* CreatedDate: 04/August/2014
* Description: Contine la classe di test per la classe ErrorClass
*/

@isTest
public class TestUtils{
    
    static testMethod void Test1(){
        string gmn= Utils.getSOBJECTFieldsForQuery('Log__c');
    }
    
    static testMethod void Test2(){
        string myString=null;
        try{
            myString.toLowerCase();
            
        }
        catch(Exception e){
            string gmn= Utils.getExceptionInString(e);
        }
    }
    
    // test tiny methods
    static testMethod void utils_TinyMeth(){
        test.startTest();
        System.assertEquals(2, utils.sliptString('nome, cognome', ',').size());
        System.assertEquals(2, utils.sliptToListString('nome, cognome', ',').size());
        
        String str = utils.inStrings(new List<String>{'str1', 'str2'});
        test.stopTest();
    }
    
    static testMethod void utils_getStepsAffidamento(){
        test.startTest();
        // crea strategie
        Strategia__c testata = TestClassFroDataGenAffidamenti.getStrategia('Testata');
        testata.Stato__c = 'Attiva';
        insert testata;
        Strategia__c nonTestata = TestClassFroDataGenAffidamenti.getStrategia('Step');
        nontestata.Nome__c = 'Nome NNonTest';
        nontestata.Testata__c = testata.id;
        nontestata.E_da_affidare__c = true;
        nonTestata.Stato__c = 'Attiva';
        insert nonTestata;
        testata.Stato__c = 'Attiva';
        update testata;
        utils.getStepsDaAffidamento();
        
        test.stopTest();
    }

    static testMethod void utils_getLimits(){
        string limits;
        test.startTest();
            limits = Utils.getLimits();
        test.stopTest();
    }

    static testMethod void utils_sliptString(){
        string strings='aa,bb';
        set<string> setStrings =new set<String>();
        test.startTest();
            setStrings = Utils.sliptString(strings,',');
        test.stopTest();
        System.assertEquals(2,setStrings.size());
    }

    static testMethod void utils_joinStrings_list(){
        string strings;
        List<string> setStrings =new List<String>();
        setStrings.add('aa');
        setStrings.add('bb');
        
        test.startTest();
            strings = Utils.joinStrings(setStrings,',');
        test.stopTest();
        System.assertEquals('aa,bb',strings);
    }

    static testMethod void utils_joinStrings_set(){
        string strings;
        set<string> setStrings =new set<String>();
        setStrings.add('aa');
        setStrings.add('bb');
        
        test.startTest();
            strings = Utils.joinStrings(setStrings,',');
        test.stopTest();
    }

    static testMethod void utils_nullOrEmpty_string_true(){
        string strings;     
        boolean bool;
        test.startTest();
            bool = Utils.nullOrEmpty(strings);
        test.stopTest();
        System.assertEquals(true,bool);
    }

    static testMethod void utils_nullOrEmpty_string_false(){
        string strings='xx';        
        boolean bool;
        test.startTest();
            bool = Utils.nullOrEmpty(strings);
        test.stopTest();
        System.assertEquals(false,bool);
    }

    static testMethod void utils_nullOrEmpty_List_false(){
        List<string> strings=new list<string>();
        strings.add('xx');
        
        boolean bool;
        test.startTest();
            bool = Utils.nullOrEmpty(strings);
        test.stopTest();
        System.assertEquals(false,bool);
    }

    static testMethod void utils_nullOrEmpty_List_true(){
        List<string> strings=new list<string>();
        boolean bool;
        test.startTest();
            bool = Utils.nullOrEmpty(strings);
        test.stopTest();
        System.assertEquals(true,bool);
    }   

    static testMethod void permissionCRUDFLS(){
        Test.startTest();
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            SecuritySettings__c sc = new SecuritySettings__c();
            sc.isSecure__c = false;
            insert sc;
            Utils.checkObjPermission('Movimento__c');
            Utils.checkFLSPermission('Movimento__c', 'Account__c');
            Utils.cebCheckObjPermission('Movimento__c', gd);
            Utils.cebCheckFLSPermission('Movimento__c', 'Account__c', gd);
            sc.isSecure__c = true;
            update sc;
            Utils.checkObjPermission('Movimento__c');
            Utils.checkFLSPermission('Movimento__c', 'Account__c');
            Utils.cebCheckObjPermission('Movimento__c', gd);
            Utils.cebCheckFLSPermission('Movimento__c', 'Account__c', gd);
        Test.stopTest();
    }

    static testMethod  void generateRandomStringTest() {
        Test.startTest();
            Utils.generateRandomString(10);
        Test.stopTest();
    }

    static testMethod  void sortTaskActivitiesTest(){
        Test.startTest();
            List<SObject> listSO = new List<SObject>();
            Task t = new Task();
            listSO.add(t);
            Task t2 = new Task();
            listSO.add(t2);
            CRABB_DEV__ActivityExtended__c a = new CRABB_DEV__ActivityExtended__c();
            listSO.add(a);
            List<SObject> retList = Utils.sortTaskActivities(listSO);
        Test.stopTest();
    }

    static testMethod  void getStatusListTest(){
        Test.startTest();
            Utils.getStatusList('DeveloperName');
        Test.stopTest();
    }

    static testMethod  void getPraticaAndTasksWithActivityExtendedTest() {
        Test.startTest();
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            List<SObject> listSO = new List<SObject>();
            Task t = new Task();
            listSO.add(t);
            Task t2 = new Task();
            listSO.add(t2);

            insert listSO;

            Utils.getPraticaWithActivityExtended(listSO);
            Utils.getTaskWithActivityExtended(listSO);
            Utils.cebGetTaskWithActivityExtended(listSO, gd);
        Test.stopTest();
    }

    static testMethod void checkFLSPermissionTest() {
        Test.startTest();
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Utils.checkFLSPermission('Movimento__c', 'CRABB_DEV__Importo__c');
            Utils.cebCheckFLSPermission('Movimento__c', 'CRABB_DEV__Importo__c', gd);
        Test.stopTest();
    }

    static testMethod void getSOBJECTFieldsForQueryTest() {
        Test.startTest();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Utils.getSOBJECTFieldsForQuery('Movimento__c');
        Utils.cebGetSOBJECTFieldsForQuery('Movimento__c', gd);
        Test.stopTest();
    }

    static testMethod void checkisAutoNumberTest() {
        Test.startTest();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Utils.checkisAutoNumber('Movimento__c', 'CRABB_DEV__Importo__c');
        Utils.cebcheckisAutoNumber('Movimento__c', 'CRABB_DEV__Importo__c', gd);
        Test.stopTest();
    }

    static testMethod void checkisCalculatedTest() {
        Test.startTest();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Utils.checkisCalculated('Movimento__c', 'CRABB_DEV__Importo__c');
        Utils.cebcheckisCalculated('Movimento__c', 'CRABB_DEV__Importo__c', gd);
        Test.stopTest();
    }

    static testMethod void CheckCondition_lessOrEqual(){
        test.startTest();
                boolean bool;
                string condition='<=';
                date a,b; a=system.today(); b=a.adddays(1);
                datetime at,bt; at=system.now(); bt=at.adddays(1);
                Decimal ad,bd; ad=1.45; bd=1.68;
                Double adD,bdD; adD=1.45; bdD=1.68;
                integer ai,bi; ai=1; bi=2;
                String sa='1',sb='2';


                bool= Utils.checkConditionFieldValue(a,b,condition, 'date');
                bool= Utils.checkConditionFieldValue(at,bt,condition, 'datetime');
                bool= Utils.checkConditionFieldValue(ad,bd,condition, 'decimal');
                bool= Utils.checkConditionFieldValue(sa,sb,condition, 'string');
                bool= Utils.checkConditionFieldValue(adD,bdD,condition, 'decimal');
                bool= Utils.checkConditionFieldValue(ai,bi,condition, 'decimal');

                condition='<';
                bool= Utils.checkConditionFieldValue(a,b,condition, 'date');
                bool= Utils.checkConditionFieldValue(at,bt,condition, 'datetime');
                bool= Utils.checkConditionFieldValue(ad,bd,condition, 'decimal');
                bool= Utils.checkConditionFieldValue(sa,sb,condition, 'string');
                bool= Utils.checkConditionFieldValue(adD,bdD,condition, 'decimal');
                bool= Utils.checkConditionFieldValue(ai,bi,condition, 'decimal');

                condition='>';
                bool= Utils.checkConditionFieldValue(a,b,condition, 'date');
                bool= Utils.checkConditionFieldValue(at,bt,condition, 'datetime');
                bool= Utils.checkConditionFieldValue(ad,bd,condition, 'decimal');
                bool= Utils.checkConditionFieldValue(sa,sb,condition, 'string');
                bool= Utils.checkConditionFieldValue(adD,bdD,condition, 'decimal');
                bool= Utils.checkConditionFieldValue(ai,bi,condition, 'decimal');

                condition='>=';
                bool= Utils.checkConditionFieldValue(a,b,condition, 'date');
                bool= Utils.checkConditionFieldValue(at,bt,condition, 'datetime');
                bool= Utils.checkConditionFieldValue(ad,bd,condition, 'decimal');
                bool= Utils.checkConditionFieldValue(sa,sb,condition, 'string');
                bool= Utils.checkConditionFieldValue(adD,bdD,condition, 'decimal');
                bool= Utils.checkConditionFieldValue(ai,bi,condition, 'decimal');
        test.stopTest();
    }
}