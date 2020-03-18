public with sharing class BusinessUnitDetailCompController {

    @AuraEnabled
    public static List<BusinessDetail__c> getBusinessUnitDetail(Id acctId){
        system.debug('***acctId: ' + acctId);
        return [select Id, Name, Status__c, BusinessUnit__r.Name from BusinessDetail__c where BusinessUnit__c != null AND Account__c = :acctId];
    }

    //Retrieve the list of Account Team Members in this business unit
    @AuraEnabled
    public static List<AccountTeamMemberObj> getAccountTeamList(string businessUnit, string accountId){
        List<AccountTeamMemberObj> result = new List<AccountTeamMemberObj>();
        //get all the users from the same business unit
        Map<string, User> userMap = new Map<string, User>();
        for(User user : [select Id, Name, Title, Email from User where Cargill_Business_Unit__c = :businessUnit]){
            userMap.put(user.Id, user);
            system.debug('*** found User: ' + user.Name + ' in BU: ' + businessUnit);
        }

        //get all the account team member
        Map<string, AccountTeamMember> accountMemberMap = new Map<string, AccountTeamMember>();
        for(AccountTeamMember atm : [select UserId, AccountId, TeamMemberRole
                                     from AccountTeamMember
                                     where AccountId = :accountId
                                     AND UserId IN :userMap.keySet()]){
                                         system.debug('*** found acct member: ' + atm.UserId + ' for acct id: ' + accountId);
                                         accountMemberMap.put(atm.UserId, atm);
                                     }

        //Ensure both maps aren't empty
        if(userMap != null && accountMemberMap != null){
            for(string userId : accountMemberMap.keySet()){
                if(userMap.get(userId)!=null){
                    AccountTeamMemberObj atObj = new AccountTeamMemberObj();
                    atObj.AccountId = accountMemberMap.get(userId).AccountId;
                    atObj.TeamRole = accountMemberMap.get(userId).TeamMemberRole;

                    atObj.UserId = userMap.get(userId).Id;
                    atObj.Email = userMap.get(userId).Email;
                    atObj.Name = userMap.get(userId).Name;
                    atObj.Title = userMap.get(userId).Title;

                    system.debug('*** this user qualifieds atObj:' + atObj);
                    result.add(atObj);
                }
            }
        }

        return result;
    }

    //Retrieve the current user's business unit
    @AuraEnabled
    public static string getCurrentUserBusinessUnit(){
        string curUserBusinessUnit;
        List<User> curUser = [select Id, Cargill_Business_Unit__c from User where Id = :UserInfo.getUserId() limit 1];
        if(curUser!= null){
            system.debug('Fetch current user: ' + curUser[0].Cargill_Business_Unit__c);
            curUserBusinessUnit = curUser[0].Cargill_Business_Unit__c;
        }

        return curUserBusinessUnit;
    }

    @AuraEnabled
    public static string getCurrentUserBusinessUnit(List<BusinessDetail__c> budList){
        string curUserBusinessUnit;
        List<User> curUser = [select Id, Cargill_Business_Unit__c from User where Id = :UserInfo.getUserId() limit 1];
        if(curUser!= null){
            system.debug('Fetch current user: ' + curUser[0].Cargill_Business_Unit__c);
            curUserBusinessUnit = curUser[0].Cargill_Business_Unit__c;
        }

        return curUserBusinessUnit;
    }
    
    @AuraEnabled
    public static BusinessDetail__c getUpdatedBusinessDetail(string id){
        return [select Id, Name, Status__c, BusinessUnit__r.Name from BusinessDetail__c where Id = :id];
    }

    @AuraEnabled
    public static boolean updateBusinessUnitDetail(List<BusinessDetail__c> budList){
        boolean success = false;

        if(budList != null){
            Database.SaveResult[] srList = Database.update(budList, false);

            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('*** Successfully updated record: ' + sr.getId());

                }
                else {
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {
                        System.debug('*** The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                        return false;
                }
            }

            success = true;
        }

        return success;
    }
}