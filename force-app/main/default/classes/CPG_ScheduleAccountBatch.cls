/**
@Author Vaishali Thite
@name CPG_ScheduleAccountBatch 
@CreateDate Nov 14, 2017
@Description Schedule Accoun batch
@Version <1.0>
@reference 
@Modifiedby :  
@ModifiedDate: 
*/ 

global class CPG_ScheduleAccountBatch implements schedulable{
    global void execute(SchedulableContext sc) {
        CPG_AccountBatch accbatch= new CPG_AccountBatch(); 
        database.executebatch(accbatch);
    }
}