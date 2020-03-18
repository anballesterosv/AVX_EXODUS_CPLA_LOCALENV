@isTest
public class Protein_ProductRequestTriggerHelper_Test {
    
    public static testMethod void testProdRequestExistsAndOppLineItemExists() {
        Test.startTest();
        Protein_TestDataFactory.insertCustomIntegrationProfileDetail();
        Account globalAccount = Protein_TestDataFactory.createAccountRecord('Test Global Account', Protein_TestDataFactory.GLOBALACCOUNT_RECORD_TYPE, 
                                                                     Protein_TestDataFactory.INTERNAL_MARKETCHANNEL);
        Account commercialAccount = Protein_TestDataFactory.createAccountRecord('Test Commercial Account', Protein_TestDataFactory.COMMERCIALACCOUNT_RECORD_TYPE, 
	        																	Protein_TestDataFactory.FOODSERVICE_MARKETCHANNEL);
        commercialAccount.ParentId = globalAccount.Id;
        update commercialAccount;
        
        Opportunity opp = Protein_TestDataFactory.createOpportunityRecord('Test Opp', Protein_TestDataFactory.EGG_OPP_RT, commercialAccount.Id,
                                                                          100, Protein_TestDataFactory.EXPLORE_OPP_STAGE, System.today().addDays(20),
                                                                         Protein_TestDataFactory.POUND_OPP_UOM);
        Product2 prod = Protein_TestDataFactory.createProduct('Test product');
        System.assertEquals(prod.Name, 'Test product');
        System.debug('opp Id: '+opp.Id);
        System.debug('prod Id: '+prod.Id);
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE product2Id=:prod.Id LIMIT 1];
        OpportunityLineItem oli = Protein_TestDataFactory.createOppProduct(opp.Id, prod.Id, 500, 20, pbe.Id);
        System.debug('opp Line Item: '+oli);
        System.debug('opp.HasOpportunityLineItem: '+opp.HasOpportunityLineItem);
        System.debug('Before opp.HasOpportunityProductRequest__c: '+opp.HasOpportunityProductRequest__c);
        User busMngr = Protein_TestDataFactory.createUser('Business Manager');
        Product_Request__c pr = Protein_TestDataFactory.createProductRequest('Test PR', Protein_TestDataFactory.RETAIL_MARKETCHANNEL, busMngr.Id, 
                                                                             'Egg', 'Test Desc', 'Test reason', 200, System.today().addDays(20), opp.Id);
        System.debug('After opp.HasOpportunityProductRequest__c: '+opp.HasOpportunityProductRequest__c);
        delete pr;
        Test.stopTest();
    }
    
    public static testMethod void testProdRequestExistsAndNoOppLineItem() {
        Test.startTest();
        Protein_TestDataFactory.insertCustomIntegrationProfileDetail();
        Account globalAccount = Protein_TestDataFactory.createAccountRecord('Test Global Account', Protein_TestDataFactory.GLOBALACCOUNT_RECORD_TYPE, 
                                                                     Protein_TestDataFactory.INTERNAL_MARKETCHANNEL);
        Account commercialAccount = Protein_TestDataFactory.createAccountRecord('Test Commercial Account', Protein_TestDataFactory.COMMERCIALACCOUNT_RECORD_TYPE, 
	        																	Protein_TestDataFactory.FOODSERVICE_MARKETCHANNEL);
        commercialAccount.ParentId = globalAccount.Id;
        update commercialAccount;
        
        Opportunity opp = Protein_TestDataFactory.createOpportunityRecord('Test Opp', Protein_TestDataFactory.EGG_OPP_RT, commercialAccount.Id,
                                                                          100, Protein_TestDataFactory.EXPLORE_OPP_STAGE, System.today().addDays(20),
                                                                         Protein_TestDataFactory.POUND_OPP_UOM);
        Product_Group__c pg = Protein_TestDataFactory.createProductGroup(opp.Id, 100);
        System.assertEquals(pg.Volume__c, 100);
        User busMngr = Protein_TestDataFactory.createUser('Business Manager');
        Product_Request__c pr = Protein_TestDataFactory.createProductRequest('Test PR', Protein_TestDataFactory.RETAIL_MARKETCHANNEL, busMngr.Id, 
                                                                             'Egg', 'Test Desc', 'Test reason', 200, System.today().addDays(20), opp.Id);
        System.assertEquals(pr.Name, 'Test PR');
        delete pr;
        Test.stopTest();
    }

}