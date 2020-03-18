/****************************************
Name-CPG_ParentAccountForStrategicObj_Test
Created Date- 15/9/2017
Description-this is test class test functionolity of class CPG_ParentAccountForStrategicObjective used by process builder
******************************************/


@isTest
public class CPG_ParentAccountForStrategicObj_Test
{
    public static testMethod void setParentAcctest()
    {
        Account acc=new account(Name='testAcc',Market_Channel__c='Internal',Status__c='Active');
        insert acc;
        Account ChildAcc=new Account(Name='testCAcc',Market_Channel__c='Internal',Status__c='Active',ParentId=acc.Id);  
        insert ChildAcc;
        list<account> acclist=new list<account>{acc,ChildAcc};
        list<CustomerProfile__c> cplist1=CPG_TestFactory_Util.createTestCustomerProfiles(1,acclist);
        System.assertEquals(2, cplist1.size());
      
        list<CustomerProfile__c> cplist2=new list<CustomerProfile__c>{cplist1[0]};
        
        list<StrategicObjective__c> solist=CPG_TestFactory_Util.createTestStrategicObjectives(3,cplist2);
        solist[2].Name='TestSO';
        update solist[2];
        Delete solist[1];
        
        list<Id> cplist=new list<Id>{cplist1[0].Id,cplist1[1].Id};
        
        test.startTest();
        CPG_ParentAccountForStrategicObjective.setParentAcc(cplist);       
        test.stopTest();
    }
}