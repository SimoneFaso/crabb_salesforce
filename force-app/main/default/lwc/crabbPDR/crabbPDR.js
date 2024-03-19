/**
 * Created by MatteoSala on 29/05/2020.
 *
 * Modified by escam & ssala on 15/03/2021
 * Update PDR creation: add choice of instalments frequency
 * Modified 18/03/2021
 * Update PDR creation: handling the creation of a repayment plan from the account page
 * 28/12/2022 Update PDR creation: handling the Type, Reason and Custom Amount
 */

import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getFieldDisplayValue } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import TYPE_FIELD from '@salesforce/schema/Piano_di_Rientro__c.Type__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import RP_OBJECT from '@salesforce/schema/Piano_di_Rientro__c';
import showRepaymentPlanType from '@salesforce/apex/CRABB_PDRCtrl.showRepaymentPlanType';
import showRepaymentPlanReason from '@salesforce/apex/CRABB_PDRCtrl.showReason';
import showCustomAmount from '@salesforce/apex/CRABB_PDRCtrl.showCustomAmount';
import createPDR_APEX from '@salesforce/apex/CRABB_PDRCtrl.CreatePDR';
import createAttachment_APEX from '@salesforce/apex/CRABB_PDRCtrl.createAttachment';
import getPDR from '@salesforce/apex/CRABB_PDRCtrl.ExistPDR';
import getPraticaId from '@salesforce/apex/CRABB_PDRCtrl.getPraticaId';
import getPraticheAccount from '@salesforce/apex/CRABB_PDRCtrl.ExistPratica';
import currencySymbol from '@salesforce/i18n/number.currencySymbol';

import nopdr from '@salesforce/label/c.NoPDR';
import nopdr2 from '@salesforce/label/c.NoPDR2';
import newPdr from '@salesforce/label/c.newPdr';
import repPlan from '@salesforce/label/c.Repayment_Plan';
import next from '@salesforce/label/c.Next';
import previous from '@salesforce/label/c.Previous';
import setPdR from '@salesforce/label/c.Set_PdR';
import installment from '@salesforce/label/c.Installment';
import confirmation from '@salesforce/label/c.Confirmation';
import outcome from '@salesforce/label/c.Outcome';
import setRP from '@salesforce/label/c.Set_RP';
import insTotAmount from '@salesforce/label/c.Total_Installments_Amount';
import choTotAmount from '@salesforce/label/c.Choose_Total_Amount';
import instalTotAmo from '@salesforce/label/c.Installments_Total_Amount';
import numOfInsta from '@salesforce/label/c.Number_of_Installments';
import firstInstalDate from '@salesforce/label/c.First_Installmet_Date';
import insNumInstal from '@salesforce/label/c.Insert_Number_of_Installments';
import InstalAmount from '@salesforce/label/c.Installment_Amount';
import insInsAmo from '@salesforce/label/c.Insert_Intallment_Amount';
import intCalculator from '@salesforce/label/c.Interest_Calculator';
import expInt from '@salesforce/label/c.Expansion_Interests';
import intMora from '@salesforce/label/c.Interest_of_Mora';
import instNum from '@salesforce/label/c.Installments_Number';
import totRepPlan from '@salesforce/label/c.Total_Repayment_Plan';
import totInt from '@salesforce/label/c.Total_Interests';
import confRepPlan from '@salesforce/label/c.Confirmation_Repayment_Plan';
import progress from '@salesforce/label/c.Progress';
import practise from '@salesforce/label/c.Practise';
import scaduto from '@salesforce/label/c.Scaduto';
import calInt from '@salesforce/label/c.Calculate_Interest';
import pickInt from '@salesforce/label/c.PDR_Picklist_Interessi';
import Prima_Rata from '@salesforce/label/c.Prima_Rata';
import Tutte_Rate from '@salesforce/label/c.Tutte_le_Rate';
import Ultima_Rata from '@salesforce/label/c.Ultima_Rata';
import account from '@salesforce/label/c.Account';
import pratica from '@salesforce/label/c.Pratica';
import PDRsuccessMessage from '@salesforce/label/c.PDRsuccessMessage';
import backToDossier from '@salesforce/label/c.BackToDossier';
import backToAccount from '@salesforce/label/c.backToAccount';
import dataRata from '@salesforce/label/c.DataRata';
import importoRata from '@salesforce/label/c.ImportoRata';
import freqRata from '@salesforce/label/c.Instalment_frequency';
import weekly from '@salesforce/label/c.Weekly';
import monthly from '@salesforce/label/c.Monthly';
import applyInterest from '@salesforce/label/c.Apply_interest';
import createPdrRequirement from '@salesforce/label/c.Create_Prd_Requirement';
import tipoRP from '@salesforce/label/c.Type';
import rp from '@salesforce/label/c.RP';
//modifica per inserimento
import getExpiredInvoices from '@salesforce/apex/CRABB_PDRCtrl.getExpiredInvoices';


/*
import PRATICA_OBJECT from '@salesforce/schema/Pratica__c';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import PRATICA_FIELD from '@salesforce/schema/Pratica__c.Name';
import STATO_FIELD from '@salesforce/schema/Pratica__c.Stato__c';
import SCADUTO_ACC_FIELD from '@salesforce/schema/Pratica__c.Account__r.Saldo_Movimenti_Scaduti__c';
*/

const fields = ['CRABB_DEV__Pratica__c.Name','CRABB_DEV__Pratica__c.CRABB_DEV__Account__r.Name','CRABB_DEV__Pratica__c.CRABB_DEV__Stato__c','CRABB_DEV__Pratica__c.CRABB_DEV__Residuo_Totale__c','CRABB_DEV__Pratica__c.CRABB_DEV__Account__r.CRABB_DEV__Saldo_Movimenti_Scaduti__c',
              //Test Claudio Start
              'CRABB_DEV__Pratica__c.CRABB_DEV__Saldo_Totale__c'];
              //Test Claudio End

const actions = [
    { label: 'Show details', name: 'show_details' },
    { label: 'Delete', name: 'delete' }
];

const COLS = [
    //{ label: 'Id', fieldName: 'Id', editable: true, type: 'number'},
    { label: dataRata, fieldName: 'Data_Rata', editable: true, type: 'date'},
    //{ label: importoRata, fieldName: 'Importo_Rata', editable: true,  type: 'currency', typeAttributes: { currencyCode: 'EUR'}, cellAttributes: { alignment: 'left' } },
    { label: importoRata, fieldName: 'Importo_Rata', editable: true,  type: 'currency', typeAttributes: { currency: currencySymbol}, cellAttributes: { alignment: 'left' } },
    { type:  'button', typeAttributes: {
        iconName: 'action:delete',
        label: 'Delete',
        name: 'delete',
        title: 'delete',
        disabled: false,
        value: 'test'
      }, cellAttributes: { alignment: 'center' }
    }
    ];

const frequency = [{ label: monthly, value: 'monthly' },
                   { label: weekly, value: 'weekly' }]

 // Modifica per inserimento transactions-> pdr
const transactionColumns = [
      { label: 'Numero Documento', fieldName: 'CRABB_DEV__numero_documento__c', type: 'Text'},
      { label: 'Importo', fieldName: 'CRABB_DEV__Importo__c', type:'currency'},
      { label: 'Residuo', fieldName: 'CRABB_DEV__Residuo__c', type:'currency'},
      { label: 'Data Emissione', fieldName: 'CRABB_DEV__Data_Emissione__c' , type:'date'},
      { label: 'Data Scadenza', fieldName: 'CRABB_DEV__Data_Scadenza__c', type:'date'},];

export default class CrabbPdr extends NavigationMixin(LightningElement){

    label = {nopdr,nopdr2,newPdr,repPlan,previous,next,setPdR,installment,confirmation,outcome,setRP,insTotAmount,choTotAmount,
            instalTotAmo,numOfInsta,firstInstalDate,insNumInstal,InstalAmount,insInsAmo,intCalculator,expInt,intMora,instNum,totRepPlan,
            totInt,confRepPlan,progress,practise,scaduto,calInt,pickInt,Prima_Rata,Tutte_Rate,Ultima_Rata,account,pratica,PDRsuccessMessage,backToDossier,
            backToAccount,freqRata,applyInterest,createPdrRequirement,tipoRP,rp};

    @api objectApiName;
    @api recordId;
    @track praticaId;
    @track accountId;
    @track isPratica;
    @track isTransactions;
    @track openDossier = false;
    @track expiredInvoices = [];
    /*@track selectedTransactions = [];*/
    @track isEmpty = false;

    @wire(getPraticaId,  {recordId : '$recordId' })
    objectPratica({error, data}) {

        if (data) {
            this.praticaId = data;
            if(this.praticaId == this.recordId){
                this.isPratica = true;
                this.openDossier = true;
            }else {
                //we are creating a PDR from an Account page
                this.isPratica = false;
                this.accountId = this.recordId;
            }
            console.log('praticaID ' + this.praticaId);
            console.log('is this obj type Pratica?  ' + this.isPratica);
        } else if (error) {
            console.log('data ', data);
            console.log(error);
        }
    }

    //return true if exist active dossier related to the current account
    @wire( getPraticheAccount , {accId : '$accountId', checkPratica : '$isPratica'} )
    wirePratiche({ error, data}){

        if(data){
            console.log('This account has one or more active dossiers associated: ',  data);
            this.bCreaPDR = false;
            this.bPDR = false;
            this.BStep0 = true;
            this.openDossier = true;
        }
        else if (error){
            console.error(error);
            console.log('Id account in error ' + this.accountId);
            this.bPDR = false;
        } else {
            console.log('You can\'t create other PDR. This account hasn\'t active dossiers associated: ' + this.accountId);
        }
    }

    //return a dossier to manage the creation od PDR
    //if we are in an account page, return the older open dossier related to that account
    @wire(getRecord, { recordId: '$praticaId', fields })
    pratica;

    get scaduto() {
        if(this.selectedImporto == '' || this.selectedImporto == null)
        {
            this.selectedImporto = getFieldValue(this.pratica.data, 'CRABB_DEV__Pratica__c.CRABB_DEV__Residuo_Totale__c');
            return this.selectedImporto;
        }
        else
            return getFieldValue(this.pratica.data, 'CRABB_DEV__Pratica__c.CRABB_DEV__Residuo_Totale__c');
    }

    get scadutoAcc() {
        return getFieldValue(this.pratica.data, 'CRABB_DEV__Pratica__c.CRABB_DEV__Account__r.CRABB_DEV__Saldo_Movimenti_Scaduti__c');
    }

    //Get Custom RP Amount from Dossier
    get scadutoCustom() {
            return getFieldValue(this.pratica.data, 'CRABB_DEV__Pratica__c.CRABB_DEV__Saldo_Totale__c');
        }

    get praticaName() {
        return getFieldValue(this.pratica.data, 'CRABB_DEV__Pratica__c.Name');
    }

    get accountName() {
        return getFieldValue(this.pratica.data, 'CRABB_DEV__Pratica__c.CRABB_DEV__Account__r.Name');
    }

    get statoPratica()
    {
        return getFieldDisplayValue(this.pratica.data, 'CRABB_DEV__Pratica__c.CRABB_DEV__Stato__c');
    }

    @track bPDR = false;
    @track bCreaPDR = false;
    @track BStep0 = false;
    @track BStep1 = false;
    @track BStep2 = false;
    @track BStep3 = false;
    @track BStep4 = false;
    @track BStep5 = false;
    @track bNext = false;
    @track bPrev = false;
    @track currentStep = "0";
    @track selectedImporto;
    @track selectedImportoMovimento;
    @track selectedFrequency = 'monthly';
    @track options = [];
    @track optionsFreq = frequency;
    //@track b1Checked = true;
    //@track b2Checked = true;
    @track calcInt = false;
    @track dPR;
    @track numRate;
    @track impRate;
    @track intMora = "0.0";
    @track intDilazione = "0.0";
    @track totInt = 0;
    @track totPDR = 0;
    @track columns = COLS;
    @track transactionColumns = transactionColumns;
    @track draftRate = [];
    @track uiRate = [];
    @track updRate = [];
    @track finalMessage = '';
    @track optionValues = [];
    @track selectedValues = 2;

    //Repayment Plan Type, Reason and Custom Amount from Dossier
    @track typeRP;
    @track showTypeRP = false;
    @track showAmount = false;
    @track showReason = false;
    @track reason;

    @wire(showCustomAmount)
        wireAmount({ error, data}){
            if(data){
                this.showAmount = true;
            } else {
                console.log('RP Custom Amount - Custom Setting False');
            }
        }

    @wire(showRepaymentPlanReason)
        wireReason({ error, data}){
            if(data){
                this.showReason = true;
            } else {
                console.log('RP Reason - Custom Setting False');
            }
        }

    @wire(showRepaymentPlanType)
    wireType({ error, data}){
        if(data){
            this.showTypeRP = true;
        }
        else {
            //console.error(error);
            console.log('RP Type - Custom Setting False');
        }
    }


/*    /*//*//*test claudio Start

        //test claudio End*/

/*    .then(result => {
    this.showTypeRP = result;
    })
    }*/

    @wire(getObjectInfo, { objectApiName: RP_OBJECT })
    objectInfo;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: TYPE_FIELD})
    wireTypeValues({ error, data}){
            if(data){
                this.typeValues = data.values;
            }
            else {

                console.log('error - getPicklistValues for RPType ' + this.error);
            }
        }


    //Claudio End

    today = new Date();
    lastDOTM = new Date(this.today.getFullYear(), this.today.getMonth()+1, 0);
    TM = this.lastDOTM.getMonth()+1;
    //console.log(TM);

    //set the first instalment date the next week of the PDR creation
    weeklyPR = new Date(this.today.setDate(this.today.getDate() + 7));

    @wire( getPDR , {praticaid : '$praticaId'} )
    wiredPDR({ error, data }){

        if(data){
            console.log(data);
            console.log('Id pratica ' + this.praticaId);
            this.bCreaPDR = false;
            this.bPDR = true;
            this.BStep0 = true;
        }
        else if (error){
            console.error(error);
            console.log('Id pratica in error ' + this.praticaId);
            this.bPDR = false;
        } else {
            console.log('Id pratica in else ' + this.praticaId);
        }
    }



    createPDR(){

        console.log('createPDR - PRE: ' + this.bCreaPDR);
        this.bCreaPDR = true;
        console.log('createPDR - POST: ' + this.bCreaPDR);
        this.optionValues.push({label : this.label.Prima_Rata, value : 0});
        this.optionValues.push({label : this.label.Tutte_Rate, value : 1});
        this.optionValues.push({label : this.label.Ultima_Rata, value : 2});
        console.log('optionValues: ' + this.optionValues);
        this.handleNext();
    }

    get disableRitornaPratica(){
        return this.finalMessage ? false : true;
    }

    get disableRitornaAccount(){
            return this.finalMessage ? false : true;
    }



    handlePrev(){
        switch (this.currentStep) {
            case "0":
                this.currentStep = "0";
                this.BStep0 = true;
                this.BStep1 = false;
                this.BStep2 = false;
                this.BStep3 = false;
                this.BStep4 = false;
                this.BStep5 = false;
                this.bNext = false;
                this.bPrev = false;
                break;
            case "1":
                this.currentStep = "0";
                this.BStep0 = true;
                this.BStep1 = false;
                this.BStep2 = false;
                this.BStep3 = false;
                this.BStep4 = false;
                this.BStep5 = false;
                this.bNext = false;
                this.bPrev = false;
                break;
            case "2":
                this.currentStep ="1";
                this.BStep0 = false;
                this.BStep1 = true;
                this.BStep2 = false;
                this.BStep3 = false;
                this.BStep4 = false;
                this.BStep5 = false;
                this.bNext = true;
                this.bPrev = false;
                break;
            case "3":
                this.currentStep = "2";
                this.BStep0 = false;
                this.BStep1 = false;
                this.BStep2 = true;
                this.BStep3 = false;
                this.BStep4 = false;
                this.BStep5 = false;
                this.bNext = true;
                this.bPrev = true;
                break;
            case "4":
                this.currentStep = "3";
                this.BStep0 = false;
                this.BStep1 = false;
                this.BStep2 = false;
                this.BStep3 = true;
                this.BStep4 = false;
                this.BStep5 = false;
                this.bNext = false;
                this.bPrev = true;
                break;
            default:
                this.currentStep = "0";
                this.BStep0 = true;
                this.BStep1 = false;
                this.BStep2 = false;
                this.BStep3 = false;
                this.BStep4 = false;
                this.BStep5 = false;
                this.bNext = false;
                this.bPrev = false;
            break;
        }
        console.log('>>>this.currentStep: ' + this.currentStep);
        console.log('BStep0 = ' + this.BStep0);
        console.log('BStep1 = ' + this.BStep1);
        console.log('BStep2 = ' + this.BStep2);
        console.log('BStep3 = ' + this.BStep3);
        console.log('BStep4 = ' + this.BStep4);
        console.log('BStep5 = ' + this.BStep5);
    }

    handleNext(){
        //console.log('>>>handleNext in mergeDuplicates.js called.');
        console.log('>>>this.currentStep: ' + this.currentStep);
        switch (this.currentStep) {
            case "0":
                this.currentStep ="1";
                this.BStep0 = false;
                this.BStep1 = true;
                this.BStep2 = false;
                this.BStep3 = false;
                this.BStep4 = false;
                this.BStep5 = false;
                this.bNext = true;
                this.bPrev = false;
                console.log('############## pratica info: '+ this.fields);

                /* default date if the user doesn't choose a different date in the calendar and leaves the monthly frequency
                 * last day of the current month */
                this.dPR = this.lastDOTM.getFullYear() + '-' + this.TM + '-' + this.lastDOTM.getDate();
                console.log(this.dPR);

                let optionsValues = [];
                if(this.isPratica){
                    optionsValues.push({
                        //label: this.label.pratica + ': ' + this.scaduto +'€',
                        label: this.label.pratica + ': ' + this.scaduto +currencySymbol,
                        value: this.scaduto
                    })


                }
                //modificato per spostamento checkbox
                optionsValues.push({
                                     label: 'Transaction',
                                     value: 'Transaction'
                               })

                optionsValues.push({
                    //label: this.label.account + ': '+ this.scadutoAcc +'€',
                    label: this.label.account + ': '+ this.scadutoAcc +currencySymbol,
                    value: this.scadutoAcc
                })
                //Test Claudio Start


                console.log('TESTTTT' + this.showAmount);
                if(this.showAmount) {
                    optionsValues.push({
                                                        //label: this.label.account + ': '+ this.scadutoAcc +'€',
                                                        label: 'Test Claudio - custom amount: '+ this.scadutoCustom +currencySymbol,
                                                        value: this.scadutoCustom
                                                    })
                }

                //Test Claudio End

                this.options = optionsValues;
                this.selectedImporto = this.scadutoAcc;
                break;
            case "1":
                this.currentStep ="2";
                this.BStep0 = false;
                this.BStep1 = false;
                this.BStep2 = true;
                this.BStep3 = false;
                this.BStep4 = false;
                this.BStep5 = false;
                this.bNext = true;
                this.bPrev = true;
                this.columns = COLS;
                this.createRateizzazione();
                console.log(this.impRate + ' - ' + this.numRate + ' - ' + this.dPR);
                break;
            case "2":
                this.currentStep = "3";
                this.BStep0 = false;
                this.BStep1 = false;
                this.BStep2 = false;
                this.BStep3 = true;
                this.BStep4 = false;
                this.BStep5 = false;
                this.bNext = false;
                this.bPrev = true;
                break;
            case "3":
                this.currentStep = "4";
                this.BStep0 = false;
                this.BStep1 = false;
                this.BStep2 = false;
                this.BStep3 = false;
                this.BStep4 = true;
                this.BStep5 = false;
                this.bNext = false;
                this.bPrev = false;
                break;
            case "4":
                this.currentStep = "5";
                this.BStep0 = false;
                this.BStep1 = false;
                this.BStep2 = false;
                this.BStep3 = false;
                this.BStep4 = false;
                this.BStep5 = true;
                this.bNext = false;
                this.bPrev = false;
                break;
            default:
                this.currentStep = "0";
                this.BStep0 = true;
                this.BStep1 = false;
                this.BStep2 = false;
                this.BStep3 = false;
                this.BStep4 = false;
                this.BStep5 = false;
                this.bNext = false;
                this.bPrev = false;
            break;
        }
        console.log('>>>this.currentStep: ' + this.currentStep);
        console.log('BStep0 = ' + this.BStep0);
        console.log('BStep1 = ' + this.BStep1);
        console.log('BStep2 = ' + this.BStep2);
        console.log('BStep3 = ' + this.BStep3);
        console.log('BStep4 = ' + this.BStep4);
        console.log('BStep5 = ' + this.BStep5);
    }

    handleChangeInt(event)
    {
        this.calcInt = event.target.checked;
        this.intMora = "0.0";
        this.intDilazione = "0.0";
    }

    //Test claudio Start
     handleChangeType(event)
     {
            this.typeRP = event.target.value;
     }

     handleChangeReason(event)
          {
                 this.reason = event.target.value;
          }
    //Test claudio End

    handleChangeDPR(event)
    {
        this.dPR = event.target.value;
        console.log('date ' + this.dPR);
    }

    handleChangeNR(event)
    {
        this.numRate = event.target.value;
        this.impRate = 0;
    }

    handleChangeIR(event)
    {
        this.impRate = event.target.value;
        this.numRate = 0;
    }

    handleChangeIM(event)
    {
        this.intMora = event.target.value;
        console.log('Interessi di mora = ' + this.intMora);
    }

    handleChangeID(event)
    {
        this.intDilazione = event.target.value;
        console.log('Interessi di dilazione = ' + this.intDilazione);
    }

    createRateizzazione(){
        /*let parameterObject = {
            Pratica: this.recordId,
            Num_Rate: this.numRate,
            Int_Mora: this.intMora,
            Int_Dilazione: this.intDilazione,
            Calcolo_Int: this.calcInt,
            ListRate: []
        };*/
        let nr = parseInt(this.numRate);
        let ir = parseFloat(this.impRate);
        console.log('NR precheck: ' + nr);
        console.log('IR precheck: ' + ir);
        if(Number.isNaN(nr) && Number.isNaN(ir))
        {
            nr = 3;
            ir = 0;
            this.numRate = 3;
            this.impRate = 0;
        }
        console.log('NR postcheck: ' + nr);
        console.log('IR postcheck: ' + ir);
        console.log(this.selectedImporto);
        var remainder = 0;
        if(nr > 0)
        {
            //this.impRate = Math.floor(this.scaduto / nr);
            this.impRate = Math.floor(this.selectedImporto / nr);
            //remainder = this.scaduto % nr;
            remainder = this.selectedImporto % nr;
            console.log('Importo Rata: ' + this.impRate);
            console.log('Residuo Rata: ' + remainder);
        }
        else if(ir > 0)
        {
            //this.numRate = Math.floor(this.scaduto / ir);
            this.numRate = Math.floor(this.selectedImporto / ir);
            //var remainder = this.scaduto % ir;
            var remainder = this.selectedImporto % ir;
            console.log('Numero Rate: ' + this.numRate);
            //remainder = this.scaduto % ir;
            console.log('Residuo Rata: ' + remainder);
            //remainder = Math.round((remainder + Number.EPSILON) * 100) / 100;
            remainder = parseFloat(remainder.toFixed(2));
            console.log('Residuo Rata: ' + remainder);
        }
        else
        {
            nr = 3;
            //this.impRate = Math.floor(this.scaduto / nr);
            this.impRate = Math.floor(this.selectedImporto / nr);
            //remainder = this.scaduto % nr;
            remainder = this.selectedImporto % nr;
            console.log('Importo Rata: ' + this.impRate);
            console.log('Residuo Rata: ' + remainder);
        }

        // Populating a list
        /* date we receive from the previous step due to the default setting or the user's choice of a different frequency
         * or the manual setting of a date in the calendar */
        console.log('dPR: ' + this.dPR);
        let res = this.dPR.split("-");
        console.log('res '+ res);
        // converting the actual month (es. Apr is the 4th month) with the corresponding month index (Jan is 0 -> Dec is 11)
        let monthIndex = res[1]-1;

        //storing the date to set for the payment of the first instalment
        let data_Prox_Rata = new Date(res[0],monthIndex,res[2]);
        console.log('First instalment date: '+ data_Prox_Rata);

        //**** CALCOLO INTERESSI ****
        if(this.calcInt)
        {
            //this.totInt = (this.scaduto*this.intMora)+(this.scaduto*this.intDilazione);
            this.totInt = (this.selectedImporto*this.intMora/100)+(this.selectedImporto*this.intDilazione/100);
            this.totInt = parseFloat(this.totInt.toFixed(2));

        }
        this.draftRate = [];
        console.log('selectedValues: ' + this.selectedValues);
        var newDate;

        //**** INSERIMENTO RATE ****
        for (let i = 0; i < this.numRate; i++){
            var importoRata = 0;

            if(i == 0){

                //FIRST INSTALMENT
                data_Prox_Rata = new Date(data_Prox_Rata);
                importoRata = parseFloat(this.impRate);
                if(this.selectedValues === 0){
                    importoRata += this.totInt;
                } else if(this.selectedValues === 1){
                    importoRata += parseFloat((this.totInt/this.numRate).toFixed(2));
                }

            }else if(i == (this.numRate-1) ){

                //LAST INSTALMENT
                data_Prox_Rata = this.selectedFrequency == 'monthly'? new Date(data_Prox_Rata.getFullYear(),data_Prox_Rata.getMonth()+2,0) : new Date(data_Prox_Rata.setDate(data_Prox_Rata.getDate() + 7));
                importoRata = parseFloat(this.impRate) + remainder;
                if(this.selectedValues === 2){
                    importoRata += this.totInt;
                } else if(this.selectedValues === 1){
                    importoRata += parseFloat((this.totInt/this.numRate).toFixed(2));
                }

            }else {

                //MIDDLE INSTALMENTS
                //Date calculation: Monthly -> last day of the next month OR Weekly -> next week (+7 days)
                data_Prox_Rata = this.selectedFrequency == 'monthly'? new Date(data_Prox_Rata.getFullYear(),data_Prox_Rata.getMonth()+2,0) : new Date(data_Prox_Rata.setDate(data_Prox_Rata.getDate() + 7));
                importoRata = parseFloat(this.impRate);
                if(this.selectedValues === 1){
                    importoRata += parseFloat((this.totInt/this.numRate).toFixed(2));
                }
            }

            console.log('data rata #' + i + ' :' + data_Prox_Rata);

            this.draftRate.push({
                Id: i,
                Data_Rata: new Date(data_Prox_Rata),
                Importo_Rata: importoRata
            });

        }
        this.RecalcTot();
        this.uiRate = JSON.parse(JSON.stringify(this.draftRate));
        //console.log(parameterObject);
    }

    handleNewRata()
    {
        var i = parseInt(this.numRate)-1;
        console.log(i);
        console.log(this.draftRate[i]);
        console.log(this.draftRate[i].Data_Rata.getFullYear());

        var data_Prox_Rata = new Date(this.draftRate[i].Data_Rata);
        data_Prox_Rata = this.selectedFrequency == 'monthly'? new Date(data_Prox_Rata.getFullYear(),data_Prox_Rata.getMonth()+2,0) : new Date(data_Prox_Rata.setDate(data_Prox_Rata.getDate() + 7));

        this.draftRate.push({
            Id: this.numRate,
            Data_Rata: data_Prox_Rata,
            //data_Prox_Rata,//new Date(),
            Importo_Rata: 0
        });
        this.uiRate = JSON.parse(JSON.stringify(this.draftRate));
        //this.numRate = parseInt(this.numRate) + 1;
        this.RecalcTot();
        console.log('New Rata: ' + this.numRate);
        console.log('New Rata: ' + JSON.stringify(this.draftRate));
        console.log('New Rata: ' + JSON.stringify(this.updRate));
    }

    handleSave(event)
    {
        console.log(event.detail.draftValues);
        var dvlength = parseInt(event.detail.draftValues.length);
        console.log(event.detail.draftValues.length);
        console.log(dvlength);
        for(let i = 0; i < dvlength ; i++)
        {
            let draftId = event.detail.draftValues[i].Id;
            if(draftId == 'row-0')
                draftId = 0;
            console.log(draftId);
            console.log(event.detail.draftValues[i].Data_Rata);
            if(event.detail.draftValues[i].Data_Rata != null
                && event.detail.draftValues[i].Data_Rata != undefined
                && event.detail.draftValues[i].Data_Rata != '')
            {
                this.draftRate[draftId].Data_Rata = event.detail.draftValues[i].Data_Rata;
//                  this.draftRate[i].Data_Rata = event.detail.draftValues[i].Data_Rata;
            }
            console.log(event.detail.draftValues[i].Importo_Rata);
            if(event.detail.draftValues[i].Importo_Rata != null
                && event.detail.draftValues[i].Importo_Rata != undefined
                && event.detail.draftValues[i].Importo_Rata != '')
            {
                this.draftRate[draftId].Importo_Rata = event.detail.draftValues[i].Importo_Rata;
//                  this.draftRate[i].Importo_Rata = event.detail.draftValues[i].Importo_Rata;
            }
        }
        this.uiRate = JSON.parse(JSON.stringify(this.draftRate));
        this.RecalcTot();
        this.clearDraft();
        console.log('New Rata: ' + this.numRate);
        console.log('New Rata: ' + JSON.stringify(this.draftRate));
        console.log('New Rata: ' + JSON.stringify(this.uiRate));
    }

    handleRowAction(event)
    {
        console.log('New Rata: ' + this.numRate);
        console.log('New Rata: ' + JSON.stringify(this.draftRate));
        console.log('New Rata: ' + JSON.stringify(this.uiRate));

        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'show_details':
                alert('Showing Details: ' + JSON.stringify(row));
                break;
            case 'delete':
                console.log('DELETE - Start: ' + JSON.stringify(this.uiRate));
                const rows = this.draftRate;
                rows.splice(parseInt(row.Id), 1);
                this.draftRate = rows;
                var dvlength = parseInt(this.draftRate.length);
                for(let i = 0; i < dvlength ; i++)
                {
                    this.draftRate[i].Id = i;
                }
                this.uiRate = JSON.parse(JSON.stringify(this.draftRate));
                this.RecalcTot();

                break;
        }
    }

    clearDraft()
    {
       this.columns = [...this.columns];
    }

    RecalcTot()
    {
        var dvlength = parseInt(this.draftRate.length);
        //console.log(event.detail.draftValues.length);
        //console.log(dvlength);
        this.numRate = dvlength;
        this.totPDR = 0;
        for(let i = 0; i < dvlength ; i++)
        {
            this.totPDR += parseFloat(this.draftRate[i].Importo_Rata);
        }
    }

    handleConfirm()
    {
        let parameterObject = {
            //Pratica: this.recordId,
            Pratica: this.praticaId,
            Num_Rate: parseInt(this.numRate),
            Int_Mora: parseFloat(this.intMora),
            Int_Dilazione: parseFloat(this.intDilazione),
            Calcolo_Int: this.calcInt,
            Importo_Tot: this.totPDR,
            //Claudio Start
            Type: this.typeRP,
            Reason: this.reason,
            //Claudio End
            ListRate: []
        };
        parameterObject.ListRate = [...this.draftRate];
        console.log(parameterObject);
        createPDR_APEX({
            PDR_Structure: parameterObject
        })
        .then(( data ) => {
            console.log('OK');
            this.finalMessage = this.label.PDRsuccessMessage;
            createAttachment_APEX({
                pdrId : data.Id ,
                //praticaId : this.recordId
                praticaId: this.praticaId,
            })
            .then(() => {
                console.log('attachment creato');
            })
            .catch((error) => {
                console.log('Error received: code' + error.errorCode + ', ' +
                    'message ' + error.body.message);

            });
        })
        .catch((error) => {
            console.log('Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message);
            this.finalMessage = 'Error received: code' + error.errorCode + ', ' + 'message ' + error.body.message;
        });
        this.handleNext();
    }

    navigateToPraticaOrAccount() {
        // Navigate to a specific CustomTab.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                //recordId: this.praticaId,
                actionName: 'view'
            }
        });
    }

    // handle the selected value
    handleSelected(event)
    {
        console.log('selected importo start ===> '+this.selectedImporto);

        console.log('selected value ===> '+event.target.value);
       //MODIFICA PER INSERIMENTO TRANSACTION->PDR
        if(event.target.value == 'Transaction') {

       // @wire(getExpiredInvoices, {praticaId : '$praticaId'}) invoicesList ({ data, error }){
         
               console.log('Start Invoices WIRE Table');
               console.log('Pratica Id PRE: ', this.praticaId);

               getExpiredInvoices({ praticaId: this.praticaId})
                 .then(result =>{
                     this.expiredInvoices = result;
                     this.isTransactions = true;
                     console.log('Invoice Result', result);
                     console.log('this.expiredInvoices inside: ', JSON.stringify(this.expiredInvoices));
                 })
                 .catch(error =>{
                     /*this.errorMsg = error;*/
                     console.log('Start Invoices WIRE Table error', error);
                 });



               console.log('Pratica Id: ', this.praticaId);
               console.log('this.expiredInvoices: ', JSON.stringify(this.expiredInvoices));
               // LAVORARE SULL'ASSEGNAZIONE DEL VALORE DELLA SOMMA DEI MOV SELEZIONATI IN QUESTO IMPORTO this.selectedImporto =
               /*if (data) {
                   console.log(data);
                   console.log('Array lenght: ', data.length);

                   this.isEmpty = data.length == 0 ? true : false;
                   this.expiredInvoices = data;

                   console.log('Data from getExpiredInvoices' , JSON.stringify(data));

               } else if (error){
                   console.log('errore --> ', error);
               }*/
        }


        else{
            this.isTransactions = false;
             /*this.selectedTransactions = [];*/
             console.log('selectedTransactions --> ', this.selectedTransactions);
            this.selectedImporto = event.target.value;
            console.log('selected importo end ===> '+this.selectedImporto);
        }
    }

    //@track transactionamount = 0;
/*    handleTransactionSelection(event) {
            const selectedTransactions = event.detail.selectedRows;
            console.log('selectedTransactions --> ', selectedTransactions);
            console.log('this.selectedTransactions --> ', selectedTransactions.length);
            this.selectedImportoMovimento=0;
            for (let i = 0; i < selectedTransactions.length; i++){
                if(i == 0) {
                  this.selectedImportoMovimento =  selectedTransactions.[i].CRABB_DEV__Residuo__c;
                } else {
                   this.selectedImportoMovimento =  this.selectedImportoMovimento + selectedTransactions.[i].CRABB_DEV__Residuo__c;
                }
                 console.log('this.selectedImportoMovimento --> ', this.selectedImportoMovimento);
                 console.log('this.selectedTransactions.[i].CRABB_DEV__Residuo__c --> ', selectedTransactions.[i].CRABB_DEV__Residuo__c);
            }
            //transactionamount = transactionamount + selectedTransactions.CRABB_DEV__Importo__c;
            //console.log('transactionamount  --> ', transactionamount);
             *//*let myAmounts = [];
                       myAmounts.push(this.result[0].CRABB_DEV__Importo__c);
                       this.preSelectedRows = myAmounts;*//*

    }*/


    // handle the selected frequency value
    handleSelectedFreq(event)
    {
        console.log('selected freq start ===> '+this.selectedFrequency);
        console.log('selected value ===> '+event.target.value);
        this.selectedFrequency = event.target.value;
        console.log('selected freq end ===> '+this.selectedFrequency);

        if(this.selectedFrequency == 'monthly'){
            this.dPR = this.lastDOTM.getFullYear() + '-' + this.TM + '-' + this.lastDOTM.getDate();
            console.log(this.dPR);
        }else {
            let TMw = this.weeklyPR.getMonth()+1; //index of the month +1
            this.dPR = this.weeklyPR.getFullYear() + '-' + TMw + '-' + this.weeklyPR.getDate();
            console.log('durante la scelta della frequenza ' + this.dPR);
            console.log('weekly: ' + this.weeklyPR);

        }
    }

    handlePicklistChange(event)
    {
        console.log(event.target.value);
        console.log(this.selectedValues);
        this.selectedValues = parseInt(event.target.value);
        console.log(this.selectedValues);
    }

}