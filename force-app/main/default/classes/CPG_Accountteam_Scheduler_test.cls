/**
Class Name: CPG_Accountteam_Scheduler 
Description: This scheduler class for Account Team sharing batch
CreatedDate: 12-04-2017
**/
@isTest
public class CPG_Accountteam_Scheduler_test{  

    public static testmethod void scheduleAccountTeamBatch(){
        Test.startTest();
        CPG_Accountteam_Scheduler sh1 = new CPG_Accountteam_Scheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Account Team Scheduler', sch, sh1);
        Test.stopTest();
    }  

}