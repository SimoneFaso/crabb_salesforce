/* ---------------------------------------------------------------------------------------------------------------------
Name:            ImportStrategie.cls
Description:     Controller Class for import strategy visualforce page
Test class:      TestImportStrategie.cls

Date         Version  Author               Summary of Changes
-----------  -------  -------------------  -----------------------------------------------------------------------------
17-Feb-2021  0.2      Rajni                 replace getRecordTypeInfosByName with getrecordtypeinfosbydevelopername -44, 129
11-Jun-2021  0.2      M.Siotto              Reviewed for using ceb methods
28-Sep-2021  0.3      M.Pizzichini          Fixing FLS adding braces to if
13-Sep-2022  0.4      R.Kurti & C.Sanna     Added cebCheckObjPermissions (security review)
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class ImportStrategie {
    Public Map<String, SObjectType> gd = Schema.getGlobalDescribe();
    public string nameFile { get; set; }
    public Blob contentFile { get; set; }
    String[] filelines = new String[]{
    };
    List<Strategia__c> StratToUpload;
    public Map<String, Id> recordTypeName2Id;
    public Strategia__c testata;
    public Integer numAccTest { get; set; }
    public Set<String> CheckFLSCampi;

    private String TogliACapo(String s) {
        s = s.replace('\r\n', '');
        s = s.replace('\n', '');
        s = s.replace('\r', '');
        return s;
    }

    public ImportStrategie() {
        recordTypeName2Id = new Map<String, Id>();
        testata = new Strategia__c();
        numAccTest = 10;
        CheckFLSCampi = new Set<String>();
    }


    public Pagereference ReadFile() {
        nameFile = contentFile.toString();
        filelines = nameFile.split('\n');
        //accstoupload = new List<Account>();
        StratToUpload = new List<Strategia__c>();
        List<Strategia__c> StratToUploadUnOrder = new List<Strategia__c>();
        Map<string, Schema.RecordTypeInfo> RTStrategiaNameID = Schema.SObjectType.Strategia__c.getrecordtypeinfosbydevelopername();
        for (String tmp : RTStrategiaNameID.keySet()) {
            system.debug('Record Type name' + tmp);
            Id currRtId = RTStrategiaNameID.get(tmp).getRecordTypeId();
            recordTypeName2Id.put(tmp.toUpperCase(), currRtId);
        }
        //throw new Utils.BalanceException('BBBB:'+recordTypeName2Id);
        List<String> headers = new List<String>();
        for (Integer i = 0; i < filelines.size(); i++) {
            filelines[i] = TogliACapo(filelines[i]);
            headers = filelines[i].replace('"', '').split(',');
            break;
        }
        Map<String, Integer> headers2Num = new Map<String, Integer>();
        Integer colcounter = 0;
        for (String tmp : headers) {
            System.debug('REPLACE:' + tmp.replace(Utils.NAMESPACE, '').toUpperCase());
            String f = tmp.replace(Utils.NAMESPACE, '').toUpperCase();
            headers2Num.put(f, colcounter);
            System.debug('REPLACE:' + headers2Num);
            colcounter++;
        }
        String[] rows = new String[]{
        };
        // GENERATE TESTATA
        for (Integer i = 1; i < filelines.size(); i++) {
            //rows = filelines[i].replace('"','').split(',');
            filelines[i] = filelines[i].removeEnd('\r\n');
            filelines[i] = filelines[i].removeEnd('\n');
            filelines[i] = filelines[i].removeEnd('\r');
            rows = filelines[i].split('","');
            for (Integer x = 0; x < rows.size(); x++) {
                system.debug('###Prima: ' + rows[x]);
                rows[x] = rows[x].replace('"', '');
                system.debug('###Dopo: ' + rows[x]);
                system.debug('###Dopo: ' + rows.size() + ' - ' + headers2Num.get('RECORD_TYPE__C'));
            }
            //if (!rows[headers2Num.get('RECORD_TYPE__C')].toUpperCase().equals('STEP')) throw new Utils.BalanceException('OOOO:'+rows[headers2Num.get('RECORD_TYPE__C')].toUpperCase());
            if (rows[headers2Num.get('RECORD_TYPE__C')].toUpperCase().equals('TESTATA')) {
                Id rTypeId = (Id) recordTypeName2Id.get(rows[headers2Num.get('RECORD_TYPE__C')].toUpperCase());
                system.debug('Record Type Id-' + rtypeId);
                testata = populateStrategia(testata, rows, headers2Num);
                testata.Stato__c = system.label.draft;
                testata.RecordTypeId = rTypeId;
                //throw new Utils.BalanceException('OOOOO:'+rTypeId);
                break;
            }
        }
        Boolean CheckFLSOK = false;
        for (String campo : CheckFLSCampi) {
            CheckFLSOK = Utils.cebCheckFLSPermission('Strategia__c', campo, gd).get('INSERT');
            if (!CheckFLSOK)
                break;
        }
        system.debug('CheckFLSOK-->' + CheckFLSOK);
        system.debug('RecordTypeID-->' + testata.RecordTypeId);

        if (testata.RecordTypeId != null
                && CheckFLSOK)
            insert testata;
        else
                throw new Utils.BalanceException('Testata record is missing!');
        //throw new Utils.BalanceException('UUUU:'+rows);
        StratToUpload.add(testata);
        //GENERATE CHILDS
        rows.clear();
        List<Strategia__c> childs = new List<Strategia__c>();
        Map<String, Strategia__c> relationsParent = new Map<String, Strategia__c>();
        Map<String, Strategia__c> relationsChild = new Map<String, Strategia__c>();
        Map<String, Strategia__c> relationsJump = new Map<String, Strategia__c>();
        for (Integer i = 1; i < filelines.size(); i++) {
            //rows = filelines[i].replace('"','').split(',');
            rows = filelines[i].split('","');
            for (Integer x = 0; x < rows.size(); x++) {
                rows[x] = rows[x].replace('"', '');
            }
            if (rows[headers2Num.get('RECORD_TYPE__C')].toUpperCase().equals('TESTATA')) {
                relationsChild.put(rows[headers2Num.get('ID_WITH18_CHAR__C')], testata);
                relationsJump.put(rows[headers2Num.get('NOME__C')], testata);
                continue; //skip the testata record
            }
            //Id rTypeId = (Id)recordTypeName2Id.get(rows[headers2Num.get('RECORD_TYPE__C')].toUpperCase().replace('_',' '));
            Id rTypeId = (Id) recordTypeName2Id.get(rows[headers2Num.get('RECORD_TYPE__C')].toUpperCase());
            Strategia__c s = new Strategia__c();
            s.Stato__c = system.label.draft;
            s.Testata__c = testata.Id;
            s = populateStrategia(s, rows, headers2Num);
            s.RecordTypeId = rTypeId;
            childs.add(s);
            //throw new Utils.BalanceException('OOOOO:'+childs);
            relationsChild.put(rows[headers2Num.get('ID_WITH18_CHAR__C')], s);
            relationsParent.put(rows[headers2Num.get('ATTIVIT_PADRE__C')], s);
            relationsJump.put(rows[headers2Num.get('NOME__C')], s);
        }
        rows.clear();
        CheckFLSOK = false;
        for (String campo : CheckFLSCampi) {
            CheckFLSOK = Utils.cebCheckFLSPermission('Strategia__c', campo, gd).get('INSERT');
            if (!CheckFLSOK)
                break;
        }
        if (childs.size() > 0
                && CheckFLSOK) {
            insert childs;
        } else {
            throw new Utils.BalanceException('No Childs records!');
        }
        List<Strategia__c> strategie2link = new List<Strategia__c>();

        for (Integer i = 1; i < filelines.size(); i++) {
            //rows = filelines[i].replace('"','').split(',');
            rows = filelines[i].split('","');
            for (Integer x = 0; x < rows.size(); x++) {
                rows[x] = rows[x].replace('"', '');
            }
            //System.debug('###' + rows);
            if (rows[headers2Num.get('RECORD_TYPE__C')].toUpperCase().equals('TESTATA')) continue;
            //System.debug('###' + rows[headers2Num.get('ATTIVIT_PADRE__C')]);
            Strategia__c sfiglio = relationsChild.get(rows[headers2Num.get('ID_WITH18_CHAR__C')]);
            Strategia__c spadre;
            if (rows[headers2Num.get('ATTIVIT_PADRE__C')] != '') {
                //system.debug('###' + rows[headers2Num.get('ATTIVIT_PADRE__C')]);
                spadre = relationsChild.get(rows[headers2Num.get('ATTIVIT_PADRE__C')]);
                sfiglio.Attivit_Padre__c = spadre.Id;

            } else if (rows[headers2Num.get('RECORD_TYPE__C')].equalsIgnoreCase(System.Label.Jump)) {

                sfiglio.Jump_From__c = (relationsJump.get(sfiglio.SupportJumpFromName__c) != null) ? relationsJump.get(sfiglio.SupportJumpFromName__c).Id : null;
                sfiglio.Jump_To__c = (relationsJump.get(sfiglio.SupportJumpToName__c) != null) ? relationsJump.get(sfiglio.SupportJumpToName__c).Id : null;
                if (sfiglio.Id == sfiglio.Jump_From__c) {
                    throw new Utils.BalanceException('Circular FROM:' + sfiglio + ' riga:' + filelines[i]);
                }
                if (sfiglio.Id == sfiglio.Jump_To__c) {
                    throw new Utils.BalanceException('Circular TO:' + sfiglio + ' riga:' + filelines[i]);
                }
            }
            strategie2link.add(sfiglio);
        }
        CheckFLSOK = false;
        for (String campo : CheckFLSCampi) {
            CheckFLSOK = Utils.cebCheckFLSPermission('Strategia__c', campo, gd).get('UPDATE');
            if (!CheckFLSOK) {
                break;
            }
        }
        //if (strategie2link.size() >0 && CheckFLSOK) update strategie2link;
        if (strategie2link.size() > 0 && CheckFLSOK && Utils.cebCheckObjPermission('Strategia__c', gd).get('UPDATE')) {
            update strategie2link;
        }

        StratToUpload.addAll(strategie2link);
        return null;
    }

    private String sanitizeField(String s) {
        String field = '';
        for (Integer i = 0; i < s.length(); i++) {
            if (s.charAt(i) <= 255)
                field += String.fromCharArray(new List<integer>{
                        s.charAt(i)
                });
        }
        return field;
    }

    private Strategia__c populateStrategia(Strategia__c s, String[] rows, Map<String, Integer> headers2Num) {
        SObjectType objToken = gd.get(Utils.NAMESPACE + 'Strategia__c');
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap();
        //System.debug('ffff'+fields);
        //throw new Utils.BalanceException('ffff'+fields);
        for (String tmp : headers2Num.keySet()) {
            String field = tmp;
            //throw new Utils.BalanceException('ffff'+field+'gggg');
            //System.debug('FIELD0:'+ field + '####' + tmp + '####');
            field = sanitizeField(field);
            if (field.toLowerCase().endsWith('__c')) {
                field = Utils.NAMESPACE + field;
            }
            System.debug('Field:' + field);
            if (field.equalsIgnoreCase(Utils.NAMESPACE + 'FORMULAJUMPFROMNAME__C')) {

                if (String.isNotBlank(rows[headers2Num.get(tmp)])) {
                    s.put(Utils.NAMESPACE + 'SupportJumpFromName__c', rows[headers2Num.get(tmp)]);
                }

            } else if (field.equalsIgnoreCase(Utils.NAMESPACE + 'FORMULAJUMPTONAME__C')) {

                if (String.isNotBlank(rows[headers2Num.get(tmp)])) {
                    s.put(Utils.NAMESPACE + 'SupportJumpToName__c', rows[headers2Num.get(tmp)]);
                }

            } else if (field.equalsIgnoreCase(Utils.NAMESPACE + 'JUMP_FROM__C') || field.equalsIgnoreCase(Utils.NAMESPACE + 'JUMP_TO__C')) {

                continue;

            } else if (
                    fields.get(field).getDescribe().isCreateable()
                            //&& fields.get(field).getDescribe().isUpdateable()
                            && field != Utils.NAMESPACE + 'ATTIVIT_PADRE__C'
                            && field != Utils.NAMESPACE + 'TESTATA__C')
            /*if(Utils.checkFLSPermission('Strategia__c', field).get('INSERT')
                && Utils.checkFLSPermission('Strategia__c', field).get('UPDATE')
                && field != Utils.NAMESPACE+'ATTIVIT_PADRE__C'
                && field != Utils.NAMESPACE+'TESTATA__C')*/ {
                CheckFLSCampi.add(field);
                //system.debug('###:' + rows[headers2Num.get(tmp)] + '### ' + field);
                Schema.DisplayType fielddataType = fields.get(field).getDescribe().getType();
                if (String.isNotBlank(rows[headers2Num.get(tmp)])) {
                    if (fielddataType == Schema.DisplayType.TextArea
                            || fielddataType == Schema.DisplayType.String
                            || fielddataType == Schema.DisplayType.picklist
                            || fielddataType == Schema.DisplayType.MultiPicklist
                            || fielddataType == Schema.DisplayType.ID
                            || fielddataType == Schema.DisplayType.Reference) {
                        s.put(field, rows[headers2Num.get(tmp)]);
                    } else if (fielddataType == Schema.DisplayType.Integer) {
                        s.put(field, Integer.ValueOf(rows[headers2Num.get(tmp)]));
                    } else if (fielddataType == Schema.DisplayType.Double
                            || fielddataType == Schema.DisplayType.Currency) {
                        s.put(field, decimal.ValueOf(rows[headers2Num.get(tmp)]));
                    } else if (fielddataType == Schema.DisplayType.Date) {
                        s.put(field, Date.ValueOf(rows[headers2Num.get(tmp)]));
                    } else if (fielddataType == Schema.DisplayType.DateTime) {
                        s.put(field, DateTime.ValueOf(rows[headers2Num.get(tmp)]));
                    } else if (fielddataType == Schema.DisplayType.Boolean) {
                        s.put(field, Boolean.ValueOf(rows[headers2Num.get(tmp)]));
                    }
                }
            } else if (field == Utils.NAMESPACE + 'RECORD_TYPE__C') {
                s.RecordTypeId = (Id) recordTypeName2Id.get(rows[headers2Num.get('RECORD_TYPE__C')].toUpperCase());
            }

            system.debug('#### s.' + field + ' : ' + s.get(field));
        }
        return s;
    }


    public List<Strategia__c> getuploadedStrategie() {
        if (StratToUpload != NULL)
            if (StratToUpload.size() > 0)
                return StratToUpload;
            else
                    return null;
        else
                return null;
    }
    public void generateTestData() {
        List<Account> accBulk1 = TestClassForDatagenerationCreateData.getTestAccounts(numAccTest);
        if (Utils.cebCheckObjPermission('Account', gd).get('CREATE') && Utils.cebCheckFLSPermission('Account', 'Mail1__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Account', 'Mail_Sollecito__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Account', 'E_Mail_Sollecito_migrazione__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Account', 'E_Mail_Account_migrazione__c', gd).get('CREATE')) {
            insert accBulk1;
        }
        //insert accBulk1;

        Contratto__c ct = TestClassForDatagenerationCreateData.getTestContract();
        if (Utils.cebCheckObjPermission('Contratto__c', gd).get('CREATE') && Utils.cebCheckFLSPermission('Contratto__c', 'titolo__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Contratto__c', 'Id_Esterno__c', gd).get('CREATE')) {
            //insert ct;
            insert ct;
        }

        List<Servizio__c> services = new List<Servizio__c>();
        for (Account tmp : accBulk1) {
            Servizio__c serv = TestClassForDatagenerationCreateData.getTestService();
            serv.LookupContratto__c = ct.Id;
            serv.Account__c = tmp.Id;
            serv.Id_Esterno__c = tmp.Id;
            services.add(serv);
        }
        if (Utils.cebCheckObjPermission('Servizio__c', gd).get('CREATE') && Utils.cebCheckFLSPermission('Servizio__c', 'LookupContratto__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Servizio__c', 'Account__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Servizio__c', 'Id_Esterno__c', gd).get('CREATE'))
        //insert services;
        {
            insert services;
        }

        List<Pratica__c> lPrat = new List<Pratica__c>();
        for (Servizio__c s : services) {
            Pratica__c p = TestClassForDatagenerationCreateData.getTestPratica();
            p.Account__c = s.Account__c;
            p.Servizio_Fornitura__c = s.Id;
            //p.CRABB_DEV__Residuo_Totale__c = 0;
            p.Stato__c = 'BOZZA';
            lPrat.add(p);
        }
        if (Utils.cebCheckObjPermission('Pratica__c', gd).get('CREATE') && Utils.cebCheckFLSPermission('Pratica__c', 'Servizio_Fornitura__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Account__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Pratica__c', 'Stato__c', gd).get('CREATE')){
        //insert lPrat;

            insert lPrat;
        }

        List<Movimento__c> lMov = new List<Movimento__c>();
        String codLotto = Utils.generateRandomString(5);
        integer i = 0;
        String movPrefix = Utils.generateRandomString(5);
        for (Pratica__c p : lPrat) {
            i++;
            Movimento__c m = TestClassForDatagenerationCreateData.getTestMovimento();
            m.Account__c = p.Account__c;
            m.Servizio_Fornitura__c = p.Servizio_Fornitura__c;
            m.Pratica__c = p.Id;
            m.Residuo__c = i * 10;
            m.Sollecitabile__c = true;
            m.Tipo_Scadenza__c = 'Scaduto';
            m.Id_Movimento_Ext__c = 'TEST-' + movPrefix + codLotto + String.ValueOf(i);
            m.Importo__c = i * 10;
            lMov.add(m);
        }
        if (Utils.cebCheckObjPermission('Movimento__c', gd).get('CREATE') && Utils.cebCheckFLSPermission('Movimento__c', 'Servizio_Fornitura__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Account__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Pratica__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Residuo__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Sollecitabile__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Tipo_Scadenza__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Id_Movimento_Ext__c', gd).get('CREATE')
                && Utils.cebCheckFLSPermission('Movimento__c', 'Importo__c', gd).get('CREATE')){
        //insert lMov;

            insert lMov;
        }

        /*system.schedule('BalanceTest0', '0 0 * * * ?', new CRABB_DEV.BatchScheduler());
        system.schedule('BalanceTest1', '0 15 * * * ?', new CRABB_DEV.BatchScheduler());
        system.schedule('BalanceTest2', '0 30 * * * ?', new CRABB_DEV.BatchScheduler());
        system.schedule('BalanceTest3', '0 45 * * * ?', new CRABB_DEV.BatchScheduler());*/
    }

    public void runBatch() {
        OrkBatch FCMB = new OrkBatch();
        Database.executeBatch(FCMB, 1);
    }
}