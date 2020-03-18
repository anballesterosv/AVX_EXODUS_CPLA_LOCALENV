/*@Author -Apps-AMS-CustomerFacing-Global
@date - 11-13-2018
purpose:The testclass is used for updating the productcode in quotelineitem*/
@isTest
private class updateproductcodeHandlerTest
{
    @isTest
    static void TestMethodforhandler() 
    {
        updateproductcodeHandler up = new updateproductcodeHandler();
        Product2 prod = new Product2();
        prod.Name = 'PR-52763';
        prod.Business__c = 'Food Service';
        prod.CurrencyIsoCode = 'USD';
        insert prod;
        Schema.DescribeSObjectResult cfrSchemaaccount = Schema.SObjectType.account; 
        Map<String,Schema.RecordTypeInfo> accountRecordTypeInfo = cfrSchemaaccount.getRecordTypeInfosByName();
        Id rtIdacc = accountRecordTypeInfo.get('Prospect').getRecordTypeId();
        system.debug('proepect id' + rtIdacc );
        Account acc= new Account(RecordTypeId =rtIdacc, Name='MyTestAcc_11 Parent', 
                                 Market_Channel__c= 'Food Service');
        insert acc;
        Schema.DescribeSObjectResult cfrSchemaopportunity = Schema.SObjectType.opportunity; 
        Map<String,Schema.RecordTypeInfo> opportunityRecordTypeInfo = cfrSchemaopportunity.getRecordTypeInfosByName();
        Id rtIdopp = opportunityRecordTypeInfo.get('Turkey').getRecordTypeId();
        List<Opportunity> opps = new List<Opportunity>();
        
        // For each account just inserted, add opportunities
        
        opps.add(new Opportunity(RecordTypeId=rtIdopp,Name='Opportunitytest',Volume__c =5980,StageName ='Explore',Accountid=acc.id,Unit_of_Measure__c='Pound',CloseDate=system.today()));
        
        
        // Insert all opportunities for all accounts.
        insert opps;
        CameleonCPQ__Quote__c  quote = new CameleonCPQ__Quote__c ();
        quote.Name = 'Test Quote';
        
        quote.OpportunityId__c= opps[0].Id;
        quote.Pricing_Start_Date__c =system.today();
        quote.Pricing_End_Date__c = system.today()+1;
        quote.FOBDelivered__c = 'FOB';
        quote.Pricing_Type__c  ='Fixed';
        
        
        insert quote;
        List<CPQQuoteLineItem__c> cpqLineItemlst = new List<CPQQuoteLineItem__c >();
        CPQQuoteLineItem__c cpq = new CPQQuoteLineItem__c();
        cpq.Name ='test';
        cpq.PROS_Quote__c = quote.id;
        cpq.CurrencyIsoCode= 'USD';
        cpq.Initial_Volume__c =1;
        cpq.ContractSyncID__c ='testforbulk';
        cpq.Product_Code__c ='PR-52763';
        cpqLineItemlst.add(cpq);
        insert cpq;
        
        
        
    }
}