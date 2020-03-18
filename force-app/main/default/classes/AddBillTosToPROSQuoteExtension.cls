public  with sharing class AddBillTosToPROSQuoteExtension {
    private CameleonCPQ__Quote__c quote;
    public list<wrapBillTo> lstBillTos{get;set;}
    private string quoteCurrency;
    set<string> setQuoteBillTos = new set<string>();

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public AddBillTosToPROSQuoteExtension(ApexPages.StandardController stdController) {
        this.quote = (CameleonCPQ__Quote__c)stdController.getRecord();       
        CameleonCPQ__Quote__c prosQuote = [SELECT Id,Name,CameleonCPQ__AccountId__c,   OpportunityId__r.recordtype.developerName,Pricing_Type__c FROM CameleonCPQ__Quote__c WHERE Id=: this.quote.Id];
        
        Boolean displayBillTos=  false;
        if (prosQuote.Pricing_Type__c != null && prosQuote.Pricing_Type__c.equalsIgnoreCase('PPP')){
            displayBillTos = true;
        }
        
        Id accountId = prosQuote.CameleonCPQ__AccountId__c;
        string oppType = prosQuote.OpportunityId__r.recordtype.developerName;
        string oppSystems;
        if(oppType!=null){
            list<Opportunity_RecordType_System_Mapping__mdt> lstOppSystems = [select Legacy_Systems__c from Opportunity_RecordType_System_Mapping__mdt where DeveloperName=:oppType];    
            if(lstOppSystems!=null && lstOppSystems.size()>0){
                oppSystems = lstOppSystems[0].Legacy_Systems__c;
            }
        }
        for(Quote_Bill_To__c qbt:[select Bill_To__c, bill_to__r.Default_Currency__c from Quote_Bill_To__c where pros_quote__c=:this.quote.id]){
            if(quoteCurrency!=null && qbt.bill_to__r.Default_Currency__c!=null){
                quoteCurrency = qbt.bill_to__r.Default_Currency__c;
            } 
            setQuoteBillTos.add(qbt.Bill_To__c);   
        }
        
        if (accountId != null && displayBillTos)
        {
            //for(Ship_To__c st : [select Id, Name,Payer__c,description__c,currency__c,City__c,state__c, ERP_Number__c, Legacy_System__c,Commercial_Account__c from Ship_To__c where (Commercial_Account__c = :accountId OR Payer__r.Parentid=:accountId)  AND id not in :setQuoteBillTos AND Status__c = 'Active']) {
            //Pull list of all available Ship Tos
            Boolean alreadySelected = false;
            for(Bill_To__c bt : [select Id, Name,Payer__c,description__c,Default_Currency__c,City__c,state__c, ERP_Number__c, Legacy_System__c,Commercial_Account__c,Global_Account__c from Bill_To__c where (Commercial_Account__c = :accountId OR Payer__r.Parentid=:accountId OR Global_Account__c=: accountId)  AND Status__c = 'Active']) {
                if(lstBillTos==null){
                    lstBillTos= new list<wrapBillTo>();
                }
                //Check if current Ship-Tos already selected
               	alreadySelected = false;
                if (setQuoteBillTos.contains(bt.Id)){
                    alreadySelected =true;
                }
                if(oppSystems!=null && oppType!='Non_CPQ'){
                    if((bt.Legacy_System__c!= null)&& (oppSystems.toLowerCase().indexOf(bt.Legacy_System__c.toLowerCase() )>=0)){
                        lstBillTos.add(new wrapBillTo(bt,alreadySelected));
                    }
                }
                else{
                    lstBillTos.add(new wrapBillTo(bt,alreadySelected));
                }
                //lstBillTos.add(new wrapBillTo(st));
            }
        }
    }
    public pageReference backtoQuote(){
        PageReference pageRef = new PageReference('/'+this.quote.id  + '?core.apexpages.devmode.url=1' ); 
        pageRef.setRedirect(true); 
        return pageRef; 
    }
    public pageReference addBillTos(){
        //Delete all BillTo first
        SmartCPQUtils.removeAllBillTos(this.quote);
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter value'));
        list<Quote_Bill_To__c> lstQuoteBillTo = new list<Quote_Bill_To__c>();   
        for(wrapBillTo bt:lstBillTos){
            if(bt.selected && (quoteCurrency==null || bt.BillTo.Default_Currency__c==quoteCurrency)){
                string externalId = this.quote.Id+'|'+ bt.BillTo.id;
                lstQuoteBillTo.add(new Quote_Bill_To__c(PROS_Quote__c=this.quote.Id, Bill_To__c = bt.BillTo.id, External_Id__c=externalId));    
                system.debug('selected ship:'+bt.BillTo.Name);
            }
            else if(bt.selected && quoteCurrency!=null && bt.BillTo.Default_Currency__c==quoteCurrency){
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: All selected Bill To\'s must have same currency!');
                ApexPages.addMessage(errMsg);  
                return null;       
            }
        }
        savePoint sp= database.setSavePoint();
        try{
            upsert lstQuoteBillTo;
        }catch(DmlException ex){
            ApexPages.addMessages(ex); 
            database.Rollback(sp);
            return null;   
        }
        PageReference pageRef = new PageReference('/'+this.quote.id  + '?core.apexpages.devmode.url=1'); 
        pageRef.setRedirect(true); 
        return pageRef; 
    }
    
    public pageReference addAllBillTos(){
        CameleonCPQ__Quote__c prosQuote = [SELECT Id,Name,CameleonCPQ__AccountId__c,OpportunityId__r.recordtype.developerName FROM CameleonCPQ__Quote__c WHERE Id=: this.quote.Id];

        SmartCPQUtils.addAllBillTos(prosQuote,null);
        return this.backToQuote();
    }
    
    public pageReference removeAllBillTos(){
        SmartCPQUtils.removeAllBillTos(quote);
        return this.backToQuote();
    }    
    
    public void selectAllBillTos(){
        for(wrapBillTo bh:lstBillTos){
            bh.setSelected(true);
        }
    }
    
    public void unSelectAllBillTos(){
        for(wrapBillTo bh:lstBillTos){
            bh.setSelected(false);
        }
    }
    
    public wrapBillTo createNewWrapBillTo(Bill_To__c billTo){
        wrapBillTo wbt = new  wrapBillTo(billTo,false);
        return wbt;
    }
    public class wrapBillTo{
        public boolean selected {get;set;}
        public void setSelected(Boolean isSelected){
            selected = isSelected;
        }
        public Bill_To__c billTo {get;set;}
        public wrapBillTo(Bill_To__c billTo,Boolean alreadySelected){
            this.selected = alreadySelected;
            this.billTo = billTo;
        }
    }
}