/* ---------------------------------------------------------------------------------------------------------------------
Name:            RepContrattiCTRL.cls
Description:
Test class:      TestRepContrattiCTRL.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
16-Jun-2016  0.2      E.Sino               Aggiunto il with sharing come richiesta da Salesforce.com per soddisfare le specifiche
                                           del Security Review.
16-Sep-2022  0.3      C.Sanna & R.Kurti    Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class RepContrattiCTRL {

    //public List<String> AllReports {get; set;}
    //public Map<String,String> mAllReports {get; set;}
    public String Report1 { get; set; }
    public String Report2 { get; set; }
    public String Report3 { get; set; }
    public String Report4 { get; set; }
    public String Report5 { get; set; }
    public String Report6 { get; set; }
    private final Contratto__c contr;
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public RepContrattiCTRL(ApexPages.StandardController controller) {

        this.contr = (Contratto__c) controller.getRecord();
        //mAllReports = new Map<String,String>();
        //AllReports = new List<String>();
        if (Utils.cebCheckObjPermission('Report', gd).get('ACCESS')
        && Utils.cebCheckFLSPermission('Report','Name',gd).get('ACCESS')) {
            for (Report r : [
                    Select Id, Name
                    From Report
                    Where Format In ('Summary', 'Matrix') and
                    Name in (
                            'STORICO MENSILE SCADUTO SERVIZI/COMUNE',
                            'REPORT MENSILE ANNO SU ANNO',
                            'SCADUTO FRUITORE X COSTO PASTO',
                            'NUMERO FRUITORI MOROSI X COSTO PASTO',
                            'REPORT DELLE ATTIVITÀ UI (ULTIMI 30GG)')
                    //WITH SECURITY_ENFORCED
                    Order By Name
            ]) {

                if (r.Name.toUpperCase() == 'STORICO MENSILE SCADUTO SERVIZI/COMUNE')
                    Report1 = r.Id;
                else if (r.Name.toUpperCase() == 'REPORT MENSILE ANNO SU ANNO')
                    Report2 = r.Id;
                else if (r.Name.toUpperCase() == 'SCADUTO FRUITORE X COSTO PASTO')
                    Report3 = r.Id;
                else if (r.Name.toUpperCase() == 'NUMERO FRUITORI MOROSI X COSTO PASTO')
                    Report4 = r.Id;
                else if (r.Name.toUpperCase() == 'REPORT DELLE ATTIVITÀ UI (ULTIMI 30GG)')
                    Report5 = r.Id;

                /*  else if(r.Name.toUpperCase() == 'Report Mensile Anno su Anno')
                    Report6 = r.Id;
                */
                //AllReports.add(r.Id);
            }
        }
    }

    /*public List<String> getAllReports() {
        
        return lRept;
    }*/
}