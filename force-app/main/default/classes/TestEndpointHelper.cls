@isTest
public class TestEndpointHelper {
    static testmethod void unitTest(){
        test.startTest();
        EndpointHelper.getToken('name');
        
        delete([Select id From Endpoints__c Where name = 'name']);
        EndpointHelper.setToken('name', 'token');
        
        delete([Select id From Endpoints__c Where name = 'name']);
        EndpointHelper.setToken('name', 'token', 2);
        
        delete([Select id From Endpoints__c Where name = 'name']);
        EndpointHelper.endpoint('name');
        
        delete([Select id From Endpoints__c Where name = 'name']);
        EndpointHelper.endpoint('name');
        
        EndpointHelper.isTokenToRefresh('name');
        delete([Select id From Endpoints__c Where name = 'name']);
        EndpointHelper.isTokenToRefresh('name');
        
        test.stopTest();
    }
}