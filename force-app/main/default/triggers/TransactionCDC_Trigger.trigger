trigger TransactionCDC_Trigger on Movimento__ChangeEvent (after insert)
{ 
    /*** Aggiungere: Gestione Scadenza con DUE DATE & Residuo <0, >0 e =0 ***/
    List<ListOfFields__c> lLOF = [SELECT Field__c 
                                  FROM ListOfFields__c 
                                  WHERE Object__c = 'Movimento__c' 
                                  AND Show__c = true
                                  AND Name like 'Pdf%' WITH SECURITY_ENFORCED];
    List<CEB__c> lCEB = new List<CEB__c>();
    List<Id> recordIds = new List<Id>();
    for (Movimento__ChangeEvent event : Trigger.New)
    {
        recordIds.addAll(event.ChangeEventHeader.getRecordIds());
        System.debug('RecordIds: ' + recordIds);
        System.debug('RecordIds size: ' + recordIds.size());
    }
    Boolean bECFields = false;
    Integer i = 0;

    List<Movimento__c> lMov = [SELECT Pratica__c FROM Movimento__c Where Id IN :recordIds WITH SECURITY_ENFORCED];
    Set<Id> sPrat = new Set<Id>();
    for(Movimento__c m : lMov)
    {
        sPrat.add(m.Pratica__c);
    }
    List<CEB__c> lExistingCEBs = [SELECT Pratica__c,Type__c, Movimento__c FROM CEB__c
                                    Where Movimento__c IN :recordIds
                                    and Type__c IN ('CEX','UEC')
                                    AND Status__c = 'New'
                                    WITH SECURITY_ENFORCED];
    List<CEB__c> lExistingCEXs = [SELECT Pratica__c,Type__c, Movimento__c FROM CEB__c
                                    Where Movimento__c IN :recordIds
                                    and Type__c = 'CEX'
                                    AND Status__c = 'New'
                                    WITH SECURITY_ENFORCED];
    List<CEB__c> lExistingUECs = [SELECT Pratica__c,Type__c, Movimento__c FROM CEB__c
                                    Where Pratica__c IN :sPrat
                                    and Type__c = 'UEC'
                                    AND Status__c = 'New'
                                    WITH SECURITY_ENFORCED];
    System.debug('lExistingCEBs: ' + lExistingCEBs);
    Map<String,CEB__c> mExCEBs = new Map<String,CEB__c>();
    Map<String,CEB__c> mExCEXs = new Map<String,CEB__c>();
    Map<String,CEB__c> mExUECs = new Map<String,CEB__c>();
    for(CEB__c c : lExistingCEBs)
    {
        String mKey = '';
        if(c.Type__c == 'UEC')
            mKey = c.Type__c + '_' + c.Pratica__c;
        else if(c.Type__c == 'CEX')
            mKey = c.Type__c + '_' + c.Movimento__c;
        mExCEBs.put(mKey,c);
    }
    for(CEB__c c : lExistingCEXs)
    {
        String mKey = 'CEX_' + c.Movimento__c;
        mExCEXs.put(mKey,c);
    }
    for(CEB__c c : lExistingUECs)
    {
        String mKey = 'UEC_' + c.Pratica__c;
        mExUECs.put(mKey,c);
    }
    System.debug('mExCEXs: ' + mExCEXs.keySet());
    System.debug('mExUECs: ' + mExUECs.keySet());

    List<grace_period__mdt> delay = [SELECT CRABB_DEV__Days__c FROM CRABB_DEV__grace_period__mdt where DeveloperName = 'Delay'];
    for (Movimento__ChangeEvent event : Trigger.New)
    {
        EventBus.ChangeEventHeader header = event.ChangeEventHeader;
        System.debug('Received change event for ' + header.entityName +
                     ' for the ' + header.changeType + ' operation.');
        List<Id> internalRecordIds = new List<Id>();
        internalRecordIds.addAll(event.ChangeEventHeader.getRecordIds());
                
        if (header.changetype == 'CREATE') 
        {
            Date dGracePeriod;
            Boolean bExpiration = false;

            if(event.get('CRABB_DEV__Data_Scadenza__c') != null)
            {
                String d = String.valueOf(event.get('CRABB_DEV__Data_Scadenza__c'));
                System.debug('D: ' + d);
                //dGracePeriod = date.parse(String.valueOf(event.get('CRABB_DEV__Data_Scadenza__c')));
                dGracePeriod = Date.valueOf(d).addDays(Integer.valueOf(delay.get(0).Days__c));
                System.debug('Date: ' + dGracePeriod);
                //dGracePeriod = dGracePeriod.addDays(-Integer.valueOf(delay.get(0).Days__c));
                System.debug('Changed field value: ' + 'CRABB_DEV__Data_Scadenza__c' + '. New Value: ' + event.get('CRABB_DEV__Data_Scadenza__c'));
                bExpiration = true;
            }

            for(Movimento__c m : lMov)
            {
                if(!mExUECs.containsKey('UEC_'+m.Pratica__c) && internalRecordIds.contains(m.id))
                {
                    CEB__c cebUEC = new CEB__c();
                    cebUEC.Type__c = 'UEC';
                    cebUEC.Pratica__c = m.Pratica__c;
                    cebUEC.Immediate_Action__c = true;
                    cebUEC.Movimento__c = m.Id;
                    cebUEC.Log__c = 'CREATE: ' + i;
                    i++;
                    lCEB.add(cebUEC);
                }

                if(bExpiration && !mExCEXs.containsKey('CEX_'+m.Id) && internalRecordIds.contains(m.id))
                {
                    CEB__c cebCEX = new CEB__c();
                    cebCEX.Type__c = 'CEX';
                    cebCEX.Pratica__c = m.Pratica__c;
                    cebCEX.Immediate_Action__c = false;
                    cebCEX.Movimento__c = m.Id;
                    cebCEX.Wait_Due_Date__c = dGracePeriod;
                    cebCEX.Log__c = 'CREATE: ' + i;
                    i++;
                    lCEB.add(cebCEX);
                }
            }
        }        
        else if ((header.changetype == 'UPDATE')) 
        {
            Boolean bExpiryCheck = false;
            // For update operations, iterate over the list of changed fields
            System.debug('Iterate over the list of changed fields.'); 
            for (String field : header.changedFields) 
            {
                for(ListOfFields__c lof: lLOF)
                {
                    System.debug(lof.Field__c + ' --- ' + field);
                    if(field.contains(lof.Field__c)
                      || field.contains('Sollecitabile__c')
                      || field.contains('Tipo_Scadenza__c'))
                        bECFields = true;

                    if(field.contains('Residuo__c'))
                    {
                        /*String d = String.valueOf(event.get('Residuo__c'));
                        Decimal res = Decimal.valueOf(d);
                        if(res == 0 || res < 0)*/
                            bExpiryCheck = true;
                    }
                }
            }

            for(Movimento__c m : lMov)
            {
                if(!(mExUECs.containsKey('UEC_'+m.Pratica__c)) && bECFields && internalRecordIds.contains(m.id))
                {
                    CEB__c cebUEC = new CEB__c();
                    cebUEC.Type__c = 'UEC';
                    cebUEC.Pratica__c = m.Pratica__c;
                    cebUEC.Immediate_Action__c = true;
                    cebUEC.Movimento__c = m.Id;
                    cebUEC.Log__c = 'UPDATE: ' + i;
                    i++;
                    lCEB.add(cebUEC);
                }

                if(bExpiryCheck && !mExCEXs.containsKey('CEX_'+m.Id) && internalRecordIds.contains(m.id))
                {
                    CEB__c cebCEX = new CEB__c();
                    cebCEX.Type__c = 'CEX';
                    cebCEX.Pratica__c = m.Pratica__c;
                    cebCEX.Immediate_Action__c = true;
                    cebCEX.Movimento__c = m.Id;
                    cebCEX.Log__c = 'UPDATE: ' + i;
                    i++;
                    lCEB.add(cebCEX);
                }
            }
        }
    }

    if (Utils.checkFLSPermission('CEB__c', 'Type__c').get('ACCESS')
            && Utils.checkFLSPermission('CEB__c', 'Pratica__c').get('ACCESS')
            && Utils.checkFLSPermission('CEB__c', 'Immediate_Action__c').get('ACCESS')
            && Utils.checkFLSPermission('CEB__c', 'Movimento__c').get('ACCESS')
            && Utils.checkFLSPermission('CEB__c', 'Wait_Due_Date__c').get('ACCESS')
            && lCEB.size()>0) {
        insert lCEB;
    }
}