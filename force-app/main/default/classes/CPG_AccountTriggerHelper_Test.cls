/**
@Author Siva Sankar
@name CPG_AccountTriggerHelper_Test
@CreateDate Nov 15, 2017
@Description test class for CPG_AccountTriggerHelper, CPG_AccountUtil additionally it will tace care for batch update too
@Version <1.0>
@reference CPG_AccountTrigger Trigger
@Modifiedby :  Vaishali
@ModifiedDate: 
*/ 
@isTest
public class CPG_AccountTriggerHelper_Test 
{
    public static testMethod void DefineSharingModel()
    {        
        
        //create account       
        list<Account> acclist=CPG_TestFactory_Util.createTestAccounts(1);
        Map<id,Account> accMap=new Map<id,Account>();
        for(Account acc:acclist){
            accMap.put(acc.Id,acc);
        }        
        
        list<AccountTeamMember> atmlist=CPG_TestFactory_Util.createTestAccountTeamMember(1,acclist);
              
        test.startTest();
        CPG_AccountTriggerHelper.DefineSharingModelforAcc(acclist, accMap);
        CPG_AccountTriggerHelper.manualShareRead(acclist[0].Id,atmlist[0]);
        CPG_AccountBatch accbatch= new CPG_AccountBatch(); 
        database.executebatch(accbatch);
        CPG_ScheduleAccountBatch accSCH=new CPG_ScheduleAccountBatch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Schedule Check', sch, accSCH);
        test.stopTest();        
            
    }
}