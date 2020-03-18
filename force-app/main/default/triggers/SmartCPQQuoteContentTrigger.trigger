trigger SmartCPQQuoteContentTrigger on CameleonCPQ__QuoteContent__c (after insert, after update, before insert, before update) {
        
        SmartCPQQuoteContentTriggerHandler handler = new SmartCPQQuoteContentTriggerHandler();
  
        if (Trigger.isInsert && Trigger.isBefore)
        {
            //handler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isInsert && Trigger.isAfter)
        {
           //handler.handleAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate && Trigger.isBefore)
        {
            //handler.handleBeforeUpdate(Trigger.new, Trigger.old);
        } else if (Trigger.isUpdate && Trigger.isAfter)
        {
            handler.handleAfterUpdate(Trigger.new, Trigger.old);
        }
}