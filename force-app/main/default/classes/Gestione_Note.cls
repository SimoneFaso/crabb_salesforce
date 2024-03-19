/*----------------------------------------------------------------------------------------------------------
Name:            Gestione_Note.cls
Description:
Test class:      TestGestione_Note.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
27-Aug-2021  0.2      Claudio Sanna                   Modified and added cebCheckObjPermission and cebCheckFLSPermission
                                                      (Security Review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class Gestione_Note
{
    Static Integer Max =  Max_Note__c.getValues('Max').Max_Note__c.intValue();
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    public static List<Nota__c> qNote(Boolean b,Id IdPratica)
    {
        String queryN = 'Select ';
        queryN = queryN + 'Id,'; 
        queryN = queryN + 'LastModifiedDate,';
        queryN = queryN + 'RecordType.Name,';
        queryN = queryN + 'Nota__c,';
        queryN = queryN + 'CreatedDate,';
        queryN = queryN + 'CreatedBy.Name,';
        for(integer x = 2; x <= Max; x++)
        {
            queryN = queryN + 'Nota_' + x + '__c,';
            queryN = queryN + 'User_' + x + '__c,';
            queryN = queryN + 'Visibilit_' + x + '__c,';
            queryN = queryN + 'Data_Inserimento_' + x + '__c,';
        }
        //queryN = queryN + 'Nota_3__c,User_3__c,Visibilit_3__c,Data_Inserimento_3__c,';
        queryN = queryN + 'Current_Note__c,';
        queryN = queryN + 'Max_Note__c ';
        queryN = queryN + 'From Nota__c ';
        queryN = queryN + 'where Pratica__c = :IdPratica ';
        queryN = queryN + 'order by CreatedDate Desc ';
        if(b)
            queryN = queryN + 'Limit 1';
        /*
        if (Utils.checkFLSPermission('Nota__c', 'Nota__c').get('ACCESS')
            && Utils.checkFLSPermission('Nota__c', 'RecordTypeId').get('ACCESS')
            && Utils.checkFLSPermission('Nota__c', 'Pratica__c').get('ACCESS')
            && Utils.checkFLSPermission('Nota__c', 'Max_Note__c').get('ACCESS')
            && Utils.checkFLSPermission('Nota__c', 'Current_Note__c').get('ACCESS'))
         */
        if(Utils.cebcheckObjPermission('Nota__c', gd).get('ACCESS')
            && Utils.cebcheckFLSPermission('Nota__c', 'Nota__c', gd).get('ACCESS')
            && Utils.cebcheckFLSPermission('Nota__c', 'RecordTypeId', gd).get('ACCESS')
            && Utils.cebcheckFLSPermission('Nota__c', 'Pratica__c', gd).get('ACCESS')
            && Utils.cebcheckFLSPermission('Nota__c', 'Max_Note__c', gd).get('ACCESS')
            && Utils.cebcheckFLSPermission('Nota__c', 'Current_Note__c', gd).get('ACCESS'))
        {
            List<Nota__c> notes = Database.query(queryN);
            return notes;
        }

        else return null;
    }
    
    public static List<Nota> queryNote(Id IdPratica)
    {
        List<Nota> lNote = new List<Nota>();
        List<Nota__c> notes = qNote(false,IdPratica);
        
        for(Nota__c cmn : notes)
        {
            integer cur = cmn.Current_Note__c.intValue();
            for(integer i = cur; i > 0; i--)
            {
                Nota n = new Nota();
                if(i==1)
                {
                    n.Nota = cmn.Nota__c;
                    n.User = cmn.CreatedBy.Name;
                    n.Data = cmn.CreatedDate;
                    n.Visibility = cmn.RecordType.Name;
                }
                else
                {
                    Object o = cmn.get('Nota_' + i + '__c');
                    n.Nota = String.valueOf(o);
                    o = cmn.get('User_' + i + '__c');
                    n.User = String.valueOf(o);
                    o = cmn.get('Data_Inserimento_' + i + '__c');
                    n.Data = Date.valueOf(o);
                    o = cmn.get('Visibilit_' + i + '__c');
                    n.Visibility = String.valueOf(o);
                }
                lNote.add(n);
            }
        }
        system.debug('Note da visualizzare: ' + lNote);
        return lNote;
    }
    
    public static String insertNote(Id IdPratica, String Nota, String User, Id Visibility, DateTime Data)
    {
        String esito = '';
        system.debug(IdPratica + '-' + Nota + '-' + User + '-' + Visibility + '-' + Data);
        Nota__c n;
        List<Nota__c> notes = qNote(true,IdPratica);
        if(notes.size() > 0)
        {
            if(notes[0].Current_Note__c >= notes[0].Max_Note__c)
            {
                /*Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Nota__c; 
                Map<String,Schema.RecordTypeInfo> NotaRTInfo = cfrSchema.getRecordTypeInfosByName(); 
                Id rtId = NotaRTInfo.get(Visibility).getRecordTypeId();*/
                n = new Nota__c();
                n.Nota__c = Nota;
                n.RecordTypeId = Visibility;
                n.Pratica__c = IdPratica;
                n.Max_Note__c = Max;
                system.debug('CREO NOTA');
            }
            else
            {
                integer cur = notes[0].Current_Note__c.IntValue() + 1;
                n = notes[0];
                n.Current_Note__c = cur;
                n.put('Nota_' + cur  + '__c',Nota);
                n.put('User_' + cur  + '__c',User);
                n.put('Visibilit_' + cur  + '__c',Visibility);
                n.put('Data_Inserimento_' + cur  + '__c',Date.valueOf(Data));
                system.debug('AGGIORNO NOTA SUL RECORD ' + n.Id);
            }
        }
        else
        {
            n = new Nota__c();
            n.Nota__c = Nota;
            n.RecordTypeId = Visibility;
            n.Pratica__c = IdPratica;
            n.Max_Note__c = Max;
            system.debug('CREO NOTA');        
        }
        if (Utils.cebCheckObjPermission('Nota__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Nota__c', 'Nota__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Nota__c', 'RecordTypeId', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Nota__c', 'Pratica__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Nota__c', 'Max_Note__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Nota__c', 'Current_Note__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Nota__c', 'User__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Nota__c', 'Visibilit__c', gd).get('UPSERT')
                && Utils.cebCheckFLSPermission('Nota__c', 'Data_Inserimento__c', gd).get('UPSERT')) {
            upsert n;
        }
        /*
        if (Utils.checkFLSPermission('Nota__c', 'Nota__c').get('CREATE')
            && Utils.checkFLSPermission('Nota__c', 'RecordTypeId').get('CREATE')
            && Utils.checkFLSPermission('Nota__c', 'Pratica__c').get('CREATE')
            && Utils.checkFLSPermission('Nota__c', 'Max_Note__c').get('CREATE')
            && Utils.checkFLSPermission('Nota__c', 'Current_Note__c').get('CREATE')
            ) upsert n;
         */
        
        return esito;
    }

}