public with sharing class Protein_SampleRequestFulfillmentCtlr{

    private final static String SUCCESS='Success';
    private final static String FAILED='Failure';
    //private final static String ERROR_MSG='Unknown Error';
    
    @AuraEnabled
    public static List<ProductSelectUnselectWrapper> getSampleRequestProducts(Id sampleId) {
        List<ProductSelectUnselectWrapper> lstProductWrapper = new List<ProductSelectUnselectWrapper>();
        List<SampleRequestProduct__c> lstProducts = new List<SampleRequestProduct__c>();
        if(SampleRequestProduct__c.sObjectType.getDescribe().isAccessible()){
        lstProducts = [SELECT Id, Name, Product__c, Product_Description__c, Product_Cost__c, 
                                                     Quantity__c, SampleRequest__c, Sample_Request_Fulfillment__c, Sequence_Number__c, 
                                                     CFNA_Type__c, Shipped_Weight__c,  CFNA_Other_Type__c,  
                                                     Julian_Date__c, Fulfillment_Status__c,Fulfilled__c, Fulfillment_Plant__c,Distributor_Code__c, 
                                                     Product_Code__c, CFNA_Business_Unit__c, Sample_Request_Name__c, Product__r.Name, recordType.DeveloperName, 
                                                     SampleRequest__r.recordType.DeveloperName FROM SampleRequestProduct__c 
                                                     WHERE SampleRequest__c=:sampleId ORDER BY Name DESC];
        }
        for(SampleRequestProduct__c p : lstProducts) {
            ProductSelectUnselectWrapper prodWrapper = new ProductSelectUnselectWrapper();  //SRProductWrapper 
            prodWrapper.srProduct = p;
            lstProductWrapper.add(prodWrapper);
        }
        return lstProductWrapper;
    }  
    
    @AuraEnabled
    //Get the picklist values of Fulfillment_Status__c field from SampleRequestProduct__c (SRP) object
    public static List<String> getSRP_BUs(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = SampleRequestProduct__c.Fulfillment_Status__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        //System.debug('getSRP_BUs:' +options);
        return options;
    }      
    
    
    
    Public class ProductSelectUnselectWrapper{
        @AuraEnabled
        public SampleRequestProduct__c srProduct;
        @Auraenabled
        public string prdId,prdName,prdProductDesc,prdProductDescription,prdSampleRequest,
            prdSequence,prdType,prdPlant,prdOtherType,prdOriginalOrgId,
            prdJulianProductionDate,prdFulfillmentStatus,prdFulfillmentPlant,prdDistributorProductCode,prdCargillProductCode,
            prdBusinessUnit,prdSampleRequestName,prdProductName,prdRecordType,prdSampleRqstRecType,StatusSRF,ProductCount;
        @Auraenabled
        public Boolean prdSampleRequestFulfillment,prdFulfilled;
        @AuraEnabled public boolean isChecked; //{get;set;}
        @Auraenabled
        public Decimal prdProductCost,prdQuantity,prdShippedWeight;
        @Auraenabled
        public Date prdPackDate;
    }
    
    @Auraenabled
    public static Response getProductWrapperList(string sampleRequestId){
        system.debug('*****sampleRequestId=='+sampleRequestId);
        //Boolean hasError=false;
        //String StatusSRF;
        //Set<Id> myMainParentId = new Set<Id>();
        List<ProductSelectUnselectWrapper> wrapList = new List<ProductSelectUnselectWrapper>();
        List<SampleRequestProduct__c> prdList = new List<SampleRequestProduct__c>();
        if(sampleRequestId!=null)
        {
            Sample_Request_Fulfillment__c srp = new Sample_Request_Fulfillment__c();
            if(Sample_Request_Fulfillment__c.sObjectType.getDescribe().isAccessible()){
               srp = [select id,Name,Status__c,Sample_Request__c from Sample_Request_Fulfillment__c where id=:sampleRequestId limit 1];
            }//system.debug('*****srp =='+srp );            
            prdList = [SELECT Id, Name, Product__c,  Product_Description__c, Product_Cost__c, 
                       Quantity__c, SampleRequest__c, Sample_Request_Fulfillment__c, Sequence_Number__c, 
                       CFNA_Type__c, Shipped_Weight__c,   CFNA_Other_Type__c, 
                       Julian_Date__c, Fulfillment_Status__c, Fulfillment_Plant__c,Fulfilled__c, Distributor_Code__c, 
                       Product_Code__c, CFNA_Business_Unit__c, Sample_Request_Name__c, Product__r.Name, recordType.DeveloperName, 
                       SampleRequest__r.recordType.DeveloperName FROM SampleRequestProduct__c where SampleRequest__c =:srp.Sample_Request__c AND Sample_Request_Fulfillment__c = null];
            
            //system.debug('****prdList ==='+prdList);
          
           for(SampleRequestProduct__c prd : prdList )
            {   
                ProductSelectUnselectWrapper wrap = new ProductSelectUnselectWrapper();
                wrap.prdName =prd.Name;
                wrap.prdId = prd.id;                
                wrap.prdProductDescription= prd.Product_Description__c;
                wrap.prdProductCost= prd.Product_Cost__c;
                wrap.prdQuantity= prd.Quantity__c;
                wrap.prdSampleRequest= prd.SampleRequest__c;
                wrap.prdSequence= prd.Sequence_Number__c;
                wrap.prdType= prd.CFNA_Type__c;
                wrap.prdShippedWeight= prd.Shipped_Weight__c;
                wrap.prdOtherType= prd.CFNA_Other_Type__c;
                wrap.prdJulianProductionDate= prd.Julian_Date__c;
                wrap.prdFulfillmentStatus= prd.Fulfillment_Status__c;
                wrap.prdFulfillmentPlant= prd.Fulfillment_Plant__c;
                wrap.prdDistributorProductCode= prd.Distributor_Code__c;
                wrap.prdCargillProductCode= prd.Product_Code__c;
                wrap.prdBusinessUnit= prd.CFNA_Business_Unit__c;
                wrap.prdProductName=prd.Product__r.Name; 
                
                wrap.isChecked = false;
                wrapList.add(wrap);
            }
        }
        return new Response(true,'Success',wrapList);
    } 

    
    // Method to push selected products to processed table
    @AuraEnabled
    public static Response getSelectedProductList(List<string> sampleRequestProd, string sampleReqFulFillId){
        
        //ProductSelectUnselectWrapper sampleRequestProdWrap =(ProductSelectUnselectWrapper)JSON.deserialize(sampleRequestProd,ProductSelectUnselectWrapper.class);
        system.debug('####sampleRequestProd ==='+sampleRequestProd);
        List<SampleRequestProduct__c> sampleRequestProdList = new List<SampleRequestProduct__c>();
        List<SampleRequestProduct__c> updateSampleRequestProdList = new List<SampleRequestProduct__c>();
        
        sampleRequestProdList = [select id,name,Sample_Request_Fulfillment__c,SampleRequest__c from SampleRequestProduct__c where id IN: sampleRequestProd];
        //system.debug('%%%%%sampleRequestProdList =='+sampleRequestProdList);
        //List<Sample_Request_Fulfillment__c> sampleReqFulfillmentList = new List<Sample_Request_Fulfillment__c>();
        List<ProductSelectUnselectWrapper> wrapList = new List<ProductSelectUnselectWrapper>();    
        
        for(SampleRequestProduct__c srp : sampleRequestProdList)
        {
            srp.Sample_Request_Fulfillment__c = sampleReqFulFillId;
            updateSampleRequestProdList.add(srp);
            //system.debug('%%%%%updateSampleRequestProdList=='+updateSampleRequestProdList);
        }
        if(!updateSampleRequestProdList.isEmpty())           
        {
            try{
                if(SampleRequestProduct__c.sObjectType.getDescribe().isUpdateable()){
                    update updateSampleRequestProdList;
                    system.debug('%%%updateSampleRequestProdList=='+updateSampleRequestProdList); 
                }
            }catch(exception e){
                system.debug('%%%exception=='+e);
            }
            
        }
        
        //system.debug('%%%%%%sampleReqFulFillId=='+sampleReqFulFillId);
        Sample_Request_Fulfillment__c srpf = new Sample_Request_Fulfillment__c();
        srpf= [select id,Name,Sample_Request__c,Status__c from Sample_Request_Fulfillment__c where id=:sampleReqFulFillId];
        List<SampleRequestProduct__c> prdASList = new List<SampleRequestProduct__c>();
        //system.debug('%%%%%%srpf=='+srpf);
        prdASList= [SELECT Id, Name, Product__c,  Product_Description__c, Product_Cost__c, 
                    Quantity__c, SampleRequest__c, Sample_Request_Fulfillment__c, Sequence_Number__c, 
                    CFNA_Type__c, Shipped_Weight__c,  CFNA_Other_Type__c, 
                    Julian_Date__c, Fulfillment_Status__c, Fulfillment_Plant__c, Distributor_Code__c, 
                    Product_Code__c, CFNA_Business_Unit__c,Fulfilled__c , Sample_Request_Name__c, Product__r.Name, recordType.DeveloperName, 
                    SampleRequest__r.recordType.DeveloperName FROM SampleRequestProduct__c where SampleRequest__c =:srpf.Sample_Request__c and Sample_Request_Fulfillment__c=:sampleReqFulFillId and Sample_Request_Fulfillment__c !=null];
        //system.debug('%%%%%%prdASList=='+prdASList);
        for(SampleRequestProduct__c srp : prdASList)
        {
            ProductSelectUnselectWrapper wrap = new ProductSelectUnselectWrapper();
            wrap.prdName =srp.Name;
            wrap.prdId = srp.id;            
            wrap.prdProductDescription= srp.Product_Description__c;
            wrap.prdProductCost= srp.Product_Cost__c;
            wrap.prdQuantity= srp.Quantity__c;
            wrap.prdSampleRequest= srp.SampleRequest__c;
            wrap.prdSequence= srp.Sequence_Number__c;
            wrap.prdType= srp.CFNA_Type__c;
            wrap.prdShippedWeight= srp.Shipped_Weight__c;                      
            wrap.prdOtherType= srp.CFNA_Other_Type__c;           
            wrap.prdJulianProductionDate= srp.Julian_Date__c;
            wrap.prdFulfillmentStatus= srp.Fulfillment_Status__c;
            wrap.prdFulfillmentPlant= srp.Fulfillment_Plant__c;
            wrap.prdDistributorProductCode= srp.Distributor_Code__c;
            wrap.prdCargillProductCode= srp.Product_Code__c;
            wrap.prdBusinessUnit= srp.CFNA_Business_Unit__c;
            wrap.prdProductName=srp.Product__r.Name;            
            wrap.isChecked = false;
            
            wrapList.add(wrap); 
        }  
        
        return new Response(true,'Success',wrapList);
    }
    
    @AuraEnabled
    public static Response getRemovedProductDetails(List<string> sampleRequestProd, string sampleReqFulFillId){
        
        system.debug('####sampleRequestProd ==='+sampleRequestProd);
        List<SampleRequestProduct__c> sampleRequestProdList = new List<SampleRequestProduct__c>();
        List<SampleRequestProduct__c> updateSampleRequestProdList = new List<SampleRequestProduct__c>();
        sampleRequestProdList = [select id,name,Sample_Request_Fulfillment__c,SampleRequest__c from SampleRequestProduct__c where id IN: sampleRequestProd];
        //List<Sample_Request_Fulfillment__c> sampleReqFulfillmentList = new List<Sample_Request_Fulfillment__c>();
        //List<ProductSelectUnselectWrapper> wrapList = new List<ProductSelectUnselectWrapper>();    
        
        for(SampleRequestProduct__c srp : sampleRequestProdList)
        {
            srp.Sample_Request_Fulfillment__c = null;
            updateSampleRequestProdList.add(srp);
        }
        if(!updateSampleRequestProdList.isEmpty())
        {
            try{
                update updateSampleRequestProdList;
                system.debug('%%%updateSampleRequestProdList22=='+updateSampleRequestProdList); 
            }catch(exception e){
                system.debug('%%%exception=='+e);
            }
        }
        return new Response(true,'Success',updateSampleRequestProdList);
    }
    
    @AuraEnabled   
    public static Response saveSampleRequestDetails(string sampleWrapper, string sampleReqFulFillId) {
        List<ProductSelectUnselectWrapper> sampleWrapperList = new List<ProductSelectUnselectWrapper>();
        system.debug('%%%%sampleWrapper===='+sampleWrapper);
        sampleWrapperList = (List<ProductSelectUnselectWrapper>)System.JSON.deserialize(sampleWrapper,List<ProductSelectUnselectWrapper>.class);
        //system.debug('%%%%sampleWrapperList===='+sampleWrapperList);
        set<Id> prdIds = new set<Id>();
        for(ProductSelectUnselectWrapper wrap: sampleWrapperList){
            prdIds.add(wrap.prdId);
        }
        List<SampleRequestProduct__c> srplist = new List<SampleRequestProduct__c>();
        List<SampleRequestProduct__c> updateSrplist = new List<SampleRequestProduct__c>();
        List<Sample_Request_Fulfillment__c> srfList = new List<Sample_Request_Fulfillment__c>();
        ProductSelectUnselectWrapper wrap = new ProductSelectUnselectWrapper();
        srplist =[SELECT Id, Name, Product__c,Shipped_Weight__c,Julian_Date__c,Sequence_Number__c,Product__r.Name,CFNA_Type__c,CFNA_Other_Type__c,Fulfillment_Status__c,Fulfilled__c from SampleRequestProduct__c where ID IN : prdIds];
        //system.debug('+++sampleReqFulFillId=='+sampleReqFulFillId);
        srfList =[select id,Name,Sample_Request__c,Status__c from Sample_Request_Fulfillment__c where id=:sampleReqFulFillId];
        
        updateSrplist = validateSampleReqDetails(sampleWrapperList,srplist,updateSrplist);
        /*for(ProductSelectUnselectWrapper wrap1: sampleWrapperList )
        {
           //system.debug('++wrap1++'+wrap1);
            for(SampleRequestProduct__c srp1 : srplist)
            {
                //updateSrplist = Protein_SampleRequestHelper.validateSampleReqDetails(wrap1,srp1,updateSrplist);
                system.debug('###updateSrplist##=='+updateSrplist);
                if(wrap1.prdId == srp1.id)  //moved to separate method
                {
                    //system.debug('+++srp1+'+srp1);
                    //srp1.id= wrap1.prdId;
                    srp1.Sequence_Number__c = wrap1.prdSequence;
                    srp1.CFNA_Type__c = wrap1.prdType;
                    srp1.Shipped_Weight__c = wrap1.prdShippedWeight;
                    srp1.CFNA_Other_Type__c = wrap1.prdOtherType;
                    srp1.Julian_Date__c = wrap1.prdJulianProductionDate;
                    if(wrap1.prdFulfillmentStatus == '--None--'){  ///////
                        srp1.Fulfillment_Status__c='';                   
                    }
                    else{
                        srp1.Fulfillment_Status__c = wrap1.prdFulfillmentStatus;    
                    }
                    updateSrplist.add(srp1); 
                    //system.debug('###updateSrplist##=='+updateSrplist);
                } 
            } 
            
        } */
        if(!updateSrplist.isEmpty())
        {
            try{
                update updateSrplist;
                system.debug('%%%updateSrplist22=='+updateSrplist); 
            }catch(exception e){
                system.debug('%%%exception=='+e);
            }
        }
        //system.debug('####Sample_Request_Fulfillment__c'+srfList);      
        List<SampleRequestProduct__c> updateSampleRequestProd = new List<SampleRequestProduct__c>();
        updateSampleRequestProd = validateSampleReqProdDetails(srfList,srplist,updateSampleRequestProd);
        /*for(Sample_Request_Fulfillment__c srf1 : srfList) //moved to separate method
        {
            if (srf1.Status__c == 'Complete' || srf1.Status__c == 'Not Approved')
            {
                //system.debug('@@@srplist'+srplist);
                for (SampleRequestProduct__c srp : srplist) 
                {
                    srp.Fulfilled__c = true;
                    updateSampleRequestProd.add(srp);
                    //system.debug('@@@updateSampleRequestProd'+updateSampleRequestProd);
                } 
            }
            
        } */
        if(!updateSampleRequestProd.isEmpty())
        {
            try{
                update updateSampleRequestProd;
                system.debug('@@@updateSampleRequestProd=='+updateSampleRequestProd);
            }catch(exception e){
                system.debug('@@@exception=='+e);
            }
            
            // Below part of code is to update email template with sample product details
            //system.debug('****sampleReqFulFillId ==='+sampleReqFulFillId);
            Sample_Request_Fulfillment__c  fullStatusUpdate =[select id,name,IsFulfilled__c from Sample_Request_Fulfillment__c where id=: sampleReqFulFillId limit 1];
            fullStatusUpdate.IsFulfilled__c = true;   
            if(Sample_Request_Fulfillment__c.sObjectType.getDescribe().isUpdateable()){  
                Update fullStatusUpdate;
            }//system.debug('****FullStatusUpdate==='+fullStatusUpdate);
            List<SampleRequestProduct__c> srProd = new List<SampleRequestProduct__c>();
            srProd  = [select id,Sample_Request_Fulfillment__r.name,Fulfillment_Status__c from SampleRequestProduct__c where Sample_Request_Fulfillment__c =: sampleReqFulFillId];
            //system.debug('****srProd ==='+srProd  ); 
        }
        return new Response(true,'Success',updateSrplist);
    }
    
    private static List<SampleRequestProduct__c> validateSampleReqDetails(List<ProductSelectUnselectWrapper> sampleWrapperList,List<SampleRequestProduct__c> srplist,List<SampleRequestProduct__c> updateSrplist)
    {
        for(ProductSelectUnselectWrapper wrap1: sampleWrapperList )
        {
           //system.debug('++wrap1++'+wrap1);
            for(SampleRequestProduct__c srp1 : srplist)
            {
                system.debug('###updateSrplist##=='+updateSrplist);
                if(wrap1.prdId == srp1.id)  //added in Protein_SampleRequestHelper class
                {
                    //system.debug('+++srp1+'+srp1);
                    //srp1.id= wrap1.prdId;
                    srp1.Sequence_Number__c = wrap1.prdSequence;
                    srp1.CFNA_Type__c = wrap1.prdType;
                    srp1.Shipped_Weight__c = wrap1.prdShippedWeight;
                    srp1.CFNA_Other_Type__c = wrap1.prdOtherType;
                    srp1.Julian_Date__c = wrap1.prdJulianProductionDate;
                    if(wrap1.prdFulfillmentStatus == '--None--'){  ///////
                        srp1.Fulfillment_Status__c='';                   
                    }
                    else{
                        srp1.Fulfillment_Status__c = wrap1.prdFulfillmentStatus;    
                    }
                    updateSrplist.add(srp1); 
                    //system.debug('###updateSrplist##=='+updateSrplist);
                } 
            }
            
        }

        return updateSrplist;
    }
    
    private static List<SampleRequestProduct__c> validateSampleReqProdDetails(List<Sample_Request_Fulfillment__c> srfList,List<SampleRequestProduct__c> srplist,List<SampleRequestProduct__c> updateSampleRequestProd)
    {
        for(Sample_Request_Fulfillment__c srf1 : srfList)
        {
            if (srf1.Status__c == 'Complete' || srf1.Status__c == 'Not Approved')
            {
                //system.debug('@@@srplist'+srplist);
                for (SampleRequestProduct__c srp : srplist) 
                {
                    srp.Fulfilled__c = true;
                    updateSampleRequestProd.add(srp);
                    //system.debug('@@@updateSampleRequestProd'+updateSampleRequestProd);
                } 
            }
            
        } 
        return updateSampleRequestProd;
    }
    // Ended //
   
    
}