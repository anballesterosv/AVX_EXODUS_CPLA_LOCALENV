@isTest
public class CPG_AddChildController_Test 
{
    public Static TestMethod Void AddContactsToMyContacts()
    {           
        //creating test user for run as
        user u=CPG_TestFactory_Util.createTestUser('System Administrator');
        System.runAs(u)
        {
            //Creating test contacts and account for User_Contact__c
            list<account> acclist=CPG_TestFactory_Util.createTestAccounts(1);
           
            list<contact> conlist=CPG_TestFactory_Util.createTestContacts(2,acclist);
            
            list<user_contact__c> ucList=CPG_TestFactory_Util.createTestUserContacts(1,conlist);
            String accId=String.valueOf(acclist[0].Id);
            String conId=String.valueOf(conlist[1].Id);
            list<string> conIdList=new list<String>{String.valueOf(conlist[0].Id)};
                
            Test.startTest();             
            
            List<contact> contlist=CPG_AddChildController.getContacts(accId); 
            system.assertEquals(true, contlist.size()>0);
            List<user_contact__c> usercontactlist=CPG_AddChildController.getuContacts(accId);
            list<user_contact__c> userconList=[select contact__c from user_contact__c where contact__r.accountid=:acclist[0].Id];
            system.assertEquals(true, userconList.size()>0);
            CPG_AddChildController.removeuContact(conId);
            CPG_AddChildController.addCons(conIdList);
            
            Test.stopTest();
        }        
    }   
}