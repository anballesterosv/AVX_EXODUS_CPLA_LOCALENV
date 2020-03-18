@isTest
public class AVX_SalesScript_tst {
    @TestSetup
    static void makeData(){
        User objSupervisorUser = AVX_DataGenerator_cls.createUser('Supervisor');
        insert objSupervisorUser;

        User objTelemarketerUser = AVX_DataGenerator_cls.createUser('Telemarketer');
        insert objTelemarketerUser;

        Integration_profile__c objCustomSettings = AVX_DataGenerator_cls.createCustomSettings(true);
        insert objCustomSettings;

        Account objGlobalAcc = AVX_DataGenerator_cls.createGlobalAccount('GlobalAcc');
        insert objGlobalAcc;

        Account objCommercialAcc = AVX_DataGenerator_cls.createCommercialAccount('CommercialAcc', objGlobalAcc);
        insert objCommercialAcc;

        Account objPayerAcc = AVX_DataGenerator_cls.createPayerAccount('PayerAcc', objCommercialAcc);
        insert objPayerAcc;

        Bill_To__c objBillTo = AVX_DataGenerator_cls.createBillTo('BillTo1', objPayerAcc, objCommercialAcc);
        insert objBillTo;

        Ship_To__c objShipTo = AVX_DataGenerator_cls.createShipTo('ShipTo1', objPayerAcc, objBillTo);
        insert objShipTo;

        Task objTask = AVX_DataGenerator_cls.createTask(objShipTo);
        insert objTask;
    }
    @isTest
    static void salesScript01(){
        Test.startTest();

        AVX_SalesScript_ctr ctr = new AVX_SalesScript_ctr();
        Task t = [Select id,ShipTo__c from Task limit 1];
        System.assert(t != null);

        AVX_SalesScript_ctr.getShipToByTask(String.valueOf(t.Id));
        Ship_To__c s = [select id,Country__c from Ship_To__c limit 1 ];
        System.assert(s != null);
        
        AVX_SalesScript_ctr.getSalesScriptByCountry(s.Country__c);
        Test.stopTest();
    }
}