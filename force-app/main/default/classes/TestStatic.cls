/*
* CreatedBy: KMeta
* CreatedDate:31/July/2014
* Description: Questa classe contiene dei metodi di utility statici per la classi di test
*/

@isTest
public class TestStatic {
    /*Rule control generation */
    public static testMethod void generaRuleControl() {
        List<Rule_Control__c> rcList = new List<Rule_control__c>();
        rcList.add(new Rule_control__c (name = 'R1', Api_field_name__c = 'Numero_figli__c', Api_object_name__c = 'Pratica__c', Condition__c = '>', Rule_name__c = 'Numero di figli maggiore', Strategia_api_field_name__c = 'Numero_figli__c'));
        rcList.add(new Rule_control__c (name = 'R2', Api_field_name__c = 'Importo_Scaduto_Consolidato__c', Api_object_name__c = 'Pratica__c', Condition__c = '<', Rule_name__c = 'Scaduto consolidato', Strategia_api_field_name__c = 'Scaduto__c'));
        rcList.add(new Rule_control__c (name = 'R3', Api_field_name__c = 'Giorni_trascorsi_dall_ultima_AR__c', Api_object_name__c = 'Pratica__c', Condition__c = '<=', Rule_name__c = 'Invio celere della AR', Strategia_api_field_name__c = 'Giorni_trascorsi_dall_ultima_AR__c'));
        rcList.add(new Rule_control__c (name = 'R4', Api_field_name__c = 'Classe_di_rischio__c', Api_object_name__c = 'Pratica__c', Condition__c = 'IsIncluded', Rule_name__c = 'Classe di rischio è inclussa', Strategia_api_field_name__c = 'Classe_di_rischio__c'));
        rcList.add(new Rule_control__c (name = 'R5', Api_field_name__c = 'Scelta_utente__c', Api_object_name__c = 'Task', Condition__c = '=', Rule_name__c = 'Task: Scelta utente uguale', Strategia_api_field_name__c = 'Scelta_utente__c'));
        rcList.add(new Rule_control__c (name = 'R6', Api_field_name__c = 'Comune__c', Api_object_name__c = 'pratica__c', Condition__c = '!=', Rule_name__c = 'Comune diverso', Strategia_api_field_name__c = 'Comune__c'));
        rcList.add(new Rule_control__c (name = 'R7', Api_field_name__c = 'Residuo_Totale__c', Api_object_name__c = 'Pratica__c', Condition__c = '>=', Rule_name__c = 'creato per Strattegia appalto', Strategia_api_field_name__c = 'Min_Scaduto__c'));
        rcList.add(new Rule_control__c (name = 'R8', Api_field_name__c = 'Residuo_Totale__c', Api_object_name__c = 'pratica__c', Condition__c = '<=', Rule_name__c = 'creato per Strattegia appalto1', Strategia_api_field_name__c = 'Max_Scaduto__c'));
        rcList.add(new Rule_control__c (name = 'R9', Api_field_name__c = 'Residuo_Totale__c', Api_object_name__c = 'Pratica__c', Condition__c = '>', Rule_name__c = 'creato per Strattegia appalto', Strategia_api_field_name__c = 'Scaduto__c'));
        rcList.add(new Rule_control__c (name = 'R10', Api_field_name__c = 'Metodo_di_Pagamento__c', Api_object_name__c = 'Pratica__c', Condition__c = '!=', Rule_name__c = 'creato per Strattegia appalto', Strategia_api_field_name__c = 'Metodo_di_Pagamento__c'));
        rcList.add(new Rule_control__c (name = 'R11', Api_field_name__c = 'Tipo_contratto__c', Api_object_name__c = 'Pratica__c', Condition__c = '=', Rule_name__c = 'creato per Strattegia appalto', Strategia_api_field_name__c = 'Tipo_contratto__c'));
        rcList.add(new Rule_control__c (name = 'R12', Api_field_name__c = 'White_list__c', Api_object_name__c = 'Pratica__c', Condition__c = '=', Rule_name__c = 'White list uguale a white list', Strategia_api_field_name__c = 'White_list__c'));
        rcList.add(new Rule_control__c (name = 'R13', Api_field_name__c = 'Residuo_Totale__c', Api_object_name__c = 'Pratica__c', Condition__c = '>=', Rule_name__c = 'scaduto maggiore uguale di', Strategia_api_field_name__c = 'Scaduto__c'));
        rcList.add(new Rule_control__c (name = 'R14', Api_field_name__c = 'E_phone_SMS_popolato__c', Api_object_name__c = 'Pratica__c', Condition__c = '=', Rule_name__c = 'E\' phone SMS popolato', Strategia_api_field_name__c = 'E_phone_SMS_popolato__c'));
        rcList.add(new Rule_control__c (name = 'R15', Api_field_name__c = 'Importo_Scaduto_Consolidato__c', Api_object_name__c = 'Pratica__c', Condition__c = '>', Rule_name__c = 'Scaduto consolidato maggiore di', Strategia_api_field_name__c = 'Scaduto__c'));
        rcList.add(new Rule_control__c (name = 'R16', Api_field_name__c = 'Comune__c', Api_object_name__c = 'Pratica__c', Condition__c = '=', Rule_name__c = 'Comune uguale', Strategia_api_field_name__c = 'Comune__c'));
        rcList.add(new Rule_control__c (name = 'R17', Api_field_name__c = 'Email_sollecito_popolata__c', Api_object_name__c = 'Pratica__c', Condition__c = '=', Rule_name__c = 'Verifica se è presente la mail di sollegic', Strategia_api_field_name__c = 'Email_sollecito_popolata__c'));
        rcList.add(new Rule_control__c (name = 'R18', Api_field_name__c = 'Anzianita_scaduto__c', Api_object_name__c = 'Pratica__c', Condition__c = '>', Rule_name__c = 'Anzianità scaduto maggiore', Strategia_api_field_name__c = 'Anzianita_scaduto__c'));
        rcList.add(new Rule_control__c (name = 'R19', Api_field_name__c = 'Numero_figli__c', Api_object_name__c = 'Pratica__c', Condition__c = '=', Rule_name__c = 'Numero di figli uguale', Strategia_api_field_name__c = 'Numero_figli__c'));
        rcList.add(new Rule_control__c (name = 'R20', Api_field_name__c = 'Flag_Processo_Automatico_Mensile__c', Api_object_name__c = 'Pratica__c', Condition__c = '=', Rule_name__c = 'Flag processo automatico mensile', Strategia_api_field_name__c = 'Flag_Processo_Automatico_Mensile__c'));
        rcList.add(new Rule_control__c (name = 'R21', Api_field_name__c = 'Anzianita_scaduto__c', Api_object_name__c = 'Pratica__c', Condition__c = '=', Rule_name__c = 'Prova Slamtt', Strategia_api_field_name__c = 'Anzianita_scaduto__c'));
        rcList.add(new Rule_control__c (name = 'R22', Api_field_name__c = 'Numero_figli__c', Api_object_name__c = 'Pratica__c', Condition__c = '<', Rule_name__c = 'numero di figli minore', Strategia_api_field_name__c = 'Numero_figli__c'));
        rcList.add(new Rule_control__c (name = 'R23', Api_field_name__c = 'STR_Appalto_invia_terza_AR__c', Api_object_name__c = 'Pratica__c', Condition__c = '=', Rule_name__c = 'Rule per invio terza raccomanda nella strategia di Appalto', Strategia_api_field_name__c = 'STR_Appalto_invia_terza_AR__c'));
        rcList.add(new Rule_control__c (name = 'R24', Api_field_name__c = 'Residuo_Totale__c', Api_object_name__c = 'Pratica__c', Condition__c = '<', Rule_name__c = 'scaduto minore di Max scaduto', Strategia_api_field_name__c = 'Max_Scaduto__c'));
        rcList.add(new Rule_control__c (name = 'R25', Api_field_name__c = 'Scelta_utente__c', Api_object_name__c = 'Task', Condition__c = '=', Rule_name__c = 'Task: tipo attività', Strategia_api_field_name__c = 'Tipo_attivita__c'));
        rcList.add(new Rule_control__c (name = 'R26', Api_field_name__c = 'Scelta_utente__c', Api_object_name__c = 'XXXX', Condition__c = '=', Rule_name__c = 'Task: tipo attività', Strategia_api_field_name__c = 'Tipo_attivita__c'));
        insert rcList;
    }

    //TASK methods
    public static Map<string, Schema.RecordTypeInfo> RTTaskNameId;
    public static Map<id, Schema.RecordTypeInfo> RTTaskIdName;
    public static List<String> taskFieldsList;

    public static Id getTaskRTId(String recordTypeName) {
        if (RTTaskNameId == null) {
            RTTaskNameId = Schema.SObjectType.ActivityExtended__c.getRecordTypeInfosByDeveloperName();
        }

        return RTTaskNameId.get(recordTypeName).getRecordTypeId();
    }

    public static string getTaskRTName(string recordTypeId) {
        if (RTTaskIdName == null)
            RTTaskIdName = Schema.SObjectType.ActivityExtended__c.getRecordTypeInfosById();
        return RTTaskIdName.get(recordTypeId).getName();
    }

    public static string getTaskAllFieds() {
        if (taskFieldsList != null) return utils.joinStrings(taskFieldsList, ',');
        SObjectType type = Schema.getGlobalDescribe().get('Task');
        Map<String, Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        taskFieldsList = new List<string>();
        taskFieldsList.addAll(mfields.keySet());
        return utils.joinStrings(taskFieldsList, ',');
    }

    //Pratica Methods
    public static List<String> praticaFieldsList;

    public static string getPraticaAllFieds() {
        if (praticaFieldsList != null) return utils.joinStrings(praticaFieldsList, ',');
        SObjectType type = Schema.getGlobalDescribe().get(Utils.NAMESPACE + 'Pratica__c');
        Map<String, Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        praticaFieldsList = new List<string>();
        praticaFieldsList.addAll(mfields.keySet());
        return utils.joinStrings(praticaFieldsList, ',');
    }

    //Strategia Methods
    public static Map<string, Schema.RecordTypeInfo> RTStrategiaNameId;
    public static Map<id, Schema.RecordTypeInfo> RTStrategiaIdName;
    public static List<String> strategiaFieldsList;
    public static id getStrategiaRTId(string recordTypeName) {
        if (RTStrategiaNameId == null)
            RTStrategiaNameId = Schema.SObjectType.Strategia__c.getRecordTypeInfosByName();
        return RTStrategiaNameId.get(recordTypeName).getRecordTypeID();
    }
    public static string getStrategiaRTName(string recordTypeId) {
        if (RTStrategiaIdName == null)
            RTStrategiaIdName = Schema.SObjectType.Strategia__c.getRecordTypeInfosById();
        return RTStrategiaIdName.get(recordTypeId).getName();
    }
    public static string getStrategiaAllFieds() {
        if (strategiaFieldsList != null) return utils.joinStrings(strategiaFieldsList, ',');
        SObjectType type = Schema.getGlobalDescribe().get(Utils.NAMESPACE + 'Strategia__c');
        Map<String, Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        strategiaFieldsList = new List<string>();
        strategiaFieldsList.addAll(mfields.keySet());
        return utils.joinStrings(strategiaFieldsList, ',');
    }

    //Movimenti Methods
    public static Map<string, Schema.RecordTypeInfo> RTMovimentoNameId;
    public static Map<id, Schema.RecordTypeInfo> RTMovimentoIdName;
    public static List<String> movimentoFieldsList;

    public static id getMovimentoRTId(string recordTypeName) {
        if (RTMovimentoNameId == null)
            RTMovimentoNameId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByName();
        return RTMovimentoNameId.get(recordTypeName).getRecordTypeID();
    }
    public static string getMovimentoRTName(string recordTypeId) {
        if (RTMovimentoIdName == null)
            RTMovimentoIdName = Schema.SObjectType.Movimento__c.getRecordTypeInfosById();
        return RTMovimentoIdName.get(recordTypeId).getName();
    }
    public static string getMovimentoAllFieds() {
        if (movimentoFieldsList != null) return utils.joinStrings(movimentoFieldsList, ',');
        SObjectType type = Schema.getGlobalDescribe().get(Utils.NAMESPACE + 'Movimento__c');
        Map<String, Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        movimentoFieldsList = new List<string>();
        movimentoFieldsList.addAll(mfields.keySet());
        return utils.joinStrings(movimentoFieldsList, ',');
    }


}