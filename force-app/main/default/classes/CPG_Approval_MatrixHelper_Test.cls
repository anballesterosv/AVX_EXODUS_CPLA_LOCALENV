@isTest
private class CPG_Approval_MatrixHelper_Test {
    
    static testMethod void testApproverAssignment() {
        //Create Pricing Approvers
        user SPapprover = CPG_TestFactory_Util.createTestUser('Price Team');
        user STapprover = CPG_TestFactory_Util.createTestUser('Price Team');
        user BMapprover = CPG_TestFactory_Util.createTestUser('Account Manager');
        
        //Create Approval Matrix record
        list<approval_matrix__c> appMat = new list<approval_matrix__c >();
        appMat.add(new approval_matrix__c(criterion__c='Quote-RED-Full-BOXED_BEEF_GROUND_BEEF-Formula', sp_approver_1__c = SPapprover.id , st_approver_1__c = STapprover.id, bm_approver_1__c = BMapprover.id));
        appMat.add(new approval_matrix__c(criterion__c='Quote-RED-Full-BOXED_BEEF_GROUND_BEEF', sp_approver_1__c = SPapprover.id , st_approver_1__c = STapprover.id, bm_approver_1__c = BMapprover.id));
        appMat.add(new approval_matrix__c(criterion__c='Quote-RED-Full-null-Formula', sp_approver_1__c = SPapprover.id , st_approver_1__c = STapprover.id, bm_approver_1__c = BMapprover.id));
        appMat.add(new approval_matrix__c(criterion__c='Quote-RED-Full-null', sp_approver_1__c = SPapprover.id , st_approver_1__c = STapprover.id, bm_approver_1__c = BMapprover.id));
        
        appMat.add(new approval_matrix__c(criterion__c='Quote-Retail-RED-Full-BOXED_BEEF_GROUND_BEEF-Formula', sp_approver_1__c = SPapprover.id , st_approver_1__c = STapprover.id, bm_approver_1__c = BMapprover.id));
        appMat.add(new approval_matrix__c(criterion__c='Quote-Retail-RED-Full-BOXED_BEEF_GROUND_BEEF', sp_approver_1__c = SPapprover.id , st_approver_1__c = STapprover.id, bm_approver_1__c = BMapprover.id));
        appMat.add(new approval_matrix__c(criterion__c='Quote-Retail-RED-Full-null-Formula', sp_approver_1__c = SPapprover.id , st_approver_1__c = STapprover.id, bm_approver_1__c = BMapprover.id));
        appMat.add(new approval_matrix__c(criterion__c='Quote-Retail-RED-Full-null', sp_approver_1__c = SPapprover.id , st_approver_1__c = STapprover.id, bm_approver_1__c = BMapprover.id));
        
        appMat.add(new approval_matrix__c(criterion__c='Quote-Food Service-RED-Full-BOXED_BEEF_GROUND_BEEF-Formula', sp_approver_1__c = SPapprover.id , st_approver_1__c = STapprover.id, bm_approver_1__c = BMapprover.id));
        appMat.add(new approval_matrix__c(criterion__c='Quote-Food Service-RED-Full-BOXED_BEEF_GROUND_BEEF', sp_approver_1__c = SPapprover.id , st_approver_1__c = STapprover.id, bm_approver_1__c = BMapprover.id));
        appMat.add(new approval_matrix__c(criterion__c='Quote-Food Service-RED-Full-null-Formula', sp_approver_1__c = SPapprover.id , st_approver_1__c = STapprover.id, bm_approver_1__c = BMapprover.id));
        appMat.add(new approval_matrix__c(criterion__c='Quote-Food Service-RED-Full-null', sp_approver_1__c = SPapprover.id , st_approver_1__c = STapprover.id, bm_approver_1__c = BMapprover.id));
        
        insert appMat;
        
        //Create Commercial Account
        Map<String,Schema.RecordTypeInfo> recordTypeMap = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Account acc = new Account();
        acc.Name = 'Test Comm Account';
        acc.BillingCity = 'Test';
        acc.BillingState = 'Iowa';
        acc.BillingStreet = 'Test';
        acc.BillingPostalCode = 'Test';
        acc.ShippingCity = 'Test';
        acc.ShippingState = 'Iowa';
        acc.ShippingStreet = 'Test';
        acc.ShippingPostalCode = 'Test';
        acc.RecordTypeId= recordTypeMap.get('Commercial Account').getRecordTypeId();
        acc.Market_Channel__c='Retail';
        insert(acc);
        
        //Insert Opportunity
        Map<String,Schema.RecordTypeInfo> recordTypeMapOpp = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName();
        Opportunity opp = new Opportunity();
        opp.Name='TestClone'; 
        opp.RecordTypeId= recordTypeMapOpp.get('Boxed Beef/Ground Beef').getRecordTypeId();
        opp.NextStep='test';                                   
        opp.CloseDate = System.today();                                    
        opp.AccountId=acc.id; 
        opp.StageName='Explore'; 
        opp.Probability=100;
        opp.Unit_of_Measure__c='Pound';
        opp.Volume__c=100;
        insert(opp);
            
    Product2 prd1 = new Product2 (Name='Test Protein Product',Description='Test Protein Product',productCode = 'CPGprotein', isActive = true,Business__c='Commercial Excellence NA',Product_Deployment__c='Placeholder');
    insert prd1;
    
    
    PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=Test.getStandardPricebookId(),UnitPrice=50, isActive=true);
    insert pbe1;
    
    OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200);
    insert lineItem1;
    
    CameleonCPQ__Quote__c   prosQuote = new CameleonCPQ__Quote__c();
    prosQuote.OpportunityId__c = opp.id;
    prosQuote.CameleonCPQ__AccountId__c = acc.id;
    prosQuote.Pricing_Type__c = 'Formula';
    prosQuote.Primary_Quote__c = true;
    prosQuote.Formula_Type__c = 'USDA';
    prosQuote.Pricing_End_Date__c = system.today().addDays(30);
    prosQuote.FOBDelivered__c = 'FOB';
    prosQuote.DealSize__c = 'Direct';
    prosQuote.pricing_start_date__c = date.today().addDays(15);
    insert prosQuote;
    //update Approval Zone and Deal Size for Quote in oreder to assign approvers
    prosQuote.Approval_Zone__c = 'RED'; 
    prosQuote.DealSize__c = 'Full';
    prosQuote.CameleonCPQ__Status__c = 'Needs Review';
    update prosQuote;
    
    Test.StartTest();
    list<CameleonCPQ__Quote__c> lstQuotes = new list<CameleonCPQ__Quote__c>();
    lstQuotes.add(prosQuote);
    CPG_Approval_MatrixHelper.setQuoteApprovers(lstQuotes);
    CameleonCPQ__Quote__c   iprosQuote = [select sp_approver_1__c, st_approver_1__c, bm_approver_1__c from CameleonCPQ__Quote__c where id=:prosQuote.id];
    //system.assertequals(SPapprover.id, iprosQuote.sp_approver_1__c,'SP Approver not assigned!');
    //system.assertequals(STapprover.id, iprosQuote.st_approver_1__c,'ST Approver not assigned!');
    //system.assertequals(BMapprover.id,iprosQuote.bm_approver_1__c, 'BM Approver not assigned!');
    Test.StopTest();
        
    }
}