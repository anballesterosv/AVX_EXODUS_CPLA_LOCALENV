/**
@Author Cognizant
@name CPG_OpportunityProductTrigger
@CreateDate Sept 1, 2017
@Description Opportunity Line Item trigger to calculate business values
@Version <1.0>
@reference OpportunityLineItem
@Modifiedby Vaishali
@ModifiedDate Sept 4, 2017
*/ 
trigger CPG_OpportunityProductTrigger on OpportunityLineItem (before insert, before update, after insert, after update, after delete, after undelete) {
    If(Trigger.isAfter ){
        if(trigger.isInsert){
            CPG_OpportunityProductTriggerHelper.beforeInsertOpportunityProduct(Trigger.New);  
            //CPG_OpportunityProductTriggerHelper.rollupTrigger(Trigger.New);
            CPG_ProductBrandHelper.syncOppProduct(Trigger.New);
        }    
        else if(trigger.isUpdate || trigger.isUnDelete){
            //CPG_OpportunityProductTriggerHelper.rollupTrigger(Trigger.New);
            CPG_ProductBrandHelper.syncOppProduct(Trigger.New);
        }
        else if(trigger.isdelete){
            //CPG_OpportunityProductTriggerHelper.rollupTrigger(Trigger.old);
             //Sync deleted Product Groups with Product Brand staging object
            set<string> setProdId = new set<string>();
            for(OpportunityLineItem prod :Trigger.old){
                setProdId.add(prod.id);
            }
            CPG_ProductBrandHelper.delProductBrand(setProdId);
        }        
    }
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        CPG_OpportunityProductTriggerHelper.updateVolumeforCases(Trigger.new);
    }
    
}