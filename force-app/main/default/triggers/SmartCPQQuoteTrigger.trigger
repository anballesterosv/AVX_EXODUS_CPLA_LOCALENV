trigger SmartCPQQuoteTrigger on CameleonCPQ__Quote__c (after insert, after update, before insert, before update,after delete, after undelete) {
  
   SmartCPQQuoteTriggerHandler handler = new SmartCPQQuoteTriggerHandler ();
    
    //Pricing Date Validation on Opportunity
     if(Trigger.isBefore && (trigger.isUpdate || trigger.isInsert)){
                CPG_OppPrQuotesTriggerHelper.rollupTrigger(Trigger.New);
     }
     if(trigger.isdelete){
         CPG_OppPrQuotesTriggerHelper.rollupTrigger(Trigger.Old);
     }
    if (Trigger.isInsert && Trigger.isBefore)
    {
    handler.handleBeforeInsert(Trigger.new);
    } else if (Trigger.isInsert && Trigger.isAfter)
    {
    	handler.handleAfterInsert(Trigger.new);
    	//Cognizant: As per new CR- Quote Price Type and Deal size considertaion for Opportunity Type*/
        CPG_OpportunityUtil.calculateOppType(Trigger.new);
    } else if (Trigger.isUpdate && Trigger.isBefore)
    {
        
    handler.handleBeforeUpdate(Trigger.new, Trigger.old);
    } else if (Trigger.isUpdate && Trigger.isAfter)
    {
    	handler.handleAfterUpdate(Trigger.new, Trigger.old);
    	//Cognizant: As per new CR- Quote Price Type and Deal size considertaion for Opportunity Type*/
        CPG_OpportunityUtil.calculateOppType(Trigger.new);
    }
  
}