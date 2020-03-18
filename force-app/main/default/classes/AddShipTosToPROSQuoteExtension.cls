public with sharing class AddShipTosToPROSQuoteExtension {
    private CameleonCPQ__Quote__c quote;
    public list<wrapShipTo> lstShipTos{get;set;}
    private string quoteCurrency;
    set<string> setQuoteShipTos = new set<string>();

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public AddShipTosToPROSQuoteExtension(ApexPages.StandardController stdController) {
        this.quote = (CameleonCPQ__Quote__c)stdController.getRecord();       
        CameleonCPQ__Quote__c prosQuote = [SELECT Id,Name,CameleonCPQ__AccountId__c,   OpportunityId__r.recordtype.developerName FROM CameleonCPQ__Quote__c WHERE Id=: this.quote.Id];
        Id accountId = prosQuote.CameleonCPQ__AccountId__c;
        string oppType = prosQuote.OpportunityId__r.recordtype.developerName;
        string oppSystems;
        if(oppType!=null){
            list<Opportunity_RecordType_System_Mapping__mdt> lstOppSystems = [select Legacy_Systems__c from Opportunity_RecordType_System_Mapping__mdt where DeveloperName=:oppType];    
            if(lstOppSystems!=null && lstOppSystems.size()>0){
                oppSystems = lstOppSystems[0].Legacy_Systems__c;
            }
        }
        for(Quote_Ship_To__c qst:[select ship_to__c, ship_to__r.Currency__c from Quote_Ship_To__c where pros_quote__c=:this.quote.id]){
            if(quoteCurrency!=null && qst.ship_to__r.Currency__c!=null){
                quoteCurrency = qst.ship_to__r.Currency__c;
            } 
            setQuoteShipTos.add(qst.ship_to__c);   
        }
        
        if (accountId != null)
        {
            //for(Ship_To__c st : [select Id, Name,Payer__c,description__c,currency__c,City__c,state__c, ERP_Number__c, Legacy_System__c,Commercial_Account__c from Ship_To__c where (Commercial_Account__c = :accountId OR Payer__r.Parentid=:accountId)  AND id not in :setQuoteShipTos AND Status__c = 'Active']) {
            //Pull list of all available Ship Tos
            Boolean alreadySelected = false;
            for(Ship_To__c st : [select Id, Name,Payer__c,description__c,currency__c,City__c,state__c, ERP_Number__c, Legacy_System__c,Commercial_Account__c,Global_Account__c from Ship_To__c where (Commercial_Account__c = :accountId OR Payer__r.Parentid=:accountId OR Global_Account__c=: accountId)  AND Status__c = 'Active']) {
                if(lstShipTos==null){
                    lstShipTos= new list<wrapShipTo>();
                }
                //Check if current Ship-Tos already selected
               	alreadySelected = false;
                if (setQuoteShipTos.contains(st.Id)){
                    alreadySelected =true;
                }
                if(oppSystems!=null && oppType!='Non_CPQ'){
                    if((st.Legacy_System__c!= null)&& (oppSystems.toLowerCase().indexOf(st.Legacy_System__c.toLowerCase() )>=0)){
                        lstShipTos.add(new wrapShipTo(st,alreadySelected));
                    }
                }
                else{
                    lstShipTos.add(new wrapShipTo(st,alreadySelected));
                }
                //lstShipTos.add(new wrapShipTo(st));
            }
        }
    }
    public pageReference backtoQuote(){
        PageReference pageRef = new PageReference('/'+this.quote.id  + '?core.apexpages.devmode.url=1' ); 
        pageRef.setRedirect(true); 
        return pageRef; 
    }
    public pageReference addShipTos(){
        //Delete all ShipTo first
        SmartCPQUtils.removeAllShipTos(this.quote);
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter value'));
        list<Quote_Ship_To__c> lstQuoteShipTo = new list<Quote_Ship_To__c>();   
        for(wrapShipTo sh:lstShipTos){
            if(sh.selected && (quoteCurrency==null || sh.shipTo.currency__c==quoteCurrency)){
                string externalId = this.quote.Id+'|'+ sh.shipTo.id;
                lstQuoteShipTo.add(new Quote_Ship_To__c(PROS_Quote__c=this.quote.Id, Ship_To__c = sh.shipTo.id, External_Id__c=externalId));    
                system.debug('selected ship:'+sh.shipTo.Name);
            }
            else if(sh.selected && quoteCurrency!=null && sh.shipTo.currency__c==quoteCurrency){
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: All selected Ship To\'s must have same currency!');
                ApexPages.addMessage(errMsg);  
                return null;       
            }
        }
        savePoint sp= database.setSavePoint();
        try{
            upsert lstQuoteShipTo;
        }catch(DmlException ex){
            ApexPages.addMessages(ex); 
            database.Rollback(sp);
            return null;   
        }
        PageReference pageRef = new PageReference('/'+this.quote.id  + '?core.apexpages.devmode.url=1'); 
        pageRef.setRedirect(true); 
        return pageRef; 
    }
    
    public pageReference addAllShipTos(){
        CameleonCPQ__Quote__c prosQuote = [SELECT Id,Name,CameleonCPQ__AccountId__c,OpportunityId__r.recordtype.developerName FROM CameleonCPQ__Quote__c WHERE Id=: this.quote.Id];

        SmartCPQUtils.addAllShipTos(prosQuote,null);
        return this.backToQuote();
    }
    
    public pageReference removeAllShipTos(){
        SmartCPQUtils.removeAllShipTos(quote);
        return this.backToQuote();
    }    
    
    public void selectAllShipTos(){
        for(wrapShipTo sh:lstShipTos){
            sh.setSelected(true);
        }
    }
    
    public void unSelectAllShipTos(){
        for(wrapShipTo sh:lstShipTos){
            sh.setSelected(false);
        }
    }
    
    public wrapShipTo createNewWrapShipTo(SHIP_To__c shipTo){
        wrapShipTo wst = new  wrapShipTo(shipTo,false);
        return wst;
    }
    public class wrapShipTo{
        public boolean selected {get;set;}
        public void setSelected(Boolean isSelected){
            selected = isSelected;
        }
        public Ship_To__c shipTo {get;set;}
        public wrapShipTo(SHIP_To__c shipTo,Boolean alreadySelected){
            this.selected = alreadySelected;
            this.shipTo = shipTo;
        }
    }
}