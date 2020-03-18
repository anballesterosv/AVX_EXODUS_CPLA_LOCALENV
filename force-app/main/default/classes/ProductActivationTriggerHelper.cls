/**
@Author - Harshavi Tanguturi
@name - ProductActivationTriggerHelper
@CreateDate - 01-19-2017
@Description - This is a helper class that is used in ProductActivationUpdateTrigger
@Revision-
*/ 
public class ProductActivationTriggerHelper {
    /*@Description -  Method to get the list of products and send to furure method 
    @Author - Harshavi Tanguturi
    @date - 01-19-2017
    @param - newProductList,oldProductMap
    @Return - void */ 
    public static void retrieveProduct(List<Product2> newProductList,Map<Id,Product2> oldProductMap){
        List<String> productId = new list<String>();
        for(Product2  prod : newProductList){
            if(prod.IsActive != oldProductMap.get(prod.Id).IsActive){
                productId.add(prod.id);
            }
        }
        ProductActivationTriggerHelper.UpdateProduct(productId);
    }
    /*@Description -  furure Method to update the oppotunity products of updated product records 
    @Author - Harshavi Tanguturi
    @date - 01-19-2017
    @param - 
    @Return - void */ 
    @future
    public static void  UpdateProduct(List<String> idList){
        map<id,Product2> productMap = new  map<id,Product2>();
        List<Opportunity> opportunityListUpdate= new List<Opportunity>();
        Map<id,integer> countMap = new Map<id,integer>();
        Integer count=0;
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        List<String> priceBEList= new list<String>();
        Map<id,List<Boolean>> oppMap = new Map<id,List<Boolean>>();
        productMap  = new  map<id,Product2>([select id,IsActive from Product2 where id IN:idList LIMIT 49999]);
        for(PriceBookEntry priceBE: [select id,Product2Id from PriceBookEntry where  Product2Id IN: idList LIMIT 49999]){
            priceBEList.add(priceBE.id);
        }
       
        for(OpportunityLineItem oppLineItem : [SELECT Id,ListPrice,Name,OpportunityId,PricebookEntryId,Product2Id FROM OpportunityLineItem WHERE PricebookEntryId IN : priceBEList LIMIT 49999]){
            oppLineItem.ActiveProduct2__c = productMap.get(oppLineItem.Product2Id).IsActive;
            oppLineItemList.add(oppLineItem);
            oppMap.put(oppLineItem.OpportunityId,new List<Boolean> {oppLineItem.ActiveProduct2__c });
        }
        Database.update(oppLineItemList,false);
        for(String str:oppMap.keyset()){
            for(Boolean booln:oppMap.get(str)){
                if(booln==false){
                    count++;
                }
                countMap.put(str,count);
            }  
        }
        for(Opportunity opl : [select id,Name,InactiveProducts__c from Opportunity WHERE id IN : oppMap.keyset() LIMIT 49999]){                    
            if(!(countMap!=null&&countMap.get(opl.id)==0) && opl.InactiveProducts__c != true){
                 opl.InactiveProducts__c = true;  
                 opportunityListUpdate.add(opl);    
            }   
        }
        if(opportunityListUpdate!=null){
            Database.update(opportunityListUpdate,false);
        }
    }
}