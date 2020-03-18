/**
 * @author       Ramesh Yenugula
 * @version      1.0
 * @createddate 26.01.2020
 * @name         CS_schedulablespamcaseClass 
 * @description Schedulable class for Schedul CS_deleteSpamCaseRecords 
 * @modifiedby
 * @modifieddate
*/
global class CS_schedulablespamcaseClass implements Schedulable{

    // This method is used schdule the  this batch Class CS_deleteSpamCaseRecords  
    public void  execute(SchedulableContext ctx){    
        CS_deleteSpamCaseRecords deleteSpamRecds = new CS_deleteSpamCaseRecords();
        database.executeBatch(deleteSpamRecds ,200);
    }

}