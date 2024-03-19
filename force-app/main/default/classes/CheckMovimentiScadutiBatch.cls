global with sharing class CheckMovimentiScadutiBatch implements Database.Batchable<sObject>, Database.AllowsCallouts
        /*** 20210520 MSala - Review Code - Start ***/
        //, Database.Stateful
        /*** 20210520 MSala - Review Code - End ***/

{
    public class movimentiScadutiBatchException extends Exception{}
    String query;
    List<grace_period__mdt> delay = new List<grace_period__mdt>();
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    global CheckMovimentiScadutiBatch(){}

    /*** - 20210223 - MSala - Review Ageing ***/
    /*global Database.QueryLocator start(Database.BatchableContext BC)
    {
        delay = [SELECT CRABB_DEV__Days__c FROM CRABB_DEV__grace_period__mdt where DeveloperName='Delay'];
        Date dGracePeriod = Date.today().addDays(-Integer.valueOf(delay.get(0).Days__c));
        query='select Tipo_Scadenza__c from Movimento__c ';
        query += 'where Tipo_Scadenza__c=\'In Scadenza\' and Data_Scadenza__c <:dGracePeriod and Residuo__c !=0';
        try
        {
            if (Utils.checkFLSPermission('Movimento__c', 'Tipo_Scadenza__c').get('ACCESS')
                    && Utils.checkFLSPermission('Movimento__c', 'Data_Scadenza__c').get('ACCESS')
                    && Utils.checkFLSPermission('Movimento__c', 'Residuo__c').get('ACCESS'))
            {
                return Database.getqueryLocator(query);
            }
            else return null;
        }
        catch(Exception e)
        {
            errorClass.LogError('CheckMovimentiScadutiBatch.QueryLocator',e.getMessage()+ '\n'+e.getlinenumber()+'\n'+e.getStackTraceString());
            throw new movimentiScadutiBatchException('Exception-'+e.getMessage()+ '\n'+e.getlinenumber()+'\n'+e.getStackTraceString());
        }
    }
    */

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        query='select Tipo_Scadenza__c,Ageing__c,Data_Pagamento__c,Data_Scadenza__c,Residuo__c,Stato_Pratica__c,Check_Scadenza__c from Movimento__c ';
        //query += 'where Tipo_Scadenza__c IN (\'In Scadenza\',\'Scaduto\') and Check_Scadenza__c = true';
        query += 'where Check_Scadenza__c = true ';
        query += 'AND RecordType.Name IN (\'ADDEBITO\',\'FATTURE\',\'NOTE DI DEBITO\',\'SCONTRINO\')';
        //query += 'where Tipo_Scadenza__c=\'In Scadenza\' and Data_Scadenza__c <:dGracePeriod and Residuo__c !=0';
        try
        {
            /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
            /*if (Utils.checkFLSPermission('Movimento__c', 'Tipo_Scadenza__c').get('ACCESS')
                    && Utils.checkFLSPermission('Movimento__c', 'Data_Scadenza__c').get('ACCESS')
                    && Utils.checkFLSPermission('Movimento__c', 'Residuo__c').get('ACCESS')
                    && Utils.checkFLSPermission('Movimento__c', 'Ageing__c').get('ACCESS')
                    && Utils.checkFLSPermission('Movimento__c', 'Data_Pagamento__c').get('ACCESS')
                    && Utils.checkFLSPermission('Movimento__c', 'Stato_Pratica__c').get('ACCESS')
                    && Utils.checkFLSPermission('Movimento__c', 'Check_Scadenza__c').get('ACCESS')
                    //&& !CEBUtils.newOrkVersionEnabled()
                    )
            {*/
            /*** 20210513 MSiotto - Code Review - End Rimosso per nuova gestione CEB ***/

            if (Utils.cebCheckFLSPermission('Movimento__c', 'Tipo_Scadenza__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Scadenza__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Residuo__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Ageing__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Pagamento__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Stato_Pratica__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Movimento__c', 'Check_Scadenza__c', gd).get('ACCESS')
                    /*&& !CEBUtils.newOrkVersionEnabled()*/)
            {
                return Database.getqueryLocator(query);
            }
            else return null;
        }
        catch(Exception e)
        {
            errorClass.LogError('CheckMovimentiScadutiBatch.QueryLocator',e.getMessage()+ '\n'+e.getlinenumber()+'\n'+e.getStackTraceString());
            throw new movimentiScadutiBatchException('Exception-'+e.getMessage()+ '\n'+e.getlinenumber()+'\n'+e.getStackTraceString());
        }
    }


    /*** - 20210223 - MSala - Review Ageing ***/
    /*global void execute(Database.BatchableContext BC, List<Movimento__c> scope)
    {
        for(Movimento__c mov : scope)
        {
            mov.Tipo_Scadenza__c='Scaduto';
        }

        if (Utils.checkFLSPermission('Movimento__c', 'Tipo_Scadenza__c').get('ACCESS')
                && Utils.checkObjPermission('Movimento__c').get('UPDATE'))
        {
            update scope;
        }
    }
    */

    global void execute(Database.BatchableContext BC, List<Movimento__c> scope)
    {
        delay = [SELECT CRABB_DEV__Days__c FROM CRABB_DEV__grace_period__mdt where DeveloperName = 'Delay'];
        Date dGracePeriod = Date.today().addDays(-Integer.valueOf(delay.get(0).Days__c));
        for(Movimento__c mov : scope)
        {
            /*** 20210306 - MSALA - Logiche OLD - START ***/
            /*if(mov.Stato_Pratica__c == 'Chiusa')
                mov.Check_Scadenza__c = false;
            if( mov.Tipo_Scadenza__c=='In Scadenza'
                && mov.Data_Scadenza__c < dGracePeriod
                && mov.Residuo__c > 0)
            {
                mov.Tipo_Scadenza__c='Scaduto';
                mov.Ageing__c = (Date.valueOf(mov.Data_Scadenza__c)).daysBetween(system.today());
            }
            else if(mov.Tipo_Scadenza__c == 'In Scadenza'
                    && mov.Residuo__c == 0)
            {
                mov.Tipo_Scadenza__c='Pagato';
                if(mov.Data_Pagamento__c == null)
                {
                    mov.Data_Pagamento__c = Date.today();
                    mov.Ageing__c = (Date.valueOf(mov.Data_Scadenza__c)).daysBetween(system.today());
                }
                else
                {
                    mov.Ageing__c = (Date.ValueOf(mov.Data_Scadenza__c).daysBetween(Date.valueOf(mov.Data_Pagamento__c)));
                }
            }
            else if(mov.Tipo_Scadenza__c == 'Scaduto'
                    && mov.Residuo__c > 0)
            {
                mov.Ageing__c = (Date.valueOf(mov.Data_Scadenza__c)).daysBetween(system.today());
                if(mov.Data_Scadenza__c >= dGracePeriod)
                    mov.Tipo_Scadenza__c='In Scadenza';
            }
            else if (mov.Tipo_Scadenza__c=='Scaduto'
                    && mov.Residuo__c == 0)
            {
                mov.Tipo_Scadenza__c='Pagato';
                if(mov.Data_Pagamento__c == null)
                {
                    mov.Data_Pagamento__c = Date.today();
                    mov.Ageing__c = (Date.valueOf(mov.Data_Scadenza__c)).daysBetween(system.today());
                }
                else
                {
                    mov.Ageing__c = (Date.ValueOf(mov.Data_Scadenza__c).daysBetween(Date.valueOf(mov.Data_Pagamento__c)));
                }
            }
            else if (mov.Tipo_Scadenza__c == 'Pagato'
                    && mov.Residuo__c > 0)
            {
                if(mov.Data_Scadenza__c < dGracePeriod)
                    mov.Tipo_Scadenza__c='Scaduto';
                else
                    mov.Tipo_Scadenza__c='In Scadenza';
            }
            else if(mov.Residuo__c < 0)
            {
                mov.Tipo_Scadenza__c = 'Credito';
                if(mov.Data_Pagamento__c == null)
                {
                    mov.Data_Pagamento__c = Date.today();
                    mov.Ageing__c = (Date.valueOf(mov.Data_Scadenza__c)).daysBetween(system.today());
                }
                else
                {
                    mov.Ageing__c = (Date.ValueOf(mov.Data_Scadenza__c).daysBetween(Date.valueOf(mov.Data_Pagamento__c)));
                }
            }
            else if(mov.Tipo_Scadenza__c == 'Credito')
            {
                if (mov.Residuo__c == 0)
                {
                    mov.Tipo_Scadenza__c='Pagato';
                    if(mov.Data_Pagamento__c == null)
                    {
                        mov.Data_Pagamento__c = Date.today();
                        mov.Ageing__c = (Date.valueOf(mov.Data_Scadenza__c)).daysBetween(system.today());
                    }
                    else
                    {
                        mov.Ageing__c = (Date.ValueOf(mov.Data_Scadenza__c).daysBetween(Date.valueOf(mov.Data_Pagamento__c)));
                    }
                }
                else if(mov.Residuo__c > 0)
                {
                    if(mov.Data_Scadenza__c < dGracePeriod)
                    {
                        mov.Tipo_Scadenza__c='Scaduto';
                        mov.Ageing__c = (Date.valueOf(mov.Data_Scadenza__c)).daysBetween(system.today());
                    }
                    else
                        mov.Tipo_Scadenza__c='In Scadenza';
                }
            }*/
            /*** 20210306 - MSALA - Logiche OLD - END ***/
            /*** 20210306 - MSALA - Review logiche con riaperture - START ***/
            if(mov.Stato_Pratica__c == 'Chiusa')
                mov.Check_Scadenza__c = false;
            if(mov.Tipo_Scadenza__c=='In Scadenza')
            {
                if(mov.Residuo__c > 0
                    && mov.Data_Scadenza__c < dGracePeriod)
                {
                    mov.Tipo_Scadenza__c='Scaduto';
                    mov.Ageing__c = (Date.valueOf(mov.Data_Scadenza__c)).daysBetween(system.today());
                }
                else if(mov.Residuo__c == 0)
                {
                    mov.Tipo_Scadenza__c='Pagato';
                    if(mov.Data_Pagamento__c == null)
                    {
                        mov.Data_Pagamento__c = Date.today();
                        mov.Ageing__c = (Date.valueOf(mov.Data_Scadenza__c)).daysBetween(system.today());
                    }
                    else
                    {
                        mov.Ageing__c = (Date.ValueOf(mov.Data_Scadenza__c).daysBetween(Date.valueOf(mov.Data_Pagamento__c)));
                    }
                }
                else if(mov.Residuo__c < 0)
                {
                    mov.Tipo_Scadenza__c = 'Credito';
                    if(mov.Data_Pagamento__c == null)
                    {
                        mov.Data_Pagamento__c = Date.today();
                        mov.Ageing__c = (Date.valueOf(mov.Data_Scadenza__c)).daysBetween(system.today());
                    }
                    else
                    {
                        mov.Ageing__c = (Date.ValueOf(mov.Data_Scadenza__c).daysBetween(Date.valueOf(mov.Data_Pagamento__c)));
                    }
                }
            }
            else if(mov.Tipo_Scadenza__c == 'Scaduto')
            {
                if(mov.Residuo__c > 0)
                {
                    if(mov.Data_Scadenza__c >= dGracePeriod)
                        mov.Tipo_Scadenza__c='In Scadenza';
                    mov.Ageing__c = (Date.valueOf(mov.Data_Scadenza__c)).daysBetween(system.today());
                }
                else if(mov.Residuo__c == 0)
                {
                    mov.Tipo_Scadenza__c='Pagato';
                    if(mov.Data_Pagamento__c == null)
                    {
                        mov.Data_Pagamento__c = Date.today();
                        mov.Ageing__c = (Date.valueOf(mov.Data_Scadenza__c)).daysBetween(system.today());
                    }
                    else
                    {
                        mov.Ageing__c = (Date.ValueOf(mov.Data_Scadenza__c).daysBetween(Date.valueOf(mov.Data_Pagamento__c)));
                    }
                }
                else if(mov.Residuo__c < 0)
                {
                    mov.Tipo_Scadenza__c = 'Credito';
                    if(mov.Data_Pagamento__c == null)
                    {
                        mov.Data_Pagamento__c = Date.today();
                        mov.Ageing__c = (Date.valueOf(mov.Data_Scadenza__c)).daysBetween(system.today());
                    }
                    else
                    {
                        mov.Ageing__c = (Date.ValueOf(mov.Data_Scadenza__c).daysBetween(Date.valueOf(mov.Data_Pagamento__c)));
                    }
                }
            }
            else if (mov.Tipo_Scadenza__c == 'Pagato')
            {
                if(mov.Residuo__c > 0)
                {
                    mov.Data_Pagamento__c = null;
                    mov.Ageing__c = (Date.valueOf(mov.Data_Scadenza__c)).daysBetween(system.today());
                    if(mov.Data_Scadenza__c < dGracePeriod)
                        mov.Tipo_Scadenza__c='Scaduto';
                    else
                        mov.Tipo_Scadenza__c='In Scadenza';
                }
                else if(mov.Residuo__c < 0)
                {
                    mov.Tipo_Scadenza__c = 'Credito';
                    if(mov.Data_Pagamento__c == null)
                    {
                        mov.Data_Pagamento__c = Date.today();
                        mov.Ageing__c = (Date.valueOf(mov.Data_Scadenza__c)).daysBetween(system.today());
                    }
                    else
                    {
                        mov.Ageing__c = (Date.ValueOf(mov.Data_Scadenza__c).daysBetween(Date.valueOf(mov.Data_Pagamento__c)));
                    }
                }
            }
            else if(mov.Tipo_Scadenza__c == 'Credito')
            {
                if (mov.Residuo__c == 0)
                {
                    mov.Tipo_Scadenza__c='Pagato';
                    if(mov.Data_Pagamento__c == null)
                    {
                        mov.Data_Pagamento__c = Date.today();
                        mov.Ageing__c = (Date.valueOf(mov.Data_Scadenza__c)).daysBetween(system.today());
                    }
                    else
                    {
                        mov.Ageing__c = (Date.ValueOf(mov.Data_Scadenza__c).daysBetween(Date.valueOf(mov.Data_Pagamento__c)));
                    }
                }
                else if(mov.Residuo__c > 0)
                {
                    mov.Data_Pagamento__c = null;
                    mov.Ageing__c = (Date.valueOf(mov.Data_Scadenza__c)).daysBetween(system.today());
                    if(mov.Data_Scadenza__c < dGracePeriod)
                        mov.Tipo_Scadenza__c='Scaduto';
                    else
                        mov.Tipo_Scadenza__c='In Scadenza';
                }
            }
            /*** 20210306 - MSALA - Review logiche con riaperture - END ***/
        }
        /*** 20210513 MSiotto - Code Review - Start Rimosso per nuova gestione CEB ***/
        /*if (Utils.checkFLSPermission('Movimento__c', 'Tipo_Scadenza__c').get('ACCESS')
                && Utils.checkFLSPermission('Movimento__c', 'Data_Scadenza__c').get('ACCESS')
                && Utils.checkFLSPermission('Movimento__c', 'Residuo__c').get('ACCESS')
                && Utils.checkFLSPermission('Movimento__c', 'Ageing__c').get('ACCESS')
                && Utils.checkFLSPermission('Movimento__c', 'Data_Pagamento__c').get('ACCESS')
                && Utils.checkFLSPermission('Movimento__c', 'Check_Scadenza__c').get('ACCESS')
                && Utils.checkObjPermission('Movimento__c').get('UPDATE'))
        { */
        /*** 20210513 MSiotto - Code Review - End Rimosso per nuova gestione CEB ***/

        if (Utils.cebCheckFLSPermission('Movimento__c', 'Tipo_Scadenza__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Scadenza__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Residuo__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Ageing__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Data_Pagamento__c',gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Check_Scadenza__c',gd).get('ACCESS')
                && Utils.cebCheckObjPermission('Movimento__c',gd).get('UPDATE'))
        {
            update scope;
        }
    }

    global void finish(Database.BatchableContext BC){}
}