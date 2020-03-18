/*
 test class to cover functionality of class : CPG_RenewOpportunityWithProducts
*/

@isTest
public class CPG_RenewOpportunityWithProducts_Test 
{
    public static testMethod void RenewOpportunityWithProducts()
    {
        List<account> acclist=CPG_TestFactory_Util.createTestAccounts(1);
        list<opportunity> opplist=CPG_TestFactory_Util.createTestOpportunity(2,acclist);        
                
        opportunity opptest=[select Id, Name, OriginalName__c from opportunity where Id=:opplist[0].Id];
        String oppName=opptest.Name;
        If(oppName.indexOfAny('|')>0)
        {
            System.assert(True);
        }
          
        list<OpportunityLineItem> oppLIlist=CPG_TestFactory_Util.createTestOpportunityLineItem(1,opplist);
        
        List<id> oppids=new list<id>{opplist[0].Id,opplist[1].Id};
              
        system.assertEquals(2, oppids.size());
        
        test.startTest();
        CPG_RenewOpportunityWithProducts.getRenewedOpp(oppids);
        test.stopTest();
        
        list<opportunity> oppsAfterClone=[select id from opportunity where AccountId=:acclist[0].Id];
        System.assertEquals(3, oppsAfterClone.size());
    }
}