/**
 * Created by msala on 04/05/2020.
 */

import {LightningElement, api, track, wire} from 'lwc';
//import IMAGE_PATH from '@salesforce/resourceUrl/lcaimages';
import getAgeing from '@salesforce/apex/CRABB_PraticaAgeingCtrl.getAgeing';

import section from '@salesforce/label/c.Section';
import residual from '@salesforce/label/c.Residual';
import amoTran from '@salesforce/label/c.Amount_Transactions';

const   PIE_COLORS = {
    'viola' : '#9D53F2' ,
    'celeste' : '#FFAF4F' ,
    'azzurro' : '#31BCB7' ,
    'blu' : '#77B9F2',
    'turchese' : '#30d5c8',
    'blu scuro' : '#00249c',
    'giallo' : 'yellow'
};
const   IST_COLORS = {
    1 : '#00A65E',
    2 : '#30d5c8',
    3 : '#31BCB7',
    4 : '#77B9F2',
    5 : '#00249c',
    6 : '#FFAF4F',
    7 : '#ED1B24',
    8 : '#9D53F2'
};

export default class CrabbPraticaAgeing extends LightningElement{

    //label = {section,residual,amoTran};
    //@api accountid;
    //@api uid;
    //@track protectionwealth;
    //@track messaggio;
    //@track titolografico;
    //@track sizePatrimonio = 3000000;
    //@track showModal;
    //@track patrimonioAssicurativo = [ ];
    //@track pieData = [ ];

    @api recordId;
    @track istogramma;
    @track dt = [];
    @track columns = [
        {
            label: section,
            fieldName: 'descrizione',
            type: 'text',
            sortable: true,
            cellAttributes: {  class: { fieldName: 'cellColor' }}
            //cellAttributes: { color: #DDDDDD }
        },
        {
            label: residual,
            fieldName: 'ctv',
            type: 'currency',
            typeAttributes: { currencyCode: 'EUR'}
        },
        {
            label: amoTran,
            fieldName: 'quantitativo',
            type: 'number'
        }
    ];

    @wire( getAgeing , {praticaid : '$recordId'} )
    wiredAgeing({ error, data })
    {
        if(data && data.serie)
        {
            console.log('sono in getAgeing');
            console.log('Data from getAgeing',data);
            //console.log('praticaid: '+ this.recordId);
            this.istogramma = {
                titolo : data.titolo ,
                size : data.size,
                serie : []
            }
            var i = 1;
            for(var ps of data.serie)
            {
                this.istogramma.serie.push({
                    descrizione : ps.descrizione,
                    quantitativo : ps.quantitativo,
                    ctv : ps.valore ,
                    //color : PIE_COLORS[ps.colore]
                    color : IST_COLORS[ps.colore],
                    cellColor : 'LegendColor' + ps.colore
                });
                this.dt.push({
                    descrizione : ps.descrizione,
                    quantitativo : ps.quantitativo,
                    valore : ps.valore ,
                    //color : PIE_COLORS[ps.colore]
                    color : IST_COLORS[ps.colore]
                });
            }
            console.log('Istogramma: ',this.istogramma);
            console.log('DataTable: ',this.dt);
        }
        else if (error)
        {
            //this.error = error;
            console.error(error);
            this.istogramma = {};
        }
    }

    renderedCallback() {
        const style1 = document.createElement('style');
        style1.innerText = `.LegendColor1 {
           background: ` + IST_COLORS[1] + ` !important;
           color: white;
        }`;
        this.template.querySelector('div').appendChild(style1);
        const style2 = document.createElement('style');
        style2.innerText = `.LegendColor2 {
           background: ` + IST_COLORS[2] + ` !important;
           color: white;
        }`;
        this.template.querySelector('div').appendChild(style2);
        const style3 = document.createElement('style');
        style3.innerText = `.LegendColor3 {
           background: ` + IST_COLORS[3] + ` !important;
           color: white;
        }`;
        this.template.querySelector('div').appendChild(style3);
        const style4 = document.createElement('style');
        style4.innerText = `.LegendColor4 {
           background: ` + IST_COLORS[4] + ` !important;
           color: white;
        }`;
        this.template.querySelector('div').appendChild(style4);
        const style5 = document.createElement('style');
        style5.innerText = `.LegendColor5 {
           background: ` + IST_COLORS[5] + ` !important;
           color: white;
        }`;
        this.template.querySelector('div').appendChild(style5);
        const style6 = document.createElement('style');
        style6.innerText = `.LegendColor6 {
           background: ` + IST_COLORS[6] + ` !important;
           color: white;
        }`;
        this.template.querySelector('div').appendChild(style6);
        const style7 = document.createElement('style');
        style7.innerText = `.LegendColor7 {
           background: ` + IST_COLORS[7] + ` !important;
           color: white;
        }`;
        this.template.querySelector('div').appendChild(style7);
        const style8 = document.createElement('style');
        style8.innerText = `.LegendColor8 {
           background: ` + IST_COLORS[8] + ` !important;
           color: white;
        }`;
        this.template.querySelector('div').appendChild(style8);
    }
}