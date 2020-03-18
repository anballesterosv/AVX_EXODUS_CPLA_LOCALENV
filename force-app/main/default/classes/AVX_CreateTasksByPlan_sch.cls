public with sharing class AVX_CreateTasksByPlan_sch implements Schedulable{
    public void execute(SchedulableContext context){
        AVX_CreateTasksByPlan_batch bch = new AVX_CreateTasksByPlan_batch(Date.Today());
        Database.executeBatch(bch);
    }
}