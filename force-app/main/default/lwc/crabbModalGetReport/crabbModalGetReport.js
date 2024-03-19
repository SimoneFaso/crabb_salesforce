/**
 * Created by Matteo on 05/08/2020.
 */

import { LightningElement , api , wire , track } from 'lwc';
import getDossierListView from '@salesforce/apex/CrabbEsitiMassiviCtrl.getDossierListView';
import getQueryListView from '@salesforce/apex/CrabbEsitiMassiviCtrl.getQueryListView';
import countQueryListViewRows from '@salesforce/apex/CrabbEsitiMassiviCtrl.countQueryListViewRows';
import getQueryListRows from '@salesforce/apex/CrabbEsitiMassiviCtrl.getQueryListRows';
//import getEsitiPickListValues from '@salesforce/apex/CrabbEsitiMassiviCtrl.getEsitiPickListValues';
import { NavigationMixin , CurrentPageReference } from 'lightning/navigation';

export default class CrabbModalGetReport extends NavigationMixin(LightningElement) {
    @track error;
    @track reportList=[];
    @track reportId;
    @api dossierList = [];
//    @track esitiOptions [];
    @wire(CurrentPageReference)
    currentPageReference;

    @wire(getDossierListView)
    populateReportList({error, data}){
        if(data){
            console.log(data);
            let rList = [];
            for(var r of data){
                rList.push( {value : r.Id , label : r.Name} );
            }
            this.reportList = [...rList];
        }else{
            console.log(error);
        }
    }

    goToTablePage(){
//        console.log(this.currentPageReference);
        console.log(window.location.origin);
        let dossiersIds= [];
        getQueryListView({ 'listViewId' : this.reportId })
        .then(result => {
            console.log(' getQueryListView -> '+result);
            countQueryListViewRows( { 'query' : result })
            .then(countQuery => {
                console.log(' countQueryListViewRows -> '+countQuery);

                this.getDossiersId(result);
                //this.getDossiersInfo(result, countQuery);
                //console.log('dossiersIds -> ' + dossiersIds);
                //countQueryListViewRows()
            })
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
        // Navigate to a URL
        /*this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName : 'CRABB_DEV__BulkOutcomeProcess'
            },
            state: {
                c__reportId: this.reportId
            }
        }
      );*/

    }

    async getDossiersId(query){
        console.log('Method getDossiersId - START')
        let offsetData = 0;
        let limitData = 2000;
        let totalRecordList = []; 
        let offsetValue = 'PR-000000';
        let jsonQuery = '';
        let appData;
        let jsonQueryStringify;

        while(true){
            console.log('Offset Value -> ' + offsetValue);
            let resQuery = await getQueryListRows( { 'query' : query , 'limitClause' : limitData , 'offsetClause' : offsetData, 'offsetValue' : offsetValue  })
            console.log(' resQuery -> ' + resQuery);

            totalRecordList = totalRecordList.concat(resQuery);

            if(resQuery.length == 0){
                break;
            }

            jsonQueryStringify = JSON.stringify(resQuery);
            jsonQuery = JSON.parse(jsonQueryStringify)
            let result = [];
            for(var i in jsonQuery) {
                result.push([i, jsonQuery[i]]);
            }
            console.log('result --> ' + result);
            appData = result[result.length - 1];
            offsetValue = appData[appData.length-1].Name;

        }
        const event = new CustomEvent('senddossierids', {
            detail: totalRecordList
        });
        this.dispatchEvent(event);
    }

    /* NEW TEST - START
    async getDossiersInfo(query, queryCount){
        let offsetData = 0;
        let limitData = 2000;
        let totalRecordList = [];

        while(true){
            let resQuery = await getQueryListRows( { 'query' : query , 'limitClause' : limitData , 'offsetClause' : offsetData  })
            console.log(' getQueryListRows -> '+resQuery);
            console.log(' getQueryRowsCount --> ' + queryCount);
            totalRecordList = totalRecordList.concat(resQuery);
            if(resQuery.length == 0){
                break;
            }
            offsetData += 2000;

        }
        const event = new CustomEvent('senddossierinfo', {
            detail: {
                recordList: this.totalRecordList,
                numberOfRecords: this.queryCount
            }
        });
        console.log('#### Event --> ' + event.detail.recorListì);
        console.log('#### Event --> ' + event.detail.numberOfRecords);
        this.dispatchEvent(event);
    }
    /* NEW TEST - END */

    handleReportChange(evt){
        this.reportId = evt.detail.value;
    }

    @api
    openModal(event){
        console.log('open modal report');
        this.template.querySelector('div[data-id=modalContainer]').classList.remove('slds-hide');
    }

    @api
    closeModal(){
        console.log('close modal report');
        this.template.querySelector('div[data-id=modalContainer]').classList.add('slds-hide');
    }
    close() {
        this.dispatchEvent(new CustomEvent('hide', {}));
    }

}