/**
Class Name: CPG_AddAccountPlanDetailController_Test
Created Date: Oct-15-2017
Created By: Cognizant
This class is  the test class for controller class- CPG_AddAccountPlanDetailController
**/
@isTest
public class CPG_AddAccountPlanDetailController_Test{
@testSetup
static void setup(){
    //creating test running user
    user u=CPG_TestFactory_Util.createTestUser('System Administrator');
    system.runAs(u){
        //create Account
        list<Account> acc=CPG_TestFactory_Util.createTestAccounts(1); 
        //Create Opportunity    
        list<opportunity> opplist=CPG_TestFactory_Util.createTestOpportunity(1,acc);
        system.assertEquals(opplist[0].Volume__c, 100);    
        //create Customer Profile
        list<CustomerProfile__c> custProf = CPG_TestFactory_Util.createTestCustomerProfiles(1,acc);
        //Create Strategic Objective
        list<StrategicObjective__c> stratObj = CPG_TestFactory_Util.createTestStrategicObjectives(1, custProf);
        //Create Account Plan
        list<AccountPlan__c> accPlan = CPG_TestFactory_Util.createTestAccountPlan(1, acc);          
    }
}
@isTest
static void testAccountPlanDetailController(){
    list<AccountPlan__c> accPlan = [select id from accountPlan__c limit 1];
    list<StrategicObjective__c> lstStrat = CPG_AddAccountPlanDetailController.getStratObjectives(accPlan[0].id);
    System.assertNotEquals(lstStrat.size(),0);
    
    list<Opportunity> lstOpp = CPG_AddAccountPlanDetailController.addAPobjectives(new list<id> {lstStrat[0].id}, accPlan[0].id);
    System.assertNotEquals(lstOpp.size(),0); 
    
    CPG_AddAccountPlanDetailController.saveAP(new list<id> {lstOpp[0].id} , accPlan[0].id, null);
}


}