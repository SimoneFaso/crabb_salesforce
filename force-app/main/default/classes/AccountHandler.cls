/* ---------------------------------------------------------------------------------------------------------------------
Name:            AccountHandler.cls
Description:     Trigger Handler for the Account SObject
Test class:      TestAccountHandler.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
03-Jun-2014  0.1      Klodjan Meta                    First Version
27-Apr-2021  0.2      Giulia Mameli                   BeforeDelete: added Delete_Account_Permission check to let other
                                                      Profiles to delete Accounts.
08-Jun-2021  0.3      Giulia Mameli                   Modified for including Skip Trigger check to avoid afterInsert updates
27-Sep-2021  0.4      Matteo Pizzichini               Modified AfterInsert for adding check permission:
                                                      cebCheckFLSPermission (Security Review)
07-Sep-2022  0.5      R. Kurti & C. Sanna             Modified for adding check permission:
                                                      cebCheckFLSPermission/cebCheckObjPermission/WITH SECURITY_ENFORCED (Security Review)
02-Mar-2023  0.6      C.Sanna                         Modified for including Skip Trigger check to avoid beforeDelete permission Check
                                                      (without any other custom permission)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class AccountHandler implements ITrigger {
    Id recordTypeId = Schema.SObjectType.CRABB_DEV__Log__c.getRecordTypeInfosByDeveloperName().get('DataMapper').getRecordTypeId();
    public final List<CRABB_DEV__Log__c> logsToSync = new List<CRABB_DEV__Log__c>();
    public static final List<String> SOURCE_FIELDS_LIST = MappingUtils.getMappingFields('Account');
    Schema.SObjectField externalIDField = MappingUtils.getSobjectExternalId();
    List<Account> ListAcc = new List<Account>();
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public AccountHandler() {
    }
    public void bulkBefore() {
    }
    public void bulkBefore(List<SObject> soListNew) {
    }

    public void bulkAfter() {
    }
    public void bulkAfter(List<SObject> soListNew) {
    }
    public void beforeInsert(List<SObject> soList) {
    }
    public void beforeUpdate(List<SObject> soList, List<SObject> oList) {
        if (!skipTrigger.skip('Account')) {
            setPraticheInLavorazione();
        }
    }

    public void beforeDelete(List<SObject> so) {
        if (!skipTrigger.skip('Account')) {
            Id profileId = UserInfo.getProfileId();
            Boolean hasDeletePermission = FeatureManagement.checkPermission('Delete_Account_Permission');
            Id AdminProfileId = [SELECT Id, Name FROM Profile WHERE Name IN ('System Administrator', 'Amministratore del sistema')].Id;

            for (SObject s : so) {
                if (profileId != AdminProfileId && !hasDeletePermission) {
                    s.addError('Non si hanno i permessi per cancellare l\'Account. Contattare l\'Amministratore del sistema.');
                }
            }
        }
    }

    public void afterInsert(List<SObject> soList) {
        System.debug('Account skip trigger --> ' + skipTrigger.skip('Account'));
        if (!skipTrigger.skip('Account')) {
            for (Account acc : (List<Account>) soList) {
                Account newAcc = new Account();
                newAcc.Id = acc.Id;
                newAcc.Mail1__c = acc.E_Mail_Account_migrazione__c;
                newAcc.Mail_Sollecito__c = acc.E_Mail_Sollecito_migrazione__c;
                ListAcc.add(newAcc);
            }

            if (ListAcc.size() > 0) {
                try {
                    /*if (Utils.checkFLSPermission('Account', 'Mail1__c').get('UPDATE')
                            && Utils.checkFLSPermission('Account', 'Mail_Sollecito__c').get('UPDATE')
                            && Utils.checkFLSPermission('Account', 'E_Mail_Sollecito_migrazione__c').get('UPDATE')
                            && Utils.checkFLSPermission('Account', 'E_Mail_Account_migrazione__c').get('UPDATE')) update ListAcc;*/

                    if (Utils.cebCheckObjPermission('Account', gd).get('UPDATE') && Utils.cebCheckFLSPermission('Account', 'Mail1__c',gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('Account', 'Mail_Sollecito__c',gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('Account', 'E_Mail_Sollecito_migrazione__c',gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('Account', 'E_Mail_Account_migrazione__c',gd).get('UPDATE')) {
                        update ListAcc;
                    }

                } catch (Exception e) {
                    System.debug('Salvataggio Account Integration Email: ' + e.getMessage());
                }
            }
        }

        List<Account> ListAccNew = (List<Account>) soList;

        if (SOURCE_FIELDS_LIST.size() != 0) {
            for (Account account : ListAccNew) {
                logsToSync.add(MappingUtils.createDataMapperLog(
                        account,
                        SOURCE_FIELDS_LIST,
                        'Account',
                        'insert',
                        'Fatture'
                )
                );
            }
        }
    }


    public void afterUpdate(List<SObject> oldSo, List<SObject> so) {
        System.debug('Account afterUpdate');
        List<Account> ListAccNew = (List<Account>) so;
        if (SOURCE_FIELDS_LIST.size() != 0) {
            for (Account account : ListAccNew) {
                logsToSync.add(MappingUtils.createDataMapperLog(
                        account,
                        SOURCE_FIELDS_LIST,
                        'Account',
                        'update',
                        'Fatture'
                )
                );
            }
        }

    }

    public void afterDelete(List<SObject> so) {
    }

    public void andFinally() {

        /*if (logsToSync.size() > 0 && !MappingUtils.alreadyRun) {
            if (logsToSync.size() > 0) {
                Database.UpsertResult[] resultLogList = Database.upsert(logsToSync, externalIDField, false);
                System.debug('Account resultLogList --> ' + resultLogList);
                //insert logToSync;
                MappingUtils.alreadyRun = true;
            }
        }*/
    }

    public void setPraticheInLavorazione() {
        System.debug('< setPraticheInLavorazione >');
        if (Utils.cebCheckObjPermission('Account', gd).get('ACCESS') && Utils.cebCheckObjPermission('Pratica__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Pratiche_In_Lavorazione__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Trigger_cause__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Account', 'Pratiche_Accodamento__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Flag_Accodamento__c', gd).get('ACCESS')) {
            for (Account acc : [
                    SELECT Id,
                            Pratiche_In_Lavorazione__c,
                            Trigger_cause__c,
                            Pratiche_Accodamento__c, (
                            SELECT Id, Flag_Accodamento__c
                            FROM Pratiche__r
                            WHERE Stato__c IN ('In Lavorazione', 'Bloccata', 'Affidata')
                    )
                    FROM Account
                    WHERE Id IN :Trigger.newMap.keySet()
                    //WITH SECURITY_ENFORCED
            ]) {
                Account accT = (Account) Trigger.newMap.get(acc.Id);
                if (accT.Trigger_cause__c == null || accT.Trigger_cause__c == '' || !(accT.Trigger_cause__c.contains('*0*')))
                    continue;
                accT.Pratiche_In_Lavorazione__c = acc.Pratiche__r.size();
                accT.Trigger_cause__c = accT.Trigger_cause__c.replace('*0*', '');
                accT.Pratiche_Accodamento__c = 0;
                for (Pratica__c pr : acc.Pratiche__r) {
                    if (pr.Flag_Accodamento__c)
                        accT.Pratiche_Accodamento__c = accT.Pratiche_Accodamento__c + 1;
                }
            }
        }
    }
}