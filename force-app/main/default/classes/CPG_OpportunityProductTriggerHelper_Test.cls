/*
 test class to cover functionality of class : CPG_OpportunityProductTriggerHelper
                                              CPG_OpportunityProductGroupTriggerHelper
                                              CPG_OpportunityProductGroupTriger  
                                              CPG_OpportunityProductTrigger
*/

@isTest
public class CPG_OpportunityProductTriggerHelper_Test 
{
    public static testMethod void OpportunityProductTriggerHelper()
    {
        //creating test running user
        user u=CPG_TestFactory_Util.createTestUser('System Administrator');
        system.runAs(u)
        {
            //creating test opportunity
            list<Account> acc=CPG_TestFactory_Util.createTestAccounts(1); 
            
            list<opportunity> opplist=CPG_TestFactory_Util.createTestOpportunity(1,acc);
            system.assertEquals(opplist[0].Volume__c, 100);
            
            Product_Group__c pg=new Product_Group__c(opportunity__c=opplist[0].Id, Volume__c=1000);
            insert pg;
            Opportunity ou = [select id,Volume__c from Opportunity where Id = :opplist[0].Id];
            system.assertEquals(ou.Volume__c, pg.Volume__c);
            
            list<OpportunityLineItem> oltlist=CPG_TestFactory_Util.createTestOpportunityLineItem(2,opplist);                         
            
            //testing volume updated on opportunity from  OpportunityLineItem  oppLI1 quantity
            Opportunity ou1 = [select Id,Volume__c from Opportunity where Id = :opplist[0].Id];
            Decimal quantity=oltlist[0].Quantity+oltlist[1].Quantity;
            system.assertEquals(ou1.Volume__c,quantity);
            
            OpportunityLineItem updateCheckLT=[SELECT id,Quantity,OpportunityId FROM OpportunityLineItem WHERE Id=:oltlist[0].Id];
            updateCheckLT.Quantity=200;            
            update updateCheckLT;
        
            Opportunity ou2 = [select Id, Volume__c from Opportunity where Id = :opplist[0].Id];
            system.assertEquals(ou2.Volume__c,updateCheckLT.Quantity+oltlist[1].Quantity);        
                        
            
            //Test volume on delete
            delete oltlist[1];
            
 
                      
            test.startTest();            
            CPG_OpportunityProductTriggerHelper.beforeInsertOpportunityProduct(oltlist);            
            test.stopTest();
            
            list<Product_Group__c> pglist=[select id from Product_Group__c where opportunity__c=:opplist[0].Id];
            system.assertEquals(0, pglist.size());
        }
    }
}