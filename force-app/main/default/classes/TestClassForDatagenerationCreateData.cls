/*
* CreatedBy: KMeta
* CreatedDate:31/July/2014
* Description: Questa classe ha lo scopo di generare dati del data model precompilati secondo le necessità. I dati sono presi da record esistenti a sistema e sono
*              stati modificati i dati sensibili o collegamenti tra oggetti (lookup). Sono dei pezzi di lego fondamentali per  poi costruire scenari di test
*              complessi. Sono tutti dati prototipo, poi bisogna che vengano manipolati secodo le neccessità per poter creare un vero e proprio caso di test
*              sono 
* Modified to fix English version - replace getRecordTypeInfosByName with getrecordtypeinfosbydevelopername, line no 16, 
*/


public class TestClassForDatagenerationCreateData{
    public static Map<string, Schema.RecordTypeInfo> RTStrategiaNameID;
    public static id getRTStrategiaId(string RecordTypeName){
        if(RTStrategiaNameID==null){
            RTStrategiaNameID=Schema.SObjectType.Strategia__c.getrecordtypeinfosbydevelopername();         
        }
        return RTStrategiaNameID.get(RecordTypeName).getRecordTypeID();
    }
    public static Strategia__c getTestStrategiaTestata(){
        Strategia__c str = new Strategia__c();
        str.nome__c='STRATEGIA APPALTI';
        str.priority__c=0;
        str.stato__c='Attiva';
        str.Versione__c=1;
        str.recordtypeId=getRTStrategiaId('Testata');
        str.Tipo_Strategia__c='Standard';
        str.Activation_roles__c='R2014-07-01 11:58:54,R2014-06-27 08:08:28,R2014-07-02 11:48:39,R5,R4,R6,R7,R2014-07-21 10:00:52,R2014-07-02 11:43:56,R3,R2014-07-11 10:29:40';
        return str;
    }
    public static Strategia__c getTestStrategiaCDU(id testata){
        Strategia__c str = new Strategia__c();
        str.nome__c='Condizioni uscita strategia APPALTI';
        str.testata__c=testata;
        str.priority__c=0;
        str.Descrizione__c='condizione di uscita in caso lo scaduto sia inferiore di 30€ ma maggiore di 0€';
        str.Versione__c=1;
        str.recordtypeId=getRTStrategiaId('Condizioni_di_Uscita');
        str.Tipo_Strategia__c='Standard';
        str.industri_print_reference__c='STR-0000004.1';
        str.Activation_roles__c='R7,R6';
        str.Max_Scaduto__c=29.99;
        str.Min_Scaduto__c=0.01;
        return str;
    }
    public static Strategia__c getTestStrategiaCDI(id testata){
        Strategia__c str = new Strategia__c();
        str.testata__c=testata;
        str.nome__c='Condizioni ingresso strategia APPALTO';
        str.priority__c=0;
        str.Descrizione__c='condizione di ingresso';
        str.Versione__c=1;
        str.recordtypeId=getRTStrategiaId('Condizioni_di_Ingresso');
        str.industri_print_reference__c='STR-0000004.1';
        str.Min_Scaduto__c=0;
        str.Scaduto__c=30.00;
        str.comune__c='Rho';
        str.Metodo_di_Pagamento__c='RID';
        str.Activation_roles__c='R5,R4,R3,R2014-07-11 10:29:40';
        return str;
    }   
    public static Strategia__c getTestStrategiaSTEP(id testata,id attivitaPadre){
        Strategia__c str = new Strategia__c();
        str.testata__c=testata;
        str.Attivit_Padre__c=attivitaPadre;
        str.nome__c='Proposta invio prima raccomandata';
        str.priority__c=0;
        str.Descrizione__c='L\'attività propone all\'utente di inviare una raccomandata al cliente';
        str.Versione__c=1;
        str.recordtypeId=getRTStrategiaId('Step');
        str.industri_print_reference__c='S2.Step1#1';
        str.Tipologia__c='UI';
        str.Fase__c='Pre-Legale';
        str.Tipo_attivita__c='Proposta di Attività';
        str.Sotto_tipo_attivita__c='Prima raccomandata';
        return str;
    }   
    public static Strategia__c getTestStrategiaJUMP(id testata,id jumpFrom, id jumpTo){
        Strategia__c str = new Strategia__c();
        str.testata__c=testata;
        str.jump_from__c=jumpFrom;
        str.jump_to__c=jumpTo;
        str.nome__c='Torna al primo step della strategia';
        str.priority__c=0;
        str.Descrizione__c='questa operazione viene fatta automaticamente';
        str.Versione__c=1;
        str.recordtypeId=getRTStrategiaId('Salto');
        str.industri_print_reference__c='S2.Jump#2';
        str.activation_roles__c='R2014-07-02 11:43:56';
        str.Esito__c='Ritorno al primo step';
        return str;
    }   
    
    /* Creazione  Account */
    public static List<Account> getTestAccounts(integer numberOfAccounts){
        List<Account> accList = new List<Account>();
        for(Integer x=0; x<numberOfAccounts; x++){
            account acc = new Account();
            acc=getTestAccount();
            acc.Name+=x;
            accList.add(acc);  
        }
        return accList;
    }
        public static Account getTestAccount(){
            account acc = new Account();
                acc.Indirizzo_Principale__c=false;
                acc.Phone_SMS__c='8888888888';
                acc.mail_sollecito__c='test@balanceconsulting.it';
                acc.White_List__c=false;
                acc.ShippingState='FI';
                acc.phone='0000000000';
                acc.Phone2__c='2222222222';
                acc.phone3__c='3333333333';
                acc.phone4__c='4444444444';
                acc.phone5__c='5555555555';
                acc.phone6__c='6666666666';
                acc.mail1__c='test1@balanceconsulting.it';
                acc.mail2__c='test2@balanceconsulting.it';
                acc.mail3__c='test3@balanceconsulting.it';
                acc.mail4__c='test4@balanceconsulting.it';
                acc.BillingState='FI';
                acc.Invio_Piano_di_Rientro__c=false;
                acc.BillingPostalCode='50063';
                acc.Codice_Fiscale__c='NA';
                acc.ShippingCity='FIGLINE VALDARNO';
                acc.Fascia_ISEE__c='764,33';
                acc.Pratiche_In_Lavorazione__c=0;
                acc.Scadenza_ISEE__c=date.valueof('2014-09-11');
                acc.ShippingStreet='P.ZZA S. FRANCESCO DASSISI, 1114';
                acc.Warning_Integration__c=false;
                acc.BillingStreet='P.ZZA S. FRANCESCO DASSISI, 1114';
                acc.Name=Utils.generateRandomString(8)+'BALTEST'+System.currentTimeMillis();
                acc.BillingCity='FIGLINE VALDARNO';
                acc.Invio_Sollecito__c=false;
                acc.ShippingPostalCode='50063';
                acc.data_scaduto__c=system.today();
                acc.codice_account__c='Codice account Test';
                acc.stato__c='Attivo';
                acc.importo_incasso_corrente__c=0;
                acc.Id_Esterno__c = 'BAL_'+Utils.generateRandomString(50);
                acc.invio_piano_di_rientro__c=false;        
                acc.trigger_cause__c=null;
            return acc;
        }
    
    /* Creazione  Contratto */
    public static List<Contratto__c> getTestContracts(integer numberOfContracts){
        
        List<Contratto__c> ctrList = new List<Contratto__c>();
    
        for(Integer x=0; x<numberOfContracts; x++){
            Contratto__c ctr = new Contratto__c();
            ctr=getTestContract();
            ctr.referenti_gruppo_elior__c+=x;
            ctrList.add(ctr);  
        }
        return ctrList;
    }
        public static Contratto__c getTestContract(){
            Contratto__c ctr = new Contratto__c();
            ctr.referenti_gruppo_elior__c='prova';
            ctr.gestore_del_credito__c='Sig. Rossi';
            ctr.tipologia__c='APPALTO';
            ctr.prezzo_pasto_aggiudicazione__c=2.30;
            ctr.esercenti_e_sportello__c='Sig. Bianchi';
            ctr.referenti_comunali__c='Sig. Rossi, Via comune di Rho 34';
            ctr.dominio__c='Scuola';
            ctr.cifra_affari__c=2000000;
            ctr.mondo_scuola__c=false;
            ctr.nome_dei_servizi__c='PREPAGATO-CENTRO-ESTIVO;PREPAGATO-REFEZIONE';
            ctr.flag_processo_automatico_mensile__c=true;
            ctr.azienda__c='Elior';
            ctr.Incaricato__c= UserInfo.getUserId();
            ctr.altre_note__c='altre note';
            ctr.software_house__c='ACM';
            ctr.stato__c='ATTIVO';
            ctr.partita_iva__c='02302301232';
            ctr.data_inizio__c=date.valueof('2014-06-03');
            ctr.numero_frequentanti__c=1200;
            ctr.comune__c='Milano';
            ctr.metodo_di_pagamento_utenza__c='XXX';
            ctr.data_fine__c=date.valueof('2019-06-05');
            ctr.comune_pec__c='test-pec@balanceconsulting.it';
            ctr.titolo__c='APPALTO RHO 2013';
            ctr.Id_Esterno__c = 'BAL_'+System.currentTimeMillis();
            return ctr;
        }
        
    /* Creazione  Servizio */
    public static List<Servizio__c> getTestServices(integer numberOfServices){
        List<Servizio__c> servList = new List<Servizio__c>();
        
        for(Integer x=0; x<numberOfServices; x++){
            Servizio__c serv = new Servizio__c();
            serv.id_esterno__c+=x;
            servList.add(serv);  
        }
        return servList;
    }   
        public static Servizio__c getTestService(){
            Servizio__c serv = new Servizio__c();
            serv.metodo_di_pagamento__c='ALTRO';
            serv.id_softwarehouse__c='XXXX';
            serv.codice__c='POSTREF';
            serv.id_esterno__c='XXXX';
            serv.stato__c='ATTIVO';
            serv.nome__c='POSTPAGATO-REFEZIONE';
            return serv;
        }
        
    /* Creazione  Servizi item */
    public static List<Servizi_Item__c> getTestServiziItem(integer numberOfServiziItem){
        List<Servizi_Item__c> servList = new List<Servizi_Item__c>();
        
        for(Integer x=0; x<numberOfServiziItem; x++){
            Servizi_Item__c serv = new Servizi_Item__c();
            serv=getTestServizioItem();
            serv.circolo_didattico__c+=x;
            servList.add(serv);  
        }
        return servList;
    }
        public static Servizi_Item__c getTestServizioItem(){
            Servizi_Item__c serv = new Servizi_Item__c();
            serv.frequenza__c='IN-CORSO';
            serv.codice__c='PREREF';
            serv.mf__c='MASCHIO';
            serv.warning_integration__c=false;
            serv.circolo_didattico__c='CIRCOLO DIDATTICO DI FIGLINE';
            serv.fruizione__c='ATTIVO';
            serv.cognome__c='ARVIA';
            serv.scuola__c='ASILO NIDO TRENINO';
            serv.costo_pasto_utente__c=4.20;
            serv.data_di_nascita__c=date.valueof('2011-09-02');
            serv.classe__c='grandi';
            serv.nome__c='ALESSANDRO';
            return serv;
        }
        
    /*Creazione SR*/
    public static List<SR__c> getTestSR(integer numberOfSR){
        List<SR__c> srList = new List<SR__c>();
        
        for(Integer x=0; x<numberOfSR; x++){
            SR__c sr = new SR__c();
            sr=getTestSR();
            sr.Note__c+=x;
            srList.add(sr);  
        }
        return srList;
    }
        public static SR__c getTestSR() {
            SR__c sr = new SR__c();
            sr.Bloccante__c=false;
            sr.Categoria__c='Reclamo';
            sr.Data_Apertura__c=system.Today();
            sr.Data_Chiusura__c=system.Today();
            sr.Tipo__c='Credito';
            sr.Note__c='note note note';
            sr.Stato__c='Aperta';
            sr.Sotto_Categoria__c='Pagamento';      
            return sr;
        }
    
    /* Creazione Pratica */
    public static List<Pratica__c> getTestPratica(integer numberOfPratica){
        List<Pratica__c> pList = new List<Pratica__c>();
        
        for(Integer x=0; x<numberOfPratica; x++){
            Pratica__c p = new Pratica__c();
            p=getTestPratica();
            p.Nome_Collector_Attivo__c+=x;
            pList.add(p);  
        }
        return pList;
    }
    public static Pratica__c getTestPratica(){
        Pratica__c p = new Pratica__c();
        p.Anzianit_Pratica__c=system.today();
        p.Check_In_Lavorazione__c=false;
        p.Data_inizio_scaduto__c=system.today();
        p.Esci_e_chiudi__c=false;
        p.Fascia_di_rischio__c='1234';
        p.Importo_Incasso_Consolidato__c=0;
        p.Nome_Collector_Attivo__c='XXX';
        p.Request__c='Request XXX';
        p.Importo_saldo_Consolidato__c=0;
        p.Importo_Spese_Consolidato__c=0;
        p.Importo_Scaduto_Consolidato__c=0;
        p.Scaduto_Spese__c=0;
        p.Scaduto_Spese_Consolidato__c=0;
        p.Stato__c='Bozza';
        p.ownerid=userinfo.getuserid();
        return p;
    }
    
    /* Creazione Note */
    public static List<Nota__c> getTestNote(integer numberOfNote){
        List<Nota__c> noteList = new List<Nota__c>();
        
        for(Integer x=0; x<numberOfNote; x++){
            Nota__c note = new Nota__c();
            note=getTestNote();
            note.Nota__c+=x;
            
            noteList.add(note);  
       }
       return noteList;
    }   
        public static Nota__c getTestNote(){
            Nota__c note = new Nota__c();
            note.Current_Note__c=1;
            note.Data_Inserimento__c=system.Today();
            note.Data_Inserimento_2__c=system.Today();
            note.Max_Note__c=7;
            note.Nota__c='ccc';
            note.Nota_2__c='xxx';
            note.User__c=userinfo.getFirstName() +' '+userinfo.getLastName();
            note.User_2__c=userinfo.getFirstName() +' '+userinfo.getLastName();
            note.Visibilit__c='Visibile a tutti';
            note.Visibilit_2__c='Visibile a tutti';     
            note.ownerid=userinfo.getuserid();
            return note;
        }

    /* Creazione Movimenti */
    public static List<Movimento__c> getTestMovimento(integer numberOfMovimento){
        List<Movimento__c> movList = new List<Movimento__c>();
        for(Integer x=0; x<numberOfMovimento; x++){
            Movimento__c mov = new Movimento__c();
            mov=getTestMovimento();
            mov.Importo_Saldo_1__c+=x;
            movList.add(mov);  
        }
        return movList;
    }   
        public static Movimento__c getTestMovimento(){
            Movimento__c mov = new Movimento__c();
            mov.Calcola_SALDO_ANNO__c=false;
            mov.Causale__c='CAUSALE';
            mov.Causale_Non_Sollecitabile__c='Integrazione';
            mov.Data_Emissione__c=system.today();
            mov.Data_Integrazione__c=system.today();
            mov.Data_Integrazione_1__c=system.today();
            mov.Data_Pagamento__c=system.today();
            mov.Data_Scadenza__c=system.today();
            mov.Data_Saldo_1__c=system.today();
            mov.Flag_Incasso_Utente__c=false;
            mov.Importo__c=1863;
            mov.Importo_Saldo_1__c=786;
            mov.IsFutureContext__c=false;
            mov.Mese__c='AGOSTO';
            mov.Redisuo__c=47;
            mov.Ritardo__c=1;
            mov.SALDO_ANNO_LAVORATO__c=false;
            mov.Sollecitabile__c=false;
            mov.Saldo__c=758;
            mov.Saldo_Mese_Precedente__c=99;
            mov.Saldo_Mese_Precedente_Data__c=system.today();
            mov.Saldo_Spese__c=150;
            mov.Saldo_Spese_1__c=100;
            mov.Saldo_Spese_Mese_Precedente__c=10;
            mov.Residuo__c=1;
            mov.Scaduto_Saldo_1__c=1;
            mov.Tipo_Movimento_SWH__c='SWH';
            mov.Tipo_Movimento_SWH_1__c='SWH 1';
            mov.Tipo_Scadenza__c='Scaduto';
            mov.Write_Off__c=false;
            mov.Write_Off_1__c=false;               
            
            return mov;
        }
}