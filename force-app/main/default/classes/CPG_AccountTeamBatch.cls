/**
Class Name: CPG_AccountTeamBatch 
Description: This batch class is used for sharing for Account child objects to Account team
CreatedDate: 12-04-2017
**/
global class CPG_AccountTeamBatch implements Database.Batchable<sObject>,Database.Stateful {
    private static string query ='select accountid, accountAccessLevel, userId from AccountTeamMember where lastmodifieddate=last_N_days:'+label.Account_Team_Param;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
      return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<AccountTeamMember> lstAcc){
        map<string, map<string,string>> mapAccTeamAccess = new map<string, map<string,string>>();
        for(AccountTeamMember accMem :lstAcc){
                if(mapAccTeamAccess.isEmpty() || (!mapAccTeamAccess.isEmpty() && !mapAccTeamAccess.containsKey(accMem.accountid))){
                     map<string, string> access = new map<string, string>();
                     access.put(accMem.userid, accMem.accountAccessLevel);
                     mapAccTeamAccess.put(accMem.accountid, access);          
                }
                else {
                    map<string, string> access = new map<string, string>();
                    access.put(accMem.userid, accMem.accountAccessLevel);   
                    mapAccTeamAccess.get(accMem.accountid).put(accMem.userid, accMem.accountAccessLevel); 
                }   
        }
        CPG_AccountChildSharingUtil.shareCustomerProfile(mapAccTeamAccess);
        CPG_AccountChildSharingUtil.shareAccountPlan(mapAccTeamAccess);
        CPG_AccountChildSharingUtil.shareBusinessDetail(mapAccTeamAccess);
        CPG_AccountChildSharingUtil.shareCustomerMeetingReport(mapAccTeamAccess);
        
    }    

    global void finish(Database.BatchableContext bc){
            
    }  
   
}