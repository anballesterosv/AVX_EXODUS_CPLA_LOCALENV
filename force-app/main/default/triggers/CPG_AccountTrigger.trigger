/**
@Author Vaishali Thite
@name CPG_AccountTrigger
@CreateDate Nov 20, 2017
@Description Account apex sharing based on account teammeber
@reference Account
@Modifiedby 
@ModifiedDate 
*/ 
trigger CPG_AccountTrigger on Account (after insert, after update, after delete) {

    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        CPG_AccountTriggerHelper.DefineSharingModelforAcc(Trigger.New, Trigger.newMap);
    }
}