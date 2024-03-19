/*
* ClassName   : ContactHandler 
* Description :
*
*/
/* ---------------------------------------------------------------------------------------------------------------------
Name:            ContactHandler.cls
Description:     This class implements the ITrigger, and ensures that the
                 trigger is bulkified, and is all in one place.
Test class:      TestContactHandler.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
             0.2                                      Modified to fix English version - replace getRecordTypeInfosByName with getrecordtypeinfosbydevelopername, line no 34, 35
12-Sep-2022  0.3      C.Sanna & R. Kurti              Added cebCheck Obj/FLS security and WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class ContactHandler implements ITrigger {
    public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    public ContactHandler() {
    }
    public void bulkBefore() {
    }
    public void bulkBefore(List<SObject> soListNew) {
    }

    public void bulkAfter() {
    }
    public void bulkAfter(List<SObject> soListNew) {
    }
    public void beforeInsert(List<Contact> con) {
    }
    public void beforeUpdate(List<Contact> oldcon, List<Contact> con) {
    }
    public void beforeDelete(List<Contact> con) {
    }
    public void afterInsert(List<Contact> con) {
        Set<Id> AccId = new Set<Id>();
        for (Contact c : con) {
            AccId.add(c.AccountId);
        }
        UpdateIndirizziSuAccount(AccId);
    }
    public void afterUpdate(List<Contact> oldcon, List<Contact> con) {
        Set<Id> AccId = new Set<Id>();
        for (Contact c : con) {
            AccId.add(c.AccountId);
        }
        UpdateIndirizziSuAccount(AccId);
    }
    public void afterDelete(List<Contact> con) {
    }
    public void andFinally() {
    }

    public void UpdateIndirizziSuAccount(Set<Id> AccId) {
        if (!CredManUtility.IsTriggerEnabled())
            return;
        Map<Id, List<Contact>> MapContactsPerAccId = new Map<Id, List<Contact>>();
        Map<Id, Contact> MapContactsToUpdate = new Map<Id, Contact>();
        Id DomicilioRTId = Schema.SObjectType.Contact.getrecordtypeinfosbydevelopername().get('DOMICILIO').getRecordTypeId();
        Id ResidenzaRTId = Schema.SObjectType.Contact.getrecordtypeinfosbydevelopername().get('RESIDENZA').getRecordTypeId();
        List<Account> UpdateAccount = new List<Account>();
        List<Contact> UpdateContact_Domicilio = new List<Contact>();
        List<Contact> UpdateContact_Residenza = new List<Contact>();
        list<Account> ListAccount = new list<Account>();

        if (Utils.cebCheckObjPermission('Contact',gd).get('ACCESS')
                && Utils.checkFLSPermission('Contact', 'Principale__c').get('ACCESS')
                && Utils.checkFLSPermission('Contact', 'Comune__c').get('ACCESS')
                && Utils.checkFLSPermission('Contact', 'Indirizzo__c').get('ACCESS')
                && Utils.checkFLSPermission('Contact', 'Cap__c').get('ACCESS')
                && Utils.checkFLSPermission('Contact', 'Provincia__c').get('ACCESS')
                && Utils.checkFLSPermission('Contact', 'Toponimo__c').get('ACCESS')
                && Utils.checkFLSPermission('Contact', 'Civico__c').get('ACCESS')) {
            for (Contact cont : [
                    Select Id, Name, AccountId, RecordTypeId, Principale__c, Comune__c, Indirizzo__c, Cap__c, Provincia__c, Toponimo__c, Civico__c
                    from Contact
                    where AccountId IN :AccId
                    //WITH SECURITY_ENFORCED

            ]) {
                if (MapContactsPerAccId.get(cont.AccountId) == null)
                    MapContactsPerAccId.put(cont.AccountId, new List<Contact>());
                MapContactsPerAccId.get(cont.AccountId).add(cont);
                MapContactsToUpdate.put(cont.Id, cont);
            }
        }
        boolean PresenzaDomicilio;
        boolean PresenzaResidenza;
        map<Id, Contact> MapIndirDomicilioPerId = new map<Id, Contact>();
        map<Id, Contact> MapIndirResidenzaPerId = new map<Id, Contact>();
        if (Utils.cebCheckObjPermission('Account', gd).get('ACCESS') && Utils.cebCheckFLSPermission('Account', 'Indirizzo_Principale__c', gd).get('ACCESS')) {
            listAccount = [
                    Select Id, Name, BillingCity, BillingStreet, BillingPostalCode, BillingState, Indirizzo_Principale__c
                    from Account
                    WHERE Id = :MapContactsPerAccId.keyset()
                    //WITH SECURITY_ENFORCED
            ];
            for (Account Acc : listAccount) {
                PresenzaDomicilio = false;
                PresenzaResidenza = false;
                for (Contact c : MapContactsPerAccId.get(Acc.Id)) {
                    Contact Indirizzo = MapContactsToUpdate.get(c.Id);
                    if (Indirizzo.RecordTypeId == DomicilioRTId) {
                        PresenzaDomicilio = true;
                        MapIndirDomicilioPerId.put(c.Id, c);
                        system.debug('********MapIndirDomicilioPerId = ' + MapIndirDomicilioPerId);

                    } else if (MapContactsToUpdate.get(c.Id).RecordTypeId == ResidenzaRTId) {
                        PresenzaResidenza = true;
                        MapIndirResidenzaPerId.put(c.Id, c);

                    }
                    if (PresenzaResidenza && PresenzaDomicilio) {
                        Contact IndirizzoShipping = MapIndirResidenzaPerId.get(c.Id);
                        Contact IndirizzoBilling = MapIndirDomicilioPerId.get(c.Id);
                        system.debug('*****IndirizzoShipping= ' + IndirizzoShipping);
                        system.debug('*****IndirizzoBilling= ' + IndirizzoBilling);
                        if (IndirizzoShipping != null) {
                            IndirizzoShipping.Principale__c = false;
                            String ShippingCity = IndirizzoShipping.Comune__c;
                            String ShippingStreet = IndirizzoShipping.Indirizzo__c;
                            String ShippingState = IndirizzoShipping.Provincia__c;
                            String ShippingPostalCode = IndirizzoShipping.Cap__c;
                            String ToponimoShip = IndirizzoShipping.Toponimo__c;
                            String CivicoShip = IndirizzoShipping.Civico__c;
                            Acc.ShippingCity = ShippingCity;
                            Acc.ShippingStreet = (ToponimoShip == null ? '' : ToponimoShip) + ' ' + ShippingStreet + (CivicoShip == null ? '' : ', ' + CivicoShip);
                            Acc.ShippingPostalCode = ShippingPostalCode;
                            Acc.ShippingState = ShippingState;
                            UpdateContact_Residenza.add(IndirizzoShipping);
                        }
                        if (IndirizzoBilling != null) {
                            IndirizzoBilling.Principale__c = true;
                            String BillingCity = IndirizzoBilling.Comune__c;
                            String BillingStreet = IndirizzoBilling.Indirizzo__c;
                            String BillingState = IndirizzoBilling.Provincia__c;
                            String BillingPostalCode = IndirizzoBilling.Cap__c;
                            String Toponimo = IndirizzoBilling.Toponimo__c;
                            String Civico = IndirizzoBilling.Civico__c;
                            Acc.BillingCity = BillingCity;
                            Acc.BillingStreet = (Toponimo == null ? '' : Toponimo) + ' ' + BillingStreet + (Civico == null ? '' : ', ' + Civico);
                            Acc.BillingPostalCode = BillingPostalCode;
                            Acc.BillingState = BillingState;
                            UpdateContact_Domicilio.add(IndirizzoBilling);
                        }


                    } else if (PresenzaResidenza && !PresenzaDomicilio) {

                        Contact IndirizzoShipping = MapIndirResidenzaPerId.get(c.Id);
                        if (IndirizzoShipping != null) {
                            IndirizzoShipping.Principale__c = true;
                            String ShippingCity = IndirizzoShipping.Comune__c;
                            String ShippingStreet = IndirizzoShipping.Indirizzo__c;
                            String ShippingState = IndirizzoShipping.Provincia__c;
                            String ShippingPostalCode = IndirizzoShipping.Cap__c;
                            String ToponimoShip = IndirizzoShipping.Toponimo__c;
                            String CivicoShip = IndirizzoShipping.Civico__c;
                            Acc.ShippingCity = ShippingCity;
                            Acc.ShippingStreet = (ToponimoShip == null ? '' : ToponimoShip) + ' ' + ShippingStreet + (CivicoShip == null ? '' : ', ' + CivicoShip);
                            //Acc.ShippingStreet = ToponimoShip + ' ' + ShippingStreet + ', ' + CivicoShip;
                            Acc.ShippingPostalCode = ShippingPostalCode;
                            Acc.ShippingState = ShippingState;


                            Acc.BillingCity = ShippingCity;
                            Acc.BillingStreet = (ToponimoShip == null ? '' : ToponimoShip) + ' ' + ShippingStreet + (CivicoShip == null ? '' : ', ' + CivicoShip);
                            //Acc.BillingStreet = ToponimoShip + ' ' + ShippingStreet + ', ' + CivicoShip;
                            Acc.BillingPostalCode = ShippingPostalCode;
                            Acc.BillingState = ShippingState;
                            UpdateContact_Residenza.add(IndirizzoShipping);
                        }

                    } else if (!PresenzaResidenza && PresenzaDomicilio) {
                        Contact IndirizzoBilling = MapIndirDomicilioPerId.get(c.Id);
                        if (IndirizzoBilling != null) {
                            IndirizzoBilling.Principale__c = true;
                            String BillingCity = IndirizzoBilling.Comune__c;
                            String BillingStreet = IndirizzoBilling.Indirizzo__c;
                            String BillingState = IndirizzoBilling.Provincia__c;
                            String BillingPostalCode = IndirizzoBilling.Cap__c;
                            String Toponimo = IndirizzoBilling.Toponimo__c;
                            String Civico = IndirizzoBilling.Civico__c;
                            Acc.BillingCity = BillingCity;
                            Acc.BillingStreet = (Toponimo == null ? '' : Toponimo) + ' ' + BillingStreet + (Civico == null ? '' : ', ' + Civico);
                            //Acc.BillingStreet = Toponimo + ' ' + BillingStreet + ', ' + Civico;
                            Acc.BillingPostalCode = BillingPostalCode;
                            Acc.BillingState = BillingState;
                            UpdateContact_Domicilio.add(IndirizzoBilling);
                        }

                    }

                }
                UpdateAccount.add(Acc);
            }
        }
        CredManUtility.DisableTrigger();
        if (UpdateContact_Domicilio.size() > 0) {
            if (Utils.cebCheckObjPermission('Contact', gd).get('UPDATE') && Utils.cebCheckFLSPermission('Contact', 'Principale__c', gd).get('UPDATE')) {
                update UpdateContact_Domicilio;
            }
        }
        if (UpdateContact_Residenza.size() > 0) {
            if (Utils.cebCheckObjPermission('Contact', gd).get('UPDATE') && Utils.cebCheckFLSPermission('Contact', 'Principale__c', gd).get('UPDATE')) {
                update UpdateContact_Residenza;
            }
        }
        if (UpdateAccount.size() > 0) {
            if (Utils.cebCheckObjPermission('Account', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Account', 'ShippingCity', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Account', 'ShippingStreet', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Account', 'ShippingPostalCode', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Account', 'ShippingState', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Account', 'BillingCity', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Account', 'BillingStreet', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Account', 'BillingState', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Account', 'BillingPostalCode', gd).get('UPDATE')) {
                update UpdateAccount;
            }
        }
    }

}