@isTest
public class AddBillTosToPROSQuoteExtensionTest {
        private static Account account1;
        private static CameleonCPQ__Quote__c quote1;
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
        account1 = new Account(Name='Test Sold To Account',Market_Channel__c='Retail Channel',RecordTypeId=prospectRecTypeId);
        accounts.add(account1);
        insert accounts;
        
        Account payer = new Account(Name='Payer Account',Market_Channel__c='Retail Channel',parentId=account1.Id,RecordTypeId=prospectRecTypeId);
        insert payer; 
            
		//Opportunities        
        //RecordType oppRecordTypeId = [SELECT Id,Name FROM RecordType WHERE DeveloperName=:'Turkey']; Turkey RecordType
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Turkey').getRecordTypeId();
        List<Opportunity> opps = new List<Opportunity>();
        opp1 = new Opportunity(Name='Opp1',Unit_Of_Measure__c='Pound',RecordTypeId=oppRecordTypeId,AccountId=account1.Id,StageName='Explore',Volume__c=100000,CloseDate=Date.newInstance(Date.today().year(), Date.today().month() + 2, 1));
        opps.add(opp1);
        insert opps;
        
        //BIll To
        List<Bill_To__c> billTos = new List<Bill_To__c>();
        billTo1 = new Bill_To__c(Name='BillTo1',Payer__c=payer.Id,Status__c = 'Active',Legacy_System__c='PROTEAN');
        billTos.add(billTo1);
        insert billTos;  
            
        //ShipTos
        List<Ship_To__c> shipTos = new List<Ship_To__c>();
    	shipTo1 = new Ship_To__c(Name='ShipTo1',Legacy_System__c='XLGO', ERP_Number__c='ERPNB0000001',Payer__c=payer.Id,Sold_To__c=billTo1.Id,Status__c = 'Active');
        shipTo2 = new Ship_To__c(Name='ShipTo2',Legacy_System__c='PROTEAN', ERP_Number__c='ERPNB0000002',Payer__c=payer.Id,Sold_To__c=billTo1.Id,Status__c = 'Active');
        shipTo3 = new Ship_To__c(Name='ShipTo3',Legacy_System__c='XLDM', ERP_Number__c='ERPNB0000003',Payer__c=payer.Id,Sold_To__c=billTo1.Id,Status__c = 'Active');
        Ship_To__c shipTo4 = new Ship_To__c(Name='ShipTo4',Legacy_System__c='PROTEAN', ERP_Number__c='ERPNB0000004',Payer__c=payer.Id,Sold_To__c=billTo1.Id,Status__c = 'Inactive');
        Ship_To__c shipTo5 = new Ship_To__c(Name='ShipTo5',Legacy_System__c='PROTEAN', ERP_Number__c='ERPNB0000005',Payer__c=payer.Id,Sold_To__c=billTo1.Id,Status__c = 'Inactive');
        shipTos.add(shipTo1);
        shipTos.add(shipTo2);
        shipTos.add(shipTo3);
        shipTos.add(shipTo4);
        shipTos.add(shipTo5);
        insert shipTos;        
        
        // Quotes
        Date pricingStartDate = Date.today();
        pricingStartDate = pricingStartDate.addDays(70);
        List<CameleonCPQ__Quote__c> quotes = new List<CameleonCPQ__Quote__c>();
    	quote1 = new CameleonCPQ__Quote__c(Name='THIS IS QUOTE 1',Pricing_Type__c='PPP',PPP_Duration__c='3 Months',OpportunityId__c=opp1.Id, CameleonCPQ__AccountId__c=account1.Id ,Formula_Type__c='',Pricing_Start_Date__c=pricingStartDate,Pricing_End_Date__c=pricingStartDate.addMonths(1),FOBDelivered__c='FOB');
		insert quote1;

    }
    
    private static testMethod void runTest_VFController(){
            init();
            Test.startTest();
            AddBillTosToPROSQuoteExtension VFController = new AddBillTosToPROSQuoteExtension(new ApexPages.StandardController(quote1));

			Integer unselectedBillTos = VFController.lstBillTos.size();
            //XLGO & XLDM not selected for Turkey Opportunity
            System.assertEquals(1, unselectedBillTos, 'Wrong number of unselected Bill tos');
			VFController.backtoQuote();            
            
            //Remove all shiptos
            VFController.removeAllBillTos();
            VFController.addAllBillTos();
            VFController.addBillTos();
            VFController.selectAllBillTos();
            VFController.unSelectAllBillTos();
            VFController.createNewWrapBillTo(billTo1);
            Test.stopTest();
        }
    
    private static testMethod void runTest_StaticMethods(){
            init();
            Test.startTest();
        	List<Quote_Bill_To__c> quoteBillTos1 = [SELECT Id,Name,Bill_To__c,PROS_Quote__c FROM Quote_Bill_To__c WHERE  PROS_Quote__c=:quote1.Id];
        	System.assertEquals(0, quoteBillTos1.size(), 'Wrong number of selected Bill tos');
			SmartCPQUtils.addAllBillTos(quote1,'Turkey');
        	quoteBillTos1 = [SELECT Id,Name,Bill_To__c,PROS_Quote__c FROM Quote_Bill_To__c WHERE  PROS_Quote__c=:quote1.Id];
        	System.assertEquals(1, quoteBillTos1.size(), 'Wrong number of selected Bill tos');
        	
        	Date pricingStartDate = Date.today();
        	pricingStartDate = pricingStartDate.addDays(70);
            CameleonCPQ__Quote__c quote2 = new CameleonCPQ__Quote__c(Name='THIS IS QUOTE 2',Pricing_Type__c='Formula',PPP_Duration__c='',OpportunityId__c=opp1.Id, Formula_Type__c='USDA',Pricing_Start_Date__c=pricingStartDate ,Pricing_End_Date__c=pricingStartDate.addMonths(1),FOBDelivered__c='FOB');
            insert quote2;
        	List<Quote_Bill_To__c> quoteBillTos2 = [SELECT Id,Name,Bill_To__c,PROS_Quote__c FROM Quote_Bill_To__c WHERE  PROS_Quote__c=:quote2.Id];
        	System.assertEquals(0, quoteBillTos2.size(), 'Wrong number of selected Bill tos');
			SmartCPQUtils.addParentQuoteBillTos(quote2,'Turkey',quote1.Id);
        	quoteBillTos2 = [SELECT Id,Name,Bill_To__c,PROS_Quote__c FROM Quote_Bill_To__c WHERE  PROS_Quote__c=:quote2.Id];
        	System.assertEquals(0, quoteBillTos2.size(), 'Wrong number of selected Bill tos');
            Test.stopTest();
        }

}