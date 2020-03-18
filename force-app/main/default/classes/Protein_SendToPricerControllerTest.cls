@istest
public class Protein_SendToPricerControllerTest {
    public static final String DRAFT_STATUS = 'Draft';
    public static final String ACCEPTED_BY_BM_STATUS = 'Accepted by BM';
    public static final String EGG_OPP_REC_TYPE = 'Egg';
    public static final String TEST_PR_NAME = 'Test PR';
    
    public static void createTestMetaData() {
        Product_Collection__mdt prCol=new Product_Collection__mdt();
        prCol.Opportunity_Type__c='Egg';
        prCol.Pricer__c='test@gmail.com';
    }
    
    public static Product_Request__c createTestData() {
        Account commercialAccount = Protein_TestDataFactory.createAccountRecord('Test Commercial Account', Protein_TestDataFactory.COMMERCIALACCOUNT_RECORD_TYPE, 
	        																	Protein_TestDataFactory.FOODSERVICE_MARKETCHANNEL);
        Opportunity opp = Protein_TestDataFactory.createOpportunityRecord('Test Opp', Protein_TestDataFactory.EGG_OPP_RT, commercialAccount.Id,
                                                                          100, Protein_TestDataFactory.EXPLORE_OPP_STAGE, System.today().addDays(20),
                                                                         Protein_TestDataFactory.POUND_OPP_UOM);
        System.assertEquals(opp.Name, 'Test Opp');
        User busMngr = Protein_TestDataFactory.createUser('Business Manager');
        Product_Request__c pr = Protein_TestDataFactory.createProductRequest('Test PR', Protein_TestDataFactory.RETAIL_MARKETCHANNEL, busMngr.Id, 
                                                                             'Egg', 'Test Desc', 'Test reason', 200, System.today().addDays(20), opp.Id);
        return pr;
    }
    
    /*public static testMethod void sendToPricerCase1() { //Opp RT is null
        createTestMetaData();
        Account commercialAccount = Protein_TestDataFactory.createAccountRecord('Test Commercial Account', Protein_TestDataFactory.COMMERCIALACCOUNT_RECORD_TYPE, 
	        																	Protein_TestDataFactory.FOODSERVICE_MARKETCHANNEL);
        Opportunity opp=new Opportunity(Name='Test opp', StageName='Explore', CloseDate=system.today(), Unit_of_Measure__c='Pound', Volume__c=12);
        insert opp;
        System.assertEquals(opp.Name, 'Test opp');
        User busMngr = Protein_TestDataFactory.createUser('Business Manager');
        Product_Request__c pr1 = Protein_TestDataFactory.createProductRequest('Test PR1', Protein_TestDataFactory.RETAIL_MARKETCHANNEL, busMngr.Id, 
                                                                             null, 'Test Desc', 'Test reason', 200, System.today().addDays(20), opp.Id);
        
        Protein_SendToPricerController.sendEmail(pr1.Id);
    }
    
    public static testMethod void sendToPricerTestCases() {
        final String DRAFT_STATUS = 'Draft';
        final String ACCEPTED_BY_BM_STATUS = 'Accepted by BM';
        final String EGG_OPP_REC_TYPE = 'Egg';
        
        List<Product_Request__c> lstPRs = new List<Product_Request__c>();
        Account commercialAccount = Protein_TestDataFactory.createAccountRecord('Test Commercial Account', Protein_TestDataFactory.COMMERCIALACCOUNT_RECORD_TYPE, 
	        																	Protein_TestDataFactory.FOODSERVICE_MARKETCHANNEL);
        Opportunity opp = Protein_TestDataFactory.createOpportunityRecord('Test Opp', Protein_TestDataFactory.EGG_OPP_RT, commercialAccount.Id,
                                                                          100, Protein_TestDataFactory.EXPLORE_OPP_STAGE, System.today().addDays(20),
                                                                         Protein_TestDataFactory.POUND_OPP_UOM);
        System.assertEquals(opp.Name, 'Test Opp');
        User busMngr = Protein_TestDataFactory.createUser('Business Manager');
        Product_Request__c pr2 = Protein_TestDataFactory.createProductRequest('Test PR2', Protein_TestDataFactory.RETAIL_MARKETCHANNEL, busMngr.Id, 
                                                                             EGG_OPP_REC_TYPE, 'Test Desc2', 'Test reason2', 200, System.today().addDays(20), opp.Id);
        lstPRs.add(pr2);
        Product_Request__c pr3 = Protein_TestDataFactory.createProductRequest('Test PR3', Protein_TestDataFactory.RETAIL_MARKETCHANNEL, busMngr.Id, 
                                                                             EGG_OPP_REC_TYPE, 'Test Desc3', 'Test reason3', 200, System.today().addDays(20), opp.Id);
        lstPRs.add(pr3);
        Product_Request__c pr4 = Protein_TestDataFactory.createProductRequest('Test PR4', Protein_TestDataFactory.RETAIL_MARKETCHANNEL, busMngr.Id, 
                                                                             EGG_OPP_REC_TYPE, 'Test Desc4', 'Test reason4', 200, System.today().addDays(20), opp.Id);
        lstPRs.add(pr4);
        Product_Request__c pr5 = Protein_TestDataFactory.createProductRequest('Test PR5', Protein_TestDataFactory.RETAIL_MARKETCHANNEL, busMngr.Id, 
                                                                             EGG_OPP_REC_TYPE, 'Test Desc5', 'Test reason5', 200, System.today().addDays(20), opp.Id);
        lstPRs.add(pr5);
        Product_Request__c pr6 = Protein_TestDataFactory.createProductRequest('Test PR6', Protein_TestDataFactory.RETAIL_MARKETCHANNEL, busMngr.Id, 
                                                                             EGG_OPP_REC_TYPE, 'Test Desc6', 'Test reason6', 200, System.today().addDays(20), opp.Id);
        lstPRs.add(pr6);
        Product_Request__c pr7 = Protein_TestDataFactory.createProductRequest('Test PR7', Protein_TestDataFactory.RETAIL_MARKETCHANNEL, busMngr.Id, 
                                                                             EGG_OPP_REC_TYPE, 'Test Desc7', 'Test reason7', 200, System.today().addDays(20), opp.Id);
        lstPRs.add(pr7);
        Product_Request__c pr8 = Protein_TestDataFactory.createProductRequest('Test PR8', Protein_TestDataFactory.RETAIL_MARKETCHANNEL, busMngr.Id, 
                                                                             EGG_OPP_REC_TYPE, 'Test Desc8', 'Test reason8', 200, System.today().addDays(20), opp.Id);
        lstPRs.add(pr8);
        Product_Request__c pr9 = Protein_TestDataFactory.createProductRequest('Test PR9', Protein_TestDataFactory.RETAIL_MARKETCHANNEL, busMngr.Id, 
                                                                             EGG_OPP_REC_TYPE, 'Test Desc9', 'Test reason9', 200, System.today().addDays(20), opp.Id);
        lstPRs.add(pr9);
        Product_Request__c pr10 = Protein_TestDataFactory.createProductRequest('Test PR10', Protein_TestDataFactory.RETAIL_MARKETCHANNEL, busMngr.Id, 
                                                                             EGG_OPP_REC_TYPE, 'Test Desc10', 'Test reason10', 200, System.today().addDays(20), opp.Id);
        lstPRs.add(pr10);
        
        //updates on all the PRs
        pr2.Sent_to_Pricer__c = false; // PR2 - Pricing_Due_Date__c and Pricing_Timeframe__c are blanks & Status__c != 'Accepted by BM'
        pr2.Status__c = DRAFT_STATUS;
        pr3.Pricing_Due_Date__c=system.today(); //PR3 - Pricing_Due_Date__c is not blank, Pricing_Timeframe__c is blank & Status__c != 'Accepted by BM'
        pr3.Sent_to_Pricer__c = false;
        pr3.Status__c = DRAFT_STATUS;
        pr4.Pricing_Due_Date__c=system.today(); //PR4 - Pricing_Due_Date__c is not blank, Pricing_Timeframe__c is blank & Status__c = 'Accepted by BM'
        pr4.Sent_to_Pricer__c = false;
        pr4.Status__c = ACCEPTED_BY_BM_STATUS;
        pr5.Pricing_Due_Date__c=system.today(); //PR5 - Pricing_Due_Date__c and Pricing_Timeframe__c are not blanks & Status__c = 'Accepted by BM'
        pr5.Pricing_Timeframe__c='12';
        pr5.Sent_to_Pricer__c = false;
        pr5.Status__c = ACCEPTED_BY_BM_STATUS;
        pr6.Pricing_Due_Date__c=system.today(); //PR6 - Pricing_Due_Date__c and Pricing_Timeframe__c are not blanks & Sent_to_Pricer__c=true
        pr6.Pricing_Timeframe__c='12';
        pr6.Sent_to_Pricer__c = true;
        pr6.Status__c = ACCEPTED_BY_BM_STATUS;
        pr7.Pricing_Due_Date__c=system.today(); //PR7 - Pricing_Due_Date__c and Pricing_Timeframe__c are not blanks & Status__c != 'Accepted by BM'
        pr7.Pricing_Timeframe__c='12';
        pr7.Sent_to_Pricer__c = false;
        pr7.Status__c = DRAFT_STATUS;
        pr8.Sent_to_Pricer__c = false; //PR8 - Pricing_Due_Date__c and Pricing_Timeframe__c are blanks & Status__c = 'Accepted by BM'
        pr8.Status__c = ACCEPTED_BY_BM_STATUS;
        pr9.Pricing_Timeframe__c='12'; //PR9 - Pricing_Due_Date__c is blank, Pricing_Timeframe__c is not blank & Status__c = 'Accepted by BM'
        pr9.Sent_to_Pricer__c = false;
        pr9.Status__c = ACCEPTED_BY_BM_STATUS;
        pr10.Pricing_Timeframe__c='12'; //PR10 - Pricing_Due_Date__c is blank, Pricing_Timeframe__c is not blank & Status__c != 'Accepted by BM'
        pr10.Sent_to_Pricer__c = false;
        pr10.Status__c = DRAFT_STATUS;
        
        update lstPRs;
        Protein_SendToPricerController.sendEmail(pr2.Id);
        Protein_SendToPricerController.sendEmail(pr3.Id);
        Protein_SendToPricerController.sendEmail(pr4.Id);
        Protein_SendToPricerController.sendEmail(pr5.Id);
        Protein_SendToPricerController.sendEmail(pr6.Id);
        Protein_SendToPricerController.sendEmail(pr7.Id);
        Protein_SendToPricerController.sendEmail(pr8.Id);
        Protein_SendToPricerController.sendEmail(pr9.Id);
        Protein_SendToPricerController.sendEmail(pr10.Id);
        
    }*/
    
    public static testMethod void sendToPricerCase2() { //Pricing_Due_Date__c and Pricing_Timeframe__c are blanks & Status__c != 'Accepted by BM'
        createTestMetaData();
        Product_Request__c pr = createTestData();
        System.assertEquals(pr.Name, TEST_PR_NAME);
        pr.Sent_to_Pricer__c = false;
        pr.Status__c = DRAFT_STATUS;
        update pr;
        Protein_SendToPricerController.sendEmail(pr.Id);
    }
    
    public static testMethod void sendToPricerCase3() { //Pricing_Due_Date__c is not blank, Pricing_Timeframe__c is blank & Status__c != 'Accepted by BM'
        createTestMetaData();
        Product_Request__c pr = createTestData();
        System.assertEquals(pr.Name, TEST_PR_NAME);
        pr.Pricing_Due_Date__c=system.today();
        pr.Sent_to_Pricer__c = false;
        pr.Status__c = DRAFT_STATUS;
        update pr;
        Protein_SendToPricerController.sendEmail(pr.Id);
    }
    
    public static testMethod void sendToPricerCase4() { //Pricing_Due_Date__c is not blank, Pricing_Timeframe__c is blank & Status__c = 'Accepted by BM'
        createTestMetaData();
        Product_Request__c pr = createTestData();
        System.assertEquals(pr.Name, TEST_PR_NAME);
        pr.Pricing_Due_Date__c=system.today();
        pr.Sent_to_Pricer__c = false;
        pr.Status__c = ACCEPTED_BY_BM_STATUS;
        update pr;
        Protein_SendToPricerController.sendEmail(pr.Id);
    }
    
    public static testMethod void sendToPricerCase5() { //Pricing_Due_Date__c and Pricing_Timeframe__c are not blanks & Status__c = 'Accepted by BM'
        createTestMetaData();
        Product_Request__c pr = createTestData();
        System.assertEquals(pr.Name, TEST_PR_NAME);
        pr.Pricing_Due_Date__c=system.today();
        pr.Pricing_Timeframe__c='12';
        pr.Sent_to_Pricer__c = false;
        pr.Status__c = ACCEPTED_BY_BM_STATUS;
        update pr;
        Protein_SendToPricerController.sendEmail(pr.Id);
    }
    
    public static testMethod void sendToPricerCase6() { //Pricing_Due_Date__c and Pricing_Timeframe__c are not blanks & Sent_to_Pricer__c=true
        createTestMetaData();
        Product_Request__c pr = createTestData();
        System.assertEquals(pr.Name, TEST_PR_NAME);
        pr.Pricing_Due_Date__c=system.today();
        pr.Pricing_Timeframe__c='12';
        pr.Sent_to_Pricer__c = true;
        pr.Status__c = ACCEPTED_BY_BM_STATUS;
        update pr;
        Protein_SendToPricerController.sendEmail(pr.Id);
    }
    
    public static testMethod void sendToPricerCase7() { //Pricing_Due_Date__c and Pricing_Timeframe__c are not blanks & Status__c != 'Accepted by BM'
        createTestMetaData();
        Product_Request__c pr = createTestData();
        System.assertEquals(pr.Name, TEST_PR_NAME);
        pr.Pricing_Due_Date__c=system.today();
        pr.Pricing_Timeframe__c='12';
        pr.Sent_to_Pricer__c = false;
        pr.Status__c = DRAFT_STATUS;
        update pr;
        Protein_SendToPricerController.sendEmail(pr.Id);
    }
    
    public static testMethod void sendToPricerCase8() { //Pricing_Due_Date__c and Pricing_Timeframe__c are blanks & Status__c = 'Accepted by BM'
        createTestMetaData();
        Product_Request__c pr = createTestData();
        System.assertEquals(pr.Name, TEST_PR_NAME);
        pr.Sent_to_Pricer__c = false;
        pr.Status__c = ACCEPTED_BY_BM_STATUS;
        update pr;
        Protein_SendToPricerController.sendEmail(pr.Id);
    }
    
    public static testMethod void sendToPricerCase9() { //Pricing_Due_Date__c is blank, Pricing_Timeframe__c is not blank & Status__c = 'Accepted by BM'
        createTestMetaData();
        Product_Request__c pr = createTestData();
        System.assertEquals(pr.Name, TEST_PR_NAME);
        pr.Pricing_Timeframe__c='12';
        pr.Sent_to_Pricer__c = false;
        pr.Status__c = ACCEPTED_BY_BM_STATUS;
        update pr;
        Protein_SendToPricerController.sendEmail(pr.Id);
    }
    
    public static testMethod void sendToPricerCase10() { //Pricing_Due_Date__c is blank, Pricing_Timeframe__c is not blank & Status__c != 'Accepted by BM'
        createTestMetaData();
        Product_Request__c pr = createTestData();
        System.assertEquals(pr.Name, TEST_PR_NAME);
        pr.Pricing_Timeframe__c='12';
        pr.Sent_to_Pricer__c = false;
        pr.Status__c = DRAFT_STATUS;
        update pr;
        Protein_SendToPricerController.sendEmail(pr.Id);
    }
    
}