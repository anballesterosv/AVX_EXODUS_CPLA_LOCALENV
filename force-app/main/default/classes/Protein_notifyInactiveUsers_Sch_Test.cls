@isTest(seeAllData=true)
public class Protein_notifyInactiveUsers_Sch_Test {
    
    public static testMethod void testSchedule() {
        Test.startTest();
        Protein_notifyInactiveUsers_Scheduler sh1= new Protein_notifyInactiveUsers_Scheduler();
        String sch = '0 0 23 * * ?';
        String jobId = System.schedule('Test User Inactivity', sch, sh1);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(sch, ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
    }

}