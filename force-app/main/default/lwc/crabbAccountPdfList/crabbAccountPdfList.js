/**
 * Created by User on 01/07/2021.
 */

import { LightningElement , api } from 'lwc';
import { crabbWebComponentApi } from 'c/crabbWebComponentApi';
export default class CrabbAccountPdfList extends LightningElement {
    @api recordId;
    connectedCallback(){
        let params = {
            "accountId" : recordId
        };
        crabbWebComponentApi.invokeApexMethodWithNoCache(params , 'AccountPdfListCtrl')
        .then( (result) => {
            console.log('result -> '+result);
        });
    }
}