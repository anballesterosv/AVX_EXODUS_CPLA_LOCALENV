/**
Class Name: Protein_notifyInactiveUsers_Scheduler
Description: This class is a scheduler for Protein_notifyUsersOnInactivity batch class.

Developer: Sri Harshitha Bandi
CreatedDate: 16/12/2019
**/

global class Protein_notifyInactiveUsers_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Protein_notifyUsersOnInactivity usersBatch= new Protein_notifyUsersOnInactivity(); 
        database.executebatch(usersBatch);
    }
}