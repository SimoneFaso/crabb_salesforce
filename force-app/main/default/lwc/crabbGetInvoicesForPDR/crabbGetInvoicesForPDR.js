/**
 * Created by gmame on 08/10/2021.
 */

import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getExpiredInvoices from '@salesforce/apex/CRABB_PDRCtrl.getExpiredInvoices';

const columns = [
      { label: 'Numero Documento', fieldName: 'CRABB_DEV__numero_documento__c', type: 'Text'},
      { label: 'Importo', fieldName: 'CRABB_DEV__Importo__c', type:'currency'},
      { label: 'Residuo', fieldName: 'CRABB_DEV__Residuo__c', type:'currency'},
      { label: 'Data Emissione', fieldName: 'CRABB_DEV__Data_Emissione__c' , type:'date'},
      { label: 'Data Scadenza', fieldName: 'CRABB_DEV__Data_Scadenza__c', type:'date'},];

export default class CrabbGetInvoicesForPdr extends LightningElement {


        @api recordId;
        @track praticaId = 'a0d09000000p9IGAAY';
        //@track praticaId = this.recordId;
        @track expiredInvoices = [];
        @track isEmpty = false;

        @wire(getExpiredInvoices, {praticaId : '$praticaId'}) invoicesList ({ data, error }) {

               console.log('Start Invoices WIRE Table');
               console.log('Pratica Id: ', this.praticaId);

               if (data) {
                   console.log(data);
                   console.log('Array lenght: ', data.length);

                   this.isEmpty = data.length == 0 ? true : false;
                   this.expiredInvoices = data;

                   console.log('Data from getExpiredInvoices' , JSON.stringify(data));

               } else if (error){
                   console.log('errore --> ', error);
               }
        }

}