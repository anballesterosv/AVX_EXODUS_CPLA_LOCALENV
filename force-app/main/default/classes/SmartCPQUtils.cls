public class SmartCPQUtils  { 

    public static void addAllShipTos(CameleonCPQ__Quote__c quote, String oppType){
        if (quote != null && quote.CameleonCPQ__AccountId__c !=null){
            
            if (oppType == null){
                oppType = quote.OpportunityId__r.recordtype.developerName;
            }
			
            String oppSystems;
            if(oppType!=null){
                list<Opportunity_RecordType_System_Mapping__mdt> lstOppSystems = [select Legacy_Systems__c from Opportunity_RecordType_System_Mapping__mdt where DeveloperName=:oppType];    
                if(lstOppSystems!=null && lstOppSystems.size()>0){
                    oppSystems = lstOppSystems[0].Legacy_Systems__c;
                }
            }
            Set<Id> existingQuoteShipTos = new Set<Id>();
            List<Quote_Ship_To__c> quoteShipTos = [SELECT Id,Name,Ship_To__c,PROS_Quote__c FROM Quote_Ship_To__c WHERE  PROS_Quote__c=:quote.Id];
            for (Quote_Ship_To__c quoteShipTo : quoteShipTos ){
                existingQuoteShipTos.add(quoteShipTo.Ship_To__c);
            }
                
            List<Ship_To__c> shipTos = [SELECT Id,Name,Payer__c,Legacy_System__c,Commercial_Account__c,Global_Account__c FROM Ship_To__c WHERE  (Commercial_Account__c=:quote.CameleonCPQ__AccountId__c OR Payer__r.Parentid=:quote.CameleonCPQ__AccountId__c OR Global_Account__c=: quote.CameleonCPQ__AccountId__c)  AND Status__c = 'Active'];
            for(Ship_To__c shipTo : shipTos){
                if(oppSystems!=null && oppType!='Non_CPQ'){
                    if((shipTo.Legacy_System__c!= null)&& (oppSystems.toLowerCase().indexOf(shipTo.Legacy_System__c.toLowerCase() )>=0) && !existingQuoteShipTos.contains(shipTo.Id)){
                        quoteShipTos.add(new Quote_Ship_To__c(PROS_Quote__c=quote.Id,Ship_To__c=shipTo.Id));
                    }
                }
                
            }
            if (shipTos.size()>0){
				upsertQuoteToShipTos(quoteShipTos);
            }
        }
    }
 
    public static void addAllBillTos(CameleonCPQ__Quote__c quote, String oppType){
        if (quote != null && quote.CameleonCPQ__AccountId__c !=null){
            
            if (oppType == null){
                oppType = quote.OpportunityId__r.recordtype.developerName;
            }
			
            String oppSystems;
            if(oppType!=null){
                list<Opportunity_RecordType_System_Mapping__mdt> lstOppSystems = [select Legacy_Systems__c from Opportunity_RecordType_System_Mapping__mdt where DeveloperName=:oppType];    
                if(lstOppSystems!=null && lstOppSystems.size()>0){
                    oppSystems = lstOppSystems[0].Legacy_Systems__c;
                }
            }
            Set<Id> existingQuoteBillTos = new Set<Id>();
            List<Quote_Bill_To__c> quoteBillTos = [SELECT Id,Name,Bill_To__c,PROS_Quote__c FROM Quote_Bill_To__c WHERE  PROS_Quote__c=:quote.Id];
            for (Quote_Bill_To__c quoteShipTo : quoteBillTos ){
                existingQuoteBillTos.add(quoteShipTo.Bill_To__c);
            }
                
            List<Bill_To__c> billTos = [SELECT Id,Name,Payer__c,Legacy_System__c,Commercial_Account__c,Global_Account__c FROM Bill_To__c WHERE  (Commercial_Account__c=:quote.CameleonCPQ__AccountId__c OR Payer__r.Parentid=:quote.CameleonCPQ__AccountId__c OR Global_Account__c=: quote.CameleonCPQ__AccountId__c)  AND Status__c = 'Active'];
            for(Bill_To__c billTo : billTos){
                if(oppSystems!=null && oppType!='Non_CPQ'){
                    if((billTo.Legacy_System__c!= null)&& (oppSystems.toLowerCase().indexOf(billTo.Legacy_System__c.toLowerCase() )>=0) && !existingQuoteBillTos.contains(billTo.Id)){
                        String externalId = quote.Id + '|' + billTo.Id;
                        quoteBillTos.add(new Quote_Bill_To__c(PROS_Quote__c=quote.Id,Bill_To__c=billTo.Id, External_Id__c=externalId));
                    }
                }
                
            }
            if (billTos.size()>0){
				upsertQuoteToBillTos(quoteBillTos);
            }
        }
    }

    public static void addParentQuoteShipTos(CameleonCPQ__Quote__c quote, String oppType,Id parentQuoteId){
        if (quote != null && quote.CameleonCPQ__AccountId__c !=null){
            
            if (oppType == null){
                oppType = quote.OpportunityId__r.recordtype.developerName;
            }
			
            String oppSystems;
            if(oppType!=null){
                list<Opportunity_RecordType_System_Mapping__mdt> lstOppSystems = [select Legacy_Systems__c from Opportunity_RecordType_System_Mapping__mdt where DeveloperName=:oppType];    
                if(lstOppSystems!=null && lstOppSystems.size()>0){
                    oppSystems = lstOppSystems[0].Legacy_Systems__c;
                }
            }
            Set<Id> existingQuoteShipTos = new Set<Id>();
            List<Quote_Ship_To__c> quoteShipTos = [SELECT Id,Name,Ship_To__c,PROS_Quote__c FROM Quote_Ship_To__c WHERE  PROS_Quote__c=:parentQuoteId];
            for (Quote_Ship_To__c quoteShipTo : quoteShipTos ){
                existingQuoteShipTos.add(quoteShipTo.Ship_To__c);
            }
            
            List<Quote_Ship_To__c> quoteShipTosToAdd = new  List<Quote_Ship_To__c>();
            List<Ship_To__c> shipTos = [SELECT Id,Name,Payer__c,Legacy_System__c,Commercial_Account__c,Global_Account__c FROM Ship_To__c WHERE  (Commercial_Account__c=:quote.CameleonCPQ__AccountId__c OR Payer__r.Parentid=:quote.CameleonCPQ__AccountId__c OR Global_Account__c=: quote.CameleonCPQ__AccountId__c) AND Status__c = 'Active' AND ID IN: existingQuoteShipTos];
            for(Ship_To__c shipTo : shipTos){
                if(oppSystems!=null && oppType!='Non_CPQ'){
                    if((shipTo.Legacy_System__c!= null)&& (oppSystems.toLowerCase().indexOf(shipTo.Legacy_System__c.toLowerCase() )>=0)){
                        quoteShipTosToAdd.add(new Quote_Ship_To__c(PROS_Quote__c=quote.Id,Ship_To__c=shipTo.Id));
                    }
                }	
                
            }
            if (shipTos.size()>0){
				upsertQuoteToShipTos(quoteShipTosToAdd);
            }
        }
    }
    
    public static void addParentQuoteBillTos(CameleonCPQ__Quote__c quote, String oppType,Id parentQuoteId){
        if (quote != null && quote.CameleonCPQ__AccountId__c !=null){
            
            if (oppType == null){
                oppType = quote.OpportunityId__r.recordtype.developerName;
            }
			
            String oppSystems;
            if(oppType!=null){
                list<Opportunity_RecordType_System_Mapping__mdt> lstOppSystems = [select Legacy_Systems__c from Opportunity_RecordType_System_Mapping__mdt where DeveloperName=:oppType];    
                if(lstOppSystems!=null && lstOppSystems.size()>0){
                    oppSystems = lstOppSystems[0].Legacy_Systems__c;
                }
            }
            Set<Id> existingQuoteBillTos = new Set<Id>();
            List<Quote_Bill_To__c> quoteBillTos = [SELECT Id,Name,Bill_To__c,PROS_Quote__c FROM Quote_Bill_To__c WHERE  PROS_Quote__c=:parentQuoteId];
            for (Quote_Bill_To__c quoteBillTo : quoteBillTos ){
                existingQuoteBillTos.add(quoteBillTo.Bill_To__c);
            }
            
            List<Quote_Bill_To__c> quoteBillTosToAdd = new  List<Quote_Bill_To__c>();
            List<Bill_To__c> billTos = [SELECT Id,Name,Payer__c,Legacy_System__c,Commercial_Account__c,Global_Account__c FROM Bill_To__c WHERE  (Commercial_Account__c=:quote.CameleonCPQ__AccountId__c OR Payer__r.Parentid=:quote.CameleonCPQ__AccountId__c OR Global_Account__c=: quote.CameleonCPQ__AccountId__c) AND Status__c = 'Active' AND ID IN: existingQuoteBillTos];
            for(Bill_To__c billTo : billTos){
                if(oppSystems!=null && oppType!='Non_CPQ'){
                    if((billTo.Legacy_System__c!= null)&& (oppSystems.toLowerCase().indexOf(billTo.Legacy_System__c.toLowerCase() )>=0)){
                        quoteBillTosToAdd.add(new Quote_Bill_To__c(PROS_Quote__c=quote.Id,Bill_To__c=billTo.Id));
                    }
                }	
                
            }
            if (billTos.size()>0){
				upsertQuoteToBillTos(quoteBillTosToAdd);
            }
        }
    }
    
    public static void removeAllShipTos(CameleonCPQ__Quote__c quote){
        if (quote !=null){
            List<Quote_Ship_To__c> quoteShipTos = [SELECT Id,Name FROM Quote_Ship_To__c WHERE PROS_Quote__c =: quote.Id];

            if (quoteShipTos.size()>0){
				deleteQuoteToShipTos(quoteShipTos);
            }
        }
    }

    public static void removeAllBillTos(CameleonCPQ__Quote__c quote){
        if (quote !=null){
            List<Quote_Bill_To__c> quoteBillTos = [SELECT Id,Name FROM Quote_Bill_To__c WHERE PROS_Quote__c =: quote.Id];

            if (quoteBillTos.size()>0){
				deleteQuoteToBillTos(quoteBillTos);
            }
        }
    }  
    
    private static void upsertQuoteToShipTos(List<Quote_Ship_To__c> quoteShipTos){
        savePoint sp= database.setSavePoint();
        try{
            upsert quoteShipTos;
        }catch(DmlException ex){
            ApexPages.addMessages(ex); 
            database.Rollback(sp);
        } 
    }
    
    private static void upsertQuoteToBillTos(List<Quote_Bill_To__c> quoteBillTos){
        savePoint sp= database.setSavePoint();
        try{
            upsert quoteBillTos;
        }catch(DmlException ex){
            ApexPages.addMessages(ex); 
            database.Rollback(sp);
        } 
    }
    
    private static void deleteQuoteToShipTos(List<Quote_Ship_To__c> quoteShipTos){
        savePoint sp= database.setSavePoint();
        try{
            delete quoteShipTos;
        }catch(DmlException ex){
            ApexPages.addMessages(ex); 
            database.Rollback(sp);
        } 
    }

    private static void deleteQuoteToBillTos(List<Quote_Bill_To__c> quoteBillTos){
        savePoint sp= database.setSavePoint();
        try{
            delete quoteBillTos;
        }catch(DmlException ex){
            ApexPages.addMessages(ex); 
            database.Rollback(sp);
        } 
    }
    
    public static void syncQLIstoOLIS(Id quoteId,Id oppId){
        //Remove all previous Opportunity Line Items/Products associated with the oportunity
        deletePreviousOLIS(oppId);
        
        //Get Opportunity Object
        Opportunity opp = [SELECT Id,Name,Pricebook2Id,RecordType.developerName FROM Opportunity WHERE Id=:oppId];
        
        //Get Opportunity Record Type
        String oppType = 'NA';
        if (opp != null){
        	oppType = opp.recordtype.developerName;
        }
        List<OpportunityLineItem> newOlis = new List<OpportunityLineItem>();
        
        List<CPQQuoteLineItem__c> qlis = [SELECT Id,Name,Legacy_System__c,Product_Code__c,Actual_Volume__c,Floor_Price__c,Target_Price__c,Expert_Price__c,NSP_Floor_Price__c,NSP_Target_Price__c,NSP_Expert_Price__c,UOM__c,Net_Sales_Price__c,Result__c,Overage__c,Quantity__c,Beef_Net_Sales_Price__c FROM CPQQuoteLineItem__c WHERE PROS_Quote__c =: quoteId];
        
        //Handle PriceBook Entriees for all identified products
        Id pricebookId = SmartCPQUtils.getPricebookId(opp);
      	Map<String, Product2> productMap = SmartCPQUtils.getProductIdsFromQLIs(qlis); 
        //Get Product Id list
        Set<Id> productIds = new Set<Id>();
        for (String key : productMap.keySet()){
            productIds.add(productMap.get(key).Id);
        }
        List<PricebookEntry> pricebookEntries = getPricebookEntries(productIds, pricebookId);           
        Map<Id, Id> pricebookEntriesIdsByProductIds = getPricebookEntriesByProductIds(pricebookEntries, productIds, pricebookId);
        
        for(CPQQuoteLineItem__c qli : qlis){
            
            //Check if Product 
            if ((qli.Legacy_System__c != null) && (qli.Product_Code__c != null) ){
                String productCode =  qli.Product_Code__c;
                String legacySystem = qli.Legacy_System__c;
                if (productMap.get(productCode + '|' + legacySystem.toUpperCase()) != null){
                    Product2 currentProd = productMap.get(productCode + '|' + legacySystem.toUpperCase());
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli.OpportunityId = oppId;
                    oli.Product2Id = currentProd.Id;
                    oli.PricebookEntryId = pricebookEntriesIdsByProductIds.get(currentProd.Id);
                    oli.Quantity = qli.Actual_Volume__c;
                    /*oli.UnitOfMeasure__c = qli.UOM__c;*/
                    if (qli.UOM__c == 'lb'){
                        oli.UnitOfMeasure__c = 'Pound (lb)';
                    }else{
                        oli.UnitOfMeasure__c = qli.UOM__c;
                    }
                    /*if (qli.Result__c != 'Won'){
                        oli.Result__c='Lost';
                    }else{
                        oli.Result__c=qli.Result__c;
                    }*/
                    if (qli.Result__c != 'NA'){
                        oli.Result__c=qli.Result__c;
                    }                  
                    
                    if (oppType.toLowerCase().contains('beef')){
                        oli.PricingGuildanceFloorPrice__c=qli.Floor_Price__c;
                        oli.PricingGuidanceTargetPrice__c=qli.Target_Price__c;
                        oli.PricingGuidanceStartPrice__c=qli.Expert_Price__c;   
                        oli.Overage__c=qli.Overage__c;
                        oli.UnitPrice=qli.Beef_Net_Sales_Price__c;
                        if (qli.UOM__c == 'case'){
                        oli.Number_of_Cases__c = qli.Quantity__c;
                    	}else{
                        oli.Number_of_Cases__c = null;
                    	}
                    }else{                    
                        oli.PricingGuildanceFloorPrice__c=qli.NSP_Floor_Price__c;
                        oli.PricingGuidanceTargetPrice__c=qli.NSP_Target_Price__c;
                        oli.PricingGuidanceStartPrice__c=qli.NSP_Expert_Price__c;
                        oli.UnitPrice=qli.Net_Sales_Price__c;
                    }    
                    //oli.UnitOfMeasure__c = 'Pound (lb)';
                     
                    newOlis.add(oli); 
                }
            }
        }
		
        if(!Test.isRunningTest()) insert newOlis;
    }

    public static void deletePreviousOLIS(Id oppId){
        delete [SELECT id FROM OpportunityLineItem WHERE OpportunityId =: oppId];
    }
    
    /**
     * Set & Update Quote Expiration Date field, can specific a default Deal Size to override Quote one when Setting up Quote Expiration the first time
	*/
    public static void setQuoteExpirationDate(CameleonCPQ__Quote__c quote, String defaultResponse){
		Integer minimumDays = 14 ;
        Integer daysBetween = minimumDays;
        if (quote.Pricing_Type__c != 'PPP' && quote.Pricing_Type__c != 'NOF'){            
            
            //Get DQuote Creation Date
            Date quoteCreationDate = Date.today();
            if (quote.CreatedDate != null){
                Datetime quoteCreationDatetime = quote.CreatedDate;
                quoteCreationDate = quoteCreationDatetime.date();
            }
            
            //Determine Current Deal Size/Response Direct/Light/Full (Small/Medium/Large)
            String currentResponse = 'Direct';
            if ((defaultResponse !=null) && (defaultResponse.equals('Direct') || defaultResponse.equals('Light') || defaultResponse.equals('Full') )){
                currentResponse = defaultResponse;            
            }else if(quote.DealSize__c !=null){
                   currentResponse = quote.DealSize__c;           
            }
            currentResponse = currentResponse.toLowerCase();
            
            //Determine the days between Quote Creation and Expiration Date based on Opportunity Type and Dealsize/Response
            if (quote.Opportunity_Type__c != null){
                String oppType = quote.Opportunity_Type__c;
                    if (oppType.toLowerCase().contains('beef')){
                        if (currentResponse.equals('full')){
                            daysBetween = 60; 
                        }else if(currentResponse.equals('light')){
                            daysBetween = 30;
                        }else{
                            daysBetween = minimumDays;
                        } 
                    }else{
                        if (currentResponse.equals('full')){
                            daysBetween = 60; 
                        }else if(currentResponse.equals('light')){
                            daysBetween = 60;
                        }else{
                            daysBetween = 60;
                        }                     
                    }
            }
            
            //CHeck & Update Expiration Date
            Date newExpirationDate = quoteCreationDate.addDays(daysBetween);
            if (quote.CameleonCPQ__Expires__c == null){
                quote.CameleonCPQ__Expires__c = newExpirationDate;
            }else{
                Integer currentDaysBetween = quoteCreationDate.daysBetween(quote.CameleonCPQ__Expires__c);           
                if (currentDaysBetween != daysBetween && quote.CameleonCPQ__Expires__c > newExpirationDate){
                    quote.CameleonCPQ__Expires__c = newExpirationDate;
                }
            }
        }else{
            quote.CameleonCPQ__Expires__c = Date.today().addDays(1);
        }
    }

    /**
     * 
     */
     public static boolean checkValidExpirationDate(CameleonCPQ__Quote__c quote, boolean beforeQuoteUpdateFlag){
		Integer minimumDays = 14 ;
        Integer daysBetween = minimumDays;
        Boolean result = true;
         if (quote.CameleonCPQ__Expires__c == null){
             result = false;
             quote.addError('Expiration Date cannot be null');
         } else if(quote.CameleonCPQ__Expires__c < Date.today()){
             result = false;
             quote.addError('Expiration Date cannot before today');
         }else if ((quote.Pricing_Type__c == 'PPP' || quote.Pricing_Type__c != 'NOF') && quote.CameleonCPQ__Expires__c > Date.today().addDays(1) && beforeQuoteUpdateFlag == true ){
             result = false;  
             quote.addError('Expiration Date cannot be after Default Expiration Date.');         
         }else{
             Date computedDate = null;
             
            //Get Quote Creation Date
            Date quoteCreationDate = Date.today();
            if (quote.CreatedDate != null){
                Datetime quoteCreationDatetime = quote.CreatedDate;
                quoteCreationDate = quoteCreationDatetime.date();
            }
            
            //Determine Current Deal Size/Response Direct/Light/Full (Small/Medium/Large)
            String currentResponse = 'Direct';
            if (quote.DealSize__c !=null){
                   currentResponse = quote.DealSize__c;           
            }
            currentResponse = currentResponse.toLowerCase();    
             
            //Determine the days between Quote Creation and Expiration Date based on Opportunity Type and Dealsize/Response
            if (quote.Opportunity_Type__c != null){
                String oppType = quote.Opportunity_Type__c;
                    if (oppType.toLowerCase().contains('beef')){
                        if (currentResponse.equals('full')){
                            daysBetween = 60; 
                        }else if(currentResponse.equals('light')){
                            daysBetween = 30;
                        }else{
                            daysBetween = minimumDays;
                        } 
                    }else{
                        if (currentResponse.equals('full')){
                            daysBetween = 60; 
                        }else if(currentResponse.equals('light')){
                            daysBetween = 60;
                        }else{
                            daysBetween = 60;
                        }                     
                    }
            }
             
             if (quote.CameleonCPQ__Expires__c > quoteCreationDate.addDays(daysBetween)){
               result = false;  
                quote.addError('Expiration Date cannot be after Default Expiration Date.');  
             }        
             
         }
			return result;
    }
    
   /**
     * Retrieve the PROS SmartCPQ associated with the current quote content (Cart Spreadsheet)
    */ 
    public static CameleonCPQ__Quote__c getQuote(CameleonCPQ__QuoteContent__c quoteContent) {
        return [SELECT Id, 
                	Name,
                	Primary_Quote__c,
                	OpportunityId__c
                FROM CameleonCPQ__Quote__c
                WHERE Id =: quoteContent.CameleonCPQ__QuoteId__c][0];
    }
    
    /*
     * Creates a CameleonCPQ.CPQParser.Quote object with actual quote content retrieved from XML. 
     */
    public static CameleonCPQ.CPQParser.Quote getParsedQuote(Id quoteContentId)
    {
        Attachment attachment = retrieveAttachment(quoteContentId);
        Blob quoteContentXML = attachment.Body; // quoteContentXML actually contains all the cart data
        CameleonCPQ.CPQParser quoteParser = new CameleonCPQ.CPQParser(quoteContentXML);
        CameleonCPQ.CPQParser.Quote parsedQuote = quoteParser.getQuote();
        
        return parsedQuote;
    }
    
    
    public static Attachment retrieveAttachment(Id quoteContentId)
    {
        return [SELECT Id, Name, Body FROM Attachment WHERE parentId =: quoteContentId AND Name like '%_content'];
    }
    /**
     * Get the list of contract Sync IDs of existing SmartCPQ Quote Line Items of the SMartCPQ Quote in parameter
     */
    public static Set<String> getExistingQLISyncIds(CameleonCPQ__Quote__c quote)
    {
        Set<String> contractSyncIds = new Set<String>();
        
        List<CPQQuoteLineItem__c> qlis = [SELECT Id,ContractSyncID__c,PROS_Quote__c FROM CPQQuoteLineItem__c WHERE PROS_Quote__c =: quote.Id ];
        for (CPQQuoteLineItem__c qli : qlis){
            contractSyncIds.add(qli.ContractSyncID__c);
        }
        
        return contractSyncIds;
    }
    
    /**
     * Creates & Adds a SmartCPQ Quote Line Item with current column information & current Quote Id for lookup
     */
    public static void addSmartCPQQuoteLineItem(Map<String, String> columns, Id quoteId){
		CPQQuoteLineItem__c qli = SmartCPQUtils.createSmartCPQQuoteLineItem(columns,quoteId);
                
    	insert qli;
    }
    
    /**
     * Updates a SmartCPQ Quote Line Item with current column information & current Quote Id & Contract Sync Id of the Quote Line Item
     */
    public static void updateSmartCPQQuoteLineItem(Map<String, String> columns, Id quoteId, String contractSyncId){
        CPQQuoteLineItem__c qli = [SELECT Id,Name FROM CPQQuoteLineItem__c WHERE PROS_Quote__c =: quoteId AND ContractSyncID__c =: contractSyncId];
        if (qli != null)
        {
			updateSmartCPQQuoteLineItemInfo(columns,qli);	
            
            update qli;  
        }
           	
    }
    
    /**
     * Updates a SmartCPQ Quote Line Item with current column information & current Quote Id & Contract Sync Id of the Quote Line Item
     */
    public static void updateSmartCPQQuoteLineItemInfo(Map<String, String> columns, CPQQuoteLineItem__c qli){
        
        if (qli != null)
        {
            //Currency values
            if (isNotEmpty(columns.get('ProductTotalLB'))){qli.Initial_Volume__c = Decimal.valueof(columns.get('ProductTotalLB'));} else{qli.Initial_Volume__c = 0;}
            if (isNotEmpty(columns.get('ActualTotalLB'))){qli.Actual_Volume__c = Decimal.valueof(columns.get('ActualTotalLB'));} else{qli.Actual_Volume__c = 0;}
            
            if (isNotEmpty(columns.get('NSPFloorPrice'))){qli.NSP_Floor_Price__c = Decimal.valueof(columns.get('NSPFloorPrice'));} else{qli.NSP_Floor_Price__c = 0;} 
            if (isNotEmpty(columns.get('NSPTargetPrice'))){qli.NSP_Target_Price__c = Decimal.valueof(columns.get('NSPTargetPrice'));} else{qli.NSP_Target_Price__c = 0;}
            if (isNotEmpty(columns.get('NSPExpertPrice'))){qli.NSP_Expert_Price__c = Decimal.valueof(columns.get('NSPExpertPrice'));} else{qli.NSP_Expert_Price__c = 0;} 
            if (isNotEmpty(columns.get('RealNetSalesPrice'))){qli.Real_Net_Sales_Price__c = Decimal.valueof(columns.get('RealNetSalesPrice'));} else{qli.Real_Net_Sales_Price__c = 0;} 
            if (isNotEmpty(columns.get('NetSalesPrice'))){qli.Net_Sales_Price__c = Decimal.valueof(columns.get('NetSalesPrice'));} else{qli.Net_Sales_Price__c = 0;} 
            if (isNotEmpty(columns.get('OnSalePrice'))){qli.On_Sale_Price__c = Decimal.valueof(columns.get('OnSalePrice'));} else{qli.On_Sale_Price__c = 0;} 
            if (isNotEmpty(columns.get('FloorPrice'))){qli.Floor_Price__c = Decimal.valueof(columns.get('FloorPrice'));} else{qli.Floor_Price__c = 0;} 
            if (isNotEmpty(columns.get('TargetPrice'))){qli.Target_Price__c = Decimal.valueof(columns.get('TargetPrice'));} else{qli.Target_Price__c = 0;} 
            if (isNotEmpty(columns.get('ExpertPrice'))){qli.Expert_Price__c = Decimal.valueof(columns.get('ExpertPrice'));} else{qli.Expert_Price__c = 0;} 
            if (isNotEmpty(columns.get('BlendedPrice'))){qli.Blended_Price__c = Decimal.valueof(columns.get('BlendedPrice'));} else{qli.Blended_Price__c = 0;} 
            if (isNotEmpty(columns.get('SalesMultiplier'))){qli.Sales_Multiplier__c = Decimal.valueof(columns.get('SalesMultiplier'));} else{qli.Sales_Multiplier__c = 1;} 
            if (isNotEmpty(columns.get('BilledFreight'))){qli.Billed_Freight__c = Decimal.valueof(columns.get('BilledFreight'));} else{qli.Billed_Freight__c = 0;} 
            if (isNotEmpty(columns.get('QuotedFOBLB'))){qli.Overage_Lb__c = Decimal.valueof(columns.get('QuotedFOBLB'));} else{qli.Overage_Lb__c = 0;} 
            if (isNotEmpty(columns.get('ProgramLB'))){qli.Program_Lb__c = Decimal.valueof(columns.get('ProgramLB'));} else{qli.Program_Lb__c = 0;} 
            if (isNotEmpty(columns.get('DiscountAccrual'))){qli.Discount_Accrual__c = Decimal.valueof(columns.get('DiscountAccrual'));} else{qli.Discount_Accrual__c = 0;} 
            if (isNotEmpty(columns.get('CorporateAccrual'))){qli.Corporate_Discount__c = Decimal.valueof(columns.get('CorporateAccrual'));} else{qli.Corporate_Discount__c = 0;} 
            if (isNotEmpty(columns.get('DemoRateAccrual'))){qli.Demo_Rate_Accrual__c = Decimal.valueof(columns.get('DemoRateAccrual'));} else{qli.Demo_Rate_Accrual__c = 0;} 
            if (isNotEmpty(columns.get('VolumeRebateAccrual'))){qli.Volume_Rebate_Accrual__c = Decimal.valueof(columns.get('VolumeRebateAccrual'));} else{qli.Volume_Rebate_Accrual__c = 0;} 
            if (isNotEmpty(columns.get('AccrualLB'))){qli.Accrual_Lb__c = Decimal.valueof(columns.get('AccrualLB'));} else{qli.Accrual_Lb__c = 0;} 
            if (isNotEmpty(columns.get('BrokerLB'))){qli.Broker_Lb__c = Decimal.valueof(columns.get('BrokerLB'));} else{qli.Broker_Lb__c = 0;} 
            if (isNotEmpty(columns.get('ExpenseLB'))){qli.Expense_Lb__c = Decimal.valueof(columns.get('ExpenseLB'));} else{qli.Expense_Lb__c = 0;} 
            if (isNotEmpty(columns.get('ProductCostLB'))){qli.Product_Cost_Lb__c = Decimal.valueof(columns.get('ProductCostLB'));} else{qli.Product_Cost_Lb__c = 0;} 
            if (isNotEmpty(columns.get('MarginLB'))){qli.Margin_Lb__c = Decimal.valueof(columns.get('MarginLB'));} else{qli.Margin_Lb__c = 0;}
            if (isNotEmpty(columns.get('GrowthIncentiveAccrual'))){qli.Growth_Incentive_Accrual__c = Decimal.valueof(columns.get('GrowthIncentiveAccrual'));} else{qli.Growth_Incentive_Accrual__c = 0;}
			if (isNotEmpty(columns.get('DeliveredPrice'))){qli.DeliveredPrice__c = Decimal.valueof(columns.get('DeliveredPrice'));} else{qli.DeliveredPrice__c = 0;}
            if (isNotEmpty(columns.get('CustomerBid'))){qli.CustomerBid__c = Decimal.valueof(columns.get('CustomerBid'));} else{qli.CustomerBid__c = 0;}
            if (isNotEmpty(columns.get('CurrentPrice'))){qli.CurrentPrice__c = Decimal.valueof(columns.get('CurrentPrice'));} else{qli.CurrentPrice__c = 0;}
            if (isNotEmpty(columns.get('FirstOffier'))){qli.FirstOffier__c = Decimal.valueof(columns.get('FirstOffier'));} else{qli.FirstOffier__c = 0;}
            if (isNotEmpty(columns.get('FirstBid'))){qli.FirstBid__c = Decimal.valueof(columns.get('FirstBid'));} else{qli.FirstBid__c = 0;}
            if (isNotEmpty(columns.get('SecondOffer'))){qli.SecondOffer__c = Decimal.valueof(columns.get('SecondOffer'));} else{qli.SecondOffer__c = 0;}
            if (isNotEmpty(columns.get('SecondBid'))){qli.SecondBid__c = Decimal.valueof(columns.get('SecondBid'));} else{qli.SecondBid__c = 0;}
            if (isNotEmpty(columns.get('Plant')))
            {
            	if (isNotEmpty(columns.get('QuotedFOB')))
                {
                    qli.Beef_Net_Sales_Price__c = Decimal.valueof(columns.get('QuotedFOB'));
                }else
                {
                    qli.Beef_Net_Sales_Price__c = 0;
                }
        	}else
            {
                if (isNotEmpty(columns.get('QuotedFOB')))
                {
                    qli.Overage__c = Decimal.valueof(columns.get('QuotedFOB'));
                    qli.Beef_Net_Sales_Price__c = 0;
                }else
                {
                     qli.Overage__c = 0;                                  
                }
            }          
             //Number values
            if (isNotEmpty(columns.get('DealScore'))){qli.Deal_Score__c = Decimal.valueof(columns.get('DealScore'));} else{qli.Deal_Score__c = 0;} 
            if (isNotEmpty(columns.get('Quantity'))){qli.Quantity__c = Decimal.valueof(columns.get('Quantity'));} else{qli.Quantity__c = 0;} 
            if (isNotEmpty(columns.get('Weeks'))){qli.Weeks__c = Decimal.valueof(columns.get('Weeks'));} else{qli.Weeks__c = 0;} 
            
            //Percent Values
            if (isNotEmpty(columns.get('PctTimeOnSale'))){qli.Percent_Time_On_Sale__c = Decimal.valueof(columns.get('PctTimeOnSale'));} else{qli.Percent_Time_On_Sale__c = 0;} 
                
            //CheckBox Values    
            if (isNotEmpty(columns.get('SpecialSKU'))){qli.Special_SKU__c = Boolean.valueof(columns.get('SpecialSKU'));} else{qli.Special_SKU__c = false;}
            if (isNotEmpty(columns.get('AccrualsRebates'))){qli.AccrualsRebates__c = Boolean.valueof(columns.get('AccrualsRebates'));} else{qli.AccrualsRebates__c = false;}
            if (isNotEmpty(columns.get('SubProduct'))){qli.SubProduct__c = Boolean.valueof(columns.get('SubProduct'));} else{qli.SubProduct__c = false;}
            if (isNotEmpty(columns.get('GuidanceOverride'))){ 
                if (columns.get('GuidanceOverride')=='1') { 
                    qli.Guidance_Overridden__c	 = true; 
                } else{ qli.Guidance_Overridden__c	 = false;}
            } else{qli.Guidance_Overridden__c	 = false;}
            
            //Other Text Values            
            if (isNotEmpty(columns.get('Description'))){qli.Name = columns.get('Description');} else{qli.Name = 'N/A';}
            if (isNotEmpty(columns.get('IMPSUSDAReport'))){qli.USDA_IMPS__c = columns.get('IMPSUSDAReport');} else{qli.USDA_IMPS__c = '';}
            if (isNotEmpty(columns.get('ProductCode'))){qli.Product_Code__c = columns.get('ProductCode');} else{qli.Product_Code__c = '';}
            if (isNotEmpty(columns.get('FormulaType'))){qli.Formula_Type__c = columns.get('FormulaType');} else{qli.Formula_Type__c = '';}
            if (isNotEmpty(columns.get('BaseCode'))){qli.Base_Code__c = columns.get('BaseCode');} else{qli.Base_Code__c = '';}
            if (isNotEmpty(columns.get('UOM'))){qli.UOM__c = columns.get('UOM');} else{qli.UOM__c = '';}
            if (isNotEmpty(columns.get('ShipTo'))){qli.Ship_To__c = columns.get('ShipTo');} else{qli.Ship_To__c = '';}
            if (isNotEmpty(columns.get('ProgramTF'))){qli.Program_TF__c = columns.get('ProgramTF');} else{qli.Program_TF__c = '';}
            if (isNotEmpty(columns.get('LegacySystem'))){qli.Legacy_System__c = columns.get('LegacySystem');} else{qli.Legacy_System__c = '';}
            if (isNotEmpty(columns.get('Result'))){qli.Result__c = columns.get('Result');} else{qli.Result__c = 'NA';}
            if (isNotEmpty(columns.get('Plant'))){qli.Plant__c = columns.get('Plant');} else{qli.Plant__c = '';}
            if (isNotEmpty(columns.get('ShipFrequency'))){qli.ShipFrequency__c = columns.get('ShipFrequency');} else{qli.ShipFrequency__c = '';}
            
            //Dates
            if (isNotEmpty(columns.get('ShipStartDate'))){qli.ShipStartDate__c = Date.newInstance(Integer.valueOf(columns.get('ShipStartDate').substring(0,4)), Integer.valueOf(columns.get('ShipStartDate').substring(4,6)), Integer.valueOf(columns.get('ShipStartDate').substring(6,8)));} 
            if (isNotEmpty(columns.get('ShipEndDate'))){qli.ShipEndDate__c = Date.newInstance(Integer.valueOf(columns.get('ShipEndDate').substring(0,4)), Integer.valueOf(columns.get('ShipEndDate').substring(4,6)), Integer.valueOf(columns.get('ShipEndDate').substring(6,8)));}
        }
    }
    
    
    public static Boolean isNotEmpty(String param)
    {
      if (param != null && param != '')
      {
        return true;
      }
      return false;
    }
    
    /**
     * Delete SmartCPQ Quote Line Items associate with the current SmartCPQ Quote & current Set of Contract Ids
     */
    public static void deleteSmartCPQQuoteLineItems(Id quoteId,Set<String> contractSyncIdsToDel)
    {
        delete [SELECT id FROM CPQQuoteLineItem__c WHERE PROS_Quote__c =: quoteId AND ContractSyncID__c IN: contractSyncIdsToDel];
    }


    /*
     * Returns Pricebook Id associated to Opportunity. If NULL, returns Id of Standard Pricebook.
     */
    private static Id getPricebookId(Opportunity opportunity)
    {
        if(opportunity.Pricebook2Id == null)
        {           	
            Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
            opportunity.Pricebook2Id = standardPricebook.Id;
        }
        return opportunity.Pricebook2Id;
    }

    /*
     * @param productIds: set containg Ids of all Products present in the Quote
     * @param pricebookId: Pricebook Id
     * @return list with Pricebook Entries associated to Products in productIds
     */
    private static List<PricebookEntry> getPricebookEntries(Set<Id> productIds, Id pricebookId)
    {
        
        return [SELECT Id, 
                       Product2.ProductCode 
                 FROM PricebookEntry
                 WHERE Pricebook2.Id =: pricebookId 
                 // AND CurrencyIsoCode =: currencyCode 
                 	AND Product2.Id IN: productIds]; 
    }
    
    /*
     * @param pricebookEntries: list with Pricebook Entries associated to Products in productIds
     * @param productIds: set containg Ids of all Products present in the Quote
     * @param pricebookId: Pricebook Id
     * @return Map<ProductId, PricebookEntryId>
     *
     * Creates a Map entry <PricebookEntryId - ProductId> for each Pricebook Entry in pricebookEntries.
     * Creates a trivial Pricebook Entry Id for every Product missing a Pricebook Entry. 
     */
    private static Map<Id, Id> getPricebookEntriesByProductIds(List<PricebookEntry> pricebookEntries, Set<Id> productIds, Id pricebookId)
    {
        Map<Id, Id> pricebookEntriesByProductIds = new Map<Id, Id>();
        for (PricebookEntry pricebookEntry : pricebookEntries) 
        {
            pricebookEntriesByProductIds.put(pricebookEntry.Product2.Id, pricebookEntry.Id);
            pricebookEntry.isActive = true;
        }
        if(!Test.isRunningTest())update pricebookEntries;
        checkAndHandleMissingPricebookEntries(pricebookEntriesByProductIds, productIds, pricebookId);
        return pricebookEntriesByProductIds;
    }

    
    private static void checkAndHandleMissingPricebookEntries(Map<Id, Id> pricebookEntriesByProductIds, Set<Id> productIds, Id pricebookId)
    {
        Map<Id, PricebookEntry> newPricebookEntriesByProductIds = new Map<Id, PricebookEntry>();
        
        for (Id productId : productIds)
        {
            if (!pricebookEntriesByProductIds.keySet().contains(productId)) // Checking if we don't already have a PricebookEntry associated to that Product Id.
            {
                PricebookEntry newPricebookEntry = createTrivialPricebookEntry(productId, pricebookId);
                newPricebookEntriesByProductIds.put(productId, newPricebookEntry);

            }
        }

        if(!Test.isRunningTest())insert newPricebookEntriesByProductIds.values();
        
        // Updating pricebookEntriesByProductIds with the new PricebookEntries
        for (Id productId : newPricebookEntriesByProductIds.keySet())
        {
            pricebookEntriesByProductIds.put(productId, newPricebookEntriesByProductIds.get(productId).Id);
        }
    }
    
    
    private static PricebookEntry createTrivialPricebookEntry(Id productId, Id pricebookId)
    {
        PricebookEntry pricebookEntry = new PriceBookEntry(Pricebook2Id = pricebookId, 
                                                           Product2Id = productId, 
                                                           UseStandardPrice = false, 
                                                           IsActive = true, 
                                                           UnitPrice = 0);
        return pricebookEntry;
    }
    
    /*private static Map<String,Product2>  getProductIdsFromQLIs(List<CPQQuoteLineItem__c> qlis){
        Map<String,Product2> productMap = new Map<String,Product2>();
        for(CPQQuoteLineItem__c qli : qlis){
            if (qli.Product_Code__c !=null && qli.Legacy_System__c !=null){
                String productCode =  qli.Product_Code__c;
                String legacySystem = qli.Legacy_System__c;
                List<Product2> products = [SELECT Id,Name,ProductCode,IPFS_Code__c FROM Product2 WHERE Product_Id__c LIKE:  productCode + '|%' AND Product_Id__c LIKE:  '%|' + legacySystem ];
                //Check if Product exists
                if (products.size() >0 ){
                    productMap.put(productCode + '|' + legacySystem.toUpperCase() ,products[0]);
                }
            }
        }  
        return productMap;
    }*/
    
    public static void generateSmartCPQQuoteLineItems(List<CameleonCPQ.CPQParser.QuoteLine> xmlLines, Id quoteId, Set<String> existingContractSyncIds){
	
		String syncId = '';
		List<CPQQuoteLineItem__c> existingQlis = [SELECT Id,Name,ContractSyncID__c FROM CPQQuoteLineItem__c WHERE PROS_Quote__c =: quoteId AND ContractSyncID__c IN: existingContractSyncIds];
		
        Map<String,CPQQuoteLineItem__c> existingQlisMap = new Map<String,CPQQuoteLineItem__c>();
		for (CPQQuoteLineItem__c qli : existingQlis){
			existingQlisMap.put(qli.ContractSyncID__c,qli);
		}

		List<CPQQuoteLineItem__c> qlisToAdd = new List<CPQQuoteLineItem__c>();
		
        Set<String>  qlisToRemove = new Set<String>();
		qlisToRemove.addAll(existingContractSyncIds);
	
		for (CameleonCPQ.CPQParser.QuoteLine xmlLine : xmlLines){
			Map<String, String> columns = xmlLine.getColumns();
			if (SmartCPQUtils.isNotEmpty(columns.get('ContractSyncID'))){
				syncId = columns.get('ContractSyncID');
			
				/*Existing QLI to Udpate*/
				if  (existingQlisMap.get(syncId) != null)
				{
					CPQQuoteLineItem__c qliToUpdate = existingQlisMap.get(syncId);
				
					SmartCPQUtils.updateSmartCPQQuoteLineItemInfo(columns,qliToUpdate);	
				
					//Current QLIs still exists and not to be removed
					qlisToRemove.remove(syncId);
				}else{
					/*QLI to add*/
					CPQQuoteLineItem__c qliToAdd = SmartCPQUtils.createSmartCPQQuoteLineItem(columns,quoteId);
				
					qlisToAdd.add(qliToAdd);				
				}
			}
		}
	
		//Update existing QLIs
		update existingQlis;
		//Insert new QLIs
		insert qlisToAdd;
		//Remove old QLIS
		//Delete SmartCPQ Quote Line Items that are not reference in the Quote COntent/Cart anymore
		SmartCPQUtils.deleteSmartCPQQuoteLineItems(quoteId,qlisToRemove);
	
	
	
	}
    
	private static CPQQuoteLineItem__c createSmartCPQQuoteLineItem(Map<String, String> columns, Id quoteId){
        CPQQuoteLineItem__c qli = new CPQQuoteLineItem__c();
        
        
        //Initial Values for insertion
        qli.Name = columns.get('Description');
        qli.ContractSyncID__c = columns.get('ContractSyncID');
        qli.PROS_Quote__c = quoteId;
        if (isNotEmpty(columns.get('ProductTotalLB'))){qli.Actual_Volume__c = Decimal.valueof(columns.get('ProductTotalLB'));} else{qli.Actual_Volume__c = 0;}
           
        updateSmartCPQQuoteLineItemInfo(columns,qli);
        
        return qli;
    }
    
    private static Map<String,Product2>  getProductIdsFromQLIs(List<CPQQuoteLineItem__c> qlis){
        Map<String,Product2> productMap = new Map<String,Product2>();
        Set<String> productsIds = new Set<String>();
        for(CPQQuoteLineItem__c qli : qlis){
            String productCode =  qli.Product_Code__c;
            String legacySystem = qli.Legacy_System__c;
    
            if (qli.Product_Code__c !=null && qli.Legacy_System__c !=null){
                productsIds.add(productCode + '|' + legacySystem.toUpperCase());
            }		
        }
        List<Product2> products = [SELECT Id,Name,ProductCode,IPFS_Code__c,Product_Id__c FROM Product2 WHERE Product_Id__c IN: productsIds];
        for (Product2 product : products){
            productMap.put(product.Product_Id__c,product);
        }
    
        return productMap;
    }

    public static void setQLIsToLost(Id quoteId){
        List<CPQQuoteLineItem__c> existingQlis = [SELECT Id,Name,ContractSyncID__c FROM CPQQuoteLineItem__c WHERE PROS_Quote__c =: quoteId];
        for(CPQQuoteLineItem__c qli : existingQlis){
            qli.Result__c = 'Lost';
        }
        update existingQlis;
    }

}