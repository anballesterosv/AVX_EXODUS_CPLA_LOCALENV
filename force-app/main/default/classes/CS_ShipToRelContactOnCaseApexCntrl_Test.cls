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
public class CS_ShipToRelContactOnCaseApexCntrl_Test {
    
        /**
         * @Description :
         *  The below test method will cover the getShipToContactFromCase
         * 
         * @author : Manikandan Radhakrishnapillai
         */ 
    public static testMethod void testgetShipToContactFromCase(){
        
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
            
            Case caseRec = CS_TestDataHelper.createCaseRecord( cRec.Id,null,null,null,null,null,null);
            CS_ShipToRelContactOnCaseApexController.DataTableResponse objDataTableResponse = CS_ShipToRelContactOnCaseApexController.getShipToContactFromCase(caseRec.id);
            Case cserr = [SELECT Id, CS_Ship_To__c, ContactId, AccountId FROM Case LIMIT 1];
            cserr.CS_Ship_To__c = shipTo.id;
            update cserr;
            CS_ShipToRelContactOnCaseApexController.DataTableResponse objDataTableResponseErr = CS_ShipToRelContactOnCaseApexController.getShipToContactFromCase(cserr.id);
            System.debug('objDataTableResponseErr : '+objDataTableResponseErr);
            System.assertNotEquals(objDataTableResponseErr.lstDataTableColumns,null);
            
            //
            
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
    public static testMethod void testmapShipToCase(){
        
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
            
            
            
            Case caseRec = CS_TestDataHelper.createCaseRecord( cRec.Id,null,null,null,null,null,null);
            CS_Ship_To_Contact_Relation__c shipToRelation = CS_TestDataHelper.createShipToContactRelation(cRec.id, shipTo.id);
            System.debug('shipToRelation.CS_Ship_To__r.id:' +shipToRelation.CS_Ship_To__r.id);
            String jsonShipToRelation = JSON.serialize(shipToRelation);
            System.debug('jsonShipToRelation :' +jsonShipToRelation);
            Boolean b = CS_ShipToRelContactOnCaseApexController.mapShipToCase(jsonShipToRelation, caseRec.Id);
            System.assertEquals(TRUE, b);
            Boolean berr = CS_ShipToRelContactOnCaseApexController.mapShipToCase(null, caseRec.Id);
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
            CS_ShipToRelContactOnCaseApexController.getShipToContactFromCase('test');
            //CS_ShipToRelContactOnCaseApexController.getlstDataTableData(new CS_ShipToRelContactOnCaseApexController.DataTableResponse(),new List<String>());
            System.assertEquals(null,null);
       }catch(Exception ex){
            System.debug('Exception ex : '+ ex);
       }
    }
  
}