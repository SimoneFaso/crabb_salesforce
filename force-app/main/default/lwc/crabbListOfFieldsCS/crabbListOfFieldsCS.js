import {LightningElement, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import onComponentLoad from '@salesforce/apex/CRABB_ListOfFieldsCS.onComponentLoad';
import removeRecord from '@salesforce/apex/CRABB_ListOfFieldsCS.removeRecord';
import retrieveListFields from '@salesforce/apex/CRABB_ListOfFieldsCS.retrieveListFields';
import retrieveTabObj from '@salesforce/apex/CRABB_ListOfFieldsCS.retrieveTabObj';
import addRecord from '@salesforce/apex/CRABB_ListOfFieldsCS.addRecord';
import addTabField from '@salesforce/apex/CRABB_ListOfFieldsCS.addTabField';
import updateRecords from '@salesforce/apex/CRABB_ListOfFieldsCS.updateRecords';

import Dossier_Information_Section from '@salesforce/label/c.Dossier_Information_Section';
import Transaction_Information_Section from '@salesforce/label/c.Transaction_Information';
import Transaction_Label from '@salesforce/label/c.Transaction';
import Dossier_Label from '@salesforce/label/c.Pratica';
import Geturl from '@salesforce/apex/AmministrazioneCTRL.getUrl';

export default class CrabbListOfFieldsCS extends LightningElement {

    labels = {Dossier_Information_Section, Transaction_Information_Section, Transaction_Label, Dossier_Label};
    @track spinner;
    @track obj;
    @track pageData;
    @track iconName;
    @track showDelete;
    @track rowToDelete;
    @track selectedTO;
    @track selectedOF;
    @track selectedTOFvisible;
    @track selectedOFLabel;
    @track selectedObj;
    @track selectedField;
    @track selectedVisible;
    @track isTab;
    @track isCSV;
    @track isPDF;
    @track tableData;

    @wire(Geturl) url;

    get previewPageURL()
    {
      return this.url.data+ "/apex/CRABB_DEV__EstrattoContoPage?type=preview";

    }
    get changeLogoPageURL()
    {
      return this.url.data+ "/apex/CRABB_DEV__ChangeLogoPage";

    }
    connectedCallback() {

        let self = this;
        this.spinner = true;
        let currentURL = new URL(window.location.href).searchParams;
        this.obj = currentURL.get('object__c');

        onComponentLoad({'obj': this.obj})
            .then((result) => {
                this.setData(result);
                console.log('result --' + JSON.stringify(result) );

            })
            .catch((error) => {
                console.log(error);
                this.showToast('Error', JSON.stringify(error), 'error');
                this.spinner = false;
            });
    }

    setData(result) {
        this.pageData = {};
        this.rowToDelete = {};
        this.selectedTO = '';
        this.selectedOF = '';
        this.selectedOFLabel = '';
        this.selectedTOFvisible = false;
        this.selectedObj = '';
        this.selectedField = '';
        this.selectedVisible = false;
        if (result.isSuccess) {
            this.pageData = result.Data;
            if (this.obj === 'TAB') {
                this.isTab = true;
                this.iconName = "custom:custom102";

                let mapShowTF = this.pageData.mapShowTF;
                let mapTabFields = this.pageData.mapTabFields;
                this.pageData.listLOF.forEach(function (lof) {
                    if (mapShowTF[lof.CRABB_DEV__Field__c] == true) {
                        lof.showRows = true;
                        lof.rows = mapTabFields[lof.CRABB_DEV__Field__c];
                    }
                    if (lof.CRABB_DEV__Field__c == 'Expired Amounts Ageing' ||
                        lof.CRABB_DEV__Field__c == 'Statement of Account' ||
                        lof.CRABB_DEV__Field__c == 'Activities') {
                        lof.disabled = true;
                        lof.class = "greenCell";
                    }
                });


            } else if (this.obj === 'CSVNEW') {
                this.isCSV = true;
                this.iconName = "doctype:csv";

                let mapIdRecordOrder = this.pageData.mapIdrecordOrder;
                this.pageData.listLOF.forEach(function (lof) {
                    lof.object = lof.CRABB_DEV__Object__c.substr(5);
                    lof.field = lof.CRABB_DEV__Field__c;
                    lof.order = mapIdRecordOrder[lof.Id];
                });

            } else if (this.obj === 'PDF') {
                this.isPDF = true;
                this.iconName = "doctype:pdf";
                let mapIdRecordOrder = this.pageData.mapIdrecordOrder;
                                
                this.pageData.listLOF.forEach(function (lof) {
                    if (lof.Name.startsWith('Pdf_') &&
                        lof.CRABB_DEV__Object__c == 'Pratica__c'){
                        lof.object = Dossier_Label;
                        lof.isTable1 = true;}
                    else{
                        lof.isTable2 = true;
                        lof.object = Transaction_Label;  
                    }
                    //lof.object = lof.CRABB_DEV__Object__c;
                  // lof.object = this.pagedata.mapObjLabel['CRABB_DEV__'+lof.CRABB_DEV__Object__c];
                   lof.field = lof.CRABB_DEV__Field__c;
                    lof.fieldLabel = lof.CRABB_DEV__Field_Label__c;
                    lof.order = mapIdRecordOrder[lof.Id];
                });

            }
        } else {

            this.showToast('Error', result.Message, 'error');
            onComponentLoad({'obj': this.obj})
                .then((result) => {
                    this.setData(result);

                })
                .catch((error) => {
                    console.log(error);
                    this.showToast('Error', JSON.stringify(error), 'error');
                    this.spinner = false;
                });
        }
        this.spinner = false;
    }

    showRows(event) {
        let template = this.template.querySelectorAll('[data-id="' + event.currentTarget.name + '"]');
        template.forEach(function (tr) {
            tr.classList.toggle('slds-hide');
        });
    }

    deleteRow(event) {
        this.rowToDelete = event.currentTarget.dataset;
        this.showDelete = true;
    }

    closeDelete() {
        this.showDelete = false;
    }

    removeRecord(event) {
        this.spinner = true;
        removeRecord({'obj': this.obj, 'id': event.currentTarget.dataset.id})
            .then((result) => {
                this.showDelete = false;
                this.setData(result);
            })
            .catch((error) => {
                console.log(error);
                this.showToast('Error', JSON.stringify(error), 'error');
                this.spinner = false;
            });

    }

    setSelectedObj(event) {
        this.spinner = true;
        this.selectedObj = event.target.value;

        retrieveListFields({'selectedObj': this.selectedObj})
            .then((result) => {
                this.pageData.listFields = result.Data.listFields;
                this.pageData.listStrFields = result.Data.listStrFields;
                this.spinner = false;
            })
            .catch((error) => {
                console.log(error);
                this.showToast('Error', JSON.stringify(error), 'error');
                this.spinner = false;
            });
    }

    retrieveTabObj(event) {

        this.spinner = true;
        this.selectedTO = event.target.value;

        retrieveTabObj({'selectedTO': this.selectedTO})
            .then((result) => {
                this.pageData.listObjFieldOptions = result.Data.listObjFieldOptions;
                this.spinner = false;
            })
            .catch((error) => {
                console.log(error);
                this.showToast('Error', JSON.stringify(error), 'error');
                this.spinner = false;
            });
    }

    add() {
        this.spinner = true;
        if (this.isTab) {

            addTabField({
                'selectedOF': this.selectedOF,
                'selectedTO': this.selectedTO,
                'selectedTOFvisible': this.selectedTOFvisible,
                'obj': this.obj,
                'selectedFieldLabel': this.selectedOFLabel
                
            })
                .then((result) => {
                    this.setData(result);
                })
                .catch((error) => {
                    console.log('error', error);
                    this.showToast('Error', JSON.stringify(error), 'error');
                    this.spinner = false;
                });
        } else {
            addRecord({
                'selectedObj': this.selectedObj,
                'selectedField': this.selectedField,
                'obj': this.obj,
                'selectedVisible': this.selectedVisible,
                'selectedFieldLabel': this.pageData.listStrFields[this.selectedField]
            })
                .then((result) => {
                    this.setData(result);
                })
                .catch((error) => {
                    console.log('error', error);
                    this.showToast('Error', JSON.stringify(error), 'error');
                    this.spinner = false;
                });
        }
    }

    setSelectedTOFvisible(event) {
        this.selectedTOFvisible = event.target.checked;
    }

    setSelectedVisible(event) {
        this.selectedVisible = event.target.checked;
    }

    setSelectedOF(event) {
        this.selectedOF = event.target.value;
        this.selectedOFLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
    }

    setSelectedField(event) {
        this.selectedField = event.target.value;
    }

    get disabledAdd() {
        if (this.isTab) {
            if (this.selectedOF != null && this.selectedTO != null) {
                return false;
            } else {
                return true;
            }
        } else {
            if (this.selectedObj != null && this.selectedField != null) {
                return false;
            } else {
                return true;
            }
        }
    }

    save() {
        this.spinner = true;
        this.pageData.listLOF.forEach(function (lof) {
            delete lof.showRows;
            delete lof.rows;
            delete lof.disabled;
            delete lof.class;

        });
        updateRecords({
            'pageDataStr': JSON.stringify(this.pageData)
        })
            .then((result) => {
                this.setData(result);
            })
            .catch((error) => {
                console.log('error', error);
                this.showToast('Error', JSON.stringify(error), 'error');
                this.spinner = false;
            });
    }

    setTabFieldVisible(event) {
        let value = event.target.checked;
        let id = event.target.name;

        let self = this;
        this.pageData.listLOF.forEach(function (lof) {
            if (lof.showRows) {
                lof.rows.forEach(function (rowItem) {
                    if (rowItem.Id == id) {
                        rowItem.CRABB_DEV__Show__c = value;
                        self.pageData.mapTabFields[lof.CRABB_DEV__Field__c].forEach(function (tabField) {
                            if (tabField.Id == id) {
                                tabField.CRABB_DEV__Show__c = value;
                            }
                        });
                    }
                });
            }

        });
    }

    setVisible(event) {

        let value = event.target.checked;
        let id = event.target.name;

        let self = this;
        this.pageData.listLOF.forEach(function (lof) {
            if (lof.Id == id) {
                lof.CRABB_DEV__Show__c = value;
            }
        });
    }

    setOrder(event) {

        let value = event.target.value;
        let id = event.target.name;

        let self = this;
        this.pageData.listLOF.forEach(function (lof) {
            if (lof.Id == id) {
                lof.order = value;
                self.pageData.mapIdrecordOrder[lof.Id] = value;
            }
        });
    }

    //generic method to show Toast
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}