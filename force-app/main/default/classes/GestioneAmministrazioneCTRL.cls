/* ---------------------------------------------------------------------------------------------------------------------
Name:            GestioneAmministrazioneCTRL.cls
Description:
Test class:      TestGestioneAffidamentiCTRL.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
13-Sep-2022  0.2      C.sanna & Rei Kurti  Modified for adding check permission: cebCheckFLSPermission/cebCheckObjPermission/
                                           WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/
global with sharing class GestioneAmministrazioneCTRL {
    
    public Map<Id,String> mapProfileId                                      {get; set;}
    public List<AmministrazioneSettings__c> listAmmSett                     {get; set;}
    public List<SelectOption> profileOptions                                {get; set;}
    public String selectedProfile                                           {get; set;}
    public Boolean selectedCanAccess                                        {get; set;}
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public GestioneAmministrazioneCTRL() {
        
        String asQuery = 'SELECT '+Utils.getSOBJECTFieldsForQuery('AmministrazioneSettings__c')+' FROM AmministrazioneSettings__c';
        listAmmSett = Database.query(String.escapeSingleQuotes(asQuery));

        if(listAmmSett != null && !listAmmSett.isEmpty()){

            AmministrazioneSettings__c defaultOrg = AmministrazioneSettings__c.getOrgDefaults();

            Set<String> idsProf = new Set<String>();
            for(AmministrazioneSettings__c las : listAmmSett){
                idsProf.add(las.SetupOwnerId);
            }

            mapProfileId = new Map<Id,String>();
            profileOptions = new List<SelectOption>();
            profileOptions.add(new SelectOption('','-- None --'));
            mapProfileId.put(defaultOrg.SetupOwnerId,'Organization Default');
            if(Utils.cebCheckObjPermission('Profile',gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Profile','Name',gd).get('ACCESS')) {
                List<Profile> profList = [SELECT Id, Name FROM Profile WITH SECURITY_ENFORCED];
                //List<Profile> profList = [SELECT Id, Name FROM Profile WITH SECURITY_ENFORCED];

                for (Profile p : profList) {

                    if (idsProf.contains(p.Id)) {
                        mapProfileId.put(p.Id, p.Name);
                    }

                    profileOptions.add(new SelectOption(p.Name + '_' + p.Id, p.Name));

                }

                profileOptions.sort();
            }
        }

    }

    public PageReference updateRecords(){

        if (Utils.cebCheckObjPermission('AmministrazioneSettings__c',gd).get('UPDATE')) {
            update listAmmSett;
        }

        PageReference page = new PageReference('/apex/GestioneAmministrazione');
        page.setRedirect(true);
        return page;

    }

    @RemoteAction
    global static String removeRecord(String paramId){

        AmministrazioneSettings__c toRemove = new AmministrazioneSettings__c(Id=paramId);

        if(Utils.cebCheckObjPermission('AmministrazioneSettings__c', gd).get('DELETE')){
            delete toRemove;
        }

        return '/apex/GestioneAmministrazione';
    }

    @RemoteAction
    public static String addNewRecord(String profParam,Boolean pu, Boolean ap, Boolean ca, Boolean cs, Boolean ec, Boolean cp, Boolean cc, Boolean fc, Boolean ac, Boolean go, Boolean el, Boolean cm, Boolean co, Boolean is, Boolean fsc){

        try{

            if(profParam != null && String.isNotBlank(profParam)){

                AmministrazioneSettings__c newAS = new AmministrazioneSettings__c();
                newAS.SetupOwnerId = profParam.split('_')[1];
                newAS.AffidoCollector__c = ac;
                newAS.AttivitaProfili__c = ap;
                newAS.ConfigurazioneAmministrazione__c = ca;
                newAS.ConfigurazioneCollector__c = cc;
                newAS.ConfigurazioneMapping__c = cm;
                newAS.ConfigurazioneStrategie__c = cs;
                newAS.CruscottoPratica__c = cp;
                newAS.EstrattoConto__c = ec;
                newAS.FlussiCollector__c = fc;
                newAS.GestioneOrkBatch__c = go;
                newAs.EliminazioneLog__c = el;
                newAS.ProfilazioneUtenti__c = pu;
                newAS.CostiAttivita__c = co;
                newAS.ImportStrategie__c = is;
                newAs.FasceCollector__c = fsc;

                if(Utils.cebCheckObjPermission('AmministrazioneSettings__c', gd).get('CREATE')
                        && Utils.cebCheckObjPermission('AmministrazioneSettings__c', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('AmministrazioneSettings__c','SetupOwnerId', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('AmministrazioneSettings__c','AffidoCollector__c', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('AmministrazioneSettings__c','AttivitaProfili__c', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('AmministrazioneSettings__c','ConfigurazioneAmministrazione__c', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('AmministrazioneSettings__c','ConfigurazioneCollector__c', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('AmministrazioneSettings__c','ConfigurazioneMapping__c', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('AmministrazioneSettings__c','ConfigurazioneStrategie__c', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('AmministrazioneSettings__c','CruscottoPratica__c', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('AmministrazioneSettings__c','EstrattoConto__c', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('AmministrazioneSettings__c','FlussiCollector__c', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('AmministrazioneSettings__c','GestioneOrkBatch__c', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('AmministrazioneSettings__c','EliminazioneLog__c', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('AmministrazioneSettings__c','ProfilazioneUtenti__c', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('AmministrazioneSettings__c','CostiAttivita__c', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('AmministrazioneSettings__c','ImportStrategie__c', gd).get('INSERT')
                        && Utils.cebCheckFLSPermission('AmministrazioneSettings__c','FasceCollector__c', gd).get('INSERT')){
                    insert newAS;
                }

            }

        }catch(Exception ex){
            System.debug('Exception in GestioneAmministrazioneCTRL::addNewRecord --> '+ex.getStackTraceString()+' --- '+ex.getMessage());
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Unable to continue : '+ex.getMessage()));
            return 'error';
        }

        return '/apex/GestioneAmministrazione';

    }

}