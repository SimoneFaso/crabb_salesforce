/* ---------------------------------------------------------------------------------------------------------------------
Name:            newStrategiaCTRL.cls
Description:     This class manages the configurations of Strategy records
Test class:      TestnewStrategiaCtrl.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
16-Jun-2016  0.2      E. Sino                         Added with sharing (Security Review)
25-Aug-2021  0.3      Claudio Sanna                   Modified and added cebCheckObjPermission and cebCheckFLSPermission
                                                      (Security Review)
16-Sep-2022  0.4      R.Kurti & C.Sanna               Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class newStrategiaCTRL{

    // Le variable del controller
    
    public Strategia__c str;
    public Strategia__c strategia;
    public Strategia__c myTestata;
    public Strategia__c newRule;  
    public String myTestataSTR; // il codice della testata che appare nel lookup  
    public string type;
    public string testata;
    public String action;// tipo di operazione : Crea/Modifica/Clone
    public String recordId;// id del record che si modificera
    public String mieRegoleStep3;
    public String myPrevSelRules= '';// un string per ricordare le regole scelte nel ultima modifica
    public String mySessionRules= '';// le regole selezionat in un sessione crea/modifica
    public id myTestataId;
    public string ruleSelected;
    public string field='Nome__c';
    public static List<String> strategiaFieldsList;// una list di tutti i campi di un oggetto
    public List<cRule> cRuleList;
    public List<cRule> cRuleListNoTestata;
    public LIST<Rule_control__c > mySelList;
    public List <rule_control__c> SelectedRulesStep2;
    public Set<String> campiDaInserireDati;
    public Boolean Error = false;
    public Boolean noRuleSelected;
    public boolean flagRegole;
    public list<Rule_Control__c> fieldsDaControlare;
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    
    // il costruttore
    // controllo dell id e del tipo operazione 
    // ogni volta che si esegue un operazione.
    public newStrategiaCTRL(){

        // inizia il flag dell errore
        this.Error = false;
        
        // prendi il tipo di oggetto che si processerà
        this.type = getMyType();
        
        // controllo se quando inseriamo una CDI,CDU, ... 
        // l'id della testata non è valida e se il type non è valido
        if((getMyType()!= 'STR')&&(!idTestataValid(getMyTestataId())))
            setError();
        if (!isTypeValid())
            setError();
               
        // inizio anche il oggetto NewRule, in caso dell un inserimento di una nuova regola
        getNewRule();
        
        // inizia la strtegia 
        str = getStrategia();
     }
     
     public boolean getflagRegole(){
        return flagRegole;
     }
    
     // i metodi get e set delle varie gield dell controller 
     public string getfield(){
        return field;
     }
    
     public string getMieRegoleStep3(){
        return mieRegoleStep3;
     }   

       
     public Strategia__c getStrategia() {// inizia la strategia 
        
        // se la testata gia esiste, nel caso della modifica e clone
        if(str!=null) return str;
        String action = getaction();
         //Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Strategia__c.getRecordTypeInfosByName();
         Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName();
        string  queryString;
        //throw new TriggerFactory.TriggerException('RDONATO:'+ctRecordTypes);
        // Inizia la strategia
        if(action == 'Crea'){ 
            if(str==null){
                str = new Strategia__c();
                if(type == 'TESTATA'){
                    str.recordtypeId= ctRecordTypes.get('Condizioni_di_Ingresso').getRecordTypeID();
                }
                else if(type == 'CDI'){
                        str.recordTypeId = ctRecordTypes.get('Condizioni_di_Ingresso').getRecordTypeID();
                }
                else if(type == 'CDU'){
                        str.recordTypeId = ctRecordTypes.get('Condizioni_di_Uscita').getRecordTypeID();
                }
                else if(type == 'STEP'){
                        str.recordTypeId = ctRecordTypes.get('Step').getRecordTypeID();
                }
                else if(type == 'JUMP'){
                        str.recordTypeId = ctRecordTypes.get('Salto').getRecordTypeID();
                } 
            }
        }else {
            String myRecordId = getRecordId();
            // fornisci i campi da chiedere il db
            setStrategiaFieldsList();
                 
            // composi il query per db
            queryString='Select ';
            queryString+= utils.joinStrings(getStrategiaFieldsList(),',');
            queryString+=' FROM Strategia__c where id =: myRecordId';
            str = new Strategia__c();      
            if(action == 'modifica'){
            // inizio nuovo codice 13/04/17 inserimento check permission
              /*
                if (Utils.checkFLSPermission('Strategia__c', 'Anzianita_scaduto__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'BaseType__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'CAP_Massimo__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'CAP_Minimo__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Cattivo_Pagatore__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Data_attivazione__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Data_disattivazione_strategia__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Descrizione__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Esito__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Tipologia__c').get('ACCESS'))
               */
                if (Utils.cebcheckObjPermission('Strategia__c', gd).get('ACCESS')
                    && Utils.cebcheckFLSPermission('Strategia__c', 'Anzianita_scaduto__c', gd).get('ACCESS')
                    && Utils.cebcheckFLSPermission('Strategia__c', 'BaseType__c', gd).get('ACCESS')
                    && Utils.cebcheckFLSPermission('Strategia__c', 'CAP_Massimo__c', gd).get('ACCESS')
                    && Utils.cebcheckFLSPermission('Strategia__c', 'CAP_Minimo__c', gd).get('ACCESS')
                    && Utils.cebcheckFLSPermission('Strategia__c', 'Cattivo_Pagatore__c', gd).get('ACCESS')
                    && Utils.cebcheckFLSPermission('Strategia__c', 'Data_attivazione__c', gd).get('ACCESS')
                    && Utils.cebcheckFLSPermission('Strategia__c', 'Data_disattivazione_strategia__c', gd).get('ACCESS')
                    && Utils.cebcheckFLSPermission('Strategia__c', 'Descrizione__c', gd).get('ACCESS')
                    && Utils.cebcheckFLSPermission('Strategia__c', 'Esito__c', gd).get('ACCESS')
                    && Utils.cebcheckFLSPermission('Strategia__c', 'Tipologia__c', gd).get('ACCESS'))
                {
                // prendi i campi delle testate
                str = database.query(String.escapeSingleQuotes(queryString));
                              
                // prima di partire da zero il activation roles, memorizzala
                setmyPrevSelRules(str.Activation_roles__c);
                              
                // parti le regole scelte dal zero
                str.Activation_Roles__c = '';
              }
              // fine nuovo codice 13/04/17 inserimento check permission            
          }
            else if(action == 'Clone'){
              // inizio nuovo codice 13/04/17 inserimento check permission
              /*
              if (Utils.checkFLSPermission('Strategia__c', 'Anzianita_scaduto__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'BaseType__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'CAP_Massimo__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'CAP_Minimo__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Cattivo_Pagatore__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Data_attivazione__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Data_disattivazione_strategia__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Descrizione__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Esito__c').get('ACCESS')
                && Utils.checkFLSPermission('Strategia__c', 'Tipologia__c').get('ACCESS'))
               */
               if (Utils.cebcheckObjPermission('Strategia__c', gd).get('ACCESS')
                  && Utils.cebcheckFLSPermission('Strategia__c', 'Anzianita_scaduto__c', gd).get('ACCESS')
                  && Utils.cebcheckFLSPermission('Strategia__c', 'BaseType__c', gd).get('ACCESS')
                  && Utils.cebcheckFLSPermission('Strategia__c', 'CAP_Massimo__c', gd).get('ACCESS')
                  && Utils.cebcheckFLSPermission('Strategia__c', 'CAP_Minimo__c', gd).get('ACCESS')
                  && Utils.cebcheckFLSPermission('Strategia__c', 'Cattivo_Pagatore__c', gd).get('ACCESS')
                  && Utils.cebcheckFLSPermission('Strategia__c', 'Data_attivazione__c', gd).get('ACCESS')
                  && Utils.cebcheckFLSPermission('Strategia__c', 'Data_disattivazione_strategia__c', gd).get('ACCESS')
                  && Utils.cebcheckFLSPermission('Strategia__c', 'Descrizione__c', gd).get('ACCESS')
                  && Utils.cebcheckFLSPermission('Strategia__c', 'Esito__c', gd).get('ACCESS')
                  && Utils.cebcheckFLSPermission('Strategia__c', 'Tipologia__c', gd).get('ACCESS'))
                {
              // fornisci i campi da chiedere il db
              setStrategiaFieldsList();
              Strategia__c strTemp = new Strategia__c(); 
              strTemp = database.query(String.escapeSingleQuotes(queryString));
              str = strTemp.clone(false,true,false,false);
                         
              // prima di partire da zero il activation roles, memorizzala
              setmyPrevSelRules(str.Activation_roles__c);
                    
              // parti le regole scelte dal zero
              str.Activation_Roles__c = '';}
            }
            // inizio nuovo codice 13/04/17 inserimento check permission
        }
        return str;
    }
    
    // un metodo per popolare la lista dei campi che deveno essere forniti dal DB
    public static void setStrategiaFieldsList(){
        if(strategiaFieldsList!=null) return;
        SObjectType type = gd.get(Utils.NAMESPACE+'Strategia__c');
        // SObjectType type = Schema.getGlobalDescribe().get(Utils.NAMESPACE+'Strategia__c');
        Map<String,Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        strategiaFieldsList=new List<string>();
        strategiaFieldsList.addAll(mfields.keySet());
    }
    
    // un metodo per prendere la lista dei campi che deveno essere forniti dal DB
    public static List<String> getStrategiaFieldsList(){
        return StrategiaFieldsList;
    }
    
    // la testat di una cdi, cdu, etc.
    public Strategia__c getmyTestata(){
        
        myTestata = new Strategia__c();
        if (Utils.cebcheckObjPermission('Strategia__c', gd).get('ACCESS')
            && Utils.cebcheckFLSPermission('Strategia__C', 'Stato__c', gd).get('ACCESS')
            && Utils.cebcheckFLSPermission('Strategia__C', 'Nome__c', gd).get('ACCESS')
            && Utils.cebcheckFLSPermission('Strategia__C', 'Descrizione__c', gd).get('ACCESS')
            && Utils.cebcheckFLSPermission('Strategia__C', 'Versione__c', gd).get('ACCESS')
            && Utils.cebcheckFLSPermission('Strategia__C', 'industri_print_reference__c', gd).get('ACCESS')
            && Utils.cebcheckFLSPermission('Strategia__C', 'Esito__c', gd).get('ACCESS')
            && Utils.cebcheckFLSPermission('Strategia__C', 'Testata__c', gd).get('ACCESS')
            && Utils.cebcheckFLSPermission('Strategia__C', 'Activation_roles__c', gd).get('ACCESS'))
        /*
            if(Utils.checkFLSPermission('Strategia__C', 'Stato__c').get('ACCESS')
            && Utils.checkFLSPermission('Strategia__C', 'Nome__c').get('ACCESS')
            && Utils.checkFLSPermission('Strategia__C', 'Descrizione__c').get('ACCESS')
            && Utils.checkFLSPermission('Strategia__C', 'Versione__c').get('ACCESS')
            && Utils.checkFLSPermission('Strategia__C', 'industri_print_reference__c').get('ACCESS')
            && Utils.checkFLSPermission('Strategia__C', 'Esito__c').get('ACCESS')
            && Utils.checkFLSPermission('Strategia__C', 'Testata__c').get('ACCESS')
            && Utils.checkFLSPermission('Strategia__C', 'Activation_roles__c').get('ACCESS'))
         */
        {
        myTestata = [Select Id,Stato__c,Nome__c,Descrizione__c,Versione__c,
                       Name,industri_print_reference__c,Esito__c,Testata__c,Activation_roles__c  
                       FROM  Strategia__C 
                       WHERE id =:getMyTestataId()
                        WITH SECURITY_ENFORCED ];
        }
        return myTestata ;
    }
    
    // prendi il codice della testata, propieta di cui sara
    // il oggetto CDI/CDU/Salto o Step che si creera
    public String getMyTestataSTR(){
        
        // prendi idTestata dal URL
        String CurrentId = getMyTestataId();
        Strategia__c tempStr = new Strategia__c();
        
        // se la testata esiste, torna il codice STR - {xxxx}
        if(idTestataValid(CurrentId)) 
            tempStr = [SELECT id,Name FROM Strategia__c 
                        WHERE id =: CurrentId WITH SECURITY_ENFORCED ];
        else{// se la testatat non esiste
            return 'Questa Testata non esiste!';     
        }
        return tempStr.Name;
    }
    
    // metodo get set per myPrevSelRules
    public string getmyPrevSelRules(){
        return this.myPrevSelRules;
    }
    
    public void setmyPrevSelRules(String mieRegole){
        this.myPrevSelRules = mieRegole;
    }
    
    // metodi get set per mySessionRules
    public string getmySessionRules(){
        return this.mySessionRules;
    }
    
    public void setmySessionRules(String mieRegole){
        this.mySessionRules= mieRegole;
    }
    
    // get & set per il flag Error
    public Boolean getError(){
        return this.Error;
    }
    
    public void setError(){
        Error = true;
    }
    
    // get&set per il flag noRuleSelected
    public Boolean getNoRuleSelected(){
        return this.NoRuleSelected;
    }
    
    public void setNoRuleSelected(){
        NoRuleSelected = true;
    }
    
    // inizia il container che la useremo per leggere
    // i valori pickList, e metterli nel nuovo regola
    public Strategia__c getNewRule() {
        if(str == null) newRule= new Strategia__c();
        return newRule;
    }    
     
    // prendi il type dal URL  
    public string getType(){

        type= String.isNotBlank(ApexPages.currentPage().getParameters().get('type'))?String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('type')):null;
        return type;
    }
    
    // predni il idTestata dal URL
    public String getMyTestataId(){
        try{
            //myTestataId=String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('idTestata'));
            myTestataId=String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('idTestata').escapeHtml4());
        }catch(Exception e){
            return null;
        }
        return myTestataId;
    }
    
    // il tipo del azzione/operazione dal URL
    public String getAction(){
        action = String.isNotBlank(ApexPages.currentPage().getParameters().get('action'))?String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('action')):null;
        return action ;
    }
    
    // l'id del record che si modifica dal URl(RecordId)
    public String getRecordId(){
        recordId = String.isNotBlank(ApexPages.currentPage().getParameters().get('recordId'))?String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('recordId')):null;
        return recordId;
    }
    
    // inizia la lista delle regole possibile da scegliere 
    public List<cRule> getcRuleList(){
        cRuleList = compilaWrapList();
        return cRuleList;
    } 
    // inizia la lista delle regole possibile da scegliere 
    public List<cRule> getcRuleListNoTestata(){
        cRuleListNoTestata = compilaWrapList();
        return cRuleList;
    }
    
    // Metodo per visualizzare le reg nel step 3
    public List<Rule_control__c> getSelectedRulesStep2() {
       
       // La list che avra i campi da inserire dati
       List<Rule_control__c> myRulesSel=new List<Rule_control__c>();
       
       // vedi chi ha scelto e aggiungilo nella lista
       if(cRuleList==null) return myRulesSel;
       for(cRule c: cRuleList){
           if(c.selected){
               myRulesSel.add(c.myCrule);
           }
       }
       return myRulesSel;
   } 
    
    // leggi il campo name dalle regole selezionate tramite rulesToString()  
    public string getcRuleSelected(){
        return  rulesToString();
    }
    
    // prendi il tipo di modifica che si eseguira
    public String getMytype(){
       type = String.isNotBlank(ApexPages.currentPage().getParameters().get('type'))?String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('type')):'';  
       return type;  
    }
    
    // la lista con i campi da insere dati secondo le regole scelte
    public List<String> getCampiDaInserireDati() {
        
        // La list che avra i campi da inserire dati
        List<string> ListFields=new List<string>();
        
        // un set per leggere i campi Strategia_Api_Field_Name 
        // dalle regole selezinate
        set<string> setFields= new set<string>();
        
        // vedi chi ha scelto e aggiungilo nella lista
        if(cRuleList==null) return ListFields;
        for(cRule c: cRuleList){
            if(c.selected){
                setFields.add(c.myCrule.Strategia_api_field_name__c);
            }
        }
        
        // passa i resultati del set nella lista
        ListFields.addAll(setFields);
        return ListFields;
    } 
    
    /* I metodi che formerano il wizard 
    *  Questi metodi verrano convocati dai bottoni next e previous
    * 
    */
    // il primo step
    public PageReference step1() {
        return Page.newStrategiaDataInput;
    }
    
    // rifresca il flag delle regole selezionate
    // prima di aggiungere delle regole 
    public PageReference step2() {
        try{
            System.debug('\n Presso Next!!!');
            NoRuleSelected = false ;
            return Page.newStrategiaRules;
        }catch(Exception e){
            System.debug('\n Dettagli: ' + e.getLineNumber());
            return null;
        }
    }
    
    // controla se sono delle regole scelte
    // controlando se sono campi da riempire con dati
    public PageReference step3() {
        
        // una lista per i campi da inserire dati
        List<String> tmmpCampiDati = new List<String>();
        tmmpCampiDati = getCampiDaInserireDati();
        
        // se non sono campi da inserire dati, avisa il utente
        if(tmmpCampiDati.isEmpty())
            setNoRuleSelected();
        
        // rifresca il campo Act_Roles
        str.Activation_roles__c = rulesToString();
        /*
        setmySessionRules(rulesToString());
        */
        // se crea una testata deve andare alla ultima pagina 
        if ((getMyType() == 'STR')) return Page.newStrategiaSummary;
        return Page.newStrategiaDettails;
    }
    
    // il step finale 
    public PageReference step4() {
        return Page.newStrategiaSummary;
    }
    
    // Secondo il tipo della strategia, inserisci in DB
    public PageReference save() {
         
         // i prerequisiti, prima di fare un operazione salva in DB
         type = getMyType();
         recordId = getRecordId();
         action = getAction();
         
         // il recordType del record che si salvera
        //Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Strategia__c.getRecordTypeInfosByName();
        Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Strategia__c.getRecordTypeInfosByDeveloperName();
         
         // controlla che tipo di Strategia, salveremo in db
         if(type == 'STR'){
              str.recordTypeId = ctRecordTypes.get('Testata').getRecordTypeID();
              //throw new TriggerFactory.TriggerException('RDONATO:'+ctRecordTypes.get('Testata').getRecordTypeID()); 
         }else{  // ora per tutti i altri tipi di Strategia che inseriamo, 
                 // fissiamo il campo Testata__c
                 // altro che il recordType
                 str.Testata__c = getMyTestataID();
                 if(type == 'CDI'){
                     str.recordTypeId = ctRecordTypes.get('Condizioni_di_Ingresso').getRecordTypeID();
                 }
                 else if(type == 'CDU'){
                         str.recordTypeId = ctRecordTypes.get('Condizioni_di_Uscita').getRecordTypeID();
                 }
                 else if(type == 'STEP'){
                     str.recordTypeId = ctRecordTypes.get('Step').getRecordTypeID();             
                 }
                 else if(type == 'JUMP'){
                     str.recordTypeId = ctRecordTypes.get('Salto').getRecordTypeID();
                 }         
          } 
          
          // rifresca il Act_roles, prima di inserire in DB
          // controlla per i tipi di operazione: Crea, Modifica o Clone
          if(action == 'Crea')
              str.Activation_roles__c = rulesToString();
          else
              if(action == 'Modifica' || action == 'Clone'){    
                  // se l'utente non ha scelto delle regole durante la modifica, metti solo le vecchie regole
                  if(getcRuleSelected() == 'No rules selected')
                      str.Activation_roles__c = 'No rules selected';
                      //str.Activation_Roles__c = getmyPrevSelRules();
                  else
                      str.Activation_roles__c = rulesToString();
              }              
          // se ha un nuovo oggetto, fai insert, se no update uno esistente
          /*
          if (Utils.checkFLSPermission('Strategia__c', 'Activation_roles__c').get('CREATE')
                && Utils.checkFLSPermission('Strategia__c', 'Testata__c').get('CREATE')
                && Utils.checkFLSPermission('Strategia__c', 'recordTypeId').get('CREATE')
                ) upsert str;
           */
          if (Utils.cebCheckObjPermission('Strategia__c', gd).get('UPSERT')
                  && Utils.cebCheckFLSPermission('Strategia__c', 'Activation_roles__c', gd).get('UPSERT')
                  && Utils.cebCheckFLSPermission('Strategia__c', 'Testata__c', gd).get('UPSERT')
                  && Utils.cebCheckFLSPermission('Strategia__c', 'recordTypeId', gd).get('UPSERT')) {
              upsert str;
          }
      
          // una volta inserito/modificato un record esistente, 
          // vai nella paginaDettagli con Id come idTestata nel URL
          PageReference opptyPage;
          
          // e come str.id, nel caso del creazione di una nuova Testata
          if((action == 'crea')&&(type == 'STR'))
              opptyPage = new PageReference('/apex/paginaDettagli?myid=' + str.id);
          else
              opptyPage = new PageReference('/apex/paginaDettagli?myid=' + getMyTestataId());
          
          opptyPage.setRedirect(true);
          return opptyPage;
    }
        
    //WRAPPER DELLE RULE CONTROL
    public class cRule {
        public Rule_control__c myCRule {get; set;}
        public Boolean selected {get; set;}
 
        public cRule(Rule_control__c r) {
            myCrule = r;
            selected = false;
        }
    }   
    
    /*
    * La lista wrap si compilera in due modi diversi, dipendente dal tipo del operazione
    * rendere le regole da scegliere con un attributo selected
    * tramite il wrapClass cRule
    */
    public  List<cRule> compilaWrapList(){
        
        // la lista finale che si riempiera con regole da scegliere
        List<cRule> crList = new List<cRule>();
        
        // il tipo del operazione, dividera il modo del compila della lista
        String opType = getMyType();
        
        // se abbiamo che fare con un STR, prendi tutte le regole
        if(opType == 'STR'){
            for(Rule_control__c a: [select Id, Name,Api_field_name__c,Api_object_name__c,Condition__c,Note__c,
                                            Rule_name__c,Strategia_api_field_name__c  
                                            FROM Rule_control__c WITH SECURITY_ENFORCED order by Api_field_name__c LIMIT 50000])
                crList.add(new cRule(a));
        }
        
        // per un oggetto non Testata, prendi solo le regole che appartengono a la testata
        else 
            if(String.isNotBlank(opType)){
                    // per un oggetto non Testata, prendi solo le regole che appartengono a la testata
                    String testataId = getMytestataId();
                    
                    // adesso popoliamo la lista wrap solo con le regole della testata                    
                    Strategia__c myTestata = new Strategia__c();
                    if(Utils.cebcheckFLSPermission('Strategia__C', 'Activation_roles__c', gd).get('ACCESS'))
                    //if(Utils.checkFLSPermission('Strategia__C', 'Activation_roles__c').get('ACCESS'))
                    {
                      myTestata = [SELECT id, Activation_roles__c FROM Strategia__c WHERE id =: testataId WITH SECURITY_ENFORCED ];
                    }
                    // controlla se la testata contiene delle regole    
                    if((myTestata.Activation_Roles__c != null)&&(myTestata.Activation_Roles__c != '')){
                        
                        // dividi le regole in String, nella Act_Roles, nella Lista<String>
                        List<String> mySelectedRules = myTestata.Activation_Roles__c.split(',');
                        
                        // aggiungi queste regole nella crList finale
                        for(Rule_control__c a: [select Id, Name,Api_field_name__c,Api_object_name__c,Condition__c,Note__c,
                                                    Rule_name__c,Strategia_api_field_name__c  
                                                    FROM Rule_control__c 
                                                    WHERE Name IN : mySelectedRules WITH SECURITY_ENFORCED order by Api_field_name__c ])
                            crList.add(new cRule(a));
                    }else {// questa testata non contiene delle regole da scegliere
                        return null;
                    }   
            }
        // prima di visualizzare la lista con regole da selezionare
        // controlliamo se stiamo un caso di modificá o clone, e fare check le regole
        // le regole selezionate al ultima volta che il record 'e modificato
        if((crList != null ) && (action == 'Modifica' || action == 'Clone')){
            
            // prendi le regole che eranno selezionate per questo record nel ultimo modificÃ¡
            String myPrevSelRules = getMyPrevSelRules();
            
            // iteriamo dentro il wraplist appena creata, fai true il attributo selected, se trovi una regola selezionata prima
            for(cRule tempCRule : crList)
            {
                if(myPrevSelRules != null)
                {
                    if( myPrevSelRules != '' && myPrevSelRules.contains(tempCRule.myCRule.Name))
                        tempCRule.selected = true;
                }
                // se qualche regola e aggiunta durante il sessione, aggingi anche quello    
                if(((mySessionRules != null)||(mySessionRules != '')) && (mySessionRules.contains(tempCRule.myCRule.Name)))
                    tempCRule.selected = true;    
            }                
        }else{
        // Se stiamo creando un oggetto, e se qualche regola é
        // aggiunta durante il sessione, aggingi anche quello
        if(crList != null ) 
            for(cRule tempCRule : crList)
                if(((mySessionRules != null)||(mySessionRules != '')) && (mySessionRules.contains(tempCRule.myCRule.Name)))
                        tempCRule.selected = true;
        }            
        return crList;
    }
    
    // metodo per vedere le regole selezionate di cdi, cdu, step , salto
    // public  List<cRule> regoleselezionate
    // leggi le regole scelte e mettili in un String
    public string rulesToString(){
        string s='';
        if(cRuleList==null) return 'no rules selected';
       
        for(cRule c: cRuleList){
            if(c.selected){
                s              += c.myCrule.Name+',';
                mySessionRules += c.myCrule.Name+',';
            }    
        }
        // se l'utente non ha scelto delle regole avertilo
        if((s == '') || (s == null)){
           noRuleSelected = true;
           s = 'No rules selected';
           }
         else   s= s.Substring(0,s.length()-1);
        return s; 
    }
    
    // controlla la validitá della testata collegate con il CDI,CDU....
    Public Boolean idTestataValid(String myTestataId){
        if((myTestataId != null) && (myTestataId != '')){
            
            // check if exists such an object
            Strategia__c tempStr = new Strategia__c();
            try{
                tempStr = [SELECT id FROM Strategia__c WHERE id =: myTestataId WITH SECURITY_ENFORCED ];
            }catch(Exception e){
                return false;
            }   
            return true;
        }else
            // we know there was an error with testataID
            return false;
    }
    
     // controlla la validitá del TYPE
    public Boolean isTypeValid(){
        String opType = getMyType();
        if((opType == 'STR')||(opType == 'CDI')||(opType == 'CDU')||(opType == 'JUMP')||(opType == 'STEP'))
            return true;
        else 
            return false;
    }
    
    // il bottone cancel per dare la oportunita al utente di tornare indietro
    public PageReference CancelButton(){
        
        // Quando si crea una testata, l'utente deve tornare nel GestioneStrategie con cancel
        if((getMyType() == 'STR') && (getAction() == 'Crea'))
            return new PageReference('/apex/GestioneStrategie');
        else
            // se no torna nella pagina dettagli della testata 
            return new Pagereference('/apex/PaginaDettagli?myId=' + getMyTestataId());
    }

}