/**
**************************************************************************************************************
* @company          Avanxo Brasil
* @author           Igor Novaes href=<igor.novaes@globant.com>
* @project          EXODUS - CPLA Cargill
* @name             AVX_CreditLimit_tgr
* @description      Helper for the trigger AVX_CreditLimit_tgr
* @dependencies     none
* @changes (Version)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Date         Author                        Description
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* @version   1.0   2020-02-03   Igor Novaes.                  Initial version.
**************************************************************************************************************
**/

public class AVX_CreditLimitTriggerHelper_cls {

    public static void relateShipToAndCreditLimit(List<CreditLimit__c> lstContext) {
        
        Map<Id,Id> mapCreditLimitByCommercialAcc = new Map<Id,Id>();
        for(CreditLimit__c objCreditLimit : lstContext){
            if(objCreditLimit.IsActive__c){
                mapCreditLimitByCommercialAcc.put(objCreditLimit.CommercialAccount__c, objCreditLimit.Id);
            }
        }

        List<Ship_To__c> lstShipTo = [SELECT Id,Commercial_Account__c, CreditLimit__c FROM Ship_To__c WHERE Commercial_Account__c IN :mapCreditLimitByCommercialAcc.keySet()];
        if(lstShipTo.isEmpty()) return;

        List<Ship_To__c> lstShipTo_Update = new List<Ship_To__c>();
        
        for(Ship_To__c objShipTo : lstShipTo){
            if(objShipTo.CreditLimit__c != mapCreditLimitByCommercialAcc.get(objShipTo.Commercial_Account__c)){
                objShipTo.CreditLimit__c = mapCreditLimitByCommercialAcc.get(objShipTo.Commercial_Account__c);
                lstShipTo_Update.add(objShipTo);
            }
        }

        if(lstShipTo_Update != null && !lstShipTo_Update.isEmpty()){
            update lstShipTo_Update; 
        }
    }
}