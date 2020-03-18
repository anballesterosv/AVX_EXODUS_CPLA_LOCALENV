trigger Protein_CustomerMeetingReportOppTrigger on CustomerMeetingReportOpp__c (after insert, after update, after delete) {
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        Protein_CustMtgReportOppTriggerHandler.updateNextStepsPresenceCheckboxInOppty(Trigger.New);
    }
    if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isDelete)) {
        Protein_CustMtgReportOppTriggerHandler.updateNextStepsPresenceCheckboxInOppty(Trigger.Old);
    }

}