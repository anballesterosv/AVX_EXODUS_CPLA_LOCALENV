/*@Author -Apps-AMS-CustomerFacing-Global
@date - 11-13-2018
purpose:The trigger is used for updating the productcode in quotelineitem*/

trigger updateproductcode on CPQQuoteLineItem__c(before insert, before update) {
  
  if((trigger.isbefore && trigger.isInsert) || (trigger.isbefore && trigger.isUpdate))
  {
  updateproductcodeHandler.updateproductcode(trigger.new);
  }
}