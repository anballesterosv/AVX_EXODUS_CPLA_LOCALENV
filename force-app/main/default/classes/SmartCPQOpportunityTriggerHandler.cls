public with sharing class SmartCPQOpportunityTriggerHandler {
    
    public void handleAfterInsert(List<Opportunity> opportunities){
        /* Proceed with cloning the active release of the primary quote of the source opportunity if  new opportunity cloned with a SmartCPQ QUote*/
        for(Opportunity o : opportunities){
                if(o.IsApexCloned__c == true && o.SourceOpportunity__c != null){
                    List<CameleonCPQ__Quote__c> quotes = [SELECT Id, Name, CameleonCPQ__ActiveRelease__c, OpportunityId__c,Primary_Quote__c FROM CameleonCPQ__Quote__c WHERE OpportunityId__c =: o.SourceOpportunity__c AND Primary_Quote__c =TRUE];
                    if (quotes.size()>0){
                        for(CameleonCPQ__Quote__c q : quotes){
                            //Clone SmartCPQ Quote
                            SmartCPQQuoteCustomCloner.customCloneQuote(q.Id, o.Id,true,true);
                        }
                    }
                }
        }
            
    }
    
    public void handleAfterUpdate(List<Opportunity> oppsNew, List<Opportunity> oppsOld){
        /**RDE - 3/15/2018 - No need All quotes would be locked through expiration & Change status workflows & Approval lock
        for (Opportunity oppNew : oppsNew) {
            for (Opportunity oppOld : oppsOld)
            {
                
                //Opportunity got closed (won or loss), lock all associated quotes
                if (oppNew.StageName.contains('Close') && !oppOld.StageName.contains('Close')){
                    String oppType = oppNew.Record_Type_Name__c;
                    Id lockQuoteRecTypeId;
                    if (oppType != null && oppType.containsIgnoreCase('Beef')){
                        lockQuoteRecTypeId = Schema.SObjectType.CameleonCPQ__Quote__c.getRecordTypeInfosByName().get('Non-Editable Beef').getRecordTypeId();
                    }else{
                        lockQuoteRecTypeId = Schema.SObjectType.CameleonCPQ__Quote__c.getRecordTypeInfosByName().get('Non-Editable').getRecordTypeId();
                    }
                    if (lockQuoteRecTypeId != null){
                        List<CameleonCPQ__Quote__c> quotes = [SELECT Id, Name,Primary_Quote__c,Is_Primary_Quote_Removable__c FROM CameleonCPQ__Quote__c  WHERE OpportunityId__c =: oppNew.Id];   
                        for(CameleonCPQ__Quote__c quote : quotes){
                            quote.RecordTypeId = lockQuoteRecTypeId;
                        }   
                        if (!quotes.isEmpty()){
                            update quotes;
                        }
                    }             
                
                }
                
            }
        }*/
        //Call helper method to determine Opportunity Type for eligible Opportunities
        
        //Cognizant 02/08/2018: commented As per new CR- Quote Price Type and Deal size considertaion for Opportunity Type*/
        /*for(integer i=0; i<oppsNew.size();i++){
        //system.debug('****oppsNew[i].volume__c:'+oppsNew[i].volume__c+'*****oppsOld[i].volume__c:'+oppsOld[i].volume__c);
            if(oppsNew[i].volume__c!=oppsOld[i].volume__c){
                CPG_OpportunityUtil.calculateOppSize(oppsNew[i].id);
            }
        }*/
    }
    
}