public with sharing class AVX_CloseOpenTasks_sch implements Schedulable{ 
  public void execute(SchedulableContext context){
      AVX_CloseOpenTasks_batch batch = new AVX_CloseOpenTasks_batch();
      Database.executeBatch(batch);
  }
}