/* ---------------------------------------------------------------------------------------------------------------------
Name:            GestioneStrategieCTRL.cls
Description:     Controller per visualizzare le strategie configurate in sistema.
Test class:      TestGestioneStrategieCTRL.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
5/2014       0.1      E.Sino               First Version
16-Jun-2016  0.2      E.Sino               Aggiunto il with sharing come richiesta da Salesforce.com per soddisfare le specifiche
                                           del Security Review.
                                           Modified line 19 to replace getRecordTypeInfosByName with getrecordtypeinfosbydevelopername.

16-Sep-2022  0.3      R.Kurti & C.Sanna    Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class GestioneStrategieCTRL {

    public list <Strategia__c> str { get; set; }
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public GestioneStrategieCTRL() {
        retriveList();
    }
    public void retriveList() {
        Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Strategia__c.getrecordtypeinfosbydevelopername();
        str = new list<Strategia__c>();
        if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Stato__c', gd).get('ACCESS')
                && Utils.cebCheckFLSPermission('Strategia__c', 'Descrizione__c', gd).get('ACCESS')) {
            str = [
                    select Nome__c, toLabel(Stato__c), Descrizione__c
                    from Strategia__c
                    where recordTypeId = :ctRecordTypes.get('Testata').getRecordTypeID()
                    //WITH SECURITY_ENFORCED
                    Order by Nome__c ASC
            ];
        }
    }
}