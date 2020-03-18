trigger CPG_Bill_To_Trigger on Bill_To__c (before Insert, before update, before delete, after Insert, after update, after delete) {
    //Call method to specify COmmercial Accounts for Ship To records.
    CPG_Bill_To_TriggerHandler.setupBillToCommercialAccounts();
}