/**
 test class to cover functionality of class : AccountPlanCloneButtonClass
 */
@isTest
private class AccountPlanCloneButtonClass_Test {
	private AccountPlanCloneButtonClass_Test(){}
    static testMethod void myUnitTest() {
        AccountPlan__c accPlan = new AccountPlan__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(accPlan);
        AccountPlanCloneButtonClass accPlanCont = new AccountPlanCloneButtonClass(sc);
        PageReference pgf = Page.AccountPlanCloneButtonLandingPage;
        Test.setCurrentPage(pgf);
        
        //accPlanCont.myFlow = new flow.interview.AccountPlanRecordClone(new Map<String, Object>());
        //accPlanCont.myFlow.start();
        accPlanCont.getNewAbsenceId();
        
    }
}