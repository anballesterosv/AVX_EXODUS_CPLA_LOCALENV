/* eslint-disable no-console */
import { LightningElement,track,wire,api } from 'lwc';
//Utilerias
import { deleteRecord } from 'lightning/uiRecordApi';
import { getRecord } from "lightning/uiRecordApi";
import TELESALESAPLAN_RT from '@salesforce/schema/TelesalesPlan__c.RecordTypeId';

import getPlanDetailsByPlan  from '@salesforce/apex/AVX_TeleSalesPlan_ctr.getPlanDetailsByPlan';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPickistValuesByField from '@salesforce/apex/AVX_TeleSalesPlan_ctr.getPickistValuesByField';
import canEdit from '@salesforce/apex/AVX_TeleSalesPlan_ctr.canEdit';
import getPlanDetailsByPlanReload from '@salesforce/apex/AVX_TeleSalesPlan_ctr.getPlanDetailsByPlanReload';
import getRecordTypeById from '@salesforce/apex/AVX_TeleSalesPlan_ctr.getRecordTypeById';

//Custom labels
import AVX_Telesales_Filter_By_day from '@salesforce/label/c.AVX_Telesales_Filter_By_day';
import AVX_Telesales_Order_by from '@salesforce/label/c.AVX_Telesales_Order_by';
import AVX_Telesales_Name from '@salesforce/label/c.AVX_Telesales_Name';
import AVX_Telesales_ERP_Number from '@salesforce/label/c.AVX_Telesales_ERP_Number';
import AVX_Telesales_Status from '@salesforce/label/c.AVX_Telesales_Status';
import AVX_Telesales_Identification_Number from '@salesforce/label/c.AVX_Telesales_Identification_Number';
import AVX_Telesales_Hour from '@salesforce/label/c.AVX_Telesales_Hour';
import AVX_Telesales_Day from '@salesforce/label/c.AVX_Telesales_Day';
import AVX_Telesales_Actions from '@salesforce/label/c.AVX_Telesales_Actions';
import AVX_Telesales_Edit from '@salesforce/label/c.AVX_Telesales_Edit';
import AVX_Telesales_Delete	from '@salesforce/label/c.AVX_Telesales_Delete';
import AVX_Telesales_Records_deleted from '@salesforce/label/c.AVX_Telesales_Records_deleted';
import AVX_Telesales_Name_asc from '@salesforce/label/c.AVX_Telesales_Name_asc';
import AVX_Telesales_Name_desc from '@salesforce/label/c.AVX_Telesales_Name_desc';
import AVX_Telesales_ERP_Number_asc from '@salesforce/label/c.AVX_Telesales_ERP_Number_asc';
import AVX_Telesales_ERP_Number_desc from '@salesforce/label/c.AVX_Telesales_ERP_Number_desc';
import AVX_Telesales_Yes from '@salesforce/label/c.AVX_Telesales_Yes';
import AVX_Telesales_No from '@salesforce/label/c.AVX_Telesales_No';
import AVX_Telesales_Message_confirm_delete from '@salesforce/label/c.AVX_Telesales_Message_confirm_delete';
import AVX_Telesales_Hour_asc from '@salesforce/label/c.AVX_Telesales_Hour_asc';
import AVX_Telesales_Hour_desc from '@salesforce/label/c.AVX_Telesales_Hour_desc';
import AVX_telesales_Telemarketer from '@salesforce/label/c.AVX_telesales_Telemarketer';
//listener
import {CurrentPageReference} from 'lightning/navigation';
import {fireEvent,unregisterAllListeners, registerListener} from 'c/pubsub';


//listener 

export default class Avx_telesalesplan_detail extends LightningElement {

    //Custom labels
    label = {
        AVX_Telesales_Filter_By_day,
        AVX_Telesales_Order_by,
        AVX_Telesales_Name,
        AVX_Telesales_ERP_Number,
        AVX_Telesales_Status,
        AVX_Telesales_Identification_Number,
        AVX_Telesales_Hour,
        AVX_Telesales_Day,
        AVX_Telesales_Actions,
        AVX_Telesales_Edit,
        AVX_Telesales_Delete,
        AVX_Telesales_Records_deleted,
        AVX_Telesales_Name_asc,
        AVX_Telesales_Name_desc,
        AVX_Telesales_ERP_Number_asc,
        AVX_Telesales_ERP_Number_desc,
        AVX_Telesales_Yes,
        AVX_Telesales_No,
        AVX_Telesales_Message_confirm_delete,
        AVX_Telesales_Hour_asc,
        AVX_Telesales_Hour_desc,
        AVX_telesales_Telemarketer
    };

    
    //listener atributes
    @wire(CurrentPageReference) pageRef;
    @api objectApiName;
    @api recordId;
    @track currenObjectName;
    @track currenRecordId;
    @track canEdit = false;
    @track isContingency = false;
    @track isWorkPlan = false;

    @track showSpinner = false;

    //load table and filter by key word
    @track orderByDetailSelected = 'HOURASC';
    @track daySelected = 'GENERAL';
    @track reloadAux = true;

    @track accountDetailToSearch =  '';
    @track showInstantResultAccountDetail = false;
    @track lstPlanDetails = [];
    @track isSpanish = false;

    //Detail
    @track dayDetail = '';
    @track checkAll = false;
    @track hourDetail = '';
    @track priorityDetail = '';

    //picklistvalues
    @track lstDays = []; 
    @track lstPriority = [];
   
    @track daysOfTheWeekendSelected = [];
    //dates
    @track startDatePlan;
    @track endDatePlan;

    //confirm modal
    @track showModalConfirm = false;
    @track message = this.label.AVX_Telesales_Message_confirm_delete;
    @track modalHeading = 'Confirm';
    @track recordToDelete='';
    @track fullObjectToDelete = null;
    @track objTelesalesPlan = null;
    @track recordTypeInfo = null;

     //RecordType
     @wire(getRecord, { recordId: '$recordId', fields: [TELESALESAPLAN_RT] })
     wireRecordType({ error, data }){ 
         if(data) {
             let result = JSON.parse(JSON.stringify(data));
             console.log('TelesalesPlan: ', result);
             this.objTelesalesPlan = result;
             this.recordTypeInfo = this.objTelesalesPlan.recordTypeInfo;
             if(this.recordTypeInfo.recordTypeId){
                getRecordTypeById({id: this.recordTypeInfo.recordTypeId})
                .then(data => {
                    console.log('data-->', data);
                    this.isContingency = (data.DeveloperName==='ContingencyPlan');
                    this.isWorkPlan = (data.DeveloperName === 'WorkPlan');
                    console.log('recordType-->',this.recordTypeInfo );
                    this.reloadTablaDetails();
                })
                .catch(error => {
                    console.log('Error when loading Record type',  error.message);
                    this.showSpinner = false;
                });
            }
         } else if (error) {
             let result = JSON.parse(JSON.stringify(error));
             console.log('error: ', result);
         }
     }

    //listener
    connectedCallback() {
        // subscribe to inputChangeEvent event
        registerListener('inputChangeEvent', this.handleChange, this);
        registerListener('handleReloadTableDetails', this.handleReloadTableDetails,this);
        this.currenRecordId = this.recordId;
        this.currenObjectName = this.objectApiName;
    }

    disconnectedCallback() {
        // unsubscribe from inputChangeEvent event
        unregisterAllListeners(this);
    }

    //handle fired events
    handleReloadTableDetails(reload) {
        if(reload){
            this.reloadTablaDetails();
        }
    }

    reloadTablaDetails(){
        this.showSpinner = true; 
        getPlanDetailsByPlanReload({idPlan: this.currenRecordId, dayFilter: this.daySelected, orderBy: this.orderByDetailSelected})
            .then(result => {
                this.transformPlanDetail(result);
                
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
    }

    handleChange(inpVal) {
        this.inpVal = inpVal;
    }
    
    //handle fired events end

    //can edit
    @wire(canEdit)
    wiredCanEdit({error, data}){
        if (data) {
            this.canEdit = data;
        } else if (error) {
            console.log('Error to get the profile');
        }
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
        this.reloadTelesalesPlanDetails();
    }

    get orderPlanDetailByOptions (){
        return [
                 { label: this.label.AVX_Telesales_Hour_asc , value: 'HOURASC' },
                 { label: this.label.AVX_Telesales_Hour_desc , value: 'HOURDESC' }
               ];
    }

    handleOrderByDetailSelected(e){
        this.orderByDetailSelected = e.detail.value;
        this.reloadTelesalesPlanDetails();
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

    getValuesTraslated(option, value){
        let valueTraslated = value;
        if(this.isSpanish){
            if(option ==='DAY' ){
                if(value==='Monday'){
                    valueTraslated = 'Lunes';
                } else if(value==='Tuesday'){
                    valueTraslated = 'Martes';
                }else if(value==='Wednesday'){
                    valueTraslated = 'Miércoles';
                }else if(value==='Thursday'){
                    valueTraslated = 'Jueves';
                }else if(value==='Friday'){
                    valueTraslated = 'Viernes';
                }else if(value==='Saturday'){
                    valueTraslated = 'Sábado';
                }else if(value==='Sunday'){
                    valueTraslated = 'Domingo';
                }
            } else if(option === 'STATUS'){
                if(value === 'Active'){
                    valueTraslated = 'Activo';
                } else {
                    valueTraslated = 'Inactivo';
                }

            }
        }
        return valueTraslated;
    }

    transformPlanDetail(result){
        this.showSpinner = true;
        this.lstPlanDetails = [];
        let indexKey=0;
        console.log('result transformPlanDetail-->', result);
        for(let key in result){
            if (result.hasOwnProperty(key)) {
                indexKey = indexKey++;
                let obj = JSON.parse(JSON.stringify(result[key]));
                obj.Id = obj.telesalesPlanDetail.Id + 'EDIT-' + Math.random() + indexKey;
                if(obj.telesalesPlanDetail.Hours__c!==undefined){
                    console.log(obj.telesalesPlanDetail.Hours__c);
                    let hourBeforeTransfor = obj.telesalesPlanDetail.Hours__c;
                    obj.Hours__c = new Date(hourBeforeTransfor).toISOString().toString().replace('1970-01-01T',''); 
                    obj.hour = this.transformHourToAmPmText(hourBeforeTransfor);
                }
                obj.dayTraslated = this.getDayTraslated(obj.telesalesPlanDetail.DayOfTheWeek__c);
                obj.statusTraslated = this.getValuesTraslated('STATUS', obj.telesalesPlanDetail.Ship_To__r.Status__c);
                
                this.lstPlanDetails.push(obj);
            }
        } 
        this.showSpinner = false;
    }

    reloadTelesalesPlanDetails(){
        getPlanDetailsByPlanReload({idPlan: this.currenRecordId, dayFilter: this.daySelected, orderBy: this.orderByDetailSelected})
            .then(result => {
                this.transformPlanDetail(result);
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({title: 'Error while refreshing TelesalesPlanDetail 382', 
                        message: error.message, 
                        variant: 'error'
                    }),
                );
                this.showSpinner = false;
            });
    }


    //loading plan details 
    @wire(getPlanDetailsByPlan, { idPlan:  '$currenRecordId', dayFilter: '$daySelected', orderBy:'$orderByDetailSelected'})
    wiredTelesalesPlanDetails({ error, data }) {
        if (data) {
            this.transformPlanDetail(data);
        } else if (error) {
            this.lstPlanDetails = [];
        } 
    }

    //plan details options: edit & remove
    handleEditPlanDetail(e) {
        console.log('isWorkPlan', this.isWorkPlan);
        console.log('current-->', e.currentTarget.id);
        let targetArray = (e.currentTarget.id).split('-');
        let idSelected = targetArray[0];
        let jsonDetailToEdit = '';
        let lstAux = [];
        for(let key in this.lstPlanDetails){
            if (this.lstPlanDetails.hasOwnProperty(key)) {
                let obj = this.getObjectToModify(this.lstPlanDetails[key],idSelected);
                if(obj!==null){
                    jsonDetailToEdit = JSON.stringify(obj);
                } else {
                    lstAux.push(this.lstPlanDetails[key]);
                }
            }
        }
        console.log('jsonEdit-->', jsonDetailToEdit); 
        if(this.isWorkPlan){
            fireEvent(this.pageRef, 'handleFullListPlanDetails', JSON.stringify(lstAux));
            fireEvent(this.pageRef, 'handleIsSpanish', this.isSpanish);
            fireEvent(this.pageRef, 'handleEditPlansDetails', jsonDetailToEdit);
        } else if (this.isContingency){
            fireEvent(this.pageRef, 'handleEditDetailContingency',jsonDetailToEdit);
        
            console.log('isContigency', this.isContingency);
        }
        
    }

    getObjectToModify(objParam, idSelected){
        let finalObj = null;
        let objToEdit = JSON.parse(JSON.stringify(objParam));
        let idArray = (objToEdit.telesalesPlanDetail.Id).split('EDIT-');
        let idAux = idArray[0];
        if(idAux === idSelected ) {
            finalObj = objToEdit;
        }
        return finalObj;
    }

    handleRemovePlanDetail(e){
        console.log('currectTarget-->', e.currentTarget.id);
        let targetArray = (e.currentTarget.id).split('-');
        this.recordToDelete = targetArray[0];
        console.log('recordToDelete-->', this.recordToDelete);
        for(let key in this.lstPlanDetails){
            if (this.lstPlanDetails.hasOwnProperty(key)) {
                let obj = this.getObjectToModify(this.lstPlanDetails[key],this.recordToDelete);
                if(obj!==null) {
                    this.fullObjectToDelete = obj;
                    break;
                }
            }
        }
        this.showModalConfirm = true;
        console.log('fullObjectToDelete-->', this.fullObjectToDelete);
    }

    handleKeyUpDetailText(e){
        this.detailTextToSearch = e.target.value;
    }

    handleKeyUpAccountDetail(e){
        this.accountDetailToSearch =  e.target.value;
        this.showInstantResultAccountDetail = true;
    }

    handlePriorityDetail(e){
        this.priorityDetail = e.detail.value;
    }

    handleHourDetail(e){
        this.hourDetail = e.target.value;
    }

    removePlanDetails(recordId){
        let lstPlanDetailsAux = [];
        for(let key in this.lstPlanDetails){
            if (this.lstPlanDetails.hasOwnProperty(key)) {
                let obj = JSON.parse(JSON.stringify(this.lstPlanDetails[key]));
                let targetArray = (obj.Id).split('EDIT-');
                let idAux = targetArray[0];
                if(idAux !== recordId){
                    lstPlanDetailsAux.push(obj);
                }
            }
        }
        this.lstPlanDetails = [];
        this.lstPlanDetails = lstPlanDetailsAux;
    }
    

    handleSave(){
        let lstPlanDetailsToUpdate = [];
        for(let key in this.lstPlanDetails){
            if (this.lstPlanDetails.hasOwnProperty(key)) {
                let obj = JSON.parse(JSON.stringify(this.lstPlanDetails[key]));
                let objToUpdate = {
                    Plan__c: '',
                    ShipTo__c: obj.ShipTo__c,
                    DayOfTheWeek__c: this.daysOfTheWeekendSelected,
                    EndDate__c: this.endDatePlan,
                    Hour__c: this.hourDetail,
                    Priority__c: this.priorityDetail,
                    StartDate__c: this.startDatePlan
                }
                lstPlanDetailsToUpdate.push(objToUpdate);
            } 
        }
                           
    }  


    handleConfirmNo(){
        this.recordToDelete='';
        this.showModalConfirm = false;
    }

    handleConfirmYes(){
        this.showModalConfirm = false;
        this.showSpinner = true;
        deleteRecord(this.recordToDelete)
        .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: this.label.AVX_Telesales_Records_deleted,
                        variant: 'success'
                    })
                );
                this.removePlanDetails(this.recordToDelete);
                this.showSpinner = false;
                fireEvent(this.pageRef, 'handleReloadClient', true);
        })
        .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                this.showSpinner = false;
        });
    }
}