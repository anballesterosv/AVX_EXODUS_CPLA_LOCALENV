/**
Class Name: CPG_AccountteamDelete_Scheduler 
Description: This scheduler class for Account Team sharing batch
CreatedDate: 12-04-2017
**/
global class CPG_AccountteamDelete_Scheduler implements schedulable{
    global void execute(SchedulableContext sc) {
        CPG_AccountTeamDeleteCustProfileShare  accTeamDelBatch= new CPG_AccountTeamDeleteCustProfileShare(); 
        database.executebatch(accTeamDelBatch);
    }
}