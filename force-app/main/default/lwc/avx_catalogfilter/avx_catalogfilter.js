/* eslint-disable no-console */
import { LightningElement, wire, track, api } from 'lwc';

import getFilter from '@salesforce/apex/AVX_ProductCatalog_ctr.getFilter';

import AVX_Search from '@salesforce/label/c.AVX_Search';
import AVX_EnterSearch from '@salesforce/label/c.AVX_EnterSearch';

import AVX_SearchFilters from '@salesforce/label/c.AVX_SearchFilters';
import AVX_ShowMore from '@salesforce/label/c.AVX_ShowMore';
import AVX_ShowLess from '@salesforce/label/c.AVX_ShowLess';

export default class Avx_catalogfilter extends LightningElement {
    @track searchText;
    @track searchWire;
    @track showErrorMsg = false;
    @track stringPriceBook = 'Product Catalog TestModal';
    @track setFilterParamenter = '';
    @track responseFilterData = [];
    @track showFilter = true;
    @track openContainer = 'slds-modal slds-fade-in-open slds-modal_small filterModal close';
    @track closedContainer = 'slds-modal slds-fade-in-open slds-modal_small filterModal';
    @api showFilter3 = 'false';


    @wire(getFilter, { stringPriceBook: '$stringPriceBook'}) 
    filterData({ error, data }) {
        if (data) {
            this.responseFilterData = data;
        }else if (error){ 
            console.log('error', JSON.stringify(error));             
        }
    } 
    

    label = {
        AVX_SearchFilters,
        AVX_ShowMore,
        AVX_ShowLess,
        AVX_Search,
        AVX_EnterSearch
    };

    
    

    openModal(e){
        this.showFilter = true;
        this.openContainer = 'slds-modal slds-fade-in-open slds-modal_small filterModal open';
        this.closedContainer = 'slds-modal slds-fade-in-open slds-modal_small filterModal close';
    }

    closeModal(e){
        this.showFilter = false;
        this.openContainer = 'slds-modal slds-fade-in-open slds-modal_small filterModal close';
        this.closedContainer = 'slds-modal slds-fade-in-open slds-modal_small filterModal open';
    }

    @api selectChkField(event){
        this.setFilterParamenter = '';
        let selectedInputs = [];
        let target = this.template.querySelectorAll('[data-id="checkGroupFilter"]');
        for (let i = 0; i < target.length; i++) {
            let a = JSON.parse(JSON.stringify(target[i].value));
            let b = JSON.parse(JSON.stringify(target[i].label));
            let c = JSON.parse(JSON.stringify(target[i].name));
            console.log('value', a);
            console.log('label', b);
            console.log('name',c);
            if(a[0] !== undefined){
                if(a[0].length > 1){
                    //selectedInputs.concat(a);
                    for (let x = 0; x < a.length; x++) {
                        selectedInputs.push(a[x]);
                    }
                }
            }
        }
        this.setFilterParamenter = JSON.stringify(selectedInputs);
        
        event.preventDefault();
        const val = this.setFilterParamenter;
        const selectedEvent = new CustomEvent('receiveFilter', {detail : val,  bubbles: true});
        this.dispatchEvent(selectedEvent);       
    }
}