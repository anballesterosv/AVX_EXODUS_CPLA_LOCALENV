/*
*    @description:    Controller of PositioningBarGraph page.
*    @author:         Sharee Mae Ingatan (sharee.mae.r.ingatan@accenture.com)
*    @createddate:    April 19, 2016
*/
public class PositioningBarGraphCX {

    public Account currentAccount {get;set;}
    public Map<String, Integer> mapStrings {get;set;}
    List<String> positioningValuesList {get;set;}

    public PositioningBarGraphCX(ApexPages.StandardController controller) {
                currentAccount = [SELECT Id, Name FROM Account WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
                
    }
    
    
    public void positioningCount() {
        //get all related competitor products of account
        List<Competitor_Product__c> relatedProductsList = [SELECT ID, Name, Positioning__c, Competitor__c FROM Competitor_Product__c WHERE Competitor__c = :currentAccount.Id];
    
        if(relatedProductsList.size() > 0) {
                List<String> usedPositioningList = new List<String>();
                for(Competitor_Product__c product : relatedProductsList) {
                        if(product.Positioning__c != null) {
                                usedPositioningList.add(product.Positioning__c);
                        }
                }
            
            positioningValuesList = new List<String>();
            for(String s : usedPositioningList) {
                List<String> sList = s.split(';');
                positioningValuesList.addAll(sList);
                positioningValuesList.sort();
            }
                
                mapStrings = new Map<String, Integer>();
                Integer counter = 1;
                
                for(String s : positioningValuesList) { 
                    if(mapStrings.containsKey(s)) {
                        mapStrings.put(s, mapStrings.get(s) + 1);
                    } else {
                        mapStrings.put(s, counter);
                    }
                }
        }
    }
    
    
    public List<VerticalBarData> getBarData() { 
        positioningCount();
        List<VerticalBarData> newBardata = new List<VerticalBarData>();
        for(String s : mapStrings.keySet()) {
                newBardata.add(new VerticalBarData(s, mapStrings.get(s)));
        }
        return newBardata;
    }  

    public class VerticalBarData {  
        public String positions { get; set; }  
        public Integer posNum { get; set; }  
        
        public VerticalBarData(String positions, Integer posNum) {  
            this.positions = positions;  
            this.posNum = posNum;  
        }  
    }
}