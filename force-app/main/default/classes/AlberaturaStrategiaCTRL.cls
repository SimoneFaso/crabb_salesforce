/* ---------------------------------------------------------------------------------------------------------------------
Name:            AlberaturaStrategiaCTRL.cls
Description:     Controller per supportare la pagina che schematizza la struttura della strategia, simile ad un albero.
Test class:      TestAlberaturaStrategiaCTRL.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
16-Jun-2016  0.2      E.Sino                          Aggiunto il with sharing come richiesta da Salesforce.com per soddisfare le specifiche
                                                      del Security Review.
14-Sep-2022  0.3      R. Kurti & C. Sanna             Modified for adding check permission:
                                                      cebCheckFLSPermission/cebCheckObjPermission/WITH SECURITY_ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class AlberaturaStrategiaCTRL {
    Public static Map<String, SObjectType> gd = Schema.getGlobalDescribe();

    public String getDRows() {

        String StratId = ApexPages.currentPage().getParameters().get('STRId');
        String NomePratica = 'Strategia di riferimento';
        String sJSon;
        if (StratId != null) {
            if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                    && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('ACCESS')) {
                // Aggiungo la parte per gestire il chart sulla strategia
                //NomePratica = [SELECT Nome__c FROM Strategia__c where Id = :StratId WITH SECURITY_ENFORCED LIMIT 1].Nome__c;
                NomePratica = [SELECT Nome__c FROM Strategia__c where Id = :StratId LIMIT 1].Nome__c;

                if (Utils.cebCheckObjPermission('Strategia__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Nome__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Attivit_Padre__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'SLA__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Tipo_attivita__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Sotto_tipo_attivita__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Tipo_Attivit__c', gd).get('ACCESS')
                        && Utils.cebCheckFLSPermission('Strategia__c', 'Sotto_Tipo_Attivit__c', gd).get('ACCESS')) {
                    List<Strategia__c> lStr = [
                            SELECT
                                    Name,
                                    Attivit_Padre__c,
                                    Nome__c,
                                    SLA__c,
                                    Tipo_attivita__c,
                                    Sotto_tipo_attivita__c,
                                    Tipo_Attivit__c,
                                    Sotto_Tipo_Attivit__c,
                                    Tipologia__c,
                                    Jump_to__r.Nome__c,
                                    Jump_from__c,
                                    RecordType.Name,
                                    isFinal__c,
                                    isAutomaticJump__c
                            FROM
                                    Strategia__c
                            where
                                    (RecordType.Name = 'Step' OR RecordType.Name = 'Salto')
                                    AND
                                    Testata__c = :StratId
                            //WITH SECURITY_ENFORCED
                    ];

                    String s = '[';
                    Integer i = 0;

                    for (Strategia__c str : lStr) {
                        String parent = '';
                        String SottoTipo = '';
                        String SLA = 'NA';
                        if (str.SLA__c != null)
                            SLA = String.ValueOf(str.SLA__c);

                        if (
                                str.RecordType.Name == 'Step'
                                        &&
                                        (
                                                str.Attivit_Padre__c == null ||
                                                        String.ValueOf(str.Attivit_Padre__c) == '' ||
                                                        String.ValueOf(str.Attivit_Padre__c) == StratId
                                        )
                        )
                            parent = NomePratica; //StratId; //'***';
                        else if (str.RecordType.Name == 'Step')
                            parent = str.Attivit_Padre__c;
                        else
                                parent = str.Jump_from__c;

                        if (str.Sotto_tipo_attivita__c != null)
                            SottoTipo = str.Sotto_tipo_attivita__c;

                        if (str.RecordType.Name == 'Step') {
                            if (str.Tipologia__c == 'Process') {
                                s = s +
                                        '[{v:\'' + str.Id + '\', f:\'<div style="background: #64a59e; color: white;">' + str.Nome__c + ' <BR/> ' + str.Tipo_attivita__c + ' ' + SottoTipo
                                        + '<div>' + 'SLA: ' + SLA + '</div>' + '</div>\'},';
                                //+'\''+parent+'\',\''+str.Name+''+'\']';
                            } else if (str.Tipologia__c == 'UI') {
                                s = s +
                                        '[{v:\'' + str.Id + '\', f:\'<div style="background: #3DB0D7; color: white;">' + str.Nome__c + ' <BR/> ' + str.Tipo_attivita__c + ' ' + SottoTipo
                                        + '<div>' + 'SLA: ' + SLA + '</div>' + '</div>\'},';
                                //+'\''+parent+'\',\''+str.Name+''+'\']';
                            } else if (str.Tipologia__c == 'Expectance') {
                                s = s +
                                        '[{v:\'' + str.Id + '\', f:\'<div style="background: #fb927d; color: white;">' + str.Nome__c + ' <BR/> ' + str.Tipo_attivita__c + ' ' + SottoTipo
                                        + '<div>' + 'SLA: ' + SLA + '</div>' + '</div>\'},';
                                //+'\''+parent+'\',\''+str.Name+''+'\']';
                            } else {
                                s = s +
                                        '[{v:\'' + str.Id + '\', f:\'' + str.Nome__c + ' <BR/> ' + str.Tipo_attivita__c + ' ' + SottoTipo
                                        + '<div>' + 'SLA: ' + SLA + '</div>' + '\'},';
                                //+'\''+parent+'\',\''+str.Name+''+'\']';
                            }

                            if (str.isFinal__c)
                                s = s + '\'' + parent + '\',\'' + str.Name + ' - Step FINALE ' + '\']';
                            else
                                    s = s + '\'' + parent + '\',\'' + str.Name + '' + '\']';
                        } else if (str.RecordType.Name == 'Salto') {
                            if (str.isAutomaticJump__c) {
                                s = s +
                                        '[{v:\'' + str.Id + '\', f:\'<div style="background: #f1c40f; color: green;">' + str.Nome__c + ' <BR/>' + system.label.Jump_to + ':<BR/> ' + str.Jump_to__r.Nome__c + '</div>\'},'
                                        + '\'' + parent + '\',\'' + str.Name + '' + '\']';
                            } else {
                                s = s +
                                        '[{v:\'' + str.Id + '\', f:\'<div style="background: #e67e22; color: green;">' + str.Nome__c + ' <BR/>' + system.label.Jump_to + ':<BR/> ' + str.Jump_to__r.Nome__c + '</div>\'},'
                                        + '\'' + parent + '\',\'' + str.Name + '' + '\']';
                            }
                        }


                        if (i < lStr.size() - 1)
                            s = s + ',';

                        System.debug('La stringa parent è ' + parent);
                        i++;
                    }

                    s = s + ']';
                    sJSon = s;
                    System.debug('La stringa DROWs è ' + sJSon);
                }
            }
        }
        return sJSon;
    }

}