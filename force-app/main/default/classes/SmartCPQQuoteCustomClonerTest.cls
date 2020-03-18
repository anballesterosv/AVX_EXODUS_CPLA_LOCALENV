@isTest
private class SmartCPQQuoteCustomClonerTest {
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
        account1 = new Account(Name='Test Sold To Account',Market_Channel__c='Retail Channel', RecordTypeId=prospectRecTypeId);
        accounts.add(account1);
        insert accounts;
        
        Account payer = new Account(Name='Payer Account',Market_Channel__c='Retail Channel',parentId=account1.Id, RecordTypeId=prospectRecTypeId);
        insert payer; 
        
		//Opportunities        
        List<Opportunity> opps = new List<Opportunity>();
        opp1 = new Opportunity(Name='Opp1',Unit_Of_Measure__c='Pound',AccountId=account1.Id,StageName='Explore',Volume__c=100000,CloseDate=Date.newInstance(Date.today().year(), Date.today().month() + 2, 1));
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
    	quote1 = new CameleonCPQ__Quote__c(Name='THIS IS QUOTE 1',Pricing_Type__c='Formula',OpportunityId__c=opp1.Id, Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDelivered__c='FOB', Need_To_Clone_Flag__c=true);
		insert quote1;

    }
    
    static TestMethod void check_customQuoteClone1(){
            init();
            Test.startTest(); 
            //Regular Opportunity insertion
            Opportunity opp2 = new Opportunity(Name='Opp2',Unit_Of_Measure__c='Pound',AccountId=account1.Id,StageName='Explore',Volume__c=100000,CloseDate=Date.newInstance(Date.today().year(), Date.today().month() + 2, 1));
            insert opp2;
            List<CameleonCPQ__Quote__c> quotes = [SELECT Id,Name FROM CameleonCPQ__Quote__c WHERE OpportunityId__c=:opp2.Id];
            System.assertEquals(0, quotes.size(), 'No quote should have been cloned in the opporturnity insertion');
            
            //Instantiate controller
            SmartCPQQuoteCustomCloner controller1= new SmartCPQQuoteCustomCloner();
                
            //CLone Quote1 from Opp1 into Opp2
            SmartCPQQuoteCustomCloner.customCloneQuote(quote1.Id, opp2.Id,true,false); 
                
            quotes = [SELECT Id,Name,OpportunityId__c,Pricing_Type__c,Pricing_End_Date__c, CameleonCPQ__Status__c FROM CameleonCPQ__Quote__c WHERE OpportunityId__c=:opp2.Id];
            System.assertEquals(1, quotes.size(), 'A quote should have been cloned');
            System.assertEquals('V2 - THIS IS QUOTE 1', quotes[0].Name, 'Wrong Quote Name in the cloned quote');
            System.assertEquals(opp2.Id, quotes[0].OpportunityId__c, 'Wrong Quote Opportunity Id in the cloned quote');
            System.assertEquals('Formula', quotes[0].Pricing_Type__c, 'Wrong Quote Pricing Type in the cloned quote');
            System.assertEquals(Date.newInstance(Date.today().year(), 12, 31), quotes[0].Pricing_End_Date__c, 'Wrong Quote Pricing End Date in the cloned quote');
            
            SmartCPQQuoteCustomCloner.cloneQuoteAction(quote1.Id, opp2.Id); 
            
            Test.stopTest();
    }
    
    static TestMethod void check_customQuoteClone2(){
            init();
            Test.startTest(); 
            //Regular Opportunity insertion
            Opportunity opp2 = new Opportunity(Name='Opp2',Unit_Of_Measure__c='Pound',AccountId=account1.Id,StageName='Explore',Volume__c=100000,CloseDate=Date.newInstance(Date.today().year(), Date.today().month() + 2, 1));
            insert opp2;
            List<CameleonCPQ__Quote__c> quotes = [SELECT Id,Name FROM CameleonCPQ__Quote__c WHERE OpportunityId__c=:opp2.Id];
            System.assertEquals(0, quotes.size(), 'No quote should have been cloned in the opporturnity insertion');
            
                
            //CLone Quote1 from Opp1 into Opp2
            String cloneId = SmartCPQQuoteCustomCloner.cloneQuoteAction(quote1.Id, opp2.Id); 
                

            System.assertNotEquals('-1', cloneId, 'A quote should have been cloned');
            
                String activeRel =  String.valueOf(quote1.CameleonCPQ__ActiveRelease__c);
                boolean refresh = true;
                 SmartCPQQuoteCustomCloner.cloneQuoteContentAction(quote1.Id, cloneId,activeRel,refresh);
           //             quotes = [SELECT Id,Name,OpportunityId__c,Pricing_Type__c,Pricing_End_Date__c,CameleonCPQ__ActiveRelease__c FROM CameleonCPQ__Quote__c WHERE OpportunityId__c=:opp2.Id];
           // System.assertEquals('Clone of THIS IS QUOTE 1', quotes[0].Name, 'Wrong Quote Name in the cloned quote');
//            System.assertEquals(opp2.Id, quotes[0].OpportunityId__c, 'Wrong Quote Opportunity Id in the cloned quote');
            //System.assertEquals('Formula', quotes[0].Pricing_Type__c, 'Wrong Quote Pricing Type in the cloned quote');
            //System.assertEquals(Date.newInstance(Date.today().year(), 12, 31), quotes[0].Pricing_End_Date__c, 'Wrong Quote Pricing End Date in the cloned quote');
            
           
            Test.stopTest();
    }
    
    
    static TestMethod void check_buildVFController(){
            init();
            Test.startTest();
            SmartCPQQuoteCustomCloner VFController = new SmartCPQQuoteCustomCloner(new ApexPages.StandardController(quote1));
        	Test.stopTest();
    }
}