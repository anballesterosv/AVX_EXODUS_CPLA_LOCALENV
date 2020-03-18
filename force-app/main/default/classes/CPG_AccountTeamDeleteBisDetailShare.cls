/**
Class Name: CPG_AccountTeamBatchdeleteBisDetailShare 
Description: This batch class is used for deleting Account Plan apex sharing records for removed Account Team Members
CreatedDate: 05-07-2017
**/
global class CPG_AccountTeamDeleteBisDetailShare implements Database.Batchable<sObject>,Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
      return Database.getQueryLocator('select id, userOrGroupid, parentid from BusinessDetail__Share where RowCause =\'Account_Team__c\'');
    }

    global void execute(Database.BatchableContext bc, List<BusinessDetail__Share> lstShare){
        list<BusinessDetail__Share> lstDelete = new list<BusinessDetail__Share>();
        map<id, set<id>> mapAccTeam = new map<id, set<id>>();
        set<id> setAccIds = new set<id>();
        set<id> setRecIds = new set<id>();
        for(BusinessDetail__Share sh:lstShare){
            setRecIds.add(sh.parentid);
        }
        if(!setRecIds.isEmpty()){
            for(BusinessDetail__c rec: [select account__c from BusinessDetail__c where id in :setRecIds]){
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
        for(BusinessDetail__Share sh:lstShare){
            if(!mapAccTeam.isEmpty() || !mapAccTeam.containsKey(sh.parentid) || (!mapAccTeam.get(sh.parentid).contains(sh.userOrGroupId))){
                lstDelete.add(sh);  
            }   
        }
        
        if(!lstDelete.isEmpty()){
            delete lstDelete;
        }
        
    }    

    global void finish(Database.BatchableContext bc){
        //Call Customer Meeting Report share deletion batch class
        CPG_AccountTeamDeleteCustMeetingShare delShare = new CPG_AccountTeamDeleteCustMeetingShare();  
        database.executeBatch(delShare);         
    }  
   
}