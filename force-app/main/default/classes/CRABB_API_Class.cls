/* ---------------------------------------------------------------------------------------------------------------------
Name:            CRABB_API_Class.cls
Description:
Test class:

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
30-Mar-2020  0.1      M.Sala                          First Version
13-Sep-2022  0.2      R.Kurti & C.Sanna               Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/

global with sharing class CRABB_API_Class
{
    Global Class CrabbCreaNuovaPraticaInput
    {
        Global String IdAccountSFDC;
        Global String AccountExternalKey;
        Global CrabbServizio Serv;
        Global List<CrabbMovimento> lMov;
    }

    Global Class CrabbCreaNuovaPraticaOutput
    {
        Global String Esito;
        Global List<Error> lErrors;
        Global String AccountIdSFDC;
        Global String ServizioIdSFDC;
        Global String PraticaCodeSFDC;
        Global String MovimentoIdSFDC;
    }

    Global Class CrabbInput
    {
        Global String IdAccountSFDC;
        Global String AccountExternalKey;
        Global CrabbServizio Serv;
        Global List<CrabbMovimento> lMov;
    }

    Global Class CrabbOutput
    {
        Global String Esito;
        Global List<Error> lErrors;
        Global String AccountIdSFDC;
        Global String ServizioIdSFDC;
        Global String PraticaCodeSFDC;
        Global String MovimentoIdSFDC;
    }

    Global Class CrabbCreaMovimentoInput
    {
        Global String IdAccountSFDC;
        Global String AccountExternalKey;
        Global String IdServSFDC;
        Global String ServExternalKey;
        Global String IdPratSFDC;
        Global CrabbMovimento mov;
    }

    Global Class CrabbCreaMovimentoOutput
    {
        Global String Esito;
        Global List<Error> lErrors;
        Global String AccountIdSFDC;
        Global String ServizioIdSFDC;
        Global String PraticaCodeSFDC;
        Global String MovimentoIdSFDC;
    }

    Global Class CrabbServizio
    {
        Global String RecordType;
        Global String IdServSFDC;
        Global String ServExternalKey;
        Global String Name;
        Global Boolean UpdServizio;
        Global List<CrabbPayload> lPL;
    }

    Global Class CrabbMovimento
    {
        Global String RecordType;
        Global Date DataEmissione;
        Global Date DataScadenza;
        Global String MovExternalKey;
        Global String IdMovSFDC;
        Global Boolean UpdMovimento;
        Global Decimal Importo;
        Global Decimal Residuo;
        Global Boolean Sollecitabile;
        Global List<CrabbPayload> lPL;
    }

    Global Class CrabbPayload
    {
        Global String Field;
        Global String Value;
    }

    Global Class Error
    {
        Global String Code;
        Global String Description;
    }

    public static Map<String,Map<String,String>> getPayloadMapping()
    {
        /*List<ServicePaymentsMappingField__mdt> lMappingFields = [SELECT ObjectType__c,ObjectField__c,PayloadField__c
        FROM ServicePaymentsMappingField__mdt where isTest__c = false];*/
        List<CRABB_API_Mapping__mdt> lMappingFields = [SELECT ObjectType__c,ObjectField__c,PayloadField__c
        FROM CRABB_API_Mapping__mdt where isTest__c = false WITH SECURITY_ENFORCED ];
        Map<String,Map<String,String>> mMappingObjects = new Map<String,Map<String,String>>();
        for(CRABB_API_Mapping__mdt mapping : lMappingFields)
        {
            Map<String,String> mMappingFields = new Map<String,String>();
            mMappingFields.put(mapping.PayloadField__c,mapping.ObjectField__c);
            if(mMappingObjects.containsKey(mapping.ObjectType__c))
                mMappingObjects.get(mapping.ObjectType__c).put(mapping.PayloadField__c,mapping.ObjectField__c);
            else
                mMappingObjects.put(mapping.ObjectType__c,mMappingFields);
        }

        return mMappingObjects;
    }

    public static Object setPayloadField(String objectType , Map<String , Map<String ,String>> mMappingObjects ,
            List<CRABB_API_Class.CrabbPayload> crabbPayload , sObject sobj)
    {
        System.debug('Payload object mapping : ' + mMappingObjects);
        System.debug('objectType -> '+ objectType);
        Map<String ,String> servMapping = mMappingObjects.get(objectType);
        System.debug('Payload object mapping : ' + servMapping);
        if(servMapping != null && crabbPayload != null){
            Map<String,String> payloadObject = new Map<String, String>();
            for(CRABB_API_Class.CrabbPayload payload :  crabbPayload){
                payloadObject.put(payload.Field, payload.Value);
            }
            System.debug('Payload object values : ' + payloadObject);
            for(String payloadField : servMapping.keySet()){
                String objectField = servMapping.get(payloadField);
                System.debug('Payload field -> '+ payloadField + ' - Object Field -> '+objectField);
                System.debug('objectType -> '+ objectType);
                //String sobject_type = 'Account';
                Map<String, Schema.SObjectType> global_describe = Schema.getGlobalDescribe();
                Map<String, Schema.SObjectField> object_fields_map = global_describe.get(objectType).getDescribe().fields.getMap();
                System.debug('Field Type: -> '+ object_fields_map);
                if(payloadObject.containsKey(payloadField))
                {
                    if(object_fields_map.containsKey(objectField)
                            && payloadObject.get(payloadField) != null
                            && payloadObject.get(payloadField) != '' )
                    {
                        System.debug('Field Type: -> ' + objectField + ' --> ' + object_fields_map.get(objectField).getDescribe().getType());
                        if(object_fields_map.get(objectField).getDescribe().getType() == Schema.DisplayType.STRING)
                            sobj.put(objectField, payloadObject.get(payloadField));
                        if(object_fields_map.get(objectField).getDescribe().getType() == Schema.DisplayType.INTEGER)
                            sobj.put(objectField, Integer.valueOf(payloadObject.get(payloadField)));
                        if(object_fields_map.get(objectField).getDescribe().getType() == Schema.DisplayType.DOUBLE)
                            sobj.put(objectField, Decimal.valueOf(payloadObject.get(payloadField)));
                        if(object_fields_map.get(objectField).getDescribe().getType() == Schema.DisplayType.CURRENCY)
                            sobj.put(objectField, Decimal.valueOf(payloadObject.get(payloadField)));
                        if(object_fields_map.get(objectField).getDescribe().getType() == Schema.DisplayType.DATE)
                            sobj.put(objectField, date.parse(payloadObject.get(payloadField)));
                        if(object_fields_map.get(objectField).getDescribe().getType() == Schema.DisplayType.DATETIME)
                            sobj.put(objectField, datetime.parse(payloadObject.get(payloadField)));
                    }
                }
            }

        }
        System.debug('Return '+objectType +' obj:'+sobj);
        return sobj;
    }

    public static String checkFLSPraticaServizioMovimento(Map<String , List<String>> objField  ){
        List<String> res = new List<String>();
        for(String objType : objField.keySet()) {
            if(!Utils.checkObjPermission(objType).get('INSERT')){
                res.add('Oggetto '+objType+' non si ha l\'autorizzazine per creare record ');
            }
            for (String field : objField.get(objType)) {
                if (!Utils.checkFLSPermission( objType , field).get('CREATE')) {
                    res.add('Oggetto '+objType+' , Campo ' + field + ' non modificabile ');
                }
            }
        }
        return String.join(res, ' - ');
    }
}