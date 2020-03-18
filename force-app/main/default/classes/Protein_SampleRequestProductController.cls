public with sharing class Protein_SampleRequestProductController {
    private final static String SUCCESS='Success';
    private final static String FAILED='Failure';
    //private final static String ERROR_MSG='Unknown Error';
    
        
    // ***************** Code written by Harshitha ****************************
    @AuraEnabled
    public static List <sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select Id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        List <sObject> lstOfRecords = Database.query(String.escapeSingleQuotes(sQuery));
        
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
        SampleRequest__c srData;
        if (SampleRequest__c.sObjectType.getDescribe().isAccessible()){
        srData = [SELECT Id, CFNA_Business_Unit__c, RecordTypeId, RecordType.DeveloperName FROM SampleRequest__c WHERE Id =:sampleId LIMIT 1];
        }
        return srData;
    }
    
    @AuraEnabled
    public static List<SRProductWrapperOfASample> getSampleRequestProductsOfASample(Id sampleId) {
        List<SRProductWrapperOfASample> lstProductWrapper = new List<SRProductWrapperOfASample>();
        List<SampleRequestProduct__c> lstProducts = new List<SampleRequestProduct__c>();
        if (SampleRequestProduct__c.sObjectType.getDescribe().isAccessible()){
        lstProducts = [SELECT Id, Name, Product__c, CFNA_Product_Desc__c, Product_Description__c, Product_Cost__c, 
                                                     Quantity__c, SampleRequest__c, Sample_Request_Fulfillment__c, Sequence_Number__c, 
                                                     CFNA_Type__c, Shipped_Weight__c, CFNA_Other_Type__c,  
                                                     Julian_Date__c, Fulfillment_Status__c, Fulfillment_Plant__c,Distributor_Code__c, 
                                                     Product_Code__c, CFNA_Business_Unit__c, Sample_Request_Name__c, Product__r.Name, recordType.DeveloperName, 
                                                     SampleRequest__r.recordType.DeveloperName, SampleRequest__r.CFNA_Business_Unit__c FROM SampleRequestProduct__c 
                                                     WHERE SampleRequest__c=:sampleId ORDER BY Name DESC];
        }
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
        
    } 
    /* --------------------------- Dependent picklist methods ends here -------------------------------*/
    
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
    // This method is called from Protein_SampleRequestController class
    public static PageReference validatePageRef(SampleRequest__c sampleRequest,PageReference pr)
    {
        if(sampleRequest.Sales_Channel__c == 'Retail'){
            pr = new PageReference('/resource/Retail_Ingredient_Sample_Request_Form');
        }else if(sampleRequest.Sales_Channel__c == 'Ingredient'){
            pr = new PageReference('/resource/Protein_Ingredient_Sample_Request_Form');
        }
        return pr;
    }
    
}