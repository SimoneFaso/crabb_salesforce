/* ---------------------------------------------------------------------------------------------------------------------
Name:            OrkPratica.cls
Description:     Used in OrkBatch class for processing Dossiers and creating new Strategy Tasks
Test class:

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
06-May-2014  0.1      Klodjan Meta                    First Version
03-Sep-2021  0.2      G. Mameli & C. Sanna            Reviewed for Security Review
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class OrkPratica {
    public class OrkException extends Exception {
    }
    public static Boolean areLogsActive;
    //data Manipulation
    public Map<Id, SObject> sobjectsToUpdate = new Map<Id, SObject>();
    public List<SObject> sobjectsToInsert = new List<SObject>();
    public List<Log__c> logsList = new List<Log__c>();
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public Boolean executePratica(String token, Map<Id, Pratica__c> pMap, Strategia__c strategia) {
        if (token == null || strategia == null || pMap == null || pMap.keySet() == null || pMap.keySet().size() == 0) return null;
        if (areLogsActive == null) areLogsActive = TagHelper.getValueBoolean('OrkPraticaLogl');

        Set<Id> praticaToProcess = new Set<Id>();
        Set<Id> tempPraticaSet = new Set<Id>();
        Set<Id> praticaProcessed = new Set<Id>();
        Integer priorityLevel, priorityElement;
        Pratica__c pratica = new Pratica__c();
        Boolean result;
        Task tsk = new Task(); //Variabile dummie per non duplicare la classe isRoleSatisfied
        //Setting delle variabili statiche
        OrkStatic.setTaskRecrdType();
        OrkStatic.retrieveStrategie();
        praticaToProcess = OrkBL.getPraticheProcessabili(token, pMap, strategia);
        // debug
        if (praticaToProcess == null) {
            logsList.add(ErrorClass.instanceError(areLogsActive, 'OrkPratica:1', 'Non ci sono pratiche processabili'));
        }

        for (Id idPratica : praticaToProcess) {
            pratica = pMap.get(idPratica);
            if (OrkStatic.cdiPO.get(strategia.Id) == null) continue;
            for (Id idCDI : OrkStatic.cdiPO.get(strategia.Id)) {
                if (praticaProcessed.contains(idPratica)) continue;

                Strategia__c cdi = OrkStatic.strategies.get(idCDI);
                result = OrkKernel.isRoleSatisfied(pratica, cdi, logsList, tsk, null);
                if (result == null) {
                    logsList.add(ErrorClass.instanceError(areLogsActive, 'OrkPratica:2', 'isRoleSatisfied result uguale a null per la pratica: ' + idPratica + ' rispetto alla condizione di ingresso: ' + idCDI));
                } else if (result == true) {
                    tempPraticaSet.add(idPratica);
                    praticaProcessed.add(idPratica);
                }
            }
        }
        praticaToProcess = tempPraticaSet;
        praticaProcessed = new Set<Id>();
        // debug
        /*
        if(praticaToProcess == null){
            logL.add(errorClass.istanceError('OrkPratica:3','Nessuna pratica da processare '));
            if(areLogsActive
                && Utils.checkObjPermission('Log__c').get('UPDATE')
                && Utils.checkObjPermission('Log__c').get('INSERT'))
                upsert logl;
        }
        */
        if (praticaToProcess == null) {
            logsList.add(ErrorClass.instanceError(areLogsActive, 'OrkPratica:3', 'Nessuna pratica da processare'));
            if (areLogsActive) {
                ErrorClass.checkOPFLSAndUpsertErrorLogs(logsList, 'UPSERT', gd);
            }
            /*if (areLogsActive && Utils.cebCheckObjPermission('Log__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'Class_Name__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'Method__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'Line_number__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'Error_code__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'Error__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'Message_Out__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'RecordTypeId', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'Name__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'info__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'Message__c', gd).get('UPSERT')
                        && Utils.cebCheckFLSPermission('Log__c', 'type__c', gd).get('UPSERT')) {
                upsert logL;
            }*/
        }
        for (Id idPratica : praticaToProcess) {
            pratica = pMap.get(idPratica);
            if (OrkStatic.nSPO == null) {
                System.debug('Non legge le attivita per la pratica!');
            }
            for (Id idStr : OrkStatic.nSPO.get(strategia.Id)) {
                Strategia__c st = OrkStatic.strategies.get(idStr);
                if (OrkStatic.strategies != null) {
                    System.debug('Letto lo step o l\'attività!');
                }
                priorityElement = Integer.valueOf(st.Priority__c);
                if (praticaProcessed.contains(pratica.Id) && priorityLevel != priorityElement) {
                    break;
                } else if (priorityLevel != priorityElement) {
                    priorityLevel = priorityElement;
                }
                result = OrkKernel.isRoleSatisfied(pratica, st, logsList);
                if (result == null) {
                    logsList.add(ErrorClass.instanceError(areLogsActive, 'OrkPratica:4', 'isRoleSatisfied result uguale a null per la pratica: ' + idPratica + ' rispetto allo step: ' + idStr));
                } else if (result == true) {
                    List<SObject> nt = OrkBL.newTask(pratica, st);
                    sobjectsToInsert.addAll(nt);
                    praticaProcessed.add(pratica.Id);
                }
            }
        }
        if (sobjectsToInsert.size() > 0) {
            insert sobjectsToInsert;
        }
        /*
        logL.add(errorClass.istanceError('InfoLimits',Utils.getLimits()));
        //if(areLogsActive) upsert logl;
        if(areLogsActive && Utils.checkObjPermission('Log__c').get('UPDATE') && Utils.checkObjPermission('Log__c').get('INSERT')) upsert logl;
         */
        logsList.add(ErrorClass.instanceError(areLogsActive, 'InfoLimits', Utils.getLimits()));
        if (areLogsActive) {
            ErrorClass.checkOPFLSAndUpsertErrorLogs(logsList, 'UPSERT', gd);
        }
        /*if (areLogsActive && Utils.cebCheckObjPermission('Log__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Log__c', 'Class_Name__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Log__c', 'Method__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Log__c', 'Line_number__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Log__c', 'Error_code__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Log__c', 'Error__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Log__c', 'Message_Out__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Log__c', 'RecordTypeId', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Log__c', 'Name__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Log__c', 'info__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Log__c', 'Message__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Log__c', 'type__c', gd).get('UPSERT')) {
            upsert logsList;
        }*/
        return true;
    }
}