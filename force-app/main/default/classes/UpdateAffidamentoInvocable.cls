/* ---------------------------------------------------------------------------------------------------------------------
Name:            UpdateAffidamentoInvocable.cls
Description:
Test class:

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
16-Sep-2022  0.2      C.Sanna & R.Kurti    Added WITH SECURITY ENFORCED and cebCheckObjPermissions (security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class UpdateAffidamentoInvocable {
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    /*@InvocableMethod(label='Update Affidamento' description='UpdateAffidamento')
    public static void UpdateAffidamento(List<ActivityExtended__c> lAE) 
    {
        List<affidamento__c> aList=new list<affidamento__c>();
        List<Log__c> logL = new List<Log__c>();
        Log__c l = new Log__c();
        l.Error_code__c = 'Update Affidamento Inizio';
        logL.add(l);
        date mydate;
        for(ActivityExtended__c ae : lAE)
        {
            if(!ae.E_da_affidare__c) continue;
            if(ae.id_affidamento__c==null) continue;
           
            affidamento__c a = new affidamento__c();
            mydate = System.today();
            a.id = ae.id_affidamento__c;
            System.Debug('SLA: ' + ae.SLA__c);
            a.Data_fine_affidamento_prevista__c = mydate.addDays(integer.valueof(ae.SLA__c));
            //a.Data_fine_affidamento_prevista__c=mydate.addDays(integer.valueof(t.ActivityExtended__r.SLA__c));
            a.ID_task_target_revoca__c = ae.id_attivita__c;
            //a.ID_task_target_revoca__c=t.id;
            aList.add(a);
            l = new Log__c();
            l.Error_code__c = 'Update Affidamento FOR: ' + ae.Id;
            logL.add(l);
        }
        
        if (Utils.checkFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c').get('UPDATE')
            && Utils.checkFLSPermission('Affidamento__c', 'ID_task_target_revoca__c').get('UPDATE')
            ) 
            update aList;
        
        l = new Log__c();
        l.Error_code__c = 'Update Affidamento FINE';
        logL.add(l);
        if(logl.size()>0) insert logl;
    }*/

    @InvocableMethod(label='Update Affidamento' description='UpdateAffidamento')
    public static void UpdateAffidamento(List<Id> lIdAE) {
        if (lIdAE.size() > 0) {
            /*if(Utils.checkFLSPermission('ActivityExtended__c', 'E_da_affidare__c').get('ACCESS')
                && Utils.checkFLSPermission('ActivityExtended__c', 'id_affidamento__c').get('ACCESS')
                && Utils.checkFLSPermission('ActivityExtended__c', 'SLA__c').get('ACCESS')
                && Utils.checkFLSPermission('ActivityExtended__c', 'id_attivita__c').get('ACCESS'))
            { */
            if (Utils.cebCheckObjPermission('ActivityExtended__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'E_da_affidare__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_affidamento__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'SLA__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('ActivityExtended__c', 'id_attivita__c', gd).get('ACCESS')) {
                List<ActivityExtended__c> lAE = [
                        SELECT Id, E_da_affidare__c, id_affidamento__c, SLA__c, id_attivita__c
                        FROM ActivityExtended__c
                        WHERE Id in :lIdAE
                        WITH SECURITY_ENFORCED
                ];

                List<affidamento__c> aList = new list<affidamento__c>();
                List<Log__c> logL = new List<Log__c>();
                Log__c l = new Log__c();
                l.Error_code__c = 'Update Affidamento Inizio';
                logL.add(l);
                date mydate;
                Set<Id> affids = new Set<Id>();
                for (ActivityExtended__c ae : lAE) {
                    affids.add(ae.id_affidamento__c);
                }
                // potrebbero esserci affidi cancellati referenziati su acitivity extended
                if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Affidamento__c', 'ID_task_target_revoca__c', gd).get('ACCESS')) {
                    Map<Id, Affidamento__c> affReal = new Map<Id, Affidamento__c>([
                            SELECT Id, Data_fine_affidamento_prevista__c, ID_task_target_revoca__c
                            FROM Affidamento__c
                            WHERE Id in :affids
                            WITH SECURITY_ENFORCED
                    ]);
                    mydate = System.today();
                    for (ActivityExtended__c ae : lAE) {
                        if (!ae.E_da_affidare__c) continue;
                        if (ae.id_affidamento__c == null) continue;
                        if (affReal != null && affReal.containsKey(ae.id_affidamento__c)) {
                            Affidamento__c a = affReal.get(ae.id_affidamento__c);
                            Boolean b = false;
                            /* 20190110 MSala - Non aggiorno la fine affido prevista se è già popolata */
                            if (a.Data_fine_affidamento_prevista__c == null) {
                                a.Data_fine_affidamento_prevista__c = mydate.addDays(integer.valueof(ae.SLA__c));
                                b = true;
                            }
                            if (a.ID_task_target_revoca__c == null) {
                                a.ID_task_target_revoca__c = ae.id_attivita__c;
                                b = true;
                            }
                            if (b)
                                aList.add(a);
                        } else {
                            continue;
                        }
                        System.Debug('SLA: ' + ae.SLA__c);
                        l = new Log__c();
                        l.Error_code__c = 'Update Affidamento FOR: ' + ae.Id;
                        logL.add(l);
                    }
                }
                if (Utils.cebCheckObjPermission('Affidamento__c', gd).get('UPDATE')
                        && Utils.cebCheckFLSPermission('Affidamento__c', 'Data_fine_affidamento_prevista__c', gd).get('UPDATE')
                        && Utils.cebCheckFLSPermission('Affidamento__c', 'ID_task_target_revoca__c', gd).get('UPDATE')
                        && aList.size() > 0) {
                    update aList;
                    l = new Log__c();
                    l.Error_code__c = 'Update Affidamento FINE';
                    logL.add(l);
                    if (logl.size() > 0 && Utils.cebCheckObjPermission('Log__c', gd).get('CREATE')
                            && Utils.cebCheckFLSPermission('Log__c', 'Error_code__c', gd).get('CREATE')) {
                        insert logl;
                    }
                }
            }
        }
    }
}