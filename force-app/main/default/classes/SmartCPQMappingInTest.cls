@isTest
private class SmartCPQMappingInTest {
    private static SmartCPQMappingIn cpqMappingIn;
    private static Account account1;
    private static CameleonCPQ__Quote__c quote1;
    private static Opportunity opp1;
    private static Ship_To__c shipTo1;
    private static Ship_To__c shipTo2;
    private static Ship_To__c shipTo3;
    private static Bill_To__c billTo1;

    private static void init(){
        cpqMappingIn = new SmartCPQMappingIn();       
        //Get Prospect Account Record Type Id
       	Id prospectRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        //Account
        List<Account> accounts = new List<Account>();
        account1 = new Account(Name='Test Sold To Account',Market_Channel__c='Retail Channel',RecordTypeId=prospectRecTypeId);
        accounts.add(account1);
        insert accounts;
        
        Account payer = new Account(Name='Payer Account',Market_Channel__c='Retail Channel',parentId=account1.Id,RecordTypeId=prospectRecTypeId);
        insert payer;
        
        //Opportunities   
        //RecordType oppRecordTypeId = [SELECT Id,Name FROM RecordType WHERE DeveloperName=:'Turkey']; 
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Turkey').getRecordTypeId();
        List<Opportunity> opps = new List<Opportunity>();
        opp1 = new Opportunity(Name='Opp1',Unit_Of_Measure__c='Pound',RecordTypeId=oppRecordTypeId, AccountId=account1.Id,StageName='Explore',Volume__c=100000,CloseDate=Date.newInstance(Date.today().year(), Date.today().month() + 2, 1));
        opps.add(opp1);
        insert opps;
        
        //BIll To
        List<Bill_To__c> billTos = new List<Bill_To__c>();
        billTo1 = new Bill_To__c(Name='BillTo1',Payer__c=account1.Id);
        billTos.add(billTo1);
        insert billTos;
        
        //ShipTos
        List<Ship_To__c> shipTos = new List<Ship_To__c>();
    	shipTo1 = new Ship_To__c(Name='ShipTo1',Legacy_System__c='XLGO', ERP_Number__c='ERPNB0000001',Payer__c=payer.Id,Status__c = 'Active',Sold_To__c=billTo1.Id);
        shipTo2 = new Ship_To__c(Name='ShipTo2',Legacy_System__c='PROTEAN', ERP_Number__c='ERPNB0000002',Payer__c=payer.Id,Status__c = 'Active',Sold_To__c=billTo1.Id);
        shipTo3 = new Ship_To__c(Name='ShipTo3',Legacy_System__c='XLDM', ERP_Number__c='ERPNB0000003',Payer__c=payer.Id,Status__c = 'Active',Sold_To__c=billTo1.Id);
        shipTos.add(shipTo1);
        shipTos.add(shipTo2);
        shipTos.add(shipTo3);
        insert shipTos;        
        
        // Quotes
        List<CameleonCPQ__Quote__c> quotes = new List<CameleonCPQ__Quote__c>();
    	quote1 = new CameleonCPQ__Quote__c(Name='TEST QUOTE',OpportunityId__c=opp1.Id,Pricing_Type__c='Formula', Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB');
        quotes.add(quote1);
        insert quotes;
        
        //Insert 2 ShipTos for the quote (ShipTo1 & ShipTo3) to add to original 3 Ships-tos automatically added
        List<Quote_Ship_To__c> quoteShipTos = new List<Quote_Ship_To__c>();
        Quote_Ship_To__c  qst1 = new Quote_Ship_To__c(PROS_Quote__c=quote1.Id,Ship_To__c=shipTo1.Id);
        Quote_Ship_To__c  qst2 = new Quote_Ship_To__c(PROS_Quote__c=quote1.Id,Ship_To__c=shipTo3.Id);
        quoteShipTos.add(qst1);
        quoteShipTos.add(qst2);
        insert quoteShipTos;
    }
    
    static TestMethod void checkTupleCreation1(){
        init();
        Test.startTest(); 
        
        List<CameleonCPQ.CPQRequestFormatter.Tuple> tuples = cpqMappingIn.getCPQCustomSettings(quote1.Id);
        System.assertEquals(12, tuples.size(), 'Not Enough/Too many Tuples were created');
        cpqMappingIn.addTuple(tuples, 'tupleKey1', 'tupleValue1');
        System.assertEquals(13, tuples.size(), 'Not Enough/Too many Tuples were created');
        Test.stopTest();
    }
    
    static TestMethod void checkTupleValue1(){
        init();
        Test.startTest(); 
        List<CameleonCPQ.CPQRequestFormatter.Tuple> tuples = cpqMappingIn.getCPQCustomSettings(quote1.Id);
        System.assertEquals('ShipTo[1].Name', tuples.get(1).getKey(), 'Wrong Key for current Tuple');
        System.assertEquals('ShipTo1', tuples.get(1).getValue(), 'Wrong Value for current Tuple');
        Test.stopTest();
        
    }
}