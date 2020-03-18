/**
 Test Class to cover functionality of class:SyncAccountTeamMemberHelper
 */
@isTest
private class SyncAccountTeamMemberHelper_Test {
	
	public static AccountView__c accView;
	public static Account acc;
	public static Business__c BUnit;
	public static BusinessDetail__c BDetails;
	//create test data
	public static void createTestData()
	{
		//insert test data
        Map<String,Schema.RecordTypeInfo> recordTypeMap = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        acc = new Account();
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
        acc.ShippingStreet = 'TestShippingStreet';
        
        Opportunity opp = new Opportunity();
        opp.Name='Test'; 
        opp.NextStep='test';                                   
        opp.CloseDate = System.today();                                    
        opp.AccountId=acc.id; 
        opp.StageName='Closed Won - One Time'; 
        opp.Probability=100;
        insert(opp);
        
        BUnit = new Business__c();
        BUnit.Name = 'Teat';
        BUnit.BusinessUnitAlias__c = 'GTM Corp Accts';
        BUnit.CargillEnterprise__c = 'FoodIngredientsBioIndustrialFIBI';
        BUnit.CargillGroup__c = 'GoToMarket (GTM)';
        insert(BUnit);
        
        BDetails = new BusinessDetail__c();
        BDetails.Account__c = acc.Id;
        BDetails.BusinessUnit__c = BUnit.Id;
        BDetails.Status__c = 'Active';
        insert(BDetails);
        
        accView = new AccountView__c();
        accView.Account__c = acc.id;
        accView.Business__c = BUnit.id;
        accView.Business_Detail__c = BDetails.id;
        accView.User__c = UserInfo.getUserId();
        accView.Account_Access__c = 'Read/Write';
        accView.Account_Team_Role__c = 'Account Manager';
        accView.Case_Access__c = 'Read/Write';
        accView.Opportunity_Access__c = 'Read/Write';
        
        
	}
	
	
    static testMethod void insertAccountTeamMemberTest() {
        createTestData();
        Test.StartTest();
        
        //cover before insert functionality
        insert accView;
        
        system.assertEquals(accView.User__c,UserInfo.getUserId());
        //test delete functionality
       // delete accView;
        
        Test.StopTest();
        
    }
    
    
    static testMethod void insertAccountExtTeamMemberTest() {
        createTestData();
        
        
        AccountTeamMember accNewCr = new AccountTeamMember();
        accNewCr.UserId = UserInfo.getUserId();
        accNewCr.AccountId = acc.id;
        //accNewCr.AccountAccessLevel = 'Read/Write';
        //accNewCr.CaseAccessLevel= 'Read/Write';
        //accNewCr.OpportunityAccessLevel = 'Read/Write';
        accNewCr.TeamMemberRole = 'Account Manager';
        insert accNewCr;
        
        AccountView__c accView2 = new AccountView__c();
        accView2.Account__c = acc.id;
        accView2.Business__c = BUnit.id;
        accView2.Business_Detail__c = BDetails.id;
        accView2.User__c = UserInfo.getUserId();
        accView2.Account_Access__c = 'Read/Write';
        accView2.Account_Team_Role__c = 'Account Manager';
        accView2.Case_Access__c = 'Read/Write';
        accView2.Opportunity_Access__c = 'Read/Write';
        
        Test.StartTest();
        
        //cover before insert functionality
        insert accView2;
        
        system.assertEquals(accView.User__c,UserInfo.getUserId());
        
        List<AccountView__c> acList2 = new List<AccountView__c>();
        acList2.add(accView2);
        //test delete functionality
  		SyncAccountTeamMemberHelper syncAcc = new SyncAccountTeamMemberHelper(null,null,acList2);
    	syncAcc.deleteAccRec();
        
        Test.StopTest();
        
    }
    
    static testMethod void updateAccountTeamMemberTest() {
    	 createTestData();
    	 insert accView;
    	 
    	 Test.StartTest();
    	 //test before update functionality
	        accView.Opportunity_Access__c = 'Read Only';
	        update accView;
	        
	        system.assertNotEquals(accView.User__c,null);
	        List<AccountView__c> acList = new List<AccountView__c>();
	        acList.add(accView);
	        SyncAccountTeamMemberHelper syncAcc = new SyncAccountTeamMemberHelper(null,acList,null);
        	syncAcc.syncAccTeamupdate();
        	
        Test.StopTest();
    }
    
    static testMethod void updateAccountExtTeamMemberTest() {
    	 createTestData();
    	 insert accView;
    	 
    	 AccountTeamMember accNewCr = new AccountTeamMember();
        accNewCr.UserId = UserInfo.getUserId();
        accNewCr.AccountId = acc.id;
        //accNewCr.AccountAccessLevel = 'Read/Write';
        //accNewCr.CaseAccessLevel= 'Read/Write';
        //accNewCr.OpportunityAccessLevel = 'Read/Write';
        accNewCr.TeamMemberRole = 'Account Manager';
        insert accNewCr;
        
        AccountView__c accView2 = new AccountView__c();
        accView2.Account__c = acc.id;
        accView2.Business__c = BUnit.id;
        accView2.Business_Detail__c = BDetails.id;
        accView2.User__c = UserInfo.getUserId();
        accView2.Account_Access__c = 'Read/Write';
        accView2.Account_Team_Role__c = 'Account Manager';
        accView2.Case_Access__c = 'Read/Write';
        accView2.Opportunity_Access__c = 'Read/Write';
    	insert accView2; 
    	 Test.StartTest();
    	 //test before update functionality
	        accView.Opportunity_Access__c = 'Read Only';
	        update accView2;
	        
	        system.assertNotEquals(accView.User__c,null);
	        List<AccountView__c> acList = new List<AccountView__c>();
	        acList.add(accView2);
	        SyncAccountTeamMemberHelper syncAcc = new SyncAccountTeamMemberHelper(null,acList,null);
        	syncAcc.syncAccTeamupdate();
        	
        Test.StopTest();
    }
    
}