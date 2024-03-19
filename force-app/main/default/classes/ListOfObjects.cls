/* ---------------------------------------------------------------------------------------------------------------------
Name:            ListOfObjects.cls
Description:
Test class:      TestListOfObjects.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
16-Sep-2022  0.2      R.Kurti & C.Sanna    Added WITH SECURITY ENFORCED, replaced CheckFLSPermission with cebCheckFLSPermission
                                           and added cebCheckObjPermission (security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class ListOfObjects
{
      public class ListOfObjectsException extends Exception{}
    /*--- Funzione per recuperare i campi dal custom setting ---*/
    public static List<String> GetFields(String obj){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        List<String> lfields = new List<String>();
        Map<String, ListOfFields__c> lof = ListOfFields__c.getall();
        List<String> keys = new List<String>(lof.keySet());
        keys.sort();
        for(String s : keys){
            ListOfFields__c l = lof.get(s);
            if(l.Object__c==obj && l.Show__c==true && !l.Name.startsWith('Pdf')){
                lfields.add(l.Field__c);
            }
        }
        return lfields;
    }
    /*--- Funzione per concatenarli in una stringa unica ---*/
    public static String ConcatenateFields(List<String> lfields){
        String concFields = '';
        Integer x = 1;
        for(String s : lfields){
            concFields = concFields + s;
            if(x<lfields.size())
                concFields = concFields + ',';
            else
                concFields = concFields + ' ';
            x++;
        }
        system.debug('***STRINGA CAMPI: ' + concFields);
        return String.isBlank(concFields)?'Id':concFields;
    } 
        
    /*--- Query con OFFSET per paginazione ---*/
    public List<Movimento__c> qMov_Offset(String oPadre, Id IdPadre, String TipoPadre, Integer lim, Integer off)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    String query = 'SELECT ';
        if(Utils.cebCheckObjPermission('Movimento__c',gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Movimento__c', 'Cartolarizzazione__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Movimento__c', 'Causale_Non_Sollecitabile__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Emissione__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Incasso__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Integrazione__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Pagamento__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Scadenza__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Movimento__c', 'Importo__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Movimento__c', 'Mese__c',gd).get('ACCESS'))
        {
            List<String> lFields = GetFields('Movimento__c');

            Set<String> setFields = new Set<String>();
            setFields.addAll(lFields);
            if( !setFields.contains('Account__r.Name') ){
                lFields.add('Account__r.Name');
            }
            if( !setFields.contains('Pratica__r.Name') ){
                lFields.add('Pratica__r.Name');
            }
            
            query = query + ConcatenateFields(lFields);

            query = query + ' FROM Movimento__c ';
            if(oPadre == 'Pratica') {
                query = query + ' where Pratica__c = :IdPadre ';
                if(TipoPadre == 'Consolidato')
                    query = query + ' AND RecordType.Name IN (\'SALDO MESE CONSOLIDATO\', \'INCASSO CONSOLIDATO\', \'SALDO ANNO\') ';
                if(TipoPadre == 'Saldo')
                    query = query + ' AND RecordType.Name = \'SALDO\'';
                if(TipoPadre == 'Incasso')
                    query = query + ' AND RecordType.Name = \'INCASSO\'';
                if(TipoPadre == 'EC')
                {
                    query = query + ' AND RecordType.Name IN (\'FATTURE\',\'INCASSO\',\'NOTE DI CREDITO\',\'NOTE DI DEBITO\',\'STORNI\',\'SCONTRINO\',\'ADDEBITO\')';
                }
            }    
            else if(oPadre == 'Cliente') {
                query = query + ' where Account__c =:IdPadre';
                if(TipoPadre == 'Consolidato')
                    query = query + ' AND RecordType.Name IN (\'SALDO MESE CONSOLIDATO\', \'INCASSO CONSOLIDATO\', \'SALDO ANNO\') ';
                if(TipoPadre == 'Saldo')
                    query = query + ' AND RecordType.Name = \'SALDO\'';
                if(TipoPadre == 'Incasso')
                    query = query + ' AND RecordType.Name = \'INCASSO\'';
                if(TipoPadre == 'EC')
                {
                    query = query + ' AND RecordType.Name IN (\'FATTURE\',\'INCASSO\',\'NOTE DI CREDITO\',\'NOTE DI DEBITO\',\'STORNI\',\'SCONTRINO\',\'ADDEBITO\')';
                }
            }
            query = query + ' order by Data_Scadenza__c DESC';
            //query = query + ' LIMIT '+ lim ;
            query = query + ' LIMIT :lim';
            //query = query + ' OFFSET '+off;
            query = query + ' OFFSET :off';
        }
            try{
                System.debug('QUERY:'+query);
                // inizio nuovo codice 13/04/17 inserimento check permission
                if(Utils.cebCheckObjPermission('Movimento__c',gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Movimento__c', 'Cartolarizzazione__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Causale_Non_Sollecitabile__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Emissione__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Incasso__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Integrazione__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Pagamento__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Scadenza__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Importo__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Mese__c',gd).get('ACCESS'))
                {
                    List<Movimento__c> lMvm = Database.query(query);
                    System.debug(LoggingLevel.INFO, 'MOVIMENTI OFFSET: Query eseguita');
                    return lMvm;
                }
                else return null;
                // fine nuovo codice 13/04/17 inserimento check permission
            }catch(Exception e){
                throw new ListOfObjectsException('Exception:'+Query);
            }
    }
    
    public List<Contact> qInd_Offset(String oPadre, Id IdPadre, Integer lim, Integer off)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    String query = 'SELECT ';
        if(Utils.cebCheckObjPermission('Contact',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Contact', 'Cap__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Contact', 'Casella_Postale__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Contact', 'Civico__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Contact', 'Comune__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Contact', 'Fallibilita__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Contact', 'Level__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Contact', 'Principale__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Contact', 'Scala__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Contact', 'StatoGaranzia__c',gd).get('ACCESS'))
        {
            List<String> lFields = GetFields('Contact');
            query = query + ConcatenateFields(lFields);
            query = query + ' FROM Contact ';
            if(oPadre == 'Cliente')
                query = query + 'where AccountId = :IdPadre ';
            query = query + 'order by CreatedDate DESC';
            query = query + ' LIMIT :lim ';
            query = query + ' OFFSET :off';
        // inizio nuovo codice 13/04/17 spostamento delle righe comprese tra commenti nel controllo check permission 
            List<Contact> lInd = Database.query(String.escapeSingleQuotes(query));
            System.debug(LoggingLevel.INFO, 'INDIRIZZI OFFSET: Query eseguita');
            return lInd;
        }
        else return null;
        // fine nuovo codice 13/04/17 spostamento delle righe comprese tra commenti nel controllo check permission
    }
    
    public List<Servizio__c> qSer_Offset(String oPadre, Id IdPadre, Integer lim, Integer off)
    {
         Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    String query = 'SELECT ';
        if(Utils.cebCheckObjPermission('Servizio__c',gd).get('ACCESS') &&
                Utils.cebCheckFLSPermission('Servizio__c', 'Contratto__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Servizio__c', 'Data_Fine_Contratto__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Servizio__c', 'Codice__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Servizio__c', 'Data_Inizio_Contratto__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Servizio__c', 'Id_SoftwareHouse__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Servizio__c', 'Metodo_di_Pagamento__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Servizio__c', 'Nome__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Servizio__c', 'POD__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Servizio__c', 'Stato__c',gd).get('ACCESS'))
        {
            List<String> lFields = GetFields('Servizio__c');
            query = query + ConcatenateFields(lFields);
            query = query + ' FROM Servizio__c ';
            if(oPadre == 'Cliente')
                query = query + 'where Account__c = :IdPadre ';
            query = query + 'order by CreatedDate DESC';
            query = query + ' LIMIT :lim ';
            query = query + ' OFFSET :off';
            // inizio nuovo codice 13/04/17 spostamento delle righe comprese tra commenti nel controllo check permission
            List<Servizio__c> lSer = Database.query(String.escapeSingleQuotes(query));
            System.debug(LoggingLevel.INFO, 'SERVIZI OFFSET: Query eseguita');
            return lSer;
        }
        else return null;
        // fine nuovo codice 13/04/17 spostamento delle righe comprese tra commenti nel controllo check permission 

    }
    
    public List<Pratica__c> qPrat_Offset(String oPadre, Id IdPadre, Integer lim, Integer off)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        String query = 'SELECT ';
        if(Utils.cebCheckObjPermission('Pratica__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Anzianit_Pratica__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'byPassRole__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Check_In_Lavorazione__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Esecuzione_Processo_Mensile__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Blocco__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Chiusura__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_inizio_scaduto__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Data_Ultimo_Saldo__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Pratica__c', 'Esci_e_chiudi__c',gd).get('ACCESS'))
        {
            List<String> lFields = GetFields('Pratica__c');
            query = query + ConcatenateFields(lFields);       
            query = query + 'From Pratica__c ';
            query = query + 'where Account__c = :IdPadre ';
            query = query + 'order by CreatedDate Desc';
            query = query + ' LIMIT :lim ';
            query = query + ' OFFSET :off';
            // inizio nuovo codice 13/04/17 spostamento delle righe comprese tra commenti nel controllo check permission 
            List<Pratica__c> lPrat = Database.query(String.escapeSingleQuotes(query));
            System.debug(LoggingLevel.INFO, 'PRATICHE OFFSET: Query eseguita');
            return lPrat;
        }
        else return null;
        // fine nuovo codice 13/04/17 spostamento delle righe comprese tra commenti nel controllo check permission 
    }
    
    public List<Piano_di_Rientro__c> qPDR_Offset(String oPadre, Id IdPadre, Integer lim, Integer off)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        String query = 'SELECT ';
        if(Utils.cebCheckObjPermission('Piano_di_Rientro__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Data_Stipula_Piano__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Importo_Rata__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Importo_Totale__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Numero_di_Rate__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Piano_di_Rientro__c', 'Stato__c',gd).get('ACCESS'))
        {
            List<String> lFields = GetFields('Piano_di_Rientro__c');
            query = query + ConcatenateFields(lFields);
            query = query + 'From Piano_di_Rientro__c ';
            if(oPadre == 'Pratica')
                query = query + 'where Pratica__c = :IdPadre ';
            else if(oPadre == 'Cliente')
                query = query + 'where Pratica__r.Account__c = :IdPadre ';
            query = query + 'order by CreatedDate Desc';
            query = query + ' LIMIT :lim ';
            query = query + ' OFFSET :off';
            // inizio nuovo codice 13/04/17 spostamento delle righe comprese tra commenti nel controllo check permission 
            List<Piano_di_Rientro__c> lPdR = Database.query(String.escapeSingleQuotes(query));
            System.debug(LoggingLevel.INFO, 'PIANI DI RIENTRO OFFSET: Query eseguita');
            return lPdR;
        }
        else return null;
        // fine nuovo codice 13/04/17 spostamento delle righe comprese tra commenti nel controllo check permission 
    }

    public List<Attachment> qAtt_Offset(String oPadre, Id IdPadre, Integer lim, Integer off)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        String query = 'Select ';
        List<String> lFields = GetFields('Attachment');
        query = query + ConcatenateFields(lFields);
        query = query + 'From Attachment ';
        if(oPadre == 'Pratica'){
            //if(Utils.cebCheckFLSPermission('Pratica__c','Account__c').get('ACCESS') && Utils.cebCheckFLSPermission('Pratica__c','Name').get('ACCESS')){
                Pratica__c tempP = [SELECT Id,Account__c,Name FROM Pratica__c WHERE Id = :idPadre WITH SECURITY_ENFORCED LIMIT 1];
                String acc = tempP.Account__c;
                query = query + 'where (ParentId = :acc AND Name LIKE \'%'+String.escapeSingleQuotes(tempP.Name)+'%\') OR ParentId =:IdPadre ';

            /*Pratica__c prat = [SELECT Id,Account__c,Name FROM Pratica__c WHERE Id =: IdPadre LIMIT 1];
            String acc = prat.Account__c;
            query = query + 'where ParentId = :acc AND Name LIKE \'%_'+prat.Name+'_%\'';*/
        }else if(oPadre == 'Cliente'){
            query = query + 'where ParentId = :IdPadre ';
        }
        query = query + 'order by CreatedDate Desc';
        query = query + ' LIMIT :lim ';
        query = query + ' OFFSET :off';
        // inizio nuovo codice 13/04/17 inserimento check permission
        if (Utils.cebCheckObjPermission('Attachment', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Attachment','ParentId',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Attachment','body',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Attachment','Name',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Attachment','IsPrivate',gd).get('ACCESS'))
        {
            List<Attachment> lAtt = Database.query(query);
            System.debug(LoggingLevel.INFO, 'ATTACHMENT OFFSET: Query eseguita');
            return lAtt;
        }
        else return null;
        // fine nuovo codice 13/04/17 inserimento check permission
    }
    
    public List<Task> qTsk_Offset(String oPadre, Id IdPadre, Integer lim, Integer off)
    {

        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        String query = 'SELECT ';
        if(Utils.cebCheckObjPermission('Task', gd).get('ACCESS') && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Count_of_Events__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Count_of_Tasks__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Giorni_di_completamento_attivita__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Giorni_Fuori_SLA__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'SLA__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Task', 'Tipo_esecuzione__c',gd).get('ACCESS'))
        {
            List<String> lFields;
            if(oPadre == 'MyTask')
               lFields = GetFields('MyTask');
            else
               lFields = GetFields('Task');
            query = query + ConcatenateFields(lFields);
            query = query + 'FROM Task ';
            query = query + 'where Type = \'Credito\'';
            if(oPadre == 'Pratica')
                query = query + 'AND whatId = :IdPadre ';
            else if(oPadre == 'Cliente')
                query = query + 'AND ActivityExtended__r.IdAccount__c = :IdPadre ';
            else if (oPadre == 'MyTask')
               query = query + ' AND OwnerId= \'' + UserInfo.getUserId() + '\' AND ActivityExtended__r.Strategia__c = \'Manuale\' AND Status!=\'Completed\' ';
            query = query + 'order by CreatedDate Desc';
            query = query + ' LIMIT :lim ';
            query = query + ' OFFSET :off';
            // inizio nuovo codice 13/04/17 spostamento delle righe comprese tra commenti nel controllo check permission 
            List<Task> lTsk = Database.query(query);
            System.debug(LoggingLevel.INFO, 'TASK OFFSET: Query eseguita');
            return lTsk;
        }
        else return null;
        // fine nuovo codice 13/04/17 spostamento delle righe comprese tra commenti nel controllo check permission 
    }
    
    public List<Servizi_Item__c> qSItem_Offset(String oPadre, Id IdPadre, Integer lim, Integer off)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        String query = 'Select ';
        List<String> lFields = GetFields('Servizi_Item__c');
        query = query + ConcatenateFields(lFields);
        query = query + 'From Servizi_Item__c ';
        if(oPadre == 'Pratica')    
            query = query + 'where Servizio__c = :IdPadre ';
        else if(oPadre == 'Cliente')
            query = query + 'where Servizio__r.Account__c = :IdPadre ';
        query = query + 'order by CreatedDate Desc';
        query = query + ' LIMIT :lim ';
        query = query + ' OFFSET :off';
        // inizio nuovo codice 13/04/17 inserimento check permission
        if(Utils.cebCheckObjPermission('Servizi_Item__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Servizi_Item__c', 'Nome__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Servizi_Item__c', 'Codice__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Servizi_Item__c', 'Note__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Servizi_Item__c', 'Id_Esterno__c',gd).get('ACCESS'))
        {
            List<Servizi_Item__c> lSItem = Database.query(String.escapeSingleQuotes(query));
            system.debug(LoggingLevel.INFO, 'SERVIZI ITEM OFFSET: Query eseguita');
            return lSItem;
        }
        else return null;
        // fine nuovo codice 13/04/17 inserimento check permission
    }
    
    /*
     * Modificata da: Endrit Sino
     */
    
    public List<Affidamento__c> qAff_Offset(String oPadre, Id IdPadre, Integer lim, Integer off)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        System.debug('\n *Inizio qAff_Offset!!!');
        String query = 'Select ';
        if(Utils.cebCheckObjPermission('Affidamento__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Affidamento__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_chiusura_effettiva__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Revoca__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_Richiesta_Proroga__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Affidamento__c', 'E_richiesta_una_proroga__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Affidamento__c', 'Esito_Lavorazione__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Affidamento__c', 'Giorni_di_proroga__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Affidamento__c', 'id_Task_associato__c',gd).get('ACCESS'))
        {
            List<String> lFields = GetFields('Affidamento__c');
            //System.debug('\n Campi restituiti: ' + lFields);
            
            // i campi, via hard-code(E.S.)
            //query += ' id, Name, Stato__c, Data_Affidamento__c, Data_Fine_Affidamento__c, Nome_Collector__c ';
             
            query = query + ConcatenateFields(lFields);
            query = query + ' From Affidamento__c ';
            if(oPadre == 'Pratica')
                query = query + ' where Pratica__c = :IdPadre ';
            query = query + ' order by CreatedDate Desc';
            query = query + ' LIMIT :lim ';
            query = query + ' OFFSET :off';
        // inizio nuovo codice 13/04/17 spostamento delle righe comprese tra commenti nel controllo check permission     
            List<Affidamento__c> lAff = Database.query(String.escapeSingleQuotes(query));
            System.debug(LoggingLevel.INFO, 'AFFIDAMENTI OFFSET: Query eseguita');
            return lAff;
        }
        
        else return null;
        // fine nuovo codice 13/04/17 spostamento delle righe comprese tra commenti nel controllo check permission 
    }

    /*--- Query con COUNT per paginazione ---*/
    public Integer qMov_Count(String oPadre, Id IdPadre, String TipoPadre)
    {    
        String query = 'SELECT ';
        query = query + 'count() ';
        query = query + 'FROM Movimento__c ';
        if(oPadre == 'Pratica') {
            query = query + 'where Pratica__c = :IdPadre ';
            if(TipoPadre == 'Consolidato')
                query = query + 'AND RecordType.Name IN (\'Saldo Consolidato\', \'Incasso Consolidato\', \'Saldo Fruitore Consolidato\') ';
            if(TipoPadre == 'Saldo')
                query = query + 'AND RecordType.Name = \'SALDO\'';
            if(TipoPadre == 'Incasso')
                query = query + 'AND RecordType.Name = \'INCASSO\'';
            if(TipoPadre == 'EC')
            {
                query = query + ' AND RecordType.Name IN (\'FATTURE\',\'INCASSO\',\'NOTE DI CREDITO\',\'NOTE DI DEBITO\',\'STORNI\',\'SCONTRINO\',\'ADDEBITO\')';
            }
        }
        else if(oPadre == 'Cliente') {
            query = query + 'where Account__c = :IdPadre ';
            if(TipoPadre == 'Consolidato')
                query = query + 'AND RecordType.Name IN (\'Saldo Consolidato\', \'Incasso Consolidato\', \'Saldo Fruitore Consolidato\') ';
            if(TipoPadre == 'Saldo')
                query = query + 'AND RecordType.Name = \'SALDO\'';
            if(TipoPadre == 'Incasso')
                query = query + 'AND RecordType.Name = \'INCASSO\'';
            if(TipoPadre == 'EC')
            {
                query = query + ' AND RecordType.Name IN (\'FATTURE\',\'INCASSO\',\'NOTE DI CREDITO\',\'NOTE DI DEBITO\',\'STORNI\',\'SCONTRINO\',\'ADDEBITO\')';
            }
        }
        
        Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        
        //use remainingRows-100 to leave 100 query rows available for next queries during the same transaction 
        remainingRows = Math.min(remainingRows-100, 2000);
        
        query += ' LIMIT :remainingRows';

        Integer i = Database.countQuery(query);
        system.debug(LoggingLevel.INFO, 'MOVIMENTI COUNT: Query eseguita');
        /*if(i>100){
            i = 100;}*/
        return i;
    }
    
    public Integer qPrat_Count(String oPadre, Id IdPadre)
    {
        String query = 'SELECT ';
        query = query + 'count() ';
        query = query + 'From Pratica__c ';
        query = query + 'where Account__c = :IdPadre ';
        if(oPadre != 'Cliente')
            query = query + ' LIMIT 100';

        Integer i = Database.countQuery(query);
        system.debug(LoggingLevel.INFO, 'PRATICHE COUNT: Query eseguita');
        return i;
    }

    public Integer qPDR_Count(String oPadre, Id IdPadre)
    {
        String query = 'SELECT ';
        query = query + 'count() ';
        query = query + 'From Piano_di_Rientro__c ';
        if(oPadre == 'Pratica')
            query = query + 'where Pratica__c = :IdPadre ';
        else if(oPadre == 'Cliente')
            query = query + 'where Pratica__r.Account__c = :IdPadre ';
            
        Integer i = Database.countQuery(query);
        system.debug(LoggingLevel.INFO, 'PIANI DI RIENTRO COUNT: Query eseguita');
        return i;
    }
    
    
    public Integer qAtt_Count(String oPadre, Id IdPadre)
    {
        String query = 'SELECT ';
        query = query + 'count() ';
        query = query + 'From Attachment ';
        if(oPadre == 'Pratica'){
            //if(Utils.cebCheckFLSPermission('Pratica__c','Account__c').get('ACCESS') && Utils.cebCheckFLSPermission('Pratica__c','Name').get('ACCESS')){
                Pratica__c tempP = [SELECT Id,Account__c,Name FROM Pratica__c WHERE Id = :idPadre WITH SECURITY_ENFORCED LIMIT 1];
                String acc = tempP.Account__c;
                query = query + 'where (ParentId = :acc AND Name LIKE \'%'+String.escapeSingleQuotes(tempP.Name)+'%\') OR ParentId =:IdPadre';

        }else if(oPadre == 'Cliente'){
            query = query + 'where ParentId = :IdPadre ';
        }
        
        Integer i = Database.countQuery(query);
        system.debug(LoggingLevel.INFO, 'ATTACHMENT COUNT: Query eseguita');
        return i;
    }
    
    public Integer qTsk_Count(String oPadre, Id IdPadre)
    {
        String query = 'SELECT ';
        query = query + 'count() ';
        query = query + 'FROM Task ';
        query = query + 'where Type = \'Credito\'';
        if(oPadre == 'Pratica')
            query = query + 'AND whatId = :IdPadre ';
        else if(oPadre == 'Cliente')
            query = query + 'AND ActivityExtended__r.IdAccount__c = :IdPadre ';
        else if (oPadre == 'MyTask')
        {
            String IdUtente = String.escapeSingleQuotes(UserInfo.getUserId());
            query = query + ' AND OwnerId= \'' + IdUtente + '\' AND ActivityExtended__r.Strategia__c = \'Manuale\' AND Status!=\'Completed\' ';
            //query = query + ' AND OwnerId= \'' + UserInfo.getUserId() + '\' AND ActivityExtended__r.Strategia__c = \'Manuale\' AND Status!=\'Completed\' ';
        }
        Integer i = Database.countQuery(query);
        system.debug(LoggingLevel.INFO, 'TASK COUNT: Query eseguita');
        return i;
    }
    
    public Integer qAff_Count(String oPadre, Id IdPadre)
    {
        String query = 'SELECT ';
        query = query + 'count() ';
        query = query + 'From Affidamento__c ';
        if(oPadre == 'Pratica')
            query = query + 'where Pratica__c = :IdPadre ';
        
        Integer i = Database.countQuery(query);
        system.debug(LoggingLevel.INFO, 'AFFIDAMENTI COUNT: Query eseguita');
        return i;
    }
    
    public Integer qInd_Count(String oPadre, Id IdPadre)
    {
        String query = 'SELECT ';
        query = query + 'count() ';
        query = query + 'From Contact ';
        if(oPadre == 'Cliente')
            query = query + 'where AccountId = :IdPadre ';
        
        Integer i = Database.countQuery(query);
        system.debug(LoggingLevel.INFO, 'INDIRIZZI COUNT: Query eseguita');
        return i;
    }
    
    public Integer qSer_Count(String oPadre, Id IdPadre)
    {
        String query = 'SELECT ';
        query = query + 'count() ';
        query = query + 'From Servizio__c ';
        if(oPadre == 'Cliente')
            query = query + 'where Account__c = :IdPadre ';
        
        Integer i = Database.countQuery(query);
        system.debug(LoggingLevel.INFO, 'SERVIZI COUNT: Query eseguita');
        return i;
    }
    
    public Integer qSItem_Count(String oPadre, Id IdPadre)
    {
        String query = 'SELECT ';
        query = query + 'count() ';
        query = query + 'From Servizi_Item__c ';
        if(oPadre == 'Cliente')
            query = query + 'where Servizio__r.Account__c = :IdPadre ';
        if(oPadre == 'Pratica')    
            query = query + 'where Servizio__c = :IdPadre ';
        Integer i = Database.countQuery(query);
        system.debug(LoggingLevel.INFO, 'SERVIZI ITEM COUNT: Query eseguita');
        return i;
    }
    
    /*---------------*/
    public List<Nota__c> qNote(String oPadre, Id IdPadre)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        String query = 'Select Id, LastModifiedDate, RecordType.Name, Nota__c, CreatedBy.Name, CreatedBy.FullPhotoUrl ';
        query = query + 'From Nota__c ';
        if(oPadre == 'Pratica')
            query = query + 'where Pratica__c = :IdPadre ';
        query = query + 'order by CreatedDate Desc';
        if(oPadre != 'Pratica')
            query = query + ' LIMIT 100';
        // inizio nuovo codice 13/04/17 inserimento check permission    
        if(Utils.cebCheckObjPermission('Nota__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Nota__c', 'Nota__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Nota__c', 'RecordTypeId',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Nota__c', 'Pratica__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Nota__c', 'Max_Note__c',gd).get('ACCESS')
            && Utils.cebCheckFLSPermission('Nota__c', 'Current_Note__c',gd).get('ACCESS'))
        {
            List<Nota__c> lNote = Database.query(String.escapeSingleQuotes(query));
            system.debug(LoggingLevel.INFO, 'NOTE: Query eseguita');
            return lNote;
        }
        else return null;
        // fine nuovo codice 13/04/17 inserimento check permission
    }
}