/**************************************************************************************************************
* Avanxo Brasil
* @author           Ismael Sanchez (isanchez@avanxo.com)
* Project:          CPLA - EXODUS Project
* Description:      Class used to show the sales script related a client
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                      Description     
*           -----   ----------      --------------------        ---------------   
* @version   1.0    2020-03-05      Ismael Sanchez              class created 
*************************************************************************************************************/
public with sharing class AVX_SalesScript_ctr {
    public AVX_SalesScript_ctr() {

    }

    @AuraEnabled(cacheable=true)
    public static Ship_To__c getShipToByTask( String idTask){
        Ship_To__c shipTo = new Ship_To__c();
        List<Task> lstTasks = [Select Id, ShipTo__c from Task where id=:idTask ];
        if(!lstTasks.isEmpty()){
            Id idShipTo = lstTasks[0].ShipTo__c;
            List<Ship_To__c> lstShipTos = [Select Country__c, CountyCode__c from  Ship_To__c where id =:idShipTo];
            if(!lstShipTos.isEmpty()){
                shipTo = lstShipTos[0];
            }
        }
        return shipTo;
    }

    @AuraEnabled(cacheable=true)
    public static List<SalesScript__c> getSalesScriptByCountry( String country){
        List<SalesScript__c> lstSripts = new List<SalesScript__c>();
        String status = 'Active';
        String strEmpty = '';
        lstSripts = Database.query(String.escapeSingleQuotes('Select Name,Country__c,CountyCode__c,TelesalesScript__c from  SalesScript__c  where  Status__c=:status ORDER BY CountyCode__c ASC NULLS FIRST'));
        return lstSripts;
    }

}