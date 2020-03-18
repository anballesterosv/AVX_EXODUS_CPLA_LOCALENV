/**
 Test class to cover functionality of class: AccountPlanPDFGenerate_Extension
 */
@isTest
private class AccountPlanPDFGenerate_Extension_Test {

	private AccountPlanPDFGenerate_Extension_Test(){}
    static testMethod void pdfGenerationTest() {
        
        //insert test data
        Map<String,Schema.RecordTypeInfo> recordTypeMap = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Account acc = new Account();
        acc.Name = 'TestAcc';
        acc.BillingCity = 'TestBillingCity';
        acc.BillingState = 'Iowa';
        acc.BillingStreet = 'TestBillingStreet';
        acc.BillingPostalCode = 'TestBilling';
        acc.ShippingCity = 'TestShippingCity';
        acc.ShippingState = 'Iowa';
        acc.ShippingStreet = 'TestShippingStreet';
        acc.ShippingPostalCode = 'TestShipping';
        acc.Market_Channel__c='Retail Channel';
        acc.RecordTypeId= recordTypeMap.get('Global Account').getRecordTypeId();
        acc.Is_Universal__c = TRUE;
        insert(acc);
        
        Account acc1 = new Account();
        acc1.Name = 'TestAcc';
        acc1.BillingCity = 'TestBillingCity';
        acc1.BillingState = 'Iowa';
        acc1.BillingStreet = 'TestBillingStreet';
        acc1.BillingPostalCode = 'TestBilling';
        acc1.ShippingCity = 'TestShippingCity';
        acc1.ShippingState = 'Iowa';
        acc1.ShippingStreet = 'TestShippingStreet';
        acc1.ShippingPostalCode = 'TestShipping';
        acc1.Market_Channel__c='Retail Channel';
        acc1.RecordTypeId= recordTypeMap.get('Sold To').getRecordTypeId();
        acc1.Is_Universal__c = TRUE;
        insert(acc1);
        
        Opportunity opp = new Opportunity();
        opp.Name='Test'; 
        opp.NextStep='testNextStep';                                   
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
                 
        
        CustomerProfile__c cProfile = new CustomerProfile__c();
        cProfile.Account__c = acc.Id;
        insert cProfile;
        
        AccountPlan__c accPlan = new AccountPlan__c();
        accPlan.Account__c = acc1.id;
        accPlan.Business2__c = bDetails.id;
        accPlan.Customer_Profile__c = cProfile.id;
        accPlan.Plan_Year__c = '2017 Fiscal Year';
        insert accPlan;
        
        Project__c project = new Project__c();
        project.Account__c = acc.id;
        project.AccountPlan__c = accPlan.id;
        project.Business__c = bUnit.id;
        project.Opportunity__c = opp.id;
        insert project;
        
        AccountPlanDetail__c accPlanDetail = new AccountPlanDetail__c();
        accPlanDetail.Account_Plan__c = accPlan.id;
        accPlanDetail.Customer_Profile__c = cProfile.id;
        accPlanDetail.Project__c = project.id;
        insert accPlanDetail;
        
        //test execution begin
        Test.StartTest();
        
        //set standard conrtoller for Account_Plan__c	
        ApexPages.StandardController sc = new ApexPages.StandardController(accPlan);
        AccountPlanPDFGenerate_Extension accPlanExtController = new AccountPlanPDFGenerate_Extension(sc);
        pageReference pgf = Page.AccountPlanPDFGenerate;
        Test.SetCurrentPage(pgf);
        accPlanExtController.getRelatedObjects(accPlan);
        
        
        //test coverage for class AccountTeamMemberObj
        
        AccountTeamMemberObj accTeamMem = new AccountTeamMemberObj();
        accTeamMem.UserId = userInfo.getUserId();
        accTeamMem.AccountId = acc.id;
        accTeamMem.Name = 'test';
        accTeamMem.Title ='test';
        accTeamMem.TeamRole = 'test';
        accTeamMem.Email ='tt.test@test.com';
        
        
        //test coverage for class checkRecursive
        checkRecursive.run = true;
        checkRecursive.runOnce();
        
        system.assertNotEquals(checkRecursive.run,true);
        
        checkRecursive.run = false;
        checkRecursive.runOnce();
        system.assertEquals(checkRecursive.run,false);
        //test coverage for class CreateNewAccountPlan
        //CreateNewAccountPlan newAccPlanController = new CreateNewAccountPlan(sc);
        
        Test.StopTest();
        
        
        
    }
}