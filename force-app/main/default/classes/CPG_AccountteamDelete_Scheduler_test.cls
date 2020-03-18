/**
Class Name: CPG_AccountteamDelete_Schedulert_Test
Description: This is test class for scheduler class CPG_AccountteamDelete_Scheduler
CreatedDate: 05-30-2018
**/
@isTest
public class CPG_AccountteamDelete_Scheduler_test{  

    public static testmethod void scheduleAccountTeamBatch(){
        Test.startTest();
        CPG_AccountteamDelete_Scheduler sh1 = new CPG_AccountteamDelete_Scheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Account Team Scheduler', sch, sh1);
        Test.stopTest();
    }  

}