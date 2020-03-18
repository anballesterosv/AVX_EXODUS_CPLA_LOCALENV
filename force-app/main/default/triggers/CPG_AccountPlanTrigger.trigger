/**
@Author Vaishali Thite
@name CPG_AccountPlanTrigger
@CreateDate Sept 15, 2017
@Description AccountPlan apex sharing based on account teammeber
@reference AccountPlan__c
@Modifiedby 
@ModifiedDate 
*/ 
trigger CPG_AccountPlanTrigger on AccountPlan__c (after insert, after update, after delete) {

    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        CPG_AccountPlanTriggerHelper.DefineSharingModelforAccPlan(Trigger.New, Trigger.newMap);
    }
}