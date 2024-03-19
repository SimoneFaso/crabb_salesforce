import { LightningElement, api } from 'lwc';

export default class CrabbManualResultFlow extends LightningElement {
    @api valueString; // Arrives from the Flow
    @api valueChosen; // Goes to the Flow
    picklistOptionValues = []; // Contains the options for the Picklist
    connectedCallback()
    {
        var arrayValues = this.valueString.split(';');
        for(var i = 0; i < arrayValues.length; i++)
        {
            if(i==0)
                this.valueChosen = arrayValues[i];
            this.picklistOptionValues.push(arrayValues[i]);
        }
    }
    assignValue(event)
    {
        this.valueChosen = event.target.value;
    }
}