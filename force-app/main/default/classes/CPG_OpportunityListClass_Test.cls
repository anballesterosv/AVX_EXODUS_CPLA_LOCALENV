/**
@Author Siva
@name CPG_OpportunityListClass_Test
@CreateDate Oct 13, 2017
@Description test class for CPG_OpportunityListClass
@Version <1.0>
@reference CPG_OpportunityListClass
@Modifiedby :  
@ModifiedDate: 
*/ 
@isTest
public class CPG_OpportunityListClass_Test
{
    public static testMethod void OpportunityList()
    {
        //creating test running user
        user u=CPG_TestFactory_Util.createTestUser('System Administrator');
        system.runAs(u)
        {
            // creating test opportunities
            list<account> accList=CPG_TestFactory_Util.createTestAccounts(1);        
            list<opportunity> oppList=CPG_TestFactory_Util.createTestOpportunity(6,accList);
            Test.StartTest();
            list<opportunity> OpportunityList=CPG_OpportunityListClass.findTopOppty();
            Test.StopTest();
            System.assertEquals(True,OpportunityList.size()>0);
        }        
    }
}