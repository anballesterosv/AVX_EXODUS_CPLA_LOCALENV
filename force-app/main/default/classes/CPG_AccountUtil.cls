/**
@Author Vaishali Thite
@name CPG_AccountUtil
@CreateDate Nov 20, 2017
@Description Utility class for Account Batch
@Version <1.0>
@reference CPG_AccountBatch
@Modifiedby :  
@ModifiedDate: 
*/ 
public class CPG_AccountUtil{ 

    public static void DefineSharingModelforAcc(List<Account> lstAcc){
        Set<Id> setAccId=new Set<Id>();
        for(Account ac:lstAcc){
            setAccId.add(ac.Id);
        }
        Map<Id,AccountTeamMember> accTeamtoShareMap=new Map<Id,AccountTeamMember>();
        
        for(AccountTeamMember atm:[SELECT AccountAccessLevel,AccountId,LastModifiedById,TeamMemberRole,UserId FROM AccountTeamMember where AccountId IN:setAccId]){
            accTeamtoShareMap.put(atm.AccountId,atm);
        }
        List<AccountShare> lstAccShare=new List<AccountShare>();
        for(Account acc:lstAcc){
            if(accTeamtoShareMap.containsKey(acc.Id)){
                AccountTeamMember atMemb=accTeamtoShareMap.get(acc.Id);
                AccountShare aShare=manualShareRead(acc.Id,atMemb);
                lstAccShare.add(aShare);
            }
        }
        List<Database.SaveResult> srList = Database.insert(lstAccShare,false);
    }
    
      public static AccountShare manualShareRead(Id recordId, AccountTeamMember accTeam){
          // Create new sharing object for the custom object Job.
          AccountShare accShare  = new AccountShare();
          // Set the ID of record being shared.
          accShare.AccountId= recordId;
          // Set the ID of user or group being granted access.
          accShare.UserOrGroupId = accTeam.UserId;
          // Set the access level same as parent Account AccessLevel.
          accShare.AccountAccessLevel= 'Edit';
          //accShare.ContactAccessLevel= 'Edit';
          accShare.OpportunityAccessLevel= 'Edit';
          // Set rowCause to 'manual' for apex sharing.
          accShare.RowCause = Schema.AccountShare.RowCause.Manual;
          
          return accShare;
   }

}