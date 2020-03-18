/**
@Author Siva Sankar
@name CPG_CustomerProfileTriggerHelper_Test
@CreateDate Nov 15, 2017
@Description test class for CPG_CustomerProfileTriggerHelper, additionally it will tace care for batch update too
@Version <1.0>
@reference CPG_CustomerProfileTrigger Trigger
@Modifiedby :  Vaishali
@ModifiedDate: 
*/ 
@isTest
public class CPG_CustomerProfileTriggerHelper_Test 
{
    public static testMethod void DefineSharingModel()
    {        
        
        //create account       
        list<Account> acclist=CPG_TestFactory_Util.createTestAccounts(1);
           
        //related AccountPaln__c creation for account acc        
        list<CustomerProfile__c> cplist=CPG_TestFactory_Util.createTestCustomerProfiles(2,acclist);
        Map<id,CustomerProfile__c> cpMap=new Map<id,CustomerProfile__c>();
        cpMap.put(cplist[0].Id, cplist[0]);
        cpMap.put(cplist[1].Id, cplist[1]);
        list<AccountTeamMember> atmlist=CPG_TestFactory_Util.createTestAccountTeamMember(1,acclist);
              
        test.startTest();
        CPG_CustomerProfileTriggerHelper.DefineSharingModelforCustomerProfile(cplist, cpMap);
        CPG_CustomerProfileTriggerHelper.manualShareRead(cplist[0].Id,atmlist[0]);
        CPG_CustomerProfileBatch cpbatch= new CPG_CustomerProfileBatch (); 
        database.executebatch(cpbatch);
        CPG_ScheduleCustomerProfileBatch cpSCH=new CPG_ScheduleCustomerProfileBatch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Schedule Check', sch, cpSCH);
        test.stopTest();        
            
    }
}