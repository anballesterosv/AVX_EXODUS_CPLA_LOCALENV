/**
@Author - Cognizant
@name - CPG_ProductTriggerHelper
@CreateDate - Jan-19-2018
@Description - This Trigger Helper class executes trigger logic for Products.
@Revision-
*/ 
//Using without Sharing Class in order to get Product fields which are not exposed to non-admin users
public without Sharing class CPG_ProductTriggerHelper{
//Method to update Product Collection for updated Products
public static void updateProductCollection(map<id,Product2> mapProductsOld , list<Product2> lstProductsNew){
    if(lstProductsNew!=null){
        //Get all Collection settings
        list<CPQCollectionMap__c> lstProdCollection = CPQCollectionMap__c.getAll().values();
        //Loop through eligible Products to match Collection
        for(Product2 prod:lstProductsNew){
            
        if(mapProductsOld==null || (prod.PRODUCT_HIER_1__c!= mapProductsOld.get(prod.id).PRODUCT_HIER_1__c || prod.legacy_business__c!= mapProductsOld.get(prod.id).legacy_business__c || prod.PRODUCT_HIER_2__c!= mapProductsOld.get(prod.id).PRODUCT_HIER_2__c || prod.PRODUCT_HIER_3__c!= mapProductsOld.get(prod.id).PRODUCT_HIER_3__c || prod.PRODUCT_HIER_4__c!= mapProductsOld.get(prod.id).PRODUCT_HIER_4__c || prod.PRODUCT_HIER_5__c!= mapProductsOld.get(prod.id).PRODUCT_HIER_5__c)){
                for(CPQCollectionMap__c coll:lstProdCollection){
                    //Not using Custom setting map due to negation logic constraint
                    if(prod.legacy_business__c==coll.legacy_business__c && (coll.PRODUCT_HIER_1__c ==null || (coll.PRODUCT_HIER_1__c == prod.PRODUCT_HIER_1__c ))  && (coll.PRODUCT_HIER_2__c ==null || (coll.PRODUCT_HIER_2__c == prod.PRODUCT_HIER_2__c )) && (coll.PRODUCT_HIER_4__c ==null || (coll.PRODUCT_HIER_4__c == prod.PRODUCT_HIER_4__c ))  && (coll.PRODUCT_HIER_5__c ==null || (coll.PRODUCT_HIER_5__c == prod.PRODUCT_HIER_5__c ))){
                        if(coll.PRODUCT_HIER_3__c ==null || (coll.PRODUCT_HIER_3__c == prod.PRODUCT_HIER_3__c || (coll.PRODUCT_HIER_3__c.contains('(') && (prod.PRODUCT_HIER_3_Neg__c==null || !coll.PRODUCT_HIER_3__c.contains(prod.PRODUCT_HIER_3_Neg__c))))){
                            prod.CPQCollection__c = coll.CPQCollection__c;
                            break;
                        }
                    }
                }
            }
        }
    }
}

}