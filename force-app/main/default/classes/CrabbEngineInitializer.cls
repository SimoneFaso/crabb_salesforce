/* ---------------------------------------------------------------------------------------------------------------------
Name:            CrabbEngineInitializer.cls
Description:
Test class:      TestCrabbEngineInitializer.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
08-Oct-2021  0.2     C. Sanna                         Modified for adding check permission:
                                                      cebCheckObjPermission (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

global class CrabbEngineInitializer implements Database.Batchable<sObject>
{
    //private mapping_status_pratica__mdt msp {get; set;}
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    private static final Set<String> praticaAperta = getStatusList('CRABB_DEV__stati_in_lavorazione__c');
    private List<CEB__c> lCEB = new List<CEB__c>();
    private Set<String> PDFTemplateSet = new Set<String>();
    private Map<String, CRABB_DEV__ManageCaseMapping__mdt> mappingCaseMdtMap = new Map<String, CRABB_DEV__ManageCaseMapping__mdt>();
    private Integer iSCH = 0;
    private Integer iWAI = 0;
    private Integer iCASE = 0;
    private Integer iPDF = 0;
    
    global CrabbEngineInitializer()
    {
        /*** Constructor - Start ***/
        List<CRABB_DEV__ManageCaseMapping__mdt> mappingCaseMdt = [
                SELECT Id, DeveloperName, CRABB_DEV__FieldTarget__c, CRABB_DEV__FieldSource__c, CRABB_DEV__StaticValue__c,
                        CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__Tipo__c, CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__Sottotipo__c, CRABB_DEV__sObjectSource__c
                FROM CRABB_DEV__ManageCaseMapping__mdt
                WHERE CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__SourceObject__c = 'ActivityExtended__c'
                WITH SECURITY_ENFORCED
        ];

        for (CRABB_DEV__ManageCaseMapping__mdt mapCase : mappingCaseMdt) 
        {
            if (!mappingCaseMdtMap.containsKey(mapCase.CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__Tipo__c + ' ' + mapCase.CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__Sottotipo__c)) 
            {
                mappingCaseMdtMap.put(mapCase.CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__Tipo__c + ' ' + mapCase.CRABB_DEV__ManageCaseHeader__r.CRABB_DEV__Sottotipo__c, mapCase);
            }
        }

        List<CRABB_DEV__CRABB_PDF_from_Template__mdt> PDFTemplateList = [
            	SELECT CRABB_DEV__Tipo_Sottotipo__c 
            	FROM CRABB_DEV__CRABB_PDF_from_Template__mdt 
            	WHERE CRABB_DEV__Active__c = true 
            	WITH SECURITY_ENFORCED];
        
        for (CRABB_DEV__CRABB_PDF_from_Template__mdt pdfTemp : PDFTemplateList) 
        {
            PDFTemplateSet.add(String.valueOf(pdfTemp.CRABB_DEV__Tipo_Sottotipo__c));
        }
        System.debug('PDFTemplateSet --> ' + PDFTemplateSet);

        /*** Constructor - End ***/
    }

    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        /*** Query - Start ***/
        
        string query = 'SELECT id,Stato__c FROM Pratica__c WHERE Stato__c IN :praticaAperta';
        System.debug('Query CrabbEngineInitializer --> ' + query);
        return Database.getQueryLocator(query);
        
        /*** Query - End ***/
    }
    
    global void execute(Database.BatchableContext BC, List<Pratica__c> scope)
    {
        /*** Execute - Start ***/
        System.debug('scope size --> ' + scope.size());
        Map<Id,String> mPrat = new Map<Id,String>();
        //Set<Id> sPrat = new Set<Id>();
        for(Pratica__c p : scope)
        {
            //sPrat.add(p.Id);
            mPrat.put(p.Id,p.Stato__c);
        }
        List<CEB__c> lExistingCEBs = [SELECT Pratica__c,Type__c,Status__c FROM CEB__c
                                        Where Pratica__c IN :mPrat.keySet()
                                        AND Status__c IN ('New','Blocked')
                                        WITH SECURITY_ENFORCED];

        Map<Id,List<CEB__c>> mCeb = new Map<Id,List<CEB__c>>();

        For(CEB__c c : lExistingCEBs)
        {
            List<CEB__c> lCebs = new List<CEB__c>();

            if(mCeb.containsKey(c.Pratica__c))
            {
                lCebs = mCeb.get(c.Pratica__c);
                lCebs.add(c);
            }
            else
                lCebs.add(c);

            mCeb.put(c.Pratica__c,lCebs);
        }

        System.debug('lExistingCEBs size --> ' + lExistingCEBs.size());

        List<Task> lExistingTasks = [SELECT
                                        Id,
                                        WhatId,
                                        ActivityExtended__c,
                                        ActivityExtended__r.Tipo_Sottotipo__c,
                                        ActivityExtended__r.RecordType.DeveloperName
                                    FROM
                                        Task
                                    WHERE
                                        WhatId IN :mPrat.keySet()
                                        AND Status IN ('Non iniziata','Bloccata')
                                        AND Type = 'Credito'
                                    WITH SECURITY_ENFORCED];

        Map<Id,List<Task>> mTask = new Map<Id,List<Task>>();

        For(Task t : lExistingTasks)
        {
            List<Task> lTasks = new List<Task>();

            if(mTask.containsKey(t.WhatId))
            {
                lTasks = mTask.get(t.WhatId);
                lTasks.add(t);
            }
            else
                lTasks.add(t);

            mTask.put(t.WhatId,lTasks);
        }

        System.debug('lExistingTasks size --> ' + lExistingTasks.size());

        List<CEB__c> lInsertCebs = new List<CEB__c>();

        checkExistingScheduling(mPrat, lInsertCebs, mCeb);
        iSCH = lInsertCebs.size();
        System.debug('lInsertCebs SCH size --> ' + iSCH);
        checkExistingWait(mPrat, lInsertCebs, mCeb, mTask);
        iWAI = lInsertCebs.size();
        System.debug('lInsertCebs WAI size --> ' + iWAI);
        checkExistingCase(mPrat, lInsertCebs, mCeb, mTask);
        iCASE = lInsertCebs.size();
        System.debug('lInsertCebs CASE size --> ' + iCASE);
        checkExistingPDF(mPrat, lInsertCebs, mCeb, mTask);
        iPDF = lInsertCebs.size();
        System.debug('lInsertCebs PDF size --> ' + iPDF);
        /*** Execute - End ***/

        //if(lInsertCebs.size()>0)
        if(lInsertCebs.size()>0 && Utils.cebCheckObjPermission('CEB__c', gd).get('INSERT')) {
            insert lInsertCebs;
        }

    }
    
    global void finish(Database.BatchableContext BC)
    {
        /*** Finish - Start ***/
        
        /*** Finish - End ***/
    }
    
    //returns a list of picklist values with closed or open status
    public static Set<String> getStatusList(String s) {
        List<String> statusList = new List<String>();
        List<SObject> mappingStatusList = new List<SObject>();
        String lbl = 'CrabbEngineInitializer';
        String query2 = 'SELECT ' + String.escapeSingleQuotes(s) +' FROM CRABB_DEV__mapping_status_pratica__mdt where label =:lbl WITH SECURITY_ENFORCED';
        mappingStatusList = Database.query(query2);
        statusList = String.valueOf(mappingStatusList.get(0).get(s)).split('\\|');

        return new Set<String>(statusList);
    }

    private void checkExistingScheduling(Map<Id,String> mPrat, List<CEB__c> lInsertCebs, Map<Id,List<CEB__c>> mCeb)
    {
        for(Id pId: mPrat.keySet())
        {
            String pStato = mPrat.get(pId);
            Boolean bSCHExist = false;
            if(mCeb.containsKey(pId))
            {
                List<CEB__c> lCs = mCeb.get(pId);
                for(CEB__c c: lCs)
                {
                    if(c.Type__c == 'SCH')
                    {
                        bSCHExist = true;
                        System.Debug('SCH exists --> ' + pId);
                    }
                }
            }

            if(!bSCHExist)
            {
                System.Debug('SCH not exists --> ' + pId);
                CEB__c evt = new CEB__c();
                evt.CRABB_DEV__ActivityExtended__c=null;
                evt.CRABB_DEV__Immediate_Action__c=false;
                evt.CRABB_DEV__Pratica__c=pId;
                evt.CRABB_DEV__Type__c='SCH';
                if(pStato == 'Bloccata' || pStato == 'Bloccata Manualmente')
                {
                    evt.CRABB_DEV__Status__c='Blocked';
                }
                else
                {
                    evt.CRABB_DEV__Status__c='New';
                }
                lInsertCebs.add(evt);
            }
        }
    }

    private void checkExistingWait(Map<Id,String> mPrat, List<CEB__c> lInsertCebs, Map<Id,List<CEB__c>> mCeb, Map<Id,List<Task>> mTask)
    {
        for(Id pId: mPrat.keySet())
        {
            if(mTask.containsKey(pId))
            {
                for (Task t : mTask.get(pId))
                {
                    if(t.ActivityExtended__r.RecordType.DeveloperName == 'Expectance')
                    {
                        String pStato = mPrat.get(pId);
                        Boolean bWAIExist = false;

                        if (mCeb.containsKey(pId)) {
                            List<CEB__c> lCs = mCeb.get(pId);
                            for (CEB__c c : lCs) {
                                if (c.Type__c == 'WAI')
                                    bWAIExist = true;
                            }
                        }

                        if (!bWAIExist) {
                            CEB__c evt = new CEB__c();
                            evt.CRABB_DEV__ActivityExtended__c = t.ActivityExtended__c;
                            evt.CRABB_DEV__Immediate_Action__c = false;
                            evt.CRABB_DEV__Pratica__c = pId;
                            evt.CRABB_DEV__Type__c = 'WAI';
                            if (pStato == 'Bloccata' || pStato == 'Bloccata Manualmente') {
                                evt.CRABB_DEV__Status__c = 'Blocked';
                            } else {
                                evt.CRABB_DEV__Status__c = 'New';
                            }
                            lInsertCebs.add(evt);
                        }
                    }
                }
            }
        }
    }
    
    private void checkExistingCase(Map<Id,String> mPrat, List<CEB__c> lInsertCebs, Map<Id,List<CEB__c>> mCeb, Map<Id,List<Task>> mTask)
    {
        for(Id pId: mPrat.keySet())
        {
            if(mTask.containsKey(pId))
            {
                for (Task t : mTask.get(pId))
                {
                    if (mappingCaseMdtMap.containsKey(t.ActivityExtended__r.Tipo_Sottotipo__c))
                    //if(t.ActivityExtended__r.RecordType.DeveloperName == 'Expectance')
                    {
                        String pStato = mPrat.get(pId);
                        Boolean bNCAExist = false;

                        if (mCeb.containsKey(pId)) {
                            List<CEB__c> lCs = mCeb.get(pId);
                            for (CEB__c c : lCs) {
                                if (c.Type__c == 'NCA')
                                    bNCAExist = true;
                            }
                        }

                        if (!bNCAExist) {
                            CEB__c evt = new CEB__c();
                            evt.CRABB_DEV__ActivityExtended__c = t.ActivityExtended__c;
                            evt.CRABB_DEV__Immediate_Action__c = true;
                            evt.CRABB_DEV__Pratica__c = pId;
                            evt.CRABB_DEV__Type__c = 'NCA';
                            if (pStato == 'Bloccata' || pStato == 'Bloccata Manualmente') {
                                evt.CRABB_DEV__Status__c = 'Blocked';
                            } else {
                                evt.CRABB_DEV__Status__c = 'New';
                            }
                            lInsertCebs.add(evt);
                        }
                    }
                }
            }
        }
    }
    
    private void checkExistingPDF(Map<Id,String> mPrat, List<CEB__c> lInsertCebs, Map<Id,List<CEB__c>> mCeb, Map<Id,List<Task>> mTask)
    {
        for(Id pId: mPrat.keySet())
        {
            if(mTask.containsKey(pId))
            {
                for (Task t : mTask.get(pId))
                {
                    if (PDFTemplateSet.contains(t.ActivityExtended__r.Tipo_Sottotipo__c))
                    //if(t.ActivityExtended__r.RecordType.DeveloperName == 'Expectance')
                    {
                        String pStato = mPrat.get(pId);
                        Boolean bPDFExist = false;

                        if (mCeb.containsKey(pId)) {
                            List<CEB__c> lCs = mCeb.get(pId);
                            for (CEB__c c : lCs) {
                                if (c.Type__c == 'PDF')
                                    bPDFExist = true;
                            }
                        }

                        if (!bPDFExist) {
                            CEB__c evt = new CEB__c();
                            evt.CRABB_DEV__ActivityExtended__c = t.ActivityExtended__c;
                            evt.CRABB_DEV__Immediate_Action__c = true;
                            evt.CRABB_DEV__Pratica__c = pId;
                            evt.CRABB_DEV__Type__c = 'PDF';
                            if (pStato == 'Bloccata' || pStato == 'Bloccata Manualmente') {
                                evt.CRABB_DEV__Status__c = 'Blocked';
                            } else {
                                evt.CRABB_DEV__Status__c = 'New';
                            }
                            lInsertCebs.add(evt);
                        }
                    }
                }
            }
        }
    }
}