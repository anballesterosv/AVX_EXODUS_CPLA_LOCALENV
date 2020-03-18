@isTest
public class AVX_ShipToContactRelationTgrHelper_tst {
    @TestSetup
    static void makeData(){
        User objUser = AVX_DataGenerator_cls.createUser('Misa');
        insert objUser;

        Integration_profile__c objCustomSettings = AVX_DataGenerator_cls.createCustomSettings(true);
        insert objCustomSettings;

        Account objGlobalAcc = AVX_DataGenerator_cls.createGlobalAccount('Global Acc');
        insert objGlobalAcc;

        Account objCommercialAcc = AVX_DataGenerator_cls.createCommercialAccount('Commercial Acc', objGlobalAcc);
        insert objCommercialAcc;

        Account objPayerAcc = AVX_DataGenerator_cls.createPayerAccount('Payer Acc', objCommercialAcc);
        insert objPayerAcc;

        Contact objContact = AVX_DataGenerator_cls.createContact('El', objGlobalAcc, 'misa@el.com');
        insert objContact;

        Bill_To__c objBillTo = AVX_DataGenerator_cls.createBillTo('BillTo1', objPayerAcc, objCommercialAcc);
        insert objBillTo;

        Ship_To__c objShipTo = AVX_DataGenerator_cls.createShipTo('ShipTo1', objPayerAcc, objBillTo);
        insert objShipTo;   

        CS_Ship_To_Contact_Relation__c objShipToContact = AVX_DataGenerator_cls.createShipToContactRelation(objContact, objShipTo, false);
        insert objShipToContact;
    }        

    @isTest 
    static void relateContactPrimaryContactTest(){
        User objUser = [SELECT Id FROM User WHERE FirstName = 'Misa'];
        System.assert(objUser != null);

        Contact objContact = [SELECT Id FROM Contact WHERE LastName = 'El' LIMIT 1];
        System.assert(objContact != null);

        Ship_To__c objShipTo = [SELECT Id FROM Ship_To__c WHERE Name = 'ShipTo1' LIMIT 1];
        System.assert(objShipTo != null);

        CS_Ship_To_Contact_Relation__c objShipToContact = [SELECT Id, PrimaryContact__c FROM CS_Ship_To_Contact_Relation__c WHERE CS_Ship_To__r.Name = 'ShipTo1' LIMIT 1];
        System.assert(objShipToContact != null);

        Test.startTest();
        System.runAs(objUser){
            objShipToContact.PrimaryContact__c = true;
            update objShipToContact;
        }
        Test.stopTest();
    }
}