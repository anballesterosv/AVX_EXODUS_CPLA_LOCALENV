/*****************************************************************************************************************************
Author:sanhita.hegde
Description: Helps ProductRestriction trigger
name :OppTeamMemberTriggerHelper 
****************************************************************************************************************************/
public with sharing class projectProductHandler{
    Private List<ProjectProduct__c > newOppList = new List<ProjectProduct__c >();
    Private static final string ERRORMSG = 'You can only add Products from the Opportunity as a Project Product';
    /*****************************************************************************************************************************
Author:sanhita.hegde
Description: Helps MasterOpp trigger
name :OppTeamMemberTriggerHelper 
****************************************************************************************************************************/
    public projectProductHandler( List<ProjectProduct__c > newTriggerList){
        newOppList = newTriggerList ;
    }
    /*****************************************************************************************************************************
Author:sanhita.hegde
Description: It will add the members to the realted project team when opportunity member gets added.
name :addProjectTeam 
****************************************************************************************************************************/
    public void restrictionProduct(){
        List<Id> projectIds = new List<Id>();
        For(ProjectProduct__c pp:newOppList ){
            projectIds.add(pp.Project__c);
        }
        List<Id> holdOppId = new List<Id>();
        for(Project__c p: [select Opportunity__c from Project__c where Id In: projectIds]){
            holdOppId.add(p.Opportunity__c);
        }
        
        Set<Id> listSet = new Set<Id>();
        for(OpportunityLineItem op: [select Product2Id from OpportunityLineItem where OpportunityId In: holdOppId]){
            listSet.add(op.Product2Id);
            
        }
        
        For(ProjectProduct__c pp:newOppList){
            If(listSet.Contains(pp.Product__c)){
            }
            else{
                pp.addError(ERRORMSG);
            }
            
            
        }
        
        
    }
    
}