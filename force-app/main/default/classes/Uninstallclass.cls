/* ---------------------------------------------------------------------------------------------------------------------
Name:            Uninstallclass.cls
Description:
Test class:      TestUninstallclass.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
             0.1                           First Version
16-Sep-2022  0.2      C.Sanna & R.Kurti    Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/
global with sharing class Uninstallclass implements UninstallHandler {
  global void onUninstall(UninstallContext ctx) {
    User u = [Select Id, Email from User where Id =:ctx.uninstallerID() WITH SECURITY_ENFORCED];
    String toAddress= u.Email;
    String[] toAddresses = new String[] {toAddress};
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(toAddresses);
    mail.setReplyTo('build@balanceconsulting.it');
    mail.setSenderDisplayName('CRABB Support');
    mail.setSubject('Package uninstall successful');
    mail.setPlainTextBody('Thanks for uninstalling the package.');
    try {
        Messaging.sendEmail(new Messaging.Email[] { mail });
        } catch (Exception e) {
            System.debug('Error on sending email uninstall:'+e.getMessage());
        }
    
  }
}