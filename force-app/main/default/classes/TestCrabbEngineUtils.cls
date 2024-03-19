@IsTest 
public class TestCrabbEngineUtils {
    @TestSetup
    public static void generateStrategy(){
        generateStrategyRecords();
    }

    @IsTest
    public static void cebsTest() {
        List<CRABB_DEV__Pratica__c> praList = generateData();
        List<String> cebEvents = new List<String>{'WAI','CEX', 'UEC', 'NCA', 'DSU','PDF'};
        Map<String, String> cebEventsMap = new Map<String, String>();
        cebEventsMap.put('WAI','Expectance End');
        cebEventsMap.put('CEX','Check Expiration Type');
        cebEventsMap.put('UEC','Refresh EC');
        cebEventsMap.put('NCA','Create CASE');
        cebEventsMap.put('DSU','Transaction Dossier Status Update');
        cebEventsMap.put('PDF','Create PDF');


        Test.startTest();
            for(String ceb : cebEvents) {
                System.debug('cebEngineUtils Call --> ' + ceb + ' - ' + cebEventsMap.get(ceb));
                if(ceb!='PDF') {
                    CEBUtils.addCebEvents(true, praList, ceb);
                    new CrabbEngineUtils().defineStrategy(cebEventsMap.get(ceb),praList);
                } else {
                    changeTypeSubtype('Proposta di Attività', 'Lettera ordinaria', praList);
                    CEBUtils.addCebEvents(true, praList, ceb);
                    new CrabbEngineUtils().defineStrategy(cebEventsMap.get(ceb),praList);
                }
            }

            changeTypeSubtype('Invio e-mail', 'Primo Sollecito', praList);
            new CrabbEngineUtils().defineStrategy('Send Email',praList);
        Test.stopTest();
    }

    @IsTest
    public static void cebSchTest() {
        List<CRABB_DEV__Pratica__c> praList = generateData();

        Test.startTest();
            CEBUtils.addCebEvents(true, praList, 'SCH');
            new CrabbEngineUtils().defineStrategy('Check Next Step',praList);
            new CrabbEngineUtils().defineStrategy('Check Jump',praList);
            new CrabbEngineUtils().defineStrategy('Check Strategy Exit Criteria',praList);
            new CrabbEngineUtils().defineStrategy('Refresh Scoring',praList);
        Test.stopTest();
    }

    public static List<CRABB_DEV__Pratica__c> generateData() {
        //cebEventsMap.put('PDF','Create PDF');

        Account acc = new Account(name = 'accTest');
        insert acc;

        List<CRABB_DEV__Pratica__c> praList = new List<CRABB_DEV__Pratica__c>();
        CRABB_DEV__Pratica__c pra = new CRABB_DEV__Pratica__c();
        pra.CRABB_DEV__Account__c = acc.id;
        praList.add(pra);
        insert praList;

        CRABB_DEV__Movimento__c mov = new CRABB_DEV__Movimento__c();
        mov.CRABB_DEV__Pratica__c = pra.id;
        mov.CRABB_DEV__Residuo__c = 1000;
        mov.CRABB_DEV__Importo__c= 1000;
        mov.CRABB_DEV__Data_Emissione__c = system.today().addDays(-30);
        mov.CRABB_DEV__Data_Scadenza__c = system.today().addDays(-20);
        mov.CRABB_DEV__Account__c = acc.id;
        mov.CRABB_DEV__Sollecitabile__c = true;
        mov.CRABB_DEV__Tipo_Scadenza__c = 'Scaduto';
        insert mov;

        Task t = [SELECT id, CRABB_DEV__ActivityExtended__c from Task where WhatId=:pra.id];

        CRABB_DEV__ActivityExtended__c ae = [SELECT id, CRABB_DEV__Tipo_Sottotipo__c, CRABB_DEV__Expiration_date__c from CRABB_DEV__ActivityExtended__c where id = :t.CRABB_DEV__ActivityExtended__c];
        ae.CRABB_DEV__Expiration_date__c = System.today().addDays(-7);

        update ae;

        return praList;
    }

    public static void changeTypeSubtype(String tipo, String sottotipo, List<CRABB_DEV__Pratica__c> pralist) {

        Task t = [SELECT id, CRABB_DEV__ActivityExtended__c from Task where WhatId in :praList limit 1];

        CRABB_DEV__ActivityExtended__c ae = [SELECT id, CRABB_DEV__Tipo__c, CRABB_DEV__Sotto_Tipo__c, CRABB_DEV__Expiration_date__c from CRABB_DEV__ActivityExtended__c where id = :t.CRABB_DEV__ActivityExtended__c];
        ae.CRABB_DEV__Expiration_date__c = System.today().addDays(-7);
        ae.CRABB_DEV__Tipo__c = tipo;
        ae.CRABB_DEV__Sotto_Tipo__c = sottotipo;
        ae.CRABB_DEV__code_status__c = 'Non iniziata';

        update ae;

    }

    private static void generateStrategyRecords(){
        Map<string, Schema.RecordTypeInfo> RTStrategiaNameID =Schema.SObjectType.Strategia__c.getrecordtypeinfosbydevelopername();
        List<Strategia__c> strategyList = new List<Strategia__c>();

        Strategia__c testata = new Strategia__c();
        testata.nome__c='Strategy test';
        testata.priority__c=1;
        testata.stato__c='Attiva';
        testata.Versione__c=1;
        testata.recordtypeId=RTStrategiaNameID.get('Testata').getRecordTypeID();
        testata.Tipo_Strategia__c='Standard';
        testata.Activation_roles__c='R2015-03-04 11:35:16,R2021-03-03 14:52:18,R7,R2014-07-11 10:29:40';
        //strategyList.add(testata);
        insert testata;


        Strategia__c condIngresso = new Strategia__c();
        condIngresso.CRABB_DEV__Testata__c=testata.id;
        condIngresso.nome__c='Ingresso strategia test';
        condIngresso.priority__c=1;
        condIngresso.stato__c='Attiva';
        condIngresso.recordtypeId=RTStrategiaNameID.get('Condizioni_di_Ingresso').getRecordTypeID();
        condIngresso.RC_Rule_Name__c='R2021-03-03 14:52:18';
        strategyList.add(condIngresso);

        //Step Stand-By
        Strategia__c stepSB = new Strategia__c();
        stepSB.CRABB_DEV__Testata__c=testata.id;
        stepSB.CRABB_DEV__Attivit_Padre__c=testata.id;
        stepSB.CRABB_DEV__Tipo_attivita__c='Attività di Attesa';
        stepSB.nome__c='1 - Stand by';
        stepSB.Tipologia__c = 'Expectance';
        stepSB.priority__c=0;
        stepSB.stato__c='Attiva';
        stepSB.recordtypeId=RTStrategiaNameID.get('Step').getRecordTypeID();
        insert stepSB;

        //Step Crea Case
        Strategia__c stepCreaCase = new Strategia__c();
        stepCreaCase.CRABB_DEV__Testata__c=testata.id;
        stepCreaCase.CRABB_DEV__Attivit_Padre__c=stepSB.id;
        stepCreaCase.CRABB_DEV__Tipo_attivita__c='Invio SMS';
        stepCreaCase.sotto_tipo_attivita__c='Seconda Raccomandata';
        stepCreaCase.nome__c='Crea Case';
        stepCreaCase.Tipologia__c = 'UI';
        stepCreaCase.priority__c=1;
        stepCreaCase.stato__c='Attiva';
        stepCreaCase.recordtypeId=RTStrategiaNameID.get('Step').getRecordTypeID();
        strategyList.add(stepCreaCase);

        //Step Crea PDF
        Strategia__c stepCreaPDF = new Strategia__c();
        stepCreaPDF.CRABB_DEV__Testata__c=testata.id;
        stepCreaPDF.CRABB_DEV__Attivit_Padre__c=stepSB.id;
        stepCreaPDF.CRABB_DEV__Tipo_attivita__c='Proposta di Attività';
        stepCreaPDF.sotto_tipo_attivita__c='Lettera ordinaria';
        stepCreaPDF.nome__c='CREA PDF';
        stepCreaPDF.Tipologia__c = 'UI';
        stepCreaPDF.priority__c=2;
        stepCreaPDF.stato__c='Attiva';
        stepCreaPDF.recordtypeId=RTStrategiaNameID.get('Step').getRecordTypeID();
        strategyList.add(stepCreaPDF);

        insert strategyList;
        update testata;

    }
}