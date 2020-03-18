@isTest
private class CloneOpportunityProducts_Test {
    
    static testMethod void testOppClone() {
        Integration_profile__c objIP = new Integration_profile__c(SkipValidationProfiles__c=TRUE);
        insert objIP;
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
        acc.RecordTypeId= recordTypeMap.get('Commercial Account').getRecordTypeId();
        acc.Market_Channel__c='Retail Channel';
        insert(acc);
        
        Opportunity opp = new Opportunity();
        opp.Name='TestClone'; 
        opp.NextStep='test';                                   
        opp.CloseDate = System.today();                                    
        opp.AccountId=acc.id; 
        opp.StageName='Explore'; 
        opp.Probability=100;
        opp.Unit_of_Measure__c='Pound';
        opp.Volume__c=100;
        insert(opp);
            
    Product2 prd1 = new Product2 (Name='Test Protein Product',Description='Test Protein Product',productCode = 'CPGprotein', isActive = true,Business__c='Retail',Product_Deployment__c='Placeholder');
    insert prd1;
    
    PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=Test.getStandardPricebookId(),UnitPrice=50, isActive=true);
        try{
            insert pbe2;
        }
        catch(Exception ex){
            System.debug('Error: ' +ex.getMessage());
        }
    PricebookEntry pbe1 = [SELECT Id, Product2Id, Pricebook2Id, UnitPrice, isActive FROM PricebookEntry WHERE Product2ID =:prd1.id];
    
        
    OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200);
    insert lineItem1;
    
    Test.StartTest();
    CloneOpportunityProducts.getCloneOpp(opp.id);
    list<Opportunity> lstOpp = new list<Opportunity>();
    lstOpp= [select id from Opportunity where name like '%TestClone%' and id!=:opp.id];
    //system.assert(lstOpp.size()>0);
    Test.StopTest();
        
    }
}