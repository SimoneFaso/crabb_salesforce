/* ---------------------------------------------------------------------------------------------------------------------
Name:            FlussiColDownloadZipCTRL.cls
Description:
Test class:      TestFlussiColDownloadZipCTRL.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------

02-Oct-2014  0.1      Endrit Sino                     First version
27-Sep-2021  0.2      Matteo Pizzichini               Modified for adding check permission:
                                                      cebCheckFLSPermission (Security Review)
13-Sep-2022  0.3      C.Sanna & R. Kurti              Modified for adding check permission:
                                                      cebCheck Obj/FLS permission (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class FlussiColDownloadZipCTRL {
    public class FlussiColDownloadZipCTRLException extends Exception{}
   
    public List<Attachment> myAttach;  
    public List<RowTable> myAttachWrapp{get;set;}
    public Flussi_collector__c fc{get;set;}
    public Map<String, Map<String,String>> keepTrackOfDl;
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();


    public String queryAttach;   
    public String lastDownloadDate{get;set;}
    
    public boolean errorLoadingFlusso{get;set;}
    
    //costruttore
    public FlussiColDownloadZipCTRL(ApexPages.StandardController controller) {
        
        errorLoadingFlusso = false;
        
        this.fc=(Flussi_collector__c)controller.getRecord();
        if(fc!=null && fc.id!=null){
            String flussoID = fc.id;
            //if(Utils.checkFLSPermission('Flussi_Collector__c', 'Track_Downloaded_File__c').get('ACCESS'))
            if(Utils.cebCheckObjPermission('Flussi_Collector__c',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Flussi_Collector__c', 'Track_Downloaded_File__c',gd).get('ACCESS'))
            {
                fc = Database.query('Select Track_Downloaded_File__c From Flussi_Collector__c Where id =: flussoID');
            }
            flussoID = String.escapeSingleQuotes(flussoID);
            queryAttach = 'Select id, Name  From Attachment where parentID=\''+flussoID+'\' ';
        }
        else{
            errorLoadingFlusso = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,' Nessuna operazione é eseguibile! '));                
            return;
        }
        
        // inizia mapa
        if(fc.Track_Downloaded_File__c != null){
            keepTrackOfDl = new Map<String, Map<String,String>>();
                        
            // serializza e popola campo
            Map<String, Map<String, Object>> tmpMap = new Map<String, Map<String, Object>>();
            tmpMap = (Map<String, Map<String,String>>)JSON.deserialize(fc.Track_Downloaded_File__c, Map<String, Map<String,String>>.class);
            keepTrackOfDl = (Map<String, Map<String,String>>)tmpMap;
        }
        else
            keepTrackOfDl = new Map<String, Map<String,String>>();
        
        // popola tabellone
        myAttachWrapp = getAttachments();
    }
    
    // chiedi i attachment dal DB
    public List<RowTable> getAttachments(){
        myAttachWrapp = new List<RowTable>();
         /*if (Utils.checkFLSPermission('Attachment','ParentId').get('ACCESS')
            && Utils.checkFLSPermission('Attachment','body').get('ACCESS')
            && Utils.checkFLSPermission('Attachment','Name').get('ACCESS')
            && Utils.checkFLSPermission('Attachment','IsPrivate').get('ACCESS')
            ){ */
             if (Utils.cebCheckObjPermission('Attachment',gd).get('ACCESS') && Utils.cebCheckFLSPermission('Attachment','ParentId',gd).get('ACCESS')
                     && Utils.cebCheckFLSPermission('Attachment','body',gd).get('ACCESS')
                     && Utils.cebCheckFLSPermission('Attachment','Name',gd).get('ACCESS')
                     && Utils.cebCheckFLSPermission('Attachment','IsPrivate',gd).get('ACCESS')
                     ){
            myAttach = Database.query(queryAttach);
            Map<String,String> attachmentsDownloadedFromTheCurrentUser = keepTrackOfDl.get(userInfo.getUserID());

            for(Attachment a: myAttach){
                if(attachmentsDownloadedFromTheCurrentUser==null ||  attachmentsDownloadedFromTheCurrentUser.get(a.id)==null){
                        myAttachWrapp.add(new RowTable(a, null));
                }
                else myAttachWrapp.add(new RowTable(a, attachmentsDownloadedFromTheCurrentUser.get(a.id)));
            }
            return myAttachWrapp;
        }
        else return null;
    }
    
    // metodo per mettere check il file scaricato
    public pageReference AggiornaElementoLista(){
        String attachId = ApexPages.currentPage().getParameters().get('attachId');
        //throw new FlussiColDownloadZipCTRLException('ID:'+attachId);
        for(RowTable wrapAttach: myAttachWrapp)
        {
            if(wrapAttach.Attach.id == attachId ){
                // aggiorna ultimo download
                lastDownloadDate = String.valueOf(System.now().day()+'/'+System.now().month()+'/'+System.now().year()+' '+System.now().Time());
                
                wrapAttach.isSelected = true;
                wrapAttach.lastDownDate = lastDownloadDate;                   
                
                Map<String, String> tmpMap = new Map<String, String>();
                tmpMap.put(wrapAttach.attach.id, lastDownloadDate);
                keepTrackOfDl.put(UserInfo.getUserId(), tmpMap);
                        
                // serializza e popola campo
                fc.Track_Downloaded_File__c = JSON.serialize(keepTrackOfDl);
                try{
                    //if (Utils.checkFLSPermission('Flussi_collector__c', 'Track_Downloaded_File__c').get('UPDATE')) update fc;
                    if (Utils.cebCheckObjPermission('Flussi_collector__c',gd).get('UPDATE')
                            && Utils.cebCheckFLSPermission('Flussi_collector__c', 'Track_Downloaded_File__c',gd).get('UPDATE')) {
                        update fc;
                    }
                }
                catch(exception e){ 
                    errorClass.logError('FC:','E:'+Utils.getExceptionInString(e)); 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Errore in aggiornamento del sistema. Riprovare più tardi. '));                
                    return null;
                }
                    
                
             }
         }           
         return null;
    }
    
    // classe wrap per visualizzare come checked i file scaricati
    public class RowTable{
        public Attachment attach{get;set;}
        public Boolean isSelected{get;set;}
        public String lastDownDate{get;set;}
        
        public rowTable(Attachment Attach, String Moddate){
            this.attach = Attach;            

            if(ModDate==null){
                this.isSelected = false;
                this.lastDownDate ='';
            }
            else{
                this.isSelected = true;
                this.lastDownDate =Moddate;            
            }
                
        }
    }
}