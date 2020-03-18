/**
Class Name: CPG_QuoteShipTo_TriggerHelper
Created Date: Jan-04-2017
Created By: Cognizant
This class is  helper class for Quote Ship To Trigger.
**/
public class CPG_QuoteShipTo_TriggerHelper{
//Method to set up Ship To/Sold To on Quote
public static void updateSoldToShipTo(list<Quote_ship_to__c> lstQuoteShipTo){
    set<id> setQuotes = new set<id>();
    map<id,string> mapQShipTo = new map<id, string>();
    map<id,string> mapQShipToDesc = new map<id, string>();
    map<id,string> mapQSoldTo = new map<id, string>();
    list<CameleonCPQ__Quote__c> lstQuotes = new list<CameleonCPQ__Quote__c>();
    
    //Get the Quotes for querying updated list of Quote Ship To's
    for(Quote_ship_to__c qs:lstQuoteShipTo){
        setQuotes.add(qs.PROS_Quote__c);
    }
    if(!setQuotes.isEmpty()){
        for(Quote_ship_to__c qs:[select PROS_Quote__c,ship_to__r.Description__c,ship_to__r.legacy_id__c,ship_to__r.legacy_system__c, ship_to__r.erp_Number__c , ship_to__r.sold_to__r.erp_Number__c from quote_ship_to__c where PROS_Quote__c in:setQuotes]){
            if(!mapQShipTo.isEmpty() && mapQShipTo.containsKey(qs.pros_quote__c)){
                string shipTos = mapQShipTo.get(qs.pros_quote__c)+';'+qs.ship_to__r.erp_number__c+'|'+qs.ship_to__r.legacy_system__c;
                mapQShipTo.put(qs.pros_quote__c,shipTos);
                
                string shipTosDesc = mapQShipToDesc.get(qs.pros_quote__c)+';'+qs.ship_to__r.Description__c;
                mapQShipToDesc.put(qs.pros_quote__c,shipTosDesc);
                
                string soldTos = mapQSoldTo.get(qs.pros_quote__c)+';'+qs.ship_to__r.sold_to__r.erp_Number__c;
                mapQSoldTo.put(qs.pros_quote__c,soldTos);               
            }
            else{
                string shipTos = qs.ship_to__r.erp_number__c+'|'+qs.ship_to__r.legacy_system__c;
                mapQShipTo.put(qs.pros_quote__c,shipTos);
                string shipTosDesc = qs.ship_to__r.description__c;
                mapQShipToDesc.put(qs.pros_quote__c,shipTosDesc);
                
                string soldTos = qs.ship_to__r.sold_to__r.erp_Number__c;
                mapQSoldTo.put(qs.pros_quote__c,soldTos);     
            }    
        }    
    } 
    
    //Update Quotes with added/deleted Ship To/Sold To list
    if(!setQuotes.isEmpty()){
        for(id qId :setQuotes){
            if(!mapQShipTo.isEmpty() && mapQShipTo.containsKey(qId)){
                lstQuotes.add(new CameleonCPQ__Quote__c(id = qId, Ship_To_List__c = mapQShipTo.get(qId), Ship_To_Description_List__c = mapQShipToDesc.get(qId), Sold_To_List__c = mapQSoldTo.get(qId)));    
            }
            else{
                lstQuotes.add(new CameleonCPQ__Quote__c(id = qId, Ship_To_List__c = null, Ship_To_Description_List__c=null,Sold_To_List__c = null)); 
            }
        }
        //UPdate Quotes with new Ship To/Sold To list
        database.update(lstQuotes, false);
    }
    
}
}