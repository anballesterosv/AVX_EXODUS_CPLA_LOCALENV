/*
*    @description:    Test class for CPG_OpportunityProsQuotesTriggerHelper & CPG_OpportunityProsQuotetrigger.*    
*    @createddate:    April 5, 2018
*/
@isTest
private class CPG_OppPrQuotesTriggerHelper_Test {
    static testMethod void rollupTest(){
        Map<String,Schema.RecordTypeInfo> recordTypeMap = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName();
        list<Account> acclist=CPG_TestFactory_Util.createTestAccounts(1);
        list<opportunity> opplist=CPG_TestFactory_Util.createTestOpportunity(1, acclist);
        for(opportunity opp:opplist){
            opp.RecordTypeId= recordTypeMap.get('Egg').getRecordTypeId();
                    
        }
        update opplist;
        list<CameleonCPQ__Quote__c> quotelist=CPG_TestFactory_Util.createTestProsQuotes(2,opplist);      
        CameleonCPQ__Quote__c cq=quotelist[0];
        delete cq;
        
        test.startTest();
        CPG_OppPrQuotesTriggerHelper.rollupTrigger(quotelist);        
        test.stopTest();        
    }
}