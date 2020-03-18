public class SmartCPQQuoteTriggerHandler { 
    //Used to avoid too many automatic quotes (Expiration rule for NOF)
    private static final Integer QUOTE_COUNT_LIMIT = 31;
    
    /**
     * Main method called on a before insert trigger on the CameleonCPQ__Quote__c object (PROS Quote)
     */
    public void handleBeforeInsert(List<CameleonCPQ__Quote__c> quotes)
    {
        /*Set<Id> oppIds = new Set<ID>();
        Map<Id,Date> pricingStartDateMap = new Map<Id,Date>();
        Map<Id,Date> pricingEndDateMap = new Map<Id,Date>();*/
        for(CameleonCPQ__Quote__c quote : quotes){
           
            if (quote.OpportunityId__c != null){
                
                /*Set up Expiration Date*/
                //Reset Expiration Date
                quote.CameleonCPQ__Expires__c = null;
                SmartCPQUtils.setQuoteExpirationDate(quote, 'Direct');
                
                /*Assign Opportunity's Account Lookup to the current Quote before its creation*/
                Opportunity opp = [SELECT Id,Account.Id,Name,Record_Type_Name__c FROM Opportunity WHERE Id =: quote.OpportunityId__c];
                if (opp.AccountId != null)
                {
                    quote.CameleonCPQ__AccountId__c = opp.AccountId;
                }
                
                /*Set Quote Record Type to Editable*/
                String oppType = opp.Record_Type_Name__c;
                Id quoteRecordTypeId;
                if (oppType != null && oppType.containsIgnoreCase('Beef')){
                    quoteRecordTypeId = Schema.SObjectType.CameleonCPQ__Quote__c.getRecordTypeInfosByName().get('Editable Beef').getRecordTypeId();
                    //quote.FOBDelivered__c = 'FOB';
                }else{
                    quoteRecordTypeId = Schema.SObjectType.CameleonCPQ__Quote__c.getRecordTypeInfosByName().get('Editable').getRecordTypeId();
                }
                if (quoteRecordTypeId != null){
                    quote.RecordTypeId = quoteRecordTypeId;
                }
                
                
                //Check if opportunity has an existing primary quote, flag created quote as Primary if not
                List<CameleonCPQ__Quote__c> primaryQuotes =[SELECT Id,Name,Primary_Quote__c,Is_Primary_Quote_Removable__c,CameleonCPQ__Status__c FROM CameleonCPQ__Quote__c WHERE OpportunityId__c=: quote.OpportunityId__c  AND Primary_Quote__c = TRUE];
                if (quote.Primary_Quote__c == false){
                    if (primaryQuotes.size() <= 0){
                        quote.Primary_Quote__c = true;
                        
                        /*pricingStartDateMap.put(quote.OpportunityId__c,quote.Pricing_Start_Date__c);
                        pricingEndDateMap.put(quote.OpportunityId__c,quote.Pricing_End_Date__c);
                        //Update Accepted Date, Pricing Start & End Date of the opportunity to today
                        oppIds.add(quote.OpportunityId__c);*/
                    }                    
                }else{
                    for(CameleonCPQ__Quote__c otherPrimaryQuote : primaryQuotes)
                    {
                        if (otherPrimaryQuote.CameleonCPQ__Status__c.equals('Accepted')){
                            quote.addError('You cannot flag a primary quote when another Accepted primary quote exists in the opportunity');                               
                        }else{
                            otherPrimaryQuote.Primary_Quote__c = false;
                            otherPrimaryQuote.Is_Primary_Quote_Removable__c = true;
                        }
                    }
                    update primaryQuotes;                    
                }
            }  
        }
        
        /*Update Accepted Date for identified opportunities
        if(oppIds.size() > 0){
            List<Opportunity> opportunities = [SELECT Id,Name FROM Opportunity WHERE Id IN: oppIds];
            for(Opportunity o : opportunities){
                o.Pricing_Start_Date__c = pricingStartDateMap.get(o.Id);
                o.Pricing_End_Date__c = pricingEndDateMap.get(o.Id);
            }
            update opportunities; 
        }*/
    
    }

    /**
     * Main method called on a after insert trigger on the CameleonCPQ__Quote__c object (PROS Quote)
     */
    public void handleAfterInsert(List<CameleonCPQ__Quote__c> quotes)
    {
        Set<Id> oppIds = new Set<ID>();
        Map<Id,Date> pricingStartDateMap = new Map<Id,Date>();
        Map<Id,Date> pricingEndDateMap = new Map<Id,Date>();
        Map<Id,Id> primaryQuoteMap = new Map<Id,Id>();
        for(CameleonCPQ__Quote__c quote : quotes){
            if (quote.CameleonCPQ__AccountId__c !=null){
                String oppType = [SELECT Id,OpportunityId__r.recordtype.developerName FROM CameleonCPQ__Quote__c WHERE Id=: quote.Id].OpportunityId__r.recordtype.developerName;
                
                /****PROCESS IF QUOTE IS CLONED***/
                if (quote.Clone_Parent_Quote__c != null){
                    // Retrieve Ship-Tos to add to the clone
                    SmartCPQUtils.addParentQuoteShipTos(quote,oppType,quote.Clone_Parent_Quote__c);
                    
                    // Retrieve Bill-Tos to add to the clone
                    SmartCPQUtils.addParentQuoteBillTos(quote,oppType,quote.Clone_Parent_Quote__c);
                    
                }else{
                /******PROCESS IF REGULAR QUOTE*****/
                    /*Update 3/30/18 - RDE - No longer adds all ship-tos as a default when created new quote*/
                    //SmartCPQUtils.addAllShipTos(quote,oppType);

                    //Trigger Opportunity size calculation upon change of Contract Duration if quote is Primary quote
                    //if (quote.Primary_Quote__c== TRUE /*&&  quote.PPP_Duration__c != null*/ &&  quote.DealSize__c != null && quote.OpportunityId__c != null ){
                     //   CPG_OpportunityUtil.calculateOppSize(quote.OpportunityId__c);                      
                   // }
                }
                
                
                /*Save current Quote Information for Opportunity sync */
                if (quote.Primary_Quote__c== TRUE && quote.OpportunityId__c != null){
                    pricingStartDateMap.put(quote.OpportunityId__c,quote.Pricing_Start_Date__c);
                    pricingEndDateMap.put(quote.OpportunityId__c,quote.Pricing_End_Date__c);
                    primaryQuoteMap.put(quote.OpportunityId__c,quote.Id);
                    //Update Accepted Date, Pricing Start & End Date of the opportunity to today
                    oppIds.add(quote.OpportunityId__c);
                }
                
                
            }
        }
        
        //Sync Quote Info to Mapped Opportunities
        if(oppIds.size() > 0){
            List<Opportunity> opportunities = [SELECT Id,Name FROM Opportunity WHERE Id IN: oppIds];
            for(Opportunity o : opportunities){
                o.Pricing_Start_Date__c = pricingStartDateMap.get(o.Id);
                o.Pricing_End_Date__c = pricingEndDateMap.get(o.Id);
            }
            update opportunities; 
        }
        
        
    }
    
    /**
     * Main method called on an after update trigger on the CameleonCPQ__Quote__c object (PROS Quote)
     */
    public void handleAfterUpdate(List<CameleonCPQ__Quote__c> quotesNew, List<CameleonCPQ__Quote__c> quotesOld)
    {
        Set<Id> oppIds = new Set<ID>();
        List<CameleonCPQ__Quote__c> quotesToUpdate =new List<CameleonCPQ__Quote__c>();
        Map<Id,Date> pricingStartDateMap = new Map<Id,Date>();
        Map<Id,Date> pricingEndDateMap = new Map<Id,Date>();
        Map<Id,Id> primaryQuoteMap = new Map<Id,Id>();
        Map<Id,Boolean> hasOppAcceptedQuote = new Map<Id,Boolean>();
        for (CameleonCPQ__Quote__c quoteNew : quotesNew) {
            for (CameleonCPQ__Quote__c quoteOld : quotesOld)
            {
                
                //Sync Opportunity Line Items : If an accepted primary quote just got either accepted nor set to primary quote
                if(quoteNew.Id ==quoteOld.Id && quoteNew.OpportunityId__c != null && quoteNew.CameleonCPQ__Status__c.equals('Accepted') && quoteNew.Primary_Quote__c == true && (!quoteOld.CameleonCPQ__Status__c.equals('Accepted') || quoteOld.Primary_Quote__c == false)){
                    pricingStartDateMap.put(quoteNew.OpportunityId__c,quoteNew.Pricing_Start_Date__c);
                    pricingEndDateMap.put(quoteNew.OpportunityId__c,quoteNew.Pricing_End_Date__c);
                    primaryQuoteMap.put(quoteNew.OpportunityId__c,quoteNew.Id);
                    //Update Accepted Date, Pricing Start & End Date of the opportunity to today
                    oppIds.add(quoteNew.OpportunityId__c);
					//Specify that current opportunity has an accepted quote
					hasOppAcceptedQuote.put(quoteNew.OpportunityId__c, true);
                    //Sync QLIs to OLIs, HMR 3/2/18 Sync happens every time the quote is saved
                    //SmartCPQUtils.syncQLIstoOLIS(quoteNew.Id,quoteNew.OpportunityId__c);
                }
                
                //Synchronize Pricing Start & End Date of the primary quote to the opportunity if those dates changed
                if (quoteNew.Id == quoteOld.Id && quoteNew.Primary_Quote__c == true && (quoteNew.Pricing_End_Date__c != quoteOld.Pricing_End_Date__c || quoteNew.Pricing_Start_Date__c != quoteOld.Pricing_Start_Date__c || quoteOld.Primary_Quote__c == false) ){
                    pricingStartDateMap.put(quoteNew.OpportunityId__c,quoteNew.Pricing_Start_Date__c);
                    pricingEndDateMap.put(quoteNew.OpportunityId__c,quoteNew.Pricing_End_Date__c);
                    primaryQuoteMap.put(quoteNew.OpportunityId__c,quoteNew.Id);
                    //Update Accepted Date, Pricing Start & End Date of the opportunity to today
                    oppIds.add(quoteNew.OpportunityId__c);
					//Specify that current opportunity has an accepted quote
					hasOppAcceptedQuote.put(quoteNew.OpportunityId__c, quoteNew.CameleonCPQ__Status__c.equals('Accepted'));
					//Sync QLIs to OLIs if the primary quote changes
                    SmartCPQUtils.syncQLIstoOLIS(quoteNew.Id,quoteNew.OpportunityId__c);                    
                }
                
                /*Trigger Opportunity size calculation upon change of Contract Duration*/
                // Cognizant 02/08/2018: should be commented As per new CR- Quote Price Type and Deal size considertaion for Opportunity Type*/
                //if (quoteNew.Id == quoteOld.Id && quoteNew.Primary_Quote__c== TRUE && (/*(quoteNew.PPP_Duration__c != quoteOld.PPP_Duration__c)*/ (quoteNew.DealSize__c != quoteOld.DealSize__c) || quoteOld.Primary_Quote__c == false)  && (quoteNew.OpportunityId__c != null) ){
                 //   CPG_OpportunityUtil.calculateOppSize(quoteNew.OpportunityId__c);                      
               // }
                
                /*Set up All Quote Line Items to Lost if Status changes to 'Expired' or 'Rejected'*/
                if (quoteNew.Id == quoteOld.Id && quoteNew.CameleonCPQ__Status__c != quoteOld.CameleonCPQ__Status__c && ( quoteNew.CameleonCPQ__Status__c.equalsIgnoreCase('Expired') || quoteNew.CameleonCPQ__Status__c.equalsIgnoreCase('Rejected'))){
                    SmartCPQUtils.setQLIsToLost(quoteNew.Id);
                }
                
                /*Start Approval process if Status changes to Needs Review or Pricing Review*/
                if (!Test.isRunningTest() && quoteNew.Id == quoteOld.Id && quoteNew.CameleonCPQ__Status__c != quoteOld.CameleonCPQ__Status__c && ( quoteNew.CameleonCPQ__Status__c.equalsIgnoreCase('Needs Review') || quoteNew.CameleonCPQ__Status__c.equalsIgnoreCase('Pricing Review')) && !Approval.isLocked(quoteNew.id)  && (quoteNew.Pricing_Type__c != 'NOF') && (quoteNew.Pricing_Type__c != 'PPP')){
                    Approval.ProcessResult approvalResult = null;
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments('Please approve this quote.');
                    req.setObjectId(quoteNew.Id);
                    req.setProcessDefinitionNameOrId('PROS_Quote_Approval');           
                    approvalResult =  Approval.process(req);
                }

                 //Use case when quote needs to be expired & Cloned
                if(quoteNew.Need_To_Clone_Flag__c==TRUE && quoteOld.Need_To_Clone_Flag__c==FALSE){
                    List<CameleonCPQ__Quote__c> quoteListFromOpp = [SELECT Id FROM CameleonCPQ__Quote__c WHERE OpportunityId__c =: quoteNew.OpportunityId__c];
                    //Clone quote if not too many quotes on opportunity
                    if (quoteListFromOpp.size()<QUOTE_COUNT_LIMIT){
						SmartCPQQuoteCustomCloner.customCloneQuote(quoteNew.Id, quoteNew.OpportunityId__c,false, false);
                    }                    
                }
                
                
            }   
        }
        
        //Update Accepted Date for identified opportunities
        if(oppIds.size() > 0){
            List<Opportunity> opportunities = [SELECT Id,Name FROM Opportunity WHERE Id IN: oppIds];
            for(Opportunity o : opportunities){
                if (hasOppAcceptedQuote.get(o.Id)){
                    o.Accepted_Date__c = Date.today();
                }
                o.Primary_Quote__c = primaryQuoteMap.get(o.Id);                
                o.Pricing_Start_Date__c = pricingStartDateMap.get(o.Id);
                o.Pricing_End_Date__c = pricingEndDateMap.get(o.Id);

            }
            update opportunities; 
        }
         
        
    }
    
 /**
     * Main method called on an after update trigger on the CameleonCPQ__Quote__c object (PROS Quote)
     */
    public void handleBeforeUpdate(List<CameleonCPQ__Quote__c> quotesNew, List<CameleonCPQ__Quote__c> quotesOld)
    {
        //list of Quotes for setting up approvers
        list<CameleonCPQ__Quote__c> lstQuotes = new list<CameleonCPQ__Quote__c>();        
        for (CameleonCPQ__Quote__c quoteNew : quotesNew) {
            for (CameleonCPQ__Quote__c quoteOld : quotesOld)
            {
                if (quoteNew.Id == quoteOld.Id){                    
                
                    //Update up Expiration Date if need be : Changein Deal Size/Response
                    if (((quoteNew.DealSize__c!=null) && (quoteOld.DealSize__c==null)) ||  (quoteOld.DealSize__c!=null && !quoteOld.DealSize__c.equals(quoteNew.DealSize__c))){
                        SmartCPQUtils.setQuoteExpirationDate(quoteNew, null);
                    }
                    
                    /*if (quoteNew.Status_Change_Flag__c != quoteOld.Status_Change_Flag__c && quoteNew.Status_Change_Flag__c==TRUE  && quoteOld.CameleonCPQ__Status__c.equalsIgnoreCase('Price Submitted') && ((quoteNew.Pricing_Type__c == 'NOF') || (quoteNew.Pricing_Type__c == 'PPP'))){
                        quoteNew.CameleonCPQ__Status__c = 'Pricing Review';
                        quoteNew.Status_Change_Flag__c = FALSE;
                    }*/
                    
                    //Check validity of new Expiration >=Today() & <= Computed Expiration Date
                    if (quoteOld.CameleonCPQ__Expires__c != quoteNew.CameleonCPQ__Expires__c){
                        SmartCPQUtils.checkValidExpirationDate(quoteNew,true);
                        
                        //TO DELETE AFTER VALIDATION Check if Expiration date was extended by a day, if the quote if NOF or PPP and in Pricing Submitted status, then change status to Pricing Review
                        /*Date comparisonExpirationDate = quoteOld.CameleonCPQ__Expires__c.addDays(1);
                        if (quoteNew.CameleonCPQ__Expires__c == comparisonExpirationDate && quoteOld.CameleonCPQ__Status__c.equalsIgnoreCase('Price Submitted') && ((quoteNew.Pricing_Type__c == 'NOF') || (quoteNew.Pricing_Type__c == 'PPP'))){
                            quoteNew.CameleonCPQ__Status__c = 'Pricing Review';
                        }*/
                    }
                    
                    //Check if Primary Quote Flag was unchecked which is prohibited
                    if (quoteOld.Primary_Quote__c == true && quoteNew.Primary_Quote__c ==false && quoteNew.Is_Primary_Quote_Removable__c == false)
                    {
                        quoteNew.addError('You cannot unflag a primary quote, please flag another quote from the same opportunity as primary quote instead');
                    }else if (quoteOld.Primary_Quote__c == false && quoteNew.Primary_Quote__c ==true)
                    {
                        List<CameleonCPQ__Quote__c> otherPrimaryQuotes = [SELECT Id,Name,Primary_Quote__c,CameleonCPQ__Status__c FROM CameleonCPQ__Quote__c WHERE OpportunityId__c=: quoteNew.OpportunityId__c  AND Primary_Quote__c = TRUE AND Id !=: quoteNew.Id];
                         //List<CameleonCPQ__Quote__c> quotesToUpdate = new List<CameleonCPQ__Quote__c>();
                        if (otherPrimaryQuotes.size() >0)
                        {
                            for(CameleonCPQ__Quote__c otherPrimaryQuote : otherPrimaryQuotes)
                            {
                                if (otherPrimaryQuote.CameleonCPQ__Status__c.equals('Accepted')){
                                    quoteNew.addError('You cannot flag a primary quote when another Accepted primary quote exists in the opportunity');                               
                                }else{
                                    otherPrimaryQuote.Primary_Quote__c = false;
                                    otherPrimaryQuote.Is_Primary_Quote_Removable__c = true;
                                }
                            }
                            update otherPrimaryQuotes;
                        }       
                    }
                    quoteNew.Is_Primary_Quote_Removable__c = false;
                }
                //Get all eligible Quotes where Approvers need to be set/reset
                if(quoteNew.Approval_Zone__c != ((CameleonCPQ__Quote__c)Trigger.oldMap.get(quoteNew.id)).Approval_Zone__c || quoteNew.DealSize__c != ((CameleonCPQ__Quote__c)Trigger.oldMap.get(quoteNew.id)).DealSize__c || quoteNew.Pricing_Type__c != ((CameleonCPQ__Quote__c)Trigger.oldMap.get(quoteNew.id)).Pricing_Type__c){
                    lstQuotes.add(quoteNew);
                }
                //Reset Expired Quote Status post approval
                if(((CameleonCPQ__Quote__c)Trigger.oldMap.get(quoteNew.id)).CameleonCPQ__Status__c=='Expired' && (quoteNew.CameleonCPQ__Status__c== 'Accepted'|| quoteNew.CameleonCPQ__Status__c=='Rejected')){
                    quoteNew.CameleonCPQ__Status__c='Expired';
                }
                 //Use case when quote needs to be expired & Cloned = If there is too many quotes already just Expire the quote
                if(quoteNew.Need_To_Clone_Flag__c==TRUE && quoteOld.Need_To_Clone_Flag__c==FALSE){
                    List<CameleonCPQ__Quote__c> quoteListFromOpp = [SELECT Id FROM CameleonCPQ__Quote__c WHERE OpportunityId__c =: quoteNew.OpportunityId__c];
                    //Expire Quote only if there is too many quotes
                    if (quoteListFromOpp.size()>=QUOTE_COUNT_LIMIT){
                        quoteNew.CameleonCPQ__Status__c='Expired';
                        quoteNew.Need_To_Clone_Flag__c=false;
                        Id quoteRecordTypeId = null;
                        if (quoteNew.Opportunity_Type__c !=null && quoteNew.Opportunity_Type__c.containsIgnoreCase('Beef')){
                            quoteRecordTypeId = Schema.SObjectType.CameleonCPQ__Quote__c.getRecordTypeInfosByName().get('Non-Editable Beef').getRecordTypeId();
                        }else{
                            quoteRecordTypeId = Schema.SObjectType.CameleonCPQ__Quote__c.getRecordTypeInfosByName().get('Non-Editable').getRecordTypeId();
                        }
                        if (quoteRecordTypeId!=null){
                            quoteNew.RecordTypeId=quoteRecordTypeId;
                        }
                    }                    
                }
                    
            }
        }
       // Populate approver 
        if(!lstQuotes.isEmpty()){
            CPG_Approval_MatrixHelper.setQuoteApprovers(lstQuotes);
        } 
    }       
}