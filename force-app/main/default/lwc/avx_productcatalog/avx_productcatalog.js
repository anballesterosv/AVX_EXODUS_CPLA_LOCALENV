/* eslint-disable guard-for-in */
/* eslint-disable no-console */
import { LightningElement, wire, track, api } from 'lwc';

import getPriceBookList from '@salesforce/apex/AVX_ProductCatalog_ctr.getPriceBookList';
import AVX_Previous from '@salesforce/label/c.AVX_Previous';
import AVX_FirstPage from '@salesforce/label/c.AVX_FirstPage';
import AVX_LastPage from '@salesforce/label/c.AVX_LastPage';
import AVX_Next from '@salesforce/label/c.AVX_Next';
import AVX_PageSize from '@salesforce/label/c.AVX_PageSize';
import AVX_ProductName from '@salesforce/label/c.AVX_ProductName';
import AVX_ProductCode from '@salesforce/label/c.AVX_ProductCode';
import AVX_Brand from '@salesforce/label/c.AVX_Brand';
import AVX_Family from '@salesforce/label/c.AVX_Family';
import AVX_DefaultPricingUOM from '@salesforce/label/c.AVX_DefaultPricingUOM';
import AVX_DefaultUom from '@salesforce/label/c.AVX_DefaultUom';
import AVX_SalesOrg from '@salesforce/label/c.AVX_SalesOrg';
import AVX_ShowImageOrNot from '@salesforce/label/c.AVX_ShowImageOrNot'; 
import AVX_Search from '@salesforce/label/c.AVX_Search';
import AVX_EnterSearch from '@salesforce/label/c.AVX_EnterSearch';
import AVX_ShowImage from '@salesforce/label/c.AVX_ShowImage';
import AVX_DontShowImage from '@salesforce/label/c.AVX_DontShowImage';
import AVX_NoRecordsFound from '@salesforce/label/c.AVX_NoRecordsFound';



export default class avx_productcatalog extends LightningElement {

    //labels list
    label = {
        AVX_Previous,
        AVX_FirstPage,
        AVX_LastPage,
        AVX_Next,
        AVX_PageSize,
        AVX_ProductName,
        AVX_ProductCode,
        AVX_Brand,
        AVX_Family,
        AVX_DefaultPricingUOM,
        AVX_DefaultUom,
        AVX_SalesOrg,
        AVX_ShowImageOrNot,
        AVX_Search,
        AVX_EnterSearch,
        AVX_ShowImage,
        AVX_DontShowImage,
        AVX_NoRecordsFound
    };

    //conection ParentChild
    @api openProductDetailModal = false;
    @api showdefaultimage = false;
    @api showdefaulttext = false;
    @api productTargeting;
    @api taxedYesOrNo;

    //control
    @track priceBookListResponse = [];
    @track loading = true;
    @track showimage = false;

    //html Inputs
    @track showvalue = 'Dont';    
    @track showqty = '8';

    //tracks
    @track orderByTrack = 'product2.name|ASC';
    @track totalRecords = '0';
    @track priceBookNameTrack = 'Product Catalog TestModal';
    @track showErrorMsg = false;
    @track msgnoData = true;
    @track msgnoDataSize = '8';
    @track disableNextButton = true;
    @track detailObject;
    @track page_size;
    @track off_Set;
    @track totalPages;
    @track pageShow;
    @track searchValueTrack;
    @track ErrorMsg;
    @track detailFilter;
    @track disabledPrevious =false;
    @track disabledFirstPage =false;
    @track disabledLastPage =false;
    @track disabledNext =false;


    //wire
    @track offSetWire = 0;
    @track pageSizeWire = 8;
    @track orderByTypeWire = 'product2.name';
    @track orderByDirWire = 'ASC';
    @track searchValueWire = '';
    @track filterValueWire = '';


    @wire(getPriceBookList, { 
            priceBookName: '$priceBookNameTrack', 
            offSetString: '$offSetWire', 
            pageSizeString: '$pageSizeWire', 
            orderByTypeString: '$orderByTypeWire', 
            orderByDirString: '$orderByDirWire', 
            searchValue: '$searchValueWire', 
            filterValue: '$filterValueWire'}) 
    productsPriceBook({ error, data }) {
        if (data) {
            console.log('data productsPriceBook-->', data);
            //window.console.log('data ==> '+JSON.stringify(data));
            this.msgnoData = true;
            
            this.disabledPrevious =false;
            this.disabledFirstPage =false;
            this.disabledLastPage =false;
            this.disabledNext =false;

            this.priceBookListResponse = data.priceBookList;
            this.searchValueTrack = data.paginationData.searchValueResponse;
            this.totalPages = data.paginationData.totalPagesResponse;
            this.page_size = data.paginationData.pageSizeResponse;
            this.off_Set = data.paginationData.offSetResponse;
            console.log('searchValueTrack', this.searchValueTrack);
            if(this.totalPages > 0){                
                this.pageShow = (this.off_Set +1)  + '/' + this.totalPages;
            }else{
                this.pageShow = '0';
            }
            if(this.pageShow === this.off_Set + 1){this.disableNextButton = true;}else{this.disableNextButton = false;}
            this.loading = false;
            this.error = undefined;
            if(this.priceBookListResponse.length > 0){
                this.msgnoData = false;
            }
            if(this.searchValueTrack !== '' && this.msgnoData){
                this.errorMsg = this.label.AVX_NoRecordsFound;
                this.showErrorMsg = true;
            }
            //Button Control
            if(this.off_Set === 0 ){
                this.disabledPrevious = true;
                this.disabledFirstPage = true;
            }
            if((this.off_Set+1) === this.totalPages || this.totalPages === 0){
                this.disabledLastPage  = true
                this.disabledNext  = true
            }

        }else if (error) {
            this.msgnoData = true;
            this.error = error;
            
            this.errorMsg = this.label.AVX_NoRecordsFound;
            this.showErrorMsg = true;
        }
    } 
    
    //Html Inputs
    @track optionsShowImage = [
        { label: this.label.AVX_ShowImage , value: 'Show'  },
        { label: this.label.AVX_DontShowImage, value: 'Dont' }
    ];
    @track page_size = [
        { label: '8', value: '8'  },
        { label: '16', value: '16' },
        { label: '24', value: '24' },
        { label: '32', value: '32' }
    ];           
    @track columnsData =  [
        {classString : 'slds-is-sortable columns_title  ', order : '1', display : 'true', stringTitle : this.label.AVX_ProductName, name : 'product2.name'}
        ,{classString : 'slds-is-sortable columns_title ', order : '2', display : 'true', stringTitle : this.label.AVX_ProductCode, name : 'Product2.ProductCode'}
        ,{classString : 'slds-is-sortable columns_title ', order : '3', display : 'true', stringTitle : this.label.AVX_Brand, name : 'Product2.Brand__c'}
        ,{classString : 'slds-is-sortable columns_title ', order : '4', display : 'true', stringTitle : this.label.AVX_Family, name : 'Product2.Family'}
        ,{classString : 'slds-is-sortable columns_title ', order : '5', display : 'true', stringTitle : this.label.AVX_SalesOrg, name : 'Product2.SalesArea__r.SalesOrg__c'}
        ,{classString : 'slds-is-sortable columns_title ', order : '6', display : 'true', stringTitle : this.label.AVX_DefaultPricingUOM, name : 'Product2.DEFAULT_PRICING_UOM__c'}
        ,{classString : 'slds-is-sortable columns_title ', order : '7', display : 'true', stringTitle : this.label.AVX_DefaultUom, name : 'Product2.Default_UOM__c'}
        ,{classString : 'slds-is-sortable  columns_title  columns_info', order : '8', display : 'true', stringTitle : 'Info', name : 'product2.name'}
        
    ];        
    
    constructor() {
        super();
        this.template.addEventListener('receiveFilter', this.sendfilter.bind(this));
        
    }
          
    //Events
    sortBy(e){ 
        var orderByType = e.currentTarget.id.split('-')[0];
        var orderByTrackSplit = this.orderByTrack.split('|');
        if(orderByType === orderByTrackSplit[0]){
            if(orderByTrackSplit[1] === 'ASC'){
                this.orderByTrack = orderByTrackSplit[0] + '|DESC';
            }else{
                this.orderByTrack = orderByTrackSplit[0] + '|ASC';
            }
        }else{
            this.orderByTrack = orderByType + '|ASC';
        }       
        this.orderByTypeWire = this.orderByTrack.split('|')[0];
        this.orderByDirWire = this.orderByTrack.split('|')[1];
        this.offSetWire = 0;
        this.loading = true;
    }           
    handleChangeQTYPag(e){
        if(e.currentTarget.value !== ''){
            this.page_size = e.currentTarget.value;
            this.pageSizeWire = this.page_size;
            this.offSetWire = 0;
            this.loading = true;
        }            
    }
    doPagination(e){
        let eventpagination = e.currentTarget.label;
        var offSetPagination = this.off_Set;
        if(!this.msgnoData){
            switch (eventpagination) {
                case this.label.AVX_Previous:
                    if(offSetPagination !== 0){
                        this.offSetWire = this.off_Set -1;
                        this.loading = true;
                    }
                    break;
                case this.label.AVX_FirstPage:
                    if(offSetPagination !== 0){
                        this.offSetWire = 0;
                        this.loading = true;
                    }
                    break;
                case this.label.AVX_LastPage:
                    if(offSetPagination !== (this.totalPages -1)){ 
                        this.offSetWire = this.totalPages -1 ;
                        this.loading = true;
                    }
                    break;
                case this.label.AVX_Next:
                    if(offSetPagination !== (this.totalPages -1)){                 
                        this.offSetWire = this.off_Set +1;
                        this.loading = true;
                    }
                    break;
                default:
                    break;
            }
        }        
    }               
    handleChangeImg(e){
        if(e.detail.value === 'Show' && !this.msgnoData){
            this.showimage = true;
            this.showvalue = 'Show';
        }else{ 
            this.showimage = false;
            this.showvalue = 'Dont';
        }
    }    
    openModal(e){        
        console.log('AAAAA');
        this.detailObject = JSON.parse(e.detail);
        this.openProductDetailModal = true;
        if(this.detailObject.urlLst === undefined){
            this.showDefaultImage = true;
        }else{
            this.showDefaultImage = false;
        }
        if(this.detailObject.taxed){
            this.taxedYesOrNo = true;
        }else{
            this.taxedYesOrNo = false;
        }
    }
    sendfilter(event){
        this.filterValueWire = '';
        console.log('receiveFilter IN', event.detail);
        //this.filterValueWire = JSON.parse(event.detail);
        let returnDetail = event.detail;
        if(returnDetail !== '[]'){
            this.filterValueWire = event.detail;
        }
        this.offSetWire = 0;
        //this.loading = true;
        console.log('receiveFilter OUT', this.filterValueWire);
    }
    closeModal(){
        this.openProductDetailModal = false;
    }
    handleSearchText(e){
        this.searchValueTrack = e.detail.value;
        this.showErrorMsg = false;
        if(e.detail.value === ''){this.handleSearch()}
    }
    handleKeyPress(event) {
        if(event.keyCode===13){
            console.log('Enter');
            this.handleSearch();
        }
    }  
    handleSearch(){
        let searchvalue = this.searchValueTrack;
        if(this.searchValueTrack === '' || !this.searchValueTrack) {
            //this.searchValueTrack = undefined;
            this.searchValueWire = '';
            this.showimage = false;
            this.showvalue = 'Dont';
            
        }else if(this.searchValueTrack !== this.searchValueWire){
            this.searchValueWire = searchvalue;
            this.offSetWire = 0;
            this.loading = true;
        }
    }
}