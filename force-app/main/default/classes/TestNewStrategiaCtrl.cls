/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestnewStrategiaCtrl.cls
Description:     Test Class for code coverage of newStrategiaCTRL.cls


Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1      E. Sino                         First Version
25-Aug-2021  0.2      Claudio Sanna                   Modified for coverage and getRecordTypeInfosByDeveloperName
----------------------------------------------------------------------------------------------------------------------*/

@isTest
class TestNewStrategiaCtrl{

  /*
  * Controlla i trigger crate, delete, undelete e update, tra i adequati testcase.
  *
  */
  public static testmethod void testWorstTriggerCases(){
      
      // load the controller and proceed with testing
      newStrategiaCTRL nsc = new newStrategiaCTRL ();
      // il recordTYpe
      Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName();

      // 1. Test la creazione di un solo tipo di oggetto su db
      List<Strategia__c> mieiRecordDaCreare = new List<Strategia__c>();
      
      // crea prima testata e aggiungi nella lista
      Strategia__c miaTestata = new Strategia__c(Descrizione__c = 'Desc');
      miaTestata.recordTypeId = ctRecordTypes.get('Testata').getRecordTypeID();
      mieiRecordDaCreare.add(miaTestata);
      
      // crea un record nonTestata e aggiungi nella lista
      Strategia__c miaCDI = new Strategia__c(Descrizione__c = 'DescCDI');
      miaCDI.recordTypeId = ctRecordTypes.get('Condizioni_di_Ingresso').getRecordTypeID();
      mieiRecordDaCreare.add(miaCDI);
      
      // inserisci in db tutti i dati;
      insert mieiRecordDaCreare;
  
      // 2. Crea un numero considerabile di record, di tipo Testata. I.e. 200+.
      List<Strategia__c> mieiRecordDaCreare2 = new List<Strategia__c>();
      
      // crea 200+ record di tipo testata
      for (integer i = 0; i<100; i++)
      {
          String mioDescrizione = 'Testata Numero' + i;
          Strategia__c mieTestate2 = new Strategia__c(Descrizione__c = mioDescrizione);
          mieTestate2.recordTypeId = ctRecordTypes.get('Testata').getRecordTypeID();
          mieiRecordDaCreare2.add(mieTestate2); 
      }
      
      // inserisci 200+ record Testata
      insert mieiRecordDaCreare2;
      
      // una lista per i record di tipo nonTestata
      List<Strategia__c> mieiRecordDaCreare2_1 = new List<Strategia__c>();
      
      // crea 200 record di tipo testata
      for (integer i = 0; i<239; i++)
      {
          String mioDescrizione2 = 'CDINumero' + i;
          Strategia__c mieCDI= new Strategia__c(Descrizione__c = mioDescrizione2);
          mieCDI.recordTypeId = ctRecordTypes.get('Condizioni_di_Ingresso').getRecordTypeID();
          mieiRecordDaCreare2_1.add(mieCDI);
      }
      
      // inserisci 200 record Testata
      insert mieiRecordDaCreare2_1;
      
      // 3. Test la modifica di un o 200 record di tipo Testata e non Testat
      for(Strategia__c strTemp : mieiRecordDaCreare2){
          strTemp.Descrizione__c = 'When I met you in the summer!';
          }
      // Prova a mod questi record
      update mieiRecordDaCreare2;
      
      // update di record non Testata
      for(Strategia__c strTemp1 : mieiRecordDaCreare2_1){
          strTemp1.Descrizione__c = 'When I met you in the summer!';
          }
      update mieiRecordDaCreare2_1;   
      
      // 4. prova delete  
      delete mieiRecordDaCreare2;
      delete mieiRecordDaCreare2_1;
      
      // 5. prova undelete
      undelete mieiRecordDaCreare2;
      undelete mieiRecordDaCreare2_1;
  }
  
  public static testmethod void testCreazioneStr(){
      
      // create a new page reference, set it as the current page, 
      // and use the ApexPages.currentPage() method to put the values
      PageReference PageRef = new PageReference('/apex/newStrategiaDataInput');
      Test.setCurrentPage(PageRef);
      
      // caso del creazione testata
      ApexPages.currentPage().getParameters().put('action', 'Crea');
      ApexPages.currentPage().getParameters().put('type', 'STR');
      
      // load the controller and proceed with testing
      newStrategiaCTRL nsc = new newStrategiaCTRL ();
      
      // proviamo a creare una testata
      Strategia__c str = new Strategia__c();
      
      str = nsc.getStrategia();
      
  }
  
  public static testmethod void testModificaStrategia(){
      
      // load the controller and proceed with testing
      newStrategiaCTRL nsc = new newStrategiaCTRL ();
      
      Strategia__c str = new Strategia__c();
      
      // allora modificiamo una testata giá esistente 
      // (il recordId, sara il id della strategia esistente)
      // caso del modifica testata
      // create a new page reference, set it as the current page, 
      // and use the ApexPages.currentPage() method to put the values
      PageReference PageRef = new PageReference('/apex/newStrategiaDataInput');
      Test.setCurrentPage(PageRef);

      ApexPages.currentPage().getParameters().put('action', 'modifica');
      ApexPages.currentPage().getParameters().put('type', 'STR');
      ApexPages.currentPage().getParameters().put('recordId', str.Id);
      ApexPages.currentPage().getParameters().put('idTestata', str.Id);   
      
      // set Activation_roles__c in un valore random
      str.Activation_roles__c = 'regola 1, regola 2';
      
      // chiediamo al db la strategia che sta per essere modificata
      str = nsc.getStrategia();
      nsc.save();
  }
  
  //test dei metodi correlati con i parametri di URL
  public static testmethod void testMetodiURL(){
      
      // crea un caso hipoteticó dove si modifcera una str
      // load the controller and proceed with testing
      newStrategiaCTRL nsc = new newStrategiaCTRL ();
      
      // crea una testata e fissa il nome
      Strategia__c str = new Strategia__c();
      
      // controlla metodo isTestataValid()
      nsc.idTestataValid(str.id); 
      
      // allora modificiamo una testata giá esistente 
      // (il recordId, sara il id della strategia esistente)
      // caso del modifica testata
      // create a new page reference, set it as the current page, 
      // and use the ApexPages.currentPage() method to put the values
      PageReference PageRef = new PageReference('/apex/newStrategiaDataInput');
      Test.setCurrentPage(PageRef);

      ApexPages.currentPage().getParameters().put('action', 'modifica');
      ApexPages.currentPage().getParameters().put('type', 'STR');
      ApexPages.currentPage().getParameters().put('recordId', str.Id);
      ApexPages.currentPage().getParameters().put('idTestata', str.Id);
      
      // controlla metodo controlla metodo myTestataStr()
      String myStrName = nsc.getMyTestataStr();
  }
  
  // Test the se la wrapList si riempie con dati
  public static testmethod void testCompilaRegole(){
      
      // 1. Crea la pgina test
      // create a new page reference, set it as the current page, 
      // and use the ApexPages.currentPage() method to put the values
      PageReference PageRef = new PageReference('/apex/newStrategiaRules');
      Test.setCurrentPage(PageRef);
      
      // load the controller and proceed with testing
      newStrategiaCTRL nsc = new newStrategiaCTRL ();
      
      // 2. Crea delle regole per scopi di test
      Rule_Control__c rule1 = new Rule_Control__c();
      Rule_Control__c rule2 = new Rule_Control__c();
      
          rule1.Name = 'Rule nr. 1';
          rule1.Rule_Name__c = 'R1';
          rule1.Strategia_api_field_name__c = 'Min_Scaduto__c';
          
          rule2.Rule_Name__c = 'R2';
          rule2.Name = 'Rule nr. 2';
          rule2.Strategia_api_field_name__c = 'Max_Scaduto__c';
      
      insert rule1;
      insert rule2;
      
      // 3. Crea una Strategia e metti i parametri del URL secondo il caso
      // e anche collega le regole con la strategia
      Strategia__c str = new Strategia__c();
      str.Activation_roles__c = rule1.Name + rule2.Name;
      insert str;
      
      ApexPages.currentPage().getParameters().put('action', 'Crea');
      ApexPages.currentPage().getParameters().put('type', 'CDI');
      ApexPages.currentPage().getParameters().put('recordId', str.Id);
      ApexPages.currentPage().getParameters().put('idTestata', str.Id);     
      
      // 4.1 Compila le regole per il caso di creazione di una strategia
      nsc.compilaWrapList(); 
      
      // 4.2 Test il metodo quando il type nel URL, e null
      ApexPages.currentPage().getParameters().put('type', 'null');
      nsc.CompilaWrapList();
      
      // 4.3 Test quando stiamo per compilare le regole quando 
      // abbiamo che fare con un oggetto non testata, CDI, per esempio
      ApexPages.currentPage().getParameters().put('type', 'CDI');
      nsc.CompilaWrapList();
  }
  
  // test il caso quando si compilano le regole per una modifica
  public static testmethod void testCompilaRuleModifica(){
      
      // create a new page reference, set it as the current page, 
      // and use the ApexPages.currentPage() method to put the values
      PageReference PageRef = new PageReference('/apex/newStrategiaDataInput');
      Test.setCurrentPage(PageRef);
      
      // load the controller and proceed with testing
      newStrategiaCTRL nsc = new newStrategiaCTRL ();
      
      // Crea delle regole per scopi di test
      Rule_Control__c rule1 = new Rule_Control__c();
      Rule_Control__c rule2 = new Rule_Control__c();
      
          rule1.Name = 'Rule nr. 1';
          rule1.Rule_Name__c = 'R1';
          rule1.Strategia_api_field_name__c = 'Min_Scaduto__c';
          
          rule2.Rule_Name__c = 'R2';
          rule2.Name = 'Rule nr. 2';
          rule2.Strategia_api_field_name__c = 'Max_Scaduto__c';
      
      insert rule1;
      insert rule2;
      
      // Crea una Strategia e metti i parametri del URL secondo il caso
      // e anche collega le regole con la strategia
      Strategia__c str = new Strategia__c();
      str.Activation_roles__c = rule1.Name + rule2.Name;
      insert str;
      
      // 4.4 Non ci sono delle regole, e stiamo modificando una testata
      ApexPages.currentPage().getParameters().put('action', 'Modifica');
      ApexPages.currentPage().getParameters().put('type', 'STR');
      ApexPages.currentPage().getParameters().put('recordId', str.Id);
      ApexPages.currentPage().getParameters().put('idTestata', str.Id);     
      
      nsc.compilaWrapList();
  }
  
  // controlla metodi getMyTestata() e getMytestataId()
  public static testmethod void tesGetMyTestataMethods(){
      
      // le instanze neccessarie
      newStrategiaCTRL nsc = new newStrategiaCTRL();
      Strategia__c str = new Strategia__c();
      
      // accedi la pagina imaginaria
      // create a new page reference, set it as the current page, 
      // and use the ApexPages.currentPage() method to put the values
      PageReference PageRef = new PageReference('/apex/newStrategiaDataInput');
      Test.setCurrentPage(PageRef);
      
      ApexPages.currentPage().getParameters().put('action', 'modifica');
      ApexPages.currentPage().getParameters().put('type', 'STR');
      ApexPages.currentPage().getParameters().put('recordId', str.Id);
      ApexPages.currentPage().getParameters().put('idTestata', 'xcxx');
      
      // caso dell catch, nel metodo getMytestataId()
      nsc.getMytestataId();
  }
  
  public static testmethod void testSimpleMethods(){
  
      newStrategiaCTRL nsc = new newStrategiaCTRL ();
      nsc.getfield();
      nsc.getMieRegoleStep3();
      nsc.getAction();
      nsc.getRecordId();
      nsc.gettype();
      nsc.getMytype();
      nsc.getcRuleSelected();
      nsc.getError();
      nsc.getNoRuleSelected();
      nsc.setNoRuleSelected();
      system.assertEquals(true,nsc.noRuleSelected);
      nsc.step1();
      nsc.step2();
      system.assertEquals(false,nsc.NoRuleSelected );
      nsc.step4();
      nsc.getMieRegoleStep3();
      boolean var = nsc.getflagRegole();
      String myPrevRules = nsc.getMyPrevSelRules();
      nsc.setmyPrevSelRules('MyRule');
      myPrevRules = nsc.getmySessionRules();
      nsc.setmySessionRules('AnotherRule');
    }
    
    public static testmethod void testisTypeValid() {
    
        newStrategiaCTRL nsc = new newStrategiaCTRL ();
        
        system.assertEquals(false,nsc.isTypeValid() );
        nsc.type= 'STR';
        nsc.isTypeValid() ;
    }
    
   
    public static testmethod void testidTestataValid( ) {
       
       newStrategiaCTRL nsc = new newStrategiaCTRL ();
       
       Strategia__c str1 = new Strategia__c();
       str1.Nome__c ='test';
       str1.Stato__c = 'bozza';
       str1.Activation_roles__c ='r2,r3';
      
       insert(str1);
       nsc.idTestataValid(str1.id);
     }
    
    /*
    * 4 metodi per testare  
    * il salvatagio delle diversi tipi 
    * tipi di strategia
    */
    public static testmethod void testsaveStrCdi(){
         
         // create a new page reference, set it as the current page, 
         // and use the ApexPages.currentPage() method to put the values
         PageReference PageRef = new PageReference('/apex/newStrategiaDataInput');
         Test.setCurrentPage(PageRef);
      
         // caso del creazione testata
         ApexPages.currentPage().getParameters().put('action', 'Crea');
         ApexPages.currentPage().getParameters().put('type', 'CDI');
         newStrategiaCTRL nsc = new newStrategiaCTRL ();
         
         // inizia la strategia
         Strategia__c str1 = new Strategia__c();
         str1.Nome__c ='test';
         str1.Stato__c = 'bozza';
         str1.Activation_roles__c ='r2,r3';
         str1.Descrizione__c = 'questo e un test';
         str1.industri_print_reference__c='hi';
         str1.Esito__c='esitotest';
         insert str1;
                  
         
         // 1. Il save di una nuova testata
         nsc.save();
         
         // 2. Il save di una cdi
         /*
         // - creazione di una cdi
         ApexPages.currentPage().getParameters().put('idTestata', nsc.str.id);
         ApexPages.currentPage().getParameters().put('type', 'CDI');
         nsc.save(); */
    }  

    // il controlo del salvataggio di un CDU
    public static testmethod void testSaveCdu(){
         
         // create a new page reference, set it as the current page, 
         // and use the ApexPages.currentPage() method to put the values
         PageReference PageRef = new PageReference('/apex/newStrategiaDataInput');
         Test.setCurrentPage(PageRef);   
         newStrategiaCTRL nsc = new newStrategiaCTRL ();
         
         // inizia la strategia
         Strategia__c str1 = new Strategia__c();
         str1.Nome__c ='test';
         str1.Stato__c = 'bozza';
         str1.Activation_roles__c ='r2,r3';
         str1.Descrizione__c = 'questo e un test';
         str1.industri_print_reference__c='hi';
         str1.Esito__c='esitotest';
         Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName();
         str1.recordTypeId = ctRecordTypes.get('Testata').getRecordTypeID();
         insert str1;
         
         // caso del creazione di un oggetto nonTestata
         ApexPages.currentPage().getParameters().put('action', 'Crea');
         ApexPages.currentPage().getParameters().put('idTestata', str1.id);
         
         // creazione di un CDU
         ApexPages.currentPage().getParameters().put('type', 'CDU');
         nsc.save();  
    }
    
    // il controlo del salvataggio di un salto
    public static testmethod void testSaveSalto(){
         
         // create a new page reference, set it as the current page, 
         // and use the ApexPages.currentPage() method to put the values
         PageReference PageRef = new PageReference('/apex/newStrategiaDataInput');
         Test.setCurrentPage(PageRef);   
         newStrategiaCTRL nsc = new newStrategiaCTRL ();
         
         // inizia la strategia
         Strategia__c str1 = new Strategia__c();
         str1.Nome__c ='test';
         str1.Stato__c = 'bozza';
         str1.Activation_roles__c ='r2,r3';
         str1.Descrizione__c = 'questo e un test';
         str1.industri_print_reference__c='hi';
         str1.Esito__c='esitotest';
         Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName();
         str1.recordTypeId = ctRecordTypes.get('Testata').getRecordTypeID();
         insert str1;
         
         
         // caso del creazione di un oggetto nonTestata
         ApexPages.currentPage().getParameters().put('action', 'Crea');
         ApexPages.currentPage().getParameters().put('idTestata', str1.id);
         
         // creazione di un salto
         ApexPages.currentPage().getParameters().put('type', 'JUMP');
         nsc.save();
    }
    // il controlo del salvataggio di un step
    public static testmethod void testSaveStep(){
         
		
         // create a new page reference, set it as the current page, 
         // and use the ApexPages.currentPage() method to put the values
         PageReference PageRef = new PageReference('/apex/newStrategiaDataInput');
         Test.setCurrentPage(PageRef);   
         newStrategiaCTRL nsc = new newStrategiaCTRL ();
         
         // inizia la strategia
         Strategia__c str1 = new Strategia__c();
         str1.Nome__c ='test';
         str1.Stato__c = 'bozza';
         str1.Activation_roles__c ='r2,r3';
         str1.Descrizione__c = 'questo e un test';
         str1.industri_print_reference__c='hi';
         str1.Esito__c='esitotest';
         Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName();
         str1.recordTypeId = ctRecordTypes.get('Testata').getRecordTypeID();
         insert str1;
         
         // caso del creazione di un oggetto nonTestata
         ApexPages.currentPage().getParameters().put('action', 'Crea');
         ApexPages.currentPage().getParameters().put('idTestata', str1.id);
         
         // creazione di un salto
         ApexPages.currentPage().getParameters().put('type', 'STEP');
         nsc.save();
    }
    
    // il metodoi per testare le metodi:
    // getcRuleLsit(), compilaWrapList(), rulesToString()
    public static testmethod void testRulesCompiling(){
        
          // inizia le istanzi delle classi
          newStrategiaCTRL nsc = new newStrategiaCTRL();
          
          // 1. crea una strategia valida
          Strategia__c str = new Strategia__c();
          str.Nome__c = 'il mio nomeStr';
          insert str;
          
          // 2.1 crea delle regole
          // primo oggetto di tipo Rule_control__c
          Rule_control__c rc =new Rule_control__c();
          rc.Name ='test1';
          rc.Api_field_name__c ='Nome__c';
          rc.Api_object_name__c = 'strategia__c';
          rc.Condition__c = '<';
          rc.Note__c = 'simpletest';
          rc.Rule_name__c='r1';
          rc.Strategia_api_field_name__c ='Rating__c';
          insert rc;
          
          // secondo oggetto di tipo Rule_control__c    
          Rule_control__c rc1 = new Rule_control__c();
          rc1.Name ='test1';
          rc1.Api_field_name__c ='Nome__c';
          rc1.Api_object_name__c = 'strategia__c';
          rc1.Condition__c = '<';
          rc1.Note__c = 'simpletest';
          rc1.Rule_name__c='r2';
          rc1.Strategia_api_field_name__c ='Rating__c';
          insert rc1;
          
          // le liste utili per creare la lista con le regole da scegliere
          list< Rule_control__c> myRClist = new list<Rule_control__c>();
          list < newStrategiaCTRL.cRule> myWrapRCList= new list< newStrategiaCTRL.cRule>();
          list< Rule_control__c> mySelectedRClist = new list<Rule_control__c>();
          
          // aggiungi i elemnti creati nella lista
          myRClist.add(rc);
          myRClist.add(rc1);
          
          // 2.2 aggiungili queste regole ad una testata
          
          // popoliamo la WrapList myWrapRCList
          for(Rule_control__c tempElement : myRClist )
              myWrapRCList.add(new newStrategiaCTRL.cRule(tempElement));
          
          // mettiamo true la variabile
          for(newStrategiaCTRL.cRule temWrapElement : myWrapRCList)
                   temWrapElement.selected=true;
          
          // aggiorniamo la lista mySelectedRCList con elemnti scelti
          for(newStrategiaCTRL.cRule temWrapElement1 : myWrapRCList)
                  mySelectedRCList.add(temWrapElement1.myCRule);
                            
          // 3. Adesso abbiamo delle regole scelte. Aggiungiamoli nei campi della nostro classe
          nsc.mySelList = mySelectedRCList;
          nsc.cRuleList = myWrapRCList;
          nsc.compilaWrapList();
          
          // aggiungi i nomi di queste regoli nella nostra testata
          str.Activation_roles__c = nsc.rulesToString();
          
          // 4. Crea il ambiente per il caso di creazione di nonTestata(compilamento regole, caso nontestata)
          // create a new page reference, set it as the current page, 
          // and use the ApexPages.currentPage() method to put the values
          PageReference PageRef = new PageReference('/apex/newStrategiaDataInput');
          Test.setCurrentPage(PageRef);   
          
          // caso del creazione di un oggetto nonTestata
          ApexPages.currentPage().getParameters().put('action', 'Crea');
          ApexPages.currentPage().getParameters().put('idTestata', str.id);
          ApexPages.currentPage().getParameters().put('type', 'CDI');
          nsc.getMytestata();
          nsc.compilaWrapList();
          
          // 5. Prova a chiamare il metodo per inserimento dei dati nei campi
          nsc.step3();
   }
    
    // test la classa wrap cRule       
    public static testmethod void testCRuleClass(){
   
           newStrategiaCTRL rcw = new newStrategiaCTRL();
           
           // prova a creare un oggetto cRule
           Rule_control__c myRule = new Rule_control__c();
           newStrategiaCTRL.cRule myWrapRule = new newStrategiaCTRL.cRule (myRule);
    } 
    
    // test il cancel button
    public static testmethod void testCancelButton(){
           
          // create a new page reference, set it as the current page, 
          // and use the ApexPages.currentPage() method to put the values
          PageReference PageRef = new PageReference('/apex/newStrategiaDataInput');
          Test.setCurrentPage(PageRef); 
          
          newStrategiaCTRL nsc = new newStrategiaCTRL();  
          
          // primo caso del creazione di un oggetto nonTestata
          ApexPages.currentPage().getParameters().put('action', 'Crea');
          ApexPages.currentPage().getParameters().put('type', 'CDI');
          nsc.cancelButton();
          
          // primo caso del creazione di un oggetto nonTestata
          ApexPages.currentPage().getParameters().put('action', 'Crea');
          ApexPages.currentPage().getParameters().put('type', 'STR');
          nsc.cancelButton();
    }       
}