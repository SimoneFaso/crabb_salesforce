/*
 * created by: Endrit Sino
 * Desc: Questa classe contiene dei metodi per istanziare i vari oggetti neccessari per
 *       la creazione dei affidamenti. Poi secondo le casistiche possono essere modificate
 *       e fatte overload.
 * date: 23/9/2014
 * * Modified to fix English version - replace getRecordTypeInfosByName with getrecordtypeinfosbydevelopername, 16
 */
@isTest
public class TestClassFroDataGenAffidamenti {
    
    //  metodo per strategia
    public static Strategia__c getStrategia(String recordType){
        
        Strategia__c s = new Strategia__c();
        Map<String, Schema.RecordTypeInfo> ctRecordTypes = Schema.SObjectType.Strategia__c.getrecordtypeinfosbydevelopername();         
        s.recordTypeId = ctRecordTypes.get(recordType).getRecordTypeID();
        return s;
    }
        
    // metodo statico per chiedere in DB un profilo
    // speciale di User(id, ProfileId, UserRoleId)
    public static User getUser(String userProfileName){
        
        User user = new User();
        user.Username = 'test'+System.currentTimeMillis()+'@balanceconsulting.it';
        user.LastName = 'Tester';
        user.Email = 'test@balanceconsulting.it';
        user.alias = 'Guru';
        user.Country = 'IT/IT';
        user.TimeZoneSidKey = 'Europe/Rome';
        user.LocaleSidKey = 'it_IT';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.collector__c = true;
        //user.ProfileId = [select id from Profile where Name='System Administrator'].Id;
        user.LanguageLocaleKey = 'en_US';
        Profile p;
        try {
           p = [SELECT Id FROM Profile WHERE Name=:userProfileName LIMIT 1]; 
        } catch (Exception e) {
           p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; //Standard User
        }
        //Name = 'Standard User'
        //System.debug('PROFILININO:'+[SELECT Name FROM Profile]);
        user.ProfileId = p.Id;
        insert user;
        //u = [Select id, ProfileId, UserRoleId From User Where userType= 'PowerPartner' limit 1];
        return user;
    }
    
    // metodo per gestire i collector
    public static Collector__c getCollector(id userId){
        Collector__c col = new Collector__c();
        col.Prefisso_Lotto__c = '001';
        col.Ragione_Sociale__c = 'Rag Soc Test';
        col.Localita__c = 'Localitá test';
        col.User__c = userId;
        col.Tipo_Collector__c = 'ADR ';
        return col;
    }
    
    
    // metodo per gestire i lotto
    public static Lotto__c getLotto(id CollectorId){
        
        Lotto__c lot = new Lotto__c();
         lot.Agenzia_di_Recupero__c = collectorId;
        return lot;
    }
    
    
    // Crezione di una pratica, avviene contenendo anche un account.
    // *Prima creeremo un Contratto => che poi possiamo creare un account test
    public static Pratica__c getPratica(id accId){
        
        Pratica__c prat = new Pratica__c();
         prat.account__c = accId;
        return prat;
    }
    
    // metodo per creare un contratto
    public static contratto__c getContratto(){
        
        Contratto__c con = new Contratto__c();
        con.Id_esterno__c = 'NomeContrTest'; 
        con.Comune__c = 'NomecoumneTest';
        con.Data_inizio__c = System.Today();
        con.Partita_IVA__c = 'ssss';
        con.Titolo__c = String.valueOf(System.today());
        return con;
    }
        
    // metodo per creare un acct
    public static Account getAccount(id conId){
        
        Account act = new Account();
        act.Contratto__c = conId;
        act.Name = 'Test';
        act.Stato__c = 'Attiva';
        act.Pratiche_In_Lavorazione__c = 1;
        return act;
    }
    
    // metodo per creare un affidamento
    Public static Affidamento__c getAffido(String stato, Date dataAffido, id lotId, id pratId){
        
        Affidamento__c affid = new Affidamento__c();
        affid.Stato__c = stato;
        affid.Data_Affidamento__c = dataAffido;
        affid.Lotto__c = lotId;
        affid.Pratica__c = pratId;
        return affid;
    }
    
    // metodo per creare affido on the fly
    public static Affidamento__c getQuickAffido(){
        
        // prendi lotto
        User u = getUser('CRABB ADR');
       
        Collector__c col = new Collector__c();
        col = getCollector(u.id);
        insert col;
        Lotto__c l = new Lotto__c();
        l = getLotto(col.id);
        insert l;
        
        //prendi pratica 
        Contratto__c cont = new Contratto__C();
        cont = getContratto();
        Database.insert(cont,false);
        
        Account ac = new Account();
        ac = getAccount(cont.id);
        insert ac;
        
        Pratica__c p = new Pratica__c();
        p = getPratica(ac.id);
        insert p;
        
        // compila affido
        Affidamento__c affid = new Affidamento__c();
        affid.Stato__c = 'stato';
        affid.Data_Affidamento__c = System.today();
        affid.Lotto__c = l.id;
        affid.Pratica__c = p.Id;
        
        return affid;
    }

    public static List<Affidamento__c> CreateAffidGeneric(){
        // Prendi il user con per il filter lookup: CRABB Partner ADR 
                User lUs = new User();
                lUs = TestClassFroDataGenAffidamenti.getUser('CRABB ADR');
                    
                // Chiedi collector
                Collector__c col = TestClassFroDataGenAffidamenti.getCollector(lUs.id); 
                col.Tipo_Collector__c = 'ADR';
                insert col;
                // chiedo lotto
                Lotto__c lot= TestClassFroDataGenAffidamenti.getLotto(col.id);
                insert lot;
                // crea pratica
                Contratto__c ct = TestClassFroDataGenAffidamenti.getContratto();
                insert ct;
                // prendi il acct con il contratto appena chiesto
                Account acc = TestClassFroDataGenAffidamenti.getAccount(ct.id);
                insert acc;
                // crea la pratica con il acct
                Pratica__c pr = TestClassFroDataGenAffidamenti.getPratica(acc.id);
                insert pr;
                // adesso crea gli affidi
                Affidamento__c aff1 = TestClassFroDataGenAffidamenti.getAffido('In Corso', System.today(), lot.id, pr.id);
                Affidamento__c aff2 = TestClassFroDataGenAffidamenti.getAffido('In Corso', System.today(), lot.id, pr.id);
                insert aff1;
                insert aff2;
                List<Affidamento__c> affList = new List<Affidamento__c>();
                affList.add(aff1);
                affList.add(aff2);
                return affList;
    }

    public static GestioneRevocaCTRL setEnviromentWithAffidi(GestioneRevocaCTRL istanza){
                
        List<Affidamento__c> affidi = new List<Affidamento__c>();
        affidi = CreateAffidGeneric();
        
        istanza.QueryAffidPag = 'Select id, Stato__c From affidamento__c';
        istanza.BAllSel = true;
        
        istanza.recordsSelected = new Set<String>();
        istanza.recordsUnSelected = new Set<String>{'Che figata', 'In che senso'};
        istanza.ListTabellaAffidamentoSelectable();
        return istanza;
        
    }

    public static GestioneProrogaCTRL1 setEnviromentWithAffidi(GestioneProrogaCTRL1 istanza){
                
        List<Affidamento__c> affidi = new List<Affidamento__c>();
        affidi = CreateAffidGeneric();
        
        istanza.QueryAffidPag = 'Select id, Stato__c From affidamento__c';
        istanza.BAllSel = true;
        
        istanza.recordsSelected = new Set<String>();
        istanza.recordsUnSelected = new Set<String>{'Che figata', 'In che senso'};
        istanza.ListTabellaAffidamentoSelectable();
        return istanza;
        
    }
    
    // Metodi per creare oggetti fantasmi ..._Share
    public static AccountShare getAccountShare(id accId, id uId){
        AccountShare acSh = new AccountShare();
        acsh.AccountId = accid;// required 
        //acsh.RowCause = 'Manual';
        acsh.UserOrGroupId = uid;//required
        acsh.AccountAccessLevel = 'Read';// req
        acsh.OpportunityAccessLevel = 'Read';// req
        return acsh;
    }
    
    public static Pratica__Share getPraticaShare(id parentId, id uid){
        Pratica__Share pSh = new Pratica__Share();
        psh.parentId = parentId;
        psh.RowCause = Utils.NAMESPACE+'Affido__c';
        psh.UserOrGroupId = uid;
        psh.AccessLevel = 'Read';
        return psh;
    }
}