/**
 * Created by MatteoSala on 28/09/2021.
 */

import { LightningElement, api  , track } from 'lwc';
import getSelezioni from '@salesforce/apex/CrabbEsitiMassiviLngCtrl.getSelezioni';
import getQueryListView from '@salesforce/apex/CrabbEsitiMassiviLngCtrl.getQueryListView';
import countQueryListViewRows from '@salesforce/apex/CrabbEsitiMassiviLngCtrl.countQueryListViewRows';
import getQueryListRows from '@salesforce/apex/CrabbEsitiMassiviLngCtrl.getQueryListRows';
import getMaxRecords from '@salesforce/apex/CrabbEsitiMassiviLngCtrl.getMaxRecords';
import ConfermaLista from '@salesforce/apex/CrabbEsitiMassiviLngCtrl.ConfermaLista';
import refreshTable from '@salesforce/apex/CrabbEsitiMassiviLngCtrl.refreshTable';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import EsitiMassiviButtonProcedi from '@salesforce/label/c.EsitiMassiviButtonProcedi';
import EsitiMassiviButtonIndietro from '@salesforce/label/c.EsitiMassiviButtonIndietro';
import EsitiMassiviSelectType from '@salesforce/label/c.EsitiMassiviSelectType';
import EsitiMassiviSelectDossierListView from '@salesforce/label/c.EsitiMassiviSelectDossierListView';
import EsitiMassiviNoListViewFound from '@salesforce/label/c.EsitiMassiviNoListViewFound';
import EsitiMassiviSelectionContains from '@salesforce/label/c.EsitiMassiviSelectionContains';
import EsitiMassiviYourSelection from '@salesforce/label/c.EsitiMassiviYourSelection';
import EsitiMassiviRecord from '@salesforce/label/c.EsitiMassiviRecord';
import EsitiMassiviBackToMod from '@salesforce/label/c.EsitiMassiviBackToMod';
import EsitiMassiviProceedToDetails from '@salesforce/label/c.EsitiMassiviProceedToDetails';
import EsitiMassiviMaxOutcomeInfo from '@salesforce/label/c.EsitiMassiviMaxOutcomeInfo';
import EsitiMassiviClickToUpdateInfo from '@salesforce/label/c.EsitiMassiviClickToUpdateInfo';
import EsitiMassiviOperationComplete from '@salesforce/label/c.EsitiMassiviOperationComplete';
import EsitiMassiviStartProcess from '@salesforce/label/c.EsitiMassiviStartProcess';
import EsitiMassiviRefreshButton from '@salesforce/label/c.EsitiMassiviRefreshButton';
import EsitiMassiviCloseButton from '@salesforce/label/c.EsitiMassiviCloseButton';
import EsitiMassiviRecordToOutcome from '@salesforce/label/c.EsitiMassiviRecordToOutcome';
import EsitiMassiviContains from '@salesforce/label/c.EsitiMassiviContains';
import EsitiMassiviNoTypeFound from '@salesforce/label/c.EsitiMassiviNoTypeFound';
import EsitiMassiviBulkOutcomes from '@salesforce/label/c.EsitiMassiviBulkOutcomes';
import EsitiMassiviNoExternalAuth from '@salesforce/label/c.EsitiMassiviNoExternalAuth';



const minStep = 1;
const maxStep = 5;

export default class CrabbEsitiMassiviLng extends LightningElement
{
    @track isLoading = true;
    @track stepProcess = 1;
    isAvanti = false; 
    isIndietro = false;
    isTS = false;
    isLV = false; 
    @track TaskType;
    @track optionSelected;
    @track ListView;
    @track reportId;
    @track countQuery;
    @track filteredDossiers = [];
    @track totalRecordList = [];
    @track selectedRecordList = [];
    @track finalOutcome;
    @track finalOutcomeType;
    @track maxRecords;
    @track disableCloseProcedureButton = true;
    @track disableRefreshButton = false;
    @track isProcessing = true;
    @track batchInformation = new Map();
    @track retrievedRows = [];
    @track tableRecords = [];
    @track TotalJobItems;
    @track JobItemsProcessed;
    @track batchStatus;
    @track NumberOfErrors;
    @track batchId;
    @track selectedRows = [];

    labels = {
        EsitiMassiviButtonProcedi,
        EsitiMassiviButtonIndietro,
        EsitiMassiviSelectType,
        EsitiMassiviSelectDossierListView,
        EsitiMassiviNoListViewFound,
        EsitiMassiviSelectionContains,
        EsitiMassiviYourSelection,
        EsitiMassiviRecord,
        EsitiMassiviBackToMod,
        EsitiMassiviProceedToDetails,
        EsitiMassiviMaxOutcomeInfo,
        EsitiMassiviClickToUpdateInfo,
        EsitiMassiviOperationComplete,
        EsitiMassiviStartProcess,
        EsitiMassiviRefreshButton,
        EsitiMassiviCloseButton,
        EsitiMassiviRecordToOutcome,
        EsitiMassiviContains,
        EsitiMassiviNoTypeFound,
        EsitiMassiviBulkOutcomes,
        EsitiMassiviNoExternalAuth
    };

    connectedCallback()
    {

        getSelezioni()
        .then(( data ) =>
        {
            this.TaskType=data.lTS;
            if(this.TaskType.length > 0)
                this.isTS = true; 
            else
                this.isAvanti = false;
            this.ListView=data.lLV;
            if(this.ListView.length > 0)
                this.isLV = true;
            else
                this.isAvanti = false;
            this.isLoading = false;
        }).catch((error) => {
            console.error('Error: ' + error);
            this.isLoading = false; 
        });
    }

    setIsActiveButtonHandle(event) {
        if(event.detail.selectedRowCount > 0 && event.detail.selectedValue !== '--- Select one ---' && event.detail.selectedValue !== '' && event.detail.selectedValue != null) {
            this.isAvanti = true;
            this.retrievedRows = event.detail.retrievedRows;
            this.tableRecords = event.detail.tableRecords; 
        } else {
            this.isAvanti = false;
        }
    }

    setIsActiveButtonHandleSelectAll(event) {
        if(event.detail.selectedRCount > 0 && event.detail.selectedValue !== '--- Select one ---' && event.detail.selectedValue !== '' && event.detail.selectedValue != null) {
            this.isAvanti = true;
            this.retrievedRows = event.detail.retrievedRows;
            this.tableRecords = event.detail.tableRecords;
        } else {
            this.isAvanti = false;
        }
    }

    setIsActiveButtonHandleDeselectAll(event) {
        this.isAvanti = false;
    }

    SelectType(evt)
    {
        console.log('SelectType: ' + JSON.stringify(evt));
    }

    getSelectionTS(event)
    {
        this.optionSelected = event.detail.value;
        console.log('OptionSelected --> ' + this.optionSelected);
        if(this.optionSelected === undefined || !this.optionSelected || 0 === this.optionSelected.length || !this.reportId || 0 === this.reportId.length || this.reportId === undefined) {
            this.isAvanti = false;
        } else {
            this.isAvanti = true;
        }
    }
 
    getSelectionLV(event)
    {
        this.reportId = event.detail.value;
        if(this.optionSelected === undefined || !this.optionSelected || 0 === this.optionSelected.length || !this.reportId || 0 === this.reportId.length || this.reportId === undefined) {
            this.isAvanti = false;
        } else {
            this.isAvanti = true;
        }
    }

    ProcediStepSucc()
    {
        this.isLoading=true;
        this.stepProcess += 1;
        if(this.stepProcess <= maxStep)
        {
            this.isAvanti = true;
        }
        if(this.stepProcess > maxStep)
        {
            this.isAvanti = false;
        }
        if(this.stepProcess <= minStep)
        {
            this.isIndietro = false;
        }
        if(this.stepProcess > minStep)
        {
            this.isIndietro = true;
        }

        if(this.stepProcess === 2)
        {
 
            getMaxRecords()
            .then(result => {
                this.maxRecords = result;
            })
            .catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'System Error',
                        message: JSON.stringify(error),
                        variant: 'error',
                    }),
                );

            })
            getQueryListView({ 'listViewId' : this.reportId , 'TipoSottotipo' : this.optionSelected})
            .then(result => {
            countQueryListViewRows( { 'query' : result , 'TipoSottotipo' : this.optionSelected})
                .then(countQuery => {
                    this.countQuery = countQuery;
                    if(countQuery == 0)
                        this.isAvanti = false;

                    this.getDossiersId(result);
                })
            })
            .catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'System Error',
                        //message: JSON.stringify(error),
                        message: EsitiMassiviNoExternalAuth,
                        variant: 'error',
                    }),
                );

            })
        }
        if(this.stepProcess === 3)
        {
            this.isAvanti = false;
        }
        if(this.stepProcess === 4)
        {
            //console.log('---> ' + this.template.querySelector('c-crabb-table-esiti-massivi').GetRetrievedRows());
            this.selectedRows = this.template.querySelector('c-crabb-table-esiti-massivi').GetRetrievedRows();
            this.selectedRecordList = this.template.querySelector('c-crabb-table-esiti-massivi').FinalDossierList();
            this.finalOutcome = this.template.querySelector('c-crabb-table-esiti-massivi').FinalOutcome();
            this.finalOutcomeType = this.template.querySelector('c-crabb-table-esiti-massivi').FinalOutcomeType();
            this.isAvanti = true;
        }

        if(this.stepProcess === 5) {
            this.isAvanti = false;
            this.isIndietro = false; 
            this.isLoading = true;

            ConfermaLista({'lPratDaElaborare' : this.selectedRecordList, 'selectedEsitiPickValue' : this.finalOutcome, 'tipoesotto' : this.optionSelected}).then(result => {
                this.batchInformation = JSON.parse(JSON.stringify(result));
                this.TotalJobItems = this.batchInformation['TotalJobItems'];
                this.JobItemsProcessed = this.batchInformation['JobItemsProcessed'];
                this.batchStatus = this.batchInformation['Status'];
                this.NumberOfErrors = this.batchInformation['NumberOfErrors'];
                this.batchId = this.batchInformation['Id'];
                if(JSON.stringify(this.batchStatus) == 'Completed') {
                    this.isProcessing = false;
                    this.disableRefreshButton = true;
                    this.disableCloseProcedureButton = false;
                    this.isLoading = false;
                }
            });


            this.isLoading = false;
        }
        this.isLoading = false;
    }

    async callConfermaLista() {

    }

    async getDossiersId(query)
    {
        this.isLoading = true;
        let offsetData = 0;
        let limitData = this.maxRecords;
        //let totalRecordList = [];
        let offsetValue = 'PR-000000';
        let jsonQuery = '';
        let appData;
        let jsonQueryStringify;
        this.totalRecordList = [];
        if(limitData>this.maxRecords)
            limitData = this.maxRecords;

        while(true)
        {
            let resQuery = await getQueryListRows( { 'query' : query , 'limitClause' : limitData , 'offsetClause' : offsetData, 'offsetValue' : offsetValue , 'TipoSottotipo' : this.optionSelected })
            this.totalRecordList = this.totalRecordList.concat(resQuery);

            if(resQuery.length == 0 || this.totalRecordList.length>=this.maxRecords || this.totalRecordList.length<this.maxRecords)
            {
                break;
            }
            else if(this.totalRecordList.length+limitData>this.maxRecords)
            {
                limitData = this.maxRecords-this.totalRecordList.length;
            }

            jsonQueryStringify = JSON.stringify(resQuery);
            jsonQuery = JSON.parse(jsonQueryStringify)
            let result = [];
            for(var i in jsonQuery) {
                result.push([i, jsonQuery[i]]);
            }
            appData = result[result.length - 1];
            offsetValue = appData[appData.length-1].Name;
        }
        
        this.isLoading = false;
    }

    ProcediStepPrec()
    {
        this.isLoading=true;
        this.stepProcess -= 1;
        if(this.stepProcess <= maxStep)
        {
            this.isAvanti = true;
        }
        if(this.stepProcess > maxStep)
        {
            this.isAvanti = false;
        }
        if(this.stepProcess <= minStep)
        {
            this.isIndietro = false;
        }
        if(this.stepProcess > minStep)
        {
            this.isIndietro = true;
        }

        if(this.stepProcess === 1) {
            this.optionSelected = '';
            this.reportId = '';
            this.countQuery = 0;
            this.isAvanti = false;
        }
        this.isLoading = false;
    }

    closeProcedure() {

        window.location.reload();
    }
    
    // this method validates the data and creates the csv file to download
    downloadCSVFile()
    {
        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();
        let itemToSubmit = [];

        for (let i = 0; i < this.tableRecords.length; i++)
        {
            if(this.retrievedRows.includes(this.tableRecords[i].Id))
            {
                itemToSubmit.push(this.tableRecords[i]);
            }
        }

        // getting keys from data
        itemToSubmit.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);

        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;

        // main for loop to get the data based on key value
        for(let i=0; i < itemToSubmit.length; i++)
        {
            let colValue = 0;

            // validating keys in data
            for(let key in rowData)
            {
                if(rowData.hasOwnProperty(key))
                {
                    // Key value
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0)
                    {
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = itemToSubmit[i][rowKey] === undefined ? '' : itemToSubmit[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }

        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        //downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        let pathSection = 'data:text/csv;charset=utf-8,';
        //downloadElement.href = pathSection + encodeURI(csvString);
        downloadElement.href = pathSection + encodeURIComponent(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'CRABB-BEMT.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click();
    }

    refreshBatchInformation() {
        this.isLoading = true;
        refreshTable({'batchId' : this.batchId}).then(result => {
            this.batchInformation = JSON.parse(JSON.stringify(result));
            this.TotalJobItems = this.batchInformation['TotalJobItems'];
            this.JobItemsProcessed = this.batchInformation['JobItemsProcessed'];
            this.batchStatus = this.batchInformation['Status'];
            this.NumberOfErrors = this.batchInformation['NumberOfErrors'];
            this.batchId = this.batchInformation['Id'];
            if(this.batchStatus === 'Completed') {
                this.isProcessing = false;
                this.disableRefreshButton = true;
                this.disableCloseProcedureButton = false;
                this.isLoading = false;
            }
        });
        this.isLoading = false;
    }

    get isStep1()
    {
        return this.stepProcess==1 ? true : false;
    }

    get isStep2()
    {
        if(this.stepProcess==2)
        {
            this.isLoading = true;
        }

        return this.stepProcess==2 ? true : false;
    }

    get isStep3()
    {
        return this.stepProcess==3 ? true : false;
    }

    get isStep4()
    {
        return this.stepProcess==4 ? true : false;
    }

    get isStep5()
    {
        return this.stepProcess==5 ? true : false;
    }

    get isEmpty()
    {
        return this.countQuery==0 ? true : false;
    }
}