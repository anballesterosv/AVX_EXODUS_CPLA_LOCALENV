/**
* @author       Ramesh Yenugula
* @version      1.0
* @createddate  April 15, 2019
* @name         CS_EmailMessageHandler_Test
* @description  Test Class for CS_EmailMessageHandler
* @modifiedby   
* @modifieddate 
*/
@isTest
public class CS_EmailMessageHandler_Test
{    
    /*
* @Description :
*  The below test method will cover the 'updateEmailMessageBeforeInsert' function  in  CS_EmailMessageHandler
* @author : Ramesh Yenugula
*/
    public static testMethod void testupdateEmailMessageBeforeInsert(){        
        List<EmailMessage> es = CS_TestDataHelper.getEmailMessageRecords(null,false,null,null);      
        Test.startTest();
        Try{
            CS_EmailMessageHandler.updateEmailMessageBeforeInsert(es );
        }
        Catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    /*
* @Description :
*  The below test method will cover the 'assignInternalCaseOwner' function  in  CS_EmailMessageHandler
* @author : Ramesh Yenugula
*/
    public static testMethod void testassignInternalCaseOwner_Test(){
        List<EmailMessage> es = CS_TestDataHelper.getEmailMessageRecords(null,false,null,null);      
        Test.startTest();
        Try{        
            CS_EmailMessageHandler.assignInternalCaseOwner(es);//updateCaseOwner
            //CS_EmailMessageHandler.updateCaseOwner();
            es = CS_TestDataHelper.getEmailMessageRecords(CS_SystemConstants.CASE_STATUS_CLOSED,true,CS_SystemConstants.CASE_REASON_DUPLICATE,null); 
            CS_EmailMessageHandler.assignInternalCaseOwner(es);
        }
        Catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        Test.stopTest();
    }

    public static testMethod void testassignInternalCaseOwnerCSR_Test(){
        List<EmailMessage> es = CS_TestDataHelper.getEmailMessageRecords(null,false,null,'ramesh@cargill.com');      
        Test.startTest();
        Try{        
            CS_EmailMessageHandler.assignInternalCaseOwner(es);//updateCaseOwner
            //CS_EmailMessageHandler.updateCaseOwner();
            es = CS_TestDataHelper.getEmailMessageRecords(CS_SystemConstants.CASE_STATUS_CLOSED,true,CS_SystemConstants.CASE_REASON_DUPLICATE,'ramesh@cargill.com'); 
            CS_EmailMessageHandler.assignInternalCaseOwner(es);
        }
        Catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        Test.stopTest();
    }

        /*
* @Description :
*  The below test method will cover the 'afterInsertEmailMessage' function  in  CS_EmailMessageHandler
* @author : Ramesh Yenugula
*/
    public static testMethod void testassignInternalCaseClosedStatus_Test(){
        List<EmailMessage> es = CS_TestDataHelper.getEmailMessageRecords('New',false,'Duplicate Case',null);      
        Test.startTest();
        Try{        
            CS_EmailMessageHandler.assignInternalCaseOwner(es);
            es = CS_TestDataHelper.getEmailMessageRecords(CS_SystemConstants.CASE_STATUS_CLOSED,true,CS_SystemConstants.CASE_REASON_DUPLICATE,null); 
            CS_EmailMessageHandler.afterInsertEmailMessage(es);
        }
        Catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        Test.stopTest();
    }

    public static testmethod void testupdateValidateFromAddress(){
        List<EmailMessage> es = CS_TestDataHelper.getEmailMessageRecords('New',false,'Duplicate Case',null);
        CS_EmailMessageHelper.updateValidateFromAddress(es,'test@gmail.com',new Set<Id>());
    }

    public static testmethod void testappendCaseNumberToSubject(){
        List<EmailMessage> es = CS_TestDataHelper.getEmailMessageRecords('New',false,'Duplicate Case',null);
        CS_EmailMessageHelper.appendCaseNumberToSubject(es,new Set<Id>{es[0].parentId});
    }
    
}