global with sharing  class SmartCPQQuoteCustomCloner {
    private CameleonCPQ__Quote__c quote;
    private Id oppId;
    
    public SmartCPQQuoteCustomCloner(ApexPages.StandardController stdController){
        this.quote = (CameleonCPQ__Quote__c)stdController.getRecord();       
        if (quote.OpportunityId__c != null) this.oppId = quote.OpportunityId__c;       
    }
    
    public SmartCPQQuoteCustomCloner(){
        
    }   
    
    private static CPQInfo setCPQInfo(String statusNb,String errorMsg,String srcQuoId, String targetQuoId, Boolean errorPage,Boolean dbDeletion){
        final CPQInfo cpqInfo = new CPQInfo();
        cpqInfo.cpqStatus = statusNb;
        if(!errorMsg.equalsIgnoreCase('')){
            cpqInfo.cpqErr = errorMsg;
        }        
        if (errorPage){
           cpqInfo.cpqUrl = (Site.getPathPrefix()!=null?Site.getPathPrefix():'')+(new PageReference(Page.CameleonCPQ__CPQErrorPage.getURL()+'?id='+srcQuoId+'&msgType=2&errMsg='+EncodingUtil.urlEncode(errorMsg,'UTF-8'))).getUrl(); 
        }else{
           cpqInfo.cpqUrl = (Site.getPathPrefix()!=null?Site.getPathPrefix():'')+'/' + targetQuoId; 
        }
        if (dbDeletion){
            SObject[] q = Database.query('SELECT Id FROM CameleonCPQ__Quote__c where Id=\''+targetQuoId+'\'');
            if(q.size()>0) delete q;           
        }
        return cpqInfo;
    }
    @RemoteAction
    global static String cloneQuoteAction(Id quoteId, Id clonedOppId){
        String result = '-1';
        CameleonCPQ__Quote__c clone = cloneQuote(quoteId,clonedOppId,false,false); 
        if (clone != null){
             result = String.valueOf(clone.Id);
        }
           return result;
    }
    
    @RemoteAction
    global static CPQInfo cloneQuoteContentAction(String srcQuoId, String targetQuoId, String activeRelease, Boolean refresh) {
        /*final CPQInfo cpqInfo = new CPQInfo();*/
        System.debug('Cloning Cameleon CPQ Quote ['+srcQuoId+'] to ['+targetQuoId+']');
        try {
           final String[] CPQResult = CameleonCPQ.CPQRequestFormatter.sendCPQRequest(srcQuoId, targetQuoId, activeRelease,'copyCartRelease',''); 
           if(!'0'.equals(CPQResult[1])) {
              /*cpqInfo.cpqStatus = CPQResult[1];
              cpqInfo.cpqErr = CPQResult[2];
              cpqInfo.cpqUrl = (Site.getPathPrefix()!=null?Site.getPathPrefix():'')+(new PageReference(Page.CameleonCPQ__CPQErrorPage.getURL()+'?id='+srcQuoId+'&msgType=2&errMsg='+EncodingUtil.urlEncode(CPQResult[2],'UTF-8'))).getUrl();
              SObject[] q = Database.query('SELECT Id FROM CameleonCPQ__Quote__c where Id=\''+targetQuoId+'\'');
              if(q.size()>0) delete q;
              return cpqInfo;*/
              return setCPQInfo(CPQResult[1],CPQResult[2],srcQuoId,targetQuoId,true,true);
           }
        }
        catch (CameleonCPQ.CPQRequestFormatter.CPQRequestException e) {
          /* cpqInfo.cpqStatus = '2';
           cpqInfo.cpqErr = e.getMessage();
           cpqInfo.cpqUrl = (Site.getPathPrefix()!=null?Site.getPathPrefix():'')+(new PageReference(Page.CameleonCPQ__CPQErrorPage.getURL()+'?id='+srcQuoId+'&msgType=2&errMsg='+EncodingUtil.urlEncode(e.getMessage(),'UTF-8'))).getUrl();
           SObject[] q = Database.query('SELECT Id FROM CameleonCPQ__Quote__c where Id=\''+targetQuoId+'\'');
           if(q.size()>0) delete q;
           return cpqInfo;*/
            return setCPQInfo('2',e.getMessage(),srcQuoId,targetQuoId,true,true);
        }
        if(refresh) {
           try {
              CameleonCPQ.CPQRequestFormatter.refreshQuoteContent(targetQuoId);
              Integer start = System.Now().millisecond();
              Integer i=0;
              while(System.Now().millisecond()< start+1000 && i<100000){i++;}
           }
           catch (CameleonCPQ.CPQRequestFormatter.CPQRequestException e) {
              /*cpqInfo.cpqStatus = '2';
              cpqInfo.cpqErr = e.getMessage();
              cpqInfo.cpqUrl = (Site.getPathPrefix()!=null?Site.getPathPrefix():'')+(new PageReference(Page.CameleonCPQ__CPQErrorPage.getURL()+'?id='+srcQuoId+'&msgType=2&errMsg='+EncodingUtil.urlEncode(e.getMessage(),'UTF-8'))).getUrl();
              return cpqInfo;*/
              return setCPQInfo('2',e.getMessage(),srcQuoId,targetQuoId,true,false);
           }
        }
        /*cpqInfo.cpqStatus = '0';
        cpqInfo.cpqUrl = (Site.getPathPrefix()!=null?Site.getPathPrefix():'')+'/' + targetQuoId;
        return cpqInfo; */
        return setCPQInfo('0','',srcQuoId,targetQuoId,false,false);
    }
    
    webservice static String customCloneQuote(Id quoteId,Id cloneQuoteId,boolean updateCurrentPrice,boolean OppClone) 
    {
        String result = '-1';
        CameleonCPQ__Quote__c clone = cloneQuote(quoteId,cloneQuoteId,updateCurrentPrice,OppClone);
        if (clone != null){
            callOutAsyncCopyCartRelease(quoteId, clone.Id, String.valueOf(clone.CameleonCPQ__ActiveRelease__c));
        }
       
        return String.valueOf(clone.Id);
    }
    
    private static CameleonCPQ__Quote__c cloneQuote(Id quoteId,Id clonedOppId,boolean updateCurrentPrice,boolean OppClone) 
    { 
        CameleonCPQ__Quote__c quo = [SELECT Id,Name,Pricing_Type__c,CreatedDate,Pricing_Start_Date__c,Pricing_End_Date__c, CameleonCPQ__ActiveRelease__c, OpportunityId__c,Opportunity_Type__c, Primary_Quote__c,CameleonCPQ__Status__c, PPP_Duration__c, Version_Number__c, Need_To_Clone_Flag__c FROM CameleonCPQ__Quote__c WHERE Id =: quoteId];
        Map<String, Schema.SObjectField> flds = Schema.SObjectType.CameleonCPQ__Quote__c.fields.getMap();
        Schema.DescribeFieldResult fd = Schema.SObjectType.CameleonCPQ__Quote__c.fields.CameleonCPQ__Status__c;
        final String initStatus;
        
        if(fd!=null && fd.getPicklistValues()!=null && !fd.getPicklistValues().isEmpty())
        {
           initStatus = fd.getPicklistValues()[0].getValue();
        }
        
        List<String> fieldList = new List<String>();
        fieldList.addAll(flds.keySet());
        String quoFlds = '';
        for(integer i=0; i<fieldList.size(); i++)
        {
          if (flds.get(fieldList[i]).getDescribe().IsCreateable())
           {
              quoFlds = quoFlds + (quoFlds.length()>0?', ':'') + fieldList[i];
           }
        }
        
        SObject[] queryObject = Database.query('SELECT '+quoFlds+' FROM CameleonCPQ__Quote__c where Id=\''+quo.Id+'\'');
        if(queryObject!=null && queryObject.size()>0) 
        {
           CameleonCPQ__Quote__c[] oriQuoteList = new CameleonCPQ__Quote__c[]{ (CameleonCPQ__Quote__c)queryObject[0] };
           CameleonCPQ__Quote__c[] newQuoteList = oriQuoteList.deepClone(false);
           newQuoteList[0].put('CameleonCPQ__ActiveRelease__c',1);
           newQuoteList[0].put('CameleonCPQ__ExternalId__c','');
           newQuoteList[0].put('DealSize__c','');
           newQuoteList[0].put('Approval_Zone__c','');
           newQuoteList[0].put('Clone_Parent_Quote__c',quoteId);
           newQuoteList[0].put('Need_To_Clone_Flag__c',false);
            if(quo.CameleonCPQ__Status__c == 'Accepted'){
                newQuoteList[0].put('CurrentPriceCopy__c',updateCurrentPrice); 
            }else{
                newQuoteList[0].put('CurrentPriceCopy__c',false); 
            }
           
           newQuoteList[0].put('PPP_Duration__c', quo.PPP_Duration__c);
            String oldQuoteName = quo.Name;
            if (quo.Version_Number__c!=null && OppClone==false) {
               newQuoteList[0].put('Name','V'+ (quo.Version_Number__c + 1)+' - '+oldQuoteName.replace('V'+quo.Version_Number__c+' - ', '')); 
               newQuoteList[0].put('Version_Number__c',quo.Version_Number__c + 1);
            } else {
               newQuoteList[0].put('Name','V1 - '+oldQuoteName.replace('V'+quo.Version_Number__c+' - ', '')); 
               newQuoteList[0].put('Version_Number__c', 1);
            }
           
            if (clonedOppId != null){
                newQuoteList[0].put('OpportunityId__c',clonedOppId);
            }
           if(initStatus!=null)
           {
              newQuoteList[0].put('CameleonCPQ__Status__c',initStatus);
           }
           
            /*****Proceeds to original quote updaes*******/
			//If Previous quote accepted & primary quote, clone quote must be unflagged as primary quote
			Boolean originalQuoteUpdate =false;
            if (quo.Primary_Quote__c == true)       {
                if (quo.CameleonCPQ__Status__c == 'Accepted'){
                    newQuoteList[0].put('Primary_Quote__c',false);
                }else if (quo.OpportunityId__c ==  newQuoteList[0].OpportunityId__c){
                   quo.put('Primary_Quote__c',false);
                    quo.put('Is_Primary_Quote_Removable__c',true);
                    originalQuoteUpdate=true;
                    
                }                
            }     
            if(quo.Need_To_Clone_Flag__c==true){
                /* For NOF quotes if the status is Pricing Review or Price Submitted, the clone would be Pricing Review */
                if (quo.Pricing_Type__c=='NOF' && (quo.CameleonCPQ__Status__c == 'Pricing Review' || quo.CameleonCPQ__Status__c == 'Price Submitted')) {
                    newQuoteList[0].put('CameleonCPQ__Status__c','Pricing Review');
                }
                quo.put('CameleonCPQ__Status__c','Expired');
                quo.put('Need_To_Clone_Flag__c',false);
                Id quoteRecordTypeId = null;
                if (quo.Opportunity_Type__c !=null && quo.Opportunity_Type__c.containsIgnoreCase('Beef')){
                    quoteRecordTypeId = Schema.SObjectType.CameleonCPQ__Quote__c.getRecordTypeInfosByName().get('Non-Editable Beef').getRecordTypeId();
                }else{
                    quoteRecordTypeId = Schema.SObjectType.CameleonCPQ__Quote__c.getRecordTypeInfosByName().get('Non-Editable').getRecordTypeId();
                }
                if (quoteRecordTypeId!=null){
                    quo.put('RecordTypeId',quoteRecordTypeId);
                }              
                originalQuoteUpdate=true;
            }
            if(originalQuoteUpdate){
                update quo;
            }
                
            
            /*****END -Proceeds to original quote updaes*******/
            
            /*Updates the quotes Pricing Dates with (Today - original quote creation date) for NOF and PPP Quotes if they are expired*/
            if (quo.CameleonCPQ__Status__c == 'Expired' && (quo.Pricing_Type__c=='NOF' || quo.Pricing_Type__c=='PPP' )){
                Integer daysDeltaNb = quo.CreatedDate.date().daysBetween(Date.today());
                if (daysDeltaNb > 0){
                    newQuoteList[0].put('Pricing_Start_Date__c',quo.Pricing_Start_Date__c.addDays(daysDeltaNb));
                    newQuoteList[0].put('Pricing_End_Date__c',quo.Pricing_End_Date__c.addDays(daysDeltaNb));
                }
            }
			//Set new Expiration Date of clone
			SmartCPQUtils.setQuoteExpirationDate(newQuoteList[0], null);
            
           // Clone the Release 
           /*String qry = 'SELECT Id '+(UserInfo.isMultiCurrencyOrganization() ? ',CurrencyIsoCode' : '')+' FROM CameleonCPQ__QuoteRelease__c where CameleonCPQ__QuoteId__c=\''+quo.Id+'\' and CameleonCPQ__ReleaseNumber__c='+quo.CameleonCPQ__ActiveRelease__c;
           System.debug(LoggingLevel.INFO, 'My query: ' + qry);
           SObject[] oriQrList = (CameleonCPQ__QuoteRelease__c[])Database.query(qry);
           if(oriQrList!=null&&oriQrList.size()>0) 
           {
              CameleonCPQ__QuoteRelease__c[] newQrList = oriQrList.deepClone(false);
              newQrList[0].put('CameleonCPQ__QuoteId__c',newQuoteList[0].Id);
              newQrList[0].put('CameleonCPQ__ReleaseNumber__c',1);
              insert newQrList[0];
           }*/
			
            insert newQuoteList[0];
            
           return newQuoteList[0];
        }
        return null;
    }
    
    @future (callout=true)
    public static void callOutAsyncCopyCartRelease(string tqid, string nql0id, string activerelease) {
        if(!Test.isRunningTest())
        	final String[] CPQResult = CameleonCPQ.CPQRequestFormatter.sendCPQRequest(tqid, nql0id, activerelease,'copyCartRelease','');
    }  
    
    global class CPQInfo
    {
        global String cpqUrl {get; set;}
        global String cpqStatus {get; set;}
        global String cpqErr {get; set;}
        
        global CPQInfo()
        {
        }
    }
}