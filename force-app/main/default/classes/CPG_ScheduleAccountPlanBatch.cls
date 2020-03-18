/**
@Author Vaishali Thite
@name CPG_ScheduleAccountPlanBatch 
@CreateDate Sept 19, 2017
@Description Schedule AccountPlan batch
@Version <1.0>
@reference 
@Modifiedby :  
@ModifiedDate: 
*/ 

global class CPG_ScheduleAccountPlanBatch implements schedulable{
    global void execute(SchedulableContext sc) {
       CPG_UpdateAccountPlanBatch sAccPlan= new CPG_UpdateAccountPlanBatch (); 
       database.executebatch(sAccPlan);
    }
}