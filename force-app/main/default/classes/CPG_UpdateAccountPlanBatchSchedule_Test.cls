/**
@Author Vaishali Thite
@name CPG_UpdateAccountPlanBatchSchedule_Test 
@CreateDate Sept 19, 2017
@Description Test class for CPG_UpdateAccountPlanBatchSchedule
@Version <1.0>
@reference : CPG_UpdateAccountPlanBatchSchedule
@Modifiedby :  
@ModifiedDate: 
*/ 
@isTest
private class CPG_UpdateAccountPlanBatchSchedule_Test {
     public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    private static testMethod void testUpdateSiebel() {
        User u = CPG_TestFactory_Util.createTestUser('System Administrator');
        test.startTest();
        system.runAs(u) {
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new  CPG_ScheduleAccountPlanBatch());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
            
        }
        test.stopTest();
    }

}