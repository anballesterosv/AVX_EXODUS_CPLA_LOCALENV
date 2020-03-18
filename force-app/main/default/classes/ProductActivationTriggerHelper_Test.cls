/**
 Test Class to cover functionality of class: ProductActivationTriggerHelper
 */
@isTest
private class ProductActivationTriggerHelper_Test {

    static testMethod void ProductActivationTriggerHelperTest() {
        //insert test data
        Map<String,Schema.RecordTypeInfo> recordTypeMap = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCity = 'Test';
        acc.BillingState = 'Iowa';
        acc.BillingStreet = 'Test';
        acc.BillingPostalCode = 'Test';
        acc.ShippingCity = 'Test';
        acc.ShippingState = 'Iowa';
        acc.ShippingStreet = 'Test';
        acc.ShippingPostalCode = 'Test';
        acc.RecordTypeId= recordTypeMap.get('Prospect').getRecordTypeId();
        acc.Market_Channel__c='Retail Channel';
        insert(acc);
        
        Opportunity opp = new Opportunity();
        opp.Name='Test'; 
        opp.NextStep='test';                                   
        opp.CloseDate = System.today();                                    
        opp.AccountId=acc.id; 
        opp.StageName='Closed Won - One Time'; 
        opp.Probability=100;
        opp.Unit_of_Measure__c = 'Pound';
        opp.Volume__c = 10;        
        insert(opp);
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true,Business__c='RETAIL',Product_Deployment__c='Placeholder');
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=Test.getStandardPricebookId(),UnitPrice=50, isActive=true);
        insert pbe1;
        
                
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200);
        insert lineItem1;
        
        Test.StartTest();
            prd1.isActive = false;
            update prd1;
            //check for isActive update status
            system.assertEquals(prd1.isActive,false);
        
        Test.StopTest();
        
    }
}