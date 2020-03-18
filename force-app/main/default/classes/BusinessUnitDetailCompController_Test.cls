@isTest
private class BusinessUnitDetailCompController_Test{
    static testMethod void validateHelper(){
        Account acc1= new Account();
        acc1.Name ='TestAccount';
        acc1.BillingCity ='Chennai' ;
        acc1.BillingCountry='india';         
        acc1.BillingPostalCode='600075';
        acc1.BillingState='tamil nadu';
        acc1.BillingStreet='water well street';  
        acc1.ShippingCity='Chennai';
        acc1.ShippingCountry='india';         
        acc1.ShippingPostalCode='600075';
        acc1.ShippingState='tamil nadu';
        acc1.ShippingStreet='waterr well street';
        acc1.Market_Channel__c='Retail Channel';
        insert acc1;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'SysAdm', Email='systemadmin@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles',Cargill_Business_Unit__c='Commercial Excellence NA',CargillRegion__c = 'South America (SA)',CargillEnterprise__c = 'FoodIngredientsBioIndustrialFIBI',CargillGroup__c='GoToMarket (GTM)', UserName='standarduser22@testorg.com');
        insert u;
        
        AccountTeamMember aa = new AccountTeamMember();
        aa.UserId= u.Id;
        aa.AccountId =acc1.Id;
        insert aa; 
        
        
        Business__c bb= new Business__c();
        bb.Name = 'test';
        bb.BusinessUnitAlias__c ='GTM Corp Accts';
        bb.CargillEnterprise__c = 'FoodIngredientsBioIndustrialFIBI';
        bb.CargillGroup__c = 'GoToMarket (GTM)';
        
        insert bb;
        
        
        BusinessDetail__c bd = new BusinessDetail__c();
        bd.Name = 'test';
        bd.Account__c = acc1.Id;
        bd.BusinessUnit__c =bb.Id;
        bd.Status__c = 'Active';
        bd.PrimaryBusinessContact__c = u.Id;
        insert bd;
        
        List<BusinessDetail__c> listbud =[select Id from BusinessDetail__c];
        //String idb = [select Id from BusinessDetail__c LIMIT 1].Id;
        BusinessUnitDetailCompController callm = new BusinessUnitDetailCompController();
        BusinessUnitDetailCompController.getBusinessUnitDetail(acc1.Id);
        BusinessUnitDetailCompController.getCurrentUserBusinessUnit();
        BusinessUnitDetailCompController.getAccountTeamList('Go To Market Corporate Accounts',acc1.Id);
        BusinessUnitDetailCompController.getCurrentUserBusinessUnit(listbud);
        BusinessUnitDetailCompController.updateBusinessUnitDetail(listbud);
        BusinessUnitDetailCompController.getUpdatedBusinessDetail(bd.Id);
        
    }
}