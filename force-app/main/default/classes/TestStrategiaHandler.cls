@isTest
public class TestStrategiaHandler {
	
    static testmethod void testTinyMeths(){
        Strategiahandler sh = new StrategiaHandler();
        
        test.startTest();
        List<SObject> so = new List<SObject>();
        sh.afterDelete(so);
        sh.afterInsert(so);
        sh.afterUpdate(so, so);
        sh.andFinally();
        sh.beforeDelete(so);
        sh.afterDelete(so);
        sh.beforeInsert(so);
        sh.beforeUpdate(so, so);
        sh.bulkAfter();
        sh.bulkAfter(so);
        sh.bulkBefore();
        sh.bulkBefore(so);
        
        test.stopTest();
    }
}