@isTest(seeAlldata=false)
public class Protein_SampleRequestController_Test {
    static testmethod void test1() {
        Account acc = Protein_TestDataFactory.createAccountRecord('Test Account', 'Commercial Account', 'Retail');
        System.assertEquals('Test Account' , acc.Name);
        //Product2 Prd2 = Protein_TestDataFactory.createProduct('Heritage');
        //Plant__c plnt= Protein_TestDataFactory.createPlant('Walmart INC');
        SampleRequest__c sRReq = Protein_TestDataFactory.SampleRequestRec(acc.Id, 'salt', 'competitive Cutting', 'draft', System.today(), System.today()+30,'foodservice', 'mahesh', 'test@gmail.com', 'yes');
        SampleRequestProduct__c sRProd = Protein_TestDataFactory.sampleRequestPrd(sRReq.Id,'prodDesc', 'productCode', 12);
        system.debug('%%%SRProd%%%'+sRProd);
        Sample_Request_Fulfillment__c sRFul = Protein_TestDataFactory.sampleRequestFul(sRReq.Id,'walmart');
        List<String> sRPList=new List<String>();
        sRPList.add(sRProd.Id);
        Protein_SampleRequestFulfillmentCtlr.ProductSelectUnselectWrapper prodSelUnsel1 = Protein_TestDataFactory.createProductSelectUnselectWrapper(sRProd, SRReq, 'fulfilled');
        List<Protein_SampleRequestFulfillmentCtlr.ProductSelectUnselectWrapper> lstProdSelUnsel1 = new List<Protein_SampleRequestFulfillmentCtlr.ProductSelectUnselectWrapper>();
        lstProdSelUnsel1.add(prodSelUnsel1);
        Protein_SampleRequestFulfillmentCtlr.saveSampleRequestDetails(JSON.serialize(lstProdSelUnsel1),sRFul.Id);
        Protein_SampleRequestFulfillmentCtlr.ProductSelectUnselectWrapper prodSelUnsel2 = Protein_TestDataFactory.createProductSelectUnselectWrapper(sRProd, sRReq, '--None--');
        List<Protein_SampleRequestFulfillmentCtlr.ProductSelectUnselectWrapper> lstProdSelUnsel2 = new List<Protein_SampleRequestFulfillmentCtlr.ProductSelectUnselectWrapper>();
        lstProdSelUnsel2.add(prodSelUnsel2);
        Protein_SampleRequestFulfillmentCtlr.saveSampleRequestDetails(JSON.serialize(lstProdSelUnsel2),sRFul.Id);
        Protein_SampleRequestController.populateCFNASampleRequestFormData(sRReq.id);
        Protein_SampleRequestController.fetchSampleRequestInfoOnExcel(sRReq.id);
        Protein_SampleRequestController.fetchSampleProductInfoOnExcel(sRReq.id);
        Protein_SampleRequestController.checkSampleProductData(sRReq.id);
        Protein_SampleRequestFulfillmentCtlr.getSampleRequestProducts(sRReq.id);
        Protein_SampleRequestFulfillmentCtlr.getSRP_BUs();
        Protein_SampleRequestFulfillmentCtlr.getRemovedProductDetails(sRPList,sRFul.Id); 
        Protein_SampleRequestFulfillmentCtlr.getProductWrapperList(sRFul.Id);
        Protein_SampleRequestProductController.fetchLookUpValues('test', 'Account'); 
        Protein_SampleRequestFulfillmentCtlr.getSelectedProductList(sRPList,sRFul.Id );
        Protein_SampleRequestProductController.getSampleDetails(sRReq.id);
        Protein_SampleRequestProductController.getSampleRequestProductsOfASample(sRReq.id);
        Protein_SampleRequestProductController.deleteSRProduct(sRProd.Id);
        // Convert to schema.sObjectType and then create an instance of that type
        Sobject genericObject = Schema.getGlobalDescribe().get('SampleRequestProduct__c').newSObject();   
        Protein_SampleRequestProductController.getDependentMap(genericObject, 'CFNA_Business_Unit__c', 'CFNA_Type__c');  //Harshitha
        Protein_SampleRequestProductController.decimalToBinary(2);
        Protein_SampleRequestProductController.base64ToBits('test');
        SampleRequestProduct__c sRProd1 = Protein_TestDataFactory.sampleRequestPrd(sRReq.Id,'prodDesc', 'productCode', 12);
        Protein_SampleRequestProductController.deleteRecord(sRProd1.Id);
        Protein_SampleRequestFulfillmentCtlr.getProductWrapperList(sRFul.Id);
    }
    
    public static testMethod void upsertSRProductsTest() {
        //Protein_SampleRequestController.SRProductWrapperOfASample prodWrapper = new Protein_SampleRequestController.SRProductWrapperOfASample();
        Account acc = Protein_TestDataFactory.createAccountRecord('Test Account', 'commercial Account', 'retail');
        System.assertEquals('Test Account' , acc.Name);
        //Product2 Prd2 = Protein_TestDataFactory.createProduct('test Product');
        SampleRequest__c sReq = Protein_TestDataFactory.SampleRequestRec(acc.Id, 'salt', 'competitive Cutting',  'draft', System.today(), System.today()+30,'foodservice', 'mahesh', 'test@gmail.com', 'no');
        SampleRequestProduct__c sRProd = Protein_TestDataFactory.sampleRequestPrd(SReq.Id,'prodDesc', 'productCode', 12);
        SampleRequestProduct__c sRProd1 = Protein_TestDataFactory.sampleRequestPrd(SReq.Id,'prodDesc', 'productCode', 12);
        List<Protein_SampleRequestProductController.SRProductWrapperOfASample> lstSRPWrapper = Protein_SampleRequestProductController.getSampleRequestProductsOfASample(sReq.Id);
        lstSRPWrapper[0].isNew = true;
        lstSRPWrapper[1].isNew = false;
        Protein_SampleRequestProductController.upsertSRProducts(sReq.id, JSON.serialize(lstSRPWrapper), 'salt');
    }
    
    public static testMethod void sendSampleRequestTest() {
        Account acc = Protein_TestDataFactory.createAccountRecord('Test Account', 'Commercial Account', 'Retail');
        System.assertEquals('Test Account' , acc.Name);
        SampleRequest__c sRReq1 = Protein_TestDataFactory.SampleRequestRec(acc.Id, 'salt', 'competitive Cutting', 'draft', System.today(), System.today()+30,'foodservice', 'mahesh', 'test@gmail.com', 'yes');
        Response getSampleRequestWrapperList1 = Protein_SampleRequestController.getSampleRequestWrapperList(sRReq1.id);
        List<Protein_SampleRequestController.sampleRequestWrapper> wrapList1 = (List<Protein_SampleRequestController.sampleRequestWrapper>)getSampleRequestWrapperList1.data;
        Protein_SampleRequestController.sendSampleRequest(sRReq1.id, JSON.serialize(wrapList1[0]), 'TEST');
        
        SampleRequest__c sRReq2 = Protein_TestDataFactory.SampleRequestRec(acc.Id, 'salt', 'competitive Cutting', 'draft', System.today(), System.today()+30,'retail', 'mahesh', null, 'no');
        Response getSampleRequestWrapperList2 = Protein_SampleRequestController.getSampleRequestWrapperList(sRReq2.id);
        List<Protein_SampleRequestController.sampleRequestWrapper> wrapList2 = (List<Protein_SampleRequestController.sampleRequestWrapper>)getSampleRequestWrapperList2.data;
        Protein_SampleRequestController.sendSampleRequest(sRReq2.id, JSON.serialize(wrapList2[0]), 'TEST');
        Protein_SampleRequestController.populateCFNASampleRequestFormData(sRReq2.id);
        
        SampleRequest__c sRReq3 = Protein_TestDataFactory.SampleRequestRec(acc.Id, 'salt', 'competitive Cutting', 'draft', System.today(), System.today()+30,'ingredient', 'mahesh', null, 'no');
        Response getSampleRequestWrapperList3 = Protein_SampleRequestController.getSampleRequestWrapperList(sRReq3.id);
        List<Protein_SampleRequestController.sampleRequestWrapper> wrapList3 = (List<Protein_SampleRequestController.sampleRequestWrapper>)getSampleRequestWrapperList3.data;
        Protein_SampleRequestController.sendSampleRequest(sRReq3.id, JSON.serialize(wrapList3[0]), 'TEST');
        Protein_SampleRequestController.populateCFNASampleRequestFormData(sRReq3.id);
    }
    
}