/**
@Author Siva
@name CPG_OpportunityProductGroupTriger
@CreateDate Sept 1, 2017
@Description Product Group trigger to calculate business values
@Version <1.0>
@reference Product_Group__c
@Modifiedby Vaishali
@ModifiedDate Sept 4, 2017
*/ 
trigger CPG_OpportunityProductGroupTriger on Product_Group__c (before insert, after insert, after update, after delete, after undelete) {
   if(Trigger.isAfter){
        if(trigger.isInsert || trigger.isUpdate || trigger.isUnDelete){
            CPG_OpportunityProductGroupTriggerHelper.rollupTrigger(Trigger.New);
            CPG_ProductBrandHelper.syncproductGroup(Trigger.New);
        }
        if(trigger.isdelete){
            CPG_OpportunityProductGroupTriggerHelper.rollupTrigger(Trigger.old);
            //Sync deleted Product Groups with Product Brand staging object
            set<string> setProdId = new set<string>();
            for(Product_Group__c prod :Trigger.old){
                setProdId.add(prod.id);
            }
            CPG_ProductBrandHelper.delProductBrand(setProdId);
        }  
   }
}