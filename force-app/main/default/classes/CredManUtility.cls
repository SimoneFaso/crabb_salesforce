/* ---------------------------------------------------------------------------------------------------------------------
Name:            CredManUtility.cls
Description:
Test class:      TestCoverage_CredManUtility.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
08-Oct-2021  0.2      Claudio Sanna                   Modified for adding cebCheckFLSPermission (Security Review)
13-Sep-2022  0.3      C.Sanna & R.Kurti               Added WITH SECURITY ENFORCED (Security review)
04-Oct-2022  0.4      R.Kurti & C.Sanna               Added if statement to add NAMESPACE to field name (security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class CredManUtility
{
    //Riceve in ingresso una stringa Multipicklist(separatore ;) e un valore
    //Restituisce true se il valore è presente altrimenti restituisce false
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    public Boolean isPresent(String Multipick, String value)
    {
        Boolean b = false;
        if(Multipick != null)
        {
            List<String> aMulti = Multipick.split(';');
            for(String s : aMulti)
            {
                if(s == value)
                {
                    b = true;
                }
            }
        }
        return b;
    }
    
    // Questo metodo viene richiamato dalla classe degli affidi e serve per gestire la selezione di valori per i campi multipick
    
    public List<SelectOption> selectclick(List<String> leftselected, List<String> rightvalues, Map<String, String> MemoriaValDX){
        
        try{
        
            
            // carico il map della scelta fatta
            
            If(rightvalues.size() == 0){
            
                rightvalues.addall(leftselected); // faccio coincidere i valori da mostrare a desta con quelli selezionati
        
                for(Integer n=0; n<leftselected.size();n++){
        
                      MemoriaValDX.put(leftselected.get(n),leftselected.get(n));
                }

            // il codice sotto gestisce l'aggiunta di elementi da sinistra a destra evitando duplicati
            }else{
            
                for(Integer m=0; m<leftselected.size();m++){
                        
                    if(!MemoriaValDX.containsKey(leftselected.get(m))){
                        
                        MemoriaValDX.put(leftselected.get(m),leftselected.get(m));
                        rightvalues.add(leftselected.get(m));
                    }
                }
            
            }
            
            // il metodo torna la lista delle Opzioni modificata
            
            return getSelectedValues(rightvalues);
            
        }catch(Exception e){
            System.debug('Eccezione dentro il select click: ' + e.getMessage());
            return null;
        }
    }

    public List<SelectOption> unselectclick(List<String> rightselected, List<String> rightvalues, Map<String, String> MemoriaValDX){
        
        try{
        
            If(rightselected.size()>0){
            
                List<String> Temp = new List<String>();
                // Aggiorno il map con il dettaglio delle scelte fatte e poi la lista di valori rightvalues
                for(Integer z=0; z<rightselected.size();z++){
                            
                        if(MemoriaValDX.containsKey(rightselected.get(z))){
                            
                            MemoriaValDX.remove(rightselected.get(z));
                        }
                }
                
                Temp.addAll(rightvalues);
                rightvalues.clear();
                
                for(Integer h=0; h<Temp.size();h++){
                    
                    If(MemoriaValDX.containsKey(Temp.get(h))){
                        rightvalues.add(Temp.get(h));
                    }
                }
                
                // il metodo ritorna la lista delle SelectOption modificata
                return getSelectedValues(rightvalues);
            }    
            return getSelectedValues(rightvalues); // L'utente potrebbe pigiare il tasto di unselect senza aver selezionato valori a destra da eliminare.          
        }catch(Exception e){
            System.debug('Eccezione dentro Unselectclick: ' + e.getMessage());
            return null;
        }

    }
    
    
    // viene richiamato dalla classe degli Affidi e serve per gestire il caricamento delle liste dei campoi multipick
    
    public List<SelectOption> getunSelectedValues(List<String> original){
        try{
        
            List<SelectOption> options = new List<SelectOption>();

            List<String> tempList = new List<String>();

            tempList.addAll(original);

            //tempList.sort();

            for(String b : tempList)

                options.add(new SelectOption(b,b));

            return options;
        }catch(Exception e){
            System.debug('Eccezione nel caricamento dei valori di sinistra: ' + e.getMessage());
            return null;
        }

    }

    // viene richiamato dalla classe degli Affidi e serve per gestire il caricamento delle liste dei campoi multipick

    public List<SelectOption> getSelectedValues(List<String> right){

        try{    
            
            //Quando carico la prima volta a destra non metto nulla, poi dipende da quello che l'utente ha selezionato
        
            List<SelectOption> options1 = new List<SelectOption>();

            List<String> tempList = new List<String>();

            tempList.addAll(right);

            tempList.sort();

            for(String a : tempList)

                options1.add(new SelectOption(a,a));

            return options1;
            
        }catch(Exception e){
            System.debug('Eccezione nel caricamento dei valori di destra: ' + e.getMessage());
            return null;
        }
    
    }   
    
    public String get_string_query(List<String> rightvaluesq, String Qfield){

        String Qcampo = null;
        Map<String, String> Valori = new Map<String, String>();
    
        If(rightvaluesq.size()>0){
            for(String objfor: rightvaluesq){
                Valori.put(objfor,objfor);
            }            
            Qcampo = Qfield+' in '+Valori.keySet();
            QCampo = QCampo.replace('{','(\'');  // sostituisco le parentesi graffe
            QCampo = QCampo.replace('}','\')'); // sostituisco le parentesi graffe
            QCampo = QCampo.replace(', ','\',\''); // sostituisco le virgole fra le varie voci
            Valori.clear();
        }
        return Qcampo;
    }
    
   Public String Build_query(List<String> Elementi, String Start, Integer End_loop){
    
       Integer Controllo = 0;
       If(End_loop == null || Elementi.size()== 0)
           return Start;
       else{
            for(Integer j = 0; j<End_loop; j++){
    
                If(Elementi[j] != ''){
                
                    If(Controllo == 0){
                        Start = Start+' where '+Elementi[j];
                        Controllo = 1;
                    }else{
                        Start = Start+' and '+Elementi[j];
                    }
                }
            }
            return Start;
        }
    }   
 
    // Questo metodo permette di costruire parte di una query, facendo riferimento a campi

    public String get_string_range(String query, Integer check, List<Integer> Daval, List<Integer> Aval, List<String> Campi){
   
        If(Daval.size()== 0){
                    
             return query;
        }else{
            
            for(Integer i = 0; i<Daval.size();i++){
            
                if(Daval[i] != null){
                
                    String last_chunk = Campi[i]+' >  '+Daval[i]+' and '+Campi[i]+' < '+Aval[i];
                
                    if(check == -1){
        
                        query = query+' where '+last_chunk;
                        check = 0;
                        
                    }else{
                    
                        query = query+' and '+last_chunk;
                    }
                
                }
        
            }
            
            return query;
        }
    }
    
            
    public void create_attach(String Parent, blob filecont, String nome){    
        Attachment attachcrea = new Attachment();
        attachcrea.ParentId = Parent;
        attachcrea.body = filecont;
        attachcrea.Name = nome;
        attachcrea.IsPrivate = false;
 /*       if (Utils.checkFLSPermission('Attachment','ParentId').get('CREATE')
            && Utils.checkFLSPermission('Attachment','body').get('CREATE')
            && Utils.checkFLSPermission('Attachment','Name').get('CREATE')
            && Utils.checkFLSPermission('Attachment','IsPrivate').get('CREATE')
            ) insert attachcrea;*/
        if (Utils.cebCheckObjPermission('Attachment',gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Attachment','ParentId', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Attachment','body', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Attachment','Name', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Attachment','IsPrivate', gd).get('CREATE')) {
            insert attachcrea;
        }
    }
    
        /////////////////////
    ///// SELECTALL /////
    // ritorna una stringa con i nomi di tutti i campi dell'oggetto passato come parametro.
    public static String selectall(String sObjectName){
        String sObjectName4Desc = sObjectName.endsWithIgnoreCase('__c')?Utils.NAMESPACE+sObjectName:sObjectName;
        //map<String, schema.sobjectfield> m = schema.getglobaldescribe().get(sObjectName4Desc).getdescribe().fields.getmap();
        map<String, schema.sobjectfield> m = gd.get(sObjectName4Desc).getdescribe().fields.getmap();
        set<String> s = m.keyset();
        String allfields= '';
        for(String f : s)
        {
            if(f != 'billingaddress' && f != 'lastreferenceddate' && f != 'lastvieweddate' && 
                f != 'lastreferenceddate' && f != 'shippinglatitude' && 
                f != 'billinglongitude' && f != 'billinglatitude' && 
                f != 'shippinglongitude' && f != 'shippingaddress' && 
                f != 'middlename' && f != 'personmailingaddress' && 
                f != 'personmailinglatitude' && f != 'personmailinglongitude' && 
                f != 'personotherlatitude' && f != 'personotherlongitude' && f != 'suffix' &&
                f != 'isemailbounced' && f != 'mailinglatitude' && f != 'otherlongitude' && 
                f != 'mailinglongitude' && f != 'mailingcountry' && f != 'otherlatitude' && 
                f != 'emailbounceddate' && f != 'emailbouncedreason' && f != 'masterrecordid')
                allfields += f+', ';
        }
        allfields = allfields.substring(0,allfields.length()-2);
        return String.escapeSinglequotes(allfields);
    }
    
        /////////////////////
    ///// SELECTALL Short /////
    // ritorna una stringa con i nomi di tutti i campi, tranne quelli di 32768 caratteri, dell'oggetto passato come parametro.
    public static String selectallShort(String sObjectName){
        String sObjectName4Desc = sObjectName.endsWithIgnoreCase('__c')?Utils.NAMESPACE+sObjectName:sObjectName;
        //map<String, schema.sobjectfield> m = schema.getglobaldescribe().get(sObjectName4Desc).getdescribe().fields.getmap();
        map<String, schema.sobjectfield> m = gd.get(sObjectName4Desc).getdescribe().fields.getmap();
        set<String> s = m.keyset();
        String allfields= '';
        for(String f : s)
        {
            if(f != 'billingaddress' && f != 'lastreferenceddate' && f != 'lastvieweddate' && 
                f != 'lastreferenceddate' && f != 'shippinglatitude' && 
                f != 'billinglongitude' && f != 'billinglatitude' && 
                f != 'shippinglongitude' && f != 'shippingaddress' && 
                f != 'middlename' && f != 'personmailingaddress' && 
                f != 'personmailinglatitude' && f != 'personmailinglongitude' && 
                f != 'personotherlatitude' && f != 'personotherlongitude' && f != 'suffix' &&
                f != 'isemailbounced' && f != 'mailinglatitude' && f != 'otherlongitude' && 
                f != 'mailinglongitude' && f != 'mailingcountry' && f != 'otherlatitude' && 
                f != 'emailbounceddate' && f != 'emailbouncedreason' && f != 'masterrecordid' && f != 'CDI_Json__c' &&
                f != 'CDU_json__c' && f != 'Debug__c' && f != 'Buffer_Json__c')
                allfields += f+', ';
        }
        allfields = allfields.substring(0,allfields.length()-2);
        return String.escapeSinglequotes(allfields);
    }
    
    
        /////////////////
    ///// RESTO /////
    /////////////////
    //definizione dell'operatore % che non esiste in apex
    public static decimal resto(decimal dividendo, decimal divisore){
        decimal result = dividendo/divisore;
        integer parteintera = integer.valueOf(result);
        dividendo -= parteintera * divisore;
        return dividendo;
    }
    ////////////////////////////////////////
    ///// Numero Maggiore in una lista /////
    ////////////////////////////////////////
    public static integer NumberMax(List<integer> elencoNumeri){
        integer NMax = 0;
        for(integer n : elencoNumeri){
            if(NMax < n)
                NMax = n;
        }
        return NMax;
    }
    
    
    ///////////////////
    ///// TRIGGER /////
    ///////////////////
    // metodo utilizzato per bloccare l'esecuzione del trigger
    // ogni trigger dovrebbe iniziare invocando isTriggerEnabled(). 
    // Se restutuisce False, il trigger deve uscire senza eseguire altro.
    private static boolean TriggerEnabled = true;
    
    public static void EnableTrigger(){
        TriggerEnabled = true;
    }
    public static void DisableTrigger(){
        TriggerEnabled = false;
    }
    public static boolean IsTriggerEnabled(){
        return TriggerEnabled;
    }
    
    public static id ORGWIDEEMAILID;
    public static Id getOrgWideEmailId(){
        if(OrgWideEmailId==null){
            OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WITH SECURITY_ENFORCED LIMIT 1];
            OrgWideEmailId = owa.id;
        }
        return OrgWideEmailId;   
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //////Metodo che ritorna la lista dei valori presenti nella picklist che li passi in input//////
    ////////////////////////////////////////////////////////////////////////////////////////////////
    public static List<String> getPicklistValues(String ObjectApi_name,String Field_name){
        ObjectApi_name = ObjectApi_name.endsWithIgnoreCase('__c')?Utils.NAMESPACE+ObjectApi_name:ObjectApi_name;

        //Field_name = Utils.NAMESPACE+Field_name;
        //Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Schema.SObjectType targetType = gd.get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        map<String, Schema.SObjectField> fieldMap = Object_name.getSObjectType().getDescribe().fields.getMap();
        system.debug('*****fieldMap = ' + fieldMap);
        if(!Field_name.contains(Utils.NAMESPACE)) {
            Field_name = Utils.NAMESPACE + Field_name;
        }// if statement that adds the NAMESPACE if it's not present in the field name
        system.debug('*******Field_name = ' + Field_name);
        List<Schema.PicklistEntry> pickelems = fieldMap.get(Field_name).getDescribe().getPicklistValues();
        list<String> ListValueString = new list<String>();
        for (Schema.PicklistEntry a : pickelems)
            ListValueString.add(a.getValue());
            //selformatl[i].add(new SelectOption(a.getValue(), a.getLabel()));*/

        return ListValueString;


    }
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////Medoto che mi restituisce una lista contenente i valori doppi presenti nella lista passata in input///////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*public static List<String> FindDoubleValueInInput (List<String> ListInput){ 
        list<String> ValoriDoppi = new list <String>();
        for(Integer n=0; n<ListInput.size();n++){
            for(Integer a=n+1; a<ListInput.size();a++){
                if(a<ListInput.size()){
                    if(ListInput[n] == ListInput[a]){
                        ValoriDoppi.add(ListInput[n]);
                    }
                }
            }
        }
        return ValoriDoppi;
    }*/
    
    public static List<String> FindDoubleValueInInput (List<String> ListInput){ 
        map <String, boolean> MapBooleanPerValue = new map<String, boolean>();
        list<String> ListValoriDoppi = new list<String>();
        for(String S : ListInput){
            if(MapBooleanPerValue.get(S) == null){
                MapBooleanPerValue.put(S, false);
            }else{
                MapBooleanPerValue.put(S,true);
            }
        }
        for(String S : ListInput){
            if(MapBooleanPerValue.get(S)){
                ListValoriDoppi.add(S);
            }
        }
        return ListValoriDoppi;
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////Medoto che da un Date, mi restituisce una stringa di questo Formato {YYYYMMDD} ///////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static String CreateStringFromDate (Date DateInput){ 
        if(DateInput==null) return null;
        String Anno = String.ValueOf(DateInput.Year());
        String Mese = String.ValueOf(DateInput.month());
        String Day = String.ValueOf(DateInput.Day());
        if(Mese.length()==1){
            Mese = 0+Mese;
        }
        if(Day.length()==1){
            Day = 0+Day;
        }
        String StringFinale = Anno+Mese+Day;
        return StringFinale;
    }
    
    /*Metodo che formatta una data aggiungendo lo zero a giorno e mese nel caso siano <10*/
    public static String DateToString (Date DateInput){
        String Anno = String.ValueOf(DateInput.Year());
        String Mese = String.ValueOf(DateInput.month());
        String Day = String.ValueOf(DateInput.Day());
        if(DateInput.month()<10)
            Mese = '0'+Mese;
        if(DateInput.Day()<10)
            Day = '0'+Day;
        String finaldate = Day+'/'+Mese+'/'+Anno;
        return finaldate;
    }
    
    
}