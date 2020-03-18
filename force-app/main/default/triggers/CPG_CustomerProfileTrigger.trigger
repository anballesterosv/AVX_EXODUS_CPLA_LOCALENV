/**
@Author Vaishali Thite
@name CPG_CustomerProfileTrigger
@CreateDate Nov 14, 2017
@Description CustomerProfile apex sharing based on account teammeber
@reference CustomerProfile__c
@Modifiedby 
@ModifiedDate 
*/ 
trigger CPG_CustomerProfileTrigger on CustomerProfile__c (after insert, after update, after delete) {

    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        CPG_CustomerProfileTriggerHelper.DefineSharingModelforCustomerProfile(Trigger.New, Trigger.NewMap);
    }
}