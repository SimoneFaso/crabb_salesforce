/* ---------------------------------------------------------------------------------------------------------------------
Name:            CRABB_Log_Utils.cls
Description:
Test class:      Test_CRABB_Log_Utils.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
24-Aug-2021  0.2      Claudio Sanna                   Modified class to with sharing (Security Review)
13-Sep-2022  0.3      R.Kurti                         Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/

global with sharing class CRABB_Log_Utils {
    global static void publishCRABBLog(List<String> lLogs) {
        Organization org = [
                SELECT
                        Id,
                        OrganizationType,
                        Name,
                        InstanceName,
                        IsSandbox,
                        NamespacePrefix
                FROM
                        Organization
                WITH SECURITY_ENFORCED
                LIMIT 1
        ];

        List<CRABB_Log_Event__e> lCLE = new List<CRABB_Log_Event__e>();

        for (String log : lLogs) {
            CRABB_Log_Event__e cle = new CRABB_Log_Event__e();
            cle.Log__c = log;
            cle.Org__c = org.Id;
            cle.Org_Name__c = org.Name;
            cle.isSandbox__c = org.IsSandbox;
            cle.Org_Type__c = org.OrganizationType;
            cle.Instance_Name__c = org.InstanceName;
            cle.Namespace_Prefix__c = org.NamespacePrefix;
            lCLE.add(cle);
            System.debug('Crabb Log Event: ' + cle);
        }

        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(lCLE);

        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                            err.getStatusCode() +
                            ' - ' +
                            err.getMessage());
                }
            }
        }
    }
}