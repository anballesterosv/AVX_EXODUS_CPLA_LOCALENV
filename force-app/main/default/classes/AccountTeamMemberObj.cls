public class AccountTeamMemberObj {
    public AccountTeamMemberObj(){}
    
    @AuraEnabled 
    public string UserId {get; set;}
    
    @AuraEnabled
    public string AccountId {get;set;}
    
    @AuraEnabled
    public string Name {get; set;}
    
    @AuraEnabled
    public string Title {get; set;}
    
    @AuraEnabled
    public string TeamRole {get; set;}
    
    @AuraEnabled
    public string Email {get; set;}
    
    Public static void getAccountDetails(){
        // Logic here
    }
}