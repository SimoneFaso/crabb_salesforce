/**
 * Created by Matteo on 05/08/2020.
 */

import { LightningElement , track } from 'lwc';
const pickVisibility = [
    { label : 'All_Task' , value : 'All_Task'},
    { label : 'My_Task' , value : 'My_Task'},
]
import getActivityExtendedData from '@salesforce/apex/CrabbEsitiMassiviCtrl.getActivityExtendedData';
import createObjects from '@salesforce/apex/CrabbEsitiMassiviCtrl.createObjects';
import createStepOne from '@salesforce/apex/CrabbEsitiMassiviCtrl.createStepOne';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class CrabbEsitiMassivi extends LightningElement {
    @track isLoading = false;
    @track isAffido;
    @track pickVisibilityResult = pickVisibility;
    @track selectedVisibility = 'All_Task';
    @track mapWrapper = [];
    @track mapSottoDisabled;
    @track mapTipoTotal;
    @track mapTipoOldest;
    @track dossierId = [];
    @track showModal=false;
    @track filteredDossiers = [];
    @track stepProcess = 1;
    @track tipoSottotipoKey;
    connectedCallback(){
        let limit = 50000;
        let offset = 0;
        getActivityExtendedData({ selectedVisibility : this.selectedVisibility , limitData : limit , offsetData : offset })
        .then(( data ) => {
            for(let key in data.mapWrapper) {
                // Preventing unexcepted data
                if (data.mapWrapper.hasOwnProperty(key)) { // Filtering the data in the loop
                    this.mapWrapper.push({value:data.mapWrapper[key], key:key});
                }
            }
            console.log('getActivityExtendedData Wrapper --> ' , data.mapWrapper);
            this.mapSottoDisabled = data.mapSottoDisabled;
            this.mapTipoTotal = data.mapTipoTotal;
            this.mapTipoOldest = data.mapTipoOldest;
            //this.dossierId = data.idPratiche;
        }).catch((error) => {
            console.error(error);
        });
        this.invokeGetActivityExtendedData();
    }

    async invokeGetActivityExtendedData(){
        let limit = 1000;
        let offset = 0;
        let step = 1000;
        let continueProcess = true;
        let dossierList = [];
        while(true){
            let res = await getActivityExtendedData({ selectedVisibility : this.selectedVisibility , limitData : limit , offsetData : offset });
            console.log('res -> ', res);
            if(res.idPratiche.length==0){
                break;
            }
            dossierList = dossierList.concat(  res.idPratiche );
            offset+=step;
        }
        this.dossierId = dossierList;

    }


    hidemodal(){
//        this.showModal = true;
        this.template.querySelector('c-crabb-modal-get-report').closeModal();
    }

    openModalReport(evt){
        console.log('show modal report')
        let eventData = evt.detail;
        this.tipoSottotipoKey = eventData.mapKey;
        createStepOne({ tipoesotto : eventData.mapKey , ownerOne : '' , idPratiche : this.dossierId })
        .then(( data ) => {
            console.log('createStepOne -> ' + JSON.stringify(data));
            this.template.querySelector('c-crabb-modal-get-report').openModal( { detail : data  } );
        }).catch((error) => {
            console.error(error);
        });

    }

    onchangeowner(){
        this.isLoading = true;
        createObjects({ selectedVisibility : this.selectedVisibility })
        .then(( data ) => {
            for(let key in data.mapWrapper) {
                // Preventing unexcepted data
                if (data.mapWrapper.hasOwnProperty(key)) { // Filtering the data in the loop
                    this.mapWrapper.push({value:data.mapWrapper[key], key:key});
                }
            }
            console.log(data.mapWrapper);
            this.mapSottoDisabled = data.mapSottoDisabled;
            this.mapTipoTotal = data.mapTipoTotal;
            this.mapTipoOldest = data.mapTipoOldest;
            this.isLoading = false;
        }).catch((error) => {
            console.error(error);
            this.isLoading = false;
        });
    }

     goToSecondStep(evt){
        console.log('goToSecondStep start ' + evt.detail);
        //let numberOfRecords = evt.detail.numberOfRecords;
        for(let dossierData of evt.detail){
            console.log('check dossier id -> ' + dossierData.Id);
            //console.log('check Record Count -> ' + dossierData)
            let searchingOk =  this.dossierId.find(element => element == dossierData.Id);
            //console.log('searchingOk -> ' + searchingOk);
            if(searchingOk){
                this.filteredDossiers.push(dossierData);
            }
            this.filteredDossiers.push(dossierData);
        }
        if(this.filteredDossiers.length == 0){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'No record',
                    message: 'Nessuna pratica trovata',
                    variant: 'warning',
                }),
            );
            return;
        }
        this.stepProcess = 2;
        this.template.querySelector('c-crabb-modal-get-report').closeModal(  );
        console.log('goToSecondStep end ', this.filteredDossiers );
        console.log('filteredDossiers lenght: ' + this.filteredDossiers.length);
    }

    get isStep1(){
        return this.stepProcess==1 ? true : false;
    }

    get isStep2(){
        return this.stepProcess==2 ? true : false;
    }

}