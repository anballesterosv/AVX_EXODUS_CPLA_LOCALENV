/**
 Test class to cover functionality of class: ProjectProductHandler
 */
@isTest
private class ProjectProductHandler_Test {

    static testMethod void projectProductHandlerTest() {
       
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
        acc.RecordTypeId= recordTypeMap.get('Global Account').getRecordTypeId();
        acc.Market_Channel__c='Retail Channel';
        insert(acc);
        
        Account acc1 = new Account();
        acc1.Name = 'Test';
        acc1.BillingCity = 'Test';
        acc1.BillingState = 'Iowa';
        acc1.BillingStreet = 'Test';
        acc1.BillingPostalCode = 'Test';
        acc1.ShippingCity = 'Test';
        acc1.ShippingState = 'Iowa';
        acc1.ShippingStreet = 'Test';
        acc1.ShippingPostalCode = 'Test';
        acc1.RecordTypeId= recordTypeMap.get('Sold To').getRecordTypeId();
        acc1.Is_Universal__c = TRUE;
        acc1.Market_Channel__c='Retail Channel';
        insert(acc1);
        
        Opportunity opp = new Opportunity();
        opp.Name='Test'; 
        opp.NextStep='test';                                   
        opp.CloseDate = System.today();                                    
        opp.AccountId=acc.id; 
        opp.StageName='Closed Won - One Time'; 
        opp.Probability=100;
        insert(opp);
        
        Business__c BUnit = new Business__c();
        BUnit.Name = 'Teat';
        BUnit.BusinessUnitAlias__c = 'GTM Corp Accts';
        BUnit.CargillEnterprise__c = 'FoodIngredientsBioIndustrialFIBI';
        BUnit.CargillGroup__c = 'GoToMarket (GTM)';
        insert(BUnit);
        
        BusinessDetail__c BDetails = new BusinessDetail__c();
        BDetails.Account__c = acc.Id;
        BDetails.BusinessUnit__c = BUnit.Id;
        BDetails.Status__c = 'Active';
        insert(BDetails);
        
				
		Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true,Business__c='Commercial Excellence NA',Product_Deployment__c='Placeholder');
		insert prd1;
		
		
		PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=Test.getStandardPricebookId(),UnitPrice=50, isActive=true);
		insert pbe1;
		
				
		OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200);
		insert lineItem1;
                 
        
        CustomerProfile__c cProfile = new CustomerProfile__c();
        cProfile.Account__c = acc.Id;
        insert cProfile;
        
        AccountPlan__c accPlan = new AccountPlan__c();
        accPlan.Account__c = acc1.id;
        accPlan.Business2__c = BDetails.id;
        accPlan.Customer_Profile__c = cProfile.id;
        accPlan.Plan_Year__c = '2017 Fiscal Year';
        insert accPlan;
        
        Project__c project = new Project__c();
        project.Account__c = acc.id;
        project.AccountPlan__c = accPlan.id;
        project.Business__c = BUnit.id;
        project.Opportunity__c = opp.id;
        insert project;
        
        ProjectProduct__c projProduct = new ProjectProduct__c();
        projProduct.Project__c = project.id;
        projProduct.Product__c = prd1.id;
        projProduct.Category__c = 'Bakery';
        //test execution begin
        Test.StartTest();
        //test for before insert trigger method
        insert projProduct;
        
        system.assertEquals(projProduct.Category__c,'Bakery');
        
        projProduct.Category__c = 'Beverage';
        update projProduct;
        
        system.assertEquals(projProduct.Category__c,'Beverage');
        
        Test.StopTest();
        
        
    }
}