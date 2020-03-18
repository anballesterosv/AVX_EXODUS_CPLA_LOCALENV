@isTest
public with sharing class Protein_TestDataFactory {
    
    public static final String GLOBALACCOUNT_RECORD_TYPE = 'GlobalAccount';
    public static final String PAYERCCOUNT_RECORD_TYPE = 'Payer';
    public static final String COMMERCIALACCOUNT_RECORD_TYPE = 'CommercialAccount';
    public static final String INTERNAL_MARKETCHANNEL = 'Internal'; 
    public static final String FOODSERVICE_MARKETCHANNEL = 'Food Service';
    public static final String PI_MARKETCHANNEL = 'Protein Ingredients';
    public static final String INTERNATIONAL_MARKETCHANNEL = 'International'; 
    public static final String GROWTHVENTURES_MARKETCHANNEL = 'Growth Ventures';
    public static final String RETAIL_MARKETCHANNEL = 'Retail';
    public static final String BOXEDBEEF_OPP_RT = 'Boxed_Beef_Ground_Beef';
    public static final String DELI_OPP_RT = 'Deli';
    public static final String EGG_OPP_RT = 'Egg';
    public static final String OTHER_OPP_RT = 'Non_CPQ';
    public static final String TURKEY_OPP_RT = 'Turkey';
    public static final String EXPLORE_OPP_STAGE = 'Explore';
    public static final String DISCOVER_OPP_STAGE = 'Discover';
    public static final String CREATE_OPP_STAGE = 'Create';
    public static final String PRESENT_OPP_STAGE = 'Present';
    public static final String CLOSEDWON_OPP_STAGE = 'Closed Won';
    public static final String CLOSEDLOST_OPP_STAGE = 'Closed Lost';
    public static final String POUND_OPP_UOM = 'Pound';
    
    /**
* @Description :
*  This function will insert Integration_profile__c custom setting with SkipValidationProfiles__c= true
* 
* @author : Sri Harshitha Bandi
*/
    public static void insertCustomIntegrationProfileDetail(){
        try{
            insert new Integration_profile__c(SetupOwnerId=UserInfo.getOrganizationId(), SkipValidationProfiles__c=true);
        }catch(Exception ex){
            System.debug('Exception occured: '+ex);
        }
    }
    
    /**
* @Description :
*  This function will create Account Record with given accName, recordTypeName & marketChannel and return the same
* 
* @author : Sri Harshitha Bandi
* @param : accName - name of the Account, 
recordTypeName - Account recordtype,
marketChannel  - any of the market Channel 
* @return Account record 
*/
    public static Account createAccountRecord(String accName, String recordTypeName, String marketChannel) {
        //  Id recTypeId = [SELECT Id, Name FROM RecordType WHERE DeveloperName =: recordTypeName].Id;
        Account acc = new Account(Name = accName, 
                                  Market_Channel__c = marketChannel, 
                                  recordTypeId = Protein_SystemConstants.getRecordTypeId(recordtypename, Account.SObjectType));
        try{
            insert acc;
        }
        catch(Exception ex){
            system.debug('Exception ex :'+ex);
        }
        return acc;
        
    }
    
    /**
* @Description :
*  This function will create Opportunity Record with given oppName, recordTypeName, accId, volume, stage, closeDate & UOM and return the same
* 
* @author : Sri Harshitha Bandi
* @param : oppName - name of the Opportunity, 
recordTypeName - Opportunity recordtype,
accId  - Id of the parent account,
volume - Volume of the opp,
stage - Opportunity Stage,
closeDate - Opportunity Close Date,
UOM - Opp's Unit of Measure
* @return Opportunity record 
*/
    public static Opportunity createOpportunityRecord(String oppName, String recordTypeName, Id accId, Integer volume, String stage, Date closeDate, String uom) {
        //Id recTypeId = [SELECT Id, Name FROM RecordType WHERE developerName =: recordTypeName AND sobjecttype = 'Opportunity'].Id;
        Opportunity opp = new Opportunity(Name = oppName, AccountId = accId, CurrencyIsoCode = 'USD',
                                          StageName = stage, CloseDate = closeDate,
                                          Volume__c = volume, Unit_of_Measure__c = uom,
                                          recordTypeId = Protein_SystemConstants.getRecordTypeId(recordtypename, Opportunity.SObjectType));
        
        try{
            insert opp;
        }
        catch(Exception ex){
            system.debug('Exception ex :'+ex);
        }
        return opp;
    }
    
/**
* @Description :
*  This function will create CustomerMeetingReport Record with given Account and return the same
* 
* @author : Sri Harshitha Bandi
* @param : accId - ID of the Account
* @return CustomerMeetingReport record 
*/
    public static CustomerMeetingReport__c createCustomerMeetingReportRecord(Id accId) {
        CustomerMeetingReport__c cmr = new CustomerMeetingReport__c(Name = 'Test CMR', Account__c = accId);
        try{
            insert cmr;
        }
        catch(Exception ex){
            system.debug('Exception ex :'+ex);
        }
        return cmr;
    }
    
/**
* @Description :
*  This function will create CustomerMeetingReportOpp Record with given CMR & Opp and return the same
* 
* @author : Sri Harshitha Bandi
* @param : cmrId - ID of the Customer Meeting Report,
           oppId - ID of the Opportunity
* @return CustomerMeetingReportOpp record 
*/
    public static CustomerMeetingReportOpp__c createCustomerMeetingReportOppRecord(Id cmrId, Id oppId) {
        CustomerMeetingReportOpp__c cmro = new CustomerMeetingReportOpp__c(CustomerMeetingReport__c = cmrId, Opportunity__c = oppId);
        try{
            insert cmro;
        }
        catch(Exception ex){
            system.debug('Exception ex :'+ex);
        }
        return cmro;
    }
    
/**
* @Description :
*  This function will create Product Request Record
* 
* @author : Sri Harshitha Bandi 
* @return Product Request record 
*/
    public static Product_Request__c createProductRequest(String prName, String marketChannel, Id bmId, String protein, String prodDesc, 
                                                          String reasonForNoPrice, Integer annualVol, Date deliveryDate, Id oppId) {
                                                              System.debug(prodDesc);
                                                              Product_Request__c pr = new Product_Request__c(Name = prName, Market_Channel__c = marketChannel, Business_Manager__c = bmId,
                                                                                                             Protein__c = protein, Reason_for_No_Price__c = reasonForNoPrice, Annual_Volume__c = annualVol,
                                                                                                             Date_First_Sample_Delivered_to_Customer__c = deliveryDate, Related_Opportunity__c = oppId);
                                                              try{
                                                                  insert pr;
                                                              }
                                                              catch(Exception ex){
                                                                  system.debug('Exception ex :'+ex);
                                                              }
                                                              return pr;
                                                          }
    
    /**
* @Description :
*  This function will create User Record
* @author : Sri Harshitha Bandi 
* @return User record 
*/
    public static User createUser(String profileName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName]; 
        User u = new User(Alias = 'standt', Email='businessmanager@cargill.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='businessmanager@cargill.com.protein');
        try{
            insert u;
        }
        catch(Exception ex){
            system.debug('Exception ex :'+ex);
        }
        return u;
    }
    
    /**
* @Description :
*  This function will create Standard Product(Product2) Record
* @author : Sri Harshitha Bandi 
* @return Product record
*/
    public static Product2 createProduct(String prodName) {
        Product2 prod = new Product2(Name = prodName, Business__c ='Trade', CurrencyIsoCode = 'USD');
        try{
            insert prod;
        }
        catch(Exception ex){
            system.debug('Exception ex :'+ex);
        }
        return prod;
    }
    
    /**
* @Description :
*  This function will create PriceBook and PriceBookEntry Records
* @author : Sri Harshitha Bandi 
* @return PriceBookEntry record 
*/
    public static PricebookEntry createPriceBookEntry(Product2 p1) {
        // Get standard price book ID.
        Id pricebookId = Test.getStandardPricebookId();
        
        // Insert a price book entry for the standard price book.
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = p1.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = p1.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        return customPrice;
    }
    
    /**
* @Description :
*  This function will create Opportunity Line Item (Opportunity Product) Record
* @author : Sri Harshitha Bandi 
* @return Opp Product record 
*/
    public static OpportunityLineItem createOppProduct(Id oppId, Id prodId, Double salesPrice, Integer quantity, id pbeId) {
        OpportunityLineItem oli = new OpportunityLineItem(UnitPrice = salesPrice, Product2Id = prodId, OpportunityId = oppId, Quantity = quantity,
                                                          PricebookEntryId = pbeId);
        try{
            insert oli;
        }
        catch(Exception ex){
            system.debug('Exception ex :'+ex);
        }
        return oli;
    }
    
    /**
* @Description :
*  This function will create Opportunity Product Group Record
* @author : Sri Harshitha Bandi 
* @return Product Group record 
*/
    public static Product_Group__c createProductGroup(Id oppId, Integer volume) {
        Product_Group__c pg = new Product_Group__c(Opportunity__c = oppId, Volume__c = volume);
        try{
            insert pg;
        }
        catch(Exception ex){
            system.debug('Exception ex :'+ex);
        }
        return pg;
    }
    
    /**

* @author : Mahesh
* @return Sample Request record 
*/
    public static SampleRequest__c sampleRequestRec(Id accId, String sampleBU, String reason,string status,Date reqDate,Date reqDelDate,string salesChannel,string salesrep,string confirmMail, String isPulledFromDistr) {
        Id recTypeId = [SELECT Id, Name FROM RecordType WHERE developerName='Protein_Sample_Request'].Id;
        SampleRequest__c sr = new SampleRequest__c(recordTypeId=recTypeId, SRCustomer_Name__c=accId, Reason_for_Sample__c=reason, CFNA_Business_Unit__c=sampleBU, Status__c=status,Request_Date__c=reqDate,Requested_Delivery_Date__c=reqDelDate,Sales_Channel__c=salesChannel,Sales_Rep__c=salesrep,Fulfillment_Back_to_Requester__c=TRUE,Confirmation_Email__c=confirmMail, Pull_Product_From_Distributor__c=isPulledFromDistr);
        try{
            insert sr;
        }
        catch(Exception ex){
            system.debug('Exception ex :'+ex);
        }
        return sr;
    }
    
    /**
* @author : Mahesh
* @return Sample Product record 
*/
    public static SampleRequestProduct__c sampleRequestPrd(Id sampleId,String prodDesc,string productCode,Integer quantity) {
        Product2 prod = createProduct('Test product');
        SampleRequestProduct__c srp = new SampleRequestProduct__c(Product__c=prod.Id,CFNA_Product_Desc__c=prodDesc,Product_Code__c=productCode,CFNA_Business_Unit__c='Salt',CFNA_Type__c='Can',Quantity__c= quantity,SampleRequest__c=sampleId);
        try{
            insert srp;
            system.debug('++++srp+++'+srp);
        }
        catch(Exception ex){
            system.debug('Exception ex :'+ex);
        }
        return srp;
    }
    
    
    /**
* @author : Mahesh
* @return Sample Product record 
*/
    public static Sample_Request_Fulfillment__c sampleRequestFul(Id sampleId, string plntName) {
        Plant__c pnt = createPlant(plntName);
        Sample_Request_Fulfillment__c srf = new Sample_Request_Fulfillment__c(Plant_Lookup__c=pnt.Id,Sample_Ship_Date__c=system.today(),Tracking__c='12345',Shipping_Company__c='FedEx',Status__c='Complete',Sample_Request__c=sampleId);
        try{
            insert srf;
        }
        catch(Exception ex){
            system.debug('Exception ex :'+ex);
        }
        return srf;
    }
    
    
    /**
* @Description : Create a new Plant
* @author : Mahesh C
* @return Plant Record 
*/
    public static Plant__c createPlant(string plntName) {
        Plant__c pnt = new Plant__c(Name=plntName ,CurrencyIsoCode = 'USD');
        try{
            insert pnt;
        }
        catch(Exception ex){
            system.debug('Exception ex :'+ex);
        }
        return pnt;
    }
    
    //Wrapper class
    public static Protein_SampleRequestFulfillmentCtlr.ProductSelectUnselectWrapper createProductSelectUnselectWrapper(SampleRequestProduct__c srProd, SampleRequest__c srReq, String prodFFstatus){
    Protein_SampleRequestFulfillmentCtlr.ProductSelectUnselectWrapper prodSelUnsel =new Protein_SampleRequestFulfillmentCtlr.ProductSelectUnselectWrapper();
        prodSelUnsel.prdId = srProd.id;
        prodSelUnsel.srProduct=srProd;
        prodSelUnsel.prdName=srProd.Name;
        prodSelUnsel.prdProductDesc='Test';
        prodSelUnsel.prdProductDescription='Test Product';
        prodSelUnsel.prdSampleRequest=srReq.Id;
        prodSelUnsel.prdSequence='test';
        prodSelUnsel.prdType='Bag';
        prodSelUnsel.prdOtherType='Box'; 
        prodSelUnsel.prdJulianProductionDate='12345';
        prodSelUnsel.prdFulfillmentStatus=prodFFstatus;
        prodSelUnsel.prdDistributorProductCode='test';
        prodSelUnsel.prdCargillProductCode='test';
        prodSelUnsel.prdBusinessUnit='Salt';
        prodSelUnsel.prdProductCost=23;
        prodSelUnsel.prdQuantity=123;
        prodSelUnsel.prdShippedWeight=2345;
        prodSelUnsel.isChecked=True;                                               
        return prodSelUnsel;
    }
    
/**
* @Description : Create a new Task
* @author : Sri Harshitha Bandi - 04/12/2019
* @returns a Task Record 
*/
    public static Task createTask(Id parentId, String subject, Id assignedToUserId, String status, Date dueDate) {
        Task tsk = new Task(Subject=subject, WhatId=parentId, OwnerId=assignedToUserId, CurrencyIsoCode = 'USD', Priority = 'Normal', Status = status, ActivityDate = dueDate);
        try{
            insert tsk;
        }
        catch(Exception ex){
            system.debug('Exception ex :'+ex);
        }
        return tsk;
    }
            
    
}