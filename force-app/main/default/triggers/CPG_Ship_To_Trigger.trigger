trigger CPG_Ship_To_Trigger on Ship_To__c (before Insert, before update, before delete, after Insert, after update, after delete) {
    //Call method to specify COmmercial Accounts for Ship To records.
    CPG_Ship_To_TriggerHandler.setupShipToCommercialAccounts();
}