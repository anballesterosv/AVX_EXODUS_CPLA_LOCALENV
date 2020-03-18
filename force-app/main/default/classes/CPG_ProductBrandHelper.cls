public class CPG_ProductBrandHelper{
public static void syncproductGroup(list<Product_Group__c> lstProdGrp){
list<Product_brand__c> lstProdBrand = new list<Product_Brand__c>();
    for(Product_Group__c pg:lstProdGrp){
        lstProdBrand.add(new product_brand__c(Opportunity__c=pg.Opportunity__c, protein__c=pg.protein__c, Brand__c=pg.Brand__c, Branded__c=pg.branded__c, volume__c=pg.volume__c, Unit_of_Measure__c = pg.Unit_of_Mesure__c, Product_brand_id__c=pg.id));
    }
    if(!lstProdBrand.isEmpty()){
        upsert lstProdBrand product_brand_id__c;
    }
}

public static void syncOppProduct(list<OpportunityLineItem> lstOppProd){
list<Product_brand__c> lstProdBrand = new list<Product_Brand__c>();
    for(OpportunityLineItem prod:lstOppProd){
        lstProdBrand.add(new product_brand__c(Opportunity__c=prod.OpportunityId, protein__c=prod.protein__c, Brand__c=prod.Brand__c, Branded__c=prod.branded__c, volume__c=prod.Quantity, Unit_of_Measure__c = prod.UnitofMeasure__c, Product_brand_id__c=prod.id));
    }
    if(!lstProdBrand.isEmpty()){
        upsert lstProdBrand product_brand_id__c;
    }
}

public static void delProductBrand(set<string> setProdBrandId){
    list<Product_Brand__c> lstProdBrand = new list<Product_Brand__c>();
    if(!setProdBrandId.isEmpty()){
        lstProdBrand = [select id from product_brand__c where product_brand_id__c in :setProdBrandId];
        if(!lstProdBrand.isEmpty()){
            delete lstProdBrand;
        }
    }
}

}