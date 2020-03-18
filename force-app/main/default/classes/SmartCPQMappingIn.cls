global without sharing class SmartCPQMappingIn implements CameleonCPQ.CPQRequestFormatter.IMappingIN_Ext1 { 
    private static final String CARGILL='CPG'; 
    private static final String CARGILL_NOF_PPP='CPG_NOFPPP';
    global List<CameleonCPQ.CPQRequestFormatter.Tuple> getCPQCustomSettings(Id quoteId) 
    {
        CameleonCPQ__Quote__c quote = getQuote(quoteId);
        
        List<CameleonCPQ.CPQRequestFormatter.Tuple> sessionXmlElts = new List< CameleonCPQ.CPQRequestFormatter.Tuple>();
        
        this.addQuoteShipTos(sessionXmlElts,quote);
        this.addCurrencyExchangeRates(sessionXmlElts);
        this.addBillToSelectedCheck(sessionXmlElts,quote);
        return sessionXmlElts;
    }
    @TestVisible
    private void addTuple(List<CameleonCPQ.CPQRequestFormatter.Tuple> sessionXmlElements, String tupleKey, String tupleValue){
        CameleonCPQ.CPQRequestFormatter.Tuple tuple = new CameleonCPQ.CPQRequestFormatter.Tuple(tupleKey, tupleValue);
        sessionXmlElements.add(tuple);
    }
    
    @TestVisible
    private CameleonCPQ__Quote__c getQuote(Id quoteId) {
      CameleonCPQ__Quote__c quote = null;
        List<CameleonCPQ__Quote__c> quotes = [SELECT Id,
                            CameleonCPQ__AccountId__c,
                            Pricing_Type__c
                          FROM CameleonCPQ__Quote__c 
                          WHERE Id =: quoteId];
        if (quotes.size() > 0)
        {
          quote = quotes.get(0);
        }
        return quote;
    }   
	
    @TestVisible
    private void addQuoteShipTos(List<CameleonCPQ.CPQRequestFormatter.Tuple> sessionXmlElts, CameleonCPQ__Quote__c quote){
    
    	List<Quote_Ship_To__c> quoteShipTos = [SELECT Id,Name,PROS_Quote__c,Ship_To__r.Name,Ship_To__r.Legacy_System__c,Ship_To__r.ERP_Number__c,Ship_To__r.Description__c FROM Quote_Ship_To__c WHERE PROS_Quote__c =: quote.Id];
        
        Integer i = 0;
        for(Quote_Ship_To__c quoteShipTo: quoteShipTos){
            i = i +1;
            this.addQuoteShipTo(sessionXmlElts,quoteShipTo,i);
        }
    }
    
    @TestVisible
    private void addBillToSelectedCheck(List<CameleonCPQ.CPQRequestFormatter.Tuple> sessionXmlElts, CameleonCPQ__Quote__c quote){
        List<Quote_Bill_To__c> quoteBillTos = [SELECT Id,Name FROM Quote_Bill_To__c WHERE PROS_Quote__c =: quote.Id];
        CameleonCPQ.CPQRequestFormatter.Tuple billTosNb = new CameleonCPQ.CPQRequestFormatter.Tuple('BillTosNb', String.valueOf(quoteBillTos.size()));
        sessionXmlElts.add(billTosNb);       
    }
    
    private void addQuoteShipTo(List<CameleonCPQ.CPQRequestFormatter.Tuple> sessionXmlElts, Quote_Ship_To__c quoteShipTo, Integer index){
        String quoteShipToPrefix = 'ShipTo[' + index + '].';
        
        CameleonCPQ.CPQRequestFormatter.Tuple qstId = new CameleonCPQ.CPQRequestFormatter.Tuple(quoteShipToPrefix + 'Id', quoteShipTo.Id);
        CameleonCPQ.CPQRequestFormatter.Tuple qstName = new CameleonCPQ.CPQRequestFormatter.Tuple(quoteShipToPrefix + 'Name', quoteShipTo.Ship_To__r.Name);
        CameleonCPQ.CPQRequestFormatter.Tuple qstERPNb = new CameleonCPQ.CPQRequestFormatter.Tuple(quoteShipToPrefix + 'ERP_Number', quoteShipTo.Ship_To__r.ERP_Number__c);
        CameleonCPQ.CPQRequestFormatter.Tuple qstLegacySystem = new CameleonCPQ.CPQRequestFormatter.Tuple(quoteShipToPrefix + 'Legacy_System', quoteShipTo.Ship_To__r.Legacy_System__c);
      
        sessionXmlElts.add(qstId);
        sessionXmlElts.add(qstName);
        sessionXmlElts.add(qstERPNb);
        sessionXmlElts.add(qstLegacySystem);

        
    }
    
    private void addCurrencyExchangeRates(List<CameleonCPQ.CPQRequestFormatter.Tuple> sessionXmlElts){
		String erPrefix = 'Exchange_Rate_';
        List<CurrencyType> currTypes = [SELECT Id,IsoCode,isActive,ConversionRate FROM CurrencyType WHERe isActive =TRUE];
        for (CurrencyType currType: currTypes){
            if (currType.IsoCode != null && currType.ConversionRate != null)
            	sessionXmlElts.add(new CameleonCPQ.CPQRequestFormatter.Tuple(erPrefix + currType.IsoCode, String.valueOf(currType.ConversionRate)));
        }
    }
    
    global CameleonCPQ.CPQRequestFormatter.CPQSessionSettings getCPQSessionSettings(Id entityId, CameleonCPQ.CPQRequestFormatter.CPQSessionSettings sessionSettings) {
        System.debug('entityId----'+entityId);
        System.debug('sessionSettings-----'+sessionSettings);
        CameleonCPQ.CPQRequestFormatter.CPQSessionSettings customSessionSettings = sessionSettings;
        CameleonCPQ__Quote__c quote = getQuote(entityId);
        String pricingType = quote.Pricing_Type__c;
        if  (pricingType != null && (pricingType.equalsIgnoreCase('NOF') || pricingType.equalsIgnoreCase('Contract') || pricingType.equalsIgnoreCase('PPP')) ){
            //Override Cart Model with NOF / PPP version 
            customSessionSettings.setQuoteModelName(CARGILL_NOF_PPP);  
        }else{
            customSessionSettings.setQuoteModelName(CARGILL);  
        }
        
        return customSessionSettings;   
    }
    
}