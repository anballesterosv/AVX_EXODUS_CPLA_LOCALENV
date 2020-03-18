/**
@Author Siva
@name CPG_OpportunityProductGroupTriggerHelper
@CreateDate Sept 1, 2017
@Description Helper class for Product group trigger
@Version <1.0>
@reference CPG_OpportunityProductGroupTriger
@Modifiedby : Vaishali, 
@ModifiedDate: Sept 5, 2017
@Modifiedby : Sri harshitha Bandi, 
@ModifiedDate: Oct 11, 2019
*/ 
public with sharing class CPG_OpportunityProductGroupTriggerHelper{
/**
@Methodname rollupTrigger
@CreateDate Sept 1, 2017
@Description This method will calculate sum of volume/quantity for all associated product group records
@Version <1.0>
*/ 
    public static void rollupTrigger(list<Product_Group__c> records){
        set<Id> opportunityIds = new set<Id>();
        Double vouleSum;
        Boolean bHasProd=false;
        for(Product_Group__c item:records){
            opportunityIds.add(item.Opportunity__c);
        } 
        map<id,Double> opportunityMap = new map<id,Double>();
        for(AggregateResult q : [select Opportunity__c,sum(Volume__c) from Product_Group__c where Opportunity__c IN :opportunityIds group by Opportunity__c]){
              system.debug('@@@Q--->'+Q);
              opportunityMap.put((Id)q.get('Opportunity__c'),(Double)q.get('expr0'));
              bHasProd=true;
              
        }
       
        //List<AggregateResult> argList =[select Opportunity__c,count(id) cnt from Product_Group__c where Opportunity__c IN :opportunityIds group by Opportunity__c];
       /* map<id,Integer> oppProdMap = new map<id,Integer>();
        for(AggregateResult q : [select Opportunity__c,count(id) cnt from Product_Group__c where Opportunity__c IN :opportunityIds group by Opportunity__c]){
              oppProdMap.put((Id)q.get('Opportunity__c'),(Integer)q.get('expr0'));
        }*/
       
        List<opportunity> opportunitiesToUpdate = new List<opportunity>();
        for(Opportunity op : [Select Id, Volume__c ,HasOpportunityLineItem,HasOpportunityProductGroup__c from Opportunity where Id IN :opportunityIds]){
            if(!op.HasOpportunityLineItem){
                if (opportunityMap.containsKey(op.Id)){
                    vouleSum= opportunityMap.get(op.Id);
                    system.debug ('@@@vouleSum--->'+vouleSum);
                    bHasProd=true;
                }
                system.debug ('@@@opp--->'+op +'-'+bHasProd);
                If(nullCheckForVolSum(vouleSum)){
                    op.Volume__c = vouleSum;
                }
                else{
                     op.Volume__c=0;
                }
                op.HasOpportunityProductGroup__c=bHasProd;
                opportunitiesToUpdate.add(op);
                system.debug ('@@@hasPRODGroup--->'+op.HasOpportunityProductGroup__c);
            }
        }
 
        database.update(opportunitiesToUpdate,false);
    }
    private static Boolean nullCheckForVolSum(Double vouleSum){
        return (vouleSum!=null);
    }
    
}