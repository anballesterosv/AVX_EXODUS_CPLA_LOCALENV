/**
* @author       Manikandan Radhakrishnapillai 
* @version      1.0
* @createddate  April 10, 2019
* @name         CS_CaseHandler_Test
* @description  Test Class for CS_CaseHandler
* @modifiedby   
* @modifieddate 
*/ 

@isTest
public class CS_CaseHandler_Test {
    
    /**
* @Description :
*  The below test method will cover the 'beforeInsertCase' function as well as 'beforeUpdateCase' functions in  CS_CaseHandler
* 
* @author : Manikandan Radhakrishnapillai
*/
    public static testMethod void testbeforeInsertCase(){
        
        try{
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
            
            //create caseRecords with owner as running User
            List<case> caseList = CS_TestDataHelper.createCaseRecordList( 1,cRec.Id, null, null);
            
            // cretae caseRecord with dummy Account as parent Account
            List<case> caseList1 = CS_TestDataHelper.createCaseRecordList( 1,cRec.Id,null,null );
            caseList[0].AccountId = proteinServiceAccountForEntitlement.Id;
            
            List<case> caseList2 = CS_TestDataHelper.createCaseRecordList( 1, cRec.Id, CS_SystemConstants.PROTEIN_SERVICE_QUEUE, null );
            
            //case record
            Case caseRec = CS_TestDataHelper.createCaseRecord( cRec.Id,null,null,null,null,null,null);
            
            
            Test.startTest();
            //insert case record
            insert caseList;
            
            System.assertNotEquals(caseList[0].AccountId, null);
            insert caseList1;
            
            System.assertEquals(caseList1[0].AccountId, null);
            insert caseList2; 
            
            Test.stopTest();
        }catch(Exception ex){
            System.debug('Exception : '+ex);
        }
    }
    
    
    /**
* @Description :
*  The below test method will cover the 'beforeInsertCase' function as well as 'beforeUpdateCase' functions in  CS_CaseHandler
* 
* @author : Manikandan Radhakrishnapillai
*/
    public static testMethod void testbeforeUpdateCase(){
        
        try{
            //Insert Custom Setting : Integration_profile__c record for bypassing the validation Rule 'Prospect_Account_Validation' on Account
            CS_TestDataHelper.insertCustomIntegrationProfileDetail();
            
            Account payerAccount = CS_TestDataHelper.createAccountRecord( 'Test Payer Account', 
                                                                         CS_TestDataHelper.GLOBALACCOUNT_RECORD_TYPE, 
                                                                         CS_TestDataHelper.INTERNAL_MARKETCHANNEL);
            //create dummy Account for Entitlement
            Account proteinServiceAccountForEntitlement = CS_TestDataHelper.createAccountRecord( CS_SystemConstants.DUMMY_ACCOUNT_NAME, 
                                                                                                CS_TestDataHelper.GLOBALACCOUNT_RECORD_TYPE, 
                                                                                                CS_TestDataHelper.INTERNAL_MARKETCHANNEL);
            //create Commercial Account
            Account commercialAccount = CS_TestDataHelper.createAccountRecord( 'testAcc' , 
                                                                              CS_TestDataHelper.COMMERCIALACCOUNT_RECORD_TYPE, 
                                                                              CS_TestDataHelper.FOODSERVICE_MARKETCHANNEL); 
            
            Account proteinIngradientsCommercialAccount = CS_TestDataHelper.createAccountRecord( 'piTestAcc' , 
                                                                                                CS_TestDataHelper.COMMERCIALACCOUNT_RECORD_TYPE, 
                                                                                                CS_TestDataHelper.PI_MARKETCHANNEL);
            
            Bill_To__c billto = CS_TestDataHelper.createBillTo(payerAccount.id);
            Ship_To__c shipTo = CS_TestDataHelper.createShipTo(billto.id, payerAccount.id, proteinIngradientsCommercialAccount.id);
            System.debug('\n\n proteinServiceAccountForEntitlement : '+proteinServiceAccountForEntitlement+'\n\n');
            
            //create entitlement records
            CS_TestDataHelper.createEntitlementRecords( proteinServiceAccountForEntitlement.Id );
            
            //createContact using the dummy Account
            Contact cRec = CS_TestDataHelper.createContactRecord( commercialAccount.Id );
            
            //case record
            Case caseRec = CS_TestDataHelper.createCaseRecord( cRec.Id,null,null,null,null,null,null);
            
            Test.startTest();
            if(shipTo != null){
                caseRec.CS_Ship_To__c = shipTo.id;
            }
            try{
                update caseRec;
            }catch(Exception e){
                System.debug('AssertEquals'+e.getMessage());
                Boolean expectedExceptionThrown;
                if(e.getMessage().contains(Label.CS_Ship_To_Contact_Relation_Error_Message)){
                    expectedExceptionThrown = true;
                }else{
                    expectedExceptionThrown = false;
                }
                System.assertEquals(expectedExceptionThrown,true);
            }
            Test.stopTest();
        }catch(Exception ex){
            System.debug('Exception occured : '+ex);
        }
        
    }
    
    //test method to test Email Message cloning
    public  static testmethod void TestReparentChildRecords() 
    {
        try{
            //Insert Custom Setting : Integration_profile__c record for bypassing the validation Rule 'Prospect_Account_Validation' on Account
            CS_TestDataHelper.insertCustomIntegrationProfileDetail();
            
            Account payerAccount = CS_TestDataHelper.createAccountRecord( 'Test Payer Account', 
                                                                         CS_TestDataHelper.GLOBALACCOUNT_RECORD_TYPE, 
                                                                         CS_TestDataHelper.INTERNAL_MARKETCHANNEL);
            //create dummy Account for Entitlement
            Account proteinServiceAccountForEntitlement = CS_TestDataHelper.createAccountRecord( CS_SystemConstants.DUMMY_ACCOUNT_NAME, 
                                                                                                CS_TestDataHelper.GLOBALACCOUNT_RECORD_TYPE, 
                                                                                                CS_TestDataHelper.INTERNAL_MARKETCHANNEL);
            //create Commercial Account
            Account commercialAccount = CS_TestDataHelper.createAccountRecord( 'testAcc' , 
                                                                              CS_TestDataHelper.COMMERCIALACCOUNT_RECORD_TYPE, 
                                                                              CS_TestDataHelper.FOODSERVICE_MARKETCHANNEL); 
            
            Account proteinIngradientsCommercialAccount = CS_TestDataHelper.createAccountRecord( 'piTestAcc' , 
                                                                                                CS_TestDataHelper.COMMERCIALACCOUNT_RECORD_TYPE, 
                                                                                                CS_TestDataHelper.PI_MARKETCHANNEL);
            
            Bill_To__c billto = CS_TestDataHelper.createBillTo(payerAccount.id);
            Ship_To__c shipTo = CS_TestDataHelper.createShipTo(billto.id, payerAccount.id, proteinIngradientsCommercialAccount.id);
            System.debug('\n\n proteinServiceAccountForEntitlement : '+proteinServiceAccountForEntitlement+'\n\n');
            
            //create entitlement records
            CS_TestDataHelper.createEntitlementRecords( proteinServiceAccountForEntitlement.Id );
            
            //createContact using the dummy Account
            Contact cRec = CS_TestDataHelper.createContactRecord( commercialAccount.Id );
            
            //case record
            Case caseRec = CS_TestDataHelper.createCaseRecord( cRec.Id,null,null,null,null,null,null);
            Case parentCaseRec = CS_TestDataHelper.createCaseRecord( cRec.Id,null,null,null,null,null,null);
            //case comment records
            List<CaseComment> cList = CS_TestDataHelper.createCaseComments( caseRec.id  );
            
            //email message record
            List<EmailMessage> emailMSgList = CS_TestDataHelper.createEmailMessageRecord( caseRec.id );
            
            insert emailMSgList;
            Set<Id> emailMsgIds = new Set<Id>();
            for(EmailMessage e: emailMSgList){
                emailMsgIds.add(e.id);
            }
            //insert Attachment records
            List<Attachment> atist = CS_TestDataHelper.CreateAttachments(caseRec.id );
            List<Case> caseList = new List<Case>{caseRec};
                //insert content document record
                CS_TestDataHelper.CreateContentDocument( emailMSgList[0].id );
            
            Test.startTest();
            caseRec.OwnerId = UserInfo.getUserId();
            caseRec.OwnerId = UserInfo.getUserId();
            caseRec.ParentId = parentCaseRec.id;
            update caseRec;
            System.assertEquals(caseRec.ParentId, parentCaseRec.id);
            
            //call invovocable method
            CS_CaseHelper.reparentChildRecords( caseList,emailMsgIds,false );
            Map<String,String> attachmentMap = new Map<String,String>{caseRec.id=>caseRec.id};
            CS_CaseHelper.insertAttachments(null,attachmentMap);
            Test.stopTest();
        }catch(Exception ex){
            System.debug('Exception occured : '+ex);
        }
        
        
    }
}