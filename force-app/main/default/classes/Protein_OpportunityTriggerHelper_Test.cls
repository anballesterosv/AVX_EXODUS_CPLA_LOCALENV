@isTest
public class Protein_OpportunityTriggerHelper_Test {
    public static testMethod void blockOppDeletionWithCMRs_test() {
        Protein_TestDataFactory.insertCustomIntegrationProfileDetail();
        Account commercialAccount = Protein_TestDataFactory.createAccountRecord('Test Commercial Account', Protein_TestDataFactory.COMMERCIALACCOUNT_RECORD_TYPE, 
	        																	Protein_TestDataFactory.FOODSERVICE_MARKETCHANNEL);
        Opportunity opp = Protein_TestDataFactory.createOpportunityRecord('Test Opp', Protein_TestDataFactory.EGG_OPP_RT, commercialAccount.Id,
                                                                          100, Protein_TestDataFactory.EXPLORE_OPP_STAGE, System.today().addDays(20),
                                                                         Protein_TestDataFactory.POUND_OPP_UOM);
        CustomerMeetingReport__c cmr = Protein_TestDataFactory.createCustomerMeetingReportRecord(commercialAccount.Id);
        CustomerMeetingReportOpp__c cmro = Protein_TestDataFactory.createCustomerMeetingReportOppRecord(cmr.Id, opp.Id);
        //The below lines are the code coverage for the Apex Trigger 'Protein_CustomerMeetingReportOppTrigger'
        Opportunity opp1 = Protein_TestDataFactory.createOpportunityRecord('Test Opp1', Protein_TestDataFactory.EGG_OPP_RT, commercialAccount.Id,
                                                                          100, Protein_TestDataFactory.EXPLORE_OPP_STAGE, System.today().addDays(20),
                                                                         Protein_TestDataFactory.POUND_OPP_UOM);
        cmro.Opportunity__c = opp1.Id;
        update cmro;
        //The code for the above mentioned trigger coverage ends here.
        try{
            delete opp;
        }
        catch(DMLException ex){
            system.debug('Error msg: '+ex.getDmlMessage(0));
            System.assertEquals('You cannot delete this Opportunity as it has one or more Customer Meeting Reports attached to it.', ex.getDmlMessage(0));
        }
        
    }

}