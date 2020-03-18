@isTest
private class CPG_Ship_To_TriggerHandler_Test {
    
    static testMethod void testShipToCommercialAccountLookup() {
        Map<String,Schema.RecordTypeInfo> recordTypeMap = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        //Insert Commercial Account
        Account commAcc = new Account();
        commAcc.Name = 'Test Commercial Account';
        commAcc.BillingCity = 'Test';
        commAcc.BillingState = 'Iowa';
        commAcc.BillingStreet = 'Test';
        commAcc.BillingPostalCode = 'Test';
        commAcc.ShippingCity = 'Test';
        commAcc.ShippingState = 'Iowa';
        commAcc.ShippingStreet = 'Test';
        commAcc.ShippingPostalCode = 'Test';
        commAcc.RecordTypeId= recordTypeMap.get('Commercial Account').getRecordTypeId();
        commAcc.Market_Channel__c='Retail Channel';
        insert commAcc;
        //Insert Payer
        Account payerAcc = new Account();
        payerAcc.Name = 'Test Payer';
        payerAcc.parentid = commAcc.id;
        payerAcc.BillingCity = 'Test';
        payerAcc.BillingState = 'Iowa';
        payerAcc.BillingStreet = 'Test';
        payerAcc.BillingPostalCode = 'Test';
        payerAcc.ShippingCity = 'Test';
        payerAcc.ShippingState = 'Iowa';
        payerAcc.ShippingStreet = 'Test';
        payerAcc.ShippingPostalCode = 'Test';
        payerAcc.RecordTypeId= recordTypeMap.get('Payer').getRecordTypeId();
        payerAcc.Market_Channel__c='Retail Channel';
        insert payerAcc;
        
        //Insert Bill To
        Bill_To__c billTo =  new Bill_To__c();
        billTo.ERP_Number__c='7654321|XLGO';
        billTo.City__c = 'Wichita';
        billTo.State__c='KS';
        billTo.Country__c='US';
        billTo.street__c = '100 N Main';   
        billTo.Payer__c= payerAcc.id;
        insert billTo;
        
        //Insert Ship To
        Ship_To__c shipTo  =  new Ship_To__c();
        shipTo .ERP_Number__c='7654321|wichita';
        shipTo .City__c = 'Wichita';
        shipTo .State__c='KS';
        shipTo .Country__c='US';
        shipTo .street__c = '100 N Main'; 
        shipTo.sold_to__c = billTo.id;  
        shipTo .Payer__c= payerAcc.id;
        insert shipTo ;
        
        //Insert Ship To
        
    
    Test.StartTest();
    Bill_to__c iBillTo =[select commercial_Account__c from Bill_to__c where ERP_Number__c='7654321|XLGO'];
    Ship_to__c iShipTo =[select commercial_Account__c from Ship_to__c where ERP_Number__c='7654321|wichita'];
    system.assertEquals(iBillTo.commercial_Account__c ,commAcc.id , 'Commercial Account not associated to Bill To record!');
    system.assertEquals(iShipTo.commercial_Account__c ,commAcc.id , 'Commercial Account not associated to Ship To record!');
    Test.StopTest();
        
    }
}