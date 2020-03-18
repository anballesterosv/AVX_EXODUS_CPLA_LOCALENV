/**
Class Name: Protein_CMRdocController_Test
Description: This test class is used for code coverage of 'Protein_CMRdocController' controller extension.
Developer: Sri Harshitha Bandi
CreatedDate: 03/12/2019
**/
@isTest
public class Protein_CMRdocController_Test {
    public static testMethod void cmrDocControllerTest() {
        Protein_TestDataFactory.insertCustomIntegrationProfileDetail();
        Account acc = Protein_TestDataFactory.createAccountRecord('Test Commercial Account', Protein_TestDataFactory.COMMERCIALACCOUNT_RECORD_TYPE, 
                                                                  Protein_TestDataFactory.FOODSERVICE_MARKETCHANNEL);
        /*Opportunity opp = Protein_TestDataFactory.createOpportunityRecord('Test Opp', Protein_TestDataFactory.EGG_OPP_RT, acc.Id,
                                                                          100, Protein_TestDataFactory.EXPLORE_OPP_STAGE, System.today().addDays(20),
                                                                          Protein_TestDataFactory.POUND_OPP_UOM);*/
        CustomerMeetingReport__c cmr = Protein_TestDataFactory.createCustomerMeetingReportRecord(acc.Id);
        cmr.MeetingDate__c = System.today();
        cmr.Customer_Attendees__c = 'Test User';
        update cmr;
        //Create a task for this CMR
        User u = Protein_TestDataFactory.createUser('System Administrator');
        Task tsk = Protein_TestDataFactory.createTask(cmr.Id, 'Call', u.Id, 'Open', System.today()+10);
        System.assertEquals('Call', tsk.Subject);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(cmr);
        Test.setCurrentPageReference(new PageReference('Page.Protein_CMRTemplate')); 
        System.currentPageReference().getParameters().put('id', cmr.Id);
        Protein_CMRdocController cntrl = new Protein_CMRdocController(controller);
        System.debug(controller + ' ' +cntrl);
    }
    
}