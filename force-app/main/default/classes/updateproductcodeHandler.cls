/*@Author -Apps-AMS-CustomerFacing-Global
@date - 11-13-2018
purpose:The triggerhandler is used for updating the productcode in quotelineitem*/

public class updateproductcodeHandler{
    
    public static void updateproductcode(List<CPQQuoteLineItem__c > cpqLineItemlst)
    {
        Map<String, Id> products = new Map<String, Id>();
        for(CPQQuoteLineItem__c record: cpqLineItemlst) {
            products.put(record.Product_Code__c, null);
        }
        // Query for record Ids
        for(Product2 record: [SELECT Name FROM Product2 WHERE Name = :products.keySet()]) {
            products.put(record.Name, record.Id);
        }
        // Update Trigger.new with queried values
        for(CPQQuoteLineItem__c record: cpqLineItemlst) {
            record.ProductCode__c = products.get(record.Product_Code__c);
        }}
    
}