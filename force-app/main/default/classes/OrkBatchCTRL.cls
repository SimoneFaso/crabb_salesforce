/* ---------------------------------------------------------------------------------------------------------------------
Name:            OrkBatchCTRL.cls
Description:     Controller Class for OrkBatchPage visualforce page
Test class:      

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
17-Feb-2021  0.2      Rajni         used custom label in Map monthcron and daycron
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class OrkBatchCTRL{

    public Boolean canRun                       {get; set;}
    public List<AsyncApexJob> jobList           {get; set;}
    public List<AsyncApexJob> activeList        {get; set;}
    public List<AsyncApexJob> completedList     {get; set;}
    public List<CronTrigger> scheduledList      {get; set;}

    public List<SelectOption> hourOptions       {get; set;}
    public List<SelectOption> dayOptions        {get; set;}
    public List<SelectOption> monthOptions      {get; set;}

    public String selectedHour                  {get; set;}
    public String selectedDay                   {get; set;}
    public String selectedMonth                 {get; set;}

    public static final Map<String,String> mapMonthCron = new Map<String,String>{
        'All' => '*',
        system.label.january => '1',
        system.label.february => '2',
        system.label.march => '3',
        system.label.april => '4',
        system.label.may => '5',
        system.label.june => '6',
        system.label.july => '7',
        system.label.august => '8',
        system.label.september => '9',
        system.label.october => '10',
        system.label.november => '11',
        system.label.december => '12'  
    };

    public static final Map<String,String> mapDayCron = new Map<String,String>{
        'All' => '*',
        system.label.Monday => '2',
        system.label.tuesday => '3',
        system.label.wednesday => '4',
        system.label.thursday => '5',
        system.label.friday => '6',
        system.label.saturday => '7',
        system.label.sunday => '1'
    };

    public OrkBatchCTRL(){
        jobList = new List<AsyncApexJob>();
        canRun = true;
        
        String jobQuery = 'SELECT Id,ApexClass.Name,Status,ExtendedStatus,CompletedDate,CreatedDate, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ApexClass.Name = \'OrkBatch\' ORDER BY CreatedDate DESC';
        jobList = Database.query(jobQuery);

        String scheduledQuery = 'SELECT Id,CronJobDetailId,CronJobDetail.Name,State,StartTime,PreviousFireTime,NextFireTime FROM CronTrigger WHERE CronJobDetail.Name LIKE \'OrkBatchSchedule%\'';
        scheduledList = Database.query(scheduledQuery);
        
        if(jobList != null && !jobList.isEmpty()){
            
            activeList = new List<AsyncApexJob>();
            completedList = new List<AsyncApexJob>();
        
            for(AsyncApexJob aaj : jobList){
                if(aaj.Status.equalsIgnoreCase('Completed') || aaj.Status.equalsIgnoreCase('Failed') || aaj.Status.equalsIgnoreCase('Aborted')){
                    completedList.add(aaj);
                }else if(aaj.Status.equalsIgnoreCase('Queued') || aaj.Status.equalsIgnoreCase('Processing') || aaj.Status.equalsIgnoreCase('Holding') || aaj.Status.equalsIgnoreCase('Preparing')){
                    activeList.add(aaj);
                }
            }
            
        }

        createSelectOptions();
    }

    public void createSelectOptions(){
        hourOptions = new List<SelectOption>();
        dayOptions = new List<SelectOption>();
        monthOptions = new List<SelectOption>();

        hourOptions.add(new SelectOption('','-- None --'));
        dayOptions.add(new SelectOption('','-- None --'));
        monthOptions.add(new SelectOption('','-- None --'));

        for(Integer i =0; i < 24; i++){
            hourOptions.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        }

        for(String s : mapMonthCron.keySet()){
            monthOptions.add(new SelectOption(s,s));
        }

        for(String s : mapDayCron.keySet()){
            dayOptions.add(new SelectOption(s,s));
        }

    }
    
    public PageReference runOrkBatch(){
        Database.executeBatch(new OrkBatch(),50);
        
        PageReference page = new PageReference('/apex/OrkBatchPage');
        page.setRedirect(true);
        return page;
    }
    
    public PageReference abortBatch(){
        String abortId = (ApexPages.currentPage().getParameters().get('idparam') != null && String.isNotBlank(ApexPages.currentPage().getParameters().get('idparam'))) ? ApexPages.currentPage().getParameters().get('idparam') : '';
        if(abortId != null && String.isNotBlank(abortId)){
            try{
                System.abortJob(abortId);
            }catch(Exception ex){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Unable to abort scheduled job. Use "Scheduled Job" section.'));
                return null;
            }
        }
        
        PageReference page = new PageReference('/apex/OrkBatchPage');
        page.setRedirect(true);
        return page;
    }
    
    public PageReference refresh(){
        PageReference page = new PageReference('/apex/OrkBatchPage');
        page.setRedirect(true);
        return page;
    }

    public PageReference reschedule(){

        if(selectedHour != null && selectedDay != null && selectedMonth != null &&
            String.isNotBlank(selectedHour) && String.isNotBlank(selectedDay) && String.isNotBlank(selectedMonth)){

			String cronExp = '0 0 ';
            cronExp += selectedHour+' ';
            cronExp += '? ';
            cronExp += mapMonthCron.get(selectedMonth)+' ';
            cronExp += mapDayCron.get(selectedDay)+' ';
			system.debug('cronExp ->' + cronExp);
            System.schedule('OrkBatchSchedule', cronExp, new OrkBatch());

        }

        PageReference page = new PageReference('/apex/OrkBatchPage');
        page.setRedirect(true);
        return page;   
    }

    public PageReference rescheduleEveryHour(){

        System.schedule('OrkBatchSchedule', '0 0 * * * ?', new OrkBatch());

        PageReference page = new PageReference('/apex/OrkBatchPage');
        page.setRedirect(true);
        return page;   
    }
}