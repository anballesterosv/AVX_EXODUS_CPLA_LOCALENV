/**
Class Name: CPG_AccountTeamBatchdeleteCustMeetingShare 
Description: This batch class is used for deleting Account Plan apex sharing records for removed Account Team Members
CreatedDate: 05-07-2017
**/
global class CPG_AccountTeamDeleteCustMeetingShare implements Database.Batchable<sObject>,Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
      return Database.getQueryLocator('select id, userOrGroupid, parentid from CustomerMeetingReport__Share where RowCause =\'Account_Team__c\'');
    }

    global void execute(Database.BatchableContext bc, List<CustomerMeetingReport__Share> lstShare){
        list<CustomerMeetingReport__Share> lstDelete = new list<CustomerMeetingReport__Share>();
        map<id, set<id>> mapAccTeam = new map<id, set<id>>();
        set<id> setAccIds = new set<id>();
        set<id> setRecIds = new set<id>();
        for(CustomerMeetingReport__Share sh:lstShare){
            setRecIds.add(sh.parentid);
        }
        if(!setRecIds.isEmpty()){
            for(CustomerMeetingReport__c rec: [select account__c from CustomerMeetingReport__c where id in :setRecIds]){
                setAccIds.add(rec.account__c);
            }
        }
        
        for(AccountTeamMember tm:[select AccountId, userId from AccountTeamMember where accountid in:setAccIds]){
            if(mapAccTeam.containsKey(tm.accountid)){
                mapAccTeam.get(tm.accountid).add(tm.userId);
            }
            else{
                set<id> temp = new set<id>();
                temp.add(tm.userId);
                mapAccTeam.put(tm.accountid, temp);
            }
        }
        for(CustomerMeetingReport__Share sh:lstShare){
            if(mapAccTeam.isEmpty() || !mapAccTeam.containsKey(sh.parentid) || (!mapAccTeam.get(sh.parentid).contains(sh.userOrGroupId))){
                lstDelete.add(sh);  
            }   
        }
        
        if(!lstDelete.isEmpty()){
            delete lstDelete;
        }
        
    }    

    global void finish(Database.BatchableContext bc){
            
    }  
   
}