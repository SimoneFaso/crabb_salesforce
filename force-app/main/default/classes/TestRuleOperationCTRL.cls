/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestRuleOperationCTRL.cls
Description:     Test Class for code coverage of RuleOperationCTRL.cls


Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
29-Sep-2014  0.1      E. Sino                         First Version
25-Aug-2021  0.2      C. Sanna                        Modified getRecordTypeInfosByDeveloperName()
----------------------------------------------------------------------------------------------------------------------*/

@isTest
public class TestRuleOperationCTRL {
    // un metodo per testare getStr()
    public static testmethod void testGetStr(){
        
        // neccessari due scenari: Un operazione new, e un altro trane edi/delete
        // crea la pagina con i parametri di URL
        PageReference PageRef = new PageReference('/apex/ruleOperation');
        Test.setCurrentPage(PageRef);
        
        // 1. Nuova regola 
        ApexPages.currentPage().getParameters().put('operation', 'new');
        
        // crea una istanza della classe che testiamo
        RuleOperationCTRL roCtrl = new RuleOperationCTRL();
        
        Strategia__c tempStr = new Strategia__c();
        tempStr = roCtrl.getStr();
                
        // 2. Edit/Delete una regola esistente 
        ApexPages.currentPage().getParameters().put('operation', 'edit');
        
        // adesso dobbiamo creare anche una regola per alleagarli un idRc alla pagina
        Rule_control__c myRule = new Rule_control__c();
          myRule.Name = 'MyRuleName';
          myRule.Api_field_name__c = 'Api Field';
          myRule.Api_object_name__c = 'Api object';
          myRule.Condition__c = '>';
          myRule.Strategia_api_field_name__c = 'Strategia Api Field';
          myRule.Note__c = 'Nota';
          myRule.Rule_Name__C = 'Rule Name Human Readable';
        insert myRule;
        
        // il id del record che si modificera
        ApexPages.currentPage().getParameters().put('idRc', myRule.id);
        
        // crea una istanza della classe che testiamo
        RuleOperationCTRL roCtrl1 = new RuleOperationCTRL();
        
        Strategia__c tempStr1 = new Strategia__c();
        tempStr1 = roCtrl1.getStr();
        
        // 2.1 Caso con un idrc = null
        ApexPages.currentPage().getParameters().put('idRc', null);
        
        // crea una istanza della classe che testiamo
        RuleOperationCTRL roCtrl2 = new RuleOperationCTRL();
        Strategia__c tempStr2 = new Strategia__c();
        tempStr2 = roCtrl2.getStr();
    }
    
    // metodo test per getStrFromRule()
    public static testmethod void testGetStrFromRule(){

        // crea una regola
        Rule_control__c myRule = new Rule_control__c();
          myRule.Name = 'MyRuleName';
          myRule.Api_field_name__c = 'Api Field';
          myRule.Api_object_name__c = 'Api object';
          myRule.Condition__c = '>';
          myRule.Strategia_api_field_name__c = 'Strategia Api Field';
          myRule.Note__c = 'Nota';
          myRule.Rule_Name__C = 'Rule Name Human Readable';
        insert myRule;
        
        Strategia__c tempStr = new Strategia__c();
        tempStr = RuleOperationCTRL.getStrFromRule(myRule);
    }
    
    // metodo per executeOperation
    public static testmethod void testExecOperation(){
        test.startTest();
        // set the page with URL parameters
        PageReference PageRef = new PageReference('/apex/ruleOperation');
        Test.setCurrentPage(PageRef);
        
        // 1. Caso di creazione Regola
        ApexPages.currentPage().getParameters().put('operation', 'new');
        
        // crea una istanza della classe, che poi legge anche i parametri nel URL        
        RuleOperationCTRL roCtrl = new RuleOperationCTRL();

        // il container di tipo Strategia__c, per leggere i campi
        roCtrl.str = new Strategia__c();
            roCtrl.str.RC_Api_Field_Name__c = 'Api Test';
            roCtrl.str.RC_Api_Object_Name__c = 'Api object';
            roCtrl.str.RC_Condition__c = '=';
            roCtrl.str.RC_Note__c = 'Note asdas';
            roCtrl.str.RC_Rule_Name__c = 'Rule name';
            roCtrl.str.RC_Strategia_Api_Field_Name__c = 'str api field';
        
        // esegui il inserimento
        roCtrl.executeOperation(); 
        
        // 1.1 Caso Creazione di una Duplicata
        // crea una regola con campi identici
        Rule_control__c myRule = new Rule_control__c();
          myRule.Name = 'MyRuleName';
          myRule.Api_field_name__c = 'Api Test';
          myRule.Api_object_name__c = 'Api object';
          myRule.Condition__c = '=';
          myRule.Strategia_api_field_name__c = 'str api field';
          myRule.Note__c = 'Nota';
          myRule.Rule_Name__C = 'Rule Name Human Readable';
        insert myRule;
        
        // esegui il inserimento
        roCtrl.executeOperation();
        
        // 2. Caso di edit
        // crea una regola per edit
        Rule_control__c ruleToEdit = new Rule_control__c();
          ruleToEdit.Name = 'MyRuleNameTO edit';
          ruleToEdit.Api_field_name__c = 'Api Test54545';
          ruleToEdit.Api_object_name__c = 'Api object45454';
          ruleToEdit.Condition__c = '=';
          ruleToEdit.Strategia_api_field_name__c = 'str api field45454';
          ruleToEdit.Note__c = 'Nota';
          ruleToEdit.Rule_Name__C = 'Rule Name Human Readable';
        insert ruleToEdit;
        
        // mettiamo i parametri adeguati nel URL
        ApexPages.currentPage().getParameters().put('operation', 'edit');
        ApexPages.currentPage().getParameters().put('idRc', ruleToEdit.id);
        
        // crea una istanza della classe, che poi legge anche i parametri nel URL        
        RuleOperationCTRL roCtrl2 = new RuleOperationCTRL();
        
        // compiliamo anche i campi del container, di tipo Strategia, che passera i valori alla regola
        roCtrl2.str = new Strategia__c();
            roCtrl2.str.RC_Api_Field_Name__c = 'Api Test';
            roCtrl2.str.RC_Api_Object_Name__c = 'Api object';
            roCtrl2.str.RC_Condition__c = '=';
            roCtrl2.str.RC_Note__c = 'Note asdas';
            roCtrl2.str.RC_Rule_Name__c = 'Rule name';
            roCtrl2.str.RC_Strategia_Api_Field_Name__c = 'str api field';
        
        // inizia anche il oggetto rcToEdit, prima di eseguire l'operazione
        Strategia__c strTemp = new Strategia__c();
        strTemp = roCtrl2.getStr();
        
        roCtrl2.executeOperation();
        
        // 3. Caso delete (Quando é contenuta da una testat e quando non é)
        
        // crea una regola da cancellare
        Rule_control__c ruleToDelete = new Rule_control__c();
          ruleToDelete.Name = 'MyRuleNameTO edit';
          ruleToDelete.Api_field_name__c = 'Api Test54545';
          ruleToDelete.Api_object_name__c = 'Api object45454';
          ruleToDelete.Condition__c = '=';
          ruleToDelete.Strategia_api_field_name__c = 'str api field45454';
          ruleToDelete.Note__c = 'Nota';
          ruleToDelete.Rule_Name__C = 'Rule Name Human Readable';
        insert ruleToDelete;
        
        // mettiamo i parametri adeguati nel URL
        ApexPages.currentPage().getParameters().put('operation', 'delete');
        ApexPages.currentPage().getParameters().put('idRc', ruleToDelete.id);
        
        // crea una istanza della classe, che poi legge anche i parametri nel URL        
        RuleOperationCTRL roCtrl3 = new RuleOperationCTRL();
        
        // 3.1 Cancella una regola che non la contiene nessuna testata
        Strategia__c strTemp3 = new Strategia__c();
        strTemp3 = roCtrl3.getStr();
        roCtrl3.executeOperation();
        
        // 3.2 Crea una Testata che contiene questa regola
        Strategia__c miaTestata = new Strategia__c();
        Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName();
        //Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Strategia__c.getRecordTypeInfosByName();
        miaTestata.recordTypeID = ctRecordTypes.get('Testata').getRecordTypeID();
        miaTestata.Nome__c = 'Nome Testata';
        miaTestata.Descrizione__c = 'Un test';
        miaTestata.Activation_roles__c = 'MyRuleNameTO edit';
        miaTEstata.stato__c = 'Attiva';
        insert miaTestata;
        
        Rule_Control__c rule = new Rule_control__C();
        rule.Name = 'RUleName';
        rule.Rule_name__c = 'Test';
        rule.Strategia_api_field_name__c = 'Rule';
        insert rule;
        miaTestata.Activation_roles__c += ',' + rule.Name;
        update miaTEstata;
        ApexPages.currentPage().getParameters().put('idRc', rule.id);
        
        // prova cancellare questa regola che e contenuta da miaTestata
        roCtrl3 = new RuleOperationCTRL();
        roCtrl3.executeOperation();
        test.stopTest();       
    }
}