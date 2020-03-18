public with sharing class Protein_SampleRequestController {
    private final static String SUCCESS='Success';
    private final static String FAILED='Failure';
    private final static String ERROR_MSG='Unknown Error';
    //private static sampleRequestWrapper wrap ;
    //private static String SendResult;
    private static String CFNASampleRequestFormData;
    
    // Sample Request Wrapper
    public class sampleRequestWrapper{
        @Auraenabled
        public string emailBody,emailTo,sampleRequestNumber,reasonForSample;
        
    }
    
    @Auraenabled
    public static Response getSampleRequestWrapperList(string sampleRequestId)
    {
        Boolean hasError=false;
        String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + sampleRequestId;
        //String EmailBody;
        sampleRequestWrapper wrap = new sampleRequestWrapper();
        SampleRequest__c sampleRequest = new SampleRequest__c();
        List<sampleRequestWrapper> wrapList = new List<sampleRequestWrapper>();
        system.debug('####sampleRequestId2222=='+sampleRequestId);
        if (SampleRequest__c.sObjectType.getDescribe().isAccessible()){
            sampleRequest =[select id,name,Email_Body__c,Business_Unit_Sales_Channel__c,Request_Number__c,SRCustomer_Name__r.Name,Sales_Channel__c,Alert_Msg_for_Sample_Request_Email__c,CFNA_Sample_Request_Email__c,Confirmation_Email__c  from SampleRequest__c where id=:sampleRequestId];
        }//System.debug('sampleRequest: ' +sampleRequest);
        String text = 'Hello,<br/>' + htmlEncode(sampleRequest.Email_Body__c) + '<br/>';
        text += '<a href="' + fullRecordURL + '">' + htmlEncode(sampleRequest.Request_Number__c + ' - ' + sampleRequest.SRCustomer_Name__r.Name) + '</a><br/>';                
        if(sampleRequest.Sales_Channel__c == 'Retail' || sampleRequest.Sales_Channel__c == 'Ingredient'){
            text += 'If you have any questions, ' + sampleRequest.Alert_Msg_for_Sample_Request_Email__c + '<br/><br/>Thank you';
        }else{
            text += 'If you have any questions, ' + sampleRequest.Alert_Msg_for_Sample_Request_Email__c + '<br/><br/>Thank you,<br/>Cargill Foodservice Sales Operations';
        }
        //system.debug('####text=='+text);
        wrap.emailBody =text; 
        //system.debug('####wrap.emailBody=='+wrap.emailBody);
        // Custom Meta data
        
        Sample_Request_Email_List_Mapping__mdt sampleReqEmailList = new Sample_Request_Email_List_Mapping__mdt();
        if (Sample_Request_Email_List_Mapping__mdt.sObjectType.getDescribe().isAccessible()){
            sampleReqEmailList = [SELECT MasterLabel, Business_Unit__c,Sales_Channel__c,Send_To__c FROM Sample_Request_Email_List_Mapping__mdt WHERE MasterLabel =: sampleRequest.Business_Unit_Sales_Channel__c];
        }
        wrap.emailTo = sampleReqEmailList.Send_To__c;  //sampleRequest.CFNA_Sample_Request_Email__c;
        if(wrap.emailTo == null) 
        {
            wrap.emailTo = UserInfo.getUserEmail();
        }else{
            wrap.emailTo = wrap.emailTo + '; ' + UserInfo.getUserEmail();
        } 
        //wrap = validateEmailInfo(wrap);
        if (sampleRequest.Confirmation_Email__c != null)
        {
            wrap.emailTo = wrap.emailTo + '; ' + sampleRequest.Confirmation_Email__c;
        } 
        wrap.emailTo = wrap.emailTo.Replace(';;', ';');
        wrapList.add(wrap);
        
        if(hasError){
            return new Response(false,FAILED+ERROR_MSG,wrapList);
        }else{
            return new Response(true,SUCCESS,wrapList);   
        } 
    }
    
    // Used to retrieve data for the CFNA Sample Request Form in base64 format
    // we store it in a hidden field so that we can retrieve the edited document for sending
    @Auraenabled
    public static Response populateCFNASampleRequestFormData(string sampleRequestId){
        
        SampleRequest__c sampleRequest = new SampleRequest__c();
        sampleRequest =[select id,name,Email_Body__c,Sales_Channel__c from SampleRequest__c where id=:sampleRequestId];
        
        PageReference pr = new PageReference('/resource/CFS_Sample_Request_Form');
        if(sampleRequest.Sales_Channel__c == 'Retail'){
            pr = new PageReference('/resource/Retail_Ingredient_Sample_Request_Form');
        }else if(sampleRequest.Sales_Channel__c == 'Ingredient'){
            pr = new PageReference('/resource/Protein_Ingredient_Sample_Request_Form');
        }
        Blob content;
        if(Test.isRunningTest()){
            content = Blob.valueOf('test data');             
        } else {
            content = pr.getContent();                  
        }
        CFNASampleRequestFormData = EncodingUtil.base64Encode(content);
        system.debug('%%%%CFNASampleRequestFormData 11=='+CFNASampleRequestFormData);
        return new Response(true,SUCCESS,CFNASampleRequestFormData); 
    }
    
    private static String htmlEncode(String input) {
        String[] fromArr  = new String[]{ '&', '<', '>', '"', '\''};
            String[] toArr  = new String[]{ '&amp;', '&lt;', '&gt;', '&quot;', '&#39;' };
                
                if (input == null || input.length() == 0){
                return '';
                }
        for (Integer i = 0; i < fromArr.size(); ++i) {
            input = input.replace(fromArr[i], toArr[i]);
        }
        
        return input;
    }
    
    @Auraenabled
    public static Response sendSampleRequest(string sampleRequestId,string sampleWrapper,String excelData) {
        
        sampleRequestWrapper sampleRequestwrap=(sampleRequestWrapper)JSON.deserialize(sampleWrapper,sampleRequestWrapper.class); 
        Boolean hasError=false;
        Boolean attachExcel;
        SampleRequest__c sampleRequest = new SampleRequest__c();
        sampleRequest =[select id,name,Email_Body__c,Request_Form_Sent_On__c,Email_Subject__c,Request_Form_Sent_By__c,Status__c,Pull_Product_From_Distributor__c,
                        SRCustomer_Name__r.Name,CFNA_Sample_Request_Email__c,CFNA_Business_Unit__c,Request_Date__c,Confirmation_Email__c,
                        Sales_Channel__c,RecordType.DeveloperName from SampleRequest__c where id=:sampleRequestId];
        system.debug('######wrap.sampleRequestwrap---=='+sampleRequestwrap);
        string getAttachmentName =  'Sample Request Form - ' + sampleRequest.SRCustomer_Name__r.Name + ' - ' + sampleRequest.Name + ' - ' + sampleRequest.CFNA_Business_Unit__c + ' - ' + sampleRequest.Request_Date__c.format().replace('/', '_') + '.xlsx';
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setHtmlBody(sampleRequestwrap.emailBody);   //(wrap.emailBody);
        email.setSubject(sampleRequest.Email_Subject__c);
        email.setToAddresses(sampleRequestwrap.emailTo.split(';'));
        //system.debug('######email---=='+sampleRequestwrap.emailTo);
        
        PageReference pr = new PageReference('/resource/CFS_Sample_Request_Form');
        pr = Protein_SampleRequestProductController.validatePageRef(sampleRequest,pr); 
        /*if(sampleRequest.Sales_Channel__c == 'Retail'){
            pr = new PageReference('/resource/Retail_Ingredient_Sample_Request_Form');
        }else if(sampleRequest.Sales_Channel__c == 'Ingredient'){
            pr = new PageReference('/resource/Protein_Ingredient_Sample_Request_Form');
        } */ 
        Blob content;
        if(Test.isRunningTest()){
            content = Blob.valueOf('test data');             
        } else {
            content = pr.getContent();                  
        }
        CFNASampleRequestFormData = EncodingUtil.base64Encode(content);
                 
        /*if (sampleRequest.Pull_Product_From_Distributor__c == 'Yes' || sampleRequest.Confirmation_Email__c != null){
            attachExcel = true;
        }   
        else if (sampleRequest.CFNA_Business_Unit__c == 'Truvia'){
            attachExcel = true;
        }
        else if (sampleRequest.RecordType.DeveloperName == 'Protein_Sample_Request'){
            attachExcel = true;
        }
        else{
            attachExcel = false;
        }*/ //added in Protein_SampleRequestHelper class 
        attachExcel = validateAttachExcel(sampleRequest,attachExcel);
        if (attachExcel){
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(getAttachmentName);
            attachment.setContentType('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
            attachment.setBody(EncodingUtil.base64Decode(excelData)); 
            email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });    
        }
        Messaging.sendEmail(new Messaging.Email[] {email});
        
        sampleRequest.Request_Form_Sent_On__c = System.now();
        sampleRequest.Request_Form_Sent_By__c = Userinfo.getUserId();
        sampleRequest.Status__c = 'Ready for Further Processing';
        if(sampleRequest.Pull_Product_From_Distributor__c == 'Yes'){
            sampleRequest.Status__c = 'Complete';
        } 
        //sampleRequest = Protein_SampleRequestHelper.validateSamReqStatus(sampleRequest); 
        if(SampleRequest__c.sObjectType.getDescribe().isUpdateable()){
            update sampleRequest;
        }  //system.debug('######sampleRequest---=='+sampleRequest); 
         
        if(hasError){
            return new Response(false,FAILED+ERROR_MSG,sampleRequestwrap);
        }else{
            return new Response(true,SUCCESS,sampleRequestwrap); 
        } //return null;
    } 
    
    @Auraenabled
    public static Response fetchSampleRequestInfoOnExcel(string sampleRequestId)
    {
        Boolean hasError=false;
        //sampleRequestWrapper wrap = new sampleRequestWrapper();
        SampleRequest__c sampleRequest = new SampleRequest__c();
        //List<sampleRequestWrapper> wrapList = new List<sampleRequestWrapper>();
        system.debug('####sampleRequestId ===='+sampleRequestId);
        
        sampleRequest =[select id,Name,Request_Date__c,Requested_Delivery_Date__c,Reason_for_Sample__c,CFNA_Business_Unit__c,Request_Number__c,
                        End_User_Company_Name__c,End_User_Contact__c,End_User_Location__c,Ship_to_Company__c,Customer_Contact__c,Street__c,City__c,
                        StatePicklist__c,Postal_Code__c,Additional_Notes__c from SampleRequest__c where id=:sampleRequestId];                     
        // wrap.sampleRequestNumber = sampleRequest.Request_Number__c ;
        // wrap.reasonForSample= sampleRequest.Reason_for_Sample__c;                
        //wrapList.add(wrap);
        
        if(hasError){
            return new Response(false,FAILED+ERROR_MSG,sampleRequest);
        }else{
            return new Response(true,SUCCESS,sampleRequest);
        }    
    }
    
    @Auraenabled
    public static Response fetchSampleProductInfoOnExcel(string sampleRequestId)
    {
        Boolean hasError=false;
        List<SampleRequestProduct__c> sampleProductList = new List<SampleRequestProduct__c>();
        //system.debug('####sampleRequestId ===='+sampleRequestId);
        if(SampleRequestProduct__c.sObjectType.getDescribe().isAccessible()){
        sampleProductList =[select id,Name,SampleRequest__c,Distributor_Code__c,Product_Name__c,Product_Description__c,Quantity__c,
                            CFNA_Type__c,SampleRequest__r.SRCustomer_Name__r.Name,SampleRequest__r.CFNA_Business_Unit__c,SampleRequest__r.Request_Date__c from SampleRequestProduct__c where SampleRequest__c =:sampleRequestId];                     
        }
        if(hasError){
            return new Response(false,FAILED+ERROR_MSG,sampleProductList);
        }else{
            //if(!sampleProductList.isEmpty())
            return new Response(true,SUCCESS,sampleProductList); 
        }//else
        //return new Response(false,Failed,sampleProductList);
        
    }  
    
    // Method to check if any products are added to sample request
    @Auraenabled
    public static Response checkSampleProductData(string sampleRequestId)
    {
        Boolean hasError=false;
        Boolean isSampleProdDataAdded;
        List<SampleRequestProduct__c> sampleProductList = new List<SampleRequestProduct__c>();
        system.debug('*****sampleRequestId ===='+sampleRequestId);
        if(SampleRequestProduct__c.sObjectType.getDescribe().isAccessible()){
        sampleProductList =[select id,Name,SampleRequest__c,Distributor_Code__c,Product_Name__c,Product_Description__c,Quantity__c,
                            CFNA_Type__c,SampleRequest__r.SRCustomer_Name__r.Name,SampleRequest__r.CFNA_Business_Unit__c,SampleRequest__r.Request_Date__c from SampleRequestProduct__c where SampleRequest__c =:sampleRequestId];                     
        }//system.debug('*****sampleProductList =='+sampleProductList );   
        if(sampleProductList.isEmpty())  //sampleProductList.size()<=0
        {
            isSampleProdDataAdded = true;
        }
        else{
            isSampleProdDataAdded = false;
        }
        if(hasError){
            return new Response(false,FAILED+ERROR_MSG,isSampleProdDataAdded);
        }else{
            return new Response(true,SUCCESS,isSampleProdDataAdded);  
        }  
    }
    
    private static boolean validateAttachExcel(SampleRequest__c sampleRequest,Boolean attachExcel)
    {
        if(sampleRequest.Pull_Product_From_Distributor__c == 'Yes' || sampleRequest.Confirmation_Email__c != null){
           return (attachExcel=true);   
                     
        }
        else{
            return validateAttachExcelTwo(sampleRequest,attachExcel); 
        } 
               
    }
    private static boolean validateAttachExcelTwo(SampleRequest__c sampleRequest,Boolean attachExcel)
    {
        if(sampleRequest.CFNA_Business_Unit__c == 'Truvia'){
           return (attachExcel=true);   
                     
        }
        else{
            return validateAttachExcelThree(sampleRequest,attachExcel);  
        } 
               
    }
    private static boolean validateAttachExcelThree(SampleRequest__c sampleRequest,Boolean attachExcel)
    {
        if(sampleRequest.RecordType.DeveloperName == 'Protein_Sample_Request'){
           return (attachExcel=true);   
                     
        }
        else{
            return false;  
        } 
               
    } 
        
    // ***** Mahesh Code  ************//
    
    //Wrapper Class
    /*public class SRProductWrapper {
        @AuraEnabled
        public SampleRequestProduct__c srProduct;
        public SRProductWrapper() {
        }
    }*/
    /*
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
        //if(sampleRequestId!=null)
        //{
           // Sample_Request_Fulfillment__c srp = new Sample_Request_Fulfillment__c();
            //if(Sample_Request_Fulfillment__c.sObjectType.getDescribe().isAccessible()){
               Sample_Request_Fulfillment__c srp = [select id,Name,Status__c,Sample_Request__c from Sample_Request_Fulfillment__c where id=:sampleRequestId limit 1];
            //}//system.debug('*****srp =='+srp );            
            prdList = [SELECT Id, Name, Product__c,  Product_Description__c, Product_Cost__c, 
                       Quantity__c, SampleRequest__c, Sample_Request_Fulfillment__c, Sequence_Number__c, 
                       CFNA_Type__c, Shipped_Weight__c,   CFNA_Other_Type__c, 
                       Julian_Date__c, Fulfillment_Status__c, Fulfillment_Plant__c,Fulfilled__c, Distributor_Code__c, 
                       Product_Code__c, CFNA_Business_Unit__c, Sample_Request_Name__c, Product__r.Name, recordType.DeveloperName, 
                       SampleRequest__r.recordType.DeveloperName FROM SampleRequestProduct__c where SampleRequest__c =:srp.Sample_Request__c AND Sample_Request_Fulfillment__c = null];
            
            //system.debug('****prdList ==='+prdList);
        //}  
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
        //
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
        
        updateSrplist = Protein_SampleRequestHelper.validateSampleReqDetails(sampleWrapperList,srplist,updateSrplist);
        /*for(ProductSelectUnselectWrapper wrap1: sampleWrapperList )
        {
           //system.debug('++wrap1++'+wrap1);
            for(SampleRequestProduct__c srp1 : srplist)
            {
                updateSrplist = Protein_SampleRequestHelper.validateSampleReqDetails(wrap1,srp1,updateSrplist);
                system.debug('###updateSrplist##=='+updateSrplist);
                /*if(wrap1.prdId == srp1.id)  //added in Protein_SampleRequestHelper class
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
            //}
            
        //}
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
        updateSampleRequestProd = Protein_SampleRequestHelper.validateSampleReqProdDetails(srfList,srplist,updateSampleRequestProd);
        /*for(Sample_Request_Fulfillment__c srf1 : srfList) //added in Protein_SampleRequestHelper class
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
            
        } /////uncommented
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
    // Ended //
    
    // ***************** Code written by Harshitha ****************************
    @AuraEnabled
    public static List <sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select Id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        List <sObject> lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    //Wrapper Class
    public class SRProductWrapperOfASample {
        @AuraEnabled
        public SampleRequestProduct__c srProduct;
        @AuraEnabled
        public Product2 relatedProduct;
        @AuraEnabled
        public Id relatedProductId;
        @AuraEnabled
        public Boolean isNew;
        
    }
    
    @AuraEnabled
    public static SampleRequest__c getSampleDetails(Id sampleId) {
        return ([SELECT Id, CFNA_Business_Unit__c, RecordTypeId, RecordType.DeveloperName FROM SampleRequest__c WHERE Id =:sampleId LIMIT 1]);
    }
    
    @AuraEnabled
    public static List<SRProductWrapperOfASample> getSampleRequestProductsOfASample(Id sampleId) {
        List<SRProductWrapperOfASample> lstProductWrapper = new List<SRProductWrapperOfASample>();
        List<SampleRequestProduct__c> lstProducts = [SELECT Id, Name, Product__c, CFNA_Product_Desc__c, Product_Description__c, Product_Cost__c, 
                                                     Quantity__c, SampleRequest__c, Sample_Request_Fulfillment__c, Sequence_Number__c, 
                                                     CFNA_Type__c, Shipped_Weight__c, CFNA_Other_Type__c,  
                                                     Julian_Date__c, Fulfillment_Status__c, Fulfillment_Plant__c,Distributor_Code__c, 
                                                     Product_Code__c, CFNA_Business_Unit__c, Sample_Request_Name__c, Product__r.Name, recordType.DeveloperName, 
                                                     SampleRequest__r.recordType.DeveloperName, SampleRequest__r.CFNA_Business_Unit__c FROM SampleRequestProduct__c 
                                                     WHERE SampleRequest__c=:sampleId ORDER BY Name DESC];
        
        Set<Id> setProductIDs = new Set<Id>();
       
        for(SampleRequestProduct__c srp : lstProducts){
            setProductIDs.add(srp.Product__c);
        }
        Map<Id,Product2> mapProducts = new Map<Id,Product2>([select id,name from product2 where id IN :setProductIDs ]); // Key- Related Product ID, Value - Relate Product record
        
        for(SampleRequestProduct__c srp : lstProducts) {
            SRProductWrapperOfASample prodWrapper = new SRProductWrapperOfASample();
            prodWrapper.srProduct = srp;
            if(srp.Product__c != null){
                prodWrapper.relatedProduct = mapProducts.get(srp.Product__c);
                prodWrapper.relatedProductId = mapProducts.get(srp.Product__c).Id;
            }
            
            lstProductWrapper.add(prodWrapper);
        }
        //for(SRProductWrapperOfASample srpwrap : lstProductWrapper)
            //System.debug('srpwrap: ' +srpwrap);
        return lstProductWrapper;
    }
    
    @AuraEnabled
    public static void deleteSRProduct(Id srpId) {
        Database.delete(srpId);
    }
    
    @AuraEnabled
    public static String upsertSRProducts(Id sampleId, String data, String sampleBU) {
        String errMsg = '';
        List<SampleRequestProduct__c> lstUpsertSRPs = new List<SampleRequestProduct__c>();
        List<SRProductWrapperOfASample> lstProductWrapper = (List<SRProductWrapperOfASample>)JSON.deserialize(data, List<SRProductWrapperOfASample>.class);
        //System.debug('lstProductWrapper: '+lstProductWrapper);
        //Adding New Sample Request Products to lstUpsertSRPs list for Insertion
        if(!lstProductWrapper.isEmpty()) {
            for(SRProductWrapperOfASample srpWrp : lstProductWrapper) {
                if(srpWrp.isNew) {
                    SampleRequestProduct__c rec = new SampleRequestProduct__c();
                    rec.CFNA_Business_Unit__c = sampleBU;
                    rec.CFNA_Other_Type__c = srpWrp.srProduct.CFNA_Other_Type__c;
                    rec.CFNA_Product_Desc__c = srpWrp.srProduct.CFNA_Product_Desc__c;
                    rec.CFNA_Type__c = srpWrp.srProduct.CFNA_Type__c;
                    //rec.Id = srpWrp.srProduct.Id;
                    rec.Product__c = srpWrp.relatedProduct.Id;
                    rec.Product_Code__c = srpWrp.srProduct.Product_Code__c;
                    rec.Product_Cost__c = srpWrp.srProduct.Product_Cost__c;
                    rec.Quantity__c = srpWrp.srProduct.Quantity__c;
                    rec.SampleRequest__c = sampleId;
                    lstUpsertSRPs.add(rec);
                }
            }
            System.debug(lstUpsertSRPs);
        }
        
        //Adding Existing Sample Request Products to lstUpsertSRPs list for Updation
        List<SampleRequestProduct__c> lstSRProductsFromDB = [SELECT Id, Name FROM SampleRequestProduct__c WHERE SampleRequest__c=:sampleId];
        for(SRProductWrapperOfASample srpWrp : lstProductWrapper) {
            for(SampleRequestProduct__c srp : lstSRProductsFromDB) {
                //system.debug('%%%%srpWrp.isNew=='+srpWrp.isNew);
                if(!srpWrp.isNew && srpWrp.srProduct.Id == srp.Id) {
                    srp.CFNA_Other_Type__c = srpWrp.srProduct.CFNA_Other_Type__c;
                    srp.CFNA_Product_Desc__c = srpWrp.srProduct.CFNA_Product_Desc__c;
                    srp.CFNA_Type__c = srpWrp.srProduct.CFNA_Type__c;
                    //System.debug('%%%%srpWrp.relatedProduct.Id=='+srpWrp.relatedProduct.Id);
                    srp.Product__c = srpWrp.relatedProduct.Id;
                    srp.Product_Code__c = srpWrp.srProduct.Product_Code__c;
                    srp.Product_Cost__c = srpWrp.srProduct.Product_Cost__c;
                    srp.Quantity__c = srpWrp.srProduct.Quantity__c;
                    lstUpsertSRPs.add(srp);
                }
            }
        }
        
        //Insert and update the above added records to lstUpsertSRPs list in Try block and catch errors(if any) in Catch block.
        try {
            if(!lstUpsertSRPs.isEmpty() && (SampleRequestProduct__c.sObjectType.getDescribe().isUpdateable() || SampleRequestProduct__c.sObjectType.getDescribe().isCreateable())) {        
                    upsert lstUpsertSRPs;
                    System.debug('Upsert successful!');
                    errMsg = '';       
            }    
        }
        catch(Exception ex) {
            errMsg = ex.getMessage();
        }
        
        return errMsg;
    }
    
    //The below method is used to get the Map of the Controlling fields along with the list of their corresponding Dependant fields.
    @AuraEnabled
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase(); 
        String dependentField  = depfieldApiName.toLowerCase(); 
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)){
            return '';
        }
        String validForBits = '';
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        return validForBits;
    }
    
    private static final String BASE64CHARS = '' +'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +'abcdefghijklmnopqrstuvwxyz' +'0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> pLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(pLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        private String active; //{get;set;}
        private String defaultValue; //{get;set;}
        private String label; //{get;set;}
        private String value; //{get;set;}
        private String validFor; //{get;set;}
        public PicklistEntryWrapper(String active,String defaultValue,String label,String value,String validFor){      
            active =  this.active;
            defaultValue = this.defaultValue;
            label = this.label;
            value = this.value;
            validFor = this.validFor;     
        }
        
    } */
    /* --------------------------- Dependent picklist methods ends here -------------------------------*/
    /*
    @AuraEnabled
    public static Response deleteRecord(Id recId){
        
        Database.DeleteResult rs=Database.delete(recId);
        if(rs.isSuccess()){
            return new Response(true,'SUCCESS',true);
        }else{
            return new Response(false,'SUCCESS',false);
        }
    }
    // ************************ Code written by Harshitha ends here *******************************
     */
}