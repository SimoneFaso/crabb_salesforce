import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
//Import for checking logged in user profile
import USER_ID from '@salesforce/user/Id';
import PROFILENAME_FIELD from '@salesforce/schema/User.Profile.Name';
//Import for reading CSV fiel
import readCSVFileAndUpload from '@salesforce/apex/ImportStrategyController.readCSVFileAndUpload';

import generateTestData from '@salesforce/apex/ImportStrategyController.generateTestData';
import runBatch from '@salesforce/apex/ImportStrategyController.runBatch';
//Import for labels
import Import_Strategies from '@salesforce/label/c.Import_Strategies';
import Strategy from '@salesforce/label/c.Strategy';
import Rule from '@salesforce/label/c.Rule';
import Name from '@salesforce/label/c.Name';
import Description from '@salesforce/label/c.Description';
import Status from '@salesforce/label/c.Status';
import AccountNumberToGenerate from '@salesforce/label/c.AccountNumberToGenerate';
import CreateTestData from '@salesforce/label/c.CreateTestData';
import StartManualBatchImport from '@salesforce/label/c.StartManualBatchImport';
import ImportStrategyNote from '@salesforce/label/c.Import_Strategy_Note';
import SystemAdministrator from '@salesforce/label/c.System_Administrator';

export default class ImportStrategy extends LightningElement {
    labels = {Import_Strategies, Name,Strategy, Rule,Description, Status,
        AccountNumberToGenerate,CreateTestData,StartManualBatchImport,
        ImportStrategyNote
    };
    numAccount = 10;
    filesUploaded = [];
    @track error;
    profileName;
    fileerror;
    filecontent;
    @track columns = [
        { label: Strategy + Name, fieldName: 'CRABB_DEV__Nome__c' },
        { label: 'Record Type', fieldName: 'RecordTypeId' },
        { label:  Rule, fieldName: 'CRABB_DEV__Activation_roles__c' },
        { label: 'SLA', fieldName: 'CRABB_DEV__SLA__c' },
        { label: Description, fieldName: 'CRABB_DEV__Descrizione__c' },
        { label: Status, fieldName: 'CRABB_DEV__Stato__c' },
    ];
    @track data;
    @track showLoadingSpinner = false;
    @track adminProfile;

    get acceptedFormats() {
        return ['.csv'];
    }
    get allowMultiple()
    {
        return false;
    }
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [PROFILENAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
           console.log('error');
        } else if (data) {
            this.profileName = data.fields.Profile.value.fields.Name.value;
            if (this.profileName === SystemAdministrator ){this.adminProfile = true;}
        }
    }
    handleNumberChange(event){
        this.numAccount = event.target.value;
     }
    handleCreateTestData(event) {
        this.showLoadingSpinner = true;
        // calling apex class
        generateTestData({numAcc : this.numAccount})
        .then(result => {
            this.showLoadingSpinner = false;
            window.console.log('result ===> '+JSON.stringify(result));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Accounts created successfully!!!',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            this.showLoadingSpinner = false;
            console.log(JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: error.body.message,
                    variant: 'error',
                }),
            );     
        })

    }
    handleBatchImport(event) {
        this.showLoadingSpinner = true;
        // calling apex class
        runBatch()
        .then(result => {
            this.showLoadingSpinner = false;
            window.console.log('result ===> '+JSON.stringify(result));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Ork Batch run successfully !!!',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            this.showLoadingSpinner = false;
            console.log(JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: error.body.message,
                    variant: 'error',
                }),
            );     
        })

    }
    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        this.showLoadingSpinner = true;
        // calling apex class
        readCSVFileAndUpload({idContentDocument : uploadedFiles[0].documentId})
        .then(result => {
            this.showLoadingSpinner = false;
            window.console.log('result ===> '+JSON.stringify(result));
            this.data = result;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Strategy Imported !!!',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            this.showLoadingSpinner = false;
            this.error = error;
            console.log(JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: error.body.message,
                    variant: 'error',
                }),
            );     
        })

    }
   
     
    
}