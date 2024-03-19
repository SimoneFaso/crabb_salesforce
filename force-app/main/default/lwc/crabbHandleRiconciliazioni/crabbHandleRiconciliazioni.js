import {LightningElement, api, track, wire} from 'lwc';
import {refreshApex} from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import GetpraticheByAccount from '@salesforce/apex/RiconciliazioneCTRL.GetpraticheByAccount';
import SaveBozza from '@salesforce/apex/RiconciliazioneCTRL.SaveBozza';
import isEditable from '@salesforce/apex/RiconciliazioneCTRL.isEditable';
import updateStatus from '@salesforce/apex/RiconciliazioneCTRL.updateStatus';
import PRATICA_OBJECT from '@salesforce/schema/Pratica__c';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import STRATEGIA_OBJECT from '@salesforce/schema/Strategia__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { updateRecord } from 'lightning/uiRecordApi';
import ConfirmationMessage from '@salesforce/label/c.ConfirmationMessage';
import TotalAmountMessage from '@salesforce/label/c.TotalAmountMessage';
import TotalValueMessage from '@salesforce/label/c.TotalValueMessage';
import RemainingAmountMessage from '@salesforce/label/c.RemainingAmountMessage';
import ClickButtonMessage from '@salesforce/label/c.ClickButtonMessage';
import ApproveButton from '@salesforce/label/c.ApproveButton';
import RejectButton from '@salesforce/label/c.RejectButton';
import YesButton from '@salesforce/label/c.YesButton';
import NoButton from '@salesforce/label/c.NoButton'; 
import ToastSuccessMessage from '@salesforce/label/c.ToastSuccessMessage';
import ToastErrorMessage from '@salesforce/label/c.ToastErrorMessage';
import checkAmountFlagSuccess from '@salesforce/label/c.checkAmountFlagSuccess';
import checkAmountFlagWarning from '@salesforce/label/c.checkAmountFlagWarning';

export default class crabbHandleRiconciliazioni extends LightningElement{

    // Expose the labels to use in the template.
    label = {
        ConfirmationMessage,
        TotalAmountMessage,
        TotalValueMessage,
        RemainingAmountMessage,
        ClickButtonMessage,
        ApproveButton,
        RejectButton,
        YesButton,
        NoButton,
        ToastSuccessMessage,
        ToastErrorMessage,
        checkAmountFlagSuccess,
        checkAmountFlagWarning
    };

    @api recordId;
    @track praticaList;
    @track isLoading = true;
    @track searchText='';
    draftValues = [];
    @track editable = true;
    @track columns;
    @track ApprovalStatus;
    @track showConfirmation=false;
    //******** retrieve obj info for pratica, strategia and account  ********
    @wire(getObjectInfo, { objectApiName: PRATICA_OBJECT }) praticaFieldsInfo;
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT }) accountFieldsInfo;
    @wire(getObjectInfo, { objectApiName: STRATEGIA_OBJECT }) strategiaFieldsInfo;
    //************************************************************************
    @track importoBonifico;
    @track valueSum;
    @track totalAmount; //importoBonifico - valueSum
    @track checkAmountFlag = false;

    // initialize component (come init in aura component)
    connectedCallback() {
        this.isLoading=true;
        this.isEditable(); //find out if riconciliazione is already approved/rejected (ro) or editable
    }

    handleSave(event) {
        //console.log('################ SONO HANDLE SAVE ##############');
        const updatedFields = event.detail.draftValues;
        SaveBozza({riconciliazioneId: this.recordId , bozzaJson: JSON.stringify(updatedFields)})
        .then(result => {
            this.retriveRecordsFromServer();
            this.showMessage('success', this.label.ToastSuccessMessage);
        }).catch(error => {
           console.log('error handleSave '+JSON.stringify(error));
        });
    }

    updateSearch(event){
        this.searchText=event.target.value;
        //this.editable=false;
        //this.retriveRecordsFromServer();
        this.isEditable();
    }

    retriveRecordsFromServer(){
        GetpraticheByAccount({riconciliazioneId: this.recordId , searchText: this.searchText})
        .then(result => {
            console.log('result callback '+JSON.stringify(result));
            this.praticaList = result;
            this.draftValues = [];

            //calcolo variabili a layout
            if(this.praticaList.length>=0) {
                this.importoBonifico = parseFloat(this.praticaList[0].totaleImportoRiconciliazione).toFixed(2);
                var valueSum = 0;
                for(var i=0;i<this.praticaList.length;i++){
                    if(this.praticaList[i].Value){
                        valueSum += parseFloat(this.praticaList[i].Value);
                    }
                }
                this.valueSum = parseFloat(valueSum).toFixed(2);
                this.totalAmount = parseFloat(this.importoBonifico).toFixed(2) - parseFloat(this.valueSum).toFixed(2);
                this.totalAmount = this.totalAmount.toFixed(2);
                if(this.totalAmount < 0 || this.totalAmount > 0) {
                    this.checkAmountFlag = false;
                } else {
                    this.checkAmountFlag = true;
                }
            } else {
                this.editable = false;
            }

        })
        .catch(error => {
            console.log('error retriveRecordsFromServer '+JSON.stringify(error));
        });
    }

    showMessage(outcome, message){
        const evt = new ShowToastEvent({
            title: outcome,
            message: message,
            variant: outcome,
        });
        this.dispatchEvent(evt);
    }

    setTabColumns(){
        const columns = [
            { label: this.praticaFieldsInfo.data.fields.Name.label, fieldName: 'Name', type: 'text' },
            { label: this.accountFieldsInfo.data.fields.Name.label, fieldName: 'AccountName', type: 'text' },
            { label: this.praticaFieldsInfo.data.fields.CRABB_DEV__Stato__c.label, fieldName: 'Stato', type: 'text' },
            { label: this.strategiaFieldsInfo.data.fields.CRABB_DEV__Tipo_Servizio__c.label, fieldName: 'TipoServizio', type: 'text' },
            { label: this.praticaFieldsInfo.data.fields.CRABB_DEV__Data_Apertura__c.label, fieldName: 'DataApertura', type: 'date' },
            { label: this.praticaFieldsInfo.data.fields.CRABB_DEV__Esito_Ultima_Attivit_in_Lavorazione__c.label, fieldName: 'EsitoUltimaAttivitaLavorazione', type: 'text' },
            { label: this.praticaFieldsInfo.data.fields.CRABB_DEV__Residuo_Totale__c.label, fieldName: 'Scaduto', type: 'currency' },
            { label: 'Value', fieldName: 'Value', type: 'currency', editable: this.editable },
            { label: 'Note', fieldName: 'Esito', type: 'text', editable: this.editable }
        ];
        this.columns=columns;
    }

    isEditable(){
        isEditable({riconciliazioneId: this.recordId})
        .then(result => {
            this.editable = result;
            this.setTabColumns(); //define transalted labels for custom fields
            this.retriveRecordsFromServer(); //populate pratica table
            this.isLoading=false;
        })
        .catch(error => {
            console.log('error isEditable '+JSON.stringify(error));
        });
    }

    handleApproval(event){
        this.ApprovalStatus=event.target.dataset.status;
        this.showConfirmation=true;
    }

    handleConfirmation(event){
        this.isLoading=true;
        var conf=event.target.dataset.conferma;
        //console.log('#########################: ' + JSON.stringify(event.detail.draftValues));
        if(conf=="y"){
			if(this.ApprovalStatus == 'Approvata' && (parseFloat(this.valueSum) <= 0 || parseFloat(this.valueSum) > parseFloat(this.importoBonifico) || !parseFloat(this.importoBonifico))) {
				this.editable = true;
				this.showConfirmation = false;
				this.isLoading = false;
				this.showMessage('error', this.label.ToastErrorMessage);
				} else {
					updateStatus({riconciliazioneId: this.recordId,status:this.ApprovalStatus})
					.then(result => {
						console.log('aggiornamento fatto');
						updateRecord({ fields: { Id: this.recordId } });
						window.location.reload();
						this.editable=false;
						this.setTabColumns();
						this.showConfirmation=false;
						this.isLoading=false;
					})
					.catch(error => {
						console.log('error isEditable '+JSON.stringify(error));
					});
				}

        } else if(conf=="n"){
            //this.editable=true;
            this.showConfirmation=false;
            this.isLoading=false;
            //window.reload();
        }

    }


}