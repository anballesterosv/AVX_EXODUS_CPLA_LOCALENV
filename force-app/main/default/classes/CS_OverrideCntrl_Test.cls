/**
* @author       Ramesh Yenugula
* @version      1.0
* @createddate  April 12, 2019
* @name         CS_OverrideCntrl_Test
* @description  Test Class for CS_OverrideCntrl
* @modifiedby   
* @modifieddate 
*/

@isTest
public Class CS_OverrideCntrl_Test{
    
    /*
     * @Description :
     *  The below test method will cover the 'getcaseReason' function  in  CS_OverrideCntrl
     * @author : Ramesh Yenugula
     */
     public static testMethod void testgetcaseReason(){
       
        CS_TestDataHelper.insertCustomIntegrationProfileDetail();
        Account proteinServiceAccountForEntitlement = CS_TestDataHelper.createAccountRecord( CS_SystemConstants.DUMMY_ACCOUNT_NAME, 
                                                     CS_TestDataHelper.GLOBALACCOUNT_RECORD_TYPE, 
                                                     CS_TestDataHelper.INTERNAL_MARKETCHANNEL);
        Contact cRec = CS_TestDataHelper.createContactRecord( proteinServiceAccountForEntitlement.Id );
         //insert CSR1 case 
         Test.startTest();  
         try{      
	         Case caseRec = CS_TestDataHelper.createCaseRecord( cRec.Id,null,null,null,null,null,null);
	         String caseReason = CS_OverrideCntrl.getcaseReason(caseRec.id);
	         System.assertEquals(caseReason,caseRec.Reason);
         }
         Catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
         }
         Test.stopTest();    
     }
    
     /*
     * @Description :
     *  The below test method will cover the 'getknowledgeRec' function  in  CS_OverrideCntrl
     * @author : Ramesh Yenugula
     */
    public static testMethod void testgetknowledgeRec(){    
        knowledge__kav newArticle = new knowledge__kav(Title='test',summary='xyz',urlname='xyz');
        
        Test.startTest();
        try{
        	insert newArticle;
	        Map<Boolean,Knowledge__kav> returnArticleMap = CS_OverrideCntrl.getknowledgeRec(newArticle.id);
	        System.assertEquals(returnArticleMap.get(false).id,newArticle.id);
	        knowledge__kav returnArticles = CS_OverrideCntrl.getknowledgeRecs(newArticle.id);
	        System.assertEquals(returnArticles.id,newArticle.id);
        }
        Catch(Exception e) {
            System.debug('The following exception has occurred: ' + e);
            System.debug('Line Number:  ' + e.getLineNumber());
            System.debug('StackTrace:  ' + e.getStackTraceString());
         }
        Test.stopTest();
    } 
    
     /*
     * @Description :
     *  The below test method will cover the 'publishknowledge' function  in  CS_OverrideCntrl
     * @author : Ramesh Yenugula
     */
    public static testMethod void testpublishArticle(){    
        knowledge__kav newArticle = new knowledge__kav(Title='test',summary='xyz',urlname='xyz');
        
        Test.startTest();
        try{
        	insert newArticle;
        	knowledge__kav knowledgeArticle = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: newArticle.Id];
        	System.debug('Knowledge Article : '+knowledgeArticle);
	        CS_OverrideCntrl.publishArticle(knowledgeArticle.KnowledgeArticleId);
        }
        Catch(Exception e) {
            System.debug('The following exception has occurred: ' + e);
            System.debug('Line Number:  ' + e.getLineNumber());
            System.debug('StackTrace:  ' + e.getStackTraceString());
         }
        Test.stopTest();
    } 
    
}