import { LightningElement,track,wire,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getShipToByTask  from '@salesforce/apex/AVX_SalesScript_ctr.getShipToByTask';
import {CurrentPageReference} from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import getSalesScriptByCountry from '@salesforce/apex/AVX_SalesScript_ctr.getSalesScriptByCountry';
import AVX_Telesales_No_sales_script from '@salesforce/label/c.AVX_Telesales_No_sales_script';
import AVX_Telesales_Client_no_country from '@salesforce/label/c.AVX_Telesales_Client_no_country';


export default class avx_salesscript extends LightningElement {

    labels = {
        AVX_Telesales_No_sales_script,
        AVX_Telesales_Client_no_country
    }

    @api recordId;
    @api validationMessage = '';
    @track objectApiName ='NONE';
    @track lstSalesScripts = [];
    @track currentScript = 'DEFAULT';
    @api isTask = false;
    @track showSpinner = false;

  

    @wire(CurrentPageReference)
    wiredPageRef(pageRef) {
        this.pageRef = pageRef;
        if(this.pageRef) {
            this.validationMessage='';
            this.recordId = this.pageRef.attributes.recordId;
            this.objectApiName = this.pageRef.attributes.objectApiName;
            if(this.objectApiName==='Task'){
                if(this.recordId!==undefined){
                    this.isTask = true;
                } else {
                    this.validationMessage = this.labels.AVX_Telesales_No_sales_script;
                    this.lstSalesScripts = [];
                }
            } else {
                this.isTask = false;
                console.log(this.objectApiName);
                this.validationMessage = this.labels.AVX_Telesales_No_sales_script;
                this.lstSalesScripts = [];
            }
        }
    }


    handleShiptToFromTask(json){
        this.showSpinner = true;
        console.log('json', json);
        if(this.isTask){
            getSalesScriptByCountry({country: json.Country__c})
            .then(result => {
                console.log('response sales script-->', result);
                this.lstSalesScripts = [];
                if(result.length>0) {
                    let existCountyCode = false;
                    let existCountry = false;
                    let countrySalesScript = {};
                    let countyCodeSalesScript = null;
                    let currentSalesScript = {};
                    let lstAux = [];
                    for(let key in result) {
                        if (result.hasOwnProperty(key)) {
                            let additem = true;
                            let obj = JSON.parse(JSON.stringify(result[key]));
                            obj.keyForeach = Math.random() + '00' + Math.random() ;
                            if(json.Country__c !== 'ALL'){
                                if(obj.Country__c && obj.CountyCode__c){//country and contycode
                                    if(json.Country__c === obj.Country__c && json.CountyCode__c == obj.CountyCode__c){
                                        countyCodeSalesScript = obj;
                                        additem = false;
                                        existCountyCode = true;
                                    }
                                }
                                if(obj.Country__c && !obj.CountyCode__c){
                                    if(json.Country__c === obj.Country__c){
                                        countrySalesScript = obj;
                                        additem = false;
                                    }
                                }
                                if(obj.Country__c === json.Country__c){
                                    existCountry=true;
                                }
                            }
                            if(additem){
                                lstAux.push(obj);
                            }
                        }
                    }
                    console.log('before validation-->', json.Country__c);
                    console.log(json.Country__c !== 'ALL')
                    if(json.Country__c!=='ALL'){
                        if(existCountry){
                            this.lstSalesScripts.push(countrySalesScript);
                        }
                        if(existCountyCode){
                            console.log('existCountyCode',existCountyCode);
                            this.lstSalesScripts.push(countyCodeSalesScript);
                        }
                        
                        for(let key in lstAux) {// add the rest of the sales scripts
                            if (lstAux.hasOwnProperty(key)) {
                                let obj = JSON.parse(JSON.stringify(lstAux[key]));
                                this.lstSalesScripts.push(obj);
                            }
                        }
                        const accordion = this.template.querySelector('.example-accordion');
                        if(json.CountyCode__c && existCountyCode){
                            accordion.activeSectionName = json.CountyCode__c;
                            console.log('existCountyCode', existCountyCode);
                        } else {
                            if(existCountry){
                                console.log('existCountry');
                                accordion.activeSectionName = json.Country__c;
                            } else {
                                console.log('no exist country');
                                
                                let message= (this.labels.AVX_Telesales_No_sales_script).split('.');
                                let htmlMessage = '<div class="slds-text-color_destructive"><p>'+this.labels.AVX_Telesales_No_sales_script +'</p></div>';
                                let shipToTmp = {
                                    keyForeach: Math.random() + '00' + Math.random(), 
                                    Name: message[0],
                                    CountyCode__c: 'NONE',
                                    TelesalesScript__c: htmlMessage
                                }
                                this.lstSalesScripts.push(shipToTmp);
                                const accordion = this.template.querySelector('.example-accordion');
                                accordion.activeSectionName = 'NONE';
                            }
                        }
                    } else {
                        let message= (this.labels.AVX_Telesales_No_sales_script).split('.');
                        console.log(message[0]);
                        let htmlMessage = '<div class="slds-text-color_destructive"><p>'+this.labels.AVX_Telesales_No_sales_script +'</p></div>';
                        let shipToTmp = {
                            keyForeach: Math.random() + '00' + Math.random(), 
                            Name: message[0],
                            CountyCode__c: json.Country__c,
                            TelesalesScript__c: htmlMessage
                        }
                        this.lstSalesScripts.push(shipToTmp);
                        for(let key in lstAux) {// add the rest of the sales scripts
                            if (lstAux.hasOwnProperty(key)) {
                                let obj = JSON.parse(JSON.stringify(lstAux[key]));
                                this.lstSalesScripts.push(obj);
                            }
                        }
                        const accordion = this.template.querySelector('.example-accordion');
                        accordion.activeSectionName = json.Country__c;
                    }
                    
                } else {
                    this.validationMessage = this.labels.AVX_Telesales_No_sales_script;
                    this.lstSalesScripts = [];
                }           
            })
            .catch(error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error while refreshing TelesalesPlanDetail 181', 
                                message: error.message, 
                                variant: 'error'
                            }),
            );
            this.showSpinner = false;
            });  
            this.showSpinner = false;
        } else {
            this.validationMessage = this.labels.AVX_Telesales_No_sales_script;
            this.lstSalesScripts = [];
            this.showSpinner = false;
        }
        
    }

    @wire(getShipToByTask, { idTask: '$recordId' })
    wireShipTo({ error, data }){ 
         if(data) {
             if(this.isTask){
                if(data.Country__c){
                    this.handleShiptToFromTask(data);
                } else {
                    let newShipTo = {
                        Country__c:'ALL'
                    }
                    this.handleShiptToFromTask(newShipTo);
                }
             } else {
                this.validationMessage = this.labels.AVX_Telesales_No_sales_script;
                this.lstSalesScripts = [];
             }
             
         } else if (error) {
             console.log('error: ', JSON.parse(JSON.stringify(error)));
         }
     }
}