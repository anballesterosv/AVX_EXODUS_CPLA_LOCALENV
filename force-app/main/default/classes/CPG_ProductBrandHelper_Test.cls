@isTest
private class CPG_ProductBrandHelper_Test{
static testMethod void syncProductBrandObject(){
//creating test Account/Opportunity
list<Account> acc=CPG_TestFactory_Util.createTestAccounts(1); 
            
list<opportunity> opplist=CPG_TestFactory_Util.createTestOpportunity(1,acc);
system.assertEquals(opplist[0].Volume__c, 100);
//Insert Product Group for the Opportunity
Product_Group__c pg=new Product_Group__c(opportunity__c=opplist[0].Id, Volume__c=1000);
insert pg;
list<Product_Group__c> lstProdGrp = new list<Product_Group__c>();
lstProdGrp.add(pg);
CPG_ProductBrandHelper.syncproductGroup(lstProdGrp);
set<string> setProdBrandId =new set<string>();
for(product_brand__c pb:[select product_brand_Id__c from product_brand__c limit 1]){
setProdBrandId.add(pb.id);
}
CPG_ProductBrandHelper.delProductBrand(setProdBrandId);

delete pg;


//Add Opportunity products for the Opportunity            
list<OpportunityLineItem> oltlist=CPG_TestFactory_Util.createTestOpportunityLineItem(2,opplist);   
delete oltlist;
   
}
}