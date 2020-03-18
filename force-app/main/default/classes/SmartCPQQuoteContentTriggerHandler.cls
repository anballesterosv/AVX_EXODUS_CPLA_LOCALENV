public class SmartCPQQuoteContentTriggerHandler{
    
    /**
     * Main method called on an after update trigger on the CameleonCPQ__QuoteContent__c object
     */
    public void handleAfterUpdate(List<CameleonCPQ__QuoteContent__c> quoteContentsNew, List<CameleonCPQ__QuoteContent__c> quoteContentsOld){
    	//Loop through all the cart Contents after update
    	for (CameleonCPQ__QuoteContent__c quoteContentNew : quoteContentsNew) {
            
            //Retrieve the PROS SmartCPQ associated with the current quote content (Cart Spreadsheet)
            CameleonCPQ__Quote__c quote = SmartCPQUtils.getQuote(quoteContentNew);
            
			//Get List of all contract Sync Ids of all Quote line items for current SmartCPQ Quote
			Set<String> existingContractSyncIds = SmartCPQUtils.getExistingQLISyncIds(quote);            
            
            // CameleonCPQ.CPQParser is a managed package utility class used to access the cart's content. Refer to page 54 of the guide for its API desciption.
             CameleonCPQ.CPQParser.Quote parsedQuote = SmartCPQUtils.getParsedQuote(quoteContentNew.Id);

            //Get all cart line items
            List<CameleonCPQ.CPQParser.QuoteLine> xmlLines = parsedQuote.getAllLines();
           
           /* String syncId = '';
            for (CameleonCPQ.CPQParser.QuoteLine xmlLine : xmlLines){
                Map<String, String> columns = xmlLine.getColumns();
                
                //Get Contract Sync Id of current Cart line
                
                if (SmartCPQUtils.isNotEmpty(columns.get('ContractSyncID'))){
                    syncId = columns.get('ContractSyncID');
                    //Existing Quote Line Item for current cart line ==> Update QLI
                    if  ( existingContractSyncIds.contains(syncId))
                    {
                        //Update existing SmartCPQ Quote Line Item
                        SmartCPQUtils.updateSmartCPQQuoteLineItem(columns,quote.Id,syncId);
                        
                        //Removing processed Quote line Item from the list (To determine which QLIs to delte at the end of process)
                        existingContractSyncIds.remove(syncId);
                    //No Quote Line Item for current cart line ==> New                        
                    }else{
                        //Adding new SmartCPQ Quote Line Item
                        SmartCPQUtils.addSmartCPQQuoteLineItem(columns,quote.Id);
                    }
                }
                
            }
            
            //Delete SmartCPQ Quote Line Items that are not reference in the Quote COntent/Cart anymore
            SmartCPQUtils.deleteSmartCPQQuoteLineItems(quote.Id,existingContractSyncIds);*/
			
            //Generates Quote Line Items
			SmartCPQUtils.generateSmartCPQQuoteLineItems(xmlLines,quote.Id,existingContractSyncIds);            
            
            
       		//Sync QLIs to OLIs for primary quotes
            if (quote.Primary_Quote__c == true)
                SmartCPQUtils.syncQLIstoOLIS(quote.Id,quote.OpportunityId__c);
        }

    }
   

}