/**
     *  SFA_TestFactory_Util 
     
     * @author          CTS\Vaishali Thite
     * @version         1.0
     * @date            2017-05-05
     * @description     Testfactory Class
    */
@isTest
public class SFA_TestFactory_Util{
    
    public static User createTestUser(String profileNameStr) {
        final User u = new User();
        
        if(String.isNotBlank(profileNameStr)){
            
            Profile p = [SELECT Id FROM Profile WHERE Name=:profileNameStr]; 
            Integer count = [SELECT count() from user];
            count++;
            String usernameStr = 'test'+count;
            u.UserName = usernameStr+profileNameStr.remove(' ')+'@Cargill.test';  
            u.Alias = 'standt'; 
            u.Email='standarduser@cargill.com'; 
            u.EmailEncodingKey ='UTF-8';
            u.LastName ='LastName';
            u.firstName ='FirstName';
            u.LanguageLocaleKey ='en_US'; 
            u.LocaleSidKey='en_US';
            u.ProfileId = p.Id; 
            u.TimeZoneSidKey ='America/Los_Angeles';
            u.Alias = 'alias12';
            insert u;  
           
        }
         return u;
    }
    
    public static List<Account> createTestAccounts(Integer count) {
        Map<String,Schema.RecordTypeInfo> recordTypeMap = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Account acc;
        List<Account> accountList = new List<Account>();
        for(Integer i=0; i<1; i++) {
            acc = new Account();
            acc.Name='TestAccount '+i;
            acc.BillingCity = 'TestBillingCity';
            acc.BillingState = 'Iowa';
            acc.BillingStreet = 'TestBillingStreet';
            acc.BillingPostalCode = 'TestBilling';
            acc.ShippingCity = 'TestShippingCity';
            acc.ShippingState = 'Iowa';
            acc.ShippingStreet = 'TestShippingStreet';
            acc.ShippingPostalCode = 'TestShipping';
            acc.RecordTypeId= recordTypeMap.get('Global Account').getRecordTypeId();
            acc.Market_Channel__c='Retail Channel';
            acc.Status__c='Active';
            accountList.add(acc);
        }
        Insert accountList;
        System.assertNotEquals(accountList.size(),0);
        return accountList;
    }
    
     public static List<opportunity> createTestOpportunity(Integer count,List<Account> accountList) {
        
        List<Opportunity> opportunityList=new List<opportunity>();

        for(Integer j=0;j<accountList.size();j++) {
            Account acc=accountList[j];
            for(Integer k=0; k < count; k++) {
                
                Opportunity opp= new Opportunity();
                opp.Name= accountList[j].Name + 'Opportunity ' + k;
                opp.NextStep='test';                                   
                opp.CloseDate = System.today();                                    
                opp.AccountId=acc.id; 
                opp.StageName='Closed Won'; 
                opp.Probability=100;
                opp.External_ID__c='Clone';
                opp.RenewalDate__c=system.today();
                opportunityList.add(opp);
             }
         }
         Insert opportunityList;
         System.assertNotEquals(opportunityList.size(),0);
         return opportunityList;
    }
    public static List<ProjectTeamMembers__c> createTestProjectTeamMembers(Integer count,Project__c prj,List<Opportunity> opportunityList){
        List<ProjectTeamMembers__c> lstPrjTeam=new List<ProjectTeamMembers__c>();
        for(Integer k=0; k < count; k++) {
            ProjectTeamMembers__c prjTeam=new ProjectTeamMembers__c();
            prjTeam.Project__c=prj.Id;
            prjTeam.Role__c='TechLead';
            prjTeam.Member__c=createTestUser('Account Manager').Id;
            prjTeam.LegacyRecordID__c='LegacyRecordID'+k;
            lstPrjTeam.add(prjTeam);
        }
        insert lstPrjTeam;
        return lstPrjTeam;
    }
     
    public static Project__c createTestProject(Integer count,List<Account> accountList,List<Opportunity> opportunityList){
        Project__c prj = new Project__c();
        if(!(accountList.isEmpty()) && accountList[0]!=Null )
        {
            prj.Account__c= accountList[0].Id;
        }
        prj.ActivityDate__c=System.today();
        prj.Phase__c='Explore';
        prj.opportunity__c=opportunityList[0].Id;
        prj.Stage__c='Submitted for Approval';
        insert prj;
        return prj;
    }
    
    public static ProjectProduct__c createTestProjectProduct(Project__c prj){
        List<Product2> productList=createTestProducts(1);
        PricebookEntry pbe =createTestPricebookentry(productList[0]);
        ProjectProduct__c prjProd=new ProjectProduct__c();
        prjProd.Product__c=productList[0].Id;
        prjProd.Project__c=prj.Id;
        insert prjProd;
        return prjProd;
    
    }
    public static List<OpportunityTeamMember> createTestOpportunityTeamMember(Integer count,List<Opportunity> opportunityList) {
       List<OpportunityTeamMember> lstOppTeam=new List<OpportunityTeamMember>();
       User u=[select profile.name, Id from User where profile.name='System Administrator' LIMIT 1];
       for(Integer j=0;j<opportunityList.size();j++) {
           Opportunity opp=opportunityList[j];
           for(Integer k=0; k < count; k++) {
             OpportunityTeamMember oppTeam=new OpportunityTeamMember();
             oppTeam.TeamMemberRole='Account Manager';
             oppTeam.OpportunityId=opp.Id;
             oppTeam.UserId=u.Id;            //createTestUser('System Administrator').Id;
             lstOppTeam.add(oppTeam);
           }
       }
       insert lstOppTeam;
       System.assertNotEquals(lstOppTeam.size(),0);
       return lstOppTeam;
    }
    
     public static List<Product2> createTestProducts(Integer count){
         List<Product2> productList=new List<Product2>();
         for(Integer k=0; k < count; k++) {
              Product2 prod=new Product2();
             prod.Name='Test Product Entry '+k;
             prod.Description='Test Product Entry '+k;
             prod.productCode = 'ABC';
             prod.isActive = true;
             prod.Business__c='Commercial Excellence NA';
             prod.Product_Deployment__c='Placeholder';
             productList.add(prod);
          }
          Insert productList;
          System.assertNotEquals(productList.size(),0);
          return productList;
     }
     
     public static PricebookEntry createTestPricebookentry(Product2 prod){
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prod.Id,Pricebook2ID=Test.getStandardPricebookId(),UnitPrice=50, isActive=true);
        insert pbe1;
        System.assertNotEquals(pbe1,Null);
        return pbe1;
     }
     public static List<OpportunityLineItem> createTestOpportunityLineItem(Integer count,List<Opportunity> opportunityList) {
        List<Product2> productList=createTestProducts(1);
        List<Account> lstAcc=new List<Account>();
        lstacc.add(opportunityList[0].Account);
        Project__c prj=createTestProject(1,lstAcc,opportunityList);
        ProjectProduct__c prjProd= createTestProjectProduct( prj);
        PricebookEntry pbe =createTestPricebookentry(productList[0]);
       
        List<OpportunityLineItem> oppLIList=new List<OpportunityLineItem>();
         for(Integer j=0;j<opportunityList.size();j++) {
            Opportunity opp=opportunityList[j];
            for(Integer k=0; k < count; k++) {
                 OpportunityLineItem oppLI=new OpportunityLineItem();
                 oppLI.OpportunityID=opp.id;
                 oppLI.PriceBookEntryID=pbe.Id;
                 oppLI.quantity=4;
                 oppLI.totalprice=200;
                 
                 oppLI.Project_Product_Id__c =prjProd.Id;
                 oppLIList.add(oppLI);
             }
         }
         Insert oppLIList;
         System.assertNotEquals(oppLIList.size(),0);
         return oppLIList;
     }
     public static List<AccountPlan__c> createTestAccountPlan(Integer count,List<Account> AccountList) {
                
        List<AccountPlan__c> apList = new List<AccountPlan__c>();
        for(Integer j=0;j<AccountList.size();j++) {
           Account acc=AccountList[j];
           for(Integer i=0; i<count; i++) {
               AccountPlan__c ap=new AccountPlan__c ();
               ap.Name='APtest'+i;
               ap.Account__c=acc.Id;
               ap.Plan_Year__c='2017';
           
               apList.add(ap);
           }
        }
        Insert apList;
        System.assertNotEquals(apList.size(),0);
        return apList;
    }
    public static List<AccountTeamMember> createTestAccountTeamMember(Integer count,List<Account> AccountList) {
       List<AccountTeamMember> lstAccTeam=new List<AccountTeamMember>();
       User User1=createTestUser('System Administrator');
       for(Integer j=0;j<AccountList.size();j++) {
           Account acc=AccountList[j];
           for(Integer k=0; k < count; k++) {
             AccountTeamMember accTeam=new AccountTeamMember();
             accTeam.TeamMemberRole='Account Manager';
             accTeam.AccountId=acc.Id;
             accTeam.UserId=User1.Id;            //createTestUser('System Administrator').Id;
             lstAccTeam.add(accTeam);
           }
       }
       insert lstAccTeam;
       System.assertNotEquals(lstAccTeam.size(),0);
       return lstAccTeam;
    }
    public static List<CustomerProfile__c > createTestOpportunityTeamMember(Integer count,List<Account> accountlist) {
       List<CustomerProfile__c > CPList=new List<CustomerProfile__c >();
       
       for(Integer j=0;j<accountlist.size();j++) {
           Account Acc=accountlist[j];
           for(Integer k=0; k<count; k++) {
             CustomerProfile__c CP=new CustomerProfile__c();
             CP.Account__c=Acc.Id;
             CP.Name='TestCP'+k;
             
             CPList.add(CP);              
           }
       }
       insert CPList;
       System.assertNotEquals(CPList.size(),0);
       return CPList;
    }
     
}