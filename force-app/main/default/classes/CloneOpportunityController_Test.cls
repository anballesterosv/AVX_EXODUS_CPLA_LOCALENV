/**
 Test class to cover functionality of class: cloneOpportunityController
 */
@isTest
private class CloneOpportunityController_Test {
	private CloneOpportunityController_Test(){}
    static testMethod void myUnitTest() {
        
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
        acc.RecordTypeId= recordTypeMap.get('Global Account').getRecordTypeId();
        acc.Market_Channel__c='Retail Channel';
        insert(acc);
        
        Opportunity opp = new Opportunity();
        opp.Name='Test'; 
        opp.NextStep='test';                                   
        opp.CloseDate = System.today();                                    
        opp.AccountId=acc.id; 
        opp.StageName='Closed Won - One Time'; 
        opp.Probability=100;
        insert(opp);
        
        Business__c bUnit = new Business__c();
        bUnit.Name = 'Teat';
        bUnit.BusinessUnitAlias__c = 'GTM Corp Accts';
        bUnit.CargillEnterprise__c = 'FoodIngredientsBioIndustrialFIBI';
        bUnit.CargillGroup__c = 'GoToMarket (GTM)';
        insert(bUnit);
        
        BusinessDetail__c bDetails = new BusinessDetail__c();
        bDetails.Account__c = acc.Id;
        bDetails.BusinessUnit__c = bUnit.Id;
        bDetails.Status__c = 'Active';
        insert(bDetails);
        
				
		Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true,Business__c='Commercial Excellence NA',Product_Deployment__c='Placeholder');
		insert prd1;
		
		
		PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=Test.getStandardPricebookId(),UnitPrice=50, isActive=true);
		insert pbe1;
		
				
		OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200);
		insert lineItem1;
		
		Test.StartTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(opp);
			cloneOpportunityController cloneOpp = new cloneOpportunityController(sc);
			cloneOpp.opportunityId = opp.id;
			cloneOpp.Save();
			
			
		Test.StopTest();
        
    }
}