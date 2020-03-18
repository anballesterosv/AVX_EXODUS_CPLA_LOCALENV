trigger CPG_Quote_Ship_To_Trigger on Quote_Ship_To__c (after Insert,after delete) {
    //Call helper method to update Ship To/Sold To list on Quote
    list<Quote_Ship_To__c> lstQS = new list<Quote_Ship_To__c>();
    if(Trigger.isInsert && Trigger.isAfter){
        lstQS = Trigger.New;
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        lstQS = Trigger.old;
    }
    
    CPG_QuoteShipTo_TriggerHelper.updateSoldToShipTo(lstQS);
    
    
}