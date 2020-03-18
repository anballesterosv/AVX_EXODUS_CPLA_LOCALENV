/**
     *  SFA_TestFactory_Util 
     
     * @author          CTS\Vaishali Thite
     * @version         1.0
     * @date            2017-05-05
     * @description     Opportunity Clone Batch test class
    */
@isTest
private class OpportunityClone_Test{
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    static testmethod void unitTestBatch(){
        //test Batch
        test.startTest();
        List<Account> lstAcc =  SFA_TestFactory_Util.createTestAccounts(2);
        System.assertNotEquals(lstAcc.size(),0); 
        List<Opportunity> lstOpp =  SFA_TestFactory_Util.createTestOpportunity(2,lstAcc ); 
        System.assertNotEquals(lstOpp.size(),0); 
        
        OpportunityClone objbatch = new OpportunityClone(); //ur batch class
        database.executebatch(objbatch); 
        test.stopTest();
    }
    
    static testMethod void unitTestBatchSchedule(){
     
     test.startTest();
         
     List<Account> lstAcc =  SFA_TestFactory_Util.createTestAccounts(2);
     System.assertNotEquals(lstAcc.size(),0); 
     List<Opportunity> lstOpp =  SFA_TestFactory_Util.createTestOpportunity(2,lstAcc ); 
     System.assertNotEquals(lstOpp.size(),0); 
    // List<OpportunityLineItem> lstLineItem=SFA_TestFactory_Util.createTestOpportunityLineItem(2,lstOpp );
   //  System.assertNotEquals(lstLineItem.size(),0);
     
     // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new  OpportunityCloneSched());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
     test.stopTest();   
     
    }
    
    
}