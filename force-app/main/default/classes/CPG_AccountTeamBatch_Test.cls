/**
Class Name: CPG_AccountTeamBatch_Test
Description: This Test class is to test CPG_AccountChildSharingUtil And CPG_AccountTeamBatch
CreatedDate: 12-05-2017
**/
@isTest(seeAllData=false)
Private class CPG_AccountTeamBatch_Test {
    private Static testMethod void shareCustomerProfile(){
        CPG_TestFactory_Util.createCustomSettingforIntProfile();
        User u=CPG_TestFactory_Util.createTestUser('System Administrator');
        System.runAs(u){
           
            list<Account> acclist1=CPG_TestFactory_Util.createCommercialAccounts(1);
            list<Account> acclist=CPG_TestFactory_Util.createTestAccounts(2);
            list<CustomerProfile__c> cplist=CPG_TestFactory_Util.createTestCustomerProfiles(1,acclist); 
            list<AccountPlan__c> aplist=CPG_TestFactory_Util.createTestAccountPlan(1,acclist1);
            list<BusinessDetail__c> bdlist=CPG_TestFactory_Util.createTestBusinessDetails(1,acclist);
            list<CustomerMeetingReport__c> cmrlist=CPG_TestFactory_Util.createTestCustomerMeetingReport(1,acclist); 
              
            list<AccountTeamMember> atmlist=CPG_TestFactory_Util.createTestAccountTeamMember(1,acclist);
            list<AccountTeamMember> atmlist1=CPG_TestFactory_Util.createTestAccountTeamMember(1,acclist);
            list<AccountTeamMember> atmlist2=CPG_TestFactory_Util.createTestAccountTeamMember(1,acclist1);
            System.assert(!atmlist.isEmpty());
            System.assert(!atmlist1.isEmpty());
            
            //Create Customer profile share for non-Account Team Member
            customerprofile__share cps = new customerProfile__share();
            cps.parentid= cplist[0].id;
            cps.AccessLevel='Edit';
            cps.userOrGroupId=u.id;
            cps.rowCause = Schema.CustomerProfile__share.RowCause.Account_Team__c;
            insert cps;
            //Create Account Plan share for non-Account Team Member
            AccountPlan__share aps = new AccountPlan__share();
            aps.parentid= aplist[0].id;
            aps.AccessLevel='Edit';
            aps.userOrGroupId=u.id;
            aps.rowCause = Schema.AccountPlan__share.RowCause.Account_Team__c;
            insert aps;
            //Create Biz Detail share for non-Account Team Member
            businessDetail__share bds = new businessDetail__share();
            bds.parentid= bdlist[0].id;
            bds.AccessLevel='Edit';
            bds.userOrGroupId=u.id;
            bds.rowCause = Schema.businessDetail__share.RowCause.Account_Team__c;
            insert bds;
            //Create Customer Meeting Report share for non-Account Team Member
            CustomerMeetingReport__share cms = new CustomerMeetingReport__share();
            cms.parentid= cmrlist[0].id;
            cms.AccessLevel='Edit';
            cms.userOrGroupId=u.id;
            cms.rowCause = Schema.CustomerMeetingReport__share.RowCause.Account_Team__c;
            insert cms;
            
            test.startTest();
            CPG_AccountTeamBatch atb=new CPG_AccountTeamBatch();
            database.executebatch(atb);       
            delete atmlist;
            delete atmlist1;
            database.executeBatch(new CPG_AccountTeamDeleteCustProfileShare());
            test.stopTest(); 
        }
    } 
}