/* ---------------------------------------------------------------------------------------------------------------------
Name:            CruscottoClienteCTRL.cls
Description:
Test class:      TestCoverageCruscotto.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1      E. Sino                         First Version
13-Sep-2022  0.2      C.Sanna & R. Kurti              Added WITH SECURITY_ENFORCED (Security Review)
11-Oct-2022  0.3      R.Kurti & C.Sanna               Added cebCheckObj and remove WITH SECURITY ENFORCED
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class CruscottoClienteCTRL {
    
    Public Boolean bId { get; set; }
    Public Decimal MaxRes{ get; set; }
    Public Integer Max{ get; set; }
    Public Integer PagAttuale{ get; set; }
    Public Integer NPag{ get; set; }
    Public Integer Inizio{ get; set; }
    Public Integer Fine{ get; set; }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    Public List<Task> lTsk{get; set;}
    Public List<String> LastYear {get; set;}
    Public List<String> TipoAtt {get; set;}
    Public Map<String, Map<String, Integer>> mMesiAtt {get; set;}
    
    Public class TimeLine
    {
        String Id {get; set;}
        String content {get; set;}
        String start {get; set;}
        //String end {get; set;}
    }
    
    Public String getTLTask() 
    {
        List<TimeLine> ltl = new List<TimeLine>();
        if(Utils.cebCheckObjPermission('Task',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'ActivityExtended__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'CreatedDate',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Task', 'LastModifiedDate',gd).get('ACCESS')
                && Utils.cebCheckObjPermission('ActivityExtended__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('ActivityExtended__c', 'Tipo__c',gd).get('ACCESS')) {
            //List<Task> lt = [SELECT Tipo__c,CreatedDate, LastModifiedDate FROM Task where WhatId = :acct.Id order by CreatedDate ASC];
            List<Task> lt = [
                    SELECT ActivityExtended__r.Tipo__c, CreatedDate, LastModifiedDate
                    FROM Task
                    where ActivityExtended__r.Account_id__c = :acct.Id
                    //WITH SECURITY_ENFORCED
                    order by CreatedDate ASC
            ];
            List<Map<String, String>> lmss = new List<Map<String, String>>();
            Integer i = 0;

            for (Task t : lt) {
                TimeLine tl = new TimeLine();
                tl.Id = String.ValueOf(i);
                tl.content = t.ActivityExtended__r.Tipo__c;
                String anno = String.ValueOf(t.CreatedDate.year());
                String mese = String.ValueOf(t.CreatedDate.month());
                if (t.CreatedDate.month() < 10)
                    mese = '0' + t.CreatedDate.month();
                String giorno = String.ValueOf(t.CreatedDate.day());
                if (t.CreatedDate.day() < 10)
                    giorno = '0' + t.CreatedDate.day();
                tl.start = anno + '-' + mese + '-' + giorno;
                ltl.add(tl);
            }
        }
        return Json.serialize(ltl);
    }
    
    private final Account acct;

    public CruscottoClienteCTRL(ApexPages.StandardController controller) 
    {
        system.debug(logginglevel.INFO, '****ENTRO NEL COSTRUTTORE****');
        if(ApexPages.currentPage().getParameters().get('Id') == null)
        {
            //bSearch = false;
            bId = false;
        }
        else
        {
            if(!test.isRunningTest())
            {
                PagAttuale = 1;
                List<String> fields = new List<String>();
                fields.add('Name');
                fields.add('AccountNumber');
                fields.add('BillingStreet');
                fields.add('BillingPostalCode');
                fields.add('BillingCity');
                fields.add('BillingState');
                fields.add('Saldo_Movimenti_Scaduti__c');
                fields.add('Movimenti_Scaduti_Sollecitabili__c');
                controller.addFields(fields);
            }
            this.acct = (Account)controller.getRecord();
            
            //ListOfObjects LOO = new ListOfObjects();
            Id cliId = acct.Id;
            if(cliId == null)
                bId = false;
       
            bId = true;
            //Recupero le Attività
            /*lTsk = LOO.qTsk('Cliente', cliId);
            //Creo la mappa delle attività per mese
            MapTsk mt = new MapTsk();
            mMesiAtt = new Map<String, Map<String, Integer>>();
            mt.CreateMapTsk (lTsk);
            mMesiAtt = mt.mMesiAtt;
            LastYear = mt.LastYear;
            TipoAtt = mt.TipoAtt;*/
        }
    }
    
    Public String getListViewId()
    {
        String internalListViewId = '';
        
        DefaultView__c cs = DefaultView__c.getValues('Account');
        internalListViewId = cs.View_Id__c;
        return internalListViewId;
    }
    
    /*public void Sollecito() 
    {
        System.debug('Sollecito: ' + String.valueOf(acct.Id));
        acct.Invio_Sollecito__c = true;
        update acct;
        System.Debug('Mail Inviata');
        Id parentId = acct.Id;
        System.Debug('Parent Id: ' + String.ValueOf(parentId));
        System.Debug('# Movimenti Scaduti: ' + String.ValueOf(acct.Movimenti_Scaduti_Sollecitabili__c));
        PageReference pdf = Page.LetteraSollecito;
        // add parent id to the parameters for standardcontroller
        pdf.getParameters().put('Id',parentId);
        System.Debug('Chiamata al PDF');
        // create the new attachment
        Attachment attach = new Attachment();
     
        // the contents of the attachment from the pdf
        Blob body;
        System.Debug('Inizio TRY');
        try 
        {
            System.Debug('OK1');
            // returns the output of the page as a PDF
            if (Test.IsRunningTest())
            {
                 body = Blob.valueOf('UNIT.TEST');
            }
            else
            {
                 body = pdf.getContent();
            }
            
            attach.Body = body;
            // add the user entered name
            
            Date oggi = date.Today();
            String giorno = string.ValueOf(oggi.day());
            String mese = string.ValueOf(oggi.month());
            String anno = string.ValueOf(oggi.year());
            attach.Name = acct.AccountNumber + '_Sollecito_' + anno + mese + giorno + '.pdf';
            attach.IsPrivate = false;
            // attach the pdf to the account
            attach.ParentId = parentId;
            insert attach;
            
            // need to pass unit test -- current bug    
            System.Debug('OK2');
        } 
        catch (VisualforceException e) 
        {
            System.Debug('KO');
            ApexPages.addMessages(e);
        }
        System.Debug('FINE');
    }*/
    
    public List<ChrtData> getPieData() 
    {
        ChrtData cData = new ChrtData('',0,0);
        List<ChrtData> data = CData.lChrtData(acct.Id,'Cliente');
        return data;
    }
    
    public List<ChrtSaldi> ChrtSaldi
    {   
        get{ 
        ChrtSaldi cSaldi = new ChrtSaldi('','','',0,0,0,'','',false);
        if(acct.Id == null)
            return null;
        List<ChrtSaldi> saldi = cSaldi.Json2Chrt(acct.Id,'Cliente');
        if(saldi == null || saldi.size() == 0)
        {
            return null;
        }
        return saldi;}
        
        set{}
    }
 
    public List<ChrtSaldi> getListSaldi()
    {    
        if(ChrtSaldi==null){
            NPag = 0;
            Inizio = 0;
            Fine = 0;
            PagAttuale = 0;
            return null;
        }
        NPag = ChrtSaldi.size()/10;
        if(Math.Mod(ChrtSaldi.size(),10)>0){
            NPag++;
        }
        Inizio = ChrtSaldi.size()-PagAttuale*10+10;
        Fine = ChrtSaldi.size()-PagAttuale*10;
        if(Fine<0)
            Fine = 0;
        List<ChrtSaldi> lSaldi = new List<ChrtSaldi>();
        for(Integer i = Inizio-1; i>=Fine; i--){
            lSaldi.add(ChrtSaldi[i]);
        }
        return lSaldi;
    }
    
    public List<StackedData> getStkData() 
    {
        Max = 0;
        MaxRes = 0;
        StackedData stkData = new StackedData('',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
        List<StackedData> stacked = stkData.lStkData(acct.Id,'Cliente');
        Max = stkData.Max;
        MaxRes = stkData.MaxRes;
        return stacked ;  
    }
    
    //Public String IdReport {get;set;}
    Public String getIdReport()
    {
        Id ir = [SELECT Id FROM Report WHERE Name = 'Andamento Saldi ultimi 4 mesi' Limit 1].Id;
        
        return string.ValueOf(ir);
    }
    
    public Boolean getDisableNext() 
    { 
        if (Fine==0) 
            return true; 
        else 
            return false;
    }
    
    public Boolean getDisablePrevious() 
    { 
        if (PagAttuale==1||NPag==0) 
            return true; 
        else 
            return false;
    }
    
    public PageReference Next() 
    { 
        PagAttuale++;
        return null;
    }
    
    public PageReference Previous() 
    { 
        PagAttuale--;
        return null;
    }
    
    public PageReference Beginning() 
    { 
        PagAttuale = 1;
        return null;
    }
    
    public PageReference End() 
    { 
        PagAttuale = NPag;
        return null;
    }
    
     Public void Refresh() {}
    
}