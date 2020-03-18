/**
Class Name: CPG_Accountteam_Scheduler 
Description: This scheduler class for Account Team sharing batch
CreatedDate: 12-04-2017
**/
global class CPG_Accountteam_Scheduler implements schedulable{
    global void execute(SchedulableContext sc) {
        CPG_AccountTeamBatch accTeamBatch= new CPG_AccountTeamBatch(); 
        database.executebatch(accTeamBatch);
    }
}