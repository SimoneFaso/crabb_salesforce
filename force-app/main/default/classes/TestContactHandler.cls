/*
 * Created by: Endrit Sino
 * Desc: Classe di test per il handler Contatti
 * data: 7/10/2014
 * Modified to fix English version - replace getRecordTypeInfosByName with getrecordtypeinfosbydevelopername, line no 46, 80, 120
 */

@isTest
public class TestContactHandler{
    
    static testmethod void testTinyMeth(){
        test.startTest();
        ContactHandler istanza = new ContactHandler();
        // test tiny meth
        istanza.bulkBefore();
        istanza.bulkBefore(new List<SObject>());
    
        istanza.bulkAfter();
        istanza.bulkAfter(new List<SObject>());
        istanza.beforeInsert(new List<Contact>());
        istanza.beforeUpdate(new List<Contact>(),new List<Contact>());
        istanza.beforeDelete(new List<Contact> ());
        istanza.afterDelete(new List<Contact> ());
        
        istanza.afterUpdate(new List<Contact>(), new List<Contact>());     
        test.stopTest();
    }
    
    static testmethod void testContactDomicilio(){
        test.startTest();
        List<Contact> tmp = getContactsDomicilio();
        insert tmp;
        
        test.stopTest();
    }
    
    static testmethod void testContactResidenza(){
        test.startTest();
        List<Contact> tmp = getContactsResidenza();
        insert tmp;
        test.stopTest();
    }
    
    static testmethod void testResideAndDomicilio(){
        test.startTest();
        List<Contact> tmp = getContactsResidenza();
        tmp[0].recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DOMICILIO').getRecordTypeId();
        insert tmp;
        test.stopTest();
    }
    
    // metodi ausiliari
    public static List<Contact> getContactsDomicilio(){
        // inserisci un contatto
        Contact con = new Contact();
        con.LastName = 'Sino1';
        Contact con2 = new Contact();
        con2.LastName = 'Sino2';
        Contact con3 = new Contact();
        con3.lastName = 'Sino3';
        
        // crea un account
        Contratto__c contratto = new Contratto__C();
        contratto = TestClassFroDataGenAffidamenti.getContratto();
        insert contratto;
        Account act = new Account();
        act = TestClassFroDataGenAffidamenti.getAccount(contratto.Id);
        Account act1 = new Account();
        act1 = TestClassFroDataGenAffidamenti.getAccount(contratto.Id);
        insert act1;
        insert act;
        
        con.AccountId = act.id;        
        con2.AccountId = act.id;
        con3.AccountId = act1.id;
        
        List<Contact> tmp = new List<Contact>{con, con2, con3};
        integer i = 0;
        for(Contact c: tmp)
        {
            c.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DOMICILIO').getRecordTypeId();
            c.Principale__c = true;
            c.Comune__c = 'Comune';
            c.Indirizzo__c = 'Indi';
            c.Cap__c = 'cap';
            c.Provincia__c = 'llx';
            c.Toponimo__c = 'top';
            c.Civico__c = 'civic';
        }    
        return tmp;
    }
    
    public static List<Contact> getContactsResidenza(){
        // inserisci un contatto
        Contact con = new Contact();
        con.LastName = 'Sino1';
        Contact con2 = new Contact();
        con2.LastName = 'Sino2';
        Contact con3 = new Contact();
        con3.lastName = 'Sino3';
        
        // crea un account
        Contratto__c contratto = new Contratto__C();
        contratto = TestClassFroDataGenAffidamenti.getContratto();
        insert contratto;
        Account act = new Account();
        act = TestClassFroDataGenAffidamenti.getAccount(contratto.Id);
        Account act1 = new Account();
        act1 = TestClassFroDataGenAffidamenti.getAccount(contratto.Id);
        insert act1;
        insert act;
        
        con.AccountId = act.id;        
        con2.AccountId = act.id;
        con3.AccountId = act1.id;
        
        List<Contact> tmp = new List<Contact>{con, con2, con3};
        integer i = 0;
        for(Contact c: tmp)
        {
            c.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('RESIDENZA').getRecordTypeId();
            c.Principale__c = true;
            c.Comune__c = 'Comune';
            c.Indirizzo__c = 'Indi';
            c.Cap__c = 'cap';
            c.Provincia__c = 'llx';
            c.Toponimo__c = 'top';
            c.Civico__c = 'civic';
        }    
        return tmp;
    }
}