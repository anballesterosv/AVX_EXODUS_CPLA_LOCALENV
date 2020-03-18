/**
Class Name: CPG_OpportunityUtil_Test
Description: Test class for class CPG_OpportunityUtil
CreatedDate: 06-17-2018
**/
@isTest
public without sharing class  CPG_OpportunityUtil_Test{
    private static final String OPPFACE = 'Antibiotic Free';
    private static final String OPPNAME = 'OPPNAME';
    private static final Id BEEFOPPRECTYPEID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Boxed_Beef_Ground_Beef').getRecordTypeId();
    private static final Id TURKEYOPPRECTYPEID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Turkey').getRecordTypeId();
    //Get Prospect Account Record Type Id
    private static final Id PROSPECTRECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
    private static final String STAGENAME = 'Explore';
    private static final String UNITOFMEASURE = 'Pound';

    @TestSetup
    private static void init(){
        
        Ship_To__c shipTo1;
        Ship_To__c shipTo2;
        Ship_To__c shipTo3;
        Bill_To__c billTo1;
        
        Account account1;
        List<Opportunity> lstOpp = new list<Opportunity>();
        
       
        //A ccount
        List<Account> accounts = new List<Account>();
        account1 = new Account(Name='Test Sold To Account',Market_Channel__c='Retail Channel',Billingcity = 'Texas',Billingstate ='Texas', RecordTypeId=PROSPECTRECTYPEID);
        accounts.add(account1);
        insert accounts;
        
        Account payer = new Account(Name='Payer Account',Market_Channel__c='Retail Channel',Billingcity = 'Texas',Billingstate ='Texas',parentId=account1.Id, RecordTypeId=PROSPECTRECTYPEID);
        insert payer;  
        
        //Contact 
        Contact customerContact = new Contact(LastName='Test Last Name',AccountId=account1.ID);
        insert customerContact;
        
        //Opportunities        
        Opportunity opp1 = new Opportunity(Name=OPPNAME,Pricebook2Id = Test.getStandardPricebookId(), recordTypeId= BEEFOPPRECTYPEID, Customer_key_buy_factor__c='NA',Key_Customer_Contact_Identified__c=customerContact.Id,Appointment_Set__c=Date.Today().addDays(10),NextStep='NA',Solution_Identified__c='NA',IsValidCommunicationFromCustomer__c=true,Pricing_Start_Date__c=Date.Today(),Pricing_End_Date__c=Date.Today().addYears(1),OpportunitySpace__c=OPPFACE,Unit_Of_Measure__c=UNITOFMEASURE,Initial_Volume__c=1000,Meeting_or_Call_set_to_present__c = Date.today().addDays(5),Agreement_on_next_steps_from_customer__c=true,AccountId=account1.Id,StageName=STAGENAME,Volume__c=100000,CloseDate=Date.newInstance(Date.today().year(), Date.today().month() + 2, 1));
        lstOpp.add(opp1);
        Opportunity opp2 = new Opportunity(Name=OPPNAME,Pricebook2Id = Test.getStandardPricebookId(), recordTypeId= BEEFOPPRECTYPEID, Customer_key_buy_factor__c='NA',Key_Customer_Contact_Identified__c=customerContact.Id,Appointment_Set__c=Date.Today().addDays(10),NextStep='NA',Solution_Identified__c='NA',IsValidCommunicationFromCustomer__c=true,Pricing_Start_Date__c=Date.Today(),Pricing_End_Date__c=Date.Today().addYears(1),OpportunitySpace__c=OPPFACE,Unit_Of_Measure__c=UNITOFMEASURE,Initial_Volume__c=1000,Meeting_or_Call_set_to_present__c = Date.today().addDays(5),Agreement_on_next_steps_from_customer__c=true,AccountId=account1.Id,StageName=STAGENAME,Volume__c=100000,CloseDate=Date.newInstance(Date.today().year(), Date.today().month() + 2, 1));
        lstOpp.add(opp2);
        Opportunity opp3 = new Opportunity(Name=OPPNAME,Pricebook2Id = Test.getStandardPricebookId(), recordTypeId= BEEFOPPRECTYPEID, Customer_key_buy_factor__c='NA',Key_Customer_Contact_Identified__c=customerContact.Id,Appointment_Set__c=Date.Today().addDays(10),NextStep='NA',Solution_Identified__c='NA',IsValidCommunicationFromCustomer__c=true,Pricing_Start_Date__c=Date.Today(),Pricing_End_Date__c=Date.Today().addYears(1),OpportunitySpace__c=OPPFACE,Unit_Of_Measure__c=UNITOFMEASURE,Initial_Volume__c=1000,Meeting_or_Call_set_to_present__c = Date.today().addDays(5),Agreement_on_next_steps_from_customer__c=true,AccountId=account1.Id,StageName=STAGENAME,Volume__c=100000,CloseDate=Date.newInstance(Date.today().year(), Date.today().month() + 2, 1));
        lstOpp.add(opp3);
        Opportunity opp4 = new Opportunity(Name=OPPNAME,Pricebook2Id = Test.getStandardPricebookId(), recordTypeId= TURKEYOPPRECTYPEID, Customer_key_buy_factor__c='NA',Key_Customer_Contact_Identified__c=customerContact.Id,Appointment_Set__c=Date.Today().addDays(10),NextStep='NA',Solution_Identified__c='NA',IsValidCommunicationFromCustomer__c=true,Pricing_Start_Date__c=Date.Today(),Pricing_End_Date__c=Date.Today().addYears(1),OpportunitySpace__c=OPPFACE,Unit_Of_Measure__c=UNITOFMEASURE,Initial_Volume__c=1000,Meeting_or_Call_set_to_present__c = Date.today().addDays(5),Agreement_on_next_steps_from_customer__c=true,AccountId=account1.Id,StageName=STAGENAME,Volume__c=100000,CloseDate=Date.newInstance(Date.today().year(), Date.today().month() + 2, 1));
        lstOpp.add(opp4);
        insert lstOpp;
        
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
        // 
        
        /*insert quote1;
        insert quote2;
        insert quote3;
        insert quote4;
        
        //Insert 2 ShipTos for the quote (ShipTo1 & ShipTo3)
        List<Quote_Ship_To__c> quoteShipTos = new List<Quote_Ship_To__c>();
        Quote_Ship_To__c  qst1 = new Quote_Ship_To__c(PROS_Quote__c = quote1.Id,Ship_To__c=shipTo1.Id);
        Quote_Ship_To__c  qst2 = new Quote_Ship_To__c(PROS_Quote__c = quote1.Id,Ship_To__c=shipTo3.Id);
        quoteShipTos.add(qst1);
        quoteShipTos.add(qst2);
        insert quoteShipTos;*/
    }
/*
    static TestMethod void check_OpportunityTypeUpdate(){
        init();
        list<Opportunity> lstUpdate = new list<Opportunity>();
        lstUpdate.add(new Opportunity(id=lstOpp[0].id , volume__c = 1000000));
        lstUpdate.add(new Opportunity(id=lstOpp[3].id , volume__c = 1000000));
        test.startTest();
        update lstUpdate;
        test.stopTest();
        list<Opportunity> lstOppCheck = new list<Opportunity>();
        lstOppCheck = [select Opportunity_type__c,id, volume__c from Opportunity where id =:lstOpp[0].id];    
        for(Opportunity opp:lstOppCheck){
            if(opp.volume__c >1000000){
                system.assertEquals(opp.Opportunity_type__c,'EXTENSIVE','Opportunity type not updated as expected!');
            }         
        }
    }
    
    //Apurva Lale(700291)
    static TestMethod void test_OpportunityTypeUpdate(){
        init();
        list<Opportunity> lstUpdate = new list<Opportunity>();
        lstUpdate.add(new Opportunity(id=lstOpp[1].id , volume__c = 1000000));
        lstUpdate.add(new Opportunity(id=lstOpp[3].id , volume__c = 100000));
        lstUpdate.add(new Opportunity(id=lstOpp[2].id , volume__c = 10000));
        
        test.startTest();
        update lstUpdate;
        test.stopTest();
        
        list<Opportunity> lstOppCheck = [select Opportunity_type__c,id, volume__c from Opportunity where id =:lstOpp[1].id];    
        for(Opportunity opp:lstOppCheck){
           	system.assertEquals(opp.Opportunity_type__c,'SIMPLE','Opportunity type not updated as expected!');      
        }
        
        list<Opportunity> lstOppCheck3 = [select Opportunity_type__c,id, volume__c from Opportunity where id =:lstOpp[3].id];    
        for(Opportunity opp:lstOppCheck3){
           	system.assertEquals(opp.Opportunity_type__c,'EXTENSIVE','Opportunity type not updated as expected!');      
        }
    }
    
    static TestMethod void test_TurkeyOpportunityTypeUpdate(){
        init();
        list<Opportunity> lstUpdate = new list<Opportunity>();
        lstUpdate.add(new Opportunity(id=lstOpp[3].id , volume__c = 900000));
        
        test.startTest();
        update lstUpdate;
        test.stopTest();
    
        
        list<Opportunity> lstOppCheck3 = [select Opportunity_type__c,id, volume__c from Opportunity where id =:lstOpp[3].id];    
        for(Opportunity opp:lstOppCheck3){
           	system.assertEquals(opp.Opportunity_type__c,'SIMPLE','Opportunity type not updated as expected!');      
        }
    }*/
    
    
    static TestMethod void test_rollUpClonedOppCount(){
        init();
        test.startTest();
        Set<id> ids = new Set<id>();
        CPG_OpportunityUtil.rollUpClonedOppCount(ids);
        List<Opportunity> oppList = [Select id,number_of_cloned_Opp__c,Opportunity_type__c FROM Opportunity];
        Opportunity oppr = new Opportunity(Name='opp1', StageName=STAGENAME, 
                                           CloseDate=Date.newInstance(Date.today().year(), Date.today().month() + 2, 1), 
                                           Unit_of_Measure__c=UNITOFMEASURE, volume__c = 900000, sourceOpportunity__c=oppList[1].id);
        insert oppr;
        
        for(Opportunity opp : oppList) {
            ids.add(opp.Id);
        }
        CPG_OpportunityUtil.rollUpClonedOppCount(ids);
        System.assertEquals(oppList[1].Opportunity_type__c,'EXTENSIVE');
       	test.stopTest();
    }
    
     static TestMethod void testcalculateOppType(){
     	CameleonCPQ__Quote__c quote1;
        CameleonCPQ__Quote__c quote2;
        CameleonCPQ__Quote__c quote3;
        CameleonCPQ__Quote__c quote4;
        List<CameleonCPQ__Quote__c> quotes = new List<CameleonCPQ__Quote__c>();
        String fobDelivered = 'FOB';

        init();
        List<Opportunity> lstOpp = [Select id,Opportunity_type__c FROM Opportunity];

        quote1 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 1',Pricing_Type__c='Formula',OpportunityId__c=lstOpp[0].Id, Formula_Type__c='USDA',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDELIVERED__c=fobDelivered,Primary_Quote__c = TRUE, DealSize__c='Direct');
        quote2 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 2',Pricing_Type__c='NOF',OpportunityId__c=lstOpp[1].Id, Formula_Type__c='',Pricing_Start_Date__c=Date.today().addDays(22),Pricing_End_Date__c=Date.today().addDays(34),FOBDELIVERED__c=fobDelivered, Primary_Quote__c = TRUE);
        quote3 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 3',Pricing_Type__c='PPP',OpportunityId__c=lstOpp[2].Id, Formula_Type__c='',Pricing_Start_Date__c=Date.today().addDays(61),Pricing_End_Date__c=Date.today().addDays(69),FOBDELIVERED__c=fobDelivered,PPP_Duration__c ='3 Months', Primary_Quote__c = TRUE);
        quote4 = new CameleonCPQ__Quote__c(Name='TEST QUOTE 4',Pricing_Type__c='Fixed',OpportunityId__c=lstOpp[3].Id, Formula_Type__c='',Pricing_Start_Date__c=Date.newInstance(Date.today().year(), 1, 1),Pricing_End_Date__c=Date.newInstance(Date.today().year(), 12, 31),FOBDELIVERED__c=fobDelivered);
        quotes.add(quote1);
        quotes.add(quote2);
        quotes.add(quote3);
        quotes.add(quote4);
        
      	CPG_OpportunityUtil.calculateOppType(quotes);
        System.assertEquals(lstOpp[1].Opportunity_type__c,'EXTENSIVE');
     }
}