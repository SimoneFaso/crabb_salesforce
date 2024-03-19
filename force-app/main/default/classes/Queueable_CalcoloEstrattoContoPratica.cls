/* ---------------------------------------------------------------------------------------------------------------------
Name:            Queueable_CalcoloEstrattoContoPratica.cls
Description:
Test class:      TestQueueableCalcoloEstrattoContoPratica.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
15-Dec-2021  0.2      Claudio Sanna                   Modified queries for calcola_ec_account() and calcola_ec_pratiche()
                                                      to be able to filter Transactions based on Expired Amount Type,
                                                      by setting the field CRABB_DEV__tipo_scadenza_movimenti__c
                                                      on CRABB_DEV__mapping_status_pratica__mdt
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class Queueable_CalcoloEstrattoContoPratica implements Queueable
{
    private Set<Id> triggeringPraticas;
    private Set<Id> relatedAccounts;
    private Map<Id, List<Movimento__c>> movimentiPerPratica;
    private Map<Id, List<Movimento__c>> movimentiPerAccount;
    private Map<Id, Set<Id>> pratichePerAccount;
    private Map<Integer,String> mFieldsOrder;
    private boolean showNegativeTransaction = false;
    private static final Map<String, String> fieldsToExtract = getFieldsToExtract();
    private static final Integer ECA_maxLength = Pratica__c.EC_Account__c.getDescribe().getLength();
    private static final Integer ECP_maxLength = Pratica__c.EC_Pratica__c.getDescribe().getLength();
    private static final ID movimentoFattura = Movimento__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Fatture').getRecordTypeId();
    private static final Set<String> praticaAperta = getStatusList('CRABB_DEV__stati_in_lavorazione__c');
    private static final Set<String> tipoScadenzaMovimenti = getStatusList('CRABB_DEV__tipo_scadenza_movimenti__c');

    public Queueable_CalcoloEstrattoContoPratica(Set<Id> tp, Set<Id> ra)
    {
        //System.debug('Queueable_CalcoloEstrattoContoPratica - Start');
        List<Integer> lInt = new List<Integer>();
        triggeringPraticas = tp;
        relatedAccounts = ra;

        movimentiPerPratica = new Map<Id, List<Movimento__c>>();
        movimentiPerAccount = new Map<Id, List<Movimento__c>>();
        pratichePerAccount = new Map<Id,Set<Id>>();

        Map<String,ListOfFields__c> mapFields = ListOfFields__c.getAll();
        mFieldsOrder = new Map<Integer,String>();
        Map<Integer,String> mFieldsOrderTemp = new Map<Integer,String>();
        for(String str : mapFields.keySet()){
            Boolean isPdf, isShow, isMov;
            isPdf = mapFields.get(str).Name.startsWith('Pdf_');
            isShow = mapFields.get(str).Show__c;
            isMov = mapFields.get(str).Object__c.equalsIgnoreCase('Movimento__c');

            if(isPdf && isShow && isMov)
            {
                List<String> lString = mapFields.get(str).Name.split('_');
                mFieldsOrderTemp.put(Integer.valueOf(lString[lString.size()-1]),mapFields.get(str).Field__c);
                lInt.add(Integer.valueOf(lString[lString.size()-1]));
            }
        }
        //System.debug('lInt No Sort: ' + lInt);
        lInt.sort();
        //System.debug('lInt Sort: ' + lInt);
        //System.debug('mFieldsOrderTemp: ' + mFieldsOrderTemp);
        Integer x = 0;
        for(Integer i: lInt)
        {
            mFieldsOrder.put(x,mFieldsOrderTemp.get(i));
            x++;
        }
        //System.debug('mFieldsOrder: ' + mFieldsOrder);
        String devName = 'general';
        String query = 'select ' + Utils.NAMESPACE+ 'Show_Negative_Transaction__c  from ' + Utils.NAMESPACE+'CRABB_General_Settings__mdt where developername= :devName';
        List<CRABB_General_Settings__mdt> listObj = (List<CRABB_General_Settings__mdt>) database.Query(query);
        if(listObj.size() > 0) {
            if (listObj[0].Show_Negative_Transaction__c)
                showNegativeTransaction = true;
        }
        //System.debug('listObj ---> ' + listObj);
        //System.debug('triggeringPraticas ---> ' + triggeringPraticas);
        //System.debug('relatedAccounts ---> ' + relatedAccounts);
        //System.debug('mFieldsOrder ---> ' + mFieldsOrder);
        //System.debug('showNegativeTransaction ---> ' + showNegativeTransaction);
        //System.debug('Queueable_CalcoloEstrattoContoPratica - End');
        
        //System.debug('Queueable_CalcoloEstrattoContoPratica - End');
    }
    
    public void execute(QueueableContext context) 
    {
        //System.debug('execute --> START');
        
        Map<Id, String> ec_account = calcola_ec_account();
        Map<Id, String> ec_pratica = calcola_ec_pratiche();
        //system.debug('recordtypeid-- ' + movimentoFattura);
        Map<Id, Pratica__c> praticheToCommit = new Map<Id, Pratica__c>();
        for(Id pId : ec_account.keySet()){
            if(!praticheToCommit.containsKey(pId)) praticheToCommit.put(pId, new Pratica__c(Id = pId));
            (praticheToCommit.get(pId)).EC_Account__c = ec_account.get(pId);
        }

        for(Id pId : ec_pratica.keySet()){
            if(!praticheToCommit.containsKey(pId)) praticheToCommit.put(pId, new Pratica__c(Id = pId));
            (praticheToCommit.get(pId)).EC_Pratica__c = ec_pratica.get(pId);
        }

        if(Utils.checkObjPermission('Pratica__c').get('UPDATE')){
            if(!praticheToCommit.isEmpty()) update praticheToCommit.values();
        }
        
        //System.debug('execute --> END');
    }
    
    private Map<Id, String> calcola_ec_account() 
    {
        //System.debug('calcola_ec_account --> START');
        
        Map<Id, String> ec_account = new Map<Id, String>();
        Set<String> extractedFields = new Set<String>{
                'Pratica__c', 'Account__c'
        };
        extractedFields.addAll(fieldsToExtract.keySet());
        String query = 'SELECT ' + formatForQuery(fieldsToExtract.keySet()) + ' Pratica__c, Account__c  FROM Movimento__c WHERE Account__c IN :relatedAccounts';
        if (showNegativeTransaction) {
            query += ' AND Sollecitabile__c = true AND Importo__c != 0 AND Residuo__c != 0 AND RecordTypeId = :movimentoFattura AND Pratica__r.Stato__c IN :praticaAperta AND Tipo_Scadenza__c IN:tipoScadenzaMovimenti';
        }
        else {
            query += ' AND Sollecitabile__c = true AND Importo__c > 0 AND Residuo__c > 0 AND RecordTypeId = :movimentoFattura AND Pratica__r.Stato__c IN :praticaAperta';
        }
        query += ' WITH SECURITY_ENFORCED ORDER BY Data_Emissione__c,Data_Scadenza__c DESC';
        /*if (showNegativeTransaction)
            query += ' AND Sollecitabile__c = true AND Importo__c != 0 AND Residuo__c != 0 AND RecordTypeId = :movimentoFattura AND Pratica__r.Stato__c IN :praticaAperta'; else
                query += ' AND Sollecitabile__c = true AND Importo__c > 0 AND Residuo__c > 0 AND RecordTypeId = :movimentoFattura AND Pratica__r.Stato__c IN :praticaAperta';
        query += ' WITH SECURITY_ENFORCED ORDER BY Data_Emissione__c,Data_Scadenza__c DESC';*/

        System.debug('query --> ' + query);
        for (Movimento__c m : (List<Movimento__c>) Database.query(query)) {
            //if(!movimentiPerAccount.containsKey(m.Pratica__c))
            if (!movimentiPerAccount.containsKey(m.Account__c)) {
                //movimentiPerAccount.put(m.Pratica__c, new List<Movimento__c>());
                //System.debug('Pratica: ' + m.Pratica__c);
                pratichePerAccount.put(m.Account__c, new Set<Id>());
                movimentiPerAccount.put(m.Account__c, new List<Movimento__c>());
            }

            //(movimentiPerAccount.get(m.Pratica__c)).add(m);
            (pratichePerAccount.get(m.Account__c)).add(m.Pratica__c);
            (movimentiPerAccount.get(m.Account__c)).add(m);
        }

        //System.debug(movimentiPerAccount); 

        //for(Id pId : movimentiPerAccount.keySet())
        for (Id aId : movimentiPerAccount.keySet()) {
            String htmlTable = formatForHtml(movimentiPerAccount.get(aId), ECA_maxLength);
            for (Id pId : pratichePerAccount.get(aId))
                ec_account.put(pId, htmlTable);
            System.debug('Movimenti: ' + formatForHtml(movimentiPerAccount.get(aId), ECA_maxLength));
        }

        for(String str : ec_account.keySet())
            System.debug('################### pratichePerAccount --> ' + ec_account.get(str));
        
        return ec_account;
    }
    
    private Map<Id, String> calcola_ec_pratiche() {
        Map<Id, String> ec_pratica = new Map<Id, String>();

        Set<String> extractedFields = new Set<String>{
                'Pratica__c'
        };
        extractedFields.addAll(fieldsToExtract.keySet());

        String query = 'SELECT ' + formatForQuery(fieldsToExtract.keySet()) + ' Pratica__c   FROM Movimento__c WHERE Pratica__c IN :triggeringPraticas';
        //query += ' AND Pratica__r.Stato__c IN :praticaAperta AND Sollecitabile__c = true AND Residuo__c > 0 AND Importo__c > 0 AND RecordTypeId = :movimentoFattura ORDER BY Data_Emissione__c,Data_Scadenza__c DESC';
        if (showNegativeTransaction) {
            query += ' AND Pratica__r.Stato__c IN :praticaAperta AND Sollecitabile__c = true AND Residuo__c != 0 AND Importo__c != 0 AND RecordTypeId = :movimentoFattura AND Tipo_Scadenza__c IN:tipoScadenzaMovimenti WITH SECURITY_ENFORCED ORDER BY Data_Emissione__c,Data_Scadenza__c DESC';
        }
        else {
            query += ' AND Pratica__r.Stato__c IN :praticaAperta AND Sollecitabile__c = true AND Residuo__c > 0 AND Importo__c > 0 AND RecordTypeId = :movimentoFattura WITH SECURITY_ENFORCED ORDER BY Data_Emissione__c,Data_Scadenza__c DESC';
        }
        /*    if (showNegativeTransaction)
                query += ' AND Pratica__r.Stato__c IN :praticaAperta AND Sollecitabile__c = true AND Residuo__c != 0 AND Importo__c != 0 AND RecordTypeId = :movimentoFattura WITH SECURITY_ENFORCED ORDER BY Data_Emissione__c,Data_Scadenza__c DESC'; else
                    query += ' AND Pratica__r.Stato__c IN :praticaAperta AND Sollecitabile__c = true AND Residuo__c > 0 AND Importo__c > 0 AND RecordTypeId = :movimentoFattura WITH SECURITY_ENFORCED ORDER BY Data_Emissione__c,Data_Scadenza__c DESC';
        */
        for (Movimento__c m : (List<Movimento__c>) Database.query(query)) {
            if (!movimentiPerPratica.containsKey(m.Pratica__c)) movimentiPerPratica.put(m.Pratica__c, new List<Movimento__c>());
            (movimentiPerPratica.get(m.Pratica__c)).add(m);
        }


        for (Id pId : movimentiPerPratica.keySet()) ec_pratica.put(pId, formatForHtml(movimentiPerPratica.get(pId), ECP_maxLength));

        return ec_pratica;
    }
    
    private static Map<String, String> getFieldsToExtract()
    {
        Map<String, String> fields = new Map<String, String>();
        Map<String,ListOfFields__c> mapFields = ListOfFields__c.getAll();
        //mFieldsOrder = Map<Integer,String>();

        for(String str : mapFields.keySet()){
            Boolean isPdf, isShow, isMov;
            isPdf = mapFields.get(str).Name.startsWith('Pdf_');
            isShow = mapFields.get(str).Show__c;
            isMov = mapFields.get(str).Object__c.equalsIgnoreCase('Movimento__c');

            if(isPdf && isShow && isMov)
            {
                fields.put(mapFields.get(str).Field__c, mapFields.get(str).Field_Label__c);
                //mFieldsOrder.put(Integer.valueOf(mapFields.get(str).Name),mapFields.get(str).Field__c);
            }
        }
        //System.debug('mFieldsOrder: ' + mFieldsOrder);
        return fields;
    }
    
    private String formatForQuery(Set<String> ss)
    {
        if(fieldsToExtract.keySet().toString().removeStart('{').removeEnd('}') == null
                || fieldsToExtract.keySet().toString().removeStart('{').removeEnd('}') == '')
            return '';
        else
            return fieldsToExtract.keySet().toString().removeStart('{').removeEnd('}') + ',';
    }
    
    private String formatForHtml(List<Movimento__c> lm, Integer maxSize){
        //String htmlString = '<BR/><table style="width:70%;text-align: center; border-collapse:collapse;" border="1">';
        String htmlString = '<BR/><table style="margin-left: auto; margin-right:auto;width:80%;text-align: center; border-collapse:collapse;" border="1">';

        //creazione header
        htmlString += '<tr>';
        /*for(String apiName : fieldsToExtract.keySet()){
            if(apiName == 'RecordType.Name') htmlString += '<th>Tipologia</th>';
            else htmlString += ('<th>' + fieldsToExtract.get(apiName) + '</th>');
        }*/
        for(Integer i : mFieldsOrder.keySet())
        {
            String apiName = mFieldsOrder.get(i);
            if(apiName == 'RecordType.Name')
                htmlString += '<th>Tipologia</th>';
            else
                    htmlString += ('<th>' + fieldsToExtract.get(apiName) + '</th>');
        }
        htmlString += '</tr>';

        //popolamento delle informazioni
        for(Movimento__c m : lm){
            String newRow = '<tr>';
            /*for(String f : fieldsToExtract.keySet()){
                if(f == 'RecordType.Name') newRow += ('<td>' + m.RecordType.Name + '</td>');
                else newRow += ('<td>' + m.get(f) + '</td>');
            }*/

            Map<String, Schema.SObjectField> tempMapFields = Schema.getGlobalDescribe().get('CRABB_DEV__Movimento__c').getDescribe().fields.getMap();

            for(Integer i : mFieldsOrder.keySet())
            {

                String apiName = mFieldsOrder.get(i);


                if(apiName == 'RecordType.Name')
                    newRow += ('<td>' + m.RecordType.Name + '</td>');
                else
                {
                    String apiNameDesc = apiName;
                    if(apiNameDesc.right(3) == '__c')
                        apiNameDesc = 'CRABB_DEV__' + apiName;
                    System.debug(apiNameDesc);

                    Schema.DescribeFieldResult dfr = tempMapFields.get(apiNameDesc).getDescribe();
                    String fld = dfr.getName();
                    Schema.SoapType tempSoap = dfr.getSOAPType();

                    if(tempSoap.name().equalsIgnoreCase('Date'))
                    {
                        Date d = Date.valueOf(m.get(apiName));
                        String dayString = d.format();
                        newRow += ('<td>' + dayString + '</td>');
                    }
                    else
                            newRow += ('<td>' + m.get(apiName) + '</td>');
                }
            }
            newRow += '</tr>';

            if(newRow.length() > maxSize - htmlString.length()) break;
            else htmlString += newRow;
        }

        return (htmlString += '</table>');
    }
    
    //returns a list of picklist values with closed or open status
    public static Set<String> getStatusList(String s) {
        List<String> statusList = new List<String>();
        List<SObject> mappingStatusList = new List<SObject>();
        String lbl = 'stati_pratiche_EC';
        String query2 = 'SELECT ' + String.escapeSingleQuotes(s) +' FROM CRABB_DEV__mapping_status_pratica__mdt where label =:lbl WITH SECURITY_ENFORCED';
        mappingStatusList = Database.query(query2);
        statusList = String.valueOf(mappingStatusList.get(0).get(s)).split('\\|');

        return new Set<String>(statusList);
    }
}