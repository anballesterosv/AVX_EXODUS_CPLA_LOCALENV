import { LightningElement,track,wire,api } from 'lwc';
import {fireEvent,registerListener} from 'c/pubsub';
import {CurrentPageReference} from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import getShipToByTask  from '@salesforce/apex/AVX_SalesScript_ctr.getShipToByTask';
export default class Avx_salesscript_fire_event extends LightningElement {

    @api recordId;
    @track currenRecordId='';
    @track currenObjectName = '';

    @wire(CurrentPageReference) pageRef;
    
    connectedCallback() {
        console.log('connectedCallback-->', this.recordId);
        this.currenRecordId = this.recordId;
        this.currenObjectName = this.objectApiName;
        registerListener('handleRefreshRecordId', this.handleRefreshRecordId, this);
    }

    renderedCallback(){
        console.log('renderedCallback-->', this.recordId);
    }

    handleRefreshRecordId(param){
        console.log('refresh recordId-->', this.currenRecordId);
        return refreshApex(this.wireShipTo);
    }
    

    @wire(getShipToByTask, { idTask: '$currenRecordId' })
    wireShipTo({ error, data }){ 
        console.log('idRecord-->', this.recordId);
        console.log('Enter to getShipToByTask @wired-->', data);
         if(data) {
             let result = JSON.parse(JSON.stringify(data));
             console.log('send data to Sales Script-->', data);
             //fireEvent(this.pageRef, 'handleShiptToFromTask', JSON.stringify(result));
         } else if (error) {
             console.log('error: ', JSON.parse(JSON.stringify(error)));
         }
     }
}