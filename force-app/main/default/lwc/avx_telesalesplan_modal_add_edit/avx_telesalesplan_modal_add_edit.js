import { LightningElement,track,api,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
//apex methods
import getPickistValuesByField from '@salesforce/apex/AVX_TeleSalesPlan_ctr.getPickistValuesByField';
import getPlanDetailsByShipTo from '@salesforce/apex/AVX_TeleSalesPlan_ctr.getPlanDetailsByShipTo';
import saveOrUpdateTelesalesPlanDetails from '@salesforce/apex/AVX_TeleSalesPlan_ctr.saveOrUpdateTelesalesPlanDetails';
import deleteListTelesalesPlanDetails from '@salesforce/apex/AVX_TeleSalesPlan_ctr.deleteListTelesalesPlanDetails';
import getPlanDetailsByShipToReload from '@salesforce/apex/AVX_TeleSalesPlan_ctr.getPlanDetailsByShipToReload';
import getTelemarketerByFilters from '@salesforce/apex/AVX_TeleSalesPlan_ctr.getTelemarketerByFilters';
//object
import TELESALESPLANDETAIL_ID from '@salesforce/schema/TelesalesPlanDetail__c.Id';
import TPD_TELEMARKETER_ID from '@salesforce/schema/TelesalesPlanDetail__c.Telemarketer__c';

//listener
import {CurrentPageReference} from 'lightning/navigation';
import {fireEvent,registerListener, unregisterAllListeners} from 'c/pubsub';
//listener 
//custom labels
import AVX_Telesales_Add_Edit_Client_to_Telesales_Plan	from '@salesforce/label/c.AVX_Telesales_Add_Edit_Client_to_Telesales_Plan';
import AVX_Telesales_Priority	from '@salesforce/label/c.AVX_Telesales_Priority';
import AVX_Telesales_Cancel	from '@salesforce/label/c.AVX_Telesales_Cancel';
import AVX_Telesales_Save	from '@salesforce/label/c.AVX_Telesales_Save';
import AVX_Telesales_Day	from '@salesforce/label/c.AVX_Telesales_Day';
import AVX_Telesales_Hour	from '@salesforce/label/c.AVX_Telesales_Hour';
import AVX_Telesales_Delete	from '@salesforce/label/c.AVX_Telesales_Delete';
import AVX_Telesales_Add	from '@salesforce/label/c.AVX_Telesales_Add';
import AVX_Telesales_Close	from '@salesforce/label/c.AVX_Telesales_Close';
import AVX_Telesales_Name	from '@salesforce/label/c.AVX_Telesales_Name';
import AVX_Telesales_Validation_error from '@salesforce/label/c.AVX_Telesales_Validation_error';
import AVX_Telesales_Records_added from '@salesforce/label/c.AVX_Telesales_Records_added';
import AVX_Telesales_Record_updated from '@salesforce/label/c.AVX_Telesales_Record_updated'; 
import AVX_Telesales_Records_deleted from '@salesforce/label/c.AVX_Telesales_Records_deleted';
import AVX_Telesales_Yes from '@salesforce/label/c.AVX_Telesales_Yes';
import AVX_Telesales_No from '@salesforce/label/c.AVX_Telesales_No';
import AVX_Telesales_Error_same_client_day_hour from '@salesforce/label/c.AVX_Telesales_Error_same_client_day_hour';
import AVX_telesales_Telemarketer from '@salesforce/label/c.AVX_telesales_Telemarketer';
import AVX_Telesales_Clients_no_selected from '@salesforce/label/c.AVX_Telesales_Clients_no_selected';
import AVX_Telesales_Telemerketer_no_selected from '@salesforce/label/c.AVX_Telesales_Telemerketer_no_selected';
import AVX_Telesales_telemarketer_witout_workplan from '@salesforce/label/c.AVX_Telesales_telemarketer_witout_workplan';
import AVX_Telesales_Select from '@salesforce/label/c.AVX_Telesales_Select';
import AVX_Telesales_Restart_values from '@salesforce/label/c.AVX_Telesales_Restart_values';


export default class Avx_telesalesplan_modal_add_edit extends LightningElement {
    
    label={
        AVX_Telesales_Add_Edit_Client_to_Telesales_Plan,
        AVX_Telesales_Priority,
        AVX_Telesales_Cancel,
        AVX_Telesales_Save,
        AVX_Telesales_Day,
        AVX_Telesales_Hour,
        AVX_Telesales_Delete,
        AVX_Telesales_Add,
        AVX_Telesales_Close,
        AVX_Telesales_Name,
        AVX_Telesales_Validation_error,
        AVX_Telesales_Records_added,
        AVX_Telesales_Records_deleted,
        AVX_Telesales_Yes,
        AVX_Telesales_No,
        AVX_Telesales_Error_same_client_day_hour,
        AVX_telesales_Telemarketer,
        AVX_Telesales_Clients_no_selected,
        AVX_Telesales_Hour,
        AVX_Telesales_Day,
        AVX_Telesales_Telemerketer_no_selected,
        AVX_Telesales_Record_updated,
        AVX_Telesales_telemarketer_witout_workplan,
        AVX_Telesales_Select,
        AVX_Telesales_Restart_values
    }

    //listener atributes
    @wire(CurrentPageReference) pageRef;
    @api objectApiName;
    @api recordId;
    @track currenObjectName;
    @track currenRecordId;

    
    @track showSpinner=false;
    @track isSpanish = false;
    //load initial data
    @track idShipToSelected = '';
    @track lstTelesalesPlanDetails = [];
    @track lstTelesalesPlanDetailsEdit = [];
    @track shipToFull = {};

    //reload data detail
    @track orderByDetailSelected = 'NAMEASC';
    @track daySelected = 'GENERAL';

    //show form edit/new
    @track showDetails = false;
    @track showFormNew =  false;
    @track openmodel = false;
    @track openModalConfirmation = false;
    
    //modal contingency
    @track openContingencyModal = false;
    @track openModalEditDetailContingency = false;

    //modal content
    @track accountNameTitle='';
    @track hourPlanDetail='';
    @track planDaySelected = '';
    @track planPrioritySelected = '';
    @track preDetailToInsert=null;
    @track currentTargetIdToDelete = '';
    @track currectObjectToDelete = [];

    //combo lists
    @track lstDays = [];
    @track lstPriorities = [];

    //new plan detail
    @track newHourPlanDetail = '';
    @track newPlanDaySelected = '';
    @track newPlanPrioritySelected = '';

    //list with ids to delete
    @track lstIdsToDelete = [];
    @track lstContingencyClients = [];
    @track lstPlanDetails = [];
    @track fullListPlanDetils = [];
    @track lstTelemarketers = [];
    @track currentObjectInEdition=null;

    @track telemarketerToSearch = '';
    @track idTelemarketerSelected = '';
    @track idTelesalesPlanDetailToUpdate = '';
    @track warningTelemarketer = null;
    @track lstTelesalesPlanToExclud = [];

     //listener start
     connectedCallback() { 
        // subscribe to inputChangeEvent event
        registerListener('handleFullListPlanDetails', this.handleFullListPlanDetails, this);
        registerListener('handleClientSelected', this.handleFiredClientSelected, this);
        registerListener('handleEditPlansDetails',this.handleFiredEditPlansDetails, this);
        registerListener('handleIsSpanish',this.handleIsSpanish, this);
        //contingency
        registerListener('handleOpenModalContingency', this.handleOpenModalContingency, this);
        registerListener('handleEditDetailContingency', this.handleEditDetailContingency, this);
        this.currenRecordId = this.recordId;
        this.currenObjectName = this.objectApiName;
    }

    disconnectedCallback() {
        // unsubscribe from inputChangeEvent event
        unregisterAllListeners(this);
    }
    //listener end
    
    openmodal() {
        this.openmodel = true
    }

    closeContingencyModal(){
        this.openContingencyModal =  false;
        this.openModalEditDetailContingency = false;
        this.idTelemarketerSelected = '';
        this.telemarketerToSearch = '';
    }

    closeModal() {
        this.idShipToSelected = '';
        this.openmodel = false;
        this.openModalConfirmation = false;
    } 

    replaceZInHour(hour){
        return (hour).replace('Z','').replace('z','');
    }

    convertDateAndReplaceZInHour(miliseconds){
        return this.replaceZInHour(new Date(miliseconds).toISOString().toString().replace('1970-01-01T','')); 
    }

    validateClientDayAndHour(objParam,list) {
        console.log('objToCompare-->',objParam );
        console.log('pivotList-->', list);
        let showError = false;
        let objToValidate = JSON.parse(JSON.stringify(objParam));
        let numRepetitions = 0;
        for(let key in list) {
            if (list.hasOwnProperty(key)) { 
                let obj = JSON.parse(JSON.stringify(list[key]));
                obj.Hours__c = this.replaceZInHour(obj.Hours__c);
                console.log('itemForToCompare-->', obj);
                let checkHour       = '';
                let checkShipTo     = '';
                let checkDay        = '';
                let currentHour     = '';
                let currentShipTo   = '';
                let currentDay      = '';
                if(objToValidate.telesalesPlanDetail){
                    console.log('Enter to objToValidate.telesalesPlanDetail');
                    currentHour     = this.convertDateAndReplaceZInHour(obj.telesalesPlanDetail.Hours__c);
                    currentShipTo   = obj.telesalesPlanDetail.Ship_To__r.Id;
                    currentDay      = obj.telesalesPlanDetail.DayOfTheWeek__c;
                    checkHour       = this.replaceZInHour(objToValidate.Hours__c);
                    checkShipTo     = objToValidate.telesalesPlanDetail.Ship_To__r.Id;
                    checkDay        = objToValidate.DayOfTheWeek__c;
                } else {
                    currentHour     = this.replaceZInHour(obj.Hours__c);
                    currentShipTo   = obj.Ship_To__c;
                    currentDay      = obj.DayOfTheWeek__c;
                    checkHour       = this.replaceZInHour(objToValidate.Hours__c);
                    checkShipTo     = objToValidate.Ship_To__c;
                    checkDay        = objToValidate.DayOfTheWeek__c;
                }
                if(checkShipTo === currentShipTo && checkDay===currentDay && checkHour=== currentHour){
                    numRepetitions = numRepetitions+2;
                }
            }
        }
        if(numRepetitions>1){
            showError = true;
            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error', 
                                    message: this.label.AVX_Telesales_Error_same_client_day_hour, 
                                    variant: 'error'
                                }),
                            );
            }
        console.log('numRepetitions-->', numRepetitions);
        return showError;
    }

    isValidTelemarketerSelected(){
        let isValid = false;
        if(this.idTelemarketerSelected===''){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error', 
                    message: this.label.AVX_Telesales_Telemerketer_no_selected, 
                    variant: 'error'
                }),
            );
        } else {
            isValid = true;
        }
        return isValid;
    }

    saveDetailsContingency(){
        console.log('idTelemarketerSelected',this.idTelemarketerSelected);
        if(this.isValidTelemarketerSelected()) { //save details contingency
            let lstAux = [];
            for(let key in this.lstContingencyClients) {
                if (this.lstContingencyClients.hasOwnProperty(key)) { 
                    let obj = JSON.parse(JSON.stringify(this.lstContingencyClients[key]));
                    console.log('contingency obj[checked]-->', obj);
                    let newObj = {
                        DayOfTheWeek__c:        obj.telesalesPlanDetail.DayOfTheWeek__c,
                        Hours__c:               obj.telesalesPlanDetail.Hours__c,
                        Priority__c :           obj.telesalesPlanDetail.Priority__c,
                        Ship_To__c:             obj.telesalesPlanDetail.Ship_To__c,
                        TelesalesPlan__c:       this.currenRecordId ,
                        CommercialAccount__c:   obj.telesalesPlanDetail.Ship_To__r.Commercial_Account__c,
                        Telemarketer__c:        this.idTelemarketerSelected,
                        Id:                     'NEW-' + Math.random()
                    };
                    lstAux.push(newObj);
                }
            }
            if(lstAux.length>0){
                this.saveOrUpdateTelesalesPlanDetails(lstAux);
            }
            this.closeContingencyModal();
        }

    }

    saveMethod() {
        //add new telesalesplandetails
        let showError = false;
        if(this.showFormNew){
            if(this.preDetailToInsert!==null) {//the user enter detail info
                let objToValidate = JSON.parse(JSON.stringify(this.preDetailToInsert));
                if(objToValidate.DayOfTheWeek__c==='' || objToValidate.Hours__c==='' || objToValidate.Priority__c ===''){
                    showError = true;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error', 
                            message: this.label.AVX_Telesales_Validation_error, 
                            variant: 'error'
                        }),
                    );
                } else {//there are not data in detail form
                    showError = false;
                    if(this.lstTelesalesPlanDetails.length>0){
                        console.log('objBefore-->', objToValidate);
                        showError = this.validateClientDayAndHour(objToValidate,this.lstTelesalesPlanDetails);
                    }
                    if(!showError){
                        console.log('objToSave-->', objToValidate);
                        this.lstTelesalesPlanDetails.push(objToValidate);
                    }
                }
            }
            console.log('validate list before save');
            if(!showError){
                for(let key in this.lstTelesalesPlanDetails){
                    if(this.lstTelesalesPlanDetails.hasOwnProperty(key)){
                        let currentObj = JSON.parse(JSON.stringify(this.lstTelesalesPlanDetails[key]));
                        showError = this.countDetailsInList(currentObj,this.lstTelesalesPlanDetails,true);
                        console.log('showError-->',showError );
                        if(showError){
                           break;
                        }
                    }
                }
            }
            
        } else if(this.showDetails) {
            let lstDtos = this.buildLstDtosDetails(this.fullListPlanDetils);            
            if(lstDtos.length>0){
                let dto = this.createDtoFromDetail(this.lstTelesalesPlanDetailsEdit[0]);
                showError = this.countDetailsInList(dto,lstDtos, false );
                console.log('showError-->', showError);
            }
            if(!showError){
                this.lstTelesalesPlanDetails=[];
                console.log('saveOrUpdateTelesalesPlanDetails(329)-->', this.lstTelesalesPlanDetailsEdit);
                for(let key in this.lstTelesalesPlanDetailsEdit){
                    if(this.lstTelesalesPlanDetailsEdit.hasOwnProperty(key)){
                        let obj = JSON.parse(JSON.stringify(this.lstTelesalesPlanDetailsEdit[key]));
                        let idArray = (obj.Id).split('EDIT-');
                        obj.Id = idArray[0];
                        this.lstTelesalesPlanDetails.push(obj);
                    }
                }
            }
        }

        //execute action if not error
        if(!showError){
            console.log('343');
            this.saveOrUpdateTelesalesPlanDetails(this.lstTelesalesPlanDetails);
    
            //delete telesalesplandetails
            if(this.lstIdsToDelete.length>0){
                deleteListTelesalesPlanDetails({lstTelesalesPlanDetailsToDelete: this.lstIdsToDelete})
                .then(result => {
                    console.log(':::response-->' + result);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success', 
                            message: this.label.AVX_Telesales_Records_deleted, 
                            variant: 'success'
                        }),
                    );
                    this.showSpinner = false; 
                    fireEvent(this.pageRef, 'handleReloadTableDetails',true);
                    fireEvent(this.pageRef, 'handleReloadClient', true);
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error while deleting TelesalesPlanDetail', 
                            message: error.message, 
                            variant: 'error'
                        }),
                    );
                    this.showSpinner = false;
                });
    
            }
            this.closeModal();
        }
        
    }


    createDtoFromDetail(detail){
        console.log('DetailToTransform-->', detail);
        let day = '';
        let hour = '';
        if(detail.DayOfTheWeek__c){//day changed
            day = detail.DayOfTheWeek__c;
        } else {//no changed
            day = detail.telesalesPlanDetail.DayOfTheWeek__c;
        }
        if(detail.Hours__c){//hour changed
            hour =  this.replaceZInHour(detail.Hours__c);
        } else {//no changed
            hour =  this.replaceZInHour(detail.telesalesPlanDetail.Hours__c);
        }
        let newDto = {
            Ship_To__c: detail.telesalesPlanDetail.Ship_To__c,
            DayOfTheWeek__c: day,
            Hours__c : hour
        }
        return newDto;
    }

    saveOrUpdateTelesalesPlanDetails(lstToSaveOrUpdate) {
        console.log(':::lstToSaveOrUpdate(403)-->', lstToSaveOrUpdate);
        let lstAux = [];
        for(let key in lstToSaveOrUpdate){  
            if(lstToSaveOrUpdate.hasOwnProperty(key)){
                let obj = JSON.parse(JSON.stringify(lstToSaveOrUpdate[key]));
                let strId = obj.Id;
                if(strId.includes('NEW-')) {
                    obj.Id = null;
                }
                if(!obj.DayOfTheWeek__c){
                    obj.DayOfTheWeek__c = obj.telesalesPlanDetail.DayOfTheWeek__c;
                }
                if(!obj.Hours__c){
                    obj.Hours__c = obj.telesalesPlanDetail.Hours__c;
                }
                if(!obj.Priority__c){
                    obj.Priority__c = obj.telesalesPlanDetail.Priority__c;
                }
                lstAux.push(obj);
            }  
        }

        console.log('Final list to save/update-->(416)',lstAux );
        if(lstAux.length>0){
            saveOrUpdateTelesalesPlanDetails({lstToSaveOrUpdate: lstAux})
            .then(result => {
                console.log(':::response-->' + result);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success', 
                        message: this.label.AVX_Telesales_Records_added, 
                        variant: 'success'
                    }),
                );
                this.lstTelesalesPlanDetails = [];
                this.showSpinner = false;
                fireEvent(this.pageRef, 'handleReloadTableDetails',true);
                fireEvent(this.pageRef, 'handleReloadClient', true);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while saving TelesalesPlanDetail', 
                        message: error.message, 
                        variant: 'error'
                    }),
                );
                this.showSpinner = false;
            });
        }
    }
    
   

    handleTelemarketerToSearch(e) {
        this.telemarketerToSearch = e.target.value;
        let plansToExlud = this.lstTelesalesPlanToExclud.toString();
        console.log('RecordId-->', this.recordId);
        getTelemarketerByFilters({textFilter: this.telemarketerToSearch, plansToExlud:plansToExlud, idContingencyPlan:this.recordId  })
        .then(data => {
            this.lstTelemarketers = [];
            console.log(data);
            for(let key in data) {
                if (data.hasOwnProperty(key)) {
                    let obj = JSON.parse(JSON.stringify(data[key]));
                    this.lstTelemarketers.push(obj);
                }
            }
            if(this.lstTelemarketers.length==0){
                this.warningTelemarketer = this.label.AVX_Telesales_telemarketer_witout_workplan;
            }
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while loading TelesalesPlanDetail related to ShipTo', 
                    message: error.message, 
                    variant: 'error'
                }),
            );
            this.showSpinner = false;
        });
    }

    handleTelemarketerSelected(e) {
        this.idTelemarketerSelected  = e.currentTarget.dataset.key;
        for(let key in this.lstTelemarketers) {
            if (this.lstTelemarketers.hasOwnProperty(key)) {
                let obj = JSON.parse(JSON.stringify(this.lstTelemarketers[key]));
                console.log('supervisor selected-->', obj);
                if(this.idTelemarketerSelected === obj.Id){
                    this.telemarketerToSearch = obj.Name;
                }   
            }
        }
        this.lstTelemarketers = null;
    }

    handleCleanTelemarketer(e) {
        this.telemarketerToSearch = e.target.value;
        console.log('handleCleanTelemarketer-->',this.telemarketerToSearch );
        if(this.telemarketerToSearch===''){
            this.lstTelemarketers = null;
            this.idTelemarketerSelected = '';
            this.telemarketerToSearch = '';
            this.warningTelemarketer = null;
        }
    }

    handleEditDetailContingency(jsonObj){
        this.openModalEditDetailContingency = true;
        let obj = JSON.parse(jsonObj);
        console.log('objToEdit-->', obj);
        this.idTelesalesPlanDetailToUpdate = obj.telesalesPlanDetail.Id;
        this.telemarketerToSearch = obj.telesalesPlanDetail.Telemarketer__r.Name;
        this.idTelemarketerSelected = obj.telesalesPlanDetail.Telemarketer__c;
        this.lstContingencyClients=[];
        this.lstContingencyClients.push(obj);
    }

    handleOpenModalContingency(jsonList){
        console.log('contingencyJsonList 123-->', jsonList);
        console.log('length-->', jsonList.length);
        this.lstContingencyClients = JSON.parse(jsonList);
        this.warningTelemarketer = null;
        if(this.lstContingencyClients.length>0) { 
            this.openContingencyModal = true; 
            this.idTelemarketerSelected = '';
            this.telemarketerToSearch = '';
            let lstTelemarketersExcluded = [];
            for(let key in this.lstContingencyClients){
                if (this.lstContingencyClients.hasOwnProperty(key)) {
                    let obj = JSON.parse(JSON.stringify(this.lstContingencyClients[key]));
                    console.log('objExcluir-->', obj);
                    lstTelemarketersExcluded.push(obj.telesalesPlanDetail.TelesalesPlan__c);
                }
            }
            this.lstTelesalesPlanToExclud = lstTelemarketersExcluded;
            console.log('lstTelemarketersExcluded-->', lstTelemarketersExcluded);
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error', 
                    message: this.label.AVX_Telesales_Clients_no_selected, 
                    variant: 'error'
                }),
            );
        }
    }

    //Handle Fired evets 
    handleFullListPlanDetails(jsonList){
        this.fullListPlanDetils = JSON.parse(jsonList);
    }

    
    handleFiredEditPlansDetails(jsonDetailToEdit) {
        console.log('fired in modal-->', jsonDetailToEdit);
        let obj = JSON.parse(jsonDetailToEdit);
        obj.Id = obj.Id+'EDIT-' +Math.random() + Math.random();
        obj.telesalesPlanDetail.Hours__c =  new Date(obj.telesalesPlanDetail.Hours__c).toISOString().toString().replace('1970-01-01T',''); 
        this.lstTelesalesPlanDetailsEdit = [];
        this.lstTelesalesPlanDetailsEdit.push(obj);
        this.showFormNew = false;
        this.showDetails = true;
        this.openmodal();
    }

    handleFiredClientSelected(idClientSelected) {
        this.openModalConfirmation = false;
        this.idShipToSelected = idClientSelected;
        getPlanDetailsByShipToReload({idShipTo: this.idShipToSelected})
        .then(data => {
            this.initValuesModal();
                if(data.shipTo){
                    let objShipTo =  JSON.parse(JSON.stringify(data.shipTo));
                    this.accountNameTitle = objShipTo.Name;
                    this.shipToFull = objShipTo;
                    for(let key in data.lstTelesalesPlanDetails){
                        if (data.lstTelesalesPlanDetails.hasOwnProperty(key)) {
                            let obj = JSON.parse(JSON.stringify(data.lstTelesalesPlanDetails[key]));
                            obj.Hours__c = new Date(obj.Hours__c).toISOString().toString().replace('1970-01-01T',''); 
                            if(obj.Hours__c === 0 ){
                                obj.Hours__c = '00:00:00.000Z';
                            }
                            this.lstTelesalesPlanDetails.push(obj);
                        }
                    }
                }
            this.showFormNew = true;
            this.showDetails = false;
            this.openmodal();
            this.showSpinner = false; 
            console.log(this.lstTelesalesPlanDetails);
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while loading TelesalesPlanDetail related to ShipTo', 
                    message: error.message, 
                    variant: 'error'
                }),
            );
            this.showSpinner = false;
        });

    }

    handleIsSpanish(isSpanish){
        this.isSpanish = isSpanish;
    }

    buildLstDtosDetails(lstToTransform){
        console.log('Enter to buildLstDtosDetails-->', lstToTransform);
        let lstDtos = [];
        for(let key in lstToTransform){
            if (lstToTransform.hasOwnProperty(key)) { 
                let day = '';
                let hour = '';
                let shipTo = '';
                console.log('lstToTransform[key]-->', lstToTransform[key]);
                if(lstToTransform[key].telesalesPlanDetail){
                    let hourAux =new Date(lstToTransform[key].telesalesPlanDetail.Hours__c).toISOString().toString().replace('1970-01-01T',''); 
                    day     = lstToTransform[key].telesalesPlanDetail.DayOfTheWeek__c;
                    hour    = this.replaceZInHour(hourAux);
                    shipTo  = lstToTransform[key].telesalesPlanDetail.Ship_To__c;
                } else { 
                    day     = lstToTransform[key].DayOfTheWeek__c;
                    hour    = this.replaceZInHour(lstToTransform[key].Hours__c);
                    shipTo  = lstToTransform[key].Ship_To__c;
                }
                let newDto= {
                    DayOfTheWeek__c : day,
                    Hours__c        : hour,
                    Ship_To__c      : shipTo
                };
                lstDtos.push(newDto);
            }
        }
        return lstDtos;
    }


    updateLstTelesalesPlanDetailsEdit(index,field, value){       
        let lstAux = [];
        let lstDtos =  this.buildLstDtosDetails(this.fullListPlanDetils);
        for(let key in this.lstTelesalesPlanDetailsEdit){
            if (this.lstTelesalesPlanDetailsEdit.hasOwnProperty(key)) { 
                let obj = JSON.parse(JSON.stringify(this.lstTelesalesPlanDetailsEdit[key]));
                console.log('obj-->', obj);
                if(key===index) {
                    if(field === 'DAY'){
                        console.log('DAY-->', value);
                        obj.DayOfTheWeek__c = value;
                    } else if (field ==='HOUR' ){
                        obj.Hours__c = value;
                    } else if (field === 'PRIORITY'){
                        obj.Priority__c = value;
                    }
                    let dtoToCompare = this.createDtoFromDetail(obj);
                    this.countDetailsInList(dtoToCompare, lstDtos,false);
                }
                lstAux.push(obj);
            } 
        }
        this.lstTelesalesPlanDetailsEdit = [];
        this.lstTelesalesPlanDetailsEdit = lstAux;
    }

   
    //edit handlers
    handleEditDay(e){ 
        let index= e.target.dataset.index;
        let field = 'DAY';
        let value = e.detail.value;
        this.updateLstTelesalesPlanDetailsEdit(index, field, value);
    } 

    handleEditHour(e){
        let index= e.target.dataset.index;
        let field = 'HOUR';
        let value = e.detail.value;
        this.updateLstTelesalesPlanDetailsEdit(index, field, value);
    }
    
    handleEditPriority(e){
        let index= e.target.dataset.index;
        let field = 'PRIORITY';
        let value = e.detail.value;
        this.updateLstTelesalesPlanDetailsEdit(index, field, value);
    }

    countDetailsInList(dto, lstDtos, clickBtnSave){
        console.log(':::dtoToCompare-->', dto);
        console.log(':::lstDtos-->', lstDtos);
        let exist = false;
        let counter = 0;
        dto.Hours__c = this.replaceZInHour(dto.Hours__c);
        for(let key in lstDtos){
            if (lstDtos.hasOwnProperty(key)) { 
                let currentObj = JSON.parse(JSON.stringify(lstDtos[key]));
                console.log('currentObject to validate-->',currentObj );
                currentObj.Hours__c =  this.replaceZInHour(currentObj.Hours__c);
                if(dto.Ship_To__c == currentObj.Ship_To__c &&  dto.DayOfTheWeek__c === currentObj.DayOfTheWeek__c && dto.Hours__c === currentObj.Hours__c){
                    counter = counter + 1;
                }
            }
        }
        if(clickBtnSave){
            if(counter>1) { 
                exist = true;
            }
        } else {
            if(counter>0) { 
                exist = true;
            }
        }
        if(exist){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error', 
                    message: this.label.AVX_Telesales_Error_same_client_day_hour, 
                    variant: 'error'
                }),
            );
        }
        console.log('counter', counter);
        console.log('exist-->', exist);
        return exist; 
    }

    updateLstTelesalesPlanDetails(index, field, value, isBtnSave){
        console.log('updateLstTelesalesPlanDetails');
        let lstAux = [];
        let lstDtos = this.buildLstDtosDetails(this.lstTelesalesPlanDetails);
        for(let key in this.lstTelesalesPlanDetails){
            if (this.lstTelesalesPlanDetails.hasOwnProperty(key)) { 
                let obj = JSON.parse(JSON.stringify(this.lstTelesalesPlanDetails[key]));                
                if(key===index) {
                    //before to update validate if exist the same data
                    if(field === 'DAY'){
                        obj.DayOfTheWeek__c = value;
                    } else if (field ==='HOUR' ){ 
                        obj.Hours__c = value;
                    } else if (field === 'PRIORITY'){ 
                        obj.Priority__c = value;
                    }
                    this.countDetailsInList(obj, lstDtos,isBtnSave);
                }
                lstAux.push(obj);
            } 
        }
        this.lstTelesalesPlanDetails = [];
        this.lstTelesalesPlanDetails = lstAux;

    }

    
    //edit handlers client list
    handleEditDayClientList(e){ 
        let index= e.target.dataset.index;
        let field = 'DAY';
        let value = e.detail.value;
        this.updateLstTelesalesPlanDetails(index, field, value,false);
    } 

    handleEditHourClientList(e){
        let index= e.target.dataset.index;
        let field = 'HOUR';
        let value = e.detail.value;
        this.updateLstTelesalesPlanDetails(index, field, value,false);
    }
    
    handleEditPriorityClientList(e){
        let index= e.target.dataset.index;
        let field = 'PRIORITY';
        let value = e.detail.value;
        this.updateLstTelesalesPlanDetails(index, field, value,true);
    }


    //combos data
    @wire(getPickistValuesByField, { fieldName: 'DAYS'})
    wiredPickListValuesDays({ error, data }) {
        if (data) {
            this.lstDays = [];
            for(let key in data){
                if (data.hasOwnProperty(key)) { 
                    if(data[key].label==='Lunes'){
                        this.isSpanish = true;
                    }
                    let obj = { 
                        label: data[key].label, 
                        value: data[key].value
                    };
                    this.lstDays.push(obj);
                }
            }
        } else if (error) {
            this.lstDays = [];
        }
    }

    
    @wire(getPickistValuesByField, { fieldName: 'PRIORITY'})
    wiredPickListValuesPriority({ error, data }) {
        if (data) {
            this.lstPriorities = [];
            for(let key in data){
                if (data.hasOwnProperty(key)) { 
                    let obj = {
                        label: data[key].label, 
                        value: data[key].value
                    };
                    this.lstPriorities.push(obj);
                } 
            }
        } else if (error) {
            this.lstPriorities = [];
        }
    }



    
    //handle inputs/combos
    handleNewHourPlanDetail(e) {
        this.newHourPlanDetail = e.target.value;
        this.preBuilddDetail();
    }
    
    handleNewPlanDaySelected(e){
        this.newPlanDaySelected = e.detail.value;
        this.preBuilddDetail();
    }

    
    handleNewPlanPrioritySelected(e){
        this.newPlanPrioritySelected = e.detail.value;
        this.preBuilddDetail();
    }

    preBuilddDetail(){
        this.preDetailToInsert = this.getNewObjToAdd();
    }


    //load data
    
    initValuesModal() {
        this.lstIdsToDelete = [];
        this.lstTelesalesPlanDetails = [];
        this.resetNewPlanDetail();
    }

    resetNewPlanDetail(){
        this.newHourPlanDetail = '';
        this.newPlanDaySelected = '';
        this.newPlanPrioritySelected = '';
        this.preDetailToInsert = null;
    }


    //loading plan details 
    @wire(getPlanDetailsByShipTo, { idShipTo: '$idShipToSelected'})
    wiredPlanDetails({ error, data }) {
        if(data !==undefined){
            if (data) {
                this.initValuesModal();
                if(data.shipTo) {
                    let objShipTo =  JSON.parse(JSON.stringify(data.shipTo));
                    this.accountNameTitle = objShipTo.Name;
                    this.shipToFull = objShipTo;
                    for(let key in data.lstTelesalesPlanDetails){
                        if (data.lstTelesalesPlanDetails.hasOwnProperty(key)) {
                            let obj = JSON.parse(JSON.stringify(data.lstTelesalesPlanDetails[key]));
                            obj.Hours__c = new Date(obj.Hours__c).toISOString().toString().replace('1970-01-01T',''); 
                            this.lstTelesalesPlanDetails.push(obj);
                        }
                    }
                }
            } else if (error) {
                this.lstTelesalesPlanDetails = [];
            }
        }
    }

    handleRemoveItemOfList(e) {
        if(this.showFormNew){
            let targetArray = (e.currentTarget.id).split('-');
            let index = targetArray[0];
            let lstAux = [];
            for(let key in this.lstTelesalesPlanDetails){
                if (this.lstTelesalesPlanDetails.hasOwnProperty(key)) {
                    let obj = JSON.parse(JSON.stringify(this.lstTelesalesPlanDetails[key]));
                    if(key === index){
                        let idAux = obj.Id;
                        if(obj.Id && !idAux.includes('NEW-')){
                            this.lstIdsToDelete.push(this.lstTelesalesPlanDetails[key].Id);
                        }                    
                    } else { 
                        lstAux.push(obj);
                    }
                }
            }
            this.lstTelesalesPlanDetails = [];
            this.lstTelesalesPlanDetails = lstAux;
        } else if(this.showDetails){
            this.currentTargetIdToDelete = e.currentTarget.id;
            this.openModalConfirmation = true;
            this.currectObjectToDelete = this.lstTelesalesPlanDetailsEdit;
            this.lstTelesalesPlanDetailsEdit = [];
            
        }
    }

    handleYes(){
        let targetArray = (this.currentTargetIdToDelete).split('-');
        let index = targetArray[0];

        let lstAux = [];
        for(let key in this.currectObjectToDelete){
                if (this.currectObjectToDelete.hasOwnProperty(key)) {
                    let obj = JSON.parse(JSON.stringify(this.currectObjectToDelete[key]));
                    if(key === index){
                        if(obj.Id){
                            let idArray = (obj.Id).split('EDIT-');
                            let idAux= idArray[0];
                            this.lstIdsToDelete.push(idAux);
                        }                    
                    } else {
                        lstAux.push(obj);
                    }
                }
        }
        this.currectObjectToDelete = [];
        this.currectObjectToDelete = lstAux;
        //delete telesalesplandetails
        if(this.lstIdsToDelete.length>0){
            deleteListTelesalesPlanDetails({lstTelesalesPlanDetailsToDelete: this.lstIdsToDelete})
            .then(result => {
                console.log(':::response-->' + result);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success', 
                        message: this.label.AVX_Telesales_Records_deleted, 
                        variant: 'success'
                    }),
                );
                this.showSpinner = false; 
                fireEvent(this.pageRef, 'handleReloadTableDetails',true);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while deleting TelesalesPlanDetail', 
                        message: error.message, 
                        variant: 'error'
                    }),
                );
                this.showSpinner = false;
            });

        }
        this.openModalConfirmation = false;
        this.closeModal();
    }

    handleNo(){
        this.openModalConfirmation = false;
        this.lstTelesalesPlanDetailsEdit = this.currectObjectToDelete;
    }
    

    //create record in telesalesplandetail
    handleAddClientToPlanDetail() { 
        if(this.newPlanDaySelected ==='' || this.newHourPlanDetail ==='' || this.newPlanPrioritySelected===''){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error', 
                    message: this.label.AVX_Telesales_Validation_error, 
                    variant: 'error'
                }),
            );
        } else {
            let newObj = this.getNewObjToAdd();
            if(!this.countDetailsInList(newObj, this.lstTelesalesPlanDetails, false)){
                this.lstTelesalesPlanDetails.push(newObj);
                this.resetNewPlanDetail();
            }
        }
    }

    getNewObjToAdd(){
        let shipTo = JSON.parse(JSON.stringify(this.shipToFull));
        let newObj = {
            DayOfTheWeek__c:        this.newPlanDaySelected,
            Hours__c:               this.newHourPlanDetail,
            Priority__c :           this.newPlanPrioritySelected,
            Ship_To__c:             this.idShipToSelected,
            TelesalesPlan__c:       this.currenRecordId ,
            CommercialAccount__c:   shipTo.Commercial_Account__c,
            Id:                     'NEW-' + Math.random()
        };
        return newObj
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

    updateDetailContingency(){
        if(this.isValidTelemarketerSelected()) {
            // Create the recordInput object
            const fields = {};
            fields[TELESALESPLANDETAIL_ID.fieldApiName] = this.idTelesalesPlanDetailToUpdate;
            fields[TPD_TELEMARKETER_ID.fieldApiName] = this.idTelemarketerSelected;
            const recordInput = { fields };
            updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: this.label.AVX_Telesales_Record_updated,
                        variant: 'success'
                    })
                );
                fireEvent(this.pageRef, 'handleReloadTableDetails',true);
                this.closeContingencyModal();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        }
    }

}