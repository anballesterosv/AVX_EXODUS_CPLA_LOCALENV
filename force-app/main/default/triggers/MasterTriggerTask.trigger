/*************************************************************************************************************************************************************
*@ Version:        1.0
@ Author:     Sanhit.Hegde
@ Req No:     task 39     
@ Refer Classes:  
@ Purpose:        
**************************************************************************************************************************************************************/
trigger MasterTriggerTask on Task (before Insert ,before Update, before Delete, After insert, after update, after delete) {
    
    /*********************Before Insert******************************************************/   
    If(Trigger.isBefore && Trigger.isInsert){
        beforeInsertorUpdate();
    }
   
    /*********************Before Update******************************************************/
    If(Trigger.isBefore && Trigger.isUpdate){
        beforeUpdate();
    }
    
    /********************methods to call helper class****************************************/   

    public void beforeUpdate(){
        System.debug('Enter to beforeUpdate');
        TaskTriggerHelper methodCall = new TaskTriggerHelper (Trigger.new); 
        methodCall.scheduleTask();
    }

    public void beforeInsertorUpdate(){
        TaskTriggerHelper methodCall = new TaskTriggerHelper (Trigger.new);
        methodCall.populateBusiness();
        
    }
    //Call helper method to update related Open Tasks on Customer Meeting Report
    set<id> setCustMeetingIds = new set<id>();
    if(Trigger.isInsert || Trigger.isUpdate){
        for(Task iTask: Trigger.New){
        //iTask.addError('testing debug');
            if(iTask.whatid!=null && iTask.whatid.getSObjectType().getDescribe().getName()=='CustomerMeetingReport__c'){
                setCustMeetingIds.add(iTask.whatid);
            }
        }
    }
    else if(Trigger.isDelete){
        for(Task iTask: Trigger.Old){
            if(iTask.whatid!=null && iTask.whatid.getSObjectType().getDescribe().getName()=='CustomerMeetingReport__c'){
                setCustMeetingIds.add(iTask.whatid);
            }
        }
    }    
    if(!setCustMeetingIds.isEmpty()){
        TaskTriggerHelper.updateCustMeetingTasks(setCustMeetingIds);
    }
    
}