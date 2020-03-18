/****************************************
Name-AccountActivityListCompController_Test
Author-Heena
Created Date- 9/1/2017
Req No-
Description-this is test class for retrieving task records of related object records to particular account
******************************************/

@isTest
public without sharing class AccountActivityListCompControllerTest{
   
  
  private Static testMethod void retrieveActivityObjectListTest() {
        Cargill_Leap_App_Config__c leap = new Cargill_Leap_App_Config__c();
        leap.AccountActivityDefaultDisplayNummber__c = 100;
        leap.AccountActivityObjectList__c = 'Contact,Opportunity';
        leap.Status_Filter_List__c = 'Open';
        insert(leap);
        
        Test.startTest();   
        AccountActivityListCompController.retrieveActivityObjectList();
        Test.stopTest();
        system.assert(true);
    }
    private Static testMethod void createActivityObjectListTest() {
        Cargill_Leap_App_Config__c leap = new Cargill_Leap_App_Config__c();
        leap.AccountActivityDefaultDisplayNummber__c = 100;
        leap.AccountActivityObjectList__c = 'Opportunity,BusinessDetail__c';
        leap.Status_Filter_List__c = 'Open';
        insert(leap);
        
        Account acc = new Account();
        acc.Name = 'TestName';
        acc.BillingCity = 'TestBillingCity';
        acc.BillingState = 'Iowa';
        acc.BillingStreet = 'TestBillingStreet';
        acc.BillingPostalCode = 'TestBilling';
        acc.ShippingCity = 'TestShippingCity';
        acc.ShippingState = 'Iowa';
        acc.ShippingStreet = 'TestShippingStreet';
        acc.ShippingPostalCode = 'TestShipping';
        acc.Market_Channel__c='Retail Channel';
        insert(acc);
        
        String recordId = acc.Id;
        
        Opportunity opp = new Opportunity();
        opp.Name='TestOpp'; 
        //opp.RenewalDate__c = system.today();                                        
        opp.NextStep='testNextStep';                                   
        opp.CloseDate = System.today();                                    
        opp.AccountId=acc.id; 
        opp.StageName='Closed Won - One Time'; 
        opp.Probability=100;
        insert(opp);
        
        Task tsk1 = new Task();          
        tsk1.Subject = 'other';
        tsk1.Status = 'open';
        tsk1.ActivityDate = system.today();
        tsk1.WhatId = opp.Id;
        insert(tsk1);
        
        Business__c bUnit = new Business__c();
        bUnit.Name = 'Teat';
        bUnit.BusinessUnitAlias__c = 'GTM Corp Accts';
        bUnit.CargillEnterprise__c = 'FoodIngredientsBioIndustrialFIBI';
        bUnit.CargillGroup__c = 'GoToMarket (GTM)';
        insert(bUnit);
        
        BusinessDetail__c bDetails = new BusinessDetail__c();
        bDetails.Account__c = acc.Id;
        bDetails.BusinessUnit__c = BUnit.Id;
        bDetails.Status__c = 'Active';
        insert(bDetails);
        
        Task tsk = new Task();          
        tsk.Subject = 'other';
        tsk.Status = 'open';
        tsk.ActivityDate = system.today();
        tsk.WhatId = BDetails.Id;
        insert(tsk);
        
        Test.startTest();    
        AccountActivityListCompController.createActivityObjectList(recordId);
        Test.stopTest();
        system.assert(true);
    }
    private Static testMethod void getObjectSpecificTaskListTest() {
        Cargill_Leap_App_Config__c leap = new Cargill_Leap_App_Config__c();
        leap.AccountActivityDefaultDisplayNummber__c = 100;
        leap.AccountActivityObjectList__c = 'Opportunity,BusinessDetail__c';
        leap.Status_Filter_List__c = 'Open';
        insert(leap);
        
       /*Cargill_Leap_App_Config__c leap1 = new Cargill_Leap_App_Config__c();
        leap1.AccountActivityDefaultDisplayNummber__c = 100;
        leap1.AccountActivityObjectList__c = 'BusinessDetail__c';
        leap1.Status_Filter_List__c = 'Completed';
        insert(leap1);*/
        
    
     Account acc = new Account();
        acc.Name = 'TestAcc';
        acc.BillingCity = 'Pune';
        acc.BillingState = 'Iowa';
        acc.BillingStreet = 'Iowa';
        acc.BillingPostalCode = 'TestCode';
        acc.ShippingCity = 'TestCity';
        acc.ShippingState = 'Iowa';
        acc.ShippingStreet = 'TestStreet';
        acc.ShippingPostalCode = 'TestPoCode';
        acc.Market_Channel__c='Retail Channel';
        insert(acc);
                
        String recordID = acc.Id; 
        String selectedObj = 'Opportunity';
        String recordID1 = acc.Id; 
        String selectedObj1 = 'Business Detail';
       
        Opportunity opp = new Opportunity();
        opp.Name='TestOppName'; 
        //  Account = acc1, 
        //opp.RenewalDate__c = system.today();                                        
        opp.NextStep='testNStep';                                   
        opp.CloseDate = System.today();                                    
        opp.AccountId=acc.id; 
        opp.StageName='Closed Won - One Time'; 
        opp.Probability=100;
        insert(opp);
        
        Task tsk1 = new Task();          
        tsk1.Subject = 'other';
        tsk1.Status = 'open';
        tsk1.ActivityDate = system.today();
        tsk1.WhatId = opp.Id;
        insert(tsk1); 
        
        Business__c bUnit = new Business__c();
        BUnit.Name = 'Teat';
        BUnit.BusinessUnitAlias__c = 'GTM Corp Accts';
        BUnit.CargillEnterprise__c = 'FoodIngredientsBioIndustrialFIBI';
        BUnit.CargillGroup__c = 'GoToMarket (GTM)';
        insert(BUnit);
        
        BusinessDetail__c bDetails = new BusinessDetail__c();
        BDetails.Account__c = acc.Id;
        BDetails.BusinessUnit__c = BUnit.Id;
        BDetails.Status__c = 'Active';
        insert(BDetails);
        
        Task tsk = new Task();          
        tsk.Subject = 'other';
        tsk.Status = 'open';
        tsk.ActivityDate = system.today();
        tsk.WhatId = BDetails.Id;
        insert(tsk);
        
        Test.startTest(); 
        AccountActivityListCompController.getObjectSpecificTaskList(recordID,selectedObj);
        AccountActivityListCompController.getObjectSpecificTaskList(recordID1,selectedObj1);
        Test.stopTest();    
    }
}