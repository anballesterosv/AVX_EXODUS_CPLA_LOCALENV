/**
@Author Vaishali Thite
@name CPG_AccountPlanUtil
@CreateDate Sept 19, 2017
@Description Utility class for AccountPlan Batch
@Version <1.0>
@reference CPG_AccountPlanBatch
@Modifiedby :  
@ModifiedDate: 
*/ 
public class CPG_AccountPlanUtil{ 

    public static void DefineSharingModelforAccPlan(List<AccountPlan__c> lstAccPlan){
        Set<Id> setAccId=new Set<Id>();
        for(AccountPlan__c ap:lstAccPlan){
            setAccId.add(ap.Account__c);
        }
        Map<Id,AccountTeamMember> accTeamtoShareMap=new Map<Id,AccountTeamMember>();
        
        for(AccountTeamMember atm:[SELECT AccountAccessLevel,AccountId,LastModifiedById,TeamMemberRole,UserId FROM AccountTeamMember where AccountId IN:setAccId]){
            accTeamtoShareMap.put(atm.AccountId,atm);
        }
        List<AccountPlan__Share> lstaPlanShare=new List<AccountPlan__Share>();
        for(AccountPlan__c ap:lstAccPlan){
            if(accTeamtoShareMap.containsKey(ap.Account__c)){
                AccountTeamMember atMemb=accTeamtoShareMap.get(ap.Account__c);
                AccountPlan__Share aShare=manualShareRead(ap.Id,atMemb);
                lstaPlanShare.add(aShare);
            }
        }
        List<Database.SaveResult> srList = Database.insert(lstaPlanShare,false);
    }
    
    public static AccountPlan__Share manualShareRead(Id recordId, AccountTeamMember accTeam){
          // Create new sharing object for the custom object Job.
          AccountPlan__Share aPlanShare  = new AccountPlan__Share();
          // Set the ID of record being shared.
          aPlanShare.ParentId = recordId;
          // Set the ID of user or group being granted access.
          aPlanShare.UserOrGroupId = accTeam.UserId;
          // Set the access level same as parent Account AccessLevel.
          aPlanShare.AccessLevel = accTeam.AccountAccessLevel;
          // Set rowCause to 'manual' for apex sharing.
          aPlanShare.RowCause = Schema.AccountPlan__Share.RowCause.Manual;
          
          return aPlanShare;
   }

}