/* ---------------------------------------------------------------------------------------------------------------------
Name:            CaseUtility.cls
Description:     Utility Class for Case Object
Test class:      TestCaseUtility.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
03-Jun-2020  0.1      Matteo Lecca                    First Version
29-Mar-2021  0.2      Giulia Mameli                   Modified createCaseFromStep Method: Added Case Subject mapping from
                                                      Task Subject
13-Sep-2022  0.3      R.Kurti & C.Sanna               Added WITH SECURITY ENFORCED and cebCheckObjPermission (security review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class CaseUtility {

    /* -----------------------------------------------------------------------------------------------------------------
    Author: Matteo Lecca
    Company: Balance
    Description: This method, used in TaskHandler Class, creates a Case from Activity Extended, using ManageCaseMapping
    Metadata (StaticValue__c = default value when FieldSource__c is null, sObjectSource__c = Objects (Account/Servizio)
    where to take FieldSource__c values; when sObjectSource__c is not set, it refers Activity Extended)
    Inputs:  List of Activity Extended, Dossier Ids, Map containing task.ActivityExtended__c and
    task.Pratica__c+'~'+task.Subject
    Returns: NA

    03-Jun-2020  0.1      Matteo Lecca      First Version
    29-Mar-2021  0.2      Giulia Mameli     Added Case Subject mapping from Task Subject
    ----------------------------------------------------------------------------------------------------------------- */

    public static void createCaseFromStep(List<SObject> tList, Set<Id> praticaIds, Map<String, String> taskMap) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        System.debug('activity extended list: ' + tList);
        Boolean isTest = Test.isRunningTest();
        List<ManageCaseMapping__mdt> mapping = [
                SELECT Id, DeveloperName, FieldTarget__c, FieldSource__c, StaticValue__c, ManageCaseHeader__r.Tipo__c,
                        ManageCaseHeader__r.Sottotipo__c, sObjectSource__c
                FROM ManageCaseMapping__mdt
                WHERE ManageCaseHeader__r.SourceObject__c = 'ActivityExtended__c' AND ManageCaseHeader__r.isTest__c = :isTest
                WITH SECURITY_ENFORCED
        ];

        Map<String, List<ManageCaseMapping__mdt>> mapMapping = new Map<String, List<ManageCaseMapping__mdt>>();
        Set<String> accountSelectClauseSet = new Set<String>{
                ' Account__c '
        };
        Set<String> servizioSelectClauseSet = new Set<String>{
                ' Servizio_Fornitura__c '
        };

        for (ManageCaseMapping__mdt mdtMapping : mapping) {
            if (mdtMapping.sObjectSource__c == 'Account') {
                accountSelectClauseSet.add('Account__r.' + mdtMapping.FieldSource__c);
            } else if (mdtMapping.sObjectSource__c == 'Servizio__c') {
                servizioSelectClauseSet.add('Servizio_Fornitura__r.' + mdtMapping.FieldSource__c);
            }
        }

        List<String> accountSelectClause = new List<String>();
        accountSelectClause.addAll(accountSelectClauseSet);

        List<String> servizioSelectClause = new List<String>();
        servizioSelectClause.addAll(servizioSelectClauseSet);

        if (mapping.size() > 0) {
            Map<String, Pratica__c> praticaMap = new Map<String, Pratica__c>();
            Set<Id> aeIds = new Set<Id>();
            for (SObject actExt : tList) {
                aeIds.add(actExt.Id);
            }

            Set<String> caseAlreadyCreatedFromStep = new Set<String>();
            for (Case c : [SELECT Id, ActivityExtended__c FROM Case WHERE ActivityExtended__c IN :aeIds WITH SECURITY_ENFORCED]) {
                caseAlreadyCreatedFromStep.add(c.ActivityExtended__c);
            }

            System.debug('caseAlreadyCreatedFromStep: ' + caseAlreadyCreatedFromStep);

            String query = 'SELECT Id , ' + String.join(accountSelectClause, ' , ') + ' , ' + String.join(servizioSelectClause, ' , ') +
                    '  FROM Pratica__c WHERE Id IN :praticaIds';
            System.debug('Pratica query : ' + query);

            List<Pratica__c> pratiche = Database.query(String.escapeSingleQuotes(query));
            for (Pratica__c p : pratiche) {
                praticaMap.put(p.Id, p);
            }

            for (ManageCaseMapping__mdt m : mapping) {
                if (!mapMapping.containsKey(m.ManageCaseHeader__r.Tipo__c + '_' + m.ManageCaseHeader__r.SottoTipo__c))
                    mapMapping.put(m.ManageCaseHeader__r.Tipo__c + '_' + m.ManageCaseHeader__r.SottoTipo__c, new List<ManageCaseMapping__mdt>());
                mapMapping.get(m.ManageCaseHeader__r.Tipo__c + '_' + m.ManageCaseHeader__r.SottoTipo__c).add(m);
            }

            List<Case> caseList = new List<Case>();
            for (SObject ae : tList) {
                ActivityExtended__c aeObj = (ActivityExtended__c) ae;
                System.debug('activity ' + ae);
                if (mapMapping.containsKey(aeObj.Tipo__c + '_' + aeObj.Sotto_Tipo__c)) {
                    if (mapMapping.get(aeObj.Tipo__c + '_' + aeObj.Sotto_Tipo__c).get(0).ManageCaseHeader__r.Tipo__c.equalsIgnoreCase(aeObj.Tipo__c)
                            && mapMapping.get(aeObj.Tipo__c + '_' + aeObj.Sotto_Tipo__c).get(0).ManageCaseHeader__r.Sottotipo__c.equalsIgnoreCase(aeObj.Sotto_Tipo__c)) {
                        System.debug('Start case creation for activity id ' + ae.Id);
                        SObject caseObj = Schema.getGlobalDescribe().get('Case').newSObject() ;
                        //Set required fields
                        caseObj.put('AccountId', praticaMap.get(taskMap.get(aeObj.Id).split('~').get(0)).Account__c);
                        caseObj.put('Servizio__c', praticaMap.get(taskMap.get(aeObj.Id).split('~').get(0)).Servizio_Fornitura__c);
                        caseObj.put('Pratica__c', taskMap.get(aeObj.Id).split('~').get(0));
                        caseObj.put('ActivityExtended__c', aeObj.Id);
                        caseObj.put('Origin', 'CRABB');
                        //Set Case Subject from Task Subject
                        caseObj.put('Subject', taskMap.get(aeObj.Id).split('~').get(1));
                        for (ManageCaseMapping__mdt mcm : mapMapping.get(aeObj.Tipo__c + '_' + aeObj.Sotto_Tipo__c)) {
                            if (String.isNotBlank(mcm.FieldSource__c))
                                switch on mcm.sObjectSource__c {
                                    when 'Account' {
                                        if (praticaMap.get(taskMap.get(aeObj.Id).split('~').get(0)).getSObject('Account__r') != null)
                                            caseObj.put(mcm.FieldTarget__c, praticaMap.get(taskMap.get(aeObj.Id).split('~').get(0)).getSObject('Account__r').get(mcm.FieldSource__c));
                                    }
                                    when 'Servizio__c' {
                                        if (praticaMap.get(taskMap.get(aeObj.Id).split('~').get(0)).getSObject('Servizio_Fornitura__r') != null)
                                            caseObj.put(mcm.FieldTarget__c, praticaMap.get(taskMap.get(aeObj.Id).split('~').get(0)).getSObject('Servizio_Fornitura__r').get(mcm.FieldSource__c));
                                    }
                                    when else {
                                        caseObj.put(mcm.FieldTarget__c, ae.get(mcm.FieldSource__c));
                                    }
                                }
                            else {
                                caseObj.put(mcm.FieldTarget__c, mcm.StaticValue__c);
                            }
                        }
                        if (!caseAlreadyCreatedFromStep.contains(((Case) caseObj).ActivityExtended__c))
                            caseList.add((Case) caseObj);
                    }
                }
            }

            if (caseList.size() > 0) {
                //if (Utils.checkObjPermission('Case').get('INSERT') && Utils.checkObjPermission('Case').get('ACCESS'))
                if (Utils.cebCheckObjPermission('Case', gd).get('INSERT') && Utils.cebCheckObjPermission('Case', gd).get('ACCESS')) {
                    insert caseList;
                }
            }

            if (CEBUtils.newOrkVersionEnabled()) {
                List<Id> aeForCasesList = new List<Id>();
                for (Case cs : caseList) {
                    aeForCasesList.add(cs.CRABB_DEV__ActivityExtended__c);
                }
                CrabbEngineUtils.setTasksToWorked(aeForCasesList);
            }
        }
    }
}