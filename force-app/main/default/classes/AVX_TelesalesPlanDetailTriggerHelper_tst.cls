@isTest
public class AVX_TelesalesPlanDetailTriggerHelper_tst {
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

        TelesalesPlan__c objTeleSalesPlan = AVX_DataGenerator_cls.createTeleSalesPlan(objTelemarketerUser, objSupervisorUser);
        insert objTeleSalesPlan;     

        TelesalesPlanDetail__c objTeleSalesPlanDetail = AVX_DataGenerator_cls.createTeleSalesPlanDetail(objTeleSalesPlan, objCommercialAcc, objShipTo);
        insert objTeleSalesPlanDetail;

        TelesalesPlan__c objContingencyPlan = AVX_DataGenerator_cls.createContingencyPlan(objTeleSalesPlan);
        insert objContingencyPlan;

        TelesalesPlanDetail__c objTeleSalesPlanDetail2 = AVX_DataGenerator_cls.createTeleSalesPlanDetail(objContingencyPlan, objCommercialAcc, objShipTo);
        insert objTeleSalesPlanDetail2;
    }

    @isTest 
    static void testTaskCreation(){
        User user = [SELECT Id FROM User WHERE FirstName = 'Supervisor'];
        System.assert(user != null);

        TelesalesPlanDetail__c objTeleSalesPlanDetail = [SELECT Id, Hours__c FROM TelesalesPlanDetail__c WHERE Ship_To__r.Name = 'ShipTo1' LIMIT 1];
        System.assert(objTeleSalesPlanDetail != null);

        Task objTask = [SELECT Id, Status FROM Task WHERE TelesalesPlanDetail__c = :objTeleSalesPlanDetail.Id LIMIT 1];
        System.assert(objTask != null);

        TelesalesPlan__c objTelesalesPlan = [SELECT Id FROM TelesalesPlan__c WHERE Reason__c = 'Holidays' LIMIT 1];
        System.assert(objTelesalesPlan != null);

        TelesalesPlanDetail__c objTeleSalesPlanDetail2 = [SELECT Id FROM TelesalesPlanDetail__c WHERE TelesalesPlan__r.RecordType.DeveloperName = 'ContingencyPlan'];
        System.assert(objTeleSalesPlanDetail2 != null);

        Test.startTest();
        System.runAs(user){
            AVX_TelesalesPlanDetailTriggerHelper_cls newHelper = new AVX_TelesalesPlanDetailTriggerHelper_cls();
            objTeleSalesPlanDetail.Hours__c += 50000;
            update objTeleSalesPlanDetail;

            objTask.Status = 'InProgress';
            update objTask;

            objTeleSalesPlanDetail.Hours__c += 100000;
            update objTeleSalesPlanDetail;

            delete objTeleSalesPlanDetail;

            List<Task> lstTask = [SELECT Id FROM Task WHERE TelesalesPlanDetail__c = :objTeleSalesPlanDetail.Id];
            System.assert(lstTask.isEmpty());
        }
        Test.stopTest();

    }
}