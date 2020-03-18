@isTest
private class SmartCPQOpportunityTriggerHandlerTest {
    private static Account account1;
    private static CameleonCPQ__Quote__c quote1;
    private static CameleonCPQ__Quote__c quote2;
    private static Opportunity opp1;
    private static Ship_To__c shipTo1;
    private static Ship_To__c shipTo2;
    private static Ship_To__c shipTo3;
    private static Bill_To__c billTo1;
    
    private static void init(){
        //Get Prospect Account Record Type Id
       	Id prospectRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        
        //Account
        List<Account> accounts = new List<Account>();
        account1 = new Account(Name='Test Sold To Account',Market_Channel__c='Retail Channel', RecordTypeId=prospectRecTypeId);
        accounts.add(account1);
        insert accounts;
        
        Account payer = new Account(Name='Payer Account',Market_Channel__c='Retail Channel',parentId=account1.Id, RecordTypeId=prospectRecTypeId);
        insert payer;  
        
        //Contact 
        Contact customerContact = new Contact(LastName='Test Last Name',AccountId=account1.ID);
        insert customerContact;
        
		//Opportunities        
        List<Opportunity> opps = new List<Opportunity>();
        opp1 = new Opportunity(Name='Opp1',Pricebook2Id = Test.getStandardPricebookId(), Customer_key_buy_factor__c='NA',Key_Customer_Contact_Identified__c=customerContact.Id,Appointment_Set__c=Date.Today().addDays(10),NextStep='NA',Solution_Identified__c='NA',IsValidCommunicationFromCustomer__c=true,Pricing_Start_Date__c=Date.Today(),Pricing_End_Date__c=Date.Today().addYears(1),OpportunitySpace__c='Antibiotic Free',Unit_Of_Measure__c='Pound',Initial_Volume__c=1000,Meeting_or_Call_set_to_present__c = Date.today().addDays(5),Agreement_on_next_steps_from_customer__c=true,AccountId=account1.Id,StageName='Explore',Volume__c=100000,CloseDate=Date.newInstance(Date.today().year(), Date.today().month() + 2, 1));
        opps.add(opp1);
        insert opps;
        
        //BIll To
        List<Bill_To__c> billTos = new List<Bill_To__c>();
        billTo1 = new Bill_To__c(Name='BillTo1',Payer__c=account1.Id);
        billTos.add(billTo1);
        insert billTos;        
        
        //ShipTos
        List<Ship_To__c> shipTos = new List<Ship_To__c>();
    	shipTo1 = new Ship_To__c(Name='ShipTo1',Legacy_System__c='XLGO', ERP_Number__c='ERPNB0000001',Payer__c=payer.Id,Sold_To__c=billTo1.Id);
        shipTo2 = new Ship_To__c(Name='ShipTo2',Legacy_System__c='PROTEAN', ERP_Number__c='ERPNB0000002',Payer__c=payer.Id,Sold_To__c=billTo1.Id);
        shipTo3 = new Ship_To__c(Name='ShipTo3',Legacy_System__c='XLDM', ERP_Number__c='ERPNB0000003',Payer__c=payer.Id,Sold_To__c=billTo1.Id);
        shipTos.add(shipTo1);
        shipTos.add(shipTo2);
        shipTos.add(shipTo3);
        insert shipTos;        
        
        // Quotes
        List<CameleonCPQ__Quote__c> quotes = new List<CameleonCPQ__Quote__c>();
    	quote1 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 1',Pricing_Type__c='Formula',OpportunityId__c=opp1.Id, Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB');
        quote2 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 2',Pricing_Type__c='Formula',OpportunityId__c=opp1.Id, Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB');
		insert quote1;
        insert quote2;
        
        //Insert 2 ShipTos for the quote (ShipTo1 & ShipTo3)
        List<Quote_Ship_To__c> quoteShipTos = new List<Quote_Ship_To__c>();
        Quote_Ship_To__c  qst1 = new Quote_Ship_To__c(PROS_Quote__c=quote1.Id,Ship_To__c=shipTo1.Id);
        Quote_Ship_To__c  qst2 = new Quote_Ship_To__c(PROS_Quote__c=quote1.Id,Ship_To__c=shipTo3.Id);
        quoteShipTos.add(qst1);
        quoteShipTos.add(qst2);
        insert quoteShipTos;
    }
    
    static TestMethod void check_handleBeforeInsert1_cloneQuote(){
        init();
        Test.startTest(); 
        //Regular Opportunity insertion
        Opportunity opp2 = new Opportunity(Name='Opp2',Pricebook2Id = Test.getStandardPricebookId(),Unit_Of_Measure__c='Pound',AccountId=account1.Id,StageName='Explore',Volume__c=100000,CloseDate=Date.newInstance(Date.today().year(), Date.today().month() + 2, 1));
		insert opp2;
        List<CameleonCPQ__Quote__c> quotes = [SELECT Id,Name FROM CameleonCPQ__Quote__c WHERE OpportunityId__c=:opp2.Id];
        System.assertEquals(0, quotes.size(), 'No quote should have been cloned in the opporturnity insertion');
        
        //Clone Opportunity Insertion
        Opportunity opp3 = new Opportunity(Name='Clone Opp3',Pricebook2Id = Test.getStandardPricebookId(),Unit_Of_Measure__c='Pound',IsApexCloned__c=true,SourceOpportunity__c=opp1.Id, AccountId=account1.Id,StageName='Explore',Volume__c=100000,CloseDate=Date.newInstance(Date.today().year(), Date.today().month() + 2, 1));
		insert opp3;
        quotes = [SELECT Id,Name FROM CameleonCPQ__Quote__c WHERE OpportunityId__c=:opp3.Id];
        System.assertEquals(1, quotes.size(), 'The primary should have been cloned in the opporturnity insertion');
        System.assertEquals('V1 - TEST QUOTE 1', quotes[0].Name, 'Wrong Cloned primary quote name');
        
        
        
        Test.stopTest();
    }
    
    /*static TestMethod void check_handleAfterUpdatet1_LockQuotes(){
        init();
        Test.startTest();
        Product2 prodP0001 = new Product2(Name='P0001 - Test Product #1', ProductCode='P0001', Product_Id__c='P0001|XLGO',isActive=true);
        insert prodP0001;
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id =Test.getStandardPricebookId(), Product2Id = prodP0001.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice;
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=opp1.Id,Quantity=100,TotalPrice=1500,PricebookEntryId =standardPrice.Id);
        insert oli1;
        Id lockQuoteRecTypeId = Schema.SObjectType.CameleonCPQ__Quote__c.getRecordTypeInfosByName().get('Non-Editable').getRecordTypeId();
        Id unlockQuoteRecTypeId = Schema.SObjectType.CameleonCPQ__Quote__c.getRecordTypeInfosByName().get('Editable').getRecordTypeId();
        List<CameleonCPQ__Quote__c> quotes = [SELECT Id,Name FROM CameleonCPQ__Quote__c WHERE OpportunityId__c=:opp1.Id AND RecordTypeId=: lockQuoteRecTypeId];
        System.assertEquals(0, quotes.size(), 'Wrong number of Opportunity quotes returned.');
        opp1.StageName = 'Closed Won';
        
        update opp1;
        quotes = [SELECT Id,Name FROM CameleonCPQ__Quote__c WHERE OpportunityId__c=:opp1.Id AND RecordTypeId=:  lockQuoteRecTypeId];
        //Not applicable
        //System.assertEquals(2, quotes.size(), 'Wrong number of Opportunity quotes returned.');
        Test.stopTest();
    }*/
}