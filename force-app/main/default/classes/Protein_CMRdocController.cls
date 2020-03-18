/**
Class Name: Protein_CMRdocController
Description: This class works as an extention controller for 'Protein_CMRTemplate' vf page.
			 It is used to fetch the Customer Meeting Report details and its Open tasks, 
			 format them wherever required and is available for the above vf page.
Developer: Sri Harshitha Bandi
CreatedDate: 18/11/2019
**/
public with sharing class Protein_CMRdocController {
    Id cmrId;
    public string meetingDate {get;set;}
    public List<String> lstCustAttendees {get;set;}
    public List<taskWrapper> lstTaskWrappers {get;set;}
    
    public Protein_CMRdocController(ApexPages.StandardController controller) {
        
        cmrId = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
        fetchCMRDetails(cmrId);
    }
    
/**
Method Name: fetchCMRDetails
Description: This method is used to fetch the Customer Meeting Report details, 
			 format them wherever required and is available for the vf page.
Developer: Sri Harshitha Bandi
CreatedDate: 18/11/2019
**/
    public void fetchCMRDetails(Id cmrId) {
        System.debug('CMR Id: ' +cmrId);
        //Query the data of the required fields of CMR
        if(Schema.sObjectType.CustomerMeetingReport__c.isAccessible()) {
            CustomerMeetingReport__c cmr = [SELECT Id, Name, Account__c, Agenda__c, Customer_Attendees__c, Descriptive_Name__c, 
                                            Key_Topics_Discussed__c, MeetingDate__c, Next_Steps__c FROM CustomerMeetingReport__c
                                            WHERE Id=:cmrId LIMIT 1];
            if(cmr.MeetingDate__c != null){
                meetingDate = cmr.MeetingDate__c.format(); //Formatting tha Date to mm/dd/yyyy format.
            }
            if(cmr.Customer_Attendees__c != null){
                lstCustAttendees = cmr.Customer_Attendees__c.split(','); //Split the attendees from string to a list.
            }
            fetchAllOpenTasks(cmrId);
            System.debug('lstTaskWrappers: ' +lstTaskWrappers);
        }
    }
    
    public class taskWrapper{
        public Task tsk{get;set;}
        public string dueDate{get;set;}
    }
    
/**
Method Name: fetchAllOpenTasks
Description: This method is used to fetch all the Open tasks of the Customer Meeting Report, 
			 format the ActivityDate and wrap it in the 'taskWrapper' wrapper.
Developer: Sri Harshitha Bandi
CreatedDate: 26/11/2019
**/
    public void fetchAllOpenTasks(Id accId) {
        lstTaskWrappers = new List<taskWrapper>();
        if(Schema.sObjectType.Task.isAccessible()) {
            List<task> lstOpenTasks = [SELECT Id, Owner.Name,ownerId, ActivityDate, Subject FROM Task WHERE Status='Open' AND WhatId=:accId];
            System.debug('lstOpenTasks: ' +lstOpenTasks);
            if(!lstOpenTasks.isEmpty()) {
                for(Task tsk : lstOpenTasks){
                    taskWrapper tskWrp = new taskWrapper();
                    tskWrp.tsk = tsk;
                    if(tsk.ActivityDate != null) {
                        tskWrp.dueDate = tsk.ActivityDate.format();
                    }
                    System.debug('tskWrp: '+tskWrp);
                    lstTaskWrappers.add(tskWrp);
                }
            }
        }
    }
}