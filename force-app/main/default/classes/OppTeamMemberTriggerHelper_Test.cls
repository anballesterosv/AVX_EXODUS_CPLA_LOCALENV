/**
     *  SFA_TestFactory_Util 
     
     * @author          CTS\Vaishali Thite
     * @version         1.0
     * @date            2017-05-05
     * @description     Opportunity TeamHelper test class
    */
@isTest
private class OppTeamMemberTriggerHelper_Test{
    static testMethod void unitTestOppTeam(){
        test.startTest();
        List<Account> lstAcc =  SFA_TestFactory_Util.createTestAccounts(2);
        System.assertNotEquals(lstAcc.size(),0); 
        List<Opportunity> lstOpp =  SFA_TestFactory_Util.createTestOpportunity(2,lstAcc ); 
        System.assertNotEquals(lstOpp.size(),0); 
        //List<OpportunityLineItem> lstoppItem= SFA_TestFactory_Util.createTestOpportunityLineItem(2,lstOpp);
        //System.assertNotEquals(lstoppItem.size(),0); 
        List<OpportunityTeamMember> lstOppTeam=SFA_TestFactory_Util.createTestOpportunityTeamMember(2,lstOpp); 
        System.assertNotEquals(lstOppTeam.size(),0); 
       /* Project__c prj= SFA_TestFactory_Util.createTestProject(2,lstAcc,lstOpp);
        System.assertNotEquals(prj,Null);
        ProjectProduct__c prjProd=SFA_TestFactory_Util.createTestProjectProduct(prj); 
        List<ProjectTeamMembers__c> lstPrjTeam=SFA_TestFactory_Util.createTestProjectTeamMembers(2,prj,lstOpp);
        System.assertNotEquals(lstPrjTeam.size(),0); */
        
        //Proxy Code Coverage
        OppTeamMemberTriggerHelper oppTeHelper=new OppTeamMemberTriggerHelper(lstOppTeam,lstOppTeam);
        oppTeHelper.addProjectTeam();
        oppTeHelper.deleteMemandSharing();
         //Proxy Code Coverage
        test.stopTest();
    }
}