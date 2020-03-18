@isTest 
public class AVX_TeleSalesPlan_tst {
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

        Ship_To__c objShipTo2 = AVX_DataGenerator_cls.createShipTo('ShipTo2', objPayerAcc, objBillTo);
        insert objShipTo2;

        TelesalesPlan__c objTeleSalesPlan = AVX_DataGenerator_cls.createTeleSalesPlan(objTelemarketerUser, objSupervisorUser);
        insert objTeleSalesPlan;
        
        TelesalesPlanDetail__c objTeleSalesPlanDetail = AVX_DataGenerator_cls.createTeleSalesPlanDetail(objTeleSalesPlan, objCommercialAcc, objShipTo);
        insert objTeleSalesPlanDetail;

        TelesalesPlanDetail__c objTeleSalesPlanDetail2 = AVX_DataGenerator_cls.createTeleSalesPlanDetail(objTeleSalesPlan, objCommercialAcc, objShipTo2);
        insert objTeleSalesPlanDetail2;
        
        TelesalesPlan__c planContingency = AVX_DataGenerator_cls.createTeleSalesPlanContingency(objTelemarketerUser, objSupervisorUser);
        planContingency.TelesalesWorkPlan__c = objTeleSalesPlan.Id;
        insert planContingency;
        
        TelesalesPlanDetail__c objPlanContingencynDetail = AVX_DataGenerator_cls.createTeleSalesPlanDetail(planContingency, objCommercialAcc, objShipTo);
        insert objPlanContingencynDetail;   
        

    }

    @isTest
    static void teleSalesPlanTest01(){
        User objUser = [SELECT Id FROM User WHERE FirstName = 'Supervisor' LIMIT 1];
        System.assert(objUser != null);

        Account objGlobalAcc = [SELECT Id FROM Account WHERE Name = 'GlobalAcc' LIMIT 1];
        System.assert(objGlobalAcc != null);

        Account objCommercialAcc = [SELECT Id FROM Account WHERE Name = 'CommercialAcc' LIMIT 1];
        System.assert(objCommercialAcc != null);

        Account objPayerAcc = [SELECT Id FROM Account WHERE Name = 'PayerAcc' LIMIT 1];
        System.assert(objPayerAcc != null);

        Bill_To__c objBillTo = [SELECT Id FROM  Bill_To__c WHERE Name = 'BillTo1' LIMIT 1];
        System.assert(objBillTo != null);

        Ship_To__c objShipTo = [SELECT Id FROM Ship_To__c WHERE Name = 'ShipTo1' LIMIT 1];
        System.assert(objShipTo != null);

        TelesalesPlan__c objTeleSalesPlan = [SELECT Id FROM TelesalesPlan__c WHERE Supervisor__r.FirstName = 'Supervisor' LIMIT 1];
        System.assert(objTeleSalesPlan != null);
        Id recordTypeContingency = Schema.SObjectType.TelesalesPlan__c.getRecordTypeInfosByDeveloperName().get('ContingencyPlan').getRecordTypeId();
        TelesalesPlan__C planContingency = [SELECT Id FROM TelesalesPlan__c WHERE RecordTypeId =:recordTypeContingency LIMIT 1];

        List<TelesalesPlanDetail__c> lstTeleSalesPlanDetail = [SELECT Id FROM TelesalesPlanDetail__c WHERE CommercialAccount__r.Name = 'CommercialAcc' LIMIT 1];
        System.assert(!lstTeleSalesPlanDetail.isEmpty());

        List<Id> lstTelesalesId = new List<Id>();
        for(TelesalesPlanDetail__c objTeleSalesPlanDetail : lstTeleSalesPlanDetail){
            lstTelesalesId.add(objTeleSalesPlanDetail.Id);
        }

        List<AVX_TeleSalesPlan_ctr.WrapperClientList> lstWrapperClient = new List<AVX_TeleSalesPlan_ctr.WrapperClientList>();
        List<AVX_TeleSalesPlan_ctr.WrapperOptionCombo> lstWrapperOption = new List<AVX_TeleSalesPlan_ctr.WrapperOptionCombo>();
        List<AVX_TeleSalesPlan_ctr.WrapperTelesalesPlan> lstWrapperTelesales = new List<AVX_TeleSalesPlan_ctr.WrapperTelesalesPlan>();

        Test.startTest();
        System.runAs(objUser){
            
            AVX_TeleSalesPlan_ctr ctr = new AVX_TeleSalesPlan_ctr();
            AVX_TeleSalesPlan_ctr.getClientsByFilters(String.valueOf(objTeleSalesPlan.Id), 'ShipTo1', 'ADDED',true);
            AVX_TeleSalesPlan_ctr.getClientsByFilters(String.valueOf(objTeleSalesPlan.Id), 'ShipTo1', 'ADDED',false);
            AVX_TeleSalesPlan_ctr.getClientsByFiltersReload(String.valueOf(objTeleSalesPlan.Id), 'ShipTo1', 'ADDED',false);
                
            AVX_TeleSalesPlan_ctr.getPlanDetailsByPlanReload(String.valueOf(objTeleSalesPlan.Id), 'GENERAL', 'HOURASC');
            AVX_TeleSalesPlan_ctr.getPlanDetailsByPlanReload(String.valueOf(objTeleSalesPlan.Id), 'GENERAL', 'HOURASC');
            AVX_TeleSalesPlan_ctr.getPlanDetailsByPlanReload(String.valueOf(objTeleSalesPlan.Id), '1', 'HOURASC');
            AVX_TeleSalesPlan_ctr.getPlanDetailsByPlanReload(String.valueOf(objTeleSalesPlan.Id), '1', 'HOURASC');
            AVX_TeleSalesPlan_ctr.getPlanDetailsByPlan(String.valueOf(objTeleSalesPlan.Id), 'GENERAL', 'ERP');
            AVX_TeleSalesPlan_ctr.executeQueryPlanDetailsByPlan(String.valueOf(objTeleSalesPlan.Id), 'Monday', 'NAME');
            AVX_TeleSalesPlan_ctr.executeQueryPlanDetailsByPlan(String.valueOf(objTeleSalesPlan.Id), 'GENERAL', 'NAME');
            AVX_TeleSalesPlan_ctr.executeQueryPlanDetailsByPlan(String.valueOf(objTeleSalesPlan.Id), 'Monday', 'ERP');
            AVX_TeleSalesPlan_ctr.saveOrUpdateTelesalesPlanDetails(lstTeleSalesPlanDetail);
            AVX_TeleSalesPlan_ctr.getPickistValuesByField('DAYS');
            AVX_TeleSalesPlan_ctr.getPickistValuesByField('PRIORITY');
            AVX_TeleSalesPlan_ctr.canEdit('DAYS');
            AVX_TeleSalesPlan_ctr.getPlanDetailsByShipToReload(String.valueOf(objShipTo.Id));
            AVX_TeleSalesPlan_ctr.getPlanDetailsByShipTo(String.valueOf(objShipTo.Id));
            AVX_TeleSalesPlan_ctr.deleteListTelesalesPlanDetails(lstTelesalesId);
            AVX_TeleSalesPlan_ctr.parseSecondsToHours(123456789);
            //Contingency
            TelesalesPlan__c t = [SELECT Id,recordtypeid  FROM TelesalesPlan__c  LIMIT 1];
            AVX_TeleSalesPlan_ctr.getRecordTypeById(t.recordtypeid);
            List<TelesalesPlan__c> lstPlans = [SELECT Id,recordtypeid,Telemarketer__c  FROM TelesalesPlan__c  LIMIT 2];
            String exclusions;
            if(!lstPlans.isEmpty()){
                Boolean addComa = false;
                for(TelesalesPlan__c p: lstPlans){
                    if(addComa){
                        exclusions = exclusions + ',';
                    }
                    exclusions = exclusions + p.Telemarketer__c;
                    addComa = true;
                }
                AVX_TeleSalesPlan_ctr.getTelemarketerByFilters('tele,super,a,b,c',exclusions, string.valueOf(planContingency.Id));
            }

            AVX_TeleSalesPlan_ctr.getContingencyClients('ShipTo1, ShipTo2', 'GENERAL', planContingency.Id );
            AVX_TeleSalesPlan_ctr.getContingencyClients('a,b,c', '1', planContingency.Id );
            AVX_TeleSalesPlan_ctr.getContingencyClients('a,b,c', 'GENERAL', planContingency.Id );
            AVX_TeleSalesPlan_ctr.reloadContingencyClients('a,b,c', 'GENERAL', planContingency.Id );
           }
        Test.stopTest();
    }
}