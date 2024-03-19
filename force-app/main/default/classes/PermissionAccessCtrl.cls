public with sharing class PermissionAccessCtrl {    
    private String retURL;
    private SObjectType tipo;
    private SObject actualObj;
    private String prefix;

    public PermissionAccessCtrl(ApexPages.StandardController controller) {
        this();
        actualObj = controller.getRecord();
        tipo = ActualObj.getSObjectType();
        prefix = (tipo==null)?'':tipo.getDescribe().getKeyPrefix();               
    }
    
    public PermissionAccessCtrl(){
        retURL = '/'+prefix;//String.isNotBlank(ApexPages.currentPage().getParameters().get('retURL'))?ApexPages.currentPage().getParameters().get('retURL'):'/';        
    }   
    
    public PageReference ritorna(){
        PageReference result = new PageReference(retURL);
        result.setRedirect(true);
        return result;
    }
}