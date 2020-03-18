@isTest
public class AVX_TelesalesTriggerHelper_tst {
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
        objTeleSalesPlan.StartDate__c = Date.today() + 1;
        insert objTeleSalesPlan;     

        TelesalesPlanDetail__c objTeleSalesPlanDetail = AVX_DataGenerator_cls.createTeleSalesPlanDetail(objTeleSalesPlan, objCommercialAcc, objShipTo);
        insert objTeleSalesPlanDetail;

        TelesalesPlanDetail__c objTeleSalesPlanDetail2 = AVX_DataGenerator_cls.createTeleSalesPlanDetail(objTeleSalesPlan, objCommercialAcc, objShipTo);
        insert objTeleSalesPlanDetail2;

        try{
        	TelesalesPlan__c objTeleSalesPlan2 = AVX_DataGenerator_cls.createTeleSalesPlan(objTelemarketerUser, objSupervisorUser);
            objTeleSalesPlan2.RecordTypeId = Schema.SObjectType.TelesalesPlan__c.getRecordTypeInfosByDeveloperName().get('ContingencyPlan').getRecordTypeId();
        	insert objTeleSalesPlan2;
        }catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains(System.Label.AVX_Telesales_there_is_a_plan_active) ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }

        TelesalesPlan__c objContingencyPlan = AVX_DataGenerator_cls.createContingencyPlan(objTeleSalesPlan);
        objContingencyPlan.StartDate__c = Date.today() + 1;
        insert objContingencyPlan;

        TelesalesPlanDetail__c objTeleSalesPlanDetail3 = AVX_DataGenerator_cls.createTeleSalesPlanDetail(objContingencyPlan, objCommercialAcc, objShipTo);
        objTeleSalesPlanDetail3.Telemarketer__c = objTelemarketerUser.Id;
        insert objTeleSalesPlanDetail3;
    }

    @isTest
    static void telesalesPlanControlTest(){
        String errorMessage = System.Label.AVX_Telesales_there_is_a_plan_active;

        AVX_TelesalesTriggerHelper_cls newTrigger = new AVX_TelesalesTriggerHelper_cls();
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor'];
        System.assert(supervisor != null);

        User telemarketer = [SELECT Id FROM User WHERE FirstName = 'Telemarketer'];
        System.assert(telemarketer != null);

        TelesalesPlan__c objTeleSalesPlan = [SELECT Id, StartDate__c FROM TelesalesPlan__c 
                                            WHERE Supervisor__r.FirstName = 'Supervisor' AND Telemarketer__r.FirstName = 'Telemarketer'
                                            AND RecordType.DeveloperName = 'WorkPlan' LIMIT 1];
        System.assert(objTeleSalesPlan != null);

        TelesalesPlan__c objContingencyPlan = [SELECT Id FROM TelesalesPlan__c WHERE RecordType.DeveloperName = 'ContingencyPlan' 
                                                AND StartDate__c = :Date.today() + 1 LIMIT 1];
        System.assert(objContingencyPlan != null);

        TelesalesPlanDetail__c objTspDetail = [SELECT Id, Telemarketer__c FROM TelesalesPlanDetail__c WHERE Ship_To__r.Name = 'ShipTo1' LIMIT 1];
        System.assert(objTspDetail != null);

        Test.startTest();
        System.runAs(supervisor){
            objTeleSalesPlan.StartDate__c = Date.today();
            update objTeleSalesPlan;
            try{
                TelesalesPlan__c newPlan = objTeleSalesPlan;
            	newPlan.Id=null;
            	insert newPlan;
            } catch(Exception ex){
                Boolean exceptionMsg = ex.getMessage().contains(errorMessage) ? true : false;
                System.assertEquals(exceptionMsg, true);
            }
            

            objContingencyPlan.StartDate__c = Date.today();
            update objContingencyPlan;

            objContingencyPlan.StartDate__c = objContingencyPlan.StartDate__c + 1;
            objContingencyPlan.EndDate__c = Date.today() + 6;

            try{
                update objContingencyPlan;
            }catch(Exception ex){
                Boolean exceptionMsg = ex.getMessage().contains('The End Date cannot be greater') ? true : false;
                System.assertEquals(exceptionMsg, true);
            }
            delete objContingencyPlan;
        }
        Test.stopTest();
    }
}