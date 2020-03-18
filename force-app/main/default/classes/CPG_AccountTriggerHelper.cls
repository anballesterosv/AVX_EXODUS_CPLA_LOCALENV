/**
@Author Vaishali Thite
@name CPG_AccountTriggerHelper
@CreateDate Nov 20, 2017
@Description Helper class for Account trigger
@Version <1.0>
@reference CPG_AccountTrigger Trigger
@Modifiedby :  
@ModifiedDate: 
*/ 
public class CPG_AccountTriggerHelper{ 

    public static void DefineSharingModelforAcc(List<Account> lstAcc, Map<Id,Account> mapAcc){
        Set<Id> setAccId=mapAcc.Keyset();
        
        Map<Id,AccountTeamMember> accTeamtoShareMap=new Map<Id,AccountTeamMember>();
        
        for(AccountTeamMember atm:[SELECT AccountAccessLevel,AccountId,LastModifiedById,TeamMemberRole,UserId FROM AccountTeamMember where AccountId IN:setAccId]){
            accTeamtoShareMap.put(atm.AccountId,atm);
        }
        List<AccountShare> lstaccShare=new List<AccountShare>();
        for(Account ap:lstAcc){
            if(accTeamtoShareMap.containsKey(ap.Id)){
                AccountTeamMember atMemb=accTeamtoShareMap.get(ap.Id);
                AccountShare aShare=manualShareRead(ap.Id,atMemb);
                lstaccShare.add(aShare);
            }
        }
        List<Database.SaveResult> srList = Database.insert(lstaccShare,false);
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