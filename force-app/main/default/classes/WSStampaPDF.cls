/* -----------------------------------------------------------------------------------------------------------------
Name:            WSStampaPDF.cls
Description:
Test class:


             0.1                              First Version
08-oct-2021  0.2    Matteo Pizzichini         Fixing FLS adding brace to if and ceb methods
16-Sep-2022  0.3    R.Kurti & C.Sanna         Added with SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------- */
global with sharing class WSStampaPDF {
    webservice String a;
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    webservice static String BatchStrategiaMensile(string a) {
        try {
            Task t = [select id, whatid, status From Task Where id = :a WITH SECURITY_ENFORCED];

            OrkActivities.CreteLettersForAttachment(a);
            t.status = 'Lavorata';
            if (Utils.cebCheckObjPermission('Task', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Task', 'Status', gd).get('UPDATE')) {
                update t;
            }
            return 'OK';
        } catch (Exception e) {
            errorClass.LogError('WSStampaPDF', 'KO');
            return 'KO' + utils.getExceptionInString(e);
        }
    }

}