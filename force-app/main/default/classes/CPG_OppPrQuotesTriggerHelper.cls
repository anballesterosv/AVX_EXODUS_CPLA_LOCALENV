/**
@name CPG_OpportunityProsQuotesTriggerHelper
@CreateDate Apr 5, 2018
@Description Helper class for Pros Quote trigger
@Version <1.0>
@reference CPG_OpportunityProsQuotetrigger
*/ 
public class CPG_OppPrQuotesTriggerHelper {
    public static void rollupTrigger(list<CameleonCPQ__Quote__c> records){
        set<id>  opportunityIds=new set<id>();
        for(CameleonCPQ__Quote__c quote:records){
            opportunityIds.add(quote.OpportunityId__c);
             system.debug('***inside pricing method');
        }
        list<opportunity> opplist=new list<opportunity>();
        for(opportunity opp:[select id, Number_of_Related_Quotes__c, (select id ,OpportunityId__c,Pricing_Start_Date__c,Pricing_End_Date__c  from PROS_Quotes__r where Primary_Quote__c=true order by lastmodifieddate asc) from opportunity where id IN :opportunityIds]){            
            if(opp.PROS_Quotes__r.size()==0){
                for(CameleonCPQ__Quote__c rec:records){
                    if(rec.id==null && rec.Opportunityid__c==opp.id){
                        opp.Quote_Pricing_Start_Date__c = rec.Pricing_Start_Date__c;
                        opp.Quote_Pricing_End_Date__c  = rec.Pricing_End_Date__c;
                    }    
            }
            }
            for(CameleonCPQ__Quote__c qt:opp.PROS_Quotes__r){
                for(CameleonCPQ__Quote__c rec:records){
                    if(rec.id==null || rec.id==qt.id){
                        opp.Quote_Pricing_Start_Date__c = rec.Pricing_Start_Date__c;
                        opp.Quote_Pricing_End_Date__c  = rec.Pricing_End_Date__c;
                    }
                }
            }
            opp.Number_of_Related_Quotes__c=opp.PROS_Quotes__r.size();
            opplist.add(opp);
            
        }  
        if(opplist.size()>0 && opplist!=null){
             system.debug('***inside prciing update call'+opplist[0].Pricing_Start_Date__c);
            update opplist;
        }
    }
}