@isTest
private class SmartCPQQuoteTriggerHandlerTest {
	private static SmartCPQQuoteTriggerHandler handler;
    private static Account account1;
    private static CameleonCPQ__Quote__c quote1;
    private static Opportunity opp1;
    private static Ship_To__c shipTo1;
    private static Ship_To__c shipTo2;
    private static Ship_To__c shipTo3;
    private static Bill_To__c billTo1;
    
    private static void init(){
        handler = new SmartCPQQuoteTriggerHandler(); 
        //Get Prospect Account Record Type Id
       	Id prospectRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        
        //Account
        List<Account> accounts = new List<Account>();
        account1 = new Account(Name='Test Sold To Account',Market_Channel__c='Retail Channel',Status__c = 'Active', RecordTypeId=prospectRecTypeId);
        accounts.add(account1);
        insert accounts;
        
        Account payer = new Account(Name='Payer Account',Market_Channel__c='Retail Channel',parentId=account1.Id, RecordTypeId=prospectRecTypeId);
        insert payer;          
        
		//Opportunities        
        //RecordType oppRecordTypeId = [SELECT Id,Name FROM RecordType WHERE DeveloperName=:'Turkey']; Turkey RecordType
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Turkey').getRecordTypeId();
        List<Opportunity> opps = new List<Opportunity>();
        opp1 = new Opportunity(Name='Opp1',Unit_Of_Measure__c='Pound',Pricebook2Id=Test.getStandardPricebookId(),RecordTypeId=oppRecordTypeId,AccountId=account1.Id,StageName='Explore',Volume__c=100000,CloseDate=Date.newInstance(Date.today().year(), Date.today().month() + 2, 1));
        opps.add(opp1);
        insert opps;
        
        //BIll To
        List<Bill_To__c> billTos = new List<Bill_To__c>();
        billTo1 = new Bill_To__c(Name='BillTo1',Payer__c=account1.Id);
        billTos.add(billTo1);
        insert billTos;   
        
        //ShipTos
        List<Ship_To__c> shipTos = new List<Ship_To__c>();
    	shipTo1 = new Ship_To__c(Name='ShipTo1',Legacy_System__c='XLGO', ERP_Number__c='ERPNB0000001',Payer__c=payer.Id,Sold_To__c=billTo1.Id,Status__c = 'Active');
        shipTo2 = new Ship_To__c(Name='ShipTo2',Legacy_System__c='PROTEAN', ERP_Number__c='ERPNB0000002',Payer__c=payer.Id,Sold_To__c=billTo1.Id,Status__c = 'Active');
        shipTo3 = new Ship_To__c(Name='ShipTo3',Legacy_System__c='XLDM', ERP_Number__c='ERPNB0000003',Payer__c=payer.Id,Sold_To__c=billTo1.Id,Status__c = 'Active');
        shipTos.add(shipTo1);
        shipTos.add(shipTo2);
        shipTos.add(shipTo3);
        insert shipTos;        
        
        // Quotes
        //List<CameleonCPQ__Quote__c> quotes = new List<CameleonCPQ__Quote__c>();
    	//quote1 = new CameleonCPQ__Quote__c(Name='TEST QUOTE',Pricing_Type__c='Formula',Opportunity__c= Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB');
        //quotes.add(quote1);
        //insert quotes;
        
        //Insert 2 ShipTos for the quote (ShipTo1 & ShipTo3)
        //List<Quote_Ship_To__c> quoteShipTos = new List<Quote_Ship_To__c>();
        //Quote_Ship_To__c  qst1 = new Quote_Ship_To__c(PROS_Quote__c=quote1.Id,Ship_To__c=shipTo1.Id);
        //Quote_Ship_To__c  qst2 = new Quote_Ship_To__c(PROS_Quote__c=quote1.Id,Ship_To__c=shipTo3.Id);
        //quoteShipTos.add(qst1);
        //quoteShipTos.add(qst2);
        //insert quoteShipTos;
    }
    
    static TestMethod void check_handleBeforeInsert1(){
        init();
        Test.startTest(); 
		
        CameleonCPQ__Quote__c testQuote1 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 1',OpportunityId__c=opp1.Id, Pricing_Type__c='Formula', Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB');
		insert testQuote1;
        CameleonCPQ__Quote__c resultTestQuote1 = [SELECT Id,Name,Primary_Quote__c,CameleonCPQ__AccountId__c FROM CameleonCPQ__Quote__c WHERE Id=:testQuote1.Id];
        System.assertEquals(account1.Id, resultTestQuote1.CameleonCPQ__AccountId__c, 'Account not correctly assigned');
        System.assertEquals(true, resultTestQuote1.Primary_Quote__c, 'Primary Quote Flag not correctly assigned');
        
        //Adding secnod quote to same Opportunity, primary quote flag = false
       	CameleonCPQ__Quote__c testQuote2 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 2',OpportunityId__c=opp1.Id, Pricing_Type__c='Formula', Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB');
		insert testQuote2;
        CameleonCPQ__Quote__c resultTestQuote2 = [SELECT Id,Name,Primary_Quote__c,CameleonCPQ__AccountId__c FROM CameleonCPQ__Quote__c WHERE Id=:testQuote2.Id];
        System.assertEquals(account1.Id, resultTestQuote2.CameleonCPQ__AccountId__c, 'Account not correctly assigned');
        System.assertEquals(false, resultTestQuote2.Primary_Quote__c, 'Primary Quote Flag wrongly set to true');
        
        Test.stopTest();
    }
    
    static TestMethod void check_handleBeforeUpdate1_primaryquotes(){
        init();
        Test.startTest(); 
		
        CameleonCPQ__Quote__c testQuote1 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 1',OpportunityId__c=opp1.Id, Pricing_Type__c='Formula', Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB');
		insert testQuote1;
       	CameleonCPQ__Quote__c testQuote2 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 2',OpportunityId__c=opp1.Id, Pricing_Type__c='Formula', Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB');
		insert testQuote2;
        
        //TEST 1 : UNFLAG A PRIMARY QUOTE
        try{
            testQuote1.Primary_Quote__c = false;
            update testQuote1;
        	throw new MyException('An exception should have been thrown by the trigger but was not.');
        }
        catch(Exception e)
        {
      	String actualExceptionMessage = e.getMessage().toUpperCase();
        Boolean actualExceptionThrown =  actualExceptionMessage.contains('YOU CANNOT UNFLAG A PRIMARY QUOTE')? true : false;
        System.AssertEquals(true, actualExceptionThrown);
        } 
 
        //TEST 2 : FLAG A NEW PRIMARY QUOTE
        testQuote2.Primary_Quote__c = true;
        update testQuote2;

        CameleonCPQ__Quote__c resultTestQuote1 = [SELECT Id,Name,Primary_Quote__c,Is_Primary_Quote_Removable__c FROM CameleonCPQ__Quote__c WHERE Id=:testQuote1.Id];
        System.assertEquals(false, resultTestQuote1.Primary_Quote__c, 'Quote should not be flagged as primary quote');
        System.assertEquals(false, resultTestQuote1.Is_Primary_Quote_Removable__c, 'Quote should be not flagged as Primary Quote removable');
        
        CameleonCPQ__Quote__c resultTestQuote2 = [SELECT Id,Name,Primary_Quote__c,Is_Primary_Quote_Removable__c FROM CameleonCPQ__Quote__c WHERE Id=:testQuote2.Id];
        System.assertEquals(true, resultTestQuote2.Primary_Quote__c, 'Quote should be flagged as primary quote');
        System.assertEquals(false, resultTestQuote2.Is_Primary_Quote_Removable__c, 'Quote should be not flagged as Primary Quote removable');
        
        Test.stopTest();
    }
    
    static TestMethod void check_handleBeforeUpdate1_approvalprocess(){
        init();
        Test.startTest(); 
		
        CameleonCPQ__Quote__c testQuote1 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 1',CameleonCPQ__Status__c='Draft',OpportunityId__c=opp1.Id, Pricing_Type__c='Formula', Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB');
		insert testQuote1;
        
        testQuote1.CameleonCPQ__Status__c='Needs Review';
        update testQuote1;
        //TODO
        
        Test.stopTest();
    }
        
    static TestMethod void check_handleAfterInsert2_insertAllShipTos(){
        init();
        Test.startTest(); 
		
        CameleonCPQ__Quote__c testQuote1 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 1',OpportunityId__c=opp1.Id, Pricing_Type__c='Formula', Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB');
		insert testQuote1;
        
        List<Quote_Ship_To__c> quoteShipTos = [SELECT Id,Name,PROS_Quote__c FROM Quote_Ship_To__c WHERE PROS_Quote__c=:testQuote1.Id];
        System.assertEquals(0, quoteShipTos.size(), 'The wrong amount of ShipTos were associate to the quote');

        Test.stopTest();       
    }
    
    static TestMethod void check_handleAfterUpdate2_syncOLIs(){
        init();
        Test.startTest();
        
        CameleonCPQ__Quote__c testQuote1 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 1',CameleonCPQ__Status__c='Draft',OpportunityId__c=opp1.Id, Pricing_Type__c='Formula', Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB');
		insert testQuote1;
        
        List<CPQQuoteLineItem__c> qlis = new List<CPQQuoteLineItem__c>(); 
        CPQQuoteLineItem__c cpqqli1 = new CPQQuoteLineItem__c(Name='QLI1',Product_Code__c='12345',ContractSyncID__c='contractSyncId1',PROS_Quote__c=testQuote1.Id,Initial_Volume__c=2000,Actual_Volume__c=1000,Net_Sales_Price__c=200);
        CPQQuoteLineItem__c cpqqli2 = new CPQQuoteLineItem__c(Name='QLI2',Product_Code__c='P0001',Result__c='Won',Legacy_System__c='XLGO',ContractSyncID__c='contractSyncId2',PROS_Quote__c=testQuote1.Id,Initial_Volume__c=3000,Actual_Volume__c=3000,Net_Sales_Price__c=100);
        qlis.add(cpqqli1);
        qlis.add(cpqqli2);
        insert qlis;
        
        List<OpportunityLineItem> olis = [SELECT Id,Name FROM OpportunityLineItem WHERE OpportunityId =: opp1.Id];
        System.assertEquals(0,olis.size(),'No OLIs should have been created for the test opportunity');
        
        Product2 prodP0001 = new Product2(Name='P0001 - Test Product #1', ProductCode='P0001', Product_Id__c='P0001|XLGO',isActive=true);
        insert prodP0001;

        //PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id =Test.getStandardPricebookId(), Product2Id = prodP0001.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        //insert standardPrice;
        
        //Quote is Accepted OLIs are synced
        testQuote1.CameleonCPQ__Status__c = 'Accepted';
        update testQuote1;     
        
		olis = [SELECT Id,Name,Quantity,TotalPrice FROM OpportunityLineItem WHERE OpportunityId =: opp1.Id];   
       	//System.assertEquals(1,olis.size(),'No OLIs should have been created for the test opportunity');
        //System.assertEquals(3000,olis[0].Quantity,'Wrong value for OLIs field');
       // System.assertEquals(100,olis[0].TotalPrice,'Wrong value for OLIs field');    
        
        
        SmartCPQUtils.setQLIsToLost(testQuote1.Id);
        Test.stopTest();   
        
    }
    static TestMethod void check_DateValidation1(){
        init();
        Test.startTest(); 
        
        CameleonCPQ__Quote__c testQuote1 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 1',OpportunityId__c=opp1.Id, Pricing_Type__c='Formula', Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB');
        insert testQuote1;
        System.assertEquals(false,SmartCPQUtils.checkValidExpirationDate(testQuote1,false),'Wrong date validation');
        CameleonCPQ__Quote__c testQuote2 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 2',OpportunityId__c=opp1.Id, Pricing_Type__c='Formula', CameleonCPQ__Expires__c = Date.today().addDays(-1),Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB');
        insert testQuote2;
        System.assertEquals(false,SmartCPQUtils.checkValidExpirationDate(testQuote2,false),'Wrong date validation');
        CameleonCPQ__Quote__c testQuote3 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 3',DealSize__c='Direct', OpportunityId__c=opp1.Id, CameleonCPQ__Expires__c = Date.today().addDays(14),Pricing_Type__c='Formula', Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB');
        insert testQuote3;
        CameleonCPQ__Quote__c tq3 = [SELECT Id,Name,DealSize__c,OpportunityId__c,Opportunity_Type__c,Pricing_Type__c, CameleonCPQ__Expires__c,CreatedDate FROM CameleonCPQ__Quote__c WHERE Id =: testQuote3.Id];
        System.assertEquals(true,SmartCPQUtils.checkValidExpirationDate(tq3,false),'Wrong date validation');
        CameleonCPQ__Quote__c testQuote4 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 4',DealSize__c='Full', OpportunityId__c=opp1.Id, CameleonCPQ__Expires__c = Date.today().addDays(14),Pricing_Type__c='Formula', Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB');
        insert testQuote4;
        CameleonCPQ__Quote__c tq4 = [SELECT Id,Name,DealSize__c,OpportunityId__c,Opportunity_Type__c,Pricing_Type__c, CameleonCPQ__Expires__c,CreatedDate FROM CameleonCPQ__Quote__c WHERE Id =: testQuote4.Id];
        System.assertEquals(true,SmartCPQUtils.checkValidExpirationDate(tq4,false),'Wrong date validation');
        CameleonCPQ__Quote__c testQuote5 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 5',DealSize__c='Direct', OpportunityId__c=opp1.Id, CameleonCPQ__Expires__c = Date.today().addDays(14),Pricing_Type__c='Formula', Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB');
        insert testQuote5;
        CameleonCPQ__Quote__c tq5 = [SELECT Id,Name,DealSize__c,OpportunityId__c,Opportunity_Type__c,Pricing_Type__c, CameleonCPQ__Expires__c,CreatedDate FROM CameleonCPQ__Quote__c WHERE Id =: testQuote3.Id];
        System.assertEquals(false,SmartCPQUtils.checkValidExpirationDate(tq5,true),'Wrong date validation');
        Test.stopTest(); 
    
	}	
    
    //Apurva Lale(700291)
    
	static TestMethod void check_handleBeforeInsert(){
        Opportunity opp = new Opportunity(Name='Opp1',Unit_Of_Measure__c='Pound',StageName='Explore',Volume__c=100000,CloseDate=Date.newInstance(Date.today().year(), Date.today().month() + 2, 1));
    	insert opp;
        CameleonCPQ__Quote__c testQuote1 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 1',OpportunityId__c=opp.Id, Pricing_Type__c='Formula', Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB', Primary_Quote__c = True);
        insert testQuote1;
        
       	Test.startTest(); 
        CameleonCPQ__Quote__c testQuote2 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 1',OpportunityId__c=opp.Id, Pricing_Type__c='Formula', Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB', Primary_Quote__c = True);
        insert testQuote2;
        Test.stopTest();
	}	
    
    static TestMethod void check_handleBeforeInsertForStatus(){
        Opportunity opp = new Opportunity(Name='Opp1',Unit_Of_Measure__c='Pound',StageName='Explore',Volume__c=100000,CloseDate=Date.newInstance(Date.today().year(), Date.today().month() + 2, 1));
    	insert opp;
        CameleonCPQ__Quote__c testQuote1 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 1',OpportunityId__c=opp.Id, Pricing_Type__c='Formula', Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB', Primary_Quote__c = True, CameleonCPQ__Status__c='Accepted');
        insert testQuote1;
        
        Test.startTest(); 
        try{
        	CameleonCPQ__Quote__c testQuote3 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 1',OpportunityId__c=opp.Id, Pricing_Type__c='Formula', Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB', Primary_Quote__c = True);
        	insert testQuote3;
        } catch(Exception e) {
      		String msg = e.getMessage().toUpperCase();
            boolean isError = msg.contains('YOU CANNOT FLAG A PRIMARY QUOTE WHEN ANOTHER ACCEPETD PRIMARY QUOTE EXISTS') ? true : false;
        	System.AssertEquals('INSERT FAILED. FIRST EXCEPTION ON ROW 0; FIRST ERROR: FIELD_CUSTOM_VALIDATION_EXCEPTION, YOU CANNOT FLAG A PRIMARY QUOTE WHEN ANOTHER ACCEPTED PRIMARY QUOTE EXISTS IN THE OPPORTUNITY: []', msg);
        } 
        Test.stopTest(); 
	}	
    
    static TestMethod void check_handleAfterInsert(){
        init();
        CameleonCPQ__Quote__c testQuote1 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 1',OpportunityId__c=opp1.Id, Pricing_Type__c='Formula', Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB', Primary_Quote__c = True);
        insert testQuote1;
        
        Test.startTest();
        	CameleonCPQ__Quote__c testQuote3 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 1',OpportunityId__c=opp1.Id, Pricing_Type__c='Formula', Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB', Clone_Parent_Quote__c = testQuote1.Id);
            insert testQuote3;
        Test.stopTest(); 
	}	
    
    public class MyException extends Exception{}
    
}