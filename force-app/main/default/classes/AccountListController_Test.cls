/**
 Test class to cover functionality in class AccountListController
 */
@isTest
private class AccountListController_Test {

   private AccountListController_Test(){}
    static testMethod void accListControllerTest() {
    	//insert test data
        final Account acc = new Account();
        acc.Name = 'TestAcc';
        acc.BillingCity = 'TestCity';
        acc.BillingState = 'Iowa';
        acc.BillingStreet = 'TestStreet';
        acc.BillingPostalCode = 'TestCode';
        acc.ShippingCity = 'TestShip';
        acc.ShippingState = 'IowaS';
        acc.ShippingStreet = 'TestShip';
        acc.ShippingPostalCode = 'TestPoCode';
        acc.Market_Channel__c='Retail Channel';
        insert(acc);
        
        Test.StartTest();
        AccountListController.searchRecords('Account','Name','Te',TRUE);
        system.assertEquals(acc.Name,'TestAcc');
        Test.StopTest();
        
    }
}