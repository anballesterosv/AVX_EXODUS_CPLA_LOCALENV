trigger AVX_TelesalesPlan_trigger on TelesalesPlan__c (before insert, before update, before delete, after insert, after update) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert){
            AVX_TelesalesTriggerHelper_cls.validateTelesalesPlanActiveInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            AVX_TelesalesTriggerHelper_cls.validateTelesalesPlanUpdate(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            AVX_TelesalesTriggerHelper_cls.deleteRelatedDetails(Trigger.oldMap);
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            AVX_TelesalesTriggerHelper_cls.createTelesalesTasks(Trigger.oldMap, Trigger.newMap);
            AVX_TelesalesTriggerHelper_cls.reassignTasks(Trigger.oldMap, Trigger.newMap);
        }
    }
}