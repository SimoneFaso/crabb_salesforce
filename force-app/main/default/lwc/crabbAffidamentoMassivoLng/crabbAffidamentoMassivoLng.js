/**
 * Created by User on 11/07/2022.
 */

/*** SFDC ***/
import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import currencySymbol from '@salesforce/i18n/number.currencySymbol';

/*** CLASSES ***/
import getQueryListView         from '@salesforce/apex/CrabbAffidamentoMassiviLngCtrl.getQueryListView';
import getSelezioni             from '@salesforce/apex/CrabbAffidamentoMassiviLngCtrl.getSelezioni';
import getMaxRecords            from '@salesforce/apex/CrabbAffidamentoMassiviLngCtrl.getMaxRecords';
import countQueryListViewRows   from '@salesforce/apex/CrabbAffidamentoMassiviLngCtrl.countQueryListViewRows';
import getQueryListRows         from '@salesforce/apex/CrabbAffidamentoMassiviLngCtrl.getQueryListRows';
import availableCollectors      from '@salesforce/apex/CrabbAffidamentoMassiviLngCtrl.availableCollectors';
import distributeDossiers       from '@salesforce/apex/CrabbAffidamentoMassiviLngCtrl.distributeDossiers';
import finalizzaLotti           from '@salesforce/apex/CrabbAffidamentoMassiviLngCtrl.finalizzaLotti';

/*** LABELS ***/
import EsitiMassiviButtonProcedi from '@salesforce/label/c.EsitiMassiviButtonProcedi';
import EsitiMassiviButtonIndietro from '@salesforce/label/c.EsitiMassiviButtonIndietro';
import EsitiMassiviSelectType from '@salesforce/label/c.EsitiMassiviSelectType';
import EsitiMassiviSelectDossierListView from '@salesforce/label/c.EsitiMassiviSelectDossierListView';
import EsitiMassiviNoListViewFound from '@salesforce/label/c.EsitiMassiviNoListViewFound';
import EsitiMassiviSelectionContains from '@salesforce/label/c.EsitiMassiviSelectionContains';
import EsitiMassiviYourSelection from '@salesforce/label/c.EsitiMassiviYourSelection';
import EsitiMassiviRecord from '@salesforce/label/c.EsitiMassiviRecord';
import EsitiMassiviBackToMod from '@salesforce/label/c.EsitiMassiviBackToMod';
import EsitiMassiviProceedToDetails from '@salesforce/label/c.EsitiMassiviProceedToDetails';
import EsitiMassiviMaxOutcomeInfo from '@salesforce/label/c.EsitiMassiviMaxOutcomeInfo';
import EsitiMassiviClickToUpdateInfo from '@salesforce/label/c.EsitiMassiviClickToUpdateInfo';
import EsitiMassiviOperationComplete from '@salesforce/label/c.EsitiMassiviOperationComplete';
import EsitiMassiviStartProcess from '@salesforce/label/c.EsitiMassiviStartProcess';
import EsitiMassiviRefreshButton from '@salesforce/label/c.EsitiMassiviRefreshButton';
import EsitiMassiviCloseButton from '@salesforce/label/c.EsitiMassiviCloseButton';
import EsitiMassiviRecordToOutcome from '@salesforce/label/c.EsitiMassiviRecordToOutcome';
import EsitiMassiviContains from '@salesforce/label/c.EsitiMassiviContains';
import EsitiMassiviNoTypeFound from '@salesforce/label/c.EsitiMassiviNoTypeFound';
import EsitiMassiviNoExternalAuth from '@salesforce/label/c.EsitiMassiviNoExternalAuth';
import BulkAssignmentTitle from '@salesforce/label/c.BulkAssignmentTitle';
import Order from '@salesforce/label/c.Order';
import Ass from '@salesforce/label/c.Assignments';
import EuroEntrusted from '@salesforce/label/c.EuroEntrusted';
import Prelot from '@salesforce/label/c.PreLot';
import Code from '@salesforce/label/c.Code';
import Effective from '@salesforce/label/c.Effective';
import Affido_Massivo_Step_1 from '@salesforce/label/c.Affido_Massivo_Step_1';
import Affido_Massivo_Step_2 from '@salesforce/label/c.Affido_Massivo_Step_2';
import Affido_Massivo_Step_3 from '@salesforce/label/c.Affido_Massivo_Step_3';
import Affido_Massivo_Step_4 from '@salesforce/label/c.Affido_Massivo_Step_4';
import Affido_Massivo_Step_5 from '@salesforce/label/c.Affido_Massivo_Step_5';
import Affido_Massivo_Step_6 from '@salesforce/label/c.Affido_Massivo_Step_6';
import PreAssignment_in_Creation from '@salesforce/label/c.PreAssignment_in_Creation';
import TheTableShows from '@salesforce/label/c.TheTableShows';
import YouCanWorkThemLater from '@salesforce/label/c.YouCanWorkThemLater';
import ManageLotAssignement from '@salesforce/label/c.ManageLotAssignement';
import OrProcessThemNow from '@salesforce/label/c.OrProcessThemNow';
import OnceTheAssignmentsHaveBeenCreated from '@salesforce/label/c.OnceTheAssignmentsHaveBeenCreated';
import workpreassignments from '@salesforce/label/c.WorkPreAssignments';

/*** CONST ***/
const minStep = 1;
const maxStep = 6;

export default class CrabbAffidamentoMassivoLng extends NavigationMixin(LightningElement)
{
    labels =
    {
        EsitiMassiviButtonProcedi,
        EsitiMassiviButtonIndietro,
        EsitiMassiviSelectType,
        EsitiMassiviSelectDossierListView,
        EsitiMassiviNoListViewFound,
        EsitiMassiviSelectionContains,
        EsitiMassiviYourSelection,
        EsitiMassiviRecord,
        EsitiMassiviBackToMod,
        EsitiMassiviProceedToDetails,
        EsitiMassiviMaxOutcomeInfo,
        EsitiMassiviClickToUpdateInfo,
        EsitiMassiviOperationComplete,
        EsitiMassiviStartProcess,
        EsitiMassiviRefreshButton,
        EsitiMassiviCloseButton,
        EsitiMassiviRecordToOutcome,
        EsitiMassiviContains,
        EsitiMassiviNoTypeFound,
        EsitiMassiviNoExternalAuth,
        BulkAssignmentTitle,
        Order,
        Ass,
        EuroEntrusted,
        Prelot,
        Code,
        Effective,
        Affido_Massivo_Step_1,
        Affido_Massivo_Step_2,
        Affido_Massivo_Step_3,
        Affido_Massivo_Step_4,
        Affido_Massivo_Step_5,
        Affido_Massivo_Step_6,
        PreAssignment_in_Creation,
        TheTableShows,
        YouCanWorkThemLater,
        ManageLotAssignement,
        OrProcessThemNow,
        OnceTheAssignmentsHaveBeenCreated,
        workpreassignments
    };

    AlgType = [
        {value: 'RR',   label: 'Round Robin - ABCABC',          selected: true},
        {value: 'RRR',  label: 'Reverse Round Robin - ABCCBA'},
        {value: 'FIFO', label: 'First In Fisrt Out - AABBCC'}
    ];

    collectorColumns = [
        { label: 'Id Collector',        fieldName: 'Collector',             type: 'text' },
        { label: 'Name Collector',      fieldName: 'CollectorName',         type: 'text' },
        { label: Order,                 fieldName: 'Order',                 type: 'number' },
        { label: 'N° ' + Ass,           fieldName: 'TotAssignment',         type: 'number' },
        { label: EuroEntrusted,         fieldName: 'EuroEntrusted',         type: 'currency' , typeAttributes: { currency: currencySymbol, }, cellAttributes: { alignment: 'left' }},
        { label: '% ' + Ass,            fieldName: 'PercentAssignments',    type: 'percent', typeAttributes: { step: '0.01' }, editable: true},
        { label: '% Default',           fieldName: 'PercentDefault',        type: 'percent', typeAttributes: { step: '0.01' }},
        { label: '% ' + Effective,      fieldName: 'PercentEffective',      type: 'percent', typeAttributes: { step: '0.01' }},
        { label: Prelot + ' ' + Code,   fieldName: 'PreLot',                type: 'text' },
    ];

    distributionColumns = [
       { label: 'Id Collector',        fieldName: 'Collector',             type: 'text' },
       { label: 'Name Collector',      fieldName: 'CollectorName',         type: 'text' },
       { label: Order,                 fieldName: 'Order',                 type: 'number' },
       { label: 'N° ' + Ass,           fieldName: 'TotAssignment',         type: 'number' },
       { label: EuroEntrusted,         fieldName: 'EuroEntrusted',         type: 'currency' , typeAttributes: { currency: currencySymbol, }, cellAttributes: { alignment: 'left' }},
       { label: '% ' + Ass,            fieldName: 'PercentAssignments',    type: 'percent', typeAttributes: { step: '0.01' }},
       { label: '% ' + Effective,      fieldName: 'PercentEffective',      type: 'percent', typeAttributes: { step: '0.01' }}
   ];

   preLottoColumns = [
      { label: 'Pre Lot',             fieldName: 'PreLot',                type: 'text' },
      { label: 'Type',                fieldName: 'Tipo',                  type: 'text' },
      { label: 'Status',              fieldName: 'Stato',                 type: 'text' },
      { label: 'Name Collector',      fieldName: 'CollectorName',         type: 'text' },
      { label: Order,                 fieldName: 'Order',                 type: 'number' },
      { label: 'N° ' + Ass,           fieldName: 'TotAssignment',         type: 'number' },
      { label: EuroEntrusted,         fieldName: 'EuroEntrusted',         type: 'currency' , typeAttributes: { currency: currencySymbol, }, cellAttributes: { alignment: 'left' }},
      { label: '% ' + Effective,      fieldName: 'PercentEffective',      type: 'percent', typeAttributes: { step: '0.01' }}
  ];
    
    @track isLoading = true;
    @track stepProcess = 1;
    @track sP = "1";
    isAvanti = false;
    isIndietro = false;
    isTS = false;
    isLV = false;
    @track isCollectorSelected = false;
    @track isSummary = false;
    @track isPreLotti = false;
    @track collectorsData = [];
    @track distributionData = [];
    @track preLottiData = [];
    @track TaskType;
    @track optionSelected;
    @track ListView;
    @track reportId;
    @track countQuery;
    @track filteredDossiers = [];
    @track totalRecordList = [];
    @track selectedRecordList = [];
    @track finalOutcome;
    @track finalOutcomeType;
    @track maxRecords;
    @track disableCloseProcedureButton = true;
    @track disableRefreshButton = false;
    @track isProcessing = true;
    @track batchInformation = new Map();
    @track retrievedRows = [];
    @track tableRecords = [];
    @track TotalJobItems;
    @track JobItemsProcessed;
    @track batchStatus;
    @track NumberOfErrors;
    @track batchId;
    @track selectedRows = [];
    @track options;
    @track Algoritmo = 'RR';
    @track sData;
    @track lCollectors = [];
    @track collPE = [];
    @track collectorDraftValues = [];
    distribResult = [];

    _selected = [];

    get selected() {
        return this._selected.length ? this._selected : 'none';
    }

    AlgSelection(e)
    {
        console.log('AlgSelection => ' + JSON.stringify(e.detail));
        //this.Algoritmo = JSON.stringify(e.detail.value);
        this.Algoritmo = e.detail.value;
        console.log('AlgSelection => ' + this.Algoritmo);
    }

    handleChange(e)
    {
        this._selected = e.detail.value;

        if(this.selected==='none')
        {
            this.collectorsData = [];
            this.isCollectorSelected = false;
        }
        else
        {
            this.collectorsData = [];
            let order = 1;
            let pe = 1;
            let totPerc = 0;

            this.selected.forEach(coll =>
            {
                this.lCollectors.forEach(c =>
                {
                    if(c.Id === coll)
                    {
                        totPerc += c.CRABB_DEV__Percentuale_Affido_Standard__c;
                    }
                });
            });

            this.selected.forEach(coll =>
            {
                let pa = 1;
                let pe = 0;
                let totAss = 0;
                let collName = 'NA';
                this.options.forEach(o =>
                {
                    if(coll === o.value)
                        collName = o.label;
                })
                console.log('CollectorsPush => ' + JSON.stringify(this.collectorsData));
                console.log('CollectorsPush => ' + order);

                this.lCollectors.forEach(c =>
                    {
                        if(c.Id === coll)
                        {
                            console.log(c.Name);
                            pa = c.CRABB_DEV__Percentuale_Affido_Standard__c/100;
                            pe = c.CRABB_DEV__Percentuale_Affido_Standard__c/totPerc;
                            totAss = parseFloat(this.selectedRows.length*pe).toFixed(0);

                        }
                    }
                )

                let newColl = {
                    "Collector": coll,
                    "CollectorName": collName,
                    "Order": order,
                    "TotAssignment": totAss,
                    "EuroEntrusted": 0,
                    "PercentAssignments": pe,
                    "PercentDefault": pa,
                    "PreLot": 'TBD',
                    "PercentEffective": pe
                };

                if ( this.collectorsData.length > 0 )
                {
                    console.log('CollectorsPush => ' + JSON.stringify(this.collectorsData));
                    //this.collectorsData = [ this.collectorsData, newColl ];
                    this.collectorsData = this.collectorsData.concat(newColl);
                    console.log('CollectorsPush => ' + JSON.stringify(this.collectorsData));
                }
                else
                {
                    this.collectorsData = [ newColl ];
                }

                order = order +1;
                this.isCollectorSelected = true;

            });
        }
    }

    handleSave(e)
    {
        let totPerc = 0.0;
        /***
        console.log('handleSave => ' + JSON.stringify(e.detail));
        console.log('handleSave => draftValues: ' + JSON.stringify(e.detail.draftValues));
        console.log('handleSave => collectorsData: ' + JSON.stringify(this.collectorsData));
        console.log('handleSave => collectorDraftValues: ' + JSON.stringify(this.template.querySelector('lightning-datatable').draftValues));
        ***/
        this.collectorsData.forEach(c =>
            {
                let cFound = false;
                e.detail.draftValues.forEach(coll =>
                    {
                        if(c.Collector === coll.Collector)
                        {
                            cFound = true;
                            let pa = parseFloat(coll.PercentAssignments);
                            totPerc += pa;
                        }
                    }
                );
                if(cFound === false)
                {
                    let pa = parseFloat(c.PercentAssignments);
                    totPerc += pa;
                }
            }
        );

        if(totPerc === 1)
        {
            //this.collectorsData = e.detail.draftValues;
            let newCD = [];
            this.collectorsData.forEach(cd =>
            {
                let nCD = cd;
                nCD.Collector               = cd.Collector;
                nCD.Order                   = cd.Order;
                nCD.TotAssignment           = cd.TotAssignment;
                nCD.EuroEntrusted           = cd.EuroEntrusted;
                nCD.PercentAssignments      = cd.PercentAssignments;
                nCD.PercentDefault          = cd.PercentDefault;
                nCD.PercentEffective        = cd.PercentEffective;
                nCD.PreLot                  = cd.PreLot;
                e.detail.draftValues.forEach( df =>
                {
                    if(nCD.Collector === df.Collector)
                    {
                        nCD.PercentAssignments = df.PercentAssignments;
                        nCD.TotAssignment = parseFloat(this.selectedRows.length*df.PercentAssignments).toFixed(0);
                    }
                });
                newCD.push(nCD);
            });
            this.collectorsData = newCD;
            e.detail.draftValues = [];
            this.template.querySelector('lightning-datatable').draftValues = [];
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '100%',
                    message: 'Percentuali aggiornate correttamente',
                    variant: 'success',
                }),
            );
        }
        else
        {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Not 100%',
                    message: 'La somma delle % affidi non è 100. Correggere i dati prima di proseguire. Percentuale: ' + (totPerc*100) + '%',
                    variant: 'error',
                }),
            );
        }

        //e.detail.draftValues = null;
        /***
        console.log('handleSave => ' + JSON.stringify(e.detail));
        console.log('handleSave => ' + JSON.stringify(e.detail.draftValues));
        console.log('handleSave => ' + JSON.stringify(this.collectorsData));
        ***/
    }

    get isStep1()
    {
        return this.stepProcess==1 ? true : false;
    }
    get isStep2()
    {
        if(this.stepProcess==2)
        {
            this.isLoading = true;
        }

        return this.stepProcess==2 ? true : false;
    }

    get isStep3()
    {
        return this.stepProcess==3 ? true : false;
    }

    get isStep4()
    {
        return this.stepProcess==4 ? true : false;
    }

    get isStep5()
    {
        return this.stepProcess==5 ? true : false;
    }

    get isStep6()
    {
        return this.stepProcess==6 ? true : false;
    }

    get isEmpty()
    {
        return this.countQuery==0 ? true : false;
    }

    SelectType(evt)
    {
        console.log('SelectType: ' + JSON.stringify(evt));
    }

    getSelectionTS(event)
    {
        this.optionSelected = event.detail.value;
        console.log('OptionSelected --> ' + this.optionSelected);
        if(this.optionSelected === undefined
        || !this.optionSelected
        || 0 === this.optionSelected.length
        || !this.reportId
        || 0 === this.reportId.length
        || this.reportId === undefined)
        {
            this.isAvanti = false;
        }
        else
        {
            this.isAvanti = true;
        }
    }

    getSelectionLV(event)
    {
        this.reportId = event.detail.value;
        if(this.optionSelected === undefined || !this.optionSelected || 0 === this.optionSelected.length || !this.reportId || 0 === this.reportId.length || this.reportId === undefined) {
            this.isAvanti = false;
        } else {
            this.isAvanti = true;
        }
    }

    ProcediStepPrec()
    {
        this.isLoading=true;
        this.stepProcess -= 1;
        if(this.stepProcess <= maxStep)
        {
            this.isAvanti = true;
        }
        if(this.stepProcess > maxStep)
        {
            this.isAvanti = false;
        }
        if(this.stepProcess <= minStep || this.stepProcess >= 4)
        {
            this.isIndietro = false;
        }
        if(this.stepProcess > minStep && this.stepProcess < 4)
        {
            this.isIndietro = true;
        }

        if(this.stepProcess === 1) {
            this.optionSelected = '';
            this.reportId = '';
            this.countQuery = 0;
            this.isAvanti = false;
        }
        this.sP = this.stepProcess.toString();
        this.isLoading = false;
    }

    ProcediStepSucc()
    {
        this.isLoading=true;
        this.stepProcess += 1;
        if(this.stepProcess <= maxStep)
        {
            this.isAvanti = true;
        }
        if(this.stepProcess > maxStep)
        {
            this.isAvanti = false;
        }
        if(this.stepProcess <= minStep || this.stepProcess >= 4)
        {
            this.isIndietro = false;
        }
        if(this.stepProcess > minStep && this.stepProcess < 4)
        {
            this.isIndietro = true;
        }

        if(this.stepProcess === 2)
        {
            getMaxRecords()
            .then(result => {
                this.maxRecords = result;
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
            getQueryListView({ 'listViewId' : this.reportId , 'TipoSottotipo' : this.optionSelected})
            .then(result => {
            countQueryListViewRows( { 'query' : result , 'TipoSottotipo' : this.optionSelected})
                .then(countQuery => {
                    this.countQuery = countQuery;
                    if(countQuery == 0)
                        this.isAvanti = false;

                    this.getDossiersId(result);
                })
            })
            .catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'System Error',
                        //message: JSON.stringify(error),
                        message: EsitiMassiviNoExternalAuth,
                        variant: 'error',
                    }),
                );

            })
        }
        if(this.stepProcess === 3)
        {
            this.isAvanti = false;
            console.log('Step 3 => ' + this.selectedRows.length);
            console.log('Step 3 => ' + JSON.stringify(this.selectedRows));
        }
        if(this.stepProcess === 4)
        {
            console.log('get Options --> START');
            this.selectedRows = this.template.querySelector('c-crabb-table-esiti-massivi').GetRetrievedRows();
            this.selectedRecordList = this.template.querySelector('c-crabb-table-esiti-massivi').FinalDossierList();
            console.log('Step 4 => ' + this.selectedRows.length);
            console.log('Step 4 => ' + JSON.stringify(this.selectedRows));

            let totPerc = 0;
            let cpeTemp = [];

            availableCollectors({'myTipoAffido' : this.optionSelected})
            .then(result =>
            {
                /*console.log('get Options --> RESULT');
                console.log('get Options --> ' + JSON.stringify(result.lC));
                console.log('get Options --> ' + JSON.stringify(result.lOW));*/

                this.lCollectors = result.lC;
                this.lCollectors.forEach(c =>
                    {
                        totPerc += c.CRABB_DEV__Percentuale_Affido_Standard__c;
                        let newCollPe = [{"Id":  c.Id,"PA": c.CRABB_DEV__Percentuale_Affido_Standard__c,"PE":  0,"totAss": 0}];

                        if(cpeTemp.length>0)
                        {
                            cpeTemp = cpeTemp.concat(newCollPe);
                        }
                        else
                        {
                            cpeTemp = newCollPe;
                        }
                    }
                )
                /*** Calcolo la % effettiva e il numero di pratiche da affidare ***/
                cpeTemp.forEach
                (cpe =>
                    {
                        console.log('cpe => ' + JSON.stringify(this.collPE));
                        let peCalc = cpe.PE;
                        let ta = cpe.totAss;
                        cpe.PE = (cpe.PA)/totPerc;
                        cpe.totAss = parseFloat(this.selectedRows.length*cpe.PE).toFixed(0);
                        console.log('Length => ' + this.collPE.length);

                        let newCPE = [{
                            "Id":       cpe.Id,
                            "PA":       cpe.PA,
                            "PE":       cpe.PE,
                            "totAss":   cpe.totAss
                        }]

                        if(this.collPE.length>0)
                        {
                            console.log('IF => ');
                            this.collPE = this.collPE.concat(newCPE);
                        }
                        else
                        {
                            console.log('ELSE => ');
                            this.collPE = newCPE;
                        }
                    }
                )
                console.log('collPE => ' + JSON.stringify(this.collPE));
                this.options = result.lOW;

                /***console.log('get Options --> ' + JSON.stringify(this.lCollectors));
                console.log('get Options --> ' + JSON.stringify(this.options));***/
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
            this.isAvanti = true;
        }

        if(this.stepProcess === 5)
        {
            /***console.log('Step 5 => ');
            console.log('Step 5 => ' + this.selected.length);
            console.log('Step 5 => ' + JSON.stringify(this.selected));
            console.log('Step 5 => ' + this.selectedRows.length);
            console.log('Step 5 => ' + JSON.stringify(this.selectedRows));***/
            if(this.selected === 'none')
            {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Collector',
                        message: 'Seleziona almeno un collector per procedere.',
                        variant: 'warning',
                    }),
                );
                this.stepProcess = 4;
            }
            else if(this.selected.length > this.selectedRows.length)
            {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Collector',
                        message: 'Non puoi selezionare più collector che numero di pratiche da affidare.',
                        variant: 'warning',
                    }),
                );
                this.stepProcess = 4;
            }
            else
            {
                //this.sData = JSON.stringify(this.collectorsData);
                console.log('Step 5 => Param 0: ' + this.optionSelected);
                console.log('Step 5 => Param 1: ' + JSON.stringify(this.selectedRows));
                console.log('Step 5 => Param 2: ' + JSON.stringify(this.collectorsData));
                console.log('Step 5 => Param 3: ' + this.Algoritmo);

                distributeDossiers({'myTipoAffido'  : this.optionSelected,
                                    'PraticheIds'   : this.selectedRows,
                                    'Collectors'    : JSON.stringify(this.collectorsData),
                                    'Alg'           : this.Algoritmo})
                .then(result =>
                {
                    console.log('distributeDossiers => Result: ' + JSON.stringify(result));
                    this.distribResult = result;
                    console.log('distributeDossiers => distribResult: ' + JSON.stringify(this.distribResult));
                    this.isSummary = true;
                    let NumTotPratAss = 0;
                    result.forEach(distrib =>
                        {
                            let collName = 'NA';
                            this.options.forEach(o =>
                            {
                                if(distrib.collector === o.value)
                                    collName = o.label;
                            })
                            console.log('distributeDossiers => distrib: ' + JSON.stringify(distrib));
                            let newColl = {
                                "Collector":            distrib.collector,
                                "CollectorName":        collName,
                                "Order":                distrib.position,
                                "TotAssignment":        distrib.totPrat,
                                "EuroEntrusted":        distrib.totAmount,
                                "PercentAssignments":   distrib.percAff,
                                "PercentEffective":     distrib.percEff
                            };
                            NumTotPratAss = NumTotPratAss + distrib.totPrat;
                            console.log('distributeDossiers => newColl: ' + JSON.stringify(newColl));
                            this.distributionData.push(newColl);
                            console.log('distributeDossiers => distributionData: ' + JSON.stringify(this.distributionData));
                        }
                    )
                    console.log('distributeDossiers => Result: ' + JSON.stringify(this.distributionData));
                    if(NumTotPratAss <  this.selectedRows.length)
                    {
                        if(NumTotPratAss === 0)
                        {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Nessuna pratica trovata',
                                    message: 'Nessuna delle pratiche selezionate ha le caratteristiche giuste per essere gestita in questo tipo di affido. Ti preghiamo di rivedere i criteri della list view scelta oppure di sceglierne una differente.',
                                    variant: 'error',
                                }),
                            );
                            this.isAvanti = false;
                        }
                        else
                        {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Alcune pratiche non idonee',
                                    message: 'Alcune delle pratiche selezionate non hanno le caratteristiche giuste per essere gestite in questo tipo di affido. Puoi procedere con quelle idonne oppure puoi rivedere i criteri della list view scelta o sceglierne una differente.',
                                    variant: 'warning',
                                }),
                            );
                        }
                    }
                    else
                    {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Dossier Distribution',
                                message: 'Distribuzione eseguita correttamente',
                                variant: 'success',
                            }),
                        );
                    }
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
            }
        }

        if(this.stepProcess === 6)
        {
            console.log('Step 6 => dr: ' + JSON.stringify(this.distribResult))
            finalizzaLotti({"lDR_Old": this.distribResult,
                            "sDR": JSON.stringify(this.distribResult)})
            .then(result =>
            {
                //console.log('STEP 6 => ' + JSON.stringify(result));
                this.isPreLotti = true;
                result.forEach(preLotto =>
                {
                    let newLotto = {
                        "PreLot": preLotto.Name,
                        "Tipo": preLotto.CRABB_DEV__Tipo__c,
                        "Status": preLotto.CRABB_DEV__Stato__c,
                        "CollectorName": preLotto.CRABB_DEV__Affidamenti_support_collector_ragSoc__c,
                        "Order": preLotto.CRABB_DEV__Affidamenti_support_Posizione__c,
                        "TotAssignment": preLotto.CRABB_DEV__Affidamenti_support_numero_affidi__c,
                        "EuroEntrusted": preLotto.CRABB_DEV__Affidamenti_support_Scaduto_Affidato__c,
                        "PercentEffective": preLotto.CRABB_DEV__Affidamenti_support_Percentuale_effettiv__c
                    };
                    this.preLottiData.push(newLotto);
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
        }
        this.sP = this.stepProcess.toString();
        this.isLoading = false;
    }

    async getDossiersId(query)
    {
        this.isLoading = true;
        let offsetData = 0;
        let limitData = this.maxRecords;
        //let totalRecordList = [];
        let offsetValue = 'PR-000000';
        let jsonQuery = '';
        let appData;
        let jsonQueryStringify;
        this.totalRecordList = [];
        if(limitData>this.maxRecords)
            limitData = this.maxRecords;

        while(true)
        {
            console.log('getDossiersId ---> ' + query + ' - ' + this.optionSelected);
            let resQuery = await getQueryListRows( { 'query' : query , 'limitClause' : limitData , 'offsetClause' : offsetData, 'offsetValue' : offsetValue , 'TipoSottotipo' : this.optionSelected })
            this.totalRecordList = this.totalRecordList.concat(resQuery);

            if(resQuery.length == 0 || this.totalRecordList.length>=this.maxRecords || this.totalRecordList.length<this.maxRecords)
            {
                break;
            }
            else if(this.totalRecordList.length+limitData>this.maxRecords)
            {
                limitData = this.maxRecords-this.totalRecordList.length;
            }

            jsonQueryStringify = JSON.stringify(resQuery);
            jsonQuery = JSON.parse(jsonQueryStringify)
            let result = [];
            for(var i in jsonQuery) {
                result.push([i, jsonQuery[i]]);
            }
            appData = result[result.length - 1];
            offsetValue = appData[appData.length-1].Name;
        }

        this.isLoading = false;
    }

    connectedCallback()
    {
        getSelezioni()
        .then(( data ) =>
        {
            this.TaskType=data.lTS;
            if(this.TaskType.length > 0)
                this.isTS = true;
            else
                this.isAvanti = false;
            this.ListView=data.lLV;
            if(this.ListView.length > 0)
                this.isLV = true;
            else
                this.isAvanti = false;
            this.isLoading = false;
        }).catch((error) => {
            console.error('Error: ' + error);
            this.isLoading = false;
        });
    }

    setIsActiveButtonHandle(event) {
        //if(event.detail.selectedRowCount > 0 && event.detail.selectedValue !== '--- Select one ---' && event.detail.selectedValue !== '' && event.detail.selectedValue != null) {
        if(event.detail.selectedRowCount > 0)
        {
            console.log('RowCount --> ' + event.detail.selectedRowCount);
            this.isAvanti = true;
            this.retrievedRows = event.detail.retrievedRows;
            this.tableRecords = event.detail.tableRecords;
        } else {
            this.isAvanti = false;
        }
    }

    setIsActiveButtonHandleSelectAll(event) {
        //if(event.detail.selectedRCount > 0 && event.detail.selectedValue !== '--- Select one ---' && event.detail.selectedValue !== '' && event.detail.selectedValue != null) {
        if(event.detail.selectedRCount > 0)
        {
            console.log('RowCountAll --> ' + event.detail.selectedRCount);
            this.isAvanti = true;
            this.retrievedRows = event.detail.retrievedRows;
            this.tableRecords = event.detail.tableRecords;
        } else {
            this.isAvanti = false;
        }
    }

    setIsActiveButtonHandleDeselectAll(event) {
        this.isAvanti = false;
    }

    //Navigate to visualforce page
    navigateToVFPage() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/GestioneAffidamenti?TabToView=LICTab'
            }
        }).then(generatedUrl => {
            window.open(generatedUrl);
        });
    }
}