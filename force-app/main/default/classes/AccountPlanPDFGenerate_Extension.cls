/**
   @Author - Rajeshwari M
   @name -  AccountPlanPDFGenerate_Extension 
   @CreateDate - 
   @Description - This Apex class is extension for VF Page AccountPlanPDFGenerate which displays AccountPlan's related objects information-
   @               1.Customer Profiles 2.Customer Team 3.Contact 4.Opportunities 5.Projects 6.Strategic Objectives
   @Revision- 1.0
*/
public with sharing class AccountPlanPDFGenerate_Extension {
    
    public AccountPlan__c record{get; set;}
    public List<AccountPlanDetail__c> apdcontact{get; set;}
    public List<AccountPlanDetail__c> apdProjects{get; set;}
    public List<AccountPlanDetail__c> apdSO{get; set;}
    public List<AccountPlanDetail__c> apdOpp{get; set;}
    public List<AccountPlan__c> accPlanCustomerProfile{get; set;}
    public Boolean isCustomProf{get; set;}
    public List<AccountTeamMember> teams{get; set;}
    public DateTime gmtDate{get; set;}
    public String estDate{get; set;}
    private final static string TIMEFORMAT = 'EEEE,MMMM dd,yyyy hh:mm:ss zzzz';
    private final static string TIMEZONE = 'America/New_York';
    
    /*
    @methodname-AccountPlanPDFGenerate_Extension
    @aurguments-controller
    @description-standard controller
    */
    public AccountPlanPDFGenerate_Extension(ApexPages.StandardController controller) {
        record=(AccountPlan__c)controller.getRecord(); 
        gmtDate = system.now();
        estDate=gmtDate.format(TIMEFORMAT,TIMEZONE);
        getRelatedObjects(record);
    }
    
    /*
    @methodname-getRelatedObjects
    @aurguments-accPlan
    @description-Fetches related data of Account Plan
    */
    public void getRelatedObjects(AccountPlan__c accPlan){
        try{
        List<AccountPlanDetail__c> accPlanDetailList = new List<AccountPlanDetail__c>();
        apdcontact = new List<AccountPlanDetail__c>();
        apdProjects= new List<AccountPlanDetail__c>();
        apdSO= new List<AccountPlanDetail__c>();
        apdOpp= new List<AccountPlanDetail__c>();
        teams=new List<AccountteamMember>();
        accPlanCustomerProfile = new List<AccountPlan__c>();
        
        
        if(accPlan.Id!=null){
        AccountPlan__c aPlan= [Select id,Account__c,
                               Customer_Profile__c,Customer_Profile__r.CustomerDescription__c,Customer_Profile__r.Brands__c,Customer_Profile__r.Business__c,Customer_Profile__r.ProductLines__c 
                               FROM AccountPlan__c WHERE id=: accPlan.Id LIMIT 1];
        
        if(aPlan.Customer_Profile__c!=null){
            accPlanCustomerProfile .add(aPlan);
        }
        
        Account acc=[Select id,(Select id,CustomerDescription__c,Brands__c,Business__c,ProductLines__c FROM Customer_Profiles__r LIMIT 1),(Select User.Name,User.Cargill_Business_Unit__c,TeamMemberRole FROM AccountTeamMembers LIMIT 10000) FROM Account WHERE id=:aPlan.Account__c LIMIT 1];
        if(acc.AccountTeamMembers!=null && !acc.AccountTeamMembers.isEmpty()){
            teams = acc.AccountTeamMembers;
        }
    
        accPlanDetailList = [Select id,Name,
                    Contact__c,Contact__r.Name,Contact__r.Title,Contact__r.Owner.Name,Contact__r.Role__c,Contact__r.ReportsTo.Name,
                    Project__c,Project__r.Name,Project__r.RecordType.Name,Project__r.Stage__c,Project__r.Phase__c,
                    Strategic_Objective__c,Strategic_Objective__r.CustomerProfile__r.Name,Strategic_Objective__r.Status__c,Strategic_Objective__r.StartDate__c,Strategic_Objective__r.EndDate__c,
                    Opportunity__c,Opportunity__r.Name,Opportunity__r.StageName,Opportunity__r.Probability,Opportunity__r.Amount,Opportunity__r.CloseDate,Opportunity__r.Description
                    FROM AccountPlanDetail__c WHERE Account_Plan__c =: accPlan.Id LIMIT 10000];
                    
        
        if(!accPlanDetailList.isEmpty() && accPlanDetailList!=null){
            For(AccountPlanDetail__c accPlanDetail : accPlanDetailList){
               if(accPlanDetail.Project__c!=null){
                   apdProjects.add(accPlanDetail);
               }
               if(accPlanDetail.Strategic_Objective__c!=null){
                   apdSO.add(accPlanDetail);
               }
               if(accPlanDetail.Opportunity__c!=null){
                   apdOpp.add(accPlanDetail);
               }
               if(accPlanDetail.Contact__c!=null){
                   apdcontact.add(accPlanDetail);    
               }
               
           }
         
      
        }
    }
        }catch(Exception Ex){
            Throw Ex;
        }
 
}
}