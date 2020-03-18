/**
@Author Vaishali Thite
@name CPG_CustomerProfileUtil
@CreateDate Sept 19, 2017
@Description Utility class for CustomerProfileBatch
@Version <1.0>
@reference CPG_CustomerProfileBatch
@Modifiedby :  
@ModifiedDate: 
*/ 
public class CPG_CustomerProfileUtil{ 

    public static void DefineSharingModelforCustomerProfile(List<CustomerProfile__c> lstCustomerProfile){
        Set<Id> setAccId=new Set<Id>();
        for(CustomerProfile__c cp:lstCustomerProfile){
            setAccId.add(cp.Account__c);
        }
        Map<Id,AccountTeamMember> accTeamtoShareMap=new Map<Id,AccountTeamMember>();
        
        for(AccountTeamMember atm:[SELECT AccountAccessLevel,AccountId,LastModifiedById,TeamMemberRole,UserId FROM AccountTeamMember where AccountId IN:setAccId]){
            accTeamtoShareMap.put(atm.AccountId,atm);
        }
        List<CustomerProfile__Share> lstCPShare=new List<CustomerProfile__Share>();
        for(CustomerProfile__c cp:lstCustomerProfile){
            if(accTeamtoShareMap.containsKey(cp.Account__c)){
                AccountTeamMember atMemb=accTeamtoShareMap.get(cp.Account__c);
                CustomerProfile__Share cShare=manualShareRead(cp.Id,atMemb);
                lstCPShare.add(cShare);
            }
        }
        List<Database.SaveResult> srList = Database.insert(lstCPShare,false);
    }
    
    public static CustomerProfile__Share manualShareRead(Id recordId, AccountTeamMember accTeam){
          // Create new sharing object for the custom object Job.
          CustomerProfile__Share CPShare= new CustomerProfile__Share();
          // Set the ID of record being shared.
          CPShare.ParentId = recordId;
          // Set the ID of user or group being granted access.
          CPShare.UserOrGroupId = accTeam.UserId;
          // Set the access level same as parent Account AccessLevel.
          CPShare.AccessLevel = accTeam.AccountAccessLevel;
          // Set rowCause to 'manual' for apex sharing.
          CPShare.RowCause = Schema.CustomerProfile__Share.RowCause.Manual;
          
          return CPShare;
   }

}