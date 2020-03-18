/**
Class Name: CPG_ProductTriggerHelper_Test
Created Date: Jan-24-2018
Created By: Cognizant
This class is  test class for Product Trigger helper class: CPG_ProductTriggerHelper.
**/
@isTest
private class CPG_ProductTriggerHelper_Test{
static testmethod void testProductCollectionAssignment(){
    list<CPQCollectionMap__c> lstCollectionMap = new list<CPQCollectionMap__c>();
    lstCollectionMap.add(new CPQCollectionMap__c(Name='Test Collection-01', CPQCollection__c='colBeef_BB_Muscle_Gooseneck', LEGACY_BUSINESS__c = 'Boxed Beef', PRODUCT_HIER_1__c='', PRODUCT_HIER_2__c='', PRODUCT_HIER_3__c='Muscle', PRODUCT_HIER_4__c='GN', PRODUCT_HIER_5__c=''));
    insert lstCollectionMap;
             
    Product2 prd1 = new Product2 (Name='Test Protein Product',Description='Test Protein Product',productCode = 'CPGprotein', isActive = true,Business__c='Commercial Excellence NA',Product_Deployment__c='Placeholder');
    insert prd1;
    product2 ProdCollTest =[select CPQCollection__c from product2 where id=:prd1.id limit 1];
    system.assert(ProdCollTest.CPQCollection__c==null, 'Product Colletion not assigned correctly!');
    
    //Update Product Attributes to lookup Product Collection from COllection setting
    
    prd1.LEGACY_BUSINESS__c = 'Boxed Beef';
    prd1.PRODUCT_HIER_1__c='';
    prd1.PRODUCT_HIER_2__c='';
    prd1.PRODUCT_HIER_3__c='Muscle';
    prd1.PRODUCT_HIER_4__c='GN';
    prd1.PRODUCT_HIER_5__c='';
    update prd1;
    product2 ProdCollTestUpdated =[select CPQCollection__c from product2 where id=:prd1.id limit 1];
    system.assert(ProdCollTestUpdated.CPQCollection__c=='colBeef_BB_Muscle_Gooseneck', 'Product Colletion not assigned correctly!');
    
}

}