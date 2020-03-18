/*
*    @description:    Controller of AllPositioningAndSubSectorBarGraphs page.
*    @author:         Sharee Mae Ingatan (sharee.mae.r.ingatan@accenture.com)
*    @createddate:    April 22, 2016
*/
public class AllPositioningAndSubSectorBarGraphsCC {
        
    List<Competitor_Product__c> relatedProductsList {get;set;}
    public Map<String, Integer> mapSubSectors {get;set;}
    List<String> subSectorValuesSplitList {get;set;}
    List<String> allSubSectorValuesList {get;set;}
    public Map<String, Integer> mapPositionings {get;set;}
    List<String> positioningValuesSplitList {get;set;}
    List<String> allPositioningValuesList {get;set;}
    public Boolean showChart {get;set;}
    
    public AllPositioningAndSubSectorBarGraphsCC() {
        try {
            relatedProductsList = [SELECT ID, Name, Sub_sector_segment_application__c, Positioning__c FROM Competitor_Product__c];
            
            //get the sub sector picklist values
            allSubSectorValuesList = new List<String>();
            Schema.DescribeFieldResult fieldResult = Competitor_Product__c.Sub_sector_segment_application__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
            for(Schema.PicklistEntry f : ple) {
               allSubSectorValuesList.add(f.getValue());
            }
                
            //get the positioning picklist values
            allPositioningValuesList = new List<String>();
            Schema.DescribeFieldResult fieldResultPos = Competitor_Product__c.Positioning__c.getDescribe();
            List<Schema.PicklistEntry> plePos = fieldResultPos.getPicklistValues();
                
            for(Schema.PicklistEntry f : plePos) {
               allPositioningValuesList.add(f.getValue());
            }
            
            if(!(relatedProductsList.isEmpty())) {
                showChart = true;
            } else {
                showChart = false;
            }
        } catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No Existing Competitor Records in the Org.'));
        } 
    }
    
    /***        Sub Sector START        ***/
    public void subSectorCount() {
        if(!(relatedProductsList.isEmpty())) {
                List<String> usedSubSectorList = new List<String>();        //get all subsector values of each competitor product record
                for(Competitor_Product__c product : relatedProductsList) {
                        if(product.Sub_sector_segment_application__c != null) {
                                usedSubSectorList.add(product.Sub_sector_segment_application__c);
                        }
                }
            
            subSectorValuesSplitList = new List<String>();     //split all subsector of each competitor product records into each subsector picklist values
            for(String s : usedSubSectorList) {
                List<String> sList = s.split(';');
                subSectorValuesSplitList.addAll(sList);
                subSectorValuesSplitList.sort();
            }
                
            mapSubSectors = new Map<String, Integer>();       //map how many times a subsector is used
            Integer counter = 1;
            
            for(String s : subSectorValuesSplitList) {
                if(mapSubSectors.containsKey(s)) {
                    mapSubSectors.put(s, mapSubSectors.get(s) + 1);
                } else {
                    mapSubSectors.put(s, counter);
                }
            }
        }
    }
    
    public List<SubSectorBarData> getSubSectorBarData() { 
        subSectorCount();
        List<SubSectorBarData> newBardata = new List<SubSectorBarData>();
        if(!(allSubSectorValuesList.isEmpty() ) && !(relatedProductsList.isEmpty())) {
           // if(!(relatedProductsList.isEmpty())) {
                for(String s : allSubSectorValuesList) {
                    if(mapSubSectors.get(s) != null) {
                            newBardata.add(new SubSectorBarData(s, mapSubSectors.get(s)));
                    } else {
                            newBardata.add(new SubSectorBarData(s, 0));
                    }
                }
            //}
        }
        return newBardata;
    }  

    public class SubSectorBarData {  
        public String subsectors { get; set; }  
        public Integer subNum { get; set; }  
        
        public SubSectorBarData(String subsectors, Integer subNum) {  
            this.subsectors = subsectors;  
            this.subNum = subNum;  
        }  
    }
    /***        Sub Sector END  ***/

    
    /***        Positioning START        ***/
    public void positioningCount() {
        if(!(relatedProductsList.isEmpty())) {
                List<String> usedPositioningList = new List<String>();        //get all positioning values of each competitor product record
                for(Competitor_Product__c product : relatedProductsList) {
                        if(product.Positioning__c != null) {
                                usedPositioningList.add(product.Positioning__c);
                        }
                }
            
            positioningValuesSplitList = new List<String>();     //split all positioning of each competitor product records into each positioning picklist values
            for(String s : usedPositioningList) {
                List<String> sList = s.split(';');
                positioningValuesSplitList.addAll(sList);
                positioningValuesSplitList.sort();
            }
                
            mapPositionings = new Map<String, Integer>();       //map how many times a subsector is used
            Integer counter = 1;
            
            for(String s : positioningValuesSplitList) {
                if(mapPositionings.containsKey(s)) {
                    mapPositionings.put(s, mapPositionings.get(s) + 1);
                } else {
                    mapPositionings.put(s, counter);
                }
            }
        }
    }
    
    public List<PositioningBarData> getPositioningBarData() { 
        positioningCount();
        List<PositioningBarData> newBardata = new List<PositioningBarData>();
        if(!(allPositioningValuesList.isEmpty() ) && !(relatedProductsList.isEmpty())) {
            //if(!(relatedProductsList.isEmpty() )) {
                for(String s : allPositioningValuesList) {
                    if(mapPositionings.get(s) != null) {
                            newBardata.add(new PositioningBarData(s, mapPositionings.get(s)));
                    } else {
                        newBardata.add(new PositioningBarData(s, 0));
                    }
                }
            //}
        }
        return newBardata;
    }  

    public class PositioningBarData {  
        public String positions { get; set; }  
        public Integer posNum { get; set; }  
        
        public PositioningBarData(String positions, Integer posNum) {  
            this.positions = positions;  
            this.posNum = posNum;  
        }  
    }
    /***        Positioning END  ***/
}