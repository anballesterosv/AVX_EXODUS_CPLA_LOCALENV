trigger Protein_ProductRequestTrigger on Product_Request__c (after insert, after update, after delete, after undelete) {
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUnDelete)) {
        Protein_ProductRequestTriggerHelper.deleteAllProdGroups(Trigger.New);
    }
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isUnDelete)) {
        Protein_ProductRequestTriggerHelper.volumeRollUpMethod(Trigger.New);
    }
    if(Trigger.isAfter && Trigger.isDelete) {
        Protein_ProductRequestTriggerHelper.volumeRollUpMethod(Trigger.Old);
    }

}