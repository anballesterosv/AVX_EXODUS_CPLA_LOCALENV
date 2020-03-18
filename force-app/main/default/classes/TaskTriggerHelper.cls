/*********************************************************************
Author: sanhita.hegde(sanhita.hegde@accenture.com)
class:TaskHelper
Description: Helps "MastertTask" trigger
************************************************************************/
public with sharing class TaskTriggerHelper {
    Private List<Task> newTaskList = new List<Task>();
    /*********************************************************************
Author: sanhita.hegde(sanhita.hegde@accenture.com)
class:TaskHelper
Description: constructor
************************************************************************/
    public TaskTriggerHelper( List<Task> newTriggerList){
        newTaskList = newTriggerList ;
        
    }
    public void scheduleTask(){
        List<Task> lstNewTasks = new List<Task>();
        for(Task t : newTaskList) {
            if (t.TypeTask__c=='WorkPlan' || t.TypeTask__c=='ContingencyPlan'){
                if(t.RescheduledDate__c!=null && t.ActivityDate!=null && t.RescheduledTime__c!=null && t.TimeToCall__c!=null){
                    if(t.RescheduledDate__c==t.ActivityDate && t.RescheduledTime__c != t.TimeToCall__c ){//same day
                        t.Status = 'CallBack';
                        t.TimeToCall__c = t.RescheduledTime__c ;
                    } else {//diferent dat
                        t.Status = 'Completed';
                        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
                        String finalUrl = sfdcBaseURL + '/' + t.Id;
                        Task newTask = new Task (
                            WhatId = t.WhatId,
                            WhoId = t.WhoId,
                            OwnerId = t.OwnerId,
                            Status = 'Open',
                            TelesalesPlan__c = t.TelesalesPlan__c,
                            Priority = t.Priority,
                            TypeTask__c = t.TypeTask__c,
                            ActivityDate = t.RescheduledDate__c,
                            ShipTo__c = t.ShipTo__c,
                            CreditLimit__c = t.CreditLimit__c,
                            ExtraInformation__c = t.ExtraInformation__c,
                            CurrencyIsoCode = t.CurrencyIsoCode,
                            Subject = t.Subject,
                            TimeToCall__c = t.RescheduledTime__c,
                            TelesalesPlanDetail__c = t.TelesalesPlanDetail__c,
                            RescheduledTask__c = true,
                            LinkSourceTask__c=finalUrl
                        );
                        lstNewTasks.add(newTask);
                    }
                }
            }
        }
        if(!lstNewTasks.isEmpty()){
            insert lstNewTasks;
        }
    }
    /*****************************************************************************************************************************
Author:sanhita.hegde
Description: Populate the Business__c  field on Task by cargill_Business_Unit__c  from Assigned user record.
method name : populateBisiness()
*********************************************************************************************************************************/
    public void populateBusiness(){
        try{
            List<Id> taskOwnerId = new List<Id>();
            For(Task t:newTaskList){
                taskOwnerId.add(t.OwnerId);
            }
            Map<Id,String> userBusiness = new Map<Id,String>();
            //get the cargill_Business_Unit__c from Assigned User 
            for(User u:[select Id,cargill_Business_Unit__c from User where Id IN:taskOwnerId LIMIT 10000]){
                userBusiness.put(u.Id,u.cargill_Business_Unit__c);
            }
            //get the Id of Business record so that we can assign it to look up field.
            Map<String,Id> businessUnitMap = new Map<String,Id>();
            for(Business__c bUnit:[select Id,Name from Business__c where Name IN:userBusiness.Values() LIMIT 10000]){
                businessUnitMap.put(bUnit.Name,bUnit.Id);
            }
            For(Task t:newTaskList){
                if(t.Business__c == null){
                    t.Business__c = businessUnitMap.get(userBusiness.get(t.OwnerId));
                }
            }
        }
        catch(Exception e){
            Throw e;
        }
    }
    //Method to populate related Open tasks on Customer Meeting record
    public static void updateCustMeetingTasks(set<id> setMeetingTasks){
        map<id,list<string>> mapCMRtasks = new map<id,list<string>>();
        map<id,CustomerMeetingReport__c> mapCMR = new map<id,CustomerMeetingReport__c>();
        for(task iTask:[select id,whatId,who.Name,owner.Name,subject,ActivityDate   from task where whatid in :setMeetingTasks and status='Open'order by ActivityDate ASC]){
            if(mapCMRtasks.isEmpty() || (!mapCMRtasks.isEmpty() && !mapCMRtasks.containsKey(iTask.whatId))){
                list<string> temp = new list<string>();
                string tempTask = iTask.subject+', Assigned To: '+ iTask.owner.Name+' Due Date:'+iTask.ActivityDate;
                temp.add(tempTask );
                mapCMRtasks.put(iTask.whatid, temp);
            }
            else{
               string tempTask = iTask.subject+', Assigned To: '+ iTask.owner.Name+' Due Date:'+iTask.ActivityDate;
               mapCMRtasks.get(iTask.whatid).add(tempTask); 
            }
        }
        
        for(id CMRid:setMeetingTasks){
            CustomerMeetingReport__c iCMR = new CustomerMeetingreport__c();
            iCMR.id = CMRid;
            iCMR.related_task_1__c=null;
            iCMR.related_task_2__c=null;
            iCMR.related_task_3__c=null;
            iCMR.related_task_4__c=null;
            iCMR.related_task_5__c=null;
            iCMR.related_task_6__c=null;
            iCMR.related_task_7__c=null;
            iCMR.related_task_8__c=null;
            iCMR.related_task_9__c=null;
            iCMR.related_task_10__c=null;
            mapCMR.put(CMRid, iCMR);
        }
        if(!mapCMRtasks.isEmpty()){
            for(id CMRId:mapCMR.KeySet()){
                for(integer i=1; i<=10 && i<=mapCMRtasks.get(CMRId).size(); i++){
                    string iField = 'related_task_'+i+'__c';
                    mapCMR.get(CMRid).put(iField,mapCMRtasks.get(CMRId)[i-1]);    
                }
            }
        }
        if(!mapCMR.isEmpty()){
            update mapCMR.values();
        }
    }
}