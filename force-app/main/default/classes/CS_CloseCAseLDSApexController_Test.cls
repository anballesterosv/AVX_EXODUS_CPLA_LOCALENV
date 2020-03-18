/**
    * @author       Manikandan Radhakrishnapillai 
    * @version      1.0
    * @createddate  July 03, 2019
    * @name         CS_CloseCAseLDSApexController_Test
    * @description  Test Class for CS_CloseCAseLDSApexController
    * @modifiedby   
    * @modifieddate 
    */ 

@isTest
public class CS_CloseCAseLDSApexController_Test {

    public static testmethod void testgetCaseContainsOpenEmailMessages(){
        	
        	//Insert Custom Setting : Integration_profile__c record for bypassing the validation Rule 'Prospect_Account_Validation' on Account
            CS_TestDataHelper.insertCustomIntegrationProfileDetail();
        	
            //create dummy Account for Entitlement
            Account proteinServiceAccountForEntitlement = CS_TestDataHelper.createAccountRecord( CS_SystemConstants.DUMMY_ACCOUNT_NAME, 
                                                                                                 CS_TestDataHelper.GLOBALACCOUNT_RECORD_TYPE, 
                                                                                                 CS_TestDataHelper.INTERNAL_MARKETCHANNEL);
            //create Commercial Account
            Account commercialAccount = CS_TestDataHelper.createAccountRecord( 'testAcc' , 
                                                                                CS_TestDataHelper.COMMERCIALACCOUNT_RECORD_TYPE, 
                                                                                CS_TestDataHelper.FOODSERVICE_MARKETCHANNEL); 
            
            System.debug('\n\n proteinServiceAccountForEntitlement : '+proteinServiceAccountForEntitlement+'\n\n');
            
            //create entitlement records
            CS_TestDataHelper.createEntitlementRecords( proteinServiceAccountForEntitlement.Id );
            
            //createContact using the dummy Account
            Contact cRec = CS_TestDataHelper.createContactRecord( proteinServiceAccountForEntitlement.Id );
            Case caseRec = CS_TestDataHelper.createCaseRecord( cRec.Id,null,null,null, null, null);
        	caseRec.CS_Is_New_Email__c = true;
        	update caseRec;
        	CS_CloseCAseLDSApexController.getCaseContainsOpenEmailMessages(caseRec.id);
    }
    
}