/* -----------------------------------------------------------------------------------------------------------------
Name:            Upsert_LogIndirizzi02.cls
Description:
Test class:      ?.cls


             0.1                              First Version
08-oct-2021  0.2    Matteo Pizzichini         Fixing FLS adding braces to if and ceb methods
15-Sep-2022  0.3    R.Kurti & C.Sanna         Added cebObjCheckPermission for secuirty review
----------------------------------------------------------------------------------------------------------------- */
public with sharing class Upsert_LogIndirizzi02 {

    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public void Upsert_LogIndirizzi02(){
        
    }   
    
    public static void UpsertIndirizzo(Id IdLogToWrite, DateTime DataInizio, 
                                    map<Integer, String> ErrorStringPerInteger, map<Integer, Contact> MapIndirizziToUpsertPerIndice, 
                                    map<Integer, String> NewMapException){
                                    
        //Creo In Json gli esiti del caricamento del movimento e popolo il log 
        String allfieldsLog = CredManUtility.selectallShort('Log__c');
        Log__c LogToUpdate = new Log__c();
        if(Utils.cebCheckObjPermission('Log__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'Account_KO__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Log__c', 'Account_OK__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Log__c', 'Account_TOT__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Log__c', 'Durata__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Log__c', 'Error__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Log__c', 'File_Caricati__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Log__c', 'Fine__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Log__c', 'info__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Log__c', 'Line_number__c',gd).get('ACCESS'))
        {
            LogToUpdate = database.query(String.escapeSingleQuotes('SELECT '+allfieldsLog+
                          ' FROM Log__c WHERE Id = : IdLogToWrite '));
        }                            
        integer IndirizziOK = 0;
        integer IndirizziKO = 0;
        if(MapIndirizziToUpsertPerIndice.keyset().size()>0){
            Set<integer> IndiceMapIndirizziUpsert = MapIndirizziToUpsertPerIndice.keyset();
            list<Integer> ListIndiceSortIndirizziUpsert = new list<Integer>();
            for(Integer i : IndiceMapIndirizziUpsert){
                ListIndiceSortIndirizziUpsert.add(i);
            }
            ListIndiceSortIndirizziUpsert.sort();
            list<Contact> ListIndirizziUpsertSort = new list<Contact>();
            for(integer i : ListIndiceSortIndirizziUpsert){
                ListIndirizziUpsertSort.add(MapIndirizziToUpsertPerIndice.get(i)); 
                // Silvio per bug indirizzi
                //ErrorClass.logError('Upsert_LogIndirizzi02.UpsertIndirizzo','Vediamo tutto il record: '+MapIndirizziToUpsertPerIndice.get(i));
            }
            system.debug('*****MapIndirizziToUpsertPerIndice = ' + MapIndirizziToUpsertPerIndice.size());
            system.debug('******ListIndirizziUpsertSort = ' + ListIndirizziUpsertSort);
            // inizio nuovo codice 18/04/17 inserimento check permission
            if(Utils.cebCheckObjPermission('Contact',gd).get('UPSERT')
                    && Utils.cebCheckFLSPermission('Contact', 'Principale__c',gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Contact', 'Comune__c',gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Contact', 'Indirizzo__c',gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Contact', 'Cap__c',gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Contact', 'Provincia__c',gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Contact', 'Toponimo__c',gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Contact', 'Civico__c',gd).get('UPSERT'))
            {
                List<Database.Upsertresult> upsertResultIndirizzi = Database.upsert(ListIndirizziUpsertSort, Contact.Id_Esterno__c, false);
                integer n4 = 0;
                for(Database.Upsertresult ur : upsertResultIndirizzi){
                    Integer ConteggioIndice = ListIndiceSortIndirizziUpsert[n4];
                    string message = '';
                    if(!ur.isSuccess()){
                        message += 'KO4Upsert_WARNING: ';
                        for(Database.Error dbe : ur.getErrors()){
                            message += dbe.message + ' - ';
                            /* ErrorClass.logError('Upsert_LogIndirizzi02.DatabaseError','Vediamo il flag errore: '+ur.isSuccess()+' vediamo i dati contenuto nel messaggio'+
                            dbe.message+'-'+dbe.getFields()+'-'+dbe.getStatusCode());
                            */
                        }   
                        message += '. The line ' + ConteggioIndice + ' will be ignored.\n';
                        ErrorStringPerInteger.put(ConteggioIndice, message);
                        // Silvio Ivaldi per bug indirizzo
                    
                    }
                    n4++;
                }
            }    
            // Fine nuovo codice 18/04/17 inserimento check permission
        }
        
       
        Set<Integer> SetLogFinal = ErrorStringPerInteger.keyset();
        list<Integer> ListIndiceForLog = new list<Integer>();
        for(integer i : SetLogFinal){
            ListIndiceForLog.add(i);
        }
        
        system.debug('*****ListIndiceForLog.size() = ' + ListIndiceForLog.size());
        Integer IndiceCSVForLog;
        //Integer RigaReale;
        map<Integer, String> MapErrorePerNRIGAFinal = new map<Integer, String>();
        for(integer i=0;i<ListIndiceForLog.size();i++){
            IndiceCSVForLog = ListIndiceForLog[i];
            //RigaReale = ListIndiceForLog[i]+2;
            if(ErrorStringPerInteger.get(IndiceCSVForLog).startsWith('KO')){
                system.debug('******OKFruit');
                //Gestione KO SILVIO IVALDI aggiorno qui il contatore degli errori e non sotto altrimenti non vengono conteggiati gli errori alla riga81
                IndirizziKO++;
                if(ErrorStringPerInteger.get(IndiceCSVForLog).startsWith('KO3')){
                    //Gestione Log Servizi
                    system.debug('**** KO1 *** ErrorStringPerInteger = ' + ErrorStringPerInteger);
                    //IndirizziKO++;
                    if(ErrorStringPerInteger.get(IndiceCSVForLog).contains('Exception')){
                        MapErrorePerNRIGAFinal.put(IndiceCSVForLog,'KO - Row '+IndiceCSVForLog+' - ERRORE INASPETTATO: '+NewMapException.get(IndiceCSVForLog));
                    }else if(ErrorStringPerInteger.get(IndiceCSVForLog).substring(3,9) == 'Upsert'){
                        MapErrorePerNRIGAFinal.put(IndiceCSVForLog,'KO - Row '+IndiceCSVForLog+' - ERRORE DURANTE IL SALVATAGGIO: '+ErrorStringPerInteger.get(IndiceCSVForLog).substring(10, ErrorStringPerInteger.get(IndiceCSVForLog).length()));
                    }else{
                        MapErrorePerNRIGAFinal.put(IndiceCSVForLog,'KO - Row '+IndiceCSVForLog+' - ERRORE DI DATI_A: '+ErrorStringPerInteger.get(IndiceCSVForLog).substring(4,ErrorStringPerInteger.get(IndiceCSVForLog).length()));
                    }
                }else{
                    MapErrorePerNRIGAFinal.put(IndiceCSVForLog,'KO - Row '+IndiceCSVForLog+' - ERRORE DI DATI_B: '+ErrorStringPerInteger.get(IndiceCSVForLog).substring(4,ErrorStringPerInteger.get(IndiceCSVForLog).length()));
                }
            }else{
                system.debug('******KOAcc');
                //Gestion OK
                IndirizziOK++;
                MapErrorePerNRIGAFinal.put(IndiceCSVForLog, 'OK - Row '+IndiceCSVForLog+' ['+MapIndirizziToUpsertPerIndice.get(IndiceCSVForLog).Id_Esterno__c+'] - Indirizzo Lavorato Correttamente');
            }
        }
        String MsgErrorForLog = '';
        set<Integer> IndiceForBuildLog = MapErrorePerNRIGAFinal.keyset();
        list<integer> IndiceLogCSV = new list<integer>(); 
        for(integer i : IndiceForBuildLog){
            IndiceLogCSV.add(i);
        }
        IndiceLogCSV.sort();
        map<Integer, String> MapResultIntegrationLog = new map<Integer, String>();
        String JsonResult;
        for(Integer IndiceOrdinato : IndiceLogCSV){
            MapResultIntegrationLog.put(IndiceOrdinato, MapErrorePerNRIGAFinal.get(IndiceOrdinato));
            JsonResult = Json.serialize(MapResultIntegrationLog);
            /*String LogResult = MapErrorePerNRIGAFinal.get(IndiceOrdinato);
            MsgErrorForLog+=LogResult+'\n';*/
        }
        
        // Aggiorno il Log che mi è stato passato in input
        LogToUpdate.Indirizzi_KO__c = IndirizziKO;   
        LogToUpdate.Indirizzi_OK__c = IndirizziOK;
        LogToUpdate.Indirizzi_TOT__c = IndirizziKO+IndirizziOK; 
        LogToUpdate.Integration_Result__c = JsonResult;
        LogToUpdate.Integration_processed__c = true;
        LogToUpdate.Inizio__c = DataInizio;
        if (Utils.cebCheckObjPermission('Log__c',gd).get('UPDATE ')
                && Utils.cebCheckFLSPermission('Log__c', 'Servizi_KO__c',gd).get('UPDATE')
            && Utils.cebCheckFLSPermission('Log__c', 'Servizi_OK__c',gd).get('UPDATE')
            && Utils.cebCheckFLSPermission('Log__c', 'Servizi_TOT__c',gd).get('UPDATE')
            && Utils.cebCheckFLSPermission('Log__c', 'Integration_Result__c',gd).get('UPDATE')
            && Utils.cebCheckFLSPermission('Log__c', 'Integration_processed__c',gd).get('UPDATE')
            && Utils.cebCheckFLSPermission('Log__c', 'Inizio__c',gd).get('UPDATE')) {
            update LogToUpdate;
        }
                                    
    }
}