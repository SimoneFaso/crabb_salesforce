import {LightningElement, api, track, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import elaborateScoring from '@salesforce/apex/CRABB_Scoring_ctrl.elaborateScoring';
import getAccountInfo from '@salesforce/apex/CRABB_Scoring_ctrl.getAccountInfo';

export default class CrabbScoring extends LightningElement {

    @api recordId;
    @track scoring;
    @track lastScoringUpdateDate;

    // initialize component (come init in aura component)
    connectedCallback() {
        
        getAccountInfo({accountId: this.recordId})
        .then(result => {
            console.log(' *** result -> '+JSON.stringify(result));
            if(result.CRABB_DEV__Scoring_Point__c){
                this.scoring=result.CRABB_DEV__Scoring_Point__c;
            }else{
                this.scoring='no scoring available';
            }

            if(result.CRABB_DEV__Last_scoring_evaluation_date__c){
                this.lastScoringUpdateDate=result.CRABB_DEV__Last_scoring_evaluation_date__c;
            }

        }).catch(error => {
            console.log('error handleSave '+JSON.stringify(error));
            this.showMessage('error',error.body.message + ' | ' + error.body.exceptionType);
        });
    }

    handleScoring(event){

        var recordIdList = [];
        recordIdList.push(this.recordId);

        elaborateScoring({recordIdList: recordIdList , objtype: 'Account'})
        .then(result => {
            this.showMessage('success','scoring updated');
            window.location.reload();
        }).catch(error => {
            console.log('error handleSave '+JSON.stringify(error));
            this.showMessage('error',error.body.message + ' | ' + error.body.exceptionType);
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

}