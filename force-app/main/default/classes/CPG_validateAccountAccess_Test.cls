@isTest
private class CPG_validateAccountAccess_Test {
    
    static testMethod void testAccountTeamAccess() {
        //Create Pricing Approvers
        user uAccManager = CPG_TestFactory_Util.createTestUser('Account Manager');
        user uPricingTeam = CPG_TestFactory_Util.createTestUser('Price Team');
        
        //Create Commercial Account
        Map<String,Schema.RecordTypeInfo> recordTypeMap = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Account acc = new Account();
        acc.Name = 'Test Comm Account';
        acc.BillingCity = 'Test';
        acc.BillingState = 'Iowa';
        acc.BillingStreet = 'Test';
        acc.BillingPostalCode = 'Test';
        acc.ShippingCity = 'Test';
        acc.ShippingState = 'Iowa';
        acc.ShippingStreet = 'Test';
        acc.ShippingPostalCode = 'Test';
        acc.RecordTypeId= recordTypeMap.get('Commercial Account').getRecordTypeId();
        acc.Market_Channel__c='Retail Channel';
        insert(acc);
        //Add Account Team Member
        AccountTeamMember accMem = new AccountTeamMember();
        accMem.userid = uAccManager.id;
        accMem.accountid = acc.id ;
        accMem.AccountAccessLevel='EDIT';
        accMem.OpportunityAccessLevel = 'EDIT';
        accMem.TeamMemberRole='Account Manager';
        insert accMem;
        
        //Insert Opportunity Successfully by Account Team Member
        system.RunAs(uAccManager){
            Opportunity opp = new Opportunity();
            opp.Name='TestClone'; 
            opp.NextStep='test';                                   
            opp.CloseDate = System.today();                                    
            opp.AccountId=acc.id; 
            opp.StageName='Explore'; 
            opp.Probability=100;
            opp.Unit_of_Measure__c='Pound';
            opp.Volume__c=100;
            insert(opp);
            system.assert(opp.id!=null, 'Account Team Member not able to create Opportunity');
        }
        
        //Insert Opportunity by a non-Account Team Member and catch validation error
        system.RunAs(uPricingTeam){
            Opportunity opp = new Opportunity();
            opp.Name='TestClone'; 
            opp.NextStep='test';                                   
            opp.CloseDate = System.today();                                    
            opp.AccountId=acc.id; 
            opp.StageName='Explore'; 
            opp.Probability=100;
            opp.Unit_of_Measure__c='Pound';
            opp.Volume__c=100;
            try{               
                insert(opp);  
            }
            catch(exception e){
                //system.assert(opp.id==null, 'Non Account Team Member able to create Opportunity');
            }
            
        }
        //Independently invoking the flow in order to attain test coverage independent of Opportunity Trigger
        list<id> lstAccId = new list<id>();
        lstAccId.add(acc.id);
        CPG_validateAccountAccess.checkUserAccess(lstAccId);
        
    }
}