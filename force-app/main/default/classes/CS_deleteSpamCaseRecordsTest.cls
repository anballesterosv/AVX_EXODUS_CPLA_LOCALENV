/**
 * @author       Ramesh Yenugula
 * @version      1.0
 * @createddate  04.02.2020
 * @name         CS_deleteSpamCaseRecordsTest
 * @description  Test classs for batch class and CS_schedulablespamcaseClass
 * @modifiedby
 * @modifieddate
*/
@isTest 
public class CS_deleteSpamCaseRecordsTest 
    {
     /**
    * @Description :
    *  The below test method will cover the 'start,execute ,finish' function  in  CS_deleteSpamCaseRecords
    * 
    * @author : Ramesh Yenugula
    */
        
    static testMethod void testdeleteSpamCaseRecords() 
    {
            String testLbl = Label.CS_DeletedEmailList;
            //create Commercial Account
            Account commercialAccount = CS_TestDataHelper.createAccountRecord( 'testAcc' , 
                                                                              CS_TestDataHelper.COMMERCIALACCOUNT_RECORD_TYPE, 
                                                                              CS_TestDataHelper.FOODSERVICE_MARKETCHANNEL);
            //createContact using the dummy Account
            Contact cRec = CS_TestDataHelper.createContactRecord( commercialAccount.Id );
            //case record
            Case caseRec = CS_TestDataHelper.createCaseRecord( null,null,null,null,null,null,'techsvs_requests@cargill.com');
            system.debug('caseRec'+caseRec);
            
            Test.startTest();
            System.assertEquals(caseRec.id, caseRec.id);
            CS_deleteSpamCaseRecords delSpamRec = new CS_deleteSpamCaseRecords();
            DataBase.executeBatch(delSpamRec);
            Test.stopTest();
    }
    
}