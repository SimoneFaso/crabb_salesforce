/**
 * Created by MatteoSala on 03/07/2020.
 */

import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import GetcurrentAS from '@salesforce/apex/AmministrazioneCTRL.getCurrentAS';
import Geturl from '@salesforce/apex/AmministrazioneCTRL.getUrl';
import ImportCustomSetting from '@salesforce/apex/AmministrazioneCTRL.importCustomSetting';
import ImportMapping from '@salesforce/apex/AmministrazioneCTRL.importMapping';
import Configurazione_Amministrazione_Title from '@salesforce/label/c.Configurazione_Amministrazione_Title';
import Configurazione_Amministrazione_Description from '@salesforce/label/c.Configurazione_Amministrazione_Description';
import Configurazione_Amministrazione_Button from '@salesforce/label/c.Configurazione_Amministrazione_Button';

import Attivita_Profili_Title from '@salesforce/label/c.Attivita_Profili_Title';
import Attivita_Profili_Description from '@salesforce/label/c.Attivita_Profili_Description';
import Attivita_Profili_Button from '@salesforce/label/c.Attivita_Profili_Button';

import Profilazione_Utenti_Title from '@salesforce/label/c.Profilazione_Utenti_Title';
import Profilazione_Utenti_Description from '@salesforce/label/c.Profilazione_Utenti_Description';
import Profilazione_Utenti_Button from '@salesforce/label/c.Profilazione_Utenti_Button';
import Profilazione_Ruoli_Button from '@salesforce/label/c.Profilazione_Ruoli_Button';

import Configurazione_Strategie_Title from '@salesforce/label/c.Configurazione_Strategie_Title';
import Configurazione_Strategie_Description from '@salesforce/label/c.Configurazione_Strategie_Description';
import Configurazione_Strategie_Button from '@salesforce/label/c.Configurazione_Strategie_Button';

import Estratto_Conto_Title from '@salesforce/label/c.Estratto_Conto_Title';
import Estratto_Conto_Description from '@salesforce/label/c.Estratto_Conto_Description';
import Estratto_Conto_Button from '@salesforce/label/c.Estratto_Conto_Button';

import Cruscotto_Pratica_Title from '@salesforce/label/c.Cruscotto_Pratica_Title';
import Cruscotto_Pratica_Description from '@salesforce/label/c.Cruscotto_Pratica_Description';
import Cruscotto_Pratica_Button from '@salesforce/label/c.Cruscotto_Pratica_Button';

import Import_Strategie_Title from '@salesforce/label/c.Import_Strategie_Title';
import Import_Strategie_Description from '@salesforce/label/c.Import_Strategie_Description';
import Import_Strategie_Button from '@salesforce/label/c.Import_Strategie_Button';

import Configurazione_Collector_Title from '@salesforce/label/c.Configurazione_Collector_Title';
import Configurazione_Collector_Description from '@salesforce/label/c.Configurazione_Collector_Description';
import Configurazione_Collector_Button from '@salesforce/label/c.Configurazione_Collector_Button';

import Flussi_Collector_Title from '@salesforce/label/c.Flussi_Collector_Title';
import Flussi_Collector_Description from '@salesforce/label/c.Flussi_Collector_Description';
import Flussi_Collector_Button from '@salesforce/label/c.Flussi_Collector_Button';

import Fasce_Collector_Title from '@salesforce/label/c.Fasce_Collector_Title';
import Fasce_Collector_Description from '@salesforce/label/c.Fasce_Collector_Description';
import Fasce_Collector_Button from '@salesforce/label/c.Fasce_Collector_Button';

import Affido_Collector_Title from '@salesforce/label/c.Affido_Collector_Title';
import Affido_Collector_Description from '@salesforce/label/c.Affido_Collector_Description';
import Affido_Collector_Button from '@salesforce/label/c.Affido_Collector_Button';

import Gestione_OrkBatch_Title from '@salesforce/label/c.Gestione_OrkBatch_Title';
import Gestione_OrkBatch_Description from '@salesforce/label/c.Gestione_OrkBatch_Description';
import Gestione_OrkBatch_Button from '@salesforce/label/c.Gestione_OrkBatch_Button';

import Eliminazione_Logs_Title from '@salesforce/label/c.Eliminazione_Logs_Title';
import Eliminazione_Logs_Description from '@salesforce/label/c.Eliminazione_Logs_Description';
import Eliminazione_Logs_Button from '@salesforce/label/c.Eliminazione_Logs_Button';

import Configurazione_Mapping_Title from '@salesforce/label/c.Configurazione_Mapping_Title';
import Configurazione_Mapping_Description from '@salesforce/label/c.Configurazione_Mapping_Description';
import Configurazione_Mapping_Button from '@salesforce/label/c.Configurazione_Mapping_Button';

import Costi_Attivita_Title from '@salesforce/label/c.Costi_Attivita_Title';
import Costi_Attivita_Description from '@salesforce/label/c.Configurazione_Mapping_Description';
import Costi_Attivita_Button from '@salesforce/label/c.Costi_Attivita_Button';

import Accordion_Section_Admin from '@salesforce/label/c.Accordion_Section_Admin';
import Accordion_Section_CRABB_Setup from '@salesforce/label/c.Accordion_Section_CRABB_Setup';
import Accordion_Section_Strategie from '@salesforce/label/c.Accordion_Section_Strategie';
import Accordion_Section_Collector from '@salesforce/label/c.Accordion_Section_Collector';
import Accordion_Section_Technical_Management from '@salesforce/label/c.Accordion_Section_Technical_Management';

import Custom_Setting_Title from '@salesforce/label/c.Custom_Setting_Title';
import Custom_Setting_Description from '@salesforce/label/c.Custom_Setting_Description';
import Custom_Setting_Button from '@salesforce/label/c.Custom_Setting_Button';

import Initial_Import_Mapping_Title from '@salesforce/label/c.Initial_Import_Mapping_Title';
import Initial_Import_Mapping_Description from '@salesforce/label/c.Initial_Import_Mapping_Description';
import Initial_Import_Mapping_Button from '@salesforce/label/c.Initial_Import_Mapping_Button';


export default class Administration extends NavigationMixin(LightningElement) {
    labels = {
        Configurazione_Amministrazione_Title, Configurazione_Amministrazione_Description, Configurazione_Amministrazione_Button,
        Attivita_Profili_Title, Attivita_Profili_Description, Attivita_Profili_Button,
        Profilazione_Utenti_Title,Profilazione_Utenti_Description,Profilazione_Utenti_Button, Profilazione_Ruoli_Button,
        Configurazione_Strategie_Title, Configurazione_Strategie_Description, Configurazione_Strategie_Button,
        Estratto_Conto_Title, Estratto_Conto_Description, Estratto_Conto_Button,
        Cruscotto_Pratica_Title, Cruscotto_Pratica_Description, Cruscotto_Pratica_Button,
        Import_Strategie_Title, Import_Strategie_Description, Import_Strategie_Button,
        Configurazione_Collector_Title, Configurazione_Collector_Description, Configurazione_Collector_Button,
        Flussi_Collector_Title, Flussi_Collector_Description, Flussi_Collector_Button,
        Fasce_Collector_Title, Fasce_Collector_Description, Fasce_Collector_Button,
        Affido_Collector_Title, Affido_Collector_Description, Affido_Collector_Button,
        Gestione_OrkBatch_Title, Gestione_OrkBatch_Description, Gestione_OrkBatch_Button,
        Eliminazione_Logs_Title, Eliminazione_Logs_Description, Eliminazione_Logs_Button,
        Configurazione_Mapping_Title, Configurazione_Mapping_Description, Configurazione_Mapping_Button,
        Costi_Attivita_Title, Costi_Attivita_Description, Costi_Attivita_Button,

        // accordion section Titles 
        Accordion_Section_Admin, Accordion_Section_CRABB_Setup, Accordion_Section_Strategie,
        Accordion_Section_Collector, Accordion_Section_Technical_Management,
        Custom_Setting_Title, Custom_Setting_Description, Custom_Setting_Button,
        Initial_Import_Mapping_Title, Initial_Import_Mapping_Description, Initial_Import_Mapping_Button


    };

    @track currentAS = {};
    @track disableImport = false;
    @track disableImportMapping = false;
   // @track activeSectionName='';
    @wire(Geturl) url;

    @wire(GetcurrentAS)
    loadCurrentAS({ error, data })   {
        if (data) {
            this.currentAS = data;
            this.error = undefined;
            console.log(JSON.stringify(this.currentAS));
        } else if (error) {
            console.log(JSON.stringify(error));
        }
    }

    get adminAccordionSection(){
        return this.currentAS.ConfigurazioneAmministrazione || this.currentAS.AttivitaProfili || this.currentAS.ProfilazioneUtenti;
    }
    get CRABBSetupAccordionSection(){
        return this.currentAS.EstrattoConto || this.currentAS.CruscottoPratica || this.currentAS.CostiAttivita;
    }
    get StrategieAccordionSection(){
        return this.currentAS.ConfigurazioneStrategie || this.currentAS.ImportStrategie;
    }
    get CollectorAccordionSection(){
        return this.currentAS.ConfigurazioneCollector || this.currentAS.FlussiCollector || this.currentAS.FasceCollector || this.currentAS.AffidoCollector;
    }
    get technicalManagementAccordionSection(){
        return this.currentAS.GestioneOrkBatch || this.currentAS.EliminazioneLog || this.currentAS.ConfigurazioneMapping;
    }

    // get activeSectionName(){
    //     if (adminAccordionSection)
    //         activeSectionName="Admin";
    //     else if (CRABBSetupAccordionSection)
    //         activeSectionName="CRABB Setup";
    //     else if (StrategieAccordionSection)
    //         activeSectionName="Strategie";
    //     else if (CollectorAccordionSection)
    //         activeSectionName="Collector";
    //     else if (technicalManagementAccordionSection)
    //         activeSectionName="Technical Management";
    //   }


    navigateToGestioneAmministrazione() {
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/apex/GestioneAmministrazione'
        //     }
        // }).then(generatedUrl => {
        //     window.open(generatedUrl);
        // });
        console.log(JSON.stringify(this.url.data));
        window.open(this.url.data+'/apex/CRABB_DEV__GestioneAmministrazione');
    }

    navigateToAffidiSettingsPage() {
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/apex/AffidiSettingsPage'
        //     }
        // }).then(generatedUrl => {
        //     window.open(generatedUrl);
        // });

        window.open(this.url.data+'/apex/CRABB_DEV__AffidiSettingsPage');
    }

    navigateToUtenti() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'User',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        }).then(generatedUrl =>{
            window.open(generatedUrl);
            });
    }

    navigateToRuoli(){
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/ui/setup/user/RoleViewPage?setupid=Roles'
        //     }
        // }).then(generatedUrl => {
        //     window.open(generatedUrl);
        // });

        window.open(this.url.data+'/ui/setup/user/RoleViewPage?setupid=Roles');

    }

    navigateToGestioneStrategie(){
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/apex/GestioneStrategie'
        //     }
        // }).then(generatedUrl => {
        //     window.open(generatedUrl);
        // });
        window.open(this.url.data+'/apex/CRABB_DEV__GestioneStrategie');
    }

    navigateToPDF(){
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/apex/ListOfFieldsCS_NEW?object=PDF'
        //     }
        // }).then(generatedUrl => {
        //     window.open(generatedUrl);
        // });
        window.open(this.url.data+'/lightning/n/CRABB_DEV__ListOfFieldsCS?object__c=PDF');
    }

    navigateToTAB(){
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/apex/ListOfFieldsCS_NEW?object=TAB'
        //     }
        // }).then(generatedUrl => {
        //     window.open(generatedUrl);
        // });
        window.open(this.url.data+'/lightning/n/CRABB_DEV__ListOfFieldsCS?object__c=TAB');
    }

    navigateToImportStrategie(){
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/apex/Import_Strategie'
        //     }
        // }).then(generatedUrl => {
        //     window.open(generatedUrl);
        // });
        //window.open(this.url.data+'/apex/CRABB_DEV__Import_Strategie');
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                //Name of any CustomTab. Visualforce tabs, web tabs, Lightning Pages, and Lightning Component tabs
                apiName: 'CRABB_DEV__Import_Strategy'
            },
        });

    }


    navigateToGestioneCollector() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'CRABB_DEV__Collector__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        }).then(generatedUrl => {
            window.open(generatedUrl);
        });
    }
    navigateToCSV(){
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/apex/ListOfFieldsCS_NEW?object=CSVNEW'
        //     }
        // }).then(generatedUrl => {
        //     window.open(generatedUrl);
        // });
        //window.open(this.url.data+'/apex/CRABB_DEV__ListOfFieldsCS?object=CSVNEW');
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                //Name of any CustomTab. Visualforce tabs, web tabs, Lightning Pages, and Lightning Component tabs
                apiName: 'CRABB_DEV__Flussi_Collector_CSV_Nuovo_Affido'
            },
        });

    }

    navigateToFasce(){
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/apex/FasceCollector'
        //     }
        // }).then(generatedUrl => {
        //     window.open(generatedUrl);
        // });
        window.open(this.url.data+'/apex/CRABB_DEV__FasceCollector')
    }

    navigateToGestioneAffidoCollector(){
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/apex/AffidoCollectorPage'
        //     }
        // }).then(generatedUrl => {
        //     window.open(generatedUrl);
        // });
        window.open(this.url.data+'/apex/CRABB_DEV__AffidoCollectorPage')

    }

    navigateToOrkBatch(){
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/apex/OrkBatchPage'
        //     }
        // }).then(generatedUrl => {
        //     window.open(generatedUrl);
        // });
        window.open(this.url.data+'/apex/CRABB_DEV__OrkBatchPage')
    }

    navigateToLogDelete(){
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/apex/LogDelete'
        //     }
        // }).then(generatedUrl => {
        //     window.open(generatedUrl);
        // });
        window.open(this.url.data+'/apex/CRABB_DEV__LogDelete')
    }


    navigateToBRL(){
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/apex/DataMapper'
        //     }
        // }).then(generatedUrl => {
        //     window.open(generatedUrl);
        // });
        window.open(this.url.data+'/apex/CRABB_DEV__DataMapper')
    }

    navigateToCostiAttivita(){
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/apex/GestioneCostiAttivita'
        //     }
        // }).then(generatedUrl => {
        //     window.open(generatedUrl);
        // });
        window.open(this.url.data+'/apex/CRABB_DEV__GestioneCostiAttivita')
    }

    handleImport() {
        this.disableImport = true;
        ImportCustomSetting()
        .then(result => {
            this.showMessage('success', 'Records Imported');
            this.disableImport = false;
        }).catch(error => {
           console.log('error on import ' + JSON.stringify(error));
           this.disableImport = false;
        });
    }

    handleImportMapping() {
        this.disableImportMapping = true;
        ImportMapping()
        .then(result => {
            this.showMessage('success', 'Records Imported');
            this.disableImport = false;
        }).catch(error => {
           console.log('error on import ' + JSON.stringify(error));
           this.disableImport = false;
        });
    }

    showMessage(outcome, message){
        const evt = new ShowToastEvent({
            title: outcome,
            message: message,
            variant: outcome,
        });
        this.dispatchEvent(evt);
    }
}