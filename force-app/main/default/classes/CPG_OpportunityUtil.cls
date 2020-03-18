/**
Class Name: CPG_OpportunityUtil
Description: This util class is used for defining utility methods for Opportunity related processes
CreatedDate: 12-04-2017
**/
public without sharing class  CPG_OpportunityUtil{

//Cognizant 02/08/2018 : helper method to meet new CR requirements- Quote Price Type and Deal size considertaion for Opportunity Type*/
public static void calculateOppType(List<CameleonCPQ__Quote__c> quotes){
    List<Opportunity> oppToUpdate = new List<Opportunity>();
    Set<Id> qtOppIDSet = new Set<Id>();
    Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
    
    qtOppIDSet = getCameleonCPQQuoteRecords(quotes);
    
    if(!qtOppIDSet.isEmpty() && Schema.sObjectType.Opportunity.fields.Opportunity_type__c.isAccessible()){
        oppMap=new Map<Id,Opportunity>([select ID, Opportunity_type__c from Opportunity WHERE ID IN:qtOppIDSet]);
    }

    getUpdatedOpportunityRecords(quotes,oppMap,oppToUpdate); 

    if(!oppToUpdate.isEmpty() && Schema.sObjectType.Opportunity.fields.Opportunity_type__c.isUpdateable()){
            update oppToUpdate;
    }
    
}

private static Set<Id> getCameleonCPQQuoteRecords(List<CameleonCPQ__Quote__c> quotes){
    Set<Id> qtOppIDSet = new Set<Id>();
    for(CameleonCPQ__Quote__c quote : quotes){
        if(quote.Primary_Quote__c == TRUE && quote.OpportunityId__c != null){
            qtOppIDSet.add(quote.OpportunityId__c);
        }
    }
    return qtOppIDSet;
}

private static void getUpdatedOpportunityRecords(List<CameleonCPQ__Quote__c> quotes,
                                                 Map<Id,Opportunity> oppMap,
                                                 List<Opportunity> oppToUpdate){
    for(CameleonCPQ__Quote__c quote : quotes){
        if(oppMap.containsKey(quote.OpportunityId__c)){
            Opportunity opp=new Opportunity();
            opp=oppMap.get(quote.OpportunityId__c);
            if(quote.Pricing_Type__c=='NOF' || (quote.Pricing_Type__c!='NOF' && quote.DealSize__c=='Direct')) {
                opp.Opportunity_type__c='SIMPLE';        
            }else {
                opp.Opportunity_type__c='EXTENSIVE';
            }
            oppToUpdate.add(opp);
        }
        
    }                                                  
}
/*
public static void calculateOppSize(id OppId){
   // Cognizant: commented As per new CR- Quote Price Type and Deal size considertaion for Opportunity Type*/
/*list<Opportunity> opp = new list<Opportunity>();
list<CameleonCPQ__Quote__c> pQuote = new list<CameleonCPQ__Quote__c>();
pQuote = [select OpportunityId__c,Opportunity_Type__c, PPP_Duration__c, Pricing_Type__c,OpportunityId__r.volume__c from CameleonCPQ__Quote__c where Primary_Quote__c= true and opportunityid__c=:oppId order by lastmodifieddate Desc LIMIT 1];
if(pQuote.size()>0){
    if(pQuote[0].Opportunity_Type__c== 'BOXED_BEEF_GROUND_BEEF'){ 
        if(pQuote[0].Pricing_Type__c=='Formula' && (pQuote[0].OpportunityId__r.volume__c==null || pQuote[0].OpportunityId__r.volume__c<5000000)){
            opp.add(new opportunity(id=pQuote[0].OpportunityId__c , Opportunity_type__c='SIMPLE'));        
        }
        else if(pQuote[0].Pricing_Type__c=='NOF' && (pQuote[0].OpportunityId__r.volume__c==null || pQuote[0].OpportunityId__r.volume__c<250000)){
            opp.add(new opportunity(id=pQuote[0].OpportunityId__c , Opportunity_type__c='SIMPLE'));        
        }
        else if(pQuote[0].Pricing_Type__c=='PPP' && (((pQuote[0].OpportunityId__r.volume__c==null || pQuote[0].OpportunityId__r.volume__c<500000) && pQuote[0].PPP_Duration__c=='3 Months') || ((pQuote[0].OpportunityId__r.volume__c==null || pQuote[0].OpportunityId__r.volume__c<1000000) && pQuote[0].PPP_Duration__c=='6 Months')) || ((pQuote[0].OpportunityId__r.volume__c==null || pQuote[0].OpportunityId__r.volume__c<2000000) && pQuote[0].PPP_Duration__c=='12 Months')){
            opp.add(new opportunity(id=pQuote[0].OpportunityId__c , Opportunity_type__c='SIMPLE'));        
        }
        else {
            opp.add(new opportunity(id=pQuote[0].OpportunityId__c , Opportunity_type__c='EXTENSIVE'));     
        }
    }
    else if((pQuote[0].Opportunity_Type__c== 'TURKEY' || pQuote[0].Opportunity_Type__c== 'DELI') && pQuote[0].Pricing_Type__c=='Fixed'){
        if(pQuote[0].OpportunityId__r.volume__c==null || pQuote[0].OpportunityId__r.volume__c<1000000){
            opp.add(new opportunity(id=pQuote[0].OpportunityId__c , Opportunity_type__c='SIMPLE'));
        }
        else {
            opp.add(new opportunity(id=pQuote[0].OpportunityId__c , Opportunity_type__c='EXTENSIVE'));
        }
    }
    if(opp.size()>0){
        update opp;
    }
}
}*/

//Roll-Up NUmber of Cloned Opportunities on Source Opportunity
public static void rollUpClonedOppCount(set<id> oppIds){
    list<Opportunity> lstOpp = new list<Opportunity>();
    for(aggregateResult ag:[select count(id),sourceOpportunity__c opp from Opportunity where sourceOpportunity__c in :oppIds group by sourceOpportunity__c]){
        //lstOpp.add(id=(id)ag.get(sourceOpportunity__c), number_of_Cloned_Opp__c=ag.get('expr0'));
        system.debug(ag.get('opp'));
        lstOpp.add(new Opportunity(id=(id)ag.get('opp'),number_of_cloned_Opp__c=(decimal)ag.get('expr0')));
    }
    if(!lstOpp.isEmpty()){
        update lstOpp;
    }
}
}