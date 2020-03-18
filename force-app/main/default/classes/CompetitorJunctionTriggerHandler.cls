/*
*   description:    Trigger Handler of Competitor Junction
*   author:         Sharee Ingatan (sharee.ingatan@cloudsherpas.com)
*   createddate:    April 7, 2016
*/
public class CompetitorJunctionTriggerHandler {
    
    /*
    *   description:    Count the total number of competitors of each customer.
    *   author:         Sharee Ingatan (sharee.ingatan@cloudsherpas.com)
    *   createddate:    April 7, 2016
    */
    public static void countCustomerCompetitors(List<Competitor_Junction__c> competitorJunctionsList) {
        Map<Id, List<Id>> mapAccounts = new Map<Id, List<Id>>();
        
        /* commenting this query to avoid duplicate SOQL
        for(Competitor_Junction__c cj : [SELECT Id, Customer__c, Competitor__c FROM Competitor_Junction__c]) {
            mapAccounts.put(cj.Customer__c, new List<Id>());
        }
        */
        for(Competitor_Junction__c cj : [SELECT Id, Customer__c, Competitor__c FROM Competitor_Junction__c]) {
            if(mapAccounts.containsKey(cj.Customer__c)) {
                mapAccounts.get(cj.Customer__c).add(cj.Competitor__c);
            } else {
                mapAccounts.put(cj.Customer__c, new List<Id>{cj.Competitor__c});
            }
        }
        
        List<Account> customersToUpdate = new List<Account>();
        for(Account customer : [SELECT Id, Total_Of_Competitors__c FROM Account]) {
            Map<Id, Decimal> oldMap = new Map<Id, Decimal>();
            oldMap.put(customer.id, customer.Total_Of_Competitors__c);

            if(mapAccounts.containsKey(customer.Id)) {
                customer.Total_Of_Competitors__c = mapAccounts.get(customer.Id).size();
            }
            
            if(customer.Total_Of_Competitors__c != oldMap.get(customer.id)) {
                customersToUpdate.add(customer);
            }
        }
        if(customersToUpdate.size() > 0) {
            update customersToUpdate;
        }
        updateAllCustomers();
    }
    public static void updateAllCustomers() {
        Set<Id> customerIds = new Set<Id>();
        for(Competitor_Junction__c cj : [SELECT Id, Customer__c, Competitor__c FROM Competitor_Junction__c]) {
            customerIds.add(cj.Customer__c);
        }
        
        List<Account> customersToUpdate = new List<Account>();
        for(Account acc : [SELECT Id, Total_Of_Competitors__c, Name FROM Account WHERE Id NOT IN :customerIds]) {
            acc.Total_Of_Competitors__c = 0;
            customersToUpdate.add(acc);
        }
        if(customersToUpdate.size() > 0) {
            update customersToUpdate;
        }
    }
    
    
    /*
    *   @description:   Updates the Competitor's performance field based from related customers.
    *   @author:        Sharee Mae Ingatan (sharee.mae.r.ingatan@accenture.com)
    *   @createddate:   April 18, 2016
    */
    public static void updateCompetitorPerformanceTrend(List<Competitor_Junction__c> competitorJunctionsList) {
        Decimal totalCustomers = 0;
        
        //get the competitor id
        Set<Id> competitorIds = new Set<Id>();
        for(Competitor_Junction__c competitorJunction : competitorJunctionsList) {
            competitorIds.add(competitorJunction.Competitor__c);
        }
        
        if(competitorIds.size() > 0 || competitorIds != null) {
            //get all related customers(competitor junction object)
            List<Competitor_Junction__c> customersTotalList = [SELECT Id, Name FROM Competitor_Junction__c WHERE Competitor__c IN :competitorIds AND (Competitor_Performance_Trend__c = 'Up' OR Competitor_Performance_Trend__c = 'Down')];
            if(customersTotalList.size() > 0) {
                totalCustomers = customersTotalList.size();
                    
                //get all customers with UP performace trend
                List<Competitor_Junction__c> customersUpTotalList = [SELECT Id, Name FROM Competitor_Junction__c WHERE Competitor__c IN :competitorIds AND Competitor_Performance_Trend__c = 'Up'];     //or = 'Up'
                
                //get all customers with DOWN performace trend
                List<Competitor_Junction__c> customersDownTotalList = [SELECT Id, Name FROM Competitor_Junction__c WHERE Competitor__c IN :competitorIds AND Competitor_Performance_Trend__c = 'Down'];
                
                //update the competitor's performance trend based on related customers performance trend
                List<Account> competitorsList = new List<Account>();
                
                //get the range values
                Decimal UpRange, DownRange;
                Map<String, Decimal> mapTotals = new Map<String, Decimal>();
                
                List<CompetitorPerformanceTrendRange__c> rangeSetting = [SELECT Id, Name, UP_Range__c, DOWN_Range__c, FLAT_Range__c FROM CompetitorPerformanceTrendRange__c];
                if(rangeSetting.size() > 0) {
                    UpRange = rangeSetting[0].UP_Range__c/100;
                    DownRange = rangeSetting[0].DOWN_Range__c/100;
                } else {
                    UpRange = 0.60;
                    DownRange = 0.40;
                }
                
                for(Account competitor : [SELECT Id, Competitor_Performance_Trend__c FROM Account WHERE Id IN :competitorIds]) {
                    Decimal UpTotal = customersUpTotalList.size()/totalCustomers;
                    Decimal DownTotal = customersDownTotalList.size()/totalCustomers;
                    
                    if(customersUpTotalList.size() > 0) {
                        mapTotals.put('Up', UpTotal);
                    }
                    if(customersDownTotalList.size() > 0) {
                        mapTotals.put('Down', DownTotal);
                    }
                
                    //get the highest(UpTotal or DownTotal) and compare the highest to the up and down ranges
                    if(UpTotal > DownTotal) {
                        if(UpTotal > UpRange) {
                            competitor.Competitor_Performance_Trend__c = 'Up';
                        } else if(UpTotal < DownRange) {    //if UpTotal is less than the UpRange and UpTotal is below the Downrange
                            competitor.Competitor_Performance_Trend__c = 'Down';
                        } else if(UpTotal > DownRange && UpTotal < UpRange) {
                            competitor.Competitor_Performance_Trend__c = 'Flat';
                        }
                    
                    } else if(DownTotal > UpTotal) {
                        if(DownTotal > UpRange) {
                            competitor.Competitor_Performance_Trend__c = 'Down';
                        } else if(DownTotal < DownRange) {    //if UpTotal is less than the UpRange and UpTotal is below the Downrange
                            competitor.Competitor_Performance_Trend__c = 'Down';
                        } else if(DownTotal > DownRange && DownTotal < UpRange) {
                            competitor.Competitor_Performance_Trend__c = 'Flat';
                        }
                    } else if(DownTotal == UpTotal) {    //only occurs with 50/50
                        if(UpTotal >= UpRange && DownTotal >= UpRange) {    //when UpRange is less than or equal 50
                            competitor.Competitor_Performance_Trend__c = 'Up';
                        } else if(UpTotal < UpRange && DownTotal < UpRange) {
                            if(UpTotal > DownRange && DownTotal > DownRange) {
                                //when 50 is above down range, means it is within the flat range
                                competitor.Competitor_Performance_Trend__c = 'Flat';
                            } else if(UpTotal < DownRange && DownTotal < DownRange) {    //if downrage is greater than 50
                                competitor.Competitor_Performance_Trend__c = 'Down';
                            }
                        }
                    }

                    competitorsList.add(competitor);
                }
                if(competitorsList.size() > 0) {
                    update competitorsList;
                }
            }
        }
    }
}