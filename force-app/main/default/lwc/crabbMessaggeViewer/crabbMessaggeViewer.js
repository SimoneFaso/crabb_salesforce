/**
 * Created by MatteoSala on 26/06/2020.
 */

import { LightningElement,api,track,wire } from 'lwc';

import getListMsg from '@salesforce/apex/CRABB_MsgViewerCtrl.ListMsg';

import lMsgViewr        from '@salesforce/label/c.MessageViewer'
import lMsgViewrNA      from '@salesforce/label/c.MessageViewerNA'
import lMsgViewrList    from '@salesforce/label/c.MessageViewerList'

export default class CrabbMessaggeViewer extends LightningElement
{
    label = {lMsgViewr,lMsgViewrNA,lMsgViewrList};

    @api recordId;
    @track lMsg;
    @track error;
    @track apexError;
    @track isMsg = false;

    @wire(getListMsg, { praticaid: '$recordId' })
    wiredMsg({ error, data })
    {
        if (data)
        {
            this.lMsg = data;

            if(this.lMsg.length > 0)
                this.isMsg = true;

            this.error = undefined;
            console.log('List: ' + JSON.stringify(this.lMsg));
        }
        else if (error)
        {
            this.lMsg = undefined;
            this.apexError = 'Unknown error';
            if (Array.isArray(error.body))
            {
                this.apexError = error.body.map(e => e.message).join(', ');
                console.log('Error: ' + JSON.stringify(this.apexError));
            }
            else if (typeof error.body.message === 'string')
            {
                this.apexError = error.body.message;
                console.log('Error: ' + this.apexError);
            }
        }
    }
    
}