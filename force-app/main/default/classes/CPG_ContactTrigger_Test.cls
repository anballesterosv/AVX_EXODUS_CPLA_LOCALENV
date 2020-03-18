/**
@Author Cognizant
@name CPG_ContactTrigger_Test
@CreateDate Nov 15, 2017
@Description test class for Contact Trigger
@Version <1.0>
@reference ContactTrigger Trigger
@Modifiedby :  
@ModifiedDate: 
*/ 
@isTest
public class CPG_ContactTrigger_Test 
{
    public static testMethod void testCrisisContact()
    {        
        
        //create account       
        list<Account> acclist=CPG_TestFactory_Util.createTestAccounts(1);
        Map<id,Account> accMap=new Map<id,Account>();
        for(Account acc:acclist){
            accMap.put(acc.Id,acc);
        }        
        
        list<contact> lstCon = CPG_TestFactory_Util.createTestContacts(3,acclist);
              
        test.startTest();
        for(integer i=0; i<lstCon.size(); i++){
            lstCon[i].Crisis_Management_Contact__c=true;
        }
        update lstCon;
        lstCon[0].Crisis_Management_Contact__c=false;
        update lstCon;
        delete lstCon[2];
        test.stopTest();        
            
    }
}