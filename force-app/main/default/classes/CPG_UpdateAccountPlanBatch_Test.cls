/**
@Author Vaishali Thite
@name CPG_UpdateAccountPlanBatch_Test 
@CreateDate Sept 20, 2017
@Description test class for AccountPlan batch
@Version <1.0>
@reference :CPG_UpdateAccountPlanBatch 
@Modifiedby :  
@ModifiedDate: 
*/ 
@isTest
private class CPG_UpdateAccountPlanBatch_Test {

    Public static testMethod void AccPlansharingTest(){
        //list<Account> acclist=CPG_TestFactory_Util.createTestAccounts(1);
           
        //related AccountPaln__c creation for account acc   
        CPG_TestFactory_Util.createCustomSettingforIntProfile();
        User u=CPG_TestFactory_Util.createTestUser('System Administrator');
        System.runAs(u){ 
            list<Account> acclist1=CPG_TestFactory_Util.createCommercialAccounts(1);
            list<Account> acclist=CPG_TestFactory_Util.createTestAccounts(2);
            list<CustomerProfile__c> cplist=CPG_TestFactory_Util.createTestCustomerProfiles(1,acclist); 
            list<AccountPlan__c> aplist=CPG_TestFactory_Util.createTestAccountPlan(1,acclist1);  
            list<AccountTeamMember> atmlist=CPG_TestFactory_Util.createTestAccountTeamMember(2,acclist1); 
       
              
        test.startTest();
            CPG_UpdateAccountPlanBatch sAccPlan= new CPG_UpdateAccountPlanBatch (); 
            database.executebatch(sAccPlan);
            
        test.stopTest();
        }
    }
}