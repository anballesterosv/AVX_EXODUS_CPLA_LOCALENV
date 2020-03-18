/*************************************************************************************************************************************************************
 *@ Version:        1.0
@ Author:     Sanhit.Hegde
@ Req No:     task 39     
@ Refer Classes:  
@ Purpose:        
**************************************************************************************************************************************/
trigger SyncAccountTeamMember on AccountView__c (before Insert,Before Update,Before delete) {
  if(checkRecursive.runOnce()){
 If(Trigger.isBefore && Trigger.isInsert){
 SyncAccountTeamMemberHelper call = new SyncAccountTeamMemberHelper(Trigger.new,null,null);
 call.syncAccTeaminsert();
        
    }
If(Trigger.isBefore && Trigger.isupdate){
system.debug('inside update');
    SyncAccountTeamMemberHelper call = new SyncAccountTeamMemberHelper(null,Trigger.new,null);
 call.syncAccTeamupdate();
        
    }
    
      If(Trigger.isBefore && Trigger.isDelete){
      SyncAccountTeamMemberHelper call= new SyncAccountTeamMemberHelper(null,null,Trigger.old);
      call.deleteAccRec();
           
        }

}
}