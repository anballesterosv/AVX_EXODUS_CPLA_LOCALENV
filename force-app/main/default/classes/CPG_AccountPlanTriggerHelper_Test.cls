/**
@Author Siva Sankar
@name CPG_AccountPlanTriggerHelper_Test
@CreateDate Sept 15, 2017
@Description test class for CPG_AccountPlanTriggerHelper, additionally it will tace care for batch update too
@Version <1.0>
@reference CPG_AccountPlanTrigger Trigger
@Modifiedby :  Vaishali
@ModifiedDate: Sept 20, 2017
*/ 
@isTest
public class CPG_AccountPlanTriggerHelper_Test 
{
    public static testMethod void DefineSharingModel()
    {        
        
        //create account       
        list<Account> acclist=CPG_TestFactory_Util.createTestAccounts(1);
           
        //related AccountPaln__c creation for account acc        
        list<AccountPlan__c> aplist=CPG_TestFactory_Util.createTestAccountPlan(2,acclist);
        Map<id,AccountPlan__c> apMap=new Map<id,AccountPlan__c>();
        apMap.put(aplist[0].Id, aplist[0]);
        apMap.put(aplist[1].Id, aplist[1]);
        list<AccountTeamMember> atmlist=CPG_TestFactory_Util.createTestAccountTeamMember(1,acclist);
              
        test.startTest();
        CPG_AccountPlanTriggerHelper.DefineSharingModelforAccPlan(aplist, apMap);
        CPG_AccountPlanTriggerHelper.manualShareRead(aplist[0].Id,atmlist[0]);
        test.stopTest();        
            
    }
}