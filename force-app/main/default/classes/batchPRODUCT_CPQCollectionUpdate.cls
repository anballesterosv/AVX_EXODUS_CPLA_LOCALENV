/**
Class Name: batchPRODUCT_CPQCollectionUpdate 
Description: This batch class is used for updating CPQ Collection value
CreatedDate: 08-28-2018
**/
global class batchPRODUCT_CPQCollectionUpdate implements Database.Batchable<sObject>,Database.Stateful {
    private static string query ='select id,legacy_business__c,PRODUCT_HIER_1__c,PRODUCT_HIER_2__c,PRODUCT_HIER_3__c,PRODUCT_HIER_3_DESC__c,PRODUCT_HIER_4__c,PRODUCT_HIER_5__c,CPQCollection__c,PRODUCT_HIER_3_Neg__c from product2';
    public list<CPQCollectionMap__c> lstProdCollection = CPQCollectionMap__c.getAll().values();
    global Database.QueryLocator start(Database.BatchableContext bc) {
      return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<product2> lstProductsNew){
        map<string, map<string,string>> mapAccTeamAccess = new map<string, map<string,string>>();
        List<product2> prdLst = new List<product2>();
        for(Product2 prod: lstProductsNew){
            
        for(CPQCollectionMap__c coll:lstProdCollection){
                    //Not using Custom setting map due to negation logic constraint
                    if(prod.legacy_business__c==coll.legacy_business__c && (coll.PRODUCT_HIER_1__c ==null || (coll.PRODUCT_HIER_1__c == prod.PRODUCT_HIER_1__c ))  && (coll.PRODUCT_HIER_2__c ==null || (coll.PRODUCT_HIER_2__c == prod.PRODUCT_HIER_2__c )) && (coll.PRODUCT_HIER_4__c ==null || (coll.PRODUCT_HIER_4__c == prod.PRODUCT_HIER_4__c ))  && (coll.PRODUCT_HIER_5__c ==null || (coll.PRODUCT_HIER_5__c == prod.PRODUCT_HIER_5__c ))){
                        if(coll.PRODUCT_HIER_3__c ==null || (coll.PRODUCT_HIER_3__c == prod.PRODUCT_HIER_3_Desc__c || (coll.PRODUCT_HIER_3__c.contains('(') && (prod.PRODUCT_HIER_3_Neg__c==null || !coll.PRODUCT_HIER_3__c.contains(prod.PRODUCT_HIER_3_Neg__c))))){
                            prod.CPQCollection__c = coll.CPQCollection__c;
                            prdLst.add(prod);
                            break;
                        }
                    }
           }
  
        }
        Database.update(prdLst);
        
    }    

    global void finish(Database.BatchableContext bc){
            
    }  
   
}