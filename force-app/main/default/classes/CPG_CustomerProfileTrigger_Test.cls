/**
@Author: Cognizant
@name CPG_CustomerProfileTrigger_Test
@CreateDate Jan 10, 2018
@Description test class for CustomerProfileTrigger
*/ 
@isTest
public class CPG_CustomerProfileTrigger_Test 
{
    public static testMethod void testCustomerProfileStatus()
    {        
        
        //create account       
        list<Account> acclist=CPG_TestFactory_Util.createTestAccounts(2);
        acclist[0].Parentid=acclist[1].id;
        update acclist[0];
           
        //Create Customer Profile    
        list<CustomerProfile__c> lstCP = CPG_TestFactory_Util.createTestCustomerProfiles(1,acclist);
        
        test.startTest();
        lstCP[0].Name='Test CP2';
        update lstCP;
        list<CustomerProfile__c> lstCPDB =[select status__C from CustomerProfile__c where id=:lstCP[0].id];
        system.assertEquals('Not Started',lstCPDB[0].status__c,'Customer Profile Status not updated to In Progress.');
        //Create Strategic Objectives
        list<StrategicObjective__c> lstStratObj = CPG_TestFactory_Util.createTestStrategicObjectives(1,lstCP); 
        lstCP[0].Express_Value__c = 'Test CP Express Value string';
        lstCP[0].Strategic_Initiative__c = 'Test CP Strat Init string';
        update lstCP;
        list<CustomerProfile__c> lstCPDB01 =[select status__C from CustomerProfile__c where id=:lstCP[0].id];
        system.assertEquals('Complete',lstCPDB01[0].status__c,'Customer Profile Status not updated to In Progress.');
        
        //Test CP deletion flow
        delete lstCP;
        list<Account> lstAcc = new list<Account>();
        lstAcc = [select Has_Customer_Profile_at_Commercial_Level__c from Account where id=:acclist[0].id];
        system.assert(!lstAcc[0].Has_Customer_Profile_at_Commercial_Level__c,'Parent CP roll up not correct!');
        test.stopTest();            
    }
}