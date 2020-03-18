trigger AVX_TelesalesPlanDetail_tgr on TelesalesPlanDetail__c (after insert, after update, before delete){
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            AVX_TelesalesPlanDetailTriggerHelper_cls.createTelesalesPlanDetailTask(Trigger.new);
            AVX_TelesalesPlanDetailTriggerHelper_cls.transferTasksContingencyPlan(Trigger.newMap);
        }
        if(Trigger.isUpdate){
            AVX_TelesalesPlanDetailTriggerHelper_cls.changeTaskHourPriority(Trigger.new, Trigger.oldMap);
        }
    }

    if(Trigger.isBefore){
        if(Trigger.isDelete){
            AVX_TelesalesPlanDetailTriggerHelper_cls.deleteRelatedTasks(Trigger.old);
        }
    }
}