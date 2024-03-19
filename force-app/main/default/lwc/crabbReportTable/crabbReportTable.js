/**
 * Created by Matteo on 04/08/2020.
 */

import { LightningElement , track , wire , api} from 'lwc';
import getTableData from '@salesforce/apex/CrabbDynamicTableCtrl.getTableData';
import { NavigationMixin , CurrentPageReference } from 'lightning/navigation';

export default class CrabbDynamicTable extends LightningElement {
    @track columns=[];
    @track data = [];
    @track tableKey;
    @track isLoading = true;
    @api reportName;
    @track sortBy;
    @track sortDirection;

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
//        this.currentPageReference = currentPageReference;
        console.log('current page ref state ' , currentPageReference.state);
        this.reportName= currentPageReference.state.c__reportId;
    }

    @wire(getTableData , { reportName : '$reportName' })
    populateTable({ error , data}){
        this.isLoading = false;
        if(data){
            console.log(data);
            this.columns = data.columns;
            this.data = data.data;
            this.tableKey = data.tableKey;
        }else{
            if(error) console.error(error);
        }
    }

    get isDataPopulated(){
        return this.data.length>0 ? true : false;
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));
        // Return the value stored in the field
        console.log('fieldname ' + fieldname );
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        console.log('direction ' + direction );
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
    }

}