@isTest
public class AVX_CreditLimitTriggerHelper_tst {
    @TestSetup
    static void makeData(){
        User objSupervisorUser = AVX_DataGenerator_cls.createUser('Misa');
        insert objSupervisorUser;

        Integration_profile__c objCustomSettings = AVX_DataGenerator_cls.createCustomSettings(true);
        insert objCustomSettings;

        Account objGlobalAcc = AVX_DataGenerator_cls.createGlobalAccount('GlobalAcc');
        insert objGlobalAcc;

        Account objCommercialAcc = AVX_DataGenerator_cls.createCommercialAccount('CommercialAcc', objGlobalAcc);
        insert objCommercialAcc;

        Account objCommercialAcc2 = AVX_DataGenerator_cls.createCommercialAccount('CommercialAcc2', objGlobalAcc);
        insert objCommercialAcc2;

        Account objPayerAcc = AVX_DataGenerator_cls.createPayerAccount('PayerAcc', objCommercialAcc);
        insert objPayerAcc;

        Contact objContact = AVX_DataGenerator_cls.createContact('El', objGlobalAcc, 'misa@el.com');
        insert objContact;

        Bill_To__c objBillTo = AVX_DataGenerator_cls.createBillTo('BillTo1', objPayerAcc, objCommercialAcc);
        insert objBillTo;

        Ship_To__c objShipTo = AVX_DataGenerator_cls.createShipTo('ShipTo1', objPayerAcc, objBillTo);
        insert objShipTo; 

        CreditLimit__c objCreditLimit = AVX_DataGenerator_cls.createCreditLimit(objCommercialAcc);
        insert objCreditLimit;

        CreditLimit__c objCreditLimit2 = AVX_DataGenerator_cls.createCreditLimit(objCommercialAcc2);
        objCreditLimit2.IsActive__c = false;
        insert objCreditLimit2;
    }

    @isTest
    public static void relateShipToAndCreditLimitInsert(){
        CreditLimit__c objCreditLimit = [SELECT Id FROM CreditLimit__c WHERE CommercialAccount__r.Name = 'CommercialAcc'];
        System.assert(objCreditLimit != null);

        Ship_To__c objShipTo = [SELECT Id FROM Ship_To__c WHERE Name = 'ShipTo1'];
        System.assert(objShipTo != null);
    }

    @isTest
    public static void relateShipToAndCreditLimitUpdate(){
        User objUser = [SELECT Id FROM User WHERE FirstName = 'Misa'];
        System.assert(objUser != null);

        CreditLimit__c objCreditLimit = [SELECT Id, IsActive__c FROM CreditLimit__c WHERE CommercialAccount__r.Name = 'CommercialAcc2'];
        System.assert(objCreditLimit != null);

        Ship_To__c objShipTo = [SELECT Id FROM Ship_To__c WHERE Name = 'ShipTo1'];
        System.assert(objShipTo != null);

        Test.startTest();
        System.runAs(objUser){
            objCreditLimit.IsActive__c = true;
            update objCreditLimit;
        }
        Test.stopTest();
    }
}