/**
@Author - Aditi Sharma
@name - OpportunityClone
@CreateDate - 1/6/2017 
@Description - This is a scheduler class to schedule the batch class OpportunityClone
@Revision-
*/ 


global class OpportunityCloneSched implements schedulable
{
    global void execute(SchedulableContext sc)
    {
    OpportunityClone objbatch = new OpportunityClone (); //ur batch class
      database.executebatch(objbatch);
    }
}