/**
@Author Cognizant
@name CPG_CustomerMeetingReportTrigger
@CreateDate 04-02-2018
@Description Trigger for Customer Meeting Report object
@Modifiedby 
@ModifiedDate 
*/ 
trigger CPG_CustomerMeetinReportTrigger on CustomerMeetingReport__c (after insert,before insert) {
    if(Trigger.isInsert && Trigger.isAfter){
        set<id> setAccIds = new set<id>();
        for(CustomerMeetingReport__c cmr:Trigger.New){
            if(cmr.account__c!=null){
                setAccIds.add(cmr.account__c);  
            }      
        }
        if(!setAccIds.isEmpty()){
            CPG_AccountChildSharingUtil.shareNewCustomerMeetingReport(setAccIds);
        }
    }
    
    if(Trigger.isBefore && Trigger.isInsert){
         for(CustomerMeetingReport__c customerMeetingReport : Trigger.New){
            if(customerMeetingReport.Descriptive_Name__c== null){
                customerMeetingReport.Descriptive_Name__c =customerMeetingReport.Name;
                
            }
            
        }
    }

}