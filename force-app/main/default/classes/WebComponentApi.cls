/**
 * Created by User on 01/07/2021.
 */

public with sharing class WebComponentApi {

    @AuraEnabled(Cacheable=true)
    public static WebComponentOutput invokeApexMethodWithCache(Map<String,Object> params , String apexClass){
        return invokeApexMethod( params , apexClass );
    }

    @AuraEnabled
    public static WebComponentOutput invokeApexMethodWithNoCache( Map<String,Object> params , String apexClass ){
        return invokeApexMethod(params , apexClass);
    }

    public static WebComponentOutput invokeApexMethod( Map<String,Object> params , String apexClass ){
        WebComponentOutput res = new WebComponentOutput();
        try {
            IWebComponentCtrl apiClass = (IWebComponentCtrl) Type.forName(apexClass);
            res.resultdata = apiClass.callApexMethod(params);
        }catch( Exception ex ){
            res.errorMessage = ex.getStackTraceString();
        }
        return res;
    }

    public class WebComponentOutput{
        @AuraEnabled
        public Object resultdata {get;set;}
        @AuraEnabled
        public String errorMessage {get;set;}
    }
}