/* ---------------------------------------------------------------------------------------------------------------------
Name:            ContactTrigger
Description:     Trigger for Contact

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
08-Jun-2021  0.2      Giulia Mameli                   Modified for including Skip Trigger check and disable Contact Trigger
----------------------------------------------------------------------------------------------------------------------*/

trigger ContactTrigger on Contact (after delete, after insert, after undelete, after update,
                                   before delete, before insert, before update) {
    //Check if Skip Trigger
    System.debug('skipTrigger --> '+skipTrigger.skip('Contact'));
    if (!skipTrigger.skip('Contact')) {
        if (!CredManUtility.IsTriggerEnabled())return;
        TriggerFactory.createHandler(Contact.SObjectType);
    }
}