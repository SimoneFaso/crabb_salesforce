/**
 * Created by User on 09/09/2021.
 */

import { LightningElement , api , track,wire  } from 'lwc';
import getEsitiPickListValues from '@salesforce/apex/CrabbEsitiMassiviLngCtrl.getEsitiPickListValues';
import getMapEsitiFinal from '@salesforce/apex/CrabbEsitiMassiviLngCtrl.getMapEsitiFinal';
import ConfermaLista from '@salesforce/apex/CrabbEsitiMassiviLngCtrl.ConfermaLista';
import CUSTOM_OBJECT from '@salesforce/schema/Pratica__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import EsitiMassiviLastPageButton from '@salesforce/label/c.EsitiMassiviLastPageButton';
import EsitiMassiviNextPageButton from '@salesforce/label/c.EsitiMassiviNextPageButton';
import EsitiMassiviPreviousPageButton from '@salesforce/label/c.EsitiMassiviPreviousPageButton';
import EsitiMassiviFirstPageButton from '@salesforce/label/c.EsitiMassiviFirstPageButton';
import EsitiMassiviSelectAllButton from '@salesforce/label/c.EsitiMassiviSelectAllButton';
import EsitiMassiviDeselectAllButton from '@salesforce/label/c.EsitiMassiviDeselectAllButton';
import EsitiMassiviSelectedRows from '@salesforce/label/c.EsitiMassiviSelectedRows';
import EsitiMassiviElementsForPage from '@salesforce/label/c.EsitiMassiviElementsForPage';
import EsitiMassiviCooseOutcome from '@salesforce/label/c.EsitiMassiviCooseOutcome';
import EsitiMassiviOutcomeType from '@salesforce/label/c.EsitiMassiviOutcomeType';

export default class CrabbTableEsitiMassivi extends LightningElement {

    @api tableRecords = [];
    @api tipoSottotipo;
    @api isOutcomesNeeded = false;
    @track columnsTable = [];
    @track rowsTable = [];
    @track isDataPopulated=false;
    @track isLoading = true;
    @track sortBy;
    @track sortDirection;
    @track page = 1;
    @track totalPage;
    @track keyword;
    @api keyField;
    @track disabledPreviousPageButton = false;
    @track disabledNextPageButton = false;
    @track disabledFirstPageButton = false;
    @track disabledNextStepButton = true;
    @track disabledLastPageButton = false;
    @track currentPage;
    @track retrievedRows = [];
    @track rowSelection = [];
    @track selectedRowsCount = '0';
    @track esitiList = [];
    @track finalEsitiList = [];
    @track esitiTypes = new Map();
    @track selectedValueCombobox = 'NA';
    @track selectedValue = '';
    pagedData;
    numberOfRecordsForPage = '25';
    @api itemToSubmit = [];
    @track dossierFields = [];
    @api parentRetrievedRows = [];

    labels = {
        EsitiMassiviLastPageButton,
        EsitiMassiviNextPageButton,
        EsitiMassiviPreviousPageButton,
        EsitiMassiviFirstPageButton,
        EsitiMassiviSelectAllButton,
        EsitiMassiviDeselectAllButton,
        EsitiMassiviSelectedRows,
        EsitiMassiviElementsForPage,
        EsitiMassiviCooseOutcome,
        EsitiMassiviOutcomeType
    }

    @wire(getObjectInfo, { objectApiName: CUSTOM_OBJECT })
    dossierInfo({ data, error })
    {
        if (data)
        {
            this.dossierFields.push(data.fields);
            this.dossierFields = JSON.parse(JSON.stringify(data.fields));
        }
    }

    get recordForPageOptions() {
        return [
            { label: '25', value: '25' },
            { label: '50', value: '50' },
            { label: '100', value: '100' },
            { label: '150', value: '150' }, 
            { label: '200', value: '200' },
            { label: '250', value: '250' },
            { label: '500', value: '500' }
        ];
    }
    connectedCallback(){
        //console.log('parentRetrievedRows --> ' + this.parentRetrievedRows);
        this.createTable();
        this.getOutcomeMap().then(result => this.gotoPage(this.page, this.tableRecords));
        /*if(this.parentRetrievedRows.size > 0) {
            this.rowSelection = JSON.parse(JSON.stringify(this.parentRetrievedRows));
        }*/
        this.loading=false;
    }

    get getFinalEsitiList() {
        return JSON.parse(JSON.stringify(this.finalEsitiList));
    }

    @api
    FinalDossierList()
    {
        for (let i = 0; i < this.tableRecords.length; i++){ 
            if(this.retrievedRows.includes(this.tableRecords[i].Id)) {
                this.itemToSubmit.push(this.tableRecords[i].Id);
            }
        }

        return JSON.parse(JSON.stringify(this.itemToSubmit));
    }

    @api
    FinalOutcome()
    {
        return this.selectedValue;
    }

    @api
    FinalOutcomeType()
    {
        return this.selectedValueCombobox;
    }

    @api
    GetRetrievedRows() {
        return this.retrievedRows;
    }

    @api
    createTable(){
        if(this.tableRecords.length>0){
            this.totalPage = this.getMaxPages();
        }
        //this.tableRecords = records;
        if(this.tableRecords.length>0){
            let record = this.tableRecords[0];
            let fields = Object.keys(record)
            for(let field of fields)
            {
                if(field.includes('__r')) {
                    var newField = field.replace('__r','__c');
                    var newFieldType = this.dossierFields[newField].dataType.toLowerCase();
                    this.insertColumnsTable(newField, newFieldType);
                } else {
                    var newFieldType = this.dossierFields[field].dataType.toLowerCase();
                    this.insertColumnsTable(field, newFieldType);
                }
            } 
            this.isDataPopulated = true;
            //remove duplicates from array
            var appColumnsTable = [...this.columnsTable];
            this.columnsTable = Array.from(new Set(appColumnsTable.map(JSON.stringify))).map(JSON.parse);
        }
    }

    insertColumnsTable(field, fieldType) {
        if(fieldType==='reference') {
            fieldType= 'String';
        }
        this.columnsTable.push({
            "fieldName" : field ,
            "label" : this.dossierFields[field].label ,
            "type" : fieldType.toLowerCase() ,
            "sortable" : true
        });
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.tableRecords));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.tableRecords = parseData;
        this.gotoPage(1, this.tableRecords);
    }

    handleKeywordChange(event) {
        this.keyword = event.target.value;
        this.handlePageChange();
    }

    handleButtonPrevious() {
        this.rowSelection = JSON.parse(JSON.stringify(this.retrievedRows));
        var nextPage = this.currentPage - 1;
        var maxPages =  this.getMaxPages();

        if(nextPage > 0 && nextPage <= maxPages) {
            this.gotoPage(nextPage, this.tableRecords);
        }
        //this.template.querySelector('[data-id="datarow"]').selectedRows = this.rowSelection;
    }

    handleButtonNext() {
        this.rowSelection = JSON.parse(JSON.stringify(this.retrievedRows));
        var nextPage = this.currentPage + 1;
        var maxPages =  this.getMaxPages();
        
        if(nextPage > 0 && nextPage <= maxPages) {
            this.gotoPage(nextPage, this.tableRecords);
        }
        //this.template.querySelector('[data-id="datarow"]').selectedRows = this.rowSelection;
    }

    handleButtonFirstPage() {
        this.rowSelection = JSON.parse(JSON.stringify(this.retrievedRows));
        var nextPage = this.page;
        var maxPages =  this.getMaxPages();

        if(nextPage > 0 && nextPage <= maxPages) {
            this.gotoPage(nextPage, this.tableRecords);
        }
        //this.template.querySelector('[data-id="datarow"]').selectedRows = this.rowSelection;
    }

    handleButtonLastPage() {
        this.rowSelection = JSON.parse(JSON.stringify(this.retrievedRows));
        var nextPage = this.getMaxPages();
        var maxPages =  this.getMaxPages();

        if(nextPage > 0 && nextPage <= maxPages) {
            this.gotoPage(nextPage, this.tableRecords);
        }
        //this.template.querySelector('[data-id="datarow"]').selectedRows = this.rowSelection;
    }

    submitData() {
        //ConfermaLista({'lPratDaElaborare' : this.itemToSubmit, 'selectedEsitiPickValue' : this.selectedValue, 'tipoesotto' : this.tipoSottotipo});
    }

    getMaxPages() {
        var result = 1;
        var arrayLength;
        var divideValue;

        // Ensure sourceData has a value
        if(this.tableRecords) {
            arrayLength = this.tableRecords.length;

            // Float value of number of pages in data table
            divideValue = arrayLength / this.numberOfRecordsForPage;

            // Round up to the next Integer value for the actual number of pages
            result = Math.ceil(divideValue);
        }

        this.totalPage = result;

        return result;
    }

    gotoPage(pageNumber, data) {
        var recordStartPosition, recordEndPosition;
        var i, arrayElement;
        var maximumPages = this.totalPage;

        maximumPages = this.getMaxPages();

        // Validate that desired page number is available
        if( pageNumber > maximumPages || pageNumber < 0 ) {
            // Invalid page change.
            return;
        }

        // Reenable both buttons
        this.disabledPreviousPageButton = false;
        this.disabledNextPageButton = false;
        this.disabledFirstPageButton = false;
        this.disabledLastPageButton = false;

        if(data) {

            // Empty the data source used
            this.pagedData = [];

            // Start the records at the page position
            recordStartPosition = this.numberOfRecordsForPage * (pageNumber - 1);

            // End the records at the record start position with an extra increment for the page size
            recordEndPosition = recordStartPosition + parseInt(this.numberOfRecordsForPage, 10);

            // Loop through the selected page of records
            for ( i = recordStartPosition; i < recordEndPosition; i++ ) {

                //arrayElement = this.tableRecords[i];
                arrayElement = data[i];

                if(arrayElement) {

                    // Add data element for the data to bind
                    this.pagedData.push(arrayElement);
                }
            }

            // Set global current page to the new page
            this.currentPage = pageNumber;
            
            // If current page is the final page then disable the next button
            if(maximumPages == this.currentPage) {
                this.disabledLastPageButton = true;
                this.disabledNextPageButton = true;
            }

            // If current page is the first page then disable the previous button
            if(this.currentPage == 1) {
                this.disabledFirstPageButton = true;
                this.disabledPreviousPageButton = true;
            }
        }
        this.isLoading = false;
    }

    handlerecordForPage(event) {
        this.numberOfRecordsForPage = event.detail.value;
        this.isLoading = true; 
        this.gotoPage(this.page, this.tableRecords);
        this.isLoading = false;
    }

    handleRowSelected(evt) {
    	// List of selected items from the data table event.
    	let updatedItemsSet = new Set();
    	// List of selected items we maintain.
    	let selectedItemsSet = new Set(this.retrievedRows);
    	// List of items currently loaded for the current view.
    	let loadedItemsSet = new Set();

    	this.pagedData.map((event) => {
    		loadedItemsSet.add(event.Id);
    	});

    	if (evt.detail.selectedRows) {
            evt.detail.selectedRows.map((event) => {
                updatedItemsSet.add(event.Id);
            });

            //Add any new items to the selection list
            updatedItemsSet.forEach((id) => {
                if (!selectedItemsSet.has(id)) {
                    selectedItemsSet.add(id);
                }
            });
        }

    	loadedItemsSet.forEach((id) => {
    		if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
    			// Remove any items that were unselected.
    			selectedItemsSet.delete(id);
    		}
    	});


    	this.retrievedRows = [...selectedItemsSet];
    	if(this.retrievedRows.length>0) {
    	    this.disabledNextStepButton=false;
        } else {
            this.disabledNextStepButton=true;
        }
    	this.selectedRowsCount = this.retrievedRows.length;
        const selectedEvent = new CustomEvent('setisactivebutton', {detail: {selectedRowCount : this.selectedRowsCount, selectedValue: this.selectedValue, tableRecords : this.tableRecords, retrievedRows : this.retrievedRows}});
        this.dispatchEvent(selectedEvent); 
    }

    selectAllDossiers() {
        let selValue = this.selectedValue;
        for (let i = 0; i < this.tableRecords.length; i++){
            if(!this.retrievedRows.includes(this.tableRecords[i].Id)) {
                this.retrievedRows.push(this.tableRecords[i].Id);
            }
        }
        this.disabledNextStepButton=false;
        this.rowSelection = JSON.parse(JSON.stringify(this.retrievedRows));
        let rSelection =  this.rowSelection.length
        this.selectedRowsCount = this.retrievedRows.length;

        const selectedEvent = new CustomEvent('setisactivebuttonselectall', {detail: {selectedRCount : rSelection, selectedValue: selValue, tableRecords : this.tableRecords, retrievedRows : this.retrievedRows}});
        this.dispatchEvent(selectedEvent);
    }

    deselectAllDossiers() {
        this.retrievedRows = [];
        this.disabledNextStepButton=true;
        this.rowSelection = JSON.parse(JSON.stringify(this.retrievedRows));
        this.selectedRowsCount = 0;

        const selectedEvent = new CustomEvent('setisactivebuttondeselectall');
        this.dispatchEvent(selectedEvent);
    }

    async getOutcomeMap() {

        this.esitiList = await getEsitiPickListValues({ 'tipoesotto' : this.tipoSottotipo });
        for (let i = 0; i < this.esitiList.length; i++){
            let arrayElements = this.esitiList[i];

            for (var key in arrayElements) {
                if (arrayElements.hasOwnProperty(key)) {
                    var pickElement = {
                        label: key,
                        value: arrayElements[key]
                    };
                    this.finalEsitiList.push(pickElement);
                }
            }
        }
        this.esitiTypes = await getMapEsitiFinal({ 'tipoesotto' : this.tipoSottotipo });

    }

    handleComboChange(event) {

        this.selectedValue = event.detail.value;
        this.selectedValueCombobox = this.esitiTypes[event.detail.value];

        if(this.selectedValue !== '' && this.selectedValue !== '--- Select one ---') {
            this.selectedValueCombobox = this.esitiTypes[event.detail.value];
        } else {
            this.selectedValueCombobox = 'NA';
        }

        const selectedEvent = new CustomEvent('setisactivebutton', {detail: {selectedRowCount : this.selectedRowsCount, selectedValue: this.selectedValue, tableRecords : this.tableRecords, retrievedRows : this.retrievedRows}});
        this.dispatchEvent(selectedEvent);
    }
}