/**
 * Created by m.siotto on 13/07/2021.
 */
/* ---------------------------------------------------------------------------------------------------------------------
Name:            AccountHandler.cls
Description:     Trigger Handler for the Account SObject
Test class:      TestAccountHandler.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
13-Jul-2021  0.1      M.Siotto                        First Version

13-Sep-2022  0.2      R. Kurti & C. Sanna             Modified for adding check permission:
                                                     cebCheckObjPermission/WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class ElaborateCebCTRL {
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    @AuraEnabled
    public static void elaborateCEB(String recordId) {

        try {
            Map<integer, Schedule_Batch__c> opsMap = new Map<integer, Schedule_Batch__c> ();
            Map<String, String> statusMap = new Map<String, String>();
            List<CEB__c> cebList = new List<CEB__c>();

            //1 - Retrieve all fields of Pratica__c object
            String listOfFieldsPratica = utils.joinStrings(Schema.getGlobalDescribe().get(Utils.NAMESPACE + 'Pratica__c').getDescribe().fields.getMap().keySet(), ',');

            //2- Retrieve ceb event values filtering by id of the record page and set Status__c in progress
            CEB__c ceb = [
                    SELECT id, Type__c, Status__c, Pratica__c, CRABB_DEV__Pratica__r.CRABB_DEV__Account__c,
                            Movimento__c, ActivityExtended__c, Wait_Due_Date__c, Immediate_Action__c
                    from CEB__c
                    where id = :recordId
                    WITH SECURITY_ENFORCED
            ];
            ceb.Status__c = 'In Progress';
            cebList.add(ceb);

            String praticaId = ceb.Pratica__c;
            String cebType = ceb.Type__c;
            Boolean cebImmediate = ceb.Immediate_Action__c;

            CEB__c cebSch = [
                    SELECT id, Type__c, Status__c, Pratica__c, CRABB_DEV__Pratica__r.CRABB_DEV__Account__c,
                            Movimento__c, ActivityExtended__c, Wait_Due_Date__c, Immediate_Action__c
                    from CEB__c
                    where Pratica__c = :praticaId and Type__c = 'SCH'
                    WITH SECURITY_ENFORCED
            ];
            cebSch.Status__c = 'In Progress';
            cebList.add(cebSch);
            if (Utils.cebCheckObjPermission('CEB__c', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('CEB__c', 'Status__c', gd).get('UPDATE')) {
                update cebList;
            }


            //3- Retrieve dossier related to the crabb event record
            String query = 'SELECT ' + listOfFieldsPratica + ' from Pratica__c where id = :praticaId';
            List<Pratica__c> praList = Database.query(String.escapeSingleQuotes(query));

            //4- Retrieve the Schedule&Batch custom setting information related to ceb Record selected
            Schedule_Batch__c sbReferenceRecord = [
                    select Id, CRABB_DEV__Type__c, name, CRABB_DEV__isActive__c,
                            CRABB_DEV__Wait_Due_Date__c, CRABB_DEV__Order__c, CRABB_DEV__immediate_Action__c
                    from CRABB_DEV__Schedule_Batch__c
                    where Type__c = :cebType and immediate_Action__c = :cebImmediate
                    WITH SECURITY_ENFORCED
            ];

            //5- Retrieve the Schedule&Batch custom setting information related to Scheduling (SCH) ceb records
            list<Schedule_Batch__c> Schedule_Batchlist = [
                    select Id, CRABB_DEV__Type__c, name, CRABB_DEV__isActive__c,
                            CRABB_DEV__Wait_Due_Date__c, CRABB_DEV__Order__c, CRABB_DEV__immediate_Action__c
                    from CRABB_DEV__Schedule_Batch__c
                    where Type__c = 'SCH'
                    WITH SECURITY_ENFORCED
                    order by Order__c
            ];

            //6- Generate the opsMap ordered by index used in the CrabbEngine batch
            opsMap.put(0, sbReferenceRecord);
            integer forIndex = 1;
            if (cebType != 'WAI') {
                for (Schedule_Batch__c sb : Schedule_Batchlist) {
                    opsMap.put(forIndex, sb);
                    forIndex++;
                }
            }

            //7- Call CrabbEngine Batch
            Database.executeBatch(new CrabbEngine(praList, 0, opsMap, statusMap), 50);

        } catch (Exception e) {
            System.debug('Exception on elaborateCEB: ' + e.getStackTraceString() + ' - ' + e.getMessage());
        }

    }

    @AuraEnabled
    public static String getCebStatus(String recordId) {
        CEB__c ceb = [SELECT id, Status__c from CEB__c where id = :recordId WITH SECURITY_ENFORCED];
        return ceb.status__c;
    }

}