import { LightningElement, api } from 'lwc';

//importing labels
import AVX_ProductCode from '@salesforce/label/c.AVX_ProductCode';
import AVX_Family from '@salesforce/label/c.AVX_Family';
import AVX_Family2 from '@salesforce/label/c.AVX_Family2';
import AVX_Brand from '@salesforce/label/c.AVX_Brand';
import AVX_StorageCode from '@salesforce/label/c.AVX_StorageCode';
import AVX_GrossWeight from '@salesforce/label/c.AVX_GrossWeight';
import AVX_NetWeight from '@salesforce/label/c.AVX_NetWeight';
import AVX_DefaultUom from '@salesforce/label/c.AVX_DefaultUom';
import AVX_DefaultPricingUOM from '@salesforce/label/c.AVX_DefaultPricingUOM';
import AVX_Business from '@salesforce/label/c.AVX_Business';
import AVX_MaterialType from '@salesforce/label/c.AVX_MaterialType';
import AVX_Taxed from '@salesforce/label/c.AVX_Taxed';
import AVX_Description from '@salesforce/label/c.AVX_Description';
import AVX_DurationOfConservation from '@salesforce/label/c.AVX_DurationOfConservation';
import AVX_ProductDetails from '@salesforce/label/c.AVX_ProductDetails';
import AVX_Close from '@salesforce/label/c.AVX_Close';
import AVX_PackType from '@salesforce/label/c.AVX_PackType';
import AVX_Yes from '@salesforce/label/c.AVX_Yes';
import AVX_No from '@salesforce/label/c.AVX_No';




export default class avx_productdetail extends LightningElement {
    @api objpricebookentry;
    @api openproductdetailmodal;
    @api showdefaultimage;
    @api taxedyesorno;

    //custom labels
    label = {
        AVX_ProductCode,
        AVX_Family,
        AVX_Family2,
        AVX_Brand,
        AVX_StorageCode,
        AVX_GrossWeight,
        AVX_NetWeight,
        AVX_DefaultUom,
        AVX_DefaultPricingUOM,
        AVX_Business,
        AVX_MaterialType,
        AVX_Taxed,
        AVX_Description,
        AVX_DurationOfConservation,
        AVX_ProductDetails,
        AVX_Close,
        AVX_PackType,
        AVX_Yes,
        AVX_No
    };

    @api closeModal(event){
        event.preventDefault();
        const selectedEvent = new CustomEvent('closemodal',{ });
        this.dispatchEvent(selectedEvent);
    }





}