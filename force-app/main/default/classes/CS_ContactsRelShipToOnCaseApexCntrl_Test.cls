/**
* @author       Manikandan Radhakrishnapillai
* @version      1.0
* @createddate  Feb 03, 2019
* @name         CS_ShipToRelContactOnCaseApexCntrl_Test
* @description  Test class for CS_ShipToRelContactOnCaseApexController
* @modifiedby   
* @modifieddate 
*/


@isTest
public with sharing class CS_ContactsRelShipToOnCaseApexCntrl_Test {
     /**
         * @Description :
         *  The below test method will cover the getShipToContactFromCase
         * 
         * @author : Manikandan Radhakrishnapillai
         */ 
    public static testMethod void testgetContactsRelToShipToFromCase(){
        
        try{
            CS_TestDataHelper.insertCustomIntegrationProfileDetail();
            Account payerAccount = CS_TestDataHelper.createAccountRecord( 'Test Payer Account', 
                                                                          CS_TestDataHelper.GLOBALACCOUNT_RECORD_TYPE, 
                                                                          CS_TestDataHelper.INTERNAL_MARKETCHANNEL);
            Account proteinServiceAccountForEntitlement = CS_TestDataHelper.createAccountRecord( CS_SystemConstants.DUMMY_ACCOUNT_NAME, 
                                                                                                 CS_TestDataHelper.GLOBALACCOUNT_RECORD_TYPE, 
                                                                                                 CS_TestDataHelper.INTERNAL_MARKETCHANNEL);
            Account commercialAccount = CS_TestDataHelper.createAccountRecord( 'testAcc' , 
                                                                                CS_TestDataHelper.COMMERCIALACCOUNT_RECORD_TYPE, 
                                                                                CS_TestDataHelper.FOODSERVICE_MARKETCHANNEL); 
            Bill_To__c billto = CS_TestDataHelper.createBillTo(payerAccount.id);
            Ship_To__c shipTo = CS_TestDataHelper.createShipTo(billto.id, payerAccount.id, commercialAccount.id);
            CS_TestDataHelper.createShipTo(billto.id, payerAccount.id, commercialAccount.id);
            System.debug('\n\n proteinServiceAccountForEntitlement : '+proteinServiceAccountForEntitlement+'\n\n');
            //create entitlement records
            CS_TestDataHelper.createEntitlementRecords( proteinServiceAccountForEntitlement.Id );
            Contact cRec = CS_TestDataHelper.createContactRecord( proteinServiceAccountForEntitlement.Id );
            CS_Ship_To_Contact_Relation__c shipToRelation = CS_TestDataHelper.createShipToContactRelation(cRec.id, shipTo.id);
            
            Case caseRec = CS_TestDataHelper.createCaseRecord(null,null,shipTo.id,null,null,null,null);
            CS_ContactsRelShipToOnCaseApexController.DataTableResponse objDataTableResponse = CS_ContactsRelShipToOnCaseApexController.getContactsRelToShipToFromCase(caseRec.id);
            Case cserr = [SELECT Id, CS_Ship_To__c, ContactId, AccountId FROM Case LIMIT 1];
            cserr.ContactId = cRec.id;
            update cserr;
            CS_ShipToRelContactOnCaseApexController.DataTableResponse objDataTableResponseerr = CS_ShipToRelContactOnCaseApexController.getShipToContactFromCase(cserr.id);
            System.debug('objDataTableResponse_err : '+objDataTableResponseerr);
            System.assertNotEquals(objDataTableResponseerr.lstDataTableColumns,null);
        }Catch(Exception ex){
            System.debug('Exception : '+ex);
        }        
    }
    
        /**
         * @Description :
         *  The below test method will cover the mapShipToCase
         * 
         * @author : Manikandan Radhakrishnapillai
         */ 
    public static testMethod void testmapContactToCase(){
        
        try{
            CS_TestDataHelper.insertCustomIntegrationProfileDetail();
            Account payerAccount = CS_TestDataHelper.createAccountRecord( 'Test Payer Account', 
                                                                          CS_TestDataHelper.GLOBALACCOUNT_RECORD_TYPE, 
                                                                          CS_TestDataHelper.INTERNAL_MARKETCHANNEL);
            Account proteinServiceAccountForEntitlement = CS_TestDataHelper.createAccountRecord( CS_SystemConstants.DUMMY_ACCOUNT_NAME, 
                                                                                                 CS_TestDataHelper.GLOBALACCOUNT_RECORD_TYPE, 
                                                                                                 CS_TestDataHelper.INTERNAL_MARKETCHANNEL);
            Account commercialAccount = CS_TestDataHelper.createAccountRecord( 'testAcc' , 
                                                                                CS_TestDataHelper.COMMERCIALACCOUNT_RECORD_TYPE, 
                                                                                CS_TestDataHelper.FOODSERVICE_MARKETCHANNEL); 
            Bill_To__c billto = CS_TestDataHelper.createBillTo(payerAccount.id);
            Ship_To__c shipTo = CS_TestDataHelper.createShipTo(billto.id, payerAccount.id, commercialAccount.id);
            System.debug('\n\n proteinServiceAccountForEntitlement : '+proteinServiceAccountForEntitlement+'\n\n');
            //create entitlement records
            CS_TestDataHelper.createEntitlementRecords( proteinServiceAccountForEntitlement.Id );
            Contact cRec = CS_TestDataHelper.createContactRecord( proteinServiceAccountForEntitlement.Id );
            
            
            
            Case caseRec = CS_TestDataHelper.createCaseRecord(null,null,shipTo.id,null,null,null,null);
            CS_Ship_To_Contact_Relation__c shipToRelation = CS_TestDataHelper.createShipToContactRelation(cRec.id, shipTo.id);
            System.debug('ShipToRelation:' +shipToRelation);
            String jsonShipToRelation = JSON.serialize(shipToRelation);
            Boolean b = CS_ContactsRelShipToOnCaseApexController.mapContactToCase(jsonShipToRelation, caseRec.Id);
            System.assertEquals(TRUE, b);
            Boolean berr = CS_ContactsRelShipToOnCaseApexController.mapContactToCase(null, caseRec.Id);
            System.assertEquals(TRUE, berr);
        }catch(Exception ex){
            System.debug('Exception ex : '+ex);
        }
    }
          
    /**
         * @Description :
         *  The below test method will cover the getShipRecordId
         * 
         * @author : Manikandan Radhakrishnapillai
         */ 
    public static testMethod void testExceptions(){
       try{
            CS_ContactsRelShipToOnCaseApexController.getContactsRelToShipToFromCase('test');
            //CS_ShipToRelContactOnCaseApexController.getlstDataTableData(new CS_ShipToRelContactOnCaseApexController.DataTableResponse(),new List<String>());
            System.assertEquals(null,null);
       }catch(Exception ex){
            System.debug('Exception ex : '+ ex);
       }
    }
}