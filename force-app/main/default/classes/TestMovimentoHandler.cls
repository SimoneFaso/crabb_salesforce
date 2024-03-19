/*
 * Crated by: Endrit Sino	
 * Desc: Classe di test per il movimento Handler
 * Data: 7/11/2014
 */
@isTest
public class TestMovimentoHandler {
	
    static testmethod void testTinyMeths(){
        MovimentoHandler  istanza = new MovimentoHandler();
        List<SObject> myObj = new List<SObject>();
        istanza.bulkAfter(myObj, myObj);
        istanza.bulkBefore(myObj, myObj);
        istanza.beforeDelete(myObj);
        istanza.afterDelete(myObj);
        istanza.bulkAfter();
        istanza.bulkBefore();
        istanza.bulkAfter(myObj);
        istanza.bulkBefore(myObj);
        istanza.beforeInsert(myObj);
        istanza.andFinally();
    }
    
    static testmethod void testAfter_BeforeUpdate(){
        List<Movimento__c> lmov = new List<Movimento__c>();
        lmov = getMovimenti();
        insert lmov;
        
        test.startTest();
        MovimentoHandler  istanza = new MovimentoHandler();
        istanza.afterUpdate(lmov, lmov);
        istanza.beforeUpdate(new List<SOBJect>(), lmov);
        test.stopTest();
    }
    
    // Test anche per incassiAffidamentoConnection()
    // CreaJSon()
    static testmethod void testGestisciLogiche2(){
        Movimento__c m = getMovWithRCRDType('SALDO MESE'); 
        Movimento__c m1 = getMovWithRCRDType('INCASSO');
        List<Movimento__c> lmov2 = new List<Movimento__c>();
        lmov2.add(m);
        lmov2.add(m1);
        insert lmov2;
        List<Id> ids = new List<Id>();
        ids.add(m.Id);
        ids.add(m1.Id);
        String fields = CredManUtility.selectall('Movimento__c');
        String query = 'SELECT '+ fields + ' FROM CRABB_DEV__Movimento__c';
        lmov2= Database.query(query);
        //[Select Data_Emissione__c, Data_Scadenza__c, Pratica__c, Account__c, RecordTypeId, RecordType__c,Mese_Precedente__c from Movimento__c];
        /*lmov2 = [SELECT CRABB_DEV__ANNO__c, CRABB_DEV__Account__c, CRABB_DEV__Affidamento__c, CRABB_DEV__Affidi_History_2__c, CRABB_DEV__Affidi_History__c,
                CRABB_DEV__Ageing__c, CRABB_DEV__Anno_Mese__c, CRABB_DEV__Buffer_Json__c, CRABB_DEV__Calcola_SALDO_ANNO__c, CRABB_DEV__Cartolarizzazione__c,
                CRABB_DEV__Causale_Non_Sollecitabile__c, CRABB_DEV__Causale__c, CRABB_DEV__Check_Saldo_Mese_Precedente__c, CRABB_DEV__Check_Scadenza__c,
                CRABB_DEV__Data_Emissione__c, CRABB_DEV__Data_Incasso__c, CRABB_DEV__Data_Integrazione_10__c, CRABB_DEV__Data_Integrazione_11__c,
                CRABB_DEV__Data_Integrazione_12__c, CRABB_DEV__Data_Integrazione_13__c, CRABB_DEV__Data_Integrazione_14__c, CRABB_DEV__Data_Integrazione_15__c,
                CRABB_DEV__Data_Integrazione_16__c, CRABB_DEV__Data_Integrazione_17__c, CRABB_DEV__Data_Integrazione_18__c, CRABB_DEV__Data_Integrazione_19__c,
                CRABB_DEV__Data_Integrazione_1__c, CRABB_DEV__Data_Integrazione_20__c, CRABB_DEV__Data_Integrazione_21__c, CRABB_DEV__Data_Integrazione_22__c,
                CRABB_DEV__Data_Integrazione_23__c, CRABB_DEV__Data_Integrazione_24__c, CRABB_DEV__Data_Integrazione_25__c, CRABB_DEV__Data_Integrazione_26__c,
                CRABB_DEV__Data_Integrazione_27__c, CRABB_DEV__Data_Integrazione_28__c, CRABB_DEV__Data_Integrazione_29__c, CRABB_DEV__Data_Integrazione_2__c,
                CRABB_DEV__Data_Integrazione_30__c, CRABB_DEV__Data_Integrazione_31__c, CRABB_DEV__Data_Integrazione_3__c, CRABB_DEV__Data_Integrazione_4__c,
                CRABB_DEV__Data_Integrazione_5__c, CRABB_DEV__Data_Integrazione_6__c, CRABB_DEV__Data_Integrazione_7__c, CRABB_DEV__Data_Integrazione_8__c,
                CRABB_DEV__Data_Integrazione_9__c, CRABB_DEV__Data_Integrazione__c, CRABB_DEV__Data_Pagamento__c, CRABB_DEV__Data_Saldo_10__c, CRABB_DEV__Data_Saldo_11__c,
                CRABB_DEV__Data_Saldo_12__c, CRABB_DEV__Data_Saldo_13__c, CRABB_DEV__Data_Saldo_14__c, CRABB_DEV__Data_Saldo_15__c, CRABB_DEV__Data_Saldo_16__c,
                CRABB_DEV__Data_Saldo_17__c, CRABB_DEV__Data_Saldo_18__c, CRABB_DEV__Data_Saldo_19__c, CRABB_DEV__Data_Saldo_1__c, CRABB_DEV__Data_Saldo_20__c,
                CRABB_DEV__Data_Saldo_21__c, CRABB_DEV__Data_Saldo_22__c, CRABB_DEV__Data_Saldo_23__c, CRABB_DEV__Data_Saldo_24__c, CRABB_DEV__Data_Saldo_25__c,
                CRABB_DEV__Data_Saldo_26__c, CRABB_DEV__Data_Saldo_27__c, CRABB_DEV__Data_Saldo_28__c, CRABB_DEV__Data_Saldo_29__c, CRABB_DEV__Data_Saldo_2__c,
                CRABB_DEV__Data_Saldo_30__c, CRABB_DEV__Data_Saldo_31__c, CRABB_DEV__Data_Saldo_3__c, CRABB_DEV__Data_Saldo_4__c, CRABB_DEV__Data_Saldo_5__c,
                CRABB_DEV__Data_Saldo_6__c, CRABB_DEV__Data_Saldo_7__c, CRABB_DEV__Data_Saldo_8__c, CRABB_DEV__Data_Saldo_9__c, CRABB_DEV__Data_Scadenza__c,
                CRABB_DEV__Date_Time_Field__c, CRABB_DEV__FSC_Fascia_01__c, CRABB_DEV__FSC_Fascia_02__c, CRABB_DEV__FSC_Fascia_03__c, CRABB_DEV__FSC_Fascia_04__c,
                CRABB_DEV__FSC_Fascia_05__c, CRABB_DEV__FSC_Fascia_06__c, CRABB_DEV__FSC_Fascia_07__c, CRABB_DEV__FSC_Fascia_08__c, CRABB_DEV__FSC_Fascia_ND__c,
                CRABB_DEV__Fascia_di_Rischio_Text__c, CRABB_DEV__Fascia_di_Rischio__c, CRABB_DEV__Fattura_di_riferimento__c, CRABB_DEV__Flag_Incasso_Utente__c,
                CRABB_DEV__Flag_Ritardo__c, CRABB_DEV__Flow_data_incasso__c, CRABB_DEV__GG_di_Scaduto__c, CRABB_DEV__Id_Esterno_Saldo_Mensile__c, CRABB_DEV__Id_Movimento_Ext__c,
                CRABB_DEV__Id_esterno_servizio_item__c, CRABB_DEV__IdentificativoFatturaExt__c, CRABB_DEV__Importo_Saldo_10__c, CRABB_DEV__Importo_Saldo_11__c,
                CRABB_DEV__Importo_Saldo_12__c, CRABB_DEV__Importo_Saldo_13__c, CRABB_DEV__Importo_Saldo_14__c, CRABB_DEV__Importo_Saldo_15__c, CRABB_DEV__Importo_Saldo_16__c, CRABB_DEV__Importo_Saldo_17__c,
                CRABB_DEV__Importo_Saldo_18__c, CRABB_DEV__Importo_Saldo_19__c, CRABB_DEV__Importo_Saldo_1__c, CRABB_DEV__Importo_Saldo_20__c, CRABB_DEV__Importo_Saldo_21__c, CRABB_DEV__Importo_Saldo_22__c,
                CRABB_DEV__Importo_Saldo_23__c, CRABB_DEV__Importo_Saldo_24__c, CRABB_DEV__Importo_Saldo_25__c, CRABB_DEV__Importo_Saldo_26__c, CRABB_DEV__Importo_Saldo_27__c, CRABB_DEV__Importo_Saldo_28__c,
                CRABB_DEV__Importo_Saldo_29__c, CRABB_DEV__Importo_Saldo_2__c, CRABB_DEV__Importo_Saldo_30__c, CRABB_DEV__Importo_Saldo_31__c, CRABB_DEV__Importo_Saldo_3__c, CRABB_DEV__Importo_Saldo_4__c,
                CRABB_DEV__Importo_Saldo_5__c, CRABB_DEV__Importo_Saldo_6__c, CRABB_DEV__Importo_Saldo_7__c, CRABB_DEV__Importo_Saldo_8__c, CRABB_DEV__Importo_Saldo_9__c, CRABB_DEV__Importo__c, CRABB_DEV__Incasso__c,
                CRABB_DEV__IsFutureContext__c, CRABB_DEV__Mese_Precedente__c, CRABB_DEV__Mese__c, CRABB_DEV__Pratica__c, CRABB_DEV__RecordType__c, CRABB_DEV__Redisuo__c, CRABB_DEV__Residuo__c, CRABB_DEV__Riconciliazione__c,
                CRABB_DEV__Ritardo_Pagamento__c, CRABB_DEV__Ritardo__c, CRABB_DEV__SALDO_ANNO_LAVORATO__c, CRABB_DEV__SALDO_ANNO__c, CRABB_DEV__Saldo_Corrente__c, CRABB_DEV__Saldo_Mese_Precedente_Data__c,
                CRABB_DEV__Saldo_Mese_Precedente__c, CRABB_DEV__Saldo_Spese_10__c, CRABB_DEV__Saldo_Spese_11__c, CRABB_DEV__Saldo_Spese_12__c, CRABB_DEV__Saldo_Spese_13__c, CRABB_DEV__Saldo_Spese_14__c, CRABB_DEV__Saldo_Spese_15__c,
                CRABB_DEV__Saldo_Spese_16__c, CRABB_DEV__Saldo_Spese_17__c, CRABB_DEV__Saldo_Spese_18__c, CRABB_DEV__Saldo_Spese_19__c, CRABB_DEV__Saldo_Spese_1__c, CRABB_DEV__Saldo_Spese_20__c, CRABB_DEV__Saldo_Spese_21__c, CRABB_DEV__Saldo_Spese_22__c,
                CRABB_DEV__Saldo_Spese_23__c, CRABB_DEV__Saldo_Spese_24__c, CRABB_DEV__Saldo_Spese_25__c, CRABB_DEV__Saldo_Spese_26__c, CRABB_DEV__Saldo_Spese_27__c, CRABB_DEV__Saldo_Spese_28__c, CRABB_DEV__Saldo_Spese_29__c, CRABB_DEV__Saldo_Spese_2__c,
                CRABB_DEV__Saldo_Spese_30__c, CRABB_DEV__Saldo_Spese_31__c, CRABB_DEV__Saldo_Spese_3__c, CRABB_DEV__Saldo_Spese_4__c, CRABB_DEV__Saldo_Spese_5__c, CRABB_DEV__Saldo_Spese_6__c, CRABB_DEV__Saldo_Spese_7__c, CRABB_DEV__Saldo_Spese_8__c,
                CRABB_DEV__Saldo_Spese_9__c, CRABB_DEV__Saldo_Spese_Mese_Precedente__c, CRABB_DEV__Saldo_Spese__c, CRABB_DEV__Saldo__c, CRABB_DEV__Saldo_anno_calcolato__c, CRABB_DEV__Scaduto_Saldo_10__c, CRABB_DEV__Scaduto_Saldo_11__c, CRABB_DEV__Scaduto_Saldo_12__c,
                CRABB_DEV__Scaduto_Saldo_13__c, CRABB_DEV__Scaduto_Saldo_14__c, CRABB_DEV__Scaduto_Saldo_15__c, CRABB_DEV__Scaduto_Saldo_16__c, CRABB_DEV__Scaduto_Saldo_17__c, CRABB_DEV__Scaduto_Saldo_18__c, CRABB_DEV__Scaduto_Saldo_19__c, CRABB_DEV__Scaduto_Saldo_1__c,
                CRABB_DEV__Scaduto_Saldo_20__c, CRABB_DEV__Scaduto_Saldo_21__c, CRABB_DEV__Scaduto_Saldo_22__c, CRABB_DEV__Scaduto_Saldo_23__c, CRABB_DEV__Scaduto_Saldo_24__c, CRABB_DEV__Scaduto_Saldo_25__c, CRABB_DEV__Scaduto_Saldo_26__c, CRABB_DEV__Scaduto_Saldo_27__c,
                CRABB_DEV__Scaduto_Saldo_28__c, CRABB_DEV__Scaduto_Saldo_29__c, CRABB_DEV__Scaduto_Saldo_2__c, CRABB_DEV__Scaduto_Saldo_30__c, CRABB_DEV__Scaduto_Saldo_31__c, CRABB_DEV__Scaduto_Saldo_3__c, CRABB_DEV__Scaduto_Saldo_4__c, CRABB_DEV__Scaduto_Saldo_5__c,
                CRABB_DEV__Scaduto_Saldo_6__c, CRABB_DEV__Scaduto_Saldo_7__c, CRABB_DEV__Scaduto_Saldo_8__c, CRABB_DEV__Scaduto_Saldo_9__c, CRABB_DEV__Servizio_Fornitura__c, CRABB_DEV__Servizio_Item__c, CRABB_DEV__Sollecitabile__c, CRABB_DEV__Stato_Pratica__c,
                CRABB_DEV__Stato_Pratiica_Picklist__c, CRABB_DEV__Tipo_Movimento_SWH_10__c, CRABB_DEV__Tipo_Movimento_SWH_11__c, CRABB_DEV__Tipo_Movimento_SWH_12__c, CRABB_DEV__Tipo_Movimento_SWH_13__c, CRABB_DEV__Tipo_Movimento_SWH_14__c, CRABB_DEV__Tipo_Movimento_SWH_15__c,
                CRABB_DEV__Tipo_Movimento_SWH_16__c, CRABB_DEV__Tipo_Movimento_SWH_17__c, CRABB_DEV__Tipo_Movimento_SWH_18__c, CRABB_DEV__Tipo_Movimento_SWH_19__c, CRABB_DEV__Tipo_Movimento_SWH_1__c, CRABB_DEV__Tipo_Movimento_SWH_20__c, CRABB_DEV__Tipo_Movimento_SWH_21__c,
                CRABB_DEV__Tipo_Movimento_SWH_22__c, CRABB_DEV__Tipo_Movimento_SWH_23__c, CRABB_DEV__Tipo_Movimento_SWH_24__c, CRABB_DEV__Tipo_Movimento_SWH_25__c, CRABB_DEV__Tipo_Movimento_SWH_26__c, CRABB_DEV__Tipo_Movimento_SWH_27__c, CRABB_DEV__Tipo_Movimento_SWH_28__c, CRABB_DEV__Tipo_Movimento_SWH_29__c, CRABB_DEV__Tipo_Movimento_SWH_2__c,
                CRABB_DEV__Tipo_Movimento_SWH_30__c, CRABB_DEV__Tipo_Movimento_SWH_31__c, CRABB_DEV__Tipo_Movimento_SWH_3__c, CRABB_DEV__Tipo_Movimento_SWH_4__c, CRABB_DEV__Tipo_Movimento_SWH_5__c, CRABB_DEV__Tipo_Movimento_SWH_6__c, CRABB_DEV__Tipo_Movimento_SWH_7__c,
                CRABB_DEV__Tipo_Movimento_SWH_8__c, CRABB_DEV__Tipo_Movimento_SWH_9__c, CRABB_DEV__Tipo_Movimento_SWH__c, CRABB_DEV__Tipo_Scadenza__c, CRABB_DEV__Tipo_Servizio__c, CRABB_DEV__Ultimo_Saldo_Fruitore_Consolidato__c, CRABB_DEV__Warning_Incassi__c,
                CRABB_DEV__Warning_Mese_Precedente__c, CRABB_DEV__Write_Off_10__c, CRABB_DEV__Write_Off_11__c, CRABB_DEV__Write_Off_12__c, CRABB_DEV__Write_Off_13__c, CRABB_DEV__Write_Off_14__c, CRABB_DEV__Write_Off_15__c, CRABB_DEV__Write_Off_16__c, CRABB_DEV__Write_Off_17__c,
                CRABB_DEV__Write_Off_18__c, CRABB_DEV__Write_Off_19__c, CRABB_DEV__Write_Off_1__c, CRABB_DEV__Write_Off_20__c, CRABB_DEV__Write_Off_21__c, CRABB_DEV__Write_Off_22__c, CRABB_DEV__Write_Off_23__c, CRABB_DEV__Write_Off_24__c, CRABB_DEV__Write_Off_25__c, CRABB_DEV__Write_Off_26__c,
                CRABB_DEV__Write_Off_27__c, CRABB_DEV__Write_Off_28__c, CRABB_DEV__Write_Off_29__c, CRABB_DEV__Write_Off_2__c, CRABB_DEV__Write_Off_30__c, CRABB_DEV__Write_Off_31__c, CRABB_DEV__Write_Off_3__c, CRABB_DEV__Write_Off_4__c, CRABB_DEV__Write_Off_5__c, CRABB_DEV__Write_Off_6__c,
                CRABB_DEV__Write_Off_7__c, CRABB_DEV__Write_Off_8__c, CRABB_DEV__Write_Off_9__c, CRABB_DEV__Write_Off__c, CRABB_DEV__numero_documento__c, CreatedById, CreatedDate, Id, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Name, RecordTypeId, SystemModstamp FROM CRABB_DEV__Movimento__c];
        */
        test.startTest();
        update lmov2;
        MovimentoHandler.GestisciLogiche(lmov2);
        test.stopTest();
    }

    static testmethod void testGestisciLogiche3(){
        Movimento__c m = getMovWithRCRDType('SALDO MESE'); 
        m.data_Scadenza__c = system.today();
        Movimento__c m1 = getMovWithRCRDType('INCASSO');
        List<Movimento__c> lmov2 = new List<Movimento__c>();
        lmov2.add(m);
        lmov2.add(m1);
        insert lmov2;
        List<Id> ids = new List<Id>();
        ids.add(m.Id);
        ids.add(m1.Id);
        String fields = CredManUtility.selectall('Movimento__c');
        String query = 'SELECT '+ fields + ' FROM CRABB_DEV__Movimento__c';
        lmov2= Database.query(query);
        //        lmov2 = [Select Data_Emissione__c, Data_Scadenza__c, Pratica__c, Account__c, RecordTypeId, RecordType__c,Mese_Precedente__c from Movimento__c];

        test.startTest();
        update lmov2;
        MovimentoHandler.GestisciLogiche(lmov2);
        test.stopTest();
    }  
   

    static testmethod void testGestisciLogiche(){
        // prepara movimenti
        List<Movimento__c> lmov = getMovimenti();
        //Database.insert(lmov,false);
        insert lmov;   
        test.startTest();
        MovimentoHandler.GestisciLogiche(lmov);
        test.stopTest();
    }
    
    static testmethod void testSetMyMap(){
        
    }
    
    static testmethod void testPopolaIdMesePrecedente(){
         // prepara movimenti
        List<Movimento__c> lmov = getMovimenti();
        //Database.insert(lmov,false);
        insert lmov;
        

        test.startTest();
        
        //Map<Id, Movimento__c> movMod = new  Map<Id, Movimento__c>(MovimentoHandler.incassiAffidamentoConnection(lmov));
        Set<Movimento__C> sMod = new Set<Movimento__C>(MovimentoHandler.incassiAffidamentoConnection(lmov));
        Map<Id, Movimento__c> movMod = new  Map<Id, Movimento__c>();
        //List<Movimento__C> lm = new List<Movimento__C>();
        //lm.addall(incassiAffidamentoConnection(mov));
        Map<Id, Movimento__c> movModTEmp =new  Map<Id, Movimento__c>(lmov); //(incassiAffidamentoConnection(mov));
        if(movModTEmp!=null && !movModTEmp.isempty()) 
            movMod.putAll(movModTemp);
        MovimentoHandler.PopolaIdMesePrecedente(lmov, movMod);
        test.stopTest();
        MovimentoHandler.GestisciLogiche(lmov);
    }
    
    // Metodi ausiliari
    public static List<Movimento__c> getMovimenti(){
        List<Movimento__c> lMov = new List<Movimento__c>();
        
        // prendi account & pratica
        Contratto__C con = TestClassFroDataGEnAffidamenti.getContratto();
        //insert con;
        Database.insert(con,false);
        
        Account ac = TestClassFroDataGEnAffidamenti.getAccount(con.Id);
        insert ac;
        Pratica__c p = TestClassFroDataGEnAffidamenti.getPratica(ac.Id);
        insert p;
        
        lmov.add(new Movimento__c(Account__c = ac.id, Pratica__C = p.id, Data_Emissione__c = System.today(), Data_Scadenza__c = System.today()));
        
        return lmov;
    }
    
    public static List<id> getMovimentiWithListID(){
        List<id> lMov = new List<id>();
        
        // prendi account & pratica
        Contratto__C con = TestClassFroDataGEnAffidamenti.getContratto();
        //insert con;
        Database.insert(con,false);
        
        Account ac = TestClassFroDataGEnAffidamenti.getAccount(con.Id);
        insert ac;
        Pratica__c p = TestClassFroDataGEnAffidamenti.getPratica(ac.Id);
        insert p;
        
        Movimento__c m = new Movimento__c(Account__c = ac.id, Pratica__C = p.id, Data_Emissione__c = System.today(), Data_Scadenza__c = System.today());
        insert m;
        lmov.add(m.id);
        
        return lmov;
    }
    
    public static Movimento__c getMovWithRCRDType(String recordNome){
        Movimento__c m = new Movimento__c();
        
        // prendi account & pratica
        Contratto__c con = TestClassFroDataGEnAffidamenti.getContratto();
        Database.insert(con, false);

        Account ac = TestClassFroDataGEnAffidamenti.getAccount(con.Id);
        insert ac;
        Pratica__c p = TestClassFroDataGEnAffidamenti.getPratica(ac.Id);
        insert p;
        
        m.Data_Emissione__c = System.today();
        m.Data_Scadenza__c = System.today();
        m.Pratica__c = p.id;
        m.Account__c = ac.id;
        Id idrt =  Schema.SObjectType.Movimento__c.getRecordTypeInfosByName().get(recordNome).getRecordTypeId();
        //m.RecordType = rt;
        m.RecordTypeId = idrt;
        //m.RecordType.name = recordType;
        //m.RecordTypeId = Schema.SObjectType.Movimento__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        //throw new TriggerFactory.TriggerException('Hey!:'+m.RecordType.name+'xxx:'+m.RecordTypeId);
        return m;
        
    }
}