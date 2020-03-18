/**
@Author Vaishali Thite
@name CPG_RunBatchSchedule_Test 
@CreateDate  Nov 22, 2017
@Description Test class for cust profile & account batch scheduler
@Version <1.0>
@reference : CPG_ScheduleCustomerProfileBatch & CPG_ScheduleAccountBatch
@Modifiedby :  Added cust profile & account batch schedule test coverage methods
@ModifiedDate:
*/ 
@isTest
private class CPG_RunBatchSchedule_Test {
     public static String CRON_EXP = '0 0 0 15 3 ? 2022';
   
    private static testMethod void testUpdateScheduleAcc() {
            User u = CPG_TestFactory_Util.createTestUser('System Administrator');
            test.startTest();
            system.runAs(u) {
                // Schedule the test job
                String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new   CPG_ScheduleAccountBatch());
                // Get the information from the CronTrigger API object
                CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
                // Verify the expressions are the same
                System.assertEquals(CRON_EXP, ct.CronExpression);
                  
            }
            test.stopTest();
    }
     private static testMethod void testUpdateScheduleCustProfile() {
            User u = CPG_TestFactory_Util.createTestUser('System Administrator');
            test.startTest();
            system.runAs(u) {
                // Schedule the test job
                String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new  CPG_ScheduleCustomerProfileBatch());
                // Get the information from the CronTrigger API object
                CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
                // Verify the expressions are the same
                System.assertEquals(CRON_EXP, ct.CronExpression);
                  
            }
            test.stopTest();
    }
   
}