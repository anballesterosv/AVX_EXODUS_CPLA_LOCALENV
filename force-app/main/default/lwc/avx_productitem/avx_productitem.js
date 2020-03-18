/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';

import AVX_ProductDetails from '@salesforce/label/c.AVX_ProductDetails';
import AVX_ProductName from '@salesforce/label/c.AVX_ProductName';
import AVX_ProductCode from '@salesforce/label/c.AVX_ProductCode';
import AVX_Brand from '@salesforce/label/c.AVX_Brand';
import AVX_Family from '@salesforce/label/c.AVX_Family';
import AVX_DefaultPricingUOM from '@salesforce/label/c.AVX_DefaultPricingUOM';
import AVX_DefaultUom from '@salesforce/label/c.AVX_DefaultUom';
import AVX_SalesOrg from '@salesforce/label/c.AVX_SalesOrg'

export default class AVX_ProductItem extends LightningElement {
    @api itemproduct;
    @api showimage;
    @track witemproduct;
    @track productTargeting;
    //Label em
        //data-label
        //title(Coluna Info)

        label = {
            AVX_ProductDetails,
            AVX_ProductName,
            AVX_ProductCode,
            AVX_Brand,
            AVX_Family,
            AVX_DefaultPricingUOM,
            AVX_DefaultUom,
            AVX_SalesOrg,
        };


    connectedCallback() {
        this.productTargeting =  location.protocol + '//' + location.host + '/' + this.itemproduct.product2Id;
    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    @api openModal(event){
        this.witemproduct = JSON.stringify(this.itemproduct);
        event.preventDefault();
        const selectedEvent = new CustomEvent('openmodal', { detail: this.witemproduct });
        this.dispatchEvent(selectedEvent);
    }

}