/*
*    @description:    Controller of PositioningBarGraph page.
*    @author:         Sharee Mae Ingatan (sharee.mae.r.ingatan@accenture.com)
*    @createddate:    April 19, 2016
*/
public class SubSectorBarGraphCX {

    public Account currentAccount {get;set;}
    public Map<String, Integer> mapStrings {get;set;}
    List<String> positioningValuesList {get;set;}

    public SubSectorBarGraphCX(ApexPages.StandardController controller) {
                currentAccount = [SELECT Id, Name FROM Account WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
                
    }
    
    
    public void positioningCount() {
        //get all related competitor products of account
        List<Competitor_Product__c> relatedProductsList = new List<Competitor_Product__c>([SELECT ID, Name, Sub_sector_segment_application__c, Competitor__c FROM Competitor_Product__c WHERE Competitor__c = :currentAccount.Id]);
        
        if(!relatedProductsList.isEmpty()) {
                List<String> usedPositioningList = new List<String>();
                for(Competitor_Product__c product : relatedProductsList) {
                        if(product.Sub_sector_segment_application__c != null) {
                                usedPositioningList.add(product.Sub_sector_segment_application__c);
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
            system.debug('s: ' + s);
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