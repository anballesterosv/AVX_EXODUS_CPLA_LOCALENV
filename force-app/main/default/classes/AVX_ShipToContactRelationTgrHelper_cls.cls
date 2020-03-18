/**
**************************************************************************************************************
* @company          Avanxo Brasil
* @author           Igor Novaes href=<igor.novaes@globant.com>
* @project          EXODUS - CPLA Cargill
* @name             AVX_CreditLimit_tgr
* @description      Helper for the trigger AVX_ShipToContactRelation_tgr
* @dependencies     none
* @changes (Version)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Date         Author                        Description
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* @version   1.0   2020-02-04   Igor Novaes.                  Initial version.
**************************************************************************************************************
**/

public class AVX_ShipToContactRelationTgrHelper_cls {

    public static void relateContactPrimaryContact(List<CS_Ship_To_Contact_Relation__c> lstContext) {

        Map<Id,Id> mapContactToShipTo = new Map<Id,Id>();
        for(CS_Ship_To_Contact_Relation__c objContactToShipTo : lstContext){
            if(objContactToShipTo.PrimaryContact__c){
                mapContactToShipTo.put(objContactToShipTo.CS_Ship_To__c,objContactToShipTo.CS_Contact__c);
            }
        }

        List<Ship_To__c> lstShipTo = [SELECT Id, PrimaryContact__c FROM Ship_To__c WHERE Id IN :mapContactToShipTo.keySet()];
        
        if(lstShipTo != null && !lstShipTo.isEmpty()){
            List<Ship_To__c> lShipToUpdt = new List<Ship_To__c>();
            for(Ship_To__c objShipTo : lstShipTo){
                if(objShipTo.PrimaryContact__c != mapContactToShipTo.get(objShipTo.Id)){
                    objShipTo.PrimaryContact__c = mapContactToShipTo.get(objShipTo.Id);
                    lShipToUpdt.add(objShipTo);
                }
            }

            if(lShipToUpdt != null && !lShipToUpdt.isEmpty()){
                update lShipToUpdt;
            }
        }
    }    
}