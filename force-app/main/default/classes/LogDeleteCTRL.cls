/* ---------------------------------------------------------------------------------------------------------------------
Name:            LogDeleteCTRL.cls
Description:
Test class:      TESTLogDeleteCTRL.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
16-Sep-2022  0.2      R.Kurti & C.Sanna    Added WITH SECURITY ENFORCED (security review)
13-Oct-2022  0.3      R.Kurti & C.Sanna    Removed WITH SECURITY ENFORCED and added cebChecks
----------------------------------------------------------------------------------------------------------------------*/
global with sharing class LogDeleteCTRL {

    public Integer count { get; set; }
    public Datetime oldestLog { get; set; }
    public Datetime newestLog { get; set; }
    public TempWrapper tw { get; set; }
    public Schedule_Batch__c tempFROM { get; set; }
    public Schedule_Batch__c tempTO { get; set; }
    public String message { get; set; }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public String dateFrom { get; set; }
    public String dateTo { get; set; }

    public LogDeleteCTRL() {
        String countQuery = 'SELECT COUNT() FROM Log__c LIMIT 49990';
        count = Database.countQuery(countQuery);
        if (Utils.cebCheckObjPermission('Log__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Log__c', 'CreatedDate', gd).get('ACCESS')) {
            //List<Log__c> oldList = [SELECT Id, CreatedDate FROM Log__c WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
            //List<Log__c> newList = [SELECT Id, CreatedDate FROM Log__c WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC LIMIT 1];
            List<Log__c> oldList = [SELECT Id, CreatedDate FROM Log__c ORDER BY CreatedDate DESC LIMIT 1];
            List<Log__c> newList = [SELECT Id, CreatedDate FROM Log__c ORDER BY CreatedDate ASC LIMIT 1];

            if (count > 0) {
                tw = new TempWrapper(count, oldList[0].CreatedDate, newList[0].CreatedDate);
            } else {
                tw = new TempWrapper(0, null, null);
            }
        }
        tempFROM = new Schedule_Batch__c();
        tempTO = new Schedule_Batch__c();
    }

    public PageReference deleteAll() {

        Database.executeBatch(new BatchDeleteLogs());

        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Delete is running.'));

        /*PageReference page = new PageReference('/apex/LogDelete');
        page.setRedirect(true);
        return page;*/
        return null;
    }

    public PageReference refresh() {
        PageReference page = new PageReference('/apex/LogDelete');
        page.setRedirect(true);
        return page;
    }

    public void showError() {
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, message));
    }

    public void showConfirm() {
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, message));
    }

    @RemoteAction
    global static String deletePartial(String f, String t) {
        String query = '';
        String df = '';
        String dt = '';
        try {
            if (f != null && String.isNotBlank(f)) {
                List<String> splitF = f.split(' ');
                List<String> splitSlash = splitF[0].split('/');
                List<String> splitTime = splitF[1].split('\\.');
                df = splitSlash[2] + '-' + splitSlash[1] + '-';
                df += (splitSlash[0].length() > 1) ? splitSlash[0] : '0' + splitSlash[0];
                df += 'T' + splitTime[0] + ':' + splitTime[1] + ':00Z';
            }

            if (t != null && String.isNotBlank(t)) {
                List<String> splitT = t.split(' ');
                List<String> splitSlash = splitT[0].split('/');
                List<String> splitTime = splitT[1].split('\\.');
                dt = splitSlash[2] + '-' + splitSlash[1] + '-';
                dt += (splitSlash[0].length() > 1) ? splitSlash[0] : '0' + splitSlash[0];
                dt += 'T' + splitTime[0] + ':' + splitTime[1] + ':00Z';
            }

        } catch (Exception ex) {
            return 'invalid';
        }

        if (f != null && String.isNotBlank(f)) {
            if (t != null && String.isNotBlank(t)) {
                query = 'SELECT Id FROM Log__c WHERE CreatedDate >= ' + df + ' AND CreatedDate <= ' + dt;
            } else {
                query = 'SELECT Id FROM Log__c WHERE CreatedDate >= ' + df;
            }
        } else {
            if (t != null && String.isNotBlank(t)) {
                query = 'SELECT Id FROM Log__c WHERE CreatedDate <= ' + dt;
            } else {
                return 'error';
            }
        }

        System.debug('@ ' + query);
        Database.executeBatch(new BatchDeleteLogs(query));

        return 'confirm';
    }

    public class TempWrapper {
        public Integer total { get; set; }
        public Datetime old { get; set; }
        public Datetime ne { get; set; }

        public TempWrapper(Integer i, Datetime dol, Datetime dn) {
            total = i;
            old = dol;
            ne = dn;
        }
    }

}