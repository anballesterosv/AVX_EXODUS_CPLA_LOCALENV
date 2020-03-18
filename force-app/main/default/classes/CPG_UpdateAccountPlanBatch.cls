/**
@Author Vaishali Thite
@name CPG_UpdateAccountPlanBatch 
@CreateDate Sept 19, 2017
@Description Update AccountPlan sharing based on Account Teammember
@Version <1.0>
@reference 
@Modifiedby :  
@ModifiedDate: 
*/ 

global class CPG_UpdateAccountPlanBatch implements Database.Batchable<sObject>,Database.Stateful {
    String query;
    global CPG_UpdateAccountPlanBatch(){
    query  = 'Select Id,Account__c from AccountPlan__c';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
      return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<AccountPlan__c> lstAccPlan){
        
        CPG_AccountPlanUtil.DefineSharingModelforAccPlan(lstAccPlan);
       
    }    
    /**
    * @author          Vaishali Thite
    * @version         1.0
    * @date            Sept 19,2017
    * @description     finish is global method used to send email for completion status.
    * @param           Database.BatchableContext BC This is the first paramter to execute method
    * @return          void
    */  
    global void finish(Database.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, 
                            Status, 
                            NumberOfErrors, 
                            JobItemsProcessed,
                            TotalJobItems, 
                            CreatedBy.Email
                        FROM 
                            AsyncApexJob 
                        WHERE 
                            Id = :BC.getJobId()];                         
       if(a.Status == 'Failed'||Test.isRunningTest()) {
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           String[] toAddresses = new String[] {a.CreatedBy.Email};
           mail.setToAddresses(toAddresses);
           mail.setSubject('Orgnization Name:'+UserInfo.getOrganizationName()+' Orgnization Id :'+UserInfo.getOrganizationId()+' CPG_UpdateAccountPlanBatch batch Status : ' + a.Status);
           
           mail.setPlainTextBody('CPG_UpdateAccountPlanBatch batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }  
    }
   
}