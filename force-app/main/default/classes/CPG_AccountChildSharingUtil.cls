/**
Class Name: CPG_AccountChildSharingUtil
Description: This util class is used for defining sharing for Account Child objects based on Account Team
CreatedDate: 12-04-2017
**/
public class CPG_AccountChildSharingUtil{
    public static void shareCustomerProfile(map<string, map<string,string>> mapAccTeamAccess){
        list<customerProfile__share> lstCPsharing = new list<customerProfile__share >();
        //Get all Customer profiles
        for(customerProfile__c cp:[select id,account__c from customerprofile__c where account__c in :mapAccTeamAccess.keySet()]){
            for(string iUser:mapAccTeamAccess.get(cp.account__c).keySet()){
                customerProfile__share cp_share = new customerProfile__share();
                cp_share.parentId= cp.id;
                cp_share.UserOrGroupId = iUser;
                cp_share.AccessLevel = mapAccTeamAccess.get(cp.account__c).get(iuser);
                cp_share.RowCause = Schema.customerProfile__share.RowCause.Account_Team__c;
                lstCPsharing .add(cp_share);
            }
        }    
        if(!lstCPsharing .isEmpty()){
            database.insert(lstCPsharing, false);
        }
    }
    //Create Accoutn Plan Sharing
    public static void shareAccountPlan(map<string, map<string,string>> mapAccTeamAccess){
        
        list<AccountPlan__share> lstAPsharing = new list<AccountPlan__share>();
        //Get all Customer profiles
        for(AccountPlan__c cp:[select id,account__c from AccountPlan__c where account__c in :mapAccTeamAccess.keySet()]){
            for(string iUser:mapAccTeamAccess.get(cp.account__c).keySet()){
                AccountPlan__share cp_share = new AccountPlan__share();
                cp_share.parentId= cp.id;
                cp_share.UserOrGroupId = iUser;
                cp_share.AccessLevel = mapAccTeamAccess.get(cp.account__c).get(iuser);
                cp_share.RowCause = cp_share.RowCause = Schema.AccountPlan__share.RowCause.Account_Team__c;
                lstAPsharing.add(cp_share);
            }
        }    
        if(!lstAPsharing.isEmpty()){
            database.insert(lstAPsharing, false);
        }
    }
    //Create Business Detail Sharing
    public static void shareBusinessDetail(map<string, map<string,string>> mapAccTeamAccess){
        
        list<BusinessDetail__share> lstBDsharing = new list<BusinessDetail__share>();
        //Get all Customer profiles
        for(BusinessDetail__c cp:[select id,account__c from BusinessDetail__c where account__c in :mapAccTeamAccess.keySet()]){
            for(string iUser:mapAccTeamAccess.get(cp.account__c).keySet()){
                BusinessDetail__share cp_share = new BusinessDetail__share();
                cp_share.parentId= cp.id;
                cp_share.UserOrGroupId = iUser;
                cp_share.AccessLevel = mapAccTeamAccess.get(cp.account__c).get(iuser);
                cp_share.RowCause = cp_share.RowCause = Schema.BusinessDetail__share.RowCause.Account_Team__c;
                lstBDsharing.add(cp_share);
            }
        }    
        if(!lstBDsharing.isEmpty()){
            database.insert(lstBDsharing, false);
        }
    }
    //Create Customer Meeting Report Sharing
    public static void shareCustomerMeetingReport(map<string, map<string,string>> mapAccTeamAccess){
        
        list<CustomerMeetingReport__share> lstCMRsharing = new list<CustomerMeetingReport__share>();
        //Get all Customer profiles
        for(CustomerMeetingReport__c cp:[select id,account__c from CustomerMeetingReport__c where account__c in :mapAccTeamAccess.keySet()]){
            for(string iUser:mapAccTeamAccess.get(cp.account__c).keySet()){
                CustomerMeetingReport__share cp_share = new CustomerMeetingReport__share();
                cp_share.parentId= cp.id;
                cp_share.UserOrGroupId = iUser;
                cp_share.AccessLevel = mapAccTeamAccess.get(cp.account__c).get(iuser);
                cp_share.RowCause = cp_share.RowCause = Schema.CustomerMeetingReport__share.RowCause.Account_Team__c;
                lstCMRsharing.add(cp_share);
            }
        }    
        if(!lstCMRsharing.isEmpty()){
            database.insert(lstCMRsharing, false);
        }
    }
    
    //Share newly created Customer Meeting Report to existing Account Team
    public static void shareNewCustomerMeetingReport(set<id> setAccIds){
        list<AccountTeamMember> lstAcc = new list<AccountTeamMember>();  
        lstAcc = [select accountid, accountAccessLevel, userId from AccountTeamMember where accountid in :setAccIds];
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
        shareCustomerMeetingReport(mapAccTeamAccess);
    }
    
}