/**
 * Created by MatteoSala on 09/07/2020.
 */

import { LightningElement, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getListObjectStatic from "@salesforce/apex/CRABB_FlussiCollectorMapNewCTRL.getListObjectStatic";
import retrieveListFieldsStatic from "@salesforce/apex/CRABB_FlussiCollectorMapNewCTRL.retrieveListFieldsStatic";
import retrieveListOfFieldsRecords from "@salesforce/apex/CRABB_FlussiCollectorMapNewCTRL.retrieveListOfFieldsRecords";
import addCSVNEWRecord from "@salesforce/apex/CRABB_FlussiCollectorMapNewCTRL.addCSVNEWRecord";
import getListStrFieldsReversed from "@salesforce/apex/CRABB_FlussiCollectorMapNewCTRL.getListStrFieldsReversed";
import removeRecordsLightning from "@salesforce/apex/CRABB_FlussiCollectorMapNewCTRL.removeRecordsLightning";
import rearrangeRecordsLightning from "@salesforce/apex/CRABB_FlussiCollectorMapNewCTRL.rearrangeRecordsLightning";
import updateRecordsLightning from "@salesforce/apex/CRABB_FlussiCollectorMapNewCTRL.updateRecordsLightning";

import flowColTitle from '@salesforce/label/c.Flow_Collector_Title';
import save from '@salesforce/label/c.Save';
import objField from '@salesforce/label/c.Field_Object';
import labField from '@salesforce/label/c.Field_Label';
import setIsVis from '@salesforce/label/c.Set_Is_Visible';
import add from '@salesforce/label/c.Add';
import close from '@salesforce/label/c.Close';
// import insTotAmount from '@salesforce/label/c.Total_Installments_Amount';
import delRecord from '@salesforce/label/c.Deleting_Record';
import obj from '@salesforce/label/c.Object';
import field from '@salesforce/label/c.Fileld';
import canc from '@salesforce/label/c.Cancel';
import del from '@salesforce/label/c.Delete';

export default class ListOfFieldsCSVNEW extends LightningElement{

    label = {flowColTitle,save,objField,labField,setIsVis,add,close,delRecord,obj,field,canc,del};

    // Field Object
    fieldObjectValue = null;

    @track
    fieldObjectOptions = [{ label: "-- None --", value: null }];

    // Field Label
    fieldLabelValue = null;

    @track
    fieldLabelOptions = [{ label: "-- None --", value: null }];

    @track
    isVisibleValue = true;

    // Modal
    @track
    openModalBool = false;

    @track
    listLOF = null;
    listLOFComplete = null;

    error;
    dataTableInitialized = false;

    @track
    draggingInfo = {};

    @track
    addButtonDisabled = false;

    @track
    tableDraggable = true;

    fieldSearch = "";
    objectSearch = "";

    // we will store here the item to be deleted
    tobeDeleted = {};

    get toBeDeletedObjApiName()
    {
        return this.tobeDeleted.CRABB_DEV__Object__c.replace("CSV||", "");
    }

    get itemUnder() {
        return this.draggingInfo.itemUnderId;
    }

    @wire(getListObjectStatic, { what: "CSVNEW" })
    wiredFieldObject({ error, data }) {
        if (data) {
            data = JSON.parse(data);

            let tempArray = [];

            Object.keys(data).forEach(key => {
                let newObject = {
                    label: key,
                    value: data[key]
                };

                tempArray.push(newObject);
            });

            this.fieldObjectOptions = this.sortOptionsByLabel(tempArray);
        } else if (error) {
            this.error = error;
            this.fieldObjectOptions = [];
        }
    }

    @wire(retrieveListFieldsStatic, { selectedObj: "$fieldObjectValue" })
    wiredFieldLabel({ error, data }) {
        let tempArray = [];
        if (data) {
            data = JSON.parse(data);

            Object.keys(data).forEach(key => {
                let newObject = {
                    label: key,
                    value: data[key]
                };

                tempArray.push(newObject);
            });

            this.fieldLabelOptions = this.sortOptionsByLabel(tempArray);
        } else if (error) {
            this.fieldLabelOptions = [{ label: "-- None --", value: null }];
        }
    }

    constructor() {
        super();

        this.fetchListOfFields();
    }

    async onSavePressed() {

        try {

            let result = await updateRecordsLightning({
                records: JSON.stringify(this.listLOFComplete)
            });

            result = JSON.parse(result);

            if (result.error) {
                throw new Error(result.error)
            }

            await this.fetchListOfFields();

            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Saving",
                    message: "Records have been saved.",
                    variant: "success",
                    mode: "dismissable"
                })
            );

        } catch (e) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error Saving Records",
                    message: e.message,
                    variant: "error",
                    mode: "dismissable"
                })
            )
        }


    }

    onFieldObjectChange(event) {
        this.fieldObjectValue = event.detail.value;
    }

    onFieldLabelChanged(event) {
        this.fieldLabelValue = event.detail.value;
    }

    async onAddPressed() {
        try {
            if (!this.fieldObjectValue) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error Adding Record",
                        message: "Please Select Field Object.",
                        variant: "error",
                        mode: "dismissable"
                    })
                );

                return;
            }

            if (!this.fieldLabelValue) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error Adding Record",
                        message: "Please Select Field Label.",
                        variant: "error",
                        mode: "dismissable"
                    })
                );

                return;
            }

            this.addButtonDisabled = true;

            const listStrFields = await getListStrFieldsReversed({
                selectedObj: this.fieldObjectValue
            });

            const parsedListStrFields = JSON.parse(listStrFields);

            for (let i = 0; i < this.listLOF.length; i++) {
                const elLabel =
                    parsedListStrFields[this.listLOF[i].CRABB_DEV__Field_Label__c];

                if (elLabel === this.fieldLabelValue) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error Adding Record",
                            message: "Record with this field label already exists.",
                            variant: "warning",
                            mode: "dismissable"
                        })
                    );

                    this.addButtonDisabled = false;

                    return;
                }
            }

            const result = await addCSVNEWRecord({
                selectedObj: this.fieldObjectValue,
                selectedField: this.fieldLabelValue,
                selectedVisible: this.isVisibleValue
            });

            this.addButtonDisabled = false;
            if (result) {
                await this.fetchListOfFields();
                this.resetSelectedValues();
            } else {
                throw new Error("Could not add new record for some reason!");
            }
        } catch (e) {
            throw new Error(e);
        }
    }

    resetSelectedValues() {
        this.fieldObjectValue = null;
        this.fieldLabelValue = null;
        this.isVisibleValue = true;
    }

    onIsVisibleChanged() {
        this.isVisibleValue = !this.isVisibleValue;
    }

    sortOptionsByLabel(array) {
        let arrayToInsert = array.sort((a, b) => {
            return a.label < b.label ? -1 : 1;
        });

        arrayToInsert.unshift({ label: "-- None --", value: null });
        return arrayToInsert;
    }

    async fetchListOfFields() {
        try {
            const result = await retrieveListOfFieldsRecords({
                selectedObj: "CSVNEW"
            });

            this.listLOFComplete = JSON.parse(result);
            this.listLOF = JSON.parse(result);

            this.closeModal();
            this.draggable = true;
        } catch (e) {
            throw new Error(e.message);
        }
    }

    //Drag and drop functions
    handleListItemDrag(evt) {
        this.draggingInfo.isDragging = true;
        this.draggingInfo.draggedItemId = evt.detail;
    }

    async handleItemDrop() {

        try {
            if (this.draggingInfo.itemUnderId === this.draggingInfo.draggedItemId) {
                this.draggingInfo = {};
                return;
            }

            if (this.listLOF.length !== this.listLOFComplete.length) {
                this.draggingInfo = {};
                return;
            }

            if (this.draggingInfo.itemUnderId && this.draggingInfo.draggedItemId) {

                this.draggable = false;

                let previousIndex;
                let newIndex;

                for (let i = 0; i < this.listLOF.length; i++) {

                    if (this.listLOF[i].Id === this.draggingInfo.draggedItemId)
                        previousIndex = i;

                    if (this.listLOF[i].Id === this.draggingInfo.itemUnderId)
                        newIndex = i;
                }

                if (previousIndex === newIndex) {
                    return
                }

                if (previousIndex > newIndex) {
                    newIndex++;
                }

                this.listLOF = this.arrayMove(this.listLOF, previousIndex, newIndex);

                let records = JSON.stringify(this.getChangesObject());

                this.draggingInfo = {};

                await rearrangeRecordsLightning({ records });

                await this.fetchListOfFields();

            }
        } catch (e) {
            throw new Error(e);
        }
    }

    handleItemOver(evt) {
        if (!this.draggingInfo.itemUnderId) {
            this.draggingInfo.itemUnderId = evt.detail;

            return;
        }

        if (this.draggingInfo.itemUnderId !== evt.detail) {
            this.draggingInfo.itemUnderId = evt.detail;
        }
    }

    handleListItemNewOrder(evt) {

        let listItem = this.getListItemById(evt.detail.fieldId);

        const listBefore = JSON.parse(JSON.stringify(this.listLOF));

        if (listItem === null)
            throw new Error("No item in listLOF with this fieldId");

        for (let i = 0; i < this.listLOFComplete.length; i++) {

            if (this.listLOFComplete[i].Name === evt.detail.newName) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error Updating Record",
                        message: "Another field already has this order number.",
                        variant: "error",
                        mode: "dismissable"
                    })
                );

                this.listLOF = listBefore;
                return;
            }

        }

        listItem.Name = evt.detail.newName;

        // saving the change to the complete list as well
        let originalItemIndex = this.getItemFromComplete(listItem);
        this.listLOFComplete[originalItemIndex].Name = evt.detail.newName;
    }

    handleListItemVisibleChanged(evt) {

        let listItem = this.getListItemById(evt.detail.fieldId);

        if (listItem === null)
            throw new Error("No item in listLOF with this fieldId");

        listItem.CRABB_DEV__Show__c = evt.detail.isVisible;

        // saving the change to the complete list as well
        let originalItemIndex = this.getItemFromComplete(listItem);
        this.listLOFComplete[originalItemIndex].CRABB_DEV__Show__c = evt.detail.isVisible;
    }

    getChangesObject() {
        // the old order of the array
        const initialPos = this.listLOFComplete.map(element => {
            return {
                id: element.Id,
                name: element.Name
            };
        });

        // the new order of the array
        const updatedPos = this.listLOF.map(element => {
            return {
                id: element.Id,
                name: element.Name
            };
        });

        if (initialPos.length !== updatedPos.length) {
            this.draggingInfo = {};
            throw new Error(
                "initialPos array should have the same length as updatedPos"
            );
        }

        let changesObject = {};

        updatedPos.forEach(function (record, index) {
            if (record.name !== initialPos[index].name) {
                changesObject[record.id] = initialPos[index].name;
            }
        });

        return changesObject;
    }

    handleObjectNameSearch(evt) {
        this.objectSearch = evt.detail;
        this.filterOnSearch();
    }

    handleFieldNameSearch(evt) {
        this.fieldSearch = evt.detail;
        this.filterOnSearch();
    }

    filterOnSearch() {
        this.listLOF = this.listLOFComplete;

        if (
            (!this.fieldSearch.length || !this.fieldSearch) &&
            (!this.objectSearch.length || !this.objectSearch)
        ) {
            this.draggable = true;
            return;
        }

        this.draggable = false;

        if (this.objectSearch.length > 0) {
            this.listLOF = this.listLOF.filter(element => {
                const elObjectName = element.CRABB_DEV__Object__c.replace(
                    "CSV||",
                    ""
                );
                return elObjectName
                    .toLowerCase()
                    .includes(this.objectSearch.toLowerCase());
            });
        }

        if (this.fieldSearch.length > 0) {
            this.listLOF = this.listLOF.filter(element => {
                const elObjectName = element.CRABB_DEV__Field__c;
                return elObjectName
                    .toLowerCase()
                    .includes(this.fieldSearch.toLowerCase());
            });
        }
    }

    handleListItemDelete(evt) {
        let listItem = this.getListItemById(evt.detail.fieldId);

        if (listItem === null)
            throw new Error("No item in listLOF with this fieldId");

        this.tobeDeleted = listItem;

        this.openDeleteModal();
    }

    getListItemById(listItemId) {
        for (let i = 0; i < this.listLOF.length; i++) {
            if (this.listLOF[i].Id === listItemId) return this.listLOF[i];
        }

        return null;
    }

    // move item in array from one index to another
    arrayMove(arr, old_index, new_index) {
        if (new_index >= arr.length) {
            let k = new_index - arr.length + 1;
            while (k--) {
                arr.push(undefined);
            }
        }
        arr.splice(new_index, 0, arr.splice(old_index, 1)[0]);
        return arr;
    }

    getItemFromComplete(listItem) {

        for (let i = 0; i < this.listLOFComplete.length; i++) {
            if (this.listLOFComplete[i].Id === listItem.Id)
                return i;
        }

        throw new Error("No such item found in original list");
    }


    //Modal functions
    openDeleteModal() {
        this.openModalBool = true;
    }

    closeModal() {
        this.openModalBool = false;
        this.tobeDeleted = null;
    }

    async deleteMethod() {
        try {
            await removeRecordsLightning({
                objectId: this.tobeDeleted.Id
            });

            this.fetchListOfFields();
        } catch (e) {
            throw new Error(e);
        }
    }
}