@isTest 
public with sharing class AVX_CreateTasksByPlan_tst {
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
        objShipTo.Commercial_Account__c = objCommercialAcc.Id;
        insert objShipTo;
        
        TelesalesPlan__c objTeleSalesPlan = AVX_DataGenerator_cls.createTeleSalesPlan(objTelemarketerUser, objSupervisorUser);
        objTeleSalesPlan.StartDate__c = Date.today();
        objTeleSalesPlan.EndDate__c = Date.today();
        insert objTeleSalesPlan;

        TelesalesPlanDetail__c objTeleSalesPlanDetail = AVX_DataGenerator_cls.createTeleSalesPlanDetail(objTeleSalesPlan, objCommercialAcc, objShipTo);
        objTeleSalesPlanDetail.DayOfTheWeek__c = '1';
        insert objTeleSalesPlanDetail;

        TelesalesPlanDetail__c objTeleSalesPlanDetail2 = AVX_DataGenerator_cls.createTeleSalesPlanDetail(objTeleSalesPlan, objCommercialAcc, objShipTo);
        objTeleSalesPlanDetail2.DayOfTheWeek__c = '2';
        insert objTeleSalesPlanDetail2;

        TelesalesPlanDetail__c objTeleSalesPlanDetail3 = AVX_DataGenerator_cls.createTeleSalesPlanDetail(objTeleSalesPlan, objCommercialAcc, objShipTo);
        objTeleSalesPlanDetail3.DayOfTheWeek__c = '3';
        insert objTeleSalesPlanDetail3;

        TelesalesPlanDetail__c objTeleSalesPlanDetail4 = AVX_DataGenerator_cls.createTeleSalesPlanDetail(objTeleSalesPlan, objCommercialAcc, objShipTo);
        objTeleSalesPlanDetail4.DayOfTheWeek__c = '4';
        insert objTeleSalesPlanDetail4;

        TelesalesPlanDetail__c objTeleSalesPlanDetail5 = AVX_DataGenerator_cls.createTeleSalesPlanDetail(objTeleSalesPlan, objCommercialAcc, objShipTo);
        objTeleSalesPlanDetail5.DayOfTheWeek__c = '5';
        insert objTeleSalesPlanDetail5;

        TelesalesPlanDetail__c objTeleSalesPlanDetail6 = AVX_DataGenerator_cls.createTeleSalesPlanDetail(objTeleSalesPlan, objCommercialAcc, objShipTo);
        objTeleSalesPlanDetail6.DayOfTheWeek__c = '6';
        insert objTeleSalesPlanDetail6;

        TelesalesPlanDetail__c objTeleSalesPlanDetail7 = AVX_DataGenerator_cls.createTeleSalesPlanDetail(objTeleSalesPlan, objCommercialAcc, objShipTo);
        objTeleSalesPlanDetail7.DayOfTheWeek__c = '7';
        insert objTeleSalesPlanDetail7;
    }

    @isTest
    static void createTaskbyPlanRun(){
        Test.startTest();
        AVX_CreateTasksByPlan_sch sch = new AVX_CreateTasksByPlan_sch();      
        String schTime = '0  00 1 3 * ?';
        system.schedule('Test', schTime, sch);
        Test.stopTest();


    }

    @isTest
    static void createTaskbyPlan(){
        Date dateParam = Date.newInstance(2020, 10, 03);

        Test.startTest();
        AVX_CreateTasksByPlan_batch bch0 = new AVX_CreateTasksByPlan_batch();

        TelesalesPlan__c objTeleSalesPlan = [SELECT Id, StartDate__c, EndDate__c FROM TelesalesPlan__c LIMIT 1 ];
        objTeleSalesPlan.StartDate__c = dateParam;
        objTeleSalesPlan.EndDate__c = dateParam;
        update objTeleSalesPlan;

        AVX_CreateTasksByPlan_batch bch = new AVX_CreateTasksByPlan_batch(dateParam);
        Database.executeBatch(bch);
        Test.stopTest();

        Task task1 = [SELECT ShipTo__c, TelesalesPlan__c, Subject, ShipTo__r.Commercial_Account__r.Name FROM task LIMIT 1 ];
        System.AssertEquals(task1.ShipTo__c, [SELECT Id FROM Ship_To__c LIMIT 1].Id);
        System.AssertEquals(task1.TelesalesPlan__c, [SELECT Id FROM TelesalesPlan__c LIMIT 1].Id);


    }













}