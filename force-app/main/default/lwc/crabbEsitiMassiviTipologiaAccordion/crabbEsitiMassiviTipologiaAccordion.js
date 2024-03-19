/**
 * Created by Matteo on 05/08/2020.
 */

import { LightningElement , api } from 'lwc';

export default class CrabbEsitiMassiviTipologiaAccordion extends LightningElement {
    @api mapData;
    @api mapKey;
    @api mapSottoDisabled;
    @api mapTipoTotal;
    @api mapTipoOldest;

    get showIconDisabled(){
        return this.mapSottoDisabled[this.mapKey];
    }

    get labelAccordion(){

        return this.mapKey + ' - ' + ( this.mapTipoTotal ?  this.mapTipoTotal[this.mapKey] :' ' )  + ' '+
        (this.mapTipoOldest ? this.mapTipoOldest[this.mapKey] : '' ) + ' gg';
    }

    get labelTile(){
        return 'Vedi tutti i record di: '+ this.mapKey;
    }

    openModalChooseReport(){
        console.log('openModalChooseReport start ' + this.mapKey);
        const evt = new CustomEvent('openmodalreport' , { detail : { mapKey : this.mapKey }});
        this.dispatchEvent( evt );
    }
}