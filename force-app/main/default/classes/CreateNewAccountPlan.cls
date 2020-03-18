public with sharing class CreateNewAccountPlan{
public id parentId {get;set;}
    public CreateNewAccountPlan(ApexPages.StandardController controller) {
       AccountPlan__c record = (AccountPlan__c)controller.getRecord();
    parentId = record.Account__c;
    
    }

}