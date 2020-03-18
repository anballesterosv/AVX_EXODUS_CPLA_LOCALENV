/* eslint-disable guard-for-in */
import { LightningElement,track,wire,api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import {CurrentPageReference,NavigationMixin} from 'lightning/navigation';
import {fireEvent,registerListener} from 'c/pubsub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getRecord } from "lightning/uiRecordApi";
import TELESALESAPLAN_RT from '@salesforce/schema/TelesalesPlanDetail__c.RecordTypeId';
    
//apex methods
import getClientsByFilters  from '@salesforce/apex/AVX_TeleSalesPlan_ctr.getClientsByFilters';
import getClientsByFiltersReload from '@salesforce/apex/AVX_TeleSalesPlan_ctr.getClientsByFiltersReload';
import canEdit from '@salesforce/apex/AVX_TeleSalesPlan_ctr.canEdit';
import getPickistValuesByField from '@salesforce/apex/AVX_TeleSalesPlan_ctr.getPickistValuesByField';
import getContingencyClients from '@salesforce/apex/AVX_TeleSalesPlan_ctr.getContingencyClients';
import reloadContingencyClients from '@salesforce/apex/AVX_TeleSalesPlan_ctr.reloadContingencyClients';
import getRecordTypeById from '@salesforce/apex/AVX_TeleSalesPlan_ctr.getRecordTypeById';
//apex methods

import AVX_Telesales_Clients_to_assign	from '@salesforce/label/c.AVX_Telesales_Clients_to_assign';
import AVX_Telesales_Items_to_show	from '@salesforce/label/c.AVX_Telesales_Items_to_show';
import AVX_Telesales_Order_by	from '@salesforce/label/c.AVX_Telesales_Order_by';
import AVX_Telesales_Filter	from '@salesforce/label/c.AVX_Telesales_Filter';
import AVX_Telesales_Add	from '@salesforce/label/c.AVX_Telesales_Add';
import AVX_Telesales_Edit	from '@salesforce/label/c.AVX_Telesales_Edit';
import AVX_Telesales_Name	from '@salesforce/label/c.AVX_Telesales_Name';
import AVX_Telesales_ERP_Number	from '@salesforce/label/c.AVX_Telesales_ERP_Number';
import AVX_Telesales_Name_asc from '@salesforce/label/c.AVX_Telesales_Name_asc';
import AVX_Telesales_Name_desc from '@salesforce/label/c.AVX_Telesales_Name_desc';
import AVX_Telesales_ERP_Number_asc from '@salesforce/label/c.AVX_Telesales_ERP_Number_asc';
import AVX_Telesales_ERP_Number_desc from '@salesforce/label/c.AVX_Telesales_ERP_Number_desc';
import AVX_Telesales_All from '@salesforce/label/c.AVX_Telesales_All';
import AVX_Telesales_Added from '@salesforce/label/c.AVX_Telesales_Added';
import AVX_Telesales_Non_added from '@salesforce/label/c.AVX_Telesales_Non_added';
import AVX_telesales_Telemarketer from '@salesforce/label/c.AVX_telesales_Telemarketer';
import AVX_Telesales_Plan from  '@salesforce/label/c.AVX_Telesales_Plan';
import AVX_Telesales_Filter_By_day from '@salesforce/label/c.AVX_Telesales_Filter_By_day';
import AVX_Telesales_Hour from '@salesforce/label/c.AVX_Telesales_Hour';
import AVX_Telesales_Day from '@salesforce/label/c.AVX_Telesales_Day';
import AVX_Telesales_Select_all from '@salesforce/label/c.AVX_Telesales_Select_all';
import AVX_Telesales_No_records_found  from '@salesforce/label/c.AVX_Telesales_No_records_found';

export default class Avx_telesalesplan_clientlist extends NavigationMixin(LightningElement)  {
 
    label = {
        AVX_Telesales_Clients_to_assign,
        AVX_Telesales_Items_to_show,
        AVX_Telesales_Filter,
        AVX_Telesales_Add,
        AVX_Telesales_Edit,
        AVX_Telesales_Order_by,
        AVX_Telesales_Name,
        AVX_Telesales_ERP_Number,
        AVX_Telesales_Name_asc,
        AVX_Telesales_Name_desc,
        AVX_Telesales_ERP_Number_asc,
        AVX_Telesales_ERP_Number_desc,
        AVX_Telesales_All,
        AVX_Telesales_Added,
        AVX_Telesales_Non_added,
        AVX_telesales_Telemarketer,
        AVX_Telesales_Plan,
        AVX_Telesales_Filter_By_day,
        AVX_Telesales_Hour,
        AVX_Telesales_Day,
        AVX_Telesales_Select_all,
        AVX_Telesales_No_records_found
    }
    //listener atributes
    @wire(CurrentPageReference) pageRef;
    @track canEdit = false;
    @track isContingency = false;
    @track isWorkPlan = false;
    @api objectApiName;
    @api recordId;
    @track recordTypeInfo = null;

    @track currenObjectName;
    @track currenRecordId;
    @track isSpanish;

    //redirect
    @api idToRedirect='';
    @api objectToRedirect='';
    @track url;

    // combos & filter
    @track orderBySelected= 'NAMEASC';
    @track itemToShowSelected = 'NONADDED';
    @track clientToSearch = '';
    @track orExpression = '';
    @track daySelected = 'GENERAL';
    @track error='';
    @track noRecordsFound = '';
    
    @track lstDays = [];
    @track lstClients = [];
    @track listAuxClients = [];
    @track fullListClients = [];
    @track lstContingencyClients = [];
    @track bottonScroll = 80;
    
    @track numRows = 8;
    @track visibleScroll = 80;
    @track objTelesalesPlan= null;
    @track checkAll = false;
    @track showSpinner = false;

    @track contingencyCounter = 0;
    //RecordType
    @wire(getRecord, { recordId: '$recordId', fields: [TELESALESAPLAN_RT] })
    wireRecordType({ error, data }){ 
        if(data) {
            let result = JSON.parse(JSON.stringify(data));
            console.log('TelesalesPlan: ', result);
            this.objTelesalesPlan = result;
            console.log('TelesalesPlan inEdition-->', this.objTelesalesPlan);
            this.recordTypeInfo = this.objTelesalesPlan.recordTypeInfo;
            if(this.recordTypeInfo.recordTypeId){
                getRecordTypeById({id: this.recordTypeInfo.recordTypeId})
                .then(data => {
                    console.log('data-->', data);
                    this.isContingency = (data.DeveloperName==='ContingencyPlan');
                    this.isWorkPlan = (data.DeveloperName === 'WorkPlan');
                    console.log('recordType-->',this.recordTypeInfo );
                    this.reloadClientsToAssign();
                    this.reloadContingencyClients();
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error when loading Record type', 
                            message: error.message, 
                            variant: 'error'
                        }),
                    );
                    this.showSpinner = false;
                });
            }
        } else if (error) { 
            let result = JSON.parse(JSON.stringify(error));
            console.log('error: ', result);
        }
    }
    
    //can edit
    @wire(canEdit)
    wiredCanEdit({error, data}){
        if (data) {
            this.canEdit = data;
        } else if (error) {
            console.log('Error to get the profile');
        }
    }

    //listener
    connectedCallback() {
        this.currenRecordId = this.recordId;
        console.log('currenRecordId-->', this.currenRecordId);
        this.currenObjectName = this.objectApiName;
        registerListener('handleReloadClient',this.handleReloadClient, this);
        //LL20190513 - Generate URL for viewing record page
        this.relationshipRef = {
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.idToRedirect,
                    objectApiName: this.objectToRedirect,
                    actionName: 'view'
                }
        };
        this[NavigationMixin.GenerateUrl](this.relationshipRef)
                .then((url) => {
                    this.url = url;
        });
      


    }

    handleOpenModalContingency(){
        let lstAux = [];
        for(let key in this.lstContingencyClients) {
            if (this.lstContingencyClients.hasOwnProperty(key)) {
                let obj = JSON.parse(JSON.stringify(this.lstContingencyClients[key]));
                console.log('obj->', obj);
                obj.keyForeach = obj.keyForeach + Math.random();
                if (obj.checked) {
                    lstAux.push(obj);
                } 
            }
        }
        fireEvent(this.pageRef, 'handleOpenModalContingency', JSON.stringify(lstAux));
    }


    handleClientChecked(e) {        
        let index= e.currentTarget.dataset.key;
        let lstAux = [];
        for(let key in this.lstContingencyClients) {
            if (this.lstContingencyClients.hasOwnProperty(key)) {
                let obj = JSON.parse(JSON.stringify(this.lstContingencyClients[key]));
                if (key === index) {
                    obj.checked = !obj.checked;
                    console.log('objChecked-->', obj);
                    lstAux.push(obj);
                } else { 
                    lstAux.push(obj);
                }
            }
        }
        this.lstContingencyClients = [];
        this.lstContingencyClients = lstAux;
    }
    
    handleCheckAll(){
        this.checkAll = !this.checkAll;
        let lstAux = [];
        if (this.lstContingencyClients.length>0) {
            for(let key in this.lstContingencyClients) {
                if(this.lstContingencyClients.hasOwnProperty(key)){ 
                    let obj = JSON.parse(JSON.stringify(this.lstContingencyClients[key]));
                    obj.checked = this.checkAll;
                    lstAux.push(obj);
                }
            }
            this.lstContingencyClients = [];
            this.lstContingencyClients = lstAux;
        }
    }

    //fire events anda data to another lwc
    handleModalAddEditClient(e){
        let idSelected = e.currentTarget.dataset.key;
        fireEvent(this.pageRef, 'handleClientSelected', idSelected);
    }   

    //Combos & filter
    get orderClientsByoptions() {
        return [
            { label: this.label.AVX_Telesales_Name_asc , value: 'NAMEASC' },
            { label: this.label.AVX_Telesales_Name_desc , value: 'NAMEDESC' },
            { label: this.label.AVX_Telesales_ERP_Number_asc, value: 'ERPASC' },
            { label: this.label.AVX_Telesales_ERP_Number_desc, value: 'ERPDESC' },
               ];
    }
 
    //combos
    @wire(getPickistValuesByField, { fieldName: 'DAYS'})
    wiredPickListValuesDays({ error, data }) {
        if (data) {
            this.lstDays = [];
            let optionSelected = {label: 'General', value: 'GENERAL', };  
            this.lstDays.push(optionSelected);
            for(let key in data){
                if (data.hasOwnProperty(key)) { 
                    if(data[key].label==='Lunes'){
                        this.isSpanish = true;
                    }
                    let obj = {label: data[key].label, value: data[key].value};
                    this.lstDays.push(obj);
                }
            }
        } else if (error) {
            this.lstDays = [];
        }
    }

    
    handleDaySelected(e){
        this.daySelected = e.detail.value;
        this.reloadContingencyClients();
    }

    handleKeyPress(event) {
        if(event.keyCode===13){
            console.log('Enter');
        }
        console.log(event.keyCode); 
        let input_number = event.target.value;
        console.log('Number: '+input_number); 
    }   


    handleorderClientsByoptions(e) {
        this.orderBySelected = e.detail.value;
        this.reorderResults();
    }

    get itemsToShowOptions() {
        return [
                 { label: this.label.AVX_Telesales_All , value: 'ALL' },
                 { label: this.label.AVX_Telesales_Added, value: 'ADDED' },
                 { label: this.label.AVX_Telesales_Non_added, value: 'NONADDED' }
               ];
    }
    
    handlerItemsToShowOptions (e){
        this.itemToShowSelected = e.detail.value;
        this.reloadClientsToAssign();
    }

    handleCleanClientToSearch(e){
        this.clientToSearch =  e.target.value;
        this.buildOrExpression();
        this.reloadClientsToAssign();
        this.reloadContingencyClients();
    }
    handleclientToSearch(e) { 
        this.clientToSearch =  e.target.value; 
        this.buildOrExpression();
        this.reloadClientsToAssign();
        this.reloadContingencyClients();
    }

    handleReloadClient(reload){
        if(reload){
            this.reloadClientsToAssign();
            this.reloadContingencyClients();
        }
    }

    buildOrExpression(){
       this.orExpression  = this.clientToSearch.toLowerCase().split(' or').join(',');
    }
    
    //reload work plan
    reloadClientsToAssign(){   
        if (this.isWorkPlan) {
            this.showSpinner = true;
            getClientsByFiltersReload({idPlan: this.currenRecordId, textfilter:this.orExpression, itemsToShow: this.itemToShowSelected,
                isWorkPlan: this.isWorkPlan })
            .then(data => {
                    this.lstClients = [];
                    this.fullListClients = [];
                    let i=0;
                    this.bottonScroll = 80;
                    if(data.length>0){
                        this.noRecordsFound ='';
                        let indexKey = 0;
                        for(let key in data) {
                            if(data.hasOwnProperty(key)){ 
                                indexKey = indexKey++;
                                let obj = JSON.parse(JSON.stringify(data[key]));
                                obj.keyForeach = obj.client.Id + Math.random() + indexKey;
                                if(i<this.numRows) {
                                    this.lstClients.push(obj);
                                    this.fullListClients.push(obj);
                                } else {
                                    this.fullListClients.push(obj);
                                }
                            }
                            i++;
                        }
                    } else {
                        this.noRecordsFound = this.label.AVX_Telesales_No_records_found;
                    }
                    this.showSpinner = false;  
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error while refreshing Clients to assign', 
                            message: error.message, 
                            variant: 'error'
                        }),
                    );
                    this.showSpinner = false;
            });
        }
    }

    transformHourToAmPmText(hour) {
        let finalHour = '';
        if (hour!==undefined) {
            let isoTime = new Date(hour).toISOString().toString().replace('1970-01-01T',''); 
            var hours   = parseInt(isoTime.substring(0, 2), 10),
                minutes = isoTime.substring(3, 5),
                ampm    = 'AM';
            if (hours == 12) {
                ampm = 'PM';
            } else if (hours == 0) {
                hours = 12;
            } else if (hours > 12) {
                hours -= 12;
                ampm = 'PM';
            }
            finalHour = hours + ':' + minutes + ' ' + ampm;
        }
        return finalHour;
    }



    transformDataContingency(data) {
        this.lstContingencyClients = [];
        if(data.length > 0) {
            this.noRecordsFound  ='';
            let indexKey = 0;
            for(let key in data) {
                if(data.hasOwnProperty(key)){ 
                    indexKey = indexKey++;
                    let obj = JSON.parse(JSON.stringify(data[key]));
                    obj.keyForeach = obj.telesalesPlanDetail.Id + Math.random() + indexKey;
                    obj.day = this.getDayTraslated(obj.telesalesPlanDetail.DayOfTheWeek__c);
                    obj.hour = this.transformHourToAmPmText(obj.telesalesPlanDetail.Hours__c);
                    //console.log('obj-->', obj);
                    this.lstContingencyClients.push(obj);
                }
            }
        } else {
            this.noRecordsFound = this.label.AVX_Telesales_No_records_found;
        }
        this.showSpinner = false; 
        console.log('wiredClients..>', this.orderBySelected);
        this.reorderResults();
    }

    reorderResults(){
        if((this.orderBySelected).includes('NAME')) {
            if (this.orderBySelected==='NAMEASC') {
                // sort by name
                if(this.isWorkPlan) {
                    this.lstClients.sort(function(a, b) {
                        var nameA = a.client.Name.toUpperCase(); // ignore upper and lowercase
                        var nameB = b.client.Name.toUpperCase(); // ignore upper and lowercase
                            if (nameA < nameB) {return -1;}
                            if (nameA > nameB) {return 1;}
                            // names must be equal
                            return 0;
                    });
                } else  if (this.isContingency){
                    this.lstContingencyClients.sort(function(a, b) {
                        var nameA = a.telesalesPlanDetail.Ship_To__r.Name.toUpperCase(); // ignore upper and lowercase
                        var nameB = b.telesalesPlanDetail.Ship_To__r.Name.toUpperCase(); // ignore upper and lowercase
                            if (nameA < nameB) {return -1;}
                            if (nameA > nameB) {return 1;}
                            // names must be equal
                            return 0;
                        });
                }
            } else {
                if(this.isWorkPlan) {
                    this.lstClients.reverse();
                } else if(this.isContingency){
                    this.lstContingencyClients.reverse();
                }
            }
        } else {
            if (this.orderBySelected==='ERPASC') {
                // sort by name
                if(this.isWorkPlan) {
                    this.lstClients.sort(function(a, b) {
                        var nameA='';
                        var nameB='';
                        if(a.client.ERP_Number__c){
                            nameA=a.client.ERP_Number__c.toUpperCase();
                        }
                        if(b.client.ERP_Number__c){
                            nameB=b.client.ERP_Number__c.toUpperCase();
                        } 
                        if (nameA < nameB) {return -1;}
                        if (nameA > nameB) {return 1;}
                        // names must be equal
                        return 0;
                    });
                } else if (this.isContingency){
                    this.lstContingencyClients.sort(function(a, b) {
                        var nameA='';
                        var nameB='';
                        if(a.telesalesPlanDetail.Ship_To__r.ERP_Number__c){
                            nameA=a.telesalesPlanDetail.Ship_To__r.ERP_Number__c.toUpperCase();
                        }
                        if(b.telesalesPlanDetail.Ship_To__r.ERP_Number__c){
                            nameB=b.telesalesPlanDetail.Ship_To__r.ERP_Number__c.toUpperCase();
                        } 
                        if (nameA < nameB) {return -1;}
                        if (nameA > nameB) {return 1;}
                        // names must be equal
                        return 0;
                    });
                }
            } else {
                if(this.isWorkPlan){
                    this.lstClients.reverse();
                } else if(this.isContingency){
                    this.lstContingencyClients.reverse();
                }
            }
        }
    }

    //reload contingency
    reloadContingencyClients() {
        if(this.isContingency) {
            
            reloadContingencyClients({textFilter: this.orExpression, day: this.daySelected, idContingencyPlan: this.currenRecordId })
                .then(data => {
                    this.transformDataContingency(data);
                })
                .catch(error => {
                    this.lstContingencyClients=[];
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error while refreshing Clients to assign', 
                            message: error.message, 
                            variant: 'error'
                        }),
                    );
                    this.showSpinner = false;
                });
        }
    }

    getDayTraslated(day){
        let dayTraslated = '';
        if(this.isSpanish){
            dayTraslated =  this.getDayInSpanish(parseInt(day));
        } else {
            dayTraslated = this.getDayInEnglish(parseInt(day));
        }
        return dayTraslated;
    }

    getDayInSpanish(day) {
        var dayInSpanish = '';
        if(day=== 1){
            dayInSpanish = 'Lunes';
        } else if (day ===2){
            dayInSpanish = 'Martes';
        } else if (day ===3){
            dayInSpanish = 'Miércoles';
        } else if (day ===4){
            dayInSpanish = 'Jueves';
        } else if (day ===5){
            dayInSpanish = 'Viernes';
        } else if (day ===6){
            dayInSpanish = 'Sábado';
        } else if (day ===7){
            dayInSpanish = 'Domingo';
        }
        return dayInSpanish;
    }

    getDayInEnglish(day){
        var dayInEnglish = '';
        if(day=== 1){
            dayInEnglish = 'Monday';
        } else if (day ===2){
            dayInEnglish = 'Tuesday';
        } else if (day ===3){
            dayInEnglish = 'Wednesday';
        } else if (day ===4){
            dayInEnglish = 'Thursday';
        } else if (day ===5){
            dayInEnglish = 'Friday';
        } else if (day ===6){
            dayInEnglish = 'Saturday';
        } else if (day ===7){
            dayInEnglish = 'Sunday';
        }
        return dayInEnglish;
    }

    // get clients by filters
    @wire(getClientsByFilters, {idPlan: '$currenRecordId',textfilter:'$orExpression', itemsToShow: '$itemToShowSelected',
        isWorkPlan: '$isWorkPlan'})
    wiredClients({ error, data }) { 
        console.log('itemToShowSelected-->', this.itemToShowSelected);
        this.lstClients = [];
        console.log('isWorkplan-->', this.isWorkPlan);
        if (data && this.isWorkPlan) {
            console.log('data-->', data);
            this.showSpinner = true;
            this.lstClients = [];
            this.fullListClients = [];
            let i=0;
            this.bottonScroll = 80;
            if(data.length>0){
                let indexKey = 0;
                for(let key in data) {
                    if(data.hasOwnProperty(key)){ 
                        indexKey = indexKey++;
                        let obj = JSON.parse(JSON.stringify(data[key]));
                        console.log('client-->',obj);
                        obj.keyForeach = obj.client.Id + Math.random() + indexKey;
                        if(i<this.numRows) {
                            this.lstClients.push(obj);
                            this.fullListClients.push(obj);
                        } else {
                            this.fullListClients.push(obj);
                        }
                    }
                    i++;
                }
            }
            this.showSpinner = false;
        } else if (error) {
            this.error = error;
            this.lstClients = []; 
        }
    } 

    
    // get clients by filters
    @wire(getContingencyClients, {textFilter: '$orExpression',day:'$daySelected', idContingencyPlan:'$currenRecordId' })
    wiredContingency({ error, data }) {
        if (data && this.isContingency) {
            console.log('Reload wiredContingency--->');
            this.transformDataContingency(data);
        } else if (error) {
            this.error = error;
            this.lstContingencyClients = []; 
        }
    } 


    previousHandler(idShipTo) { 
        fireEvent(this.pageRef, 'inputChangeEvent', idShipTo);
    }

    handleScrollClients(e){
        var currentScroll = e.target.scrollTop;
        if(currentScroll>this.bottonScroll){
            this.bottonScroll =  this.bottonScroll  + this.visibleScroll;
            this.loadMoreClients();
        }
    }
    
    loadMoreClients(){
        let start = this.lstClients.length;
        let limit = start + this.numRows;
        if(limit>this.fullListClients.length) {
            limit = this.fullListClients.length;
        }
        for(start;start<limit;start ++){
            let obj = JSON.parse(JSON.stringify(this.fullListClients[start]));
            this.lstClients.push(obj);
        }
    }

    navigateToRecordViewPage(e) {
        console.log('currectId', e.currentTarget.dataset.key);
        this.idToRedirect = e.currentTarget.dataset.key;
        this.objectToRedirect='TelesalesPlan__c';
        

        this.relationshipRef = {
            type: 'standard__recordPage',
            attributes: {
                recordId: this.idToRedirect,
                objectApiName: this.objectToRedirect,
                actionName: 'view'
            }
        };
        this[NavigationMixin.GenerateUrl](this.relationshipRef)
                .then((url) => {
                    this.url = url;
        });
        this[NavigationMixin.Navigate](this.relationshipRef);
    }




    
}