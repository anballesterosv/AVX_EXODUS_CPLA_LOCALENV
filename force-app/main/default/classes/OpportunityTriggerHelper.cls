/*****************************************************************************************************************************
Author:sanhita.hegde
Description: Helps MasterOpp trigger
name :OpportunityTriggerHelper 
*********************************************************************************************************************************/
public with Sharing class  OpportunityTriggerHelper {
    Private List<Opportunity> newOppList = new List<Opportunity>();
    Private map<id,opportunity> mapOfOpportunities = new map<id,opportunity>();
    /*****************************************************************************************************************************
Author:sanhita.hegde
Description: Helps MasterOpp trigger
name :OpportunityTriggerHelper constructor
*********************************************************************************************************************************/
    public OpportunityTriggerHelper( List<Opportunity> newTriggerList,map<id,opportunity>mapOftrigger){
        newOppList = newTriggerList ;
        mapOfOpportunities = mapOftrigger;
    }
    
    /*****************************************************************************************************************************
Author:sanhita.hegde
Description: Populate the Business__c  field on opprtunity by cargill_Business_Unit__c  from owner user record.
method name : populateBisiness()
*********************************************************************************************************************************/
    public void populateBisiness(){
        try{
            List<Id> taskOwnerId = new List<Id>();
            For(Opportunity t:newOppList){
                taskOwnerId.add(t.OwnerId);
            }
            Map<Id,String> userBusiness = new Map<Id,String>();
            //get the assigned users from user records
            
            for(User u:[select Id,cargill_Business_Unit__c from User where Id IN : taskOwnerId LIMIT 10000]){
                userBusiness.put(u.Id,u.cargill_Business_Unit__c);
            }
            
            //Get the business records with the same name mentioned in User record
            Map<String, Id>businessUnitMap = new Map<String, Id>();
            for(Business__c bUnit : [select Id,Name from Business__c where Name IN:userBusiness.Values() LIMIT 10000]){
                businessUnitMap.put(bUnit.Name, bUnit.Id);
            }
            For(Opportunity t:newOppList){
                if(t.Business__c == null){
                    t.Business__c =businessUnitMap.get(userBusiness.get(t.OwnerId));
                }
            }   
        }
        catch(Exception e){
            throw e;
        }
        
        
    }
    
    public void populateoriginalName(){
        For(Opportunity ot:newOppList){
            if(ot.OriginalName__c== null){
                ot.OriginalName__c =ot.Name;
                
            }
            
        }
    }
    
    /*****************************************************************************************************************************
Author:Cognizant
Description: Pricing Date Validation on Opportunity
method name : IsPrimaryQuoteExists()
*********************************************************************************************************************************/   
    
    public void  IsPrimaryQuoteExists(){
        //system.debug('@mapOfOpportunities'+mapOfOpportunities);
        
        set<Id> OppIdSet;
        if(mapOfOpportunities!=null){
            OppIdSet=mapOfOpportunities.keyset();
        }
        Map<Id,CameleonCPQ__Quote__c> qtMap=new Map<Id,CameleonCPQ__Quote__c>();
        for(CameleonCPQ__Quote__c qt:[Select Id,OpportunityId__c from CameleonCPQ__Quote__c where OpportunityId__c IN:OppIdSet]){
            qtMap.put(qt.OpportunityId__c,qt);
        }
        //system.debug('@qtMap'+ qtMap);
        //system.debug('@newOppList'+ newOppList);
        For(Opportunity oppt:newOppList){
            if(!qtMap.isEmpty() && qtMap.containsKey(oppt.Id)){
                oppt.Number_of_Related_Quotes__c=1;
            }
        }
        
    }
    /*****************************************************************************************************************************
Author:Cognizant
Description: Update Volume except Result=lost product items
method name : UpdateWonItemVolume()
*********************************************************************************************************************************/   
    
    public void  UpdateWonItemVolume(){
        /*set<id>oppIds = new set<id>();
        for(Opportunity oppt:newOppList){
            oppIds.add(oppt.id); 
        }*/
        
        //List<OpportunityLineItem> oli = new List<OpportunityLineItem>();
        //oli = [select id,name from OpportunityLineItem where id IN: oppIds];
        for(Opportunity oppt:newOppList){
            System.debug('Before loop - HasOpportunityLineItem: '+oppt.HasOpportunityLineItem);
            if(oppt.HasOpportunityLineItem){   //oppt.HasOpportunityLineItem
                oppt.Volume__c=oppt.WonItemVolume__c;
                oppt.Opportunity_Revenue__c=oppt.WonItemRevenue__c;
                system.debug('*****oppt.Volume__c='+oppt.Volume__c);
            }
            
        }
        
    }
    
    // The below method is created by Sri Harshitha Bandi as per the user story with VSTS #42722.
    // This method is used to prevent the deletion os Opportunities if it has one or more CMRs associated to it.
    public void blockOppDeletionWithCMRs(List<Opportunity> lstOldOpps, Map<Id,Opportunity> mapOldOpps) {
        Set<ID> oppIds = new Set<ID>();
        for(CustomerMeetingReportOpp__c cmro : [SELECT Opportunity__c FROM CustomerMeetingReportOpp__c Where Opportunity__c IN :lstOldOpps])
            oppIds.add(cmro.Opportunity__c);
        for(Opportunity opp : lstOldOpps){
            if(oppIds.contains(opp.ID))
                opp.addError('You cannot delete this Opportunity as it has one or more Customer Meeting Reports attached to it.');
        }
    }
    
}