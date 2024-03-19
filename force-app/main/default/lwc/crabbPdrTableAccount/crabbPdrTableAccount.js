/**
 * Created by Matteo on 18/03/2021.
 *
 * escam & ssala on 18/03/2021: handling the creation of a repayment plan from the account page
 *
 */

import { LightningElement , api , track , wire } from 'lwc';
import getPDR from '@salesforce/apex/CRABB_PDRCtrl.ListPDRAccount';

import pdr from '@salesforce/label/c.PianoDiRientro';
import pratica from '@salesforce/label/c.Pratica';
import importoTotale from '@salesforce/label/c.Total_Repayment_Plan';
import dataUltimaRata from '@salesforce/label/c.Last_Instalment_Date';
import noActivePdr from '@salesforce/label/c.NoPDR';

const PRATICA = 'CRABB_DEV__Pratica__r';
const PRATICA_NAME = 'CRABB_DEV__Pratica__r.Name';

export default class CrabbPdrTableAccount extends LightningElement {

    @api accountid;
    @track columns = [];
    @track tableData = [];
    @track isEmpty = false;

    label = {pdr,pratica, importoTotale, dataUltimaRata, noActivePdr};

    @wire(getPDR, {accountid: '$accountid'})
    listPDR({ data, error }) {

       console.log('Start WIRE TABLE in Account');
       console.log('Id: ', this.accountid);

       if (data) {
           console.log(data);
           console.log('Array lenght: ', data.length);

           this.isEmpty = data.length == 0 ? true : false;
            
           this.columns = [
               { label: this.label.pratica, fieldName: 'linkname', type: 'url', typeAttributes: { label: { fieldName: 'NamePratica' }, target: '_blank', tooltip: { fieldName: 'NamePratica' } }},
               { label: this.label.pdr, fieldName: 'Name', type:'text'},
               { label: this.label.dataUltimaRata, fieldName: 'CRABB_DEV__Data_Ultima_Rata__c' , type:'date'},
               { label: this.label.importoTotale, fieldName: 'CRABB_DEV__Importo_Totale__c', type:'currency', cellAttributes: { alignment: 'left' } }];

               console.log('data from getPDR' , JSON.stringify(data));
               let praticaData = [];

               for(var d of data){

                   console.log(d);
                   let praticaName;
                   let linkName;

                   for(var property in d){
                       if(property == PRATICA){
                           praticaName = (d[property].Name);
                           linkName = '/'+d[property].Id;
                           console.log('nome pratica ', praticaName);
                       }
                   }

                   praticaData.push({
                       Id : d.Id,
                       NamePratica : praticaName,
                       linkname : linkName,
                       Name : d.Name,
                       CRABB_DEV__Importo_Totale__c : d.CRABB_DEV__Importo_Totale__c ,
                       CRABB_DEV__Data_Ultima_Rata__c : d.CRABB_DEV__Data_Ultima_Rata__c
                   })
                   console.log(praticaData);
               }
               this.tableData = [...praticaData];
               console.log('table data', this.tableData);
       }else if (error){
           console.log('errore --->', error);
       }
    }

}