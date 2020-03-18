/**
Class Name: CPG_AddAccountPlanDetailController
Created Date: Oct-15-2017
Created By: Cognizant
This class is  controller class for component used for adding multiple Account Plan Details.
**/
public class CPG_AddAccountPlanDetailController{
public static list<id> lstStratIds= new list<id>();
public static id APDid;
@AuraEnabled
public static List<StrategicObjective__c> getStratObjectives(string accountplanid) {
    string accountid;
    list<AccountPlan__c> lstACP = [select account__c from accountplan__c where id=:accountplanid];
    if(!lstACP.isEmpty()){
       accountid= lstACP[0].account__c;
    }
    list<StrategicObjective__c> lstStrtObj = new list<StrategicObjective__c>();
    lstStrtObj  = [select Id, Name,  EndDate__c from StrategicObjective__c where CustomerProfile__r.account__c=:accountid or CustomerProfile__r.account__r.parentId=:accountid or CustomerProfile__r.account__r.parent.parentid=:accountid];
    return lstStrtObj ;
}
@AuraEnabled
public static List<Opportunity> addAPobjectives(list<id> StratIds, string accountplanid){
    string accountid;
    lstStratIds.addAll(StratIds);
    list<AccountPlan__c> lstACP = [select account__c from accountplan__c where id=:accountplanid];
    if(!lstACP.isEmpty()){
       accountid= lstACP[0].account__c;
    }
    lstStratIds = new list<id>();
    lstStratIds.addAll(StratIds);
    //Insert Account Plan Detail
    if(!StratIds.isEmpty()){
        AccountPlanDetail__c apd= new AccountPlanDetail__c(Account_Plan__c=accountplanid);
        insert apd;
        APDid = apd.id;
        //Insert Account Plan Detail Objective
        list<Strategic_Objective_APD__c> lstAPDObj = new list<Strategic_Objective_APD__c>();
        
        for(id idObj:StratIds){
            if(idObj!=null){
            lstAPDObj.add(new Strategic_Objective_APD__c(Strategic_Objective__c = idObj, Account_Plan_Detail__c = APDid, External_ID__c= idObj+'|'+APDid));
            }
        }
        if(!lstAPDObj.isEmpty()){
            upsert lstAPDObj external_Id__c;
        }
    
    }
    list<Opportunity> lstOpp = new list<Opportunity>();
    lstOpp = [select Id, Name, Account.Name, CloseDate from Opportunity where accountid=:accountid or  account.parentId=:accountid or  account.parent.parentid=:accountid];
    return lstOpp;
}

@AuraEnabled
public static void saveAP(list<id> OppIds, string accountplanid, list<id> StratIds) {
    //Insert Account Plan Detail Opportunities
    list<Account_Plan_Opportunity__c> lstAPDOpp = new list<Account_Plan_Opportunity__c>();
    string iAPD = [select id from AccountPlanDetail__c where Account_Plan__c=:accountplanid and createdbyid=:userInfo.getUserId() order by createddate desc limit 1].id;
    for(id idOpp :OppIds){
        if(idOpp!=null){
            lstAPDOpp.add(new Account_Plan_Opportunity__c(opportunity__c= idOpp, Account_Plan_Detail__c = iAPD));
        }
    }
    if(!lstAPDOpp.isEmpty()){
        insert lstAPDOpp;
    }
}

}