/**
@Author Vaishali Thite
@name CPG_OpportunityListClass
@CreateDate Oct 13, 2017
@Description apex class to show top 5 opportunities
@Version <1.0>
@reference CPG_TopOpportunityList Ltn Comp
@Modifiedby :  
@ModifiedDate: 
*/ 
Public with sharing Class CPG_OpportunityListClass{
    @AuraEnabled
    public static List<Opportunity> findTopOppty() {
        return [SELECT Id, Name, StageName , Closedate,RecordType.name,Account.name,OwnerId,volume__c FROM Opportunity 
             where OwnerId=:userinfo.getuserid() and IsClosed=false order by volume__c DESC LIMIT 5];
    }
}