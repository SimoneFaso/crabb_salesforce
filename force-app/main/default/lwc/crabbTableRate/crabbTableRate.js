/**
 * Created by Matteo on 10/06/2020.
 */

import { LightningElement , api , track , wire } from 'lwc';
import getRate from '@salesforce/apex/CRABB_PDRCtrl.getRate';
import changeStatoRata from '@salesforce/apex/CRABB_PDRCtrl.changeStatoRata';
import createAttachment_APEX from '@salesforce/apex/CRABB_PDRCtrl.createAttachment';
import getStatoMap from '@salesforce/apex/CRABB_PDRCtrl.getStatoMap';
import RATE_OBJECT from '@salesforce/schema/Rateizzazione__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import momentjs from '@salesforce/resourceUrl/moment';
import { loadScript } from 'lightning/platformResourceLoader';
import currencySymbol from '@salesforce/i18n/number.currencySymbol';
//test claudio Start
import showRepaymentPlanType from '@salesforce/apex/CRABB_PDRCtrl.showRepaymentPlanType';
//test claudio end

import expInt from '@salesforce/label/c.Expansion_Interests';
import intMora from '@salesforce/label/c.Interest_of_Mora';
import totRepPlan from '@salesforce/label/c.Total_Repayment_Plan';
import rp from '@salesforce/label/c.RP';
import stipDate from '@salesforce/label/c.Stipulated_Date';
import genPdf from '@salesforce/label/c.Generate_PDF';
import rataPagata from '@salesforce/label/c.RataPagata';
import rataDisattesa from '@salesforce/label/c.RataDisattesa';
import pagata from '@salesforce/label/c.Pagata';
import disattesa from '@salesforce/label/c.Disattesa';
//test claudio Start
import tipoRP from '@salesforce/label/c.Type';
//test claudio end
export default class CrabbTableRate extends LightningElement {

    label = {expInt,intMora,totRepPlan,rp,stipDate,genPdf,rataPagata,rataDisattesa,pagata,disattesa,tipoRP}

    @api praticaid;
    @track tableData;
    @track pdrId;
    @track CodePDR;
    @track totPDR;
    @track intMora;
    @track intDilazione;
    @track dataStipula;
    @track bPDF = false;
    //Claudio Start ---- aggiungere label
    @track typePDR;
    //Claudio End
    @track columns = [

    ];


    @track mapStato;

    //test claudio Start
    @track showTypeRP = false;

        @wire( showRepaymentPlanType)
        wireType({ error, data}){
            if(data){
                this.showTypeRP = true;
            }
            else {
                console.error(error);
                console.log('error - showRepaymentPlanType  ' + this.accountId);
            }
        }
    //test claudio End

    @wire (getStatoMap)
    mapStatoInfo({ data, error }) {
        if (data) {
            console.log(JSON.parse(data));
            let mapStatoLocal = new Map();
            for (const [key,value] of Object.entries(JSON.parse(data))) {
                   mapStatoLocal.set(key, value);
            }
            this.mapStato = mapStatoLocal;
        }
    }

    @wire(getObjectInfo, { objectApiName: RATE_OBJECT })
    rateizzazioneInfo ({ data, error }) {
        if (data) {
            console.log(data);
            this.columns = [
                { label: data.fields.CRABB_DEV__Data_Scadenza_Rata__c.label, fieldName: 'CRABB_DEV__Data_Scadenza_Rata__c' },
                { label: data.fields.CRABB_DEV__Importo_Rata__c.label, fieldName: 'CRABB_DEV__Importo_Rata__c', type:'currency'  },
                { label: data.fields.CRABB_DEV__Stato__c.label, fieldName: 'CRABB_DEV__Stato__c' } ,
                { type : 'button',fieldName:'RataDisattesa' , label : this.label.rataDisattesa ,  typeAttributes:
                        { label: this.label.rataDisattesa , name : 'RataDisattesaAction'  , disabled : { fieldName : 'disableRataDisattesa'}  }},
                { type : 'button' , fieldName : 'RataPagata', label : this.label.rataPagata,  typeAttributes:
                         { label: this.label.rataPagata ,name : 'RataPagataAction' , disabled : { fieldName : 'disableRataPagata'}   } }
            ];
        }
    }

    handleRowAction(event){
        console.log(' row action data ' , JSON.stringify(event.detail.row));
        console.log(' row action event ' , JSON.stringify(event.detail.action));
        switch (event.detail.action.name ) {
            case 'RataPagataAction':
            changeStatoRata({ rataid : event.detail.row.Id , stato : 'Pagata' }).then(( data ) => {
                console.log('data' , data)
                if(!data['errorMessage']){
                    this.retrieveRate();
                }
            });
            break;
            case 'RataDisattesaAction':
            changeStatoRata({ rataid : event.detail.row.Id , stato : 'Disattesa' }).then(( data ) => {
                console.log('data' , data)
                if(!data['errorMessage']){
                    this.retrieveRate();
                }
            });
            break;
        }
    }

    retrieveRate(){
        getRate({
            praticaid: this.praticaid
        })
        .then(( data ) => {
            this.tableData = [];
            console.log('data from getrate' , data);
            let rateData = [];
            for(var d of data){
                /*let disableRataDisattesa = ( d.CRABB_DEV__Stato__c == 'Disattesa'
                || ( d.CRABB_DEV__Stato__c == 'Nuova' && moment().diff(d.CRABB_DEV__Data_Scadenza_Rata__c , 'days') < 0 ) );*/
                let disableRataDisattesa = ( d.CRABB_DEV__Stato__c == this.mapStato.get('Disattesa'));
                /*let disableRataPagata = ( d.CRABB_DEV__Stato__c == 'Pagata'
                || ( d.CRABB_DEV__Stato__c == 'Nuova' && moment().diff(d.CRABB_DEV__Data_Scadenza_Rata__c , 'days') < 0 ) );*/
                let disableRataPagata = ( d.CRABB_DEV__Stato__c ==  this.mapStato.get('Pagata'));
//                disableRataDisattesa = false;
                rateData.push({
                    Id : d.Id ,
                    CRABB_DEV__Data_Scadenza_Rata__c : d.CRABB_DEV__Data_Scadenza_Rata__c ,
                    CRABB_DEV__Importo_Rata__c : d.CRABB_DEV__Importo_Rata__c ,
                    CRABB_DEV__Stato__c : d.CRABB_DEV__Stato__c ,
                    disableRataDisattesa :  disableRataDisattesa ,
                    disableRataPagata : disableRataPagata
                })
                this.pdrId = d.CRABB_DEV__Piano_di_Rientro__c;
                this.CodePDR = d.CRABB_DEV__Piano_di_Rientro__r.Name;
                //this.totPDR = d.CRABB_DEV__Piano_di_Rientro__r.CRABB_DEV__Importo_Totale__c;
                this.totPDR = d.CRABB_DEV__Piano_di_Rientro__r.CRABB_DEV__Importo_Totale__c +currencySymbol;
                this.intMora = d.CRABB_DEV__Piano_di_Rientro__r.CRABB_DEV__Interessi_di_Mora__c;
                this.intDilazione = d.CRABB_DEV__Piano_di_Rientro__r.CRABB_DEV__Interessi_di_Dilazione__c;
                this.dataStipula = d.CRABB_DEV__Piano_di_Rientro__r.CRABB_DEV__Data_Stipula_Piano__c;
                //Claudio Start
                console.log('type pdr pre' +this.typePDR);
                this.typePDR = d.CRABB_DEV__Piano_di_Rientro__r.CRABB_DEV__Type__c;
                console.log('type pdr post' +this.typePDR);
                //Claudio End
                console.log(this.totPDR);
            }
            console.log('table data', this.tableData);

            this.tableData = [...rateData];
        })
        .catch((error) => {
            console.error('Error received: code' + error.errorCode + ', ' +
                'message ' , error);
        });
    }

    connectedCallback(){
        Promise.all([
            loadScript(this, momentjs )
        ]).then(() => {
            console.log('momentjs loaded');
            this.retrieveRate();
        })
        .catch(error => {
            console.error(error);
        });
    }

    creaPDF()
    {
        createAttachment_APEX({
            pdrId : this.pdrId ,
            praticaId : this.praticaid
        })
        .then(() => {
            this.bPDF = true;
            console.log('attachment creato');
        })
        .catch((error) => {
            this.bPDF = false;
            console.log('Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message);

        });
    }

}