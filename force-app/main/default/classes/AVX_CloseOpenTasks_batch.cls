/**************************************************************************************************************
* Avanxo Brasil
* @author           Rodrigo Francis (rfrancis@avanxo.com)
* Project:          CPLA - EXODUS Project
* Description:      Batch used to close tasks where the ActivityDate date expires
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                      Description     
*           -----   ----------      --------------------        ---------------   
* @version   1.0    2020-03-05      Rodrigo Francis             class created 
*************************************************************************************************************/

public with sharing class AVX_CloseOpenTasks_batch implements Database.Batchable<sObject>{

   public Database.QueryLocator start(Database.BatchableContext BC){
       List<String> lstTaskType = Label.AVX_TaskType_NT.split(';');
       List<String> lstTaskStatus = Label.AVX_TaskStatus_NT.split(';');
       System.debug('lstTaskType splited: ' + lstTaskType);
       System.debug('lstTaskStatus splited: ' +lstTaskStatus); 
      
       return Database.getQueryLocator([SELECT Id FROM Task WHERE ActivityDate < :Date.today() AND TypeTask__c in: lstTaskType AND Status in: lstTaskStatus]);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('scopeSize>>>>: ' +scope.size());  
        List<Task> lstTaskScope   = (List<Task>)scope;        
        List<Task> lstTask = new List<Task>();
        for(Task objTask : lstTaskScope){
            objTask.Status = Label.AVX_CloseTaskStatus_NT;
            objTask.NotAnswerReason__c = Label.AVX_CloseTaskReason_NT;
            objTask.NotAnswerComments__c = Label.AVX_CloseTaskReasonComments;           
            lstTask.add(objTask);        
        }
         if(!lstTask.isEmpty()){        
            Database.SaveResult[] srList = Database.update(lstTask, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {                
                    System.debug('Successfully updated task. TASK ID: ' + sr.getId());
                }
                else
                    {                       
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Task fields that affected this error: ' + err.getFields());
                        }
                    }
           }
        }
    }
    
    public void finish(Database.BatchableContext BC){
         System.debug('Finish class batch AVX_CloseOpenTasks_batch.');          
    }       
}