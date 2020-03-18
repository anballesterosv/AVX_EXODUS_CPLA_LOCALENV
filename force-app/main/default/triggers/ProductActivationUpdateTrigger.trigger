/**
@Author - Harshavi Tanguturi
@name - ProductActivationUpdateTrigger
@CreateDate - 01-19-2017
@Description - This is a trigger to update the opportunity products based on the products
@Revision-
*/ 
trigger ProductActivationUpdateTrigger on Product2 (after update, before Insert , before Update) {
   
    if(Trigger.IsUpdate && Trigger.isAfter){
        ProductActivationTriggerHelper.retrieveProduct(Trigger.new,Trigger.oldMap);
    }
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        CPG_ProductTriggerHelper.updateProductCollection(Trigger.oldMap, Trigger.new);
    }
}