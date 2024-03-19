/* ---------------------------------------------------------------------------------------------------------------------
Name:            cPaginazione.cls
Description:
Test class:      TestCPaginazione.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
16-Sep-2022  0.2      C.Sanna & R.Kurti    Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class cPaginazione
{
    private integer counter=0;  //keeps track of the offset
    private integer list_size=10;//0; //sets the page size or number of rows
    public integer total_size=0; //used to show user the total size of the list
    public String nRecord { get; set;}
    public String nomeObj { get; set;}
    public String NomeParent { get; set;}
    public Id ParentId { get; set;}
    public String ParentName { get; set;}
    public Id IdRev { get; set; }
    public String sParent {get;set;}
    public String sObj {get;set;}
    public String idParent {get;set;}
    public Account Acct {get;set;}
    public String idReport {get; set;}
    public String accountName {get; set;}
    public String praticaId {get; set;}
 
    public List<String> getlField(){
       if(nomeObj == 'Task' && NomeParent == 'MyTask')
           return ListOfObjects.GetFields(NomeParent);
       else
           return ListOfObjects.GetFields(nomeObj);
    }
    
    public cPaginazione()
    {
        List<Report> repList = [SELECT Id FROM Report WHERE Name = 'MovimentoReport' WITH SECURITY_ENFORCED LIMIT 1];
        idReport = ( repList != null && !repList.isEmpty() ) ? String.valueOf(repList[0].Id) : '';
        //total_size = [select count() from Movimento__c]; //set the total size in the constructor
    }

    public void onLoadHomeComponent(){
        nomeObj = 'Task';
        NomeParent = 'MyTask';
        Account acc = new Account();
        ParentId = acc.Id;
        sParent = NomeParent;
        sObj = nomeObj;
        idParent = ParentId;
    }
    
    Public void Refresh() {}
    
    public SObject[] getObject() 
    {
        try 
        {
            ListOfObjects LOO = new ListOfObjects();
            List <SObject> obj = new List <SObject>();
            
            if(nomeObj == 'Movimento__c')
            {
                obj = LOO.qMov_Offset(NomeParent, ParentId, ParentName, list_size, counter);
                total_size = LOO.qMov_Count(NomeParent, ParentId, ParentName);
                if( obj!=null && !obj.isEmpty() ){
                    accountName = ((Movimento__c)obj[0]).Account__r.Name;
                    praticaId = ((Movimento__c)obj[0]).Pratica__r.Name;
                }
            }
            else if(nomeObj == 'Piano_di_Rientro__c')
            {
                obj = LOO.qPDR_Offset(NomeParent, ParentId, list_size, counter);
                total_size = LOO.qPDR_Count(NomeParent, ParentId);
            }
            else if(nomeObj == 'Pratica__c')
            {
                obj = LOO.qPrat_Offset(NomeParent, ParentId, list_size, counter);
                total_size = LOO.qPrat_Count(NomeParent, ParentId);
                system.debug(logginglevel.INFO, 'Ho richiamato i metodi di LOO');
            }
            /*else if(nomeObj == 'SR__c')
            {
                obj = LOO.qSR_Offset(NomeParent, ParentId, list_size, counter);
                total_size = LOO.qSR_Count(NomeParent, ParentId);
            }*/
            else if(nomeObj == 'Attachment')
            {
                obj = LOO.qAtt_Offset(NomeParent, ParentId, list_size, counter);
                total_size = LOO.qAtt_Count(NomeParent, ParentId);
            }
            else if(nomeObj == 'Task')
            {
                obj = LOO.qTsk_Offset(NomeParent, ParentId, list_size, counter);
                total_size = LOO.qTsk_Count(NomeParent, ParentId);
            }
            else if(nomeObj == 'Affidamento__c')
            {
                obj = LOO.qAff_Offset(NomeParent, ParentId, list_size, counter);
                total_size = LOO.qAff_Count(NomeParent, ParentId);
            }
            else if(nomeObj == 'Contact')
            {
                obj = LOO.qInd_Offset(NomeParent, ParentId, list_size, counter); 
                total_size = LOO.qInd_Count(NomeParent, ParentId);
            }
            else if(nomeObj == 'Servizio__c')
            {
                obj = LOO.qSer_Offset(NomeParent, ParentId, list_size, counter);
                total_size = LOO.qSer_Count(NomeParent, ParentId);
            }
            else if(nomeObj == 'Servizi_Item__c')
            {
                obj = LOO.qSItem_Offset(NomeParent, ParentId, list_size, counter);
                total_size = LOO.qSItem_Count(NomeParent, ParentId);
            }
                
            return obj;
        } 
        catch (QueryException e) 
        {
            ApexPages.addMessages(e);
            return null;
        }
    }
 
    public PageReference Beginning() 
    { 
        //user clicked beginning
        counter = 0;
        return null;
    }
 
    public PageReference Previous() 
    { 
        //user clicked previous button
        counter -= list_size;
        return null;
    }
 
    public PageReference Next() 
    { 
        //user clicked next button
        counter += list_size;
        return null;
    }
 
    public PageReference End() 
    { 
        //user clicked end
        if(math.mod(total_size, list_size) == 0)
            counter = total_size - list_size;
        else
            counter = total_size - math.mod(total_size, list_size);
        return null;
    }
 
    public Boolean getDisablePrevious() 
    { 
        //this will disable the previous and beginning buttons
        if (counter>0) 
            return false; 
        else 
            return true;
    }
    
    public Boolean getDisableNext() 
    { 
        //this will disable the next and end buttons
        if (counter + list_size < total_size) 
            return false; 
        else 
            return true;
    }
    
    public Integer getTotal_size() 
    {
        return total_size;
    }
    
    public Integer getPageNumber() 
    {
        Integer nPage = counter/list_size + 1;
        Integer fRec = (list_size * (nPage - 1)) + 1;
        Integer lRec = list_size * nPage;
        if(lRec > Total_size)
           lRec = Total_size;
        nRecord = string.valueOf(fRec) + '-' + string.valueOf(lRec);
        return nPage;
    }
    
    public Integer getTotalPages() 
    {
        if (math.mod(total_size, list_size) > 0) 
        {
            return total_size/list_size + 1;
        } 
        else 
        {
            return (total_size/list_size);
        }
    }
    
    public void RevocaAff()
    {
        /*System.Debug('REVOCA CHIAMATA:' + String.ValueOf(IdRev));
        Revoche rev = new Revoche();
        String esito = rev.Revoca(IdRev);
        System.Debug(esito);*/
    }

    public void createAttachment(){

        CreateAttachmentCTRL.createAttachment(parentId);
    }
    
    public void Email(){
        /*
        id IdAccount = apexpages.currentPage().getParameters().get('Id');
        system.debug('******Id = ' + IdAccount);
        Acct = [Select Id, Name, AccountNumber, Invio_Piano_di_Rientro__c from Account where Id =: IdAccount];
        Acct.Invio_Piano_di_Rientro__c = true;
        update Acct;
        
        System.debug('Piano di Rientro: ' + String.valueOf(acct.Id));

        System.Debug('Mail Inviata');
        Id parentId = acct.Id;
        System.Debug('Parent Id: ' + String.ValueOf(parentId));
        System.Debug('# Movimenti Scaduti: ' + String.ValueOf(acct.Movimenti_Scaduti_Sollecitabili__c));
        PageReference pdf = Page.LetteraPianoDiRientro;
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
            attach.Name = acct.AccountNumber + '_PianoDiRientro_' + anno + mese + giorno + '.pdf';
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
        
        
        /*id IdAccount = apexpages.currentPage().getParameters().get('Id');
        Account Acc = [Select Id, Name, AccountNumber, Invio_Piano_di_Rientro__c from Account where Id =: IdAccount];
        Acc.Invio_Piano_di_Rientro__c = true;
        update Acc;
        try{
           //inserisco il documento pdf negli attachment  
             system.debug('********************************************************  INIZIO');
            PageReference pagina = new PageReference('/apex/LetteraPianoDiRientro?id='+Acc.Id);
            Blob pdf = pagina.getContent();
            Attachment att;
             system.debug('********************************************************  FINE');
            String name = 'Prova: '+Acc.Id+'.pdf';
            List<Attachment> la = [Select Name,Id From Attachment Where Name = :name];
            if(la.size()>0)
                 delete la[0];
                 
            att = new Attachment();
            att.ParentId = Acc.Id; 
            att.Name = name ;
            att.Body = pdf;
            
            
            insert att;
      
        }catch (exception e){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,String.valueof(e)));
            return ;
        }    
        
        
        id IdAccount = apexpages.currentPage().getParameters().get('Id');
        system.debug('******Id = ' + IdAccount);
        Account Acc = [Select Id, Name, AccountNumber, Invio_Piano_di_Rientro__c from Account where Id =: IdAccount];
        Acc.Invio_Piano_di_Rientro__c = true;
        update Acc;
        system.debug('*****Acc.Id = ' + Acc.Id);
        PageReference pdf = new PageReference('/apex/LetteraPianoDiRientro?id='+Acc.Id);
        System.Debug('********Chiamata al PDF');
        Blob body;
        // create the new attachment
        Attachment attach = new Attachment();
     
        // the contents of the attachment from the pdf
        
        System.Debug('*******Inizio TRY');
        try {
            System.Debug('****OK1');
            // returns the output of the page as a PDF
            if (Test.IsRunningTest())
            {
                 body = Blob.valueOf('UNIT.TEST');
            }else{
                System.debug('****GetContent = ' +pdf);
                 body = pdf.getContent();
            }
            system.debug('******body= ' + String.valueOf(body));
            attach.Body = body;
            // add the user entered name
            
            Date oggi = date.Today();
            String giorno = string.ValueOf(oggi.day());
            String mese = string.ValueOf(oggi.month());
            String anno = string.ValueOf(oggi.year());
            attach.Name = Acc.AccountNumber + '_Piano_di_Rientro_' + anno + mese + giorno + '.pdf';
            //attach.IsPrivate = false;
            // attach the pdf to the account
            attach.ParentId = IdAccount;
            attach.ContentType = 'application/pdf';
            insert attach;
            system.debug('attach.Name = ' + attach.Name);

            
            // need to pass unit test -- current bug    
            System.Debug('***OK2');
        }catch (VisualforceException e){
            System.Debug('***KO');
            ApexPages.addMessages(e);
        }
        System.Debug('FINE');*/
    }
}