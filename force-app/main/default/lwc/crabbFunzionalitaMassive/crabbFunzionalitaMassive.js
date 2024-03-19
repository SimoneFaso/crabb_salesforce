/**
 * Created by msala on 05/05/2020.
 */

import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import massfeat from '@salesforce/label/c.Funzionalit_Massive';
import massres from '@salesforce/label/c.Esitazione_Massiva';
import upcollres from '@salesforce/label/c.Upload_Esiti_Collector';
import whitel from '@salesforce/label/c.White_List';
import masResAcc from '@salesforce/label/c.Inserimento_Esiti_Massivi';
import pracOutAcc from '@salesforce/label/c.Access_Practices_Outcomes';
import whiLisAcc from '@salesforce/label/c.White_List_Access';
import proceed from '@salesforce/label/c.Proceed';
import affido from '@salesforce/label/c.Affido_Collector_Title';
import affidoDesc from '@salesforce/label/c.Affido_Collector_Description';

export default class CrabbFunzionalitaMassive extends NavigationMixin(LightningElement)
{
    label = {massfeat,
            massres,
            upcollres,
            whitel,
            masResAcc,
            pracOutAcc,
            whiLisAcc,
            proceed,
            affido,
            affidoDesc};

    navigateToTabEM() {
        // Navigate to a specific CustomTab.
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                // CustomTabs from managed packages are identified by their
                // namespace prefix followed by two underscores followed by the
                // developer name. E.g. 'namespace__TabName'
                apiName: 'CRABB_DEV__EsitiMassivi'
            }
        });
    }

    navigateToTabUEC() {
        // Navigate to a specific CustomTab.
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                // CustomTabs from managed packages are identified by their
                // namespace prefix followed by two underscores followed by the
                // developer name. E.g. 'namespace__TabName'
                apiName: 'CRABB_DEV__Upload_Esiti_Collector'
            }
        });
    }

    navigateToTabWL() {
        // Navigate to a specific CustomTab.
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                // CustomTabs from managed packages are identified by their
                // namespace prefix followed by two underscores followed by the
                // developer name. E.g. 'namespace__TabName'
                apiName: 'CRABB_DEV__Gestione_White_List'
            }
        });
    }

    navigateToTabAff()
    {
        // Navigate to a specific CustomTab.
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                // CustomTabs from managed packages are identified by their
                // namespace prefix followed by two underscores followed by the
                // developer name. E.g. 'namespace__TabName'
                apiName: 'CRABB_DEV__Affidi_Massivi'
            }
        });
    }
}