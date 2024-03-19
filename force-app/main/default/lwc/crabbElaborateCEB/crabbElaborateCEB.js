import { LightningElement, api, track, wire } from 'lwc';
import elaborateCEB from '@salesforce/apex/ElaborateCebCTRL.elaborateCEB';
import isInProgress from '@salesforce/apex/ElaborateCebCTRL.getCebStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ElaborateCebButton from '@salesforce/label/c.ElaborateCebButton';
import ElaborateCebTitle from '@salesforce/label/c.ElaborateCebTitle';
import ElaborateCebRefreshButton from '@salesforce/label/c.ElaborateCebRefreshButton';
import ElaborateCebRefreshMessage from '@salesforce/label/c.ElaborateCebRefreshMessage';

export default class CrabbElaborateCeb extends LightningElement {
    @api recordId;
    @track buttonEnabled;

    labels = { ElaborateCebButton, ElaborateCebTitle, ElaborateCebRefreshButton, ElaborateCebRefreshMessage };

    // initialize component (come init in aura component)
    connectedCallback() {
        this.buttonEnabled = true;
        this.isInProgress();
    }

    elaborateThisCEB(){

        elaborateCEB({recordId: this.recordId}).then(result => {
                this.showMessage('Success', 'Success'); 

           }).catch(error => {
                this.showMessage('Error', 'Error');
           });

           window.location.reload();
    }

    showMessage(outcome, message){
        const evt = new ShowToastEvent({
            title: outcome,
            message: message,
            variant: outcome, 
        }); 
        this.dispatchEvent(evt);
    }

    isInProgress(){
        isInProgress({recordId: this.recordId}).then(result => {
                if(result == 'In Progress') {
                    this.buttonEnabled = false;
                } else{
                    this.buttonEnabled = true;
                }
            });
    }

    refreshPage() {
        window.location.reload();
    }

}