/**
 Test class to cover functionality of class: CreateNewAccountPlan
 */
@isTest
private class CreateNewAccountPlanTest {
    private CreateNewAccountPlanTest(){}
    
    static testMethod void myUnitTest() {
        Test.StartTest();
        AccountPlan__c newAccPlan=new AccountPlan__c();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(newAccPlan);
        CreateNewAccountPlan AccPlan = new CreateNewAccountPlan(sc);
        Test.StopTest();
    }
 }