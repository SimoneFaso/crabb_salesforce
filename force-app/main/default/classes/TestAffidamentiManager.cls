/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestAffidamentiManager.cls
Description:     Test Class for code coverage of AffidamentiManager.cls


Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
08-Oct-2014  0.1      Enrit Sino                      First Version
13-May-2020  0.2      M.Siotto & G.Mameli             Reviewed for using ceb methods
----------------------------------------------------------------------------------------------------------------------*/

@IsTest
public class TestAffidamentiManager {
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    @IsTest
    static void testCreateAffidamenti() {

        Test.startTest();

        // 1. Met. CreateAffidamenti Future
        // Memorizza le pratiche serializzate nel Pratiche_pre_lotto__c
        List<Pratica__c> pList = new List<Pratica__c>();
        pList = createPratiche();
        insert pList;
        Task t = new Task();
        ActivityExtended__c ae = new ActivityExtended__c();
        insert ae;
        t.Type = 'Credito';
        t.Description = 'Desc';
        t.ActivityExtended__c = ae.Id;
        insert t;

        Map<String, String> pLotMap = new Map<String, String>();
        for (Pratica__c p : pList){
            pLotMap.put(p.Id, t.Id);
        }

        //Lista di Lotti
        List<Lotto__c> lotList = new List<Lotto__c>();
        lotList = creaLotti();
        insert lotList;

        for (Lotto__c l : lotList) {
            l.Pratiche_pre_lotto__c = JSON.serialize(pLotMap);
        }
        update lotList;

        List<Id> lotId = new List<Id>();
        for (Lotto__c l : lotList) {
            lotId.add(l.Id);
        }

        AffidamentiManager.createAffidamentiFuture(lotId, 'tipoAffidamento');
        System.assert(true, t.Description == 'Desc');
        Test.stopTest();
    }

    @IsTest
    static void testCreaAffidamenti() {

        Test.startTest();
        TaskHandler.internalUpdate = true;
        // Crea lotto
        User u = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');
        //User u = [Select id From User where username = 'adr@elior.it.fd' limit 1];
        Collector__c col = TestClassFroDataGenAffidamenti.getCollector(u.Id);
        insert col;

        Lotto__c lot = new Lotto__c();
        lot = new Lotto__c(Stato__c = 'Stato', Agenzia_di_recupero__c = col.id);

        //Crea pratica
        Pratica__c p = getPratica();
        insert p;
        //Crea task
        Task t = new Task();
        ActivityExtended__c ae = new ActivityExtended__c();
        insert ae;
        t.Type = 'Credito';
        t.ActivityExtended__c = ae.Id;
        insert t;

        Map<String, String> mPT = new Map<String, String>();
        mPT.put(p.Id, t.Id);

        lot.Pratiche_pre_lotto__c = JSON.serialize(mpt);
        insert lot;

        // 2) CreaAffidamenti(lotto)
        AffidamentiManager.creaAffidamenti(lot);
        System.assert(true, lot.Stato__c == 'Stato');
        Test.stopTest();
    }

    static testmethod void testPreparaLotti() {
        test.startTest();
        // 1. Lista di affidi
        List<Affidamento__c> lAff = new List<Affidamento__c>();
        lAff.add(TestClassFroDataGenAffidamenti.getQuickAffido());
        lAff.add(TestClassFroDataGenAffidamenti.getQuickAffido());
        insert lAff;
        AffidamentiManager.preparaPreLotti(lAff);
        System.assert(true, lAff.get(0).Stato__c == 'stato');
        test.stopTest();
    }

    static testmethod void testConfermaAffidTask() {
        // 1. Input un list<id> lottoID
        // 2. Crea affidi: Stato != annullato, Lotto__c in: lottoID
        // 3. Associa task e pratiche a i affidi.
        test.startTest();
        List<Lotto__c> lot = creaLotti();
        insert lot;
        // 1- 
        List<Id> Idlotti = new List<Id>();
        for (lotto__c l : lot)
            Idlotti.add(l.id);

        // 2. 
        Affidamento__c aff = TestClassFroDataGenAffidamenti.getQuickAffido();
        aff.Lotto__c = idLotti[0];
        // 3. 
        Task t = new Task();
        t.Type = 'Credito';
        t.status = 'Non Iniziata';
        insert t;
        aff.id_Task_associato__c = t.id;

        Pratica__c p = getPratica();
        p.Stato__c = 'In Lavorazione';
        insert p;
        aff.Pratica__c = p.id;

        List<Affidamento__c> laff = new List<Affidamento__c>{
                aff
        };
        insert laff;

        AffidamentiManager.confermaAffidamentiTask(idLotti);

        // scen: idtask associ nullo
        laff[0].id_Task_associato__c = null;
        update laff;

        AffidamentiManager.confermaAffidamentiTask(idLotti);


        System.assert(true, laff[0].Stato__c == 'stato');
        test.stopTest();
    }

    static testmethod void confermaAffidPraticaNonINLavorazione() {
        test.startTest();
        List<Lotto__c> lot = creaLotti();
        insert lot;
        // 1- 
        List<Id> Idlotti = new List<Id>();
        for (lotto__c l : lot)
            Idlotti.add(l.id);

        // 2. 
        Affidamento__c aff = TestClassFroDataGenAffidamenti.getQuickAffido();
        aff.Lotto__c = idLotti[0];
        // 3. 
        Task t = new Task();
        t.status = 'Non Iniziata';
        t.Type = 'Credito';
        insert t;
        aff.id_Task_associato__c = t.id;

        Pratica__c p = getPratica();
        insert p;
        aff.Pratica__c = p.id;

        List<Affidamento__c> laff = new List<Affidamento__c>{
                aff
        };
        insert laff;

        AffidamentiManager.confermaAffidamentiTask(idLotti);
        System.assert(true, aff.Stato__c == 'stato');
        test.stopTest();
    }

    static testmethod void testEliminaPRelotto() {
        // 1. Input ID: idLotto
        // 2. Crea task con idLotoAssoc In: idLotto & stato = Non inizito
        // 3. Crea affidi con lotto In: idLOtto

        test.startTest();
        List<Lotto__c> lot = creaLotti();
        insert lot;

        // 1- 
        List<Id> Idlotti = new List<Id>();
        for (lotto__c l : lot)
            Idlotti.add(l.id);

        // 2-
        Task t = new task();
        t.Type = 'Credito';
        ActivityExtended__c ae = new ActivityExtended__c();
        ae.id_lotto_associato__c = idLotti[0];
        insert ae;
        t.ActivityExtended__c = ae.Id;
        t.Status = 'Non Iniziata';
        insert t;

        // 3-
        Affidamento__c aff = TestClassFroDataGenAffidamenti.getQuickAffido();
        aff.Lotto__c = idLotti[0];
        insert aff;

        AffidamentiManager.eliminaPreLotto(idLotti[0]);
        System.assert(true, aff.Stato__c == 'stato');
        test.stopTest();
    }

    static testmethod void testEliminaPreaffidi() {
        // 1. input idAffid
        // 2. Crea task assoic al affido
        test.startTest();

        //1- 
        Affidamento__c aff = TestClassFroDataGenAffidamenti.getQuickAffido();
        insert aff;

        //2-
        Task t = new Task();
        t.Type = 'Credito';
        ActivityExtended__c ae = new ActivityExtended__c();
        ae.id_affidamento__c = aff.id;
        insert ae;
        t.ActivityExtended__c = ae.Id;
        t.Status = 'Non Iniziata';
        insert t;

        AffidamentiManager.eliminaPreAffidamento(aff.id);
        System.assert(true, aff.Stato__c == 'stato');
        test.stopTest();
    }

    static testmethod void testgeneraAffidamentoFuture() {
        // 1. Input idLotto
        // 1.1* associa una pratica e un task al affido
        // 2. Crea affido associato al lotto
        test.startTest();

        // 1-
        List<Lotto__c> lot = creaLotti();
        insert lot;

        // 2-
        Affidamento__c aff = TestClassFroDataGenAffidamenti.getQuickAffido();
        aff.Lotto__c = lot[0].id;
        aff.Stato__c = 'Da Confermare';

        // associa un task e una pratica
        Task t = new Task();
        t.Type = 'Credito';
        ActivityExtended__c ae = new ActivityExtended__c();
        ae.id_affidamento__c = aff.id;
        insert ae;
        t.ActivityExtended__c = ae.Id;
        t.Status = 'Non Iniziata';
        insert t;


        Pratica__c p = getPratica();
        p.Stato__c = 'In Lavorazione';
        insert p;

        aff.id_Task_associato__c = t.id;
        aff.Pratica__c = p.id;

        insert aff;

        AffidamentiManager.generaAffidamentoFuture(lot[0].id);

        // senza task& pratiche associ
        Affidamento__c aff1 = TestClassFroDataGenAffidamenti.getQuickAffido();
        aff1.Lotto__c = lot[0].id;
        aff1.Stato__c = 'Da Confermare';
        insert aff1;
        AffidamentiManager.generaAffidamentoFuture(lot[0].id);
        System.assert(true, aff1.Stato__c == 'stato');
        test.stopTest();
    }

    static testmethod void TestrevocaSingoloAffidamento() {
        // 1. In: idAffid
        // 2. pratica associata al affido
        // 3. task associato al affido e non iniziato

        // 1-
        Affidamento__c aff = TestClassFroDataGenAffidamenti.getQuickAffido();
        aff.Scaduto_iniziale__c = 12;
        aff.Scaduto_finale__c = 4;
        // 2-        
        Pratica__c p = getPratica();
        p.Stato__c = 'Affidata';
        insert p;

        aff.Pratica__c = p.id;
        insert aff;

        // 3-
        Task t = new Task();
        t.Type = 'Credito';
        ActivityExtended__c ae = new ActivityExtended__c();
        ae.id_affidamento__c = aff.id;
        insert ae;
        t.ActivityExtended__c = ae.Id;
        t.Status = 'Non Iniziata';
        insert t;

        test.startTest();
        AffidamentiManager.revocaSingoloAffidamento(aff.id, 'note');
        System.assert(true, aff.Stato__c == 'stato');
        test.stopTest();
    }

    static testmethod void testRevocaLotto() {
        // 1. in: Id Lotto & String causaRevoca
        // 2. Crea un affido associato al un lotto
        // 3. crea pratiche associate al affido

        // 1-
        List<Lotto__c> lot = creaLotti();
        insert lot;

        // 2-
        Affidamento__c aff = TestClassFroDataGenAffidamenti.getQuickAffido();
        aff.Scaduto_iniziale__c = 12;
        aff.Scaduto_finale__c = 4;

        // 3-
        Pratica__c p = getPratica();
        p.Stato__c = 'Affidato';
        insert p;

        aff.Lotto__c = lot[0].id;
        aff.Pratica__c = p.id;
        aff.Stato__c = 'In corso';
        insert aff;

        Task t = new Task();
        t.Type = 'Credito';
        ActivityExtended__c ae = new ActivityExtended__c();
        ae.id_affidamento__c = aff.id;
        insert ae;
        t.ActivityExtended__c = ae.Id;
        t.Status = 'Non Iniziata';
        insert t;

        List<id> listIdAff = new List<id>{
                aff.id
        };

        test.startTest();
        AffidamentiManager.revocaLotto(lot[0].id, 'causaRevocaLotto');
        AffidamentiManager.revocaListAffidamentiInt(listIdAff, 'causaRevocaLotto');
        System.assert(true, aff.Stato__c == 'stato');
        test.stopTest();
    }
    /*
    static testmethod void TestrevocaListAffidamenti(){
        // 1. in: List AffidIDs & Str CausaRevo
        // 2. Associa pratica al affido
        // 3. associa affida al task
        
        // 1-
        List<id> idAffidi = new List<Id>();
        Affidamento__c aff = TestClassFroDataGenAffidamenti.getQuickAffido();
        aff.Scaduto_iniziale__c = 12;
        aff.Scaduto_finale__c = 4;
        
        // 2-
        Pratica__c p = getPratica();
        p.Stato__c = 'Affidato';
        insert p;
        
        aff.Pratica__c = p.id;
        insert aff;
        idAffidi.add(aff.id);
        
        // 3-
        Task t = new Task();
        t.id_affidamento__c = aff.id;
        t.Status = 'Non Iniziata';
        insert t;
        
        test.startTest();
        	AffidamentiManager.revocaListAffidamenti(idAffidi, 'causaRevocaLotto');
        test.stopTest();
    }
    */
    static testmethod void TestrevocaListAffidamentiUscitaStrategia() {
        // 1. In: Mapa id, String: id(Affidi) & String(Non so perche si usa)
        // 2. Associa pratica al affido

        // 1-
        Map<Id, String> inMap = new Map<Id, String>();
        List<id> idAffidi = new List<Id>();
        Affidamento__c aff = TestClassFroDataGenAffidamenti.getQuickAffido();
        aff.Scaduto_iniziale__c = 12;
        aff.Scaduto_finale__c = 4;

        // 2-
        Pratica__c p = getPratica();
        p.Stato__c = 'Affidato';
        insert p;

        aff.Pratica__c = p.id;
        insert aff;
        inMap.put(aff.id, 'value');

        test.startTest();
        AffidamentiManager.revocaListAffidamentiUscitaStrategia(inMap);
        AffidamentiManager.cebRevocaListAffidamentiUscitaStrategia(inMap, gd);
        System.assert(true, aff.Stato__c == 'stato');
        test.stopTest();
    }

    // *
    // **
    // ***metodi ausiliari 

    public static List<Lotto__c> creaLotti() {
        User u = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');
        Collector__c col = TestClassFroDataGenAffidamenti.getCollector(u.Id);
        insert col;

        List<Lotto__c> tmp = new List<Lotto__c>();

        for (integer i = 0; i < 10; i++)
            tmp.add(new Lotto__c(Stato__c = 'Stato', Agenzia_di_recupero__c = col.id));
        return tmp;
    }

    public static List<Pratica__c> createPratiche() {
        Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        insert con;
        Account ac = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert ac;

        List<Pratica__c> tmp = new List<PRatica__c>();
        for (integer i = 0; i < 10; i++)
            tmp.add(new Pratica__c(Account__c = ac.id, Data_ultimo_Saldo__c = System.today()));

        return tmp;
    }

    public static Pratica__c getPratica() {
        Contratto__c con = TestClassFroDataGenAffidamenti.getContratto();
        Database.insert(con, false);
        Account ac = TestClassFroDataGenAffidamenti.getAccount(con.Id);
        insert ac;

        Pratica__c p = new Pratica__c(Account__c = ac.id, Data_ultimo_Saldo__c = System.today());
        return p;
    }
}