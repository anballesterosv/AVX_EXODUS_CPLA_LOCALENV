/**
@Author Vaishali Thite
@name CPG_ScheduleCustomerProfileBatch 
@CreateDate Nov 14, 2017
@Description Schedule CustomerProfile batch
@Version <1.0>
@reference 
@Modifiedby :  
@ModifiedDate: 
*/ 

global class CPG_ScheduleCustomerProfileBatch implements schedulable{
    global void execute(SchedulableContext sc) {
       CPG_CustomerProfileBatch sCustomerProfile= new CPG_CustomerProfileBatch(); 
       database.executebatch(sCustomerProfile);
    }
}