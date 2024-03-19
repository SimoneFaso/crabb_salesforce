/**
 * Created by ssalaris on 20/05/2021.
 */

import { LightningElement, track, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import readCSV from '@salesforce/apex/updateRiconBulkCTRL.readCSVFile';
import callBatch from '@salesforce/apex/updateRiconBulkCTRL.callBatch';
import deleteBatch from '@salesforce/apex/updateRiconBulkCTRL.deleteStagingRecords';
import getRicon from '@salesforce/apex/updateRiconBulkCTRL.getExportData';

import AttachFile from '@salesforce/label/c.AttachFile';
import exportCSV from '@salesforce/label/c.exportCSV';
import exportRiconciliazioni from '@salesforce/label/c.exportRiconciliazioni';
import exportTemplate from '@salesforce/label/c.exportTemplate';
import downloadCSV from '@salesforce/label/c.downloadCSV';
import Back from '@salesforce/label/c.Back';
import insertCSVricon from '@salesforce/label/c.insertCSVricon';
import updateRicon from '@salesforce/label/c.updateRicon';
import Cancel from '@salesforce/label/c.Cancel';
import caricamentoCompletato from '@salesforce/label/c.caricamentoCompletato';
import caricamentoCompletatoMex from '@salesforce/label/c.caricamentoCompletatoMex';
import Error from '@salesforce/label/c.Error';
import RiconciliazioniTemplate from '@salesforce/label/c.RiconciliazioniTemplate';
import updateRiconMex from '@salesforce/label/c.updateRiconMex';
import operazioneAnnullata from '@salesforce/label/c.operazioneAnnullata';
import riconError from '@salesforce/label/c.riconError';
import riconciliazioniCSV from '@salesforce/label/c.riconciliazioniCSV';

const columns = [
    { label: 'Riconciliazione Id', fieldName: 'CRABB_DEV__RiconciliazioneId__c' },
    { label: 'Pratica Id', fieldName: 'CRABB_DEV__PraticaId__c' },
    { label: 'Value', fieldName: 'CRABB_DEV__Value__c'},
];

const columnsExp = [
    { label: 'Account Name', fieldName: 'Account_Name'},
    { label: 'Codice Cliente', fieldName: 'Codice_Cliente'},
    { label: 'Codice Pratica', fieldName: 'Codice_Pratica'},
    { label: 'Pratica Id', fieldName: 'Pratica_Id'},
    { label: 'Scaduto Pratica', fieldName: 'Pratica_Scaduto'},
    { label: 'Codice Riconciliazione', fieldName: 'Riconciliazion_eName' },
    { label: 'Riconciliazione Id', fieldName: 'Riconciliazione_Id' },
    { label: 'Importo Riconciliazione', fieldName: 'Riconciliazione_Importo'},
    
];

export default class updateRiconBulk extends LightningElement {

    label = {
            AttachFile,exportCSV,exportRiconciliazioni,exportTemplate,downloadCSV,Back,insertCSVricon,updateRicon,Cancel,caricamentoCompletato,
            caricamentoCompletatoMex,Error,RiconciliazioniTemplate,updateRiconMex,operazioneAnnullata,riconError,riconciliazioniCSV
        };
    @api recordId;
    @track error;
    @track columns = columns;
    @track data;
    @track columnsExp = columnsExp;
    @track dataExp;

    // accepted parameters
    get acceptedFormats() {
        return ['.csv'];
    }

    downloadTemplate(event) {
           let downloadElement = document.createElement('a');
           let csvString = 'Riconciliazione Id,Pratica Id,Value';
           // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
           downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
           downloadElement.target = '_self';
           // CSV File Name
           downloadElement.download = this.label.RiconciliazioniTemplate;
           // below statement is required if you are using firefox browser
           document.body.appendChild(downloadElement);
           // click() Javascript function to download CSV file
           downloadElement.click();
            }

    handleIndietro(event) {
            this.dataExp = false;
        }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;

        // calling apex class
        readCSV({idContentDocument : uploadedFiles[0].documentId})
        .then(result => {
            window.console.log('result ===> '+result);
            this.data = result;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.label.caricamentoCompletato,
                    message: this.label.caricamentoCompletatoMex,
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            this.error = error;
            this.data = undefined;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.label.riconError,
                    message: JSON.stringify(error),
                    variant: 'error',
                }),
            );
            this.data = undefined;
        })
    }

    handleCallBatch(event) {
            // calling apex class
            callBatch()
            .then(result => {
                console.log('result ===> '+result);
                this.data = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.updateRicon,
                        message: this.label.updateRiconMex,
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.Error,
                        message: JSON.stringify(error),
                        variant: 'error',
                    }),
                );
            })

        }

    handleAnnulla(event) {
                // calling apex class
                deleteBatch()
                .then(result => {
                    console.log('result ===> '+result);
                    this.data = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.Cancel,
                            message: this.label.operazioneAnnullata,
                            variant: 'info',
                        }),
                    );
                })
                .catch(error => {
                    this.error = error;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.Error,
                            message: JSON.stringify(error),
                            variant: 'error',
                        }),
                    );
                })

    }

    getallRicon(event) {
            getRicon()
            .then(result => {
                //console.log(JSON.stringify(result));
                this.dataExp = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.Error,
                        message: error.message,
                        variant: 'error'
                    }),
                );
                this.dataExp = undefined;
            });
        }

// this method validates the data and creates the csv file to download
    downloadCSVFile(event) {
        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();

        // getting keys from data
        this.dataExp.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        console.log('@@@@@@@ rowData : '+ rowData);

        // splitting using ','
        //csvString += rowData.join(',');

        csvString+='Account Name,Codice Cliente,Codice Pratica,Pratica Id,Scaduto Pratica,Codice Riconciliazione,Riconciliazione Id,Importo Riconciliazione';
        csvString += rowEnd;

        // main for loop to get the data based on key value
        for(let i=0; i < this.dataExp.length; i++){
            let colValue = 0;

            // validating keys in data
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    // Key value
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = this.dataExp[i][rowKey] === undefined ? '' : this.dataExp[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }

        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = this.label.riconciliazioniCSV;
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click();
    }

}